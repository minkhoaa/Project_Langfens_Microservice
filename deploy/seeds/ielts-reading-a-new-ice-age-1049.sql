BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-a-new-ice-age-1049'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-a-new-ice-age-1049';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-a-new-ice-age-1049';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-a-new-ice-age-1049';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('0cc8d373-3fc5-590a-8680-cfbdf9ca4763', 'ielts-reading-a-new-ice-age-1049', $t$A New Ice Age$t$, $md$## A New Ice Age

Nguồn:
- Test: https://mini-ielts.com/1049/reading/a-new-ice-age
- Solution: https://mini-ielts.com/1049/view-solution/reading/a-new-ice-age$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('694d9840-fa15-5d64-a082-5d2467155f16', '0cc8d373-3fc5-590a-8680-cfbdf9ca4763', 1, $t$Reading — A New Ice Age$t$, $md$Read the passage and answer questions **1–13**.

### Passage: A New Ice Age

William Curry is a serious, sober climate scientist, not an art critic. But he has spent a lot of time perusing Emanuel Gottlieb Leutze’s famous painting “George Washington Crossing the Delaware”, which depicts a boatload of colonial Ameri­can soldiers making their way to attack English and Hessian troops the day after Christmas in 1776. “Most people think these other guys in the boat are rowing, but they are actually pushing the ice away ,” says Curry, tapping his finger on a reproduction of the painting. Sure enough, the lead oarsman is bashing the frozen river with his boot. “I grew up in Philadelphia. The place in this painting is 30 min­utes away by car. I can tell you, this kind of thing just doesn’t happen anymore .”

But it may again soon. And ice-choked scenes, similar to those immortalised by the 16th-century Flemish painter Pieter Brueghel the Elder, may also return to Europe. His works, including the 1565 masterpiece “Hunters in the Snow”, make the now-temperate European landscapes look more like Lapland. Such frigid set­tings were commonplace during a period dating roughly from 1300 to 1850 be­cause much of North America and Europe was in the throes of a little ice age. And now there is mounting evidence that the chill could return. A growing number of scientists believe conditions are ripe for another prolonged cooldown, or small ice age. While no one is predicting a brutal ice sheet like the one that covered the Northern Hemisphere with glaciers about 12,000 years ago , the next cooling trend could drop average temperatures 5 degrees Fahrenheit over much of the United States and 10 degrees in the Northeast, northern Europe, and northern Asia.

“It could happen in 10 years,” says Terrence Joyce, who chairs the Woods Hole Physical Oceanography Department. “Once it does, it can take hundreds of years to reverse.” And he is alarmed that Americans have yet to take the threat seriously.

A drop of 5 to 10 degrees entails much more than simply bumping up the thermo­stat and carrying on. Both economically and ecologically, such quick, persistent chilling could have devastating consequences. A 2002 report titled “ Abrupt Climate Change: Inevitable Surprises”, produced by the National Academy of Science s, pegged the cost from agricultural losses alone at $100 billion to $250 billion while also predicting that damage to ecologies could be vast and incalculable. A grim sampler: disappearing forests, increased housing expenses, dwindling fresh water, lower crop yields, and accelerated species extinctions.

The reason for such huge effects is simple. A quick climate change wreaks far more disruption than a slow one. People, animals, plants, and the economies that depend on them are like rivers; says the report: "For example, high water in a river will pose few problems until the water runs over the bank, after which levees can be breached and massive flooding can occur. Many biological processes undergo shifts at particular thresholds of temperature and precipitation.”

Political changes since the last ice age could make survival far more difficult for the world's poor . During previous cooling periods, whole tribes simply picked up and moved south, but that option doesn't work in the modern, tense world of closed borders . "To the extent that abrupt climate change may cause rapid and ex­tensive changes of fortune for those who live off the land, the inability to migrate may remove one of the major safety nets for distressed people,” says the report.

But first things first. Isn't the earth actually warming? Indeed it is, says Joyce. ‘ In his cluttered office, full of soft light from the foggy Cape Cod morning, he explains how such warming could actually be the surprising culprit of the next mini-ice age . The paradox is a result of the appearance over the past 30 years in the North Atlantic of huge rivers of fresh water - the equivalent of a 10-foot-thick layer - mixed into the salty sea. No one is certain where the fresh torrents are coming from, but a prime suspect is melting Arctic ice, caused by a build-up of carbon dioxide in the atmosphere that traps solar energy.

The freshwater trend is major news in ocean-science circles. Bob Dickson, a Brit­ish oceanographer who sounded an alarm at a February conference in Honolulu, has termed the drop in salinity and temperature in the Labrador Sea - a body of water between northeastern Canada and Greenland that adjoins the Atlantic - "arguably the largest full-depth changes observed in the modern instrumental oceanographic record”.

The trend could cause a little ice age by subverting the northern penetration of Gulf Stream waters. Normally, the Gulf Stream, laden with heat soaked up in the tropics, meanders up the east coasts of the United States and Canada. As it flows northward, the stream surrenders heat to the air. Because the prevailing North Atlantic winds blow eastward, a lot of the heat wafts to Europe . That’s why many scientists believe winter temperatures on the Continent are as much as 36 de­grees Fahrenheit warmer than those in North America at the same latitude. Frigid Boston, for example, lies at almost precisely the same latitude as balmy Rome. And some scientists say the heat also warms Americans and Canadians. “It’s a real mistake to think of this solely as a European phenomenon," says Joyce.

Having given up its heat to the air, the now-cooler water becomes denser and sinks into the North Atlantic by a mile or more in a process oceanographers call thermohaline circulation. This massive column of cascading cold is the main engine powering a deep-water current called the Great Ocean Conveyor that snakes through all the world’s oceans. But as the North Atlantic fills with fresh water , it grows less dense, making the waters carried northward by the Gulf Stream less able to sink. The new mass of relatively fresh water sits on top of the ocean like a big thermal blanket, threatening the thermohaline circulation. That in turn could make the Gulf Stream slow or veer southward. At some point, the whole system could simply shut down, and do so quickly. “There is increasing evidence that we are getting closer to a transition point, from which we can jump to a new state.”$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('d63677f0-e11b-5212-9c4d-f3a6b9d6e0bd', '694d9840-fa15-5d64-a082-5d2467155f16', 1, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 1

Questions 1-4
Questions 1-4
Choose the correct letter
A, B, C
or
D
.
Write your answers in boxes
1-4
on your answer sheet.
1.
The writer uses paintings in the first paragraph to illustrate
A
possible future climate change.
B
climate change of the last two centuries.
C
the river doesn’t freeze in winter anymore.
D
how George Washington led his troops across the river.
Locate
2.
Which of the following do scientists believe to be possible?
A
The temperature may drop over much of the Northern Hemisphere.
B
It will be colder than 12,000 years ago.
C
The entire Northern Hemisphere will be covered in ice.
D
Europe will look more like Lapland.
Locate
3.
Why is it difficult for the poor to survive the next ice age?
A
People don’t live in tribes anymore.
B
Politics are changing too fast today.
C
Abrupt climate change causes people to live off their land.
D
Migration has become impossible because of closed borders.
Locate
4.
Why is continental Europe much warmer than North America in winter?
A
Wind blows most of the heat of tropical currents to Europe.
B
Europe and North America are at different latitudes.
C
The Gulf Stream has stopped yielding heat to the air.
D
The Gulf Stream moves north along the east coast of North America.
Locate

Choose the correct letter A, B, C or D .$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('40de2597-9069-5d04-8512-e8c7e9305c3b', '694d9840-fa15-5d64-a082-5d2467155f16', 2, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 2

Questions 1-4
Questions 1-4
Choose the correct letter
A, B, C
or
D
.
Write your answers in boxes
1-4
on your answer sheet.
1.
The writer uses paintings in the first paragraph to illustrate
A
possible future climate change.
B
climate change of the last two centuries.
C
the river doesn’t freeze in winter anymore.
D
how George Washington led his troops across the river.
Locate
2.
Which of the following do scientists believe to be possible?
A
The temperature may drop over much of the Northern Hemisphere.
B
It will be colder than 12,000 years ago.
C
The entire Northern Hemisphere will be covered in ice.
D
Europe will look more like Lapland.
Locate
3.
Why is it difficult for the poor to survive the next ice age?
A
People don’t live in tribes anymore.
B
Politics are changing too fast today.
C
Abrupt climate change causes people to live off their land.
D
Migration has become impossible because of closed borders.
Locate
4.
Why is continental Europe much warmer than North America in winter?
A
Wind blows most of the heat of tropical currents to Europe.
B
Europe and North America are at different latitudes.
C
The Gulf Stream has stopped yielding heat to the air.
D
The Gulf Stream moves north along the east coast of North America.
Locate

Choose the correct letter A, B, C or D .$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('382eaa75-3825-5745-b905-aff9e264efd0', '694d9840-fa15-5d64-a082-5d2467155f16', 3, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 3

Questions 1-4
Questions 1-4
Choose the correct letter
A, B, C
or
D
.
Write your answers in boxes
1-4
on your answer sheet.
1.
The writer uses paintings in the first paragraph to illustrate
A
possible future climate change.
B
climate change of the last two centuries.
C
the river doesn’t freeze in winter anymore.
D
how George Washington led his troops across the river.
Locate
2.
Which of the following do scientists believe to be possible?
A
The temperature may drop over much of the Northern Hemisphere.
B
It will be colder than 12,000 years ago.
C
The entire Northern Hemisphere will be covered in ice.
D
Europe will look more like Lapland.
Locate
3.
Why is it difficult for the poor to survive the next ice age?
A
People don’t live in tribes anymore.
B
Politics are changing too fast today.
C
Abrupt climate change causes people to live off their land.
D
Migration has become impossible because of closed borders.
Locate
4.
Why is continental Europe much warmer than North America in winter?
A
Wind blows most of the heat of tropical currents to Europe.
B
Europe and North America are at different latitudes.
C
The Gulf Stream has stopped yielding heat to the air.
D
The Gulf Stream moves north along the east coast of North America.
Locate

Choose the correct letter A, B, C or D .$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('f0ae7440-edfe-5191-a0d3-7324eb261cca', '694d9840-fa15-5d64-a082-5d2467155f16', 4, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 4

Questions 1-4
Questions 1-4
Choose the correct letter
A, B, C
or
D
.
Write your answers in boxes
1-4
on your answer sheet.
1.
The writer uses paintings in the first paragraph to illustrate
A
possible future climate change.
B
climate change of the last two centuries.
C
the river doesn’t freeze in winter anymore.
D
how George Washington led his troops across the river.
Locate
2.
Which of the following do scientists believe to be possible?
A
The temperature may drop over much of the Northern Hemisphere.
B
It will be colder than 12,000 years ago.
C
The entire Northern Hemisphere will be covered in ice.
D
Europe will look more like Lapland.
Locate
3.
Why is it difficult for the poor to survive the next ice age?
A
People don’t live in tribes anymore.
B
Politics are changing too fast today.
C
Abrupt climate change causes people to live off their land.
D
Migration has become impossible because of closed borders.
Locate
4.
Why is continental Europe much warmer than North America in winter?
A
Wind blows most of the heat of tropical currents to Europe.
B
Europe and North America are at different latitudes.
C
The Gulf Stream has stopped yielding heat to the air.
D
The Gulf Stream moves north along the east coast of North America.
Locate

Choose the correct letter A, B, C or D .$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('54c69333-58dc-507f-a778-be4a01a6076a', '694d9840-fa15-5d64-a082-5d2467155f16', 5, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 5

Questions 5-9
Questions 5-9
Look at the following statements (Questions
5-9)
and the list of people in the box below.
Match each statement with the correct person
A-D
.
Write the appropriate letter
A-D
in boxes
5-9
on your answer sheet.
NB You may use any letter
more than once
.
5
Most Americans are not prepared for the next ice age.
Locate
6
The result of abrupt climate change is catastrophic.
Locate
7
The world is not as cold as it used to be.
Locate
8
Global warming is closely connected to the ice age.
Locate
9
Alerted people to the change of ocean water in a conference
Locate
List of People
A
William Curry
B
Terrence Joyce
C
Bob Dickson
D
National Academy of Sciences

5 ____ Most Americans are not prepared for the next ice age. Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d6afd8ac-b06d-5021-9e82-2019b445c824', '54c69333-58dc-507f-a778-be4a01a6076a', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('376a1e39-ef24-5a60-bf92-5fd0793c3cb0', '54c69333-58dc-507f-a778-be4a01a6076a', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('db3a260d-db85-5d20-98ad-8a5625f0c124', '54c69333-58dc-507f-a778-be4a01a6076a', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('45c97046-887f-5e89-a4ad-049c46198d38', '54c69333-58dc-507f-a778-be4a01a6076a', 4, $md$D$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('af0be51d-7dc0-56ea-a56a-3073ea411f57', '694d9840-fa15-5d64-a082-5d2467155f16', 6, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 6

Questions 5-9
Questions 5-9
Look at the following statements (Questions
5-9)
and the list of people in the box below.
Match each statement with the correct person
A-D
.
Write the appropriate letter
A-D
in boxes
5-9
on your answer sheet.
NB You may use any letter
more than once
.
5
Most Americans are not prepared for the next ice age.
Locate
6
The result of abrupt climate change is catastrophic.
Locate
7
The world is not as cold as it used to be.
Locate
8
Global warming is closely connected to the ice age.
Locate
9
Alerted people to the change of ocean water in a conference
Locate
List of People
A
William Curry
B
Terrence Joyce
C
Bob Dickson
D
National Academy of Sciences

6 ____ The result of abrupt climate change is catastrophic. Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('49658552-b6e5-55e9-a9d0-e21794c8bf6b', 'af0be51d-7dc0-56ea-a56a-3073ea411f57', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f3223a3c-5ef9-555d-9b9f-0ab41dfd3761', 'af0be51d-7dc0-56ea-a56a-3073ea411f57', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4238810d-fbf8-59ed-8faf-f48e4b783b4e', 'af0be51d-7dc0-56ea-a56a-3073ea411f57', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9bf23101-80aa-524d-a2dd-619634cafc43', 'af0be51d-7dc0-56ea-a56a-3073ea411f57', 4, $md$D$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('7328d874-079d-5e07-8cd8-6c415a10870d', '694d9840-fa15-5d64-a082-5d2467155f16', 7, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 7

Questions 5-9
Questions 5-9
Look at the following statements (Questions
5-9)
and the list of people in the box below.
Match each statement with the correct person
A-D
.
Write the appropriate letter
A-D
in boxes
5-9
on your answer sheet.
NB You may use any letter
more than once
.
5
Most Americans are not prepared for the next ice age.
Locate
6
The result of abrupt climate change is catastrophic.
Locate
7
The world is not as cold as it used to be.
Locate
8
Global warming is closely connected to the ice age.
Locate
9
Alerted people to the change of ocean water in a conference
Locate
List of People
A
William Curry
B
Terrence Joyce
C
Bob Dickson
D
National Academy of Sciences

7 ____ The world is not as cold as it used to be. Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9212420f-5ee0-5a69-8f8e-9cc2af53d89e', '7328d874-079d-5e07-8cd8-6c415a10870d', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('175297aa-166c-571c-aa4c-8ec66fcb1bea', '7328d874-079d-5e07-8cd8-6c415a10870d', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8def77de-1bbb-5e4c-ada9-fab253c06f39', '7328d874-079d-5e07-8cd8-6c415a10870d', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8c8d0df4-0cbd-5a63-a3d1-4458fa4a0b27', '7328d874-079d-5e07-8cd8-6c415a10870d', 4, $md$D$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('45513cea-93e1-51a8-a4e2-810b8d0c7074', '694d9840-fa15-5d64-a082-5d2467155f16', 8, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 8

Questions 5-9
Questions 5-9
Look at the following statements (Questions
5-9)
and the list of people in the box below.
Match each statement with the correct person
A-D
.
Write the appropriate letter
A-D
in boxes
5-9
on your answer sheet.
NB You may use any letter
more than once
.
5
Most Americans are not prepared for the next ice age.
Locate
6
The result of abrupt climate change is catastrophic.
Locate
7
The world is not as cold as it used to be.
Locate
8
Global warming is closely connected to the ice age.
Locate
9
Alerted people to the change of ocean water in a conference
Locate
List of People
A
William Curry
B
Terrence Joyce
C
Bob Dickson
D
National Academy of Sciences

8 ____ Global warming is closely connected to the ice age. Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ee035351-64af-59d9-b31e-cb8b8acc8c8a', '45513cea-93e1-51a8-a4e2-810b8d0c7074', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a95419ff-5588-5910-aee7-7198eb0ee1c7', '45513cea-93e1-51a8-a4e2-810b8d0c7074', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9c70ee7a-0bee-5cbd-99c0-954d51e82580', '45513cea-93e1-51a8-a4e2-810b8d0c7074', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ea07f440-e86a-5746-ae5c-05b3ff42b13c', '45513cea-93e1-51a8-a4e2-810b8d0c7074', 4, $md$D$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('1316b625-bf31-5ac0-bc88-7fe1a6b3d3ab', '694d9840-fa15-5d64-a082-5d2467155f16', 9, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 9

Questions 5-9
Questions 5-9
Look at the following statements (Questions
5-9)
and the list of people in the box below.
Match each statement with the correct person
A-D
.
Write the appropriate letter
A-D
in boxes
5-9
on your answer sheet.
NB You may use any letter
more than once
.
5
Most Americans are not prepared for the next ice age.
Locate
6
The result of abrupt climate change is catastrophic.
Locate
7
The world is not as cold as it used to be.
Locate
8
Global warming is closely connected to the ice age.
Locate
9
Alerted people to the change of ocean water in a conference
Locate
List of People
A
William Curry
B
Terrence Joyce
C
Bob Dickson
D
National Academy of Sciences

9 ____ Alerted people to the change of ocean water in a conference Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d073bee6-6e42-5bcf-b33f-029472a2b5b4', '1316b625-bf31-5ac0-bc88-7fe1a6b3d3ab', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c4b3f71f-b295-5b83-baec-ac10fc5c9880', '1316b625-bf31-5ac0-bc88-7fe1a6b3d3ab', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3509768a-a493-5b8f-a53c-59ce017bd48c', '1316b625-bf31-5ac0-bc88-7fe1a6b3d3ab', 3, $md$C$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f6c3f427-2216-5fc4-91f6-4ed3f988f824', '1316b625-bf31-5ac0-bc88-7fe1a6b3d3ab', 4, $md$D$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('f16ba41e-2724-5b4a-a3e5-f3d68cd51686', '694d9840-fa15-5d64-a082-5d2467155f16', 10, 'SHORT_ANSWER', 'READING', 4, $md$### Question 10

Questions 10-13
Questions 10-13
Complete the flow chart below.
Choose
NO MORE THAN THREE WORDS
from the passage for each answer.
Write your answers in boxes
10-13
on your answer sheet.
10
Locate
11
Locate
12
Locate
13
Locate

10 ____ Locate$md$, NULL, ARRAY['.*heat.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('f1ba3df6-5cea-53b7-acc2-a47756cc4b7e', '694d9840-fa15-5d64-a082-5d2467155f16', 11, 'SHORT_ANSWER', 'READING', 4, $md$### Question 11

Questions 10-13
Questions 10-13
Complete the flow chart below.
Choose
NO MORE THAN THREE WORDS
from the passage for each answer.
Write your answers in boxes
10-13
on your answer sheet.
10
Locate
11
Locate
12
Locate
13
Locate

11 ____ Locate$md$, NULL, ARRAY['.*denser.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('f8700927-d9db-5db0-aa89-3ed1b0d30f34', '694d9840-fa15-5d64-a082-5d2467155f16', 12, 'SHORT_ANSWER', 'READING', 4, $md$### Question 12

Questions 10-13
Questions 10-13
Complete the flow chart below.
Choose
NO MORE THAN THREE WORDS
from the passage for each answer.
Write your answers in boxes
10-13
on your answer sheet.
10
Locate
11
Locate
12
Locate
13
Locate

12 ____ Locate$md$, NULL, ARRAY['.*great.*ocean.*conveyor.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('ed242585-700f-5b26-b177-e8f110c1b460', '694d9840-fa15-5d64-a082-5d2467155f16', 13, 'SHORT_ANSWER', 'READING', 4, $md$### Question 13

Questions 10-13
Questions 10-13
Complete the flow chart below.
Choose
NO MORE THAN THREE WORDS
from the passage for each answer.
Write your answers in boxes
10-13
on your answer sheet.
10
Locate
11
Locate
12
Locate
13
Locate

13 ____ Locate$md$, NULL, ARRAY['.*fresh.*water.*']);

COMMIT;
