BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-skyscraper-farming-1448'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-skyscraper-farming-1448';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-skyscraper-farming-1448';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-skyscraper-farming-1448';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('caa54988-c73c-5123-82ed-3c4148076ee6', 'ielts-reading-skyscraper-farming-1448', $t$Skyscraper Farming$t$, $md$## Skyscraper Farming

Nguồn:
- Test: https://mini-ielts.com/1448/reading/skyscraper-farming
- Solution: https://mini-ielts.com/1448/view-solution/reading/skyscraper-farming$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('14f5664d-77f6-5143-bdba-3c87f29e1c4c', 'caa54988-c73c-5123-82ed-3c4148076ee6', 1, $t$Reading — Skyscraper Farming$t$, $md$Read the passage and answer questions **1–13**.

### Passage: Skyscraper Farming

With a global food crisis predicted, a group of scientists is advocating an innovative alternative to conventional farming that could radically transform the way that food is produced .

A Today's environment scientists are in no doubt that the world's resources of fertile sol are rapidly deteriorating, and that new land for agriculture is becoming ever more sparse Intensive farming urbanisation, desertification and sea-level rises are all putting growing pressure on the planers agricultural land and therefore on food supplies. Currently 24 per cent of the worlds 11.5 billion hectares of cultivated land has already undergone human- induced soil degradation particularly through erosion, according to a recent study by the UK Government Office for Science.

B. The global population is expected to exceed nine billion by 2050 - up a third from today's level and studies suggest that food production will have to go up by 70 per cent if we are to feed all of those new mouths This means that scientists will have to develop new ways of growing crops if we are to avoid a humanitarian crisis. Indeed, UN Food and Agriculture Organization figures suggest that the number of undernourished people is already growing. And with escalating climate change, crop yields in many areas have been projected to decline

C. With this in mind, some scientists and agricultural experts are advocating an innovative alternative to traditional farming whereby skyscrapers packed with shelf-based systems for growing vegetables on each storey -known as 'vertical farms' - could hold the key to revolutionising agriculture. Columbia University professor Dickson Despommier claims that vertical farming could boost crop yields many times over. A single 20-storey vertical farm could theoretically feed 50 000 people, according to Despommier. And if the theory translates Into realty as proposed. 160 skyscraper-sized vertical farms could feed the entire population of New York City, while 180 would be needed to feed London, 289 to feed Cairo and 302 to feed Kolkata a.

D It's a compelling vision, and one that has already been put into practice in Asia. Albeit on a smaller scale But there are problems, such as initial investment and operating costs that are too great' says a spokesman for Japan's Ministry of Agriculture, Forestry and Fisheries Nevertheless Tokyo-based mushroom producer Hokuto Corporation is a model example of how a vertical farm can be profitable. With 28 vertical mushroom farms operating across the country, it produces some 68,000 tonnes of mushrooms annually. Vertical mushroom fams have more advantages than ground-level farms,' says Hokuto's Ted Yamanoko. Yamanoko goes on to highlight the relative cost-effectiveness of his organisation's farming practices together with reduced emissions of greenhouse gases

E And the impact of vertical farms could extend beyond feeding established urban populations. Despommier sees them as being capable of helping centres of displaced persons - such as refugee camps - in much the same way that Mobile Army Surgical Hospital (MASH) units are deployed in emergency situations. "Developing an emergency­response system for crop production inside specially constructed modular and highly transportable greenhouses would allow for humanitarian interventions, at least tor refuges that are forced out of their countries by political tumor, he says. If you have three or four storeys of food already growing some place, they could become mobile units that could be picked up by helicopters and dropped into the middle of a crisis zone. The food would be ready to pick and eat. It could be designed to supply people with all the nutrition they need to make it through the crisis."

F But it isn't only about increasing food production. Despommier is concerned about the harm which farming has done to the world's landscape over a relatively short time span, particularly the elimination of hardwood forests. Farming is only 12,000 years old, 'he points allow US for the first time to feed everyone on earth and still return land to its original ecological function.' Natalie Jeremijenko, associate professor at New York University, agrees. The challenge that we have now is how we can design urban agriculture systems that not only reduce food miles, but also improve the world's ecosystems,' she says. By significantly reducing the amount of land required for food production, vertical farms could help to enrich biodiversity. And according to Jeremijenko, this can, in turn, help to improve the productivity of conventional farms, as the health of agricultural land is often tied to the health of the surrounding ecosystems. Furthermore, vertical farming could dramatically cut the utilisation of fossil fuels. And also reduce geopolitical tensions in countries where poor farming conditions cause conflict and malnutrition.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('4ff8947b-ec9b-5bc1-a93d-4cee493f7a07', '14f5664d-77f6-5143-bdba-3c87f29e1c4c', 1, 'MATCHING_HEADING', 'READING', 2, $md$### Question 1

Questions 1-6
Questions 1-6
Reading Passage has six paragraphs. A-F
Choose the correct heading for each paragraph from the list of headings below.
Write the correct number, in boxes 1-6 on your answer sheet.
List of Headings
Potential production capabilities of vertical farms
Opposition to new ideas about food production
A successful application of vertical farming technology
The potential to provide urgent relief
The original inspiration for vertical farming
Various environmental benefits of vertical farming
An increasing problem for farmers worldwide
A return to traditional farming methods
A rising demand for food
1
Paragraph A
2
Paragraph B
3
Paragraph C
4
Paragraph D
5
Paragraph E
6
Paragraph F

1 ____ Paragraph A$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('24e98a6c-602d-5736-aa86-14a40b06a3c7', '4ff8947b-ec9b-5bc1-a93d-4cee493f7a07', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('04e12cb2-84e0-50b4-8ccd-e11b1ca02f99', '4ff8947b-ec9b-5bc1-a93d-4cee493f7a07', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9e3b8702-aa2f-5902-816a-694c333635ba', '4ff8947b-ec9b-5bc1-a93d-4cee493f7a07', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('da258f84-eed9-5403-b453-1871197cd06e', '4ff8947b-ec9b-5bc1-a93d-4cee493f7a07', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ae21d79a-a285-564e-b537-7d5190eac44d', '4ff8947b-ec9b-5bc1-a93d-4cee493f7a07', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d1f6faf7-c7b4-5aa1-a1e7-6ee94213dc34', '4ff8947b-ec9b-5bc1-a93d-4cee493f7a07', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9a45f4c6-e45f-5722-a333-a6f1c053e421', '4ff8947b-ec9b-5bc1-a93d-4cee493f7a07', 7, $md$vii$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3a0e2d05-46f6-5d73-ba4e-a6ee3e88ee0b', '4ff8947b-ec9b-5bc1-a93d-4cee493f7a07', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('687e02c2-99be-571f-8ca5-db0be8940bfd', '4ff8947b-ec9b-5bc1-a93d-4cee493f7a07', 9, $md$ix$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('28f2f58e-8a05-5245-9616-6f49aff8f724', '14f5664d-77f6-5143-bdba-3c87f29e1c4c', 2, 'MATCHING_HEADING', 'READING', 2, $md$### Question 2

Questions 1-6
Questions 1-6
Reading Passage has six paragraphs. A-F
Choose the correct heading for each paragraph from the list of headings below.
Write the correct number, in boxes 1-6 on your answer sheet.
List of Headings
Potential production capabilities of vertical farms
Opposition to new ideas about food production
A successful application of vertical farming technology
The potential to provide urgent relief
The original inspiration for vertical farming
Various environmental benefits of vertical farming
An increasing problem for farmers worldwide
A return to traditional farming methods
A rising demand for food
1
Paragraph A
2
Paragraph B
3
Paragraph C
4
Paragraph D
5
Paragraph E
6
Paragraph F

2 ____ Paragraph B$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c0440ed1-a930-5207-9bc9-c951179c57f4', '28f2f58e-8a05-5245-9616-6f49aff8f724', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1847257c-7b9f-50d7-afe4-5b90951a7095', '28f2f58e-8a05-5245-9616-6f49aff8f724', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4f8b5c15-b661-539b-9671-a09a10eaaa1b', '28f2f58e-8a05-5245-9616-6f49aff8f724', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('616673c1-6bf5-54c5-8424-934fadb53e27', '28f2f58e-8a05-5245-9616-6f49aff8f724', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6ae54c65-7ad2-5db8-96cd-92279e6fc862', '28f2f58e-8a05-5245-9616-6f49aff8f724', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e9ebe8c7-1989-54d6-9cda-2f0a2d77fd30', '28f2f58e-8a05-5245-9616-6f49aff8f724', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b045f9ac-f3aa-53c1-b76f-0989415c3649', '28f2f58e-8a05-5245-9616-6f49aff8f724', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1e26d25f-9044-587c-9d4e-567d2d8babd1', '28f2f58e-8a05-5245-9616-6f49aff8f724', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fae73067-823c-58d5-a3f0-f6e4967e57d8', '28f2f58e-8a05-5245-9616-6f49aff8f724', 9, $md$ix$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('afb818e2-d788-542e-a957-da3e485f5978', '14f5664d-77f6-5143-bdba-3c87f29e1c4c', 3, 'MATCHING_HEADING', 'READING', 2, $md$### Question 3

Questions 1-6
Questions 1-6
Reading Passage has six paragraphs. A-F
Choose the correct heading for each paragraph from the list of headings below.
Write the correct number, in boxes 1-6 on your answer sheet.
List of Headings
Potential production capabilities of vertical farms
Opposition to new ideas about food production
A successful application of vertical farming technology
The potential to provide urgent relief
The original inspiration for vertical farming
Various environmental benefits of vertical farming
An increasing problem for farmers worldwide
A return to traditional farming methods
A rising demand for food
1
Paragraph A
2
Paragraph B
3
Paragraph C
4
Paragraph D
5
Paragraph E
6
Paragraph F

3 ____ Paragraph C$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('92647bbc-dc4f-51ef-a5b0-c38bae94ab5d', 'afb818e2-d788-542e-a957-da3e485f5978', 1, $md$i$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5c1fa26f-24f9-5cba-9023-06498519a41b', 'afb818e2-d788-542e-a957-da3e485f5978', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('07bfb6aa-26e7-5fc9-b324-cce61a1b3de4', 'afb818e2-d788-542e-a957-da3e485f5978', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('94bb654c-fc03-5989-ae1d-fdbfaa75aa7e', 'afb818e2-d788-542e-a957-da3e485f5978', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('09611772-7c4a-56b4-bda1-481182acc08e', 'afb818e2-d788-542e-a957-da3e485f5978', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('37903c4d-d9b1-556c-85cb-246fe26888e5', 'afb818e2-d788-542e-a957-da3e485f5978', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6c9c75ee-2ca3-5b33-b11b-3cb92186efc8', 'afb818e2-d788-542e-a957-da3e485f5978', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('83e6c7bb-e6d5-5ecb-ba32-f84e67aa4a71', 'afb818e2-d788-542e-a957-da3e485f5978', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8ab5a6fc-fd22-52a2-8631-05b8810c329e', 'afb818e2-d788-542e-a957-da3e485f5978', 9, $md$ix$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('1a488606-a0b9-5fc4-8176-61b7054b9e07', '14f5664d-77f6-5143-bdba-3c87f29e1c4c', 4, 'MATCHING_HEADING', 'READING', 2, $md$### Question 4

Questions 1-6
Questions 1-6
Reading Passage has six paragraphs. A-F
Choose the correct heading for each paragraph from the list of headings below.
Write the correct number, in boxes 1-6 on your answer sheet.
List of Headings
Potential production capabilities of vertical farms
Opposition to new ideas about food production
A successful application of vertical farming technology
The potential to provide urgent relief
The original inspiration for vertical farming
Various environmental benefits of vertical farming
An increasing problem for farmers worldwide
A return to traditional farming methods
A rising demand for food
1
Paragraph A
2
Paragraph B
3
Paragraph C
4
Paragraph D
5
Paragraph E
6
Paragraph F

4 ____ Paragraph D$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c429ca61-b469-5b15-9f7f-9f815f7a0ce9', '1a488606-a0b9-5fc4-8176-61b7054b9e07', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('dba230a4-dee6-51a5-9e8e-f66d98fa2d53', '1a488606-a0b9-5fc4-8176-61b7054b9e07', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e59368d6-8b5b-513d-b553-ce237be868f0', '1a488606-a0b9-5fc4-8176-61b7054b9e07', 3, $md$iii$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('96f1f1e5-72c6-581e-97b0-0f64729ade96', '1a488606-a0b9-5fc4-8176-61b7054b9e07', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a716fc34-a4a6-5158-a2c9-647e70f530e6', '1a488606-a0b9-5fc4-8176-61b7054b9e07', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b625de5a-1ee9-5421-ae47-023778d5244c', '1a488606-a0b9-5fc4-8176-61b7054b9e07', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cbce6856-cc2f-5a03-a33a-0bec74d8d806', '1a488606-a0b9-5fc4-8176-61b7054b9e07', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f9b5974c-4da1-55d1-9e5b-0574361e8fa7', '1a488606-a0b9-5fc4-8176-61b7054b9e07', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('febacb2e-fa66-5a66-9e93-b3d345c9563e', '1a488606-a0b9-5fc4-8176-61b7054b9e07', 9, $md$ix$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('b92625e5-5d3e-5253-ade0-93840073f448', '14f5664d-77f6-5143-bdba-3c87f29e1c4c', 5, 'MATCHING_HEADING', 'READING', 3, $md$### Question 5

Questions 1-6
Questions 1-6
Reading Passage has six paragraphs. A-F
Choose the correct heading for each paragraph from the list of headings below.
Write the correct number, in boxes 1-6 on your answer sheet.
List of Headings
Potential production capabilities of vertical farms
Opposition to new ideas about food production
A successful application of vertical farming technology
The potential to provide urgent relief
The original inspiration for vertical farming
Various environmental benefits of vertical farming
An increasing problem for farmers worldwide
A return to traditional farming methods
A rising demand for food
1
Paragraph A
2
Paragraph B
3
Paragraph C
4
Paragraph D
5
Paragraph E
6
Paragraph F

5 ____ Paragraph E$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('113d2499-e16b-5bce-9b22-f8a5025a7381', 'b92625e5-5d3e-5253-ade0-93840073f448', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d13e86dd-f115-5b0e-9016-4c01a9462bdf', 'b92625e5-5d3e-5253-ade0-93840073f448', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('32eb48d3-2940-5d8a-801e-082d7897d05e', 'b92625e5-5d3e-5253-ade0-93840073f448', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('eacec1fb-e946-5a67-ba48-043b38cdfb72', 'b92625e5-5d3e-5253-ade0-93840073f448', 4, $md$iv$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1f787404-be96-5561-9739-d948e41d14a5', 'b92625e5-5d3e-5253-ade0-93840073f448', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a422917d-03df-5215-8c93-6f5578be0bf3', 'b92625e5-5d3e-5253-ade0-93840073f448', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8e82db4b-3711-593d-b039-42205887d2f5', 'b92625e5-5d3e-5253-ade0-93840073f448', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bbb19231-f6d7-53b3-b44c-94f0d13d6621', 'b92625e5-5d3e-5253-ade0-93840073f448', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f9695bc7-ffbc-5f6f-aacb-a6d87aaad863', 'b92625e5-5d3e-5253-ade0-93840073f448', 9, $md$ix$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('6a907383-637b-5546-85c1-aacffa259173', '14f5664d-77f6-5143-bdba-3c87f29e1c4c', 6, 'MATCHING_HEADING', 'READING', 3, $md$### Question 6

Questions 1-6
Questions 1-6
Reading Passage has six paragraphs. A-F
Choose the correct heading for each paragraph from the list of headings below.
Write the correct number, in boxes 1-6 on your answer sheet.
List of Headings
Potential production capabilities of vertical farms
Opposition to new ideas about food production
A successful application of vertical farming technology
The potential to provide urgent relief
The original inspiration for vertical farming
Various environmental benefits of vertical farming
An increasing problem for farmers worldwide
A return to traditional farming methods
A rising demand for food
1
Paragraph A
2
Paragraph B
3
Paragraph C
4
Paragraph D
5
Paragraph E
6
Paragraph F

6 ____ Paragraph F$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('738b116c-c937-5f13-a34c-949ae6ed7e5d', '6a907383-637b-5546-85c1-aacffa259173', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0e68c88e-1c77-5e71-838a-cf8360c4c56b', '6a907383-637b-5546-85c1-aacffa259173', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('628edc44-984f-515c-9e1f-d333d8c80848', '6a907383-637b-5546-85c1-aacffa259173', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('32383504-5495-512f-b0d8-6af0f46090d4', '6a907383-637b-5546-85c1-aacffa259173', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b4e9ba55-04a2-5753-9d18-ddfcf2034131', '6a907383-637b-5546-85c1-aacffa259173', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('646e6c54-e818-5cd8-948d-b0ca1380ec83', '6a907383-637b-5546-85c1-aacffa259173', 6, $md$vi$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6c18bc64-1eec-5d69-9a8d-7bf07204b0a5', '6a907383-637b-5546-85c1-aacffa259173', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f3e48f84-6c0f-51f7-b9f8-b934c1ef8766', '6a907383-637b-5546-85c1-aacffa259173', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ff3814d7-4de7-5a9d-b84c-637a36b9c3c5', '6a907383-637b-5546-85c1-aacffa259173', 9, $md$ix$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('6d3d6d83-aeed-53b5-9885-39074a0c0f50', '14f5664d-77f6-5143-bdba-3c87f29e1c4c', 7, 'SENTENCE_COMPLETION', 'READING', 3, $md$### Question 7

Questions 7-9
Questions 7-9
Complete the sentences below
Choose NO MORE THAN TWO WORDS from the passage for each answer.
Write your answers in boxes 7-9 on your answer sheet.
7. A UK Government study found that
7
is a significant factor contributing to worldwide levels of soil degradation
8. Disadvantages of vertical taming projects include the expense of setting them up, as well as their high
8
9.
9
could potentially be used to take vertical farming facilities to areas where there is a critical food shortage

7. A UK Government study found that 7 ____ is a significant factor contributing to worldwide levels of soil degradation$md$, NULL, ARRAY['.*erosion.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('5a0879a9-7ab2-5379-b99f-8ce69ac13ebe', '14f5664d-77f6-5143-bdba-3c87f29e1c4c', 8, 'SENTENCE_COMPLETION', 'READING', 3, $md$### Question 8

Questions 7-9
Questions 7-9
Complete the sentences below
Choose NO MORE THAN TWO WORDS from the passage for each answer.
Write your answers in boxes 7-9 on your answer sheet.
7. A UK Government study found that
7
is a significant factor contributing to worldwide levels of soil degradation
8. Disadvantages of vertical taming projects include the expense of setting them up, as well as their high
8
9.
9
could potentially be used to take vertical farming facilities to areas where there is a critical food shortage

8. Disadvantages of vertical taming projects include the expense of setting them up, as well as their high 8 ____$md$, NULL, ARRAY['.*operating.*costs.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('16fc74b4-7f80-5dd8-bab0-291fa5d48908', '14f5664d-77f6-5143-bdba-3c87f29e1c4c', 9, 'SENTENCE_COMPLETION', 'READING', 3, $md$### Question 9

Questions 7-9
Questions 7-9
Complete the sentences below
Choose NO MORE THAN TWO WORDS from the passage for each answer.
Write your answers in boxes 7-9 on your answer sheet.
7. A UK Government study found that
7
is a significant factor contributing to worldwide levels of soil degradation
8. Disadvantages of vertical taming projects include the expense of setting them up, as well as their high
8
9.
9
could potentially be used to take vertical farming facilities to areas where there is a critical food shortage

9. 9 ____ could potentially be used to take vertical farming facilities to areas where there is a critical food shortage$md$, NULL, ARRAY['.*helicopters.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('fdaff39f-9e74-5394-9389-82a0cd59cbe7', '14f5664d-77f6-5143-bdba-3c87f29e1c4c', 10, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 10

Questions 10-13
Questions 10-13
Look at the following statements (Questions 10-13) and the list of people below Match each statement with the correct person, A.B or c
Write the correct letter A, B or c, in boxes 10-13 on your answer sheet
NB You may use any letter more than once
10
Vertical farming can have financial benefits
11
Traditional farming has had a negative effect on the natural world
12
Vertical farming could dramatically increase world food production.
13
Traditional farms may benefit from wider use of vertical farming
List of people
A Dickson Despommier
Ted Yamanoko
Natalie Jeremijenko

10 ____ Vertical farming can have financial benefits$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('528677b9-2e6c-5f1b-ae88-3365764ceafc', 'fdaff39f-9e74-5394-9389-82a0cd59cbe7', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6a33929c-b039-5861-b66b-14e0e5f7c04e', 'fdaff39f-9e74-5394-9389-82a0cd59cbe7', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ac0852df-a460-51ac-819b-996b651030cd', 'fdaff39f-9e74-5394-9389-82a0cd59cbe7', 3, $md$C$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('d4c1ead6-d38b-5e8f-90bb-fc34f39168e7', '14f5664d-77f6-5143-bdba-3c87f29e1c4c', 11, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 11

Questions 10-13
Questions 10-13
Look at the following statements (Questions 10-13) and the list of people below Match each statement with the correct person, A.B or c
Write the correct letter A, B or c, in boxes 10-13 on your answer sheet
NB You may use any letter more than once
10
Vertical farming can have financial benefits
11
Traditional farming has had a negative effect on the natural world
12
Vertical farming could dramatically increase world food production.
13
Traditional farms may benefit from wider use of vertical farming
List of people
A Dickson Despommier
Ted Yamanoko
Natalie Jeremijenko

11 ____ Traditional farming has had a negative effect on the natural world$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('51bab6ec-43ef-541f-bd68-375480e138f7', 'd4c1ead6-d38b-5e8f-90bb-fc34f39168e7', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9f97e584-175e-5ae4-a641-69bbf9161b77', 'd4c1ead6-d38b-5e8f-90bb-fc34f39168e7', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2bf38d76-67d5-539d-9ad6-049abd825daa', 'd4c1ead6-d38b-5e8f-90bb-fc34f39168e7', 3, $md$C$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('bb3012da-34e9-50c0-99cf-96bf8b29d64e', '14f5664d-77f6-5143-bdba-3c87f29e1c4c', 12, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 12

Questions 10-13
Questions 10-13
Look at the following statements (Questions 10-13) and the list of people below Match each statement with the correct person, A.B or c
Write the correct letter A, B or c, in boxes 10-13 on your answer sheet
NB You may use any letter more than once
10
Vertical farming can have financial benefits
11
Traditional farming has had a negative effect on the natural world
12
Vertical farming could dramatically increase world food production.
13
Traditional farms may benefit from wider use of vertical farming
List of people
A Dickson Despommier
Ted Yamanoko
Natalie Jeremijenko

12 ____ Vertical farming could dramatically increase world food production.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8472f5be-6bf9-535e-bb92-00891445fffd', 'bb3012da-34e9-50c0-99cf-96bf8b29d64e', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9a6458bc-d6e3-5d8e-806c-1a3635af4e3a', 'bb3012da-34e9-50c0-99cf-96bf8b29d64e', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('faf28fac-9773-5d83-a40a-f5f06353f68c', 'bb3012da-34e9-50c0-99cf-96bf8b29d64e', 3, $md$C$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('28e977dd-c38c-5b7c-ac48-7e14d792c160', '14f5664d-77f6-5143-bdba-3c87f29e1c4c', 13, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 13

Questions 10-13
Questions 10-13
Look at the following statements (Questions 10-13) and the list of people below Match each statement with the correct person, A.B or c
Write the correct letter A, B or c, in boxes 10-13 on your answer sheet
NB You may use any letter more than once
10
Vertical farming can have financial benefits
11
Traditional farming has had a negative effect on the natural world
12
Vertical farming could dramatically increase world food production.
13
Traditional farms may benefit from wider use of vertical farming
List of people
A Dickson Despommier
Ted Yamanoko
Natalie Jeremijenko

13 ____ Traditional farms may benefit from wider use of vertical farming$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('23a4533b-4ec6-541c-befa-faf375a6beb6', '28e977dd-c38c-5b7c-ac48-7e14d792c160', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('76d8fc7c-a9a0-5200-a8a2-4ba7ff045be1', '28e977dd-c38c-5b7c-ac48-7e14d792c160', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1dda4a1f-6e04-58b6-b35a-ff303934401d', '28e977dd-c38c-5b7c-ac48-7e14d792c160', 3, $md$C$md$, true);

COMMIT;
