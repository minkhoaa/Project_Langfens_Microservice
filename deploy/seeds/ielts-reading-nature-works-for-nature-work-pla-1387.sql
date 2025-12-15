BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-nature-works-for-nature-work-pla-1387'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-nature-works-for-nature-work-pla-1387';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-nature-works-for-nature-work-pla-1387';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-nature-works-for-nature-work-pla-1387';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('639e9f1a-31f4-5f5e-b10f-ec1276fefaca', 'ielts-reading-nature-works-for-nature-work-pla-1387', $t$Nature works for Nature Work PLA$t$, $md$## Nature works for Nature Work PLA

Nguồn:
- Test: https://mini-ielts.com/1387/reading/nature-works-for-nature-work-pla
- Solution: https://mini-ielts.com/1387/view-solution/reading/nature-works-for-nature-work-pla$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('e481cd4e-e776-5614-833c-826b8578776b', '639e9f1a-31f4-5f5e-b10f-ec1276fefaca', 1, $t$Reading — Nature works for Nature Work PLA$t$, $md$Read the passage and answer questions **1–10**.

### Passage: Nature works for Nature Work PLA

A

A dozen years ago, scientists at Cargill got the idea of converting lactic acid made from corn into plastic while examining possible new uses for materials produced from corn wet milling processes. In the past, several efforts had been made to develop plastics from lactic acid, but with limited success. Achieving this technological breakthrough didn’t come easily, but in time the efforts did succeed. A fermentation and distillation process using com was designed to create a polymer suitable for a broad variety of applications.

B

As an agricultural based firm, Cargill had taken this product as far as it could by 1997. The company needed a partner with access to plastics markets and polymerization capabilities, and began discussions with The Dow Chemical Company. The next step was the formation of the joint venture that created Cargill Dow LLC. Cargill Dow’s product is the world’s first commercially available plastic made from annually renewable resources such as com:

C

By applying their unique technology to the processing of natural plant sugars, Cargill Dow has created a more environmentally friendly material that reaches the consumer in clothes, cups, packaging and other products. While Cargill Dow is a stand-alone business, it continues to leverage the agricultural processing, manufacturing and polymer expertise of the two parent companies in order to bring the best possible products to market.

D

The basic raw materials for PLA are carbon dioxide and water. Growing plants, like com, take these building blocks from the atmosphere and the soil. They are combined in the plant to make carbohydrates (sucrose and starch) through a process driven by photosynthesis. The process for making Nature Works PLA begins when a renewable resource such as corn is milled, separating starch from the raw material. Unrefined dextrose, in turn, is processed from the starch.

E

Cargill Dow turns the unrefined dextrose into lactic acid using a fermentation process similar to that used by beer and wine producers. This is the same lactic acid that is used as a food additive and is found in muscle tissue in the human body. Through a special condensation process, a lactide is formed. This lactide is purified through vacuum distillation and becomes a polymer (the base for NatureWorks PLA) that is ready for use through a solvent-free melt process. Development of this new technology allows the company to “harvest” the carbon that living plants remove from the air through photosynthesis. Carbon is stored in plant starches, which can be broken down into natural plant sugars. The carbon and other elements in these natural sugars are then used to make NatureWorks PLA.

F

Nature Works PLA fits all disposal systems and is fully compostable in commercial composting facilities. With the proper infrastructure, products made from this polymer can be recycled back to a monomer and re-used as a polymer. Thus, at the end of its life cycle, a product made from Nature Works PLA can be broken down into its simplest parts so that no sign of it remains.

G

PLA is now actively competing with traditional materials in packaging and fiber applications throughout the world; based on the technology’s success and promise, Cargill Dow is quickly becoming a premier player in the polymers market. This new polymer now competes head-on with petroleum-based materials like polyester. A wide range of products that vary in molecular weight and crystallinity can be produced, and the blend of physical properties of PLA makes it suited for a broad range of fiber and packaging applications. Fiber and non-woven applications include clothing, fiberfill, blankets and wipes. Packaging applications include packaging films and food and beverage containers.

H

As Nature Works PLA polymers are more oil- and grease-resistant and provide a better flavor and aroma barrier than existing petroleum-based polymers, grocery retailers are increasingly using this packaging for their fresh foods. As companies begin to explore this family of polymers, more potential applications are being identified. For example, PLA possess two properties that are particularly useful for drape fabrics and window furnishings. Their resistance to ultraviolet light is particularly appealing as this reduces the amount of fading in such fabrics, and their refractive index is low, which means fabrics constructed from these polymers can be made with deep colors without requiring large amounts of dye. In addition, sportswear makers have been drawn to the product as it has an inherent ability to take moisture away from the skin and when blended with cotton and wool, the result is garments that are lighter and better at absorbing moisture.

I

PLA combines inexpensive large-scale fermentation with chemical processing to produce a value-added polymer product that improves the environment as well. The source material for PLA is a natural sugar found in plants such as com and using such renewable feedstock presents several environmental benefits. As an alternative to traditional petroleum-based polymers, the production of PLA uses 20%-50% less fossil fuel and releases a lower amount of greenhouse gasses than comparable petroleum-based plastic; carbon dioxide in the atmosphere is removed when the feedstock is grown and is returned to the earth when the polymer is degraded. Because the company is using raw materials that can be regenerated year after year, it is both cost-competitive and environmentally responsible.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('589bfd7f-50df-511a-808a-7e7d9db8d1f8', 'e481cd4e-e776-5614-833c-826b8578776b', 1, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 1

Questions 1-4
Questions 1-4
Write the letters
A-F
in boxes
1-4
on your answer sheet.
1
scientists manage to
2
Cargill needs to have contacts with
3
Nature work is used for
4
Ingeo is used to
A
make things like clothes
B
produce plastic from plant
C
selling plastic in market
D
fermentation process
E
drape fabrics
F
wrapping products

1 ____ scientists manage to$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e154dae9-505b-5e6a-b2f3-aaa8faab1cfa', '589bfd7f-50df-511a-808a-7e7d9db8d1f8', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c437725d-650b-50a3-a6df-3440e310cbda', '589bfd7f-50df-511a-808a-7e7d9db8d1f8', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b8fdd1bb-ba1d-581d-afb3-1225f32ced99', '589bfd7f-50df-511a-808a-7e7d9db8d1f8', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3acbcae1-f578-50da-9b0b-0a5b26a02bab', '589bfd7f-50df-511a-808a-7e7d9db8d1f8', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fea67bad-194f-5ed1-9fd9-74649e2238e0', '589bfd7f-50df-511a-808a-7e7d9db8d1f8', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('33a59f33-c39f-5b23-867d-58f1fcd37154', '589bfd7f-50df-511a-808a-7e7d9db8d1f8', 6, $md$F$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('f373990f-0199-5bd3-932d-201c480b2209', 'e481cd4e-e776-5614-833c-826b8578776b', 2, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 2

Questions 1-4
Questions 1-4
Write the letters
A-F
in boxes
1-4
on your answer sheet.
1
scientists manage to
2
Cargill needs to have contacts with
3
Nature work is used for
4
Ingeo is used to
A
make things like clothes
B
produce plastic from plant
C
selling plastic in market
D
fermentation process
E
drape fabrics
F
wrapping products

2 ____ Cargill needs to have contacts with$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e0286c89-c194-59f4-8fbf-b8ac0161c6e7', 'f373990f-0199-5bd3-932d-201c480b2209', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b0624b8e-f499-5eda-8c6a-656193b8dca4', 'f373990f-0199-5bd3-932d-201c480b2209', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('843fd7ad-b724-5479-971b-5bed13a2b4b2', 'f373990f-0199-5bd3-932d-201c480b2209', 3, $md$C$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e9db0fb1-f912-545b-878a-a9c4fd73ab57', 'f373990f-0199-5bd3-932d-201c480b2209', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('40721e46-977d-56b1-b89e-5ddc2f205bc1', 'f373990f-0199-5bd3-932d-201c480b2209', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('92254fe6-6fd0-51c3-b984-1b2d183bdf55', 'f373990f-0199-5bd3-932d-201c480b2209', 6, $md$F$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('634eb4d6-cd76-5abc-a1ee-a5ad4d583c65', 'e481cd4e-e776-5614-833c-826b8578776b', 3, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 3

Questions 1-4
Questions 1-4
Write the letters
A-F
in boxes
1-4
on your answer sheet.
1
scientists manage to
2
Cargill needs to have contacts with
3
Nature work is used for
4
Ingeo is used to
A
make things like clothes
B
produce plastic from plant
C
selling plastic in market
D
fermentation process
E
drape fabrics
F
wrapping products

3 ____ Nature work is used for$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c524f7fb-038e-5914-8dc1-845005b7cd06', '634eb4d6-cd76-5abc-a1ee-a5ad4d583c65', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4cecd9fb-2780-50c6-8924-230239ca9004', '634eb4d6-cd76-5abc-a1ee-a5ad4d583c65', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4aaf2b94-43d4-5926-915b-7a9ff652e5b7', '634eb4d6-cd76-5abc-a1ee-a5ad4d583c65', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b8f49e39-16e1-50ff-a626-e049c2127615', '634eb4d6-cd76-5abc-a1ee-a5ad4d583c65', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b9244776-bb23-58d0-8bbe-19ec8d33aa57', '634eb4d6-cd76-5abc-a1ee-a5ad4d583c65', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f34bd79f-3133-5578-92d9-a20ba5ef1059', '634eb4d6-cd76-5abc-a1ee-a5ad4d583c65', 6, $md$F$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('7c497b86-6651-5af1-85be-a9cd2d7b35e9', 'e481cd4e-e776-5614-833c-826b8578776b', 4, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 4

Questions 1-4
Questions 1-4
Write the letters
A-F
in boxes
1-4
on your answer sheet.
1
scientists manage to
2
Cargill needs to have contacts with
3
Nature work is used for
4
Ingeo is used to
A
make things like clothes
B
produce plastic from plant
C
selling plastic in market
D
fermentation process
E
drape fabrics
F
wrapping products

4 ____ Ingeo is used to$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5c0865f6-2cd3-54c2-a2fa-0c021792e6f2', '7c497b86-6651-5af1-85be-a9cd2d7b35e9', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3a7035ac-3bd4-59b3-a4b3-4b978de2c497', '7c497b86-6651-5af1-85be-a9cd2d7b35e9', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a4df77fb-cd6b-5d36-a5a3-724938f0be42', '7c497b86-6651-5af1-85be-a9cd2d7b35e9', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9a5e424a-02bd-546a-bc5a-7c92a233684c', '7c497b86-6651-5af1-85be-a9cd2d7b35e9', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8e0899aa-9230-565a-9072-6719c59b31b2', '7c497b86-6651-5af1-85be-a9cd2d7b35e9', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c9b2fbfa-808d-52a3-91de-d9d5cc776f7a', '7c497b86-6651-5af1-85be-a9cd2d7b35e9', 6, $md$F$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('8b42f555-d5ff-5323-ac96-e6b547c77cc7', 'e481cd4e-e776-5614-833c-826b8578776b', 5, 'SUMMARY_COMPLETION', 'READING', 3, $md$### Question 5

Questions 5-8
Questions 5-8
Complete the following summary of the paragraphs of Reading Passage.
Using
NO MORE THAN TWO WORDS
from the Reading Passage for each answer.
Write your answers in boxes
5-8
on your answer sheet.
Process: the production of PLA
5
6
7
8

5 ____$md$, NULL, ARRAY['.*starch.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('ddb524b7-e0a6-5be1-b77f-2aac9d5f45e9', 'e481cd4e-e776-5614-833c-826b8578776b', 6, 'SUMMARY_COMPLETION', 'READING', 3, $md$### Question 6

Questions 5-8
Questions 5-8
Complete the following summary of the paragraphs of Reading Passage.
Using
NO MORE THAN TWO WORDS
from the Reading Passage for each answer.
Write your answers in boxes
5-8
on your answer sheet.
Process: the production of PLA
5
6
7
8

6 ____$md$, NULL, ARRAY['.*fermentation.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('61130e94-6b29-587b-8473-6d6f4c13948a', 'e481cd4e-e776-5614-833c-826b8578776b', 7, 'SUMMARY_COMPLETION', 'READING', 3, $md$### Question 7

Questions 5-8
Questions 5-8
Complete the following summary of the paragraphs of Reading Passage.
Using
NO MORE THAN TWO WORDS
from the Reading Passage for each answer.
Write your answers in boxes
5-8
on your answer sheet.
Process: the production of PLA
5
6
7
8

7 ____$md$, NULL, ARRAY['.*condensation.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('2186f7b8-1ae8-535d-9f6c-0d7e3c53e747', 'e481cd4e-e776-5614-833c-826b8578776b', 8, 'SUMMARY_COMPLETION', 'READING', 3, $md$### Question 8

Questions 5-8
Questions 5-8
Complete the following summary of the paragraphs of Reading Passage.
Using
NO MORE THAN TWO WORDS
from the Reading Passage for each answer.
Write your answers in boxes
5-8
on your answer sheet.
Process: the production of PLA
5
6
7
8

8 ____$md$, NULL, ARRAY['.*polymer.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('56b6e14a-dbf1-5ea2-96bf-78aef33bf320', 'e481cd4e-e776-5614-833c-826b8578776b', 9, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 9

Questions 9-10
Questions 9-10
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
9-10
on your answer sheet.
9.
Why did choose the PLA as material for food packaging?
A
It smells good
B
It can save food freshness
C
It can be used on other materials
D
Some other things need to be revised about it.
10.
What is PLA packaging is used for?
A
absorbing moisture
B
composting facilities
C
Packaging fresh food
D
manufacturing

Choose the correct letter, A , B , C or D .$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('c90ae03e-d350-5e84-bb25-759f95e431a2', 'e481cd4e-e776-5614-833c-826b8578776b', 10, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 10

Questions 9-10
Questions 9-10
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
9-10
on your answer sheet.
9.
Why did choose the PLA as material for food packaging?
A
It smells good
B
It can save food freshness
C
It can be used on other materials
D
Some other things need to be revised about it.
10.
What is PLA packaging is used for?
A
absorbing moisture
B
composting facilities
C
Packaging fresh food
D
manufacturing

Choose the correct letter, A , B , C or D .$md$, NULL);

COMMIT;
