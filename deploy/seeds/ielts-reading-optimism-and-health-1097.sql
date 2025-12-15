BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-optimism-and-health-1097'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-optimism-and-health-1097';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-optimism-and-health-1097';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-optimism-and-health-1097';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('6efb27a8-9f9c-523d-8f42-2184a230e58e', 'ielts-reading-optimism-and-health-1097', $t$Optimism and Health$t$, $md$## Optimism and Health

Nguồn:
- Test: https://mini-ielts.com/1097/reading/optimism-and-health
- Solution: https://mini-ielts.com/1097/view-solution/reading/optimism-and-health$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('623af460-1187-5f67-9bde-a8c930e4b81b', '6efb27a8-9f9c-523d-8f42-2184a230e58e', 1, $t$Reading — Optimism and Health$t$, $md$Read the passage and answer questions **1–13**.

### Passage: Optimism and Health

Mindset is all. How you start the year will set the template for the rest, and two scientifically backed character traits hold the key: optimism and resili­ence (if the prospect leaves you feeling pessimistically spineless, the good news is that you can significantly boost both of these qualities).

Faced with 12 months of plummeting economics and rising human distress, staunchly maintaining a rosy view might seem deludedly Pollyannaish. But here we encounter the optimism paradox. As Brice Pitt, an emeritus professor of the psychiatry of old age at Imperial College, London, told me: “Optimists are unrealistic. Depressive people see things as they really are, but that is a disadvantage from an evolutionary point of view. Optimism is a piece of equipment that carried us through millennia of setbacks.”

Optimists have plenty to be happy about. In other words, if you can convince yourself that things will get better, the odds of it happening will improve - be­cause you keep on playing the game. In this light, optimism “is a habitual way of explaining your setbacks to yourself”, reports Martin Seligman, the psychology professor and author of Learned Optimism. The research shows that when times get tough, optimists do better than pessimists - they succeed better at work, respond better to stress, suffer fewer depressive episodes, and achieve more personal goals.

Studies also show that belief can help with the financial pinch. Chad Wallens, a social forecaster at the Henley Centre who surveyed middle-class Britons’ beliefs about income, has found that “ the people who feel wealthiest, and those who feel poorest, actually have almost the same amount of money at their disposal . Their attitudes and behaviour patterns, however, are different from one another.”

Optimists have something else to be cheerful about - in general, they are more robust. For example, a study of 660 volunteers by the Yale University psychologist Dr. Becca Levy found that thinking positively adds an average of seven years to your life. Other American research claims to have identified a physical mechanism behind this. A Harvard Medical School study of 670 men found that the optimists have significantly better lung function . The lead author, Dr. Rosalind Wright, believes that attitude somehow strengthens the immune system . “Preliminary studies on heart patients suggest that, by changing a per­son’s outlook, you can improve their mortality risk,” she says.

Few studies have tried to ascertain the proportion of optimists in the world. But a 1995 nationwide survey conducted by the American magazine Adweek found that about half the population counted themselves as optimists, with women slightly more apt than men (53 per cent versus 48 per cent) to see the sunny side.

Of course, there is no guarantee that optimism will insulate you from the crunch’s worst effects, but the best strategy is still to keep smiling and thank your lucky stars. Because (as every good sports coach knows) adversity is char­acter-forming - so long as you practise the skills of resilience. Research among tycoons and business leaders shows that the path to success is often littered with failure: a record of sackings, bankruptcies and blistering castigation. But instead of curling into a foetal ball beneath the coffee table, they resiliently pick themselves up, learn from their pratfalls and march boldly towards the next opportunity.

The American Psychological Association defines resilience as the ability to adapt in the face of adversity, trauma or tragedy. A resilient person may go through difficulty and uncertainty, but he or she will doggedly bounce back.

Optimism is one of the central traits required in building resilience, say Yale University investigators in the. Annual Review of Clinical Psychology. They add that resilient people learn to hold on to their sense of humour and this can help them to keep a flexible attitude when big changes of plan are warranted . The ability to accept your lot with equanimity also plays an important role, the study adds.

One of the best ways to acquire resilience is through experiencing a difficult childhood , the sociologist Steven Stack reports in the Journal of Social Psych­ology. For example, short men are less likely to commit suicide than tall guys, he says, because shorties develop psychological defence skills to handle the bullies and mickey-taking that their lack of stature attracts. By contrast, those who enjoyed adversity-free youths can get derailed by setbacks later on be­cause they’ve never been inoculated against aggro.

If you are handicapped by having had a happy childhood, then practising proactive optimism can help you to become more resilient. Studies of resilient people show that they take more risks; 'they court failure and learn not to fear it.

And despite being thick-skinned, resilient types are also more open than aver­age to other people . Bouncing through knock-backs is all part of the process.

It’s about optimistic risk-taking - being confident that people will like you. Simply smiling and being warm to people can help. It’s an altruistic path to self-interest - and if it achieves nothing else, it will reinforce an age-old adage: hard times can bring out the best in you.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('2f782426-8378-5f24-9bda-ff6e7d317fcf', '623af460-1187-5f67-9bde-a8c930e4b81b', 1, 'SUMMARY_COMPLETION', 'READING', 2, $md$### Question 1

Questions 1-4
Questions 1-4
Complete the summary below using
NO MORE THAN THREE WORDS
from Reading Passage for each answer.
A study group from Yale University had discovered that optimism can stretch one's life length by
1
Locate
years. And another group from Harvard thinks they have found the biological basis - optimists have better
2
Locate
because an optimist outlook boosts one's
3
Locate
. The study on
4
Locate
was cited as evidence in support of this claim.

A study group from Yale University had discovered that optimism can stretch one's life length by 1 ____ Locate years. And another group from Harvard thinks they have found the biological basis - optimists have better 2 ____ Locate because an optimist outlook boosts one's 3 ____ Locate . The study on 4 ____ Locate was cited as evidence in support of this claim.$md$, NULL, ARRAY['.*7.*','.*seven.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('ebde275b-1cfd-53fa-b82d-867109edfb2d', '623af460-1187-5f67-9bde-a8c930e4b81b', 2, 'SUMMARY_COMPLETION', 'READING', 2, $md$### Question 2

Questions 1-4
Questions 1-4
Complete the summary below using
NO MORE THAN THREE WORDS
from Reading Passage for each answer.
A study group from Yale University had discovered that optimism can stretch one's life length by
1
Locate
years. And another group from Harvard thinks they have found the biological basis - optimists have better
2
Locate
because an optimist outlook boosts one's
3
Locate
. The study on
4
Locate
was cited as evidence in support of this claim.

A study group from Yale University had discovered that optimism can stretch one's life length by 1 ____ Locate years. And another group from Harvard thinks they have found the biological basis - optimists have better 2 ____ Locate because an optimist outlook boosts one's 3 ____ Locate . The study on 4 ____ Locate was cited as evidence in support of this claim.$md$, NULL, ARRAY['.*7.*','.*seven.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('b6e9004e-14ba-5309-8ee1-2310a1fd7469', '623af460-1187-5f67-9bde-a8c930e4b81b', 3, 'SUMMARY_COMPLETION', 'READING', 2, $md$### Question 3

Questions 1-4
Questions 1-4
Complete the summary below using
NO MORE THAN THREE WORDS
from Reading Passage for each answer.
A study group from Yale University had discovered that optimism can stretch one's life length by
1
Locate
years. And another group from Harvard thinks they have found the biological basis - optimists have better
2
Locate
because an optimist outlook boosts one's
3
Locate
. The study on
4
Locate
was cited as evidence in support of this claim.

A study group from Yale University had discovered that optimism can stretch one's life length by 1 ____ Locate years. And another group from Harvard thinks they have found the biological basis - optimists have better 2 ____ Locate because an optimist outlook boosts one's 3 ____ Locate . The study on 4 ____ Locate was cited as evidence in support of this claim.$md$, NULL, ARRAY['.*7.*','.*seven.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('0954e1f1-d1ac-58ba-9cc6-f7acb4e0557f', '623af460-1187-5f67-9bde-a8c930e4b81b', 4, 'SUMMARY_COMPLETION', 'READING', 2, $md$### Question 4

Questions 1-4
Questions 1-4
Complete the summary below using
NO MORE THAN THREE WORDS
from Reading Passage for each answer.
A study group from Yale University had discovered that optimism can stretch one's life length by
1
Locate
years. And another group from Harvard thinks they have found the biological basis - optimists have better
2
Locate
because an optimist outlook boosts one's
3
Locate
. The study on
4
Locate
was cited as evidence in support of this claim.

A study group from Yale University had discovered that optimism can stretch one's life length by 1 ____ Locate years. And another group from Harvard thinks they have found the biological basis - optimists have better 2 ____ Locate because an optimist outlook boosts one's 3 ____ Locate . The study on 4 ____ Locate was cited as evidence in support of this claim.$md$, NULL, ARRAY['.*7.*','.*seven.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('cd3f15f1-1f70-52e4-a7a5-1f4c65efcaea', '623af460-1187-5f67-9bde-a8c930e4b81b', 5, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 5

Questions 5-9
Questions 5-9
Complete each sentence with the correct ending
A-H
.
5
Brice Pitt believes
Locate
6
The research at Henley Centre discovers
Locate
7
The study conducted by Adweek finds
Locate
8
The Annual Review of Clinical Psychology reports
Locate
9
Steven Stack says in his report
Locate
A
material wealth doesn't necessarily create happiness.
B
optimists tend to be unrealistic about human evolution.
C
optimism is advantageous for human evolution.
D
adversity is the breeding ground of resilience.
E
feelings of optimism vary according to gender.
F
good humour means good flexibility.
G
evenness of mind under stress is important to building resilience.
H
having an optimistic outlook is a habit.

5 ____ Brice Pitt believes Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('40cded20-521c-5c4d-a093-305f19f0c69b', 'cd3f15f1-1f70-52e4-a7a5-1f4c65efcaea', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a62966b1-46d6-5657-88b9-ec616bd1a144', 'cd3f15f1-1f70-52e4-a7a5-1f4c65efcaea', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7f5a5c95-af68-5015-86ed-845771e3d93d', 'cd3f15f1-1f70-52e4-a7a5-1f4c65efcaea', 3, $md$C$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bcd0ac88-c28f-5176-b162-dc60c709c22c', 'cd3f15f1-1f70-52e4-a7a5-1f4c65efcaea', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5c26b708-7608-5f3f-a2bb-61b2ef16e9c1', 'cd3f15f1-1f70-52e4-a7a5-1f4c65efcaea', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f40e63f7-4073-51bb-96d7-e1b9aef57be5', 'cd3f15f1-1f70-52e4-a7a5-1f4c65efcaea', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b563d3af-f622-5735-b3ad-1ff690d5e190', 'cd3f15f1-1f70-52e4-a7a5-1f4c65efcaea', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5e98d42b-ff73-5d45-a326-3c2ed1d35862', 'cd3f15f1-1f70-52e4-a7a5-1f4c65efcaea', 8, $md$H$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('403f15d5-8b23-5d9f-9352-574858523556', '623af460-1187-5f67-9bde-a8c930e4b81b', 6, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 6

Questions 5-9
Questions 5-9
Complete each sentence with the correct ending
A-H
.
5
Brice Pitt believes
Locate
6
The research at Henley Centre discovers
Locate
7
The study conducted by Adweek finds
Locate
8
The Annual Review of Clinical Psychology reports
Locate
9
Steven Stack says in his report
Locate
A
material wealth doesn't necessarily create happiness.
B
optimists tend to be unrealistic about human evolution.
C
optimism is advantageous for human evolution.
D
adversity is the breeding ground of resilience.
E
feelings of optimism vary according to gender.
F
good humour means good flexibility.
G
evenness of mind under stress is important to building resilience.
H
having an optimistic outlook is a habit.

6 ____ The research at Henley Centre discovers Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3f884932-6fea-53e6-8325-94b122ac9326', '403f15d5-8b23-5d9f-9352-574858523556', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e2007775-92de-5c34-891d-d1b750c89006', '403f15d5-8b23-5d9f-9352-574858523556', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('76174063-a173-5eee-8623-1202bbc087ae', '403f15d5-8b23-5d9f-9352-574858523556', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9fdbb1d2-4970-5d51-8004-25a2d71ba40b', '403f15d5-8b23-5d9f-9352-574858523556', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('542bb9ad-ea51-50ee-a692-8cd523cc68a6', '403f15d5-8b23-5d9f-9352-574858523556', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('88d9ea60-4dce-5a78-8416-945eae65b6e1', '403f15d5-8b23-5d9f-9352-574858523556', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('eea281e6-580e-5c2e-8f13-db1f5207c151', '403f15d5-8b23-5d9f-9352-574858523556', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4243746d-771d-5332-892e-30b851b0be98', '403f15d5-8b23-5d9f-9352-574858523556', 8, $md$H$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('0fbfb285-743e-5363-b8a4-0d81382c8579', '623af460-1187-5f67-9bde-a8c930e4b81b', 7, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 7

Questions 5-9
Questions 5-9
Complete each sentence with the correct ending
A-H
.
5
Brice Pitt believes
Locate
6
The research at Henley Centre discovers
Locate
7
The study conducted by Adweek finds
Locate
8
The Annual Review of Clinical Psychology reports
Locate
9
Steven Stack says in his report
Locate
A
material wealth doesn't necessarily create happiness.
B
optimists tend to be unrealistic about human evolution.
C
optimism is advantageous for human evolution.
D
adversity is the breeding ground of resilience.
E
feelings of optimism vary according to gender.
F
good humour means good flexibility.
G
evenness of mind under stress is important to building resilience.
H
having an optimistic outlook is a habit.

7 ____ The study conducted by Adweek finds Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b86a0c5f-ae05-524e-a6d9-80371a254d9c', '0fbfb285-743e-5363-b8a4-0d81382c8579', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6326f706-2c14-5a04-b891-96831736adb5', '0fbfb285-743e-5363-b8a4-0d81382c8579', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e51856d6-596b-5435-8e7f-1a8bae8eedbd', '0fbfb285-743e-5363-b8a4-0d81382c8579', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('435ac654-f9d5-5a5a-8c29-92c880598f12', '0fbfb285-743e-5363-b8a4-0d81382c8579', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3a0dca1b-a3fa-5f6c-bef0-07854761cc92', '0fbfb285-743e-5363-b8a4-0d81382c8579', 5, $md$E$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f4dc786c-c696-53c2-a53d-4d6579cc2f7a', '0fbfb285-743e-5363-b8a4-0d81382c8579', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ce0ece4a-810d-528b-afa1-1b999f4c2425', '0fbfb285-743e-5363-b8a4-0d81382c8579', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2a3e5deb-90c7-5375-8a64-59e77f54f3eb', '0fbfb285-743e-5363-b8a4-0d81382c8579', 8, $md$H$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('3a945c66-30d4-5a0d-9b8e-f11220061b62', '623af460-1187-5f67-9bde-a8c930e4b81b', 8, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 8

Questions 5-9
Questions 5-9
Complete each sentence with the correct ending
A-H
.
5
Brice Pitt believes
Locate
6
The research at Henley Centre discovers
Locate
7
The study conducted by Adweek finds
Locate
8
The Annual Review of Clinical Psychology reports
Locate
9
Steven Stack says in his report
Locate
A
material wealth doesn't necessarily create happiness.
B
optimists tend to be unrealistic about human evolution.
C
optimism is advantageous for human evolution.
D
adversity is the breeding ground of resilience.
E
feelings of optimism vary according to gender.
F
good humour means good flexibility.
G
evenness of mind under stress is important to building resilience.
H
having an optimistic outlook is a habit.

8 ____ The Annual Review of Clinical Psychology reports Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ee8256aa-ad59-5c81-b42b-52d3231bb90a', '3a945c66-30d4-5a0d-9b8e-f11220061b62', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('72e61aec-92d7-55fa-8fe4-fb08fd98089e', '3a945c66-30d4-5a0d-9b8e-f11220061b62', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('681b8c75-3820-541e-9e2f-421dc809046f', '3a945c66-30d4-5a0d-9b8e-f11220061b62', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1a8f5495-2547-5424-a6a9-6c18107ea693', '3a945c66-30d4-5a0d-9b8e-f11220061b62', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('281c8ef1-4f7c-52a0-abee-ff4b9782dbb5', '3a945c66-30d4-5a0d-9b8e-f11220061b62', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('74d4eb2a-2253-5858-a1d5-793eec58a4df', '3a945c66-30d4-5a0d-9b8e-f11220061b62', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9cd7e05c-b235-5c92-9244-553f08e651da', '3a945c66-30d4-5a0d-9b8e-f11220061b62', 7, $md$G$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4cfb09fa-7835-5261-81cb-732f88743760', '3a945c66-30d4-5a0d-9b8e-f11220061b62', 8, $md$H$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('004ce7e1-567c-582e-aaac-62b39a711bcc', '623af460-1187-5f67-9bde-a8c930e4b81b', 9, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 9

Questions 5-9
Questions 5-9
Complete each sentence with the correct ending
A-H
.
5
Brice Pitt believes
Locate
6
The research at Henley Centre discovers
Locate
7
The study conducted by Adweek finds
Locate
8
The Annual Review of Clinical Psychology reports
Locate
9
Steven Stack says in his report
Locate
A
material wealth doesn't necessarily create happiness.
B
optimists tend to be unrealistic about human evolution.
C
optimism is advantageous for human evolution.
D
adversity is the breeding ground of resilience.
E
feelings of optimism vary according to gender.
F
good humour means good flexibility.
G
evenness of mind under stress is important to building resilience.
H
having an optimistic outlook is a habit.

9 ____ Steven Stack says in his report Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bca19b4c-9ef6-52c1-8cc3-4984df3dfd04', '004ce7e1-567c-582e-aaac-62b39a711bcc', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d0804532-1b74-5057-847f-b1df06441662', '004ce7e1-567c-582e-aaac-62b39a711bcc', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ede6da3e-05e1-5943-b649-6c01d28dbc07', '004ce7e1-567c-582e-aaac-62b39a711bcc', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c9ca6939-35ec-54d5-b535-ed9ee6c211c0', '004ce7e1-567c-582e-aaac-62b39a711bcc', 4, $md$D$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('186a2a1a-6d22-5289-a178-3a63c153d08d', '004ce7e1-567c-582e-aaac-62b39a711bcc', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('26c1a39b-294c-56f7-bd4f-b66225a5b87b', '004ce7e1-567c-582e-aaac-62b39a711bcc', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7c16ba14-ad7b-5c2c-b9f6-df663a3e966c', '004ce7e1-567c-582e-aaac-62b39a711bcc', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d95998c0-e26c-5cc1-94ac-213baab5a3a9', '004ce7e1-567c-582e-aaac-62b39a711bcc', 8, $md$H$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('7396a808-4150-5c51-a32f-43a106c380b2', '623af460-1187-5f67-9bde-a8c930e4b81b', 10, 'YES_NO_NOT_GIVEN', 'READING', 4, $md$### Question 10

Questions 10-13
Questions 10-13
Do the following statements agree with the claims of the writer in Reading Passage?
In boxes
10-13
on your answer sheet write
YES
if the statement agrees with the information
NO
if the statement contradicts the information
NOT GIVEN
if there is no information on this
10
The benefits of optimism on health have been long known.
11
Optimists have better relationships with people than pessimists.
12
People with happy childhoods won't be able to practise optimism.
Locate
13
Resilient people are often open, and even thick­skinned.
Locate

10 ____ The benefits of optimism on health have been long known.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('05793918-a449-55bd-90d4-262957c3c0bb', '7396a808-4150-5c51-a32f-43a106c380b2', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('123b6f7f-5263-5b58-bd15-4f7c7ccaaba6', '7396a808-4150-5c51-a32f-43a106c380b2', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9a527ccb-85ed-5de0-a1a0-212d4e4d313d', '7396a808-4150-5c51-a32f-43a106c380b2', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('9cc33389-edfe-5c2a-ac89-8c69dc02ff67', '623af460-1187-5f67-9bde-a8c930e4b81b', 11, 'YES_NO_NOT_GIVEN', 'READING', 4, $md$### Question 11

Questions 10-13
Questions 10-13
Do the following statements agree with the claims of the writer in Reading Passage?
In boxes
10-13
on your answer sheet write
YES
if the statement agrees with the information
NO
if the statement contradicts the information
NOT GIVEN
if there is no information on this
10
The benefits of optimism on health have been long known.
11
Optimists have better relationships with people than pessimists.
12
People with happy childhoods won't be able to practise optimism.
Locate
13
Resilient people are often open, and even thick­skinned.
Locate

11 ____ Optimists have better relationships with people than pessimists.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2f1a9f08-f43d-5991-83ca-0a3f5daf3d1f', '9cc33389-edfe-5c2a-ac89-8c69dc02ff67', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c26497d1-35a2-568a-8539-bb9b494e20a1', '9cc33389-edfe-5c2a-ac89-8c69dc02ff67', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('671c665c-5acd-5b34-a6fb-d006235f8a64', '9cc33389-edfe-5c2a-ac89-8c69dc02ff67', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('2a0a4a9e-0a2c-501d-9235-483d53ba7476', '623af460-1187-5f67-9bde-a8c930e4b81b', 12, 'YES_NO_NOT_GIVEN', 'READING', 4, $md$### Question 12

Questions 10-13
Questions 10-13
Do the following statements agree with the claims of the writer in Reading Passage?
In boxes
10-13
on your answer sheet write
YES
if the statement agrees with the information
NO
if the statement contradicts the information
NOT GIVEN
if there is no information on this
10
The benefits of optimism on health have been long known.
11
Optimists have better relationships with people than pessimists.
12
People with happy childhoods won't be able to practise optimism.
Locate
13
Resilient people are often open, and even thick­skinned.
Locate

12 ____ People with happy childhoods won't be able to practise optimism. Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c97d5e05-2f56-500b-842b-fd78fa070693', '2a0a4a9e-0a2c-501d-9235-483d53ba7476', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6f1519c6-0b54-592e-b7b3-a918560bc658', '2a0a4a9e-0a2c-501d-9235-483d53ba7476', 2, $md$NO$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1f8f51c1-68c1-5881-9202-0f99c5dc5587', '2a0a4a9e-0a2c-501d-9235-483d53ba7476', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('d83cd4af-93dd-555b-844d-681022998c16', '623af460-1187-5f67-9bde-a8c930e4b81b', 13, 'YES_NO_NOT_GIVEN', 'READING', 4, $md$### Question 13

Questions 10-13
Questions 10-13
Do the following statements agree with the claims of the writer in Reading Passage?
In boxes
10-13
on your answer sheet write
YES
if the statement agrees with the information
NO
if the statement contradicts the information
NOT GIVEN
if there is no information on this
10
The benefits of optimism on health have been long known.
11
Optimists have better relationships with people than pessimists.
12
People with happy childhoods won't be able to practise optimism.
Locate
13
Resilient people are often open, and even thick­skinned.
Locate

13 ____ Resilient people are often open, and even thick­skinned. Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('012cc0d2-b9aa-5013-a625-feec127d09a2', 'd83cd4af-93dd-555b-844d-681022998c16', 1, $md$YES$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('610736d4-4ef7-572f-8539-62323afb6be7', 'd83cd4af-93dd-555b-844d-681022998c16', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bfb428ca-521a-580c-89ee-f718cd7c472f', 'd83cd4af-93dd-555b-844d-681022998c16', 3, $md$NOT GIVEN$md$, false);

COMMIT;
