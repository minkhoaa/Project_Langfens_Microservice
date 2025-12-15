BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-nature-works-polylactic-acid-1444'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-nature-works-polylactic-acid-1444';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-nature-works-polylactic-acid-1444';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-nature-works-polylactic-acid-1444';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('9036002b-5a56-5b77-919b-7af8cf275821', 'ielts-reading-nature-works-polylactic-acid-1444', $t$Nature works Polylactic acid$t$, $md$## Nature works Polylactic acid

Nguồn:
- Test: https://mini-ielts.com/1444/reading/nature-works-polylactic-acid
- Solution: https://mini-ielts.com/1444/view-solution/reading/nature-works-polylactic-acid$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('cdb9d0e0-251e-5157-8584-0dd78eb83143', '9036002b-5a56-5b77-919b-7af8cf275821', 1, $t$Reading — Nature works Polylactic acid$t$, $md$Read the passage and answer questions **1–10**.

### Passage: Nature works Polylactic acid

A dozen years ago, scientists at Cargill got the idea of converting lactic acid made from corn into plastic while examining possible new uses for materials produced from corn wet milling processes. In the past, several efforts had been made to develop plastics from lactic acid, but with limited success. Achieving this technological breakthrough didn’t come easily, but in time the efforts did succeed. A fermentation and distillation process using com was designed to create a polymer suitable for a broad variety of applications.

B

As an agricultural based firm, Cargill had taken this product as far as it could by 1997.

The company needed a partner with access to plastics markets and polymerization capabilities, and began discussions with The Dow Chemical Company. The next step was the formation of the joint venture that created Cargill Dow LLC. Cargill Dow’s product is the world’s first commercially available plastic made from annually renewable resources such as com:

c

By applying their unique technology to the processing of natural plant sugars, Cargill Dow has created a more environmentally friendly material that reaches the consumer in clothes, cups, packaging and other products. While Cargill Dow is a stand-alone business, it continues to leverage the agricultural processing, manufacturing and polymer expertise of the two parent companies in order to bring the best possible products to market.

D

The basic raw materials for PLA are carbon dioxide and water. Growing plants, like com, take these building blocks from the atmosphere and the soil. They are combined in the plant to make carbohydrates (sucrose and starch) through a process driven by photosynthesis. The process for making Nature Works PLA begins when a renewable resource such as corn is milled, separating starch from the raw material. Unrefined dextrose, in turn, is processed from the starch.

E

Cargill Dow turns the unrefined dextrose into lactic acid using a fermentation process similar to that used by beer and wine producers. This is the same lactic acid that is used as a food additive and is found in muscle tissue in the human body. Through a special condensation process, a lactide is formed. This lactide is purified through vacuum distillation and becomes a polymer (the base for Natureworks PLA) that is ready for use through a solvent-free melt process. Development of this new technology allows the company to “harvest” the carbon that living plants remove from the air through photosynthesis. Carbon is stored in plant starches, which can be broken down into natural plant sugars. The carbon and other elements in these natural sugars are then used to make Natureworks PLA.

F

Nature Works PLA fits all disposal systems and is fully compostable in commercial composting facilities. With the proper infrastructure, products made from this polymer can be recycled back to a monomer and re-used as a polymer. Thus, at the end of its life cycle, a product made from Nature Works PLA can be broken down into its simplest parts so that no sign of it remains.

G

PLA is now actively competing with traditional materials in packaging and fiber applications throughout the world; based on the technology’s success and promise, Cargill Dow is quickly becoming a premier player in the polymers market. This new polymer now competes head-on with petroleum-based materials like polyester. A wide range of products that vary in molecular weight and crystallinity can be produced, and the blend of physical properties of PLA makes it suited for a broad range of fiber and packaging applications. Fiber and non-woven applications include clothing, fiberfill, blankets and wipes. Packaging applications include packaging films and food and beverage containers.

H

As Nature Works PLA polymers are more oil- and grease-resistant and provide a better flavor and aroma barrier than existing petroleum-based polymers, grocery retailers are increasingly using this packaging for their fresh foods. As companies begin to explore this family of polymers, more potential applications are being identified. For example, PLA possess two properties that are particularly useful for drape fabrics and window furnishings. Their resistance to ultraviolet light is particularly appealing as this reduces the amount of fading in such fabrics, and their refractive index is low, which means fabrics constructed from these polymers can be made with deep colors without requiring large amounts of dye. In addition, sportswear makers have been drawn to the product as it has an inherent ability to take moisture away from the skin and when blended with cotton and wool, the result is garments that are lighter and better at absorbing moisture.

I

PLA combines inexpensive large-scale fermentation with chemical processing to produce a value-added polymer product that improves the environment as well. The source material for PLA is a natural sugar found in plants such as com and using such renewable feedstock presents several environmental benefits. As an alternative to traditional petroleum-based polymers, the production of PLA uses 20%-50% less fossil fuel and releases a lower amount of greenhouse gasses than comparable petroleum­based plastic; carbon dioxide in the atmosphere is removed when the feedstock is grown and is returned to the earth when the polymer is degraded. Because the company is using raw materials that can be regenerated year after year, it is both cost- competitive and environmentally responsible.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('773bbf3c-adb7-57dd-8147-a4493272c424', 'cdb9d0e0-251e-5157-8584-0dd78eb83143', 1, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 1

Questions 1-4
Questions 1-4
Write the letters A-F in boxes 1-4 on your answer sheet.
1
scientists manage to
2
Cargill needs to have contacts with
3
Nature work is used for
4
Ingeo is used to
A make things like clothes
B produce plastic from plant
C selling plastic in market
D fermentation process
E drape fabrics
F wrapping products

1 ____ scientists manage to 2 ____ Cargill needs to have contacts with 3 ____ Nature work is used for 4 ____ Ingeo is used to$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('eb284a1f-e3e3-588f-b841-ec4bdb65ce85', '773bbf3c-adb7-57dd-8147-a4493272c424', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('84e5cadc-e9eb-5fa0-981e-854482a39710', '773bbf3c-adb7-57dd-8147-a4493272c424', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bab799b2-9eee-5d83-8a27-666de9637b71', '773bbf3c-adb7-57dd-8147-a4493272c424', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a0947e38-ebb8-54f4-a762-bc227b86077e', '773bbf3c-adb7-57dd-8147-a4493272c424', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('48ad0aa7-b019-5afa-886b-eb8c61729359', '773bbf3c-adb7-57dd-8147-a4493272c424', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('11ff0d2c-91a1-5414-88b9-c01bd4d980ba', '773bbf3c-adb7-57dd-8147-a4493272c424', 6, $md$F$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('767bf730-6612-578c-8534-5847b453de03', 'cdb9d0e0-251e-5157-8584-0dd78eb83143', 2, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 2

Questions 1-4
Questions 1-4
Write the letters A-F in boxes 1-4 on your answer sheet.
1
scientists manage to
2
Cargill needs to have contacts with
3
Nature work is used for
4
Ingeo is used to
A make things like clothes
B produce plastic from plant
C selling plastic in market
D fermentation process
E drape fabrics
F wrapping products

1 ____ scientists manage to 2 ____ Cargill needs to have contacts with 3 ____ Nature work is used for 4 ____ Ingeo is used to$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c9715e89-521f-5a0e-820e-8a476675c11b', '767bf730-6612-578c-8534-5847b453de03', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0762467f-07bc-5857-8414-ff60efc1d2e8', '767bf730-6612-578c-8534-5847b453de03', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('38190950-877b-5ee6-8e77-20f469e21357', '767bf730-6612-578c-8534-5847b453de03', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('eb0769cd-49e5-5e9b-b90c-5f001ae5f0f1', '767bf730-6612-578c-8534-5847b453de03', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4ab8e65e-eb47-5376-8403-a5462ec5c9ba', '767bf730-6612-578c-8534-5847b453de03', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9a400956-3a46-5598-89af-7e81d263ec9d', '767bf730-6612-578c-8534-5847b453de03', 6, $md$F$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('3a49d592-98e3-53e5-a67f-4084520670fb', 'cdb9d0e0-251e-5157-8584-0dd78eb83143', 3, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 3

Questions 1-4
Questions 1-4
Write the letters A-F in boxes 1-4 on your answer sheet.
1
scientists manage to
2
Cargill needs to have contacts with
3
Nature work is used for
4
Ingeo is used to
A make things like clothes
B produce plastic from plant
C selling plastic in market
D fermentation process
E drape fabrics
F wrapping products

1 ____ scientists manage to 2 ____ Cargill needs to have contacts with 3 ____ Nature work is used for 4 ____ Ingeo is used to$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4b74d3b9-5e5a-5c69-8cc7-1fc7aa636a5a', '3a49d592-98e3-53e5-a67f-4084520670fb', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('005026b2-df09-5fd1-ab5e-92e2f305bca5', '3a49d592-98e3-53e5-a67f-4084520670fb', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5f9e082c-a182-518b-b1af-defcbb1f6b19', '3a49d592-98e3-53e5-a67f-4084520670fb', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a0c26988-43f5-5abe-bb66-6cd93ab75f3f', '3a49d592-98e3-53e5-a67f-4084520670fb', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a9e6208e-3c95-5e27-a40a-c7eaea98c36a', '3a49d592-98e3-53e5-a67f-4084520670fb', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('04c1b9ad-f141-5918-bf46-d3387b0830e3', '3a49d592-98e3-53e5-a67f-4084520670fb', 6, $md$F$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('ba9380a0-b96f-5da9-86d0-536de030a17e', 'cdb9d0e0-251e-5157-8584-0dd78eb83143', 4, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 4

Questions 1-4
Questions 1-4
Write the letters A-F in boxes 1-4 on your answer sheet.
1
scientists manage to
2
Cargill needs to have contacts with
3
Nature work is used for
4
Ingeo is used to
A make things like clothes
B produce plastic from plant
C selling plastic in market
D fermentation process
E drape fabrics
F wrapping products

1 ____ scientists manage to 2 ____ Cargill needs to have contacts with 3 ____ Nature work is used for 4 ____ Ingeo is used to$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b9fa26d4-9985-5857-8fe4-31845b5b4520', 'ba9380a0-b96f-5da9-86d0-536de030a17e', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('25c3e2d8-0111-523b-9cb1-f00fe4cfc5ae', 'ba9380a0-b96f-5da9-86d0-536de030a17e', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a0740073-33d2-5267-9ed4-5f0cf016d178', 'ba9380a0-b96f-5da9-86d0-536de030a17e', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d74d0263-0863-50e7-b506-0588efa30f5e', 'ba9380a0-b96f-5da9-86d0-536de030a17e', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('37de0074-c76a-54c0-a2aa-5df315925bef', 'ba9380a0-b96f-5da9-86d0-536de030a17e', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f57e6521-a1dd-5e20-9ae5-a3f53dbd0d5e', 'ba9380a0-b96f-5da9-86d0-536de030a17e', 6, $md$F$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('c55208bb-5c8c-5cb3-b398-407ec039d677', 'cdb9d0e0-251e-5157-8584-0dd78eb83143', 5, 'SUMMARY_COMPLETION', 'READING', 3, $md$### Question 5

Questions 5-8
Questions 5-8
Complete the following summary of the paragraphs of Reading Passage.
Using
NO MORE THAN TWO WORDS
from the Reading Passage for each answer.
Write your answers in boxes 31-34 on your answer sheet.
Process:
Polylactic acid
5
6
7
8

5 ____ 6 ____ 7 ____ 8 ____$md$, NULL, ARRAY['.*starch.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('5b78d581-ecc4-5d2b-b1c4-fe9104d4208a', 'cdb9d0e0-251e-5157-8584-0dd78eb83143', 6, 'SUMMARY_COMPLETION', 'READING', 3, $md$### Question 6

Questions 5-8
Questions 5-8
Complete the following summary of the paragraphs of Reading Passage.
Using
NO MORE THAN TWO WORDS
from the Reading Passage for each answer.
Write your answers in boxes 31-34 on your answer sheet.
Process:
Polylactic acid
5
6
7
8

5 ____ 6 ____ 7 ____ 8 ____$md$, NULL, ARRAY['.*starch.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('a81ffef7-c4e7-5cf7-9143-511f26c2b6c8', 'cdb9d0e0-251e-5157-8584-0dd78eb83143', 7, 'SUMMARY_COMPLETION', 'READING', 3, $md$### Question 7

Questions 5-8
Questions 5-8
Complete the following summary of the paragraphs of Reading Passage.
Using
NO MORE THAN TWO WORDS
from the Reading Passage for each answer.
Write your answers in boxes 31-34 on your answer sheet.
Process:
Polylactic acid
5
6
7
8

5 ____ 6 ____ 7 ____ 8 ____$md$, NULL, ARRAY['.*starch.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('8c8d681e-c6ee-52a0-8b96-046be008ffb6', 'cdb9d0e0-251e-5157-8584-0dd78eb83143', 8, 'SUMMARY_COMPLETION', 'READING', 3, $md$### Question 8

Questions 5-8
Questions 5-8
Complete the following summary of the paragraphs of Reading Passage.
Using
NO MORE THAN TWO WORDS
from the Reading Passage for each answer.
Write your answers in boxes 31-34 on your answer sheet.
Process:
Polylactic acid
5
6
7
8

5 ____ 6 ____ 7 ____ 8 ____$md$, NULL, ARRAY['.*starch.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('fc1eac76-7d70-5f1a-8440-925ff7f77d4e', 'cdb9d0e0-251e-5157-8584-0dd78eb83143', 9, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 9

Questions 9-10
Questions 9-10
Choose the correct letter, A, B, c or D.
Write your answers in boxes 9-10 on your answer sheet.
9. Why did choose the PLA as material for food packaging?
A
It smells good
B
It can save food freshness
C
It can be used on other materials
D
Some other things need to be revised about it.
10. What is PLA packaging is used for?
A
absorbing moisture
B
composting facilities
C
Packaging fresh food
D
manufacturing

Choose the correct letter, A, B, c or D.$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('7a969cab-ecda-5fbe-b8c9-04bdba14fe3a', 'cdb9d0e0-251e-5157-8584-0dd78eb83143', 10, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 10

Questions 9-10
Questions 9-10
Choose the correct letter, A, B, c or D.
Write your answers in boxes 9-10 on your answer sheet.
9. Why did choose the PLA as material for food packaging?
A
It smells good
B
It can save food freshness
C
It can be used on other materials
D
Some other things need to be revised about it.
10. What is PLA packaging is used for?
A
absorbing moisture
B
composting facilities
C
Packaging fresh food
D
manufacturing

Choose the correct letter, A, B, c or D.$md$, NULL);

COMMIT;
