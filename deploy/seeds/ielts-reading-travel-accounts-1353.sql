BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-travel-accounts-1353'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-travel-accounts-1353';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-travel-accounts-1353';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-travel-accounts-1353';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('1be3c9ac-f4e3-5305-b54f-4480a500326d', 'ielts-reading-travel-accounts-1353', $t$Travel Accounts$t$, $md$## Travel Accounts

Nguồn:
- Test: https://mini-ielts.com/1353/reading/travel-accounts
- Solution: https://mini-ielts.com/1353/view-solution/reading/travel-accounts$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('f39fee0a-3496-5fe8-b715-b1bdf3c094cd', '1be3c9ac-f4e3-5305-b54f-4480a500326d', 1, $t$Reading — Travel Accounts$t$, $md$Read the passage and answer questions **1–13**.

### Passage: Travel Accounts

A

There are many reasons why individuals have traveled beyond their own societies. Some travelers may have simply desired to satisfy curiosity about the larger world. Until recent times, however, trade, business dealings, diplomacy, political administration, military campaigns, exile, flight from persecution, migration, pilgrimage, missionary efforts, and the quest for economic or educational opportunities were more common inducements for foreign travel than was a mere curiosity. While the travelers’ accounts give much valuable information on these foreign lands and provide a window for the understanding of the local cultures and histories, they are also a mirror to the travelers themselves, for these accounts help them to have a better understanding of themselves.

B

Records of foreign travel appeared soon after the invention of writing, and fragmentary travel accounts appeared in both Mesopotamia and Egypt in ancient times. After the formation of large, imperial states in the classical world, travel accounts emerged as a prominent literary genre in many lands, and they held especially strong appeal for rulers desiring useful knowledge about their realms. The Greek historian Herodotus reported on his travels in Egypt and Anatolia in researching the history of the Persian wars. The Chinese envoy Zhang Qian described much of central Asia as far west as Bactria (modern-day Afghanistan) on the basis of travels undertaken in the first century BC while searching for allies for the Han dynasty. Hellenistic and Roman geographers such as Ptolemy, Strabo, and Pliny the Elder relied on their own travels through much of the Mediterranean world as well as reports of other travelers to compile vast compendia of geographical knowledge.

C

During the postclassical era (about 500 to 1500 CE), trade and pilgrimage emerged as major incentives for travel to foreign lands. Muslim merchants sought trading opportunities throughout much of the eastern hemisphere. They described lands, peoples, and commercial products of the Indian Ocean basin from East Africa to Indonesia, and they supplied the first written accounts of societies in sub-Saharan west Africa. While merchants set out in search of trade and profit, devout Muslims traveled as pilgrims to Mecca to make their hajj and visit the holy sites of Islam. Since the prophet Muhammad’s original pilgrimage to Mecca, untold millions of Muslims have followed his example, and thousands of hajj accounts have related their experiences. One of the best known Muslim travelers, Ibn Battuta, began his travels with the hajj but then went on to visit central Asia, India, China, sub-Saharan Africa, and parts of Mediterranean Europe before returning finally to his home in Morocco. East Asian travelers were not quite so prominent as Muslims during the postclassical era, but they too followed many of the highways and sea lanes of the eastern hemisphere. Chinese merchants frequently visited Southeast Asia and India, occasionally venturing even to east Africa, and devout East Asian Buddhists undertook distant pilgrimages. Between the 5th and 9th centuries CE, hundreds and possibly even thousands of Chinese Buddhists traveled to India to study with Buddhist teachers, collect sacred texts, and visit holy sites. Written accounts recorded the experiences of many pilgrims, such as Faxian, Xuanzang, and Yijing. Though not so numerous as the Chinese pilgrims, Buddhists from Japan, Korea, and other lands also ventured abroad in the interests of spiritual enlightenment.

D

Medieval Europeans did not hit the roads in such large numbers as their Muslim and east Asian counterparts during the early part of the postclassical era, although gradually increasing crowds of Christian pilgrims flowed to Jerusalem, Rome, Santiago de Compostela (in northern Spain), and other sites. After the 12th century, however, merchants, pilgrims, and missionaries from medieval Europe traveled widely and left numerous travel accounts, of which Marco Polo’s description of his travels and sojourn in China is the best known. As they became familiar with the larger world of the eastern hemisphere – and the profitable commercial opportunities that it offered – European peoples worked to find new and more direct routes to Asian and African markets. Their efforts took them not only to all parts of the eastern hemisphere but eventually to the Americas and Oceania as well.

E

If Muslim and Chinese peoples dominated travel writing in postclassical times, European explorers, conquerors, merchants, and missionaries took center stage during the early modern era (about 1500 to 1800 CE). By no means did Muslim and Chinese travel come to a halt in early modern times. But European peoples ventured to the distant corners of the globe, and European printing presses churned out thousands of travel accounts that described foreign lands and peoples for a reading public with an apparently insatiable appetite for news about the larger world. The volume of travel literature was so great that several editors, including Giambattista Ramusio, Richard Hakluyt, Theodore de Bry, and Samuel Purchas, assembled numerous travel accounts and made them available in enormous published collections.

F

During the 19th century, European travelers made their way to the interior regions of Africa and the Americas, generating a fresh round of travel writing as they did so. Meanwhile, European colonial administrators devoted numerous writing to the societies of their colonial subjects, particularly in Asian and African colonies they established. By midcentury, attention was flowing also in the other direction. Painfully aware of the military and technological prowess of European and Euro-American societies, Asian travelers, in particular, visited Europe and the United States in hopes of discovering principles useful for the reorganization of their own societies. Among the most prominent of these travelers who made extensive use of their overseas observations and experiences in their own writing were the Japanese reformer Fukuzawa Yukichi and the Chinese revolutionary Sun Yat-sen.

G

With the development of inexpensive and reliable means of mass transport, the 20th century witnessed explosions both in the frequency of long-distance travel and in the volume of travel writing. While a great deal of travel took place for reasons of business, administration, diplomacy, pilgrimage, and missionary work, as in ages past, increasingly effective modes of mass transport made it possible for new kinds of travel to flourish. The most distinctive of them was mass tourism, which emerged as a major form of consumption for individuals living in the world’s wealthy societies. Tourism enabled consumers to get away from home to see the sights in Rome, take a cruise through the Caribbean, walk the Great Wall of China, visit some wineries in Bordeaux, or go on safari in Kenya. A peculiar variant of the travel account arose to meet the needs of these tourists: the guidebook, which offered advice on food, lodging, shopping, local customs, and all the sights that visitors should not miss seeing. Tourism has had a massive economic impact throughout the world, but other new forms of travel have also had considerable influence in contemporary times. Recent times have seen unprecedented waves of migration, for example, and numerous migrants have sought to record their experiences and articulate their feelings about life in foreign lands. Recent times have also seen an unprecedented development of ethnic consciousness, and many are the intellectuals and writers in the diaspora who have visited the homes of their ancestors to see how much of their forebears’ values and cultural traditions they themselves have inherited. Particularly notable among their accounts are the memoirs of Malcolm X and Maya Angelou describing their visits to Africa.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('3b18b2e5-c34a-5708-96ee-4725e8ba9aa8', 'f39fee0a-3496-5fe8-b715-b1bdf3c094cd', 1, 'TABLE_COMPLETION', 'READING', 2, $md$### Question 1

Questions 1-8
Questions 1-8
Complete the table below.
Write
NO MORE THAN TWO WORDS
from Reading Passage for each answer.
Write your answer in boxes
1-8
on your answer sheet.
TIME
DESTINATION
TRAVELER
PURPOSE
Classical era
Egypt and Anatolia
Herodotus
To obtain information on
1
.
1st century BC
Central Asia
Zhang Qian
To seek
2
.
Roman Empire
Mediterranean
Ptolemy, Strabo Pliny the Elder
To gather
3
Post-classical era
Eastern Hemisphere
Muslims
For business and
4
5th to 9th centuries CE
India
Asian Buddhists
To study with
5
and for spiritual enlightenment
Early modern era
Distant places of the globe
The Europeans
To meet the public’s expectation for the outside
19th century
Asia, Africa
Colonial administrator
To provide information on the
6
they conquer
By the mid-century of the 1800s
Europe and the United States
Sun Yat-sen, Fukuzawa Yukichi
To learn
7
for the reorganization of their societies
20th century
Mass tourism
People from
8
countries
For entertainment

To obtain information on 1 ____ .$md$, NULL, ARRAY['.*persian.*wars.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('c05bd13a-03ca-5712-8a09-ea92709e0433', 'f39fee0a-3496-5fe8-b715-b1bdf3c094cd', 2, 'TABLE_COMPLETION', 'READING', 2, $md$### Question 2

Questions 1-8
Questions 1-8
Complete the table below.
Write
NO MORE THAN TWO WORDS
from Reading Passage for each answer.
Write your answer in boxes
1-8
on your answer sheet.
TIME
DESTINATION
TRAVELER
PURPOSE
Classical era
Egypt and Anatolia
Herodotus
To obtain information on
1
.
1st century BC
Central Asia
Zhang Qian
To seek
2
.
Roman Empire
Mediterranean
Ptolemy, Strabo Pliny the Elder
To gather
3
Post-classical era
Eastern Hemisphere
Muslims
For business and
4
5th to 9th centuries CE
India
Asian Buddhists
To study with
5
and for spiritual enlightenment
Early modern era
Distant places of the globe
The Europeans
To meet the public’s expectation for the outside
19th century
Asia, Africa
Colonial administrator
To provide information on the
6
they conquer
By the mid-century of the 1800s
Europe and the United States
Sun Yat-sen, Fukuzawa Yukichi
To learn
7
for the reorganization of their societies
20th century
Mass tourism
People from
8
countries
For entertainment

To seek 2 ____ .$md$, NULL, ARRAY['.*allies.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('830f31de-7af7-5431-af84-f34ef82c080a', 'f39fee0a-3496-5fe8-b715-b1bdf3c094cd', 3, 'TABLE_COMPLETION', 'READING', 2, $md$### Question 3

Questions 1-8
Questions 1-8
Complete the table below.
Write
NO MORE THAN TWO WORDS
from Reading Passage for each answer.
Write your answer in boxes
1-8
on your answer sheet.
TIME
DESTINATION
TRAVELER
PURPOSE
Classical era
Egypt and Anatolia
Herodotus
To obtain information on
1
.
1st century BC
Central Asia
Zhang Qian
To seek
2
.
Roman Empire
Mediterranean
Ptolemy, Strabo Pliny the Elder
To gather
3
Post-classical era
Eastern Hemisphere
Muslims
For business and
4
5th to 9th centuries CE
India
Asian Buddhists
To study with
5
and for spiritual enlightenment
Early modern era
Distant places of the globe
The Europeans
To meet the public’s expectation for the outside
19th century
Asia, Africa
Colonial administrator
To provide information on the
6
they conquer
By the mid-century of the 1800s
Europe and the United States
Sun Yat-sen, Fukuzawa Yukichi
To learn
7
for the reorganization of their societies
20th century
Mass tourism
People from
8
countries
For entertainment

To gather 3 ____$md$, NULL, ARRAY['.*geographical.*knowledge.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('8c2d54aa-df8e-56f7-916f-5879336aab03', 'f39fee0a-3496-5fe8-b715-b1bdf3c094cd', 4, 'TABLE_COMPLETION', 'READING', 2, $md$### Question 4

Questions 1-8
Questions 1-8
Complete the table below.
Write
NO MORE THAN TWO WORDS
from Reading Passage for each answer.
Write your answer in boxes
1-8
on your answer sheet.
TIME
DESTINATION
TRAVELER
PURPOSE
Classical era
Egypt and Anatolia
Herodotus
To obtain information on
1
.
1st century BC
Central Asia
Zhang Qian
To seek
2
.
Roman Empire
Mediterranean
Ptolemy, Strabo Pliny the Elder
To gather
3
Post-classical era
Eastern Hemisphere
Muslims
For business and
4
5th to 9th centuries CE
India
Asian Buddhists
To study with
5
and for spiritual enlightenment
Early modern era
Distant places of the globe
The Europeans
To meet the public’s expectation for the outside
19th century
Asia, Africa
Colonial administrator
To provide information on the
6
they conquer
By the mid-century of the 1800s
Europe and the United States
Sun Yat-sen, Fukuzawa Yukichi
To learn
7
for the reorganization of their societies
20th century
Mass tourism
People from
8
countries
For entertainment

For business and 4 ____$md$, NULL, ARRAY['.*pilgrimage.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('008b0b0e-975c-5e5e-8c59-de8f1b2d79e1', 'f39fee0a-3496-5fe8-b715-b1bdf3c094cd', 5, 'TABLE_COMPLETION', 'READING', 3, $md$### Question 5

Questions 1-8
Questions 1-8
Complete the table below.
Write
NO MORE THAN TWO WORDS
from Reading Passage for each answer.
Write your answer in boxes
1-8
on your answer sheet.
TIME
DESTINATION
TRAVELER
PURPOSE
Classical era
Egypt and Anatolia
Herodotus
To obtain information on
1
.
1st century BC
Central Asia
Zhang Qian
To seek
2
.
Roman Empire
Mediterranean
Ptolemy, Strabo Pliny the Elder
To gather
3
Post-classical era
Eastern Hemisphere
Muslims
For business and
4
5th to 9th centuries CE
India
Asian Buddhists
To study with
5
and for spiritual enlightenment
Early modern era
Distant places of the globe
The Europeans
To meet the public’s expectation for the outside
19th century
Asia, Africa
Colonial administrator
To provide information on the
6
they conquer
By the mid-century of the 1800s
Europe and the United States
Sun Yat-sen, Fukuzawa Yukichi
To learn
7
for the reorganization of their societies
20th century
Mass tourism
People from
8
countries
For entertainment

To study with 5 ____ and for spiritual enlightenment$md$, NULL, ARRAY['.*buddhist.*teachers.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('90f4a362-1472-5022-865e-c7b124dd668a', 'f39fee0a-3496-5fe8-b715-b1bdf3c094cd', 6, 'TABLE_COMPLETION', 'READING', 3, $md$### Question 6

Questions 1-8
Questions 1-8
Complete the table below.
Write
NO MORE THAN TWO WORDS
from Reading Passage for each answer.
Write your answer in boxes
1-8
on your answer sheet.
TIME
DESTINATION
TRAVELER
PURPOSE
Classical era
Egypt and Anatolia
Herodotus
To obtain information on
1
.
1st century BC
Central Asia
Zhang Qian
To seek
2
.
Roman Empire
Mediterranean
Ptolemy, Strabo Pliny the Elder
To gather
3
Post-classical era
Eastern Hemisphere
Muslims
For business and
4
5th to 9th centuries CE
India
Asian Buddhists
To study with
5
and for spiritual enlightenment
Early modern era
Distant places of the globe
The Europeans
To meet the public’s expectation for the outside
19th century
Asia, Africa
Colonial administrator
To provide information on the
6
they conquer
By the mid-century of the 1800s
Europe and the United States
Sun Yat-sen, Fukuzawa Yukichi
To learn
7
for the reorganization of their societies
20th century
Mass tourism
People from
8
countries
For entertainment

To provide information on the 6 ____ they conquer$md$, NULL, ARRAY['.*colonies.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('ba6bdda4-3f5e-59f9-8e44-7cdba51f6688', 'f39fee0a-3496-5fe8-b715-b1bdf3c094cd', 7, 'TABLE_COMPLETION', 'READING', 3, $md$### Question 7

Questions 1-8
Questions 1-8
Complete the table below.
Write
NO MORE THAN TWO WORDS
from Reading Passage for each answer.
Write your answer in boxes
1-8
on your answer sheet.
TIME
DESTINATION
TRAVELER
PURPOSE
Classical era
Egypt and Anatolia
Herodotus
To obtain information on
1
.
1st century BC
Central Asia
Zhang Qian
To seek
2
.
Roman Empire
Mediterranean
Ptolemy, Strabo Pliny the Elder
To gather
3
Post-classical era
Eastern Hemisphere
Muslims
For business and
4
5th to 9th centuries CE
India
Asian Buddhists
To study with
5
and for spiritual enlightenment
Early modern era
Distant places of the globe
The Europeans
To meet the public’s expectation for the outside
19th century
Asia, Africa
Colonial administrator
To provide information on the
6
they conquer
By the mid-century of the 1800s
Europe and the United States
Sun Yat-sen, Fukuzawa Yukichi
To learn
7
for the reorganization of their societies
20th century
Mass tourism
People from
8
countries
For entertainment

To learn 7 ____ for the reorganization of their societies$md$, NULL, ARRAY['.*principles.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('cdc5c264-95bc-517f-b26d-1d42d9f288fc', 'f39fee0a-3496-5fe8-b715-b1bdf3c094cd', 8, 'TABLE_COMPLETION', 'READING', 3, $md$### Question 8

Questions 1-8
Questions 1-8
Complete the table below.
Write
NO MORE THAN TWO WORDS
from Reading Passage for each answer.
Write your answer in boxes
1-8
on your answer sheet.
TIME
DESTINATION
TRAVELER
PURPOSE
Classical era
Egypt and Anatolia
Herodotus
To obtain information on
1
.
1st century BC
Central Asia
Zhang Qian
To seek
2
.
Roman Empire
Mediterranean
Ptolemy, Strabo Pliny the Elder
To gather
3
Post-classical era
Eastern Hemisphere
Muslims
For business and
4
5th to 9th centuries CE
India
Asian Buddhists
To study with
5
and for spiritual enlightenment
Early modern era
Distant places of the globe
The Europeans
To meet the public’s expectation for the outside
19th century
Asia, Africa
Colonial administrator
To provide information on the
6
they conquer
By the mid-century of the 1800s
Europe and the United States
Sun Yat-sen, Fukuzawa Yukichi
To learn
7
for the reorganization of their societies
20th century
Mass tourism
People from
8
countries
For entertainment

People from 8 ____ countries$md$, NULL, ARRAY['.*wealthy.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('d46519b0-d354-5eea-bdea-34e2a71230f7', 'f39fee0a-3496-5fe8-b715-b1bdf3c094cd', 9, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 9

Questions 9-13
Questions 9-13
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
9-13
on your answer sheet.
9.
Why did some people travel in the early days?
A
to do research on themselves
B
to write travel books
C
to have a better understanding of other people and places
D
to study local culture
10.
The travelers’ accounts are a mirror to themselves,
A
because they help them to be aware of local histories.
B
because travelers are curious about the world.
C
because travelers could do more research on the unknown.
D
because they reflect the writers’ own experience and social life.
11.
Most of the people who went to holy sites during the early part of the postclassical era are
A
Europeans.
B
Muslim and East Asians.
C
Americans.
D
Greeks.
12.
During the early modern era, a large number of travel books were published to
A
provide what the public wants.
B
encourage the public’s feedback.
C
gain profit.
D
prompt trips to the new world.
13.
What stimulated the market for traveling in the 20th century?
A
the wealthy
B
travel books
C
delicious food
D
mass transport

Choose the correct letter, A , B , C or D .$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('7ce90430-ee5e-5a5b-a7cb-12f14c74fe02', 'f39fee0a-3496-5fe8-b715-b1bdf3c094cd', 10, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 10

Questions 9-13
Questions 9-13
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
9-13
on your answer sheet.
9.
Why did some people travel in the early days?
A
to do research on themselves
B
to write travel books
C
to have a better understanding of other people and places
D
to study local culture
10.
The travelers’ accounts are a mirror to themselves,
A
because they help them to be aware of local histories.
B
because travelers are curious about the world.
C
because travelers could do more research on the unknown.
D
because they reflect the writers’ own experience and social life.
11.
Most of the people who went to holy sites during the early part of the postclassical era are
A
Europeans.
B
Muslim and East Asians.
C
Americans.
D
Greeks.
12.
During the early modern era, a large number of travel books were published to
A
provide what the public wants.
B
encourage the public’s feedback.
C
gain profit.
D
prompt trips to the new world.
13.
What stimulated the market for traveling in the 20th century?
A
the wealthy
B
travel books
C
delicious food
D
mass transport

Choose the correct letter, A , B , C or D .$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('71d4577b-6bfa-5ebc-bcde-320f91195107', 'f39fee0a-3496-5fe8-b715-b1bdf3c094cd', 11, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 11

Questions 9-13
Questions 9-13
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
9-13
on your answer sheet.
9.
Why did some people travel in the early days?
A
to do research on themselves
B
to write travel books
C
to have a better understanding of other people and places
D
to study local culture
10.
The travelers’ accounts are a mirror to themselves,
A
because they help them to be aware of local histories.
B
because travelers are curious about the world.
C
because travelers could do more research on the unknown.
D
because they reflect the writers’ own experience and social life.
11.
Most of the people who went to holy sites during the early part of the postclassical era are
A
Europeans.
B
Muslim and East Asians.
C
Americans.
D
Greeks.
12.
During the early modern era, a large number of travel books were published to
A
provide what the public wants.
B
encourage the public’s feedback.
C
gain profit.
D
prompt trips to the new world.
13.
What stimulated the market for traveling in the 20th century?
A
the wealthy
B
travel books
C
delicious food
D
mass transport

Choose the correct letter, A , B , C or D .$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('7555fec8-f45b-5eb1-ac7a-14aa6619f170', 'f39fee0a-3496-5fe8-b715-b1bdf3c094cd', 12, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 12

Questions 9-13
Questions 9-13
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
9-13
on your answer sheet.
9.
Why did some people travel in the early days?
A
to do research on themselves
B
to write travel books
C
to have a better understanding of other people and places
D
to study local culture
10.
The travelers’ accounts are a mirror to themselves,
A
because they help them to be aware of local histories.
B
because travelers are curious about the world.
C
because travelers could do more research on the unknown.
D
because they reflect the writers’ own experience and social life.
11.
Most of the people who went to holy sites during the early part of the postclassical era are
A
Europeans.
B
Muslim and East Asians.
C
Americans.
D
Greeks.
12.
During the early modern era, a large number of travel books were published to
A
provide what the public wants.
B
encourage the public’s feedback.
C
gain profit.
D
prompt trips to the new world.
13.
What stimulated the market for traveling in the 20th century?
A
the wealthy
B
travel books
C
delicious food
D
mass transport

Choose the correct letter, A , B , C or D .$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('dd49244a-a09f-55cb-b6d8-438ef4e59b83', 'f39fee0a-3496-5fe8-b715-b1bdf3c094cd', 13, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 13

Questions 9-13
Questions 9-13
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
9-13
on your answer sheet.
9.
Why did some people travel in the early days?
A
to do research on themselves
B
to write travel books
C
to have a better understanding of other people and places
D
to study local culture
10.
The travelers’ accounts are a mirror to themselves,
A
because they help them to be aware of local histories.
B
because travelers are curious about the world.
C
because travelers could do more research on the unknown.
D
because they reflect the writers’ own experience and social life.
11.
Most of the people who went to holy sites during the early part of the postclassical era are
A
Europeans.
B
Muslim and East Asians.
C
Americans.
D
Greeks.
12.
During the early modern era, a large number of travel books were published to
A
provide what the public wants.
B
encourage the public’s feedback.
C
gain profit.
D
prompt trips to the new world.
13.
What stimulated the market for traveling in the 20th century?
A
the wealthy
B
travel books
C
delicious food
D
mass transport

Choose the correct letter, A , B , C or D .$md$, NULL);

COMMIT;
