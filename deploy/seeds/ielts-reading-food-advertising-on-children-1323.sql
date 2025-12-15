BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-food-advertising-on-children-1323'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-food-advertising-on-children-1323';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-food-advertising-on-children-1323';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-food-advertising-on-children-1323';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('f5f33e86-452b-58c0-b2bc-0c60a33b9ca0', 'ielts-reading-food-advertising-on-children-1323', $t$Food advertising on children$t$, $md$## Food advertising on children

Nguồn:
- Test: https://mini-ielts.com/1323/reading/food-advertising-on-children
- Solution: https://mini-ielts.com/1323/view-solution/reading/food-advertising-on-children$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('6e3ee1b0-1a52-59ad-9a0e-b73963b4e5ad', 'f5f33e86-452b-58c0-b2bc-0c60a33b9ca0', 1, $t$Reading — Food advertising on children$t$, $md$Read the passage and answer questions **1–13**.

### Passage: Food advertising on children

This review was commissioned by the Food Standards Agency to examine the current research evidence on:

• the extent and nature of food promotion to children

the effect, if any, that this promotion has on their food knowledge, preferences and behaviour.

A

Children’s food promotion is dominated by television advertising, and the great majority of this promotes the so-called ‘Big Four’ of pre-sugared breakfast cereals, soft drinks, confectionery and savoury snacks. In the last ten years advertising for fast food, outlets have rapidly increased. There is some evidence that the dominance of television has recently begun to wane. The importance of strong, global branding reinforces a need for multi-faceted communications combining television with merchandising, ‘tie-ins’ and point of sale activity. The advertised diet contrasts sharply with that recommended by public health advisors, and themes of fun and fantasy or taste, rather than health and nutrition, are used to promote it to children. Meanwhile, the recommended diet gets little promotional support.

B

There is plenty of evidence that children notice and enjoy food promotion. However, establishing whether this actually influences them is a complex problem. The review tackled it by looking at studies that had examined possible effects on what children know about food, their food preferences, their actual food behaviour (both buying and eating), and their health outcomes (eg. Obesity or cholesterol levels). The majority of studies examined food advertising, but a few examined other forms of food promotion. In terms of nutritional knowledge, food advertising seems to have little influence on children’s general perceptions of what constitutes a healthy diet, but, in certain contexts, it does have an effect on more specific types of nutritional knowledge. For example, seeing soft drink and cereal adverts reduced primary aged children’s ability to determine correctly whether or not certain products contained real fruit.

C

The review also found evidence that food promotion influences children’s food preferences and purchase behaviour. A study of primary school children, for instance, found that exposure to advertising influenced which foods they claimed to like; and another showed that labelling and signage on a vending machine had an effect on what was bought by secondary school pupils. A number of studies have also shown that food advertising can influence what children eat. One, for example, showed that advertising influenced a primary class’s choice of daily snack at playtime.

D

The next step, of trying to establish whether or not a link exists between food promotion and diet or obesity, is extremely difficult as it requires research to be done in real-world settings. A number of studies have attempted this by using the amount of television viewing as a proxy for exposure to television advertising. They have established a clear link between television viewing and diet, obesity, and cholesterol levels. It is impossible to say, however, whether this effect is caused by the advertising, the sedentary nature of television viewing or snacking that might take place whilst viewing. One study resolved this problem by taking a detailed diary of children’s viewing habits. This showed that the more food adverts they saw, the more snacks and calories they consumed.

E

Thus the literature does suggest food promotion is influencing children’s diet in a number of ways. This does not amount to proof; as noted above with this kind of research, incontrovertible proof simply isn’t attainable. Nor do all studies point to this conclusion; several have not found an effect. In addition, very few studies have attempted to measure how strong these effects are relative to other factors influencing children’s food choices. Nonetheless, many studies have found clear effects and they have used sophisticated methodologies that make it possible to determine that i) these effects are not just due to chance; ii) they are independent of other factors that influence diets, such as parents’ eating habits or attitudes; and iii) they occur at a brand and category level.

