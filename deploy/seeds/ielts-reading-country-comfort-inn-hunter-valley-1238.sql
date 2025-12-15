BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-country-comfort-inn-hunter-valley-1238'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-country-comfort-inn-hunter-valley-1238';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-country-comfort-inn-hunter-valley-1238';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-country-comfort-inn-hunter-valley-1238';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('50da6173-384c-5920-9d78-a19c32698c7b', 'ielts-reading-country-comfort-inn-hunter-valley-1238', $t$Country Comfort Inn, Hunter Valley$t$, $md$## Country Comfort Inn, Hunter Valley

Nguồn:
- Test: https://mini-ielts.com/1238/reading/country-comfort-inn-hunter-valley
- Solution: https://mini-ielts.com/1238/view-solution/reading/country-comfort-inn-hunter-valley$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('1ece3432-1f80-5a8e-862f-bac148230f08', '50da6173-384c-5920-9d78-a19c32698c7b', 1, $t$Reading — Country Comfort Inn, Hunter Valley$t$, $md$Read the passage and answer questions **1–14**.

### Passage: Country Comfort Inn, Hunter Valley

Use information in the description below to answer Questions 1 to 3 . Write your answer in boxes 1-3 on your answer sheet.

Morpeth is today a small town about two hours’ drive north of Sydney. The town of Morpeth grew from an original 2000 acres of land given to an English army officer, Lieutenant Edward Close (1790-1866), in 1821 . During the 1830s and 1840s Morpeth became a major river port, due to its favourable location. Produce, hides and timber were brought to Morpeth from inland New South Wales and shipped down the Hunter river to the coast and then to Sydney. However, in 1870 a railway line reached the town, and the importance of river shipping began to decline. Today, Morpeth, with its beautiful old buildings, is a popular tourist destination.

Country Comfort Inn, Hunter Valley

The Country Comfort Inn, Hunter Valley, is a beautifully restored 125-year-old building just 20 minutes from the vineyards.

Formerly an orphanage, the Inn is set on 10 acres of landscaped gardens complete with pool, sauna, tennis court, spa, gym, billiard room, guest lounge, fireplace, cocktail bar, and two restaurants. Special packages available.

New England Highway, Maitland.

Call toll free 1800 065 064

or (049) 32 52 88

Siesta Motel

“Spend a night – not a fortune”

That’s the Budget Motel chain motto. The Siesta Motel, rated 3-star, is conveniently placed at the gateway to tire winery district and nearby to the historic towns of Morpeth and Wollombi.

The family-owned and operated Siesta offers air – conditioned comfort and a friendly atmosphere. A free light breakfast is delivered to your suite and excellent meals are available at the Maitland City Bowling Club next door. Quality of accommodation is assured and the tariff is the lowest in the district.

258 New England Highway, Maitland.

Phone (049) 32 83 22

Endeavour East Maitland Motel

28 modern, comfortable 3-star units which open onto the swimming pool and bar beque area. All units feature TV and videos, air-conditioning, 2 with spas.

Fully licensed restaurant with cocktail bar and lounge is open 7 nights. Close to all amenities.

New England Highway, East Maitland.

Phone (049) 33 54 88

Eskdale Country Cottages

Rustic cottages secluded amongst gum trees provide quietness and privacy on 200 acres. The cottages are located on the historic beef cattle property, “Eskdale”, nestled in the Williams Valley. Each cottage is completely self-contained having 2 bedrooms, full kitchen facilities , and sitting rooms with TV and video, and offers comfortable rural accommodation to those who enjoy the delights of the country yet still retain access to the city. Situated close to the towns of Morpeth, Maitland, Port Stephens & rainforests around Dungog.

Nelson Plains Road, Seaham NSW 2324.

Phone (049) 88 62 07, 88 62 09

Fax (049)88 62 09

Read the description below of the town of Morpeth and answer the questions that follow.

The best way to see Morpeth is to take the Morpeth Heritage Walk. This covers about three kilometres, and takes visitors past many beautiful historical buildings. Starting at Fig Tree Hill, which has picnic facilities, stroll past the Surgeon’s Cottage , built in 1845, formerly home of the local doctor, now shops. From there you will come to Morpeth Bridge , erected in 1870, which replaced a ferry boat. Opposite it on the right is the Courthouse , still in use today. Continue your walk past the historic Railway Station , then turn into George Street. Stroll past gracious houses until you come to the Church of the Immaculate Conception on your right, built of bricks made in Gosford. Continuing up George Street, you come to the shopping district ; browse through the shops or stop for refreshment. Your tour of Morpeth will finish at magnificent Closebourne House , built in 1826 by Lieutenant Edward Close.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('d5988764-8e53-579f-a153-414d261111b1', '1ece3432-1f80-5a8e-862f-bac148230f08', 1, 'FORM_COMPLETION', 'READING', 2, $md$### Question 1

Questions 1–3
Questions 1–3
Use information in the description below to answer
Questions 1 to 3
. Write your answer in boxes
1-3
on your answer sheet
1
. When was Lieutenant Close given the land on which Morpeth grew?
1
Locate
2.
On what river is Morpeth situated?
2
Locate
3.
When did trains first get to Morpeth?
3
Locate

1 . When was Lieutenant Close given the land on which Morpeth grew? 1 ____ Locate$md$, NULL, ARRAY['.*1821.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('956ea17c-164f-5c37-939f-adea833a08b3', '1ece3432-1f80-5a8e-862f-bac148230f08', 2, 'FORM_COMPLETION', 'READING', 2, $md$### Question 2

Questions 1–3
Questions 1–3
Use information in the description below to answer
Questions 1 to 3
. Write your answer in boxes
1-3
on your answer sheet
1
. When was Lieutenant Close given the land on which Morpeth grew?
1
Locate
2.
On what river is Morpeth situated?
2
Locate
3.
When did trains first get to Morpeth?
3
Locate

2. On what river is Morpeth situated? 2 ____ Locate$md$, NULL, ARRAY['.*the.*hunter.*river.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('ddeb4766-8320-5fd8-a7ae-7f6698d15cc5', '1ece3432-1f80-5a8e-862f-bac148230f08', 3, 'FORM_COMPLETION', 'READING', 2, $md$### Question 3

Questions 1–3
Questions 1–3
Use information in the description below to answer
Questions 1 to 3
. Write your answer in boxes
1-3
on your answer sheet
1
. When was Lieutenant Close given the land on which Morpeth grew?
1
Locate
2.
On what river is Morpeth situated?
2
Locate
3.
When did trains first get to Morpeth?
3
Locate

3. When did trains first get to Morpeth? 3 ____ Locate$md$, NULL, ARRAY['.*the.*hunter.*river.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('c7704efd-9101-5f7d-a164-9f882cfa569c', '1ece3432-1f80-5a8e-862f-bac148230f08', 4, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 4

Questions 4 -7
Questions 4 -7
There are four advertisements on the next page for places to stay near Morpeth.
Answer the questions below by writing the letters of the appropriate advertisements in boxes
4-7
on your answer sheet.
4.
Which TWO places to stay have restaurants?
4
Locate
5.
Which place claims to offer the cheapest rate?
5
6.
For more information, to which place can you telephone free of charge?
6
Locate
7.
At which place can the guests cook their own food?
7
Locate

4. Which TWO places to stay have restaurants? 4 ____ Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e4a2fc3b-271f-5c23-9b67-7203d334f7fa', 'c7704efd-9101-5f7d-a164-9f882cfa569c', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2b917edc-a700-52f9-a1d5-2fb739922f16', 'c7704efd-9101-5f7d-a164-9f882cfa569c', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0433a647-7405-5823-a936-e03f17bdc5fc', 'c7704efd-9101-5f7d-a164-9f882cfa569c', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('740268e1-b621-5358-8cfb-053ee352c885', 'c7704efd-9101-5f7d-a164-9f882cfa569c', 4, $md$D$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('2a78f624-550f-591f-8f92-b67d664613d9', '1ece3432-1f80-5a8e-862f-bac148230f08', 5, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 5

Questions 4 -7
Questions 4 -7
There are four advertisements on the next page for places to stay near Morpeth.
Answer the questions below by writing the letters of the appropriate advertisements in boxes
4-7
on your answer sheet.
4.
Which TWO places to stay have restaurants?
4
Locate
5.
Which place claims to offer the cheapest rate?
5
6.
For more information, to which place can you telephone free of charge?
6
Locate
7.
At which place can the guests cook their own food?
7
Locate

5. Which place claims to offer the cheapest rate? 5 ____$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f42f4052-beb8-5019-a91e-14b115702138', '2a78f624-550f-591f-8f92-b67d664613d9', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('086eede7-d296-538a-9e96-881f20826246', '2a78f624-550f-591f-8f92-b67d664613d9', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9f9ff804-f4bc-581d-948d-97f9a8491cc8', '2a78f624-550f-591f-8f92-b67d664613d9', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5b297d63-80db-5e92-93c8-b99df254708a', '2a78f624-550f-591f-8f92-b67d664613d9', 4, $md$D$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('671f0152-c83f-57e7-90d6-a0287efc1c77', '1ece3432-1f80-5a8e-862f-bac148230f08', 6, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 6

Questions 4 -7
Questions 4 -7
There are four advertisements on the next page for places to stay near Morpeth.
Answer the questions below by writing the letters of the appropriate advertisements in boxes
4-7
on your answer sheet.
4.
Which TWO places to stay have restaurants?
4
Locate
5.
Which place claims to offer the cheapest rate?
5
6.
For more information, to which place can you telephone free of charge?
6
Locate
7.
At which place can the guests cook their own food?
7
Locate

6. For more information, to which place can you telephone free of charge? 6 ____ Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('431d2a65-f624-595b-9e9d-2fab4afad7ad', '671f0152-c83f-57e7-90d6-a0287efc1c77', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e491bd6f-6ad3-5d02-b5c8-3e17a89a30b9', '671f0152-c83f-57e7-90d6-a0287efc1c77', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('112557a0-57d5-516e-bdeb-0cfec948c2d9', '671f0152-c83f-57e7-90d6-a0287efc1c77', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9073dc71-3aba-54fd-a19d-0a39532609f5', '671f0152-c83f-57e7-90d6-a0287efc1c77', 4, $md$D$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('18aee9fc-466b-5375-83f8-a8c2f0522721', '1ece3432-1f80-5a8e-862f-bac148230f08', 7, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 7

Questions 4 -7
Questions 4 -7
There are four advertisements on the next page for places to stay near Morpeth.
Answer the questions below by writing the letters of the appropriate advertisements in boxes
4-7
on your answer sheet.
4.
Which TWO places to stay have restaurants?
4
Locate
5.
Which place claims to offer the cheapest rate?
5
6.
For more information, to which place can you telephone free of charge?
6
Locate
7.
At which place can the guests cook their own food?
7
Locate

7. At which place can the guests cook their own food? 7 ____ Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ea413d8e-e7b2-507e-8013-123f18c75370', '18aee9fc-466b-5375-83f8-a8c2f0522721', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('591d947e-888b-5012-828f-c76cde778a8a', '18aee9fc-466b-5375-83f8-a8c2f0522721', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('53548685-b8a4-50ca-be29-d38e49ce17b3', '18aee9fc-466b-5375-83f8-a8c2f0522721', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a9488d4f-1657-5d0c-b7b1-11b5fefc7876', '18aee9fc-466b-5375-83f8-a8c2f0522721', 4, $md$D$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('78c5032e-b649-5976-a8c1-72977738edef', '1ece3432-1f80-5a8e-862f-bac148230f08', 8, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 8

Questions 8-14
Questions 8-14
Using information from the text, fill in the names of the numbered tourist attractions on the map. Write pour answers in boxes
8-14
on your answer sheet. The first one has been done for you as an example. Note: there are more names than you will need
Tourist attractions
A Fig Tree Hill
B Ferry Boat
C George Street
D Gosford
E Church of the Immaculate Conception
F Closebourne House
G Morpeth Bridge
H shopping district
I Surgeon’s Cottage
J Railway Station
K Courthouse
8
Locate
9
Locate
10
Locate
11
Locate
12
Locate
13
Locate
Locate
14

8 ____ Locate 9 ____ Locate 10 ____ Locate 11 ____ Locate 12 ____ Locate 13 ____ Locate Locate 14 ____$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2de2f7da-08e6-5cda-b1c5-5869e9770b74', '78c5032e-b649-5976-a8c1-72977738edef', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('483ff5ee-33af-5388-92d6-3e7d3dc80ee2', '78c5032e-b649-5976-a8c1-72977738edef', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('682a40ac-030b-5c69-b748-ce1ca4bf1d38', '78c5032e-b649-5976-a8c1-72977738edef', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('724383ff-d312-575c-9107-74fe3afe967f', '78c5032e-b649-5976-a8c1-72977738edef', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2e4b6a37-bdd0-5973-ae75-a7f680254c60', '78c5032e-b649-5976-a8c1-72977738edef', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('edd2eae6-8160-57ab-9d0a-ea659efc54b8', '78c5032e-b649-5976-a8c1-72977738edef', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('77021877-0f18-5e1c-8407-af3413ebbdcc', '78c5032e-b649-5976-a8c1-72977738edef', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('58361bcc-28de-5cd0-9f92-20b297ad5555', '78c5032e-b649-5976-a8c1-72977738edef', 8, $md$H$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ac560168-d85d-5eed-a692-27e9a3d0e51d', '78c5032e-b649-5976-a8c1-72977738edef', 9, $md$I$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e75ea257-1583-592c-bb79-77b95cf50929', '78c5032e-b649-5976-a8c1-72977738edef', 10, $md$J$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('60d92b88-62a9-5c6a-bc4c-d4a6e4a8602f', '78c5032e-b649-5976-a8c1-72977738edef', 11, $md$K$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('39d3230e-9bbf-5fb8-a5f1-b239cb815b89', '1ece3432-1f80-5a8e-862f-bac148230f08', 9, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 9

Questions 8-14
Questions 8-14
Using information from the text, fill in the names of the numbered tourist attractions on the map. Write pour answers in boxes
8-14
on your answer sheet. The first one has been done for you as an example. Note: there are more names than you will need
Tourist attractions
A Fig Tree Hill
B Ferry Boat
C George Street
D Gosford
E Church of the Immaculate Conception
F Closebourne House
G Morpeth Bridge
H shopping district
I Surgeon’s Cottage
J Railway Station
K Courthouse
8
Locate
9
Locate
10
Locate
11
Locate
12
Locate
13
Locate
Locate
14

8 ____ Locate 9 ____ Locate 10 ____ Locate 11 ____ Locate 12 ____ Locate 13 ____ Locate Locate 14 ____$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('dcc85bfc-fba1-505a-bd33-d3e7a0e1d8a0', '39d3230e-9bbf-5fb8-a5f1-b239cb815b89', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('053a428e-8e24-55bf-b592-a6436e821723', '39d3230e-9bbf-5fb8-a5f1-b239cb815b89', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c9006420-c00a-5c33-b710-afbace1dd734', '39d3230e-9bbf-5fb8-a5f1-b239cb815b89', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c439c296-0305-57b6-b8c9-a9203d3ba779', '39d3230e-9bbf-5fb8-a5f1-b239cb815b89', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5333e05c-40f6-54c3-9ea7-3d93a97f309f', '39d3230e-9bbf-5fb8-a5f1-b239cb815b89', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5b2e394b-e95e-5d6e-936d-c31e8fe50ef0', '39d3230e-9bbf-5fb8-a5f1-b239cb815b89', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d5c40117-6ded-5152-8488-481c8b382f7b', '39d3230e-9bbf-5fb8-a5f1-b239cb815b89', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('28b866eb-9273-56b3-b5f7-436f9dd53520', '39d3230e-9bbf-5fb8-a5f1-b239cb815b89', 8, $md$H$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1a53d21a-96b6-55c5-a4ce-8c792240038e', '39d3230e-9bbf-5fb8-a5f1-b239cb815b89', 9, $md$I$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('eb9a2a77-96f4-55a8-a7f1-c17e7194de97', '39d3230e-9bbf-5fb8-a5f1-b239cb815b89', 10, $md$J$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('577cb888-8447-5976-bb3e-979b18bf2a6e', '39d3230e-9bbf-5fb8-a5f1-b239cb815b89', 11, $md$K$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('6f8f3fe7-b933-5a2c-874c-374a2a0c94ba', '1ece3432-1f80-5a8e-862f-bac148230f08', 10, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 10

Questions 8-14
Questions 8-14
Using information from the text, fill in the names of the numbered tourist attractions on the map. Write pour answers in boxes
8-14
on your answer sheet. The first one has been done for you as an example. Note: there are more names than you will need
Tourist attractions
A Fig Tree Hill
B Ferry Boat
C George Street
D Gosford
E Church of the Immaculate Conception
F Closebourne House
G Morpeth Bridge
H shopping district
I Surgeon’s Cottage
J Railway Station
K Courthouse
8
Locate
9
Locate
10
Locate
11
Locate
12
Locate
13
Locate
Locate
14

8 ____ Locate 9 ____ Locate 10 ____ Locate 11 ____ Locate 12 ____ Locate 13 ____ Locate Locate 14 ____$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b02258df-cbbf-54dd-b508-f99052466e82', '6f8f3fe7-b933-5a2c-874c-374a2a0c94ba', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('87dca728-a0db-56f0-a79e-040c655dbea2', '6f8f3fe7-b933-5a2c-874c-374a2a0c94ba', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('774b197e-b8c7-5b83-852a-af05aa2083ff', '6f8f3fe7-b933-5a2c-874c-374a2a0c94ba', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ead562ab-eb20-589d-9126-3d5eb19b57f5', '6f8f3fe7-b933-5a2c-874c-374a2a0c94ba', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f7457d84-ae3b-5b43-b8ba-24d52bfa28ff', '6f8f3fe7-b933-5a2c-874c-374a2a0c94ba', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f88e6f80-4b71-5dcb-baf2-f4c49e2d6a4b', '6f8f3fe7-b933-5a2c-874c-374a2a0c94ba', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d1aad0a8-60bb-547b-b0ef-6686956cb3ca', '6f8f3fe7-b933-5a2c-874c-374a2a0c94ba', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4df6d89f-3cd4-5a8f-aa43-c6bed9ad48fb', '6f8f3fe7-b933-5a2c-874c-374a2a0c94ba', 8, $md$H$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3964b58d-daea-5282-b67e-29ca9b40861d', '6f8f3fe7-b933-5a2c-874c-374a2a0c94ba', 9, $md$I$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8d786448-2921-5ef5-b3e1-d2db7b44de19', '6f8f3fe7-b933-5a2c-874c-374a2a0c94ba', 10, $md$J$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4ea484a6-4455-5da7-8e8a-88a9b2395a29', '6f8f3fe7-b933-5a2c-874c-374a2a0c94ba', 11, $md$K$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('271f6ee6-54a4-56b2-8164-99b9ae28fcb8', '1ece3432-1f80-5a8e-862f-bac148230f08', 11, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 11

Questions 8-14
Questions 8-14
Using information from the text, fill in the names of the numbered tourist attractions on the map. Write pour answers in boxes
8-14
on your answer sheet. The first one has been done for you as an example. Note: there are more names than you will need
Tourist attractions
A Fig Tree Hill
B Ferry Boat
C George Street
D Gosford
E Church of the Immaculate Conception
F Closebourne House
G Morpeth Bridge
H shopping district
I Surgeon’s Cottage
J Railway Station
K Courthouse
8
Locate
9
Locate
10
Locate
11
Locate
12
Locate
13
Locate
Locate
14

8 ____ Locate 9 ____ Locate 10 ____ Locate 11 ____ Locate 12 ____ Locate 13 ____ Locate Locate 14 ____$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a9b06483-73ce-5ca1-a2b9-fd291ce79001', '271f6ee6-54a4-56b2-8164-99b9ae28fcb8', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('aac5d174-60e0-5ab3-ada0-d4475f9fa85d', '271f6ee6-54a4-56b2-8164-99b9ae28fcb8', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c3bea245-d199-5e61-9992-54294b817747', '271f6ee6-54a4-56b2-8164-99b9ae28fcb8', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('40b4931b-e55c-5867-ad2d-5c71588f1ca6', '271f6ee6-54a4-56b2-8164-99b9ae28fcb8', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6c897a16-2a28-5d80-8d97-ecb552bfca37', '271f6ee6-54a4-56b2-8164-99b9ae28fcb8', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a0c06e29-3369-5ed4-bb02-dda2521eaecf', '271f6ee6-54a4-56b2-8164-99b9ae28fcb8', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1717c3b1-a16a-56e4-b191-b383bf984883', '271f6ee6-54a4-56b2-8164-99b9ae28fcb8', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('33435318-d195-5f96-ae8a-fb3a5ddf836f', '271f6ee6-54a4-56b2-8164-99b9ae28fcb8', 8, $md$H$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d2435c02-f11f-5f3f-8d79-88406c7c7486', '271f6ee6-54a4-56b2-8164-99b9ae28fcb8', 9, $md$I$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('dcc07313-fc91-5365-8953-22feb372338d', '271f6ee6-54a4-56b2-8164-99b9ae28fcb8', 10, $md$J$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3958f6de-e64b-5ee0-b587-4e9f7aba32ed', '271f6ee6-54a4-56b2-8164-99b9ae28fcb8', 11, $md$K$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('39c69369-051b-55eb-b9b8-6c9227a5c845', '1ece3432-1f80-5a8e-862f-bac148230f08', 12, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 12

Questions 8-14
Questions 8-14
Using information from the text, fill in the names of the numbered tourist attractions on the map. Write pour answers in boxes
8-14
on your answer sheet. The first one has been done for you as an example. Note: there are more names than you will need
Tourist attractions
A Fig Tree Hill
B Ferry Boat
C George Street
D Gosford
E Church of the Immaculate Conception
F Closebourne House
G Morpeth Bridge
H shopping district
I Surgeon’s Cottage
J Railway Station
K Courthouse
8
Locate
9
Locate
10
Locate
11
Locate
12
Locate
13
Locate
Locate
14

8 ____ Locate 9 ____ Locate 10 ____ Locate 11 ____ Locate 12 ____ Locate 13 ____ Locate Locate 14 ____$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('07253993-233e-5116-87e7-738f8d74cc22', '39c69369-051b-55eb-b9b8-6c9227a5c845', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3af28b1b-c275-5d75-8114-f55172656b88', '39c69369-051b-55eb-b9b8-6c9227a5c845', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('69c4ebd0-8f34-5fdb-b1b5-b4dec6facb61', '39c69369-051b-55eb-b9b8-6c9227a5c845', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('36aace02-511e-5438-90e4-f7a136d05e46', '39c69369-051b-55eb-b9b8-6c9227a5c845', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('be71184a-f6f5-51e1-81df-ac09a35e4544', '39c69369-051b-55eb-b9b8-6c9227a5c845', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('993e2401-ab8b-51d4-bd97-4b6a694547df', '39c69369-051b-55eb-b9b8-6c9227a5c845', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('23f5ddca-cb6e-54a3-b629-682b56ce6d66', '39c69369-051b-55eb-b9b8-6c9227a5c845', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('91d64d48-a5bc-5e93-9c89-3b8c4e6a4f42', '39c69369-051b-55eb-b9b8-6c9227a5c845', 8, $md$H$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0ef64004-78e1-5c48-907a-3fbff3ea6a9e', '39c69369-051b-55eb-b9b8-6c9227a5c845', 9, $md$I$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('48dd493c-27ea-5604-99e1-3fba3a85bc7a', '39c69369-051b-55eb-b9b8-6c9227a5c845', 10, $md$J$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('eed916b7-1a8b-567b-a7f0-cd16df631a65', '39c69369-051b-55eb-b9b8-6c9227a5c845', 11, $md$K$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('444d8f9e-141f-531a-9dd9-a123ea532d6a', '1ece3432-1f80-5a8e-862f-bac148230f08', 13, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 13

Questions 8-14
Questions 8-14
Using information from the text, fill in the names of the numbered tourist attractions on the map. Write pour answers in boxes
8-14
on your answer sheet. The first one has been done for you as an example. Note: there are more names than you will need
Tourist attractions
A Fig Tree Hill
B Ferry Boat
C George Street
D Gosford
E Church of the Immaculate Conception
F Closebourne House
G Morpeth Bridge
H shopping district
I Surgeon’s Cottage
J Railway Station
K Courthouse
8
Locate
9
Locate
10
Locate
11
Locate
12
Locate
13
Locate
Locate
14

8 ____ Locate 9 ____ Locate 10 ____ Locate 11 ____ Locate 12 ____ Locate 13 ____ Locate Locate 14 ____$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9f187894-f74d-5be5-a68c-d7412ba47b14', '444d8f9e-141f-531a-9dd9-a123ea532d6a', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d3320a21-be21-5655-a491-052776c85c17', '444d8f9e-141f-531a-9dd9-a123ea532d6a', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('16924f21-5b95-5151-adef-69e4dfbea7e0', '444d8f9e-141f-531a-9dd9-a123ea532d6a', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4a471841-a9e2-5e44-ba17-0fb2a8e326e5', '444d8f9e-141f-531a-9dd9-a123ea532d6a', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a809eb68-dddc-5c7c-9d58-6b3aa3095820', '444d8f9e-141f-531a-9dd9-a123ea532d6a', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8ab98f05-38be-59c6-9229-37d3fc7615cf', '444d8f9e-141f-531a-9dd9-a123ea532d6a', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a2daaa77-6fd9-5d88-bbba-89b25f4c315e', '444d8f9e-141f-531a-9dd9-a123ea532d6a', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('860d7868-003d-59f2-8f36-bf335504d710', '444d8f9e-141f-531a-9dd9-a123ea532d6a', 8, $md$H$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9be39d82-1ce0-59b5-a4d5-d47f249c15f3', '444d8f9e-141f-531a-9dd9-a123ea532d6a', 9, $md$I$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('168f30f4-201e-5641-86cb-d224af81635f', '444d8f9e-141f-531a-9dd9-a123ea532d6a', 10, $md$J$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1da9c4ae-116e-581c-8d97-e371e6a98a98', '444d8f9e-141f-531a-9dd9-a123ea532d6a', 11, $md$K$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('0d4942e6-f283-53a3-bced-72734ba8e007', '1ece3432-1f80-5a8e-862f-bac148230f08', 14, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 14

Questions 8-14
Questions 8-14
Using information from the text, fill in the names of the numbered tourist attractions on the map. Write pour answers in boxes
8-14
on your answer sheet. The first one has been done for you as an example. Note: there are more names than you will need
Tourist attractions
A Fig Tree Hill
B Ferry Boat
C George Street
D Gosford
E Church of the Immaculate Conception
F Closebourne House
G Morpeth Bridge
H shopping district
I Surgeon’s Cottage
J Railway Station
K Courthouse
8
Locate
9
Locate
10
Locate
11
Locate
12
Locate
13
Locate
Locate
14

8 ____ Locate 9 ____ Locate 10 ____ Locate 11 ____ Locate 12 ____ Locate 13 ____ Locate Locate 14 ____$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4aa059eb-b67a-5866-b479-9a108902af3e', '0d4942e6-f283-53a3-bced-72734ba8e007', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bbb590ef-9e4b-5712-8eed-0a3faba394e5', '0d4942e6-f283-53a3-bced-72734ba8e007', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('672816a2-9b8a-54e0-a72d-d323a1b2d559', '0d4942e6-f283-53a3-bced-72734ba8e007', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5857dc92-d47f-5ca4-8108-671a362b02fe', '0d4942e6-f283-53a3-bced-72734ba8e007', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bcf7b46a-6df3-5044-ae8f-bf24293cde40', '0d4942e6-f283-53a3-bced-72734ba8e007', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d7538d66-1f0e-591f-b87c-7aadda4ef2bd', '0d4942e6-f283-53a3-bced-72734ba8e007', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('54687300-ca34-5c66-a418-08da8bb64382', '0d4942e6-f283-53a3-bced-72734ba8e007', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ea5205bf-c65d-58f2-8f42-418928068766', '0d4942e6-f283-53a3-bced-72734ba8e007', 8, $md$H$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2d7807f5-c7d1-5ce3-8078-1549dcc964ad', '0d4942e6-f283-53a3-bced-72734ba8e007', 9, $md$I$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b44538d6-47fa-5e4c-aa07-4308ab125eb0', '0d4942e6-f283-53a3-bced-72734ba8e007', 10, $md$J$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('98b4ac59-9bf1-581d-b230-3362b2c8aca6', '0d4942e6-f283-53a3-bced-72734ba8e007', 11, $md$K$md$, false);

COMMIT;
