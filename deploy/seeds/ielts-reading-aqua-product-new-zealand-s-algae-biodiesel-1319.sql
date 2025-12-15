BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-aqua-product-new-zealand-s-algae-biodiesel-1319'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-aqua-product-new-zealand-s-algae-biodiesel-1319';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-aqua-product-new-zealand-s-algae-biodiesel-1319';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-aqua-product-new-zealand-s-algae-biodiesel-1319';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('b249a6ef-fdec-555f-b423-f58a8a4ab6e3', 'ielts-reading-aqua-product-new-zealand-s-algae-biodiesel-1319', $t$Aqua Product: New zealand ‘s Algae Biodiesel$t$, $md$## Aqua Product: New zealand ‘s Algae Biodiesel

Nguồn:
- Test: https://mini-ielts.com/1319/reading/aqua-product-new-zealand-s-algae-biodiesel
- Solution: https://mini-ielts.com/1319/view-solution/reading/aqua-product-new-zealand-s-algae-biodiesel$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('5790b858-9c02-53a4-857d-4914dcab7246', 'b249a6ef-fdec-555f-b423-f58a8a4ab6e3', 1, $t$Reading — Aqua Product: New zealand ‘s Algae Biodiesel$t$, $md$Read the passage and answer questions **1–13**.

### Passage: Aqua Product: New zealand ‘s Algae Biodiesel

A

The world’s first wild algae biodiesel, produced in New Zealand by Aquaflow Bionomic Corporation, was successfully test-driven in Wellington by the Minister for Energy and Climate Change Issues, David Parker. In front of a crowd of invited guests, media and members of the public, the Minister filled up a diesel-powered Land Rover with Aquaflow B5 blend bio-diesel and then drove the car around the forecourt of Parliament Buildings in Central Wellington. Green Party co-leader, Jeanette Fitzsimons was also on board. Marlborough-based Aquaflow announced on May 2006 that it had produced the world’s first bio-diesel derived from wild microalgae sourced from local sewage ponds.

B

“We believe we are the first company in the world to test drive a car powered by wild algae-based biodiesel. This will come as a surprise to some international bio-diesel industry people who believe that this break-through is still years away,” explains Aquaflow spokesperson Barrie Leay. “A bunch of inventive Kiwis and an Aussie have developed this fuel in just over a year”, he comments. “This is a huge opportunity for New Zealand and a great credit to the team of people who saw the potential in this technology from day one.”

C

Bio-diesel based on algae could eventually become a sustainable, low cost, cleaner-burning fuel alternative for New Zealand, powering family cars, trucks, buses and boats. It can also be used for other purposes such as heating or distributed electricity generation. There is now a global demand for billions of litres of biodiesel per year. Algae are also readily available and produced in huge volumes in nutrient-rich waste streams such as at the settling ponds of Effluent Management Systems (EMS). It is a renewable indigenous resource ideally suited to the production of fuel and other useful by-products. The breakthrough comes after technology start-up, Aquaflow, agreed to undertake a pilot with Marlborough District Council late last year to extract algae from the settling ponds of its EMS based in Blenheim. By removing the main contaminant to use as a fuel feedstock, Aquaflow is also helping clean up the council’s water discharge – a process known as bio-remediation. Dairy farmers, and many food processors too, can benefit in similar ways by applying the harvesting technology to their nutrient-rich waste streams.

D

Blended with conventional mineral diesel, bio-diesel can run vehicles without the need for vehicle modifications. Fuel derived from algae can also help meet the Government B5 (5% blended) target, with the prospect of this increase over time as bio-fuel production increases. “Our next step is to increase capacity to produce one million litres of bio-diesel from the Marlborough sewerage ponds over the next year,” says Leay. Aquaflow will launch a prospectus pre-Christmas as the company has already attracted considerable interest from potential investors. The test drive bio-diesel was used successfully in a static engine test at Massey University’s Wellington campus on Monday, December 11.

E

Today Algae are used by humans in many ways; for example, as fertilizers, soil conditioners and livestock feed. Aquatic and microscopic species are cultured in clear tanks or ponds and are either harvested or used to treat effluents pumped through the ponds. Algaculture on a large scale is an important type of aquaculture in some places. Naturally growing seaweeds are an important source of food, especially in Asia. They provide many vitamins including A, B, B2, B6, niacin and C, and are rich in iodine, potassium, iron, magnesium and calcium. In addition, commercially cultivated microalgae, including both Algae and Cyan-bacteria, are marketed as nutritional supplements, such as Spirulina, Chlorella and the Vitamin-C supplement, Dunaliella, high in beta-carotene. Algae are national foods of many nations: China consumes more than 70 species, including fat choy , a cyanobacterium considered a vegetable; Japan, over 20 species. The natural pigments produced by algae can be used as an alternative to chemical dyes and coloring agents.

F

Algae are the simplest plant organisms that convert sunlight and carbon dioxide in the air around us into stored energy through the well-understood process of photosynthesis. Algae are rich in lipids and other combustible elements and Aquaflow is developing technology that will allow these elements to be extracted in a cost-effective way. The proposed process is the subject of a provisional patent. Although algae are good at taking most of the nutrients out of sewage, too many algae can taint the water and make it smell. So, councils have to find a way of cleaning up the excess algae in their sewerage outflows and then either dispose of it or find alternative uses for it. And that’s where Aquaflow comes in.

G

Unlike some bio-fuels which require crops to be specially grown and thereby compete for land use with food production, and use other scarce resources of fuel, chemicals and fertiliser, the source for algae-based biodiesel already exists extensively and the process produces a sustainable net energy gain by capturing free solar energy from the sun.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('4c2a4652-79f9-5294-b28b-8c3277e7af24', '5790b858-9c02-53a4-857d-4914dcab7246', 1, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 1

Questions 1-5
Questions 1-5
Reading Passage contains seven paragraphs
A-G.
Which paragraph stales the following information?
Write the appropriate letter
A-G
, in boxes
1-5
on your answer sheet.
NB
You may use any letter more than once.
1
It is unnecessary to modify vehicles driven by bio-diesel.
2
Some algae are considered edible plants.
3
Algae could be part of a sustainable and recycled source.
4
Algae biodiesel is superior to other bio-fuels in a lot of ways.
5
overgrown algae also can be a potential threat to the environment

1 ____ It is unnecessary to modify vehicles driven by bio-diesel.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('48a89155-1669-5bd2-aebf-43368ca8e065', '4c2a4652-79f9-5294-b28b-8c3277e7af24', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fcadc91d-78b0-5ce5-b2bb-34f5e3325e73', '4c2a4652-79f9-5294-b28b-8c3277e7af24', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('02d2878e-a92f-5845-8c81-80aff74fea71', '4c2a4652-79f9-5294-b28b-8c3277e7af24', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('accba204-94fa-56cc-b014-0e0b489f2da2', '4c2a4652-79f9-5294-b28b-8c3277e7af24', 4, $md$D$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9c520111-1433-5042-a6bf-266f8dfbf906', '4c2a4652-79f9-5294-b28b-8c3277e7af24', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('72eb66da-0d29-5a0a-a679-85024db536ae', '4c2a4652-79f9-5294-b28b-8c3277e7af24', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7399cb70-3600-5823-86f9-27c262936101', '4c2a4652-79f9-5294-b28b-8c3277e7af24', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('38262836-31ff-5abd-9825-778e80c3bab6', '5790b858-9c02-53a4-857d-4914dcab7246', 2, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 2

Questions 1-5
Questions 1-5
Reading Passage contains seven paragraphs
A-G.
Which paragraph stales the following information?
Write the appropriate letter
A-G
, in boxes
1-5
on your answer sheet.
NB
You may use any letter more than once.
1
It is unnecessary to modify vehicles driven by bio-diesel.
2
Some algae are considered edible plants.
3
Algae could be part of a sustainable and recycled source.
4
Algae biodiesel is superior to other bio-fuels in a lot of ways.
5
overgrown algae also can be a potential threat to the environment

2 ____ Some algae are considered edible plants.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8bd20dfe-201f-51e8-9f70-7fe270707d2b', '38262836-31ff-5abd-9825-778e80c3bab6', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a1547a04-3583-5c4c-b13b-86435ac2692c', '38262836-31ff-5abd-9825-778e80c3bab6', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0d408836-75d8-5e27-ad80-9364631daeee', '38262836-31ff-5abd-9825-778e80c3bab6', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('29d3c7ac-cf14-56fa-9a0c-0f19c18f301b', '38262836-31ff-5abd-9825-778e80c3bab6', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7c6a0163-cc63-5aef-ae9b-ad944562cbd5', '38262836-31ff-5abd-9825-778e80c3bab6', 5, $md$E$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0ec37c33-90ee-50ea-9a19-ca4c19445c97', '38262836-31ff-5abd-9825-778e80c3bab6', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c6f32eab-0266-57c1-ab55-f68b4c48b882', '38262836-31ff-5abd-9825-778e80c3bab6', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('f8264b6c-3f53-546b-aad9-6ae520aae83d', '5790b858-9c02-53a4-857d-4914dcab7246', 3, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 3

Questions 1-5
Questions 1-5
Reading Passage contains seven paragraphs
A-G.
Which paragraph stales the following information?
Write the appropriate letter
A-G
, in boxes
1-5
on your answer sheet.
NB
You may use any letter more than once.
1
It is unnecessary to modify vehicles driven by bio-diesel.
2
Some algae are considered edible plants.
3
Algae could be part of a sustainable and recycled source.
4
Algae biodiesel is superior to other bio-fuels in a lot of ways.
5
overgrown algae also can be a potential threat to the environment

3 ____ Algae could be part of a sustainable and recycled source.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('85acd9ae-0d4e-50b8-8645-52995768619c', 'f8264b6c-3f53-546b-aad9-6ae520aae83d', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3d45c8bb-5107-50bc-a9b0-699259490ed4', 'f8264b6c-3f53-546b-aad9-6ae520aae83d', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2820176c-2eaf-5ddf-a9b0-322eac5aa0fb', 'f8264b6c-3f53-546b-aad9-6ae520aae83d', 3, $md$C$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7b4a4ebd-c470-5370-b0a3-808558f4727d', 'f8264b6c-3f53-546b-aad9-6ae520aae83d', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f5f19113-dbcd-5ac2-a396-df4f21be6aec', 'f8264b6c-3f53-546b-aad9-6ae520aae83d', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0c2ddba2-4780-5cfe-a99e-4c1c027b3b41', 'f8264b6c-3f53-546b-aad9-6ae520aae83d', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('37f2a56f-70fa-5bff-973f-daad450bb588', 'f8264b6c-3f53-546b-aad9-6ae520aae83d', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('492efdc2-9b0c-5cc2-ab7f-3f840e2e27ee', '5790b858-9c02-53a4-857d-4914dcab7246', 4, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 4

Questions 1-5
Questions 1-5
Reading Passage contains seven paragraphs
A-G.
Which paragraph stales the following information?
Write the appropriate letter
A-G
, in boxes
1-5
on your answer sheet.
NB
You may use any letter more than once.
1
It is unnecessary to modify vehicles driven by bio-diesel.
2
Some algae are considered edible plants.
3
Algae could be part of a sustainable and recycled source.
4
Algae biodiesel is superior to other bio-fuels in a lot of ways.
5
overgrown algae also can be a potential threat to the environment

4 ____ Algae biodiesel is superior to other bio-fuels in a lot of ways.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('938b26e0-81d7-52a3-bb79-a1e974e5ba9b', '492efdc2-9b0c-5cc2-ab7f-3f840e2e27ee', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d17122d5-b07f-5a95-895e-04f0cefa6582', '492efdc2-9b0c-5cc2-ab7f-3f840e2e27ee', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8f9de89e-1252-56c0-b544-ceaf14dc6819', '492efdc2-9b0c-5cc2-ab7f-3f840e2e27ee', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('113b13d3-5ec1-54eb-9ace-1875d5d16333', '492efdc2-9b0c-5cc2-ab7f-3f840e2e27ee', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1e3b422c-141e-5ca4-8f78-24c5d9a6f2aa', '492efdc2-9b0c-5cc2-ab7f-3f840e2e27ee', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('51386259-f46d-5c0a-a54b-b2be930bdc4c', '492efdc2-9b0c-5cc2-ab7f-3f840e2e27ee', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c05749e2-9702-58fc-920c-1ce98318d76e', '492efdc2-9b0c-5cc2-ab7f-3f840e2e27ee', 7, $md$G$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('aa9de4bb-9639-526f-9b45-4670f2c907a4', '5790b858-9c02-53a4-857d-4914dcab7246', 5, 'MATCHING_INFORMATION', 'READING', 3, $md$### Question 5

Questions 1-5
Questions 1-5
Reading Passage contains seven paragraphs
A-G.
Which paragraph stales the following information?
Write the appropriate letter
A-G
, in boxes
1-5
on your answer sheet.
NB
You may use any letter more than once.
1
It is unnecessary to modify vehicles driven by bio-diesel.
2
Some algae are considered edible plants.
3
Algae could be part of a sustainable and recycled source.
4
Algae biodiesel is superior to other bio-fuels in a lot of ways.
5
overgrown algae also can be a potential threat to the environment

5 ____ overgrown algae also can be a potential threat to the environment$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2b617e19-28df-590a-9096-ff77410b4836', 'aa9de4bb-9639-526f-9b45-4670f2c907a4', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ebffdc62-4b30-570b-9ce9-d189fcb93e8d', 'aa9de4bb-9639-526f-9b45-4670f2c907a4', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('20d2761a-9de0-5561-b0bc-9ff1579908b7', 'aa9de4bb-9639-526f-9b45-4670f2c907a4', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3a4947a8-84f1-5c57-808b-fe1998844c93', 'aa9de4bb-9639-526f-9b45-4670f2c907a4', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b5529ad6-3279-504f-825d-c567dbdf6b5c', 'aa9de4bb-9639-526f-9b45-4670f2c907a4', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4786bf8f-5b33-5e7e-9e0f-3c1d7059aff0', 'aa9de4bb-9639-526f-9b45-4670f2c907a4', 6, $md$F$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d08d32c7-15e7-58df-9821-f2f94aad5473', 'aa9de4bb-9639-526f-9b45-4670f2c907a4', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('7d9aca3e-3b75-55f1-bce4-f0aacb56918e', '5790b858-9c02-53a4-857d-4914dcab7246', 6, 'SUMMARY_COMPLETION', 'READING', 3, $md$### Question 6

Questions 6-10
Questions 6-10
Complete the following summary of the paragraphs of Reading Passage.
Using
NO MORE THAN TWO WORDS
from the Reading Passage for each answer.
Write your answers in boxes
6-10
on your answer sheet.
Bio-diesel based on algae could become a substitute for
6
in New Zealand. It could be used to
7
vehicles such as cars and boats. As a result, billions of litres of bio-diesel are required worldwide each year. Algae can be obtained from
8
with nutrient materials. With the technology breakthrough, algae are extracted and the
9
is removed from the settling ponds. Dairy farmers and many food processors can adopt such
10
technology.

Bio-diesel based on algae could become a substitute for 6 ____ in New Zealand. It could be used to 7 ____ vehicles such as cars and boats. As a result, billions of litres of bio-diesel are required worldwide each year. Algae can be obtained from 8 ____ with nutrient materials. With the technology breakthrough, algae are extracted and the 9 ____ is removed from the settling ponds. Dairy farmers and many food processors can adopt such 10 ____ technology.$md$, NULL, ARRAY['.*fuel.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('526d5e5c-c1d0-533a-b69d-63b52de082a2', '5790b858-9c02-53a4-857d-4914dcab7246', 7, 'SUMMARY_COMPLETION', 'READING', 3, $md$### Question 7

Questions 6-10
Questions 6-10
Complete the following summary of the paragraphs of Reading Passage.
Using
NO MORE THAN TWO WORDS
from the Reading Passage for each answer.
Write your answers in boxes
6-10
on your answer sheet.
Bio-diesel based on algae could become a substitute for
6
in New Zealand. It could be used to
7
vehicles such as cars and boats. As a result, billions of litres of bio-diesel are required worldwide each year. Algae can be obtained from
8
with nutrient materials. With the technology breakthrough, algae are extracted and the
9
is removed from the settling ponds. Dairy farmers and many food processors can adopt such
10
technology.

Bio-diesel based on algae could become a substitute for 6 ____ in New Zealand. It could be used to 7 ____ vehicles such as cars and boats. As a result, billions of litres of bio-diesel are required worldwide each year. Algae can be obtained from 8 ____ with nutrient materials. With the technology breakthrough, algae are extracted and the 9 ____ is removed from the settling ponds. Dairy farmers and many food processors can adopt such 10 ____ technology.$md$, NULL, ARRAY['.*fuel.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('a68fea47-7c00-596e-b6bc-f014da497c5c', '5790b858-9c02-53a4-857d-4914dcab7246', 8, 'SUMMARY_COMPLETION', 'READING', 3, $md$### Question 8

Questions 6-10
Questions 6-10
Complete the following summary of the paragraphs of Reading Passage.
Using
NO MORE THAN TWO WORDS
from the Reading Passage for each answer.
Write your answers in boxes
6-10
on your answer sheet.
Bio-diesel based on algae could become a substitute for
6
in New Zealand. It could be used to
7
vehicles such as cars and boats. As a result, billions of litres of bio-diesel are required worldwide each year. Algae can be obtained from
8
with nutrient materials. With the technology breakthrough, algae are extracted and the
9
is removed from the settling ponds. Dairy farmers and many food processors can adopt such
10
technology.

Bio-diesel based on algae could become a substitute for 6 ____ in New Zealand. It could be used to 7 ____ vehicles such as cars and boats. As a result, billions of litres of bio-diesel are required worldwide each year. Algae can be obtained from 8 ____ with nutrient materials. With the technology breakthrough, algae are extracted and the 9 ____ is removed from the settling ponds. Dairy farmers and many food processors can adopt such 10 ____ technology.$md$, NULL, ARRAY['.*fuel.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('9bc3995c-e91f-59ef-8723-6b530a761747', '5790b858-9c02-53a4-857d-4914dcab7246', 9, 'SUMMARY_COMPLETION', 'READING', 3, $md$### Question 9

Questions 6-10
Questions 6-10
Complete the following summary of the paragraphs of Reading Passage.
Using
NO MORE THAN TWO WORDS
from the Reading Passage for each answer.
Write your answers in boxes
6-10
on your answer sheet.
Bio-diesel based on algae could become a substitute for
6
in New Zealand. It could be used to
7
vehicles such as cars and boats. As a result, billions of litres of bio-diesel are required worldwide each year. Algae can be obtained from
8
with nutrient materials. With the technology breakthrough, algae are extracted and the
9
is removed from the settling ponds. Dairy farmers and many food processors can adopt such
10
technology.

Bio-diesel based on algae could become a substitute for 6 ____ in New Zealand. It could be used to 7 ____ vehicles such as cars and boats. As a result, billions of litres of bio-diesel are required worldwide each year. Algae can be obtained from 8 ____ with nutrient materials. With the technology breakthrough, algae are extracted and the 9 ____ is removed from the settling ponds. Dairy farmers and many food processors can adopt such 10 ____ technology.$md$, NULL, ARRAY['.*fuel.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('bf85c046-15df-5155-9288-543a5737f4e1', '5790b858-9c02-53a4-857d-4914dcab7246', 10, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 10

Questions 6-10
Questions 6-10
Complete the following summary of the paragraphs of Reading Passage.
Using
NO MORE THAN TWO WORDS
from the Reading Passage for each answer.
Write your answers in boxes
6-10
on your answer sheet.
Bio-diesel based on algae could become a substitute for
6
in New Zealand. It could be used to
7
vehicles such as cars and boats. As a result, billions of litres of bio-diesel are required worldwide each year. Algae can be obtained from
8
with nutrient materials. With the technology breakthrough, algae are extracted and the
9
is removed from the settling ponds. Dairy farmers and many food processors can adopt such
10
technology.

Bio-diesel based on algae could become a substitute for 6 ____ in New Zealand. It could be used to 7 ____ vehicles such as cars and boats. As a result, billions of litres of bio-diesel are required worldwide each year. Algae can be obtained from 8 ____ with nutrient materials. With the technology breakthrough, algae are extracted and the 9 ____ is removed from the settling ponds. Dairy farmers and many food processors can adopt such 10 ____ technology.$md$, NULL, ARRAY['.*fuel.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('bed18263-25f3-5a1e-ba2e-06fcf9dabfb4', '5790b858-9c02-53a4-857d-4914dcab7246', 11, 'SHORT_ANSWER', 'READING', 4, $md$### Question 11

Questions 11-13
Questions 11-13
Choose words from the passage to answer the questions
11-13
.
Write
NO MORE THAN THREE WORDS
for each answer.
11. What environmental standard would bio-diesel vehicles are to meet?
11
12. What is to do like the immediate plan for coming years for Aquaflow?
12
13. Through what kind of process do algae obtain and store energy?
13

11. What environmental standard would bio-diesel vehicles are to meet? 11 ____$md$, NULL, ARRAY['.*photosynthesis.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('54cdb112-24d8-5f4b-9dd1-94b7aeebbc65', '5790b858-9c02-53a4-857d-4914dcab7246', 12, 'SHORT_ANSWER', 'READING', 4, $md$### Question 12

Questions 11-13
Questions 11-13
Choose words from the passage to answer the questions
11-13
.
Write
NO MORE THAN THREE WORDS
for each answer.
11. What environmental standard would bio-diesel vehicles are to meet?
11
12. What is to do like the immediate plan for coming years for Aquaflow?
12
13. Through what kind of process do algae obtain and store energy?
13

12. What is to do like the immediate plan for coming years for Aquaflow? 12 ____$md$, NULL, ARRAY['.*government.*b5.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('ac250acf-7fd5-5a38-abba-d8f9e3d6e5bf', '5790b858-9c02-53a4-857d-4914dcab7246', 13, 'SHORT_ANSWER', 'READING', 4, $md$### Question 13

Questions 11-13
Questions 11-13
Choose words from the passage to answer the questions
11-13
.
Write
NO MORE THAN THREE WORDS
for each answer.
11. What environmental standard would bio-diesel vehicles are to meet?
11
12. What is to do like the immediate plan for coming years for Aquaflow?
12
13. Through what kind of process do algae obtain and store energy?
13

13. Through what kind of process do algae obtain and store energy? 13 ____$md$, NULL, ARRAY['.*capacity.*']);

COMMIT;
