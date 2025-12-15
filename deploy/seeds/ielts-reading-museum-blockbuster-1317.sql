BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-museum-blockbuster-1317'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-museum-blockbuster-1317';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-museum-blockbuster-1317';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-museum-blockbuster-1317';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('6fccddce-437b-5672-88f5-0d6245c7105d', 'ielts-reading-museum-blockbuster-1317', $t$Museum Blockbuster$t$, $md$## Museum Blockbuster

Nguồn:
- Test: https://mini-ielts.com/1317/reading/museum-blockbuster
- Solution: https://mini-ielts.com/1317/view-solution/reading/museum-blockbuster$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('b6adae51-9ea3-52a7-aa47-a780e958cdf6', '6fccddce-437b-5672-88f5-0d6245c7105d', 1, $t$Reading — Museum Blockbuster$t$, $md$Read the passage and answer questions **1–8**.

### Passage: Museum Blockbuster

A

Since the 1980s, the term “blockbuster” has become the fashionable word for the special spectacular museum, art gallery or science centre exhibitions. These exhibitions have the ability to attract large crowds and often large corporate sponsors. Here is one of some existing definitions of a blockbuster: Put by Elsen (1984), a blockbuster is a “… large scale loan exhibition that people who normally don’t go to museums will stand in line for hours to see …” James Rosenfield, writing in Direct Marketing in 1993, has described a successful blockbuster exhibition as a “… triumph of both curatorial and marketing skills …” My own definition for a blockbuster is “a popular, high profile exhibition on display for a limited period, that attracts the general public, who are prepared to both stand in line and pay a fee in order to partake in the exhibition.” What both Elsen and Rosenfield omit in their descriptions of a blockbuster, is that people are prepared to pay a fee to see a blockbuster and that the term blockbuster can just as easily apply to a movie or a museum exhibition.

B

Merely naming an exhibition or movie a blockbuster, however, does not make it a blockbuster. The term can only apply when the item in question has had an overwhelmingly successful response from the public. However, in literature from both the UK and USA the other words that also start to appear in descriptions of a blockbuster are “less scholarly”, “non-elitist” and “popularist”. Detractors argue that blockbusters are designed to appeal to the lowest common denominator, while others extol the virtues of encouraging scholars to cooperate on projects and to provide exhibitions that cater for a broad selection of the community rather than an elite sector.

C

Maintaining and increasing visitor levels is paramount in the new museology. This requires continued product development. Not only the creation or hiring of blockbuster exhibitions but regular exhibition changes and innovations. In addition, the visiting public has become customers rather than visitors, and the skills that are valued in museums, science centres and galleries to keep the new customers coming through the door have changed. High on the list of requirements are commercial, business, marketing and entrepreneurial skills. Curators are now administrators. Being a director of an art gallery no longer requires an Arts Degree. As succinctly summarised in the Economist in 1994 “business nous and public relation skills” were essential requirements for a director, and the ability to compete with other museums to stage travelling exhibitions which draw huge crowds.

D

The new museology has resulted in the convergence of museums, the heritage industry, and tourism, profit-making and pleasure-giving. This has given rise to much debate about the appropriateness of adopting the activities of institutions so that they more closely reflect the priorities of the market place and whether it is appropriate to see museums primarily as tourist attractions. At many institutions, you can now hold office functions in the display areas, or have dinner with the dinosaurs. Whatever commentators may think, managers of museums, art galleries and science centres worldwide are looking for artful ways to blend culture and commerce, and blockbuster exhibitions are at the top of the list. But while blockbusters are all part of the new museology, there is proof that you don’t need a museum, science centre or art gallery to benefit from the drawing power of a blockbuster or to stage a blockbuster.

E

But do blockbusters held in public institutions really create a surplus to fund other activities? If the bottom line is profit, then according to the accounting records of many major museums and galleries, blockbusters do make money. For some museums overseas, it may be the money that they need to update parts of their collections or to repair buildings that are in need of attention. For others in Australia, it may be the opportunity to illustrate that they are attempting to pay their way, by recovering part of their operating costs or funding other operating activities with off-budget revenue. This makes the economic rationalists cheerful. However, not all exhibitions that are hailed to be blockbusters will be blockbusters, and some will not make money. It is also unlikely that the accounting systems of most institutions will recognise the real cost of either creating or hiring a blockbuster.

F

Blockbusters require large capital expenditure, and draw on resources across all branches of an organisation; however, the costs don’t end there. There is a Human Resource Management cost in addition to a measurable ‘real’ dollar cost. Receiving a touring exhibition involves large expenditure as well, and draws resources from across functional management structures in project management style. everyone from a general labourer to a building servicing unit, the front of the house, technical, promotion, education and administration staff, are required to perform additional tasks. Furthermore, as an increasing number of institutions in Australia try their hand at increasing visitor numbers, memberships (and therefore revenue), by staging blockbuster exhibitions, it may be less likely that blockbusters will continue to provide a surplus to subsidise other activities due to the competitive nature of the market. There are only so many consumer dollars to go around, and visitors will need to choose between blockbuster products.

G

Unfortunately, when the bottom-line is the most important objective to the mounting of blockbuster exhibitions, this same objective can be hard to maintain. Creating, mounting or hiring blockbusters is exhausting for staff, with the real costs throughout an institution difficult to calculate. Although the direct aims may be financial, creating or hiring a blockbuster has many positive spin-offs; by raising their profile through a popular blockbuster exhibition, a museum will be seen in a more favorable light at budget time. Blockbusters mean crowds, and crowds are good for the local economy, providing increased employment for shops, hotels, restaurants, the transport industry and retailers. Blockbusters expose staff to the vagaries and pressures of the market place and may lead to creative excellence. Either the success or failure of a blockbuster may highlight the need for managers and policymakers to rethink their strategies. However, the new museology and the apparent trend towards blockbusters make it likely that museums, art galleries and particularly science centres will be seen as part of the entertainment and tourism industry, rather than as cultural icons deserving of government and philanthropic support.

H

Perhaps the best pathway to take is one that balances both blockbusters and regular exhibitions. However, this easy middle ground may only work if you have enough space, and have alternate sources of funding to continue to support the regular less exciting fare. Perhaps the advice should be to make sure that your regular activities and exhibitions are more enticing, and find out what your local community wants from you. The question (trend) now at most museums and science centres, is “What blockbusters can we tour to overseas venues and will it be cost-effective?”$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('bf04a4fd-d950-55e9-a578-dafa378b5797', 'b6adae51-9ea3-52a7-aa47-a780e958cdf6', 1, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 1

Questions 1-4
Questions 1-4
The Reading Passage has seven paragraphs
A-H
Which paragraphs contains the following information?
Write the correct letter
A-H
, in boxes
1-4
on your answer sheet.
NB
You may use any letter more than once.
1
A reason for changing the exhibition programs.
2
The time people have to wait in a queue in order to enjoy exhibitions.
3
Terms people used when referring to the blockbuster
4
There was some controversy over confining target groups of a blockbuster.

1 ____ A reason for changing the exhibition programs.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('435e6a04-e863-5bf4-8f48-6f3c8f1e84c4', 'bf04a4fd-d950-55e9-a578-dafa378b5797', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('24da3123-4ccb-5b89-909e-2b804313d8c2', 'bf04a4fd-d950-55e9-a578-dafa378b5797', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d6134918-6e0b-56b8-bba0-ff2bc25dab72', 'bf04a4fd-d950-55e9-a578-dafa378b5797', 3, $md$C$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('18cf33a9-9c77-5bec-bd1c-00bcc373012f', 'bf04a4fd-d950-55e9-a578-dafa378b5797', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1e572a38-236f-5bdf-94f4-f9a2b015b5fd', 'bf04a4fd-d950-55e9-a578-dafa378b5797', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bcc931fd-356e-53da-bd87-318946a5f016', 'bf04a4fd-d950-55e9-a578-dafa378b5797', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b83321a5-4510-5f65-8f76-4215d59cdbf5', 'bf04a4fd-d950-55e9-a578-dafa378b5797', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('693b9710-b7c2-5ba5-844a-1922981eded9', 'bf04a4fd-d950-55e9-a578-dafa378b5797', 8, $md$H$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('5d6a0d2c-2bf2-5f8f-8596-b2ed5b3203f0', 'b6adae51-9ea3-52a7-aa47-a780e958cdf6', 2, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 2

Questions 1-4
Questions 1-4
The Reading Passage has seven paragraphs
A-H
Which paragraphs contains the following information?
Write the correct letter
A-H
, in boxes
1-4
on your answer sheet.
NB
You may use any letter more than once.
1
A reason for changing the exhibition programs.
2
The time people have to wait in a queue in order to enjoy exhibitions.
3
Terms people used when referring to the blockbuster
4
There was some controversy over confining target groups of a blockbuster.

2 ____ The time people have to wait in a queue in order to enjoy exhibitions.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9f34c4c3-b19a-54b6-a9c7-f73e28448b6a', '5d6a0d2c-2bf2-5f8f-8596-b2ed5b3203f0', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('19d72cee-4038-501b-b9fc-6c74e4b1ba65', '5d6a0d2c-2bf2-5f8f-8596-b2ed5b3203f0', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('01388bcd-0c78-5605-a6ed-4c2d6bb1fb19', '5d6a0d2c-2bf2-5f8f-8596-b2ed5b3203f0', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ef9c2733-1b18-5c51-9b84-c70f6eb25460', '5d6a0d2c-2bf2-5f8f-8596-b2ed5b3203f0', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('aea350e0-87cd-5457-a51d-3e2d175aa863', '5d6a0d2c-2bf2-5f8f-8596-b2ed5b3203f0', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9826ad0b-9da5-5867-abe7-08edea7f6446', '5d6a0d2c-2bf2-5f8f-8596-b2ed5b3203f0', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7e5740a4-5373-59d2-8639-b5f146968685', '5d6a0d2c-2bf2-5f8f-8596-b2ed5b3203f0', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9d045c56-b6b0-5560-b714-27d4750ddb70', '5d6a0d2c-2bf2-5f8f-8596-b2ed5b3203f0', 8, $md$H$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('55717613-c7b5-5132-af63-e123ba68be8b', 'b6adae51-9ea3-52a7-aa47-a780e958cdf6', 3, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 3

Questions 1-4
Questions 1-4
The Reading Passage has seven paragraphs
A-H
Which paragraphs contains the following information?
Write the correct letter
A-H
, in boxes
1-4
on your answer sheet.
NB
You may use any letter more than once.
1
A reason for changing the exhibition programs.
2
The time people have to wait in a queue in order to enjoy exhibitions.
3
Terms people used when referring to the blockbuster
4
There was some controversy over confining target groups of a blockbuster.

3 ____ Terms people used when referring to the blockbuster$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0ac1edee-26e0-5af6-98e4-b0357860410a', '55717613-c7b5-5132-af63-e123ba68be8b', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fc38881a-2a5e-533d-a39c-f0b274fb8376', '55717613-c7b5-5132-af63-e123ba68be8b', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7f1aee4d-2f40-5e01-8ef3-df80f3422517', '55717613-c7b5-5132-af63-e123ba68be8b', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ac49adfd-0017-5aa5-9617-db298fe65742', '55717613-c7b5-5132-af63-e123ba68be8b', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9c0b4a5f-3a88-5820-918c-59f4a62ccbb3', '55717613-c7b5-5132-af63-e123ba68be8b', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('270c7e9f-3e2b-5bff-9f31-2fc8b831662b', '55717613-c7b5-5132-af63-e123ba68be8b', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('aadde7e5-9cf0-57a5-9f69-274d3e5d517e', '55717613-c7b5-5132-af63-e123ba68be8b', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d7bb3659-6634-5b71-abc9-5a6a519b370c', '55717613-c7b5-5132-af63-e123ba68be8b', 8, $md$H$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('c3ae73ce-a39a-5897-9693-5d05b97b37e6', 'b6adae51-9ea3-52a7-aa47-a780e958cdf6', 4, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 4

Questions 1-4
Questions 1-4
The Reading Passage has seven paragraphs
A-H
Which paragraphs contains the following information?
Write the correct letter
A-H
, in boxes
1-4
on your answer sheet.
NB
You may use any letter more than once.
1
A reason for changing the exhibition programs.
2
The time people have to wait in a queue in order to enjoy exhibitions.
3
Terms people used when referring to the blockbuster
4
There was some controversy over confining target groups of a blockbuster.

4 ____ There was some controversy over confining target groups of a blockbuster.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('379defee-fcd5-587f-81b3-e86d64d5fa89', 'c3ae73ce-a39a-5897-9693-5d05b97b37e6', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3c7cdcf4-77c3-5181-b1fe-8d9055d3f7bf', 'c3ae73ce-a39a-5897-9693-5d05b97b37e6', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7b653ced-dd98-5619-85c9-4476ea209004', 'c3ae73ce-a39a-5897-9693-5d05b97b37e6', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f6702c52-61e2-5de6-9af9-310ed96fefdf', 'c3ae73ce-a39a-5897-9693-5d05b97b37e6', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bcbc4dbe-d971-5a05-913c-dcd48b292312', 'c3ae73ce-a39a-5897-9693-5d05b97b37e6', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2f0b394d-d02b-59a1-be6a-a971a2a03f5d', 'c3ae73ce-a39a-5897-9693-5d05b97b37e6', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b8cd0e6a-bb74-5baa-9b27-60061a312cd7', 'c3ae73ce-a39a-5897-9693-5d05b97b37e6', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ef451593-ae5c-571c-9491-3f4799612c9b', 'c3ae73ce-a39a-5897-9693-5d05b97b37e6', 8, $md$H$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('7080db75-d702-555c-8c11-e6a335618fa4', 'b6adae51-9ea3-52a7-aa47-a780e958cdf6', 5, 'SUMMARY_COMPLETION', 'READING', 3, $md$### Question 5

Questions 5-8
Questions 5-8
Complete the following summary of the paragraphs of Reading Passage
Using
NO MORE THAN THREE WORDS
from the Reading Passage for each answer.
Write your answers in boxes
5-8
on your answer sheet.
Instead of being visitors, people turned out to be
5
, who require the creation or hiring of blockbuster exhibitions as well as regular exhibition changes and innovations. Business nous and
6
simply summarized in a magazine are not only important factors for directors but also an ability to attract a crowd of audiences.
7
has contributed to the linking of museums, the heritage industry, tourism, profit-making and pleasure-giving. There occurs some controversy over whether it is proper to consider museums mainly as
8

Instead of being visitors, people turned out to be 5 ____ , who require the creation or hiring of blockbuster exhibitions as well as regular exhibition changes and innovations. Business nous and 6 ____ simply summarized in a magazine are not only important factors for directors but also an ability to attract a crowd of audiences. 7 ____ has contributed to the linking of museums, the heritage industry, tourism, profit-making and pleasure-giving. There occurs some controversy over whether it is proper to consider museums mainly as 8 ____$md$, NULL, ARRAY['.*customers.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('2cc00cec-8f55-5b12-9ea8-8cf2fcc4acd6', 'b6adae51-9ea3-52a7-aa47-a780e958cdf6', 6, 'SUMMARY_COMPLETION', 'READING', 3, $md$### Question 6

Questions 5-8
Questions 5-8
Complete the following summary of the paragraphs of Reading Passage
Using
NO MORE THAN THREE WORDS
from the Reading Passage for each answer.
Write your answers in boxes
5-8
on your answer sheet.
Instead of being visitors, people turned out to be
5
, who require the creation or hiring of blockbuster exhibitions as well as regular exhibition changes and innovations. Business nous and
6
simply summarized in a magazine are not only important factors for directors but also an ability to attract a crowd of audiences.
7
has contributed to the linking of museums, the heritage industry, tourism, profit-making and pleasure-giving. There occurs some controversy over whether it is proper to consider museums mainly as
8

Instead of being visitors, people turned out to be 5 ____ , who require the creation or hiring of blockbuster exhibitions as well as regular exhibition changes and innovations. Business nous and 6 ____ simply summarized in a magazine are not only important factors for directors but also an ability to attract a crowd of audiences. 7 ____ has contributed to the linking of museums, the heritage industry, tourism, profit-making and pleasure-giving. There occurs some controversy over whether it is proper to consider museums mainly as 8 ____$md$, NULL, ARRAY['.*customers.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('7b536a53-ff2a-546b-b3b5-9f9b309bf3f7', 'b6adae51-9ea3-52a7-aa47-a780e958cdf6', 7, 'SUMMARY_COMPLETION', 'READING', 3, $md$### Question 7

Questions 5-8
Questions 5-8
Complete the following summary of the paragraphs of Reading Passage
Using
NO MORE THAN THREE WORDS
from the Reading Passage for each answer.
Write your answers in boxes
5-8
on your answer sheet.
Instead of being visitors, people turned out to be
5
, who require the creation or hiring of blockbuster exhibitions as well as regular exhibition changes and innovations. Business nous and
6
simply summarized in a magazine are not only important factors for directors but also an ability to attract a crowd of audiences.
7
has contributed to the linking of museums, the heritage industry, tourism, profit-making and pleasure-giving. There occurs some controversy over whether it is proper to consider museums mainly as
8

Instead of being visitors, people turned out to be 5 ____ , who require the creation or hiring of blockbuster exhibitions as well as regular exhibition changes and innovations. Business nous and 6 ____ simply summarized in a magazine are not only important factors for directors but also an ability to attract a crowd of audiences. 7 ____ has contributed to the linking of museums, the heritage industry, tourism, profit-making and pleasure-giving. There occurs some controversy over whether it is proper to consider museums mainly as 8 ____$md$, NULL, ARRAY['.*customers.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('ff0a9041-c978-5960-8c18-e9a88da006c2', 'b6adae51-9ea3-52a7-aa47-a780e958cdf6', 8, 'SUMMARY_COMPLETION', 'READING', 3, $md$### Question 8

Questions 5-8
Questions 5-8
Complete the following summary of the paragraphs of Reading Passage
Using
NO MORE THAN THREE WORDS
from the Reading Passage for each answer.
Write your answers in boxes
5-8
on your answer sheet.
Instead of being visitors, people turned out to be
5
, who require the creation or hiring of blockbuster exhibitions as well as regular exhibition changes and innovations. Business nous and
6
simply summarized in a magazine are not only important factors for directors but also an ability to attract a crowd of audiences.
7
has contributed to the linking of museums, the heritage industry, tourism, profit-making and pleasure-giving. There occurs some controversy over whether it is proper to consider museums mainly as
8

Instead of being visitors, people turned out to be 5 ____ , who require the creation or hiring of blockbuster exhibitions as well as regular exhibition changes and innovations. Business nous and 6 ____ simply summarized in a magazine are not only important factors for directors but also an ability to attract a crowd of audiences. 7 ____ has contributed to the linking of museums, the heritage industry, tourism, profit-making and pleasure-giving. There occurs some controversy over whether it is proper to consider museums mainly as 8 ____$md$, NULL, ARRAY['.*customers.*']);

COMMIT;
