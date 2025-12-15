BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-what-makes-a-musical-expert-1433'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-what-makes-a-musical-expert-1433';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-what-makes-a-musical-expert-1433';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-what-makes-a-musical-expert-1433';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('6dd7547f-47a8-521a-987d-a878faf16f9d', 'ielts-reading-what-makes-a-musical-expert-1433', $t$What makes a musical expert?$t$, $md$## What makes a musical expert?

Nguồn:
- Test: https://mini-ielts.com/1433/reading/what-makes-a-musical-expert
- Solution: https://mini-ielts.com/1433/view-solution/reading/what-makes-a-musical-expert$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('c33c0d4c-87db-53d0-a95c-8511dc1a96e3', '6dd7547f-47a8-521a-987d-a878faf16f9d', 1, $t$Reading — What makes a musical expert?$t$, $md$Read the passage and answer questions **1–14**.

### Passage: What makes a musical expert?

How does someone become expert in music? And IS it really possible to have a ‘talent’ for music?

Does that class of people acknowledged to be musical experts just have more of the same basic skills we are all endowed with, or do they have a set of abilities - or neural structures - that are totally different from those of the rest of US? Are high levels of musical achievement simply the result of training and practice, or are they based on innate brain structure - what we refer to as ‘talent’? Talent can be defined as something that originates in genetic structures and that is identifiable by trained people who can recognize its existence before a person has achieved exceptional levels of performance. The emphasis on early identification means that to investigate it, we study the development of skills in children.

It is evident that some children acquire skills more rapidly than others: the age of onset for walking and talking varies widely, even between children in the same household. There may be genetic factors at work, but these are closely linked with other factors - with a presumably environmental component - such as motivation and family dynamics. Similar factors can influence musical development and can mask the contribution of genetics to musical ability.

Brain studies, so far, haven’t been of much use in sorting out the issues. Gottfried Schlaug at Harvard collected brain scans of individuals with absolute pitch (AP) and showed that a region in the brain called the planum temporale is larger in these people than in others. This suggests that the planum is involved in AP, but it’s not clear if it starts out larger in people who eventually acquire AP, or if the acquisition of AP makes the planum increase in size.

Results of research into the areas of the brain involved in skilled motor movement are more conclusive. Studies of violin players have shown that the region of the brain responsible for controlling the movement of the left hand (the hand that requires greater precision in violin playing) increases in size as a result of practice. We do not know yet if the propensity for increase pre-exists in some-peopled not others.

The evidence against talent comes from research on how much training the experts do. Like experts in mathematics, chess, or sports, experts in music require lengthy periods of instruction and practice. In several studies, the very best music students

Were found to have practiced more than twice as much as the others. In another study, students were secretly divided into two groups based on teachers’ perceptions of their talent. Several years later, it was found that the students who achieved the highest performance ratings had practiced the most, irrespective of which ‘talent’ group they had been assigned to, suggesting that practice does not merely correlate with achievement, but causes it.

Anders Ericsson, at Florida state University, approaches the topic of musical expertise as a general problem in cognitive psychology. He takes as a starting point the assumption that there are certain issues involved in becoming an expert at anything; that we can learn about musical expertise by studying expert chess players, athletes, artists, mathematicians, as well as the musicians themselves. The emerging picture from such studies is that ten thousand hours of practice is required to achieve the level of mastery associated with being a world-class expert - in anything. In study after study, of composers, ice skaters, concert pianists, chess players and master criminals, this number comes up again and again. Someone would do this amount of practice if they practiced, for example, roughly 20 hours a week for ten years. Of course, this does not address why some people do not seem to get anywhere when they practice, and why some people get more out of their practice sessions than others. But no-one has yet found a case in which true world-class expertise was accomplished in less time. It seems that it takes the brain this long to assimilate all that it needs to know to achieve true mastery.

The ten-thousand-hour theory is consistent with what we know about how the brain learns. Learning requires the assimilation and consolidation of information in neural tissue. The more experiences we have with something, the stronger the memory/learning trace for that experience becomes. Although people differ in how long it takes them to consolidate information neutrally, it remains true that increased practice leads to a greater number of neural traces, which create stronger memory representation.

The classic rebuttal to this theory goes something like this: ‘What about Mozart? I hear that he composed his first symphony at the age of four!’ First, there is a factual error here: Mozart did not write it until he was eight, still, this is unusual, to say the least. However, this early work received little acclaim and was not performed very often. In fact, the only reason we know about it is because the child who wrote it grew up to become Mozart. And Mozart had an expert teacher in his father, who was renowned as a teacher of musicians all over Europe. We do not know how much Mozart practiced, but if he started at age two and worked thirty- two hours a week (quite possible, given that his father was a stern taskmaster) he would have made his ten thousand hours by the time he composed his first symphony. This does not mean that there are no genetic factors involved in Mozart’s greatness, but that inborn traits may not be the only cause.

[1] individuals with absolute pitch: people who can identify or sing any musical note correctly without help$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('12451778-d178-5032-8aed-b9138848e648', 'c33c0d4c-87db-53d0-a95c-8511dc1a96e3', 1, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 1

Questions 1-4
Questions 1-4
Choose the correct letter,
A, B, c
or
D.
Write the correct letter in boxes 1-4 on your answer sheet.
1. In the first paragraph, the writer suggests that a musician who IS talented someone
A
who is aware of being set apart from other people.
B
whose brain structure is unlike that of other people,
C
who can perform extremely well in early childhood.
D
whose essential skills are more varied than those of ordinary people.
2. According to the writer, what is unclear about the findings of Gottfried Schlaug?
A
which part of the brain is linked to a particular musical skill.
B
which type of musical skill leads to the greatest change in the brain.
C
whether a feature of the brain is a cause or an effect of a musical skill.
D
whether the acquisition of a musical skill is easier for some people than others.
3. According to the writer, what has been established by studies of violin players?
A
Changes may occur in the brain following violin practice.
B
Left-handed violinists have a different brain structure from other people,
C
A violinist’s hand size is not due to practice but to genetic factors.
D
Violinists are born with brains that have a particular structure
4. According to the writer, findings on the amount of practices done by expert musicians suggest that
A
talent may have little to do with expertise.
B
practice may actually prevent the development of talent.
C
talent may not be recognised by teachers.
D
expertise may be related to quality of instruction.

Choose the correct letter, A, B, c or D.$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('dc889658-0b16-51f0-9ce3-3ad6e5fe0ce5', 'c33c0d4c-87db-53d0-a95c-8511dc1a96e3', 2, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 2

Questions 1-4
Questions 1-4
Choose the correct letter,
A, B, c
or
D.
Write the correct letter in boxes 1-4 on your answer sheet.
1. In the first paragraph, the writer suggests that a musician who IS talented someone
A
who is aware of being set apart from other people.
B
whose brain structure is unlike that of other people,
C
who can perform extremely well in early childhood.
D
whose essential skills are more varied than those of ordinary people.
2. According to the writer, what is unclear about the findings of Gottfried Schlaug?
A
which part of the brain is linked to a particular musical skill.
B
which type of musical skill leads to the greatest change in the brain.
C
whether a feature of the brain is a cause or an effect of a musical skill.
D
whether the acquisition of a musical skill is easier for some people than others.
3. According to the writer, what has been established by studies of violin players?
A
Changes may occur in the brain following violin practice.
B
Left-handed violinists have a different brain structure from other people,
C
A violinist’s hand size is not due to practice but to genetic factors.
D
Violinists are born with brains that have a particular structure
4. According to the writer, findings on the amount of practices done by expert musicians suggest that
A
talent may have little to do with expertise.
B
practice may actually prevent the development of talent.
C
talent may not be recognised by teachers.
D
expertise may be related to quality of instruction.

Choose the correct letter, A, B, c or D.$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('272f06e5-6928-5637-bb2a-af6915b00bfd', 'c33c0d4c-87db-53d0-a95c-8511dc1a96e3', 3, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 3

Questions 1-4
Questions 1-4
Choose the correct letter,
A, B, c
or
D.
Write the correct letter in boxes 1-4 on your answer sheet.
1. In the first paragraph, the writer suggests that a musician who IS talented someone
A
who is aware of being set apart from other people.
B
whose brain structure is unlike that of other people,
C
who can perform extremely well in early childhood.
D
whose essential skills are more varied than those of ordinary people.
2. According to the writer, what is unclear about the findings of Gottfried Schlaug?
A
which part of the brain is linked to a particular musical skill.
B
which type of musical skill leads to the greatest change in the brain.
C
whether a feature of the brain is a cause or an effect of a musical skill.
D
whether the acquisition of a musical skill is easier for some people than others.
3. According to the writer, what has been established by studies of violin players?
A
Changes may occur in the brain following violin practice.
B
Left-handed violinists have a different brain structure from other people,
C
A violinist’s hand size is not due to practice but to genetic factors.
D
Violinists are born with brains that have a particular structure
4. According to the writer, findings on the amount of practices done by expert musicians suggest that
A
talent may have little to do with expertise.
B
practice may actually prevent the development of talent.
C
talent may not be recognised by teachers.
D
expertise may be related to quality of instruction.

Choose the correct letter, A, B, c or D.$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('acb2f439-2a2d-5c11-86d5-43a675c68391', 'c33c0d4c-87db-53d0-a95c-8511dc1a96e3', 4, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 4

Questions 1-4
Questions 1-4
Choose the correct letter,
A, B, c
or
D.
Write the correct letter in boxes 1-4 on your answer sheet.
1. In the first paragraph, the writer suggests that a musician who IS talented someone
A
who is aware of being set apart from other people.
B
whose brain structure is unlike that of other people,
C
who can perform extremely well in early childhood.
D
whose essential skills are more varied than those of ordinary people.
2. According to the writer, what is unclear about the findings of Gottfried Schlaug?
A
which part of the brain is linked to a particular musical skill.
B
which type of musical skill leads to the greatest change in the brain.
C
whether a feature of the brain is a cause or an effect of a musical skill.
D
whether the acquisition of a musical skill is easier for some people than others.
3. According to the writer, what has been established by studies of violin players?
A
Changes may occur in the brain following violin practice.
B
Left-handed violinists have a different brain structure from other people,
C
A violinist’s hand size is not due to practice but to genetic factors.
D
Violinists are born with brains that have a particular structure
4. According to the writer, findings on the amount of practices done by expert musicians suggest that
A
talent may have little to do with expertise.
B
practice may actually prevent the development of talent.
C
talent may not be recognised by teachers.
D
expertise may be related to quality of instruction.

Choose the correct letter, A, B, c or D.$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('237dbb69-04a6-5c5f-a9c8-3a53d6be16f9', 'c33c0d4c-87db-53d0-a95c-8511dc1a96e3', 5, 'YES_NO_NOT_GIVEN', 'READING', 3, $md$### Question 5

Questions 5-10
Questions 5-10
Do the following statements agree with the claims of the writer in Reading Passage?
In boxes 5-10 on your answer sheet, write
YES
if the statement agrees with the claims of the writer
NO
if the statement contradicts the claims of the writer
NOT GIVEN
if it is impossible to say what the writer thinks about this
5
Anders Ericsson's work with cognitive psychology has influenced other researchers.
6
Different areas of expertise seem to have one specific thing in common.
7
In order to be useful, practice must be carried out regularly every day.
8
Anyone who practices for long enough can reach the level of a world-class expert.
9
Occasionally, someone can become an expert at global level with fewer than 10,000 hours' practice.
10
Existing knowledge of learning and cognitive skills supports the importance of practice.

5 ____ Anders Ericsson's work with cognitive psychology has influenced other researchers.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7000921e-156a-5bcb-9dfa-6fd81f7d43a0', '237dbb69-04a6-5c5f-a9c8-3a53d6be16f9', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8bc77842-eecd-5255-b0a3-d67c7f3ca8ab', '237dbb69-04a6-5c5f-a9c8-3a53d6be16f9', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('221b823a-885a-5980-84d0-d0c9b4aa740b', '237dbb69-04a6-5c5f-a9c8-3a53d6be16f9', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('e976ccf3-36e2-5361-947a-25b1a471ba54', 'c33c0d4c-87db-53d0-a95c-8511dc1a96e3', 6, 'YES_NO_NOT_GIVEN', 'READING', 3, $md$### Question 6

Questions 5-10
Questions 5-10
Do the following statements agree with the claims of the writer in Reading Passage?
In boxes 5-10 on your answer sheet, write
YES
if the statement agrees with the claims of the writer
NO
if the statement contradicts the claims of the writer
NOT GIVEN
if it is impossible to say what the writer thinks about this
5
Anders Ericsson's work with cognitive psychology has influenced other researchers.
6
Different areas of expertise seem to have one specific thing in common.
7
In order to be useful, practice must be carried out regularly every day.
8
Anyone who practices for long enough can reach the level of a world-class expert.
9
Occasionally, someone can become an expert at global level with fewer than 10,000 hours' practice.
10
Existing knowledge of learning and cognitive skills supports the importance of practice.

6 ____ Different areas of expertise seem to have one specific thing in common.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8cc37384-9177-50a5-ae87-42bd89776938', 'e976ccf3-36e2-5361-947a-25b1a471ba54', 1, $md$YES$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('12e29518-4f96-5307-ba78-54408f6a9f3b', 'e976ccf3-36e2-5361-947a-25b1a471ba54', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f29383be-427e-5a27-af2b-2140e5306598', 'e976ccf3-36e2-5361-947a-25b1a471ba54', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('956289ee-1ed9-5ec4-aec8-e9de8ccb52f5', 'c33c0d4c-87db-53d0-a95c-8511dc1a96e3', 7, 'YES_NO_NOT_GIVEN', 'READING', 3, $md$### Question 7

Questions 5-10
Questions 5-10
Do the following statements agree with the claims of the writer in Reading Passage?
In boxes 5-10 on your answer sheet, write
YES
if the statement agrees with the claims of the writer
NO
if the statement contradicts the claims of the writer
NOT GIVEN
if it is impossible to say what the writer thinks about this
5
Anders Ericsson's work with cognitive psychology has influenced other researchers.
6
Different areas of expertise seem to have one specific thing in common.
7
In order to be useful, practice must be carried out regularly every day.
8
Anyone who practices for long enough can reach the level of a world-class expert.
9
Occasionally, someone can become an expert at global level with fewer than 10,000 hours' practice.
10
Existing knowledge of learning and cognitive skills supports the importance of practice.

7 ____ In order to be useful, practice must be carried out regularly every day.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8f50d03a-9db5-5cc1-8fda-1fc038cb274f', '956289ee-1ed9-5ec4-aec8-e9de8ccb52f5', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b407c9bc-9c2f-5f12-b8d2-3aef1ae04e59', '956289ee-1ed9-5ec4-aec8-e9de8ccb52f5', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('707fde4a-ebe3-515f-96e9-fb36f1a4b361', '956289ee-1ed9-5ec4-aec8-e9de8ccb52f5', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('c00a31f1-29e8-5015-840b-8fcc6e82a62a', 'c33c0d4c-87db-53d0-a95c-8511dc1a96e3', 8, 'YES_NO_NOT_GIVEN', 'READING', 3, $md$### Question 8

Questions 5-10
Questions 5-10
Do the following statements agree with the claims of the writer in Reading Passage?
In boxes 5-10 on your answer sheet, write
YES
if the statement agrees with the claims of the writer
NO
if the statement contradicts the claims of the writer
NOT GIVEN
if it is impossible to say what the writer thinks about this
5
Anders Ericsson's work with cognitive psychology has influenced other researchers.
6
Different areas of expertise seem to have one specific thing in common.
7
In order to be useful, practice must be carried out regularly every day.
8
Anyone who practices for long enough can reach the level of a world-class expert.
9
Occasionally, someone can become an expert at global level with fewer than 10,000 hours' practice.
10
Existing knowledge of learning and cognitive skills supports the importance of practice.

8 ____ Anyone who practices for long enough can reach the level of a world-class expert.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('09423c42-c2c9-5b25-8d55-98614cf77b53', 'c00a31f1-29e8-5015-840b-8fcc6e82a62a', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6e86ffdd-5b2c-5e53-9e50-543d3064c8a4', 'c00a31f1-29e8-5015-840b-8fcc6e82a62a', 2, $md$NO$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7d691247-b860-5022-9f10-a9b0eb0dd3ea', 'c00a31f1-29e8-5015-840b-8fcc6e82a62a', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('90ddb4ce-bc93-546a-8af2-d82200ea1954', 'c33c0d4c-87db-53d0-a95c-8511dc1a96e3', 9, 'YES_NO_NOT_GIVEN', 'READING', 3, $md$### Question 9

Questions 5-10
Questions 5-10
Do the following statements agree with the claims of the writer in Reading Passage?
In boxes 5-10 on your answer sheet, write
YES
if the statement agrees with the claims of the writer
NO
if the statement contradicts the claims of the writer
NOT GIVEN
if it is impossible to say what the writer thinks about this
5
Anders Ericsson's work with cognitive psychology has influenced other researchers.
6
Different areas of expertise seem to have one specific thing in common.
7
In order to be useful, practice must be carried out regularly every day.
8
Anyone who practices for long enough can reach the level of a world-class expert.
9
Occasionally, someone can become an expert at global level with fewer than 10,000 hours' practice.
10
Existing knowledge of learning and cognitive skills supports the importance of practice.

9 ____ Occasionally, someone can become an expert at global level with fewer than 10,000 hours' practice.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b4d66079-8a88-54f0-866e-066eb7ded703', '90ddb4ce-bc93-546a-8af2-d82200ea1954', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6af34920-473d-5b24-ae0b-05956ea533b2', '90ddb4ce-bc93-546a-8af2-d82200ea1954', 2, $md$NO$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b7756279-31e2-5c2f-b9f4-dbd7721768f8', '90ddb4ce-bc93-546a-8af2-d82200ea1954', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('4d184b55-a5e1-5edd-8914-a93c03d7c882', 'c33c0d4c-87db-53d0-a95c-8511dc1a96e3', 10, 'YES_NO_NOT_GIVEN', 'READING', 4, $md$### Question 10

Questions 5-10
Questions 5-10
Do the following statements agree with the claims of the writer in Reading Passage?
In boxes 5-10 on your answer sheet, write
YES
if the statement agrees with the claims of the writer
NO
if the statement contradicts the claims of the writer
NOT GIVEN
if it is impossible to say what the writer thinks about this
5
Anders Ericsson's work with cognitive psychology has influenced other researchers.
6
Different areas of expertise seem to have one specific thing in common.
7
In order to be useful, practice must be carried out regularly every day.
8
Anyone who practices for long enough can reach the level of a world-class expert.
9
Occasionally, someone can become an expert at global level with fewer than 10,000 hours' practice.
10
Existing knowledge of learning and cognitive skills supports the importance of practice.

10 ____ Existing knowledge of learning and cognitive skills supports the importance of practice.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('57fb6738-e13a-50fc-98d4-59a347a3b7d9', '4d184b55-a5e1-5edd-8914-a93c03d7c882', 1, $md$YES$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cf8a7529-0318-5172-9b02-018996bd92f3', '4d184b55-a5e1-5edd-8914-a93c03d7c882', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6eb9153d-f3ad-5f67-8fcf-0a80e72e4d78', '4d184b55-a5e1-5edd-8914-a93c03d7c882', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('3e381371-ccce-5bc7-b4d5-679541136ad1', 'c33c0d4c-87db-53d0-a95c-8511dc1a96e3', 11, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 11

Questions 12-14
Questions 12-14
Complete the summary using the list of words, A-J, below.
Write the correct letter, A-J, in boxes 12-14 on your answer sheet.
Mozart
The case of Mozart could be quoted as evidence against the 10,000-hour-practice theory. However, the writer points out that the young Mozart received a lot of
11
from his father, and that the symphony he wrote at the age of
12
was not
13
and may be of only academic interest. The case therefore supports the view that expertise is not solely the result of
14
characteristics.
A
popular
B
artistic
c
completed
D
eight
E
tuition
F
encouragement
G
inherited
H
four
1
practice
J
two

The case of Mozart could be quoted as evidence against the 10,000-hour-practice theory. However, the writer points out that the young Mozart received a lot of 11 ____ from his father, and that the symphony he wrote at the age of 12 ____ was not 13 ____ and may be of only academic interest. The case therefore supports the view that expertise is not solely the result of 14 ____ characteristics.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ba3ee6b0-f3ed-5882-8a6c-d6de0d148cb5', '3e381371-ccce-5bc7-b4d5-679541136ad1', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8951e075-9588-50d6-87ca-d976e81dbaeb', '3e381371-ccce-5bc7-b4d5-679541136ad1', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9c336f91-6738-5cc1-ad8d-9c26c90bf7da', '3e381371-ccce-5bc7-b4d5-679541136ad1', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8a7ffa95-4064-59fc-b48e-c897b9c145da', '3e381371-ccce-5bc7-b4d5-679541136ad1', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('751ee985-d81d-53ec-9647-319f88e5dde4', '3e381371-ccce-5bc7-b4d5-679541136ad1', 5, $md$E$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9184e1ec-8ab6-57b2-9c25-86c51d6404b0', '3e381371-ccce-5bc7-b4d5-679541136ad1', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7e13f5c1-6f11-5c1f-abd6-fce637d9bb4d', '3e381371-ccce-5bc7-b4d5-679541136ad1', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f76d2a84-fb91-570f-9e37-30708787ed39', '3e381371-ccce-5bc7-b4d5-679541136ad1', 8, $md$H$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('58be7e0b-149f-581f-8a6d-9b623ea0c268', '3e381371-ccce-5bc7-b4d5-679541136ad1', 9, $md$I$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('491fa396-4739-5a1a-8ed2-1d0fc7c6e598', '3e381371-ccce-5bc7-b4d5-679541136ad1', 10, $md$J$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('d7b38b61-a7cc-5b23-858a-cf4344bafcc3', 'c33c0d4c-87db-53d0-a95c-8511dc1a96e3', 12, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 12

Questions 12-14
Questions 12-14
Complete the summary using the list of words, A-J, below.
Write the correct letter, A-J, in boxes 12-14 on your answer sheet.
Mozart
The case of Mozart could be quoted as evidence against the 10,000-hour-practice theory. However, the writer points out that the young Mozart received a lot of
11
from his father, and that the symphony he wrote at the age of
12
was not
13
and may be of only academic interest. The case therefore supports the view that expertise is not solely the result of
14
characteristics.
A
popular
B
artistic
c
completed
D
eight
E
tuition
F
encouragement
G
inherited
H
four
1
practice
J
two

The case of Mozart could be quoted as evidence against the 10,000-hour-practice theory. However, the writer points out that the young Mozart received a lot of 11 ____ from his father, and that the symphony he wrote at the age of 12 ____ was not 13 ____ and may be of only academic interest. The case therefore supports the view that expertise is not solely the result of 14 ____ characteristics.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9450f78b-6cef-54bf-8d6a-15e7942ca4f2', 'd7b38b61-a7cc-5b23-858a-cf4344bafcc3', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2c4b2914-bd41-5b50-b5ec-12902170b931', 'd7b38b61-a7cc-5b23-858a-cf4344bafcc3', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f97c46ef-ca30-50a4-baaa-63a551e0959b', 'd7b38b61-a7cc-5b23-858a-cf4344bafcc3', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1f3f5ca8-25d6-5ab5-bc66-14e5f2ecbb2f', 'd7b38b61-a7cc-5b23-858a-cf4344bafcc3', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('248ce64b-da02-56cd-9812-3c6927c83db8', 'd7b38b61-a7cc-5b23-858a-cf4344bafcc3', 5, $md$E$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('97609d27-fe85-5d89-98b8-6b97472d7ac3', 'd7b38b61-a7cc-5b23-858a-cf4344bafcc3', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('096fb373-abe5-5749-aa24-e4855a105ec6', 'd7b38b61-a7cc-5b23-858a-cf4344bafcc3', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2817124a-daab-575a-8478-64f5f2f010f2', 'd7b38b61-a7cc-5b23-858a-cf4344bafcc3', 8, $md$H$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ba4407ec-07bc-5c26-a2bf-1a9e8c2b3233', 'd7b38b61-a7cc-5b23-858a-cf4344bafcc3', 9, $md$I$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('025a577c-2717-5c99-9fdf-cdef6bae2a22', 'd7b38b61-a7cc-5b23-858a-cf4344bafcc3', 10, $md$J$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('3fc7d87e-dbbe-54b9-9c1c-8a34fbc41fcf', 'c33c0d4c-87db-53d0-a95c-8511dc1a96e3', 13, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 13

Questions 12-14
Questions 12-14
Complete the summary using the list of words, A-J, below.
Write the correct letter, A-J, in boxes 12-14 on your answer sheet.
Mozart
The case of Mozart could be quoted as evidence against the 10,000-hour-practice theory. However, the writer points out that the young Mozart received a lot of
11
from his father, and that the symphony he wrote at the age of
12
was not
13
and may be of only academic interest. The case therefore supports the view that expertise is not solely the result of
14
characteristics.
A
popular
B
artistic
c
completed
D
eight
E
tuition
F
encouragement
G
inherited
H
four
1
practice
J
two

The case of Mozart could be quoted as evidence against the 10,000-hour-practice theory. However, the writer points out that the young Mozart received a lot of 11 ____ from his father, and that the symphony he wrote at the age of 12 ____ was not 13 ____ and may be of only academic interest. The case therefore supports the view that expertise is not solely the result of 14 ____ characteristics.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c8509a6f-e392-59f4-bed0-ef35bb6db59e', '3fc7d87e-dbbe-54b9-9c1c-8a34fbc41fcf', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b2d5caec-6ca7-5e45-8c62-9b137db0fcb8', '3fc7d87e-dbbe-54b9-9c1c-8a34fbc41fcf', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('21c4b0f4-625b-57f8-8f1e-c1b3ddb92ddc', '3fc7d87e-dbbe-54b9-9c1c-8a34fbc41fcf', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1ede4db3-940b-5cf3-a82f-5aa45fe2b38a', '3fc7d87e-dbbe-54b9-9c1c-8a34fbc41fcf', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('efd82563-4013-53f6-be55-1ee60851816e', '3fc7d87e-dbbe-54b9-9c1c-8a34fbc41fcf', 5, $md$E$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6e5cf4e8-1395-574f-a99b-f6cccf1e2db9', '3fc7d87e-dbbe-54b9-9c1c-8a34fbc41fcf', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('17c800cf-3827-5b9b-a20a-01eff6ebd906', '3fc7d87e-dbbe-54b9-9c1c-8a34fbc41fcf', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('550fb68a-9153-584b-99f4-51e33d762644', '3fc7d87e-dbbe-54b9-9c1c-8a34fbc41fcf', 8, $md$H$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('acb67c23-2612-519d-b7cf-8bf9f9e87a61', '3fc7d87e-dbbe-54b9-9c1c-8a34fbc41fcf', 9, $md$I$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8c4a9093-3629-5f75-a3e6-cbce6ee64ae1', '3fc7d87e-dbbe-54b9-9c1c-8a34fbc41fcf', 10, $md$J$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('3575d37d-3a02-5802-b1cf-a2a87ad0fd62', 'c33c0d4c-87db-53d0-a95c-8511dc1a96e3', 14, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 14

Questions 12-14
Questions 12-14
Complete the summary using the list of words, A-J, below.
Write the correct letter, A-J, in boxes 12-14 on your answer sheet.
Mozart
The case of Mozart could be quoted as evidence against the 10,000-hour-practice theory. However, the writer points out that the young Mozart received a lot of
11
from his father, and that the symphony he wrote at the age of
12
was not
13
and may be of only academic interest. The case therefore supports the view that expertise is not solely the result of
14
characteristics.
A
popular
B
artistic
c
completed
D
eight
E
tuition
F
encouragement
G
inherited
H
four
1
practice
J
two

The case of Mozart could be quoted as evidence against the 10,000-hour-practice theory. However, the writer points out that the young Mozart received a lot of 11 ____ from his father, and that the symphony he wrote at the age of 12 ____ was not 13 ____ and may be of only academic interest. The case therefore supports the view that expertise is not solely the result of 14 ____ characteristics.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('18fe9a1e-c78e-5def-9216-a8a0f60e5d38', '3575d37d-3a02-5802-b1cf-a2a87ad0fd62', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('232c6bd2-3cc3-5979-9437-41abef13943c', '3575d37d-3a02-5802-b1cf-a2a87ad0fd62', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b94ee9c6-f7a3-5356-a335-48fba9693dcf', '3575d37d-3a02-5802-b1cf-a2a87ad0fd62', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('557c0aa9-0832-53d9-8538-4fa517df0aaf', '3575d37d-3a02-5802-b1cf-a2a87ad0fd62', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('260ee6f1-28d7-568b-819b-7481b20c8c49', '3575d37d-3a02-5802-b1cf-a2a87ad0fd62', 5, $md$E$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('440f8c55-c97d-5e5a-a924-f9b1403c5750', '3575d37d-3a02-5802-b1cf-a2a87ad0fd62', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b01a7ce5-e30d-5045-9121-a7a57ba65545', '3575d37d-3a02-5802-b1cf-a2a87ad0fd62', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('60c43ee9-65e1-5a8c-b43f-45dfb4f08dd5', '3575d37d-3a02-5802-b1cf-a2a87ad0fd62', 8, $md$H$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('266f19c9-7b3c-5f56-88a0-bdc2bce7a8dc', '3575d37d-3a02-5802-b1cf-a2a87ad0fd62', 9, $md$I$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('196d506b-0c40-5a45-bfb5-42972c4c6605', '3575d37d-3a02-5802-b1cf-a2a87ad0fd62', 10, $md$J$md$, false);

COMMIT;
