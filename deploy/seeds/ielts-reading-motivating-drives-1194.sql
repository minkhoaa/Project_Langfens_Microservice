BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-motivating-drives-1194'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-motivating-drives-1194';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-motivating-drives-1194';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-motivating-drives-1194';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('19c9724b-d40f-5dcb-9a9a-5f100925fb3c', 'ielts-reading-motivating-drives-1194', $t$Motivating Drives$t$, $md$## Motivating Drives

Nguồn:
- Test: https://mini-ielts.com/1194/reading/motivating-drives
- Solution: https://mini-ielts.com/1194/view-solution/reading/motivating-drives$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('febfe91b-76bd-50b4-bc8e-f40f819cb9ab', '19c9724b-d40f-5dcb-9a9a-5f100925fb3c', 1, $t$Reading — Motivating Drives$t$, $md$Read the passage and answer questions **1–11**.

### Passage: Motivating Drives

Scientists have been researching the way to get employees motivated for many years. This research in a relational study which builds the fundamental and comprehensive model for study. This is especially true when the business goal is to turn unmotivated teams into productive ones. But their researchers have limitations. It is like studying the movements of car without taking out the engine.

Motivation is what drives people to succeed and plays a vital role in enhancing an organizational development. It is important to study the motivation of employees because it is related to the emotion and behavior of employees. Recent studies show there are four drives for motivation. They are the drive to acquire, the drive to bond, the drive to comprehend and the drive to defend.

The Drive to Acquire

The drive to acquire must be met to optimize the acquire aspect as well as the achievement element. Thus the way that outstanding performance is recognized, the type of perks that is provided to polish the career path. But sometimes a written letter of appreciation generates more motivation than a thousand dollar check, which can serve as the invisible power to boost business engagement. Successful organizations and leaders not only need to focus on the optimization of physical reward but also on moving other levers within the organization that can drive motivation.

The Drive to Bond

The drive to bond is also key to driving motivation. There are many kinds of bonds between people, like friendship, family. In company, employees also want to be an essential part of company. They want to belong to the company. Employees will be motivated if they find personal belonging to the company. In the meantime, the most commitment will be achieved by the employee on condition that the force of motivation within the employee affects the direction, intensity and persistence of decision and behavior in company.

The Drive to Comprehend

The drive to comprehend motivates many employees to higher performance. For years, it has been known that setting stretch goals can greatly impact performance. Organizations need to ensure that the various job roles provide employees with simulation that challenges them or allow them to grow. Employees don’t want to do meaningless things or monotonous job. If the job didn’t provide them with personal meaning and fulfillment, they will leave the company.

The Drive to Defend

The drive to defend is often the hardest lever to pull. This drive manifests itself as a quest to create and promote justice, fairness, and the ability to express ourselves freely. The organizational lever for this basic human motivator is resource allocation. This drive is also met through an employee feeling connection to a company. If their companies are merged with another, they will show worries.

Two studies have been done to find the relations between the four drives and motivation. The article based on two studies was finally published in Harvard Business Review. Most authors’ arguments have laid emphasis on four-drive theory and actual investigations. Using the results of the surveys which executed with employees from Fortune 500 companies and other two global businesses (P company and H company), the article mentions about how independent drives influence employees’ behavior and how organizational levers boost employee motivation.

The studies show that the drive to bond is most related to fulfilling commitment, while the drive to comprehend is most related to how much effort employees spend on works. The drive to acquire can be satisfied by a rewarding system which ties rewards to performances, and gives the best people opportunities for advancement. For drive to defend, a study on the merging of P company and H company shows that employees in former company show an unusual cooperating attitude.

The key to successfully motivate employees is to meet all drives. Each of these drives is important if we are to understand employee motivation. These four drives, while not necessarily the only human drives, are the ones that are central to unified understanding of modern human life.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('9988c87d-a4a7-54d5-baaa-536340412ade', 'febfe91b-76bd-50b4-bc8e-f40f819cb9ab', 1, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 1

Questions 1-5
Questions 1-5
Choose the correct letter
A, B, C
or
D
Write the correct letter in boxes
1-5
on your answer sheet.
1.
According to the passage, what are we told about the study of motivation?
A
The theory of motivating employees is starting to catch attention in organizations in recent years.
B
It is very important for managers to know how to motivate their subordinates because it is related to the salary of employees.
C
Researchers have tended to be too theoretical to their study.
D
The goal of employee motivation is to increase the profit of organizations.
2.
What can be inferred from the passage about the study of people’s drives?
A
Satisfying employees’ drives can positively lead to the change of behavior.
B
Satisfying employees’ drives will negatively affect their emotions.
C
Satisfying employees’ drives can increase companies’
productions.
D
Satisfying employees’ drives will result in employees’ outstanding performance.
3.
According to paragraph three, in order to optimize employees’
performance,
are needed.
A
Drive to acquire and achievement element
B
Outstanding performance and recognition
C
Career fulfillment and a thousand dollar check
D
Financial incentive and recognition
4.
According to paragraph five, how does “the drive to comprehend” help employees perform better?
A
It can help employees better understand the development of their organizations.
B
It can help employees feel their task in meaningful to their companies.
C
It can help employees set higher goals.
D
It can provide employees with repetitive tasks.
5.
According to paragraph six, which of following is true about “drive to defend”?
A
Organizational resource is the most difficult to allocate.
B
It is more difficult to implement than the drive to comprehend.
C
Employees think it is very important to voice their own opinions.
D
Employees think it is very important to connect with a merged
corporation.

Choose the correct letter A, B, C or D$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('fc4a10ef-5720-5b45-a698-01b5027f98e2', 'febfe91b-76bd-50b4-bc8e-f40f819cb9ab', 2, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 2

Questions 1-5
Questions 1-5
Choose the correct letter
A, B, C
or
D
Write the correct letter in boxes
1-5
on your answer sheet.
1.
According to the passage, what are we told about the study of motivation?
A
The theory of motivating employees is starting to catch attention in organizations in recent years.
B
It is very important for managers to know how to motivate their subordinates because it is related to the salary of employees.
C
Researchers have tended to be too theoretical to their study.
D
The goal of employee motivation is to increase the profit of organizations.
2.
What can be inferred from the passage about the study of people’s drives?
A
Satisfying employees’ drives can positively lead to the change of behavior.
B
Satisfying employees’ drives will negatively affect their emotions.
C
Satisfying employees’ drives can increase companies’
productions.
D
Satisfying employees’ drives will result in employees’ outstanding performance.
3.
According to paragraph three, in order to optimize employees’
performance,
are needed.
A
Drive to acquire and achievement element
B
Outstanding performance and recognition
C
Career fulfillment and a thousand dollar check
D
Financial incentive and recognition
4.
According to paragraph five, how does “the drive to comprehend” help employees perform better?
A
It can help employees better understand the development of their organizations.
B
It can help employees feel their task in meaningful to their companies.
C
It can help employees set higher goals.
D
It can provide employees with repetitive tasks.
5.
According to paragraph six, which of following is true about “drive to defend”?
A
Organizational resource is the most difficult to allocate.
B
It is more difficult to implement than the drive to comprehend.
C
Employees think it is very important to voice their own opinions.
D
Employees think it is very important to connect with a merged
corporation.

Choose the correct letter A, B, C or D$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('54da384a-0313-5802-bee9-c95f2d99cbf4', 'febfe91b-76bd-50b4-bc8e-f40f819cb9ab', 3, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 3

Questions 1-5
Questions 1-5
Choose the correct letter
A, B, C
or
D
Write the correct letter in boxes
1-5
on your answer sheet.
1.
According to the passage, what are we told about the study of motivation?
A
The theory of motivating employees is starting to catch attention in organizations in recent years.
B
It is very important for managers to know how to motivate their subordinates because it is related to the salary of employees.
C
Researchers have tended to be too theoretical to their study.
D
The goal of employee motivation is to increase the profit of organizations.
2.
What can be inferred from the passage about the study of people’s drives?
A
Satisfying employees’ drives can positively lead to the change of behavior.
B
Satisfying employees’ drives will negatively affect their emotions.
C
Satisfying employees’ drives can increase companies’
productions.
D
Satisfying employees’ drives will result in employees’ outstanding performance.
3.
According to paragraph three, in order to optimize employees’
performance,
are needed.
A
Drive to acquire and achievement element
B
Outstanding performance and recognition
C
Career fulfillment and a thousand dollar check
D
Financial incentive and recognition
4.
According to paragraph five, how does “the drive to comprehend” help employees perform better?
A
It can help employees better understand the development of their organizations.
B
It can help employees feel their task in meaningful to their companies.
C
It can help employees set higher goals.
D
It can provide employees with repetitive tasks.
5.
According to paragraph six, which of following is true about “drive to defend”?
A
Organizational resource is the most difficult to allocate.
B
It is more difficult to implement than the drive to comprehend.
C
Employees think it is very important to voice their own opinions.
D
Employees think it is very important to connect with a merged
corporation.

Choose the correct letter A, B, C or D$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('dc319328-4629-5982-b3d2-45782f0d9804', 'febfe91b-76bd-50b4-bc8e-f40f819cb9ab', 4, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 4

Questions 1-5
Questions 1-5
Choose the correct letter
A, B, C
or
D
Write the correct letter in boxes
1-5
on your answer sheet.
1.
According to the passage, what are we told about the study of motivation?
A
The theory of motivating employees is starting to catch attention in organizations in recent years.
B
It is very important for managers to know how to motivate their subordinates because it is related to the salary of employees.
C
Researchers have tended to be too theoretical to their study.
D
The goal of employee motivation is to increase the profit of organizations.
2.
What can be inferred from the passage about the study of people’s drives?
A
Satisfying employees’ drives can positively lead to the change of behavior.
B
Satisfying employees’ drives will negatively affect their emotions.
C
Satisfying employees’ drives can increase companies’
productions.
D
Satisfying employees’ drives will result in employees’ outstanding performance.
3.
According to paragraph three, in order to optimize employees’
performance,
are needed.
A
Drive to acquire and achievement element
B
Outstanding performance and recognition
C
Career fulfillment and a thousand dollar check
D
Financial incentive and recognition
4.
According to paragraph five, how does “the drive to comprehend” help employees perform better?
A
It can help employees better understand the development of their organizations.
B
It can help employees feel their task in meaningful to their companies.
C
It can help employees set higher goals.
D
It can provide employees with repetitive tasks.
5.
According to paragraph six, which of following is true about “drive to defend”?
A
Organizational resource is the most difficult to allocate.
B
It is more difficult to implement than the drive to comprehend.
C
Employees think it is very important to voice their own opinions.
D
Employees think it is very important to connect with a merged
corporation.

Choose the correct letter A, B, C or D$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('225ef739-5585-54f0-ae7d-0f20d47841b7', 'febfe91b-76bd-50b4-bc8e-f40f819cb9ab', 5, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 5

Questions 1-5
Questions 1-5
Choose the correct letter
A, B, C
or
D
Write the correct letter in boxes
1-5
on your answer sheet.
1.
According to the passage, what are we told about the study of motivation?
A
The theory of motivating employees is starting to catch attention in organizations in recent years.
B
It is very important for managers to know how to motivate their subordinates because it is related to the salary of employees.
C
Researchers have tended to be too theoretical to their study.
D
The goal of employee motivation is to increase the profit of organizations.
2.
What can be inferred from the passage about the study of people’s drives?
A
Satisfying employees’ drives can positively lead to the change of behavior.
B
Satisfying employees’ drives will negatively affect their emotions.
C
Satisfying employees’ drives can increase companies’
productions.
D
Satisfying employees’ drives will result in employees’ outstanding performance.
3.
According to paragraph three, in order to optimize employees’
performance,
are needed.
A
Drive to acquire and achievement element
B
Outstanding performance and recognition
C
Career fulfillment and a thousand dollar check
D
Financial incentive and recognition
4.
According to paragraph five, how does “the drive to comprehend” help employees perform better?
A
It can help employees better understand the development of their organizations.
B
It can help employees feel their task in meaningful to their companies.
C
It can help employees set higher goals.
D
It can provide employees with repetitive tasks.
5.
According to paragraph six, which of following is true about “drive to defend”?
A
Organizational resource is the most difficult to allocate.
B
It is more difficult to implement than the drive to comprehend.
C
Employees think it is very important to voice their own opinions.
D
Employees think it is very important to connect with a merged
corporation.

Choose the correct letter A, B, C or D$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('a9562f48-b609-5d48-8260-b7d8c765a5f8', 'febfe91b-76bd-50b4-bc8e-f40f819cb9ab', 9, 'YES_NO_NOT_GIVEN', 'READING', 3, $md$### Question 9

Questions 9-14
Questions 9-14
Do the following statements agree with the claims of the writer in Reading Passage?
In boxes
35-40
on your answer sheet, write
YES
if the statement agree with the claims of the writer
NO
if the statement contradicts the claims of the writer
NOT GIVEN
if it is impossible to say what the writer thinks about this
9
Increasing pay can lead to the high work motivation.
10
Local companies benefit more from global companies through the study.
11
Employees achieve the most commitment if their drive to comprehend is
met.
12
The employees in former company presented unusual attitude toward the merging of two companies.
13
The two studies are done to analyze the relationship between the natural drives and the attitude of employees.
14
Rewarding system cause the company to lose profit.

9 ____ Increasing pay can lead to the high work motivation.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('819a2329-d5d5-5840-bea5-e9240be9ca8e', 'a9562f48-b609-5d48-8260-b7d8c765a5f8', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('025f76fd-c5f8-5551-a9a0-3f05acce517a', 'a9562f48-b609-5d48-8260-b7d8c765a5f8', 2, $md$NO$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5b707c22-e3d0-5bee-96fc-045bff54eebc', 'a9562f48-b609-5d48-8260-b7d8c765a5f8', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('3e9d8536-bd9d-573d-a4ec-04fbbbc9c544', 'febfe91b-76bd-50b4-bc8e-f40f819cb9ab', 10, 'YES_NO_NOT_GIVEN', 'READING', 4, $md$### Question 10

Questions 9-14
Questions 9-14
Do the following statements agree with the claims of the writer in Reading Passage?
In boxes
35-40
on your answer sheet, write
YES
if the statement agree with the claims of the writer
NO
if the statement contradicts the claims of the writer
NOT GIVEN
if it is impossible to say what the writer thinks about this
9
Increasing pay can lead to the high work motivation.
10
Local companies benefit more from global companies through the study.
11
Employees achieve the most commitment if their drive to comprehend is
met.
12
The employees in former company presented unusual attitude toward the merging of two companies.
13
The two studies are done to analyze the relationship between the natural drives and the attitude of employees.
14
Rewarding system cause the company to lose profit.

10 ____ Local companies benefit more from global companies through the study.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('68b965f9-550f-5f78-a3a2-b4b63b3ade9b', '3e9d8536-bd9d-573d-a4ec-04fbbbc9c544', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('400a560f-807f-593b-b937-c0484bc05923', '3e9d8536-bd9d-573d-a4ec-04fbbbc9c544', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5b2c1a4b-0a2a-5d06-ab5a-4bacfd367aae', '3e9d8536-bd9d-573d-a4ec-04fbbbc9c544', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('41efe72e-01f0-5554-a11d-a7efc35d61c1', 'febfe91b-76bd-50b4-bc8e-f40f819cb9ab', 11, 'YES_NO_NOT_GIVEN', 'READING', 4, $md$### Question 11

Questions 9-14
Questions 9-14
Do the following statements agree with the claims of the writer in Reading Passage?
In boxes
35-40
on your answer sheet, write
YES
if the statement agree with the claims of the writer
NO
if the statement contradicts the claims of the writer
NOT GIVEN
if it is impossible to say what the writer thinks about this
9
Increasing pay can lead to the high work motivation.
10
Local companies benefit more from global companies through the study.
11
Employees achieve the most commitment if their drive to comprehend is
met.
12
The employees in former company presented unusual attitude toward the merging of two companies.
13
The two studies are done to analyze the relationship between the natural drives and the attitude of employees.
14
Rewarding system cause the company to lose profit.

11 ____ Employees achieve the most commitment if their drive to comprehend is met.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('840b64f7-7c4f-5c5f-b641-a84972d9d9e0', '41efe72e-01f0-5554-a11d-a7efc35d61c1', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ffb263f4-38be-58f9-9724-8fe946f08839', '41efe72e-01f0-5554-a11d-a7efc35d61c1', 2, $md$NO$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3068d4dd-b46f-5293-a3c4-c8999942d3b8', '41efe72e-01f0-5554-a11d-a7efc35d61c1', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('c5deaa50-b797-53cc-81da-79e7bf8c78e0', 'febfe91b-76bd-50b4-bc8e-f40f819cb9ab', 12, 'YES_NO_NOT_GIVEN', 'READING', 4, $md$### Question 12

Questions 9-14
Questions 9-14
Do the following statements agree with the claims of the writer in Reading Passage?
In boxes
35-40
on your answer sheet, write
YES
if the statement agree with the claims of the writer
NO
if the statement contradicts the claims of the writer
NOT GIVEN
if it is impossible to say what the writer thinks about this
9
Increasing pay can lead to the high work motivation.
10
Local companies benefit more from global companies through the study.
11
Employees achieve the most commitment if their drive to comprehend is
met.
12
The employees in former company presented unusual attitude toward the merging of two companies.
13
The two studies are done to analyze the relationship between the natural drives and the attitude of employees.
14
Rewarding system cause the company to lose profit.

12 ____ The employees in former company presented unusual attitude toward the merging of two companies.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f68f54a5-928e-5d1f-922b-c849bb7db97c', 'c5deaa50-b797-53cc-81da-79e7bf8c78e0', 1, $md$YES$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('abd1bb92-def6-5fb2-a0e7-e4f5a80756cb', 'c5deaa50-b797-53cc-81da-79e7bf8c78e0', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('14c0558d-acbe-5150-b809-201c59b4fd5e', 'c5deaa50-b797-53cc-81da-79e7bf8c78e0', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('abfcf01e-935a-53fd-ade1-9a447b6890a0', 'febfe91b-76bd-50b4-bc8e-f40f819cb9ab', 13, 'YES_NO_NOT_GIVEN', 'READING', 4, $md$### Question 13

Questions 9-14
Questions 9-14
Do the following statements agree with the claims of the writer in Reading Passage?
In boxes
35-40
on your answer sheet, write
YES
if the statement agree with the claims of the writer
NO
if the statement contradicts the claims of the writer
NOT GIVEN
if it is impossible to say what the writer thinks about this
9
Increasing pay can lead to the high work motivation.
10
Local companies benefit more from global companies through the study.
11
Employees achieve the most commitment if their drive to comprehend is
met.
12
The employees in former company presented unusual attitude toward the merging of two companies.
13
The two studies are done to analyze the relationship between the natural drives and the attitude of employees.
14
Rewarding system cause the company to lose profit.

13 ____ The two studies are done to analyze the relationship between the natural drives and the attitude of employees.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ad0b6796-46ab-561b-be2f-709a94a55671', 'abfcf01e-935a-53fd-ade1-9a447b6890a0', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('59cf5ec9-20ec-5e7f-8f49-10b5fc36ee03', 'abfcf01e-935a-53fd-ade1-9a447b6890a0', 2, $md$NO$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('edabec41-c4f4-5a21-a860-41175b95e4e7', 'abfcf01e-935a-53fd-ade1-9a447b6890a0', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('46fab5ff-aea3-5e78-ae3f-dd54a4429eed', 'febfe91b-76bd-50b4-bc8e-f40f819cb9ab', 14, 'YES_NO_NOT_GIVEN', 'READING', 4, $md$### Question 14

Questions 9-14
Questions 9-14
Do the following statements agree with the claims of the writer in Reading Passage?
In boxes
35-40
on your answer sheet, write
YES
if the statement agree with the claims of the writer
NO
if the statement contradicts the claims of the writer
NOT GIVEN
if it is impossible to say what the writer thinks about this
9
Increasing pay can lead to the high work motivation.
10
Local companies benefit more from global companies through the study.
11
Employees achieve the most commitment if their drive to comprehend is
met.
12
The employees in former company presented unusual attitude toward the merging of two companies.
13
The two studies are done to analyze the relationship between the natural drives and the attitude of employees.
14
Rewarding system cause the company to lose profit.

14 ____ Rewarding system cause the company to lose profit.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('38e7282f-f312-5f6d-ae55-972e64d96ea8', '46fab5ff-aea3-5e78-ae3f-dd54a4429eed', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5e42faf6-715f-5ab6-a983-71c18eefc7c4', '46fab5ff-aea3-5e78-ae3f-dd54a4429eed', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a782cd0f-7eaa-5c5e-b165-2f4621900d79', '46fab5ff-aea3-5e78-ae3f-dd54a4429eed', 3, $md$NOT GIVEN$md$, true);

COMMIT;
