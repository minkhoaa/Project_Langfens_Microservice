BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-when-the-tulip-bubble-burst-1259'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-when-the-tulip-bubble-burst-1259';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-when-the-tulip-bubble-burst-1259';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-when-the-tulip-bubble-burst-1259';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('fe789b19-d2fc-5124-b623-93a66395e6c1', 'ielts-reading-when-the-tulip-bubble-burst-1259', $t$When the Tulip Bubble Burst$t$, $md$## When the Tulip Bubble Burst

Nguồn:
- Test: https://mini-ielts.com/1259/reading/when-the-tulip-bubble-burst
- Solution: https://mini-ielts.com/1259/view-solution/reading/when-the-tulip-bubble-burst$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('863a0906-2bca-5e39-a40d-484da60af959', 'fe789b19-d2fc-5124-b623-93a66395e6c1', 1, $t$Reading — When the Tulip Bubble Burst$t$, $md$Read the passage and answer questions **1–14**.

### Passage: When the Tulip Bubble Burst

Tulips are spring-blooming perennials that grow from bulbs. Depending on the species, tulip plants can grow as short as 4 inches (10 cm) or as high as 28 inches (71 cm). The tulip’s large flowers usually bloom on scapes or sub-scapose stems that lack bracts. Most tulips produce only one flower per stem, but a few species bear multiple flowers on their scapes (e.g. Tulipa turkestanica). The showy, generally cup or star-shaped tulip flower has three petals and three sepals, which are often termed tepals because they are nearly identical. These six tepals are often marked on the interior surface near the bases with darker colorings. Tulip flowers come in a wide variety of colors, except pure blue (several tulips with “blue” in the name have a faint violet hue)

A . Long before anyone ever heard of Qualcomm, CMGI, Cisco Systems, or the other high-tech stocks that have soared during the current bull market, there was Semper Augustus. Both more prosaic and more sublime than any stock or bond, it was a tulip of extraordinary beauty, its midnight-blue petals topped by a band of pure white and accented with crimson flares. To denizens of 17th century Holland, little was as desirable.

B . Around 1624, the Amsterdam man who owned the only dozen specimens was offered 3,000 guilders for one bulb. While there’s no accurate way to render that in today’s greenbacks, the sum was roughly equal to the annual income of a wealthy merchant. (A few years later, Rembrandt received about half that amount for painting The Night Watch.) Yet the bulb’s owner, whose name is now lost to history, nixed the offer.

C . Who was crazier, the tulip lover who refused to sell for a small fortune or the one who was willing to splurge. That’s a question that springs to mind after reading Tulip mania: The Story of the World’s Most Coveted Flower and the Extraordinary Passions It Aroused by British journalist Mike Dash. In recent years, as investors have intentionally forgotten everything they learned in Investing 101 in order to load up on unproved, unprofitable dot- com issues, tulip mania has been invoked frequently. In this concise, artfully written account, Dash tells the real history behind the buzzword and in doing so, offers a cautionary tale for our times.

D . The Dutch were not the first to go gaga over the tulip. Long before the first tulip bloomed in Europe-in Bavaria, it turns out, in 1559-the flower had enchanted the Persians and bewitched the rulers of the Ottoman Empire. It was in Holland, however, that the passion for tulips found its most fertile ground, for reasons that had little to do with horticulture.

E . Holland in the early 17th century was embarking on its Golden Age. Resources that had just a few years earlier gone toward fighting for independence from Spain now flowed into commerce. Amsterdam merchants were at the center of the lucrative East Indies trade, where a single voyage could yield profits of 400%. They displayed their success by erecting grand estates surrounded by flower gardens. The Dutch population seemed tom by two contradictory impulses: a horror of living beyond one’s means and the love of a long shot.

F . Enter the tulip. “It is impossible to comprehend the tulip mania without understanding just how different tulips were from every other flower known to horticulturists in the 17th century,” says Dash. “The colors they exhibited were more intense and more concentrated than those of ordinary plants.” Despite the outlandish prices commanded by rare bulbs, ordinary tulips were sold by the pound. Around 1630, however, a new type of tulip fancier appeared, lured by tales of fat profits. These “florists,” or professional tulip traders, sought out flower lovers and speculators alike. But if the supply of tulip buyers grew quickly, the supply of bulbs did not. The tulip was a conspirator in the supply squeeze: It takes seven years to grow one from seed. And while bulbs can produce two or three clones, or “offsets,” annually, the mother bulb only lasts a few years.

G . Bulb prices rose steadily throughout the 1630s, as ever more speculators into the market. Weavers and farmers mortgaged whatever they could to raise cash to begin trading. In 1633, a farmhouse in Hoorn changed hands for three rare bulbs. By 1636 any tulip-even bulbs recently considered garbage-could be sold off, often for hundreds of guilders. A futures market for bulbs existed, and tulip traders could be found conducting their business in hundreds of Dutch taverns. Tulip mania reached its peak during the winter of 1636-37, when some bulbs were changing hands ten times in a day. The zenith came early that winter, at an auction to benefit seven orphans whose only asset was 70 fine tulips left by then father. One, a rare Violetten Admirael van Enkhuizen bulb that was about to split in two, sold for 5,200 guilders, the all-time record. All told, the flowers brought in nearly 53,000 guilders.

H . Soon after, the tulip market crashed utterly, spectacularly. It began in Haarlem, at a routine bulb auction when, for the first time, the greater fool refused to show up and pay. Within days, the panic had spread across the country. Despite the efforts of traders to prop up demand, the market for tulips evaporated. Flowers that had commanded 5,000 guilders a few weeks before now fetched one-hundredth that amount. Tulip mania is not without flaws. Dash dwells too long on the tulip’s migration from Asia to Holland. But he does a service with this illuminating, accessible account of incredible financial folly.

I . Tulip mania differed in one crucial aspect from the dot-com craze that grips our attention today: Even at its height, the Amsterdam Stock Exchange, well- established in 1630, wouldn’t touch tulips. “The speculation in tulip bulbs always existed at the margins of Dutch economic life,” Dash writes. After the market crashed, a compromise was brokered that let most traders settle then debts for a fraction of then liability. The overall fallout on the Dutch economy was negligible. Will we say the same when Wall Street’s current obsession finally runs its course?$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('f399d984-b819-53d6-9cf9-fbca2c546de5', '863a0906-2bca-5e39-a40d-484da60af959', 1, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 1

Questions 1-5
Questions 1-5
The reading Passage has seven paragraphs
A-I
.
Which paragraph contains the following information?
Write the correct letter
A-I
, in boxes
1-5
on your answer sheet.
1
Difference between bubble burst impacts by tulip and by
high-tech
shares
2
Spread of tulip before 17th century
3
Indication of money offered for rare bulb in 17th century
4
Tulip was treated as money in Holland
5
Comparison made between tulip and other plants

1 ____ Difference between bubble burst impacts by tulip and by high-tech shares$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f0e7bc7d-6df4-5cff-8e06-11dbbc3e84bb', 'f399d984-b819-53d6-9cf9-fbca2c546de5', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e590af6e-5f99-55af-ba3d-52e1a1508410', 'f399d984-b819-53d6-9cf9-fbca2c546de5', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('01fd025b-a94f-50f4-81ef-97b0dedf6c68', 'f399d984-b819-53d6-9cf9-fbca2c546de5', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6ac3f408-bc25-585b-b573-276775c867ef', 'f399d984-b819-53d6-9cf9-fbca2c546de5', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('48c4d92d-6122-5bd6-a061-33bf85bc1d72', 'f399d984-b819-53d6-9cf9-fbca2c546de5', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7fca6005-156c-5116-b58a-c9d3db1e8301', 'f399d984-b819-53d6-9cf9-fbca2c546de5', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('154b6552-007f-576b-93d4-152a2b7d08a9', 'f399d984-b819-53d6-9cf9-fbca2c546de5', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c64b28db-d450-543a-842a-0f7fc6452126', 'f399d984-b819-53d6-9cf9-fbca2c546de5', 8, $md$H$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('74804f7e-1c83-5b26-8818-3263e2565bae', 'f399d984-b819-53d6-9cf9-fbca2c546de5', 9, $md$I$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('27b0f35c-c295-52af-aba0-ea62933c29a7', '863a0906-2bca-5e39-a40d-484da60af959', 2, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 2

Questions 1-5
Questions 1-5
The reading Passage has seven paragraphs
A-I
.
Which paragraph contains the following information?
Write the correct letter
A-I
, in boxes
1-5
on your answer sheet.
1
Difference between bubble burst impacts by tulip and by
high-tech
shares
2
Spread of tulip before 17th century
3
Indication of money offered for rare bulb in 17th century
4
Tulip was treated as money in Holland
5
Comparison made between tulip and other plants

2 ____ Spread of tulip before 17th century$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('33dd72c8-99b0-5b98-ae85-3ddd15ad9ec8', '27b0f35c-c295-52af-aba0-ea62933c29a7', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2026615b-8181-5be5-a2b7-2bba36407e55', '27b0f35c-c295-52af-aba0-ea62933c29a7', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b15f5dc7-77e6-559f-9281-7289a06fc6ca', '27b0f35c-c295-52af-aba0-ea62933c29a7', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f8b4374e-e13f-5269-8156-148d680910d9', '27b0f35c-c295-52af-aba0-ea62933c29a7', 4, $md$D$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3368e4a9-3fa2-5475-9d8c-9b742e1add25', '27b0f35c-c295-52af-aba0-ea62933c29a7', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e8ddc4b8-412d-5846-b041-e1079b7e8ef3', '27b0f35c-c295-52af-aba0-ea62933c29a7', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5c1ca452-30d3-58b2-a332-6b917637783c', '27b0f35c-c295-52af-aba0-ea62933c29a7', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fff6f813-aab7-55d1-bd3b-38ee0c912e14', '27b0f35c-c295-52af-aba0-ea62933c29a7', 8, $md$H$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fd66e696-e5f0-57be-89ab-319a2fae7714', '27b0f35c-c295-52af-aba0-ea62933c29a7', 9, $md$I$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('20e0efdb-f05d-530e-88ec-7cdda352adf2', '863a0906-2bca-5e39-a40d-484da60af959', 3, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 3

Questions 1-5
Questions 1-5
The reading Passage has seven paragraphs
A-I
.
Which paragraph contains the following information?
Write the correct letter
A-I
, in boxes
1-5
on your answer sheet.
1
Difference between bubble burst impacts by tulip and by
high-tech
shares
2
Spread of tulip before 17th century
3
Indication of money offered for rare bulb in 17th century
4
Tulip was treated as money in Holland
5
Comparison made between tulip and other plants

3 ____ Indication of money offered for rare bulb in 17th century$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8a370eca-16f0-532b-bdee-d0b43b7cd2d3', '20e0efdb-f05d-530e-88ec-7cdda352adf2', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fb3bdd7d-56fd-53c1-9696-f10ee42e31b4', '20e0efdb-f05d-530e-88ec-7cdda352adf2', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('49cc5935-229e-56b3-9dd0-34d965d0b8c4', '20e0efdb-f05d-530e-88ec-7cdda352adf2', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f17a110e-a872-5d45-a8e7-22507bfc6d0f', '20e0efdb-f05d-530e-88ec-7cdda352adf2', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('721c208f-87a7-5d68-ae95-53bc152b8437', '20e0efdb-f05d-530e-88ec-7cdda352adf2', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('039c2e15-9a5b-5fe6-ac79-2e0643039d5b', '20e0efdb-f05d-530e-88ec-7cdda352adf2', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('68a61d19-5e8a-54ec-8d66-d5e62bcc71bd', '20e0efdb-f05d-530e-88ec-7cdda352adf2', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cee7e35f-712a-5bf3-b41a-0b688f021095', '20e0efdb-f05d-530e-88ec-7cdda352adf2', 8, $md$H$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1c4eb864-e23a-52ef-8bbb-459ee6705b1d', '20e0efdb-f05d-530e-88ec-7cdda352adf2', 9, $md$I$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('cc0d7b6e-67ab-516d-a28c-fa964ebded3b', '863a0906-2bca-5e39-a40d-484da60af959', 4, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 4

Questions 1-5
Questions 1-5
The reading Passage has seven paragraphs
A-I
.
Which paragraph contains the following information?
Write the correct letter
A-I
, in boxes
1-5
on your answer sheet.
1
Difference between bubble burst impacts by tulip and by
high-tech
shares
2
Spread of tulip before 17th century
3
Indication of money offered for rare bulb in 17th century
4
Tulip was treated as money in Holland
5
Comparison made between tulip and other plants

4 ____ Tulip was treated as money in Holland$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('28c1e3ff-1720-5c07-b5c2-eaf0cc379047', 'cc0d7b6e-67ab-516d-a28c-fa964ebded3b', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4e2182b9-ce6d-5820-a3d6-aa4266e3c41e', 'cc0d7b6e-67ab-516d-a28c-fa964ebded3b', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0ec3968b-80fd-5d1d-86cd-fe4c077ee486', 'cc0d7b6e-67ab-516d-a28c-fa964ebded3b', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e25da0e4-1b9e-5b29-8bf9-72e306033276', 'cc0d7b6e-67ab-516d-a28c-fa964ebded3b', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2d4a17e3-bee5-596f-9548-18a882d2ac7b', 'cc0d7b6e-67ab-516d-a28c-fa964ebded3b', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3b221c69-2a3c-5ca8-99d4-9cd0b2dade65', 'cc0d7b6e-67ab-516d-a28c-fa964ebded3b', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bdbc7ea4-2529-5da1-8399-57fe48b302a2', 'cc0d7b6e-67ab-516d-a28c-fa964ebded3b', 7, $md$G$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5e11997e-8333-50a0-b2c4-530ee85f9e1a', 'cc0d7b6e-67ab-516d-a28c-fa964ebded3b', 8, $md$H$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('82dad153-00bb-585f-8ca7-10319849a997', 'cc0d7b6e-67ab-516d-a28c-fa964ebded3b', 9, $md$I$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('9cbd6a3b-6032-57ca-bc02-35df477fd2fa', '863a0906-2bca-5e39-a40d-484da60af959', 5, 'MATCHING_INFORMATION', 'READING', 3, $md$### Question 5

Questions 1-5
Questions 1-5
The reading Passage has seven paragraphs
A-I
.
Which paragraph contains the following information?
Write the correct letter
A-I
, in boxes
1-5
on your answer sheet.
1
Difference between bubble burst impacts by tulip and by
high-tech
shares
2
Spread of tulip before 17th century
3
Indication of money offered for rare bulb in 17th century
4
Tulip was treated as money in Holland
5
Comparison made between tulip and other plants

5 ____ Comparison made between tulip and other plants$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('da1c8e08-beb2-5ae9-b7cf-3b4192b8c5c7', '9cbd6a3b-6032-57ca-bc02-35df477fd2fa', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5555ff17-0a18-5487-b16f-dc2e56b5253e', '9cbd6a3b-6032-57ca-bc02-35df477fd2fa', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9cfd47f0-b848-5c40-8392-5943a54b1b8a', '9cbd6a3b-6032-57ca-bc02-35df477fd2fa', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d4e73f9e-745c-57a0-b025-e7bfdd866e62', '9cbd6a3b-6032-57ca-bc02-35df477fd2fa', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('035db656-9829-5066-a78f-5c3e535b41f3', '9cbd6a3b-6032-57ca-bc02-35df477fd2fa', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4d443993-9653-59c8-9bc7-05e2354692af', '9cbd6a3b-6032-57ca-bc02-35df477fd2fa', 6, $md$F$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9fa41842-93a3-5850-9bd0-aa6c4bf5c021', '9cbd6a3b-6032-57ca-bc02-35df477fd2fa', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a95d612a-a657-51a3-9621-8c5cdeedbb98', '9cbd6a3b-6032-57ca-bc02-35df477fd2fa', 8, $md$H$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a64eed8c-ea4b-5d02-b393-a6e3b0aab8c4', '9cbd6a3b-6032-57ca-bc02-35df477fd2fa', 9, $md$I$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('f8c541e5-1891-5cfa-a5b6-54edf19e5e44', '863a0906-2bca-5e39-a40d-484da60af959', 6, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 6

Questions 6-10
Questions 6-10
Do the following statements agree with the information given in
Reading Passage
? In boxes
6-10
on your answer sheet, write
TRUE
if the statement is true
FALSE
if the statement is false
NOT GIVEN
if the information is not given in the
passage
6
In 1624, all the tulip collection belonged to a man in Amsterdam.
7
Tulip was first planted in Holland according to this passage.
8
Popularity of Tulip in Holland was much higher than any other countries in 17th century.
9
Holland was the most wealthy country in the world in 17th century.
10
From 1630, Amsterdam Stock Exchange started to regulate Tulips exchange market.

6 ____ In 1624, all the tulip collection belonged to a man in Amsterdam.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4d21ce8e-4677-5c55-8511-11b032c8fcee', 'f8c541e5-1891-5cfa-a5b6-54edf19e5e44', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bc68bcc2-46d7-5ff9-b29c-d5d43b96d1de', 'f8c541e5-1891-5cfa-a5b6-54edf19e5e44', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('30c79b48-13cf-5d55-afcc-c1a17ead0864', 'f8c541e5-1891-5cfa-a5b6-54edf19e5e44', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('d89cc564-627e-5736-8de4-00349974b04a', '863a0906-2bca-5e39-a40d-484da60af959', 7, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 7

Questions 6-10
Questions 6-10
Do the following statements agree with the information given in
Reading Passage
? In boxes
6-10
on your answer sheet, write
TRUE
if the statement is true
FALSE
if the statement is false
NOT GIVEN
if the information is not given in the
passage
6
In 1624, all the tulip collection belonged to a man in Amsterdam.
7
Tulip was first planted in Holland according to this passage.
8
Popularity of Tulip in Holland was much higher than any other countries in 17th century.
9
Holland was the most wealthy country in the world in 17th century.
10
From 1630, Amsterdam Stock Exchange started to regulate Tulips exchange market.

7 ____ Tulip was first planted in Holland according to this passage.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e6f3d8f1-131f-54db-8fae-c06667265901', 'd89cc564-627e-5736-8de4-00349974b04a', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('62dbb252-4d5f-528f-9231-06075b9cf4a9', 'd89cc564-627e-5736-8de4-00349974b04a', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('599a9b3e-5750-56cd-8988-44d2789eb04b', 'd89cc564-627e-5736-8de4-00349974b04a', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('0106577b-8103-59d0-adbd-c6d916e757ba', '863a0906-2bca-5e39-a40d-484da60af959', 8, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 8

Questions 6-10
Questions 6-10
Do the following statements agree with the information given in
Reading Passage
? In boxes
6-10
on your answer sheet, write
TRUE
if the statement is true
FALSE
if the statement is false
NOT GIVEN
if the information is not given in the
passage
6
In 1624, all the tulip collection belonged to a man in Amsterdam.
7
Tulip was first planted in Holland according to this passage.
8
Popularity of Tulip in Holland was much higher than any other countries in 17th century.
9
Holland was the most wealthy country in the world in 17th century.
10
From 1630, Amsterdam Stock Exchange started to regulate Tulips exchange market.

8 ____ Popularity of Tulip in Holland was much higher than any other countries in 17th century.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('740246f8-6f62-53be-8314-efa260148c72', '0106577b-8103-59d0-adbd-c6d916e757ba', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0380f28b-fbb7-5443-b019-be054cec092d', '0106577b-8103-59d0-adbd-c6d916e757ba', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('916ef6a6-96c9-5168-be4e-79188c7aa094', '0106577b-8103-59d0-adbd-c6d916e757ba', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('73e6a15e-e5c9-5647-a599-b9caadd0f8e2', '863a0906-2bca-5e39-a40d-484da60af959', 9, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 9

Questions 6-10
Questions 6-10
Do the following statements agree with the information given in
Reading Passage
? In boxes
6-10
on your answer sheet, write
TRUE
if the statement is true
FALSE
if the statement is false
NOT GIVEN
if the information is not given in the
passage
6
In 1624, all the tulip collection belonged to a man in Amsterdam.
7
Tulip was first planted in Holland according to this passage.
8
Popularity of Tulip in Holland was much higher than any other countries in 17th century.
9
Holland was the most wealthy country in the world in 17th century.
10
From 1630, Amsterdam Stock Exchange started to regulate Tulips exchange market.

9 ____ Holland was the most wealthy country in the world in 17th century.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5a00da6e-afcf-54ed-8563-c3464f18b8dc', '73e6a15e-e5c9-5647-a599-b9caadd0f8e2', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2acbf4a9-5e89-52e6-9597-8536b72f5f9c', '73e6a15e-e5c9-5647-a599-b9caadd0f8e2', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('56efb84c-d8eb-5911-8032-7d1083233de2', '73e6a15e-e5c9-5647-a599-b9caadd0f8e2', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('ed2b2800-7ff0-5618-909e-468820bf85e9', '863a0906-2bca-5e39-a40d-484da60af959', 10, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 10

Questions 6-10
Questions 6-10
Do the following statements agree with the information given in
Reading Passage
? In boxes
6-10
on your answer sheet, write
TRUE
if the statement is true
FALSE
if the statement is false
NOT GIVEN
if the information is not given in the
passage
6
In 1624, all the tulip collection belonged to a man in Amsterdam.
7
Tulip was first planted in Holland according to this passage.
8
Popularity of Tulip in Holland was much higher than any other countries in 17th century.
9
Holland was the most wealthy country in the world in 17th century.
10
From 1630, Amsterdam Stock Exchange started to regulate Tulips exchange market.

10 ____ From 1630, Amsterdam Stock Exchange started to regulate Tulips exchange market.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8c2c2a20-9ba7-5d33-9f45-b93ee9e3b96b', 'ed2b2800-7ff0-5618-909e-468820bf85e9', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('517c4117-95e5-5f6a-999a-2aff0abb2031', 'ed2b2800-7ff0-5618-909e-468820bf85e9', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9697e28c-61b1-524c-9d33-21db73b9287f', 'ed2b2800-7ff0-5618-909e-468820bf85e9', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('99ecd6ac-725a-52a5-8b86-4fd022a3e192', '863a0906-2bca-5e39-a40d-484da60af959', 11, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 11

Questions 11-14
Questions 11-14
Summary
Complete the following summary of the paragraphs of Reading Passage, using no more than two words from the Reading Passage for each answer.
Write your answers in boxes
11-14
on your answer sheet.
Dutch concentrated on gaining independence by
11
against Spain in the early 17th century; consequently spare resources entered the area of
12
. Prosperous traders demonstrated their status by building great
13
and with gardens in surroundings. Attracted by the success of profit on tulip, traders kept looking for
14
and speculator for sale.

Dutch concentrated on gaining independence by 11 ____ against Spain in the early 17th century; consequently spare resources entered the area of 12 ____ . Prosperous traders demonstrated their status by building great 13 ____ and with gardens in surroundings. Attracted by the success of profit on tulip, traders kept looking for 14 ____ and speculator for sale.$md$, NULL, ARRAY['.*fighting.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('8895373d-9bfd-55e4-a9db-84ce0975a302', '863a0906-2bca-5e39-a40d-484da60af959', 12, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 12

Questions 11-14
Questions 11-14
Summary
Complete the following summary of the paragraphs of Reading Passage, using no more than two words from the Reading Passage for each answer.
Write your answers in boxes
11-14
on your answer sheet.
Dutch concentrated on gaining independence by
11
against Spain in the early 17th century; consequently spare resources entered the area of
12
. Prosperous traders demonstrated their status by building great
13
and with gardens in surroundings. Attracted by the success of profit on tulip, traders kept looking for
14
and speculator for sale.

Dutch concentrated on gaining independence by 11 ____ against Spain in the early 17th century; consequently spare resources entered the area of 12 ____ . Prosperous traders demonstrated their status by building great 13 ____ and with gardens in surroundings. Attracted by the success of profit on tulip, traders kept looking for 14 ____ and speculator for sale.$md$, NULL, ARRAY['.*fighting.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('7d86de83-b432-5b6d-83d6-5de7c47b6317', '863a0906-2bca-5e39-a40d-484da60af959', 13, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 13

Questions 11-14
Questions 11-14
Summary
Complete the following summary of the paragraphs of Reading Passage, using no more than two words from the Reading Passage for each answer.
Write your answers in boxes
11-14
on your answer sheet.
Dutch concentrated on gaining independence by
11
against Spain in the early 17th century; consequently spare resources entered the area of
12
. Prosperous traders demonstrated their status by building great
13
and with gardens in surroundings. Attracted by the success of profit on tulip, traders kept looking for
14
and speculator for sale.

Dutch concentrated on gaining independence by 11 ____ against Spain in the early 17th century; consequently spare resources entered the area of 12 ____ . Prosperous traders demonstrated their status by building great 13 ____ and with gardens in surroundings. Attracted by the success of profit on tulip, traders kept looking for 14 ____ and speculator for sale.$md$, NULL, ARRAY['.*fighting.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('2ba2c952-48af-5d81-a754-9e6ba1f89cce', '863a0906-2bca-5e39-a40d-484da60af959', 14, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 14

Questions 11-14
Questions 11-14
Summary
Complete the following summary of the paragraphs of Reading Passage, using no more than two words from the Reading Passage for each answer.
Write your answers in boxes
11-14
on your answer sheet.
Dutch concentrated on gaining independence by
11
against Spain in the early 17th century; consequently spare resources entered the area of
12
. Prosperous traders demonstrated their status by building great
13
and with gardens in surroundings. Attracted by the success of profit on tulip, traders kept looking for
14
and speculator for sale.

Dutch concentrated on gaining independence by 11 ____ against Spain in the early 17th century; consequently spare resources entered the area of 12 ____ . Prosperous traders demonstrated their status by building great 13 ____ and with gardens in surroundings. Attracted by the success of profit on tulip, traders kept looking for 14 ____ and speculator for sale.$md$, NULL, ARRAY['.*fighting.*']);

COMMIT;
