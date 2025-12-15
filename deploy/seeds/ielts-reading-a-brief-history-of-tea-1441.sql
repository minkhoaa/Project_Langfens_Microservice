BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-a-brief-history-of-tea-1441'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-a-brief-history-of-tea-1441';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-a-brief-history-of-tea-1441';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-a-brief-history-of-tea-1441';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('edf92cc9-2c3b-5578-93aa-631cb0931f72', 'ielts-reading-a-brief-history-of-tea-1441', $t$A Brief History of Tea$t$, $md$## A Brief History of Tea

Nguồn:
- Test: https://mini-ielts.com/1441/reading/a-brief-history-of-tea
- Solution: https://mini-ielts.com/1441/view-solution/reading/a-brief-history-of-tea$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('d36ccd1b-d9e4-512d-8be6-ca609edfede7', 'edf92cc9-2c3b-5578-93aa-631cb0931f72', 1, $t$Reading — A Brief History of Tea$t$, $md$Read the passage and answer questions **1–13**.

### Passage: A Brief History of Tea

A

The story of tea began in ancient China over 5,000 years ago. According to legend, the Emperor Shen Nung was a skilled ruler, creative scientist and patron of the arts. His far­sighted edicts required, among other things, that all drinking water be boiled as a hygienic precaution. One summer day while visiting a distant region of his realm, he and the court stopped to rest. In accordance with his ruling, the servants began to boil water for the court to drink. Dried leaves from a nearby bush fell into the boiling water, and as the leaves infused the water turned brown. As a scientist, the Emperor was intrigued by the new liquid, drank some, and found it very refreshing. And so, according to legend, tea was created.

B

Tea consumption spread throughout Chinese culture, reaching into every aspect of the society: The first definitive book was written on tea - a book clearly reflecting Zen Buddhist philosophy - 1,200 years ago, The first tea seeds were brought to Japan by a returning Buddhist priest, who had seen the value of tea in enhancing meditation in China. As a result, he is known as the 'Father of Tea' in Japan. Because of this early association, tea in Japan has always been linked with Zen Buddhism. Tea received the Japanese Emperots support almost instantly and spread rapidly from the royal court and monasteries to other sections of society.

B

Tea was elevated to an art form in the Japanese tea ceremony, in which supreme importance is given to making tea in the most perfect, most polite, most graceful, most charming manner possible. Such a purity of expression prompted the creation of a particular form of architecture for tea house: duplicating the simplicity of a forest cottage. The cultural/artistic hostesses of Japan, the geishas, began to specialize in the presentation of the tea ceremony. However, as more and more people became involved in the excitement surrounding tea, the purity of the original concept was lost, and for a period the tea ceremony became corrupted, boisterous and highly embellished. Efforts were then made to return to the earlier simplicity, with the result that, in the 15th and 16th centuries, tea was viewed as the ultimate gift. Even warlords paused for tea before battles.

While tea was at this high level of development in parts of Asia, information concerning the then unknown beverage began to filter back to Europe. Earlier traders had mentioned it, btit were unclear as to whether tea should be eaten or drunk. The first European to personally encounter tea and write about it was Portuguese - Portugal, with her technologically advanced navy, had been successful in gaining the first right of trade with China.

E

Tea finally arrived in Europe in the 16tr’ century, brought to Holland by the country's navy, and becoming very fashionable in the Dutch capital, the Hague. This was due in part to tea being very expensive (over $100 per pound), which immediately made it the domain of the wealthy. Slowly, as the amount of tea imported increased, the price fell, and by 1675 it was available in common food shops throughout Holland.

F

As the consumption of tea increased dramatically in Dutch society, doctors and university authorities in Holland argued as to its benefits or drawbacks. The public largely ignored the scholarly debate and continued to enjoy their new beverage, through the controversy lasted from 1635 to roughly 1657. Throughout this period, France and Holland led Europe in the use of tea.

G

As the craze for all things oriental swept through Europe, tea became part of the way of life. Adding milk to the drink was first mentioned in 1680. Around that time, Dutch inns provided the first restaurant service of tea. Innkeepers would furnish guests with a portable tea set complete with a heating unit. The Dutchman would then prepare tea for himself and his friends outside in the inn garden. Tea remained popular in France for only about fifty years, being replaced by a preference for wine, chocolate, and exotic coffees. Tea was introduced into England in 1660 by King Charles II and his Portuguese queen, who were both confirmed tea drinkers. Tea mania swept across England as it had earlier spread throughout France and Holland. By 1708 tea importation had risen to thirteen times the 1699 level. Tea was drunk by all levels of society.

H

The Russian interest in tea began as early as 1618, when the Chinese embassy in Moscow presented several chests of tea to the Emperor, Czar Alexis. Later in the century, a trade treaty between Russia and China allowed caravans to cross back and forth freely between the two countries. Still, the journey was not easy. The average caravan consisted of 200 to 300 camels, and the 18,000-kilometre trip took over 16 months to complete. Eventually, however, tea became - as it still is - one of the most popular drinks in the country.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('a9667dab-01a2-5b25-a5c6-cb44fd62de84', 'd36ccd1b-d9e4-512d-8be6-ca609edfede7', 1, 'MATCHING_HEADING', 'READING', 2, $md$### Question 1

Question 1- 8
Question 1- 8
Choose the correct heading for each paragraph from the list of headings below.
Write the correct number, i-xi, in boxes 1-8..On your answer sheet.
List of Headings
Not enough tea to meet demand
Religious objections
in - and sometimes out of- fashion
A connection between tea and religion
A luxury item
News of tea reaches another continent
Is tea a good or bad thing?
A chance discovery
Tea-making as a ritual
Difficulties in importing tea
1
Paragraph A
2
Paragraph B
3
Paragraph c
4
Paragraph C
5
Paragraph E
6
Paragraph F
7
Paragraph G
8
Paragraph H

1 ____ Paragraph A$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a20d80c0-bab2-5ad5-bc6c-e53a1a7b78da', 'a9667dab-01a2-5b25-a5c6-cb44fd62de84', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cdeb84e8-31b1-5c09-9d20-6825ada2a491', 'a9667dab-01a2-5b25-a5c6-cb44fd62de84', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b138c40e-ad58-5ec6-831b-5709331b4fd7', 'a9667dab-01a2-5b25-a5c6-cb44fd62de84', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8c01fb45-7b81-5f9e-b7a6-a486c3fdbb0a', 'a9667dab-01a2-5b25-a5c6-cb44fd62de84', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f3ae1373-b415-51aa-bc1c-3bca5ccad2a3', 'a9667dab-01a2-5b25-a5c6-cb44fd62de84', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('75538c58-ebb1-5756-a90a-3b0573fc2c9f', 'a9667dab-01a2-5b25-a5c6-cb44fd62de84', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f33b7020-3338-5392-98cd-394b43086c22', 'a9667dab-01a2-5b25-a5c6-cb44fd62de84', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('20f0ce5a-08a2-56bc-a82a-ffaaea8535a7', 'a9667dab-01a2-5b25-a5c6-cb44fd62de84', 8, $md$viii$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f20b5371-2826-5318-a543-a2ee9af47f80', 'a9667dab-01a2-5b25-a5c6-cb44fd62de84', 9, $md$ix$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('25dfe7c0-4077-539a-ab5b-3c326f8ce70d', 'a9667dab-01a2-5b25-a5c6-cb44fd62de84', 10, $md$x$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('142d3827-db68-5dd4-b674-b8883cd7b685', 'd36ccd1b-d9e4-512d-8be6-ca609edfede7', 2, 'MATCHING_HEADING', 'READING', 2, $md$### Question 2

Question 1- 8
Question 1- 8
Choose the correct heading for each paragraph from the list of headings below.
Write the correct number, i-xi, in boxes 1-8..On your answer sheet.
List of Headings
Not enough tea to meet demand
Religious objections
in - and sometimes out of- fashion
A connection between tea and religion
A luxury item
News of tea reaches another continent
Is tea a good or bad thing?
A chance discovery
Tea-making as a ritual
Difficulties in importing tea
1
Paragraph A
2
Paragraph B
3
Paragraph c
4
Paragraph C
5
Paragraph E
6
Paragraph F
7
Paragraph G
8
Paragraph H

2 ____ Paragraph B$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bb64b2aa-e292-5c51-bfb9-ec826535816f', '142d3827-db68-5dd4-b674-b8883cd7b685', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('90e9632c-7be9-5bb7-a100-c9c7a5a6d38d', '142d3827-db68-5dd4-b674-b8883cd7b685', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('604536a2-efd2-5575-a759-866b54e982c5', '142d3827-db68-5dd4-b674-b8883cd7b685', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b40a1445-6ed0-5044-9a1d-dd7807314092', '142d3827-db68-5dd4-b674-b8883cd7b685', 4, $md$iv$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3e739edd-6212-5c77-b536-a2d28e78d06b', '142d3827-db68-5dd4-b674-b8883cd7b685', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('35d9b046-74b3-58d0-83a0-21ccb9608455', '142d3827-db68-5dd4-b674-b8883cd7b685', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e54afece-6ebd-531d-a7d6-98b8fc6ab141', '142d3827-db68-5dd4-b674-b8883cd7b685', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6d4e8dce-c368-51ba-ac8a-4bd3b2424fc8', '142d3827-db68-5dd4-b674-b8883cd7b685', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2ab0bdcb-b2b5-50ef-b400-9f559c650907', '142d3827-db68-5dd4-b674-b8883cd7b685', 9, $md$ix$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('dab4f338-686c-5f87-b920-86b785072635', '142d3827-db68-5dd4-b674-b8883cd7b685', 10, $md$x$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('3e66a18e-fdef-5774-ab98-eb59a903fc2a', 'd36ccd1b-d9e4-512d-8be6-ca609edfede7', 3, 'MATCHING_HEADING', 'READING', 2, $md$### Question 3

Question 1- 8
Question 1- 8
Choose the correct heading for each paragraph from the list of headings below.
Write the correct number, i-xi, in boxes 1-8..On your answer sheet.
List of Headings
Not enough tea to meet demand
Religious objections
in - and sometimes out of- fashion
A connection between tea and religion
A luxury item
News of tea reaches another continent
Is tea a good or bad thing?
A chance discovery
Tea-making as a ritual
Difficulties in importing tea
1
Paragraph A
2
Paragraph B
3
Paragraph c
4
Paragraph C
5
Paragraph E
6
Paragraph F
7
Paragraph G
8
Paragraph H

3 ____ Paragraph c$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8fc12974-5231-5ce3-8be1-e251e07cdca3', '3e66a18e-fdef-5774-ab98-eb59a903fc2a', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('840d000c-b9cc-57a6-a8fa-b2c908415ac6', '3e66a18e-fdef-5774-ab98-eb59a903fc2a', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('977f31f6-550c-5f53-aa38-aef2579a7e5e', '3e66a18e-fdef-5774-ab98-eb59a903fc2a', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7bdebe5d-077b-5d2d-8210-2fe7494e6e17', '3e66a18e-fdef-5774-ab98-eb59a903fc2a', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5877c681-f4e9-5dce-aaf2-95871d8dd7d7', '3e66a18e-fdef-5774-ab98-eb59a903fc2a', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ad6793a9-6f1a-5234-87d5-1cc15112a8c0', '3e66a18e-fdef-5774-ab98-eb59a903fc2a', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4678f314-704d-5722-a5a6-af4580947ce4', '3e66a18e-fdef-5774-ab98-eb59a903fc2a', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('32e146a2-d398-5997-9f21-5792b372df04', '3e66a18e-fdef-5774-ab98-eb59a903fc2a', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cd4b08bd-5d1c-5192-944d-e93c9c51272c', '3e66a18e-fdef-5774-ab98-eb59a903fc2a', 9, $md$ix$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f63947ae-1f23-5d64-8592-7eb00ab98e3c', '3e66a18e-fdef-5774-ab98-eb59a903fc2a', 10, $md$x$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('f884790a-f88d-503f-ba1d-457480248ec8', 'd36ccd1b-d9e4-512d-8be6-ca609edfede7', 4, 'MATCHING_HEADING', 'READING', 2, $md$### Question 4

Question 1- 8
Question 1- 8
Choose the correct heading for each paragraph from the list of headings below.
Write the correct number, i-xi, in boxes 1-8..On your answer sheet.
List of Headings
Not enough tea to meet demand
Religious objections
in - and sometimes out of- fashion
A connection between tea and religion
A luxury item
News of tea reaches another continent
Is tea a good or bad thing?
A chance discovery
Tea-making as a ritual
Difficulties in importing tea
1
Paragraph A
2
Paragraph B
3
Paragraph c
4
Paragraph C
5
Paragraph E
6
Paragraph F
7
Paragraph G
8
Paragraph H

4 ____ Paragraph C$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8557f30d-f57f-5845-8e67-2f5da09996f0', 'f884790a-f88d-503f-ba1d-457480248ec8', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('54aa7f79-13d9-5428-b26a-7bb603d4f5a1', 'f884790a-f88d-503f-ba1d-457480248ec8', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7ab707c7-3a71-5960-ae63-c98f90d7fb4f', 'f884790a-f88d-503f-ba1d-457480248ec8', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0d529819-666f-5b95-a706-fb7d91a52d31', 'f884790a-f88d-503f-ba1d-457480248ec8', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9ae82bc5-5308-5bb3-88d1-638c0856a227', 'f884790a-f88d-503f-ba1d-457480248ec8', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c5ac31b2-244a-5769-807a-ee65ea909320', 'f884790a-f88d-503f-ba1d-457480248ec8', 6, $md$vi$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4d580810-4015-57e5-bf29-ff34a0e22a27', 'f884790a-f88d-503f-ba1d-457480248ec8', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('550c8c9a-7f16-53c7-8823-51294b83dec3', 'f884790a-f88d-503f-ba1d-457480248ec8', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cc773c1c-23e6-593c-af69-9c5a750e416a', 'f884790a-f88d-503f-ba1d-457480248ec8', 9, $md$ix$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1dee313c-cc3c-50d9-b980-aca882421455', 'f884790a-f88d-503f-ba1d-457480248ec8', 10, $md$x$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('5988ec48-1169-53e9-ae61-b671850bfe78', 'd36ccd1b-d9e4-512d-8be6-ca609edfede7', 5, 'MATCHING_HEADING', 'READING', 3, $md$### Question 5

Question 1- 8
Question 1- 8
Choose the correct heading for each paragraph from the list of headings below.
Write the correct number, i-xi, in boxes 1-8..On your answer sheet.
List of Headings
Not enough tea to meet demand
Religious objections
in - and sometimes out of- fashion
A connection between tea and religion
A luxury item
News of tea reaches another continent
Is tea a good or bad thing?
A chance discovery
Tea-making as a ritual
Difficulties in importing tea
1
Paragraph A
2
Paragraph B
3
Paragraph c
4
Paragraph C
5
Paragraph E
6
Paragraph F
7
Paragraph G
8
Paragraph H

5 ____ Paragraph E$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('74b583c1-88ac-578a-9548-7b32d2a14eae', '5988ec48-1169-53e9-ae61-b671850bfe78', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('703b29b4-8b4b-5f70-aeaf-747f81421ccb', '5988ec48-1169-53e9-ae61-b671850bfe78', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('637a00de-db1d-5925-a293-296f86895ded', '5988ec48-1169-53e9-ae61-b671850bfe78', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d8a367a2-bcfb-570d-998f-2fa4017eb568', '5988ec48-1169-53e9-ae61-b671850bfe78', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('198862d6-c04a-52ea-b330-b00655667035', '5988ec48-1169-53e9-ae61-b671850bfe78', 5, $md$v$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('50f26c72-2a83-50ea-adf7-f47a6bc3e7bc', '5988ec48-1169-53e9-ae61-b671850bfe78', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c40bb921-5967-5b87-a5c1-b317ed77335d', '5988ec48-1169-53e9-ae61-b671850bfe78', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5ae946b1-79cc-5221-a105-e2acd8730512', '5988ec48-1169-53e9-ae61-b671850bfe78', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ccfcd260-4fd2-5d7e-b930-731b1e580d2f', '5988ec48-1169-53e9-ae61-b671850bfe78', 9, $md$ix$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1460c5ad-35a5-5efc-99f3-028236b409db', '5988ec48-1169-53e9-ae61-b671850bfe78', 10, $md$x$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('eaaa6f5d-a8f5-5a8f-b515-965de4eae613', 'd36ccd1b-d9e4-512d-8be6-ca609edfede7', 6, 'MATCHING_HEADING', 'READING', 3, $md$### Question 6

Question 1- 8
Question 1- 8
Choose the correct heading for each paragraph from the list of headings below.
Write the correct number, i-xi, in boxes 1-8..On your answer sheet.
List of Headings
Not enough tea to meet demand
Religious objections
in - and sometimes out of- fashion
A connection between tea and religion
A luxury item
News of tea reaches another continent
Is tea a good or bad thing?
A chance discovery
Tea-making as a ritual
Difficulties in importing tea
1
Paragraph A
2
Paragraph B
3
Paragraph c
4
Paragraph C
5
Paragraph E
6
Paragraph F
7
Paragraph G
8
Paragraph H

6 ____ Paragraph F$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b81a0208-c695-5beb-8d89-6ef3900bb88c', 'eaaa6f5d-a8f5-5a8f-b515-965de4eae613', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3581d261-34bd-55aa-859c-2fcf60fb7c23', 'eaaa6f5d-a8f5-5a8f-b515-965de4eae613', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('40268632-53af-510b-a09b-f599d3093fd5', 'eaaa6f5d-a8f5-5a8f-b515-965de4eae613', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('859c9b1f-0b46-58b4-a852-429cf18b3591', 'eaaa6f5d-a8f5-5a8f-b515-965de4eae613', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5ff9e1f7-e9d3-56ca-b797-6679ba093773', 'eaaa6f5d-a8f5-5a8f-b515-965de4eae613', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d2fae552-80a8-5efd-b0fe-795b00f54e63', 'eaaa6f5d-a8f5-5a8f-b515-965de4eae613', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ae819d02-779f-5bec-8cf2-f79acd4c5ab1', 'eaaa6f5d-a8f5-5a8f-b515-965de4eae613', 7, $md$vii$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('be832101-e6f5-54cf-80bc-6fc901716615', 'eaaa6f5d-a8f5-5a8f-b515-965de4eae613', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('758897c8-15db-5d0b-8ad2-a8fc138b2b23', 'eaaa6f5d-a8f5-5a8f-b515-965de4eae613', 9, $md$ix$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b70ce47c-4801-5a24-baf4-6c2266121d96', 'eaaa6f5d-a8f5-5a8f-b515-965de4eae613', 10, $md$x$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('a1312b72-3580-57c5-87f1-c5ca8da05c4c', 'd36ccd1b-d9e4-512d-8be6-ca609edfede7', 7, 'MATCHING_HEADING', 'READING', 3, $md$### Question 7

Question 1- 8
Question 1- 8
Choose the correct heading for each paragraph from the list of headings below.
Write the correct number, i-xi, in boxes 1-8..On your answer sheet.
List of Headings
Not enough tea to meet demand
Religious objections
in - and sometimes out of- fashion
A connection between tea and religion
A luxury item
News of tea reaches another continent
Is tea a good or bad thing?
A chance discovery
Tea-making as a ritual
Difficulties in importing tea
1
Paragraph A
2
Paragraph B
3
Paragraph c
4
Paragraph C
5
Paragraph E
6
Paragraph F
7
Paragraph G
8
Paragraph H

7 ____ Paragraph G$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('04cabc4a-bec5-550c-ae18-b280f0677964', 'a1312b72-3580-57c5-87f1-c5ca8da05c4c', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('76457049-f3ac-5415-b993-ee30610e4935', 'a1312b72-3580-57c5-87f1-c5ca8da05c4c', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2fa4a74f-2186-5b8a-9b20-ed998a8897a7', 'a1312b72-3580-57c5-87f1-c5ca8da05c4c', 3, $md$iii$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2f203e09-590f-5e2a-99cc-34dc8a5b4602', 'a1312b72-3580-57c5-87f1-c5ca8da05c4c', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3983e1a5-ec10-5e48-8c52-cbb99023d50c', 'a1312b72-3580-57c5-87f1-c5ca8da05c4c', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f158261e-96e1-5219-8dd7-fec927c80b0d', 'a1312b72-3580-57c5-87f1-c5ca8da05c4c', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7074b7a4-07f4-5cfb-9397-bbfa94f7dd41', 'a1312b72-3580-57c5-87f1-c5ca8da05c4c', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7050a132-4602-5211-9418-9ffba7ef2ecb', 'a1312b72-3580-57c5-87f1-c5ca8da05c4c', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('07f5978b-7833-55eb-aa26-1fcf503d04e7', 'a1312b72-3580-57c5-87f1-c5ca8da05c4c', 9, $md$ix$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a0083658-432c-5e6d-bbd0-a8cd8cbab697', 'a1312b72-3580-57c5-87f1-c5ca8da05c4c', 10, $md$x$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('3c908baf-2e52-5db6-bb1f-0de7ca0a5110', 'd36ccd1b-d9e4-512d-8be6-ca609edfede7', 8, 'MATCHING_HEADING', 'READING', 3, $md$### Question 8

Question 1- 8
Question 1- 8
Choose the correct heading for each paragraph from the list of headings below.
Write the correct number, i-xi, in boxes 1-8..On your answer sheet.
List of Headings
Not enough tea to meet demand
Religious objections
in - and sometimes out of- fashion
A connection between tea and religion
A luxury item
News of tea reaches another continent
Is tea a good or bad thing?
A chance discovery
Tea-making as a ritual
Difficulties in importing tea
1
Paragraph A
2
Paragraph B
3
Paragraph c
4
Paragraph C
5
Paragraph E
6
Paragraph F
7
Paragraph G
8
Paragraph H

8 ____ Paragraph H$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d9ff9ba8-0d98-510a-b0dd-73ac2de1cc88', '3c908baf-2e52-5db6-bb1f-0de7ca0a5110', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5779775b-21b3-5b11-a12e-15b0c794b1ed', '3c908baf-2e52-5db6-bb1f-0de7ca0a5110', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b7fc20eb-d08b-5bcc-b3f8-121c557b2a4b', '3c908baf-2e52-5db6-bb1f-0de7ca0a5110', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0c238da5-5ea0-5e00-8014-fe99aecaecc3', '3c908baf-2e52-5db6-bb1f-0de7ca0a5110', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f23e63bd-dc99-5985-b57e-47979a7834eb', '3c908baf-2e52-5db6-bb1f-0de7ca0a5110', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6e9b0041-45d7-53bc-a6e2-99e2855f1c62', '3c908baf-2e52-5db6-bb1f-0de7ca0a5110', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7e06fa37-6451-5b29-a7d0-e2425a3ab8b9', '3c908baf-2e52-5db6-bb1f-0de7ca0a5110', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('87b24857-8756-5c04-b018-002b671d555e', '3c908baf-2e52-5db6-bb1f-0de7ca0a5110', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f44b018f-b2e3-5cf5-ad85-7a83d8594b19', '3c908baf-2e52-5db6-bb1f-0de7ca0a5110', 9, $md$ix$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8116c196-c9b1-5056-aa5c-21ce894e0085', '3c908baf-2e52-5db6-bb1f-0de7ca0a5110', 10, $md$x$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('5fe6116b-d409-542e-99ee-9704e0b7db1e', 'd36ccd1b-d9e4-512d-8be6-ca609edfede7', 9, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 9

Question 9-13
Question 9-13
Look at the following statements (Question 9-13) and the list ofcountries below.
Match each statement with the correct country, A-G.
Write the correct letter, A-G, in boxes 9-13 On your answer sheet.
List of Countries
A China
B Japan
c Portugal
D Holland
E France
F England
G Russia
9
Claims that tea might be harmful failed to affect it popularity.
10
Tea lost favour to other drinks.
11
Special buildings were constructed in which to drink tea.
12
Animals were involved in importing tea.
13
A ruler's specialist knowledge led to an interest in tea.

9 ____ Claims that tea might be harmful failed to affect it popularity.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f2e2903d-a531-5bee-b9f8-ba8c6df39a40', '5fe6116b-d409-542e-99ee-9704e0b7db1e', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f8d159f2-36e6-5256-aa59-0c2b892af502', '5fe6116b-d409-542e-99ee-9704e0b7db1e', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ae17bca8-6143-5853-acf2-57636342c52f', '5fe6116b-d409-542e-99ee-9704e0b7db1e', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ac6e1716-7e13-5ed5-8e06-7a3b6c7da426', '5fe6116b-d409-542e-99ee-9704e0b7db1e', 4, $md$D$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b563b194-9e8c-5c15-ae18-316162ac1355', '5fe6116b-d409-542e-99ee-9704e0b7db1e', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c7a5c679-fa6f-5018-9580-9b83380da013', '5fe6116b-d409-542e-99ee-9704e0b7db1e', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('864871a3-b8da-5be3-8b2b-0f2703428170', '5fe6116b-d409-542e-99ee-9704e0b7db1e', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('b600ed29-cd5e-5a77-837e-1785893061d0', 'd36ccd1b-d9e4-512d-8be6-ca609edfede7', 10, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 10

Question 9-13
Question 9-13
Look at the following statements (Question 9-13) and the list ofcountries below.
Match each statement with the correct country, A-G.
Write the correct letter, A-G, in boxes 9-13 On your answer sheet.
List of Countries
A China
B Japan
c Portugal
D Holland
E France
F England
G Russia
9
Claims that tea might be harmful failed to affect it popularity.
10
Tea lost favour to other drinks.
11
Special buildings were constructed in which to drink tea.
12
Animals were involved in importing tea.
13
A ruler's specialist knowledge led to an interest in tea.

10 ____ Tea lost favour to other drinks.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e55e1373-731f-562e-a73b-6cc49c17a0f1', 'b600ed29-cd5e-5a77-837e-1785893061d0', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('429dc4cd-97b3-5df3-9664-df9369d74903', 'b600ed29-cd5e-5a77-837e-1785893061d0', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b4409b22-d796-50db-9318-65f7ceb6ff08', 'b600ed29-cd5e-5a77-837e-1785893061d0', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ff0b640c-e18c-572c-b959-4815d050e242', 'b600ed29-cd5e-5a77-837e-1785893061d0', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c8728b0e-c6bb-5705-84b9-eab174aaccb2', 'b600ed29-cd5e-5a77-837e-1785893061d0', 5, $md$E$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('62042adb-af47-50e5-acad-d712e7d2742d', 'b600ed29-cd5e-5a77-837e-1785893061d0', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('08bc1128-3132-5f2c-9f9b-902feca66e84', 'b600ed29-cd5e-5a77-837e-1785893061d0', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('49515342-a896-5f8a-be64-1f20ab69fee5', 'd36ccd1b-d9e4-512d-8be6-ca609edfede7', 11, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 11

Question 9-13
Question 9-13
Look at the following statements (Question 9-13) and the list ofcountries below.
Match each statement with the correct country, A-G.
Write the correct letter, A-G, in boxes 9-13 On your answer sheet.
List of Countries
A China
B Japan
c Portugal
D Holland
E France
F England
G Russia
9
Claims that tea might be harmful failed to affect it popularity.
10
Tea lost favour to other drinks.
11
Special buildings were constructed in which to drink tea.
12
Animals were involved in importing tea.
13
A ruler's specialist knowledge led to an interest in tea.

11 ____ Special buildings were constructed in which to drink tea.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6e2ebc4f-5fbb-51b3-8415-e92c341ce7f5', '49515342-a896-5f8a-be64-1f20ab69fee5', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bbe063c8-4913-547f-91b4-c3e3222945c1', '49515342-a896-5f8a-be64-1f20ab69fee5', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('45ca1331-9416-5cee-8020-63a57a5ca23c', '49515342-a896-5f8a-be64-1f20ab69fee5', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('946fd8ba-831b-5eb6-bb90-f4651114ade8', '49515342-a896-5f8a-be64-1f20ab69fee5', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('481767c9-5e2b-5f65-90f2-bc4597ef0ad4', '49515342-a896-5f8a-be64-1f20ab69fee5', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('24b2edb2-3c63-52a4-9403-056ae66038cd', '49515342-a896-5f8a-be64-1f20ab69fee5', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8fdc6653-a464-5135-8064-4190ccb0ad75', '49515342-a896-5f8a-be64-1f20ab69fee5', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('604bbd21-5345-522e-a98c-a6cf68a5861d', 'd36ccd1b-d9e4-512d-8be6-ca609edfede7', 12, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 12

Question 9-13
Question 9-13
Look at the following statements (Question 9-13) and the list ofcountries below.
Match each statement with the correct country, A-G.
Write the correct letter, A-G, in boxes 9-13 On your answer sheet.
List of Countries
A China
B Japan
c Portugal
D Holland
E France
F England
G Russia
9
Claims that tea might be harmful failed to affect it popularity.
10
Tea lost favour to other drinks.
11
Special buildings were constructed in which to drink tea.
12
Animals were involved in importing tea.
13
A ruler's specialist knowledge led to an interest in tea.

12 ____ Animals were involved in importing tea.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a2df0faa-c3a7-5f09-bff9-73c327dedbaf', '604bbd21-5345-522e-a98c-a6cf68a5861d', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8c916aa0-75fb-5be9-86e7-9bffd4726617', '604bbd21-5345-522e-a98c-a6cf68a5861d', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('df7c7270-8ffa-5ce6-80c6-9730a3a22e82', '604bbd21-5345-522e-a98c-a6cf68a5861d', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('92ce32f9-c605-5bd8-8cd7-6b8a748e7c2b', '604bbd21-5345-522e-a98c-a6cf68a5861d', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('060d3dda-b1f6-55d6-952b-cd9b99f28186', '604bbd21-5345-522e-a98c-a6cf68a5861d', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('94114a8b-8e3b-55c1-ab4f-cc336797e863', '604bbd21-5345-522e-a98c-a6cf68a5861d', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('be8189e5-b3a8-55a5-a187-e2d3c8dd944f', '604bbd21-5345-522e-a98c-a6cf68a5861d', 7, $md$G$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('b9b775ae-544e-5ebb-be72-1806006e8568', 'd36ccd1b-d9e4-512d-8be6-ca609edfede7', 13, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 13

Question 9-13
Question 9-13
Look at the following statements (Question 9-13) and the list ofcountries below.
Match each statement with the correct country, A-G.
Write the correct letter, A-G, in boxes 9-13 On your answer sheet.
List of Countries
A China
B Japan
c Portugal
D Holland
E France
F England
G Russia
9
Claims that tea might be harmful failed to affect it popularity.
10
Tea lost favour to other drinks.
11
Special buildings were constructed in which to drink tea.
12
Animals were involved in importing tea.
13
A ruler's specialist knowledge led to an interest in tea.

13 ____ A ruler's specialist knowledge led to an interest in tea.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('accf8c65-e13b-59a7-9459-5d073b15bf52', 'b9b775ae-544e-5ebb-be72-1806006e8568', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d88fdc91-b7cb-5df9-924b-b50342a5c22c', 'b9b775ae-544e-5ebb-be72-1806006e8568', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a4721c72-71e4-557b-93cd-eb97ad9ca199', 'b9b775ae-544e-5ebb-be72-1806006e8568', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ca7c27d9-1d1b-5bc3-9936-f44f1ef20a8a', 'b9b775ae-544e-5ebb-be72-1806006e8568', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1c23dbe6-a6eb-5e5a-ac84-86d1042afde3', 'b9b775ae-544e-5ebb-be72-1806006e8568', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bb364eb4-f5f2-5d9b-941b-dddc74b74504', 'b9b775ae-544e-5ebb-be72-1806006e8568', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e85a8109-f757-56c0-aeee-203bd73b0f5e', 'b9b775ae-544e-5ebb-be72-1806006e8568', 7, $md$G$md$, false);

COMMIT;
