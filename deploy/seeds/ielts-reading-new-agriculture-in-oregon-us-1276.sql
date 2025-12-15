BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-new-agriculture-in-oregon-us-1276'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-new-agriculture-in-oregon-us-1276';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-new-agriculture-in-oregon-us-1276';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-new-agriculture-in-oregon-us-1276';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('da2e68a5-cde9-5fb8-b933-1d4b76de1999', 'ielts-reading-new-agriculture-in-oregon-us-1276', $t$New Agriculture in Oregon, US$t$, $md$## New Agriculture in Oregon, US

Nguồn:
- Test: https://mini-ielts.com/1276/reading/new-agriculture-in-oregon-us
- Solution: https://mini-ielts.com/1276/view-solution/reading/new-agriculture-in-oregon-us$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('cf0896df-73ba-5671-a192-affcfb60aa2d', 'da2e68a5-cde9-5fb8-b933-1d4b76de1999', 1, $t$Reading — New Agriculture in Oregon, US$t$, $md$Read the passage and answer questions **1–13**.

### Passage: New Agriculture in Oregon, US

A

Onion growers in eastern Oregon are adopting a system that saves water and keeps topsoil in place while producing the highest quality “super-colossal” onions. Pear growers in southern Oregon have reduced their use of some of the most toxic pesticides by up to two-thirds, and are still producing top-quality pear. Range managers throughout the state have controlled the poisonous weed tansy ragwort with insect predators and saved the Oregon livestock industry up to $4.8 million a year.

B

These are some of the results Oregon growers have achieved in collaboration with Oregon State University (OSU) researchers as they test new farming methods including integrated pest management (IPM). Nationwide, however, IPM has not delivered results comparable to those in Oregon. A recent U.S General Accounting Office (GAO) report indicates that while integrated pest management can result in dramatically reduced pesticide use, the federal government has been lacking in effectively promoting that goal and implementing IPM. Farmers also blame the government for not making the new options of pest management attractive. “Wholesale changes in the way that farmers control the pests on their farms is an expensive business.” Tony Brown, of the National Farmers Association, says. “If the farmers are given tax breaks to offset the expenditure, then they would willingly accept the new practices.” The report goes on to note that even though the use of the riskiest pesticides has declined nationwide, they still make up more than 40 percent of all pesticides used today; and national pesticide use has risen by 40 million kilograms since 1992. “Our food supply remains the safest and highest quality on Earth but we continue to overdose our farmland with powerful and toxic pesticides and to under-use the safe and effective alternatives,” charged Patrick Leahy, who commissioned the report. Green action groups disagree about the safety issue. “There is no way that habitual consumption of foodstuffs grown using toxic chemical of the nature found on today’s farms can be healthy for consumers,” noted Bill Bowler, spokesman for Green Action, one of many lobbyists interested in this issue.

C

The GAO report singles out Oregon’s apple and pear producers who have used the new IPM techniques with growing success. Although Oregon is clearly ahead of the nation, scientists at OSU are taking the Government Accounting Office criticisms seriously. “We must continue to develop effective alternative practices that will reduce environmental hazards and produce high-quality products,” said Paul Jepson, a professor of entomology at OSU and new director of

D

OSU’s Integrated Plant Protection Centre (IPPC). The IPPC brings together scientists from OSU’s Agricultural Experiment Station, OSU Extension service, the U.S. Department of Agriculture and Oregon farmers to help develop agricultural systems that will save water and soil, and reduce pesticides. In response to the GAO report, the Centre is putting even more emphasis on integrating research and farming practices to improve Oregon agriculture environmentally and economically.

E

“The GAO report criticizes agencies for not clearly communicating the goals of IPM,” said Jepson. “Our challenge is to greatly improve the communication to and from growers, to learn what works and what doesn’t. the work coming from OSU researchers must be adopted in the field and not simply languish in scientific journals.”

F

In Oregon, growers and scientists are working together to instigate new practices. For example, a few years ago scientists at OSU’s Malheur Experiment Station began testing a new drip irrigation system to replace old ditches that wasted water and washed soil and fertilizer into streams. The new system cut water and fertilizer use by half kept topsoil in place and protected water quality.

G

In addition, the new system produced crops of very large onions, rated “super-colossal” and highly valued by the restaurant industry and food processors. Art Pimms, one of the researchers at Malheur comments: “Growers are finding that when they adopt more environmentally benign practices, they can have excellent results. The new practices benefit the environment and give the growers their success.”

H

OSU researcher in Malheur next tested straw mulch and found that it successfully held soil in place and kept the ground moist with less irrigation. In addition, and unexpectedly, the scientists found that the mulched soil created a home for beneficial beetles and spiders that prey on onion thrips – a notorious pest in commercial onion fields – a discovery that could reduce the need for pesticides. “I would never have believed that we could replace the artificial pest controls that we had before and still keep our good results,” commented Steve Black, a commercial onion farmer in Oregon, “but instead we have actually surpassed expectations.”

I

OSU researchers throughout the state have been working to reduce dependence on broad-spectrum chemical spays that are toxic to many kinds of organisms, including humans. “Consumers are rightly putting more and more pressure on the industry to change its reliance on chemical pesticides, but they still want a picture-perfect product,” said Rick Hilton, an entomologist at OSU’s Southern Oregon Research and Extension Centre, where researches help pear growers reduce the need for highly toxic pesticides. Picture perfect pears are an important product in Oregon and traditionally they have required lots of chemicals. In recent years, the industry has faced stiff competition from overseas producers, so any new methods that growers adopt must make sense economically as well as environmentally. Hilton is testing a growth regulator that interferes with the molting of codling moth larvae. Another study used pheromone dispensers to disrupt codling moth mating. These and other methods of integrated pest management have allowed pear growers to reduce their use of organophosphates by two-thirds and reduce all other synthetic pesticides by even more and still produce top-quality pears. These and other studies around the state are part of the effort of the IPPC to find alternative farming practices that benefit both the economy and the environment.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('b060ce53-f9c2-57c6-9da1-57cceaf4f38c', 'cf0896df-73ba-5671-a192-affcfb60aa2d', 1, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 1

Questions 1-8
Questions 1-8
Use the information in the passage to match the people (listed
A-G
) with opinions or deeds below.
Write the appropriate letters
A-G
in boxes
1-8
on your answer sheet.
NB
You may use any letter more than once
A
Tony Brown
E
Art Pimms
B
Patrick Leahy
F
Steve Black
C
Bill Bowler
G
Rick Hilton
D
Paul Jepson
1
There is a double-advantage to the new techniques.
2
The work on developing these alternative techniques is not finished.
3
Eating food that has had chemicals used in its production is dangerous to our health.
4
Changing current farming methods into a new one is not a cheap process.
5
Results have exceeded the anticipated goal.
6
The research done should be translated into practical projects.
7
The U.S. produces the best food in the world nowadays.
8
Expectations of end-users of agricultural products affect the products.

1 ____ There is a double-advantage to the new techniques.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0acf4baf-cca8-560c-9e28-473826c493c6', 'b060ce53-f9c2-57c6-9da1-57cceaf4f38c', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3dd2a042-5adb-573e-b8fc-341aceab1bfb', 'b060ce53-f9c2-57c6-9da1-57cceaf4f38c', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e67b19de-bc44-5294-abe8-11304bc34784', 'b060ce53-f9c2-57c6-9da1-57cceaf4f38c', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2d2a4f79-dbaa-5c7c-acff-0b02e60cc8c5', 'b060ce53-f9c2-57c6-9da1-57cceaf4f38c', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7df59661-d578-500d-8c3f-4beb8bd0377a', 'b060ce53-f9c2-57c6-9da1-57cceaf4f38c', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('52894419-63c4-5baf-920e-e7512f198fb3', 'b060ce53-f9c2-57c6-9da1-57cceaf4f38c', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3fb6d44c-697e-50f2-8aa0-67138b19a77b', 'b060ce53-f9c2-57c6-9da1-57cceaf4f38c', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('2200d298-4063-55af-a81b-5a05a1c756d1', 'cf0896df-73ba-5671-a192-affcfb60aa2d', 2, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 2

Questions 1-8
Questions 1-8
Use the information in the passage to match the people (listed
A-G
) with opinions or deeds below.
Write the appropriate letters
A-G
in boxes
1-8
on your answer sheet.
NB
You may use any letter more than once
A
Tony Brown
E
Art Pimms
B
Patrick Leahy
F
Steve Black
C
Bill Bowler
G
Rick Hilton
D
Paul Jepson
1
There is a double-advantage to the new techniques.
2
The work on developing these alternative techniques is not finished.
3
Eating food that has had chemicals used in its production is dangerous to our health.
4
Changing current farming methods into a new one is not a cheap process.
5
Results have exceeded the anticipated goal.
6
The research done should be translated into practical projects.
7
The U.S. produces the best food in the world nowadays.
8
Expectations of end-users of agricultural products affect the products.

2 ____ The work on developing these alternative techniques is not finished.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('38d708fb-b296-527d-8a88-e620c7791410', '2200d298-4063-55af-a81b-5a05a1c756d1', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e99a7a02-12ab-57cc-adbb-1f8f801630ce', '2200d298-4063-55af-a81b-5a05a1c756d1', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0d8d1327-9d28-5af8-8739-a24a68c206eb', '2200d298-4063-55af-a81b-5a05a1c756d1', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0588b383-1b86-5510-af59-80bd0645e69f', '2200d298-4063-55af-a81b-5a05a1c756d1', 4, $md$D$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('91cf4c4b-b74a-5c4b-8e90-a4511a70f033', '2200d298-4063-55af-a81b-5a05a1c756d1', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d3d4d23d-5165-57e9-bf19-cbb5b1d38127', '2200d298-4063-55af-a81b-5a05a1c756d1', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0fe1281e-fe11-5582-b706-60a1cb4ba828', '2200d298-4063-55af-a81b-5a05a1c756d1', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('0f19ec4b-12ad-5176-8dd7-a3788c5cc1fd', 'cf0896df-73ba-5671-a192-affcfb60aa2d', 3, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 3

Questions 1-8
Questions 1-8
Use the information in the passage to match the people (listed
A-G
) with opinions or deeds below.
Write the appropriate letters
A-G
in boxes
1-8
on your answer sheet.
NB
You may use any letter more than once
A
Tony Brown
E
Art Pimms
B
Patrick Leahy
F
Steve Black
C
Bill Bowler
G
Rick Hilton
D
Paul Jepson
1
There is a double-advantage to the new techniques.
2
The work on developing these alternative techniques is not finished.
3
Eating food that has had chemicals used in its production is dangerous to our health.
4
Changing current farming methods into a new one is not a cheap process.
5
Results have exceeded the anticipated goal.
6
The research done should be translated into practical projects.
7
The U.S. produces the best food in the world nowadays.
8
Expectations of end-users of agricultural products affect the products.

3 ____ Eating food that has had chemicals used in its production is dangerous to our health.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c3621f6b-e136-5942-82fe-cd3fb8455cbf', '0f19ec4b-12ad-5176-8dd7-a3788c5cc1fd', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('22564c83-8dea-5963-9e92-d91739ff5299', '0f19ec4b-12ad-5176-8dd7-a3788c5cc1fd', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2cfd4a00-2e72-50be-ab33-e1f9b6713265', '0f19ec4b-12ad-5176-8dd7-a3788c5cc1fd', 3, $md$C$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ba899087-c10b-5b2b-8bd5-a6ac66070ffe', '0f19ec4b-12ad-5176-8dd7-a3788c5cc1fd', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7b6acdbf-514d-5ac6-af74-fa05710450cc', '0f19ec4b-12ad-5176-8dd7-a3788c5cc1fd', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2c867617-9179-5798-8f65-9382c60e5abd', '0f19ec4b-12ad-5176-8dd7-a3788c5cc1fd', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4596bded-f915-5f1c-9bf1-9a06694f354f', '0f19ec4b-12ad-5176-8dd7-a3788c5cc1fd', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('5d1a16f9-ed8f-5be4-9237-bba54724919e', 'cf0896df-73ba-5671-a192-affcfb60aa2d', 4, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 4

Questions 1-8
Questions 1-8
Use the information in the passage to match the people (listed
A-G
) with opinions or deeds below.
Write the appropriate letters
A-G
in boxes
1-8
on your answer sheet.
NB
You may use any letter more than once
A
Tony Brown
E
Art Pimms
B
Patrick Leahy
F
Steve Black
C
Bill Bowler
G
Rick Hilton
D
Paul Jepson
1
There is a double-advantage to the new techniques.
2
The work on developing these alternative techniques is not finished.
3
Eating food that has had chemicals used in its production is dangerous to our health.
4
Changing current farming methods into a new one is not a cheap process.
5
Results have exceeded the anticipated goal.
6
The research done should be translated into practical projects.
7
The U.S. produces the best food in the world nowadays.
8
Expectations of end-users of agricultural products affect the products.

4 ____ Changing current farming methods into a new one is not a cheap process.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('09c66d52-b4ad-57fd-85cc-8149e1aba1bc', '5d1a16f9-ed8f-5be4-9237-bba54724919e', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b666655b-74e1-59d2-9968-4deb9230df97', '5d1a16f9-ed8f-5be4-9237-bba54724919e', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5c9e9875-4286-575d-8d19-28e1b94404fc', '5d1a16f9-ed8f-5be4-9237-bba54724919e', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b763c08b-42f6-5d98-b9b0-ea307e63b9d1', '5d1a16f9-ed8f-5be4-9237-bba54724919e', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('be237b7b-35dc-5415-8d9c-4cffa65b95a9', '5d1a16f9-ed8f-5be4-9237-bba54724919e', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5b8ab293-18e7-50c8-a215-3268135ab0a9', '5d1a16f9-ed8f-5be4-9237-bba54724919e', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1f69c831-ba2c-51ab-862a-47bb11e02dc9', '5d1a16f9-ed8f-5be4-9237-bba54724919e', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('97826f4c-f5d9-502c-a739-481acfad73c7', 'cf0896df-73ba-5671-a192-affcfb60aa2d', 5, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 5

Questions 1-8
Questions 1-8
Use the information in the passage to match the people (listed
A-G
) with opinions or deeds below.
Write the appropriate letters
A-G
in boxes
1-8
on your answer sheet.
NB
You may use any letter more than once
A
Tony Brown
E
Art Pimms
B
Patrick Leahy
F
Steve Black
C
Bill Bowler
G
Rick Hilton
D
Paul Jepson
1
There is a double-advantage to the new techniques.
2
The work on developing these alternative techniques is not finished.
3
Eating food that has had chemicals used in its production is dangerous to our health.
4
Changing current farming methods into a new one is not a cheap process.
5
Results have exceeded the anticipated goal.
6
The research done should be translated into practical projects.
7
The U.S. produces the best food in the world nowadays.
8
Expectations of end-users of agricultural products affect the products.

5 ____ Results have exceeded the anticipated goal.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bf40b098-e6a5-517a-86a3-7ce094569659', '97826f4c-f5d9-502c-a739-481acfad73c7', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f0df71aa-e342-527b-bd08-42b373140f2f', '97826f4c-f5d9-502c-a739-481acfad73c7', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a1431131-1e2b-533b-855b-31d29ec06cfd', '97826f4c-f5d9-502c-a739-481acfad73c7', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bf60304b-8a69-54ba-8874-185b201e756f', '97826f4c-f5d9-502c-a739-481acfad73c7', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1577d1ba-5841-51ad-b0f1-26b6fb53031a', '97826f4c-f5d9-502c-a739-481acfad73c7', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('82741d53-6fb5-55e1-9f6b-df172cb7a561', '97826f4c-f5d9-502c-a739-481acfad73c7', 6, $md$F$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e5a43390-33da-5bf6-a91a-b98cf7a20adc', '97826f4c-f5d9-502c-a739-481acfad73c7', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('812546b2-25bc-5af4-83c9-4f643adee265', 'cf0896df-73ba-5671-a192-affcfb60aa2d', 6, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 6

Questions 1-8
Questions 1-8
Use the information in the passage to match the people (listed
A-G
) with opinions or deeds below.
Write the appropriate letters
A-G
in boxes
1-8
on your answer sheet.
NB
You may use any letter more than once
A
Tony Brown
E
Art Pimms
B
Patrick Leahy
F
Steve Black
C
Bill Bowler
G
Rick Hilton
D
Paul Jepson
1
There is a double-advantage to the new techniques.
2
The work on developing these alternative techniques is not finished.
3
Eating food that has had chemicals used in its production is dangerous to our health.
4
Changing current farming methods into a new one is not a cheap process.
5
Results have exceeded the anticipated goal.
6
The research done should be translated into practical projects.
7
The U.S. produces the best food in the world nowadays.
8
Expectations of end-users of agricultural products affect the products.

6 ____ The research done should be translated into practical projects.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bcb2c59d-430a-5b85-a197-b7012f175029', '812546b2-25bc-5af4-83c9-4f643adee265', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4d145e47-acf9-5998-8e91-d0c34a69a18c', '812546b2-25bc-5af4-83c9-4f643adee265', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0cc4597c-5de3-59c1-9a50-2c09d2a8b82d', '812546b2-25bc-5af4-83c9-4f643adee265', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('83828eb6-875e-5e0d-b87e-7d4fd2e207b5', '812546b2-25bc-5af4-83c9-4f643adee265', 4, $md$D$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b5d2aa7e-bb1f-5ca4-83fa-587a0d80be96', '812546b2-25bc-5af4-83c9-4f643adee265', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0609ffa2-6890-51fe-8994-1a35d5a7ee68', '812546b2-25bc-5af4-83c9-4f643adee265', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f319603b-deac-51f5-83c5-009c92166c02', '812546b2-25bc-5af4-83c9-4f643adee265', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('9dcb451c-9b5a-57c1-9e94-cb2e923806a2', 'cf0896df-73ba-5671-a192-affcfb60aa2d', 7, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 7

Questions 1-8
Questions 1-8
Use the information in the passage to match the people (listed
A-G
) with opinions or deeds below.
Write the appropriate letters
A-G
in boxes
1-8
on your answer sheet.
NB
You may use any letter more than once
A
Tony Brown
E
Art Pimms
B
Patrick Leahy
F
Steve Black
C
Bill Bowler
G
Rick Hilton
D
Paul Jepson
1
There is a double-advantage to the new techniques.
2
The work on developing these alternative techniques is not finished.
3
Eating food that has had chemicals used in its production is dangerous to our health.
4
Changing current farming methods into a new one is not a cheap process.
5
Results have exceeded the anticipated goal.
6
The research done should be translated into practical projects.
7
The U.S. produces the best food in the world nowadays.
8
Expectations of end-users of agricultural products affect the products.

7 ____ The U.S. produces the best food in the world nowadays.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d57d0c56-05d9-59d0-8741-20407bbafa73', '9dcb451c-9b5a-57c1-9e94-cb2e923806a2', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6d5b02bb-f923-5115-9550-51cd4503721a', '9dcb451c-9b5a-57c1-9e94-cb2e923806a2', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0a067fd1-ac3c-5c86-8ad8-6cc328a63d70', '9dcb451c-9b5a-57c1-9e94-cb2e923806a2', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8b2d1b35-b341-58bb-bf44-01bee64a4273', '9dcb451c-9b5a-57c1-9e94-cb2e923806a2', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('88845654-39e1-5840-8f7d-8f7848babe8d', '9dcb451c-9b5a-57c1-9e94-cb2e923806a2', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('195ade3a-7eb6-5a38-8b3c-6bc7c14eedaa', '9dcb451c-9b5a-57c1-9e94-cb2e923806a2', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7b2df5ea-cae8-5627-ae96-b3a7625c278c', '9dcb451c-9b5a-57c1-9e94-cb2e923806a2', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('88de4beb-5e32-5ea7-b22d-b72ba47b8f3b', 'cf0896df-73ba-5671-a192-affcfb60aa2d', 8, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 8

Questions 1-8
Questions 1-8
Use the information in the passage to match the people (listed
A-G
) with opinions or deeds below.
Write the appropriate letters
A-G
in boxes
1-8
on your answer sheet.
NB
You may use any letter more than once
A
Tony Brown
E
Art Pimms
B
Patrick Leahy
F
Steve Black
C
Bill Bowler
G
Rick Hilton
D
Paul Jepson
1
There is a double-advantage to the new techniques.
2
The work on developing these alternative techniques is not finished.
3
Eating food that has had chemicals used in its production is dangerous to our health.
4
Changing current farming methods into a new one is not a cheap process.
5
Results have exceeded the anticipated goal.
6
The research done should be translated into practical projects.
7
The U.S. produces the best food in the world nowadays.
8
Expectations of end-users of agricultural products affect the products.

8 ____ Expectations of end-users of agricultural products affect the products.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('171815f5-397a-50ca-ba13-7db5a9dd01c4', '88de4beb-5e32-5ea7-b22d-b72ba47b8f3b', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('348f22ed-00e2-53bf-9b24-5d12db00992b', '88de4beb-5e32-5ea7-b22d-b72ba47b8f3b', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e42ee3a5-86fe-5048-9fb4-226f0e5b688a', '88de4beb-5e32-5ea7-b22d-b72ba47b8f3b', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('af61a947-88b3-5d55-8727-fd593af8d5cf', '88de4beb-5e32-5ea7-b22d-b72ba47b8f3b', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('12db5a7c-c026-507e-96c2-46beb39ec655', '88de4beb-5e32-5ea7-b22d-b72ba47b8f3b', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('696a7bd4-d4ab-5992-b2f6-bbb0c3298a3d', '88de4beb-5e32-5ea7-b22d-b72ba47b8f3b', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9780ff69-2ba3-584b-8585-c9269ee498dd', '88de4beb-5e32-5ea7-b22d-b72ba47b8f3b', 7, $md$G$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('5044b1f1-b8d1-54f7-9892-20d38846d7d3', 'cf0896df-73ba-5671-a192-affcfb60aa2d', 9, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 9

Questions 9-13
Questions 9-13
Do the following statements agree with the information given in Reading Passage 1?
In boxes
9-13
on your answer sheet, write
YES
if the statement is true
NO
if the statement is false
NOT GIVEN
if the information is not given in the passage
9
Integrated Pest Management has generally been regarded as a success in across the US.
10
Oregon farmers of apples and pears have been promoted as successful examples of Integrated Pest Management.
11
The IPPC uses scientists from different organisations globally
12
Straw mulch experiments produced unplanned benefits.
13
The apple industry is now facing a lot of competition from abroad.

9 ____ Integrated Pest Management has generally been regarded as a success in across the US.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('67a7346c-633e-546c-a059-473d95fdcd20', '5044b1f1-b8d1-54f7-9892-20d38846d7d3', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('04615bde-4fb7-5fac-a474-df9dad0e5c92', '5044b1f1-b8d1-54f7-9892-20d38846d7d3', 2, $md$NO$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2b157b43-c194-5b47-904a-a5b0b52b5f70', '5044b1f1-b8d1-54f7-9892-20d38846d7d3', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('c3ec28ec-2c96-53c3-b219-74a6d779c1a2', 'cf0896df-73ba-5671-a192-affcfb60aa2d', 10, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 10

Questions 9-13
Questions 9-13
Do the following statements agree with the information given in Reading Passage 1?
In boxes
9-13
on your answer sheet, write
YES
if the statement is true
NO
if the statement is false
NOT GIVEN
if the information is not given in the passage
9
Integrated Pest Management has generally been regarded as a success in across the US.
10
Oregon farmers of apples and pears have been promoted as successful examples of Integrated Pest Management.
11
The IPPC uses scientists from different organisations globally
12
Straw mulch experiments produced unplanned benefits.
13
The apple industry is now facing a lot of competition from abroad.

10 ____ Oregon farmers of apples and pears have been promoted as successful examples of Integrated Pest Management.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('33935f96-e354-5848-ab7e-7fb67ed7ac96', 'c3ec28ec-2c96-53c3-b219-74a6d779c1a2', 1, $md$YES$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3bb50232-eb20-557d-8038-257701b55053', 'c3ec28ec-2c96-53c3-b219-74a6d779c1a2', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2255fac6-e0fa-576c-bff6-90f9ec3c2adb', 'c3ec28ec-2c96-53c3-b219-74a6d779c1a2', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('96d9ecb2-c853-53cf-8b2d-0e9abf342680', 'cf0896df-73ba-5671-a192-affcfb60aa2d', 11, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 11

Questions 9-13
Questions 9-13
Do the following statements agree with the information given in Reading Passage 1?
In boxes
9-13
on your answer sheet, write
YES
if the statement is true
NO
if the statement is false
NOT GIVEN
if the information is not given in the passage
9
Integrated Pest Management has generally been regarded as a success in across the US.
10
Oregon farmers of apples and pears have been promoted as successful examples of Integrated Pest Management.
11
The IPPC uses scientists from different organisations globally
12
Straw mulch experiments produced unplanned benefits.
13
The apple industry is now facing a lot of competition from abroad.

11 ____ The IPPC uses scientists from different organisations globally$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8d17e185-c216-59d9-854e-5faf509feddb', '96d9ecb2-c853-53cf-8b2d-0e9abf342680', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('629ce91e-be8c-5201-82a7-0b09962a0b70', '96d9ecb2-c853-53cf-8b2d-0e9abf342680', 2, $md$NO$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c1d43db8-8204-547d-a875-0cdc64da5c9f', '96d9ecb2-c853-53cf-8b2d-0e9abf342680', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('c3792fbe-0b51-5c46-a957-910af7db26fb', 'cf0896df-73ba-5671-a192-affcfb60aa2d', 12, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 12

Questions 9-13
Questions 9-13
Do the following statements agree with the information given in Reading Passage 1?
In boxes
9-13
on your answer sheet, write
YES
if the statement is true
NO
if the statement is false
NOT GIVEN
if the information is not given in the passage
9
Integrated Pest Management has generally been regarded as a success in across the US.
10
Oregon farmers of apples and pears have been promoted as successful examples of Integrated Pest Management.
11
The IPPC uses scientists from different organisations globally
12
Straw mulch experiments produced unplanned benefits.
13
The apple industry is now facing a lot of competition from abroad.

12 ____ Straw mulch experiments produced unplanned benefits.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d93155c1-5641-5d2c-90a2-ee640375bcdc', 'c3792fbe-0b51-5c46-a957-910af7db26fb', 1, $md$YES$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6ef18086-9b09-53ff-bc51-12da8791c4ee', 'c3792fbe-0b51-5c46-a957-910af7db26fb', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('799a25a1-3312-57d7-9b6b-8b259cc8560a', 'c3792fbe-0b51-5c46-a957-910af7db26fb', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('4d776504-efb1-5688-aec5-1d7dbd554742', 'cf0896df-73ba-5671-a192-affcfb60aa2d', 13, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 13

Questions 9-13
Questions 9-13
Do the following statements agree with the information given in Reading Passage 1?
In boxes
9-13
on your answer sheet, write
YES
if the statement is true
NO
if the statement is false
NOT GIVEN
if the information is not given in the passage
9
Integrated Pest Management has generally been regarded as a success in across the US.
10
Oregon farmers of apples and pears have been promoted as successful examples of Integrated Pest Management.
11
The IPPC uses scientists from different organisations globally
12
Straw mulch experiments produced unplanned benefits.
13
The apple industry is now facing a lot of competition from abroad.

13 ____ The apple industry is now facing a lot of competition from abroad.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('066b9c01-0ac8-53f2-8052-69a94dda7c0a', '4d776504-efb1-5688-aec5-1d7dbd554742', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2d537b40-8983-5099-ab9b-69a72fdcf0ed', '4d776504-efb1-5688-aec5-1d7dbd554742', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('090d9a05-7a92-5451-9178-92fe2e958a7d', '4d776504-efb1-5688-aec5-1d7dbd554742', 3, $md$NOT GIVEN$md$, true);

COMMIT;
