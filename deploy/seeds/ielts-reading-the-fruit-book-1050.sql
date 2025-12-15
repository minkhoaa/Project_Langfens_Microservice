BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-the-fruit-book-1050'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-the-fruit-book-1050';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-the-fruit-book-1050';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-the-fruit-book-1050';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('149cacc1-d161-53a7-ae3a-3d24b7f28dcc', 'ielts-reading-the-fruit-book-1050', $t$The Fruit Book$t$, $md$## The Fruit Book

Nguồn:
- Test: https://mini-ielts.com/1050/reading/the-fruit-book
- Solution: https://mini-ielts.com/1050/view-solution/reading/the-fruit-book$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('ac413df9-fb2b-598b-8a9b-55569b6e5b11', '149cacc1-d161-53a7-ae3a-3d24b7f28dcc', 1, $t$Reading — The Fruit Book$t$, $md$Read the passage and answer questions **1–14**.

### Passage: The Fruit Book

It’s not every scientist who writes books for people who can’t read. And how many scientists want their books to look as dog-eared as possible? But Pa­tricia Shanley, an ethnobotanist, wanted to give something back. After the poorest people of the Amazon allowed her to study their land and its ecology, she turned her research findings into a picture book that tells the local people how to get a good return on their trees without succumbing to the lure of a quick buck from a logging company. It has proved a big success.

A The book is called Fruit Trees and Useful Plants in the Lives of Amazonians, but is better known simply as the “fruit book”. The second edition was pro­duced at the request of politicians in western Amazonia. Its blend of hard science and local knowledge on the use and trade of 35 native forest species has been so well received (and well used) that no less a dignitary than Bra­zil’s environment minister, Marina Silva, has written the foreword. “There is nothing else like the Shanley book,” says Adalberto Verrisimo, director of the Institute of People and the Environment of the Amazon. “ It gives sci­ence back to the poor, to the people who really need it .”

B Shanley’s work on the book began a decade ago, with a plea for help from the Rural Workers’ Union of Paragominas, a Brazilian town whose prosperity is based on exploitation of timber . The union realised that logging companies would soon be knocking on the doors of the caboclos, peasant farmers living on the Rio Capim, an Amazon tributary in the Brazilian state of Para. Isol­ated and illiterate, the caboclos would have little concept of the true value of their trees; communities downstream had already sold off large blocks of forest for a pittance. “What they wanted to know was how valuable the forests were,” recalls Shanley, then a researcher in the area for the Massa­chusetts-based Woods Hole Research Centre.

C The Rural Workers’ Union wanted to know whether harvesting wild fruits would make economic sense in the Rio Capim . “There was a lot of interest in trading non-timber forest products (NTFPs),” Shanley says. At the time, environmental groups and green-minded businesses were promoting the idea. This was the view presented in a seminal paper, Valuation of an Ama­zonian Rainforest, published in Nature in 1989. The researchers had calcu­lated that revenues from the sale of fruits could far exceed those from a one- off sale of trees to loggers. “The union was keen to discover whether it made more sense conserving the forest for subsistence use and the possible sale of fruit, game and medicinal plants, than selling trees for timber,” says Shanley. Whether it would work for the caboclos was far from clear.

D Although Shanley had been invited to work in the Rio Capim, some caboclos were suspicious. “When Patricia asked if she could study my forest,” says Joao Fernando Moreira Brito, "my neighbours said she was a foreigner who’d come to rob me of my trees." In the end, Moreira Brito, or Mangueira as he is known, welcomed Shanley and worked on her study. His land, an hour's walk from the Rio Capim, is almost entirely covered with primary forest. A study of this and other tracts of forest selected by the communities enabled Shanley to identify three trees, found throughout the Amazon, whose fruit was much favoured by the caboclos: bacuri (Platonia insignis), uxi (Endop- leura uchi) and piquia (Cayocas villosum). The caboclos used their fruits, extracted oils, and knew what sort of wildlife they attracted. But, in the face of aggressive tactics from the logging companies, they had no measure of the trees' financial worth. The only way to find out, Shanley decided, was to start from scratch with a scientific study. “From a scientific point of view, hardly anything was known about these trees,” she says. But six years of field research yielded a mass of data on their flowering and fruiting behaviour. During 1993 and 1994, 30 families weighed everything they used from the forest - game , fruit , fibre , medicinal plants - and documented its source.

E After three logging sales and a major fire in 1997, the researchers were also able to study the ecosystem's reaction to logging and disturbance. They car­ried out a similar, though less exhaustive, study in 1999, this time with 15 families. The changes were striking. Average annual household consumption of forest fruit had fallen from 89 to 28 kilogrammes between 1993 and 1999. “What we found,” says Shanley, “was that fruit collection could coexist with a certain amount of logging, but after the forest fire it dropped dramatically.” Over the same period, fibre use also dropped from around 20 to 4 kilogrammes. The fire and logging also changed the nature of the caboclo diet . In 1993 most households ate game two or three times a month. By 1999 some were fortunate if they ate game more than two or three times a year.

F The loss of certain species of tree was especially significant. Shanley’s team persuaded local hunters to weigh their catch, noting the trees under which the animals were caught. Over the year, they trapped five species of game averaging 232 kilogrammes under piquia trees. Under copaiba, they caught just two species averaging 63 kilogrammes; and under uxi, four species weighing 38 kilogrammes. At last, the team was getting a handle on which trees were worth keeping, and which could reasonably be sold. “This showed that selling piquia trees to loggers for a few dollars made little sense,” explains Shanley. “Their local value lies in providing a prized fruit, as well as flowers which attract more game than any other species.”

G As a result of these studies, Shanley had to tell the Rural Workers’ Union of Paragominas that the Nature thesis could not be applied wholesale to their community - harvesting NTFPs would not always yield more than timber sales. Fruiting patterns of trees such as uxi were unpredictable , for example. In 1994, one household collected 3,654 uxi fruits; the following year, none at all.

H This is not to say that wild fruit trees were unimportant. On the contrary, argues Shanley, they are critical for subsistence, something that is often ig­nored in much of the current research on NTFPs, which tends to focus on their commercial potential . Geography was another factor preventing the Rio Capim caboclos from establishing a serious trade in wild fruit: villa­gers in remote areas could not compete with communities collecting NTFPs close to urban markets, although they could sell them to passing river boats.

I But Shanley and her colleagues decided to do more than just report their results to the union. Together with two of her research colleagues, Shanley wrote the fruit book. This, the Bible and a publication on medicinal plants co-authored by Shanley and designed for people with minimal literacy skills are about the only books you will see along this stretch of the Rio Capim. The first print ran to only 3,000 copies, but the fruit book has been remarkably influential, and is used by colleges, peasant unions, industries and the cabo­clos themselves. Its success is largely due to the fact that people with poor literacy skills can understand much of the information it contains about the non-timber forest products, thanks to its illustrations, anecdotes, stories and songs . “The book doesn’t tell people what to do,” says Shanley, “but it does provide them with choices.” The caboclos who have used the book now have a much better understanding of which trees to sell to the loggers, and which to protect.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('7ef97480-ac8a-5b43-8039-4b7a60d22652', 'ac413df9-fb2b-598b-8a9b-55569b6e5b11', 1, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 1

Questions 1-6
Questions 1-6
Reading Passage has nine paragraphs
A-I
.
Which paragraph contains the following information?
Write the correct letter
A-I
in boxes
1-6
on your answer sheet.
1
A description of Shanley’s initial data collection
Locate
2
Why a government official also contributes to the book
Locate
3
Reasons why the community asked Shanley to conduct the research
Locate
4
Reference to the starting point of her research
Locate
5
Two factors that alter food consumption patterns
Locate
6
Why the book is successful
Locate

1 ____ A description of Shanley’s initial data collection Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('af14f4f3-39f5-52b4-a1b3-40a1eff21ec1', '7ef97480-ac8a-5b43-8039-4b7a60d22652', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('09587d52-fd52-51b8-9c5c-9f4dfe646a9b', '7ef97480-ac8a-5b43-8039-4b7a60d22652', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('318cdfaa-2356-556e-9d58-d141d4aedc0f', '7ef97480-ac8a-5b43-8039-4b7a60d22652', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f66ea471-fca1-58ec-b08e-4366bbce6977', '7ef97480-ac8a-5b43-8039-4b7a60d22652', 4, $md$D$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9661ce17-0e18-529c-9d39-99c9448aabbc', '7ef97480-ac8a-5b43-8039-4b7a60d22652', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2652fd3b-25bb-51e4-bd2d-4d81552f8310', '7ef97480-ac8a-5b43-8039-4b7a60d22652', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5518a6eb-0f12-52ee-85d3-1c4ee6d699c5', '7ef97480-ac8a-5b43-8039-4b7a60d22652', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c70de9db-bcd9-5e21-8f74-69edb6e77f9c', '7ef97480-ac8a-5b43-8039-4b7a60d22652', 8, $md$H$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0e050410-4f51-5241-a45b-e58be7a57c81', '7ef97480-ac8a-5b43-8039-4b7a60d22652', 9, $md$I$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('b695cb32-d0c6-57a1-8fb8-b38c422e298c', 'ac413df9-fb2b-598b-8a9b-55569b6e5b11', 2, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 2

Questions 1-6
Questions 1-6
Reading Passage has nine paragraphs
A-I
.
Which paragraph contains the following information?
Write the correct letter
A-I
in boxes
1-6
on your answer sheet.
1
A description of Shanley’s initial data collection
Locate
2
Why a government official also contributes to the book
Locate
3
Reasons why the community asked Shanley to conduct the research
Locate
4
Reference to the starting point of her research
Locate
5
Two factors that alter food consumption patterns
Locate
6
Why the book is successful
Locate

2 ____ Why a government official also contributes to the book Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6810db6d-f412-595d-8201-2617d551abfc', 'b695cb32-d0c6-57a1-8fb8-b38c422e298c', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d2db6f85-dcdb-56ab-ac1d-0206820f1f15', 'b695cb32-d0c6-57a1-8fb8-b38c422e298c', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('aa96e55a-5354-5fac-849d-98cc1076420d', 'b695cb32-d0c6-57a1-8fb8-b38c422e298c', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7623c14d-529e-556d-9126-2f9c4954cd83', 'b695cb32-d0c6-57a1-8fb8-b38c422e298c', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6a3101e6-3c76-57ef-8de3-dc5a675a604f', 'b695cb32-d0c6-57a1-8fb8-b38c422e298c', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bde2f3b7-b2be-51c6-8853-2db3084f75f0', 'b695cb32-d0c6-57a1-8fb8-b38c422e298c', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('33c554ee-5e1f-589f-8f92-380d7ebc6fd7', 'b695cb32-d0c6-57a1-8fb8-b38c422e298c', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e184e17a-b330-5c34-9ebf-7911ec335de4', 'b695cb32-d0c6-57a1-8fb8-b38c422e298c', 8, $md$H$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2ede41fb-e8bf-5657-b2a9-93af11449344', 'b695cb32-d0c6-57a1-8fb8-b38c422e298c', 9, $md$I$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('2341eb2f-843c-5d10-85f0-fa2294dc8af8', 'ac413df9-fb2b-598b-8a9b-55569b6e5b11', 3, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 3

Questions 1-6
Questions 1-6
Reading Passage has nine paragraphs
A-I
.
Which paragraph contains the following information?
Write the correct letter
A-I
in boxes
1-6
on your answer sheet.
1
A description of Shanley’s initial data collection
Locate
2
Why a government official also contributes to the book
Locate
3
Reasons why the community asked Shanley to conduct the research
Locate
4
Reference to the starting point of her research
Locate
5
Two factors that alter food consumption patterns
Locate
6
Why the book is successful
Locate

3 ____ Reasons why the community asked Shanley to conduct the research Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a34c38d3-ab5c-5d81-b966-423be0cba528', '2341eb2f-843c-5d10-85f0-fa2294dc8af8', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a8cc66a1-423a-5d90-9441-8b65a84d293e', '2341eb2f-843c-5d10-85f0-fa2294dc8af8', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6f5b35f4-7e3a-510e-9cb3-44532a00d0d6', '2341eb2f-843c-5d10-85f0-fa2294dc8af8', 3, $md$C$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('46f23053-f406-56a0-81e7-03d7a29ababc', '2341eb2f-843c-5d10-85f0-fa2294dc8af8', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6e646ca0-c873-5f12-bcb6-ee3846caf5ee', '2341eb2f-843c-5d10-85f0-fa2294dc8af8', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1dd1267a-e423-572a-a532-2c5a8455c0c9', '2341eb2f-843c-5d10-85f0-fa2294dc8af8', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('dac57812-6ab3-50b8-97d9-a03ebd2f694c', '2341eb2f-843c-5d10-85f0-fa2294dc8af8', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('736532b5-879e-59b9-a261-8f765631393b', '2341eb2f-843c-5d10-85f0-fa2294dc8af8', 8, $md$H$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3d604cb6-6f4d-5380-a752-b3fcada276b6', '2341eb2f-843c-5d10-85f0-fa2294dc8af8', 9, $md$I$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('b4cfee83-7537-5545-a5ca-6339351626c4', 'ac413df9-fb2b-598b-8a9b-55569b6e5b11', 4, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 4

Questions 1-6
Questions 1-6
Reading Passage has nine paragraphs
A-I
.
Which paragraph contains the following information?
Write the correct letter
A-I
in boxes
1-6
on your answer sheet.
1
A description of Shanley’s initial data collection
Locate
2
Why a government official also contributes to the book
Locate
3
Reasons why the community asked Shanley to conduct the research
Locate
4
Reference to the starting point of her research
Locate
5
Two factors that alter food consumption patterns
Locate
6
Why the book is successful
Locate

4 ____ Reference to the starting point of her research Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2d1c52f4-bb90-5b79-8d9d-3f2f9aef012c', 'b4cfee83-7537-5545-a5ca-6339351626c4', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('54d33ea1-d501-5858-b736-e859c51c7185', 'b4cfee83-7537-5545-a5ca-6339351626c4', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cba0abc2-7ef0-596a-a974-54fe87ce4c08', 'b4cfee83-7537-5545-a5ca-6339351626c4', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b96287eb-552f-5e64-ae25-7de1fb601501', 'b4cfee83-7537-5545-a5ca-6339351626c4', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4a6bd1e0-05ea-5a44-a51a-e7b2f4763a1b', 'b4cfee83-7537-5545-a5ca-6339351626c4', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('426abc28-5a80-5b4f-9556-450ef593575c', 'b4cfee83-7537-5545-a5ca-6339351626c4', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4bdfb26d-e750-5861-8a5a-c2fddabb445a', 'b4cfee83-7537-5545-a5ca-6339351626c4', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4a2827ba-d50c-5332-95f3-31bb71d82b09', 'b4cfee83-7537-5545-a5ca-6339351626c4', 8, $md$H$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('77aa0d07-57c1-580e-afa5-5403e0ecdfc8', 'b4cfee83-7537-5545-a5ca-6339351626c4', 9, $md$I$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('e7917689-8115-57fd-b3de-dae5e1b4579c', 'ac413df9-fb2b-598b-8a9b-55569b6e5b11', 5, 'MATCHING_INFORMATION', 'READING', 3, $md$### Question 5

Questions 1-6
Questions 1-6
Reading Passage has nine paragraphs
A-I
.
Which paragraph contains the following information?
Write the correct letter
A-I
in boxes
1-6
on your answer sheet.
1
A description of Shanley’s initial data collection
Locate
2
Why a government official also contributes to the book
Locate
3
Reasons why the community asked Shanley to conduct the research
Locate
4
Reference to the starting point of her research
Locate
5
Two factors that alter food consumption patterns
Locate
6
Why the book is successful
Locate

5 ____ Two factors that alter food consumption patterns Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('043cb3fe-7b85-5e86-a514-c9dfbd2101f3', 'e7917689-8115-57fd-b3de-dae5e1b4579c', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('406488e4-fd23-514f-b0c5-768f24bcaae5', 'e7917689-8115-57fd-b3de-dae5e1b4579c', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e50431e4-e063-5cc6-b254-61d8a23f4019', 'e7917689-8115-57fd-b3de-dae5e1b4579c', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3014f2e2-c5c8-55d1-854f-96cbf6934e3e', 'e7917689-8115-57fd-b3de-dae5e1b4579c', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6b41cd20-ca88-57f6-86f8-3413616bf8e9', 'e7917689-8115-57fd-b3de-dae5e1b4579c', 5, $md$E$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d2ad2b9a-a194-58b4-a03b-62973e430d35', 'e7917689-8115-57fd-b3de-dae5e1b4579c', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1ba0cc2b-e299-58cb-9a0c-467798ef608c', 'e7917689-8115-57fd-b3de-dae5e1b4579c', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ac5d185b-e63b-5deb-b0f8-e75d4b724ca8', 'e7917689-8115-57fd-b3de-dae5e1b4579c', 8, $md$H$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('36b5bdde-5512-5fd3-a8e4-85baf92040f5', 'e7917689-8115-57fd-b3de-dae5e1b4579c', 9, $md$I$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('17ef3b1d-46ec-5b91-b202-bef6b514f8ef', 'ac413df9-fb2b-598b-8a9b-55569b6e5b11', 6, 'MATCHING_INFORMATION', 'READING', 3, $md$### Question 6

Questions 1-6
Questions 1-6
Reading Passage has nine paragraphs
A-I
.
Which paragraph contains the following information?
Write the correct letter
A-I
in boxes
1-6
on your answer sheet.
1
A description of Shanley’s initial data collection
Locate
2
Why a government official also contributes to the book
Locate
3
Reasons why the community asked Shanley to conduct the research
Locate
4
Reference to the starting point of her research
Locate
5
Two factors that alter food consumption patterns
Locate
6
Why the book is successful
Locate

6 ____ Why the book is successful Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ff94e01e-1da1-51ed-a21c-46398b44e892', '17ef3b1d-46ec-5b91-b202-bef6b514f8ef', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c80ee18c-1628-523e-b820-12748ff0b83e', '17ef3b1d-46ec-5b91-b202-bef6b514f8ef', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('abdfb2c8-355b-590a-b180-21f5018bd7c4', '17ef3b1d-46ec-5b91-b202-bef6b514f8ef', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a041f2db-14be-5704-af29-69a5491305e7', '17ef3b1d-46ec-5b91-b202-bef6b514f8ef', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('87148d85-b59e-5588-b1e8-27d69b3b9cfe', '17ef3b1d-46ec-5b91-b202-bef6b514f8ef', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d42641bf-e09f-5c44-8545-c398f7f41659', '17ef3b1d-46ec-5b91-b202-bef6b514f8ef', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('71da78c2-eef4-59e4-bb79-e91af2763f55', '17ef3b1d-46ec-5b91-b202-bef6b514f8ef', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2cd7978f-4f74-54bf-9524-f5b64ff83d04', '17ef3b1d-46ec-5b91-b202-bef6b514f8ef', 8, $md$H$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0c72acdf-eb0c-57c1-af3b-7cbd7833fa0a', '17ef3b1d-46ec-5b91-b202-bef6b514f8ef', 9, $md$I$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('1c0bd33f-456b-5c7a-a2b7-e9b63c5106e4', 'ac413df9-fb2b-598b-8a9b-55569b6e5b11', 7, 'SUMMARY_COMPLETION', 'READING', 3, $md$### Question 7

Questions 7-14
Questions 7-14
Complete the summary below.
Choose
NO MORE THAN THREE WORDS
from the passage for each answer.
Write your answers in boxes
7-14
on your answer sheet.
Forest fire has caused local villagers to consume less:
7
Locate
8
Locate
Game
There is the least amount of game hunted under
9
yield is also
10
Locate
. Thus, it is more reasonable to keep
11
Locate
.
All the trees can also be used for
12
Locate
besides selling them to log­gers. But this is often ignored, because most researches usually focus on the
13
of the trees.
Locate
The purpose of the book:
To give information about
14
Locate

7 ____ Locate$md$, NULL, ARRAY['.*fruit.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('04cc8240-94c4-55b8-b814-5b02f0dcbe75', 'ac413df9-fb2b-598b-8a9b-55569b6e5b11', 8, 'SUMMARY_COMPLETION', 'READING', 3, $md$### Question 8

Questions 7-14
Questions 7-14
Complete the summary below.
Choose
NO MORE THAN THREE WORDS
from the passage for each answer.
Write your answers in boxes
7-14
on your answer sheet.
Forest fire has caused local villagers to consume less:
7
Locate
8
Locate
Game
There is the least amount of game hunted under
9
yield is also
10
Locate
. Thus, it is more reasonable to keep
11
Locate
.
All the trees can also be used for
12
Locate
besides selling them to log­gers. But this is often ignored, because most researches usually focus on the
13
of the trees.
Locate
The purpose of the book:
To give information about
14
Locate

8 ____ Locate$md$, NULL, ARRAY['.*fibre.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('c349e364-c707-5945-8974-37a9d7fed73a', 'ac413df9-fb2b-598b-8a9b-55569b6e5b11', 9, 'SUMMARY_COMPLETION', 'READING', 3, $md$### Question 9

Questions 7-14
Questions 7-14
Complete the summary below.
Choose
NO MORE THAN THREE WORDS
from the passage for each answer.
Write your answers in boxes
7-14
on your answer sheet.
Forest fire has caused local villagers to consume less:
7
Locate
8
Locate
Game
There is the least amount of game hunted under
9
yield is also
10
Locate
. Thus, it is more reasonable to keep
11
Locate
.
All the trees can also be used for
12
Locate
besides selling them to log­gers. But this is often ignored, because most researches usually focus on the
13
of the trees.
Locate
The purpose of the book:
To give information about
14
Locate

There is the least amount of game hunted under 9 ____ yield is also 10 ____ Locate . Thus, it is more reasonable to keep 11 ____ Locate .$md$, NULL, ARRAY['.*uxi.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('11681f24-dde2-5048-af31-d0d10cf9327a', 'ac413df9-fb2b-598b-8a9b-55569b6e5b11', 10, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 10

Questions 7-14
Questions 7-14
Complete the summary below.
Choose
NO MORE THAN THREE WORDS
from the passage for each answer.
Write your answers in boxes
7-14
on your answer sheet.
Forest fire has caused local villagers to consume less:
7
Locate
8
Locate
Game
There is the least amount of game hunted under
9
yield is also
10
Locate
. Thus, it is more reasonable to keep
11
Locate
.
All the trees can also be used for
12
Locate
besides selling them to log­gers. But this is often ignored, because most researches usually focus on the
13
of the trees.
Locate
The purpose of the book:
To give information about
14
Locate

There is the least amount of game hunted under 9 ____ yield is also 10 ____ Locate . Thus, it is more reasonable to keep 11 ____ Locate .$md$, NULL, ARRAY['.*uxi.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('19d3f51c-7a9b-56ad-a782-05086ef4d3d4', 'ac413df9-fb2b-598b-8a9b-55569b6e5b11', 11, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 11

Questions 7-14
Questions 7-14
Complete the summary below.
Choose
NO MORE THAN THREE WORDS
from the passage for each answer.
Write your answers in boxes
7-14
on your answer sheet.
Forest fire has caused local villagers to consume less:
7
Locate
8
Locate
Game
There is the least amount of game hunted under
9
yield is also
10
Locate
. Thus, it is more reasonable to keep
11
Locate
.
All the trees can also be used for
12
Locate
besides selling them to log­gers. But this is often ignored, because most researches usually focus on the
13
of the trees.
Locate
The purpose of the book:
To give information about
14
Locate

There is the least amount of game hunted under 9 ____ yield is also 10 ____ Locate . Thus, it is more reasonable to keep 11 ____ Locate .$md$, NULL, ARRAY['.*uxi.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('7f088b22-081c-55c0-b288-d6bc9a2d98f1', 'ac413df9-fb2b-598b-8a9b-55569b6e5b11', 12, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 12

Questions 7-14
Questions 7-14
Complete the summary below.
Choose
NO MORE THAN THREE WORDS
from the passage for each answer.
Write your answers in boxes
7-14
on your answer sheet.
Forest fire has caused local villagers to consume less:
7
Locate
8
Locate
Game
There is the least amount of game hunted under
9
yield is also
10
Locate
. Thus, it is more reasonable to keep
11
Locate
.
All the trees can also be used for
12
Locate
besides selling them to log­gers. But this is often ignored, because most researches usually focus on the
13
of the trees.
Locate
The purpose of the book:
To give information about
14
Locate

All the trees can also be used for 12 ____ Locate besides selling them to log­gers. But this is often ignored, because most researches usually focus on the 13 ____ of the trees. Locate$md$, NULL, ARRAY['.*subsistence.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('269d2980-8cc8-505b-8a29-267165628f2d', 'ac413df9-fb2b-598b-8a9b-55569b6e5b11', 13, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 13

Questions 7-14
Questions 7-14
Complete the summary below.
Choose
NO MORE THAN THREE WORDS
from the passage for each answer.
Write your answers in boxes
7-14
on your answer sheet.
Forest fire has caused local villagers to consume less:
7
Locate
8
Locate
Game
There is the least amount of game hunted under
9
yield is also
10
Locate
. Thus, it is more reasonable to keep
11
Locate
.
All the trees can also be used for
12
Locate
besides selling them to log­gers. But this is often ignored, because most researches usually focus on the
13
of the trees.
Locate
The purpose of the book:
To give information about
14
Locate

All the trees can also be used for 12 ____ Locate besides selling them to log­gers. But this is often ignored, because most researches usually focus on the 13 ____ of the trees. Locate$md$, NULL, ARRAY['.*subsistence.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('ec6fc92a-0111-50ff-9952-13eff78eafb5', 'ac413df9-fb2b-598b-8a9b-55569b6e5b11', 14, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 14

Questions 7-14
Questions 7-14
Complete the summary below.
Choose
NO MORE THAN THREE WORDS
from the passage for each answer.
Write your answers in boxes
7-14
on your answer sheet.
Forest fire has caused local villagers to consume less:
7
Locate
8
Locate
Game
There is the least amount of game hunted under
9
yield is also
10
Locate
. Thus, it is more reasonable to keep
11
Locate
.
All the trees can also be used for
12
Locate
besides selling them to log­gers. But this is often ignored, because most researches usually focus on the
13
of the trees.
Locate
The purpose of the book:
To give information about
14
Locate

To give information about 14 ____ Locate$md$, NULL, ARRAY['.*ntfps.*']);

COMMIT;
