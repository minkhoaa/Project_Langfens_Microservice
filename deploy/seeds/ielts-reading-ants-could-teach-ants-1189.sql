BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-ants-could-teach-ants-1189'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-ants-could-teach-ants-1189';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-ants-could-teach-ants-1189';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-ants-could-teach-ants-1189';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('2f06ac00-c19c-5a9e-8f09-730fea76e1a3', 'ielts-reading-ants-could-teach-ants-1189', $t$Ants Could Teach Ants$t$, $md$## Ants Could Teach Ants

Nguồn:
- Test: https://mini-ielts.com/1189/reading/ants-could-teach-ants
- Solution: https://mini-ielts.com/1189/view-solution/reading/ants-could-teach-ants$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('7ba21da0-5199-57d0-85fd-4b4dfc18aa9a', '2f06ac00-c19c-5a9e-8f09-730fea76e1a3', 1, $t$Reading — Ants Could Teach Ants$t$, $md$Read the passage and answer questions **1–9**.

### Passage: Ants Could Teach Ants

The ants are tiny and usually nest between rocks in the south coast of England. Transformed into research subjects at the University of Bristol, they raced along a tabletop foraging for food -and then, remarkably, returned to guide others. Time and again, followers trailed behind leaders, darting this way and that along the route, presumably to memorize land- marks. Once a follower got its bearings, it tapped the leader with its antennae, prompting the lesson to literally proceed to the next step. The ants were only looking for food but the researchers said the careful way the leaders led followers -thereby turning them into leaders in their own right -marked the Temnothorax albipennis ant as the very first example of a non-human animal exhibiting teaching behavior.

"Tandem running is an example of teaching, to our knowledge the first in a non-human animal, that involves bidirectional feedback between teacher and pupil," remarks Nigel Franks, professor of animal behavior and ecology, whose paper on the ant educators was published last week in the journal Nature.

No sooner was the paper published, of course, than another educator questioned it. Marc Hauser, a psychologist and biologist and one of the scientists who came up with the definition of teaching, said it was unclear whether the ants had learned a new skill or merely acquired new information.

Later, Franks took a further study and found that there were even races between leaders. With the guidance of leaders, ants could find food faster. But the help comes at a cost for the leader, who normally would have reached the food about four times faster if not hampered by a follower. This means the hypothesis that the leaders deliberately slowed down in order to pass the skills on to the followers seems potentially valid. His ideas were advocated by the students who carried out the video project with him.

Opposing views still arose, however. Hauser noted that mere communication of information is commonplace in the animal world. Consider a species, for example, that uses alarm calls to warn fellow members about the presence of a predator. Sounding the alarm can be costly, because the animal may draw the attention of the predator to itself. But it allows others to flee to safety. “Would you call this teaching?” wrote Hauser. “The caller incurs a cost. The naive animals gain a benefit and new knowledge that better enables them to learn about the predator’s location than if the caller had not called. This happens throughout the animal kingdom, but we don’t call it teaching, even though it is clearly transfer of information.”

Tim Caro, a zoologist, presented two cases of animal communication. He found that cheetah mothers that take their cubs along on hunts gradually allow their cubs to do more of the hunting -going, for example, from killing a gazelle and allowing young cubs to eat to merely tripping the gazelle and letting the cubs finish it off. At one level, such behavior might be called teaching -except the mother was not really teaching the cubs to hunt but merely facilitating various stages of learning. In another instance, birds watching other birds using a stick to locate food such as insects and so on, are observed to do the same thing themselves while finding food later.

Psychologists study animal behavior in part to understand the evolutionary roots of human behavior, Hauser said. The challenge in understanding whether other animals truly teach one another, he added, is that human teaching involves a “theory of mind” -teachers are aware that students don’t know something. He questioned whether Franks’s leader ants really knew that the follower ants were ignorant. Could they simply have been following an instinctive rule to proceed when the followers tapped them on the legs or abdomen? And did leaders that led the way to food -only to find that it had been removed by the experimenter -incur the wrath of followers? That, Hauser said, would suggest that the follower ant actually knew the leader was more knowledgeable and not merely following an instinctive routine itself.

The controversy went on, and for a good reason. The occurrence of teaching in ants, if proven to be true, indicates that teaching can evolve in animals with tiny brains. It is probably the value of information in social animals that determines when teaching will evolve rather than the constraints of brain size.

Bennett Galef Jr., a psychologist who studies animal behavior and social learning at McMaster University in Canada, maintained that ants were unlikely to have a “theory of mind” -meaning that leader and followers may well have been following instinctive routines that were not based on an understanding of what was happening in another ant’s brain. He warned that scientists may be barking up the wrong tree when they look not only for examples of humanlike behavior among other animals but humanlike thinking that underlies such behavior. Animals may behave in ways similar to humans without a similar cognitive system, he said, so the behavior is not necessarily a good guide into how humans came to think the way they do.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('17ee28fb-4df9-56d8-b86a-2d8a89a6f37e', '7ba21da0-5199-57d0-85fd-4b4dfc18aa9a', 1, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 1

Questions 1-5
Questions 1-5
Look at the following statements (Questions
1-5
) and the list of people in the box below.
Match each statement with the correct person,
A, B, C
or
D
.
Write the correct letter,
A, B, C
or
D
, in boxes
1-5
on your answer sheet.
NB You may use any letter
more than once
.
1
Animals could use objects to locate food.
2
Ants show two-way, interactive teaching behaviors.
3
It is risky to say ants can teach other ants like human beings do.
4
Ant leadership makes finding food faster.
5
Communication between ants is not entirely teaching.
List of People
A
Nigel Franks
B
Marc Hauser
C
Tim Caro
D
Bennett Galef Jr.

1 ____ Animals could use objects to locate food.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1da115ea-abab-565b-9a6b-103c6213cfdf', '17ee28fb-4df9-56d8-b86a-2d8a89a6f37e', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f332984a-fd30-5b6f-9106-369c26cc5e83', '17ee28fb-4df9-56d8-b86a-2d8a89a6f37e', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4ea3bc5c-68d5-5ed7-9dbe-ff6a0f21fbeb', '17ee28fb-4df9-56d8-b86a-2d8a89a6f37e', 3, $md$C$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('512438d9-b388-5cfb-9858-687dfe1e7ac2', '17ee28fb-4df9-56d8-b86a-2d8a89a6f37e', 4, $md$D$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('5560969e-8aa8-5e45-89e4-100495c9a5bb', '7ba21da0-5199-57d0-85fd-4b4dfc18aa9a', 2, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 2

Questions 1-5
Questions 1-5
Look at the following statements (Questions
1-5
) and the list of people in the box below.
Match each statement with the correct person,
A, B, C
or
D
.
Write the correct letter,
A, B, C
or
D
, in boxes
1-5
on your answer sheet.
NB You may use any letter
more than once
.
1
Animals could use objects to locate food.
2
Ants show two-way, interactive teaching behaviors.
3
It is risky to say ants can teach other ants like human beings do.
4
Ant leadership makes finding food faster.
5
Communication between ants is not entirely teaching.
List of People
A
Nigel Franks
B
Marc Hauser
C
Tim Caro
D
Bennett Galef Jr.

2 ____ Ants show two-way, interactive teaching behaviors.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ca3735e2-01f8-562e-9431-c3c3ce95fbdd', '5560969e-8aa8-5e45-89e4-100495c9a5bb', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('76e845f1-97b3-5869-8e07-1161a71e3402', '5560969e-8aa8-5e45-89e4-100495c9a5bb', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('95893c99-711b-50aa-bc58-136ca930e8b2', '5560969e-8aa8-5e45-89e4-100495c9a5bb', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('45c6c939-2d0d-54dc-9252-31e6264b60a5', '5560969e-8aa8-5e45-89e4-100495c9a5bb', 4, $md$D$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('a2f8fbc0-d5b6-50b4-a55f-c69acd1f94e8', '7ba21da0-5199-57d0-85fd-4b4dfc18aa9a', 3, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 3

Questions 1-5
Questions 1-5
Look at the following statements (Questions
1-5
) and the list of people in the box below.
Match each statement with the correct person,
A, B, C
or
D
.
Write the correct letter,
A, B, C
or
D
, in boxes
1-5
on your answer sheet.
NB You may use any letter
more than once
.
1
Animals could use objects to locate food.
2
Ants show two-way, interactive teaching behaviors.
3
It is risky to say ants can teach other ants like human beings do.
4
Ant leadership makes finding food faster.
5
Communication between ants is not entirely teaching.
List of People
A
Nigel Franks
B
Marc Hauser
C
Tim Caro
D
Bennett Galef Jr.

3 ____ It is risky to say ants can teach other ants like human beings do.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1e7837f7-d4bd-5b84-bac9-1639a6de83ef', 'a2f8fbc0-d5b6-50b4-a55f-c69acd1f94e8', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('28b97ab6-873d-5417-877c-4bcae1dfd242', 'a2f8fbc0-d5b6-50b4-a55f-c69acd1f94e8', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5c967ede-0e27-56fd-8d58-fab51ea3434d', 'a2f8fbc0-d5b6-50b4-a55f-c69acd1f94e8', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('810e8440-025b-5df9-b37c-f8eb269c0e78', 'a2f8fbc0-d5b6-50b4-a55f-c69acd1f94e8', 4, $md$D$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('a843f9f1-9621-5628-afd3-a5477220b48b', '7ba21da0-5199-57d0-85fd-4b4dfc18aa9a', 4, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 4

Questions 1-5
Questions 1-5
Look at the following statements (Questions
1-5
) and the list of people in the box below.
Match each statement with the correct person,
A, B, C
or
D
.
Write the correct letter,
A, B, C
or
D
, in boxes
1-5
on your answer sheet.
NB You may use any letter
more than once
.
1
Animals could use objects to locate food.
2
Ants show two-way, interactive teaching behaviors.
3
It is risky to say ants can teach other ants like human beings do.
4
Ant leadership makes finding food faster.
5
Communication between ants is not entirely teaching.
List of People
A
Nigel Franks
B
Marc Hauser
C
Tim Caro
D
Bennett Galef Jr.

4 ____ Ant leadership makes finding food faster.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('898278da-5e95-5086-893f-64764ef22c85', 'a843f9f1-9621-5628-afd3-a5477220b48b', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7f7f06da-7f72-5568-a41e-a4868c1e7ceb', 'a843f9f1-9621-5628-afd3-a5477220b48b', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c0cf3090-b861-561b-ac2b-085bf6a1fefc', 'a843f9f1-9621-5628-afd3-a5477220b48b', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a8cfd0e8-3ecd-5642-ae31-44d4bbdee6f6', 'a843f9f1-9621-5628-afd3-a5477220b48b', 4, $md$D$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('86e04f69-0072-5d7b-b2ef-e74b54b3055a', '7ba21da0-5199-57d0-85fd-4b4dfc18aa9a', 5, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 5

Questions 1-5
Questions 1-5
Look at the following statements (Questions
1-5
) and the list of people in the box below.
Match each statement with the correct person,
A, B, C
or
D
.
Write the correct letter,
A, B, C
or
D
, in boxes
1-5
on your answer sheet.
NB You may use any letter
more than once
.
1
Animals could use objects to locate food.
2
Ants show two-way, interactive teaching behaviors.
3
It is risky to say ants can teach other ants like human beings do.
4
Ant leadership makes finding food faster.
5
Communication between ants is not entirely teaching.
List of People
A
Nigel Franks
B
Marc Hauser
C
Tim Caro
D
Bennett Galef Jr.

5 ____ Communication between ants is not entirely teaching.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3d5543a7-2e7a-5ba2-83d0-ef2f48e2453f', '86e04f69-0072-5d7b-b2ef-e74b54b3055a', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3c0dca52-3c79-5305-ba3c-73460207757e', '86e04f69-0072-5d7b-b2ef-e74b54b3055a', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2703b4c8-3d12-54b4-b543-f69b6094c8b6', '86e04f69-0072-5d7b-b2ef-e74b54b3055a', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3758c61c-cfb1-518e-97a4-0914939028bb', '86e04f69-0072-5d7b-b2ef-e74b54b3055a', 4, $md$D$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('b03432e2-a8cd-53e2-9e14-b4fce8dcfce4', '7ba21da0-5199-57d0-85fd-4b4dfc18aa9a', 10, 'YES_NO_NOT_GIVEN', 'READING', 4, $md$### Question 10

Questions 10-13
Questions 10-13
Do the following statements agree with the claims of the writer in Reading Passage?
In boxes
10-13
on your answer sheet, write
YES
if the statement agrees with the claims of the writer
NO
if the statement contradicts the claims of the writer
NOT GIVEN
if it is impossible to say what the writer thinks about this
10
Ants' tandem running involves only one-way communication.
11
Franks's theory got many supporters immediately after publicity.
12
Ants' teaching behavior is the same as that of human.
13
Cheetah share hunting gains to younger ones

10 ____ Ants' tandem running involves only one-way communication.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a45cc38c-d8b0-5c63-bf37-3c157b345a92', 'b03432e2-a8cd-53e2-9e14-b4fce8dcfce4', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c45d57a9-9579-547e-9cb5-f1b2d27953d8', 'b03432e2-a8cd-53e2-9e14-b4fce8dcfce4', 2, $md$NO$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d5f52cf9-4680-57e6-8152-ef9444ca4e91', 'b03432e2-a8cd-53e2-9e14-b4fce8dcfce4', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('a87efc97-d983-53c1-bd47-3c8f536e3abd', '7ba21da0-5199-57d0-85fd-4b4dfc18aa9a', 11, 'YES_NO_NOT_GIVEN', 'READING', 4, $md$### Question 11

Questions 10-13
Questions 10-13
Do the following statements agree with the claims of the writer in Reading Passage?
In boxes
10-13
on your answer sheet, write
YES
if the statement agrees with the claims of the writer
NO
if the statement contradicts the claims of the writer
NOT GIVEN
if it is impossible to say what the writer thinks about this
10
Ants' tandem running involves only one-way communication.
11
Franks's theory got many supporters immediately after publicity.
12
Ants' teaching behavior is the same as that of human.
13
Cheetah share hunting gains to younger ones

11 ____ Franks's theory got many supporters immediately after publicity.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('db0d8119-6266-55b7-aefd-efd230bb3f7c', 'a87efc97-d983-53c1-bd47-3c8f536e3abd', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('db106cd7-024c-5231-b96a-2fc19c946773', 'a87efc97-d983-53c1-bd47-3c8f536e3abd', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('016a79fe-715e-5071-b948-a0c20c31df12', 'a87efc97-d983-53c1-bd47-3c8f536e3abd', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('8144bda8-eb01-5e1a-9a2b-78b299dfd452', '7ba21da0-5199-57d0-85fd-4b4dfc18aa9a', 12, 'YES_NO_NOT_GIVEN', 'READING', 4, $md$### Question 12

Questions 10-13
Questions 10-13
Do the following statements agree with the claims of the writer in Reading Passage?
In boxes
10-13
on your answer sheet, write
YES
if the statement agrees with the claims of the writer
NO
if the statement contradicts the claims of the writer
NOT GIVEN
if it is impossible to say what the writer thinks about this
10
Ants' tandem running involves only one-way communication.
11
Franks's theory got many supporters immediately after publicity.
12
Ants' teaching behavior is the same as that of human.
13
Cheetah share hunting gains to younger ones

12 ____ Ants' teaching behavior is the same as that of human.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ff1a62ef-746e-51b6-a9f3-3ec67c34a8ad', '8144bda8-eb01-5e1a-9a2b-78b299dfd452', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('804ac620-57a8-5ee1-8ed4-236816e81b55', '8144bda8-eb01-5e1a-9a2b-78b299dfd452', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('91457fbb-7732-5b9b-95e5-19e76bc15829', '8144bda8-eb01-5e1a-9a2b-78b299dfd452', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('394774f5-c528-5d31-b9c3-7f01f3aec96b', '7ba21da0-5199-57d0-85fd-4b4dfc18aa9a', 13, 'YES_NO_NOT_GIVEN', 'READING', 4, $md$### Question 13

Questions 10-13
Questions 10-13
Do the following statements agree with the claims of the writer in Reading Passage?
In boxes
10-13
on your answer sheet, write
YES
if the statement agrees with the claims of the writer
NO
if the statement contradicts the claims of the writer
NOT GIVEN
if it is impossible to say what the writer thinks about this
10
Ants' tandem running involves only one-way communication.
11
Franks's theory got many supporters immediately after publicity.
12
Ants' teaching behavior is the same as that of human.
13
Cheetah share hunting gains to younger ones

13 ____ Cheetah share hunting gains to younger ones$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('db6e5074-dd1e-511d-b5da-020f35a69cc7', '394774f5-c528-5d31-b9c3-7f01f3aec96b', 1, $md$YES$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('67257c06-be13-52fe-8c40-9084e599b313', '394774f5-c528-5d31-b9c3-7f01f3aec96b', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('78227e7c-e2f8-5aad-b9e9-237889fafef2', '394774f5-c528-5d31-b9c3-7f01f3aec96b', 3, $md$NOT GIVEN$md$, false);

COMMIT;
