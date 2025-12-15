BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-grey-workers-1352'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-grey-workers-1352';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-grey-workers-1352';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-grey-workers-1352';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('86b20166-4981-50b3-a1f5-e7cf39064bf4', 'ielts-reading-grey-workers-1352', $t$Grey Workers$t$, $md$## Grey Workers

Nguồn:
- Test: https://mini-ielts.com/1352/reading/grey-workers
- Solution: https://mini-ielts.com/1352/view-solution/reading/grey-workers$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('936e8fe5-5fb4-52e2-9dac-508db4dab429', '86b20166-4981-50b3-a1f5-e7cf39064bf4', 1, $t$Reading — Grey Workers$t$, $md$Read the passage and answer questions **1–9**.

### Passage: Grey Workers

A

Given the speed at which their workers are growing greyer, employers know surprisingly little about how productive they are. The general assumption is that the old are paid more in spite of, rather than because of, their extra productivity. That might partly explain why, when employers are under pressure to cut costs, they persuade the 55-year-olds to take early retirement. Earlier this year, Sun Life of Canada, an insurance company, announced that it was offering redundancy to all its British employees aged 50 or over “to bring in new blood”.

B

In Japan, says Mariko Fujiwara, an industrial anthropologist who runs a think-tank for Hakuhodo, Japan’s second-largest advertising agency, most companies are bringing down the retirement age from the traditional 57 to 50 or thereabouts – and in some cases, such as Nissan, to 45. More than perhaps anywhere else, pay in Japan is linked to seniority. Given that the percentage of workers who have spent more than 32 years with the same employer rose from 11% in 1980 to 42% by 1994, it is hardly surprising that seniority-based wage costs have become the most intractable item on corporate profit-and-loss accounts.

C

In Germany, Patrick Pohl, spokesman for Hoechst, expresses a widely held view: “The company is trying to lower the average age of the workforce. Perhaps the main reason for replacing older workers is that it makes it easier to ‘defrost’ the corporate culture. Older workers are less willing to try a new way of thinking. Younger workers are cheaper and more flexible.” Some German firms are hampered from getting rid of older workers as quickly as they would like. At SGL Carbon, a graphite producer, the average age of workers has been going up not down. The reason, says the company’s Ivo Lingnau, is not that SGL values older workers more. It is collective bargaining: the union agreement puts strict limits on the proportion of workers that may retire early.

D

Clearly, when older people do heavy physical work, their age may affect their productivity. But other skills may increase with age, including many that are crucial for good management, such as an ability to handle people diplomatically, to run a meeting or to spot a problem before it blows up. Peter Hicks, who co-ordinates OECD work on the policy implications of ageing, says that plenty of research suggests older people are paid more because they are worth more.

E

And the virtues of the young may be exaggerated. “The few companies that have kept on older workers find they have good judgment and their productivity is good,” says Mr Peterson. “Besides, their education standards are much better than those of today’s young high-school graduates.” Companies may say that older workers are not worth training, because they are reaching the end of their working lives: in fact, young people tend to switch jobs so frequently that offer the worst returns on training. “The median age for employer-driven training is the late 40s and early 50s,” says Mr Hicks. “It goes mainly to managers.”

F

Take away those seniority-based pay scales, and older workers may become a much more attractive employment proposition. But most companies (and many workers) are uncomfortable with the idea of reducing someone’s pay in later life – although workers on piece-fates often earn less over time. So retaining the services of older workers may mean employing them in new ways.

G

One innovation, described in Mr Walker’s report on combating age barriers, was devised by IBM Belgium. Faced with the need to cut staff costs, and have decided to concentrate cuts on 55-60-year-olds, IBM set up a separate company called SkillTeam, which re-employed any of the early retired who wanted to go on working up to the age of 60. An employee who joined SkillTeam at the age of 55 on a five-year contract would work for 58% of his time, over the full period, for 88% of his last IBM salary. The company offered services to IBM, thus allowing it to retain access to some of the intellectual capital it would otherwise have lost.

H

The best way to tempt the old to go on working may be to build on such “bridge” jobs: part-time or temporary employment that creates a more gradual transition from full-time work to retirement. Mr Quinn, who has studied the phenomenon, finds that, in the United States, nearly half of all men and women who had been in full-time jobs in middle age moved into such “bridge” jobs at the end of their working lives. In general, it is the best-paid and worst-paid who carry on working: “There are”, he says, “two very different types of bridge jog-holders – those who continue working because they have to and those who continue working because they want to, even though they could afford to retire.”

I

If the job market grows more flexible, the old may find more jobs that suit them. Often, they will be self-employed. Sometimes, they may start their own businesses: a study by David Storey of Warwick University found that, in Britain, 70% of businesses started by people over 55 survived, compared with an average of only 19%. To coax the old back into the job market, work will not only have to pay. It will need to be more fun than touring the country in an Airstream trailer, or seeing the grandchildren, or playing golf. Only then will there be many more Joe Clarks.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('51d5b932-512f-558c-a794-979c2a33947c', '936e8fe5-5fb4-52e2-9dac-508db4dab429', 1, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 1

Questions 1-4
Questions 1-4
Do the following statements agree with the information given in Reading Passage?
In boxes 1-4 on your answer sheet, write
TRUE
, if the statement is true
FALSE
, if the statement is false
NOT GIVEN
, if the information is not given in the passage
1
Insurance company Sun Life of Canada made a decision that it would hire more Canadian employees rather than British ones in order to get a fresh staff.
2
Unlike other places, employees in Japan get paid according to the years they are employed.
3
Elder workers are laid off by some German companies which are refreshing corporate culture.
4
According to Peter Hicks, companies pay older people more regardless of the contribution they make.

1 ____ Insurance company Sun Life of Canada made a decision that it would hire more Canadian employees rather than British ones in order to get a fresh staff.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b277cbfd-bb2f-5c00-bf8c-e3823ba3bd35', '51d5b932-512f-558c-a794-979c2a33947c', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c705ed32-dc05-588d-9cf2-b504c93d5007', '51d5b932-512f-558c-a794-979c2a33947c', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('591805be-0bca-5c6f-8383-d06ca9d0a7e8', '51d5b932-512f-558c-a794-979c2a33947c', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('a0298fd7-5fb9-553d-8042-9c88cd09c992', '936e8fe5-5fb4-52e2-9dac-508db4dab429', 2, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 2

Questions 1-4
Questions 1-4
Do the following statements agree with the information given in Reading Passage?
In boxes 1-4 on your answer sheet, write
TRUE
, if the statement is true
FALSE
, if the statement is false
NOT GIVEN
, if the information is not given in the passage
1
Insurance company Sun Life of Canada made a decision that it would hire more Canadian employees rather than British ones in order to get a fresh staff.
2
Unlike other places, employees in Japan get paid according to the years they are employed.
3
Elder workers are laid off by some German companies which are refreshing corporate culture.
4
According to Peter Hicks, companies pay older people more regardless of the contribution they make.

2 ____ Unlike other places, employees in Japan get paid according to the years they are employed.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('37c82c3c-fa47-52aa-a389-ecd515f69daf', 'a0298fd7-5fb9-553d-8042-9c88cd09c992', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4ea318f4-8a8a-5779-9a1d-86494769d034', 'a0298fd7-5fb9-553d-8042-9c88cd09c992', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0317f3ca-a104-5859-b8c1-4783a25bc14b', 'a0298fd7-5fb9-553d-8042-9c88cd09c992', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('1e3082e9-3d92-5c51-b89c-60e9d1ab791d', '936e8fe5-5fb4-52e2-9dac-508db4dab429', 3, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 3

Questions 1-4
Questions 1-4
Do the following statements agree with the information given in Reading Passage?
In boxes 1-4 on your answer sheet, write
TRUE
, if the statement is true
FALSE
, if the statement is false
NOT GIVEN
, if the information is not given in the passage
1
Insurance company Sun Life of Canada made a decision that it would hire more Canadian employees rather than British ones in order to get a fresh staff.
2
Unlike other places, employees in Japan get paid according to the years they are employed.
3
Elder workers are laid off by some German companies which are refreshing corporate culture.
4
According to Peter Hicks, companies pay older people more regardless of the contribution they make.

3 ____ Elder workers are laid off by some German companies which are refreshing corporate culture.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('46c0b592-9440-5d1e-8d83-9d4854cd5197', '1e3082e9-3d92-5c51-b89c-60e9d1ab791d', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('30e737e3-02db-5e20-ba62-87b7f00d390d', '1e3082e9-3d92-5c51-b89c-60e9d1ab791d', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ec533874-9803-5328-ae3c-91d7d69df086', '1e3082e9-3d92-5c51-b89c-60e9d1ab791d', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('22a07682-9266-524b-8422-aad45cccd5ff', '936e8fe5-5fb4-52e2-9dac-508db4dab429', 4, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 4

Questions 1-4
Questions 1-4
Do the following statements agree with the information given in Reading Passage?
In boxes 1-4 on your answer sheet, write
TRUE
, if the statement is true
FALSE
, if the statement is false
NOT GIVEN
, if the information is not given in the passage
1
Insurance company Sun Life of Canada made a decision that it would hire more Canadian employees rather than British ones in order to get a fresh staff.
2
Unlike other places, employees in Japan get paid according to the years they are employed.
3
Elder workers are laid off by some German companies which are refreshing corporate culture.
4
According to Peter Hicks, companies pay older people more regardless of the contribution they make.

4 ____ According to Peter Hicks, companies pay older people more regardless of the contribution they make.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c2154c2b-a520-5793-8a92-0f30441dbd11', '22a07682-9266-524b-8422-aad45cccd5ff', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8930f3da-a17a-50f1-b528-81bab4c91cb7', '22a07682-9266-524b-8422-aad45cccd5ff', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('65322948-94dc-5709-921a-f34d680d00a6', '22a07682-9266-524b-8422-aad45cccd5ff', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('f98a8ca5-2fdb-5170-814c-7ef51a56dab8', '936e8fe5-5fb4-52e2-9dac-508db4dab429', 9, 'CLASSIFICATION', 'READING', 3, $md$### Question 9

Questions 9-13
Questions 9-13
Choose the correct letter, A
,
B, C or D.
Write your answers in boxes 9-13 on your answer sheet.
9. According to paragraph F, the firms and workers still hold the opinion that:
A
Older workers are more likely to attract other staff
B
people are not happy if pay gets lower in retiring age.
C
Older people have more retaining motivation than young people
D
young people often earn less for their piece-rates salary.
10. SkillTeam that has been founded by IBM conducted which of the following movement:
A
Ask all the old worker to continue their job on former working hours basis
B
Carry on the action of cutting off the elder’s proportion of employment
C
Ask employees to work more hours in order to get extra pay
D
Re-hire old employees and kept the salary a bit lower
11. which of the followings is correct according to the research of Mr Quinn:
A
About 50% of all employees in America switched into ‘Bridge’ jobs.
B
Only the worst-paid continue to work.
C
More men than women fell into the category of ’bridge’ work.
D
Some old people keep working for their motives rather than an economic incentive.
12. Which of the followings is correct according to David Storey:
A
70% of business is successful if hire more older people.
B
The average success of the self-employed business is getting lower.
C
Self-employed elder people are more likely to survive.
D
Older people’s working hours are more flexible.
13. What is the main purpose of the author in writing this passage?
A
there must be a successful retiring program for the old
B
older people should be correctly valued in employment
C
old people should offer more helping young employees grow.
D
There are more jobs in the world that only employ older people

Choose the correct letter, A , B, C or D.$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('778c34d9-fcdb-5fac-ab93-cc097ab01c34', '936e8fe5-5fb4-52e2-9dac-508db4dab429', 10, 'CLASSIFICATION', 'READING', 4, $md$### Question 10

Questions 9-13
Questions 9-13
Choose the correct letter, A
,
B, C or D.
Write your answers in boxes 9-13 on your answer sheet.
9. According to paragraph F, the firms and workers still hold the opinion that:
A
Older workers are more likely to attract other staff
B
people are not happy if pay gets lower in retiring age.
C
Older people have more retaining motivation than young people
D
young people often earn less for their piece-rates salary.
10. SkillTeam that has been founded by IBM conducted which of the following movement:
A
Ask all the old worker to continue their job on former working hours basis
B
Carry on the action of cutting off the elder’s proportion of employment
C
Ask employees to work more hours in order to get extra pay
D
Re-hire old employees and kept the salary a bit lower
11. which of the followings is correct according to the research of Mr Quinn:
A
About 50% of all employees in America switched into ‘Bridge’ jobs.
B
Only the worst-paid continue to work.
C
More men than women fell into the category of ’bridge’ work.
D
Some old people keep working for their motives rather than an economic incentive.
12. Which of the followings is correct according to David Storey:
A
70% of business is successful if hire more older people.
B
The average success of the self-employed business is getting lower.
C
Self-employed elder people are more likely to survive.
D
Older people’s working hours are more flexible.
13. What is the main purpose of the author in writing this passage?
A
there must be a successful retiring program for the old
B
older people should be correctly valued in employment
C
old people should offer more helping young employees grow.
D
There are more jobs in the world that only employ older people

Choose the correct letter, A , B, C or D.$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('6358177f-b96b-5f37-8f30-5fb3777d7d02', '936e8fe5-5fb4-52e2-9dac-508db4dab429', 11, 'CLASSIFICATION', 'READING', 4, $md$### Question 11

Questions 9-13
Questions 9-13
Choose the correct letter, A
,
B, C or D.
Write your answers in boxes 9-13 on your answer sheet.
9. According to paragraph F, the firms and workers still hold the opinion that:
A
Older workers are more likely to attract other staff
B
people are not happy if pay gets lower in retiring age.
C
Older people have more retaining motivation than young people
D
young people often earn less for their piece-rates salary.
10. SkillTeam that has been founded by IBM conducted which of the following movement:
A
Ask all the old worker to continue their job on former working hours basis
B
Carry on the action of cutting off the elder’s proportion of employment
C
Ask employees to work more hours in order to get extra pay
D
Re-hire old employees and kept the salary a bit lower
11. which of the followings is correct according to the research of Mr Quinn:
A
About 50% of all employees in America switched into ‘Bridge’ jobs.
B
Only the worst-paid continue to work.
C
More men than women fell into the category of ’bridge’ work.
D
Some old people keep working for their motives rather than an economic incentive.
12. Which of the followings is correct according to David Storey:
A
70% of business is successful if hire more older people.
B
The average success of the self-employed business is getting lower.
C
Self-employed elder people are more likely to survive.
D
Older people’s working hours are more flexible.
13. What is the main purpose of the author in writing this passage?
A
there must be a successful retiring program for the old
B
older people should be correctly valued in employment
C
old people should offer more helping young employees grow.
D
There are more jobs in the world that only employ older people

Choose the correct letter, A , B, C or D.$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('dd13cf40-b7e2-538d-96fe-68fd3f35d8ba', '936e8fe5-5fb4-52e2-9dac-508db4dab429', 12, 'CLASSIFICATION', 'READING', 4, $md$### Question 12

Questions 9-13
Questions 9-13
Choose the correct letter, A
,
B, C or D.
Write your answers in boxes 9-13 on your answer sheet.
9. According to paragraph F, the firms and workers still hold the opinion that:
A
Older workers are more likely to attract other staff
B
people are not happy if pay gets lower in retiring age.
C
Older people have more retaining motivation than young people
D
young people often earn less for their piece-rates salary.
10. SkillTeam that has been founded by IBM conducted which of the following movement:
A
Ask all the old worker to continue their job on former working hours basis
B
Carry on the action of cutting off the elder’s proportion of employment
C
Ask employees to work more hours in order to get extra pay
D
Re-hire old employees and kept the salary a bit lower
11. which of the followings is correct according to the research of Mr Quinn:
A
About 50% of all employees in America switched into ‘Bridge’ jobs.
B
Only the worst-paid continue to work.
C
More men than women fell into the category of ’bridge’ work.
D
Some old people keep working for their motives rather than an economic incentive.
12. Which of the followings is correct according to David Storey:
A
70% of business is successful if hire more older people.
B
The average success of the self-employed business is getting lower.
C
Self-employed elder people are more likely to survive.
D
Older people’s working hours are more flexible.
13. What is the main purpose of the author in writing this passage?
A
there must be a successful retiring program for the old
B
older people should be correctly valued in employment
C
old people should offer more helping young employees grow.
D
There are more jobs in the world that only employ older people

Choose the correct letter, A , B, C or D.$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('a5d5a2fd-237a-5494-834b-11ea9a7993f2', '936e8fe5-5fb4-52e2-9dac-508db4dab429', 13, 'CLASSIFICATION', 'READING', 4, $md$### Question 13

Questions 9-13
Questions 9-13
Choose the correct letter, A
,
B, C or D.
Write your answers in boxes 9-13 on your answer sheet.
9. According to paragraph F, the firms and workers still hold the opinion that:
A
Older workers are more likely to attract other staff
B
people are not happy if pay gets lower in retiring age.
C
Older people have more retaining motivation than young people
D
young people often earn less for their piece-rates salary.
10. SkillTeam that has been founded by IBM conducted which of the following movement:
A
Ask all the old worker to continue their job on former working hours basis
B
Carry on the action of cutting off the elder’s proportion of employment
C
Ask employees to work more hours in order to get extra pay
D
Re-hire old employees and kept the salary a bit lower
11. which of the followings is correct according to the research of Mr Quinn:
A
About 50% of all employees in America switched into ‘Bridge’ jobs.
B
Only the worst-paid continue to work.
C
More men than women fell into the category of ’bridge’ work.
D
Some old people keep working for their motives rather than an economic incentive.
12. Which of the followings is correct according to David Storey:
A
70% of business is successful if hire more older people.
B
The average success of the self-employed business is getting lower.
C
Self-employed elder people are more likely to survive.
D
Older people’s working hours are more flexible.
13. What is the main purpose of the author in writing this passage?
A
there must be a successful retiring program for the old
B
older people should be correctly valued in employment
C
old people should offer more helping young employees grow.
D
There are more jobs in the world that only employ older people

Choose the correct letter, A , B, C or D.$md$, NULL);

COMMIT;
