BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-the-clipper-races-an-era-of-competition-between-cargo-ships-1434'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-the-clipper-races-an-era-of-competition-between-cargo-ships-1434';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-the-clipper-races-an-era-of-competition-between-cargo-ships-1434';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-the-clipper-races-an-era-of-competition-between-cargo-ships-1434';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('d0958abb-684b-5c6c-b537-1febdbe5ad03', 'ielts-reading-the-clipper-races-an-era-of-competition-between-cargo-ships-1434', $t$The Clipper Races: an era of competition between cargo ships$t$, $md$## The Clipper Races: an era of competition between cargo ships

Nguồn:
- Test: https://mini-ielts.com/1434/reading/the-clipper-races-an-era-of-competition-between-cargo-ships
- Solution: https://mini-ielts.com/1434/view-solution/reading/the-clipper-races-an-era-of-competition-between-cargo-ships$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('fe88fab7-a1c0-5d6b-857d-86736b79bc8c', 'd0958abb-684b-5c6c-b537-1febdbe5ad03', 1, $t$Reading — The Clipper Races: an era of competition between cargo ships$t$, $md$Read the passage and answer questions **1–13**.

### Passage: The Clipper Races: an era of competition between cargo ships

During the seventeenth and eighteenth centuries, the British East India Company had the monopoly on trade with China and India. This meant that because no rival could legally import tea or other goods from these countries at this time, the company was rarely in a hurry to transport its merchandise. Instead, its priority was to minimise costs by carrying as much as possible on each ship. This meant that its ships - known as East Indiamen - were enormous, strong and very slow.

By 1800, the average East Indiaman could carry 1,200 tons of merchandise. The trading pattern for China tea usually meant the East Indiamen set sail from Britain in January, sailed round the Cape of Good Hope at the southernmost tip of Africa, and arrived in China in September. There they would load up that year's tea harvest, set off again and, depending on the wind and weather, aim to arrive back by the following September. So even with favourable sailing conditions, the round trip lasted almost two years, and if anything went wrong it could take a lot longer.

However, by 1834 the company had lost its trading monopolies, and tea had become a freely traded item. Having no more use for its great ships, the company sold them off, and many were bought by merchants or their captains, who continued to plough the seas between Britain and China. But now that tea could be traded freely, a few smart sailors began to realise that whoever brought each new harvest of tea to Britain first, stood to make the most money.

This was partly because if you were home first, you could sell your shipment of tea before your competitors even arrived, and partly because consumers in Britain in the nineteenth century believed that the fresher and earlier-picked the tea, the better the resulting drink. Tea traders now needed faster, sleeker ships to bring their precious cargo back. Nevertheless, in Britain this idea only caught on slowly, and white the 1840s saw a few faster ships launched, for the time being many merchants remained satisfied with the slow but reliable East Indiamen.

In fact it was the Americans who pioneered the first clipper ships. These vessels were fast and slender, with a narrow hull that was deeper at the back than at the front and masses of sails on tall masts. They earned their name from the way that they clipped off journey times British merchants resolved to build their own clippers to rival the Americans and the first British tea clipper, Stornaway, was built in Aberdeen in 1850 More tea clippers were designed and built in Britain throughout the 1850s and 1860s, they had a narrower beam than their American equivalents, making them less powerful during storms, but faster in calmer weather.

There was a great spirit of competition between the British and American ships plying the tea trade, but to begin with the Americans had the edge. Then in 1851 a British ship owner, Richard Green, built the aptly named clipper Challenger, with the stated intention of beating the American ships. Loaded with tea, Challenger left China for London in 1852 at the same time as the American clipper Challenge, a much larger, older ship, already greatly admired for its speed. Large sums were bet on which would complete the journey first. In the event, the British ship beat its rival to London by two days, amid much jubilation. From then on, such international races grew in popularity.

After 1855, American participation in the British tea trade gradually stopped. But even without the Anglo-American rivalry, the competitive spirit continued. It was really ignited when new ports were opened up for trade in China. These included Fouchow, which was much closer to the tea-producing areas than Canton, the port used previously. As a result, tea could be loaded onboard earlier and fresher, and the clippers could set off in late May or early June - sometimes not even taking time to fill out the official paperwork - racing back to Britain whatever the difficulties.

They sped down through the South China Sea and into the Indian Ocean, then raced to get round the southernmost tip of Africa at the Cape of Good Hope. Then it was north across the vast Atlantic, past the Azores, through the English Channel and into the estuary of the River Thames. Once there, they would be towed by tugs, up the river and into the docks.

The cargo of the winning ship could earn a premium of up to sixpence per pound-and so the captain and crew were rewarded by the owners of the cargo. But the races were about more than just money the crews, about 40 men on each clipper, were expert sailors, proud of their ships, and they delighted in competing against each other. Without their enthusiasm, the races would never have happened, since getting the ship home as fast as possible required the crew to be totally dedicated and to sacrifice much of their rest for the duration of the race.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('c0eaa801-b9ad-5d09-b364-fc5db8ae9930', 'fe88fab7-a1c0-5d6b-857d-86736b79bc8c', 1, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 1

Questions 1 - 6
Questions 1 - 6
Do the following statements agree with the information given in Reading Passage 1?
In boxes 1-6 on your answer sheet, write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
1
In the seventeenth and eighteenth centuries, the British East India Company faced a lot of competition.
2
Before 1800, cargo size was the most important consideration for the East India Company.
3
At best, voyages of the East Indiamen to China and back took nearly two years to complete.
4
Before 1834, voyages to and from China were considered to be highly dangerous.
5
After 1834, the ships which had served the East India Company stopped being used for commercial purposes.
6
In the nineteenth century, British drinkers preferred tea made from mature leaves to that made from younger leaves.

1 ____ In the seventeenth and eighteenth centuries, the British East India Company faced a lot of competition.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7ddf03d1-7f5b-5e04-ad3d-30ac594ed2b1', 'c0eaa801-b9ad-5d09-b364-fc5db8ae9930', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f2067c8d-2b56-5246-8963-2123fae6b26a', 'c0eaa801-b9ad-5d09-b364-fc5db8ae9930', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c4e22a59-6d33-50f4-b1b8-600dacb2a570', 'c0eaa801-b9ad-5d09-b364-fc5db8ae9930', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('adffee9a-2a61-51e8-8434-20027b308a34', 'fe88fab7-a1c0-5d6b-857d-86736b79bc8c', 2, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 2

Questions 1 - 6
Questions 1 - 6
Do the following statements agree with the information given in Reading Passage 1?
In boxes 1-6 on your answer sheet, write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
1
In the seventeenth and eighteenth centuries, the British East India Company faced a lot of competition.
2
Before 1800, cargo size was the most important consideration for the East India Company.
3
At best, voyages of the East Indiamen to China and back took nearly two years to complete.
4
Before 1834, voyages to and from China were considered to be highly dangerous.
5
After 1834, the ships which had served the East India Company stopped being used for commercial purposes.
6
In the nineteenth century, British drinkers preferred tea made from mature leaves to that made from younger leaves.

2 ____ Before 1800, cargo size was the most important consideration for the East India Company.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c5daf6da-2958-50c6-8dc1-8449189acc29', 'adffee9a-2a61-51e8-8434-20027b308a34', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('72ec3769-c3c9-5990-ac79-013a303b1c47', 'adffee9a-2a61-51e8-8434-20027b308a34', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('21b8d542-1490-5b94-8dfb-7a59680f4211', 'adffee9a-2a61-51e8-8434-20027b308a34', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('a54d5029-c7b0-5e7d-aa1b-3a4aaaf09b5d', 'fe88fab7-a1c0-5d6b-857d-86736b79bc8c', 3, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 3

Questions 1 - 6
Questions 1 - 6
Do the following statements agree with the information given in Reading Passage 1?
In boxes 1-6 on your answer sheet, write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
1
In the seventeenth and eighteenth centuries, the British East India Company faced a lot of competition.
2
Before 1800, cargo size was the most important consideration for the East India Company.
3
At best, voyages of the East Indiamen to China and back took nearly two years to complete.
4
Before 1834, voyages to and from China were considered to be highly dangerous.
5
After 1834, the ships which had served the East India Company stopped being used for commercial purposes.
6
In the nineteenth century, British drinkers preferred tea made from mature leaves to that made from younger leaves.

3 ____ At best, voyages of the East Indiamen to China and back took nearly two years to complete.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('026fd056-34d3-577f-820c-5d5d6d4397d3', 'a54d5029-c7b0-5e7d-aa1b-3a4aaaf09b5d', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('438515a2-a5dd-5f57-9db1-db2b1763daf7', 'a54d5029-c7b0-5e7d-aa1b-3a4aaaf09b5d', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0aafe303-6b8f-5024-a3f1-7ed0e86bcb81', 'a54d5029-c7b0-5e7d-aa1b-3a4aaaf09b5d', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('1b34c857-5848-595b-aa45-bf4dec28d7ca', 'fe88fab7-a1c0-5d6b-857d-86736b79bc8c', 4, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 4

Questions 1 - 6
Questions 1 - 6
Do the following statements agree with the information given in Reading Passage 1?
In boxes 1-6 on your answer sheet, write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
1
In the seventeenth and eighteenth centuries, the British East India Company faced a lot of competition.
2
Before 1800, cargo size was the most important consideration for the East India Company.
3
At best, voyages of the East Indiamen to China and back took nearly two years to complete.
4
Before 1834, voyages to and from China were considered to be highly dangerous.
5
After 1834, the ships which had served the East India Company stopped being used for commercial purposes.
6
In the nineteenth century, British drinkers preferred tea made from mature leaves to that made from younger leaves.

4 ____ Before 1834, voyages to and from China were considered to be highly dangerous.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4acad847-caf1-59ff-8847-38c5f261c6e7', '1b34c857-5848-595b-aa45-bf4dec28d7ca', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d1435557-e7f3-5535-a71c-8957ee0771be', '1b34c857-5848-595b-aa45-bf4dec28d7ca', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f9b30362-eff9-551c-a243-1acc9c685976', '1b34c857-5848-595b-aa45-bf4dec28d7ca', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('9024b79c-4985-5259-aff9-d3130c98fd74', 'fe88fab7-a1c0-5d6b-857d-86736b79bc8c', 5, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 5

Questions 1 - 6
Questions 1 - 6
Do the following statements agree with the information given in Reading Passage 1?
In boxes 1-6 on your answer sheet, write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
1
In the seventeenth and eighteenth centuries, the British East India Company faced a lot of competition.
2
Before 1800, cargo size was the most important consideration for the East India Company.
3
At best, voyages of the East Indiamen to China and back took nearly two years to complete.
4
Before 1834, voyages to and from China were considered to be highly dangerous.
5
After 1834, the ships which had served the East India Company stopped being used for commercial purposes.
6
In the nineteenth century, British drinkers preferred tea made from mature leaves to that made from younger leaves.

5 ____ After 1834, the ships which had served the East India Company stopped being used for commercial purposes.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0ce6853a-64b4-593c-ae14-d02f2f8cc83c', '9024b79c-4985-5259-aff9-d3130c98fd74', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e0eaff49-6f8a-5a95-a9ae-5fd817654a10', '9024b79c-4985-5259-aff9-d3130c98fd74', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ae258a3f-21e7-5814-9abb-e2b25ceb2c2b', '9024b79c-4985-5259-aff9-d3130c98fd74', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('33c5334a-fbc8-59b5-8ee9-9d77270a9b16', 'fe88fab7-a1c0-5d6b-857d-86736b79bc8c', 6, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 6

Questions 1 - 6
Questions 1 - 6
Do the following statements agree with the information given in Reading Passage 1?
In boxes 1-6 on your answer sheet, write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
1
In the seventeenth and eighteenth centuries, the British East India Company faced a lot of competition.
2
Before 1800, cargo size was the most important consideration for the East India Company.
3
At best, voyages of the East Indiamen to China and back took nearly two years to complete.
4
Before 1834, voyages to and from China were considered to be highly dangerous.
5
After 1834, the ships which had served the East India Company stopped being used for commercial purposes.
6
In the nineteenth century, British drinkers preferred tea made from mature leaves to that made from younger leaves.

6 ____ In the nineteenth century, British drinkers preferred tea made from mature leaves to that made from younger leaves.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fbc4d518-997d-5fc2-85ca-3904e27387ce', '33c5334a-fbc8-59b5-8ee9-9d77270a9b16', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d6e9b8a5-547f-5c7a-a5a8-4256362609b1', '33c5334a-fbc8-59b5-8ee9-9d77270a9b16', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('58784fd1-6054-5b75-9a65-4b0558de9a17', '33c5334a-fbc8-59b5-8ee9-9d77270a9b16', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('eabc7bef-c2ab-5a7c-96e4-966dd159a1ad', 'fe88fab7-a1c0-5d6b-857d-86736b79bc8c', 7, 'NOTE_COMPLETION', 'READING', 3, $md$### Question 7

Questions 7-13
Questions 7-13
Complete the notes below.
Choose
ONE WORD ONL Y
from the passage for each answer.
Write your answers in boxes 7-13 on your answer sheet.
Clipper races
The ships
Clipper ships were first used for trading by American merchants.
The ships were remarkable for the number of
7
they had.
The performance of British tea clippers was particularly affected when there were
8
at sea.
The races
It was in a ship called
9
that the British first competed successfully against the Americans.
Richard Green’s ship arrived two days ahead of its competitor.
Competition increased when additional Chinese trading
10
were established.
Merchants were occasionally in such a hurry that they failed to complete the
11
before leaving China.
At the end of their journey, the ships needed the help of
12
The rewards
The crews were motivated by both
13
and their enthusiasm for the competition.

The ships were remarkable for the number of 7 ____ they had.$md$, NULL, ARRAY['.*sails.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('f23b1cc5-db2c-5e0f-a63e-f20cc781de93', 'fe88fab7-a1c0-5d6b-857d-86736b79bc8c', 8, 'NOTE_COMPLETION', 'READING', 3, $md$### Question 8

Questions 7-13
Questions 7-13
Complete the notes below.
Choose
ONE WORD ONL Y
from the passage for each answer.
Write your answers in boxes 7-13 on your answer sheet.
Clipper races
The ships
Clipper ships were first used for trading by American merchants.
The ships were remarkable for the number of
7
they had.
The performance of British tea clippers was particularly affected when there were
8
at sea.
The races
It was in a ship called
9
that the British first competed successfully against the Americans.
Richard Green’s ship arrived two days ahead of its competitor.
Competition increased when additional Chinese trading
10
were established.
Merchants were occasionally in such a hurry that they failed to complete the
11
before leaving China.
At the end of their journey, the ships needed the help of
12
The rewards
The crews were motivated by both
13
and their enthusiasm for the competition.

The performance of British tea clippers was particularly affected when there were 8 ____ at sea.$md$, NULL, ARRAY['.*storms.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('169b6c85-0cfe-5c5d-8c78-8b56f32ab159', 'fe88fab7-a1c0-5d6b-857d-86736b79bc8c', 9, 'NOTE_COMPLETION', 'READING', 3, $md$### Question 9

Questions 7-13
Questions 7-13
Complete the notes below.
Choose
ONE WORD ONL Y
from the passage for each answer.
Write your answers in boxes 7-13 on your answer sheet.
Clipper races
The ships
Clipper ships were first used for trading by American merchants.
The ships were remarkable for the number of
7
they had.
The performance of British tea clippers was particularly affected when there were
8
at sea.
The races
It was in a ship called
9
that the British first competed successfully against the Americans.
Richard Green’s ship arrived two days ahead of its competitor.
Competition increased when additional Chinese trading
10
were established.
Merchants were occasionally in such a hurry that they failed to complete the
11
before leaving China.
At the end of their journey, the ships needed the help of
12
The rewards
The crews were motivated by both
13
and their enthusiasm for the competition.

It was in a ship called 9 ____ that the British first competed successfully against the Americans.$md$, NULL, ARRAY['.*challenger.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('b32454b3-2cee-564b-88b9-6609c58a3494', 'fe88fab7-a1c0-5d6b-857d-86736b79bc8c', 10, 'NOTE_COMPLETION', 'READING', 4, $md$### Question 10

Questions 7-13
Questions 7-13
Complete the notes below.
Choose
ONE WORD ONL Y
from the passage for each answer.
Write your answers in boxes 7-13 on your answer sheet.
Clipper races
The ships
Clipper ships were first used for trading by American merchants.
The ships were remarkable for the number of
7
they had.
The performance of British tea clippers was particularly affected when there were
8
at sea.
The races
It was in a ship called
9
that the British first competed successfully against the Americans.
Richard Green’s ship arrived two days ahead of its competitor.
Competition increased when additional Chinese trading
10
were established.
Merchants were occasionally in such a hurry that they failed to complete the
11
before leaving China.
At the end of their journey, the ships needed the help of
12
The rewards
The crews were motivated by both
13
and their enthusiasm for the competition.

Competition increased when additional Chinese trading 10 ____ were established.$md$, NULL, ARRAY['.*ports.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('06fea3e1-a3e6-5240-8c0d-b01479c495c5', 'fe88fab7-a1c0-5d6b-857d-86736b79bc8c', 11, 'NOTE_COMPLETION', 'READING', 4, $md$### Question 11

Questions 7-13
Questions 7-13
Complete the notes below.
Choose
ONE WORD ONL Y
from the passage for each answer.
Write your answers in boxes 7-13 on your answer sheet.
Clipper races
The ships
Clipper ships were first used for trading by American merchants.
The ships were remarkable for the number of
7
they had.
The performance of British tea clippers was particularly affected when there were
8
at sea.
The races
It was in a ship called
9
that the British first competed successfully against the Americans.
Richard Green’s ship arrived two days ahead of its competitor.
Competition increased when additional Chinese trading
10
were established.
Merchants were occasionally in such a hurry that they failed to complete the
11
before leaving China.
At the end of their journey, the ships needed the help of
12
The rewards
The crews were motivated by both
13
and their enthusiasm for the competition.

Merchants were occasionally in such a hurry that they failed to complete the 11 ____ before leaving China.$md$, NULL, ARRAY['.*paperwork.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('51dbcacc-75cc-5b04-98ba-445b5f637ba0', 'fe88fab7-a1c0-5d6b-857d-86736b79bc8c', 12, 'NOTE_COMPLETION', 'READING', 4, $md$### Question 12

Questions 7-13
Questions 7-13
Complete the notes below.
Choose
ONE WORD ONL Y
from the passage for each answer.
Write your answers in boxes 7-13 on your answer sheet.
Clipper races
The ships
Clipper ships were first used for trading by American merchants.
The ships were remarkable for the number of
7
they had.
The performance of British tea clippers was particularly affected when there were
8
at sea.
The races
It was in a ship called
9
that the British first competed successfully against the Americans.
Richard Green’s ship arrived two days ahead of its competitor.
Competition increased when additional Chinese trading
10
were established.
Merchants were occasionally in such a hurry that they failed to complete the
11
before leaving China.
At the end of their journey, the ships needed the help of
12
The rewards
The crews were motivated by both
13
and their enthusiasm for the competition.

At the end of their journey, the ships needed the help of 12 ____$md$, NULL, ARRAY['.*tugs.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('1c5fc0ae-dfa3-55d5-bff1-f21527ebc91f', 'fe88fab7-a1c0-5d6b-857d-86736b79bc8c', 13, 'NOTE_COMPLETION', 'READING', 4, $md$### Question 13

Questions 7-13
Questions 7-13
Complete the notes below.
Choose
ONE WORD ONL Y
from the passage for each answer.
Write your answers in boxes 7-13 on your answer sheet.
Clipper races
The ships
Clipper ships were first used for trading by American merchants.
The ships were remarkable for the number of
7
they had.
The performance of British tea clippers was particularly affected when there were
8
at sea.
The races
It was in a ship called
9
that the British first competed successfully against the Americans.
Richard Green’s ship arrived two days ahead of its competitor.
Competition increased when additional Chinese trading
10
were established.
Merchants were occasionally in such a hurry that they failed to complete the
11
before leaving China.
At the end of their journey, the ships needed the help of
12
The rewards
The crews were motivated by both
13
and their enthusiasm for the competition.

The crews were motivated by both 13 ____ and their enthusiasm for the competition.$md$, NULL, ARRAY['.*money.*']);

COMMIT;
