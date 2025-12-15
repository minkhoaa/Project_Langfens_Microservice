BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-activities-for-children-1088'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-activities-for-children-1088';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-activities-for-children-1088';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-activities-for-children-1088';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('87e49c4e-c02f-5ea9-8ecc-e177f6bf8f4f', 'ielts-reading-activities-for-children-1088', $t$Activities for Children$t$, $md$## Activities for Children

Nguồn:
- Test: https://mini-ielts.com/1088/reading/activities-for-children
- Solution: https://mini-ielts.com/1088/view-solution/reading/activities-for-children$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('1242f2a6-a1ed-528c-9ca3-d1f11a6ef998', '87e49c4e-c02f-5ea9-8ecc-e177f6bf8f4f', 1, $t$Reading — Activities for Children$t$, $md$Read the passage and answer questions **1–13**.

### Passage: Activities for Children

A Twenty-five years ago, children in London walked to school and played in parks and playing fields after school and at the weekend. Today they are usually driven to school by parents anxious about safety and spend hours glued to television screens or computer games . Meanwhile, community playing fields are being sold off to property developers at an alarming rate. ‘This change in lifestyle has, sadly, meant greater restrictions on children,’ says Neil Armstrong, Professor of Health and Exercise Sciences at the University of Exeter. ‘ If children continue to be this inactive, they’ll be storing up big problems for the future .’

B In 1985, Professor Armstrong headed a five-year research project into children’s fitness. The results, published in 1990, were alarming. The survey, which monitored 700 11-16-year-olds, found that 48 per cent of girls and 41 per cent of boys already exceeded safe cholesterol levels set for children by the American Heart Foundatio n. Armstrong adds, “ heart is a muscle and need exercise, or it loses its strength .” It also found that 13 per cent of boys and 10 per cent of girls were overweight. More disturbingly, the survey found that over a four-day period, half the girls and one-third of the boys did less exercise than the equivalent of a brisk 10-minute walk. High levels of cholesterol, excess body fat and inactivity are believed to increase the risk of coronary heart disease.

C Physical education is under pressure in the UK – most schools devote little more than 100 minutes a week to it in curriculum time, which is less than many other European countries . Three European countries are giving children a head start in PE, France, Austria and Switzerland – offer at least two hours in primary and secondary schools. These findings, from the European Union of Physical Education Associations, prompted specialists in children’s physiology to call on European governments to give youngsters a daily PE programme. The survey shows that the UK ranks 13th out of the 25 countries, with Ireland bottom, averaging under an hour a week for PE . From age six to 18，British children received, on average, 106 minutes of PE a week. Professor Armstrong, who presented the findings at the meeting, noted that since the introduction of the national curriculum there had been a marked fall in the time devoted to PE in UK schools, with only a minority of pupils getting two hours a week.

D As a former junior football international, Professor Armstrong is a passionate advocate for sport. Although the Government has poured millions into beefing up sport in the community, there is less commitment to it as part of the crammed school curriculum . This means that many children never acquire the necessary skills to thrive in team games. If they are no good at them, they lose interest and establish an inactive pattern of behaviour. When this is coupled with a poor diet, it will lead inevitably to weight gain. Seventy per cent of British children give up all sport when they leave school, compared with only 20 per cent of French teenagers. Professor Armstrong believes that there is far too great an emphasis on team games at school. “We need to look at the time devoted to PE and balance it between individual and pair activities, such as aerobics and badminton, as well as team sports. “He added that children need to have the opportunity to take part in a wide variety of individual, partner and team sports.

E The good news, however, is that a few small companies and children’s activity groups have reacted positively and creatively to the problem. Take That, shouts Gloria Thomas, striking a disco pose astride her mini-spacehopper. Take That, echo a flock of toddlers, adopting outrageous postures astride their space hoppers. ‘Michael Jackson, she shouts, and they all do a spoof fan-crazed shriek. During the wild and chaotic hopper race across the studio floor, commands like this are issued and responded to with untrammelled glee. The sight of 15 bouncing seven-year-olds who seem about to launch into orbit at every bounce brings tears to the eyes. Uncoordinated, loud, excited and emotional, children provide raw comedy.

F Any cardiovascular exercise is a good option, and it doesn’t necessarily have to be high intensity. It can be anything that gets your heart rate up: such as walking the dog, swimming, miming, skipping, hiking. “Even walking through the grocery store can be exercise,” Samis-Smith said. What they don’t know is that they’re at a Fit Kids class, and that the fun is a disguise for the serious exercise plan they’re covertly being taken through. Fit Kids trains parents to run fitness classes for children . ‘Ninety per cent of children don’t like team sports,’ says company director, Gillian Gale.

G A Prevention survey found that children whose parents keep in shape are much more likely to have healthy body weights themselves. “ There’s nothing worse than telling a child what he needs to do and not doing it yourself ,” says Elizabeth Ward, R.D., a Boston nutritional consultant and author of Healthy Foods, Healthy Kids . “Set a good example and get your nutritional house in order first.” In the 1930s and ’40s, kids expended 800 calories a day just walking, carrying water, and doing other chores, notes Fima Lifshitz, M.D., a pediatric endocrinologist in Santa Barbara. “Now, kids in obese families are expending only 200 calories a day in physical activity,” says Lifshitz, “ incorporate more movement in your family’s lifepark farther away from the stores at the mall, take stairs instead of the elevator, and walk to nearby friends’ houses instead of driving. ”

--------

Great thanks to volunteer Lan Nguyen has contributed these explanations and question markings.

If you want to make a better world like this, please contact us.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('1f30754f-579b-5f24-a471-9a6143b2cd71', '1242f2a6-a1ed-528c-9ca3-d1f11a6ef998', 1, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 1

Questions 1-4
Questions 1-4
The reading Passage has seven paragraphs
A-G.
Which paragraph contains the following information?
Write the correct letter
A-G
, in boxes
1-4
on your answer sheet.
1
Health and living condition of children
Locate
2
Health organization monitored physical activity
Locate
3
Comparison of exercise time between UK and other countries
Locate
4
Wrong approach for school activity
Locate

1 ____ Health and living condition of children Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('567bcb2d-0f36-551e-b4a2-9b6c201dfe1f', '1f30754f-579b-5f24-a471-9a6143b2cd71', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e086c671-8b0b-5e45-9d30-c162aa771bf7', '1f30754f-579b-5f24-a471-9a6143b2cd71', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('142932ba-415f-5dfb-9160-448147943dc8', '1f30754f-579b-5f24-a471-9a6143b2cd71', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6c0edcce-5eb7-5804-858c-344f669c8ce7', '1f30754f-579b-5f24-a471-9a6143b2cd71', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('aa6f8816-844a-5cd5-96ad-a5a8da52de43', '1f30754f-579b-5f24-a471-9a6143b2cd71', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('20050aa0-60ed-5414-bb38-6bc0fc4a20b4', '1f30754f-579b-5f24-a471-9a6143b2cd71', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('adf6d36a-b7d8-5c52-ba03-2b47daea7f7e', '1f30754f-579b-5f24-a471-9a6143b2cd71', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('1e5f8155-b82f-53dd-8071-73d50d611e35', '1242f2a6-a1ed-528c-9ca3-d1f11a6ef998', 2, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 2

Questions 1-4
Questions 1-4
The reading Passage has seven paragraphs
A-G.
Which paragraph contains the following information?
Write the correct letter
A-G
, in boxes
1-4
on your answer sheet.
1
Health and living condition of children
Locate
2
Health organization monitored physical activity
Locate
3
Comparison of exercise time between UK and other countries
Locate
4
Wrong approach for school activity
Locate

2 ____ Health organization monitored physical activity Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('077d70b9-ff17-5b8a-9bb1-d20dd17d004a', '1e5f8155-b82f-53dd-8071-73d50d611e35', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a6957c97-00db-5926-9cdc-040de5decfa9', '1e5f8155-b82f-53dd-8071-73d50d611e35', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('034f571b-3d57-51ce-8450-6457acc7fa94', '1e5f8155-b82f-53dd-8071-73d50d611e35', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('888e7e5c-f231-5c38-b4f6-35ae1ff3576c', '1e5f8155-b82f-53dd-8071-73d50d611e35', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c970d07b-a66a-5ea1-857e-be162d8a60ea', '1e5f8155-b82f-53dd-8071-73d50d611e35', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3dd8b9a5-5971-56f2-a3f2-2413fe2fcf7c', '1e5f8155-b82f-53dd-8071-73d50d611e35', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('781116dc-483f-50a2-b722-3c968f078150', '1e5f8155-b82f-53dd-8071-73d50d611e35', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('a47259e6-4ad8-536f-a64f-957297bfd90d', '1242f2a6-a1ed-528c-9ca3-d1f11a6ef998', 3, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 3

Questions 1-4
Questions 1-4
The reading Passage has seven paragraphs
A-G.
Which paragraph contains the following information?
Write the correct letter
A-G
, in boxes
1-4
on your answer sheet.
1
Health and living condition of children
Locate
2
Health organization monitored physical activity
Locate
3
Comparison of exercise time between UK and other countries
Locate
4
Wrong approach for school activity
Locate

3 ____ Comparison of exercise time between UK and other countries Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6a77931d-3d1c-5467-bece-bfa740184d15', 'a47259e6-4ad8-536f-a64f-957297bfd90d', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5af160ac-5d34-5297-a76a-49c6f40248b6', 'a47259e6-4ad8-536f-a64f-957297bfd90d', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a9482f5f-7f0a-5f7b-b9e7-9b9234c6a82f', 'a47259e6-4ad8-536f-a64f-957297bfd90d', 3, $md$C$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1a0bb6a9-03a0-524f-8bfb-3d94883e40ad', 'a47259e6-4ad8-536f-a64f-957297bfd90d', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cc297ac3-04e7-5146-ade9-5d9986c7fdda', 'a47259e6-4ad8-536f-a64f-957297bfd90d', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a8524c12-270d-588d-a9e5-1b16b2206e5d', 'a47259e6-4ad8-536f-a64f-957297bfd90d', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e1a99892-1851-5f5d-8c54-bdeb8ad31606', 'a47259e6-4ad8-536f-a64f-957297bfd90d', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('941e1400-cf3d-5c14-9a8d-16252a52d945', '1242f2a6-a1ed-528c-9ca3-d1f11a6ef998', 4, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 4

Questions 1-4
Questions 1-4
The reading Passage has seven paragraphs
A-G.
Which paragraph contains the following information?
Write the correct letter
A-G
, in boxes
1-4
on your answer sheet.
1
Health and living condition of children
Locate
2
Health organization monitored physical activity
Locate
3
Comparison of exercise time between UK and other countries
Locate
4
Wrong approach for school activity
Locate

4 ____ Wrong approach for school activity Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('85a5426d-fbf1-5a66-bc5e-7df324a90d30', '941e1400-cf3d-5c14-9a8d-16252a52d945', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('22d6dab9-ac99-56d6-a48f-2c5af5b8b491', '941e1400-cf3d-5c14-9a8d-16252a52d945', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('33a9e45b-153d-563e-8b31-aa6bc179e10b', '941e1400-cf3d-5c14-9a8d-16252a52d945', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3c9494f9-b976-5aab-808b-9f7643d44fde', '941e1400-cf3d-5c14-9a8d-16252a52d945', 4, $md$D$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b9a23255-4e32-5dbf-b17c-25769e1759d2', '941e1400-cf3d-5c14-9a8d-16252a52d945', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ded74ee7-7672-5be5-b170-c862027d57f7', '941e1400-cf3d-5c14-9a8d-16252a52d945', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d600bcbd-6eae-51ea-ab90-0afb29141b06', '941e1400-cf3d-5c14-9a8d-16252a52d945', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('151bf44e-e1c5-5371-8456-0c2b16cb6c48', '1242f2a6-a1ed-528c-9ca3-d1f11a6ef998', 5, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 5

Questions 5-8
Questions 5-8
Do the following statements agree with the information given in Reading Passage?
In boxes
5-8
on your answer sheet, write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
5
According to American Heart Foundation, cholesterol levels of boys are higher than girls’.
6
British children generally do less exercise than some other European countries.
Locate
7
Skipping becomes more and more popular in schools of UK.
8
According to Healthy Kids, the first task is for parents to encourage their children to keep the same healthy body weight.
Locate

5 ____ According to American Heart Foundation, cholesterol levels of boys are higher than girls’.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8545e16a-e7b0-5a60-876a-a44454da7c38', '151bf44e-e1c5-5371-8456-0c2b16cb6c48', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4fee7351-eb84-5512-be89-4ae382cd97cd', '151bf44e-e1c5-5371-8456-0c2b16cb6c48', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f1246676-b917-561f-b936-6474bff9daf5', '151bf44e-e1c5-5371-8456-0c2b16cb6c48', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('8caf8e9f-ce90-52e6-8b43-d1ab1991621c', '1242f2a6-a1ed-528c-9ca3-d1f11a6ef998', 6, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 6

Questions 5-8
Questions 5-8
Do the following statements agree with the information given in Reading Passage?
In boxes
5-8
on your answer sheet, write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
5
According to American Heart Foundation, cholesterol levels of boys are higher than girls’.
6
British children generally do less exercise than some other European countries.
Locate
7
Skipping becomes more and more popular in schools of UK.
8
According to Healthy Kids, the first task is for parents to encourage their children to keep the same healthy body weight.
Locate

6 ____ British children generally do less exercise than some other European countries. Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c26ecd67-8397-5402-a268-ac700c0e4a1b', '8caf8e9f-ce90-52e6-8b43-d1ab1991621c', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fe72b351-1c4e-5854-8c60-3fe3777df830', '8caf8e9f-ce90-52e6-8b43-d1ab1991621c', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7f443654-f391-54bb-8ab3-c42e4a0bf9b9', '8caf8e9f-ce90-52e6-8b43-d1ab1991621c', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('b6a27da0-764b-5189-96a9-76a2ca687ded', '1242f2a6-a1ed-528c-9ca3-d1f11a6ef998', 7, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 7

Questions 5-8
Questions 5-8
Do the following statements agree with the information given in Reading Passage?
In boxes
5-8
on your answer sheet, write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
5
According to American Heart Foundation, cholesterol levels of boys are higher than girls’.
6
British children generally do less exercise than some other European countries.
Locate
7
Skipping becomes more and more popular in schools of UK.
8
According to Healthy Kids, the first task is for parents to encourage their children to keep the same healthy body weight.
Locate

7 ____ Skipping becomes more and more popular in schools of UK.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0dd39d20-cd83-5c4d-ae58-a419c87b9610', 'b6a27da0-764b-5189-96a9-76a2ca687ded', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b36f42c0-8a4d-5aad-a14b-de12e0bbab2e', 'b6a27da0-764b-5189-96a9-76a2ca687ded', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cc6efbb4-994c-5491-b77f-678a02423473', 'b6a27da0-764b-5189-96a9-76a2ca687ded', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('17c0beb5-eded-5370-9a37-fddd4ce765d8', '1242f2a6-a1ed-528c-9ca3-d1f11a6ef998', 8, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 8

Questions 5-8
Questions 5-8
Do the following statements agree with the information given in Reading Passage?
In boxes
5-8
on your answer sheet, write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
5
According to American Heart Foundation, cholesterol levels of boys are higher than girls’.
6
British children generally do less exercise than some other European countries.
Locate
7
Skipping becomes more and more popular in schools of UK.
8
According to Healthy Kids, the first task is for parents to encourage their children to keep the same healthy body weight.
Locate

8 ____ According to Healthy Kids, the first task is for parents to encourage their children to keep the same healthy body weight. Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d6e9a322-c766-5f2a-adf2-594e2d54e49d', '17c0beb5-eded-5370-9a37-fddd4ce765d8', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9fa50828-46d7-5b49-b8eb-f6fb6fec895e', '17c0beb5-eded-5370-9a37-fddd4ce765d8', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9361c0c1-0da5-583c-a77a-f85a91efd18d', '17c0beb5-eded-5370-9a37-fddd4ce765d8', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('6e1f0c55-fd0c-543f-897d-6785ae800149', '1242f2a6-a1ed-528c-9ca3-d1f11a6ef998', 9, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 9

Questions 9-13
Questions 9-13
Choose the correct letter,
A, B, C
or
D
.
Write your answers in boxes
9-13
on your answer sheet.
9
. According to paragraph A, what does Professor Neil Armstrong concern about?
A
Spending more time on TV affect academic level
B
Parents have less time stay with their children
C
Future health of British children
D
Increasing speed of property’s development
Locate
10
. What does Armstrong indicate in Paragraph B?
A
We need to take a 10 minute walk everyday
B
We should do more activity to exercise heart
C
Girls’ situation is better than boys
D
Exercise can cure many disease
Locate
11
. What is aim of Fit Kids’ trainning?
A
Make profit by running several sessions
B
Only concentrate on one activity for each child
C
To guide parents how to organize activities for children
D
Spread the idea that team sport is better
Locate
12
. What did Lifshitz suggest in the end of this passage?
A
Create opportunities to exercise your body
B
Taking elevator saves your time
C
Kids should spend more than 200 calories each day
D
We should never drive but walk
Locate
13
. What is main idea of this passage?
A
health of the children who are overweight is at risk in the future
B
Children in UK need proper exercises
C
Government mistaken approach for children
D
Parents play the most important role in children’s activity

Choose the correct letter, A, B, C or D .$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('01efe103-2ff2-52c6-a946-64379c083d97', '1242f2a6-a1ed-528c-9ca3-d1f11a6ef998', 10, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 10

Questions 9-13
Questions 9-13
Choose the correct letter,
A, B, C
or
D
.
Write your answers in boxes
9-13
on your answer sheet.
9
. According to paragraph A, what does Professor Neil Armstrong concern about?
A
Spending more time on TV affect academic level
B
Parents have less time stay with their children
C
Future health of British children
D
Increasing speed of property’s development
Locate
10
. What does Armstrong indicate in Paragraph B?
A
We need to take a 10 minute walk everyday
B
We should do more activity to exercise heart
C
Girls’ situation is better than boys
D
Exercise can cure many disease
Locate
11
. What is aim of Fit Kids’ trainning?
A
Make profit by running several sessions
B
Only concentrate on one activity for each child
C
To guide parents how to organize activities for children
D
Spread the idea that team sport is better
Locate
12
. What did Lifshitz suggest in the end of this passage?
A
Create opportunities to exercise your body
B
Taking elevator saves your time
C
Kids should spend more than 200 calories each day
D
We should never drive but walk
Locate
13
. What is main idea of this passage?
A
health of the children who are overweight is at risk in the future
B
Children in UK need proper exercises
C
Government mistaken approach for children
D
Parents play the most important role in children’s activity

Choose the correct letter, A, B, C or D .$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('51aff118-396a-508a-bd5b-d1c7ae40dc03', '1242f2a6-a1ed-528c-9ca3-d1f11a6ef998', 11, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 11

Questions 9-13
Questions 9-13
Choose the correct letter,
A, B, C
or
D
.
Write your answers in boxes
9-13
on your answer sheet.
9
. According to paragraph A, what does Professor Neil Armstrong concern about?
A
Spending more time on TV affect academic level
B
Parents have less time stay with their children
C
Future health of British children
D
Increasing speed of property’s development
Locate
10
. What does Armstrong indicate in Paragraph B?
A
We need to take a 10 minute walk everyday
B
We should do more activity to exercise heart
C
Girls’ situation is better than boys
D
Exercise can cure many disease
Locate
11
. What is aim of Fit Kids’ trainning?
A
Make profit by running several sessions
B
Only concentrate on one activity for each child
C
To guide parents how to organize activities for children
D
Spread the idea that team sport is better
Locate
12
. What did Lifshitz suggest in the end of this passage?
A
Create opportunities to exercise your body
B
Taking elevator saves your time
C
Kids should spend more than 200 calories each day
D
We should never drive but walk
Locate
13
. What is main idea of this passage?
A
health of the children who are overweight is at risk in the future
B
Children in UK need proper exercises
C
Government mistaken approach for children
D
Parents play the most important role in children’s activity

Choose the correct letter, A, B, C or D .$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('304e3af3-56fd-51a7-9a7d-1ceb965adca0', '1242f2a6-a1ed-528c-9ca3-d1f11a6ef998', 12, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 12

Questions 9-13
Questions 9-13
Choose the correct letter,
A, B, C
or
D
.
Write your answers in boxes
9-13
on your answer sheet.
9
. According to paragraph A, what does Professor Neil Armstrong concern about?
A
Spending more time on TV affect academic level
B
Parents have less time stay with their children
C
Future health of British children
D
Increasing speed of property’s development
Locate
10
. What does Armstrong indicate in Paragraph B?
A
We need to take a 10 minute walk everyday
B
We should do more activity to exercise heart
C
Girls’ situation is better than boys
D
Exercise can cure many disease
Locate
11
. What is aim of Fit Kids’ trainning?
A
Make profit by running several sessions
B
Only concentrate on one activity for each child
C
To guide parents how to organize activities for children
D
Spread the idea that team sport is better
Locate
12
. What did Lifshitz suggest in the end of this passage?
A
Create opportunities to exercise your body
B
Taking elevator saves your time
C
Kids should spend more than 200 calories each day
D
We should never drive but walk
Locate
13
. What is main idea of this passage?
A
health of the children who are overweight is at risk in the future
B
Children in UK need proper exercises
C
Government mistaken approach for children
D
Parents play the most important role in children’s activity

Choose the correct letter, A, B, C or D .$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('12e6428e-d8df-549d-a733-d54abb856357', '1242f2a6-a1ed-528c-9ca3-d1f11a6ef998', 13, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 13

Questions 9-13
Questions 9-13
Choose the correct letter,
A, B, C
or
D
.
Write your answers in boxes
9-13
on your answer sheet.
9
. According to paragraph A, what does Professor Neil Armstrong concern about?
A
Spending more time on TV affect academic level
B
Parents have less time stay with their children
C
Future health of British children
D
Increasing speed of property’s development
Locate
10
. What does Armstrong indicate in Paragraph B?
A
We need to take a 10 minute walk everyday
B
We should do more activity to exercise heart
C
Girls’ situation is better than boys
D
Exercise can cure many disease
Locate
11
. What is aim of Fit Kids’ trainning?
A
Make profit by running several sessions
B
Only concentrate on one activity for each child
C
To guide parents how to organize activities for children
D
Spread the idea that team sport is better
Locate
12
. What did Lifshitz suggest in the end of this passage?
A
Create opportunities to exercise your body
B
Taking elevator saves your time
C
Kids should spend more than 200 calories each day
D
We should never drive but walk
Locate
13
. What is main idea of this passage?
A
health of the children who are overweight is at risk in the future
B
Children in UK need proper exercises
C
Government mistaken approach for children
D
Parents play the most important role in children’s activity

Choose the correct letter, A, B, C or D .$md$, NULL);

COMMIT;
