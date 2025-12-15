BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-hunting-perfume-in-madagascar-1285'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-hunting-perfume-in-madagascar-1285';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-hunting-perfume-in-madagascar-1285';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-hunting-perfume-in-madagascar-1285';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('dbfe7e09-0421-5412-92bf-1e7d6de5201a', 'ielts-reading-hunting-perfume-in-madagascar-1285', $t$Hunting Perfume in Madagascar$t$, $md$## Hunting Perfume in Madagascar

Nguồn:
- Test: https://mini-ielts.com/1285/reading/hunting-perfume-in-madagascar
- Solution: https://mini-ielts.com/1285/view-solution/reading/hunting-perfume-in-madagascar$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('0942c126-0522-5510-8d6b-66ebc700bd59', 'dbfe7e09-0421-5412-92bf-1e7d6de5201a', 1, $t$Reading — Hunting Perfume in Madagascar$t$, $md$Read the passage and answer questions **1–13**.

### Passage: Hunting Perfume in Madagascar

A . Ever since the unguentari plied their trade in ancient Rome, perfumers have to keep abreast of changing fashions. These days they have several thousand ingredients to choose from when creating new scents, but there is always demand for new combinations. The bigger the “palette7 of smells, the better the perfumer’s chance of creating something fresh and appealing. Even with everyday products such as shampoo and soap, kitchen cleaners and washing powders, consumers are becoming increasingly fussy. And many of today’s fragrances have to survive tougher treatment than ever before, resisting the destructive power of bleach or a high temperature wash cycle. Chemists can create new smells from synthetic molecules, and a growing number of the odours on the perfumer’s palette are artificial. But nature has been in the business far longer.

B . The island of Madagascar is an evolutionary hot spot; 85% of its plants are unique, making it an ideal source for novel fragrances. Last October, Quest International, a company that develops fragrances for everything from the most delicate perfumes to cleaning products, sent an expedition to Madagascar in pursuit of some of nature’s most novel fragrances. With some simple technology, borrowed from the pollution monitoring industry, and a fair amount of ingenuity, the perfume hunters bagged 20 promising new aromas in the Madagascan rainforest. Each day the team set out from their “hotel”—a wooden hut lit by kerosene lamps, and trailed up and down paths and animal tracks, exploring the thick vegetation up to 10 meters on either side of the trail. Some smells came from obvious places, often big showy flowers within easy reach- Others were harder to pin down. “Often it was the very small flowers that were much more interesting, says Clery. After the luxuriance of the rainforest, the little-known island of Nosy Hara was a stark, dry place geologically and biologically very different from the mainland, “Apart from two beaches, the rest of the Island Is impenetrable, except by hacking through the bush, says Clery. One of the biggest prizes here was a sweet- smelling sap weeping from the gnarled branches of some ancient shrubby trees in the parched Interior. So far no one has been able to identify the plant.

C . With most flowers or fruits, the hunters used a technique originally designed to trap and identify air pollutants. The technique itself is relatively simple. A glass bell jar or flask Ỉ S fitted over the flower. The fragrance molecules are trapped in this “headspace” and can be extracted by pumping the air out over a series of filters which absorb different types of volatile molecules. Back home in the laboratory, the molecules are flushed out of the filters and injected into a gas chromatograph for analysis. If it Is Impossible to attach the headspace gear, hunters fix an absorbent probe close to the source of the smell. The probe looks something like a hypodermic syringe, except that the ‘needle’ is made of silicone rubber which soaks up molecules from the air. After a few hours, the hunters retract the rubber needle and seal the tube, keeping the odour molecules inside until they can.be injected into the gas chromatograph in the laboratory.

D . Some of the most promising fragrances were those given, off by resins that oozed from the bark of trees. Resins are the source of many traditional perfumes, including frankincense and myrrh. The most exciting resin came from a Calophyllum tree, which produces a strongly scented medicinal oil. The sap of this Calophyllum smelt rich and aromatic, a little like church incense. But It also smelt of something the fragrance industry has learnt to live without castoreum a substance extracted from the musk glands of beavers and once a key ingredient in many perfumes. The company does not use animal products any longer, but Ã was wonderful to find a tree with an animal smell.

E . The group also set out from the island to capture the smell of coral reefs. Odors that conjure up sun kissed seas are highly sought after by the perfume industry. “From the ocean, the only thing we have is seaweed, and that has a dark and heavy aroma. We hope to find something unique among the corals,” says Dir. The challenge for the hunters was to extract a smell from water rather than air. This was an opportunity to try Clery’s new “aquaspace” apparatus a set of filters that work underwater. On Nosy Hara, jars were fixed over knobs of coral about 2 meters down and water pumped out over the absorbent filters. So what does coral smell like? “It’s a bit like lobster and crab,” says Clery. The team’s task now is to recreate the best of then captured smells. First they must identify the molecules that make up each fragrance. Some ingredients may be quite common chemicals. But some may be completely novel, or they may be too complex or expensive to make in the lab. The challenge then is to conjure up the fragrances with more readily available materials. “We can avoid the need to import plants from the rainforest by creating the smell with a different set of chemicals from those in the original material,” says Clery. “If we get it right, you can sniff the sample and it will transport you straight back to the moment you smelt it in the rainforest.”$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('1c0de644-43f2-5ab6-8415-6a1468192b9c', '0942c126-0522-5510-8d6b-66ebc700bd59', 1, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 1

Questions 1-5
Questions 1-5
The reading passage has seven paragraphs A-E
Which paragraphs contains the following details Write the correct number,
A-E
, in boxes
1-5
on your answer sheet.
NB You may use any letter more than once.
1
One currently preferred spot to pick up plants for novel finding
2
A new task seems to be promising yet producing limited finding in fragrance source
3
The demanding conditions for fragrance to endure
4
A substitute for substance no longer available to the perfume manufacture
5
Description of an outdoor expedition on land chasing new fragrances

1 ____ One currently preferred spot to pick up plants for novel finding$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bdb832e7-e2e0-5f2c-9ed4-261caecced15', '1c0de644-43f2-5ab6-8415-6a1468192b9c', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0bd05514-5f79-5ebc-b30e-94d41f0e68fa', '1c0de644-43f2-5ab6-8415-6a1468192b9c', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('06de42f7-5a14-572b-af8e-0635267fd6ca', '1c0de644-43f2-5ab6-8415-6a1468192b9c', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('abe8ff7e-ffea-579b-9bf9-66170dba11c0', '1c0de644-43f2-5ab6-8415-6a1468192b9c', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0c939b5c-3b45-5df1-9899-23e949c6abe9', '1c0de644-43f2-5ab6-8415-6a1468192b9c', 5, $md$E$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('a5c50f23-6c61-5361-a0f4-1f255abd137c', '0942c126-0522-5510-8d6b-66ebc700bd59', 2, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 2

Questions 1-5
Questions 1-5
The reading passage has seven paragraphs A-E
Which paragraphs contains the following details Write the correct number,
A-E
, in boxes
1-5
on your answer sheet.
NB You may use any letter more than once.
1
One currently preferred spot to pick up plants for novel finding
2
A new task seems to be promising yet producing limited finding in fragrance source
3
The demanding conditions for fragrance to endure
4
A substitute for substance no longer available to the perfume manufacture
5
Description of an outdoor expedition on land chasing new fragrances

2 ____ A new task seems to be promising yet producing limited finding in fragrance source$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a8595077-5fba-5af8-a183-e0ef52bf59aa', 'a5c50f23-6c61-5361-a0f4-1f255abd137c', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('89b465e8-b556-519b-bc6d-0d87e890620c', 'a5c50f23-6c61-5361-a0f4-1f255abd137c', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d7a81f55-7961-5b02-9dbb-0d1e3bf2809f', 'a5c50f23-6c61-5361-a0f4-1f255abd137c', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7ed15d62-84c8-571b-a586-d98e6be42b14', 'a5c50f23-6c61-5361-a0f4-1f255abd137c', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('56a2bde6-0c7b-59d0-903f-3f5a8dbca7ba', 'a5c50f23-6c61-5361-a0f4-1f255abd137c', 5, $md$E$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('edf4bcba-dfaa-5fb0-9bb0-9fe2df21d28a', '0942c126-0522-5510-8d6b-66ebc700bd59', 3, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 3

Questions 1-5
Questions 1-5
The reading passage has seven paragraphs A-E
Which paragraphs contains the following details Write the correct number,
A-E
, in boxes
1-5
on your answer sheet.
NB You may use any letter more than once.
1
One currently preferred spot to pick up plants for novel finding
2
A new task seems to be promising yet producing limited finding in fragrance source
3
The demanding conditions for fragrance to endure
4
A substitute for substance no longer available to the perfume manufacture
5
Description of an outdoor expedition on land chasing new fragrances

3 ____ The demanding conditions for fragrance to endure$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('461c200a-64c3-5a03-9f8f-f1203c938f27', 'edf4bcba-dfaa-5fb0-9bb0-9fe2df21d28a', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4c778287-c13b-56f4-9c7e-9d69b1bba15f', 'edf4bcba-dfaa-5fb0-9bb0-9fe2df21d28a', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('56aa4102-cd39-5cdf-b297-464fa3761f21', 'edf4bcba-dfaa-5fb0-9bb0-9fe2df21d28a', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1789dfd2-5c0b-57f4-9884-8f8809e17648', 'edf4bcba-dfaa-5fb0-9bb0-9fe2df21d28a', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3cc6d416-e9e2-5e46-ba48-9161d4812dbe', 'edf4bcba-dfaa-5fb0-9bb0-9fe2df21d28a', 5, $md$E$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('b427ba94-6a96-5d61-9d4f-ef39623118e5', '0942c126-0522-5510-8d6b-66ebc700bd59', 4, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 4

Questions 1-5
Questions 1-5
The reading passage has seven paragraphs A-E
Which paragraphs contains the following details Write the correct number,
A-E
, in boxes
1-5
on your answer sheet.
NB You may use any letter more than once.
1
One currently preferred spot to pick up plants for novel finding
2
A new task seems to be promising yet producing limited finding in fragrance source
3
The demanding conditions for fragrance to endure
4
A substitute for substance no longer available to the perfume manufacture
5
Description of an outdoor expedition on land chasing new fragrances

4 ____ A substitute for substance no longer available to the perfume manufacture$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cac9aca6-abc3-57b5-857c-bb76d350398a', 'b427ba94-6a96-5d61-9d4f-ef39623118e5', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('15c2b23d-7e8a-5a4b-805e-2d5250e608eb', 'b427ba94-6a96-5d61-9d4f-ef39623118e5', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5402f07d-6009-59ff-b5ba-1134eaa5703c', 'b427ba94-6a96-5d61-9d4f-ef39623118e5', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('785dcbf6-fe71-56ed-b1f1-a5ed320e6ae0', 'b427ba94-6a96-5d61-9d4f-ef39623118e5', 4, $md$D$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9145c151-e789-5795-9bca-1f562c0e55c2', 'b427ba94-6a96-5d61-9d4f-ef39623118e5', 5, $md$E$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('f0511802-31ac-5c50-9327-f4d0c8bb9019', '0942c126-0522-5510-8d6b-66ebc700bd59', 5, 'MATCHING_INFORMATION', 'READING', 3, $md$### Question 5

Questions 1-5
Questions 1-5
The reading passage has seven paragraphs A-E
Which paragraphs contains the following details Write the correct number,
A-E
, in boxes
1-5
on your answer sheet.
NB You may use any letter more than once.
1
One currently preferred spot to pick up plants for novel finding
2
A new task seems to be promising yet producing limited finding in fragrance source
3
The demanding conditions for fragrance to endure
4
A substitute for substance no longer available to the perfume manufacture
5
Description of an outdoor expedition on land chasing new fragrances

5 ____ Description of an outdoor expedition on land chasing new fragrances$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3dd000f2-da78-5747-9d5f-24331b61d1ff', 'f0511802-31ac-5c50-9327-f4d0c8bb9019', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('82c73521-a837-5f8d-90a7-c17fd2eb90c6', 'f0511802-31ac-5c50-9327-f4d0c8bb9019', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1c1e8491-f5b7-502c-8b4f-3cb0ee2400cc', 'f0511802-31ac-5c50-9327-f4d0c8bb9019', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('43432abc-9af5-5e4e-913d-4277e621446b', 'f0511802-31ac-5c50-9327-f4d0c8bb9019', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0130221f-ca46-5cd1-8c0f-fd479617dee1', 'f0511802-31ac-5c50-9327-f4d0c8bb9019', 5, $md$E$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('e1499d0a-dd86-5701-bde3-7c97ec1f4e04', '0942c126-0522-5510-8d6b-66ebc700bd59', 6, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 6

Questions 6-10
Questions 6-10
Do the following statements agree with the information given in
Reading Passage
? In boxes
6-10
on your answer sheet, write
TRUE
if the statement is true
FALSE
if the statement is false
NOT GIVEN
if the information is not given in the
passage
2
6
Manufacturers can choose to use synthetic odors for the perfume nowadays
7
Madagascar is chosen to be a place for hunting plants which are rare in other parts of the world
8
Capturing the smell is one of the most important things for creating new aromas
9
The technique the hunters used to trap fragrance molecules is totally out of their ; ingenuity
10
Most customers prefer the perfume made of substance extracted from the musk I glands of animals

6 ____ Manufacturers can choose to use synthetic odors for the perfume nowadays$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9fd2b472-0490-5c55-934e-a3407eecb3e7', 'e1499d0a-dd86-5701-bde3-7c97ec1f4e04', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6fdc9f92-4787-52da-94e9-9a0af7e4b2c4', 'e1499d0a-dd86-5701-bde3-7c97ec1f4e04', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('42eb01f9-7b01-5265-a198-21b70b4c924a', 'e1499d0a-dd86-5701-bde3-7c97ec1f4e04', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('c7e70b8d-71a5-55a9-aa51-8aca92ddd5e5', '0942c126-0522-5510-8d6b-66ebc700bd59', 7, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 7

Questions 6-10
Questions 6-10
Do the following statements agree with the information given in
Reading Passage
? In boxes
6-10
on your answer sheet, write
TRUE
if the statement is true
FALSE
if the statement is false
NOT GIVEN
if the information is not given in the
passage
2
6
Manufacturers can choose to use synthetic odors for the perfume nowadays
7
Madagascar is chosen to be a place for hunting plants which are rare in other parts of the world
8
Capturing the smell is one of the most important things for creating new aromas
9
The technique the hunters used to trap fragrance molecules is totally out of their ; ingenuity
10
Most customers prefer the perfume made of substance extracted from the musk I glands of animals

7 ____ Madagascar is chosen to be a place for hunting plants which are rare in other parts of the world$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5becffba-3a7b-552f-b477-4f2b7daaf9ac', 'c7e70b8d-71a5-55a9-aa51-8aca92ddd5e5', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('daa327d2-bcdb-586a-9434-3a24a5ce24cc', 'c7e70b8d-71a5-55a9-aa51-8aca92ddd5e5', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('996aa602-08fc-5a39-ba1e-b199aab96a72', 'c7e70b8d-71a5-55a9-aa51-8aca92ddd5e5', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('f7cdad3f-f46d-54dd-ac97-4388c8c7784f', '0942c126-0522-5510-8d6b-66ebc700bd59', 8, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 8

Questions 6-10
Questions 6-10
Do the following statements agree with the information given in
Reading Passage
? In boxes
6-10
on your answer sheet, write
TRUE
if the statement is true
FALSE
if the statement is false
NOT GIVEN
if the information is not given in the
passage
2
6
Manufacturers can choose to use synthetic odors for the perfume nowadays
7
Madagascar is chosen to be a place for hunting plants which are rare in other parts of the world
8
Capturing the smell is one of the most important things for creating new aromas
9
The technique the hunters used to trap fragrance molecules is totally out of their ; ingenuity
10
Most customers prefer the perfume made of substance extracted from the musk I glands of animals

8 ____ Capturing the smell is one of the most important things for creating new aromas$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7e4b8220-8252-5634-a768-8dbcdbbcf500', 'f7cdad3f-f46d-54dd-ac97-4388c8c7784f', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('92d57081-2cdb-5919-ac3f-26a651553f80', 'f7cdad3f-f46d-54dd-ac97-4388c8c7784f', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f948a6e0-77db-5b90-8711-fe5b981e0abb', 'f7cdad3f-f46d-54dd-ac97-4388c8c7784f', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('0efd30ea-b892-5364-b428-8c6db1b2e0ff', '0942c126-0522-5510-8d6b-66ebc700bd59', 9, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 9

Questions 6-10
Questions 6-10
Do the following statements agree with the information given in
Reading Passage
? In boxes
6-10
on your answer sheet, write
TRUE
if the statement is true
FALSE
if the statement is false
NOT GIVEN
if the information is not given in the
passage
2
6
Manufacturers can choose to use synthetic odors for the perfume nowadays
7
Madagascar is chosen to be a place for hunting plants which are rare in other parts of the world
8
Capturing the smell is one of the most important things for creating new aromas
9
The technique the hunters used to trap fragrance molecules is totally out of their ; ingenuity
10
Most customers prefer the perfume made of substance extracted from the musk I glands of animals

9 ____ The technique the hunters used to trap fragrance molecules is totally out of their ; ingenuity$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4d6e4f4f-f7c4-57d9-a5fd-9610c8f26e60', '0efd30ea-b892-5364-b428-8c6db1b2e0ff', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4badfe3f-9b09-5cbe-aeaa-527ef3793139', '0efd30ea-b892-5364-b428-8c6db1b2e0ff', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bb21d295-b3ae-5ce2-a3fe-5d5eb5e48f49', '0efd30ea-b892-5364-b428-8c6db1b2e0ff', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('c404f570-5f86-5405-8a70-69e7041160c8', '0942c126-0522-5510-8d6b-66ebc700bd59', 10, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 10

Questions 6-10
Questions 6-10
Do the following statements agree with the information given in
Reading Passage
? In boxes
6-10
on your answer sheet, write
TRUE
if the statement is true
FALSE
if the statement is false
NOT GIVEN
if the information is not given in the
passage
2
6
Manufacturers can choose to use synthetic odors for the perfume nowadays
7
Madagascar is chosen to be a place for hunting plants which are rare in other parts of the world
8
Capturing the smell is one of the most important things for creating new aromas
9
The technique the hunters used to trap fragrance molecules is totally out of their ; ingenuity
10
Most customers prefer the perfume made of substance extracted from the musk I glands of animals

10 ____ Most customers prefer the perfume made of substance extracted from the musk I glands of animals$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c21025e5-6cd9-53ce-bf2f-14154905ced8', 'c404f570-5f86-5405-8a70-69e7041160c8', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('432070d0-30c1-5e45-a0ee-0d8dab099aff', 'c404f570-5f86-5405-8a70-69e7041160c8', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('70a7ee62-cf7c-56b2-93c0-38aaa71297dc', 'c404f570-5f86-5405-8a70-69e7041160c8', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('c4d3f9d3-e918-590e-90f6-371794f39033', '0942c126-0522-5510-8d6b-66ebc700bd59', 11, 'SHORT_ANSWER', 'READING', 4, $md$### Question 11

Questions 11-13
Questions 11-13
Filling the blanks and answer the questions below with only
one
word.
11
12
13

11 ____$md$, NULL, ARRAY['.*headspace.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('1827797a-a561-542f-b6a4-43932194078e', '0942c126-0522-5510-8d6b-66ebc700bd59', 12, 'SHORT_ANSWER', 'READING', 4, $md$### Question 12

Questions 11-13
Questions 11-13
Filling the blanks and answer the questions below with only
one
word.
11
12
13

12 ____$md$, NULL, ARRAY['.*filters.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('ba7c196d-d16d-5804-8ac9-7c8924fa3b76', '0942c126-0522-5510-8d6b-66ebc700bd59', 13, 'SHORT_ANSWER', 'READING', 4, $md$### Question 13

Questions 11-13
Questions 11-13
Filling the blanks and answer the questions below with only
one
word.
11
12
13

13 ____$md$, NULL, ARRAY['.*needle.*']);

COMMIT;
