BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-californias-age-of-megafires-1337'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-californias-age-of-megafires-1337';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-californias-age-of-megafires-1337';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-californias-age-of-megafires-1337';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('594250b1-4a57-5201-8051-40d5a7d595c0', 'ielts-reading-californias-age-of-megafires-1337', $t$California’s age of Megafires$t$, $md$## California’s age of Megafires

Nguồn:
- Test: https://mini-ielts.com/1337/reading/californias-age-of-megafires
- Solution: https://mini-ielts.com/1337/view-solution/reading/californias-age-of-megafires$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('83373a38-06bd-587d-ab66-9890f28d8898', '594250b1-4a57-5201-8051-40d5a7d595c0', 1, $t$Reading — California’s age of Megafires$t$, $md$Read the passage and answer questions **1–13**.

### Passage: California’s age of Megafires

A

B

The short-term explanation is that the region, which usually has dry summers, has had nine inches less rain than normal this year. Longer-term, climate change across the West is leading to hotter days on average and longer fire seasons. Experts say this is likely to yield more megafires like the conflagrations that this week forced evacuations of at least 300,000 resident in California’s southland and led President Bush to declare a disaster emergency in seven counties on Tuesday.

C

Megafires, also called “siege fires,” are the increasingly frequent blazes that burn 500,000 acres or more – 10 times the size of the average forest fire of 20 years ago. One of the current wildfires is the sixth biggest in California ever, in terms of acreage burned, according to state figures and news reports. The trend to more superhot fires, experts say, has been driven by a century-long policy of the US Forest Service to stop wildfires as quickly as possible. The unintentional consequence was to halt the natural eradication of underbrush, now the primary fuel for megafires. Three other factors contribute to the trend, they add. First is climate change marked by a 1-degree F. rise in average yearly temperature across the West. Second is a fire season that on average is 78 days longer than in the late 1980s. The third is the increased building of homes and other structures in wooded areas.

D

“We are increasingly building our homes … in fire-prone ecosystems,” says Dominik Kulakowski, adjunct professor of biology at Clark University Graduate School of Geography in Worcester, Mass. Doing that “in many of the forests of the Western US … is like building homes on the side of an active volcano.” In California, where population growth has averaged more than 600,000 a year for at least a decade, housing has pushed into such areas. “What once was open space is now residential homes providing fuel to make fires burn with greater intensity,” says Terry McHale of the California Department of Forestry firefighters union. “With so much dryness, so many communities to catch fire, so many fronts to fight, it becomes an almost incredible job.”

E

That said, many experts give California high marks for making progress on preparedness since 2003, when the largest fires in state history scorched 750,000 acres, burned 3,640 homes, and killed 22 people. Stung then by criticism of bungling that allowed fires to spread when they might have been contained, personnel are meeting the peculiar challenges of a neighborhood – and canyon-hopping fires better than in recent years, observers say.

F

State promises to provide newer engines, planes, and helicopters have been fulfilled. Firefighters unions that then complained of dilapidated equipment, old fire engines and insufficient blueprints for fire safety are now praising the state’s commitment, noting that funding for firefighting has increased despite huge cuts in many other programs. “We are pleased that the Schwarzenegger administration has been very proactive in its support of us and come through with budgetary support of the infrastructure needs we have long sought,” says Mr McHale with the firefighters union.

G

Besides providing money to upgrade the fire engines that must traverse the mammoth state and wind along serpentine canyon roads, the state has invested in better command-and-control facilities as well as the strategies to run them. “In the fire sieges of earlier years, we found out that we had the willingness of mutual-aid help from other jurisdictions and states, but we were not able to communicate adequately with them,” says Kim Zagaris, chief of the state’s Office of Emergency Services, fire and rescue branch. After a 2004 blue-ribbon commission examined and revamped those procedures, the statewide response “has become far more professional and responsive,” he says.

H

Besides ordering the California National Guard on Monday to make 1,500 guardsmen available for firefighting efforts, Gov. Arnold Schwarzenegger asked the Pentagon to send all available Modular Airborne Fighting Systems to the area. The military Lockheed C-130 cargo/utility aircraft carry a pressurized 3,000-gallon tank that can eject fire retardant or water in fewer than five seconds through two tubes at the rear of the plane. This load can cover an area 1/4-mile long and 60 feet wide to create a fire barrier. Governor Schwarzenegger also directed 2,300 inmate firefighters and 170 custody staff from the California Department of Corrections and Rehabilitation to work for hand in hand with state and local firefighters.

I

Residents and government officials alike are noting the improvements with gratitude, even amid the loss of homes, churches, businesses, and farms. By Tuesday morning, the fires had burned 1,200 homes and businesses and set 245,957 acres – 384 square miles – ablaze. Despite such losses, there is a sense that the speed, dedication, and coordination of firefighters from several states and jurisdictions are resulting in greater efficiency than in past “siege fire” situations.

J

“I am extraordinarily impressed by the improvements we have witnessed between the last big fire and this,” says Ross Simmons, a San Diego-based lawyer who had to evacuate both his home and business on Monday, taking up residence at a Hampton Inn 30 miles south of his home in Rancho Bernardo. After fires consumed 172,000 acres there in 2003, the San Diego region turned communitywide soul-searching into improved building codes, evacuation procedures, and procurement of new technology. Mr Simmons and neighbors began receiving automated phone calls at 3:30 a.m. Monday morning telling them to evacuate. “Notwithstanding all the damage that will be caused by this, we will not come close to the loss of life because of what we have … put in place since then,” he says.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('0d9ebd09-dcaa-5bd0-a8cc-432c3a47e644', '83373a38-06bd-587d-ab66-9890f28d8898', 1, 'SUMMARY_COMPLETION', 'READING', 2, $md$### Question 1

Questions 1-6
Questions 1-6
Complete the following summary of the paragraphs of Reading Passage
Using
NO MORE THAN TWO WORDS
from the Reading Passage for each answer.
Write your answers in boxes
1-6
on your answer sheet.
Experts point out that blazes in California are having more heat, faster speed and they
1
more unpredictably compared with former ones. One explanation is that California’s summer is dry,
2
is below the average point. Another long term explanation is that hotter and longer potential days occur due to
3
. Nowadays, Megafires burn
4
the size of forest area caused by an ordinary fire of 20 years ago. The serious trend is mainly caused by well-grown underbrush, which provides
5
for the siege fires. Other contributors are climate change and extended
6
.

Experts point out that blazes in California are having more heat, faster speed and they 1 ____ more unpredictably compared with former ones. One explanation is that California’s summer is dry, 2 ____ is below the average point. Another long term explanation is that hotter and longer potential days occur due to 3 ____ . Nowadays, Megafires burn 4 ____ the size of forest area caused by an ordinary fire of 20 years ago. The serious trend is mainly caused by well-grown underbrush, which provides 5 ____ for the siege fires. Other contributors are climate change and extended 6 ____ .$md$, NULL, ARRAY['.*spread.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('72310461-01f8-5b1c-a0c4-00a5e3f1be1c', '83373a38-06bd-587d-ab66-9890f28d8898', 2, 'SUMMARY_COMPLETION', 'READING', 2, $md$### Question 2

Questions 1-6
Questions 1-6
Complete the following summary of the paragraphs of Reading Passage
Using
NO MORE THAN TWO WORDS
from the Reading Passage for each answer.
Write your answers in boxes
1-6
on your answer sheet.
Experts point out that blazes in California are having more heat, faster speed and they
1
more unpredictably compared with former ones. One explanation is that California’s summer is dry,
2
is below the average point. Another long term explanation is that hotter and longer potential days occur due to
3
. Nowadays, Megafires burn
4
the size of forest area caused by an ordinary fire of 20 years ago. The serious trend is mainly caused by well-grown underbrush, which provides
5
for the siege fires. Other contributors are climate change and extended
6
.

Experts point out that blazes in California are having more heat, faster speed and they 1 ____ more unpredictably compared with former ones. One explanation is that California’s summer is dry, 2 ____ is below the average point. Another long term explanation is that hotter and longer potential days occur due to 3 ____ . Nowadays, Megafires burn 4 ____ the size of forest area caused by an ordinary fire of 20 years ago. The serious trend is mainly caused by well-grown underbrush, which provides 5 ____ for the siege fires. Other contributors are climate change and extended 6 ____ .$md$, NULL, ARRAY['.*spread.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('1583e80c-0af2-58d1-98fc-16aca5d274e9', '83373a38-06bd-587d-ab66-9890f28d8898', 3, 'SUMMARY_COMPLETION', 'READING', 2, $md$### Question 3

Questions 1-6
Questions 1-6
Complete the following summary of the paragraphs of Reading Passage
Using
NO MORE THAN TWO WORDS
from the Reading Passage for each answer.
Write your answers in boxes
1-6
on your answer sheet.
Experts point out that blazes in California are having more heat, faster speed and they
1
more unpredictably compared with former ones. One explanation is that California’s summer is dry,
2
is below the average point. Another long term explanation is that hotter and longer potential days occur due to
3
. Nowadays, Megafires burn
4
the size of forest area caused by an ordinary fire of 20 years ago. The serious trend is mainly caused by well-grown underbrush, which provides
5
for the siege fires. Other contributors are climate change and extended
6
.

Experts point out that blazes in California are having more heat, faster speed and they 1 ____ more unpredictably compared with former ones. One explanation is that California’s summer is dry, 2 ____ is below the average point. Another long term explanation is that hotter and longer potential days occur due to 3 ____ . Nowadays, Megafires burn 4 ____ the size of forest area caused by an ordinary fire of 20 years ago. The serious trend is mainly caused by well-grown underbrush, which provides 5 ____ for the siege fires. Other contributors are climate change and extended 6 ____ .$md$, NULL, ARRAY['.*spread.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('4b3bc9fb-fde8-5c98-a23b-1fbb4f67ef9d', '83373a38-06bd-587d-ab66-9890f28d8898', 4, 'SUMMARY_COMPLETION', 'READING', 2, $md$### Question 4

Questions 1-6
Questions 1-6
Complete the following summary of the paragraphs of Reading Passage
Using
NO MORE THAN TWO WORDS
from the Reading Passage for each answer.
Write your answers in boxes
1-6
on your answer sheet.
Experts point out that blazes in California are having more heat, faster speed and they
1
more unpredictably compared with former ones. One explanation is that California’s summer is dry,
2
is below the average point. Another long term explanation is that hotter and longer potential days occur due to
3
. Nowadays, Megafires burn
4
the size of forest area caused by an ordinary fire of 20 years ago. The serious trend is mainly caused by well-grown underbrush, which provides
5
for the siege fires. Other contributors are climate change and extended
6
.

Experts point out that blazes in California are having more heat, faster speed and they 1 ____ more unpredictably compared with former ones. One explanation is that California’s summer is dry, 2 ____ is below the average point. Another long term explanation is that hotter and longer potential days occur due to 3 ____ . Nowadays, Megafires burn 4 ____ the size of forest area caused by an ordinary fire of 20 years ago. The serious trend is mainly caused by well-grown underbrush, which provides 5 ____ for the siege fires. Other contributors are climate change and extended 6 ____ .$md$, NULL, ARRAY['.*spread.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('09fb5357-537a-5645-9c1f-8bddc3f51a96', '83373a38-06bd-587d-ab66-9890f28d8898', 5, 'SUMMARY_COMPLETION', 'READING', 3, $md$### Question 5

Questions 1-6
Questions 1-6
Complete the following summary of the paragraphs of Reading Passage
Using
NO MORE THAN TWO WORDS
from the Reading Passage for each answer.
Write your answers in boxes
1-6
on your answer sheet.
Experts point out that blazes in California are having more heat, faster speed and they
1
more unpredictably compared with former ones. One explanation is that California’s summer is dry,
2
is below the average point. Another long term explanation is that hotter and longer potential days occur due to
3
. Nowadays, Megafires burn
4
the size of forest area caused by an ordinary fire of 20 years ago. The serious trend is mainly caused by well-grown underbrush, which provides
5
for the siege fires. Other contributors are climate change and extended
6
.

Experts point out that blazes in California are having more heat, faster speed and they 1 ____ more unpredictably compared with former ones. One explanation is that California’s summer is dry, 2 ____ is below the average point. Another long term explanation is that hotter and longer potential days occur due to 3 ____ . Nowadays, Megafires burn 4 ____ the size of forest area caused by an ordinary fire of 20 years ago. The serious trend is mainly caused by well-grown underbrush, which provides 5 ____ for the siege fires. Other contributors are climate change and extended 6 ____ .$md$, NULL, ARRAY['.*spread.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('a711fe9a-a276-5b4b-be0d-47755119e58f', '83373a38-06bd-587d-ab66-9890f28d8898', 6, 'SUMMARY_COMPLETION', 'READING', 3, $md$### Question 6

Questions 1-6
Questions 1-6
Complete the following summary of the paragraphs of Reading Passage
Using
NO MORE THAN TWO WORDS
from the Reading Passage for each answer.
Write your answers in boxes
1-6
on your answer sheet.
Experts point out that blazes in California are having more heat, faster speed and they
1
more unpredictably compared with former ones. One explanation is that California’s summer is dry,
2
is below the average point. Another long term explanation is that hotter and longer potential days occur due to
3
. Nowadays, Megafires burn
4
the size of forest area caused by an ordinary fire of 20 years ago. The serious trend is mainly caused by well-grown underbrush, which provides
5
for the siege fires. Other contributors are climate change and extended
6
.

Experts point out that blazes in California are having more heat, faster speed and they 1 ____ more unpredictably compared with former ones. One explanation is that California’s summer is dry, 2 ____ is below the average point. Another long term explanation is that hotter and longer potential days occur due to 3 ____ . Nowadays, Megafires burn 4 ____ the size of forest area caused by an ordinary fire of 20 years ago. The serious trend is mainly caused by well-grown underbrush, which provides 5 ____ for the siege fires. Other contributors are climate change and extended 6 ____ .$md$, NULL, ARRAY['.*spread.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('c9b5a6a9-b46a-5fe8-8670-3ff19554ed7a', '83373a38-06bd-587d-ab66-9890f28d8898', 7, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 7

Questions 7-9
Questions 7-9
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
7-9
on your answer sheet.
7
What is the expert’s attitude towards California’s performance after 2003 megafire?
A
They could have done better
B
Blamed them on casualties
C
Improvement made on preparation
D
Serious criticism
8
According to Governor Schwarzenegger, which one is
CORRECT
about his effort for firefighting?
A
Schwarzenegger requested successfully for military weapons
B
Schwarzenegger led many prison management staff to work together with local firefighters
C
Schwarzenegger acted negatively in recent megafire in California
D
Schwarzenegger ordered 1,500 office clerk to join firefighting scene.
9
What happened to Ross Simmon on the day of megafire breakout?
A
He was sleeping till morning
B
He was doing business at Hampton Inn
C
He suffered employee death on that morning
D
He was alarmed by machine calls

Choose the correct letter, A , B , C or D .$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('a08278b3-ec12-5a0f-9b22-e0115f7a1038', '83373a38-06bd-587d-ab66-9890f28d8898', 8, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 8

Questions 7-9
Questions 7-9
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
7-9
on your answer sheet.
7
What is the expert’s attitude towards California’s performance after 2003 megafire?
A
They could have done better
B
Blamed them on casualties
C
Improvement made on preparation
D
Serious criticism
8
According to Governor Schwarzenegger, which one is
CORRECT
about his effort for firefighting?
A
Schwarzenegger requested successfully for military weapons
B
Schwarzenegger led many prison management staff to work together with local firefighters
C
Schwarzenegger acted negatively in recent megafire in California
D
Schwarzenegger ordered 1,500 office clerk to join firefighting scene.
9
What happened to Ross Simmon on the day of megafire breakout?
A
He was sleeping till morning
B
He was doing business at Hampton Inn
C
He suffered employee death on that morning
D
He was alarmed by machine calls

Choose the correct letter, A , B , C or D .$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('aa31bb7c-bafb-5ed4-bd01-ba22c9f78d8c', '83373a38-06bd-587d-ab66-9890f28d8898', 9, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 9

Questions 7-9
Questions 7-9
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
7-9
on your answer sheet.
7
What is the expert’s attitude towards California’s performance after 2003 megafire?
A
They could have done better
B
Blamed them on casualties
C
Improvement made on preparation
D
Serious criticism
8
According to Governor Schwarzenegger, which one is
CORRECT
about his effort for firefighting?
A
Schwarzenegger requested successfully for military weapons
B
Schwarzenegger led many prison management staff to work together with local firefighters
C
Schwarzenegger acted negatively in recent megafire in California
D
Schwarzenegger ordered 1,500 office clerk to join firefighting scene.
9
What happened to Ross Simmon on the day of megafire breakout?
A
He was sleeping till morning
B
He was doing business at Hampton Inn
C
He suffered employee death on that morning
D
He was alarmed by machine calls

Choose the correct letter, A , B , C or D .$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('9d4cafe7-ad97-55df-9cd2-5cd7f377ec50', '83373a38-06bd-587d-ab66-9890f28d8898', 10, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 10

Questions 10-13
Questions 10-13
Do the following statements agree with the information given in Reading Passage 1?
In boxes
10-13
on your answer sheet, write
TRUE
if the statement is true
FALSE
if the statement is false
NOT GIVEN
if the information is not given in the passage
10
The area of open space in California has declined during the past decade.
11
Fire squad wants to recruit more firefighters this year.
12
Firefighters union declared that firefighters have had the more improved and supportive facility by the local government.
13
Before the year of 2004, well coordination and communication between California and other states already existed in fire siege.

10 ____ The area of open space in California has declined during the past decade.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3ca01957-a853-5376-a668-28edd939c84c', '9d4cafe7-ad97-55df-9cd2-5cd7f377ec50', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0999ca02-f7a4-56e0-897d-014e8fae6e8c', '9d4cafe7-ad97-55df-9cd2-5cd7f377ec50', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ef2d21da-84eb-5a32-8a11-917b2cc605ff', '9d4cafe7-ad97-55df-9cd2-5cd7f377ec50', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('8f491ad3-2b28-511f-8145-78d3a2eefc89', '83373a38-06bd-587d-ab66-9890f28d8898', 11, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 11

Questions 10-13
Questions 10-13
Do the following statements agree with the information given in Reading Passage 1?
In boxes
10-13
on your answer sheet, write
TRUE
if the statement is true
FALSE
if the statement is false
NOT GIVEN
if the information is not given in the passage
10
The area of open space in California has declined during the past decade.
11
Fire squad wants to recruit more firefighters this year.
12
Firefighters union declared that firefighters have had the more improved and supportive facility by the local government.
13
Before the year of 2004, well coordination and communication between California and other states already existed in fire siege.

11 ____ Fire squad wants to recruit more firefighters this year.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ad9df179-01e8-5c3e-8667-6bbcf2db806f', '8f491ad3-2b28-511f-8145-78d3a2eefc89', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('09feab54-2aaa-5946-8a93-34193b0dccb6', '8f491ad3-2b28-511f-8145-78d3a2eefc89', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a9bdc405-10e0-54e7-b62f-62d5068377c0', '8f491ad3-2b28-511f-8145-78d3a2eefc89', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('01abfc44-de92-546f-acbc-e031252a1999', '83373a38-06bd-587d-ab66-9890f28d8898', 12, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 12

Questions 10-13
Questions 10-13
Do the following statements agree with the information given in Reading Passage 1?
In boxes
10-13
on your answer sheet, write
TRUE
if the statement is true
FALSE
if the statement is false
NOT GIVEN
if the information is not given in the passage
10
The area of open space in California has declined during the past decade.
11
Fire squad wants to recruit more firefighters this year.
12
Firefighters union declared that firefighters have had the more improved and supportive facility by the local government.
13
Before the year of 2004, well coordination and communication between California and other states already existed in fire siege.

12 ____ Firefighters union declared that firefighters have had the more improved and supportive facility by the local government.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9c2faff7-5986-5b45-a2f0-ec97e5b141be', '01abfc44-de92-546f-acbc-e031252a1999', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4dc3ba9d-b7c9-5121-bff8-ceb9d269690d', '01abfc44-de92-546f-acbc-e031252a1999', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e8cdbe42-4576-546c-be2b-8df3259b7ea5', '01abfc44-de92-546f-acbc-e031252a1999', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('c8479739-c70b-5b13-b0e3-08a8f8cab281', '83373a38-06bd-587d-ab66-9890f28d8898', 13, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 13

Questions 10-13
Questions 10-13
Do the following statements agree with the information given in Reading Passage 1?
In boxes
10-13
on your answer sheet, write
TRUE
if the statement is true
FALSE
if the statement is false
NOT GIVEN
if the information is not given in the passage
10
The area of open space in California has declined during the past decade.
11
Fire squad wants to recruit more firefighters this year.
12
Firefighters union declared that firefighters have had the more improved and supportive facility by the local government.
13
Before the year of 2004, well coordination and communication between California and other states already existed in fire siege.

13 ____ Before the year of 2004, well coordination and communication between California and other states already existed in fire siege.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fddad4c8-62f4-5b93-b55f-457326c1e089', 'c8479739-c70b-5b13-b0e3-08a8f8cab281', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('20b152f6-926a-5ca0-b6fa-ec08f7e3dc66', 'c8479739-c70b-5b13-b0e3-08a8f8cab281', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('eebed2d4-3817-57a9-b5db-2cb561969da2', 'c8479739-c70b-5b13-b0e3-08a8f8cab281', 3, $md$NOT GIVEN$md$, false);

COMMIT;
