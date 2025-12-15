BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-the-development-of-the-silk-industry-1431'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-the-development-of-the-silk-industry-1431';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-the-development-of-the-silk-industry-1431';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-the-development-of-the-silk-industry-1431';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('76c8fd9e-4f2c-53b7-ac71-f7a9749212d4', 'ielts-reading-the-development-of-the-silk-industry-1431', $t$The development of the silk industry$t$, $md$## The development of the silk industry

Nguồn:
- Test: https://mini-ielts.com/1431/reading/the-development-of-the-silk-industry
- Solution: https://mini-ielts.com/1431/view-solution/reading/the-development-of-the-silk-industry$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('550834af-0785-5a5d-9187-d9c0bae500ba', '76c8fd9e-4f2c-53b7-ac71-f7a9749212d4', 1, $t$Reading — The development of the silk industry$t$, $md$Read the passage and answer questions **1–13**.

### Passage: The development of the silk industry

Silk, a natural fibre produced by a particular worm called a silkworm, has been used in clothing for many centuries.

When silk was first discovered in China over 4,500 years ago, it was reserved exclusively for the use of the emperor, his close relations and the very highest of his dignitaries. Within the palace, the emperor is believed to have worn a robe of white silk; outside, he, his principal wife, and the heir to the throne wore yellow, the colour of the earth.

Gradually silk came into more general use, and the various classes of Chinese society began wearing tunics of silk. As well as being used for clothing and decoration, silk was quite quickly put to industrial use, and rapidly became one of the principal elements of the Chinese economy. It was used in the production of musical instruments, as string for fishing, and even as the world’s first luxury paper. Eventually even the common people were able to wear garments of silk.

During the Han dynasty (206 BC-220 AD), silk ceased to be a mere fabric and became a form of currency. Farmers paid their taxes in grain and silk, and silk was used to pay civil servants and to reward subjects for outstanding services. Values were calculated in lengths of silk as they had previously been calculated in weight of gold. Before long, silk became a currency used in trade with foreign countries, which continued into the Tang dynasty (616-907 AD). It is possible that this added importance was the result of a major increase in production. Silk also found its way so thoroughly into the Chinese language that 230 of the 5,000 most common characters of Mandarin* have 'silk' as their key component. Silk became a precious commodity, highly sought after by other countries from an early date, and it is believed that the silk trade.

actually existed before the Silk Road 1 " was officially opened in the second century BC. An Egyptian mummy with a silk thread in her hair, dating from 1070 BC, has been discovered in the village of Deir el Medina near the Valley of the Kings, and is probably the earliest evidence of the silk trade. During the second century BC, the Chinese emperor Han Wu Di’s ambassadors travelled as far west as Persia and Mesopotamis, bearing gifts including silks. A range of important finds of Chinese silks have also been made along the Silk Road. One of the most dramatic of these finds was some Tang silk discovered in 1900. It is believed that around 1015 AD Buddhist monks, possibly alarmed by the threat of invasion by Tibetan people, had sealed more than ten thousand manuscripts and silk paintings, silk banners and textiles in caves near Dunhuang, a trading station on the Silk Road in north-west China.

Some historians believe the first Europeans to set eyes upon the fabulous fabric were the Roman legions of Marcus Licinius Crassus, Governor of Syria. According to certain accounts of the period, at an important battle near the Euphrates River in 53 BC, the Roman soldiers were so startled by the bright silken banners of the enemy that they fled in panic. Yet, within decades Chinese silks were widely worn by the rich and noble families of Rome. The Roman Emperor Heliogabalus (218-222 AD) wore nothing but silk. By 380 AD, the Roman historian Marcellinnus Ammianus reported that. The use of silk, which was one confined to the nobility, has now spread to all classes without distinction - even to the lowest. The desire for silk continued to increase over the centuries. Despite this demand, the price of silk remained very high.

In spite of their secrecy about production methods, the Chinese eventually lost their monopoly on silk production. Knowledge of silk production methods reached Korea around 200 BC, when waves of Chinese immigrants arrived there. Shortly after 300 AD, it travelled westward, and the cultivation of the silkworm was established in India.

Around 550 AD silk production reached the Middle East. Records indicate that two monks from Constantinople (modern-day Istanbul), capital of the Byzantine Empire, appeared at their emperor’s court with silkworm eggs which they had obtained secretly, and hidden in their hollow bamboo walking sticks. Under their supervision the eggs hatched into worms, and the worms spun silk threads. Byzantium was in the silk business at last. The Byzantine church and state created imperial workshops, monopolising production and keeping the secret to themselves. This allowed a silk industry to be established, undercutting the market for ordinary-grade Chinese silk. However, high quality silk textiles, woven in China especially for the Middle Eastern market, continued to achieve high prices in the West, and trade along the Silk Road continued as before. By the sixth century the Persians, too, had mastered the art of silk weaving, developing their own rich patterns and techniques. But it wasn’t until the 13th century that Italy began silk production, with the introduction of 2,000 skilled silk weavers from Constantinople. Eventually, silk production became widespread throughout Europe.

World silk production has approximately doubled during the last 30 years in spite of man­made fibres replacing certain uses of silk. Before this period, China and Japan were the two main producers, together manufacturing more than 50 per cent of world production each year. After the late 1970s, however, China dramatically increased its silk production, and once again became the world’s leading producer.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('63a59416-539a-51a2-bc76-77079f1e3e78', '550834af-0785-5a5d-9187-d9c0bae500ba', 1, 'NOTE_COMPLETION', 'READING', 2, $md$### Question 1

Questions 1-7
Questions 1-7
Complete the notes below.
Choose
ONE WORD ONLY
from the passage for each answer.
Write your answers in boxes 1-7 on your answer sheet.
Chinese silk
Early Uses
Clothing
at first, silk only available to Chinese of high rank
emperor wore
1
silk indoors
In industry
silk items included parts of musical instruments, fishing strings and
2
Currency
silk was used as payment of
3
as well as for wages and rewards
silk replaced
4
as a unit of value
silk soon used as payment in
5
trade
Evidence of silk trade
1070 BC, Egypt:
hair of a
6
contained silk
2nd century BC, Persia and Mesopotamia:
gifts of silk were presented by Chinese ambassadors
1015 AD, north-west China:
silk objects were hidden inside
7

emperor wore 1 ____ silk indoors$md$, NULL, ARRAY['.*white.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('f7f7a853-f8cf-5ea8-88dc-aa89074fe86f', '550834af-0785-5a5d-9187-d9c0bae500ba', 2, 'NOTE_COMPLETION', 'READING', 2, $md$### Question 2

Questions 1-7
Questions 1-7
Complete the notes below.
Choose
ONE WORD ONLY
from the passage for each answer.
Write your answers in boxes 1-7 on your answer sheet.
Chinese silk
Early Uses
Clothing
at first, silk only available to Chinese of high rank
emperor wore
1
silk indoors
In industry
silk items included parts of musical instruments, fishing strings and
2
Currency
silk was used as payment of
3
as well as for wages and rewards
silk replaced
4
as a unit of value
silk soon used as payment in
5
trade
Evidence of silk trade
1070 BC, Egypt:
hair of a
6
contained silk
2nd century BC, Persia and Mesopotamia:
gifts of silk were presented by Chinese ambassadors
1015 AD, north-west China:
silk objects were hidden inside
7

silk items included parts of musical instruments, fishing strings and 2 ____$md$, NULL, ARRAY['.*paper.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('4100162c-e1b5-597f-9258-aefe3588bf17', '550834af-0785-5a5d-9187-d9c0bae500ba', 3, 'NOTE_COMPLETION', 'READING', 2, $md$### Question 3

Questions 1-7
Questions 1-7
Complete the notes below.
Choose
ONE WORD ONLY
from the passage for each answer.
Write your answers in boxes 1-7 on your answer sheet.
Chinese silk
Early Uses
Clothing
at first, silk only available to Chinese of high rank
emperor wore
1
silk indoors
In industry
silk items included parts of musical instruments, fishing strings and
2
Currency
silk was used as payment of
3
as well as for wages and rewards
silk replaced
4
as a unit of value
silk soon used as payment in
5
trade
Evidence of silk trade
1070 BC, Egypt:
hair of a
6
contained silk
2nd century BC, Persia and Mesopotamia:
gifts of silk were presented by Chinese ambassadors
1015 AD, north-west China:
silk objects were hidden inside
7

silk was used as payment of 3 ____ as well as for wages and rewards$md$, NULL, ARRAY['.*taxes.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('6558e1c8-c9a5-5f02-b96e-ee0ec673bca2', '550834af-0785-5a5d-9187-d9c0bae500ba', 4, 'NOTE_COMPLETION', 'READING', 2, $md$### Question 4

Questions 1-7
Questions 1-7
Complete the notes below.
Choose
ONE WORD ONLY
from the passage for each answer.
Write your answers in boxes 1-7 on your answer sheet.
Chinese silk
Early Uses
Clothing
at first, silk only available to Chinese of high rank
emperor wore
1
silk indoors
In industry
silk items included parts of musical instruments, fishing strings and
2
Currency
silk was used as payment of
3
as well as for wages and rewards
silk replaced
4
as a unit of value
silk soon used as payment in
5
trade
Evidence of silk trade
1070 BC, Egypt:
hair of a
6
contained silk
2nd century BC, Persia and Mesopotamia:
gifts of silk were presented by Chinese ambassadors
1015 AD, north-west China:
silk objects were hidden inside
7

silk replaced 4 ____ as a unit of value$md$, NULL, ARRAY['.*gold.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('db5f371f-5513-543b-bd35-6d1a7ba89958', '550834af-0785-5a5d-9187-d9c0bae500ba', 5, 'NOTE_COMPLETION', 'READING', 3, $md$### Question 5

Questions 1-7
Questions 1-7
Complete the notes below.
Choose
ONE WORD ONLY
from the passage for each answer.
Write your answers in boxes 1-7 on your answer sheet.
Chinese silk
Early Uses
Clothing
at first, silk only available to Chinese of high rank
emperor wore
1
silk indoors
In industry
silk items included parts of musical instruments, fishing strings and
2
Currency
silk was used as payment of
3
as well as for wages and rewards
silk replaced
4
as a unit of value
silk soon used as payment in
5
trade
Evidence of silk trade
1070 BC, Egypt:
hair of a
6
contained silk
2nd century BC, Persia and Mesopotamia:
gifts of silk were presented by Chinese ambassadors
1015 AD, north-west China:
silk objects were hidden inside
7

silk soon used as payment in 5 ____ trade$md$, NULL, ARRAY['.*foreign.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('44689e74-5add-57a9-96b5-671f957d2c1a', '550834af-0785-5a5d-9187-d9c0bae500ba', 6, 'NOTE_COMPLETION', 'READING', 3, $md$### Question 6

Questions 1-7
Questions 1-7
Complete the notes below.
Choose
ONE WORD ONLY
from the passage for each answer.
Write your answers in boxes 1-7 on your answer sheet.
Chinese silk
Early Uses
Clothing
at first, silk only available to Chinese of high rank
emperor wore
1
silk indoors
In industry
silk items included parts of musical instruments, fishing strings and
2
Currency
silk was used as payment of
3
as well as for wages and rewards
silk replaced
4
as a unit of value
silk soon used as payment in
5
trade
Evidence of silk trade
1070 BC, Egypt:
hair of a
6
contained silk
2nd century BC, Persia and Mesopotamia:
gifts of silk were presented by Chinese ambassadors
1015 AD, north-west China:
silk objects were hidden inside
7

hair of a 6 ____ contained silk 2nd century BC, Persia and Mesopotamia: gifts of silk were presented by Chinese ambassadors 1015 AD, north-west China: silk objects were hidden inside 7 ____$md$, NULL, ARRAY['.*mummy.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('072709ca-64ab-5b21-b1a0-17f56600cebb', '550834af-0785-5a5d-9187-d9c0bae500ba', 7, 'NOTE_COMPLETION', 'READING', 3, $md$### Question 7

Questions 1-7
Questions 1-7
Complete the notes below.
Choose
ONE WORD ONLY
from the passage for each answer.
Write your answers in boxes 1-7 on your answer sheet.
Chinese silk
Early Uses
Clothing
at first, silk only available to Chinese of high rank
emperor wore
1
silk indoors
In industry
silk items included parts of musical instruments, fishing strings and
2
Currency
silk was used as payment of
3
as well as for wages and rewards
silk replaced
4
as a unit of value
silk soon used as payment in
5
trade
Evidence of silk trade
1070 BC, Egypt:
hair of a
6
contained silk
2nd century BC, Persia and Mesopotamia:
gifts of silk were presented by Chinese ambassadors
1015 AD, north-west China:
silk objects were hidden inside
7

silk objects were hidden inside 7 ____$md$, NULL, ARRAY['.*caves.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('189c8913-9af0-542d-9bca-6bc70b022d73', '550834af-0785-5a5d-9187-d9c0bae500ba', 8, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 8

Questions 8-13
Questions 8-13
Do the following statements agree with the information given in Reading Passage 1 ?
In boxes 8-13 on your answer sheet, write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
8
Their first sight of silk created fear among Roman soldiers.
9
The quality of Chinese silk imported by the early Romans varied widely.
10
The Byzantine emperor first acquired silkworm eggs from the Chinese emperor.
11
The price of high-grade Chinese silk fell due to competition from Middle-Eastern producers.
12
Silk was produced in the Middle East several centuries before it was produced in Europe.
13
Global silk production has declined in recent years.

8 ____ Their first sight of silk created fear among Roman soldiers.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d7f09486-172f-5e5b-a202-d409b80a95ef', '189c8913-9af0-542d-9bca-6bc70b022d73', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('770a7c0d-0a4a-5dbd-99f3-e1cb5c1f36e7', '189c8913-9af0-542d-9bca-6bc70b022d73', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8a384718-bfbc-5e55-af5e-e8e8dfc7e751', '189c8913-9af0-542d-9bca-6bc70b022d73', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('65a74e14-a30d-5db8-937c-4d5b4ef1dd37', '550834af-0785-5a5d-9187-d9c0bae500ba', 9, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 9

Questions 8-13
Questions 8-13
Do the following statements agree with the information given in Reading Passage 1 ?
In boxes 8-13 on your answer sheet, write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
8
Their first sight of silk created fear among Roman soldiers.
9
The quality of Chinese silk imported by the early Romans varied widely.
10
The Byzantine emperor first acquired silkworm eggs from the Chinese emperor.
11
The price of high-grade Chinese silk fell due to competition from Middle-Eastern producers.
12
Silk was produced in the Middle East several centuries before it was produced in Europe.
13
Global silk production has declined in recent years.

9 ____ The quality of Chinese silk imported by the early Romans varied widely.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5206c3ce-5b9a-52ea-a559-11430643ea7a', '65a74e14-a30d-5db8-937c-4d5b4ef1dd37', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8dc395cd-8dd7-5e95-b834-f6803ced3c75', '65a74e14-a30d-5db8-937c-4d5b4ef1dd37', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2115eb43-c504-5eab-9b5e-bcda134e34fc', '65a74e14-a30d-5db8-937c-4d5b4ef1dd37', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('530b06a1-5714-527d-9dfc-79f9bf9951e2', '550834af-0785-5a5d-9187-d9c0bae500ba', 10, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 10

Questions 8-13
Questions 8-13
Do the following statements agree with the information given in Reading Passage 1 ?
In boxes 8-13 on your answer sheet, write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
8
Their first sight of silk created fear among Roman soldiers.
9
The quality of Chinese silk imported by the early Romans varied widely.
10
The Byzantine emperor first acquired silkworm eggs from the Chinese emperor.
11
The price of high-grade Chinese silk fell due to competition from Middle-Eastern producers.
12
Silk was produced in the Middle East several centuries before it was produced in Europe.
13
Global silk production has declined in recent years.

10 ____ The Byzantine emperor first acquired silkworm eggs from the Chinese emperor.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ae43dff9-1274-53a5-bf2a-1d84b81b3574', '530b06a1-5714-527d-9dfc-79f9bf9951e2', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('342abe6f-bb43-5372-82c8-1232d8e504de', '530b06a1-5714-527d-9dfc-79f9bf9951e2', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('71d74676-a546-5425-a4fe-2b31ce6402a8', '530b06a1-5714-527d-9dfc-79f9bf9951e2', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('bff8928a-348d-5545-9f9b-8c81b62d4d4a', '550834af-0785-5a5d-9187-d9c0bae500ba', 11, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 11

Questions 8-13
Questions 8-13
Do the following statements agree with the information given in Reading Passage 1 ?
In boxes 8-13 on your answer sheet, write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
8
Their first sight of silk created fear among Roman soldiers.
9
The quality of Chinese silk imported by the early Romans varied widely.
10
The Byzantine emperor first acquired silkworm eggs from the Chinese emperor.
11
The price of high-grade Chinese silk fell due to competition from Middle-Eastern producers.
12
Silk was produced in the Middle East several centuries before it was produced in Europe.
13
Global silk production has declined in recent years.

11 ____ The price of high-grade Chinese silk fell due to competition from Middle-Eastern producers.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('dcc08f38-4652-5b18-8a89-b215cb79e674', 'bff8928a-348d-5545-9f9b-8c81b62d4d4a', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5052ec13-194a-55e0-9f4b-b22f346a7e7b', 'bff8928a-348d-5545-9f9b-8c81b62d4d4a', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bad4cba7-8874-5912-b273-71fe641f8715', 'bff8928a-348d-5545-9f9b-8c81b62d4d4a', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('fdce4604-f7f1-523c-9d80-2fa2c6a1faeb', '550834af-0785-5a5d-9187-d9c0bae500ba', 12, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 12

Questions 8-13
Questions 8-13
Do the following statements agree with the information given in Reading Passage 1 ?
In boxes 8-13 on your answer sheet, write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
8
Their first sight of silk created fear among Roman soldiers.
9
The quality of Chinese silk imported by the early Romans varied widely.
10
The Byzantine emperor first acquired silkworm eggs from the Chinese emperor.
11
The price of high-grade Chinese silk fell due to competition from Middle-Eastern producers.
12
Silk was produced in the Middle East several centuries before it was produced in Europe.
13
Global silk production has declined in recent years.

12 ____ Silk was produced in the Middle East several centuries before it was produced in Europe.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d72694b7-a3df-594d-a34b-9e24db19936f', 'fdce4604-f7f1-523c-9d80-2fa2c6a1faeb', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5f3584c0-1dd1-596a-805c-d615251b2d7a', 'fdce4604-f7f1-523c-9d80-2fa2c6a1faeb', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('de3fb06d-1dfd-5daf-8ebf-863f2d9a7fe8', 'fdce4604-f7f1-523c-9d80-2fa2c6a1faeb', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('e473cfbe-a92d-5b2f-befe-72393dfe25c0', '550834af-0785-5a5d-9187-d9c0bae500ba', 13, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 13

Questions 8-13
Questions 8-13
Do the following statements agree with the information given in Reading Passage 1 ?
In boxes 8-13 on your answer sheet, write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
8
Their first sight of silk created fear among Roman soldiers.
9
The quality of Chinese silk imported by the early Romans varied widely.
10
The Byzantine emperor first acquired silkworm eggs from the Chinese emperor.
11
The price of high-grade Chinese silk fell due to competition from Middle-Eastern producers.
12
Silk was produced in the Middle East several centuries before it was produced in Europe.
13
Global silk production has declined in recent years.

13 ____ Global silk production has declined in recent years.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('09702b3e-ac34-54e2-a688-fa54956a0ef2', 'e473cfbe-a92d-5b2f-befe-72393dfe25c0', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a69d6af6-9682-57e2-b561-b281432b4c94', 'e473cfbe-a92d-5b2f-befe-72393dfe25c0', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4eaf4634-2691-5c24-8211-0ab07d426a56', 'e473cfbe-a92d-5b2f-befe-72393dfe25c0', 3, $md$NOT GIVEN$md$, false);

COMMIT;
