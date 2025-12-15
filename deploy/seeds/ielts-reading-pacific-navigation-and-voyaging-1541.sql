BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-pacific-navigation-and-voyaging-1541'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-pacific-navigation-and-voyaging-1541';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-pacific-navigation-and-voyaging-1541';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-pacific-navigation-and-voyaging-1541';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('58172659-0659-5203-83e0-1006abfdbe08', 'ielts-reading-pacific-navigation-and-voyaging-1541', $t$Pacific navigation and voyaging$t$, $md$## Pacific navigation and voyaging

Nguồn:
- Test: https://mini-ielts.com/1541/reading/pacific-navigation-and-voyaging
- Solution: https://mini-ielts.com/1541/view-solution/reading/pacific-navigation-and-voyaging$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('47006eab-3063-575e-9560-dc9f33580ae0', '58172659-0659-5203-83e0-1006abfdbe08', 1, $t$Reading — Pacific navigation and voyaging$t$, $md$Read the passage and answer questions **1–14**.

### Passage: Pacific navigation and voyaging

How people migrated to the Pacific islands

The many tiny islands of the Pacific Ocean had no human population until ancestors of today’s islanders sailed from Southeast Asia in ocean-going canoes approximately 2,000 years ago. At the present time, the debate continues about exactly how they migrated such vast distances across the ocean, without any of the modern technologies we take for granted.

Although the romantic vision of some early twentieth-century writers of fleets of heroic navigators simultaneously setting sail had come to be considered by later investigators to be exaggerated, no considered assessment of Pacific voyaging was forthcoming until 1956 when the American historian Andrew Sharp published his research. Sharp challenged the ‘heroic vision’ by asserting that the expertise of the navigators was limited, and that the settlement of the islands was not systematic, being more dependent on good fortune by drifting canoes. Sharp’s theory was widely challenged, and deservedly so. If nothing else, however, it did spark renewed interest in the topic and precipitated valuable new research.

Since the 1960s a wealth of investigations has been conducted, and most of them, thankfully, have been of the ‘non-armchair’ variety. While it would be wrong to denigrate all ‘armchair’ research - that based on an examination of available published materials - it has turned out that so little progress had been made in the area of Pacific voyaging because most writers relied on the same old sources - travelers’ journals or missionary narratives compiled by unskilled observers. After Sharp, this began to change, and researchers conducted most of their investigations not in libraries, but in the field.

In 1965, David Lewis, a physician and experienced yachtsman, set to work using his own unique philosophy: he took the yacht he had owned for many years and navigated through the islands in order to contact those men who still find their way at sea using traditional methods. He then accompanied these men, in their traditional canoes, on test voyages from which all modern instruments were banished from sight, though Lewis secretly used them to confirm the navigator’s calculations. His most famous such voyage was a return trip of around 1,000 nautical miles between two islands in mid­ocean. Far from drifting, as proposed by Sharp, Lewis found that ancient navigators would have known which course to steer by memorizing which stars rose and set in certain positions along the horizon and this gave them fixed directions by which to steer their boats.

The geographer Edwin Doran followed a quite different approach. He was interested in obtaining exact data on canoe sailing performance, and to that end employed the latest electronic instrumentation. Doran traveled on board traditional sailing canoes in some of the most remote parts of the Pacific, all the while using his instruments to record canoe speeds in different wind strengths - from gales to calms - the angle canoes could sail relative to the wind. In the process, he provided the first really precise attributes of traditional sailing canoes.

A further contribution was made by Steven Horvath. As a physiologist, Horvath’s interest was not in navigation techniques or in canoes, but in the physical capabilities of the men themselves. By adapting standard physiological techniques, Horvath was able to calculate the energy expenditure required to paddle canoes of this sort at times when there was no wind to fill the sails, or when the wind was contrary. He concluded that paddles, or perhaps long oars, could indeed have propelled for long distances what were primarily sailing vessels.

Finally, a team led by p Wall Garrard conducted important research, in this case by making investigations while remaining safely in the laboratory. Wall Garrard’s unusual method was to use the findings of linguists who had studied the languages of the Pacific islands, many of which are remarkably similar although the islands where they are spoken are sometimes thousands of kilometres apart. Clever adaptation of computer simulation techniques pioneered in other disciplines allowed him to produce convincing models suggesting the migrations were indeed systematic, but not simultaneous. Wall Garrard proposed the migrations should be seen not as a single journey made by a massed fleet of canoes, but as a series of ever more ambitious voyages, each pushing further into the unknown ocean.

What do we learn about Pacific navigation and voyaging from this research? Quite correctly, none of the researchers tried to use their findings to prove one theory or another; experiments such as these cannot categorically confirm or negate a hypothesis. The strength of this research lay in the range of methodologies employed. When we splice together these findings we can propose that traditional navigators used a variety of canoe types, sources of water and navigation techniques, and it was this adaptability which was their greatest accomplishment. These navigators observed the conditions prevailing at sea at the time a voyage was made and altered their techniques accordingly. Furthermore, the canoes of the navigators were not drifting helplessly at sea but were most likely part of a systematic migration; as such, the Pacific peoples were able to view the ocean as an avenue, not a barrier, to communication before any other race on Earth. Finally, one unexpected but most welcome consequence of this research has been a renaissance in the practice of traditional voyaging. In some groups of islands in the Pacific today young people are resurrecting the skills of their ancestors, when a few decades ago it seemed they would be lost forever.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('99945f9d-528e-5958-b450-ab76a73aa155', '47006eab-3063-575e-9560-dc9f33580ae0', 1, 'YES_NO_NOT_GIVEN', 'READING', 2, $md$### Question 1

Question 1-5
Question 1-5
Do the following statements agree with the claims of the writer in Reading Passage?
In boxes 1-5 on your answer sheet, write
YES
if the statement agrees with the claims of the writer
NO
if the statement contradicts the claims of the writer
NOT GIVEN
if is impossible to say what the writer thinks about this
1
The Pacific islands were uninhabited when migrants arrived by sea from Southeast Asia
2
Andrew Sharp was the first person to write about the migrants to islanders
3
Andrew Sharp believed migratory voyages were based on more on luck than skill
4
Despite being controversial, Andrew Sharp’s research had positive results
5
Edwin Doran disagreed with the findings of Lewis’s research

1 ____ The Pacific islands were uninhabited when migrants arrived by sea from Southeast Asia$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8c9fed5a-1ad1-5fce-9c2a-204c48535e9e', '99945f9d-528e-5958-b450-ab76a73aa155', 1, $md$YES$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bd8fd156-e0b1-5709-a422-8128bc06a662', '99945f9d-528e-5958-b450-ab76a73aa155', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a2e63858-12c0-58dd-9302-7cb648e54311', '99945f9d-528e-5958-b450-ab76a73aa155', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('f3ca658d-7ef2-58c3-806d-6fa82ef4ed1e', '47006eab-3063-575e-9560-dc9f33580ae0', 2, 'YES_NO_NOT_GIVEN', 'READING', 2, $md$### Question 2

Question 1-5
Question 1-5
Do the following statements agree with the claims of the writer in Reading Passage?
In boxes 1-5 on your answer sheet, write
YES
if the statement agrees with the claims of the writer
NO
if the statement contradicts the claims of the writer
NOT GIVEN
if is impossible to say what the writer thinks about this
1
The Pacific islands were uninhabited when migrants arrived by sea from Southeast Asia
2
Andrew Sharp was the first person to write about the migrants to islanders
3
Andrew Sharp believed migratory voyages were based on more on luck than skill
4
Despite being controversial, Andrew Sharp’s research had positive results
5
Edwin Doran disagreed with the findings of Lewis’s research

2 ____ Andrew Sharp was the first person to write about the migrants to islanders$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cdd5f31f-fc9a-59eb-bf1c-9ff055e8f2d0', 'f3ca658d-7ef2-58c3-806d-6fa82ef4ed1e', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7e37633a-23d4-5b6b-a039-7e485dc71c23', 'f3ca658d-7ef2-58c3-806d-6fa82ef4ed1e', 2, $md$NO$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1d2212b4-f7ae-54fd-8ff0-8622331e88b1', 'f3ca658d-7ef2-58c3-806d-6fa82ef4ed1e', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('27dcb8c0-b802-54a1-84c6-6c4075fefd67', '47006eab-3063-575e-9560-dc9f33580ae0', 3, 'YES_NO_NOT_GIVEN', 'READING', 2, $md$### Question 3

Question 1-5
Question 1-5
Do the following statements agree with the claims of the writer in Reading Passage?
In boxes 1-5 on your answer sheet, write
YES
if the statement agrees with the claims of the writer
NO
if the statement contradicts the claims of the writer
NOT GIVEN
if is impossible to say what the writer thinks about this
1
The Pacific islands were uninhabited when migrants arrived by sea from Southeast Asia
2
Andrew Sharp was the first person to write about the migrants to islanders
3
Andrew Sharp believed migratory voyages were based on more on luck than skill
4
Despite being controversial, Andrew Sharp’s research had positive results
5
Edwin Doran disagreed with the findings of Lewis’s research

3 ____ Andrew Sharp believed migratory voyages were based on more on luck than skill$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('39d1642d-cc33-54cd-8d53-6ad4e9bbeea0', '27dcb8c0-b802-54a1-84c6-6c4075fefd67', 1, $md$YES$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('216f365c-82bf-5f2a-beeb-4a4728bed6eb', '27dcb8c0-b802-54a1-84c6-6c4075fefd67', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9564d359-93e0-578c-b75b-d87843ba901a', '27dcb8c0-b802-54a1-84c6-6c4075fefd67', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('eb3fdb61-880d-5f0c-96af-2c78e046d1c1', '47006eab-3063-575e-9560-dc9f33580ae0', 4, 'YES_NO_NOT_GIVEN', 'READING', 2, $md$### Question 4

Question 1-5
Question 1-5
Do the following statements agree with the claims of the writer in Reading Passage?
In boxes 1-5 on your answer sheet, write
YES
if the statement agrees with the claims of the writer
NO
if the statement contradicts the claims of the writer
NOT GIVEN
if is impossible to say what the writer thinks about this
1
The Pacific islands were uninhabited when migrants arrived by sea from Southeast Asia
2
Andrew Sharp was the first person to write about the migrants to islanders
3
Andrew Sharp believed migratory voyages were based on more on luck than skill
4
Despite being controversial, Andrew Sharp’s research had positive results
5
Edwin Doran disagreed with the findings of Lewis’s research

4 ____ Despite being controversial, Andrew Sharp’s research had positive results$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('09b6572e-eb71-5160-9968-42933b0bcb76', 'eb3fdb61-880d-5f0c-96af-2c78e046d1c1', 1, $md$YES$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0e95ac9b-5153-5c78-b8dc-9f892f6fdb12', 'eb3fdb61-880d-5f0c-96af-2c78e046d1c1', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('dfee62d7-370c-58ec-93ff-bbd119d45dee', 'eb3fdb61-880d-5f0c-96af-2c78e046d1c1', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('25de138f-aa9c-538d-b631-2dc8fca427d8', '47006eab-3063-575e-9560-dc9f33580ae0', 5, 'YES_NO_NOT_GIVEN', 'READING', 3, $md$### Question 5

Question 1-5
Question 1-5
Do the following statements agree with the claims of the writer in Reading Passage?
In boxes 1-5 on your answer sheet, write
YES
if the statement agrees with the claims of the writer
NO
if the statement contradicts the claims of the writer
NOT GIVEN
if is impossible to say what the writer thinks about this
1
The Pacific islands were uninhabited when migrants arrived by sea from Southeast Asia
2
Andrew Sharp was the first person to write about the migrants to islanders
3
Andrew Sharp believed migratory voyages were based on more on luck than skill
4
Despite being controversial, Andrew Sharp’s research had positive results
5
Edwin Doran disagreed with the findings of Lewis’s research

5 ____ Edwin Doran disagreed with the findings of Lewis’s research$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fc285870-3571-5178-9207-1ea92a0e0e1b', '25de138f-aa9c-538d-b631-2dc8fca427d8', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7730cf67-9cb4-5cc3-96ae-6adf43588af6', '25de138f-aa9c-538d-b631-2dc8fca427d8', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('08058f05-986f-55da-b823-d67d346a34ef', '25de138f-aa9c-538d-b631-2dc8fca427d8', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('74540403-1078-5999-a2a6-a5c49c1beb06', '47006eab-3063-575e-9560-dc9f33580ae0', 6, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 6

Questions 6-10
Questions 6-10
Choose the correct letter,
A, B, C or D.
Write the correct letter in boxes 6-10 on your answer sheet.
6.
David Lewis’s research was different because
A
he observed traditional navigators at work
B
he conducted test voyages using his own yacht
C
he carried no modern instruments on test voyages
D
he spoke the same language as the islanders he sailed with
7.
What did David Lewis’s research discover about traditional navigators?
A
They used the sun and moon to find their position
B
They could not sail further
than about
1,000 nautical miles
C
They knew which direction they were
sailing
in
D
They were able to drift for long distances
8.
What
are we told about Edwin Doran’s research?
A
Data were collected after the canoes had returned to land
B
Canoe characteristics were recorded using modern instruments
C
Research was conducted in the most densely populated regions
D
Navigators were not allowed to see the instruments Doran used
9.
Which
of
the
following did Steven Horvath discover during his research?
A
Canoe design was less important than human strength
B
New research methods had to be developed for use in canoes
C
Navigators became very tired on the longest voyages
D
Human energy may have been used to assist sailing canoes
10.
What
is the writer’s opinion
of
p Wall Garrard’s research?
A
He is disappointed it was conducted in the laboratory
B
He is impressed by the originality of the techniques used
C
He is surprised it was used to help linguists with their research
D
He is concerned that the islands studied are long distances apart

Choose the correct letter, A, B, C or D.$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('2ac3a13d-d46e-5015-adb2-ab9f5d19dfd9', '47006eab-3063-575e-9560-dc9f33580ae0', 7, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 7

Questions 6-10
Questions 6-10
Choose the correct letter,
A, B, C or D.
Write the correct letter in boxes 6-10 on your answer sheet.
6.
David Lewis’s research was different because
A
he observed traditional navigators at work
B
he conducted test voyages using his own yacht
C
he carried no modern instruments on test voyages
D
he spoke the same language as the islanders he sailed with
7.
What did David Lewis’s research discover about traditional navigators?
A
They used the sun and moon to find their position
B
They could not sail further
than about
1,000 nautical miles
C
They knew which direction they were
sailing
in
D
They were able to drift for long distances
8.
What
are we told about Edwin Doran’s research?
A
Data were collected after the canoes had returned to land
B
Canoe characteristics were recorded using modern instruments
C
Research was conducted in the most densely populated regions
D
Navigators were not allowed to see the instruments Doran used
9.
Which
of
the
following did Steven Horvath discover during his research?
A
Canoe design was less important than human strength
B
New research methods had to be developed for use in canoes
C
Navigators became very tired on the longest voyages
D
Human energy may have been used to assist sailing canoes
10.
What
is the writer’s opinion
of
p Wall Garrard’s research?
A
He is disappointed it was conducted in the laboratory
B
He is impressed by the originality of the techniques used
C
He is surprised it was used to help linguists with their research
D
He is concerned that the islands studied are long distances apart

Choose the correct letter, A, B, C or D.$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('f01d5748-20c5-586e-884c-394487aba098', '47006eab-3063-575e-9560-dc9f33580ae0', 8, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 8

Questions 6-10
Questions 6-10
Choose the correct letter,
A, B, C or D.
Write the correct letter in boxes 6-10 on your answer sheet.
6.
David Lewis’s research was different because
A
he observed traditional navigators at work
B
he conducted test voyages using his own yacht
C
he carried no modern instruments on test voyages
D
he spoke the same language as the islanders he sailed with
7.
What did David Lewis’s research discover about traditional navigators?
A
They used the sun and moon to find their position
B
They could not sail further
than about
1,000 nautical miles
C
They knew which direction they were
sailing
in
D
They were able to drift for long distances
8.
What
are we told about Edwin Doran’s research?
A
Data were collected after the canoes had returned to land
B
Canoe characteristics were recorded using modern instruments
C
Research was conducted in the most densely populated regions
D
Navigators were not allowed to see the instruments Doran used
9.
Which
of
the
following did Steven Horvath discover during his research?
A
Canoe design was less important than human strength
B
New research methods had to be developed for use in canoes
C
Navigators became very tired on the longest voyages
D
Human energy may have been used to assist sailing canoes
10.
What
is the writer’s opinion
of
p Wall Garrard’s research?
A
He is disappointed it was conducted in the laboratory
B
He is impressed by the originality of the techniques used
C
He is surprised it was used to help linguists with their research
D
He is concerned that the islands studied are long distances apart

Choose the correct letter, A, B, C or D.$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('7ef250dd-b0cf-5e95-9284-32b5ed4da117', '47006eab-3063-575e-9560-dc9f33580ae0', 9, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 9

Questions 6-10
Questions 6-10
Choose the correct letter,
A, B, C or D.
Write the correct letter in boxes 6-10 on your answer sheet.
6.
David Lewis’s research was different because
A
he observed traditional navigators at work
B
he conducted test voyages using his own yacht
C
he carried no modern instruments on test voyages
D
he spoke the same language as the islanders he sailed with
7.
What did David Lewis’s research discover about traditional navigators?
A
They used the sun and moon to find their position
B
They could not sail further
than about
1,000 nautical miles
C
They knew which direction they were
sailing
in
D
They were able to drift for long distances
8.
What
are we told about Edwin Doran’s research?
A
Data were collected after the canoes had returned to land
B
Canoe characteristics were recorded using modern instruments
C
Research was conducted in the most densely populated regions
D
Navigators were not allowed to see the instruments Doran used
9.
Which
of
the
following did Steven Horvath discover during his research?
A
Canoe design was less important than human strength
B
New research methods had to be developed for use in canoes
C
Navigators became very tired on the longest voyages
D
Human energy may have been used to assist sailing canoes
10.
What
is the writer’s opinion
of
p Wall Garrard’s research?
A
He is disappointed it was conducted in the laboratory
B
He is impressed by the originality of the techniques used
C
He is surprised it was used to help linguists with their research
D
He is concerned that the islands studied are long distances apart

Choose the correct letter, A, B, C or D.$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('72a26e56-2166-537e-befa-10ae313c6481', '47006eab-3063-575e-9560-dc9f33580ae0', 10, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 10

Questions 6-10
Questions 6-10
Choose the correct letter,
A, B, C or D.
Write the correct letter in boxes 6-10 on your answer sheet.
6.
David Lewis’s research was different because
A
he observed traditional navigators at work
B
he conducted test voyages using his own yacht
C
he carried no modern instruments on test voyages
D
he spoke the same language as the islanders he sailed with
7.
What did David Lewis’s research discover about traditional navigators?
A
They used the sun and moon to find their position
B
They could not sail further
than about
1,000 nautical miles
C
They knew which direction they were
sailing
in
D
They were able to drift for long distances
8.
What
are we told about Edwin Doran’s research?
A
Data were collected after the canoes had returned to land
B
Canoe characteristics were recorded using modern instruments
C
Research was conducted in the most densely populated regions
D
Navigators were not allowed to see the instruments Doran used
9.
Which
of
the
following did Steven Horvath discover during his research?
A
Canoe design was less important than human strength
B
New research methods had to be developed for use in canoes
C
Navigators became very tired on the longest voyages
D
Human energy may have been used to assist sailing canoes
10.
What
is the writer’s opinion
of
p Wall Garrard’s research?
A
He is disappointed it was conducted in the laboratory
B
He is impressed by the originality of the techniques used
C
He is surprised it was used to help linguists with their research
D
He is concerned that the islands studied are long distances apart

Choose the correct letter, A, B, C or D.$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('78a8fa8d-1cf2-52eb-9242-d48c760a6c00', '47006eab-3063-575e-9560-dc9f33580ae0', 11, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 11

Questions 11-14
Questions 11-14
Complete each sentence with the correct ending, A-F, below.
Write the correct letter, A-F, in boxes 11-14 on your answer sheet.
11
One limitation in the information produced by all of this research is that it
12
The best thing about this type of research
13
The most important achievement of traditional navigators
14
The migration of people from Asia to the Pacific
A
was the variety of experimental techniques used
B
was not of interest to young islanders today
c
was not conclusive evidence in support of a single theory
D
was being able to change their practices when necessary
E
was the first time humans intentionally crossed an ocean
F
was the speed with which it was conducted

11 ____ One limitation in the information produced by all of this research is that it$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8a60bc6f-5c30-5d17-9ae7-db2073589979', '78a8fa8d-1cf2-52eb-9242-d48c760a6c00', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('39f80341-1af2-5f91-b053-ac8aefe22b35', '78a8fa8d-1cf2-52eb-9242-d48c760a6c00', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ac092471-c0af-5d92-bc58-acb60ee40163', '78a8fa8d-1cf2-52eb-9242-d48c760a6c00', 3, $md$C$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8bc01243-7b91-554c-b8b1-4e399678ad1c', '78a8fa8d-1cf2-52eb-9242-d48c760a6c00', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f346a788-82d9-5d66-98eb-05dcea0c515a', '78a8fa8d-1cf2-52eb-9242-d48c760a6c00', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('622a9281-fb38-5530-a9fa-c6798d47b294', '78a8fa8d-1cf2-52eb-9242-d48c760a6c00', 6, $md$F$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('2128f2c6-a27a-544b-aad1-33247b5f9f67', '47006eab-3063-575e-9560-dc9f33580ae0', 12, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 12

Questions 11-14
Questions 11-14
Complete each sentence with the correct ending, A-F, below.
Write the correct letter, A-F, in boxes 11-14 on your answer sheet.
11
One limitation in the information produced by all of this research is that it
12
The best thing about this type of research
13
The most important achievement of traditional navigators
14
The migration of people from Asia to the Pacific
A
was the variety of experimental techniques used
B
was not of interest to young islanders today
c
was not conclusive evidence in support of a single theory
D
was being able to change their practices when necessary
E
was the first time humans intentionally crossed an ocean
F
was the speed with which it was conducted

12 ____ The best thing about this type of research$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9cfe067b-9f12-52af-860d-c5fd7d7ff8c2', '2128f2c6-a27a-544b-aad1-33247b5f9f67', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('83852a80-3450-5b04-9a06-4eb75ef5caef', '2128f2c6-a27a-544b-aad1-33247b5f9f67', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('72ca3d03-d30a-516d-9ddb-c2f9c1371ad3', '2128f2c6-a27a-544b-aad1-33247b5f9f67', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('614ec480-a2e7-5436-80da-5be5f461e9fd', '2128f2c6-a27a-544b-aad1-33247b5f9f67', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9dc7343a-21d3-5f6c-9739-85b8b06a60e4', '2128f2c6-a27a-544b-aad1-33247b5f9f67', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('11700553-3faf-5031-910a-7335b3db4381', '2128f2c6-a27a-544b-aad1-33247b5f9f67', 6, $md$F$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('ccec578e-18f2-5515-9f57-8d31d03b9d6d', '47006eab-3063-575e-9560-dc9f33580ae0', 13, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 13

Questions 11-14
Questions 11-14
Complete each sentence with the correct ending, A-F, below.
Write the correct letter, A-F, in boxes 11-14 on your answer sheet.
11
One limitation in the information produced by all of this research is that it
12
The best thing about this type of research
13
The most important achievement of traditional navigators
14
The migration of people from Asia to the Pacific
A
was the variety of experimental techniques used
B
was not of interest to young islanders today
c
was not conclusive evidence in support of a single theory
D
was being able to change their practices when necessary
E
was the first time humans intentionally crossed an ocean
F
was the speed with which it was conducted

13 ____ The most important achievement of traditional navigators$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2d1e8d3b-772f-56d5-b80f-dbb3e4e7c5de', 'ccec578e-18f2-5515-9f57-8d31d03b9d6d', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9561064c-7d8d-5518-b3e7-addce835a68d', 'ccec578e-18f2-5515-9f57-8d31d03b9d6d', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('edce0aea-6bbf-5e1f-8b7c-b39c08746d89', 'ccec578e-18f2-5515-9f57-8d31d03b9d6d', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('41c51bc2-1726-51be-9baf-d00411ef8fdc', 'ccec578e-18f2-5515-9f57-8d31d03b9d6d', 4, $md$D$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4b2c2e37-cbed-54ab-9790-f541f3c4c142', 'ccec578e-18f2-5515-9f57-8d31d03b9d6d', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1cf622a7-2e8b-5841-8826-c96d89d50d9d', 'ccec578e-18f2-5515-9f57-8d31d03b9d6d', 6, $md$F$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('bd0fa440-85eb-5e31-9b1b-cec1145dde0c', '47006eab-3063-575e-9560-dc9f33580ae0', 14, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 14

Questions 11-14
Questions 11-14
Complete each sentence with the correct ending, A-F, below.
Write the correct letter, A-F, in boxes 11-14 on your answer sheet.
11
One limitation in the information produced by all of this research is that it
12
The best thing about this type of research
13
The most important achievement of traditional navigators
14
The migration of people from Asia to the Pacific
A
was the variety of experimental techniques used
B
was not of interest to young islanders today
c
was not conclusive evidence in support of a single theory
D
was being able to change their practices when necessary
E
was the first time humans intentionally crossed an ocean
F
was the speed with which it was conducted

14 ____ The migration of people from Asia to the Pacific$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8ba807e4-db0f-5e1f-b0a4-590a03e0c061', 'bd0fa440-85eb-5e31-9b1b-cec1145dde0c', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('dfe9de3c-dbe8-5a13-9cf1-0833a3f043a0', 'bd0fa440-85eb-5e31-9b1b-cec1145dde0c', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bda0654d-2d38-5a43-b9f6-b17d6bd6b3de', 'bd0fa440-85eb-5e31-9b1b-cec1145dde0c', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e399c88a-c0c8-5062-a914-fe0ace27a91d', 'bd0fa440-85eb-5e31-9b1b-cec1145dde0c', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('83569bdf-0202-5110-8d20-c021c748303e', 'bd0fa440-85eb-5e31-9b1b-cec1145dde0c', 5, $md$E$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2e29c417-2838-517c-8ace-279effe4410f', 'bd0fa440-85eb-5e31-9b1b-cec1145dde0c', 6, $md$F$md$, false);

COMMIT;
