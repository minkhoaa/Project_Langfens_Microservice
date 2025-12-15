BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-development-of-public-management-theory-1356'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-development-of-public-management-theory-1356';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-development-of-public-management-theory-1356';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-development-of-public-management-theory-1356';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('1d48843d-0f72-554a-8841-51493f969511', 'ielts-reading-development-of-public-management-theory-1356', $t$Development of Public management theory$t$, $md$## Development of Public management theory

Nguồn:
- Test: https://mini-ielts.com/1356/reading/development-of-public-management-theory
- Solution: https://mini-ielts.com/1356/view-solution/reading/development-of-public-management-theory$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('fb25f73c-0c19-5a9b-ad75-a4b2d17b73fd', '1d48843d-0f72-554a-8841-51493f969511', 1, $t$Reading — Development of Public management theory$t$, $md$Read the passage and answer questions **1–5**.

### Passage: Development of Public management theory

{A} Several theories bridged the gap between strictly private and public sector management. One good example is Max Weber exploring sociologist, who explored the ideal bureaucracy in The Protestant ethic and the Spirit of Capitalism. Bureaucratic Theory was developed by a German. Sociologist and political economist Max Weber (1864-1920). According to him, bureaucracy is the most efficient form of organization. The organization has a well-defined line of authority. It has clear rules and regulations which are strictly followed. according to Max Weber, there are three types of power in an organization: 1. Traditional Power, 2. Charismatic power, and 3. Bureaucratic Power or Legal Power.

{B} Weber admired Bureaucracy for its trustworthiness. The Bureaucracy was constituted by a group of professional, ethical public officials. These servants dedicate themselves to the public in return for the security of job tenure among the many advantages of public employment. There is a high degree of division of Labour and specialization as well as a defined Hierarchy of authority. There are well-defined rules and regulations that follow the principle of Rationality, Objectively, and Consistency. These rules cover all the duties and rights of the employees. These rules must be strictly followed. Impersonal relations among the member of the organization. Interpersonal relations are based on positions and not on personalities

{C} Bureaucracy organization is a very rigid type of organization. Too much emphasis on rules and regulations which are rigid and inflexible. It does not give importance to human relations. No importance is also given to informal groups which nowadays play an important role in all business organizations. Yet, too much importance is given to the technical qualifications of the employees for promotion and transfers. The dedication and commitment of the employee are not considered. It is suitable for government organizations. It is also suitable for organizations where change is very slow. There will be unnecessary delays in decision-making due to formalities and rules. It is appropriate for static organizations. There is difficulty in coordination and communication.

{D} Herbal Simon, Chester Barnard, and Charles Lindblom are among the first of those recognized as early American public administrators. These men ushered in an era during which the field gained recognition as independent and unique, despite its multidisciplinary nature. Simon contributed theoretical separation to discern management, decisions based on values. since one cannot make completely responsible decisions with public resources based solely on personal values, one must attempt to upon objectively determined facts. Simon developed other relevant theories as well. Similar to Lindblom’s subsequently discussed critique of comprehensive rationality, Simon also taught that a strictly economic man, one who maximizes returns or values by making decisions based upon complete information in unlimited time, is unrealistic. Instead, most public administrators use a sufficient amount of information to make a satisfactory decision: they” satisfice.”

{E} In decision-making, Simon believed that agents face uncertainty about the future and costs in acquiring information in the present. These factors limit the extent to which agents can make a fully rational decision, thus they possess only” bounded rationality” and must make deci9sion by “Satisficing,” or choosing that which might not be optional but which will make them happy enough. ” Rational behavior, in economics, means that individuals maximize their utility function. Under the constraints they face (e.g. their budget constraint, limited choices,…..) in pursuit of their self-interest.

{F} Chester Barnard was also one of the watershed scholars. Barnard published “The Economy of Incentives”(1938), in an attempt to explain individual participation in an organization. Barnard explained organizations as systems of exchange. Low-level employees must have more incentive to remain with the organization for which they exchange their labor and loyalty. The organization (and higher-level employees) must derive sufficient benefit from its employees to keep them, The net pull of the organization is determined by material rewards, environmental conditions, and other intangibles like recognition. He gives great importance to persuasion much more than to economic incentives. He described four general and four specific incentives including Money and other material inducements; Personal non-material opportunities for distinction; DESIREABLE PHYSICal conditions of work; Ideal benefactions, such as pride of workmanship, etc.

{G} Humanists embrace a dynamic concept of employee and management techniques. This requires a theoretical shift away from the idea that an employee is a cog in the industrial machine. Rather, employees are unique individuals with goals, needs desires, etc.

{H} The humanist era ushered in other possible interpretations of such topics as power and management. One of the most significant was Douglas McGregor’s “Theory X and TheoryY. ” McGregor’s work provided a basis for a management framework, a structure upon whose rungs the classic and new-age management might be hung. first, commonly held by early management theorists, Theory X begins with the assumption that humans possess an inherent aversion to work. Employees must therefore be coerced and controlled if management expects to see results. Further, lazy humans prefer direction bordering micromanagement whenever possible.

{I} Theory Y is much more compatible with the humanist tradition. This begins with the assumption that work is as natural for humans as rest or play. Further, employees will direct and control themselves as they complete objectives. Humans learn naturally and seek responsibility. Consequently, managers need only to steer employees in a cooperative manner toward goals that serve the organization. There is room for many to create and share power.

{J} The Z- Organization can be thought of as a complimentary third element to McGregor’s dichotomy. Z- organizations are Japanese organizations that are a Japanese organizational model. Similar to Theory Y management, Z organizations place a large degree of responsibility upon the employees. Further, relatively low-level employees are entrusted with the freedom to be creative, ” wander around the organization” and become truly unique, company-specific employees. However, employees achieve only after “agreeing on a central set of objectives and ways of doing business” In Z Organizations, decision-making is democratic and participatory. Despite the many ADVANTAGES OF THIS ORGANIZATIONAL MODEL, THERE ARE SEVERAL DRAW-BACKS. THESE INCLUDE THE DEPREDATION OF A LARGE PROFESSIONAL DIstance-de personalization is impossible in Z-organizations. Since, in reality, there is a high percentage of workers who would like to work for the financial return than the job objectives. A high level of self-discipline is also necessary.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('828f024a-4075-551c-bcbd-79b56abd4c76', 'fb25f73c-0c19-5a9b-ad75-a4b2d17b73fd', 9, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 9

QUESTIONS 9-13
QUESTIONS 9-13
Use the information in the passage to match the people (listed
A-E
) with opinions or deeds below. Write the appropriate letters A-E in boxes 9-13 on your answer sheet
NB
Some people may match more than one ideas
A.
Mark Weber
B.
McGregor
C.
Herbert Simon
D.
Chester Barnard
E.
Charles Lindblom
9
Employees like to follow professional, ethical public officials to secure a job
10
Highly effective can be achieved only after agreeing on a core of objectives and method of doing things
11
Managers need to take the employees‘ emotional feeling, besides the material rewards, into incentives system.
12
Individuals can maximize their self-interest when all the budget and choices are utilized well
13
The assumption that humans possess a natural dislike to work who ought to be forced and controlled

9 ____ Employees like to follow professional, ethical public officials to secure a job$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3284907a-49cf-5939-b05a-3c55a7fb4b46', '828f024a-4075-551c-bcbd-79b56abd4c76', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('67c27770-8270-5bf6-9df1-c3a1b7a94c75', '828f024a-4075-551c-bcbd-79b56abd4c76', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d392287f-c192-58f8-a36b-2a24d8fdbbac', '828f024a-4075-551c-bcbd-79b56abd4c76', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d8043e38-469b-5366-90d8-c9fd2c7c3b71', '828f024a-4075-551c-bcbd-79b56abd4c76', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('542ca82f-6b3f-510d-be1b-19753f4e66dc', '828f024a-4075-551c-bcbd-79b56abd4c76', 5, $md$E$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('4e932b1a-f8fd-5519-868a-33bba1c893a4', 'fb25f73c-0c19-5a9b-ad75-a4b2d17b73fd', 10, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 10

QUESTIONS 9-13
QUESTIONS 9-13
Use the information in the passage to match the people (listed
A-E
) with opinions or deeds below. Write the appropriate letters A-E in boxes 9-13 on your answer sheet
NB
Some people may match more than one ideas
A.
Mark Weber
B.
McGregor
C.
Herbert Simon
D.
Chester Barnard
E.
Charles Lindblom
9
Employees like to follow professional, ethical public officials to secure a job
10
Highly effective can be achieved only after agreeing on a core of objectives and method of doing things
11
Managers need to take the employees‘ emotional feeling, besides the material rewards, into incentives system.
12
Individuals can maximize their self-interest when all the budget and choices are utilized well
13
The assumption that humans possess a natural dislike to work who ought to be forced and controlled

10 ____ Highly effective can be achieved only after agreeing on a core of objectives and method of doing things$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3d5d3318-cf89-59dc-b497-9f351fc02025', '4e932b1a-f8fd-5519-868a-33bba1c893a4', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('243e026a-9a57-597b-b5c3-551072a35db5', '4e932b1a-f8fd-5519-868a-33bba1c893a4', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e7ff0966-d052-5507-9872-06c4b34110e9', '4e932b1a-f8fd-5519-868a-33bba1c893a4', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9eee0881-369d-59d4-acff-66c3c5bca230', '4e932b1a-f8fd-5519-868a-33bba1c893a4', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ac43b5e1-c330-5e17-97d6-cd84521ef4ad', '4e932b1a-f8fd-5519-868a-33bba1c893a4', 5, $md$E$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('6ded978a-0db9-5520-af6c-80be58c4662c', 'fb25f73c-0c19-5a9b-ad75-a4b2d17b73fd', 11, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 11

QUESTIONS 9-13
QUESTIONS 9-13
Use the information in the passage to match the people (listed
A-E
) with opinions or deeds below. Write the appropriate letters A-E in boxes 9-13 on your answer sheet
NB
Some people may match more than one ideas
A.
Mark Weber
B.
McGregor
C.
Herbert Simon
D.
Chester Barnard
E.
Charles Lindblom
9
Employees like to follow professional, ethical public officials to secure a job
10
Highly effective can be achieved only after agreeing on a core of objectives and method of doing things
11
Managers need to take the employees‘ emotional feeling, besides the material rewards, into incentives system.
12
Individuals can maximize their self-interest when all the budget and choices are utilized well
13
The assumption that humans possess a natural dislike to work who ought to be forced and controlled

11 ____ Managers need to take the employees‘ emotional feeling, besides the material rewards, into incentives system.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4682b628-df3f-506e-a501-8813b1c69c02', '6ded978a-0db9-5520-af6c-80be58c4662c', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('75fc031f-f4d8-5922-adf4-3e3473c40588', '6ded978a-0db9-5520-af6c-80be58c4662c', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('11f9c6ad-2fdd-54d3-8663-440d0f51a5b3', '6ded978a-0db9-5520-af6c-80be58c4662c', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('98aa00a4-3874-5cf8-9c5a-04c1dff31875', '6ded978a-0db9-5520-af6c-80be58c4662c', 4, $md$D$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b0874846-2e89-5cf7-91c5-753661f50c4f', '6ded978a-0db9-5520-af6c-80be58c4662c', 5, $md$E$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('feb45472-aebe-5723-9024-aeb85a899222', 'fb25f73c-0c19-5a9b-ad75-a4b2d17b73fd', 12, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 12

QUESTIONS 9-13
QUESTIONS 9-13
Use the information in the passage to match the people (listed
A-E
) with opinions or deeds below. Write the appropriate letters A-E in boxes 9-13 on your answer sheet
NB
Some people may match more than one ideas
A.
Mark Weber
B.
McGregor
C.
Herbert Simon
D.
Chester Barnard
E.
Charles Lindblom
9
Employees like to follow professional, ethical public officials to secure a job
10
Highly effective can be achieved only after agreeing on a core of objectives and method of doing things
11
Managers need to take the employees‘ emotional feeling, besides the material rewards, into incentives system.
12
Individuals can maximize their self-interest when all the budget and choices are utilized well
13
The assumption that humans possess a natural dislike to work who ought to be forced and controlled

12 ____ Individuals can maximize their self-interest when all the budget and choices are utilized well$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3736694d-8f00-5cc3-9bdc-5724683c89d0', 'feb45472-aebe-5723-9024-aeb85a899222', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('75de1d6f-2251-5365-98a7-58446c728850', 'feb45472-aebe-5723-9024-aeb85a899222', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8764cde8-3724-5e9c-a7d2-61ab3a00b38d', 'feb45472-aebe-5723-9024-aeb85a899222', 3, $md$C$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e5081795-d8aa-57f7-956f-87cdfaa1e253', 'feb45472-aebe-5723-9024-aeb85a899222', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('73ea4fd0-487b-51ce-8edf-48eae708ef19', 'feb45472-aebe-5723-9024-aeb85a899222', 5, $md$E$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('1804a49a-76bd-56ca-b389-1cfefc3db78a', 'fb25f73c-0c19-5a9b-ad75-a4b2d17b73fd', 13, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 13

QUESTIONS 9-13
QUESTIONS 9-13
Use the information in the passage to match the people (listed
A-E
) with opinions or deeds below. Write the appropriate letters A-E in boxes 9-13 on your answer sheet
NB
Some people may match more than one ideas
A.
Mark Weber
B.
McGregor
C.
Herbert Simon
D.
Chester Barnard
E.
Charles Lindblom
9
Employees like to follow professional, ethical public officials to secure a job
10
Highly effective can be achieved only after agreeing on a core of objectives and method of doing things
11
Managers need to take the employees‘ emotional feeling, besides the material rewards, into incentives system.
12
Individuals can maximize their self-interest when all the budget and choices are utilized well
13
The assumption that humans possess a natural dislike to work who ought to be forced and controlled

13 ____ The assumption that humans possess a natural dislike to work who ought to be forced and controlled$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6606095c-1a52-55a9-bd1e-0bffd0f44429', '1804a49a-76bd-56ca-b389-1cfefc3db78a', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1db1f0cf-d9c5-53c3-be0b-1fde459fe7e8', '1804a49a-76bd-56ca-b389-1cfefc3db78a', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2692bdb2-4a1a-5282-90e1-6f762ada25fa', '1804a49a-76bd-56ca-b389-1cfefc3db78a', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5ed89df0-81bc-5099-8df6-5e3c027ff03a', '1804a49a-76bd-56ca-b389-1cfefc3db78a', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d33ae248-2b5c-5d24-9c0b-1bafc747a8b7', '1804a49a-76bd-56ca-b389-1cfefc3db78a', 5, $md$E$md$, false);

COMMIT;
