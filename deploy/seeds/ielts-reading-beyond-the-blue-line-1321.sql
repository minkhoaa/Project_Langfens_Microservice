BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-beyond-the-blue-line-1321'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-beyond-the-blue-line-1321';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-beyond-the-blue-line-1321';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-beyond-the-blue-line-1321';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('433ae0bb-2f09-5f65-b018-f6ce694c2ada', 'ielts-reading-beyond-the-blue-line-1321', $t$Beyond the blue line$t$, $md$## Beyond the blue line

Nguồn:
- Test: https://mini-ielts.com/1321/reading/beyond-the-blue-line
- Solution: https://mini-ielts.com/1321/view-solution/reading/beyond-the-blue-line$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('e5c7a5c5-7f20-576c-a4e3-7896577fef2a', '433ae0bb-2f09-5f65-b018-f6ce694c2ada', 1, $t$Reading — Beyond the blue line$t$, $md$Read the passage and answer questions **1–14**.

### Passage: Beyond the blue line

A

Much of the thrill of venturing to the far side of the world rests on the romance of difference. So one feels a certain sympathy for Captain James Cook on the day in 1778 that he “discovered” Hawaii. Then on his third expedition to the Pacific, the British navigator had explored scores of islands across the breadth of the sea, from lush New Zealand to the lonely wastes of Easter Island. This latest voyage had taken him thousands of miles north from the Society Islands to an archipelago so remote that even the old Polynesians back on Tahiti knew nothing about it. Imagine Cook’s surprise, then, when the natives of Hawaii came paddling out in their canoes and greeted him in a familiar tongue, one he had heard on virtually every mote of inhabited land he had visited. Marveling at the ubiquity of this Pacific language and culture, he later wondered in his journal: “How shall we account for this Nation spreading itself so far over this vast ocean?”

B

That question, and others that flow from it has tantalized inquiring minds for centuries: Who were these amazing seafarers? Where did they come from, starting more than 3,000 years ago? And how could a Neolithic people with simple canoes and no navigation gear manage to find, let alone colonize, hundreds of far-flung island specks scattered across an ocean that spans nearly a third of the globe? Answers have been slow in coming. But now a startling archaeological find on the island of Éfaté, in the Pacific nation of Vanuatu, has revealed an ancient seafaring people, the distant ancestors of today’s Polynesians, taking their first steps into the unknown. The discoveries there have also opened a window into the shadowy world of those early voyagers.

C

“What we have is a first- or second-generation site containing the graves of some of the Pacific’s first explorers,” says Spriggs, professor of archaeology at the Australian National University and co-leader of an international team excavating the site. It came to light only by luck. A backhoe operator, digging up topsoil on the grounds of a derelict coconut plantation, scraped open a grave – the first of dozens in a burial ground some 3,000 years old. It is the oldest cemetery ever found in the Pacific islands, and it harbors the bones of an ancient people archaeologists call the Lapita, a label that derives from a beach in New Caledonia where a landmark cache of their pottery was found in the 1950s.

D

They were daring blue-water adventurers who roved the sea not just as explorers but also as pioneers, bringing along everything they would need to build new lives – their families and livestock, taro seedlings and stone tools. Within the span of a few centuries, the Lapita stretched the boundaries of their world from the jungle-clad volcanoes of Papua New Guinea to the loneliest coral outliers of Tonga, at least 2,000 miles eastward in the Pacific. Along the way they explored millions of square miles of an unknown sea, discovering and colonizing scores of tropical islands never before seen by human eyes: Vanuatu, New Caledonia, Fiji, Samoa.

It was their descendants, centuries later, who became the great Polynesian navigators we all tend to think of: the Tahitians and Hawaiians, the New Zealand Maori, and the curious people who erected those statues on Easter Island. But it was the Lapita who laid the foundation – who bequeathed to the island the language, customs, and cultures that their more famous descendants carried around the Pacific.

E

While the Lapita left a glorious legacy, they also left precious few clues about themselves. A particularly intriguing clue comes from chemical tests on the teeth of several skeletons. Then as now, the food and water you consume as a child deposits oxygen, carbon, strontium, and other elements in your still-forming adult teeth. The isotope signatures of these elements vary subtly from place to place, so that if you grow up in, say, Buffalo, New York, then spend your adult life in California, tests on the isotopes in your teeth will always reveal your eastern roots.

Isotope analysis indicates that several of the Lapita buried on Éfaté didn’t spend their childhoods here but came from somewhere else. And while isotopes can’t pinpoint their precise island of origin, this much is clear: At some point in their lives, these people left the villages of their birth and made a voyage by seagoing canoe, never to return. DNA teased from these ancient bones may also help answer one of the most puzzling questions in Pacific anthropology: Did all Pacific islanders spring from one source or many? Was there only one outward migration from a single point in Asia, or several from different points? “This represents the best opportunity we’ve had yet,” says Spriggs, “to find out who the Lapita actually were, where they came from, and who their closest descendants are today.”

F

There is one stubborn question for which archaeology has yet to provide any answers: How did the Lapita accomplish the ancient equivalent of a moon landing, many times over? No one has found one of their canoes or any rigging, which could reveal how the canoes were sailed. Nor do the oral histories and traditions of later Polynesians offer any insights.

“All we can say for certain is that the Lapita had canoes that were capable of ocean voyages, and they had the ability to sail them,” says Geoff Irwin, a professor of archaeology at the University of Auckland and an avid yachtsman. Those sailing skills, he says, were developed and passed down over thousands of years by earlier mariners who worked their way through the archipelagoes of the western Pacific making short crossings to islands within sight of each other. The real adventure didn’t begin, however, until their Lapita descendants neared the end of the Solomons chain, for this was the edge of the world. The nearest landfall, the Santa Cruz Islands, is almost 230 miles away, and for at least 150 of those miles, the Lapita sailors would have been out of sight of land, with empty horizons on every side.

G

The Lapita’s thrust into the Pacific was eastward, against the prevailing trade winds, Irwin notes. Those nagging headwinds, he argues, may have been the key to their success. “They could sail out for days into the unknown and reconnoiter, secure in the knowledge that if they didn’t find anything, they could turn about and catch a swift ride home on the trade winds. It’s what made the whole thing work.” Once out there, skilled seafarers would detect abundant leads to follow to land: seabirds and turtles, coconuts and twigs carried out to sea by the tides and the afternoon pileup of clouds on the horizon that often betokens an island in the distance.

All this presupposes one essential detail, says Atholl Anderson, professor of prehistory at the Australian National University and, like Irwin, a keen yachtsman: that the Lapita had mastered the advanced art of tacking into the wind. “And there’s no proof that they could do any such thing,” Anderson says. “There has been this assumption that they must have done so, and people have built canoes to re-create those early voyages based on that assumption. But nobody has any idea what their canoes looked like or how they were rigged.”

H

However they did it, the Lapita spread themselves a third of the way across the Pacific, then called it quits for reasons known only to them. Ahead lay the vast emptiness of the central Pacific, and perhaps they were too thinly stretched to venture farther. They probably never numbered more than a few thousand in total, and in their rapid migration eastward they encountered hundreds of islands – more than 300 in Fiji alone. Supplied with such an embarrassment of riches, they could settle down and enjoy what for a time was Earth’s last Edens.

I

Rather than give all the credit to human skill and daring, Anderson invokes the winds of change. El Niño, the same climate disruption that affects the Pacific today, may have helped scatter the first settlers to the ends of the ocean, Anderson suggests. Climate data obtained from slow-growing corals around the Pacific and from lake-bed sediments in the Andes of South America point to a series of unusually frequent El Niño around the time of the Lapita expansion, and again between 1,600 and 1,200 years ago, when the second wave of pioneer navigators made their voyages farther east, to the remotest corners of the Pacific. By reversing the regular east-to-west flow of the trade winds for weeks at a time, these “super El Niño” might have sped the Pacific’s ancient mariners on long, unplanned voyages could have been key to launching Polynesians across the wide expanse of open water between Tonga, where the Lapita stopped, and the distant archipelagoes of eastern Polynesia. “Once they crossed that gap, they could island-hop throughout the region, and from the Marquesas, it’s mostly downwind to Hawaii,” Anderson says. It took another 400 years for mariners to reach Easter Island, which lies in the opposite direction – normally upwind. “Once again this was during a period of frequent El Niño activity.”$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('522b9391-878e-5be4-856d-f1d3f0c39af3', 'e5c7a5c5-7f20-576c-a4e3-7896577fef2a', 1, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 1

Questions 1-5
Questions 1-5
Complete the summary with the list of words
A-L
below
Write the correct letter
A-L
in boxes
1-5
on your answer sheet.
The question, arisen from Captain Cook’s expedition to Hawaii, and others derived from it, has fascinated researchers for a long time. However, a surprising archaeological find on Éfaté began to provide valuable information about the
1
. On the excavating site, a
2
. Containing
3
of Lapita was uncovered. Later on, various researches and tests have been done to study the ancient people – Lapita and their
4
. How could they manage to spread themselves so far over the vast ocean? All that is certain is that they were good at canoeing. And perhaps they could take well advantage of the trade wind. But there is no
5
of it.
A
bones
B
co-leader
C
descendents
D
international team
E
inquiring minds
F
proof
G
ancestors
H
early seafarers
I
pottery
J
assumption
K
horizons
L
grave

The question, arisen from Captain Cook’s expedition to Hawaii, and others derived from it, has fascinated researchers for a long time. However, a surprising archaeological find on Éfaté began to provide valuable information about the 1 ____ . On the excavating site, a 2 ____ . Containing 3 ____ of Lapita was uncovered. Later on, various researches and tests have been done to study the ancient people – Lapita and their 4 ____ . How could they manage to spread themselves so far over the vast ocean? All that is certain is that they were good at canoeing. And perhaps they could take well advantage of the trade wind. But there is no 5 ____ of it.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7681b180-f692-56a5-9230-5bbc7ff7622b', '522b9391-878e-5be4-856d-f1d3f0c39af3', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d83feecf-736d-5416-ae91-ef727d13abae', '522b9391-878e-5be4-856d-f1d3f0c39af3', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f535b0d8-fb73-58d5-980c-d1a64ea96fac', '522b9391-878e-5be4-856d-f1d3f0c39af3', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('45fe2ea1-6ea3-526b-a1bd-86a04e5b5629', '522b9391-878e-5be4-856d-f1d3f0c39af3', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4b513273-e56e-508b-a290-51dc08c1d557', '522b9391-878e-5be4-856d-f1d3f0c39af3', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('28680015-49cb-5323-88de-2f045bb6428c', '522b9391-878e-5be4-856d-f1d3f0c39af3', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cfc6cae0-f522-5161-9a83-27d46b0e9a88', '522b9391-878e-5be4-856d-f1d3f0c39af3', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a7c887af-59c8-5720-b355-14436d2dcb4f', '522b9391-878e-5be4-856d-f1d3f0c39af3', 8, $md$H$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fbce4251-85e8-5cf9-a933-f4b747573a06', '522b9391-878e-5be4-856d-f1d3f0c39af3', 9, $md$I$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('aa3455f3-97fd-5131-ab95-1e5d5176d786', '522b9391-878e-5be4-856d-f1d3f0c39af3', 10, $md$J$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('385fb51a-5cd7-530f-9f78-50383ad07b7d', '522b9391-878e-5be4-856d-f1d3f0c39af3', 11, $md$K$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('47f8469b-b8c3-5247-b3bb-17c0b0c283ff', '522b9391-878e-5be4-856d-f1d3f0c39af3', 12, $md$L$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('ab9f1e93-ab5c-58a0-99cb-a97158e7c47e', 'e5c7a5c5-7f20-576c-a4e3-7896577fef2a', 2, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 2

Questions 1-5
Questions 1-5
Complete the summary with the list of words
A-L
below
Write the correct letter
A-L
in boxes
1-5
on your answer sheet.
The question, arisen from Captain Cook’s expedition to Hawaii, and others derived from it, has fascinated researchers for a long time. However, a surprising archaeological find on Éfaté began to provide valuable information about the
1
. On the excavating site, a
2
. Containing
3
of Lapita was uncovered. Later on, various researches and tests have been done to study the ancient people – Lapita and their
4
. How could they manage to spread themselves so far over the vast ocean? All that is certain is that they were good at canoeing. And perhaps they could take well advantage of the trade wind. But there is no
5
of it.
A
bones
B
co-leader
C
descendents
D
international team
E
inquiring minds
F
proof
G
ancestors
H
early seafarers
I
pottery
J
assumption
K
horizons
L
grave

The question, arisen from Captain Cook’s expedition to Hawaii, and others derived from it, has fascinated researchers for a long time. However, a surprising archaeological find on Éfaté began to provide valuable information about the 1 ____ . On the excavating site, a 2 ____ . Containing 3 ____ of Lapita was uncovered. Later on, various researches and tests have been done to study the ancient people – Lapita and their 4 ____ . How could they manage to spread themselves so far over the vast ocean? All that is certain is that they were good at canoeing. And perhaps they could take well advantage of the trade wind. But there is no 5 ____ of it.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5ed64c32-ee96-59ed-af2d-e61c67645d12', 'ab9f1e93-ab5c-58a0-99cb-a97158e7c47e', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8de3f743-8469-5c6a-b1d6-94aa41ad177f', 'ab9f1e93-ab5c-58a0-99cb-a97158e7c47e', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a57c9434-592c-58f2-a8f1-5ecf9b99e1af', 'ab9f1e93-ab5c-58a0-99cb-a97158e7c47e', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ee085e08-b28d-57e3-b6a9-32adc5a2906f', 'ab9f1e93-ab5c-58a0-99cb-a97158e7c47e', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ce537968-38e1-551d-bf7f-73b43d2cfc32', 'ab9f1e93-ab5c-58a0-99cb-a97158e7c47e', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d28446d5-3a3b-55cc-a378-68f5dbd27e06', 'ab9f1e93-ab5c-58a0-99cb-a97158e7c47e', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3a611328-2c69-5789-afcc-5b7e0b052535', 'ab9f1e93-ab5c-58a0-99cb-a97158e7c47e', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2ed773d9-7f3a-5554-92b3-3953b51eeddf', 'ab9f1e93-ab5c-58a0-99cb-a97158e7c47e', 8, $md$H$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('863b6029-8dd1-5fbb-b53e-0567cbbf3af3', 'ab9f1e93-ab5c-58a0-99cb-a97158e7c47e', 9, $md$I$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b3cde2db-9ba3-5fc2-b9c8-930dd1f4f453', 'ab9f1e93-ab5c-58a0-99cb-a97158e7c47e', 10, $md$J$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5fc364fe-e29f-5ebf-92d8-946230235e2a', 'ab9f1e93-ab5c-58a0-99cb-a97158e7c47e', 11, $md$K$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e07b7056-fe54-5b42-b901-456037cbd51e', 'ab9f1e93-ab5c-58a0-99cb-a97158e7c47e', 12, $md$L$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('f6a039cf-3bf4-5ef3-9f4f-a60127f675dd', 'e5c7a5c5-7f20-576c-a4e3-7896577fef2a', 3, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 3

Questions 1-5
Questions 1-5
Complete the summary with the list of words
A-L
below
Write the correct letter
A-L
in boxes
1-5
on your answer sheet.
The question, arisen from Captain Cook’s expedition to Hawaii, and others derived from it, has fascinated researchers for a long time. However, a surprising archaeological find on Éfaté began to provide valuable information about the
1
. On the excavating site, a
2
. Containing
3
of Lapita was uncovered. Later on, various researches and tests have been done to study the ancient people – Lapita and their
4
. How could they manage to spread themselves so far over the vast ocean? All that is certain is that they were good at canoeing. And perhaps they could take well advantage of the trade wind. But there is no
5
of it.
A
bones
B
co-leader
C
descendents
D
international team
E
inquiring minds
F
proof
G
ancestors
H
early seafarers
I
pottery
J
assumption
K
horizons
L
grave

The question, arisen from Captain Cook’s expedition to Hawaii, and others derived from it, has fascinated researchers for a long time. However, a surprising archaeological find on Éfaté began to provide valuable information about the 1 ____ . On the excavating site, a 2 ____ . Containing 3 ____ of Lapita was uncovered. Later on, various researches and tests have been done to study the ancient people – Lapita and their 4 ____ . How could they manage to spread themselves so far over the vast ocean? All that is certain is that they were good at canoeing. And perhaps they could take well advantage of the trade wind. But there is no 5 ____ of it.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fde50f6c-2a4b-5a6e-bbed-220f33432b8f', 'f6a039cf-3bf4-5ef3-9f4f-a60127f675dd', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('be1fafe5-3d79-586e-b58b-adbddacde800', 'f6a039cf-3bf4-5ef3-9f4f-a60127f675dd', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7dda32b6-8828-5412-8e28-6599c14a965e', 'f6a039cf-3bf4-5ef3-9f4f-a60127f675dd', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c9560a69-4d62-5fd6-9f37-f4d93a4345e6', 'f6a039cf-3bf4-5ef3-9f4f-a60127f675dd', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bbfc7347-3485-5629-847d-934568581f30', 'f6a039cf-3bf4-5ef3-9f4f-a60127f675dd', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('25ba4bca-9787-5718-b8ff-0fe92e7c5aa2', 'f6a039cf-3bf4-5ef3-9f4f-a60127f675dd', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('99e8cfa0-a66f-5a02-a8d3-02c0a06eaabf', 'f6a039cf-3bf4-5ef3-9f4f-a60127f675dd', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('490a5b07-59ba-5bd7-b52b-d8cfbeec1b8f', 'f6a039cf-3bf4-5ef3-9f4f-a60127f675dd', 8, $md$H$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d306a3f7-56e6-5d31-a78e-0431e6eb6103', 'f6a039cf-3bf4-5ef3-9f4f-a60127f675dd', 9, $md$I$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('35b1577f-7039-59c7-b734-08dc95dbb241', 'f6a039cf-3bf4-5ef3-9f4f-a60127f675dd', 10, $md$J$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b903cc82-be49-55f9-b609-8f9b6a57c455', 'f6a039cf-3bf4-5ef3-9f4f-a60127f675dd', 11, $md$K$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d209f372-88d2-55c5-aa25-dc420b3a1767', 'f6a039cf-3bf4-5ef3-9f4f-a60127f675dd', 12, $md$L$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('c878e224-c727-5cd1-9ff4-8a8dbf9ccc89', 'e5c7a5c5-7f20-576c-a4e3-7896577fef2a', 4, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 4

Questions 1-5
Questions 1-5
Complete the summary with the list of words
A-L
below
Write the correct letter
A-L
in boxes
1-5
on your answer sheet.
The question, arisen from Captain Cook’s expedition to Hawaii, and others derived from it, has fascinated researchers for a long time. However, a surprising archaeological find on Éfaté began to provide valuable information about the
1
. On the excavating site, a
2
. Containing
3
of Lapita was uncovered. Later on, various researches and tests have been done to study the ancient people – Lapita and their
4
. How could they manage to spread themselves so far over the vast ocean? All that is certain is that they were good at canoeing. And perhaps they could take well advantage of the trade wind. But there is no
5
of it.
A
bones
B
co-leader
C
descendents
D
international team
E
inquiring minds
F
proof
G
ancestors
H
early seafarers
I
pottery
J
assumption
K
horizons
L
grave

The question, arisen from Captain Cook’s expedition to Hawaii, and others derived from it, has fascinated researchers for a long time. However, a surprising archaeological find on Éfaté began to provide valuable information about the 1 ____ . On the excavating site, a 2 ____ . Containing 3 ____ of Lapita was uncovered. Later on, various researches and tests have been done to study the ancient people – Lapita and their 4 ____ . How could they manage to spread themselves so far over the vast ocean? All that is certain is that they were good at canoeing. And perhaps they could take well advantage of the trade wind. But there is no 5 ____ of it.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9f2101e8-c7f2-5856-a7ff-2d6886157dc2', 'c878e224-c727-5cd1-9ff4-8a8dbf9ccc89', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('96089d97-d3b1-5f26-88df-478ccfb8cb51', 'c878e224-c727-5cd1-9ff4-8a8dbf9ccc89', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c266feb0-617f-536d-95b3-7658f8d528f5', 'c878e224-c727-5cd1-9ff4-8a8dbf9ccc89', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('85ef7f9f-ec3a-5d6c-8ebd-823e6ed02623', 'c878e224-c727-5cd1-9ff4-8a8dbf9ccc89', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3d5ed9ce-7108-5163-bfd2-0d3e1dc5d716', 'c878e224-c727-5cd1-9ff4-8a8dbf9ccc89', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('201ec504-f031-5ae6-9fe3-33b606aa68d6', 'c878e224-c727-5cd1-9ff4-8a8dbf9ccc89', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a5b473fd-f37b-5967-a82b-11bffddc6424', 'c878e224-c727-5cd1-9ff4-8a8dbf9ccc89', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7c4b8f3d-0297-53c1-ad91-0c9f64a1bf8e', 'c878e224-c727-5cd1-9ff4-8a8dbf9ccc89', 8, $md$H$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8d48fb37-6730-5d91-b53c-71c93a37a448', 'c878e224-c727-5cd1-9ff4-8a8dbf9ccc89', 9, $md$I$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7171b6ed-1d88-59d6-aef5-30e116e4b59a', 'c878e224-c727-5cd1-9ff4-8a8dbf9ccc89', 10, $md$J$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('36f9ea52-b4dc-5c58-aee4-9e4ab929e797', 'c878e224-c727-5cd1-9ff4-8a8dbf9ccc89', 11, $md$K$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f1b9af8f-115c-54ca-a379-68f5cc52b7b2', 'c878e224-c727-5cd1-9ff4-8a8dbf9ccc89', 12, $md$L$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('77c83aff-3670-5904-80c4-3dc5161389b2', 'e5c7a5c5-7f20-576c-a4e3-7896577fef2a', 5, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 5

Questions 1-5
Questions 1-5
Complete the summary with the list of words
A-L
below
Write the correct letter
A-L
in boxes
1-5
on your answer sheet.
The question, arisen from Captain Cook’s expedition to Hawaii, and others derived from it, has fascinated researchers for a long time. However, a surprising archaeological find on Éfaté began to provide valuable information about the
1
. On the excavating site, a
2
. Containing
3
of Lapita was uncovered. Later on, various researches and tests have been done to study the ancient people – Lapita and their
4
. How could they manage to spread themselves so far over the vast ocean? All that is certain is that they were good at canoeing. And perhaps they could take well advantage of the trade wind. But there is no
5
of it.
A
bones
B
co-leader
C
descendents
D
international team
E
inquiring minds
F
proof
G
ancestors
H
early seafarers
I
pottery
J
assumption
K
horizons
L
grave

The question, arisen from Captain Cook’s expedition to Hawaii, and others derived from it, has fascinated researchers for a long time. However, a surprising archaeological find on Éfaté began to provide valuable information about the 1 ____ . On the excavating site, a 2 ____ . Containing 3 ____ of Lapita was uncovered. Later on, various researches and tests have been done to study the ancient people – Lapita and their 4 ____ . How could they manage to spread themselves so far over the vast ocean? All that is certain is that they were good at canoeing. And perhaps they could take well advantage of the trade wind. But there is no 5 ____ of it.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5eef00b5-caaf-5581-9a1e-718492e76600', '77c83aff-3670-5904-80c4-3dc5161389b2', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1d3042d9-f116-56eb-bec0-0f9ee9b9bd5a', '77c83aff-3670-5904-80c4-3dc5161389b2', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e1334e5e-6a1f-5eb7-b911-9aa09b7b76a5', '77c83aff-3670-5904-80c4-3dc5161389b2', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9770a91d-4d0d-50a0-83c5-f22f6d67a9a3', '77c83aff-3670-5904-80c4-3dc5161389b2', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c0fe3cc3-491e-5689-8ff2-a1543b4445e5', '77c83aff-3670-5904-80c4-3dc5161389b2', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0670b1b8-e5b0-539c-afa0-f46356ff0638', '77c83aff-3670-5904-80c4-3dc5161389b2', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2c992ade-1b27-5892-bec9-d6d2ad45ffbc', '77c83aff-3670-5904-80c4-3dc5161389b2', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('eb1352dd-02d7-5ace-87a6-7bcd39b1bca1', '77c83aff-3670-5904-80c4-3dc5161389b2', 8, $md$H$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('138a4133-24da-5b8a-8787-d1e5fd8f652c', '77c83aff-3670-5904-80c4-3dc5161389b2', 9, $md$I$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b94e67dc-c45f-5cb2-9781-3ec6543352eb', '77c83aff-3670-5904-80c4-3dc5161389b2', 10, $md$J$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9358cb53-2825-5e53-a0fc-fde049b2a895', '77c83aff-3670-5904-80c4-3dc5161389b2', 11, $md$K$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e6e2c3b3-9c90-5f07-ade5-21e91c4472c4', '77c83aff-3670-5904-80c4-3dc5161389b2', 12, $md$L$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('ebf7bc04-5b6b-568c-a257-084f8c16648d', 'e5c7a5c5-7f20-576c-a4e3-7896577fef2a', 6, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 6

Questions 6-9
Questions 6-9
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
6-9
on your answer sheet.
6.
The chemical tests indicate that
A
the elements in one’s teeth varied from childhood to adulthood.
B
the isotope signatures of the elements remain the same in different places.
C
the result of the study is not fascinating.
D
these chemicals can’t conceal one’s origin.
7.
The isotope analysis from the Lapita
A
exactly locates their birth island.
B
reveals that the Lapita found the new place via straits.
C
helps researchers to find out answers about the islanders.
D
leaves more new questions for anthropologists to answer.
8.
According to paragraph F, the offspring of Lapita
A
were capable of voyages to land that is not accessible to view.
B
were able to have the farthest voyage of 230 miles.
C
worked their way through the archipelagoes of the western Pacific.
D
fully explored the horizons.
9.
Once out exploring the sea, the sailors
A
always found the trade winds unsuitable for sailing.
B
could return home with various clues.
C
sometimes would overshoot their home port and sail off into eternity.
D
would sail in one direction.

Choose the correct letter, A , B , C or D .$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('1c09ba63-d50f-59fe-93be-a9b9eb8a098d', 'e5c7a5c5-7f20-576c-a4e3-7896577fef2a', 7, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 7

Questions 6-9
Questions 6-9
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
6-9
on your answer sheet.
6.
The chemical tests indicate that
A
the elements in one’s teeth varied from childhood to adulthood.
B
the isotope signatures of the elements remain the same in different places.
C
the result of the study is not fascinating.
D
these chemicals can’t conceal one’s origin.
7.
The isotope analysis from the Lapita
A
exactly locates their birth island.
B
reveals that the Lapita found the new place via straits.
C
helps researchers to find out answers about the islanders.
D
leaves more new questions for anthropologists to answer.
8.
According to paragraph F, the offspring of Lapita
A
were capable of voyages to land that is not accessible to view.
B
were able to have the farthest voyage of 230 miles.
C
worked their way through the archipelagoes of the western Pacific.
D
fully explored the horizons.
9.
Once out exploring the sea, the sailors
A
always found the trade winds unsuitable for sailing.
B
could return home with various clues.
C
sometimes would overshoot their home port and sail off into eternity.
D
would sail in one direction.

Choose the correct letter, A , B , C or D .$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('df63eebc-f841-58cb-9f06-9a8a04e6ab51', 'e5c7a5c5-7f20-576c-a4e3-7896577fef2a', 8, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 8

Questions 6-9
Questions 6-9
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
6-9
on your answer sheet.
6.
The chemical tests indicate that
A
the elements in one’s teeth varied from childhood to adulthood.
B
the isotope signatures of the elements remain the same in different places.
C
the result of the study is not fascinating.
D
these chemicals can’t conceal one’s origin.
7.
The isotope analysis from the Lapita
A
exactly locates their birth island.
B
reveals that the Lapita found the new place via straits.
C
helps researchers to find out answers about the islanders.
D
leaves more new questions for anthropologists to answer.
8.
According to paragraph F, the offspring of Lapita
A
were capable of voyages to land that is not accessible to view.
B
were able to have the farthest voyage of 230 miles.
C
worked their way through the archipelagoes of the western Pacific.
D
fully explored the horizons.
9.
Once out exploring the sea, the sailors
A
always found the trade winds unsuitable for sailing.
B
could return home with various clues.
C
sometimes would overshoot their home port and sail off into eternity.
D
would sail in one direction.

Choose the correct letter, A , B , C or D .$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('9c4e2e05-0da7-5aaf-acab-da6534712687', 'e5c7a5c5-7f20-576c-a4e3-7896577fef2a', 9, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 9

Questions 6-9
Questions 6-9
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
6-9
on your answer sheet.
6.
The chemical tests indicate that
A
the elements in one’s teeth varied from childhood to adulthood.
B
the isotope signatures of the elements remain the same in different places.
C
the result of the study is not fascinating.
D
these chemicals can’t conceal one’s origin.
7.
The isotope analysis from the Lapita
A
exactly locates their birth island.
B
reveals that the Lapita found the new place via straits.
C
helps researchers to find out answers about the islanders.
D
leaves more new questions for anthropologists to answer.
8.
According to paragraph F, the offspring of Lapita
A
were capable of voyages to land that is not accessible to view.
B
were able to have the farthest voyage of 230 miles.
C
worked their way through the archipelagoes of the western Pacific.
D
fully explored the horizons.
9.
Once out exploring the sea, the sailors
A
always found the trade winds unsuitable for sailing.
B
could return home with various clues.
C
sometimes would overshoot their home port and sail off into eternity.
D
would sail in one direction.

Choose the correct letter, A , B , C or D .$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('68f5ebdd-378e-5cd0-98a4-2ab2d5fa0c88', 'e5c7a5c5-7f20-576c-a4e3-7896577fef2a', 10, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 10

Questions 10-14
Questions 10-14
Do the following statements agree with the information given in Reading Passage?
In boxes
10-14
on your answer sheet, write
TRUE
if the statement is true
FALSE
if the statement is false
NOT GIVEN
if the information is not given in the passage
10
The Lapita could canoe in the prevailing wind.
11
It was difficult for the sailors to find ways back, once they were out.
12
The reason why the Lapita stopped canoeing farther is still unknown.
13
The majority of the Lapita dwelled on Fiji.
14
The navigators could take advantage of El Nino during their forth voyages

10 ____ The Lapita could canoe in the prevailing wind.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('eedbe01a-f0db-51f8-89f3-6ffa732304c6', '68f5ebdd-378e-5cd0-98a4-2ab2d5fa0c88', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('69d56618-aab1-5d23-a93b-c86245f2fdca', '68f5ebdd-378e-5cd0-98a4-2ab2d5fa0c88', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b2570176-9b04-5cc1-a37f-70a0b1ce8596', '68f5ebdd-378e-5cd0-98a4-2ab2d5fa0c88', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('15604f60-e6e9-57ab-8cde-5c1ec2cc830b', 'e5c7a5c5-7f20-576c-a4e3-7896577fef2a', 11, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 11

Questions 10-14
Questions 10-14
Do the following statements agree with the information given in Reading Passage?
In boxes
10-14
on your answer sheet, write
TRUE
if the statement is true
FALSE
if the statement is false
NOT GIVEN
if the information is not given in the passage
10
The Lapita could canoe in the prevailing wind.
11
It was difficult for the sailors to find ways back, once they were out.
12
The reason why the Lapita stopped canoeing farther is still unknown.
13
The majority of the Lapita dwelled on Fiji.
14
The navigators could take advantage of El Nino during their forth voyages

11 ____ It was difficult for the sailors to find ways back, once they were out.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8140927d-4039-5f47-b9d1-9989fb5cc384', '15604f60-e6e9-57ab-8cde-5c1ec2cc830b', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('54b24529-4760-5c39-925c-534dad9ac4eb', '15604f60-e6e9-57ab-8cde-5c1ec2cc830b', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('df9414cf-6483-56a0-bfdf-f0d26364e4f1', '15604f60-e6e9-57ab-8cde-5c1ec2cc830b', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('e25e02c2-371f-59ef-bcfb-04b86efacc13', 'e5c7a5c5-7f20-576c-a4e3-7896577fef2a', 12, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 12

Questions 10-14
Questions 10-14
Do the following statements agree with the information given in Reading Passage?
In boxes
10-14
on your answer sheet, write
TRUE
if the statement is true
FALSE
if the statement is false
NOT GIVEN
if the information is not given in the passage
10
The Lapita could canoe in the prevailing wind.
11
It was difficult for the sailors to find ways back, once they were out.
12
The reason why the Lapita stopped canoeing farther is still unknown.
13
The majority of the Lapita dwelled on Fiji.
14
The navigators could take advantage of El Nino during their forth voyages

12 ____ The reason why the Lapita stopped canoeing farther is still unknown.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('55c04869-7d4c-5874-96b9-31e63b5ac67e', 'e25e02c2-371f-59ef-bcfb-04b86efacc13', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('13c3943f-cfe5-56fb-8ec4-d7fa46697118', 'e25e02c2-371f-59ef-bcfb-04b86efacc13', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('eb739e20-d3e8-50cd-8079-e481985deb91', 'e25e02c2-371f-59ef-bcfb-04b86efacc13', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('63204992-7518-53af-80d5-749ae6eebfde', 'e5c7a5c5-7f20-576c-a4e3-7896577fef2a', 13, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 13

Questions 10-14
Questions 10-14
Do the following statements agree with the information given in Reading Passage?
In boxes
10-14
on your answer sheet, write
TRUE
if the statement is true
FALSE
if the statement is false
NOT GIVEN
if the information is not given in the passage
10
The Lapita could canoe in the prevailing wind.
11
It was difficult for the sailors to find ways back, once they were out.
12
The reason why the Lapita stopped canoeing farther is still unknown.
13
The majority of the Lapita dwelled on Fiji.
14
The navigators could take advantage of El Nino during their forth voyages

13 ____ The majority of the Lapita dwelled on Fiji.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b24e8990-c3ac-55c1-b6f8-49e2e062ada3', '63204992-7518-53af-80d5-749ae6eebfde', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('35e2b04c-26c3-5b33-991e-a33c2b48979b', '63204992-7518-53af-80d5-749ae6eebfde', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('82a2a5f3-9c23-54f3-a039-96e06e52ce62', '63204992-7518-53af-80d5-749ae6eebfde', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('dea728c3-2057-55a0-82c0-1aecb6a8fd6c', 'e5c7a5c5-7f20-576c-a4e3-7896577fef2a', 14, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 14

Questions 10-14
Questions 10-14
Do the following statements agree with the information given in Reading Passage?
In boxes
10-14
on your answer sheet, write
TRUE
if the statement is true
FALSE
if the statement is false
NOT GIVEN
if the information is not given in the passage
10
The Lapita could canoe in the prevailing wind.
11
It was difficult for the sailors to find ways back, once they were out.
12
The reason why the Lapita stopped canoeing farther is still unknown.
13
The majority of the Lapita dwelled on Fiji.
14
The navigators could take advantage of El Nino during their forth voyages

14 ____ The navigators could take advantage of El Nino during their forth voyages$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2f628d68-f0ed-549f-8784-8d46a102456f', 'dea728c3-2057-55a0-82c0-1aecb6a8fd6c', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f2a518cf-099e-5080-b5d7-10a03f0f0b8d', 'dea728c3-2057-55a0-82c0-1aecb6a8fd6c', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c5773ad5-2d1d-52f8-b6bb-14a2558e3668', 'dea728c3-2057-55a0-82c0-1aecb6a8fd6c', 3, $md$NOT GIVEN$md$, true);

COMMIT;
