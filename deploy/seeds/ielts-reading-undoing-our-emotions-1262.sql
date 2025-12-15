BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-undoing-our-emotions-1262'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-undoing-our-emotions-1262';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-undoing-our-emotions-1262';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-undoing-our-emotions-1262';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('86d135df-f169-5429-af57-f1bca2479b5c', 'ielts-reading-undoing-our-emotions-1262', $t$UNDOING OUR EMOTIONS$t$, $md$## UNDOING OUR EMOTIONS

Nguồn:
- Test: https://mini-ielts.com/1262/reading/undoing-our-emotions
- Solution: https://mini-ielts.com/1262/view-solution/reading/undoing-our-emotions$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('68c5e6bc-c598-5f10-8f7d-f20bd51c4bfb', '86d135df-f169-5429-af57-f1bca2479b5c', 1, $t$Reading — UNDOING OUR EMOTIONS$t$, $md$Read the passage and answer questions **1–13**.

### Passage: UNDOING OUR EMOTIONS

A. Three generations ago, 180 young women wrote essays describing why they wanted to join a convent (a religious community of nuns). Years later, a team of psychological researchers came across these autobiographies in the convent’s archives. The researchers were seeking material to confirm earlier studies hinting at a link between having a good vocabulary in youth and a low risk of Alzheimer’s disease in old age. What they found was even more amazing. The researchers found that, although the young women were in their early twenties when they wrote their essays, the emotions expressed in these writings were predictive of how long they would live: those with upbeat autobiographies lived more than ten years longer than those whose language was more neutral. Deborah Danner, a psychologist at the University of Kentucky who spearheaded the study, noted that the results were particularly striking because all members of the convent lived similar lifestyles, eliminating many variables that normally make it difficult to interpret longevity studies. It was a phenomenal finding’, she says. ‘A researcher gets a finding like that maybe once in a lifetime.’ However, she points out that no one has been able to determine why positive emotions might have such life-extending effects.

B. Barbara Fredrickson, Professor of Psychology at the University of Michigan, believes that part of the answer is the ‘undo effect’. According to this theory, positive emotions help you live longer by shutting down the effects of negative ones. Fredrickson’s theory begins with the observation that negative emotions, like fear and stress, enhance our flight-or-fight response to very real threats. However, even when the emergency is gone, negative emotions produce lingering effects. Brooks Gump, a stress researcher at the State University of New York, explains that one of these effects is excessive cardiovascular reactivity. Behaviourally, Gump says, this reactivity is related to excessive vigilance: the state of being constantly on guard for potential dangers. Not only is it physically draining to live in a perpetual state of high vigilance, but high cardiovascular reactivity could be linked to increased chances of a heart attack.

C. Fredrickson believes positive emotions work their magic by producing a rapid unwinding of pent-up tension, restoring the system to normal. People who quickly bounce back from stress often speed the process by harnessing such emotions as amusement, interest, excitement, and happiness, she says. To test her theory, Fredrickson told a group of student volunteers that they had only a few minutes to prepare a speech that would be critiqued by experts. After letting the students get nervous about that, Fredrickson then told them they wouldn’t actually have to deliver their speeches. She monitored heart rates and blood pressure. Not surprisingly, all students got nervous about their speeches, but those who viewed the experiment with good-humored excitement saw their heart rates return to normal much more quickly than those who were angry about being fooled. In a second experiment, Fredrickson reported that even those who normally were slow to bounce back could be coached to recover more quickly by being told to view the experiment as a challenge, rather than a threat.

D. Fredrickson believes that positive emotions make people more flexible and creative. Negative emotions, she says, give a heightened sense of detail that makes us hypersensitive to minute clues related to the source of a threat. But that also produces ‘tunnel vision’ in which we ignore anything unrelated to the danger. Fredrickson speculated that just as positive emotions can undo the cardiovascular effects of negative ones, they may also reverse the attention-narrowing effects of negative feelings: broadening our perspectives.

E. To verify her theory, Fredrickson showed a group of students some film clips- some saw frightening clips, some saw humorous ones or peaceful ones. They then did a matching test in which they were shown a simple drawing and asked which of two other drawings it most resembled. The drawings were designed so that people would tend to give one answer if they focused on details, and another answer if they focused on the big picture. The results confirmed Fredrickson’s suspicion that positive emotions affect our perceptions. Students who had seen the humorous or peaceful clips were more likely to match objects according to broad impressions.

F. This fits with the role that positive emotions might have played in early human tribes, Fredrickson says. Negative emotions provided focus, which was important for surviving in life-or-death situations, but the ability to feel positive emotions was of long-term value because it opened the mind to new ideas. Humour is a good example of this. She says: ‘The emotions are transient, but the resources are durable. If you building a friendship through being playful, that friendship is a lasting resource.’ So while the good feelings may pass, the friendship remains. On an individual level, Fredrickson’s theory also says that taking time to do things that make you feel happy isn’t simply self-indulgent. Not only are these emotions good for the individual, but they are also good for society.

G. Other researchers are intrigued by Fredrickson’s findings. Susan Folkman, of the University of California, has spent two decades studying how people cope with long-term stresses such as bereavement, or caring for a chronically ill child. Contrary to what one might expect, she says, these people frequently experience positive emotions. ‘These emotions aren’t there by accident’, she adds. ‘Mother Nature doesn’t work that way, I think that they give a person time out from the intense stress to restore their resources and keep going. This is very consistent with Fredrickson’s work.’$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('7f6d347a-e805-5b93-8de9-f9b6b1ff5c2f', '68c5e6bc-c598-5f10-8f7d-f20bd51c4bfb', 1, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 1

QUESTIONS 1-6
QUESTIONS 1-6
Reading Passage has seven sections,
A-G
.
Which section contains the following information?
Write the correct letter,
A-G,
in boxes 1-6 on your answer sheet.
NB
You may use any letter more than once.
1
a conclusion that it is possible to train people to deal with anxiety conclusive evidence that lifespan can be influenced by emotions.
2
an explanation of the way negative emotions affect what people concentrate on
3
an experiment that showed how a positive outlook can help people adjust to
4
a stressful situation faster than others
5
a discovery beyond what researchers were investigating
6
an experiment where the nature of a material seen by participants affected the way they performed a task

1 ____ a conclusion that it is possible to train people to deal with anxiety conclusive evidence that lifespan can be influenced by emotions.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('efbb2183-f467-5ea8-ba7b-75b1c9497923', '7f6d347a-e805-5b93-8de9-f9b6b1ff5c2f', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a1816e1f-55ee-5f9c-9594-cb41a0d2c3fa', '7f6d347a-e805-5b93-8de9-f9b6b1ff5c2f', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('08475bfe-1a6c-585a-a31a-2a4b081a66d1', '7f6d347a-e805-5b93-8de9-f9b6b1ff5c2f', 3, $md$C$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('783e4bd0-397e-5c4e-a4a1-57a759a00ea6', '7f6d347a-e805-5b93-8de9-f9b6b1ff5c2f', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d388b2e4-9367-59d6-aa33-a514b60407dc', '7f6d347a-e805-5b93-8de9-f9b6b1ff5c2f', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f1c088c5-fe34-5771-942a-695fb7f9c66f', '7f6d347a-e805-5b93-8de9-f9b6b1ff5c2f', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('98d303c3-1636-52b5-9c6b-b9cbfe010cec', '7f6d347a-e805-5b93-8de9-f9b6b1ff5c2f', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('1c765768-7af6-52e9-b872-f4039343a1b6', '68c5e6bc-c598-5f10-8f7d-f20bd51c4bfb', 2, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 2

QUESTIONS 1-6
QUESTIONS 1-6
Reading Passage has seven sections,
A-G
.
Which section contains the following information?
Write the correct letter,
A-G,
in boxes 1-6 on your answer sheet.
NB
You may use any letter more than once.
1
a conclusion that it is possible to train people to deal with anxiety conclusive evidence that lifespan can be influenced by emotions.
2
an explanation of the way negative emotions affect what people concentrate on
3
an experiment that showed how a positive outlook can help people adjust to
4
a stressful situation faster than others
5
a discovery beyond what researchers were investigating
6
an experiment where the nature of a material seen by participants affected the way they performed a task

2 ____ an explanation of the way negative emotions affect what people concentrate on$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('21290c7f-d964-5dfe-bc66-f954584c2a01', '1c765768-7af6-52e9-b872-f4039343a1b6', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('87f62d8e-0ebd-5c10-8b69-7d2f1efe439a', '1c765768-7af6-52e9-b872-f4039343a1b6', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ee89ab2e-d30c-5427-a256-1247ed52b172', '1c765768-7af6-52e9-b872-f4039343a1b6', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c4f0204e-8081-53d8-b78b-1f8c4f75efce', '1c765768-7af6-52e9-b872-f4039343a1b6', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('87997ea1-3a5a-5790-ae69-e9196e35671b', '1c765768-7af6-52e9-b872-f4039343a1b6', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bb59cc97-44b0-5705-91aa-23c1fc8ce475', '1c765768-7af6-52e9-b872-f4039343a1b6', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9b6330cc-58f1-5484-8665-6887e7888390', '1c765768-7af6-52e9-b872-f4039343a1b6', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('eab386c7-b3f9-5948-9464-e3ef5d739d53', '68c5e6bc-c598-5f10-8f7d-f20bd51c4bfb', 3, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 3

QUESTIONS 1-6
QUESTIONS 1-6
Reading Passage has seven sections,
A-G
.
Which section contains the following information?
Write the correct letter,
A-G,
in boxes 1-6 on your answer sheet.
NB
You may use any letter more than once.
1
a conclusion that it is possible to train people to deal with anxiety conclusive evidence that lifespan can be influenced by emotions.
2
an explanation of the way negative emotions affect what people concentrate on
3
an experiment that showed how a positive outlook can help people adjust to
4
a stressful situation faster than others
5
a discovery beyond what researchers were investigating
6
an experiment where the nature of a material seen by participants affected the way they performed a task

3 ____ an experiment that showed how a positive outlook can help people adjust to$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7d255ddc-d0e6-5254-ba14-50d867630281', 'eab386c7-b3f9-5948-9464-e3ef5d739d53', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b9719161-85ed-52c0-90fa-ea141aacaeff', 'eab386c7-b3f9-5948-9464-e3ef5d739d53', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3a7acc38-0f52-5a8c-ab57-377c9f13ce35', 'eab386c7-b3f9-5948-9464-e3ef5d739d53', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('aca3dbd4-34dc-5f40-b3db-746ad211643c', 'eab386c7-b3f9-5948-9464-e3ef5d739d53', 4, $md$D$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e6bedc0e-000a-5720-af51-96aa3194b3f5', 'eab386c7-b3f9-5948-9464-e3ef5d739d53', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c51611c7-cc97-5fe3-ad5a-f726c2833a48', 'eab386c7-b3f9-5948-9464-e3ef5d739d53', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('02229680-542e-558b-a6fc-66bc3fb83436', 'eab386c7-b3f9-5948-9464-e3ef5d739d53', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('4e2df813-1650-5592-8e06-527c594cea2d', '68c5e6bc-c598-5f10-8f7d-f20bd51c4bfb', 4, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 4

QUESTIONS 1-6
QUESTIONS 1-6
Reading Passage has seven sections,
A-G
.
Which section contains the following information?
Write the correct letter,
A-G,
in boxes 1-6 on your answer sheet.
NB
You may use any letter more than once.
1
a conclusion that it is possible to train people to deal with anxiety conclusive evidence that lifespan can be influenced by emotions.
2
an explanation of the way negative emotions affect what people concentrate on
3
an experiment that showed how a positive outlook can help people adjust to
4
a stressful situation faster than others
5
a discovery beyond what researchers were investigating
6
an experiment where the nature of a material seen by participants affected the way they performed a task

4 ____ a stressful situation faster than others$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a0f86a45-f5b6-56da-ad4d-2ccdf15b30fb', '4e2df813-1650-5592-8e06-527c594cea2d', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9b4db509-719e-5193-a628-1751625d8452', '4e2df813-1650-5592-8e06-527c594cea2d', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7401d244-3252-526e-9cc4-d6f774be3a8b', '4e2df813-1650-5592-8e06-527c594cea2d', 3, $md$C$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a6345a87-6110-5183-a16c-20e3d52e3011', '4e2df813-1650-5592-8e06-527c594cea2d', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d53c4959-d493-511a-ade4-98e338c65368', '4e2df813-1650-5592-8e06-527c594cea2d', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6d906bc8-9056-5f28-a211-610b1c16bf67', '4e2df813-1650-5592-8e06-527c594cea2d', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a1a54f8e-30df-510d-94d4-e4201778c28d', '4e2df813-1650-5592-8e06-527c594cea2d', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('49ebb0b4-38c6-541f-852d-a07152402bec', '68c5e6bc-c598-5f10-8f7d-f20bd51c4bfb', 5, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 5

QUESTIONS 1-6
QUESTIONS 1-6
Reading Passage has seven sections,
A-G
.
Which section contains the following information?
Write the correct letter,
A-G,
in boxes 1-6 on your answer sheet.
NB
You may use any letter more than once.
1
a conclusion that it is possible to train people to deal with anxiety conclusive evidence that lifespan can be influenced by emotions.
2
an explanation of the way negative emotions affect what people concentrate on
3
an experiment that showed how a positive outlook can help people adjust to
4
a stressful situation faster than others
5
a discovery beyond what researchers were investigating
6
an experiment where the nature of a material seen by participants affected the way they performed a task

5 ____ a discovery beyond what researchers were investigating$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b27d9d64-b5d9-5bbf-bb35-4be966f86b16', '49ebb0b4-38c6-541f-852d-a07152402bec', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a317fa26-4cdf-58c0-9700-938f53de0ab0', '49ebb0b4-38c6-541f-852d-a07152402bec', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('63fd2475-f846-5dd7-ae10-6cfa7d46ce13', '49ebb0b4-38c6-541f-852d-a07152402bec', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2ef96404-cfdd-5ce7-b69d-48144c933abb', '49ebb0b4-38c6-541f-852d-a07152402bec', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('11552764-7ca7-5e8c-a795-a9310f8f183d', '49ebb0b4-38c6-541f-852d-a07152402bec', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a8268fac-d27b-5ee6-884c-c4ba3c3ce2e4', '49ebb0b4-38c6-541f-852d-a07152402bec', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3d46a2c8-b1b9-598b-a4e0-80393c6193cb', '49ebb0b4-38c6-541f-852d-a07152402bec', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('f5838977-aa0b-5623-af4e-70e72b23836d', '68c5e6bc-c598-5f10-8f7d-f20bd51c4bfb', 6, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 6

QUESTIONS 1-6
QUESTIONS 1-6
Reading Passage has seven sections,
A-G
.
Which section contains the following information?
Write the correct letter,
A-G,
in boxes 1-6 on your answer sheet.
NB
You may use any letter more than once.
1
a conclusion that it is possible to train people to deal with anxiety conclusive evidence that lifespan can be influenced by emotions.
2
an explanation of the way negative emotions affect what people concentrate on
3
an experiment that showed how a positive outlook can help people adjust to
4
a stressful situation faster than others
5
a discovery beyond what researchers were investigating
6
an experiment where the nature of a material seen by participants affected the way they performed a task

6 ____ an experiment where the nature of a material seen by participants affected the way they performed a task$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2cfeb5ce-2f00-5395-a84c-702ae46f162d', 'f5838977-aa0b-5623-af4e-70e72b23836d', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ab8516ec-e66e-52e4-a33a-7f395dd20364', 'f5838977-aa0b-5623-af4e-70e72b23836d', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('243820d1-037d-5f24-b5a1-fa08d758af3b', 'f5838977-aa0b-5623-af4e-70e72b23836d', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6f9b47d0-bbfe-5fab-8b6a-7157a09c2fbb', 'f5838977-aa0b-5623-af4e-70e72b23836d', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('71af8326-435e-55c5-888f-12ccf4823327', 'f5838977-aa0b-5623-af4e-70e72b23836d', 5, $md$E$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('34cfc7b4-c2d4-5c6b-b23d-89d02668d22c', 'f5838977-aa0b-5623-af4e-70e72b23836d', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('29b2def0-e634-5d0a-9acd-0c63e9491e61', 'f5838977-aa0b-5623-af4e-70e72b23836d', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('233087f8-6e94-5ef9-a7bd-443dfbd9fee5', '68c5e6bc-c598-5f10-8f7d-f20bd51c4bfb', 7, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 7

QUESTIONS 7-10
QUESTIONS 7-10
ook at the following statements (Questions 7-10) and the list of researchers below.
Match each statement with the correct researcher,
A-D
.
Write the correct letter,
A-D
, in boxes 7-10 on your answer sheet.
NB
You may use any letter more than once.
List of Researchers
A
Deborah Danner
B
Barbara Fredrickson
C
Brooks Gump
D
Susan Folkman
7
People whose daily lives are stressful often have surprisingly positive emotions.
8
The body’s reaction to a crisis may trigger a life-threatening event.
9
It is unusual to have a study group whose circumstances were very alike.
10
The reasons for a link between positive emotions and a longer life have not been established.

7 ____ People whose daily lives are stressful often have surprisingly positive emotions.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e363036b-90d1-5acd-ab8d-5756e01e4ccd', '233087f8-6e94-5ef9-a7bd-443dfbd9fee5', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1508c982-a284-5ccf-899b-a0141703072a', '233087f8-6e94-5ef9-a7bd-443dfbd9fee5', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('acca300c-caaa-54bc-9106-a65b68aef81f', '233087f8-6e94-5ef9-a7bd-443dfbd9fee5', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c2a3c292-093d-5bba-9efb-24b72ac9220f', '233087f8-6e94-5ef9-a7bd-443dfbd9fee5', 4, $md$D$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('b88f40a4-8b19-5c25-aef9-6f1b2d00cfc4', '68c5e6bc-c598-5f10-8f7d-f20bd51c4bfb', 8, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 8

QUESTIONS 7-10
QUESTIONS 7-10
ook at the following statements (Questions 7-10) and the list of researchers below.
Match each statement with the correct researcher,
A-D
.
Write the correct letter,
A-D
, in boxes 7-10 on your answer sheet.
NB
You may use any letter more than once.
List of Researchers
A
Deborah Danner
B
Barbara Fredrickson
C
Brooks Gump
D
Susan Folkman
7
People whose daily lives are stressful often have surprisingly positive emotions.
8
The body’s reaction to a crisis may trigger a life-threatening event.
9
It is unusual to have a study group whose circumstances were very alike.
10
The reasons for a link between positive emotions and a longer life have not been established.

8 ____ The body’s reaction to a crisis may trigger a life-threatening event.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d8339db2-cd1e-56fd-a924-fb0bb8838f80', 'b88f40a4-8b19-5c25-aef9-6f1b2d00cfc4', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f83ea4ac-f46e-5e64-a1f3-d36316bbb009', 'b88f40a4-8b19-5c25-aef9-6f1b2d00cfc4', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('aba61816-f16c-5ff8-b056-84366e17272d', 'b88f40a4-8b19-5c25-aef9-6f1b2d00cfc4', 3, $md$C$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1d7c1bf5-44fb-59d9-9d07-e6df98d215e6', 'b88f40a4-8b19-5c25-aef9-6f1b2d00cfc4', 4, $md$D$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('be89269e-4660-5ee8-916e-f74bb6a558a0', '68c5e6bc-c598-5f10-8f7d-f20bd51c4bfb', 9, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 9

QUESTIONS 7-10
QUESTIONS 7-10
ook at the following statements (Questions 7-10) and the list of researchers below.
Match each statement with the correct researcher,
A-D
.
Write the correct letter,
A-D
, in boxes 7-10 on your answer sheet.
NB
You may use any letter more than once.
List of Researchers
A
Deborah Danner
B
Barbara Fredrickson
C
Brooks Gump
D
Susan Folkman
7
People whose daily lives are stressful often have surprisingly positive emotions.
8
The body’s reaction to a crisis may trigger a life-threatening event.
9
It is unusual to have a study group whose circumstances were very alike.
10
The reasons for a link between positive emotions and a longer life have not been established.

9 ____ It is unusual to have a study group whose circumstances were very alike.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c499ff17-460c-5b4b-899c-56fbb35e3cf5', 'be89269e-4660-5ee8-916e-f74bb6a558a0', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('09ad0fee-fd1a-5c44-9f0f-6b964bb29f4d', 'be89269e-4660-5ee8-916e-f74bb6a558a0', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d5365286-6ce7-52cf-a101-e3083d09a42c', 'be89269e-4660-5ee8-916e-f74bb6a558a0', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1c76b62c-3315-57c3-b052-fb5d5ce0f011', 'be89269e-4660-5ee8-916e-f74bb6a558a0', 4, $md$D$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('37a0cd8d-0396-56a2-914f-3125427a7d38', '68c5e6bc-c598-5f10-8f7d-f20bd51c4bfb', 10, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 10

QUESTIONS 7-10
QUESTIONS 7-10
ook at the following statements (Questions 7-10) and the list of researchers below.
Match each statement with the correct researcher,
A-D
.
Write the correct letter,
A-D
, in boxes 7-10 on your answer sheet.
NB
You may use any letter more than once.
List of Researchers
A
Deborah Danner
B
Barbara Fredrickson
C
Brooks Gump
D
Susan Folkman
7
People whose daily lives are stressful often have surprisingly positive emotions.
8
The body’s reaction to a crisis may trigger a life-threatening event.
9
It is unusual to have a study group whose circumstances were very alike.
10
The reasons for a link between positive emotions and a longer life have not been established.

10 ____ The reasons for a link between positive emotions and a longer life have not been established.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6e187a9c-3201-5b78-8031-64be1ce5828a', '37a0cd8d-0396-56a2-914f-3125427a7d38', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d329fbcd-f041-5dbd-afed-95abb60855ac', '37a0cd8d-0396-56a2-914f-3125427a7d38', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b1f5dd6c-49e3-5360-9540-f0981333ed8d', '37a0cd8d-0396-56a2-914f-3125427a7d38', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3d2912bc-32c3-5511-b0a0-ada36fe7f9d1', '37a0cd8d-0396-56a2-914f-3125427a7d38', 4, $md$D$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('e1232eb6-1f7c-5404-910f-305e3e91f308', '68c5e6bc-c598-5f10-8f7d-f20bd51c4bfb', 11, 'SENTENCE_COMPLETION', 'READING', 4, $md$### Question 11

QUESTIONS 11-13
QUESTIONS 11-13
Complete the sentences below.
Choose
ONE WORD ONLY
from the passage for each answer.
Write your answers in boxes 11-13 on your answer sheet.
11.
In early tribes, negative emotions gave humans the
11
that they needed to deal with emergencies.
12.
Fredrickson believes that a passing positive emotion can lead to an enduring asset such as a
12
, which is useful in times to come.
13.
Fredrickson also believes that both individuals and
13
benefit from positive emotions.

11. In early tribes, negative emotions gave humans the 11 ____ that they needed to deal with emergencies.$md$, NULL, ARRAY['.*focus.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('ded75a2d-eecd-5f98-abdc-2371d820f7ce', '68c5e6bc-c598-5f10-8f7d-f20bd51c4bfb', 12, 'SENTENCE_COMPLETION', 'READING', 4, $md$### Question 12

QUESTIONS 11-13
QUESTIONS 11-13
Complete the sentences below.
Choose
ONE WORD ONLY
from the passage for each answer.
Write your answers in boxes 11-13 on your answer sheet.
11.
In early tribes, negative emotions gave humans the
11
that they needed to deal with emergencies.
12.
Fredrickson believes that a passing positive emotion can lead to an enduring asset such as a
12
, which is useful in times to come.
13.
Fredrickson also believes that both individuals and
13
benefit from positive emotions.

12. Fredrickson believes that a passing positive emotion can lead to an enduring asset such as a 12 ____ , which is useful in times to come.$md$, NULL, ARRAY['.*friendship.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('b1be457f-e85f-5c71-b43a-35efd27f2e48', '68c5e6bc-c598-5f10-8f7d-f20bd51c4bfb', 13, 'SENTENCE_COMPLETION', 'READING', 4, $md$### Question 13

QUESTIONS 11-13
QUESTIONS 11-13
Complete the sentences below.
Choose
ONE WORD ONLY
from the passage for each answer.
Write your answers in boxes 11-13 on your answer sheet.
11.
In early tribes, negative emotions gave humans the
11
that they needed to deal with emergencies.
12.
Fredrickson believes that a passing positive emotion can lead to an enduring asset such as a
12
, which is useful in times to come.
13.
Fredrickson also believes that both individuals and
13
benefit from positive emotions.

13. Fredrickson also believes that both individuals and 13 ____ benefit from positive emotions.$md$, NULL, ARRAY['.*society.*']);

COMMIT;
