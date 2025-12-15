BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-the-history-of-tea-1408'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-the-history-of-tea-1408';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-the-history-of-tea-1408';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-the-history-of-tea-1408';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('c0808217-cbdc-5166-a4e2-6bbe7f74d4c4', 'ielts-reading-the-history-of-tea-1408', $t$The history of tea$t$, $md$## The history of tea

Nguồn:
- Test: https://mini-ielts.com/1408/reading/the-history-of-tea
- Solution: https://mini-ielts.com/1408/view-solution/reading/the-history-of-tea$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('54c2875b-6722-5729-9008-3c5a90ed8f40', 'c0808217-cbdc-5166-a4e2-6bbe7f74d4c4', 1, $t$Reading — The history of tea$t$, $md$Read the passage and answer questions **1–13**.

### Passage: The history of tea

The story of tea begins in China. According to legend, in 2737 BC, the Chinese emperor Shen Nung was sitting beneath a tree while his servant boiled drinking water, when some leaves from the tree blew into the water. Shen Nung, a renowned herbalist, decided to try the infusion that his servant had accidentally created. The tree was a Camellia sinensis, and the resulting drink was what we now call tea. It is impossible to know whether there is any truth in this story. But tea drinking certainly became established in China many centuries before it had even been heard of in the West. Containers for tea have been found in tombs dating from the Han Dynasty (206 BC—220 AD) but it was under the Tang Dynasty (618—906 AD), that tea became firmly established as the national drink of China.

It became such a favourite that during the late eighth century a writer called Lu Yu wrote the first book entirely about tea, the Ch’a Ching, or Tea Classic. It was shortly after this that tea was first introduced to Japan, by Japanese Buddhist monks who had travelled to China to study. Tea received almost instant imperial sponsorship and spread rapidly from the royal court and monasteries to the other sections of Japanese society.

So at this stage in the history of tea, Europe was rather lagging behind. In the latter half of the sixteenth century there are the first brief mentions of tea as a drink among Europeans. These are mostly from Portuguese who were living in the East as traders and missionaries. But although some of these individuals may have brought back samples of tea to their native country, it was not the Portuguese who were the first to ship back tea as a commercial import. This was done by the Dutch, who in the last years of the sixteenth century began to encroach on Portuguese trading routes in the East. By the turn of the century they had established a trading post on the island of Java, and it was via Java that in 1606 the first consignment of tea was shipped from China to Holland. Tea soon became a fashionable drink among the Dutch, and from there spread to other countries in continental western Europe, but because of its high price it remained a drink for the wealthy.

Britain, always a little suspicious of continental trends, had yet to become the nation of tea drinkers that it is today. Starting in 1600, the British East India Company had a monopoly on importing goods from outside Europe, and it is likely that sailors on these ships brought tea home as gifts. The first coffee house had been established in London in 1652, and tea was still somewhat unfamiliar to most readers, so it is fair to assume that the drink was still something of a curiosity. Gradually, it became a popular drink in coffee houses, which were as many locations for the transaction of business as they were for relaxation or pleasure. They were though the preserve of middle- and upper-class men; women drank tea in their own homes, and as yet tea was still too expensive to be widespread among the working classes. In part, its high price was due to a punitive system of taxation.

One unforeseen consequence of the taxation of tea was the growth of methods to avoid taxation—smuggling and adulteration. By the eighteenth century many Britons wanted to drink tea but could not afford the high prices, and their enthusiasm for the drink was matched by the enthusiasm of criminal gangs to smuggle it in. What began as a small time illegal trade, selling a few pounds of tea to personal contacts, developed by die late eighteenth century into an astonishing organised crime network, perhaps importing as much as 7 million lbs annually, compared to a legal import of 5 million lbs! Worse for die drinkers was that taxation also encouraged the adulteration of tea, particularly of smuggled tea which was not quality controlled through customs and excise. Leaves from other plants, or leaves which had already been brewed and then dried, were added to tea leaves. By 1784, the government realised that enough was enough, and that heavy taxation was creating more problems than it was words. The new Prime Minister, William Pitt the Younger, slashed the tax from 119 per cent to 12.5 per cent. Suddenly legal tea was affordable, and smuggling stopped virtually overnight.

Another great impetus to tea drinking resulted from the end of the East India Company’s monopoly on trade with China, in 1834. Before that date, China was the country of origin of the vast majority of the tea imported to Britain, but the end of its monopoly stimulated the East India Company to consider growing tea outside China. India had always been the centre of the Company’s operations, which led to the increased cultivation of tea in India, beginning in Assam. There were a few false starts, including the destruction by cattle of one of the earliest tea nurseries, but by 1888 British tea imports from India were for the first time greater than those from China.

The end of the East India Company’s monopoly on trade with China also had another result, which was more dramatic though less important in the long term: it ushered in the era of the tea clippers. While the Company had had the monopoly on trade, there was no rush to bring the tea from China to Britain, but after 1834 the tea trade became a virtual free for all. Individual merchants and sea captains with their own ships raced to bring home the tea and make the most money, using fast new clippers which had sleek lines, tall masts and huge sails. In particular there was a competition between British and American merchants, leading to the famous clipper races of the 1860s. But these races soon came to an end with the opening of the Suez Canal, which made the trade routes to China viable for steamships for the first time.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('02c4a9e5-d46d-5db5-bbf0-8aac24ada102', '54c2875b-6722-5729-9008-3c5a90ed8f40', 1, 'SENTENCE_COMPLETION', 'READING', 2, $md$### Question 1

Questions 1-7
Questions 1-7
Complete the sentences below with words taken from Reading Passage 1
Use
ONE WORD
for each answer.
Write your answers in boxes
1-7
on your answer sheet.
1
Researchers believed the tea containers detected in
1
from the Han Dynasty was the first evidence of the use of tea.
2
Lu Yu wrote a
2
about tea before anyone else in the eighth century.
3
It was
3
from Japan who brought tea to their native country from China.
4
Tea was carried from China to Europe actually by the
4
5
The British government had to cut down the taxation on tea due to the serious crime of
5
6
Tea was planted in
6
besides China in the 19th century.
7
In order to compete in shipping speed, traders used
7
for the race.

1 Researchers believed the tea containers detected in 1 ____ from the Han Dynasty was the first evidence of the use of tea.$md$, NULL, ARRAY['.*tombs.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('05d83a54-2027-5c5a-bca8-b20e32553c31', '54c2875b-6722-5729-9008-3c5a90ed8f40', 2, 'SENTENCE_COMPLETION', 'READING', 2, $md$### Question 2

Questions 1-7
Questions 1-7
Complete the sentences below with words taken from Reading Passage 1
Use
ONE WORD
for each answer.
Write your answers in boxes
1-7
on your answer sheet.
1
Researchers believed the tea containers detected in
1
from the Han Dynasty was the first evidence of the use of tea.
2
Lu Yu wrote a
2
about tea before anyone else in the eighth century.
3
It was
3
from Japan who brought tea to their native country from China.
4
Tea was carried from China to Europe actually by the
4
5
The British government had to cut down the taxation on tea due to the serious crime of
5
6
Tea was planted in
6
besides China in the 19th century.
7
In order to compete in shipping speed, traders used
7
for the race.

2 Lu Yu wrote a 2 ____ about tea before anyone else in the eighth century.$md$, NULL, ARRAY['.*book.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('af786395-1208-50bc-843c-3d3139ba5fd1', '54c2875b-6722-5729-9008-3c5a90ed8f40', 3, 'SENTENCE_COMPLETION', 'READING', 2, $md$### Question 3

Questions 1-7
Questions 1-7
Complete the sentences below with words taken from Reading Passage 1
Use
ONE WORD
for each answer.
Write your answers in boxes
1-7
on your answer sheet.
1
Researchers believed the tea containers detected in
1
from the Han Dynasty was the first evidence of the use of tea.
2
Lu Yu wrote a
2
about tea before anyone else in the eighth century.
3
It was
3
from Japan who brought tea to their native country from China.
4
Tea was carried from China to Europe actually by the
4
5
The British government had to cut down the taxation on tea due to the serious crime of
5
6
Tea was planted in
6
besides China in the 19th century.
7
In order to compete in shipping speed, traders used
7
for the race.

3 It was 3 ____ from Japan who brought tea to their native country from China.$md$, NULL, ARRAY['.*monks.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('7c18ab9a-1b1b-5df4-a66a-cac3657b7058', '54c2875b-6722-5729-9008-3c5a90ed8f40', 4, 'SENTENCE_COMPLETION', 'READING', 2, $md$### Question 4

Questions 1-7
Questions 1-7
Complete the sentences below with words taken from Reading Passage 1
Use
ONE WORD
for each answer.
Write your answers in boxes
1-7
on your answer sheet.
1
Researchers believed the tea containers detected in
1
from the Han Dynasty was the first evidence of the use of tea.
2
Lu Yu wrote a
2
about tea before anyone else in the eighth century.
3
It was
3
from Japan who brought tea to their native country from China.
4
Tea was carried from China to Europe actually by the
4
5
The British government had to cut down the taxation on tea due to the serious crime of
5
6
Tea was planted in
6
besides China in the 19th century.
7
In order to compete in shipping speed, traders used
7
for the race.

4 Tea was carried from China to Europe actually by the 4 ____$md$, NULL, ARRAY['.*dutch.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('9d6be9c3-18ce-5617-bbee-25d9042685c7', '54c2875b-6722-5729-9008-3c5a90ed8f40', 5, 'SENTENCE_COMPLETION', 'READING', 3, $md$### Question 5

Questions 1-7
Questions 1-7
Complete the sentences below with words taken from Reading Passage 1
Use
ONE WORD
for each answer.
Write your answers in boxes
1-7
on your answer sheet.
1
Researchers believed the tea containers detected in
1
from the Han Dynasty was the first evidence of the use of tea.
2
Lu Yu wrote a
2
about tea before anyone else in the eighth century.
3
It was
3
from Japan who brought tea to their native country from China.
4
Tea was carried from China to Europe actually by the
4
5
The British government had to cut down the taxation on tea due to the serious crime of
5
6
Tea was planted in
6
besides China in the 19th century.
7
In order to compete in shipping speed, traders used
7
for the race.

5 The British government had to cut down the taxation on tea due to the serious crime of 5 ____$md$, NULL, ARRAY['.*smuggling.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('a4adebc1-a3b0-5a58-88b1-62a1e2b22af3', '54c2875b-6722-5729-9008-3c5a90ed8f40', 6, 'SENTENCE_COMPLETION', 'READING', 3, $md$### Question 6

Questions 1-7
Questions 1-7
Complete the sentences below with words taken from Reading Passage 1
Use
ONE WORD
for each answer.
Write your answers in boxes
1-7
on your answer sheet.
1
Researchers believed the tea containers detected in
1
from the Han Dynasty was the first evidence of the use of tea.
2
Lu Yu wrote a
2
about tea before anyone else in the eighth century.
3
It was
3
from Japan who brought tea to their native country from China.
4
Tea was carried from China to Europe actually by the
4
5
The British government had to cut down the taxation on tea due to the serious crime of
5
6
Tea was planted in
6
besides China in the 19th century.
7
In order to compete in shipping speed, traders used
7
for the race.

6 Tea was planted in 6 ____ besides China in the 19th century.$md$, NULL, ARRAY['.*india.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('e4b4778e-f83b-5349-8436-b514154e3299', '54c2875b-6722-5729-9008-3c5a90ed8f40', 7, 'SENTENCE_COMPLETION', 'READING', 3, $md$### Question 7

Questions 1-7
Questions 1-7
Complete the sentences below with words taken from Reading Passage 1
Use
ONE WORD
for each answer.
Write your answers in boxes
1-7
on your answer sheet.
1
Researchers believed the tea containers detected in
1
from the Han Dynasty was the first evidence of the use of tea.
2
Lu Yu wrote a
2
about tea before anyone else in the eighth century.
3
It was
3
from Japan who brought tea to their native country from China.
4
Tea was carried from China to Europe actually by the
4
5
The British government had to cut down the taxation on tea due to the serious crime of
5
6
Tea was planted in
6
besides China in the 19th century.
7
In order to compete in shipping speed, traders used
7
for the race.

7 In order to compete in shipping speed, traders used 7 ____ for the race.$md$, NULL, ARRAY['.*clippers.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('a4f37027-67bf-5716-81cf-8f339dd77623', '54c2875b-6722-5729-9008-3c5a90ed8f40', 8, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 8

Questions 8-13
Questions 8-13
Do the following statements agree with the information given in Reading Passage 1?
In boxes
8-13
on your answer sheet, write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT
GIVEN
if there is no information on this
8
Tea was popular in Britain in the 16th century.
8
9
Tea was more fashionable than coffee in Europe in the late 16th century.
9
10
Tea was enjoyed by all classes in Britain in the seventeenth century.
10
11
The adulteration of tea also prompted William Pitt the Younger to reduce the tax.
11
12
Initial problems occurred when tea was planted outside China by the East India Company.
12
13
The fastest vessels were owned by America during the 19th century clipper races.
13

8 Tea was popular in Britain in the 16th century. 8 ____$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('926b3986-6b33-5ad8-baaf-ce772dee2d35', 'a4f37027-67bf-5716-81cf-8f339dd77623', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1201280e-8a45-54ca-87d2-5572be23ac98', 'a4f37027-67bf-5716-81cf-8f339dd77623', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('62b4bfee-b154-582b-b305-203ff358f0a1', 'a4f37027-67bf-5716-81cf-8f339dd77623', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('4af5d345-1559-5060-97d7-ebf410a96fd4', '54c2875b-6722-5729-9008-3c5a90ed8f40', 9, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 9

Questions 8-13
Questions 8-13
Do the following statements agree with the information given in Reading Passage 1?
In boxes
8-13
on your answer sheet, write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT
GIVEN
if there is no information on this
8
Tea was popular in Britain in the 16th century.
8
9
Tea was more fashionable than coffee in Europe in the late 16th century.
9
10
Tea was enjoyed by all classes in Britain in the seventeenth century.
10
11
The adulteration of tea also prompted William Pitt the Younger to reduce the tax.
11
12
Initial problems occurred when tea was planted outside China by the East India Company.
12
13
The fastest vessels were owned by America during the 19th century clipper races.
13

9 Tea was more fashionable than coffee in Europe in the late 16th century. 9 ____$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('488894f5-f60d-5055-adaa-21aca3183785', '4af5d345-1559-5060-97d7-ebf410a96fd4', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('911e9f68-8562-5fce-8c6b-cc910dd9ac1c', '4af5d345-1559-5060-97d7-ebf410a96fd4', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5bd66c74-3bbd-5213-a3a4-33fb0436519e', '4af5d345-1559-5060-97d7-ebf410a96fd4', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('10ba0c1f-c067-5848-8b3f-1733d649a291', '54c2875b-6722-5729-9008-3c5a90ed8f40', 10, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 10

Questions 8-13
Questions 8-13
Do the following statements agree with the information given in Reading Passage 1?
In boxes
8-13
on your answer sheet, write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT
GIVEN
if there is no information on this
8
Tea was popular in Britain in the 16th century.
8
9
Tea was more fashionable than coffee in Europe in the late 16th century.
9
10
Tea was enjoyed by all classes in Britain in the seventeenth century.
10
11
The adulteration of tea also prompted William Pitt the Younger to reduce the tax.
11
12
Initial problems occurred when tea was planted outside China by the East India Company.
12
13
The fastest vessels were owned by America during the 19th century clipper races.
13

10 Tea was enjoyed by all classes in Britain in the seventeenth century. 10 ____$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('251cb846-2496-5d16-9d28-a6ff6db52c4e', '10ba0c1f-c067-5848-8b3f-1733d649a291', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('11b82830-21c5-5d00-a085-d1dc204a5a0f', '10ba0c1f-c067-5848-8b3f-1733d649a291', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d699cf7c-c188-554f-9aa3-0d264cd08a57', '10ba0c1f-c067-5848-8b3f-1733d649a291', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('9bceae4a-e558-5bd7-a626-d3f65a64ed4f', '54c2875b-6722-5729-9008-3c5a90ed8f40', 11, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 11

Questions 8-13
Questions 8-13
Do the following statements agree with the information given in Reading Passage 1?
In boxes
8-13
on your answer sheet, write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT
GIVEN
if there is no information on this
8
Tea was popular in Britain in the 16th century.
8
9
Tea was more fashionable than coffee in Europe in the late 16th century.
9
10
Tea was enjoyed by all classes in Britain in the seventeenth century.
10
11
The adulteration of tea also prompted William Pitt the Younger to reduce the tax.
11
12
Initial problems occurred when tea was planted outside China by the East India Company.
12
13
The fastest vessels were owned by America during the 19th century clipper races.
13

11 The adulteration of tea also prompted William Pitt the Younger to reduce the tax. 11 ____$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('31028a7f-293c-5aa3-98db-071b132811c7', '9bceae4a-e558-5bd7-a626-d3f65a64ed4f', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('36c1e477-1233-5181-9e98-d320aa8b8e4a', '9bceae4a-e558-5bd7-a626-d3f65a64ed4f', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('923099da-cea3-50c8-868e-698adfcec41a', '9bceae4a-e558-5bd7-a626-d3f65a64ed4f', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('d1b83814-7741-598d-9f5a-fa2cb4ff7f25', '54c2875b-6722-5729-9008-3c5a90ed8f40', 12, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 12

Questions 8-13
Questions 8-13
Do the following statements agree with the information given in Reading Passage 1?
In boxes
8-13
on your answer sheet, write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT
GIVEN
if there is no information on this
8
Tea was popular in Britain in the 16th century.
8
9
Tea was more fashionable than coffee in Europe in the late 16th century.
9
10
Tea was enjoyed by all classes in Britain in the seventeenth century.
10
11
The adulteration of tea also prompted William Pitt the Younger to reduce the tax.
11
12
Initial problems occurred when tea was planted outside China by the East India Company.
12
13
The fastest vessels were owned by America during the 19th century clipper races.
13

12 Initial problems occurred when tea was planted outside China by the East India Company. 12 ____$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a7855aa8-f14a-5b47-bac2-d81de0d0417c', 'd1b83814-7741-598d-9f5a-fa2cb4ff7f25', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('032a4e91-b89f-5bc6-a9f0-59f16eb4b8e8', 'd1b83814-7741-598d-9f5a-fa2cb4ff7f25', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('acc21108-dfd7-56ef-83b8-4153658d7739', 'd1b83814-7741-598d-9f5a-fa2cb4ff7f25', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('62828e66-f9de-5803-88c6-d5f8f17acb2f', '54c2875b-6722-5729-9008-3c5a90ed8f40', 13, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 13

Questions 8-13
Questions 8-13
Do the following statements agree with the information given in Reading Passage 1?
In boxes
8-13
on your answer sheet, write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT
GIVEN
if there is no information on this
8
Tea was popular in Britain in the 16th century.
8
9
Tea was more fashionable than coffee in Europe in the late 16th century.
9
10
Tea was enjoyed by all classes in Britain in the seventeenth century.
10
11
The adulteration of tea also prompted William Pitt the Younger to reduce the tax.
11
12
Initial problems occurred when tea was planted outside China by the East India Company.
12
13
The fastest vessels were owned by America during the 19th century clipper races.
13

13 The fastest vessels were owned by America during the 19th century clipper races. 13 ____$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a5381dd1-eeec-50cd-9909-d485b927985f', '62828e66-f9de-5803-88c6-d5f8f17acb2f', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ec131696-f6cf-5ec6-b29e-4d15e5efed45', '62828e66-f9de-5803-88c6-d5f8f17acb2f', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c24f02ee-1c6d-58d9-89a3-f79ea5ebf813', '62828e66-f9de-5803-88c6-d5f8f17acb2f', 3, $md$NOT GIVEN$md$, true);

COMMIT;
