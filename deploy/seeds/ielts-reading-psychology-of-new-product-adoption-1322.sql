BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-psychology-of-new-product-adoption-1322'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-psychology-of-new-product-adoption-1322';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-psychology-of-new-product-adoption-1322';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-psychology-of-new-product-adoption-1322';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('9f2f7be7-6c91-5375-946e-5cdf4bbbf8ca', 'ielts-reading-psychology-of-new-product-adoption-1322', $t$Psychology of new product adoption$t$, $md$## Psychology of new product adoption

Nguồn:
- Test: https://mini-ielts.com/1322/reading/psychology-of-new-product-adoption
- Solution: https://mini-ielts.com/1322/view-solution/reading/psychology-of-new-product-adoption$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('8049add1-03d0-5382-97db-5be002bef80d', '9f2f7be7-6c91-5375-946e-5cdf4bbbf8ca', 1, $t$Reading — Psychology of new product adoption$t$, $md$Read the passage and answer questions **1–13**.

### Passage: Psychology of new product adoption

A

In today’s hypercompetitive marketplace, companies that successfully introduce new products are more likely to flourish than those that don’t. businesses spend billions of dollars making better “mousetraps” only to find consumers roundly rejecting them. Studies show that new products fail at the stunning rate of between 40% and 90%, depending on the category, and the odds haven’t changed much in the past 25 years. In the U.S. packaged goods industry, for instance, companies introduce 30,000 products every year, but 70% to 90% of them don’t stay on store shelves for more than 12 months. Most innovative products – those that create new product categories or revolutionize old ones – are also unsuccessful. According to one study, 47% of first movers have failed, meaning that approximately half the companies that pioneered new product categories later pulled out of those businesses.

B

After the fact, experts and novices alike tend to dismiss unsuccessful innovations as bad ideas that were destined to fail. Why do consumers fail to buy innovative products even when they offer distinct improvements over existing ones? Why do companies invariably have more faith in new products than is warranted? Few would question the objective advantages of many innovations over existing alternatives, but that’s often not enough for them to succeed. To understand why new products fail to live up to companies’ expectations, we must delve into the psychology of behavior change.

C

New products often require consumers to change their behavior. As companies know, those behavior changes entail costs. Consumers costs, such as the activation fees they have to pay when they switch from one cellular service provider to another. They also bear learning costs, such as when they shift from manual to automatic automobile transmissions. People sustain obsolescence costs, too. For example, when they switch from VCRs to DVD players, their videotape collections become useless. All of these are economic switching costs that most companies routinely anticipate.

D

What businesses don’t take into account, however, are the psychological costs associated with behavior change. Many products fail because of a universal, but largely ignored, psychological bias: People irrationally overvalue benefits they currently possess relative to those they don’t. The bias leads consumers to value the advantages of products they own more than the benefits of new ones. It also leads executives to value the benefits of innovations they’ve developed over the advantages of incumbent products.

E

Companies have long assumed that people will adopt new products that deliver more value or utility than existing ones. Thus, businesses need only to develop innovations that are objectively superior to incumbent products, and consumers will have sufficient incentive to purchase them. In the 1960s, communications scholar Everett Rogers called the concept “relative advantage” and identified it as the most critical driver of new-product adoption. This argument assumes that companies make unbiased assessments of innovations and of consumers, likelihood of adopting them. Although compelling, the theory has one major flaw: It fails to capture the psychological biases that affect decision making.

F

In 2002, psychologist Daniel Kahneman won the Nobel Prize in economics for a body of work that explores why and when individuals deviate from rational economic behavior. One of the cornerstones of that research, developed with psychologist Amos Tversky, is how individuals value prospects, or choices, in the marketplace. Kahneman and Tversky showed, and others have confirmed, that human beings’ responses to the alternatives before they have four distinct characteristics.

G

First, people evaluate the attractiveness of an alternative based not on its objective, or actual, value but on its subjective, or perceived value. Second, consumers evaluate new products or investments relative to a reference point, usually the products they already own or consume. Third, people view any improvements relative to this reference point as gains and treat all shortcomings as losses. Fourth, and most important, losses have a far greater impact on people than similarly sized gains, a phenomenon that Kahneman and Tversky called “loss aversion.” For instance, studies show that most people will not accept a bet in which there is a 50% chance of winning $100 and a 50% chance of losing $100. The gains from the wager must outweigh the losses by a factor of between two and three before most people find such a bet attractive. Similarly, a survey of 1,500 customers of Pacific Gas and Electric revealed that consumers demand three to four times more compensation to endure a power outage – and suffer a loss – than they are willing to pay to avoid the problem, a potential gain. As Kahneman and Tversky wrote, “losses loom larger than gains.”

H

Loss aversion leads people to value products that they already possess – those that are part of their endowment – more than those they don’t have. According to behavioral economist Richard Thaler, consumers value what they own, but many have to give up, much more than they value what they don’t own but could obtain. Thaler called that bias the “endowment effect.”

I

In a 1990 paper, Thaler and his colleagues describe a series of experiments they conducted to measure the magnitude of the endowment effect. In one such experiment, they gave coffee mugs to a group of people, the Sellers, and asked at what price point – from 25 cents to $9.25 – the Sellers would be willing to part with those mugs. They asked another group – the Choosers – to whom they didn’t give coffee mugs, to indicate whether they would choose the mug or the money at each price point. In objective terms, all the Sellers and Choosers were in the same situation: They were choosing between a mug and a sum of money. In one trial of this experiment, the Sellers priced the mug at $7.12, on average, but the Choosers were willing to pay only $3.12. In another trial, the Sellers and the Choosers valued the mug at $7.00 and $3.50, respectively. Overall, the Sellers always demanded at least twice as much to give up the mugs as the Choosers would pay to obtain them.

J

Kahneman and Tversky’s research also explains why people tend to stick with what they have even if a better alternative exists. In a 1989 paper, economist Jack Knetsch provided a compelling demonstration of what economists William Samuelson and Richard Zeckhauser called the “status quo bias.” Knetsch asked one group of students to choose between an attractive coffee mug and a large bar of Swiss chocolate. He gave a second group of students the coffee mugs but a short time later allowed each student to exchange his or her mug for a chocolate bar. Finally, Knetsch gave chocolate bars to a third group of students but much later allowed each student to exchange his or her bar for a mug. Of the students given a choice at the outset, 56% chose the mug, and 44% chose the chocolate bar, indicating a near even split in preferences between the two products. Logically, therefore, about half of the students to whom Knetsch gave the coffee mug should have traded for the chocolate bar and vice versa. That didn’t happen. Only 11% of the students who had been given the mugs and 10% of those who had been given the chocolate bars wanted to exchange their products. To approximately 90% of the students, giving up what they already had seemed like a painful loss and shrank their desire to trade.

K

Interestingly, most people seem oblivious to the existence of the behaviors implicit in the endowment effect and the status quo bias. In study after study, when researchers presented people with evidence that they had irrationally overvalued the status quo, they were shocked, skeptical, and more than a bit defensive. These behavioral tendencies are universal, but awareness of them is not.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('9ebbc17a-ebb4-5f63-a89f-0b3da2b2222a', '8049add1-03d0-5382-97db-5be002bef80d', 1, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 1

Questions 1-4
Questions 1-4
Use the information in the passage to match the people (listed
A-C
) with opinions or deeds below.
Write the appropriate letters
A-C
in boxes
1-4
on your answer sheet.
A
Richard Thaler
B
Everett Rogers
C
Kahneman and Tversky
1
stated a theory which bears potential fault in the application
2
decided the consumers’ several behavior features when they face other options
3
generalised that customers value more of their possession they are going to abandon for a purpose than alternative they are going to swap in
4
answered the reason why people don’t replace existing products

1 ____ stated a theory which bears potential fault in the application$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b39911de-25f0-543e-9896-ee839297e6ce', '9ebbc17a-ebb4-5f63-a89f-0b3da2b2222a', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b8ca8304-bed8-51bd-8e69-247b2569a933', '9ebbc17a-ebb4-5f63-a89f-0b3da2b2222a', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a23cecb1-3337-5d22-80ac-eaafd5a8578d', '9ebbc17a-ebb4-5f63-a89f-0b3da2b2222a', 3, $md$C$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('35e6f852-4045-5bb9-863f-53bf573d1ef7', '8049add1-03d0-5382-97db-5be002bef80d', 2, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 2

Questions 1-4
Questions 1-4
Use the information in the passage to match the people (listed
A-C
) with opinions or deeds below.
Write the appropriate letters
A-C
in boxes
1-4
on your answer sheet.
A
Richard Thaler
B
Everett Rogers
C
Kahneman and Tversky
1
stated a theory which bears potential fault in the application
2
decided the consumers’ several behavior features when they face other options
3
generalised that customers value more of their possession they are going to abandon for a purpose than alternative they are going to swap in
4
answered the reason why people don’t replace existing products

2 ____ decided the consumers’ several behavior features when they face other options$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a3b79115-b042-5b99-8155-70fe4b96d841', '35e6f852-4045-5bb9-863f-53bf573d1ef7', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9bf3c666-61d6-57a1-abf3-614fce6f5497', '35e6f852-4045-5bb9-863f-53bf573d1ef7', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d0155918-d450-595b-becf-1039e66ac1ef', '35e6f852-4045-5bb9-863f-53bf573d1ef7', 3, $md$C$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('439eeae9-87f3-5e4f-b36b-449190f04f28', '8049add1-03d0-5382-97db-5be002bef80d', 3, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 3

Questions 1-4
Questions 1-4
Use the information in the passage to match the people (listed
A-C
) with opinions or deeds below.
Write the appropriate letters
A-C
in boxes
1-4
on your answer sheet.
A
Richard Thaler
B
Everett Rogers
C
Kahneman and Tversky
1
stated a theory which bears potential fault in the application
2
decided the consumers’ several behavior features when they face other options
3
generalised that customers value more of their possession they are going to abandon for a purpose than alternative they are going to swap in
4
answered the reason why people don’t replace existing products

3 ____ generalised that customers value more of their possession they are going to abandon for a purpose than alternative they are going to swap in$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('82cb3c7d-bd33-5ada-817d-fa0c3068725a', '439eeae9-87f3-5e4f-b36b-449190f04f28', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('faad1e5e-db49-5648-a912-deaad8f102b3', '439eeae9-87f3-5e4f-b36b-449190f04f28', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('40c828d8-288d-5bfb-8403-357ad60f63ff', '439eeae9-87f3-5e4f-b36b-449190f04f28', 3, $md$C$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('61c6dbaf-5c19-5bcf-bff1-480917cc5d5b', '8049add1-03d0-5382-97db-5be002bef80d', 4, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 4

Questions 1-4
Questions 1-4
Use the information in the passage to match the people (listed
A-C
) with opinions or deeds below.
Write the appropriate letters
A-C
in boxes
1-4
on your answer sheet.
A
Richard Thaler
B
Everett Rogers
C
Kahneman and Tversky
1
stated a theory which bears potential fault in the application
2
decided the consumers’ several behavior features when they face other options
3
generalised that customers value more of their possession they are going to abandon for a purpose than alternative they are going to swap in
4
answered the reason why people don’t replace existing products

4 ____ answered the reason why people don’t replace existing products$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2dbe8ffb-e441-5eb8-be3a-78c34deb062d', '61c6dbaf-5c19-5bcf-bff1-480917cc5d5b', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('32753796-fe1a-52a7-aaed-500f004444c9', '61c6dbaf-5c19-5bcf-bff1-480917cc5d5b', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3cd5f7a4-af03-52e4-bbf8-8e162c7aebd3', '61c6dbaf-5c19-5bcf-bff1-480917cc5d5b', 3, $md$C$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('d0cb22d6-a8bc-53b9-9856-2f7db488ae2b', '8049add1-03d0-5382-97db-5be002bef80d', 5, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 5

Questions 5-9
Questions 5-9
Do the following statements agree with the information given in Reading Passage?
In boxes
5-9
on your answer sheet, write
TRUE
if the statement is true
FALSE
if the statement is false
NOT GIVEN
if the information is not given in the passage
5
The products of innovations which beat existing alternatives can guarantee a successful market share.
6
The fact that most companies recognised the benefits of switching to new products guarantees a successful innovation
7
Gender affects the loss and gain outcome in the real market place.
8
Endowment-effect experiment showed there was a huge gap between the seller’s anticipation and the chooser’s offer.
9
Customers accept the fact peacefully when they are revealed the status quo bias.

5 ____ The products of innovations which beat existing alternatives can guarantee a successful market share.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('090907db-0df8-5df2-8aea-3cef889b1f5b', 'd0cb22d6-a8bc-53b9-9856-2f7db488ae2b', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f59d7c04-ed64-5593-9e65-5fed8eea89c8', 'd0cb22d6-a8bc-53b9-9856-2f7db488ae2b', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('484f4e21-0d33-5fe9-bdbc-7667024c1093', 'd0cb22d6-a8bc-53b9-9856-2f7db488ae2b', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('42c771c8-ee94-5508-8c51-d3d0074a3e6b', '8049add1-03d0-5382-97db-5be002bef80d', 6, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 6

Questions 5-9
Questions 5-9
Do the following statements agree with the information given in Reading Passage?
In boxes
5-9
on your answer sheet, write
TRUE
if the statement is true
FALSE
if the statement is false
NOT GIVEN
if the information is not given in the passage
5
The products of innovations which beat existing alternatives can guarantee a successful market share.
6
The fact that most companies recognised the benefits of switching to new products guarantees a successful innovation
7
Gender affects the loss and gain outcome in the real market place.
8
Endowment-effect experiment showed there was a huge gap between the seller’s anticipation and the chooser’s offer.
9
Customers accept the fact peacefully when they are revealed the status quo bias.

6 ____ The fact that most companies recognised the benefits of switching to new products guarantees a successful innovation$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('46cdff4f-8127-5401-90cc-9764cd932a7f', '42c771c8-ee94-5508-8c51-d3d0074a3e6b', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ada4cac3-ebcb-5d49-8d62-881eb4e3f464', '42c771c8-ee94-5508-8c51-d3d0074a3e6b', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6029ea96-7642-56f2-b7dd-476797f25f69', '42c771c8-ee94-5508-8c51-d3d0074a3e6b', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('1fa8f87d-5cee-5395-b42c-a2563ae731df', '8049add1-03d0-5382-97db-5be002bef80d', 7, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 7

Questions 5-9
Questions 5-9
Do the following statements agree with the information given in Reading Passage?
In boxes
5-9
on your answer sheet, write
TRUE
if the statement is true
FALSE
if the statement is false
NOT GIVEN
if the information is not given in the passage
5
The products of innovations which beat existing alternatives can guarantee a successful market share.
6
The fact that most companies recognised the benefits of switching to new products guarantees a successful innovation
7
Gender affects the loss and gain outcome in the real market place.
8
Endowment-effect experiment showed there was a huge gap between the seller’s anticipation and the chooser’s offer.
9
Customers accept the fact peacefully when they are revealed the status quo bias.

7 ____ Gender affects the loss and gain outcome in the real market place.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d8e8ac5b-83a9-58b7-95e2-4ec23430f611', '1fa8f87d-5cee-5395-b42c-a2563ae731df', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e98a8a0a-3bf6-5668-b0cb-8761b3e86739', '1fa8f87d-5cee-5395-b42c-a2563ae731df', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0d81f1af-c0f2-5bb4-9508-9f2a1fe92ce7', '1fa8f87d-5cee-5395-b42c-a2563ae731df', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('f700bc46-fef6-5bd5-9569-79f3c18cb48e', '8049add1-03d0-5382-97db-5be002bef80d', 8, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 8

Questions 5-9
Questions 5-9
Do the following statements agree with the information given in Reading Passage?
In boxes
5-9
on your answer sheet, write
TRUE
if the statement is true
FALSE
if the statement is false
NOT GIVEN
if the information is not given in the passage
5
The products of innovations which beat existing alternatives can guarantee a successful market share.
6
The fact that most companies recognised the benefits of switching to new products guarantees a successful innovation
7
Gender affects the loss and gain outcome in the real market place.
8
Endowment-effect experiment showed there was a huge gap between the seller’s anticipation and the chooser’s offer.
9
Customers accept the fact peacefully when they are revealed the status quo bias.

8 ____ Endowment-effect experiment showed there was a huge gap between the seller’s anticipation and the chooser’s offer.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3860e6a8-b7f8-5fac-8344-d0b8e40057cc', 'f700bc46-fef6-5bd5-9569-79f3c18cb48e', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8f061f83-def6-5ccb-b3c1-c364d4034909', 'f700bc46-fef6-5bd5-9569-79f3c18cb48e', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f8d7bf49-d15f-569a-bfb9-85f12e668d3e', 'f700bc46-fef6-5bd5-9569-79f3c18cb48e', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('0a306ac0-0252-55d5-80c1-5abc469c2442', '8049add1-03d0-5382-97db-5be002bef80d', 9, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 9

Questions 5-9
Questions 5-9
Do the following statements agree with the information given in Reading Passage?
In boxes
5-9
on your answer sheet, write
TRUE
if the statement is true
FALSE
if the statement is false
NOT GIVEN
if the information is not given in the passage
5
The products of innovations which beat existing alternatives can guarantee a successful market share.
6
The fact that most companies recognised the benefits of switching to new products guarantees a successful innovation
7
Gender affects the loss and gain outcome in the real market place.
8
Endowment-effect experiment showed there was a huge gap between the seller’s anticipation and the chooser’s offer.
9
Customers accept the fact peacefully when they are revealed the status quo bias.

9 ____ Customers accept the fact peacefully when they are revealed the status quo bias.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ce4a3f10-6f88-5aab-9d95-45e4d79b9868', '0a306ac0-0252-55d5-80c1-5abc469c2442', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('18ac3eaf-3a64-537e-b931-5e0b2a87c761', '0a306ac0-0252-55d5-80c1-5abc469c2442', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('db2e0f3e-14c0-5936-afd4-7b6948310ca0', '0a306ac0-0252-55d5-80c1-5abc469c2442', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('9a3f368a-4963-576a-ac36-304355e4aa7e', '8049add1-03d0-5382-97db-5be002bef80d', 10, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 10

Questions 10-13
Questions 10-13
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
10-13
on your answer sheet.
10.
What does
paragraph A
illustrated in the business creative venture?
A
above 70% of products stored in the warehouse
B
only US packaged goods industry affected
C
roughly half of new product business failed
D
new products have a long life span.
11.
What do specialists and freshers tend to think how a product sold well:
A
as more products stored on a shelf
B
being creative and innovative enough
C
having more chain stores
D
learning from a famous company like Webvan
12.
According to this passage, a number of products fail because of the following reason:
A
they ignore the fact that people tend to overvalue the product they own.
B
they are not confident with their products
C
they are familiar with people’s psychology state
D
they forget to mention the advantages of products
13.
What does the experiment of “
status quo bias
” suggest which conducted by Nobel prize winner Kahneman and Tversky:
A
about half of them are willing to change
B
student is always to welcome new items
C
90% of both owners in a neutral position
D
only 10% of chocolate bar owner is willing to swap

Choose the correct letter, A , B , C or D .$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('a2e859b5-015a-5246-a5e0-953a60b96b55', '8049add1-03d0-5382-97db-5be002bef80d', 11, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 11

Questions 10-13
Questions 10-13
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
10-13
on your answer sheet.
10.
What does
paragraph A
illustrated in the business creative venture?
A
above 70% of products stored in the warehouse
B
only US packaged goods industry affected
C
roughly half of new product business failed
D
new products have a long life span.
11.
What do specialists and freshers tend to think how a product sold well:
A
as more products stored on a shelf
B
being creative and innovative enough
C
having more chain stores
D
learning from a famous company like Webvan
12.
According to this passage, a number of products fail because of the following reason:
A
they ignore the fact that people tend to overvalue the product they own.
B
they are not confident with their products
C
they are familiar with people’s psychology state
D
they forget to mention the advantages of products
13.
What does the experiment of “
status quo bias
” suggest which conducted by Nobel prize winner Kahneman and Tversky:
A
about half of them are willing to change
B
student is always to welcome new items
C
90% of both owners in a neutral position
D
only 10% of chocolate bar owner is willing to swap

Choose the correct letter, A , B , C or D .$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('30c7876a-f2c6-5d12-a18d-2fbf35e39bc5', '8049add1-03d0-5382-97db-5be002bef80d', 12, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 12

Questions 10-13
Questions 10-13
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
10-13
on your answer sheet.
10.
What does
paragraph A
illustrated in the business creative venture?
A
above 70% of products stored in the warehouse
B
only US packaged goods industry affected
C
roughly half of new product business failed
D
new products have a long life span.
11.
What do specialists and freshers tend to think how a product sold well:
A
as more products stored on a shelf
B
being creative and innovative enough
C
having more chain stores
D
learning from a famous company like Webvan
12.
According to this passage, a number of products fail because of the following reason:
A
they ignore the fact that people tend to overvalue the product they own.
B
they are not confident with their products
C
they are familiar with people’s psychology state
D
they forget to mention the advantages of products
13.
What does the experiment of “
status quo bias
” suggest which conducted by Nobel prize winner Kahneman and Tversky:
A
about half of them are willing to change
B
student is always to welcome new items
C
90% of both owners in a neutral position
D
only 10% of chocolate bar owner is willing to swap

Choose the correct letter, A , B , C or D .$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('d2cc4f08-ad72-5d2a-9e73-8cf9901e8924', '8049add1-03d0-5382-97db-5be002bef80d', 13, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 13

Questions 10-13
Questions 10-13
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
10-13
on your answer sheet.
10.
What does
paragraph A
illustrated in the business creative venture?
A
above 70% of products stored in the warehouse
B
only US packaged goods industry affected
C
roughly half of new product business failed
D
new products have a long life span.
11.
What do specialists and freshers tend to think how a product sold well:
A
as more products stored on a shelf
B
being creative and innovative enough
C
having more chain stores
D
learning from a famous company like Webvan
12.
According to this passage, a number of products fail because of the following reason:
A
they ignore the fact that people tend to overvalue the product they own.
B
they are not confident with their products
C
they are familiar with people’s psychology state
D
they forget to mention the advantages of products
13.
What does the experiment of “
status quo bias
” suggest which conducted by Nobel prize winner Kahneman and Tversky:
A
about half of them are willing to change
B
student is always to welcome new items
C
90% of both owners in a neutral position
D
only 10% of chocolate bar owner is willing to swap

Choose the correct letter, A , B , C or D .$md$, NULL);

COMMIT;
