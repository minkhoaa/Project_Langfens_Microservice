BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-wood-a-valuable-resource-in-new-zealands-economy--1468'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-wood-a-valuable-resource-in-new-zealands-economy--1468';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-wood-a-valuable-resource-in-new-zealands-economy--1468';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-wood-a-valuable-resource-in-new-zealands-economy--1468';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('00565578-d626-53ad-9541-89f8a08850b7', 'ielts-reading-wood-a-valuable-resource-in-new-zealands-economy--1468', $t$Wood: a valuable resource in New Zealand’s economy$t$, $md$## Wood: a valuable resource in New Zealand’s economy

Nguồn:
- Test: https://mini-ielts.com/1468/reading/wood-a-valuable-resource-in-new-zealands-economy-
- Solution: https://mini-ielts.com/1468/view-solution/reading/wood-a-valuable-resource-in-new-zealands-economy-$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('65bb3fe4-4d1b-5244-97ba-ee614cba753e', '00565578-d626-53ad-9541-89f8a08850b7', 1, $t$Reading — Wood: a valuable resource in New Zealand’s economy$t$, $md$Read the passage and answer questions **1–6**.

### Passage: Wood: a valuable resource in New Zealand’s economy

During the settlement of New Zealand by European immigrants, natural timbers played a major role. Wood was easily accessible and relatively cheap. A tradition of wooden housed arose, supported by the recognition that they were less likely to collapse suddenly during earthquakes, a not infrequent event in this part of the world. But in addition to demand from the domestic market, there was also a demand for forest products from overseas.

Early explores recognised the suitability of the tall, straight trunks of the kauri for constructing sailing vessels. The kauri is a species of coniferous tree found only in small areas of the southern hemisphere. So from the early 1800s, huge amounts of this type of wood were sold to Australia and the UK for that purpose. For a period, the forestry industry was the country’s major export earner but the rate of harvest was unsustainable and, by the beginning of the 2O' n century, indigenous timber exports were rapidly declining.

From the 1940s, newly established plantations of an imported, species of tree called radiate pine supplied timber and other wood products in increasing quantities. By the 1960s, plantation- grown timber was providing most of the the basis of paper.

Pulp: wood which is crushed until soft enough to country's sawn timber needs, especially for construction. Today, less than two per cent of timber is cut from indigenous forest, and almost ail of that is used for higher- value end uses, such as furniture and fittings. As the pine industry developed, it became apparent that this type of wood was also well suited for many uses. It makes excellent pulp*, and is frequently used for post, poles, furnishings and moldings, particleboard, fiberboard, and for plywood and' engineered' wood products. Pine by- products are used in the chemical and pharmaceutical industries and residues are consumed for fuel. This amazing versatility has encouraged the development of an integrated forest- products industry which is almost unique in the world.

Exporters of wood products have largely targeted the rapidly growing markets of South and East Asia and Australia. 80 percent of exports by value go to only five markets: Japan, Korea, China, the United States and Australia. The product mix remains heavily based on raw materials, with logs, sawn wood, pulp and paper comprising 75 per cent of export value. However, finished wood products such as panels and furniture components are exported to more than 50 countries.

In New Zealand itself, the construction industry is the principal user of solid wood products, servicing around 20000 new house starts annually. However, the small size of New Zealand's population (just over four million), plus its small manufacturing and remanufacturing base, limit the forestry industry's domestic opportunities. For the last few years local wood consumption has been around only four million cubic metres. Accordingly, the development of the export market is the key to the industry's growth and contribution to the national economy in decades to come.

In 2004, forestry export receipts were about 11 per cent of the country's total export income, their value having increased steadily for ten years, until affected by the exchange fluctuations and shipping costs of recent years. The forestry industry is New Zealand's third largest export sector, generating around $ 3.3 billion annually from logs and processed wood products. But it is generally agreed that it is operating well below its capacity and, with the domestic market already at its peak, almost all of the extra wood produced in future will have to be marketed overseas. That presents a major marketing challenge for the industry.

Although the export of logs will continue to provide valuable earnings for forest owners, there is broad acceptance that the industry mu3t be based on valuable earnings or forest owners, there is broad acceptance that the industry must be based on value- added products in future. So the industry is investigating various processing. Infrastructure and investment strategies with a view to increasing the level of local manufacturing before export. The keys to factors, better international marketing, product innovation, internationally competitive processing, better infrastructure, and a suitable political, regulatory and investment environment. The industry claim that given the right conditions, by 2025 the forestry sector could be the country's biggest export earner, generating $20 billion a year and employing 60000 people

One competitive advantages that New Zealand has is its ability to source large quantities of softwood from renewable forests. Consumers in several key wood markets are becoming more worried about sustainability, and the industry is supporting the development of national standards as well as the recognition of these internationally. However, New Zealand is not the only country with a planation- style forestry industry. Chile, brazil, Argentina, South Africa and Australia all have extensive plantings of fast growing species ( hardwood and softwood), and in the northern hemisphere, Scandinavian countries have all expanded their forest or controlled their use in the interests of future production.

Finally, in addition to completion from other wood producers, New Zealand faces competition from goods such as wood substitutes. These include stool framing for houses. This further underlines the necessity for globally competitive production and marketing strategies.

Pulp: wood which Is crushed until soft enough to form the basis of paper.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('160d3a8a-b7ac-5030-afb6-26d8c03581ca', '65bb3fe4-4d1b-5244-97ba-ee614cba753e', 1, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 1

Questions 1-6
Questions 1-6
Do the following statements agree with the information given in Reading Passage?
In boxed 1-6 on your answer sheet, write
TRUE if the statement agree with the information
FALE if the statement contradicts the information
NOT GIVEN if there is no information on this.
1
Setlters realised that wooden houses were more dangerous than other types of structure
2
During the 1800s, New Zealand exported wood for use in boat- building.
3
Plantation- grown wood is generally better for construction than native- forest wood.
4
Cottipaie to oUiei types of wood, pine lias a nanow range of uses.
5
Demand for housing in New Zealand is predicted to fall in the next few years.
6
In furure. the expansion of New Zealand’s wood industry will depend on its exports.

1 ____ Setlters realised that wooden houses were more dangerous than other types of structure$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0d0cb718-83ed-5f2b-9e63-3f7147faae77', '160d3a8a-b7ac-5030-afb6-26d8c03581ca', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0acc8b9e-e53a-56a4-8ca6-edf57f6c6171', '160d3a8a-b7ac-5030-afb6-26d8c03581ca', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4e4f6f7c-dc5e-591e-b800-f18deba3b6d1', '160d3a8a-b7ac-5030-afb6-26d8c03581ca', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('4381aa3c-d6c6-5039-afc6-ec9ba267c04f', '65bb3fe4-4d1b-5244-97ba-ee614cba753e', 2, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 2

Questions 1-6
Questions 1-6
Do the following statements agree with the information given in Reading Passage?
In boxed 1-6 on your answer sheet, write
TRUE if the statement agree with the information
FALE if the statement contradicts the information
NOT GIVEN if there is no information on this.
1
Setlters realised that wooden houses were more dangerous than other types of structure
2
During the 1800s, New Zealand exported wood for use in boat- building.
3
Plantation- grown wood is generally better for construction than native- forest wood.
4
Cottipaie to oUiei types of wood, pine lias a nanow range of uses.
5
Demand for housing in New Zealand is predicted to fall in the next few years.
6
In furure. the expansion of New Zealand’s wood industry will depend on its exports.

2 ____ During the 1800s, New Zealand exported wood for use in boat- building.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('44140dc0-eeeb-50f0-afda-530783f13c92', '4381aa3c-d6c6-5039-afc6-ec9ba267c04f', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2b95b4aa-f6d7-582b-9814-467e9be0755e', '4381aa3c-d6c6-5039-afc6-ec9ba267c04f', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('53204b76-0eb8-5b68-91f8-ee06baced9a9', '4381aa3c-d6c6-5039-afc6-ec9ba267c04f', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('7f240402-e5dd-5536-89fe-da5b02fb6976', '65bb3fe4-4d1b-5244-97ba-ee614cba753e', 3, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 3

Questions 1-6
Questions 1-6
Do the following statements agree with the information given in Reading Passage?
In boxed 1-6 on your answer sheet, write
TRUE if the statement agree with the information
FALE if the statement contradicts the information
NOT GIVEN if there is no information on this.
1
Setlters realised that wooden houses were more dangerous than other types of structure
2
During the 1800s, New Zealand exported wood for use in boat- building.
3
Plantation- grown wood is generally better for construction than native- forest wood.
4
Cottipaie to oUiei types of wood, pine lias a nanow range of uses.
5
Demand for housing in New Zealand is predicted to fall in the next few years.
6
In furure. the expansion of New Zealand’s wood industry will depend on its exports.

3 ____ Plantation- grown wood is generally better for construction than native- forest wood.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d50786ee-b322-5fc8-be00-16556a3288c9', '7f240402-e5dd-5536-89fe-da5b02fb6976', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bb3450ac-93ed-51ca-8c00-245c1b551b06', '7f240402-e5dd-5536-89fe-da5b02fb6976', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('feaee8d3-3e34-57ae-b6c5-cb747b511c62', '7f240402-e5dd-5536-89fe-da5b02fb6976', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('a32afb84-2e23-5d52-8ad9-14b9e780cffc', '65bb3fe4-4d1b-5244-97ba-ee614cba753e', 4, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 4

Questions 1-6
Questions 1-6
Do the following statements agree with the information given in Reading Passage?
In boxed 1-6 on your answer sheet, write
TRUE if the statement agree with the information
FALE if the statement contradicts the information
NOT GIVEN if there is no information on this.
1
Setlters realised that wooden houses were more dangerous than other types of structure
2
During the 1800s, New Zealand exported wood for use in boat- building.
3
Plantation- grown wood is generally better for construction than native- forest wood.
4
Cottipaie to oUiei types of wood, pine lias a nanow range of uses.
5
Demand for housing in New Zealand is predicted to fall in the next few years.
6
In furure. the expansion of New Zealand’s wood industry will depend on its exports.

4 ____ Cottipaie to oUiei types of wood, pine lias a nanow range of uses.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d386abff-a83c-5b09-be91-384d702c286b', 'a32afb84-2e23-5d52-8ad9-14b9e780cffc', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('842ba690-96aa-5af6-96fd-f6da95d6664a', 'a32afb84-2e23-5d52-8ad9-14b9e780cffc', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9768d062-a564-5ab9-a424-fd6a7184535a', 'a32afb84-2e23-5d52-8ad9-14b9e780cffc', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('e7b7a3ea-a744-5d2a-95c7-20022bf7e356', '65bb3fe4-4d1b-5244-97ba-ee614cba753e', 5, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 5

Questions 1-6
Questions 1-6
Do the following statements agree with the information given in Reading Passage?
In boxed 1-6 on your answer sheet, write
TRUE if the statement agree with the information
FALE if the statement contradicts the information
NOT GIVEN if there is no information on this.
1
Setlters realised that wooden houses were more dangerous than other types of structure
2
During the 1800s, New Zealand exported wood for use in boat- building.
3
Plantation- grown wood is generally better for construction than native- forest wood.
4
Cottipaie to oUiei types of wood, pine lias a nanow range of uses.
5
Demand for housing in New Zealand is predicted to fall in the next few years.
6
In furure. the expansion of New Zealand’s wood industry will depend on its exports.

5 ____ Demand for housing in New Zealand is predicted to fall in the next few years.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6366d444-98b0-5249-97c4-84a1c33dc62d', 'e7b7a3ea-a744-5d2a-95c7-20022bf7e356', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('df5f99d8-7d6f-51c2-a712-b93f097683c0', 'e7b7a3ea-a744-5d2a-95c7-20022bf7e356', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4870ddea-a4a3-54f8-8f23-54f4c2cab9d5', 'e7b7a3ea-a744-5d2a-95c7-20022bf7e356', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('45a1cf68-9249-540e-8103-c17cf8e659b6', '65bb3fe4-4d1b-5244-97ba-ee614cba753e', 6, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 6

Questions 1-6
Questions 1-6
Do the following statements agree with the information given in Reading Passage?
In boxed 1-6 on your answer sheet, write
TRUE if the statement agree with the information
FALE if the statement contradicts the information
NOT GIVEN if there is no information on this.
1
Setlters realised that wooden houses were more dangerous than other types of structure
2
During the 1800s, New Zealand exported wood for use in boat- building.
3
Plantation- grown wood is generally better for construction than native- forest wood.
4
Cottipaie to oUiei types of wood, pine lias a nanow range of uses.
5
Demand for housing in New Zealand is predicted to fall in the next few years.
6
In furure. the expansion of New Zealand’s wood industry will depend on its exports.

6 ____ In furure. the expansion of New Zealand’s wood industry will depend on its exports.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('358a0b6f-9b0f-5e07-9345-0f8fc665f0b8', '45a1cf68-9249-540e-8103-c17cf8e659b6', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2761c4f4-de69-5fb7-ae7a-90286376e3f5', '45a1cf68-9249-540e-8103-c17cf8e659b6', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3f779d65-7c01-58fe-92b5-89007a13fdd6', '45a1cf68-9249-540e-8103-c17cf8e659b6', 3, $md$NOT GIVEN$md$, false);

COMMIT;
