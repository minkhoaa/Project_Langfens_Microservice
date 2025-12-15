BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-the-moto-car-1511'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-the-moto-car-1511';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-the-moto-car-1511';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-the-moto-car-1511';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('ded67f11-cc6b-5422-b0cc-fd0e4461332c', 'ielts-reading-the-moto-car-1511', $t$The moto car$t$, $md$## The moto car

Nguồn:
- Test: https://mini-ielts.com/1511/reading/the-moto-car
- Solution: https://mini-ielts.com/1511/view-solution/reading/the-moto-car$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('e440205b-05c4-5ff9-bdd7-ac3ade630fa4', 'ded67f11-cc6b-5422-b0cc-fd0e4461332c', 1, $t$Reading — The moto car$t$, $md$Read the passage and answer questions **1–14**.

### Passage: The moto car

The start of the automobile's history went all the way back to 1769 when automobiles running on the steam engine were invented as carriers for human transport In 1806, the first batch of cars powered by an internal combustion engine came into being, which pioneered the introduction of the widespread modem petrol-fueled internal combustion engine in 1885.

It is generally acknowledged that the first practical automobiles equipped with petrol/gaso-line-powered internal combustion engines were invented almost at the same time by different German inventors who were Working on their own. Karl Bfenz first built the automobile in 1885 in Mannheim. Benz attained a patent for his invention on 29 January 1886, and in 1888, he started to produce automobiles in a company that later became the renowned Mercedes-Benz.

As this century began, the automobile industry marched into the transportation market for the wealth. Drivers at that time were an adventurous bunch; they would go out regardless of the weather condition even if they weren’t even protected by an enclosed body or a convertible top. Everybody in the community knew who owned what car, and cars immediately became a symbol of identity and status. Later, cars became more popular among the public since it allowed people to travel whenever and wherever they wanted. Thus, the price of automobiles in Europe and North America kept dropping, and more people from the middle class could afford them. This was especially attributed to Henry Ford who did two crucial things. First, he set the price as reasonable as possible for his cars; second, he paid his employees enough salaries so that they could afford the cars made by their very own hands.

The trend of interchangeable parts and mass production in an assembly line style had been led by America, and from 1914, this concept was significantly reinforced by Henry Ford. This large-scale, production-line manufacture of affordable automobiles was debuted. A Ford car would come off all assembled from the line every 15 minutes, an interval shorter than any of the former methods. Not only did it raise productivity, but also cut down on the requirement for manpower. Ford significantly lowered the chance of injury by carrying out complicated safety procedures in production—particularly assigning workers to specific locations rather than giving them the freedom to wander around. This mixture of high wages and high efficiency was known as Fordism, which provided a valuable lesson for most major industries.

The first Jeep automobile that came out as the prototype Bantam BRC was the primary light 4-wheel-drive automobile of the U.S. Army and Allies, and during World War II and the postwar period, its sale skyrocketed. Since then, plenty of Jeep derivatives with similar military and civilian functions have been created and kept upgraded in terms of overall performance in other nations.

Through all the 1950s, engine power and automobile rates grew higher, designs evolved into a more integrated and artful form, and cars were spreading globally. In the 1960s, the landscape changed as Detroit was confronted with foreign competition. The European manufacturers, used the latest technology, and Japan came into the picture as a dedicated car-making country. General Motors, Chrysler, and Ford dabbled with radical tiny cars such as the GM A-bodies with little success. As joint ventures such as the British Motor Corporation unified the market, captive imports and badge imports swept all over the US and the UK. BMC first launched a revolutionary space-friendly Mini in 1959, which turned out to harvest large global sales. Previously remaining under the Austin and Morris names, Mini later became an individual marque in 1969. The trend of corporate consolidation landed in Italy when niche makers such as Maserati, Ferrari, and Lancia were bought by larger enterprises. By the end of the 20th century, there had been a sharp fall in the number of automobile marques.

In the US, car performance dominated marketing, justified by the typical cases of pony cars and muscle cars. However, in the 1970s, everything changed as the American automobile industry suffered from the 1973 oil crisis, competition with Japanese and European imports, automobile emission control regulations* and moribund innovation. The irony in all this was that full-size sedans such as Cadillac and Lincoln scored a huge comeback between the years of economic crisis.

In terms of technology, the most mentionable developments that postwar era had seen were the widespread use of independent suspensions, broader application of fuel injection, and a growing emphasis on safety in automobile design. Mazda achieved many triumphs with its engine firstly installed in the fore-wheel, though it gained itself a reputation as a gas-guzzler.

The modem era also has witnessed a sharp elevation of fuel power in the modem engine management system with the. help of the computer. Nowadays, most automobiles in use are powered by an internal combustion engine, fueled by gasoline or diesel. Toxic gas from both fuels is known to pollute the air and is responsible for climate change as well as global warming.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('c61a9af4-a3aa-5342-a0a0-16b3791d4923', 'e440205b-05c4-5ff9-bdd7-ac3ade630fa4', 1, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 1

Questions 1-6
Questions 1-6
Look at the following descriptions (Questions 1-6) and the list of automobile brands below.
Match each description with the correct automobile brand, A-G. Write the correct letter, A-G, in boxes 1-6 on your answer sheet.
List of Automobile Brands
A
Ford
B
the BMC Mini
c
Cadillac and Lincoln
D
Mercedes Benz
E
Mazda
F
Jeep
G Maserati, Ferrari, and Lancia
1
began producing the first automobiles
2
produced the industrialized cars that common consumers could afford
3
improved the utilization rate of automobile space
4
upgraded the overall performance of the car continuously
5
maintained leading growth even during an economic recession
6
installed its engine on the front wheel for the first time

1 ____ began producing the first automobiles$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7489ad56-8700-5b68-8196-0871bf6dc790', 'c61a9af4-a3aa-5342-a0a0-16b3791d4923', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8e963b9a-1b75-5572-9b33-023cad008d0b', 'c61a9af4-a3aa-5342-a0a0-16b3791d4923', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('65d32a3a-4960-5d2c-94c0-e44ef9058fda', 'c61a9af4-a3aa-5342-a0a0-16b3791d4923', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2aeabfe5-b636-5283-adbc-303080f3437b', 'c61a9af4-a3aa-5342-a0a0-16b3791d4923', 4, $md$D$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('062cb012-bd9d-55f6-b9b9-ddeca6c511a0', 'c61a9af4-a3aa-5342-a0a0-16b3791d4923', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4e1d8ffe-2ab6-581f-b8b9-4cdb88fb6731', 'c61a9af4-a3aa-5342-a0a0-16b3791d4923', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('dcbbc975-3e3f-57f1-a04f-694a9ed3f9f7', 'c61a9af4-a3aa-5342-a0a0-16b3791d4923', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('b96242bb-4604-57e2-b05d-9f3a52838c5e', 'e440205b-05c4-5ff9-bdd7-ac3ade630fa4', 2, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 2

Questions 1-6
Questions 1-6
Look at the following descriptions (Questions 1-6) and the list of automobile brands below.
Match each description with the correct automobile brand, A-G. Write the correct letter, A-G, in boxes 1-6 on your answer sheet.
List of Automobile Brands
A
Ford
B
the BMC Mini
c
Cadillac and Lincoln
D
Mercedes Benz
E
Mazda
F
Jeep
G Maserati, Ferrari, and Lancia
1
began producing the first automobiles
2
produced the industrialized cars that common consumers could afford
3
improved the utilization rate of automobile space
4
upgraded the overall performance of the car continuously
5
maintained leading growth even during an economic recession
6
installed its engine on the front wheel for the first time

2 ____ produced the industrialized cars that common consumers could afford$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e00d0397-7b37-50fd-a49a-e533a4757d39', 'b96242bb-4604-57e2-b05d-9f3a52838c5e', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7b316da7-4872-5363-8555-b7c4388c91fd', 'b96242bb-4604-57e2-b05d-9f3a52838c5e', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e084d9ad-7af6-5668-8bcb-4d78d63054d2', 'b96242bb-4604-57e2-b05d-9f3a52838c5e', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('28460ed1-40ce-5ddd-a875-f090b3b49d7b', 'b96242bb-4604-57e2-b05d-9f3a52838c5e', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('65877140-aa55-5e55-9606-1171aee9bf3f', 'b96242bb-4604-57e2-b05d-9f3a52838c5e', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f70126bc-35f1-5cdb-8794-abfc7014d20c', 'b96242bb-4604-57e2-b05d-9f3a52838c5e', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e9124eb8-0ea7-5b07-beaa-f9d511497ae9', 'b96242bb-4604-57e2-b05d-9f3a52838c5e', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('7c3009c4-1a20-5c8c-8f5d-f9b8925c6dd7', 'e440205b-05c4-5ff9-bdd7-ac3ade630fa4', 3, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 3

Questions 1-6
Questions 1-6
Look at the following descriptions (Questions 1-6) and the list of automobile brands below.
Match each description with the correct automobile brand, A-G. Write the correct letter, A-G, in boxes 1-6 on your answer sheet.
List of Automobile Brands
A
Ford
B
the BMC Mini
c
Cadillac and Lincoln
D
Mercedes Benz
E
Mazda
F
Jeep
G Maserati, Ferrari, and Lancia
1
began producing the first automobiles
2
produced the industrialized cars that common consumers could afford
3
improved the utilization rate of automobile space
4
upgraded the overall performance of the car continuously
5
maintained leading growth even during an economic recession
6
installed its engine on the front wheel for the first time

3 ____ improved the utilization rate of automobile space$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0b753688-3b5f-5919-953d-f9d9c4e69527', '7c3009c4-1a20-5c8c-8f5d-f9b8925c6dd7', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f20c0012-5ead-506d-9b63-2710d30a4ccc', '7c3009c4-1a20-5c8c-8f5d-f9b8925c6dd7', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('057c2271-4245-5da0-bcac-b54cfdced313', '7c3009c4-1a20-5c8c-8f5d-f9b8925c6dd7', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e596704c-5c97-585c-85c9-8c4c3bd533f9', '7c3009c4-1a20-5c8c-8f5d-f9b8925c6dd7', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0d658262-5d4b-52d5-b312-dfd20a22e204', '7c3009c4-1a20-5c8c-8f5d-f9b8925c6dd7', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('38be9a8f-aeef-58fe-876c-bdd58894d850', '7c3009c4-1a20-5c8c-8f5d-f9b8925c6dd7', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('482bf8e2-7714-505b-a52e-ae4b2fe3a16a', '7c3009c4-1a20-5c8c-8f5d-f9b8925c6dd7', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('6bc9903d-eae7-5d87-9243-b4f4c3dea7f4', 'e440205b-05c4-5ff9-bdd7-ac3ade630fa4', 4, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 4

Questions 1-6
Questions 1-6
Look at the following descriptions (Questions 1-6) and the list of automobile brands below.
Match each description with the correct automobile brand, A-G. Write the correct letter, A-G, in boxes 1-6 on your answer sheet.
List of Automobile Brands
A
Ford
B
the BMC Mini
c
Cadillac and Lincoln
D
Mercedes Benz
E
Mazda
F
Jeep
G Maserati, Ferrari, and Lancia
1
began producing the first automobiles
2
produced the industrialized cars that common consumers could afford
3
improved the utilization rate of automobile space
4
upgraded the overall performance of the car continuously
5
maintained leading growth even during an economic recession
6
installed its engine on the front wheel for the first time

4 ____ upgraded the overall performance of the car continuously$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('624c3b4d-05f0-527d-89f2-dc908204de1b', '6bc9903d-eae7-5d87-9243-b4f4c3dea7f4', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('39792c78-d5de-5d76-915b-1728e6872ef4', '6bc9903d-eae7-5d87-9243-b4f4c3dea7f4', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ad8f84ef-d3f5-5e3f-b8cf-69d49e123423', '6bc9903d-eae7-5d87-9243-b4f4c3dea7f4', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('664a578b-3b85-5e25-9e4d-3969c294b9fe', '6bc9903d-eae7-5d87-9243-b4f4c3dea7f4', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7ef447f1-f189-5b55-8ea3-7865373024f4', '6bc9903d-eae7-5d87-9243-b4f4c3dea7f4', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('26a1066f-d853-5a83-bf70-b3485015cfe2', '6bc9903d-eae7-5d87-9243-b4f4c3dea7f4', 6, $md$F$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('88fcf319-0851-5b89-a118-7890ea18e5ae', '6bc9903d-eae7-5d87-9243-b4f4c3dea7f4', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('5f0bb209-36cd-568a-b1ca-f43d0f2f41af', 'e440205b-05c4-5ff9-bdd7-ac3ade630fa4', 5, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 5

Questions 1-6
Questions 1-6
Look at the following descriptions (Questions 1-6) and the list of automobile brands below.
Match each description with the correct automobile brand, A-G. Write the correct letter, A-G, in boxes 1-6 on your answer sheet.
List of Automobile Brands
A
Ford
B
the BMC Mini
c
Cadillac and Lincoln
D
Mercedes Benz
E
Mazda
F
Jeep
G Maserati, Ferrari, and Lancia
1
began producing the first automobiles
2
produced the industrialized cars that common consumers could afford
3
improved the utilization rate of automobile space
4
upgraded the overall performance of the car continuously
5
maintained leading growth even during an economic recession
6
installed its engine on the front wheel for the first time

5 ____ maintained leading growth even during an economic recession$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6173a041-56ac-5bce-b5f9-5f2689c08f5c', '5f0bb209-36cd-568a-b1ca-f43d0f2f41af', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f78a4caa-1fa6-5df0-9982-a59ddb271281', '5f0bb209-36cd-568a-b1ca-f43d0f2f41af', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c2dcbb79-569a-56f9-979a-e0323ca2a435', '5f0bb209-36cd-568a-b1ca-f43d0f2f41af', 3, $md$C$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9ff8b5b1-cd79-512c-9101-92334d0588ff', '5f0bb209-36cd-568a-b1ca-f43d0f2f41af', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cfeb766d-009c-55be-b692-eb7a31105c39', '5f0bb209-36cd-568a-b1ca-f43d0f2f41af', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3ce98a52-afe0-5564-adbe-e2e0b8c4c946', '5f0bb209-36cd-568a-b1ca-f43d0f2f41af', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b5ca9bcd-0719-52ad-8209-42925ff2f233', '5f0bb209-36cd-568a-b1ca-f43d0f2f41af', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('c962cf11-2208-5d08-80ea-93abb70b17a7', 'e440205b-05c4-5ff9-bdd7-ac3ade630fa4', 6, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 6

Questions 1-6
Questions 1-6
Look at the following descriptions (Questions 1-6) and the list of automobile brands below.
Match each description with the correct automobile brand, A-G. Write the correct letter, A-G, in boxes 1-6 on your answer sheet.
List of Automobile Brands
A
Ford
B
the BMC Mini
c
Cadillac and Lincoln
D
Mercedes Benz
E
Mazda
F
Jeep
G Maserati, Ferrari, and Lancia
1
began producing the first automobiles
2
produced the industrialized cars that common consumers could afford
3
improved the utilization rate of automobile space
4
upgraded the overall performance of the car continuously
5
maintained leading growth even during an economic recession
6
installed its engine on the front wheel for the first time

6 ____ installed its engine on the front wheel for the first time$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('26242048-35ab-5912-85ce-6546bb16d281', 'c962cf11-2208-5d08-80ea-93abb70b17a7', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e3c04083-f7e9-53de-a068-1158918d307f', 'c962cf11-2208-5d08-80ea-93abb70b17a7', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3e4bf871-91ba-585e-b5ff-6ade2b2c0122', 'c962cf11-2208-5d08-80ea-93abb70b17a7', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a6003d16-b318-5300-aebe-5ba137455a8c', 'c962cf11-2208-5d08-80ea-93abb70b17a7', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('986067b4-cd9d-5b5c-a0c1-26ae094e24b4', 'c962cf11-2208-5d08-80ea-93abb70b17a7', 5, $md$E$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2d568deb-1a78-5fc3-b301-b14929e31936', 'c962cf11-2208-5d08-80ea-93abb70b17a7', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a5e6c51f-719c-5036-8c95-f0352b9cc941', 'c962cf11-2208-5d08-80ea-93abb70b17a7', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('ba2e99a1-3322-5ce7-b157-faa477109ccd', 'e440205b-05c4-5ff9-bdd7-ac3ade630fa4', 7, 'SHORT_ANSWER', 'READING', 3, $md$### Question 7

Questions 7-13
Questions 7-13
Answer the questions below.
Choose
NO MORE THAN THREE WORDS AND/OR A NUMBER
from the passage for each answer.
Write your answers in boxes 20-26 on your answer sheet.
7.
What is the important feature owned by the modem engine since the 19th century?
7
8.
What did a car symbolize to the rich at the very beginning of this century?
8
9.
How long did Ford assembly line take to produce a car?
9
10.
What is the major historical event that led American cars to suffer when competing with Japanese imported cars?
10
11.
What do people call the Mazda car which was designed under the front wheel engine?
11
12.
What has greatly increased with the computerised engine management systems in modem society?
12
13.
What factor is blamed for contributing to pollution, climate change and global warming?
13

7. What is the important feature owned by the modem engine since the 19th century? 7 ____$md$, NULL, ARRAY['.*petrol.*fueled.*internal.*combustion.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('05348d52-ba37-50ba-89c6-a36c0a203d23', 'e440205b-05c4-5ff9-bdd7-ac3ade630fa4', 8, 'SHORT_ANSWER', 'READING', 3, $md$### Question 8

Questions 7-13
Questions 7-13
Answer the questions below.
Choose
NO MORE THAN THREE WORDS AND/OR A NUMBER
from the passage for each answer.
Write your answers in boxes 20-26 on your answer sheet.
7.
What is the important feature owned by the modem engine since the 19th century?
7
8.
What did a car symbolize to the rich at the very beginning of this century?
8
9.
How long did Ford assembly line take to produce a car?
9
10.
What is the major historical event that led American cars to suffer when competing with Japanese imported cars?
10
11.
What do people call the Mazda car which was designed under the front wheel engine?
11
12.
What has greatly increased with the computerised engine management systems in modem society?
12
13.
What factor is blamed for contributing to pollution, climate change and global warming?
13

8. What did a car symbolize to the rich at the very beginning of this century? 8 ____$md$, NULL, ARRAY['.*identity.*and.*status.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('ce90250a-2194-5b90-bc09-d96d5d2f6176', 'e440205b-05c4-5ff9-bdd7-ac3ade630fa4', 9, 'SHORT_ANSWER', 'READING', 3, $md$### Question 9

Questions 7-13
Questions 7-13
Answer the questions below.
Choose
NO MORE THAN THREE WORDS AND/OR A NUMBER
from the passage for each answer.
Write your answers in boxes 20-26 on your answer sheet.
7.
What is the important feature owned by the modem engine since the 19th century?
7
8.
What did a car symbolize to the rich at the very beginning of this century?
8
9.
How long did Ford assembly line take to produce a car?
9
10.
What is the major historical event that led American cars to suffer when competing with Japanese imported cars?
10
11.
What do people call the Mazda car which was designed under the front wheel engine?
11
12.
What has greatly increased with the computerised engine management systems in modem society?
12
13.
What factor is blamed for contributing to pollution, climate change and global warming?
13

9. How long did Ford assembly line take to produce a car? 9 ____$md$, NULL, ARRAY['.*15.*minutes.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('a03218a4-14b5-5043-a3c5-85796651067a', 'e440205b-05c4-5ff9-bdd7-ac3ade630fa4', 10, 'SHORT_ANSWER', 'READING', 4, $md$### Question 10

Questions 7-13
Questions 7-13
Answer the questions below.
Choose
NO MORE THAN THREE WORDS AND/OR A NUMBER
from the passage for each answer.
Write your answers in boxes 20-26 on your answer sheet.
7.
What is the important feature owned by the modem engine since the 19th century?
7
8.
What did a car symbolize to the rich at the very beginning of this century?
8
9.
How long did Ford assembly line take to produce a car?
9
10.
What is the major historical event that led American cars to suffer when competing with Japanese imported cars?
10
11.
What do people call the Mazda car which was designed under the front wheel engine?
11
12.
What has greatly increased with the computerised engine management systems in modem society?
12
13.
What factor is blamed for contributing to pollution, climate change and global warming?
13

10. What is the major historical event that led American cars to suffer when competing with Japanese imported cars? 10 ____$md$, NULL, ARRAY['.*1973.*oil.*crisis.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('e8bd4042-f24d-5955-8ed6-6a1fd541baac', 'e440205b-05c4-5ff9-bdd7-ac3ade630fa4', 11, 'SHORT_ANSWER', 'READING', 4, $md$### Question 11

Questions 7-13
Questions 7-13
Answer the questions below.
Choose
NO MORE THAN THREE WORDS AND/OR A NUMBER
from the passage for each answer.
Write your answers in boxes 20-26 on your answer sheet.
7.
What is the important feature owned by the modem engine since the 19th century?
7
8.
What did a car symbolize to the rich at the very beginning of this century?
8
9.
How long did Ford assembly line take to produce a car?
9
10.
What is the major historical event that led American cars to suffer when competing with Japanese imported cars?
10
11.
What do people call the Mazda car which was designed under the front wheel engine?
11
12.
What has greatly increased with the computerised engine management systems in modem society?
12
13.
What factor is blamed for contributing to pollution, climate change and global warming?
13

11. What do people call the Mazda car which was designed under the front wheel engine? 11 ____$md$, NULL, ARRAY['.*a.*gas.*guzzler.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('5bc26f8c-782b-5bb4-8991-7f35fc2a2171', 'e440205b-05c4-5ff9-bdd7-ac3ade630fa4', 12, 'SHORT_ANSWER', 'READING', 4, $md$### Question 12

Questions 7-13
Questions 7-13
Answer the questions below.
Choose
NO MORE THAN THREE WORDS AND/OR A NUMBER
from the passage for each answer.
Write your answers in boxes 20-26 on your answer sheet.
7.
What is the important feature owned by the modem engine since the 19th century?
7
8.
What did a car symbolize to the rich at the very beginning of this century?
8
9.
How long did Ford assembly line take to produce a car?
9
10.
What is the major historical event that led American cars to suffer when competing with Japanese imported cars?
10
11.
What do people call the Mazda car which was designed under the front wheel engine?
11
12.
What has greatly increased with the computerised engine management systems in modem society?
12
13.
What factor is blamed for contributing to pollution, climate change and global warming?
13

12. What has greatly increased with the computerised engine management systems in modem society? 12 ____$md$, NULL, ARRAY['.*fuel.*power.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('069fb09c-bbb7-5939-aea9-d11c3a5f7dfc', 'e440205b-05c4-5ff9-bdd7-ac3ade630fa4', 13, 'SHORT_ANSWER', 'READING', 4, $md$### Question 13

Questions 7-13
Questions 7-13
Answer the questions below.
Choose
NO MORE THAN THREE WORDS AND/OR A NUMBER
from the passage for each answer.
Write your answers in boxes 20-26 on your answer sheet.
7.
What is the important feature owned by the modem engine since the 19th century?
7
8.
What did a car symbolize to the rich at the very beginning of this century?
8
9.
How long did Ford assembly line take to produce a car?
9
10.
What is the major historical event that led American cars to suffer when competing with Japanese imported cars?
10
11.
What do people call the Mazda car which was designed under the front wheel engine?
11
12.
What has greatly increased with the computerised engine management systems in modem society?
12
13.
What factor is blamed for contributing to pollution, climate change and global warming?
13

13. What factor is blamed for contributing to pollution, climate change and global warming? 13 ____$md$, NULL, ARRAY['.*toxic.*gas.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('2a8618bf-6218-55ae-a112-c90bf7419398', 'e440205b-05c4-5ff9-bdd7-ac3ade630fa4', 14, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 14

Question 14
Question 14
Choose the correct letter, A, B, C or D.
Write the correct letter in box 27 on your answer sheet.
14. What is the main idea of the passage?
A
The influence of the cars on the environment
B
The historical development and innovation in car designs
C
The beginning of the modem designed gasoline engines
D
The history of human and the Auto industry

Choose the correct letter, A, B, C or D.$md$, NULL);

COMMIT;
