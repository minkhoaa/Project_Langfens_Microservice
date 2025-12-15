BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-a-little-known-island-community-comes-in-from-the-cold-1220'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-a-little-known-island-community-comes-in-from-the-cold-1220';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-a-little-known-island-community-comes-in-from-the-cold-1220';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-a-little-known-island-community-comes-in-from-the-cold-1220';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('16bc62cd-6b6f-528c-8b50-b3158e30efea', 'ielts-reading-a-little-known-island-community-comes-in-from-the-cold-1220', $t$A little-known island community comes in from the cold$t$, $md$## A little-known island community comes in from the cold

Nguồn:
- Test: https://mini-ielts.com/1220/reading/a-little-known-island-community-comes-in-from-the-cold
- Solution: https://mini-ielts.com/1220/view-solution/reading/a-little-known-island-community-comes-in-from-the-cold$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('a7689beb-3b3d-53c4-8038-9ddc77287070', '16bc62cd-6b6f-528c-8b50-b3158e30efea', 1, $t$Reading — A little-known island community comes in from the cold$t$, $md$Read the passage and answer questions **1–14**.

### Passage: A little-known island community comes in from the cold

Back in early 1961, few outside the corridors of dwindling British power had heard of the archipelago centred on the main island of Tristan da Cunha, from which the scattered islands that make up the group took their name.

It would take a dramatic volcanic eruption, and an emergency evacuation that would grab the attention of the media, to bring attention to this mysterious outpost of the British Empire. It seemed that the islands, no more than pin-pricks in the Southern Atlantic Ocean, almost equidistant between Buenos Aires in South America and Cape Town in South Africa, preferred not to be found.

The same can be said of the 290 or so residents of Tristan da Cunha at that time. They lived on the remotest island on the entire planet.There was no airport, nor was there space to build one on this mountainous carbuncle projecting from the ocean.The only harbour, impenetrable during rough weather, was 1,500 miles distant from the nearest mainland port. Cape Town. Communications with the outside world relied predominantly on signals to passing fishing boats and the annual visit of the vessel that supplied the islanders with the goods they could not produce themselves.

For this was a self-reliant community, proud of their ability to survive and help each other in times of adversity. Colonised early in the 19 th century, until December 1942, money had not been exchanged on the island. However, war-time conditions and new development, in particular a new fishing industry, saw the beginnings of links which meant that the islanders had to accept they were now part of the modern world, however much the older members of the community might resist such change.

The lives of the islanders ticked quietly along, largely ignored as the government of Britain struggled with larger events on the world stage, until the beginning of August 1961. Earth tremors and rock falls began on the 6 th , but by October the situation had got so bad that the island had to be evacuated.The entire population eventually found themselves in England, where they were met with unwanted and unexpected attention from the media. They were housed at a military camp just outside the port of Southampton.

Coming from a sub-tropical island and having had little exposure to the illnesses and chill endured by the natives of the British Isles during winter, several of the elder islanders succumbed. The government did not seem to know what to offer the islanders, there was no news about what was happening to their homeland, and the future looked very bleak.These were people who had built up their own way of life for over one hundred and fifty years. They were a compact community who shared only seven family names between them, and now it seemed that their way of life was to be destroyed.

Fortunately, and despite the islanders reluctance to have any dealings with the media, who they suspected looked on them as historical curiosities, the attention helped keep their plight in the public eye. Eventually, word came through that the island was again habitable and, despite strong resistance from the British Government, the vast majority of the islanders voted to return, turning their backs on the temptations of the brighter lights of their temporary home in favour of their own.

The last of the returning islanders arrived in November 1963 and, with the rebuilding of the crawfish canning industry and a growing demand for the island’s stamps amongst dedicated collectors following the publicity caused hy the volcanic eniption, the local economy soon recovered, although communications remained as difficult as they had ever been. Michael Parsons, a young British teacher who was employed on the island, recalls that there was no television and mail from the outside world arrived just eight times a year. ‘I was allowed to send a 100-word telegram home once a month,’he recalls,’and getting news from home brought a lump to my throat’

Things have changed with developments in technology, but at the beginning of the present century the island was again cut off from the rest of the world when, on May 23 rd 2001, a hurricane tore through the area. It caused extensive damage, knocking out the radio station and satellite telephone link as well as leaving the islanders without electricity. It would be a week before news of the disaster reached London and several more weeks before a rescue package could be agreed to help the islanders rebuild.

Today the island boasts its own internet café. For the first time people can see what the items they wish to obtain from abroad actually look like before they purchase them – a big bonus in a place where you have to wait many months to receive an order which might prove to be unsuitable for the purpose you had in mind. At last, it seems, Tristan da Cunha has joined the world.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('75609d76-6dff-5866-9e93-a1c11bdbd843', 'a7689beb-3b3d-53c4-8038-9ddc77287070', 1, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 1

Questions 1-2
Questions 1-2
Choose the correct letter,
A, B, C or D
.
1
The writer describes the islands of Tristan da Cunha as
A
difficult to find in an emergency.
B
a place the media didn’t understand.
C
somewhere different countries claimed to own.
D
unknown to most members of the public.
2
What does the writer say about the islanders?
A
They could go for years with no contact with outsiders.
B
They had no means of leaving the island to speak to others.
C
They exchanged messages with boats that went past them.
D
They travelled to the mainland on the supply ship.

Choose the correct letter, A, B, C or D .$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('c0a7fe38-3a2b-56f9-832b-ca793dd28f1b', 'a7689beb-3b3d-53c4-8038-9ddc77287070', 2, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 2

Questions 1-2
Questions 1-2
Choose the correct letter,
A, B, C or D
.
1
The writer describes the islands of Tristan da Cunha as
A
difficult to find in an emergency.
B
a place the media didn’t understand.
C
somewhere different countries claimed to own.
D
unknown to most members of the public.
2
What does the writer say about the islanders?
A
They could go for years with no contact with outsiders.
B
They had no means of leaving the island to speak to others.
C
They exchanged messages with boats that went past them.
D
They travelled to the mainland on the supply ship.

Choose the correct letter, A, B, C or D .$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('e4fef7c7-c73e-56eb-affb-060f71155b1d', 'a7689beb-3b3d-53c4-8038-9ddc77287070', 3, 'YES_NO_NOT_GIVEN', 'READING', 2, $md$### Question 3

Questions 3-8
Questions 3-8
Do the following statements agree with the claims of the writer in Reading Passage? Write
YES
if the statement agrees with the writers views
NO
if the statement contradicts the writer s views
NOT GIVEN
if it is impossible to say what the writer thinks about this
3
People living on Tristan da Cunha are totally self-sufficient.
4
The islanders often get ill.
5
Some islanders were reluctant to return after the volcanic eruption.
6
The selling of postage stamps has generated revenue for the islanders.
7
There is no television service on Tristan da Cunha.
8
Communications with the island are often interrupted.

3 ____ People living on Tristan da Cunha are totally self-sufficient.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1196d3fa-a6e5-59d3-868c-1ecf2101e6f0', 'e4fef7c7-c73e-56eb-affb-060f71155b1d', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c1320370-c728-5b0b-b722-ca526c6d38d8', 'e4fef7c7-c73e-56eb-affb-060f71155b1d', 2, $md$NO$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b6af6428-4a76-5b12-a7a8-3b492a3a768c', 'e4fef7c7-c73e-56eb-affb-060f71155b1d', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('60454b48-49a3-54d6-9fd7-771e0506097f', 'a7689beb-3b3d-53c4-8038-9ddc77287070', 4, 'YES_NO_NOT_GIVEN', 'READING', 2, $md$### Question 4

Questions 3-8
Questions 3-8
Do the following statements agree with the claims of the writer in Reading Passage? Write
YES
if the statement agrees with the writers views
NO
if the statement contradicts the writer s views
NOT GIVEN
if it is impossible to say what the writer thinks about this
3
People living on Tristan da Cunha are totally self-sufficient.
4
The islanders often get ill.
5
Some islanders were reluctant to return after the volcanic eruption.
6
The selling of postage stamps has generated revenue for the islanders.
7
There is no television service on Tristan da Cunha.
8
Communications with the island are often interrupted.

4 ____ The islanders often get ill.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('24ffd6c4-0720-5fd9-a6b2-1ef67eaaa84d', '60454b48-49a3-54d6-9fd7-771e0506097f', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('15637da4-296e-55a3-bce0-13a31e20ab21', '60454b48-49a3-54d6-9fd7-771e0506097f', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('13b49628-246e-55ca-b998-ab441883fdde', '60454b48-49a3-54d6-9fd7-771e0506097f', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('b58e6f61-f9d1-5c3f-93d9-899acd4f5b9c', 'a7689beb-3b3d-53c4-8038-9ddc77287070', 5, 'YES_NO_NOT_GIVEN', 'READING', 3, $md$### Question 5

Questions 3-8
Questions 3-8
Do the following statements agree with the claims of the writer in Reading Passage? Write
YES
if the statement agrees with the writers views
NO
if the statement contradicts the writer s views
NOT GIVEN
if it is impossible to say what the writer thinks about this
3
People living on Tristan da Cunha are totally self-sufficient.
4
The islanders often get ill.
5
Some islanders were reluctant to return after the volcanic eruption.
6
The selling of postage stamps has generated revenue for the islanders.
7
There is no television service on Tristan da Cunha.
8
Communications with the island are often interrupted.

5 ____ Some islanders were reluctant to return after the volcanic eruption.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2589d0cc-d08f-5199-8bc7-d6ff7efd6962', 'b58e6f61-f9d1-5c3f-93d9-899acd4f5b9c', 1, $md$YES$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5ece876d-3ae1-5b8a-9ca1-4ee036e675b3', 'b58e6f61-f9d1-5c3f-93d9-899acd4f5b9c', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c585cadb-f57e-5cf2-8022-860cfa11c286', 'b58e6f61-f9d1-5c3f-93d9-899acd4f5b9c', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('26fb5c1e-149d-5e3c-bd77-b653141317f9', 'a7689beb-3b3d-53c4-8038-9ddc77287070', 6, 'YES_NO_NOT_GIVEN', 'READING', 3, $md$### Question 6

Questions 3-8
Questions 3-8
Do the following statements agree with the claims of the writer in Reading Passage? Write
YES
if the statement agrees with the writers views
NO
if the statement contradicts the writer s views
NOT GIVEN
if it is impossible to say what the writer thinks about this
3
People living on Tristan da Cunha are totally self-sufficient.
4
The islanders often get ill.
5
Some islanders were reluctant to return after the volcanic eruption.
6
The selling of postage stamps has generated revenue for the islanders.
7
There is no television service on Tristan da Cunha.
8
Communications with the island are often interrupted.

6 ____ The selling of postage stamps has generated revenue for the islanders.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('74d732d4-0625-5a4b-ac35-7a70f3cdd986', '26fb5c1e-149d-5e3c-bd77-b653141317f9', 1, $md$YES$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('74ecdb87-0218-5101-a740-86ec36f08d1a', '26fb5c1e-149d-5e3c-bd77-b653141317f9', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('eb4ac6bc-a483-522e-8f12-ca96c877eddd', '26fb5c1e-149d-5e3c-bd77-b653141317f9', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('d5b251de-ee20-5359-98be-d30ec1b93679', 'a7689beb-3b3d-53c4-8038-9ddc77287070', 7, 'YES_NO_NOT_GIVEN', 'READING', 3, $md$### Question 7

Questions 3-8
Questions 3-8
Do the following statements agree with the claims of the writer in Reading Passage? Write
YES
if the statement agrees with the writers views
NO
if the statement contradicts the writer s views
NOT GIVEN
if it is impossible to say what the writer thinks about this
3
People living on Tristan da Cunha are totally self-sufficient.
4
The islanders often get ill.
5
Some islanders were reluctant to return after the volcanic eruption.
6
The selling of postage stamps has generated revenue for the islanders.
7
There is no television service on Tristan da Cunha.
8
Communications with the island are often interrupted.

7 ____ There is no television service on Tristan da Cunha.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c7930337-ecb9-53fc-af45-768448456668', 'd5b251de-ee20-5359-98be-d30ec1b93679', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('78a993ba-5488-593a-bcf4-baec04e30e86', 'd5b251de-ee20-5359-98be-d30ec1b93679', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0c388026-f323-5cc7-b5db-338c8ad42b86', 'd5b251de-ee20-5359-98be-d30ec1b93679', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('d14749b7-28cc-5a8f-908c-d11fc0d6db8d', 'a7689beb-3b3d-53c4-8038-9ddc77287070', 8, 'YES_NO_NOT_GIVEN', 'READING', 3, $md$### Question 8

Questions 3-8
Questions 3-8
Do the following statements agree with the claims of the writer in Reading Passage? Write
YES
if the statement agrees with the writers views
NO
if the statement contradicts the writer s views
NOT GIVEN
if it is impossible to say what the writer thinks about this
3
People living on Tristan da Cunha are totally self-sufficient.
4
The islanders often get ill.
5
Some islanders were reluctant to return after the volcanic eruption.
6
The selling of postage stamps has generated revenue for the islanders.
7
There is no television service on Tristan da Cunha.
8
Communications with the island are often interrupted.

8 ____ Communications with the island are often interrupted.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5c4bb1d3-2ec0-5af1-bc0a-d102ec8cadd3', 'd14749b7-28cc-5a8f-908c-d11fc0d6db8d', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('98cb98c5-ba29-5730-a433-2b0b8f55c27c', 'd14749b7-28cc-5a8f-908c-d11fc0d6db8d', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('647d142b-0756-55f8-8f6e-598af0d237cd', 'd14749b7-28cc-5a8f-908c-d11fc0d6db8d', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('e95b9fe6-5d12-5bbb-9a74-9f8adb732d54', 'a7689beb-3b3d-53c4-8038-9ddc77287070', 9, 'SUMMARY_COMPLETION', 'READING', 3, $md$### Question 9

Questions 9-14
Questions 9-14
Complete the summary.
Choose
NO MORE THAN TWO WORDS
from the passage for each answer.
First colonised in the early part of the 19
th
century, Tristan da Cunha remained unknown to many people in the rest of the world until a
9
forced the small population of this remote island to evacuate their homes and brought their existence to the attention of
10
. After spending two years as refugees in
11
, the British Government reluctantly allowed them to return to the island once it had been established that the danger had passed. The
12
of the island improved when rebuilding work had been completed, partly because of a new interest in the
13
Disaster was to strike the island again nearly forty years later when a
14
destroyed many buildings on the island.

First colonised in the early part of the 19 th century, Tristan da Cunha remained unknown to many people in the rest of the world until a 9 ____ forced the small population of this remote island to evacuate their homes and brought their existence to the attention of 10 ____ . After spending two years as refugees in 11 ____ , the British Government reluctantly allowed them to return to the island once it had been established that the danger had passed. The 12 ____ of the island improved when rebuilding work had been completed, partly because of a new interest in the 13 ____ Disaster was to strike the island again nearly forty years later when a 14 ____ destroyed many buildings on the island.$md$, NULL, ARRAY['.*volcanic.*eruption.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('ee726204-65ed-56a9-9edd-b55a0a105ed7', 'a7689beb-3b3d-53c4-8038-9ddc77287070', 10, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 10

Questions 9-14
Questions 9-14
Complete the summary.
Choose
NO MORE THAN TWO WORDS
from the passage for each answer.
First colonised in the early part of the 19
th
century, Tristan da Cunha remained unknown to many people in the rest of the world until a
9
forced the small population of this remote island to evacuate their homes and brought their existence to the attention of
10
. After spending two years as refugees in
11
, the British Government reluctantly allowed them to return to the island once it had been established that the danger had passed. The
12
of the island improved when rebuilding work had been completed, partly because of a new interest in the
13
Disaster was to strike the island again nearly forty years later when a
14
destroyed many buildings on the island.

First colonised in the early part of the 19 th century, Tristan da Cunha remained unknown to many people in the rest of the world until a 9 ____ forced the small population of this remote island to evacuate their homes and brought their existence to the attention of 10 ____ . After spending two years as refugees in 11 ____ , the British Government reluctantly allowed them to return to the island once it had been established that the danger had passed. The 12 ____ of the island improved when rebuilding work had been completed, partly because of a new interest in the 13 ____ Disaster was to strike the island again nearly forty years later when a 14 ____ destroyed many buildings on the island.$md$, NULL, ARRAY['.*volcanic.*eruption.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('19cbd9fa-3abd-54bd-a9e3-54d9c7aa820a', 'a7689beb-3b3d-53c4-8038-9ddc77287070', 11, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 11

Questions 9-14
Questions 9-14
Complete the summary.
Choose
NO MORE THAN TWO WORDS
from the passage for each answer.
First colonised in the early part of the 19
th
century, Tristan da Cunha remained unknown to many people in the rest of the world until a
9
forced the small population of this remote island to evacuate their homes and brought their existence to the attention of
10
. After spending two years as refugees in
11
, the British Government reluctantly allowed them to return to the island once it had been established that the danger had passed. The
12
of the island improved when rebuilding work had been completed, partly because of a new interest in the
13
Disaster was to strike the island again nearly forty years later when a
14
destroyed many buildings on the island.

First colonised in the early part of the 19 th century, Tristan da Cunha remained unknown to many people in the rest of the world until a 9 ____ forced the small population of this remote island to evacuate their homes and brought their existence to the attention of 10 ____ . After spending two years as refugees in 11 ____ , the British Government reluctantly allowed them to return to the island once it had been established that the danger had passed. The 12 ____ of the island improved when rebuilding work had been completed, partly because of a new interest in the 13 ____ Disaster was to strike the island again nearly forty years later when a 14 ____ destroyed many buildings on the island.$md$, NULL, ARRAY['.*volcanic.*eruption.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('6c8dc708-e4e5-589b-95d8-b301f6d07ba3', 'a7689beb-3b3d-53c4-8038-9ddc77287070', 12, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 12

Questions 9-14
Questions 9-14
Complete the summary.
Choose
NO MORE THAN TWO WORDS
from the passage for each answer.
First colonised in the early part of the 19
th
century, Tristan da Cunha remained unknown to many people in the rest of the world until a
9
forced the small population of this remote island to evacuate their homes and brought their existence to the attention of
10
. After spending two years as refugees in
11
, the British Government reluctantly allowed them to return to the island once it had been established that the danger had passed. The
12
of the island improved when rebuilding work had been completed, partly because of a new interest in the
13
Disaster was to strike the island again nearly forty years later when a
14
destroyed many buildings on the island.

First colonised in the early part of the 19 th century, Tristan da Cunha remained unknown to many people in the rest of the world until a 9 ____ forced the small population of this remote island to evacuate their homes and brought their existence to the attention of 10 ____ . After spending two years as refugees in 11 ____ , the British Government reluctantly allowed them to return to the island once it had been established that the danger had passed. The 12 ____ of the island improved when rebuilding work had been completed, partly because of a new interest in the 13 ____ Disaster was to strike the island again nearly forty years later when a 14 ____ destroyed many buildings on the island.$md$, NULL, ARRAY['.*volcanic.*eruption.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('d9d18090-da9b-51f0-b68b-c2f69a0d6492', 'a7689beb-3b3d-53c4-8038-9ddc77287070', 13, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 13

Questions 9-14
Questions 9-14
Complete the summary.
Choose
NO MORE THAN TWO WORDS
from the passage for each answer.
First colonised in the early part of the 19
th
century, Tristan da Cunha remained unknown to many people in the rest of the world until a
9
forced the small population of this remote island to evacuate their homes and brought their existence to the attention of
10
. After spending two years as refugees in
11
, the British Government reluctantly allowed them to return to the island once it had been established that the danger had passed. The
12
of the island improved when rebuilding work had been completed, partly because of a new interest in the
13
Disaster was to strike the island again nearly forty years later when a
14
destroyed many buildings on the island.

First colonised in the early part of the 19 th century, Tristan da Cunha remained unknown to many people in the rest of the world until a 9 ____ forced the small population of this remote island to evacuate their homes and brought their existence to the attention of 10 ____ . After spending two years as refugees in 11 ____ , the British Government reluctantly allowed them to return to the island once it had been established that the danger had passed. The 12 ____ of the island improved when rebuilding work had been completed, partly because of a new interest in the 13 ____ Disaster was to strike the island again nearly forty years later when a 14 ____ destroyed many buildings on the island.$md$, NULL, ARRAY['.*volcanic.*eruption.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('1fae907e-1126-5228-8f02-848527d0ff5d', 'a7689beb-3b3d-53c4-8038-9ddc77287070', 14, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 14

Questions 9-14
Questions 9-14
Complete the summary.
Choose
NO MORE THAN TWO WORDS
from the passage for each answer.
First colonised in the early part of the 19
th
century, Tristan da Cunha remained unknown to many people in the rest of the world until a
9
forced the small population of this remote island to evacuate their homes and brought their existence to the attention of
10
. After spending two years as refugees in
11
, the British Government reluctantly allowed them to return to the island once it had been established that the danger had passed. The
12
of the island improved when rebuilding work had been completed, partly because of a new interest in the
13
Disaster was to strike the island again nearly forty years later when a
14
destroyed many buildings on the island.

First colonised in the early part of the 19 th century, Tristan da Cunha remained unknown to many people in the rest of the world until a 9 ____ forced the small population of this remote island to evacuate their homes and brought their existence to the attention of 10 ____ . After spending two years as refugees in 11 ____ , the British Government reluctantly allowed them to return to the island once it had been established that the danger had passed. The 12 ____ of the island improved when rebuilding work had been completed, partly because of a new interest in the 13 ____ Disaster was to strike the island again nearly forty years later when a 14 ____ destroyed many buildings on the island.$md$, NULL, ARRAY['.*volcanic.*eruption.*']);

COMMIT;
