BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-the-farmers-parade-of-history-1402'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-the-farmers-parade-of-history-1402';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-the-farmers-parade-of-history-1402';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-the-farmers-parade-of-history-1402';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('9d4bb034-7048-5452-9d55-35fdaddac5ca', 'ielts-reading-the-farmers-parade-of-history-1402', $t$The Farmers! Parade of history$t$, $md$## The Farmers! Parade of history

Nguồn:
- Test: https://mini-ielts.com/1402/reading/the-farmers-parade-of-history
- Solution: https://mini-ielts.com/1402/view-solution/reading/the-farmers-parade-of-history$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('694fc889-f878-5cfe-a6ac-5b85bb8a498c', '9d4bb034-7048-5452-9d55-35fdaddac5ca', 1, $t$Reading — The Farmers! Parade of history$t$, $md$Read the passage and answer questions **1–13**.

### Passage: The Farmers! Parade of history

A

History of Fanner trading company: In 1909 Robert Laidlaw establishes mail-order company Laidlaw Leeds in Fort Street, Auckland. Then, Branch expansion: purchase of Green and Colebrook chain store; further provincial stores in Auckland and Waikato to follow. Opening of first furniture and boot factory. In 1920, Company now has 29 branches; Whangarei store purchased. Doors open at Hobson Street for direct selling to public. The firm establishes London and New York buying offices. With permission from the Harbour Board, the large FARMERS electric sign on the Wyndham Street frontage is erected.

B

In 1935, if the merchandise has changed, the language of the catalogues hasn’t Robert Laidlaw, the Scottish immigrant who established die century-old business, might have been scripting a modern-day television commercial when he told his earliest customers: Satisfaction, or your money back. “It was the first money back guarantee ever offered in New Zealand by any firm,” says Ian Hunter, business historian. “And his mission statement was, potentially, only the second one ever found in the world.” Laidlaw’s stated aims were simple to build the greatest business in New Zealand, to simplify every transaction, to eliminate all delays, to only sell goods it would pay the customer to buy.

C

This year, the company that began as a mail-order business and now employs 3500 staff across 58 stores turns 100. Its centenary will be celebrated with the release of a book and major community fundraising projects, to be announced next week. Hunter, who is writing the centenary history, says “coming to a Fanners store once a week was a part of the New Zealand way of life”. By 1960, one in every 10 people had an account with die company. It was the place where teenage girls shopped for their first bra, where newlyweds purchased their first dinner sets, where first pay cheques were used to pay off hire purchase furniture, where Santa paraded every Christmas.

D

Gary Blumenthal’s mother shopped there, and so does he. The fondest memory for the Rotorua resident? “We were on holiday in Auckland… I decided that upon the lookout tower on top of the Farmers building would be a unique place to fit the ring on my new fiancee’s finger.” The lovebirds, who had to wait for “an annoying youth” to leave the tower before they could enjoy their engagement kiss, celebrate their 50th wedding anniversary in June.

E

Farmers, says Hunter, has always had a heart. This, from a 1993 North & South interview with a former board chairman, Rawdon Busfield: “One day I was in the Hobson Street shop and I saw a woman with two small children. They were clean and tidily dressed, but poor, you could tell. That week we had a special on a big bar of chocolate for one shilling. I heard the woman say to her boy, ‘no, your penny won’t buy that’. He wasn’t wearing shoes. So I went up to the boy said,’ Son, have you got your penny? ‘He handed it to me. It was hot he’d had it in his hand for hours. I took the penny and gave him the chocolate.”

F

Farmers was once the home of genteel tearooms, children’s playgrounds and an annual sale of celebration for birthday of Hector the Parrot (the store mascot died, aged 131, in the 1970s his stuffed remains still occupy pride of place at the company’s head office). You could buy houses from Farmers. Its saddle factory supplied the armed forces, and its upright grand overstrung pianos offered “the acme of value” according to those early catalogues hand-drawn by Robert Laidlaw himself. Walk through a Farmers store today and get hit by bright lights and big brands. Its Albany branch houses 16 international cosmetics companies. It buys from approximately 500 suppliers, and about 30% of those are locally owned.

G

“Eight, 10 years ago,” says current chief executive Rod McDermott, “lots of brands wouldn’t partner with us. The stores were quite distressed. We were first price point focused, we weren’t fashion focused. “Remove the rose-tinted nostalgia, and Farmers is, quite simply, a business, doing business in hard times. Dancing with the Stars presenter Candy Lane launches a clothing line? “We put a trial on, and we thought it was really lovely, but the uptake wasn’t what we thought it would be. It’s got to be what the customer wants,” says McDermott.

H

He acknowledges retailers suffer in a recession: “We’re celebrating 100 years because we can and because we should.” Farmers almost didn’t pull through one economic crisis. By the mid 1980s, it had stores across the country. It had acquired the South Island’s Calder Mackay chain of stores and bought out Haywrights. Then, with sales topping $375 million, it was taken over by Chase Corporation. Lincoln Laidlaw, now aged 88, and the son of the company’s founder, remembers the dark days following the stock market crash and the collapse of Chase. “I think, once, Farmers was like a big family and all of the people who worked for it felt they were building something which would ultimately be to their benefit and to the benefit of New Zealand… then the business was being divided up and so that kind of family situation was dispelled and it hasn’t been recovered.” For a turbulent few years, the stores were controlled, first by a consortium of Australian banks and later Deka, the Maori Development Corporation and Foodland Associated Ltd. In 2003, it went back to “family” ownership, with the purchase by the James Pascoe Group, owned by David and Anne Norman the latter being the great-granddaughter of James Pascoe, whose first business interest was jewellery.

I

“Sheer power of the brand,” says McDermott, “pulled Farmers through and now we’re becoming the brand it used to be again.” Farmers was the company that, during World War n, topped up the wages of any staff member disadvantaged by overseas service. Robert Laidlaw a committed Christian who came to his faith at a 1902 evangelistic service in Dunedin concluded his original mission statement with the words, “all at it, always at it, wins success”. Next week, 58 Farmers stores across the country will announce the local charities they will raise funds for in their centenary celebration everything from guide dog services to hospices to volunteer fire brigades will benefit. Every dollar raised by the community will be matched by the company. “It’s like the rebirth of an icon,” says McDermott.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('2cbe942c-46eb-528b-b17d-b655ba8e7a2d', '694fc889-f878-5cfe-a6ac-5b85bb8a498c', 1, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 1

Questions 1-5
Questions 1-5
The reading Passage has seven paragraphs
A-I
Which paragraph contains the following information?
Write the correct letter
A-I
, in boxes
1-5
on your answer sheet.
1
Generosity offered in an occasion.
2
Innovation of offer made by the head of company.
3
Fashion was not its strong point.
4
A romantic event on the roof of farmers.
5
Farmers were sold to a private owned company.

1 ____ Generosity offered in an occasion.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5a96974a-b091-5d20-8a4e-eb3929d925f9', '2cbe942c-46eb-528b-b17d-b655ba8e7a2d', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c0dbfa68-0f66-5066-9963-c0d15914dfad', '2cbe942c-46eb-528b-b17d-b655ba8e7a2d', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2df1ddaf-69ba-5285-99bd-ad5a29bed1b3', '2cbe942c-46eb-528b-b17d-b655ba8e7a2d', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9ca6bb8e-aa71-57cd-9bf5-b1801b266021', '2cbe942c-46eb-528b-b17d-b655ba8e7a2d', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('42407f85-23d2-5e4f-8d93-637296bb4ea0', '2cbe942c-46eb-528b-b17d-b655ba8e7a2d', 5, $md$E$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('db0f89a4-333e-50cd-be11-65d961eea15e', '2cbe942c-46eb-528b-b17d-b655ba8e7a2d', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('85394d2a-6503-562a-b35b-9f2afc51d81e', '2cbe942c-46eb-528b-b17d-b655ba8e7a2d', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('54ee521a-d637-5546-a4b5-ed7a8473f14e', '2cbe942c-46eb-528b-b17d-b655ba8e7a2d', 8, $md$H$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fbed62fa-f27a-5e27-af26-b371f8ae7981', '2cbe942c-46eb-528b-b17d-b655ba8e7a2d', 9, $md$I$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('79b18547-a400-55de-9bde-dc377c69b3f9', '694fc889-f878-5cfe-a6ac-5b85bb8a498c', 2, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 2

Questions 1-5
Questions 1-5
The reading Passage has seven paragraphs
A-I
Which paragraph contains the following information?
Write the correct letter
A-I
, in boxes
1-5
on your answer sheet.
1
Generosity offered in an occasion.
2
Innovation of offer made by the head of company.
3
Fashion was not its strong point.
4
A romantic event on the roof of farmers.
5
Farmers were sold to a private owned company.

2 ____ Innovation of offer made by the head of company.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ee99e83b-5ed7-5e46-9b4f-d6fe84ffac46', '79b18547-a400-55de-9bde-dc377c69b3f9', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3ef280c3-538e-585c-b0f4-c9fab63b0fc1', '79b18547-a400-55de-9bde-dc377c69b3f9', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('184752a2-631f-5f6b-ac05-960d0df6727f', '79b18547-a400-55de-9bde-dc377c69b3f9', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('827fcdcc-650d-533a-9312-3ef36c15466a', '79b18547-a400-55de-9bde-dc377c69b3f9', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4cceb212-3215-5316-b001-28bf6d8be879', '79b18547-a400-55de-9bde-dc377c69b3f9', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3de76108-64a9-53e3-90a5-5317d76e3d02', '79b18547-a400-55de-9bde-dc377c69b3f9', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('611c5d06-c518-52aa-a4ab-dd399df6cb3e', '79b18547-a400-55de-9bde-dc377c69b3f9', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('acdcc52d-0482-53f1-a9d8-fccc157a22c7', '79b18547-a400-55de-9bde-dc377c69b3f9', 8, $md$H$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5cc328cd-c5e1-53d7-b423-7fe7f7080fc3', '79b18547-a400-55de-9bde-dc377c69b3f9', 9, $md$I$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('5960e3d4-87e4-5a39-84d5-39929a56c934', '694fc889-f878-5cfe-a6ac-5b85bb8a498c', 3, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 3

Questions 1-5
Questions 1-5
The reading Passage has seven paragraphs
A-I
Which paragraph contains the following information?
Write the correct letter
A-I
, in boxes
1-5
on your answer sheet.
1
Generosity offered in an occasion.
2
Innovation of offer made by the head of company.
3
Fashion was not its strong point.
4
A romantic event on the roof of farmers.
5
Farmers were sold to a private owned company.

3 ____ Fashion was not its strong point.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ea1c6ad9-c7f3-58dc-a517-1afc881371b0', '5960e3d4-87e4-5a39-84d5-39929a56c934', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f0e945ac-3309-56e9-b5f3-40e8c4749100', '5960e3d4-87e4-5a39-84d5-39929a56c934', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('46eb0f79-7076-53ac-a5fa-a4c2412fad56', '5960e3d4-87e4-5a39-84d5-39929a56c934', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5bcc46b4-bb94-5dfb-827d-52d525854fa7', '5960e3d4-87e4-5a39-84d5-39929a56c934', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d4a77081-fd42-5659-807a-7cde3b9e77a9', '5960e3d4-87e4-5a39-84d5-39929a56c934', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('59687ef4-fa57-52bb-9232-50e2582bef33', '5960e3d4-87e4-5a39-84d5-39929a56c934', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e9597a20-1110-5506-af53-cb52ed34f50f', '5960e3d4-87e4-5a39-84d5-39929a56c934', 7, $md$G$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f46669ff-fc8f-583c-859d-957e886ae7a9', '5960e3d4-87e4-5a39-84d5-39929a56c934', 8, $md$H$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('21cf26f3-1338-5922-aef6-5421281c1953', '5960e3d4-87e4-5a39-84d5-39929a56c934', 9, $md$I$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('d3da41f2-fa82-581c-844c-fd677f14a900', '694fc889-f878-5cfe-a6ac-5b85bb8a498c', 4, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 4

Questions 1-5
Questions 1-5
The reading Passage has seven paragraphs
A-I
Which paragraph contains the following information?
Write the correct letter
A-I
, in boxes
1-5
on your answer sheet.
1
Generosity offered in an occasion.
2
Innovation of offer made by the head of company.
3
Fashion was not its strong point.
4
A romantic event on the roof of farmers.
5
Farmers were sold to a private owned company.

4 ____ A romantic event on the roof of farmers.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('38154f3f-9919-53d3-954f-cd675a9dd643', 'd3da41f2-fa82-581c-844c-fd677f14a900', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('61dbd47a-9367-5962-a8a2-06594a16d2f2', 'd3da41f2-fa82-581c-844c-fd677f14a900', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7b11ccf3-9e7d-5430-8ab1-50a363f2fbe5', 'd3da41f2-fa82-581c-844c-fd677f14a900', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e7ffce63-a78f-52ee-bf7c-38e7960c94d3', 'd3da41f2-fa82-581c-844c-fd677f14a900', 4, $md$D$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6bc8df94-1a2d-567a-a5e5-182f6dab5765', 'd3da41f2-fa82-581c-844c-fd677f14a900', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4f0022eb-a55d-52b3-936b-5ad8b3350086', 'd3da41f2-fa82-581c-844c-fd677f14a900', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cf3e9c0f-7331-5885-816a-23eb934502f3', 'd3da41f2-fa82-581c-844c-fd677f14a900', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('57f831e8-a0a4-57d8-b2c4-482d270f0f69', 'd3da41f2-fa82-581c-844c-fd677f14a900', 8, $md$H$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d52a9ebc-89f5-5aa1-8494-c4904969b617', 'd3da41f2-fa82-581c-844c-fd677f14a900', 9, $md$I$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('4ccb2969-9d86-54aa-8be3-6fa473930ef8', '694fc889-f878-5cfe-a6ac-5b85bb8a498c', 5, 'MATCHING_INFORMATION', 'READING', 3, $md$### Question 5

Questions 1-5
Questions 1-5
The reading Passage has seven paragraphs
A-I
Which paragraph contains the following information?
Write the correct letter
A-I
, in boxes
1-5
on your answer sheet.
1
Generosity offered in an occasion.
2
Innovation of offer made by the head of company.
3
Fashion was not its strong point.
4
A romantic event on the roof of farmers.
5
Farmers were sold to a private owned company.

5 ____ Farmers were sold to a private owned company.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('61613d5f-8e9a-508d-9b60-f8eae51b5d95', '4ccb2969-9d86-54aa-8be3-6fa473930ef8', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8b6dc73e-7d41-5d13-922c-dbd89ae3934c', '4ccb2969-9d86-54aa-8be3-6fa473930ef8', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('54c1132e-6412-50be-90c4-780701d682ec', '4ccb2969-9d86-54aa-8be3-6fa473930ef8', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c08c7794-6fa0-5184-a7eb-0875f685e7c3', '4ccb2969-9d86-54aa-8be3-6fa473930ef8', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ca602953-e849-5e75-b705-2182e888dc98', '4ccb2969-9d86-54aa-8be3-6fa473930ef8', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1e844d96-6d3d-5924-95da-ab8fd82204b8', '4ccb2969-9d86-54aa-8be3-6fa473930ef8', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('039c2feb-7ac9-5b8c-9f3a-b0102fea896d', '4ccb2969-9d86-54aa-8be3-6fa473930ef8', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('74e1a902-33a0-5f3c-a360-cb94141e6248', '4ccb2969-9d86-54aa-8be3-6fa473930ef8', 8, $md$H$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('763a9a88-f94c-5867-ba10-f89a1c3edbaf', '4ccb2969-9d86-54aa-8be3-6fa473930ef8', 9, $md$I$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('bcf82a71-0df9-56a1-8dd5-a36f130b5d1d', '694fc889-f878-5cfe-a6ac-5b85bb8a498c', 6, 'SUMMARY_COMPLETION', 'READING', 3, $md$### Question 6

Questions 6-10
Questions 6-10
Complete the following summary of the paragraphs of Reading Passage
Using
NO MORE THAN TWO WORDS
from the Reading Passage for each answer.
Write your answers in boxes
6-10
on your answer sheet.
6. Farmers was first founded as a
6
in Auckland by Mr Laidlaw.
7. Farmers developed fast and bought one
7
then.
8. During oversea expansion, Farmers set up
8
in cities such as London.
9. Farmers held a
9
once a year for the well-known parrot.
10. In the opinion of Lincoln Laidlaw, Farmers is like a
10
for employees, not just for themselves but for the whole country.

6. Farmers was first founded as a 6 ____ in Auckland by Mr Laidlaw.$md$, NULL, ARRAY['.*mail.*order.*company.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('bd8a2f4c-9236-57ed-a4ce-90645db99169', '694fc889-f878-5cfe-a6ac-5b85bb8a498c', 7, 'SUMMARY_COMPLETION', 'READING', 3, $md$### Question 7

Questions 6-10
Questions 6-10
Complete the following summary of the paragraphs of Reading Passage
Using
NO MORE THAN TWO WORDS
from the Reading Passage for each answer.
Write your answers in boxes
6-10
on your answer sheet.
6. Farmers was first founded as a
6
in Auckland by Mr Laidlaw.
7. Farmers developed fast and bought one
7
then.
8. During oversea expansion, Farmers set up
8
in cities such as London.
9. Farmers held a
9
once a year for the well-known parrot.
10. In the opinion of Lincoln Laidlaw, Farmers is like a
10
for employees, not just for themselves but for the whole country.

7. Farmers developed fast and bought one 7 ____ then.$md$, NULL, ARRAY['.*chain.*store.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('359ad460-3273-54a1-bde3-e17691c8cd1a', '694fc889-f878-5cfe-a6ac-5b85bb8a498c', 8, 'SUMMARY_COMPLETION', 'READING', 3, $md$### Question 8

Questions 6-10
Questions 6-10
Complete the following summary of the paragraphs of Reading Passage
Using
NO MORE THAN TWO WORDS
from the Reading Passage for each answer.
Write your answers in boxes
6-10
on your answer sheet.
6. Farmers was first founded as a
6
in Auckland by Mr Laidlaw.
7. Farmers developed fast and bought one
7
then.
8. During oversea expansion, Farmers set up
8
in cities such as London.
9. Farmers held a
9
once a year for the well-known parrot.
10. In the opinion of Lincoln Laidlaw, Farmers is like a
10
for employees, not just for themselves but for the whole country.

8. During oversea expansion, Farmers set up 8 ____ in cities such as London.$md$, NULL, ARRAY['.*buying.*offices.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('6754b965-4c40-5c34-b51b-81121ed0af4a', '694fc889-f878-5cfe-a6ac-5b85bb8a498c', 9, 'SUMMARY_COMPLETION', 'READING', 3, $md$### Question 9

Questions 6-10
Questions 6-10
Complete the following summary of the paragraphs of Reading Passage
Using
NO MORE THAN TWO WORDS
from the Reading Passage for each answer.
Write your answers in boxes
6-10
on your answer sheet.
6. Farmers was first founded as a
6
in Auckland by Mr Laidlaw.
7. Farmers developed fast and bought one
7
then.
8. During oversea expansion, Farmers set up
8
in cities such as London.
9. Farmers held a
9
once a year for the well-known parrot.
10. In the opinion of Lincoln Laidlaw, Farmers is like a
10
for employees, not just for themselves but for the whole country.

9. Farmers held a 9 ____ once a year for the well-known parrot.$md$, NULL, ARRAY['.*celebration.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('19ca9659-e480-54cb-998a-a2e3b9a3f0cf', '694fc889-f878-5cfe-a6ac-5b85bb8a498c', 10, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 10

Questions 6-10
Questions 6-10
Complete the following summary of the paragraphs of Reading Passage
Using
NO MORE THAN TWO WORDS
from the Reading Passage for each answer.
Write your answers in boxes
6-10
on your answer sheet.
6. Farmers was first founded as a
6
in Auckland by Mr Laidlaw.
7. Farmers developed fast and bought one
7
then.
8. During oversea expansion, Farmers set up
8
in cities such as London.
9. Farmers held a
9
once a year for the well-known parrot.
10. In the opinion of Lincoln Laidlaw, Farmers is like a
10
for employees, not just for themselves but for the whole country.

10. In the opinion of Lincoln Laidlaw, Farmers is like a 10 ____ for employees, not just for themselves but for the whole country.$md$, NULL, ARRAY['.*big.*family.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('1315f533-423b-5d31-93a7-936f862d44cd', '694fc889-f878-5cfe-a6ac-5b85bb8a498c', 11, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 11

Questions 11-13
Questions 11-13
Use the information in the passage to match the people (listed
A-C
) with opinions or deeds below.
Write the appropriate letters
A-C
in boxes
11-13
on your answer sheet.
NB
You may use any letter more than once
.
A
Lincoln Laidlaw
B
Rod McDermott
C
Ian Hunter
11
Product became worse as wrong aspect focused.
12
An unprecedented statement made by Farmers in New Zealand.
13
Character of the company was changed.

11 ____ Product became worse as wrong aspect focused.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6d9fc700-e2ab-5c82-9e9b-0f64b735a30c', '1315f533-423b-5d31-93a7-936f862d44cd', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0588bd5d-7487-5647-9c4d-58f536d0d2c6', '1315f533-423b-5d31-93a7-936f862d44cd', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f47d6e14-407d-531f-b040-6859c1fb211a', '1315f533-423b-5d31-93a7-936f862d44cd', 3, $md$C$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('e31e89a9-cb6d-5988-80d0-e416dc9ff94b', '694fc889-f878-5cfe-a6ac-5b85bb8a498c', 12, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 12

Questions 11-13
Questions 11-13
Use the information in the passage to match the people (listed
A-C
) with opinions or deeds below.
Write the appropriate letters
A-C
in boxes
11-13
on your answer sheet.
NB
You may use any letter more than once
.
A
Lincoln Laidlaw
B
Rod McDermott
C
Ian Hunter
11
Product became worse as wrong aspect focused.
12
An unprecedented statement made by Farmers in New Zealand.
13
Character of the company was changed.

12 ____ An unprecedented statement made by Farmers in New Zealand.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fa360be9-0921-5f88-8a29-81653e4d563f', 'e31e89a9-cb6d-5988-80d0-e416dc9ff94b', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('dc7498da-194d-5e9c-a0fb-52fd46ef06da', 'e31e89a9-cb6d-5988-80d0-e416dc9ff94b', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('47663396-efc3-5bca-bc4c-1af56f94b113', 'e31e89a9-cb6d-5988-80d0-e416dc9ff94b', 3, $md$C$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('1bde0b8d-fdcc-574b-b221-1d406a6d90b6', '694fc889-f878-5cfe-a6ac-5b85bb8a498c', 13, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 13

Questions 11-13
Questions 11-13
Use the information in the passage to match the people (listed
A-C
) with opinions or deeds below.
Write the appropriate letters
A-C
in boxes
11-13
on your answer sheet.
NB
You may use any letter more than once
.
A
Lincoln Laidlaw
B
Rod McDermott
C
Ian Hunter
11
Product became worse as wrong aspect focused.
12
An unprecedented statement made by Farmers in New Zealand.
13
Character of the company was changed.

13 ____ Character of the company was changed.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('27d9baaa-5a96-5e73-af1c-3096076330f2', '1bde0b8d-fdcc-574b-b221-1d406a6d90b6', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('267287a4-04ce-5119-9aa1-9e7e3dd220b1', '1bde0b8d-fdcc-574b-b221-1d406a6d90b6', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d5ee2ffc-00f6-5dab-9a7a-24838add5fee', '1bde0b8d-fdcc-574b-b221-1d406a6d90b6', 3, $md$C$md$, false);

COMMIT;
