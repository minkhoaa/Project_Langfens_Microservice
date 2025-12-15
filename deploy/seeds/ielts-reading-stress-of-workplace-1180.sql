BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-stress-of-workplace-1180'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-stress-of-workplace-1180';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-stress-of-workplace-1180';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-stress-of-workplace-1180';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('100ffddc-ab40-5be5-9d96-55d6b15dc295', 'ielts-reading-stress-of-workplace-1180', $t$Stress of Workplace$t$, $md$## Stress of Workplace

Nguồn:
- Test: https://mini-ielts.com/1180/reading/stress-of-workplace
- Solution: https://mini-ielts.com/1180/view-solution/reading/stress-of-workplace$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('07d48fb4-6ee3-5647-a0b6-dc7642abedc9', '100ffddc-ab40-5be5-9d96-55d6b15dc295', 1, $t$Reading — Stress of Workplace$t$, $md$Read the passage and answer questions **1–14**.

### Passage: Stress of Workplace

A How busy is too busy? For some it means having to miss the occasional long lunch; for others it means missing lunch altogether. For a few, it is not being able to take a “sickie” once a month. Then there is a group of people for whom working every evening and weekend is normal, and frantic is the tempo of their lives. For most senior executives, workloads swing between extremely busy and frenzied. The vice-president of the management consultancy AT Kearney and its head of telecommunications for the Asia-Pacific region, Neil Plumridge, says his work weeks vary from a “manageable” 45 hours to 80 hours, but average 60 hours.

B Three warning signs alert Plumridge about his workload: sleep, scheduling and family. He knows he has too much on when he gets less than six hours of sleep for three consecutive nights; when he is constantly having to reschedule appointments; “and the third one is on the family side”, says Plumridge, the father of a three-year-old daughter, and expecting a second child in October. “If I happen to miss a birthday or anniversary, I know things are out of control.” Being “too busy” is highly subjective. But for any individual, the perception of being too busy over a prolonged period can start showing up as stress: disturbed sleep, and declining mental and physical health. National workers’ compensation figures show stress causes the most lost time of any workplace injury . Employees suffering stress are off work an average of 16.6 weeks . The effects of stress are also expensive. Comcare, the Federal Government insurer, reports that in 2003-04, claims for psychological injury accounted for 7% of claims but almost 27% of claim costs. Experts say the key to dealing with stress is not to focus on relief – a game of golf or a massage – but to reassess workloads . Neil Plumridge says he makes it a priority to work out what has to change ; that might mean allocating extra resources to a job, allowing more time or changing expectations . The decision may take several days . He also relies on the advice of colleagues, saying his peers coach each other with business problems. “Just a fresh pair of eyes over an issue can help,” he says.

C Executive stress is not confined to big organisations. Vanessa Stoykov has been running her own advertising and public relations business for seven years, specialising in work for financial and professional services firms. Evolution Media has grown so fast that it debuted on the BRW Fast 100 list of fastest-growing small enterprises last year – just after Stoykov had her first child. Stoykov thrives on the mental stimulation of running her own business. “Like everyone, I have the occasional day when I think my head’s going to blow off,” she says. Because of the growth phase the business is in, Stoykov has to concentrate on short-term stress relief – weekends in the mountains, the occasional “mental health” day – rather than delegating more work . She says: “We’re hiring more people, but you need to train them, teach them about the culture and the clients, so it’s actually more work rather than less.”

D Identify the causes: Jan Elsnera, Melbourne psychologist who specialises in executive coaching, says thriving on a demanding workload is typical of senior executives and other high-potential business people . She says there is no one-size-fits-all approach to stress: some people work best with high-adrenalin periods followed by quieter patches, while others thrive under sustained pressure. “ We could take urine and blood hormonal measures and pass a judgment of whether someone’s physiologically stressed or not, ” she says. “But that’s not going to give us an indicator of what their experience of stress is, and what the emotional and cognitive impacts of stress are going to be.”

E Eisner’s practice is informed by a movement known as positive psychology, a school of thought that argues “positive” experiences – feeling engaged, challenged, and that one is making a contribution to something meaningful – do not balance out negative ones such as stress; instead, they help people increase their resilience over time. Good stress, or positive experiences of being challenged and rewarded, is thus cumulative in the same way as bad stress. Elsner says many of the senior business people she coaches are relying more on regulating bad stress through methods such as meditation and yoga. She points to research showing that meditation can alter the biochemistry of the brain and actually help people “retrain” the way their brains and bodies react to stress. “Meditation and yoga enable you to shift the way that your brain reacts, so if you get proficient at it you’re in control.”

F The Australian vice-president of AT Kearney, Neil Plumridge, says: “ Often stress is caused by our setting unrealistic expectations of ourselves . I’ll promise a client I’ll do something tomorrow, and then promise another client the same thing, when I really know it’s not going to happen. I’ve put stress on myself when I could have said to the clients: ‘Why don’t I give that to you in 48 hours?’ The client doesn’t care.” Over-committing is something people experience as an individual problem. We explain it as the result of procrastination or Parkinson’s law: that work expands to fill the time available. New research indicates that people may be hard-wired to do it.

G A study in the February issue of the Journal of Experimental Psychology shows that people always believe they will be less busy in the future than now . This is a misapprehension, according to the authors of the report, Professor Gal Zauberman, of the University of North Carolina, and Professor John Lynch, of Duke University. “On average, an individual will be just as busy two weeks or a month from now as he or she is today. But that is not how it appears to be in everyday life,” they wrote. “People often make commitments long in advance that they would never make if the same commitments required immediate action. That is, they discount future time investments relatively steeply.” Why do we perceive a greater “surplus” of time in the future than in the present? The researchers suggest that people underestimate completion times for tasks stretching into the future, and that they are bad at imagining future competition for their time.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('36fdad37-2427-5d82-9456-80c72c4468cf', '07d48fb4-6ee3-5647-a0b6-dc7642abedc9', 1, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 1

Question 1-5
Question 1-5
Use the information in the passage to match the people (listed
A-D
) with opinions or deeds below.
Write the appropriate letters
A-D
in boxes
14-18
on your answer sheet.
NB
You may use any letter
more than once
.
A
Jan Elsnera
B
Vanessa Stoykov
C
Gal Zauberman
D
Neil Plumridge
1
Work stress usually happens in the high level of a business.
Locate
2
More people’s ideas involved would be beneficial for stress relief.
Locate
3
Temporary holiday sometimes doesn’t mean less work.
Locate
4
Stress leads to a wrong direction when trying to satisfy customers.
Locate
5
It is not correct that stress in the future will be eased more than now.
Locate

1 ____ Work stress usually happens in the high level of a business. Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c6ba9606-7698-5fff-8b73-81879446d180', '36fdad37-2427-5d82-9456-80c72c4468cf', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('91569356-d598-586e-8db2-568b1c8e2444', '36fdad37-2427-5d82-9456-80c72c4468cf', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b84451fb-47e5-52ae-ab02-56fadbaa48ad', '36fdad37-2427-5d82-9456-80c72c4468cf', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('51da2651-9eea-56a2-9674-e02a38fad236', '36fdad37-2427-5d82-9456-80c72c4468cf', 4, $md$D$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('49a4ed14-560b-5b41-8e24-df9fed8796ee', '07d48fb4-6ee3-5647-a0b6-dc7642abedc9', 2, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 2

Question 1-5
Question 1-5
Use the information in the passage to match the people (listed
A-D
) with opinions or deeds below.
Write the appropriate letters
A-D
in boxes
14-18
on your answer sheet.
NB
You may use any letter
more than once
.
A
Jan Elsnera
B
Vanessa Stoykov
C
Gal Zauberman
D
Neil Plumridge
1
Work stress usually happens in the high level of a business.
Locate
2
More people’s ideas involved would be beneficial for stress relief.
Locate
3
Temporary holiday sometimes doesn’t mean less work.
Locate
4
Stress leads to a wrong direction when trying to satisfy customers.
Locate
5
It is not correct that stress in the future will be eased more than now.
Locate

2 ____ More people’s ideas involved would be beneficial for stress relief. Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b8c56e0b-2346-5216-b2a2-d153c2fe1f50', '49a4ed14-560b-5b41-8e24-df9fed8796ee', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b6e9edb6-1a02-5c37-b63d-f70919e748b3', '49a4ed14-560b-5b41-8e24-df9fed8796ee', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('376dcfe2-f186-5cde-af13-eb10a3776d31', '49a4ed14-560b-5b41-8e24-df9fed8796ee', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f9091ec6-e6e7-52f2-9a74-9db5dd94bc47', '49a4ed14-560b-5b41-8e24-df9fed8796ee', 4, $md$D$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('734feee4-bf19-58de-9400-838eb3e5c3a8', '07d48fb4-6ee3-5647-a0b6-dc7642abedc9', 3, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 3

Question 1-5
Question 1-5
Use the information in the passage to match the people (listed
A-D
) with opinions or deeds below.
Write the appropriate letters
A-D
in boxes
14-18
on your answer sheet.
NB
You may use any letter
more than once
.
A
Jan Elsnera
B
Vanessa Stoykov
C
Gal Zauberman
D
Neil Plumridge
1
Work stress usually happens in the high level of a business.
Locate
2
More people’s ideas involved would be beneficial for stress relief.
Locate
3
Temporary holiday sometimes doesn’t mean less work.
Locate
4
Stress leads to a wrong direction when trying to satisfy customers.
Locate
5
It is not correct that stress in the future will be eased more than now.
Locate

3 ____ Temporary holiday sometimes doesn’t mean less work. Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e4ab4180-7e2f-5d20-b7f9-8b6079c0df35', '734feee4-bf19-58de-9400-838eb3e5c3a8', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('38fad668-ec0f-5ac3-ba99-041c54b45689', '734feee4-bf19-58de-9400-838eb3e5c3a8', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9c1b3166-d126-5cec-8040-42464dd74d2d', '734feee4-bf19-58de-9400-838eb3e5c3a8', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('24a1cf61-ec43-5c51-8d90-e6320419995c', '734feee4-bf19-58de-9400-838eb3e5c3a8', 4, $md$D$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('32e01fec-b3f8-55c3-a646-baaf96603720', '07d48fb4-6ee3-5647-a0b6-dc7642abedc9', 4, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 4

Question 1-5
Question 1-5
Use the information in the passage to match the people (listed
A-D
) with opinions or deeds below.
Write the appropriate letters
A-D
in boxes
14-18
on your answer sheet.
NB
You may use any letter
more than once
.
A
Jan Elsnera
B
Vanessa Stoykov
C
Gal Zauberman
D
Neil Plumridge
1
Work stress usually happens in the high level of a business.
Locate
2
More people’s ideas involved would be beneficial for stress relief.
Locate
3
Temporary holiday sometimes doesn’t mean less work.
Locate
4
Stress leads to a wrong direction when trying to satisfy customers.
Locate
5
It is not correct that stress in the future will be eased more than now.
Locate

4 ____ Stress leads to a wrong direction when trying to satisfy customers. Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('73d977ef-f190-5384-aeb0-f884e527e9bb', '32e01fec-b3f8-55c3-a646-baaf96603720', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('677411e0-3d0e-5cb4-b160-254a63207472', '32e01fec-b3f8-55c3-a646-baaf96603720', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c8fb8136-8544-57c6-9862-d0edee104e53', '32e01fec-b3f8-55c3-a646-baaf96603720', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1c3e61b3-1eb9-50a5-a06c-8e2995ca3c4d', '32e01fec-b3f8-55c3-a646-baaf96603720', 4, $md$D$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('7487549b-f85f-5324-8b34-9526a782aac4', '07d48fb4-6ee3-5647-a0b6-dc7642abedc9', 5, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 5

Question 1-5
Question 1-5
Use the information in the passage to match the people (listed
A-D
) with opinions or deeds below.
Write the appropriate letters
A-D
in boxes
14-18
on your answer sheet.
NB
You may use any letter
more than once
.
A
Jan Elsnera
B
Vanessa Stoykov
C
Gal Zauberman
D
Neil Plumridge
1
Work stress usually happens in the high level of a business.
Locate
2
More people’s ideas involved would be beneficial for stress relief.
Locate
3
Temporary holiday sometimes doesn’t mean less work.
Locate
4
Stress leads to a wrong direction when trying to satisfy customers.
Locate
5
It is not correct that stress in the future will be eased more than now.
Locate

5 ____ It is not correct that stress in the future will be eased more than now. Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c91f602a-cbd8-58ec-899b-bff1be91578a', '7487549b-f85f-5324-8b34-9526a782aac4', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d7687b9d-8189-5512-9fd1-dcd58f01d045', '7487549b-f85f-5324-8b34-9526a782aac4', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('74eda0c0-2621-50b8-bd68-5dcfcdb7aadb', '7487549b-f85f-5324-8b34-9526a782aac4', 3, $md$C$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b2d2325b-2769-52ec-8999-4456b81906a8', '7487549b-f85f-5324-8b34-9526a782aac4', 4, $md$D$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('1b08f43c-3dd6-51d7-b031-1bb4877dacf5', '07d48fb4-6ee3-5647-a0b6-dc7642abedc9', 6, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 6

Question 6-8
Question 6-8
Choose the correct letter,
A
,
B
,
C
or
D
.
Write your answers in boxes
19-21
on your answer sheet.
6
Which of the following workplace stress is
NOT
mentioned according to Plumridge in the following options
A
Not enough time spend on family
B
Unable to concentrate on work
C
Inadequate time of sleep
D
Alteration of appointment
Locate
7
Which of the following solution is NOT mentioned in helping reduce the work pressure according toPlumridge
A
Allocate more personnel
B
Increase more time
C
Lower expectation
D
Do sports and massage
Locate
8
What is point of view of Jan Elsnera towards work stress
A
Medical test can only reveal part of the data needed to cope with stress
B
Index somebody samples will be abnormal in a stressful experience
C
Emotional and cognitive affection is superior to physical one
D
One well designed solution can release all stress
Locate

Choose the correct letter, A , B , C or D .$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('c61c24bf-04ef-5c5a-9a64-4d58adc4c240', '07d48fb4-6ee3-5647-a0b6-dc7642abedc9', 7, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 7

Question 6-8
Question 6-8
Choose the correct letter,
A
,
B
,
C
or
D
.
Write your answers in boxes
19-21
on your answer sheet.
6
Which of the following workplace stress is
NOT
mentioned according to Plumridge in the following options
A
Not enough time spend on family
B
Unable to concentrate on work
C
Inadequate time of sleep
D
Alteration of appointment
Locate
7
Which of the following solution is NOT mentioned in helping reduce the work pressure according toPlumridge
A
Allocate more personnel
B
Increase more time
C
Lower expectation
D
Do sports and massage
Locate
8
What is point of view of Jan Elsnera towards work stress
A
Medical test can only reveal part of the data needed to cope with stress
B
Index somebody samples will be abnormal in a stressful experience
C
Emotional and cognitive affection is superior to physical one
D
One well designed solution can release all stress
Locate

Choose the correct letter, A , B , C or D .$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('14561c76-51ce-597d-97cb-e535b623ec69', '07d48fb4-6ee3-5647-a0b6-dc7642abedc9', 8, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 8

Question 6-8
Question 6-8
Choose the correct letter,
A
,
B
,
C
or
D
.
Write your answers in boxes
19-21
on your answer sheet.
6
Which of the following workplace stress is
NOT
mentioned according to Plumridge in the following options
A
Not enough time spend on family
B
Unable to concentrate on work
C
Inadequate time of sleep
D
Alteration of appointment
Locate
7
Which of the following solution is NOT mentioned in helping reduce the work pressure according toPlumridge
A
Allocate more personnel
B
Increase more time
C
Lower expectation
D
Do sports and massage
Locate
8
What is point of view of Jan Elsnera towards work stress
A
Medical test can only reveal part of the data needed to cope with stress
B
Index somebody samples will be abnormal in a stressful experience
C
Emotional and cognitive affection is superior to physical one
D
One well designed solution can release all stress
Locate

Choose the correct letter, A , B , C or D .$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('78de0513-cc2a-504b-aad5-242d84ded3c6', '07d48fb4-6ee3-5647-a0b6-dc7642abedc9', 9, 'SUMMARY_COMPLETION', 'READING', 3, $md$### Question 9

Question 9-14
Question 9-14
Complete the following summary of the paragraphs of Reading Passage, using
NO MORE THAN TWO WORDS
from the Reading Passage for each answer.
Write your answers in boxes
9-14
on your answer sheet.
Statistics from National worker’s compensation indicate stress plays the most important role in
9
Locate
which cause the time losses. Staffs take about
10
Locate
for absence from work caused by stress. Not just time is our main concern but great expenses generated consequently. An official insurer wrote sometime that about
11
Locate
of all claims were mental issues whereas nearly 27% costs in all claims, Sports Such as
12
Locate
as well as
13
Locate
could be a treatment to release stress; However, specialists recommended another practical way out, analyse
14
once again.

Statistics from National worker’s compensation indicate stress plays the most important role in 9 ____ Locate which cause the time losses. Staffs take about 10 ____ Locate for absence from work caused by stress. Not just time is our main concern but great expenses generated consequently. An official insurer wrote sometime that about 11 ____ Locate of all claims were mental issues whereas nearly 27% costs in all claims, Sports Such as 12 ____ Locate as well as 13 ____ Locate could be a treatment to release stress; However, specialists recommended another practical way out, analyse 14 ____ once again.$md$, NULL, ARRAY['.*workplace.*injury.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('039e94af-a156-52c3-a31c-91fd51e9950b', '07d48fb4-6ee3-5647-a0b6-dc7642abedc9', 10, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 10

Question 9-14
Question 9-14
Complete the following summary of the paragraphs of Reading Passage, using
NO MORE THAN TWO WORDS
from the Reading Passage for each answer.
Write your answers in boxes
9-14
on your answer sheet.
Statistics from National worker’s compensation indicate stress plays the most important role in
9
Locate
which cause the time losses. Staffs take about
10
Locate
for absence from work caused by stress. Not just time is our main concern but great expenses generated consequently. An official insurer wrote sometime that about
11
Locate
of all claims were mental issues whereas nearly 27% costs in all claims, Sports Such as
12
Locate
as well as
13
Locate
could be a treatment to release stress; However, specialists recommended another practical way out, analyse
14
once again.

Statistics from National worker’s compensation indicate stress plays the most important role in 9 ____ Locate which cause the time losses. Staffs take about 10 ____ Locate for absence from work caused by stress. Not just time is our main concern but great expenses generated consequently. An official insurer wrote sometime that about 11 ____ Locate of all claims were mental issues whereas nearly 27% costs in all claims, Sports Such as 12 ____ Locate as well as 13 ____ Locate could be a treatment to release stress; However, specialists recommended another practical way out, analyse 14 ____ once again.$md$, NULL, ARRAY['.*workplace.*injury.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('0837841d-f5b8-5694-804c-ee19af8c401f', '07d48fb4-6ee3-5647-a0b6-dc7642abedc9', 11, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 11

Question 9-14
Question 9-14
Complete the following summary of the paragraphs of Reading Passage, using
NO MORE THAN TWO WORDS
from the Reading Passage for each answer.
Write your answers in boxes
9-14
on your answer sheet.
Statistics from National worker’s compensation indicate stress plays the most important role in
9
Locate
which cause the time losses. Staffs take about
10
Locate
for absence from work caused by stress. Not just time is our main concern but great expenses generated consequently. An official insurer wrote sometime that about
11
Locate
of all claims were mental issues whereas nearly 27% costs in all claims, Sports Such as
12
Locate
as well as
13
Locate
could be a treatment to release stress; However, specialists recommended another practical way out, analyse
14
once again.

Statistics from National worker’s compensation indicate stress plays the most important role in 9 ____ Locate which cause the time losses. Staffs take about 10 ____ Locate for absence from work caused by stress. Not just time is our main concern but great expenses generated consequently. An official insurer wrote sometime that about 11 ____ Locate of all claims were mental issues whereas nearly 27% costs in all claims, Sports Such as 12 ____ Locate as well as 13 ____ Locate could be a treatment to release stress; However, specialists recommended another practical way out, analyse 14 ____ once again.$md$, NULL, ARRAY['.*workplace.*injury.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('a70cd189-4df3-56c0-84e0-64d845f4b248', '07d48fb4-6ee3-5647-a0b6-dc7642abedc9', 12, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 12

Question 9-14
Question 9-14
Complete the following summary of the paragraphs of Reading Passage, using
NO MORE THAN TWO WORDS
from the Reading Passage for each answer.
Write your answers in boxes
9-14
on your answer sheet.
Statistics from National worker’s compensation indicate stress plays the most important role in
9
Locate
which cause the time losses. Staffs take about
10
Locate
for absence from work caused by stress. Not just time is our main concern but great expenses generated consequently. An official insurer wrote sometime that about
11
Locate
of all claims were mental issues whereas nearly 27% costs in all claims, Sports Such as
12
Locate
as well as
13
Locate
could be a treatment to release stress; However, specialists recommended another practical way out, analyse
14
once again.

Statistics from National worker’s compensation indicate stress plays the most important role in 9 ____ Locate which cause the time losses. Staffs take about 10 ____ Locate for absence from work caused by stress. Not just time is our main concern but great expenses generated consequently. An official insurer wrote sometime that about 11 ____ Locate of all claims were mental issues whereas nearly 27% costs in all claims, Sports Such as 12 ____ Locate as well as 13 ____ Locate could be a treatment to release stress; However, specialists recommended another practical way out, analyse 14 ____ once again.$md$, NULL, ARRAY['.*workplace.*injury.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('73df318b-aca5-551f-8ca0-ee4df4aca2bc', '07d48fb4-6ee3-5647-a0b6-dc7642abedc9', 13, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 13

Question 9-14
Question 9-14
Complete the following summary of the paragraphs of Reading Passage, using
NO MORE THAN TWO WORDS
from the Reading Passage for each answer.
Write your answers in boxes
9-14
on your answer sheet.
Statistics from National worker’s compensation indicate stress plays the most important role in
9
Locate
which cause the time losses. Staffs take about
10
Locate
for absence from work caused by stress. Not just time is our main concern but great expenses generated consequently. An official insurer wrote sometime that about
11
Locate
of all claims were mental issues whereas nearly 27% costs in all claims, Sports Such as
12
Locate
as well as
13
Locate
could be a treatment to release stress; However, specialists recommended another practical way out, analyse
14
once again.

Statistics from National worker’s compensation indicate stress plays the most important role in 9 ____ Locate which cause the time losses. Staffs take about 10 ____ Locate for absence from work caused by stress. Not just time is our main concern but great expenses generated consequently. An official insurer wrote sometime that about 11 ____ Locate of all claims were mental issues whereas nearly 27% costs in all claims, Sports Such as 12 ____ Locate as well as 13 ____ Locate could be a treatment to release stress; However, specialists recommended another practical way out, analyse 14 ____ once again.$md$, NULL, ARRAY['.*workplace.*injury.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('82b3c32a-c4e8-5159-b0af-f8cdbeaebcf2', '07d48fb4-6ee3-5647-a0b6-dc7642abedc9', 14, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 14

Question 9-14
Question 9-14
Complete the following summary of the paragraphs of Reading Passage, using
NO MORE THAN TWO WORDS
from the Reading Passage for each answer.
Write your answers in boxes
9-14
on your answer sheet.
Statistics from National worker’s compensation indicate stress plays the most important role in
9
Locate
which cause the time losses. Staffs take about
10
Locate
for absence from work caused by stress. Not just time is our main concern but great expenses generated consequently. An official insurer wrote sometime that about
11
Locate
of all claims were mental issues whereas nearly 27% costs in all claims, Sports Such as
12
Locate
as well as
13
Locate
could be a treatment to release stress; However, specialists recommended another practical way out, analyse
14
once again.

Statistics from National worker’s compensation indicate stress plays the most important role in 9 ____ Locate which cause the time losses. Staffs take about 10 ____ Locate for absence from work caused by stress. Not just time is our main concern but great expenses generated consequently. An official insurer wrote sometime that about 11 ____ Locate of all claims were mental issues whereas nearly 27% costs in all claims, Sports Such as 12 ____ Locate as well as 13 ____ Locate could be a treatment to release stress; However, specialists recommended another practical way out, analyse 14 ____ once again.$md$, NULL, ARRAY['.*workplace.*injury.*']);

COMMIT;
