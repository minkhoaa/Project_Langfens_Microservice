BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-the-sweet-scent-of-success-1069'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-the-sweet-scent-of-success-1069';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-the-sweet-scent-of-success-1069';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-the-sweet-scent-of-success-1069';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('222e09be-932f-50d7-a093-bbc901d1fa13', 'ielts-reading-the-sweet-scent-of-success-1069', $t$The Sweet Scent of Success$t$, $md$## The Sweet Scent of Success

Nguồn:
- Test: https://mini-ielts.com/1069/reading/the-sweet-scent-of-success
- Solution: https://mini-ielts.com/1069/view-solution/reading/the-sweet-scent-of-success$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('3d81b5b8-29a3-5e4d-929f-8b11aa2f49c0', '222e09be-932f-50d7-a093-bbc901d1fa13', 1, $t$Reading — The Sweet Scent of Success$t$, $md$Read the passage and answer questions **1–13**.

### Passage: The Sweet Scent of Success

A Innovation and entrepreneurship, in the right mix, can bring spectacular results and propel a business ahead of the pack. Across a diverse range of commercial successes, from the Hills Hoist clothes line to the Cochlear ear implant, it is hardto generalize beyond saying the creators tapped into something consumers could not wait to get their hands on. However, most ideas never make it to the market. Some ideas that innovators are spruiking to potential investors include new water-saving shower heads, a keyless locking system, ping-pong balls that keep pollution out of rainwater tanks, making teeth grow from stemcells inserted in the gum, and technology to stop LPG tanks from exploding . Grant Kearney , chief executive of the Innovation Xchange, which connects businesses to innovation networks, says he hears of great business ideas that he knows will never get on the market. “Ideas by themselves are absolutely useless,”he says. “ An idea only becomes innovation when it is connected to the right resources and capabilities ".

B One of Australia’s latest innovation successes stems from a lemon-scented bath-room cleaner called Shower Power, the formula for which was concocted in afactory in Yatala, Queensland. In 1995, Tom Quinn and John Heron bought a struggling cleaning products business, OzKleen , for 250,000. It was selling 100 different kinds of cleaning products, mainly in bulk. The business was in bad shape, the cleaning formulas were ineffective and environmentally harsh, and there were few regular clients. Now Shower Power is claimed to be the top-selling bathroom cleaning product in the country. In the past 12 months ,almost four million bottles of OzKleen’s Power products have been sold and the company forecasts 2004 sales of 10 million bottles. The company’s, sales in2003 reached $11 million, with 700k of business being exports. In particular, Shower Power is making big inroads on the British market.

C OzKleen’s turnaround began when Quinn and Heron hired an industrial chemist to revitalize the product line. Market research showed that people werelooking for a better cleaner for the bathroom, universally regarded as the hardest room in the home to clean. The company also wanted to make the product formulas more environmentally friendly One of Tom Quinn’s sons, Peter, aged 24 at the time, began working with the chemist on the formulas, looking at the potential for citrus-based cleaning products. He detested all the chlorine-based cleaning products that dominated the market. “We didn’t want to use chlorine, simple as that,”he says. “It offers bad working conditions and there’s no money in it.”Peter looked at citrus ingredients, such as orange peel, to replace the petroleum by-products in cleaners. He is credited with finding the Shower Power formula . “The head,”he says. The company is the recipe is in a vault somewhere and in my sole owner of the intellectual property.

D To begin with, Shower Power was sold only in commercial quantities but Tom Quinn decided to sell it in 750ml bottles after the constant “raves” from customers at their retail store at , near Brisbane. Customers were travelling long distances to buy supplies. Others began writing to OzKleen to say how good Shower Power was . “We did a dummy label and went to see Woolworths,”Tom Quinn says. The Woolworths buyer took a bottle home and was able to remove a stain from her basin that had been impossible to shift. From that point on, she championed the product and OzKleen had its first super- market order, for a palette of Shower Power worth $3000. “We were over the moon,”says OzKleen’s financial controller, Belinda McDonnell.

E Shower Power was released in Australian supermarkets in 1997 and became the top-selling product in its category within six months. It was all hands on deck cat the factory, labeling and bottling Shower Power to keep up with demand . OzKleen ditched all other products and rebuilt the business around Shower Power. This stage, recalls McDonnell , was very tough. “It was hand-to-mouth, cashflow was very difficult ,”she says. OzKleen had to pay new-line fees to supermarket chains, which also squeezed margins.

F OzKleen’s next big break came when the daughter of a Coles Myer executive 1 used the product while on holidays in Queensland and convinced her father that Shower Power should be in supermarkets . Despite the product success, Peter Quinn says the company was wary of how long the sales would last and hesitated to spend money on upgrading the manufactur­ing process . As a result, he remembers long periods of working round the clock to keep up with orders. Small tanks were still being used, so batches were small and bottles were labelled and filled manually. The privately owned OzKleen relied on cash flow to expand. “The equipment could not keep up with demand,” Peter Quinn says. Eventually a new bottling machine was bought for $50,000 in the hope of streamlining production, but he says: “We got ripped off.” Since then, he has been developing a new auto­mated bottling machine that can control the amount of foam produced in the liquid, so that bottles can be filled more effectively - “I love coming up with new ideas.” The machine is being patented.

G Peter Quinn says OzKleen’s approach to research and development is open slather. “If I need it, I get it. It is about doing something simple that no one else is doing. Most of these things are just sitting in front of people ... it’s just seeing the opportunities.” With a tried and tested product, OzKleen is expanding overseas and developing more Power-brand house­hold products . Tom Quinn, who previously ran a real estate agency, says: “We are competing with the same market all over the world, the cleaning products are sold everywhere .” Shower Power, known as Bath Power in Britain, was launched four years ago with the help of an export develop­ment grant from the Federal Government. “We wanted to do it straight away because we realised we had the same opportunities worldwide.” OzKleen is already number three in the British market, and the next stop is France. The Power range includes cleaning products for carpets, kitchens and pre-wash stain removal. The Quinn and Heron families are still involved. OzKleen has been approached with offers to buy the company, but Tom Quinn says he is happy with things as they are . “We’re having too much fun.”$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('f9bed956-5fca-5163-9a71-ef6aa105c5e1', '3d81b5b8-29a3-5e4d-929f-8b11aa2f49c0', 1, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 1

Questions 1-7
Questions 1-7
Reading Passage has six paragraphs,
A-G
.
Which paragraph contains the following information?
Write the correct letter
A-G
, in boxes
1-7
on your answer sheet.
NB
You may use any letter
more than once
.
1
Description of one family member persuading another of selling cleaning products
Locate
2
An account of the cooperation of all factory staff to cope with sales increase
Locate
3
An account of the creation of the formula of Shower Power
Locate
4
An account of buying the original OzKleen company
Locate
5
Description of Shower Power’s international expansion
Locate
6
The reason of changing the packaging size of Shower Power
Locate
7
An example of some innovative ideas
Locate

1 ____ Description of one family member persuading another of selling cleaning products Locate 2 ____ An account of the cooperation of all factory staff to cope with sales increase Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e4b1de89-4cb3-5f33-9c53-371af0364b55', 'f9bed956-5fca-5163-9a71-ef6aa105c5e1', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fa36dcd5-ac28-5c6a-8ad1-ddc6c36d6dc3', 'f9bed956-5fca-5163-9a71-ef6aa105c5e1', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7994a959-ccf3-59ab-8dd2-9725e75db57c', 'f9bed956-5fca-5163-9a71-ef6aa105c5e1', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7f4f23dc-7b0a-52c1-873e-036caae08ddf', 'f9bed956-5fca-5163-9a71-ef6aa105c5e1', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('50d65d79-b162-5896-8b65-28a83affa1f6', 'f9bed956-5fca-5163-9a71-ef6aa105c5e1', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7c6dfd1a-3c11-56df-b0a0-6354385470ec', 'f9bed956-5fca-5163-9a71-ef6aa105c5e1', 6, $md$F$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d2a46fa5-49ec-5f6c-90ca-43740236ae8e', 'f9bed956-5fca-5163-9a71-ef6aa105c5e1', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('cc9837d3-d859-5d13-8f63-4d56a2aa0ac8', '3d81b5b8-29a3-5e4d-929f-8b11aa2f49c0', 2, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 2

Questions 1-7
Questions 1-7
Reading Passage has six paragraphs,
A-G
.
Which paragraph contains the following information?
Write the correct letter
A-G
, in boxes
1-7
on your answer sheet.
NB
You may use any letter
more than once
.
1
Description of one family member persuading another of selling cleaning products
Locate
2
An account of the cooperation of all factory staff to cope with sales increase
Locate
3
An account of the creation of the formula of Shower Power
Locate
4
An account of buying the original OzKleen company
Locate
5
Description of Shower Power’s international expansion
Locate
6
The reason of changing the packaging size of Shower Power
Locate
7
An example of some innovative ideas
Locate

1 ____ Description of one family member persuading another of selling cleaning products Locate 2 ____ An account of the cooperation of all factory staff to cope with sales increase Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('14387cc6-07af-5dbc-b03a-1f1a9d2fb528', 'cc9837d3-d859-5d13-8f63-4d56a2aa0ac8', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9d8cc304-dd40-5ef5-993b-f30558c9ff32', 'cc9837d3-d859-5d13-8f63-4d56a2aa0ac8', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6a810e2a-24da-5512-90d1-23d2b259246e', 'cc9837d3-d859-5d13-8f63-4d56a2aa0ac8', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('26e53b3c-534a-5e7c-acf4-26ee974bc243', 'cc9837d3-d859-5d13-8f63-4d56a2aa0ac8', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('867900df-96f5-5b71-b016-dfefaf2a7271', 'cc9837d3-d859-5d13-8f63-4d56a2aa0ac8', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7b5676cc-fd17-50d3-9ec9-0fac53ff209b', 'cc9837d3-d859-5d13-8f63-4d56a2aa0ac8', 6, $md$F$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('919f76e7-55a7-5537-b2a0-343b772fb2fd', 'cc9837d3-d859-5d13-8f63-4d56a2aa0ac8', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('aede797e-75d1-5cc2-bde5-a7cad0b0cfea', '3d81b5b8-29a3-5e4d-929f-8b11aa2f49c0', 3, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 3

Questions 1-7
Questions 1-7
Reading Passage has six paragraphs,
A-G
.
Which paragraph contains the following information?
Write the correct letter
A-G
, in boxes
1-7
on your answer sheet.
NB
You may use any letter
more than once
.
1
Description of one family member persuading another of selling cleaning products
Locate
2
An account of the cooperation of all factory staff to cope with sales increase
Locate
3
An account of the creation of the formula of Shower Power
Locate
4
An account of buying the original OzKleen company
Locate
5
Description of Shower Power’s international expansion
Locate
6
The reason of changing the packaging size of Shower Power
Locate
7
An example of some innovative ideas
Locate

3 ____ An account of the creation of the formula of Shower Power Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7e09c998-699f-5b00-a4ce-36ffd818e42d', 'aede797e-75d1-5cc2-bde5-a7cad0b0cfea', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('45f846ab-d8c9-5bc2-9ade-e77732151780', 'aede797e-75d1-5cc2-bde5-a7cad0b0cfea', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('09f69f16-3d2e-5644-8f5a-0682752c66db', 'aede797e-75d1-5cc2-bde5-a7cad0b0cfea', 3, $md$C$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7211e937-a12e-538f-b17c-7b27af62adee', 'aede797e-75d1-5cc2-bde5-a7cad0b0cfea', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('638047d2-b60f-59ae-92ba-cb470324b8ff', 'aede797e-75d1-5cc2-bde5-a7cad0b0cfea', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0711f77a-a411-50a1-9a6f-2cdcf84c3e57', 'aede797e-75d1-5cc2-bde5-a7cad0b0cfea', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('18f412f0-8da0-5e13-9760-a297a6517d85', 'aede797e-75d1-5cc2-bde5-a7cad0b0cfea', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('f8d8b01f-c8b8-5ef8-ad84-518cc245fce5', '3d81b5b8-29a3-5e4d-929f-8b11aa2f49c0', 4, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 4

Questions 1-7
Questions 1-7
Reading Passage has six paragraphs,
A-G
.
Which paragraph contains the following information?
Write the correct letter
A-G
, in boxes
1-7
on your answer sheet.
NB
You may use any letter
more than once
.
1
Description of one family member persuading another of selling cleaning products
Locate
2
An account of the cooperation of all factory staff to cope with sales increase
Locate
3
An account of the creation of the formula of Shower Power
Locate
4
An account of buying the original OzKleen company
Locate
5
Description of Shower Power’s international expansion
Locate
6
The reason of changing the packaging size of Shower Power
Locate
7
An example of some innovative ideas
Locate

4 ____ An account of buying the original OzKleen company Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('06069b72-4830-5db2-916f-6ce8f0904cee', 'f8d8b01f-c8b8-5ef8-ad84-518cc245fce5', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7957d008-6c35-55ee-b86d-49786d2fd41c', 'f8d8b01f-c8b8-5ef8-ad84-518cc245fce5', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ac14075b-35ae-5b8f-b3a1-2e48fb7f1230', 'f8d8b01f-c8b8-5ef8-ad84-518cc245fce5', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2d66ebf5-44db-5640-a6a8-074ce31332dc', 'f8d8b01f-c8b8-5ef8-ad84-518cc245fce5', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('347651bd-7364-5569-8a2f-c6a66071f945', 'f8d8b01f-c8b8-5ef8-ad84-518cc245fce5', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3a24ef62-b75e-5536-bcc5-eefae9244563', 'f8d8b01f-c8b8-5ef8-ad84-518cc245fce5', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('67f7301a-12c9-5ad9-80a1-d1def50605e6', 'f8d8b01f-c8b8-5ef8-ad84-518cc245fce5', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('0699529b-239b-5eea-949f-0f453027670b', '3d81b5b8-29a3-5e4d-929f-8b11aa2f49c0', 5, 'MATCHING_INFORMATION', 'READING', 3, $md$### Question 5

Questions 1-7
Questions 1-7
Reading Passage has six paragraphs,
A-G
.
Which paragraph contains the following information?
Write the correct letter
A-G
, in boxes
1-7
on your answer sheet.
NB
You may use any letter
more than once
.
1
Description of one family member persuading another of selling cleaning products
Locate
2
An account of the cooperation of all factory staff to cope with sales increase
Locate
3
An account of the creation of the formula of Shower Power
Locate
4
An account of buying the original OzKleen company
Locate
5
Description of Shower Power’s international expansion
Locate
6
The reason of changing the packaging size of Shower Power
Locate
7
An example of some innovative ideas
Locate

5 ____ Description of Shower Power’s international expansion Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ce54d362-9952-57b7-bbdd-96fff4a9ea83', '0699529b-239b-5eea-949f-0f453027670b', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('adf9e5d3-827c-5a03-b0de-49a7fb354620', '0699529b-239b-5eea-949f-0f453027670b', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8fd711fb-de98-5740-b38a-b06d4c891dcf', '0699529b-239b-5eea-949f-0f453027670b', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d1da44e7-ce57-5750-9740-3120a1dd7a8e', '0699529b-239b-5eea-949f-0f453027670b', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b87cfb89-0563-55ad-8d77-0072cd2bd631', '0699529b-239b-5eea-949f-0f453027670b', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1eafad27-0a49-58bb-bc7e-a4172429072f', '0699529b-239b-5eea-949f-0f453027670b', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('76c63cd7-c468-5dc5-8950-e46d89310b2f', '0699529b-239b-5eea-949f-0f453027670b', 7, $md$G$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('366cd6a3-ea80-529f-abbf-563a5b42b59c', '3d81b5b8-29a3-5e4d-929f-8b11aa2f49c0', 6, 'MATCHING_INFORMATION', 'READING', 3, $md$### Question 6

Questions 1-7
Questions 1-7
Reading Passage has six paragraphs,
A-G
.
Which paragraph contains the following information?
Write the correct letter
A-G
, in boxes
1-7
on your answer sheet.
NB
You may use any letter
more than once
.
1
Description of one family member persuading another of selling cleaning products
Locate
2
An account of the cooperation of all factory staff to cope with sales increase
Locate
3
An account of the creation of the formula of Shower Power
Locate
4
An account of buying the original OzKleen company
Locate
5
Description of Shower Power’s international expansion
Locate
6
The reason of changing the packaging size of Shower Power
Locate
7
An example of some innovative ideas
Locate

6 ____ The reason of changing the packaging size of Shower Power Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('29c3b261-2041-5247-a19a-0f1488f3fdfd', '366cd6a3-ea80-529f-abbf-563a5b42b59c', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('707d6b3c-96f1-5856-85a5-12eca5c67d61', '366cd6a3-ea80-529f-abbf-563a5b42b59c', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a376f96e-d9ad-55b9-90c5-9d7a6a48557d', '366cd6a3-ea80-529f-abbf-563a5b42b59c', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('61c9b967-1ae1-5bc2-962a-581c9696220a', '366cd6a3-ea80-529f-abbf-563a5b42b59c', 4, $md$D$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9d3de245-ca82-5088-9e7c-8ff2a8714424', '366cd6a3-ea80-529f-abbf-563a5b42b59c', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d5b35afe-33fe-58a7-aa07-1b463c944e90', '366cd6a3-ea80-529f-abbf-563a5b42b59c', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('65e1333a-a259-59fc-a58b-46a13035f73c', '366cd6a3-ea80-529f-abbf-563a5b42b59c', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('4cfa2697-8385-569e-a38d-25624bb2631b', '3d81b5b8-29a3-5e4d-929f-8b11aa2f49c0', 7, 'MATCHING_INFORMATION', 'READING', 3, $md$### Question 7

Questions 1-7
Questions 1-7
Reading Passage has six paragraphs,
A-G
.
Which paragraph contains the following information?
Write the correct letter
A-G
, in boxes
1-7
on your answer sheet.
NB
You may use any letter
more than once
.
1
Description of one family member persuading another of selling cleaning products
Locate
2
An account of the cooperation of all factory staff to cope with sales increase
Locate
3
An account of the creation of the formula of Shower Power
Locate
4
An account of buying the original OzKleen company
Locate
5
Description of Shower Power’s international expansion
Locate
6
The reason of changing the packaging size of Shower Power
Locate
7
An example of some innovative ideas
Locate

7 ____ An example of some innovative ideas Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8a96c668-2d2d-53d7-ae1c-edb07fe6cb02', '4cfa2697-8385-569e-a38d-25624bb2631b', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3efe4a1a-42cf-5716-808e-f8c849a55fd3', '4cfa2697-8385-569e-a38d-25624bb2631b', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a44bd533-6013-5de6-9f7f-245cd4b61efc', '4cfa2697-8385-569e-a38d-25624bb2631b', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fc2405aa-6d4e-5ce3-ac05-8c9f86191f6e', '4cfa2697-8385-569e-a38d-25624bb2631b', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2ff54dc6-863c-5757-b6c0-40ca3029c4b7', '4cfa2697-8385-569e-a38d-25624bb2631b', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('109bd7f1-d135-50ca-b394-b1c7724476c9', '4cfa2697-8385-569e-a38d-25624bb2631b', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e0e2af6b-8df5-51f7-96cd-807386896491', '4cfa2697-8385-569e-a38d-25624bb2631b', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('0253eb85-b2e5-5306-bf79-28d64645cf7b', '3d81b5b8-29a3-5e4d-929f-8b11aa2f49c0', 8, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 8

Questions 8-11
Questions 8-11
Look at the following people and list of statements below.
Match each person with the correct statement.
Write the correct letter
A-E
in boxes
8-11
on your answer sheet.
List of Statement
A
Described his story of selling his product to a chain store
B
Explained there was a shortage of money when sales suddenly increased
C
Believe innovations need support to succeed
D
Believes new products like Shower Power may incur risks
E
Says business won’t succeed with innovations
8
Grant Kearney
Locate
9
Tom Quinn
Locate
10
Peter Quinn
Locate
11
Belinda McDonnell
Locate

8 ____ Grant Kearney Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('63668fcd-04c4-555e-aa3a-6cace9d67338', '0253eb85-b2e5-5306-bf79-28d64645cf7b', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('adff1ed0-a56f-5879-8c0a-9980575613c1', '0253eb85-b2e5-5306-bf79-28d64645cf7b', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e4b1fae8-33ee-5a0c-b55d-b4f2fb3dea80', '0253eb85-b2e5-5306-bf79-28d64645cf7b', 3, $md$C$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('658e296e-d77a-5728-b36a-24f4a2a01c53', '0253eb85-b2e5-5306-bf79-28d64645cf7b', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('404c72be-de9c-5940-bf5d-91b9033fb02c', '0253eb85-b2e5-5306-bf79-28d64645cf7b', 5, $md$E$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('6528dcac-38b4-5c52-8819-8e86f6e9d9ea', '3d81b5b8-29a3-5e4d-929f-8b11aa2f49c0', 9, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 9

Questions 8-11
Questions 8-11
Look at the following people and list of statements below.
Match each person with the correct statement.
Write the correct letter
A-E
in boxes
8-11
on your answer sheet.
List of Statement
A
Described his story of selling his product to a chain store
B
Explained there was a shortage of money when sales suddenly increased
C
Believe innovations need support to succeed
D
Believes new products like Shower Power may incur risks
E
Says business won’t succeed with innovations
8
Grant Kearney
Locate
9
Tom Quinn
Locate
10
Peter Quinn
Locate
11
Belinda McDonnell
Locate

9 ____ Tom Quinn Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b7e835e7-5829-5726-a214-6be692f3fa13', '6528dcac-38b4-5c52-8819-8e86f6e9d9ea', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('23513f31-87e1-55be-8aec-029b44051dc2', '6528dcac-38b4-5c52-8819-8e86f6e9d9ea', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b524cfc1-7bb2-5cca-8cf5-fe54bf491984', '6528dcac-38b4-5c52-8819-8e86f6e9d9ea', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6d1a03c3-472f-577e-9ab7-fd7b560772fb', '6528dcac-38b4-5c52-8819-8e86f6e9d9ea', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1637bf73-a1da-50c5-8822-ad3e6516dd77', '6528dcac-38b4-5c52-8819-8e86f6e9d9ea', 5, $md$E$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('f48746d0-6c0a-5997-a008-3c9dd806ba66', '3d81b5b8-29a3-5e4d-929f-8b11aa2f49c0', 10, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 10

Questions 8-11
Questions 8-11
Look at the following people and list of statements below.
Match each person with the correct statement.
Write the correct letter
A-E
in boxes
8-11
on your answer sheet.
List of Statement
A
Described his story of selling his product to a chain store
B
Explained there was a shortage of money when sales suddenly increased
C
Believe innovations need support to succeed
D
Believes new products like Shower Power may incur risks
E
Says business won’t succeed with innovations
8
Grant Kearney
Locate
9
Tom Quinn
Locate
10
Peter Quinn
Locate
11
Belinda McDonnell
Locate

10 ____ Peter Quinn Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ff9c0792-6308-5fdb-967f-427e892a09d9', 'f48746d0-6c0a-5997-a008-3c9dd806ba66', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('20571232-a8da-5911-b332-fc631d72e8a8', 'f48746d0-6c0a-5997-a008-3c9dd806ba66', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a10c99f0-5cbe-51c9-bee0-0be757f93139', 'f48746d0-6c0a-5997-a008-3c9dd806ba66', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('14741367-32b1-575e-9150-21443be0f597', 'f48746d0-6c0a-5997-a008-3c9dd806ba66', 4, $md$D$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('94e2eb64-7bed-5960-b3d3-7ff005188d1c', 'f48746d0-6c0a-5997-a008-3c9dd806ba66', 5, $md$E$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('28d8f2fb-cb22-5a99-a029-dc17b65e7450', '3d81b5b8-29a3-5e4d-929f-8b11aa2f49c0', 11, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 11

Questions 8-11
Questions 8-11
Look at the following people and list of statements below.
Match each person with the correct statement.
Write the correct letter
A-E
in boxes
8-11
on your answer sheet.
List of Statement
A
Described his story of selling his product to a chain store
B
Explained there was a shortage of money when sales suddenly increased
C
Believe innovations need support to succeed
D
Believes new products like Shower Power may incur risks
E
Says business won’t succeed with innovations
8
Grant Kearney
Locate
9
Tom Quinn
Locate
10
Peter Quinn
Locate
11
Belinda McDonnell
Locate

11 ____ Belinda McDonnell Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9a221228-6fd9-504f-ac1d-fe9f32310ab1', '28d8f2fb-cb22-5a99-a029-dc17b65e7450', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8978a74c-c8d6-57f7-b6e9-84ec8e192b68', '28d8f2fb-cb22-5a99-a029-dc17b65e7450', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('883da780-2acd-5a47-886c-5410cdab0dbe', '28d8f2fb-cb22-5a99-a029-dc17b65e7450', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ea626115-e926-526e-8f36-bce2467186b1', '28d8f2fb-cb22-5a99-a029-dc17b65e7450', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d8040791-eea4-5aa0-8658-27fc6f28e0c5', '28d8f2fb-cb22-5a99-a029-dc17b65e7450', 5, $md$E$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('56ee9776-e5da-5dbf-bbdf-5588307cff55', '3d81b5b8-29a3-5e4d-929f-8b11aa2f49c0', 12, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 12

Questions 12-13
Questions 12-13
Choose the correct letter
A, B, C
or
D
.
Write your answers in boxes
12-13
on your answer sheet.
12.
Tom Quinn changed the bottle size to 750ml to make Shower Power
A
Easier to package.
B
Appealing to individual customers.
C
Popular in foreign markets.
D
Attractive to supermarkets.
Locate
13.
Why did Tom Quinn decide not to sell OzKleen?
A
No one wanted to buy OzKleen.
B
New products were being developed in OzKleen.
C
He couldn’t make an agreement on the price with the buyer.
D
He wanted to keep things unchanged.
Locate

Choose the correct letter A, B, C or D . Write your answers in boxes 12-13 on your answer sheet.$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('cbbdbb55-73bd-5b00-b485-a945faf33ba1', '3d81b5b8-29a3-5e4d-929f-8b11aa2f49c0', 13, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 13

Questions 12-13
Questions 12-13
Choose the correct letter
A, B, C
or
D
.
Write your answers in boxes
12-13
on your answer sheet.
12.
Tom Quinn changed the bottle size to 750ml to make Shower Power
A
Easier to package.
B
Appealing to individual customers.
C
Popular in foreign markets.
D
Attractive to supermarkets.
Locate
13.
Why did Tom Quinn decide not to sell OzKleen?
A
No one wanted to buy OzKleen.
B
New products were being developed in OzKleen.
C
He couldn’t make an agreement on the price with the buyer.
D
He wanted to keep things unchanged.
Locate

Choose the correct letter A, B, C or D . Write your answers in boxes 12-13 on your answer sheet.$md$, NULL);

COMMIT;
