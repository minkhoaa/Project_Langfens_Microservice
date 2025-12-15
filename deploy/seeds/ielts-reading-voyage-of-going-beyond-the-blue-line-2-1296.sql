BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-voyage-of-going-beyond-the-blue-line-2-1296'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-voyage-of-going-beyond-the-blue-line-2-1296';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-voyage-of-going-beyond-the-blue-line-2-1296';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-voyage-of-going-beyond-the-blue-line-2-1296';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('92e9b32f-7403-5ed7-9b16-4ed98fdb48ce', 'ielts-reading-voyage-of-going-beyond-the-blue-line-2-1296', $t$Voyage of going: beyond the blue line 2$t$, $md$## Voyage of going: beyond the blue line 2

Nguồn:
- Test: https://mini-ielts.com/1296/reading/voyage-of-going-beyond-the-blue-line-2
- Solution: https://mini-ielts.com/1296/view-solution/reading/voyage-of-going-beyond-the-blue-line-2$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('cbf85e2a-6437-5875-bb47-95a74bde2d36', '92e9b32f-7403-5ed7-9b16-4ed98fdb48ce', 1, $t$Reading — Voyage of going: beyond the blue line 2$t$, $md$Read the passage and answer questions **1–13**.

### Passage: Voyage of going: beyond the blue line 2

A . One feels a certain sympathy for Captain James Cook on the day in 1778 that he “discovered” Hawaii. Then on his third expedition to the Pacific, the British navigator had explored scores of islands across the breadth of the sea, from lush New Zealand to the lonely wastes of Easter Island This latest voyage had taken him thousands of miles north from the Society Islands to an archipelago so remote that even the ok! Polynesians back on Tahiti knew nothing about it. Imagine Cook’s surprise, then, when the natives of Hawaii came paddling out in their canoes and greeted him in a familiar tongue, one he had heard on virtually every mote of inhabited land he had visited Marveling at the ubiquity of this Pacific language and culture, he later wondered in his journal: “How shall we account for this Nation spreading it self so far over this Vast ocean?”

B . Answers have been slow in coming. But now a startling archaeological find on the island of Efate, in the Pacific nation of Vanuatu, has revealed an ancient seafaring people, the distant ancestors of today’s Polynesians, taking their first steps into the unknown. The discoveries there have also opened a window into the shadowy work! of those early voyagers. At the same time, other pieces of this human puzzle are turning up in unlikely places. Climate data gleaned from slow-growing corals around the Pacific and from sediments in alpine lakes in South America may help explain how, more than a thousand years later, a second wave of seafarers beat their way across the entire Pacific.

C . What we have is a first-or second-generation site containing the graves of some of the Pacific’s first explorers,” says Spriggs, professor of archaeology at the Australian National University and co-leader of an international team excavating the site. It came to light only by luck A backhoe operator, digging up topsoil on the grounds of a derelict coconut plantation, scraped open a grave— the first of dozens in a burial ground some 3,000 years old It is the oldest cemetery ever found in the Pacific islands, and it harbors the bones of an ancient people archaeologists call the Lapita, a label that derives from a beach in New Caledonia where a landmark cache of their pottery was found in the 1950s. They were daring blue-water adventurers who roved the sea not just as explorers but also as pioneers, bringing everything they would need to build new lives— their families and livestock, taro seedlings and stone tools.

D . Within the span of a few centuries the Lapita stretched the boundaries of their world from the jungle-clad volcanoes of Papua New Guinea to the loneliest coral outliers of Tonga, at least 2,000 miles eastward in the Pacific. Along the way they explored millions of square miles of unknown sea, discovering and colonizing scores of tropical islands never before seen by human eyes: Vanuatu, New Caledonia, Fiji, Samoa.

E . What little is known or surmised about them has been pieced together from fragments of pottery, animal bones, obsidian flakes, and such oblique sources as comparative linguistics and geochemistry. Although their voyages can be traced back to the northern islands of Papua New Guinea, their language variants of which are still spoken across the Pacific came from Taiwan. And their peculiar style of pottery decoration, created by pressing a carved stamp into the clay, probably had its roots in the northern Philippines. With the discovery of the Lapita cemetery on Efate, the volume of data available to researchers has expanded dramatically. The bones of at least 62 individuals have been uncovered so far including old men, young women, even babies—and more skeletons are known to be in the ground. Archaeologists were also thrilled to discover six complete Lapita pots. It’s an important find, Spriggs says, for it conclusively identifies the remains as Lapita. “It would be hard for anyone to argue that these aren’t Lapita when you have human bones enshrined inside what is unmistakably a Lapita urn.”

F . Several lines of evidence also undergird Spriggs’s conclusion that this was a community of pioneers making their first voyages into the remote reaches of Oceania. For one thing, the radiocarbon dating of bones and charcoal places them early in the Lapita expansion. For another, the chemical makeup of the obsidian flakes littering the site indicates that the rock wasn’t local; instead it was imported from a large island in Papua New Guinea’s Bismarck Archipelago, the springboard for the Lapita’s thrust into the Pacific. A particularly intriguing clue comes from chemical tests on the teeth of several skeletons. DNA teased from these ancient bones may also help answer one of the most puzzling questions in Pacific anthropology: Did all Pacific islanders spring from one source or many? Was there only one outward migration from a single point in Asia, or several from different points? “This represents the best opportunity we’ve had yet,” says Spriggs, “to find out who the Lapita actually were, where they came from, and who their best descendants are today.

G . “There is one stubborn question for which archaeology has yet to provide any answers: How did the Lapita accomplish the ancient equivalent of a moon landing, many times over? No one has found one of their canoes or any rigging, which could reveal how the canoes were sailed Nor do the oral histories and traditions of later Polynesians offer any insights, for they segue into myth long before they reach as far back in time as the Lapita.” All we can say for certain is that the Lapita had canoes that were capable of ocean voyages, and they had the ability to sail them,” says Geoff Irwin, a professor of archaeology at the University of Auckland and an avid yachtsman. Those sailing skills, he says, were developed and passed down over thousands of years by earlier mariners who worked their way through the archipelagoes of the western Pacific making short crossings to islands within sight of each other. Reaching Fiji, as they did a century or so later, meant crossing more than 500 miles of ocean, pressing on day after day into the great blue void of the Pacific. What gave them the courage to launch out on such a risky voyage?

H . The Lapita’s thrust into the Pacific was eastward, against the prevailing trade winds, Irwin notes. Those nagging headwinds, he argues, may have been the key to their success. “They could sail out for days into the unknown and reconnoiter, secure in the knowledge that if they didn’t find anything, they could turn about and catch a swift ride home on the trade winds. It’s what made the whole thing work.” Once out there, skilled seafarers would detect abundant leads to follow to land: seabirds and turtles, coconuts and twigs carried out to sea by the tides, and the afternoon pileup of clouds on the horizon that often betokens an island in the distance. Some islands may have broadcast their presence with far less subtlety than a cloud bank. Some of the most violent eruptions anywhere on the planet during the past 10,000 years occurred in Melanesia, which sits nervously in one of the most explosive volcanic regions on Earth. Even less spectacular eruptions would have sent plumes of smoke billowing into the stratosphere and rained ash for hundreds of miles. It’s possible that the Lapita saw these signs of distant islands and later sailed off in their direction, knowing they would find land For returning explorers, successful or not, the geography of their own archipelagoes provided a safety net to keep them from overshooting their home ports and sailing off into eternity.

I . However they did it, the Lapita spread themselves a third of the way across the Pacific, then called it quits for reasons known only to them. Ahead lay the vast emptiness of the central Pacific, and perhaps they were too thinly stretched to venture farther. They probably never numbered more than a few thousand in total, and in their rapid migration eastward they encountered hundreds of islands - more than 300 in Fiji alone. Still, more than a millennium would pass before the Lapita’s descendants, a people we now call the Polynesians, struck out in search of new territory.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('f5776a26-13f6-5c76-9f07-1ec70a0a5fa1', 'cbf85e2a-6437-5875-bb47-95a74bde2d36', 1, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 1

Questions 1-7
Questions 1-7
Do the following statements agree with the information given in
Reading Passage ?
In boxes
1-7
on your answer sheet
,
write
YES
if the statement is true
NO
if the statement is false
NOT GIVEN
if the information is not given in the passage
1
Captain cook once expected the Hawaii might speak another language of people from other pacific islands
2
Captain cook depicted number of cultural aspects of Polynesians in his journal
3
Professor Spriggs and his research team went to the Efate to try to find the site of ancient cemetery
4
The Lapita completed a journey of around 2,000 miles in a period less than a centenary
5
The Lapita were the first inhabitants in many pacific islands
6
The unknown pots discovered in Efate had once been used for cooking
7
The um buried in Efate site was plain as it was without any decoration

1 ____ Captain cook once expected the Hawaii might speak another language of people from other pacific islands$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('68f10844-11ce-5ba6-b0d9-4980efdf96b9', 'f5776a26-13f6-5c76-9f07-1ec70a0a5fa1', 1, $md$YES$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('34e7e608-9b78-5927-82aa-ca4f2c0ed128', 'f5776a26-13f6-5c76-9f07-1ec70a0a5fa1', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('49281b19-bf55-5972-a5e9-a8a5da548e06', 'f5776a26-13f6-5c76-9f07-1ec70a0a5fa1', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('e127806a-413e-518c-b3de-19deba1816eb', 'cbf85e2a-6437-5875-bb47-95a74bde2d36', 2, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 2

Questions 1-7
Questions 1-7
Do the following statements agree with the information given in
Reading Passage ?
In boxes
1-7
on your answer sheet
,
write
YES
if the statement is true
NO
if the statement is false
NOT GIVEN
if the information is not given in the passage
1
Captain cook once expected the Hawaii might speak another language of people from other pacific islands
2
Captain cook depicted number of cultural aspects of Polynesians in his journal
3
Professor Spriggs and his research team went to the Efate to try to find the site of ancient cemetery
4
The Lapita completed a journey of around 2,000 miles in a period less than a centenary
5
The Lapita were the first inhabitants in many pacific islands
6
The unknown pots discovered in Efate had once been used for cooking
7
The um buried in Efate site was plain as it was without any decoration

2 ____ Captain cook depicted number of cultural aspects of Polynesians in his journal$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f179ae94-3605-5bd0-a6bf-5a68c64cc7a1', 'e127806a-413e-518c-b3de-19deba1816eb', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cf6b050b-f7df-580c-b8fd-7867c701452e', 'e127806a-413e-518c-b3de-19deba1816eb', 2, $md$NO$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5c677b88-3a51-50da-be6a-4e23e8c839ef', 'e127806a-413e-518c-b3de-19deba1816eb', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('ab121d46-7ec6-5828-b60f-4ed09598d2ee', 'cbf85e2a-6437-5875-bb47-95a74bde2d36', 3, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 3

Questions 1-7
Questions 1-7
Do the following statements agree with the information given in
Reading Passage ?
In boxes
1-7
on your answer sheet
,
write
YES
if the statement is true
NO
if the statement is false
NOT GIVEN
if the information is not given in the passage
1
Captain cook once expected the Hawaii might speak another language of people from other pacific islands
2
Captain cook depicted number of cultural aspects of Polynesians in his journal
3
Professor Spriggs and his research team went to the Efate to try to find the site of ancient cemetery
4
The Lapita completed a journey of around 2,000 miles in a period less than a centenary
5
The Lapita were the first inhabitants in many pacific islands
6
The unknown pots discovered in Efate had once been used for cooking
7
The um buried in Efate site was plain as it was without any decoration

3 ____ Professor Spriggs and his research team went to the Efate to try to find the site of ancient cemetery$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('efcce766-c272-5dbc-9227-8975f955d91e', 'ab121d46-7ec6-5828-b60f-4ed09598d2ee', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d951a002-44db-5024-bfb0-8bc7725852c6', 'ab121d46-7ec6-5828-b60f-4ed09598d2ee', 2, $md$NO$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5eb7febc-5504-57c1-bb26-dcab797e6d03', 'ab121d46-7ec6-5828-b60f-4ed09598d2ee', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('a205bd22-9cf9-5650-923e-589e7251fdcf', 'cbf85e2a-6437-5875-bb47-95a74bde2d36', 4, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 4

Questions 1-7
Questions 1-7
Do the following statements agree with the information given in
Reading Passage ?
In boxes
1-7
on your answer sheet
,
write
YES
if the statement is true
NO
if the statement is false
NOT GIVEN
if the information is not given in the passage
1
Captain cook once expected the Hawaii might speak another language of people from other pacific islands
2
Captain cook depicted number of cultural aspects of Polynesians in his journal
3
Professor Spriggs and his research team went to the Efate to try to find the site of ancient cemetery
4
The Lapita completed a journey of around 2,000 miles in a period less than a centenary
5
The Lapita were the first inhabitants in many pacific islands
6
The unknown pots discovered in Efate had once been used for cooking
7
The um buried in Efate site was plain as it was without any decoration

4 ____ The Lapita completed a journey of around 2,000 miles in a period less than a centenary$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('61d707b1-b5d1-5a04-b81d-22068c6c3c4d', 'a205bd22-9cf9-5650-923e-589e7251fdcf', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7f87ae27-45c9-5259-97f0-586378f3eff5', 'a205bd22-9cf9-5650-923e-589e7251fdcf', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0b3fdc09-4990-50c7-82c3-e3ab63cd6b27', 'a205bd22-9cf9-5650-923e-589e7251fdcf', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('0cbbe1f4-e057-5967-b3f6-84da0af73834', 'cbf85e2a-6437-5875-bb47-95a74bde2d36', 5, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 5

Questions 1-7
Questions 1-7
Do the following statements agree with the information given in
Reading Passage ?
In boxes
1-7
on your answer sheet
,
write
YES
if the statement is true
NO
if the statement is false
NOT GIVEN
if the information is not given in the passage
1
Captain cook once expected the Hawaii might speak another language of people from other pacific islands
2
Captain cook depicted number of cultural aspects of Polynesians in his journal
3
Professor Spriggs and his research team went to the Efate to try to find the site of ancient cemetery
4
The Lapita completed a journey of around 2,000 miles in a period less than a centenary
5
The Lapita were the first inhabitants in many pacific islands
6
The unknown pots discovered in Efate had once been used for cooking
7
The um buried in Efate site was plain as it was without any decoration

5 ____ The Lapita were the first inhabitants in many pacific islands$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('35d6b436-f359-5542-9a1a-ec4729ebff9b', '0cbbe1f4-e057-5967-b3f6-84da0af73834', 1, $md$YES$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('26d872ba-1ccf-5bf7-a953-504441b6fb54', '0cbbe1f4-e057-5967-b3f6-84da0af73834', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('31cf32db-78f2-50f1-9d8b-f2581ee7aadf', '0cbbe1f4-e057-5967-b3f6-84da0af73834', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('37fc4ca0-d77e-570f-8696-1ba4e4a66560', 'cbf85e2a-6437-5875-bb47-95a74bde2d36', 6, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 6

Questions 1-7
Questions 1-7
Do the following statements agree with the information given in
Reading Passage ?
In boxes
1-7
on your answer sheet
,
write
YES
if the statement is true
NO
if the statement is false
NOT GIVEN
if the information is not given in the passage
1
Captain cook once expected the Hawaii might speak another language of people from other pacific islands
2
Captain cook depicted number of cultural aspects of Polynesians in his journal
3
Professor Spriggs and his research team went to the Efate to try to find the site of ancient cemetery
4
The Lapita completed a journey of around 2,000 miles in a period less than a centenary
5
The Lapita were the first inhabitants in many pacific islands
6
The unknown pots discovered in Efate had once been used for cooking
7
The um buried in Efate site was plain as it was without any decoration

6 ____ The unknown pots discovered in Efate had once been used for cooking$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3900b95b-bd03-567e-a9bc-2f5982b1edda', '37fc4ca0-d77e-570f-8696-1ba4e4a66560', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f7e6b66a-75fc-5b01-8f22-dd4ac9c4b05e', '37fc4ca0-d77e-570f-8696-1ba4e4a66560', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8ad268d4-93e8-5f64-889f-96f421cbf96b', '37fc4ca0-d77e-570f-8696-1ba4e4a66560', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('859b78ff-d9a6-5fbc-a9bb-4287dd21bf9f', 'cbf85e2a-6437-5875-bb47-95a74bde2d36', 7, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 7

Questions 1-7
Questions 1-7
Do the following statements agree with the information given in
Reading Passage ?
In boxes
1-7
on your answer sheet
,
write
YES
if the statement is true
NO
if the statement is false
NOT GIVEN
if the information is not given in the passage
1
Captain cook once expected the Hawaii might speak another language of people from other pacific islands
2
Captain cook depicted number of cultural aspects of Polynesians in his journal
3
Professor Spriggs and his research team went to the Efate to try to find the site of ancient cemetery
4
The Lapita completed a journey of around 2,000 miles in a period less than a centenary
5
The Lapita were the first inhabitants in many pacific islands
6
The unknown pots discovered in Efate had once been used for cooking
7
The um buried in Efate site was plain as it was without any decoration

7 ____ The um buried in Efate site was plain as it was without any decoration$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e480e5de-767e-55b4-b5a8-f744ac374f46', '859b78ff-d9a6-5fbc-a9bb-4287dd21bf9f', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2603d280-2d31-5a2f-9987-04c28f92313a', '859b78ff-d9a6-5fbc-a9bb-4287dd21bf9f', 2, $md$NO$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b91c589f-99c3-5c91-af2b-f85056d2794e', '859b78ff-d9a6-5fbc-a9bb-4287dd21bf9f', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('96caf251-e263-56f4-a004-38b9feb2d044', 'cbf85e2a-6437-5875-bb47-95a74bde2d36', 8, 'SUMMARY_COMPLETION', 'READING', 3, $md$### Question 8

Questions 8 -10
Questions 8 -10
Complete the following summary of the paragraphs of Reading Passage 1,
using
no more than Two words
from the Reading Passage 1 for each answer.
Write your answers in boxes
8-10
on your answer sheet.
Scientific Evident found in Efate site
Tests show the human remains and the charcoal found in the buried um are from the start of the Lapita period. Yet The
8
covering many of the Efate site did not come from that area.
Then examinations carried out on the
9
discovered at Efate site reveal that not everyone buried there was a native living in the area. In fact, DNA could identify the Lapita’s nearest
10
present-days.

Tests show the human remains and the charcoal found in the buried um are from the start of the Lapita period. Yet The 8 ____ covering many of the Efate site did not come from that area.$md$, NULL, ARRAY['.*rock.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('fd85022b-3269-52e3-93b0-d9ab1865d960', 'cbf85e2a-6437-5875-bb47-95a74bde2d36', 9, 'SUMMARY_COMPLETION', 'READING', 3, $md$### Question 9

Questions 8 -10
Questions 8 -10
Complete the following summary of the paragraphs of Reading Passage 1,
using
no more than Two words
from the Reading Passage 1 for each answer.
Write your answers in boxes
8-10
on your answer sheet.
Scientific Evident found in Efate site
Tests show the human remains and the charcoal found in the buried um are from the start of the Lapita period. Yet The
8
covering many of the Efate site did not come from that area.
Then examinations carried out on the
9
discovered at Efate site reveal that not everyone buried there was a native living in the area. In fact, DNA could identify the Lapita’s nearest
10
present-days.

Then examinations carried out on the 9 ____ discovered at Efate site reveal that not everyone buried there was a native living in the area. In fact, DNA could identify the Lapita’s nearest 10 ____ present-days.$md$, NULL, ARRAY['.*teeth.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('a26a3d8d-4e7b-5b0d-8976-99c625df2445', 'cbf85e2a-6437-5875-bb47-95a74bde2d36', 10, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 10

Questions 8 -10
Questions 8 -10
Complete the following summary of the paragraphs of Reading Passage 1,
using
no more than Two words
from the Reading Passage 1 for each answer.
Write your answers in boxes
8-10
on your answer sheet.
Scientific Evident found in Efate site
Tests show the human remains and the charcoal found in the buried um are from the start of the Lapita period. Yet The
8
covering many of the Efate site did not come from that area.
Then examinations carried out on the
9
discovered at Efate site reveal that not everyone buried there was a native living in the area. In fact, DNA could identify the Lapita’s nearest
10
present-days.

Then examinations carried out on the 9 ____ discovered at Efate site reveal that not everyone buried there was a native living in the area. In fact, DNA could identify the Lapita’s nearest 10 ____ present-days.$md$, NULL, ARRAY['.*teeth.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('d310d220-d40f-5579-97a6-76d4bfa52382', 'cbf85e2a-6437-5875-bb47-95a74bde2d36', 11, 'SHORT_ANSWER', 'READING', 4, $md$### Question 11

Questions 11-13
Questions 11-13
Answer the questions below.
Choose
NO MORE THAN THREE WORDS AND/OR A NUMBER
from the passage for each answer.
11
What did the Lapita travel in when they crossed the oceans?
11
12
In Irwins’s view, what would the Latipa have relied on to bring them fast back to the base?
12
13
Which sea creatures would have been an indication to the Lapita of where to find land ?
13

11 What did the Lapita travel in when they crossed the oceans? 11 ____$md$, NULL, ARRAY['.*canoes.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('7ff6ead2-b471-582c-9fb6-55423665cb3a', 'cbf85e2a-6437-5875-bb47-95a74bde2d36', 12, 'SHORT_ANSWER', 'READING', 4, $md$### Question 12

Questions 11-13
Questions 11-13
Answer the questions below.
Choose
NO MORE THAN THREE WORDS AND/OR A NUMBER
from the passage for each answer.
11
What did the Lapita travel in when they crossed the oceans?
11
12
In Irwins’s view, what would the Latipa have relied on to bring them fast back to the base?
12
13
Which sea creatures would have been an indication to the Lapita of where to find land ?
13

12 In Irwins’s view, what would the Latipa have relied on to bring them fast back to the base? 12 ____$md$, NULL, ARRAY['.*trade.*winds.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('fafc0cbd-ec72-5725-9fc7-dd2efd64f53a', 'cbf85e2a-6437-5875-bb47-95a74bde2d36', 13, 'SHORT_ANSWER', 'READING', 4, $md$### Question 13

Questions 11-13
Questions 11-13
Answer the questions below.
Choose
NO MORE THAN THREE WORDS AND/OR A NUMBER
from the passage for each answer.
11
What did the Lapita travel in when they crossed the oceans?
11
12
In Irwins’s view, what would the Latipa have relied on to bring them fast back to the base?
12
13
Which sea creatures would have been an indication to the Lapita of where to find land ?
13

13 Which sea creatures would have been an indication to the Lapita of where to find land ? 13 ____$md$, NULL, ARRAY['.*seabirds.*and.*turtles.*']);

COMMIT;
