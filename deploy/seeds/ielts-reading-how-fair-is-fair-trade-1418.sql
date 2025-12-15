BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-how-fair-is-fair-trade-1418'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-how-fair-is-fair-trade-1418';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-how-fair-is-fair-trade-1418';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-how-fair-is-fair-trade-1418';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('37f5dd0c-17ab-5f84-ad69-e70160024600', 'ielts-reading-how-fair-is-fair-trade-1418', $t$How Fair is Fair Trade?$t$, $md$## How Fair is Fair Trade?

Nguồn:
- Test: https://mini-ielts.com/1418/reading/how-fair-is-fair-trade
- Solution: https://mini-ielts.com/1418/view-solution/reading/how-fair-is-fair-trade$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('15f7a370-406d-58a3-b169-cea3ca41d8f0', '37f5dd0c-17ab-5f84-ad69-e70160024600', 1, $t$Reading — How Fair is Fair Trade?$t$, $md$Read the passage and answer questions **1–13**.

### Passage: How Fair is Fair Trade?

The fair-trade movement began in Europe in earnest in the post-war period, but only in the last 25 years has it grown to include producers and consumers in over 60 countries.

In the 1950s and 60s, many people in the developed world felt passionately about the enormous disparities between developed and developing countries, and they believed the system of international trade shut out African, Asian, and South American producers who could not compete with multinational companies or who came from states that, for political reasons, were not trading with the West. The catchphrase ‘Trade Not Aid’ was used by church groups and trade unions – early supporters of fair trade – who also considered that international aid was either a pittance or a covert form of subjugation. These days, much fair trade does include aid: developed-world volunteers offer their services, and there is free training for producers and their workers.

Tea, coffee, cocoa, cotton, flowers, handicrafts, and gold are all major fair-trade items, with coffee being the most recognisable, fund on supermarket shelves and at café chains throughout the developed world.

Although around two million farmers and workers produce fair-trade items, this is a tiny number in relation to total global trade. Still, fair-trade advocates maintain that the system has positively impacted upon many more people worldwide, while the critics claim that if those two million returned to the mainstream trading system, they would receive higher prices for their goods or labour.

Fair trade is supposed to be a trade that is fair to producers. Its basic tenet is that developed-world consumers will pay slightly more for end products in the knowledge that developing-world producers have been equitably remunerated, and that the products have been made in decent circumstances. Additionally, the fair-trade system diﬀers from that of the open market because there is a minimum price paid for goods, which may be higher than that of the open market. Secondly, a small premium, earmarked for community development, is added in good years; for example, coﬀee co-operatives in South America frequently receive an additional 25c per kilogram. Lastly, purchasers of fair-trade products may assist with crop pre-financing or with the training of producers and workers, which could take the form of improving product quality, using environmentally friendly fertilisers, or raising literacy. Research has shown that non-fair-trade farmers copy some fair-trade farming practices, and, occasionally, encourage social progress. In exchange for ethical purchase and other assistance, fair-trade producers agree not to use child or slave labour, to adhere to the United Nations Charter on Human Rights, to provide safe workplaces, and to protect the environment despite these not being legally binding in their own countries. However, few non-fair-trade farmers have adopted these practices, viewing them as little more than rich-world conceits.

So that consumers know which products are made under fair-trade conditions, goods are labelled, and, these days, a single European and American umbrella organisation supervises labelling, standardisation, and inspection.

While fair trade is increasing, the system is far from perfect. First and foremost, there are expenses involved in becoming a fair-trade-certified producer, meaning the desperately poor rarely participate, so the very farmers fair-trade advocates originally hoped to support are excluded. Secondly, because conforming to the standards of fair-trade certification is costly, some producers deliberately mislabel their goods. The fair-trade monitoring process is patchy, and unfortunately, around 12% of fair-trade-labelled produce is nothing of the kind. Next, a crop may genuinely be produced under fair-trade conditions, but due to a lack of demand cannot be sold as fair trade, so goes onto the open market, where prices are mostly lower. It is estimated that only between 18-37% of fair-trade output is actually sold as fair trade. Sadly, there is little reliable research on the real relationship between costs incurred and revenue for fair-trade farmers, although empirical evidence suggests that many never realise a profit. Partly, reporting from producers is inadequate, and ways of determining profit may not include credit, harvesting, transport, or processing. Sometimes, the price paid to fair-trade producers is lower than that of the open market, so while a crop may be sold, elsewhere it could have earnt more, or where there are profits, they are often taken by the corporate firms that buy the goods and sell them on to retailers.

There are problems with the developed-world part of the equation too. People who volunteer to work for fair-trade concerns may do so believing they are assisting farmers and communities, whereas their labour serves to enrich middlemen and retailers. Companies involved in West African cocoa production have been criticised for this. In the developed world, the right to use a fair-trade logo is also expensive for packers and retailers, and sometimes a substantial amount of the money received from sale is ploughed back into marketing. In richer parts of the developed world, notably in London, packers and retailers charge high prices for fair-trade products. Consumers imagine they are paying so much because more money is returned to producers when profit-taking by retailers or packers is a more likely scenario. One UK café chain is known to have passed on 1.6% of the extra 18% is charged for fair-trade coﬀee to producers. However, this happens with other items at the supermarket or cafe, so perhaps consumers are naive to believe fair-traders behave otherwise. In addition, there are struggling farmers in rich countries, too, so some critics think fair-trade associations should certify them. Other critics find the entire fair-trade system ﬂawed – nothing more than a colossal marketing scam- and they would rather assist the genuinely poor in more transparent ways, but this criticism may be overblown since fair trade has endured for and been praised in the developing world itself.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('9ea5773b-95cb-5b6e-8bfa-e4606fbeddab', '15f7a370-406d-58a3-b169-cea3ca41d8f0', 1, 'SHORT_ANSWER', 'READING', 2, $md$### Question 1

Questions 1-5
Questions 1-5
Answer the questions below.
Choose
NO MORE THAN THREE WORDS
from the passage for each answer
Write your answers in boxes
1-5
on your answer sheet.
1.
What was an early slogan about addressing the imbalance between the developed and
developing worlds?
1
2.
What is probably the most well-known fair-trade commodity?
2
3.
According to the writer, in terms of total global trade, what do fair-trade producers represent?
3
4.
How do its supporters think fair trade has aﬀected many people?
4
5.
What do its critics think fair-trade producers would get if they went back to mainstream trade?
5

developing worlds? 1 ____$md$, NULL, ARRAY['.*trade.*not.*aid.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('693cdc96-7d66-5e19-b509-a6b7e00a956d', '15f7a370-406d-58a3-b169-cea3ca41d8f0', 2, 'SHORT_ANSWER', 'READING', 2, $md$### Question 2

Questions 1-5
Questions 1-5
Answer the questions below.
Choose
NO MORE THAN THREE WORDS
from the passage for each answer
Write your answers in boxes
1-5
on your answer sheet.
1.
What was an early slogan about addressing the imbalance between the developed and
developing worlds?
1
2.
What is probably the most well-known fair-trade commodity?
2
3.
According to the writer, in terms of total global trade, what do fair-trade producers represent?
3
4.
How do its supporters think fair trade has aﬀected many people?
4
5.
What do its critics think fair-trade producers would get if they went back to mainstream trade?
5

2. What is probably the most well-known fair-trade commodity? 2 ____$md$, NULL, ARRAY['.*coffee.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('17e87867-ed69-5b53-92d1-60d18a14da9f', '15f7a370-406d-58a3-b169-cea3ca41d8f0', 3, 'SHORT_ANSWER', 'READING', 2, $md$### Question 3

Questions 1-5
Questions 1-5
Answer the questions below.
Choose
NO MORE THAN THREE WORDS
from the passage for each answer
Write your answers in boxes
1-5
on your answer sheet.
1.
What was an early slogan about addressing the imbalance between the developed and
developing worlds?
1
2.
What is probably the most well-known fair-trade commodity?
2
3.
According to the writer, in terms of total global trade, what do fair-trade producers represent?
3
4.
How do its supporters think fair trade has aﬀected many people?
4
5.
What do its critics think fair-trade producers would get if they went back to mainstream trade?
5

3. According to the writer, in terms of total global trade, what do fair-trade producers represent? 3 ____$md$, NULL, ARRAY['.*a.*tiny.*number.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('f3172b56-8445-5b4f-8540-7187543a5888', '15f7a370-406d-58a3-b169-cea3ca41d8f0', 4, 'SHORT_ANSWER', 'READING', 2, $md$### Question 4

Questions 1-5
Questions 1-5
Answer the questions below.
Choose
NO MORE THAN THREE WORDS
from the passage for each answer
Write your answers in boxes
1-5
on your answer sheet.
1.
What was an early slogan about addressing the imbalance between the developed and
developing worlds?
1
2.
What is probably the most well-known fair-trade commodity?
2
3.
According to the writer, in terms of total global trade, what do fair-trade producers represent?
3
4.
How do its supporters think fair trade has aﬀected many people?
4
5.
What do its critics think fair-trade producers would get if they went back to mainstream trade?
5

4. How do its supporters think fair trade has aﬀected many people? 4 ____$md$, NULL, ARRAY['.*positively.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('c928a022-092c-5ffa-9378-16b726fc927d', '15f7a370-406d-58a3-b169-cea3ca41d8f0', 5, 'SHORT_ANSWER', 'READING', 3, $md$### Question 5

Questions 1-5
Questions 1-5
Answer the questions below.
Choose
NO MORE THAN THREE WORDS
from the passage for each answer
Write your answers in boxes
1-5
on your answer sheet.
1.
What was an early slogan about addressing the imbalance between the developed and
developing worlds?
1
2.
What is probably the most well-known fair-trade commodity?
2
3.
According to the writer, in terms of total global trade, what do fair-trade producers represent?
3
4.
How do its supporters think fair trade has aﬀected many people?
4
5.
What do its critics think fair-trade producers would get if they went back to mainstream trade?
5

5. What do its critics think fair-trade producers would get if they went back to mainstream trade? 5 ____$md$, NULL, ARRAY['.*higher.*prices.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('50f7926d-a971-572b-8999-f7f22aa1946e', '15f7a370-406d-58a3-b169-cea3ca41d8f0', 6, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 6

Questions 6-9
Questions 6-9
Complete each sentence with the correct ending,
A-H
, below.
Write the correct letter
A-H
, in boxes
6-9
on your answer sheet.
6
Consumers of fair-trade products are happy
7
The fair-trade system may include
8
Some fair-trade practices
9
Fair-trade producers must adopt international employment standards
A
loans or training for producers and employees.
B
although they may not be obliged to do so in their own country.
C
for the various social benefits fair trade brings.
D
to pay more for what they see as ethical products.
E
has influenced non-fair-trade producers.
F
because these are United Nations obligations.
G
too much corruption.
H
have been adopted by non-fair-trade producers.

6 ____ Consumers of fair-trade products are happy$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bf971d25-aa83-50f7-bbc8-7533b1957874', '50f7926d-a971-572b-8999-f7f22aa1946e', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c8bee2db-e7eb-5800-ba17-f8bfe5f28271', '50f7926d-a971-572b-8999-f7f22aa1946e', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('054938f7-22d6-52fe-b1a1-8461d4f75c37', '50f7926d-a971-572b-8999-f7f22aa1946e', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ebcf57ba-06b5-52b3-a347-766a2e0b741b', '50f7926d-a971-572b-8999-f7f22aa1946e', 4, $md$D$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('689b976d-ebe2-5949-aece-741c4d21e771', '50f7926d-a971-572b-8999-f7f22aa1946e', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('577debad-78e6-5f82-bb6e-6ad2993908e0', '50f7926d-a971-572b-8999-f7f22aa1946e', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0a039980-169a-558d-86c1-6aee5d8ef578', '50f7926d-a971-572b-8999-f7f22aa1946e', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('32d1b26c-c8f3-508e-a061-7b97fd955e02', '50f7926d-a971-572b-8999-f7f22aa1946e', 8, $md$H$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('dcb119f4-f663-5384-a116-e071b3e24a44', '15f7a370-406d-58a3-b169-cea3ca41d8f0', 7, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 7

Questions 6-9
Questions 6-9
Complete each sentence with the correct ending,
A-H
, below.
Write the correct letter
A-H
, in boxes
6-9
on your answer sheet.
6
Consumers of fair-trade products are happy
7
The fair-trade system may include
8
Some fair-trade practices
9
Fair-trade producers must adopt international employment standards
A
loans or training for producers and employees.
B
although they may not be obliged to do so in their own country.
C
for the various social benefits fair trade brings.
D
to pay more for what they see as ethical products.
E
has influenced non-fair-trade producers.
F
because these are United Nations obligations.
G
too much corruption.
H
have been adopted by non-fair-trade producers.

7 ____ The fair-trade system may include$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d4956799-ed0b-562c-b3f4-d4a12c5ca0d6', 'dcb119f4-f663-5384-a116-e071b3e24a44', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('98dec144-2d41-5148-a2e9-c9b57041a96d', 'dcb119f4-f663-5384-a116-e071b3e24a44', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('84ef9c61-329b-529b-b279-ab1a0ece15ce', 'dcb119f4-f663-5384-a116-e071b3e24a44', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6f7bdca7-fe9f-5933-a64a-118e3d36074a', 'dcb119f4-f663-5384-a116-e071b3e24a44', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7b0607c0-50a8-5dd9-986b-f2226c76d19b', 'dcb119f4-f663-5384-a116-e071b3e24a44', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('87e28e2f-b80b-5be2-b459-adb4e3106e21', 'dcb119f4-f663-5384-a116-e071b3e24a44', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d777fdba-87c3-5254-866b-abaf9b1be180', 'dcb119f4-f663-5384-a116-e071b3e24a44', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fb79ea50-288a-5862-a1f5-cfabf4212126', 'dcb119f4-f663-5384-a116-e071b3e24a44', 8, $md$H$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('4979352a-0bdc-582f-a737-bd3b24202a7f', '15f7a370-406d-58a3-b169-cea3ca41d8f0', 8, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 8

Questions 6-9
Questions 6-9
Complete each sentence with the correct ending,
A-H
, below.
Write the correct letter
A-H
, in boxes
6-9
on your answer sheet.
6
Consumers of fair-trade products are happy
7
The fair-trade system may include
8
Some fair-trade practices
9
Fair-trade producers must adopt international employment standards
A
loans or training for producers and employees.
B
although they may not be obliged to do so in their own country.
C
for the various social benefits fair trade brings.
D
to pay more for what they see as ethical products.
E
has influenced non-fair-trade producers.
F
because these are United Nations obligations.
G
too much corruption.
H
have been adopted by non-fair-trade producers.

8 ____ Some fair-trade practices$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8f79ebf8-f22a-545d-930b-a0e4b66bdfe9', '4979352a-0bdc-582f-a737-bd3b24202a7f', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3630909b-6aa8-592d-b251-9bc3735c3169', '4979352a-0bdc-582f-a737-bd3b24202a7f', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0e1a09f0-53d0-50b9-b494-2832059c3e9f', '4979352a-0bdc-582f-a737-bd3b24202a7f', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('94e15936-b40f-54f3-9542-d84a3dc370e8', '4979352a-0bdc-582f-a737-bd3b24202a7f', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a93f3496-ea7b-5e04-954c-f5fb7e0facac', '4979352a-0bdc-582f-a737-bd3b24202a7f', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f184c0d4-00f8-5899-8ef7-356ef706411a', '4979352a-0bdc-582f-a737-bd3b24202a7f', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('24bb9bd6-dcbe-5ab9-adff-c7094252093d', '4979352a-0bdc-582f-a737-bd3b24202a7f', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b8f55c5f-ab6c-55d6-b211-fecccbfd000b', '4979352a-0bdc-582f-a737-bd3b24202a7f', 8, $md$H$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('9f61d885-f31c-5218-b7f9-c17ead509ffa', '15f7a370-406d-58a3-b169-cea3ca41d8f0', 9, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 9

Questions 6-9
Questions 6-9
Complete each sentence with the correct ending,
A-H
, below.
Write the correct letter
A-H
, in boxes
6-9
on your answer sheet.
6
Consumers of fair-trade products are happy
7
The fair-trade system may include
8
Some fair-trade practices
9
Fair-trade producers must adopt international employment standards
A
loans or training for producers and employees.
B
although they may not be obliged to do so in their own country.
C
for the various social benefits fair trade brings.
D
to pay more for what they see as ethical products.
E
has influenced non-fair-trade producers.
F
because these are United Nations obligations.
G
too much corruption.
H
have been adopted by non-fair-trade producers.

9 ____ Fair-trade producers must adopt international employment standards$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cf5b2ad8-76ca-5c50-8275-96035f891d41', '9f61d885-f31c-5218-b7f9-c17ead509ffa', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5f814d73-b414-5bb2-bf8b-86a3371ede33', '9f61d885-f31c-5218-b7f9-c17ead509ffa', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4581c5ee-1268-584e-be55-f612552426be', '9f61d885-f31c-5218-b7f9-c17ead509ffa', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('da03fc2a-6b4d-5b16-9601-0ed291afe849', '9f61d885-f31c-5218-b7f9-c17ead509ffa', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('697f1f79-97fb-5994-b37b-da07044c2d58', '9f61d885-f31c-5218-b7f9-c17ead509ffa', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6ce44912-e953-55c1-a414-5a195255a403', '9f61d885-f31c-5218-b7f9-c17ead509ffa', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d704074e-d626-54ac-bc45-1bfc6fea7343', '9f61d885-f31c-5218-b7f9-c17ead509ffa', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cba82873-a888-52a3-b8db-47bffd601554', '9f61d885-f31c-5218-b7f9-c17ead509ffa', 8, $md$H$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('c91055df-cca6-5d16-b73a-80a22f1168c0', '15f7a370-406d-58a3-b169-cea3ca41d8f0', 10, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 10

Questions 10-13
Questions 10-13
Do the following statements agree with the claims of the writer in Reading Passage?
In boxes
10-13
on your answer sheet, write:
YES
if the statement agrees with the claims of the writer.
NO
if the statement contradicts the claims of the writer.
NOT
GIVEN
if it is impossible to say what the writer thinks about this.
10
The fair-trade system assists farmers who are extremely poor.
11
Some products labelled as fair-trade is in fact not.
12
UK supermarkets and cafes should not charge such high prices for fair-trade items.
13
Fair trade is mainly a marketing ploy and not a valid way of helping the poor.

10 ____ The fair-trade system assists farmers who are extremely poor.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1807995a-feaa-52b9-881a-37efdbe2b5cc', 'c91055df-cca6-5d16-b73a-80a22f1168c0', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('687e99b9-6071-57ab-bbb3-e60ac66a1175', 'c91055df-cca6-5d16-b73a-80a22f1168c0', 2, $md$NO$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f1ad4ace-c6eb-537c-86a3-974033103dd7', 'c91055df-cca6-5d16-b73a-80a22f1168c0', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('62f04c39-5162-51bc-9fb3-c80396cf20d0', '15f7a370-406d-58a3-b169-cea3ca41d8f0', 11, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 11

Questions 10-13
Questions 10-13
Do the following statements agree with the claims of the writer in Reading Passage?
In boxes
10-13
on your answer sheet, write:
YES
if the statement agrees with the claims of the writer.
NO
if the statement contradicts the claims of the writer.
NOT
GIVEN
if it is impossible to say what the writer thinks about this.
10
The fair-trade system assists farmers who are extremely poor.
11
Some products labelled as fair-trade is in fact not.
12
UK supermarkets and cafes should not charge such high prices for fair-trade items.
13
Fair trade is mainly a marketing ploy and not a valid way of helping the poor.

11 ____ Some products labelled as fair-trade is in fact not.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7b2b0c75-52a9-5fc4-b96f-8f87318e9e78', '62f04c39-5162-51bc-9fb3-c80396cf20d0', 1, $md$YES$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2c7b7e15-151a-5f50-85a9-51f35288dd36', '62f04c39-5162-51bc-9fb3-c80396cf20d0', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3b51c0f7-ae51-537c-911d-8e8f6468fe60', '62f04c39-5162-51bc-9fb3-c80396cf20d0', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('c46191c5-7cd0-5332-a8a6-dc1a384510a6', '15f7a370-406d-58a3-b169-cea3ca41d8f0', 12, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 12

Questions 10-13
Questions 10-13
Do the following statements agree with the claims of the writer in Reading Passage?
In boxes
10-13
on your answer sheet, write:
YES
if the statement agrees with the claims of the writer.
NO
if the statement contradicts the claims of the writer.
NOT
GIVEN
if it is impossible to say what the writer thinks about this.
10
The fair-trade system assists farmers who are extremely poor.
11
Some products labelled as fair-trade is in fact not.
12
UK supermarkets and cafes should not charge such high prices for fair-trade items.
13
Fair trade is mainly a marketing ploy and not a valid way of helping the poor.

12 ____ UK supermarkets and cafes should not charge such high prices for fair-trade items.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('30765e32-f30c-5484-b5c4-2e0b9797552f', 'c46191c5-7cd0-5332-a8a6-dc1a384510a6', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6dd7fa40-e5b7-512b-a7e4-d3baa69c14a8', 'c46191c5-7cd0-5332-a8a6-dc1a384510a6', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('568ae66c-f121-5d01-8d39-d80db28918fe', 'c46191c5-7cd0-5332-a8a6-dc1a384510a6', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('545697fc-5534-5128-9371-a03b09f4bb73', '15f7a370-406d-58a3-b169-cea3ca41d8f0', 13, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 13

Questions 10-13
Questions 10-13
Do the following statements agree with the claims of the writer in Reading Passage?
In boxes
10-13
on your answer sheet, write:
YES
if the statement agrees with the claims of the writer.
NO
if the statement contradicts the claims of the writer.
NOT
GIVEN
if it is impossible to say what the writer thinks about this.
10
The fair-trade system assists farmers who are extremely poor.
11
Some products labelled as fair-trade is in fact not.
12
UK supermarkets and cafes should not charge such high prices for fair-trade items.
13
Fair trade is mainly a marketing ploy and not a valid way of helping the poor.

13 ____ Fair trade is mainly a marketing ploy and not a valid way of helping the poor.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8f4cd3d3-8cb2-52be-ad57-1b703cf3e9da', '545697fc-5534-5128-9371-a03b09f4bb73', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('06864200-b8ba-520e-a93a-9ab9576a1da3', '545697fc-5534-5128-9371-a03b09f4bb73', 2, $md$NO$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c6e36db3-c530-5576-84a7-f85180a8e624', '545697fc-5534-5128-9371-a03b09f4bb73', 3, $md$NOT GIVEN$md$, false);

COMMIT;
