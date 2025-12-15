BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-talc-powder-1064'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-talc-powder-1064';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-talc-powder-1064';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-talc-powder-1064';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('d05b1112-7ef4-5e3b-86b8-a84a6f548529', 'ielts-reading-talc-powder-1064', $t$Talc Powder$t$, $md$## Talc Powder

Nguồn:
- Test: https://mini-ielts.com/1064/reading/talc-powder
- Solution: https://mini-ielts.com/1064/view-solution/reading/talc-powder$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('1ab73cf5-c406-58a2-91de-5fa30568b949', 'd05b1112-7ef4-5e3b-86b8-a84a6f548529', 1, $t$Reading — Talc Powder$t$, $md$Read the passage and answer questions **1–14**.

### Passage: Talc Powder

Peter Rrigg discovers how talc from Luzenac’s Trimouns in France find its way into food and agricultural products—from chewing gum to olive oil.

High in the French Pyrenees, some 1,700m above see level, lies Trimouns, a huge deposit of hydrated magnesium silicate - talc to you and me. Talc from Trimouns, and from ten other Luzenac mines across the globe, is used in the manufacture of a vast array of everyday products extending from paper, paint and plaster to cosmetics, plastics and car tyres. And of course there is always talc’s best known end use: talcum powder for babies’ bottoms. But the true versatility of this remarkable mineral is nowhere better displayed than in its sometimes surprising use in certain niche markets in the food and agriculture industries.

Take, for example, the chewing gum business. Every year, Talc de Luzenac France—which owns and operates the Trimouns mine and is a member of the international Luzenac Group (art of Rio Tinto minerals)—supplies about 6,000 tones of talc to chewing gum manufacturers in Europe. “We’ve been selling to this sector of the market since the 1960s,”says Laurent Fournier, sales manager in Luzenac’s Specialties business unit in Toulouse. “Admittedly, in terms of our total annual sales of talc, the amount we supply to chewing gum manufacturers is relatively small, but we see it as a valuable niche market: one where customers place a premium on securing supplies from a reliable, high quality source. Because of this, long term allegiance to a proven suppler is very much a feature of this sector of the talc market.”Switching sources—in the way that you might choose to buy, say, paperclips from Supplier A rather than from Supplier B—is not a easy option for chewing gum manufacturers,”Fournier says. “The cost of reformulating is high, so when customers are using a talc grade that works, even if it’s expensive, they are understandably reluctant to switch.”

But how is talc actually used in the manufacture of chewing gum? PatrickDelord, an engineer with a degree in agronomics, who has been with Luzenac for 22 years and is now senior market development manager, Agriculture and Food, in Europe, explains that chewing gums has four main components. “The most important of them is the gum base,”he says. “It’s the gum base that puts the chew into chewing gum. It binds all the ingredients together, creating a soft, smooth texture. To this the manufacturer then adds sweeteners, softeners and flavourings. Our talc is used as a filler in the gum base . The amount varies between, say, ten and 35 per cent, depending on the type of gum. Fruit flavoured chewing gum, for example, is slightly acidic and would react with the calcium carbonate that the manufacturer might otherwise use as a filler. Talc, on the other hand, makes an ideal filler because it’s non-reactive chemically. In the factory, talc is also used to dust the gum base pellets and to stop the chewing gum sticking during the lamination and packing process,”Delord adds.

The chewing gum business is, however, just one example of talc’s use in the food sector. For the past 20 years or so, olive oil processors in Spain have been taking advantage of talc’s unique characteristics to help them boost the amount of oil they extract from crushed olives. According to Patrick Delord, talc is especially useful for treating what he calls “difficult” olives. After the olives are harvested-preferably early in the morning because their taste is better if they are gathered in the cool of the day - they are taken to the processing plant. There they are crushed and then stirred for 30-45 minutes. In the old days, the resulting paste was passed through an olive press but nowadays it’s more common to add water and centrifuge the mixture to separate the water and oil from the solid matter. The oil and water are then allowed to settle so that the olive oil layer can be decanted oft and bottled. “Difficult” olives are those that are more reluctant than the norm to yield up their full oil content. This may be attributable to the particular species of olive, or to its water content and the time of year the olives are collected—at the beginning and the end of the season their water content is often either too high or too low. These olives are easy to recognize because they produce a lot of extra foam during the stirring process, a consequence of an excess of a fine solid that acts as anatural emulsifier. The oil in this emulsion is lost when the water is disposed of. Not only that, if the waste water is disposed of directly into local fields—often the case in many smaller processing operations—the emulsified oil may take some time to biodegrade and so be harmful to the environment.

“If you add between a half and two percent of talc by weight during the stirring process, it absorbs the natural emulsifier in the olives and so boosts the amount of oil you can extract,”says Delord. “In addition, talc’s flat, 'platy’ structure helps increase the size of the oil droplets liberated during stirring, which again improves the yield . However, because talc is chemically inert, it doesn’t affect the colour, taste, appearance or composition of the resulting olive oil.”

If the use of talc in olive oil processing and in chewing gum is long established, new applications in the food and agriculture industries are also constantly being sought by Luzenac. One such promising new market is fruit crop protection, being pioneered in the US. Just like people, fruit can get sunburned. In fact, in very sunny regions up to 45 percent of atypical crop can be affected by heat stress and sunburn. However, in the case of fruit, it’s not so much the ultra violet rays which harm the crop as the high surface temperature that the sun’s rays create.

To combat this, farmers normally use either chemicals or spray a continuous fine canopy of mist above the fruit trees or bushes. The trouble is, this uses a lot of water—normally a precious commodity in hot, sunny areas—and it is therefore expensive. What’s more, the ground can quickly become waterlogged.” So our idea was to coat the fruit with talc to protect it from the sun,”says Greg Hunter, a marketing specialist who has been with Luzenac for ten years. “But to do this, several technical challenges had first to be overcome. Talc is very hydrophobic: it doesn’t like water. So in order to have a viable product we needed a wettable powder—something that would go readily into suspension so that it could be sprayed onto the fruit. It also had to break the surface tension of the cutin (the natural waxy, waterproof layer on the fruit) and of course it had to wash off easily when the fruit was harvested. No-one’s going to want an apple that’s covered in talc.”

Initial trials in the state of Washington in 2003 showed that when the product was sprayed onto Granny Smith apples, it reduced their surface temperature and lowered the incidence of sunburn by up to 60 per cent . Today the new product, known as Invelop Maximum SPF, is in its second commercial year on the US market. Apple growers are the primary target although Hunter believes grape growers represent another sector with long term potential. He is also hopeful of extending sales to overseas markets such as Australia, South America and southern Europe.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('e0b16ba1-1350-56a6-95fb-8bd909d6bd37', '1ab73cf5-c406-58a2-91de-5fa30568b949', 1, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 1

Questions 1-6
Questions 1-6
Use the information in the passage to match each use of talc power with correct application from
A, B
or
C
.
Write the appropriate letters
A-C
in boxes
1-6
on your answer sheet.
NB
you may use any letter
more than once
A
Chewing gum manufacture
B
Olive oil extraction
C
Fruit crop protection
1
Talc is used to prevent foaming.
Locate
2
Talc is used to prevent stickiness.
Locate
3
Talc is used to boost production.
Locate
4
Talc is used as a filler to provide a base.
Locate
5
Talc is used to prevent sunburn.
Locate
6
Talc is used to help increase the size of the product.
Locate

1 ____ Talc is used to prevent foaming. Locate 2 ____ Talc is used to prevent stickiness. Locate 3 ____ Talc is used to boost production. Locate 4 ____ Talc is used as a filler to provide a base. Locate 5 ____ Talc is used to prevent sunburn. Locate 6 ____ Talc is used to help increase the size of the product. Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1bea3033-2084-5a77-8bb8-95f6ea2e0712', 'e0b16ba1-1350-56a6-95fb-8bd909d6bd37', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('add2d550-11ff-5f11-9f8f-c6f24f74029e', 'e0b16ba1-1350-56a6-95fb-8bd909d6bd37', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7719f889-d960-5525-8036-5093eec06537', 'e0b16ba1-1350-56a6-95fb-8bd909d6bd37', 3, $md$C$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('38b92a9c-e567-5d06-988b-39cc38a1ab20', '1ab73cf5-c406-58a2-91de-5fa30568b949', 2, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 2

Questions 1-6
Questions 1-6
Use the information in the passage to match each use of talc power with correct application from
A, B
or
C
.
Write the appropriate letters
A-C
in boxes
1-6
on your answer sheet.
NB
you may use any letter
more than once
A
Chewing gum manufacture
B
Olive oil extraction
C
Fruit crop protection
1
Talc is used to prevent foaming.
Locate
2
Talc is used to prevent stickiness.
Locate
3
Talc is used to boost production.
Locate
4
Talc is used as a filler to provide a base.
Locate
5
Talc is used to prevent sunburn.
Locate
6
Talc is used to help increase the size of the product.
Locate

1 ____ Talc is used to prevent foaming. Locate 2 ____ Talc is used to prevent stickiness. Locate 3 ____ Talc is used to boost production. Locate 4 ____ Talc is used as a filler to provide a base. Locate 5 ____ Talc is used to prevent sunburn. Locate 6 ____ Talc is used to help increase the size of the product. Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c160134c-6214-57d4-80ee-403bfeea1ef9', '38b92a9c-e567-5d06-988b-39cc38a1ab20', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('10e985db-29db-520b-bbf1-2f7bdfaddd7d', '38b92a9c-e567-5d06-988b-39cc38a1ab20', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a8fe35d5-b820-580e-88bb-2565c1bf9b60', '38b92a9c-e567-5d06-988b-39cc38a1ab20', 3, $md$C$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('25d18303-2606-51c9-a850-c8a56823e4f2', '1ab73cf5-c406-58a2-91de-5fa30568b949', 3, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 3

Questions 1-6
Questions 1-6
Use the information in the passage to match each use of talc power with correct application from
A, B
or
C
.
Write the appropriate letters
A-C
in boxes
1-6
on your answer sheet.
NB
you may use any letter
more than once
A
Chewing gum manufacture
B
Olive oil extraction
C
Fruit crop protection
1
Talc is used to prevent foaming.
Locate
2
Talc is used to prevent stickiness.
Locate
3
Talc is used to boost production.
Locate
4
Talc is used as a filler to provide a base.
Locate
5
Talc is used to prevent sunburn.
Locate
6
Talc is used to help increase the size of the product.
Locate

1 ____ Talc is used to prevent foaming. Locate 2 ____ Talc is used to prevent stickiness. Locate 3 ____ Talc is used to boost production. Locate 4 ____ Talc is used as a filler to provide a base. Locate 5 ____ Talc is used to prevent sunburn. Locate 6 ____ Talc is used to help increase the size of the product. Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cf12f111-9be9-5ce7-adca-49b584c6ccc8', '25d18303-2606-51c9-a850-c8a56823e4f2', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d694f9b1-0dab-5566-a987-76b473c5c3ce', '25d18303-2606-51c9-a850-c8a56823e4f2', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c6ffe4fc-5769-553c-988b-0b60b3bdb51b', '25d18303-2606-51c9-a850-c8a56823e4f2', 3, $md$C$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('6e635993-6cdc-5168-90e4-b1a5da6de4e1', '1ab73cf5-c406-58a2-91de-5fa30568b949', 4, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 4

Questions 1-6
Questions 1-6
Use the information in the passage to match each use of talc power with correct application from
A, B
or
C
.
Write the appropriate letters
A-C
in boxes
1-6
on your answer sheet.
NB
you may use any letter
more than once
A
Chewing gum manufacture
B
Olive oil extraction
C
Fruit crop protection
1
Talc is used to prevent foaming.
Locate
2
Talc is used to prevent stickiness.
Locate
3
Talc is used to boost production.
Locate
4
Talc is used as a filler to provide a base.
Locate
5
Talc is used to prevent sunburn.
Locate
6
Talc is used to help increase the size of the product.
Locate

1 ____ Talc is used to prevent foaming. Locate 2 ____ Talc is used to prevent stickiness. Locate 3 ____ Talc is used to boost production. Locate 4 ____ Talc is used as a filler to provide a base. Locate 5 ____ Talc is used to prevent sunburn. Locate 6 ____ Talc is used to help increase the size of the product. Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fbee8c5a-34b0-5df2-a9e0-f0bff3e44162', '6e635993-6cdc-5168-90e4-b1a5da6de4e1', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('01d882fe-e418-590e-bb4d-d502456a07e2', '6e635993-6cdc-5168-90e4-b1a5da6de4e1', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e34253ae-ffdb-5ad2-9cf5-2b21b9091f01', '6e635993-6cdc-5168-90e4-b1a5da6de4e1', 3, $md$C$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('f95c6ed2-2e21-54f3-bd3c-b5d78d175401', '1ab73cf5-c406-58a2-91de-5fa30568b949', 5, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 5

Questions 1-6
Questions 1-6
Use the information in the passage to match each use of talc power with correct application from
A, B
or
C
.
Write the appropriate letters
A-C
in boxes
1-6
on your answer sheet.
NB
you may use any letter
more than once
A
Chewing gum manufacture
B
Olive oil extraction
C
Fruit crop protection
1
Talc is used to prevent foaming.
Locate
2
Talc is used to prevent stickiness.
Locate
3
Talc is used to boost production.
Locate
4
Talc is used as a filler to provide a base.
Locate
5
Talc is used to prevent sunburn.
Locate
6
Talc is used to help increase the size of the product.
Locate

1 ____ Talc is used to prevent foaming. Locate 2 ____ Talc is used to prevent stickiness. Locate 3 ____ Talc is used to boost production. Locate 4 ____ Talc is used as a filler to provide a base. Locate 5 ____ Talc is used to prevent sunburn. Locate 6 ____ Talc is used to help increase the size of the product. Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cc4af59e-037d-5756-84da-c558511fd6d6', 'f95c6ed2-2e21-54f3-bd3c-b5d78d175401', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('54a86e75-4252-5f1d-825d-bcfcbbbcd531', 'f95c6ed2-2e21-54f3-bd3c-b5d78d175401', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('23ae09c9-d86b-5acb-a212-078b23b95a5c', 'f95c6ed2-2e21-54f3-bd3c-b5d78d175401', 3, $md$C$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('d0d67573-670a-5175-855a-83d2e4bced64', '1ab73cf5-c406-58a2-91de-5fa30568b949', 6, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 6

Questions 1-6
Questions 1-6
Use the information in the passage to match each use of talc power with correct application from
A, B
or
C
.
Write the appropriate letters
A-C
in boxes
1-6
on your answer sheet.
NB
you may use any letter
more than once
A
Chewing gum manufacture
B
Olive oil extraction
C
Fruit crop protection
1
Talc is used to prevent foaming.
Locate
2
Talc is used to prevent stickiness.
Locate
3
Talc is used to boost production.
Locate
4
Talc is used as a filler to provide a base.
Locate
5
Talc is used to prevent sunburn.
Locate
6
Talc is used to help increase the size of the product.
Locate

1 ____ Talc is used to prevent foaming. Locate 2 ____ Talc is used to prevent stickiness. Locate 3 ____ Talc is used to boost production. Locate 4 ____ Talc is used as a filler to provide a base. Locate 5 ____ Talc is used to prevent sunburn. Locate 6 ____ Talc is used to help increase the size of the product. Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b20e1e2b-694d-5e8f-b731-5b4cd808f486', 'd0d67573-670a-5175-855a-83d2e4bced64', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d88872b9-8707-5f16-99ce-e2734c6e80fe', 'd0d67573-670a-5175-855a-83d2e4bced64', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c0d7f732-3d21-54f9-9b1f-59d666632d7b', 'd0d67573-670a-5175-855a-83d2e4bced64', 3, $md$C$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('ebd85613-32bb-56d6-a196-6d3df9e55ee6', '1ab73cf5-c406-58a2-91de-5fa30568b949', 7, 'SUMMARY_COMPLETION', 'READING', 3, $md$### Question 7

Questions 7-12
Questions 7-12
Complete the following summary below using
NO MORE THAN TWO WORDS
from the Reading Passage for each answer.
Write your answers in boxes
7-12
on your answer sheet.
The use of talc powder in the olive oil industry in Spain has been around for
7
Locate
years. It is extremely useful in dealing with “difficult” olives which often produce a lot of
8
Locate
due to the high content of solid matter.
The traditional method of oil extraction used in some smaller plants often produces
9
Locate
, which contains emulsified oil, and if it is directly disposed of, it may be
10
Locate
to the environment, because it can­not
11
Locate
. But adding talc powder can absorb the emulsifier and increase the production, because the size of oil
12
Locate
grows.

The use of talc powder in the olive oil industry in Spain has been around for 7 ____ Locate years. It is extremely useful in dealing with “difficult” olives which often produce a lot of 8 ____ Locate due to the high content of solid matter.$md$, NULL, ARRAY['.*20.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('e5fc4918-562e-597d-8bbf-893bcd280e06', '1ab73cf5-c406-58a2-91de-5fa30568b949', 8, 'SUMMARY_COMPLETION', 'READING', 3, $md$### Question 8

Questions 7-12
Questions 7-12
Complete the following summary below using
NO MORE THAN TWO WORDS
from the Reading Passage for each answer.
Write your answers in boxes
7-12
on your answer sheet.
The use of talc powder in the olive oil industry in Spain has been around for
7
Locate
years. It is extremely useful in dealing with “difficult” olives which often produce a lot of
8
Locate
due to the high content of solid matter.
The traditional method of oil extraction used in some smaller plants often produces
9
Locate
, which contains emulsified oil, and if it is directly disposed of, it may be
10
Locate
to the environment, because it can­not
11
Locate
. But adding talc powder can absorb the emulsifier and increase the production, because the size of oil
12
Locate
grows.

The use of talc powder in the olive oil industry in Spain has been around for 7 ____ Locate years. It is extremely useful in dealing with “difficult” olives which often produce a lot of 8 ____ Locate due to the high content of solid matter.$md$, NULL, ARRAY['.*20.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('48e7807c-1420-517d-a62b-c114420e1138', '1ab73cf5-c406-58a2-91de-5fa30568b949', 9, 'SUMMARY_COMPLETION', 'READING', 3, $md$### Question 9

Questions 7-12
Questions 7-12
Complete the following summary below using
NO MORE THAN TWO WORDS
from the Reading Passage for each answer.
Write your answers in boxes
7-12
on your answer sheet.
The use of talc powder in the olive oil industry in Spain has been around for
7
Locate
years. It is extremely useful in dealing with “difficult” olives which often produce a lot of
8
Locate
due to the high content of solid matter.
The traditional method of oil extraction used in some smaller plants often produces
9
Locate
, which contains emulsified oil, and if it is directly disposed of, it may be
10
Locate
to the environment, because it can­not
11
Locate
. But adding talc powder can absorb the emulsifier and increase the production, because the size of oil
12
Locate
grows.

The traditional method of oil extraction used in some smaller plants often produces 9 ____ Locate , which contains emulsified oil, and if it is directly disposed of, it may be 10 ____ Locate to the environment, because it can­not 11 ____ Locate . But adding talc powder can absorb the emulsifier and increase the production, because the size of oil 12 ____ Locate grows.$md$, NULL, ARRAY['.*waste.*water.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('ad2bb800-98dd-58fe-84fd-40091a068c86', '1ab73cf5-c406-58a2-91de-5fa30568b949', 10, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 10

Questions 7-12
Questions 7-12
Complete the following summary below using
NO MORE THAN TWO WORDS
from the Reading Passage for each answer.
Write your answers in boxes
7-12
on your answer sheet.
The use of talc powder in the olive oil industry in Spain has been around for
7
Locate
years. It is extremely useful in dealing with “difficult” olives which often produce a lot of
8
Locate
due to the high content of solid matter.
The traditional method of oil extraction used in some smaller plants often produces
9
Locate
, which contains emulsified oil, and if it is directly disposed of, it may be
10
Locate
to the environment, because it can­not
11
Locate
. But adding talc powder can absorb the emulsifier and increase the production, because the size of oil
12
Locate
grows.

The traditional method of oil extraction used in some smaller plants often produces 9 ____ Locate , which contains emulsified oil, and if it is directly disposed of, it may be 10 ____ Locate to the environment, because it can­not 11 ____ Locate . But adding talc powder can absorb the emulsifier and increase the production, because the size of oil 12 ____ Locate grows.$md$, NULL, ARRAY['.*waste.*water.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('3f0df79b-411a-5076-b3f4-b06a57920770', '1ab73cf5-c406-58a2-91de-5fa30568b949', 11, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 11

Questions 7-12
Questions 7-12
Complete the following summary below using
NO MORE THAN TWO WORDS
from the Reading Passage for each answer.
Write your answers in boxes
7-12
on your answer sheet.
The use of talc powder in the olive oil industry in Spain has been around for
7
Locate
years. It is extremely useful in dealing with “difficult” olives which often produce a lot of
8
Locate
due to the high content of solid matter.
The traditional method of oil extraction used in some smaller plants often produces
9
Locate
, which contains emulsified oil, and if it is directly disposed of, it may be
10
Locate
to the environment, because it can­not
11
Locate
. But adding talc powder can absorb the emulsifier and increase the production, because the size of oil
12
Locate
grows.

The traditional method of oil extraction used in some smaller plants often produces 9 ____ Locate , which contains emulsified oil, and if it is directly disposed of, it may be 10 ____ Locate to the environment, because it can­not 11 ____ Locate . But adding talc powder can absorb the emulsifier and increase the production, because the size of oil 12 ____ Locate grows.$md$, NULL, ARRAY['.*waste.*water.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('ef85f1d0-2caa-5349-8a9e-03921faa2f96', '1ab73cf5-c406-58a2-91de-5fa30568b949', 12, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 12

Questions 7-12
Questions 7-12
Complete the following summary below using
NO MORE THAN TWO WORDS
from the Reading Passage for each answer.
Write your answers in boxes
7-12
on your answer sheet.
The use of talc powder in the olive oil industry in Spain has been around for
7
Locate
years. It is extremely useful in dealing with “difficult” olives which often produce a lot of
8
Locate
due to the high content of solid matter.
The traditional method of oil extraction used in some smaller plants often produces
9
Locate
, which contains emulsified oil, and if it is directly disposed of, it may be
10
Locate
to the environment, because it can­not
11
Locate
. But adding talc powder can absorb the emulsifier and increase the production, because the size of oil
12
Locate
grows.

The traditional method of oil extraction used in some smaller plants often produces 9 ____ Locate , which contains emulsified oil, and if it is directly disposed of, it may be 10 ____ Locate to the environment, because it can­not 11 ____ Locate . But adding talc powder can absorb the emulsifier and increase the production, because the size of oil 12 ____ Locate grows.$md$, NULL, ARRAY['.*waste.*water.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('672600f0-47c0-5644-b8e0-983008934e3e', '1ab73cf5-c406-58a2-91de-5fa30568b949', 13, 'SHORT_ANSWER', 'READING', 4, $md$### Question 13

Questions 13-14
Questions 13-14
Answer the questions below using
NO MORE THAN THREE WORDS
from the passage for each answer.
Write your answers in boxes
13-14
on your answer sheet.
13
. What are the last two stages of chewing gum manufacturing process?
Locate
14
. Which group of farmers does Invelop intend to target next?
Locate

13 . What are the last two stages of chewing gum manufacturing process? ____ Locate 14 . Which group of farmers does Invelop intend to target next? ____ Locate$md$, NULL, ARRAY['.*lamination.*and.*packing.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('64feb4b5-6753-53cc-83ae-e5a558d60e88', '1ab73cf5-c406-58a2-91de-5fa30568b949', 14, 'SHORT_ANSWER', 'READING', 4, $md$### Question 14

Questions 13-14
Questions 13-14
Answer the questions below using
NO MORE THAN THREE WORDS
from the passage for each answer.
Write your answers in boxes
13-14
on your answer sheet.
13
. What are the last two stages of chewing gum manufacturing process?
Locate
14
. Which group of farmers does Invelop intend to target next?
Locate

13 . What are the last two stages of chewing gum manufacturing process? ____ Locate 14 . Which group of farmers does Invelop intend to target next? ____ Locate$md$, NULL, ARRAY['.*lamination.*and.*packing.*']);

COMMIT;