F

Furthermore, two factors suggest that these findings actually downplay the effect that food promotion has on children. First, the literature focuses principally on television advertising; the cumulative effect of this combined with other forms of promotion and marketing is likely to be significantly greater. Second, the studies have looked at the direct effects of individual children, and understate indirect influences. For example, promotion for fast food outlets may not only influence the child but also encourage parents to take them for meals and reinforce the idea that this is normal and desirable behaviour.

G

This does not amount to proof of an effect, but in our view does provide sufficient evidence to conclude that an effect exists. The debate should now shift to what action is needed, and specifically to how the power of commercial marketing can be used to bring about improvements in young people’s eating.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('c1fac4a9-5a3a-53f6-bf51-9957888f41e7', '6e3ee1b0-1a52-59ad-9a0e-b73963b4e5ad', 1, 'MATCHING_HEADING', 'READING', 2, $md$### Question 1

Questions 1-7
Questions 1-7
Reading Passage 1 has seven paragraphs,
A-G
.
Choose the most suitable heading for paragraphs
A-G
from the list of headings below.
Write the appropriate number,
i-x
, in boxes
1-7
on your answer sheet.
List of Headings
i
General points of agreements and disagreements of researchers
ii
How much children really know about food
iii
Need to take action
iv
Advertising effects of the “Big Four”
v
Connection of advertising and children’s weight problems
vi
Evidence that advertising affects what children buy to eat
vii
How parents influence children’s eating habits
viii
Advertising’s focus on unhealthy options
ix
Children often buy what they want
x
Underestimating the effects advertising has on children
1
Paragraph A
2
Paragraph B
3
Paragraph C
4
Paragraph D
5
Paragraph E
6
Paragraph F
7
Paragraph G

1 ____ Paragraph A$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c148814b-ba80-53ed-a304-d861c32581cf', 'c1fac4a9-5a3a-53f6-bf51-9957888f41e7', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3efb251d-ffbb-58db-acc1-dca9c458c97b', 'c1fac4a9-5a3a-53f6-bf51-9957888f41e7', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('43081cd0-4d0a-5654-94b7-0ac174651480', 'c1fac4a9-5a3a-53f6-bf51-9957888f41e7', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2200e95f-2f99-5dcc-9eb1-9be22a10dc77', 'c1fac4a9-5a3a-53f6-bf51-9957888f41e7', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1be47314-3634-51fc-a3c6-6cbe122af5b9', 'c1fac4a9-5a3a-53f6-bf51-9957888f41e7', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('097f66e8-d55f-5d40-8174-a55e44462644', 'c1fac4a9-5a3a-53f6-bf51-9957888f41e7', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('663e66cb-72ac-51af-afe4-7f8e6bc0d2c1', 'c1fac4a9-5a3a-53f6-bf51-9957888f41e7', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3b521b7c-35e8-5b36-a3a7-fbb0cd4fddca', 'c1fac4a9-5a3a-53f6-bf51-9957888f41e7', 8, $md$viii$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('56bb5c39-73a9-5309-b007-a612645fe96c', 'c1fac4a9-5a3a-53f6-bf51-9957888f41e7', 9, $md$ix$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e4d15be4-0352-557a-8575-49b41093b186', 'c1fac4a9-5a3a-53f6-bf51-9957888f41e7', 10, $md$x$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('c2d4dc36-d839-5775-9d72-58753d24f9dd', '6e3ee1b0-1a52-59ad-9a0e-b73963b4e5ad', 2, 'MATCHING_HEADING', 'READING', 2, $md$### Question 2

Questions 1-7
Questions 1-7
Reading Passage 1 has seven paragraphs,
A-G
.
Choose the most suitable heading for paragraphs
A-G
from the list of headings below.
Write the appropriate number,
i-x
, in boxes
1-7
on your answer sheet.
List of Headings
i
General points of agreements and disagreements of researchers
ii
How much children really know about food
iii
Need to take action
iv
Advertising effects of the “Big Four”
v
Connection of advertising and children’s weight problems
vi
Evidence that advertising affects what children buy to eat
vii
How parents influence children’s eating habits
viii
Advertising’s focus on unhealthy options
ix
Children often buy what they want
x
Underestimating the effects advertising has on children
1
Paragraph A
2
Paragraph B
3
Paragraph C
4
Paragraph D
5
Paragraph E
6
Paragraph F
7
Paragraph G

2 ____ Paragraph B$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4df413ee-dee2-5bee-a239-c592997a2f02', 'c2d4dc36-d839-5775-9d72-58753d24f9dd', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c556e425-45f0-5fd0-917f-f3efaad87d08', 'c2d4dc36-d839-5775-9d72-58753d24f9dd', 2, $md$ii$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3841bdcd-e74f-5d28-8875-72bd4390ff4c', 'c2d4dc36-d839-5775-9d72-58753d24f9dd', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4d860bff-3d68-5ae5-a606-914d1e81661d', 'c2d4dc36-d839-5775-9d72-58753d24f9dd', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('19d749b4-381d-5235-b545-1d2783225683', 'c2d4dc36-d839-5775-9d72-58753d24f9dd', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('17c21507-5368-5fc8-a803-e2bd7bdba70f', 'c2d4dc36-d839-5775-9d72-58753d24f9dd', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('948a71b7-2d60-53dd-85de-cdfbac5af407', 'c2d4dc36-d839-5775-9d72-58753d24f9dd', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6ffccb3e-92fd-5b4d-8242-0d195797b174', 'c2d4dc36-d839-5775-9d72-58753d24f9dd', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('af8c349b-8aa6-5e6d-a0e1-8e66a33fb4cc', 'c2d4dc36-d839-5775-9d72-58753d24f9dd', 9, $md$ix$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8a769328-b740-53ef-a277-895ebf17b768', 'c2d4dc36-d839-5775-9d72-58753d24f9dd', 10, $md$x$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('67f53b2a-5c5e-5c15-9a40-7c42950447da', '6e3ee1b0-1a52-59ad-9a0e-b73963b4e5ad', 3, 'MATCHING_HEADING', 'READING', 2, $md$### Question 3

Questions 1-7
Questions 1-7
Reading Passage 1 has seven paragraphs,
A-G
.
Choose the most suitable heading for paragraphs
A-G
from the list of headings below.
Write the appropriate number,
i-x
, in boxes
1-7
on your answer sheet.
List of Headings
i
General points of agreements and disagreements of researchers
ii
How much children really know about food
iii
Need to take action
iv
Advertising effects of the “Big Four”
v
Connection of advertising and children’s weight problems
vi
Evidence that advertising affects what children buy to eat
vii
How parents influence children’s eating habits
viii
Advertising’s focus on unhealthy options
ix
Children often buy what they want
x
Underestimating the effects advertising has on children
1
Paragraph A
2
Paragraph B
3
Paragraph C
4
Paragraph D
5
Paragraph E
6
Paragraph F
7
Paragraph G

3 ____ Paragraph C$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bd9211fe-87f3-5394-ad77-32edca63f0ac', '67f53b2a-5c5e-5c15-9a40-7c42950447da', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cb47881e-4e5e-51cf-9aad-fa02bdfc7cb7', '67f53b2a-5c5e-5c15-9a40-7c42950447da', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b0bb2539-7094-59e6-988e-a847ba78f226', '67f53b2a-5c5e-5c15-9a40-7c42950447da', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('77edd560-0b89-5bb6-b25d-c0531ab3d9da', '67f53b2a-5c5e-5c15-9a40-7c42950447da', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('18b982b4-c0c9-5a3f-a48b-cd11f581cb95', '67f53b2a-5c5e-5c15-9a40-7c42950447da', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0012ccd3-1383-5320-bcf3-76bc959fe366', '67f53b2a-5c5e-5c15-9a40-7c42950447da', 6, $md$vi$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('82ab23fd-e949-57f7-94d5-f541c6cac14a', '67f53b2a-5c5e-5c15-9a40-7c42950447da', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6a0a5ebb-60b5-5ffd-b0e7-7b3de12130e1', '67f53b2a-5c5e-5c15-9a40-7c42950447da', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8527bbf9-b14a-5340-a10e-9648a478677e', '67f53b2a-5c5e-5c15-9a40-7c42950447da', 9, $md$ix$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b0c84fd6-587c-5a9b-9bd4-2b1bdd34fedb', '67f53b2a-5c5e-5c15-9a40-7c42950447da', 10, $md$x$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('4be5c320-c2e0-58e2-ad46-01bf916580a2', '6e3ee1b0-1a52-59ad-9a0e-b73963b4e5ad', 4, 'MATCHING_HEADING', 'READING', 2, $md$### Question 4

Questions 1-7
Questions 1-7
Reading Passage 1 has seven paragraphs,
A-G
.
Choose the most suitable heading for paragraphs
A-G
from the list of headings below.
Write the appropriate number,
i-x
, in boxes
1-7
on your answer sheet.
List of Headings
i
General points of agreements and disagreements of researchers
ii
How much children really know about food
iii
Need to take action
iv
Advertising effects of the “Big Four”
v
Connection of advertising and children’s weight problems
vi
Evidence that advertising affects what children buy to eat
vii
How parents influence children’s eating habits
viii
Advertising’s focus on unhealthy options
ix
Children often buy what they want
x
Underestimating the effects advertising has on children
1
Paragraph A
2
Paragraph B
3
Paragraph C
4
Paragraph D
5
Paragraph E
6
Paragraph F
7
Paragraph G

4 ____ Paragraph D$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7f3ccb4b-1c46-571d-a151-f486fab1859f', '4be5c320-c2e0-58e2-ad46-01bf916580a2', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('73ea88f0-cfc7-5f14-a0ce-d6d8fcdc251e', '4be5c320-c2e0-58e2-ad46-01bf916580a2', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b6d91d71-6820-5618-be95-5aec922d45a0', '4be5c320-c2e0-58e2-ad46-01bf916580a2', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ffc95fc9-049d-5cca-a150-76fac404635b', '4be5c320-c2e0-58e2-ad46-01bf916580a2', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6f7173fc-e854-579e-887d-2d10116bc073', '4be5c320-c2e0-58e2-ad46-01bf916580a2', 5, $md$v$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('01738ebe-a2b7-57a2-8cdd-e5a324739581', '4be5c320-c2e0-58e2-ad46-01bf916580a2', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('34e8a580-914d-5b79-8fb6-bff90fc86bd0', '4be5c320-c2e0-58e2-ad46-01bf916580a2', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d9af047e-bc47-5acc-b7eb-d6801b6c28bb', '4be5c320-c2e0-58e2-ad46-01bf916580a2', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a87f9c30-db61-5d70-ab51-235ad0c4494f', '4be5c320-c2e0-58e2-ad46-01bf916580a2', 9, $md$ix$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c86837d3-b8f2-5731-a861-0b9c77a0096e', '4be5c320-c2e0-58e2-ad46-01bf916580a2', 10, $md$x$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('69240745-b50b-50c2-a834-65f45d47dd2c', '6e3ee1b0-1a52-59ad-9a0e-b73963b4e5ad', 5, 'MATCHING_HEADING', 'READING', 3, $md$### Question 5

Questions 1-7
Questions 1-7
Reading Passage 1 has seven paragraphs,
A-G
.
Choose the most suitable heading for paragraphs
A-G
from the list of headings below.
Write the appropriate number,
i-x
, in boxes
1-7
on your answer sheet.
List of Headings
i
General points of agreements and disagreements of researchers
ii
How much children really know about food
iii
Need to take action
iv
Advertising effects of the “Big Four”
v
Connection of advertising and children’s weight problems
vi
Evidence that advertising affects what children buy to eat
vii
How parents influence children’s eating habits
viii
Advertising’s focus on unhealthy options
ix
Children often buy what they want
x
Underestimating the effects advertising has on children
1
Paragraph A
2
Paragraph B
3
Paragraph C
4
Paragraph D
5
Paragraph E
6
Paragraph F
7
Paragraph G

5 ____ Paragraph E$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e89b91e0-c45a-5ac1-a354-497beb547c0b', '69240745-b50b-50c2-a834-65f45d47dd2c', 1, $md$i$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('de0aefa5-76e1-53a3-acc4-239f907cdca1', '69240745-b50b-50c2-a834-65f45d47dd2c', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('67f2f6d3-f931-5ef5-aa74-9b7c87369a53', '69240745-b50b-50c2-a834-65f45d47dd2c', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6df61047-7947-5f48-a4a5-eedbe192fde2', '69240745-b50b-50c2-a834-65f45d47dd2c', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b10e56ff-1faa-5e5d-869e-ae03352c3430', '69240745-b50b-50c2-a834-65f45d47dd2c', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bd7d6700-4470-5a8c-9099-dde1a8c05e6b', '69240745-b50b-50c2-a834-65f45d47dd2c', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a23fc1d0-d4d6-55ad-9971-e795c3c4a7d6', '69240745-b50b-50c2-a834-65f45d47dd2c', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d78ced92-b1e6-51b8-93c0-6140059b0692', '69240745-b50b-50c2-a834-65f45d47dd2c', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c2b40500-69ed-5058-917a-ef2920710f02', '69240745-b50b-50c2-a834-65f45d47dd2c', 9, $md$ix$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6f91fc78-056d-5fd2-88b7-6ac49e0962e6', '69240745-b50b-50c2-a834-65f45d47dd2c', 10, $md$x$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('64419e2d-e021-5d27-90ba-82f179ab477b', '6e3ee1b0-1a52-59ad-9a0e-b73963b4e5ad', 6, 'MATCHING_HEADING', 'READING', 3, $md$### Question 6

Questions 1-7
Questions 1-7
Reading Passage 1 has seven paragraphs,
A-G
.
Choose the most suitable heading for paragraphs
A-G
from the list of headings below.
Write the appropriate number,
i-x
, in boxes
1-7
on your answer sheet.
List of Headings
i
General points of agreements and disagreements of researchers
ii
How much children really know about food
iii
Need to take action
iv
Advertising effects of the “Big Four”
v
Connection of advertising and children’s weight problems
vi
Evidence that advertising affects what children buy to eat
vii
How parents influence children’s eating habits
viii
Advertising’s focus on unhealthy options
ix
Children often buy what they want
x
Underestimating the effects advertising has on children
1
Paragraph A
2
Paragraph B
3
Paragraph C
4
Paragraph D
5
Paragraph E
6
Paragraph F
7
Paragraph G

6 ____ Paragraph F$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('36d0d429-91a5-5379-aa87-f1cb84c4eb1f', '64419e2d-e021-5d27-90ba-82f179ab477b', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('378c1c50-2abc-584d-874a-fc81283bb2f7', '64419e2d-e021-5d27-90ba-82f179ab477b', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0cc56818-2012-51a3-b9c6-e24ee8767e3a', '64419e2d-e021-5d27-90ba-82f179ab477b', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('220beac8-36f5-5dc9-8496-b2a9e4aa09e8', '64419e2d-e021-5d27-90ba-82f179ab477b', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b17a8ced-f33b-519e-80b2-d41903268df9', '64419e2d-e021-5d27-90ba-82f179ab477b', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('771059fa-c0bb-53b9-aa72-ef27ed9e8ccc', '64419e2d-e021-5d27-90ba-82f179ab477b', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('06a46849-be96-597b-88c6-36d199bec9d3', '64419e2d-e021-5d27-90ba-82f179ab477b', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('24c6acd4-3654-584d-b672-45921c5e7d95', '64419e2d-e021-5d27-90ba-82f179ab477b', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('35da2caf-f3ed-555e-94f7-385ff26436c0', '64419e2d-e021-5d27-90ba-82f179ab477b', 9, $md$ix$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('177e78bb-b37e-5bcb-a7b3-4f970cda0c5d', '64419e2d-e021-5d27-90ba-82f179ab477b', 10, $md$x$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('ec8b904c-301f-55ba-b1fb-4683bf0a304e', '6e3ee1b0-1a52-59ad-9a0e-b73963b4e5ad', 7, 'MATCHING_HEADING', 'READING', 3, $md$### Question 7

Questions 1-7
Questions 1-7
Reading Passage 1 has seven paragraphs,
A-G
.
Choose the most suitable heading for paragraphs
A-G
from the list of headings below.
Write the appropriate number,
i-x
, in boxes
1-7
on your answer sheet.
List of Headings
i
General points of agreements and disagreements of researchers
ii
How much children really know about food
iii
Need to take action
iv
Advertising effects of the “Big Four”
v
Connection of advertising and children’s weight problems
vi
Evidence that advertising affects what children buy to eat
vii
How parents influence children’s eating habits
viii
Advertising’s focus on unhealthy options
ix
Children often buy what they want
x
Underestimating the effects advertising has on children
1
Paragraph A
2
Paragraph B
3
Paragraph C
4
Paragraph D
5
Paragraph E
6
Paragraph F
7
Paragraph G

7 ____ Paragraph G$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3ade4e1b-027e-5fb4-b4ab-8434421c4ebe', 'ec8b904c-301f-55ba-b1fb-4683bf0a304e', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9c60fc09-aafa-53b3-ad56-5f6e0813203e', 'ec8b904c-301f-55ba-b1fb-4683bf0a304e', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bd60b990-1907-59bd-88d2-7d303dabf3f2', 'ec8b904c-301f-55ba-b1fb-4683bf0a304e', 3, $md$iii$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('dda0f264-dd71-56ce-923d-09922f00e529', 'ec8b904c-301f-55ba-b1fb-4683bf0a304e', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0d4d2927-31aa-51e4-a6a2-92c5af80e143', 'ec8b904c-301f-55ba-b1fb-4683bf0a304e', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cb365875-38d0-5dec-8986-e00b10a26f14', 'ec8b904c-301f-55ba-b1fb-4683bf0a304e', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('77df8f75-3b3f-5721-b3c4-4449f073a0ad', 'ec8b904c-301f-55ba-b1fb-4683bf0a304e', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1092d730-fc5f-5dc1-b928-8a20c9b4914d', 'ec8b904c-301f-55ba-b1fb-4683bf0a304e', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('83982551-a64e-52d9-a80d-7a5ba683c7d6', 'ec8b904c-301f-55ba-b1fb-4683bf0a304e', 9, $md$ix$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('617d1c20-c029-5953-8fa9-2c48dd58ebfd', 'ec8b904c-301f-55ba-b1fb-4683bf0a304e', 10, $md$x$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('06c3dfa2-835a-539a-be7a-4eda5159db9d', '6e3ee1b0-1a52-59ad-9a0e-b73963b4e5ad', 8, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 8

Questions 8-13
Questions 8-13
Do the following statements agree with the views of the writer in Reading Passage 1?
In boxes
8-13
on your answer sheet, write
YES
if the statement agrees with the views of the writer
NO
if the statement contradicts with the views of the writer
NOT
GIVEN
if it is impossible to say what the writer thinks about this
8
There is little difference between the healthy diet recommended by advisors and diet prompted in food advertisements.
9
TV advertising has successfully taught children nutritional knowledge about vitamins and others.
10
It is hard to decide which aspect accompanied by TV viewing has caused weight problems or other detrimental effects on children.
11
The preference of food for children is affected by their age and gender.
12
The investigation primarily for food promotion on TV advertising tend to be partial and incomplete
13
Wealthy parents tend to buy more “sensible food” for their children.

8 ____ There is little difference between the healthy diet recommended by advisors and diet prompted in food advertisements.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('689c62ae-fe96-5e9c-888c-4fb49f3ad23e', '06c3dfa2-835a-539a-be7a-4eda5159db9d', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2f9c4567-fb2c-5f86-af40-b8d5c0aaad4d', '06c3dfa2-835a-539a-be7a-4eda5159db9d', 2, $md$NO$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('662db478-633b-5a62-a011-5729d38e5ebe', '06c3dfa2-835a-539a-be7a-4eda5159db9d', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('2e3a8eec-405f-5f98-a9da-27475fa39c65', '6e3ee1b0-1a52-59ad-9a0e-b73963b4e5ad', 9, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 9

Questions 8-13
Questions 8-13
Do the following statements agree with the views of the writer in Reading Passage 1?
In boxes
8-13
on your answer sheet, write
YES
if the statement agrees with the views of the writer
NO
if the statement contradicts with the views of the writer
NOT
GIVEN
if it is impossible to say what the writer thinks about this
8
There is little difference between the healthy diet recommended by advisors and diet prompted in food advertisements.
9
TV advertising has successfully taught children nutritional knowledge about vitamins and others.
10
It is hard to decide which aspect accompanied by TV viewing has caused weight problems or other detrimental effects on children.
11
The preference of food for children is affected by their age and gender.
12
The investigation primarily for food promotion on TV advertising tend to be partial and incomplete
13
Wealthy parents tend to buy more “sensible food” for their children.

9 ____ TV advertising has successfully taught children nutritional knowledge about vitamins and others.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('05dd07ef-74aa-5dc7-a3ae-676100db56ef', '2e3a8eec-405f-5f98-a9da-27475fa39c65', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6e11472e-3e8b-5dec-b65e-3fddc71fe64b', '2e3a8eec-405f-5f98-a9da-27475fa39c65', 2, $md$NO$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('02c003db-e0a8-5e59-96ea-2750dea57965', '2e3a8eec-405f-5f98-a9da-27475fa39c65', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('828350f1-7183-5b97-9c65-95bc08aa653e', '6e3ee1b0-1a52-59ad-9a0e-b73963b4e5ad', 10, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 10

Questions 8-13
Questions 8-13
Do the following statements agree with the views of the writer in Reading Passage 1?
In boxes
8-13
on your answer sheet, write
YES
if the statement agrees with the views of the writer
NO
if the statement contradicts with the views of the writer
NOT
GIVEN
if it is impossible to say what the writer thinks about this
8
There is little difference between the healthy diet recommended by advisors and diet prompted in food advertisements.
9
TV advertising has successfully taught children nutritional knowledge about vitamins and others.
10
It is hard to decide which aspect accompanied by TV viewing has caused weight problems or other detrimental effects on children.
11
The preference of food for children is affected by their age and gender.
12
The investigation primarily for food promotion on TV advertising tend to be partial and incomplete
13
Wealthy parents tend to buy more “sensible food” for their children.

10 ____ It is hard to decide which aspect accompanied by TV viewing has caused weight problems or other detrimental effects on children.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9ed1d325-a1bc-58a5-9821-7b201256c648', '828350f1-7183-5b97-9c65-95bc08aa653e', 1, $md$YES$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('82c81e8b-9773-566c-a16d-5a52e2253a76', '828350f1-7183-5b97-9c65-95bc08aa653e', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1bc3377f-2f44-5bd7-8ee3-13b87fb59a6e', '828350f1-7183-5b97-9c65-95bc08aa653e', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('df9fab36-3dbd-546b-a26e-da3f998d44fc', '6e3ee1b0-1a52-59ad-9a0e-b73963b4e5ad', 11, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 11

Questions 8-13
Questions 8-13
Do the following statements agree with the views of the writer in Reading Passage 1?
In boxes
8-13
on your answer sheet, write
YES
if the statement agrees with the views of the writer
NO
if the statement contradicts with the views of the writer
NOT
GIVEN
if it is impossible to say what the writer thinks about this
8
There is little difference between the healthy diet recommended by advisors and diet prompted in food advertisements.
9
TV advertising has successfully taught children nutritional knowledge about vitamins and others.
10
It is hard to decide which aspect accompanied by TV viewing has caused weight problems or other detrimental effects on children.
11
The preference of food for children is affected by their age and gender.
12
The investigation primarily for food promotion on TV advertising tend to be partial and incomplete
13
Wealthy parents tend to buy more “sensible food” for their children.

11 ____ The preference of food for children is affected by their age and gender.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f65c22b2-d705-56c8-a100-59434c4c87a9', 'df9fab36-3dbd-546b-a26e-da3f998d44fc', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c60513cb-5ea4-53a3-bf55-3b715e95665f', 'df9fab36-3dbd-546b-a26e-da3f998d44fc', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('948deab8-a057-559c-8533-4e30072341b9', 'df9fab36-3dbd-546b-a26e-da3f998d44fc', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('1a13c1d2-88a0-5fe1-b8ac-ec77d3a8d39d', '6e3ee1b0-1a52-59ad-9a0e-b73963b4e5ad', 12, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 12

Questions 8-13
Questions 8-13
Do the following statements agree with the views of the writer in Reading Passage 1?
In boxes
8-13
on your answer sheet, write
YES
if the statement agrees with the views of the writer
NO
if the statement contradicts with the views of the writer
NOT
GIVEN
if it is impossible to say what the writer thinks about this
8
There is little difference between the healthy diet recommended by advisors and diet prompted in food advertisements.
9
TV advertising has successfully taught children nutritional knowledge about vitamins and others.
10
It is hard to decide which aspect accompanied by TV viewing has caused weight problems or other detrimental effects on children.
11
The preference of food for children is affected by their age and gender.
12
The investigation primarily for food promotion on TV advertising tend to be partial and incomplete
13
Wealthy parents tend to buy more “sensible food” for their children.

12 ____ The investigation primarily for food promotion on TV advertising tend to be partial and incomplete$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('de0ba231-0d74-5a87-ba8b-9c09345e9dda', '1a13c1d2-88a0-5fe1-b8ac-ec77d3a8d39d', 1, $md$YES$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('50a16104-bfe2-5d45-b150-eeb8576ae45a', '1a13c1d2-88a0-5fe1-b8ac-ec77d3a8d39d', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3f7b57e0-004f-51d6-8637-c5ff80f0f307', '1a13c1d2-88a0-5fe1-b8ac-ec77d3a8d39d', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('52b46688-42e7-59fc-a6f4-779271100abf', '6e3ee1b0-1a52-59ad-9a0e-b73963b4e5ad', 13, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 13

Questions 8-13
Questions 8-13
Do the following statements agree with the views of the writer in Reading Passage 1?
In boxes
8-13
on your answer sheet, write
YES
if the statement agrees with the views of the writer
NO
if the statement contradicts with the views of the writer
NOT
GIVEN
if it is impossible to say what the writer thinks about this
8
There is little difference between the healthy diet recommended by advisors and diet prompted in food advertisements.
9
TV advertising has successfully taught children nutritional knowledge about vitamins and others.
10
It is hard to decide which aspect accompanied by TV viewing has caused weight problems or other detrimental effects on children.
11
The preference of food for children is affected by their age and gender.
12
The investigation primarily for food promotion on TV advertising tend to be partial and incomplete
13
Wealthy parents tend to buy more “sensible food” for their children.

13 ____ Wealthy parents tend to buy more “sensible food” for their children.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('29231922-f23a-5b78-a427-3d15c6aa0dff', '52b46688-42e7-59fc-a6f4-779271100abf', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b38758aa-d603-58b8-87e4-379d247e6c31', '52b46688-42e7-59fc-a6f4-779271100abf', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c86891e6-dfc0-53b1-844f-9ab5220bf208', '52b46688-42e7-59fc-a6f4-779271100abf', 3, $md$NOT GIVEN$md$, true);

COMMIT;
