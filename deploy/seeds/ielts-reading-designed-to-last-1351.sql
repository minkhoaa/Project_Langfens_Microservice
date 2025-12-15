BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-designed-to-last-1351'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-designed-to-last-1351';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-designed-to-last-1351';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-designed-to-last-1351';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('1eee18ba-0c34-59bf-b9ea-a08ecd5720de', 'ielts-reading-designed-to-last-1351', $t$Designed to Last$t$, $md$## Designed to Last

Nguồn:
- Test: https://mini-ielts.com/1351/reading/designed-to-last
- Solution: https://mini-ielts.com/1351/view-solution/reading/designed-to-last$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('7b788b11-0177-5a9c-9a96-4914507c5522', '1eee18ba-0c34-59bf-b9ea-a08ecd5720de', 1, $t$Reading — Designed to Last$t$, $md$Read the passage and answer questions **1–13**.

### Passage: Designed to Last

Could better design cure our throwaway culture?

A. Jonathan Chapman, a senior lecturer at the University of Brighton, UK, is one of a new breed of “sustainable designers’. Like many of us, they are concerned about the huge waste associated with Western consumer culture and the damage this does to the environment. Some, like Chapman, aim to create objects we will want to keep rather than discard. Others are working to create more efficient or durable consumer goods or goods designed with recycling in mind. The waste entailed in our fleeting relationships with consumer durables is colossal

B. Domestic power tools, such as electric drills, are a typical example of such waste. However much DIY the purchaser plans to do, the truth is that these things are thrown away having been used, on average, for just ten minutes. Most will serve conscience time, gathering dust on a shelf in the garage; people are reluctant to admit that they have wasted their money. However, the end is inevitable for thousands of years in landfill waste sites. In its design, manufacture, packaging, transportation, and disposal, a power tool consumes many times its own weight in resources, all for a shorter active lifespan than that of the average small insect.

C. To understand why we have become so wasteful, we should look to the underlying motivation of consumers. ‘People own things to give expression to who they are and to show what group of people they feel they belong to’ Chapman says. In a world of mass production, however, that symbolism has lost much of its potency. For most of human history, people had an intimate relationship with objects they used or treasured. Often they made the objects themselves, or family members passed them on. For more specialist objects, people relied on expert manufacturers living close by, whom they probably knew personally. Chapman points out that all these factors gave objects a history – a narrative – and an emotional connection that today’s mass production cannot match. Without these personal connections, consumerist culture instead of idolizes novelty. We know we can’t buy happiness, but the chance to remake ourselves with glossy , box-fresh products seems irresistible. When the novelty fades we simply renew the excitement by buying more new stuff: what John Thackara of Doors of Perception, a network for sharing ideas about the future of design, calls the “schlock of the new”.

D. As a sustainable designer, Chapman’s solution is what he calls “emotionally durable design”. Think about your favourite old jeans. They just don’t have the right feel until they have been worn and washed a hundred times, do they? It is like they are sharing your life story. You can fake that look, but it isn’t the same. Chapman says the gradual unfolding of a relationship like this transforms our interactions with objects into something richer than simple utility. Swiss industrial analyst Walter Stahel, visiting professor at the University of Surrey, calls it the “teddy-bear factor”. No matter how ragged and worn a favourite teddy becomes, we don’t rush out and buy another one. As adults, our teddy bear connects us to our childhoods, and this protects it from obsolescence Stahel says this is what sustainable design needs to do.

E. It is not simply about making durable items that people want to keep. Sustainable design is a matter of properly costing the whole process of production, energy use, and disposal. “It is about the design of systems, the design of culture,” says Tim Cooper from the Centre for Sustainable Consumption at Sheffield Hallam University in Britain. He thinks sustainable design has been “surprisingly slow to take off” but says looming environmental crises and resource depletion are pushing it to the top of the agenda.

F. Thackara agrees. For him, the roots of impending environmental collapse can be summarized in two words: weight and speed. We are making more stuff than the planet can sustain and using vast amounts of energy moving more and more of it around ever faster. The Information Age was supposed to lighten our economies and reduce our impact on the environment, but the reverse seems to be happening. We have simply added information technology to the industrial era and hastened the developed world’s metabolism, Thackara argues.

G. Once you grasp that, the cure is hardly rocket science: minimize waste and energy use, stop moving stuff around so much and use people more. EZIO MANZINI, Professor of industrial design at Politecnico di Milano University, Italy, describes the process of moving to a post-throwaway society as “changing the engine of an aircraft in mid-flight’ Even so, he believes it can be done, and he is not alone.

H. Manzini says a crucial step would be to redesign our globalized world into what he calls the “multi-local society”. His vision is that every resource, from food to electricity generation, should as far as possible be sourced and distributed locally. These local hubs would then be connected to national and global networks to allow the most efficient use and flow of materials.

I. So what will post-throwaway consumerism look like? For a start, we will increasingly buy sustainably designed products. This might be as simple as installing energy-saving light bulbs, more efficient washing machines, or choosing locally produced groceries with less packaging.

J. We will spend less on material goods and more on services. Instead of buying a second car, for example, we might buy into a car-sharing network. We will also buy less and rent a whole lot more: why own things that you hardly use， especially things that are likely to be updated all the time? Consumer durables will be sold with plans already in place for their disposal. Electronic goods will be designed to be recyclable, with the extra cost added to the retail price as prepayment. As consumers become increasingly concerned about the environment, many big businesses are eagerly adopting sustainable design and brushing up their green credentials to please their customers and stay one step ahead of the competition.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('f021f3ab-8780-5c26-a575-cac8bac05fbe', '7b788b11-0177-5a9c-9a96-4914507c5522', 1, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 1

Questions 1-5
Questions 1-5
Choose the correct letter, A, B, C or D
Write your answers in boxes 1-5 on your answer sheet.
1. What does ‘conscience time’ imply in paragraph 2?
A
People feel guilty when they throw things away easily.
B
The shelf in the garage needs cleaning.
C
The consumers are unaware of the waste problem.
D
The power tool should be placed in the right place after being used
2. Prior to mass production, people own things to show
A
their quality
B
their status
C
their character
D
their history
3. The word ‘narrative’ in paragraph 3 refers to
A
the novelty culture pursued by the customers
B
the motivation of buying new products
C
object stories that relate personally and meaningfully to the owners
D
the image created by the manufacturers
4. Without a personal connection, people buy new stuff for
A
sharing
B
freshness
C
collection
D
family members
5. The writer quotes the old jeans and teddy bear to illustrate that
A
the products are used for simple utility.
B
producers should create more special stuff to attract consumers.
C
Chapman led a poor childhood life.
D
the emotional connections make us to keep the objects for longer.

Choose the correct letter, A, B, C or D Write your answers in boxes 1-5 on your answer sheet.$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('30779581-dd07-5b53-ad73-a17ae9b81e05', '7b788b11-0177-5a9c-9a96-4914507c5522', 2, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 2

Questions 1-5
Questions 1-5
Choose the correct letter, A, B, C or D
Write your answers in boxes 1-5 on your answer sheet.
1. What does ‘conscience time’ imply in paragraph 2?
A
People feel guilty when they throw things away easily.
B
The shelf in the garage needs cleaning.
C
The consumers are unaware of the waste problem.
D
The power tool should be placed in the right place after being used
2. Prior to mass production, people own things to show
A
their quality
B
their status
C
their character
D
their history
3. The word ‘narrative’ in paragraph 3 refers to
A
the novelty culture pursued by the customers
B
the motivation of buying new products
C
object stories that relate personally and meaningfully to the owners
D
the image created by the manufacturers
4. Without a personal connection, people buy new stuff for
A
sharing
B
freshness
C
collection
D
family members
5. The writer quotes the old jeans and teddy bear to illustrate that
A
the products are used for simple utility.
B
producers should create more special stuff to attract consumers.
C
Chapman led a poor childhood life.
D
the emotional connections make us to keep the objects for longer.

Choose the correct letter, A, B, C or D Write your answers in boxes 1-5 on your answer sheet.$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('3589dc62-7151-546c-a04e-58daedde7554', '7b788b11-0177-5a9c-9a96-4914507c5522', 3, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 3

Questions 1-5
Questions 1-5
Choose the correct letter, A, B, C or D
Write your answers in boxes 1-5 on your answer sheet.
1. What does ‘conscience time’ imply in paragraph 2?
A
People feel guilty when they throw things away easily.
B
The shelf in the garage needs cleaning.
C
The consumers are unaware of the waste problem.
D
The power tool should be placed in the right place after being used
2. Prior to mass production, people own things to show
A
their quality
B
their status
C
their character
D
their history
3. The word ‘narrative’ in paragraph 3 refers to
A
the novelty culture pursued by the customers
B
the motivation of buying new products
C
object stories that relate personally and meaningfully to the owners
D
the image created by the manufacturers
4. Without a personal connection, people buy new stuff for
A
sharing
B
freshness
C
collection
D
family members
5. The writer quotes the old jeans and teddy bear to illustrate that
A
the products are used for simple utility.
B
producers should create more special stuff to attract consumers.
C
Chapman led a poor childhood life.
D
the emotional connections make us to keep the objects for longer.

Choose the correct letter, A, B, C or D Write your answers in boxes 1-5 on your answer sheet.$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('c0235afc-a424-5f4e-b154-088287a4afcc', '7b788b11-0177-5a9c-9a96-4914507c5522', 4, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 4

Questions 1-5
Questions 1-5
Choose the correct letter, A, B, C or D
Write your answers in boxes 1-5 on your answer sheet.
1. What does ‘conscience time’ imply in paragraph 2?
A
People feel guilty when they throw things away easily.
B
The shelf in the garage needs cleaning.
C
The consumers are unaware of the waste problem.
D
The power tool should be placed in the right place after being used
2. Prior to mass production, people own things to show
A
their quality
B
their status
C
their character
D
their history
3. The word ‘narrative’ in paragraph 3 refers to
A
the novelty culture pursued by the customers
B
the motivation of buying new products
C
object stories that relate personally and meaningfully to the owners
D
the image created by the manufacturers
4. Without a personal connection, people buy new stuff for
A
sharing
B
freshness
C
collection
D
family members
5. The writer quotes the old jeans and teddy bear to illustrate that
A
the products are used for simple utility.
B
producers should create more special stuff to attract consumers.
C
Chapman led a poor childhood life.
D
the emotional connections make us to keep the objects for longer.

Choose the correct letter, A, B, C or D Write your answers in boxes 1-5 on your answer sheet.$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('3b296031-d3c8-5a1b-98da-e699161f5232', '7b788b11-0177-5a9c-9a96-4914507c5522', 5, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 5

Questions 1-5
Questions 1-5
Choose the correct letter, A, B, C or D
Write your answers in boxes 1-5 on your answer sheet.
1. What does ‘conscience time’ imply in paragraph 2?
A
People feel guilty when they throw things away easily.
B
The shelf in the garage needs cleaning.
C
The consumers are unaware of the waste problem.
D
The power tool should be placed in the right place after being used
2. Prior to mass production, people own things to show
A
their quality
B
their status
C
their character
D
their history
3. The word ‘narrative’ in paragraph 3 refers to
A
the novelty culture pursued by the customers
B
the motivation of buying new products
C
object stories that relate personally and meaningfully to the owners
D
the image created by the manufacturers
4. Without a personal connection, people buy new stuff for
A
sharing
B
freshness
C
collection
D
family members
5. The writer quotes the old jeans and teddy bear to illustrate that
A
the products are used for simple utility.
B
producers should create more special stuff to attract consumers.
C
Chapman led a poor childhood life.
D
the emotional connections make us to keep the objects for longer.

Choose the correct letter, A, B, C or D Write your answers in boxes 1-5 on your answer sheet.$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('2a7edafc-a933-533f-82bf-129e416aa9b4', '7b788b11-0177-5a9c-9a96-4914507c5522', 6, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 6

Questions 6-9
Questions 6-9
Complete the summary using the list of words, A-H, below.
Write the correct letter, A-H, in boxes 6-9 on your answer sheet.
Tim Cooper claims that although sustainable design proceeds
6
the coming problems are pushing the move. In accordance with Tim Cooper, Thackara believes that the origins of the looming environmental crises are weight and
7
. The technology which was assumed to have a positive effect on our society actually accelerates the world’s
8
. To cure this, Manzini proposes a ‘multi-local society’ which means every resource should be located and redeployed
9
.
A properly B energy C locally
D economy E slowly F speed
G quickly H metabolism

Tim Cooper claims that although sustainable design proceeds 6 ____ the coming problems are pushing the move. In accordance with Tim Cooper, Thackara believes that the origins of the looming environmental crises are weight and 7 ____ . The technology which was assumed to have a positive effect on our society actually accelerates the world’s 8 ____ . To cure this, Manzini proposes a ‘multi-local society’ which means every resource should be located and redeployed 9 ____ .$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('257734af-b2b5-54cd-8658-a01d32c9cd9d', '2a7edafc-a933-533f-82bf-129e416aa9b4', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('53ec5c7c-0951-5d11-8396-2d9bc7bf6154', '2a7edafc-a933-533f-82bf-129e416aa9b4', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f9af5263-3915-5d97-9241-c3237dda81bb', '2a7edafc-a933-533f-82bf-129e416aa9b4', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2219552c-6701-56da-8c17-4dbe85e55c41', '2a7edafc-a933-533f-82bf-129e416aa9b4', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('88e98853-0105-50e4-a1de-df983c270f84', '2a7edafc-a933-533f-82bf-129e416aa9b4', 5, $md$E$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1dbe3abc-99c2-5d6a-978a-4e003a48da51', '2a7edafc-a933-533f-82bf-129e416aa9b4', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8860072a-b264-54fe-bd4e-d5c17d94d69c', '2a7edafc-a933-533f-82bf-129e416aa9b4', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f41e5eb1-16b1-54a9-9b3a-8b242f19f814', '2a7edafc-a933-533f-82bf-129e416aa9b4', 8, $md$H$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('c0927974-55fa-55bd-a040-42d2ecd0c7bd', '7b788b11-0177-5a9c-9a96-4914507c5522', 7, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 7

Questions 6-9
Questions 6-9
Complete the summary using the list of words, A-H, below.
Write the correct letter, A-H, in boxes 6-9 on your answer sheet.
Tim Cooper claims that although sustainable design proceeds
6
the coming problems are pushing the move. In accordance with Tim Cooper, Thackara believes that the origins of the looming environmental crises are weight and
7
. The technology which was assumed to have a positive effect on our society actually accelerates the world’s
8
. To cure this, Manzini proposes a ‘multi-local society’ which means every resource should be located and redeployed
9
.
A properly B energy C locally
D economy E slowly F speed
G quickly H metabolism

Tim Cooper claims that although sustainable design proceeds 6 ____ the coming problems are pushing the move. In accordance with Tim Cooper, Thackara believes that the origins of the looming environmental crises are weight and 7 ____ . The technology which was assumed to have a positive effect on our society actually accelerates the world’s 8 ____ . To cure this, Manzini proposes a ‘multi-local society’ which means every resource should be located and redeployed 9 ____ .$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('edede80a-aa65-5186-bda1-055938f0ac46', 'c0927974-55fa-55bd-a040-42d2ecd0c7bd', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b3a6e2ce-f2c2-5d91-ba69-15e79af7f321', 'c0927974-55fa-55bd-a040-42d2ecd0c7bd', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3346eb24-211c-5bbb-be1e-d14299e88b71', 'c0927974-55fa-55bd-a040-42d2ecd0c7bd', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e319a2dc-34ad-504b-8b83-4ad038c6601e', 'c0927974-55fa-55bd-a040-42d2ecd0c7bd', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6fca5b15-f74d-534a-84a0-28b52a983451', 'c0927974-55fa-55bd-a040-42d2ecd0c7bd', 5, $md$E$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('84260f00-3e30-5eac-b9f8-067ecfe69f3f', 'c0927974-55fa-55bd-a040-42d2ecd0c7bd', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f86b0d2c-a12d-5464-aff5-a17c43f9a9f6', 'c0927974-55fa-55bd-a040-42d2ecd0c7bd', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fb117292-f3c8-5719-adbe-292937857632', 'c0927974-55fa-55bd-a040-42d2ecd0c7bd', 8, $md$H$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('251e0f6a-9be1-5216-a971-7d01552e1fab', '7b788b11-0177-5a9c-9a96-4914507c5522', 8, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 8

Questions 6-9
Questions 6-9
Complete the summary using the list of words, A-H, below.
Write the correct letter, A-H, in boxes 6-9 on your answer sheet.
Tim Cooper claims that although sustainable design proceeds
6
the coming problems are pushing the move. In accordance with Tim Cooper, Thackara believes that the origins of the looming environmental crises are weight and
7
. The technology which was assumed to have a positive effect on our society actually accelerates the world’s
8
. To cure this, Manzini proposes a ‘multi-local society’ which means every resource should be located and redeployed
9
.
A properly B energy C locally
D economy E slowly F speed
G quickly H metabolism

Tim Cooper claims that although sustainable design proceeds 6 ____ the coming problems are pushing the move. In accordance with Tim Cooper, Thackara believes that the origins of the looming environmental crises are weight and 7 ____ . The technology which was assumed to have a positive effect on our society actually accelerates the world’s 8 ____ . To cure this, Manzini proposes a ‘multi-local society’ which means every resource should be located and redeployed 9 ____ .$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('63c09e6d-5a6d-53c1-a1d0-14b374c2325b', '251e0f6a-9be1-5216-a971-7d01552e1fab', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e0ec77fa-df24-5ad3-8766-581b8506d6b2', '251e0f6a-9be1-5216-a971-7d01552e1fab', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('98750e8b-5a1c-567f-8ce2-b8edba0aba7e', '251e0f6a-9be1-5216-a971-7d01552e1fab', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1ae892de-7aae-502f-8afb-7ca9d652bda4', '251e0f6a-9be1-5216-a971-7d01552e1fab', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8ee36253-c3b9-5d29-ae65-a09fc49a69e9', '251e0f6a-9be1-5216-a971-7d01552e1fab', 5, $md$E$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('84c8d846-5e3b-5071-ab72-bfe97af3e373', '251e0f6a-9be1-5216-a971-7d01552e1fab', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f7d8b5a5-a68a-53ec-b7bb-f6aa18ef6336', '251e0f6a-9be1-5216-a971-7d01552e1fab', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('07e6b331-171a-53ba-a4b2-58e6b2c60bf9', '251e0f6a-9be1-5216-a971-7d01552e1fab', 8, $md$H$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('59a5b061-011c-520e-8703-ff0f4e6265ed', '7b788b11-0177-5a9c-9a96-4914507c5522', 9, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 9

Questions 6-9
Questions 6-9
Complete the summary using the list of words, A-H, below.
Write the correct letter, A-H, in boxes 6-9 on your answer sheet.
Tim Cooper claims that although sustainable design proceeds
6
the coming problems are pushing the move. In accordance with Tim Cooper, Thackara believes that the origins of the looming environmental crises are weight and
7
. The technology which was assumed to have a positive effect on our society actually accelerates the world’s
8
. To cure this, Manzini proposes a ‘multi-local society’ which means every resource should be located and redeployed
9
.
A properly B energy C locally
D economy E slowly F speed
G quickly H metabolism

Tim Cooper claims that although sustainable design proceeds 6 ____ the coming problems are pushing the move. In accordance with Tim Cooper, Thackara believes that the origins of the looming environmental crises are weight and 7 ____ . The technology which was assumed to have a positive effect on our society actually accelerates the world’s 8 ____ . To cure this, Manzini proposes a ‘multi-local society’ which means every resource should be located and redeployed 9 ____ .$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2a3353c2-f14e-5bbc-8c59-0be04f805426', '59a5b061-011c-520e-8703-ff0f4e6265ed', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8a7cb9f9-864f-5296-9a08-43ae8dff9566', '59a5b061-011c-520e-8703-ff0f4e6265ed', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1dc500d1-7e66-543f-90d8-7db370555f4a', '59a5b061-011c-520e-8703-ff0f4e6265ed', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c0fef374-02e4-548e-b005-a82ada2d622f', '59a5b061-011c-520e-8703-ff0f4e6265ed', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4a54f274-843c-5c1a-b430-bdfeb0e965c5', '59a5b061-011c-520e-8703-ff0f4e6265ed', 5, $md$E$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5da9b046-5538-5709-94c4-c5684cff730e', '59a5b061-011c-520e-8703-ff0f4e6265ed', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d12edf82-1a7e-5df8-b342-861a0ddca826', '59a5b061-011c-520e-8703-ff0f4e6265ed', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0cc0e3f9-f60d-5c6b-9e3f-3d3817f35cac', '59a5b061-011c-520e-8703-ff0f4e6265ed', 8, $md$H$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('83086756-ac1b-5845-b66a-e1eea613a9c4', '7b788b11-0177-5a9c-9a96-4914507c5522', 10, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 10

Questions 10-13
Questions 10-13
Do the following statements agree with the claims of the writer in Reading Passage?
In boxes 10-13 on your answer sheet, write
YES
if the statement is true
NO
if the statement is false
NOT GIVEN
if the information is not given in the passage
10
People often buy things that are seldom used and throw them away.
11
In a post-throwaway society, we will pay extra money after disposing of electronic goods.
12
Some businesses have jumped on the sustainability bandwagon.
13
Company will spend less on repairs in the future.

10 ____ People often buy things that are seldom used and throw them away. 11 ____ In a post-throwaway society, we will pay extra money after disposing of electronic goods. 12 ____ Some businesses have jumped on the sustainability bandwagon. 13 ____ Company will spend less on repairs in the future.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9819b5bd-3eab-53ef-bb33-b4a98084abb3', '83086756-ac1b-5845-b66a-e1eea613a9c4', 1, $md$YES$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4f110c13-62d1-532a-8df4-7de35b60192e', '83086756-ac1b-5845-b66a-e1eea613a9c4', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0a7a1145-2c72-5572-86ea-819386ac399b', '83086756-ac1b-5845-b66a-e1eea613a9c4', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('987ec832-e39f-5fa7-aefb-096709ec799a', '7b788b11-0177-5a9c-9a96-4914507c5522', 11, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 11

Questions 10-13
Questions 10-13
Do the following statements agree with the claims of the writer in Reading Passage?
In boxes 10-13 on your answer sheet, write
YES
if the statement is true
NO
if the statement is false
NOT GIVEN
if the information is not given in the passage
10
People often buy things that are seldom used and throw them away.
11
In a post-throwaway society, we will pay extra money after disposing of electronic goods.
12
Some businesses have jumped on the sustainability bandwagon.
13
Company will spend less on repairs in the future.

10 ____ People often buy things that are seldom used and throw them away. 11 ____ In a post-throwaway society, we will pay extra money after disposing of electronic goods. 12 ____ Some businesses have jumped on the sustainability bandwagon. 13 ____ Company will spend less on repairs in the future.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('548ef20a-88cc-574d-afd3-3897bc41391f', '987ec832-e39f-5fa7-aefb-096709ec799a', 1, $md$YES$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c05dda4b-8180-5c32-9a32-a10c148a38d4', '987ec832-e39f-5fa7-aefb-096709ec799a', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('30b0ec6f-9260-5b40-a302-8f9e9e3127dd', '987ec832-e39f-5fa7-aefb-096709ec799a', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('7df20688-2546-5db6-bc9b-92bba2def495', '7b788b11-0177-5a9c-9a96-4914507c5522', 12, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 12

Questions 10-13
Questions 10-13
Do the following statements agree with the claims of the writer in Reading Passage?
In boxes 10-13 on your answer sheet, write
YES
if the statement is true
NO
if the statement is false
NOT GIVEN
if the information is not given in the passage
10
People often buy things that are seldom used and throw them away.
11
In a post-throwaway society, we will pay extra money after disposing of electronic goods.
12
Some businesses have jumped on the sustainability bandwagon.
13
Company will spend less on repairs in the future.

10 ____ People often buy things that are seldom used and throw them away. 11 ____ In a post-throwaway society, we will pay extra money after disposing of electronic goods. 12 ____ Some businesses have jumped on the sustainability bandwagon. 13 ____ Company will spend less on repairs in the future.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4de00614-abc1-511d-b583-1fdc19b3a12f', '7df20688-2546-5db6-bc9b-92bba2def495', 1, $md$YES$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('31733fcc-d4c7-5987-9c55-ccbc6a0e599a', '7df20688-2546-5db6-bc9b-92bba2def495', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('01c76a69-4996-5748-ae61-6978e281d5d8', '7df20688-2546-5db6-bc9b-92bba2def495', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('1377ee89-f49a-5758-a096-1bb31709ac51', '7b788b11-0177-5a9c-9a96-4914507c5522', 13, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 13

Questions 10-13
Questions 10-13
Do the following statements agree with the claims of the writer in Reading Passage?
In boxes 10-13 on your answer sheet, write
YES
if the statement is true
NO
if the statement is false
NOT GIVEN
if the information is not given in the passage
10
People often buy things that are seldom used and throw them away.
11
In a post-throwaway society, we will pay extra money after disposing of electronic goods.
12
Some businesses have jumped on the sustainability bandwagon.
13
Company will spend less on repairs in the future.

10 ____ People often buy things that are seldom used and throw them away. 11 ____ In a post-throwaway society, we will pay extra money after disposing of electronic goods. 12 ____ Some businesses have jumped on the sustainability bandwagon. 13 ____ Company will spend less on repairs in the future.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cd3cc636-c816-5044-bc7b-374ffd46441c', '1377ee89-f49a-5758-a096-1bb31709ac51', 1, $md$YES$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cd896df7-b81d-55b6-a04d-de8958fca0c7', '1377ee89-f49a-5758-a096-1bb31709ac51', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('50abf2c8-be70-52cc-ae0d-7a3f783d6536', '1377ee89-f49a-5758-a096-1bb31709ac51', 3, $md$NOT GIVEN$md$, false);

COMMIT;
