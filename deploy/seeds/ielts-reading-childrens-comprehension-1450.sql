BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-childrens-comprehension-1450'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-childrens-comprehension-1450';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-childrens-comprehension-1450';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-childrens-comprehension-1450';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('7b3d2fb2-ab71-5e3f-8bdd-1f6a69c0c957', 'ielts-reading-childrens-comprehension-1450', $t$Children's comprehension$t$, $md$## Children's comprehension

Nguồn:
- Test: https://mini-ielts.com/1450/reading/childrens-comprehension
- Solution: https://mini-ielts.com/1450/view-solution/reading/childrens-comprehension$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('960e2938-fbe0-5043-8111-b0ef81651c63', '7b3d2fb2-ab71-5e3f-8bdd-1f6a69c0c957', 1, $t$Reading — Children's comprehension$t$, $md$Read the passage and answer questions **1–13**.

### Passage: Children's comprehension

A In 1874, long before the advent of television, the English Parliament passed a law to protect children ‘from their own lack of experience and from the wiles of pushing tradesmen and moneylenders’ (James, 1965). The act is one of the earliest governmental policies to address children’s vulnerability to commercial exploitation and was produced before major corporations earned huge profits by marketing products directly to children. Yet the issues underlying this 19 th -century policy remain much the same in the 21 st century.

B Television has long been the predominant medium that advertisers have chosen for marketing products to children. It is estimated that the average child sees more than 40.000 television commercials a year, most of which are 15 to 30 seconds in length (Kunkel, 2001). According to another estimate, children aged 14 years and under make $24 billion in direct, purchases and influence $190 billion in family purchases, underscoring the high stakes involved (McNeal, 1987).

C A number of factors have contributed to an unprecedented growth in both the amount and type of advertising directed at children. First and foremost among these are changes in the media environment. In decades past, television programming targeted at children was limited and relegated to time slots unpopular with their parents, such as Saturday mornings of television advertising

(Turow, 1981). Today, the number of channels received in the average US home has escalated with the diffusion of cable television and satellite technologies. In this new multi-channel era, there are numerous national program services devoted exclusively to children. Naturally, these channels deliver significant amounts of child- oriented marketing messages. Although parent may be pleased that their youngsters can now watch children’s programming at any hour of the day, they may not recognize that such viewing opportunities entail much greater exposure to advertising than any previous generation of youth has experienced.

D Approximately 80% of all advertising targeted at children falls within four product categories: toys, cereals, candies, and fast-food restaurants (Kunkel et al, 1992). Commercials are highly effective at employing specific features designed to attract children’s attention. For example, they use the strategy of introducing unique sound effects and rapidly moving images (Greer et al, 1982). The other most common persuasive strategy employed in advertising to children is to associate the product with playfulness and happiness, rather than to provide any actual product-related information (Kunkel et al, 1992). For example, a commercial featuring Ronald McDonald dancing, singing, and smiling in McDonald’s restaurants without any mention of the actual food products available reflects a playful or happy theme. This strategy is also found frequently with cereal ads, which often include cartoon characters to help children identify the product. In contrast, most commercials fail to mention even the major grain used in each cereal.

E Another common feature of advertising to children is the use of product disclosures such as 'batteries not included’ or 'each part sold separately'. Studies make clear that young children do not comprehend the intended meaning of these disclaimers. For example, fewer than one in four kindergarten through second grade children could grasp the meaning of 'some assembly required' in a commercial. In contrast, the use of child-friendly language such as 'you have to put it together' more than doubled the proportion of children who understood the qualifying message (Liebert et al, 1977). The phrase 'part of a balanced breakfast’ is also a frequent disclosure included in most cereal ads to combat the concern that sugared cereal holds little nutritional value for children. Research shows that most children below age 7 years have no idea what the term ‘balanced breakfast’ means (Palmer & McDowell, 1981). Rather than informing young viewers about the importance of a nutritious breakfast, this common disclaimer actually leaves many children with the misimpression that cereal alone is sufficient for a meal. This pattern of employing creative terminology in advertising content so as to obscure certain information that might be unhelpful to the sponsor is a long-standing practice that often misleads the consumer (Geis, 1982).

F Very young children do not recognize that there are two fundamentally different categories of television content: programs and commercials. Most children below the age of 4 or 6 exhibit low awareness of the concept of commercials, frequently explaining them as if they were a scene in the program itself. Once this confusion diminishes, children first recognize the difference between programs and commercials based on either affective (‘commercials are funnier than TV programs') or perceptual (‘commercials are short and programs are long’) cues (Blatt et al, 1972).

G Although most children's programs indicate that a commercial break is coming (e.g. by saying 'We’ll be right back after these messages’), research reveals that these ‘separators' generally do not help children to recognize advertising content (Palmer & McDowell, 1979). This likely occurs because they are not perceptually distinct from the adjacent programming that surrounds them; in fact, many separators feature characters that appear in the same show that the commercial has just interrupted. When an ad includes one of the characters featured in a program, this is known as host-selling. This type of advertising makes the task of discriminating between program and commercial content particularly difficult for young children (Kunkel, 1988) and is thus restricted in the US by the Federal Communications Commission during children’s programs.

H In sum, because young children lack the cognitive skills and abilities of older children and adults, they do not comprehend commercial messages in the same way as more mature audiences, and are therefore uniquely susceptible to advertising influence.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('d3edf536-5cf4-5243-8ca7-a9e6b2623ca6', '960e2938-fbe0-5043-8111-b0ef81651c63', 1, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 1

Questions 1-5
Questions 1-5
Reading Passage has eight paragraphs,
A-H.
Which paragraph contains the following information?
Write the correct letter, A-H, in boxes 1-5 on your answer sheet.
NB You may use any letter more than once.
1
a description of recent innovations in TV broadcasting
2
a mention of the main goods and services advertised to children
3
a reference to a current limitation on television advertising aimed at children
4
two techniques used to encourage children to watch TV commercials
5
a type of advertisement that may make children believe the opposite of what is true

1 ____ a description of recent innovations in TV broadcasting$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f6e722c2-cc7e-5c46-b6c2-3a4a386fa8db', 'd3edf536-5cf4-5243-8ca7-a9e6b2623ca6', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ceb0253c-268b-58de-9505-cd7685fc9bf7', 'd3edf536-5cf4-5243-8ca7-a9e6b2623ca6', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1afeac33-30cf-5fda-b2ae-f4c3b435c461', 'd3edf536-5cf4-5243-8ca7-a9e6b2623ca6', 3, $md$C$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a4abcd0d-eeda-5c64-9f56-04157748f583', 'd3edf536-5cf4-5243-8ca7-a9e6b2623ca6', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('05bc2677-2516-589f-9cf4-981c259292c6', 'd3edf536-5cf4-5243-8ca7-a9e6b2623ca6', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f530b3ae-2811-5bd8-8df8-4485044bad5e', 'd3edf536-5cf4-5243-8ca7-a9e6b2623ca6', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6371a497-ecb6-53b2-8649-6f2351318214', 'd3edf536-5cf4-5243-8ca7-a9e6b2623ca6', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1a0e34a1-7a80-5a29-ae5a-3d4a14059794', 'd3edf536-5cf4-5243-8ca7-a9e6b2623ca6', 8, $md$H$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('14f53b1d-dd21-58d4-9ded-f688c5d12316', '960e2938-fbe0-5043-8111-b0ef81651c63', 2, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 2

Questions 1-5
Questions 1-5
Reading Passage has eight paragraphs,
A-H.
Which paragraph contains the following information?
Write the correct letter, A-H, in boxes 1-5 on your answer sheet.
NB You may use any letter more than once.
1
a description of recent innovations in TV broadcasting
2
a mention of the main goods and services advertised to children
3
a reference to a current limitation on television advertising aimed at children
4
two techniques used to encourage children to watch TV commercials
5
a type of advertisement that may make children believe the opposite of what is true

2 ____ a mention of the main goods and services advertised to children$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('de881095-01b6-569d-95fb-281a11650e83', '14f53b1d-dd21-58d4-9ded-f688c5d12316', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('87ccc424-1fe7-542d-a28f-81e7a98e9662', '14f53b1d-dd21-58d4-9ded-f688c5d12316', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a1210be2-8333-5f69-9f2a-ca49f2a064f0', '14f53b1d-dd21-58d4-9ded-f688c5d12316', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7d20e703-4556-56e4-a64c-62b241b6acde', '14f53b1d-dd21-58d4-9ded-f688c5d12316', 4, $md$D$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('181ab98c-c7ac-5a22-8b8e-37412d80fdac', '14f53b1d-dd21-58d4-9ded-f688c5d12316', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f2a36553-695d-5602-bffb-a25b08c43baf', '14f53b1d-dd21-58d4-9ded-f688c5d12316', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('dcef3dee-f398-5733-adc8-eb08f686a5a8', '14f53b1d-dd21-58d4-9ded-f688c5d12316', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1b208bbf-01a3-54bc-9923-b05016611160', '14f53b1d-dd21-58d4-9ded-f688c5d12316', 8, $md$H$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('8d112ae8-a16e-55fb-962a-fddbf11fbc4d', '960e2938-fbe0-5043-8111-b0ef81651c63', 3, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 3

Questions 1-5
Questions 1-5
Reading Passage has eight paragraphs,
A-H.
Which paragraph contains the following information?
Write the correct letter, A-H, in boxes 1-5 on your answer sheet.
NB You may use any letter more than once.
1
a description of recent innovations in TV broadcasting
2
a mention of the main goods and services advertised to children
3
a reference to a current limitation on television advertising aimed at children
4
two techniques used to encourage children to watch TV commercials
5
a type of advertisement that may make children believe the opposite of what is true

3 ____ a reference to a current limitation on television advertising aimed at children$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('378f1572-f9fa-581d-93c9-d8d53ad82e10', '8d112ae8-a16e-55fb-962a-fddbf11fbc4d', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7ee99044-c6fb-51d1-b53a-742cdc8456e4', '8d112ae8-a16e-55fb-962a-fddbf11fbc4d', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('94ad1c85-db29-5849-a76c-ae6ea780c383', '8d112ae8-a16e-55fb-962a-fddbf11fbc4d', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e70fbff4-b035-5c8d-b95c-11e2b0a00e80', '8d112ae8-a16e-55fb-962a-fddbf11fbc4d', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('55254eca-48da-5dce-b99e-0bdbd8fe5266', '8d112ae8-a16e-55fb-962a-fddbf11fbc4d', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8035e3f8-9049-5e29-b4b4-df8e1603df60', '8d112ae8-a16e-55fb-962a-fddbf11fbc4d', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('67a5d21c-d711-522d-abf3-7637dea164bc', '8d112ae8-a16e-55fb-962a-fddbf11fbc4d', 7, $md$G$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b924ab9d-e66c-514f-971d-2d2fbb3ab110', '8d112ae8-a16e-55fb-962a-fddbf11fbc4d', 8, $md$H$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('9d473aa8-0146-593e-b49f-ba077e10031f', '960e2938-fbe0-5043-8111-b0ef81651c63', 4, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 4

Questions 1-5
Questions 1-5
Reading Passage has eight paragraphs,
A-H.
Which paragraph contains the following information?
Write the correct letter, A-H, in boxes 1-5 on your answer sheet.
NB You may use any letter more than once.
1
a description of recent innovations in TV broadcasting
2
a mention of the main goods and services advertised to children
3
a reference to a current limitation on television advertising aimed at children
4
two techniques used to encourage children to watch TV commercials
5
a type of advertisement that may make children believe the opposite of what is true

4 ____ two techniques used to encourage children to watch TV commercials$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('10c30eb1-2212-5063-a25f-d5304a196e51', '9d473aa8-0146-593e-b49f-ba077e10031f', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4ca4cf9a-c57b-56cc-a393-adf0f555918d', '9d473aa8-0146-593e-b49f-ba077e10031f', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0f0a5a02-c5ab-5c9f-a264-dc1081c0ac3f', '9d473aa8-0146-593e-b49f-ba077e10031f', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bcbc57dc-8853-5698-b142-42079c88ac69', '9d473aa8-0146-593e-b49f-ba077e10031f', 4, $md$D$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('748f3ff0-c985-54b1-a25c-addfedc7e7ac', '9d473aa8-0146-593e-b49f-ba077e10031f', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f97bdd1b-e657-59d9-91e4-b4d91a6c53a6', '9d473aa8-0146-593e-b49f-ba077e10031f', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2eafb2e2-4e6d-5a39-b829-56cf508d2463', '9d473aa8-0146-593e-b49f-ba077e10031f', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('76c63b97-b032-5944-b041-20d09a960375', '9d473aa8-0146-593e-b49f-ba077e10031f', 8, $md$H$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('eef185a4-0da5-575e-b4db-822313251c08', '960e2938-fbe0-5043-8111-b0ef81651c63', 5, 'MATCHING_INFORMATION', 'READING', 3, $md$### Question 5

Questions 1-5
Questions 1-5
Reading Passage has eight paragraphs,
A-H.
Which paragraph contains the following information?
Write the correct letter, A-H, in boxes 1-5 on your answer sheet.
NB You may use any letter more than once.
1
a description of recent innovations in TV broadcasting
2
a mention of the main goods and services advertised to children
3
a reference to a current limitation on television advertising aimed at children
4
two techniques used to encourage children to watch TV commercials
5
a type of advertisement that may make children believe the opposite of what is true

5 ____ a type of advertisement that may make children believe the opposite of what is true$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0ba600d3-a0b4-5697-80b6-4f09de011e7f', 'eef185a4-0da5-575e-b4db-822313251c08', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b9aeb333-aeb4-5ce0-b6fa-6b8b0ec287ff', 'eef185a4-0da5-575e-b4db-822313251c08', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2c67d3cf-69bb-5629-a068-a38ed366383e', 'eef185a4-0da5-575e-b4db-822313251c08', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6ddb946d-a9e5-59a5-aaab-8f05929c3d3e', 'eef185a4-0da5-575e-b4db-822313251c08', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cdf66c48-12a9-58ca-be00-9431f2ddd02e', 'eef185a4-0da5-575e-b4db-822313251c08', 5, $md$E$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cda29d22-8737-5c6f-896e-a771cc19dd67', 'eef185a4-0da5-575e-b4db-822313251c08', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('df3b4005-d8bf-55c4-9d3f-3947a4fce93c', 'eef185a4-0da5-575e-b4db-822313251c08', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c99b8f79-8c25-510e-aa3b-432443511a02', 'eef185a4-0da5-575e-b4db-822313251c08', 8, $md$H$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('d0692868-648a-5376-abc8-201dc93fe353', '960e2938-fbe0-5043-8111-b0ef81651c63', 6, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 6

Questions 6-9
Questions 6-9
Look at the following statements (Questions 6-9) and the list of researchers below. Match each statement with the correct researcher(s). A-H
Write the correct letter, A-H, in boxes 6-9 on your answer sheet.
6
Ads often aim to teach children that a brand is fun rather than telling them about what is being sold.
7
Originally, children’s programmes were only broadcast when adults rarely watched TV.
8
Children have a significant impact on what adults buy.
9
Tests showed that children can follow information if simple words are used.
List of Researchers
A
Kunkel
B
Kunkel et al
c
McNeal
D
Turow
c
Greer et al
F
Liebert et al
G
Palmer & McDowell
H
Geis

6 ____ Ads often aim to teach children that a brand is fun rather than telling them about what is being sold.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('93079794-0613-5fbe-84e7-3b7f720aa8f3', 'd0692868-648a-5376-abc8-201dc93fe353', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('dcbcef5b-f5e2-58ab-860c-18864e879215', 'd0692868-648a-5376-abc8-201dc93fe353', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3bc76ce4-21a0-56ee-9a3b-8f68bd7c3270', 'd0692868-648a-5376-abc8-201dc93fe353', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('08b8fc9a-ee19-53d9-b1c3-dad8576b6d34', 'd0692868-648a-5376-abc8-201dc93fe353', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('522e6927-863a-56f2-8a53-1ef684ce94f7', 'd0692868-648a-5376-abc8-201dc93fe353', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('487812d5-b9eb-58f2-9014-7d7874091d65', 'd0692868-648a-5376-abc8-201dc93fe353', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1731d1d9-05bc-55bc-a419-eddb7af4f4f9', 'd0692868-648a-5376-abc8-201dc93fe353', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ed675496-229f-548a-b4e4-de9795e89b62', 'd0692868-648a-5376-abc8-201dc93fe353', 8, $md$H$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('305d40a2-7de3-5fb1-87dd-04a2ffd33d71', '960e2938-fbe0-5043-8111-b0ef81651c63', 7, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 7

Questions 6-9
Questions 6-9
Look at the following statements (Questions 6-9) and the list of researchers below. Match each statement with the correct researcher(s). A-H
Write the correct letter, A-H, in boxes 6-9 on your answer sheet.
6
Ads often aim to teach children that a brand is fun rather than telling them about what is being sold.
7
Originally, children’s programmes were only broadcast when adults rarely watched TV.
8
Children have a significant impact on what adults buy.
9
Tests showed that children can follow information if simple words are used.
List of Researchers
A
Kunkel
B
Kunkel et al
c
McNeal
D
Turow
c
Greer et al
F
Liebert et al
G
Palmer & McDowell
H
Geis

7 ____ Originally, children’s programmes were only broadcast when adults rarely watched TV.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6459807c-d506-5c8c-9ef2-593a69f39e2a', '305d40a2-7de3-5fb1-87dd-04a2ffd33d71', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8c73dd24-6ce6-5fcd-9516-183b7b7c342f', '305d40a2-7de3-5fb1-87dd-04a2ffd33d71', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('abaaa570-7ec3-57e9-bd95-695e31da5dda', '305d40a2-7de3-5fb1-87dd-04a2ffd33d71', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('71ec47e9-c6db-5fd9-952c-83992e9bd383', '305d40a2-7de3-5fb1-87dd-04a2ffd33d71', 4, $md$D$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('969114df-6333-5dd2-ade4-1c8e1fe983d5', '305d40a2-7de3-5fb1-87dd-04a2ffd33d71', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4d35c4e5-9b5e-5eae-bf49-c5173ff82867', '305d40a2-7de3-5fb1-87dd-04a2ffd33d71', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a356cb03-b2a3-5d24-9fc3-a9dc38df1921', '305d40a2-7de3-5fb1-87dd-04a2ffd33d71', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('316e371a-3103-5a06-9684-cfe493043fe4', '305d40a2-7de3-5fb1-87dd-04a2ffd33d71', 8, $md$H$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('b4c1c2dd-7e66-5e80-844e-455899e62ec3', '960e2938-fbe0-5043-8111-b0ef81651c63', 8, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 8

Questions 6-9
Questions 6-9
Look at the following statements (Questions 6-9) and the list of researchers below. Match each statement with the correct researcher(s). A-H
Write the correct letter, A-H, in boxes 6-9 on your answer sheet.
6
Ads often aim to teach children that a brand is fun rather than telling them about what is being sold.
7
Originally, children’s programmes were only broadcast when adults rarely watched TV.
8
Children have a significant impact on what adults buy.
9
Tests showed that children can follow information if simple words are used.
List of Researchers
A
Kunkel
B
Kunkel et al
c
McNeal
D
Turow
c
Greer et al
F
Liebert et al
G
Palmer & McDowell
H
Geis

8 ____ Children have a significant impact on what adults buy.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7269cc66-8a6f-5d12-acda-61fb7542873e', 'b4c1c2dd-7e66-5e80-844e-455899e62ec3', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('df3cfaae-ea0f-58ac-bfe2-ca62bfd25726', 'b4c1c2dd-7e66-5e80-844e-455899e62ec3', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b123c819-fe11-5f71-a858-0b399e5ad0b2', 'b4c1c2dd-7e66-5e80-844e-455899e62ec3', 3, $md$C$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ef490093-e09d-5387-bb25-6330c04d46b8', 'b4c1c2dd-7e66-5e80-844e-455899e62ec3', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5217b37a-53a1-5046-af4b-9c44ca751e3c', 'b4c1c2dd-7e66-5e80-844e-455899e62ec3', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('df9d3daa-ffb3-5be6-bf4b-f770b493a30e', 'b4c1c2dd-7e66-5e80-844e-455899e62ec3', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2b2a0724-2d7d-5a43-84d6-b2ebae5344d4', 'b4c1c2dd-7e66-5e80-844e-455899e62ec3', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9af46ad0-58f7-5c1e-8c11-ff52b78aa146', 'b4c1c2dd-7e66-5e80-844e-455899e62ec3', 8, $md$H$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('15021dc2-3484-58fe-85d8-efc9a2aecf90', '960e2938-fbe0-5043-8111-b0ef81651c63', 9, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 9

Questions 6-9
Questions 6-9
Look at the following statements (Questions 6-9) and the list of researchers below. Match each statement with the correct researcher(s). A-H
Write the correct letter, A-H, in boxes 6-9 on your answer sheet.
6
Ads often aim to teach children that a brand is fun rather than telling them about what is being sold.
7
Originally, children’s programmes were only broadcast when adults rarely watched TV.
8
Children have a significant impact on what adults buy.
9
Tests showed that children can follow information if simple words are used.
List of Researchers
A
Kunkel
B
Kunkel et al
c
McNeal
D
Turow
c
Greer et al
F
Liebert et al
G
Palmer & McDowell
H
Geis

9 ____ Tests showed that children can follow information if simple words are used.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('531c17f2-4407-53b5-aff1-4bacc74d7681', '15021dc2-3484-58fe-85d8-efc9a2aecf90', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9ffc2ae1-a75a-58c8-a170-6fb6f9741089', '15021dc2-3484-58fe-85d8-efc9a2aecf90', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d6de7824-d087-5991-b49c-dac983c5b1e0', '15021dc2-3484-58fe-85d8-efc9a2aecf90', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('41a5423e-637d-52ab-ba1a-191c53adcaa7', '15021dc2-3484-58fe-85d8-efc9a2aecf90', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3b647348-4054-5c63-a04f-868be080b883', '15021dc2-3484-58fe-85d8-efc9a2aecf90', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e9cb3a57-3ff9-531e-9cea-044135008543', '15021dc2-3484-58fe-85d8-efc9a2aecf90', 6, $md$F$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7c08688a-ef84-5984-b166-3d8e03b3379e', '15021dc2-3484-58fe-85d8-efc9a2aecf90', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b660c481-56da-5da5-8a81-d52fd531b308', '15021dc2-3484-58fe-85d8-efc9a2aecf90', 8, $md$H$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('15e7e720-35fd-5f64-89bf-f6f6e6be6dce', '960e2938-fbe0-5043-8111-b0ef81651c63', 10, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 10

Questions 10-13
Questions 10-13
Complete the summary below.
Choose
NO MORE THAN TWO WORDS
from the passage for each answer. Write your answers in boxes 10-13 on your answer sheet.
How very young children perceive commercials
Children below the age of 4 or 6 do not understand the difference between television programmes and commercials. In fact, these children often mistake an advertisement for a
10
from the programe they are watching. This is despite the fact that
children’s TV programmes usually include announcements called
11
to show that there is going to be a commercial break. The problem is made more difficult because of a technique called
12
. Whereby a person or cartoon
figure from the programme is used to sell a product during the commercial break. From the age of 4 or 6, children begin to realise that commercials are different from TV programmes; for example, they may recognise that there is a difference in length or that advertisements are
13
than actual TV.

Children below the age of 4 or 6 do not understand the difference between television programmes and commercials. In fact, these children often mistake an advertisement for a 10 ____ from the programe they are watching. This is despite the fact that$md$, NULL, ARRAY['.*scene.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('9933adf6-95a7-580c-b461-b03f1553e584', '960e2938-fbe0-5043-8111-b0ef81651c63', 11, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 11

Questions 10-13
Questions 10-13
Complete the summary below.
Choose
NO MORE THAN TWO WORDS
from the passage for each answer. Write your answers in boxes 10-13 on your answer sheet.
How very young children perceive commercials
Children below the age of 4 or 6 do not understand the difference between television programmes and commercials. In fact, these children often mistake an advertisement for a
10
from the programe they are watching. This is despite the fact that
children’s TV programmes usually include announcements called
11
to show that there is going to be a commercial break. The problem is made more difficult because of a technique called
12
. Whereby a person or cartoon
figure from the programme is used to sell a product during the commercial break. From the age of 4 or 6, children begin to realise that commercials are different from TV programmes; for example, they may recognise that there is a difference in length or that advertisements are
13
than actual TV.

children’s TV programmes usually include announcements called 11 ____ to show that there is going to be a commercial break. The problem is made more difficult because of a technique called 12 ____ . Whereby a person or cartoon$md$, NULL, ARRAY['.*separators.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('f31d6dc9-4545-5ab4-82c5-7ce9dd19e366', '960e2938-fbe0-5043-8111-b0ef81651c63', 12, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 12

Questions 10-13
Questions 10-13
Complete the summary below.
Choose
NO MORE THAN TWO WORDS
from the passage for each answer. Write your answers in boxes 10-13 on your answer sheet.
How very young children perceive commercials
Children below the age of 4 or 6 do not understand the difference between television programmes and commercials. In fact, these children often mistake an advertisement for a
10
from the programe they are watching. This is despite the fact that
children’s TV programmes usually include announcements called
11
to show that there is going to be a commercial break. The problem is made more difficult because of a technique called
12
. Whereby a person or cartoon
figure from the programme is used to sell a product during the commercial break. From the age of 4 or 6, children begin to realise that commercials are different from TV programmes; for example, they may recognise that there is a difference in length or that advertisements are
13
than actual TV.

children’s TV programmes usually include announcements called 11 ____ to show that there is going to be a commercial break. The problem is made more difficult because of a technique called 12 ____ . Whereby a person or cartoon$md$, NULL, ARRAY['.*separators.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('4620bad1-8829-59a9-ac90-bea77f013133', '960e2938-fbe0-5043-8111-b0ef81651c63', 13, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 13

Questions 10-13
Questions 10-13
Complete the summary below.
Choose
NO MORE THAN TWO WORDS
from the passage for each answer. Write your answers in boxes 10-13 on your answer sheet.
How very young children perceive commercials
Children below the age of 4 or 6 do not understand the difference between television programmes and commercials. In fact, these children often mistake an advertisement for a
10
from the programe they are watching. This is despite the fact that
children’s TV programmes usually include announcements called
11
to show that there is going to be a commercial break. The problem is made more difficult because of a technique called
12
. Whereby a person or cartoon
figure from the programme is used to sell a product during the commercial break. From the age of 4 or 6, children begin to realise that commercials are different from TV programmes; for example, they may recognise that there is a difference in length or that advertisements are
13
than actual TV.

figure from the programme is used to sell a product during the commercial break. From the age of 4 or 6, children begin to realise that commercials are different from TV programmes; for example, they may recognise that there is a difference in length or that advertisements are 13 ____ than actual TV.$md$, NULL, ARRAY['.*funnier.*']);

COMMIT;
