BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-blue-footed-boobies-2-1348'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-blue-footed-boobies-2-1348';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-blue-footed-boobies-2-1348';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-blue-footed-boobies-2-1348';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('c028d075-f954-5c7c-ad88-ad550a735251', 'ielts-reading-blue-footed-boobies-2-1348', $t$Blue-footed Boobies 2$t$, $md$## Blue-footed Boobies 2

Nguồn:
- Test: https://mini-ielts.com/1348/reading/blue-footed-boobies-2
- Solution: https://mini-ielts.com/1348/view-solution/reading/blue-footed-boobies-2$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('ea3c1777-5af8-5add-a0ad-b82bef3b0689', 'c028d075-f954-5c7c-ad88-ad550a735251', 1, $t$Reading — Blue-footed Boobies 2$t$, $md$Read the passage and answer questions **1–13**.

### Passage: Blue-footed Boobies 2

A

Boobies are a small group of seabirds native to tropical and subtropical oceans throughout the world. Their diet consists mainly of fish. They are specialized fish eaters feeding on small school fish like sardines, anchovies, mackerel, and flying fish. When their prey is in sight, they fold their long wings back around their streamlined bodies and plunge into the water from as high as 80 feet, so streamlined they barely make a splash. They travel in parties of about 12 to areas of water with large schools of small fish. When the lead bird sees a fish shoal in the water, it will signal the rest of the group and they will all dive together. Surprisingly, individuals do not eat with the hunting group, preferring to eat on their own, usually in the early morning or late afternoon.

B

There are three varieties on the Galapagos: the blue-footed, red-footed, and masked boobies. They are all members of the same family, and are not only different in appearance but also in behaviours. The blue-footed and red-footed boobies mate throughout the year, while the masked boobies have an annual mating cycle that differs from island to island. All catch fish in a similar manner, but in different areas: the blue-footed booby does its fishing close to shore, while the masked booby goes slightly farther out, and the red-footed booby fishes at the farthest distances from shore.

C

Although it is unknown where the name “Booby” emanates from, some conjecture it may come from the Spanish word for clown, “bobo”, meaning “stupid”. Its name was probably inspired by the bird’s clumsiness on land and apparently unwarranted bravery. The blue footed booby is extremely vulnerable to human visitors because it does not appear to fear them. Therefore these birds received such name for their clumsiness on land in which they were easy, captured, killed, and eaten by humans.

D

The blue-footed booby’s characteristic feet play a significant part in their famous courtship ceremony, the ‘booby dance’. The male walks around the female, raising his bright blue feet straight up in the air while bringing his ‘shoulders’ towards the ground and crossing the bottom tips of his wings high above the ground. Plus he’ll raise his bill up towards the sky to try to win his mate over. The female may also partake in these activities – lifting her feet, sky pointing, and of course, squawking at her mate. After mating, another ritual occurs – the nest-building which ironically is never used because they nest on the bare ground. When the female is ready to lay her eggs, they scrape the existing nest away so she can nest on exposed ground. Sun-baked islands form the booby’s breeding grounds. When ready the female Blue Footed Booby lays one to three eggs.

E

After mating, two or three eggs are laid in a shallow depression on flat or gently sloping ground. Both male and female take turns incubating the eggs. Unlike most birds, booby doesn’t develop brood patches (areas of bare skin on the breast) to warm the eggs during incubation. Instead, it uses its broad webbed feet, which have large numbers of prominent blood vessels, to transmit heat essential for incubation. The eggs are thick-shelled so they can withstand the full weight of an incubating bird.

F

After hatching, the male plays a major role in bringing fish home. He can bring back a constant supply of small fish for the chicks, which must be fed continuously. The reason is that the male has a longer tail than the female in relation to his body size, which makes him able to execute shallower dives and to feed closer to shore. Then the female takes a greater part as time proceeds. Sooner or later, the need to feed the young becomes greater than the need to protect them and both adults must fish to provide enough.

G

When times are good, the parents may successfully fledge all three chicks, but, in harder times, they may still lay as many eggs yet only obtain enough food to raise one. The problem is usually solved by the somewhat callous-sounding system of “opportunistic sibling murder.” The first-born chick is larger and stronger than its nest mate(s) as a result of hatching a few days earlier and also because the parents feed the larger chick. If food is scarce, the first born will get more food than its nest mate(s) and will outcompete them, causing them to starve. The above system optimizes the reproductive capacity of the blue-foot in an unpredictable environment. The system ensures that, if possible, at least one chick will survive a period of shortage rather than all three dying of starvation under a more ‘humane’ system.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('40d770aa-e354-528c-9b1f-becbf6ccc45f', 'ea3c1777-5af8-5add-a0ad-b82bef3b0689', 1, 'MATCHING_HEADING', 'READING', 2, $md$### Question 1

Questions 1-6
Questions 1-6
The reading passage has seven paragraphs,
A-G
Choose the correct heading for paragraphs
A-G
from the list below.
Write the correct number,
i-ix
, in boxes
1-6
on your answer sheet.
List of Headings
i
Unusual way of hatching the chicks
ii
Feeding habit of the red-footed booby
iii
Folding wings for purpose
iv
Rearing the young
v
Classification of boobies
vi
Diving for seafood
vii
Surviving mechanism during the food shortage period
viii
Mating and breeding
ix
Origin of the booby’s name
1
Paragraph A
2
Paragraph B
Example Answer
Paragraph
C ix
3
Paragraph D
4
Paragraph E
5
Paragraph F
6
Paragraph G

1 ____ Paragraph A$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2ac665e6-fb87-59d8-a214-453b94f564c5', '40d770aa-e354-528c-9b1f-becbf6ccc45f', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b3a15bb7-d1e3-5016-8a8e-6c6057ed0407', '40d770aa-e354-528c-9b1f-becbf6ccc45f', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0f85ff9e-feb5-560b-a557-485a4f368553', '40d770aa-e354-528c-9b1f-becbf6ccc45f', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('64f06e4f-547e-563f-ba47-8319553a8d8b', '40d770aa-e354-528c-9b1f-becbf6ccc45f', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4c8fd2f8-a10a-52b6-8a07-e480906d399c', '40d770aa-e354-528c-9b1f-becbf6ccc45f', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('da2625b4-8c29-566e-bf3c-5b55dca4b9c9', '40d770aa-e354-528c-9b1f-becbf6ccc45f', 6, $md$vi$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b0da11f1-b0d1-50fb-931b-c69283b2affc', '40d770aa-e354-528c-9b1f-becbf6ccc45f', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2ed06855-fb6e-548f-b5b8-e89c5ac6e98c', '40d770aa-e354-528c-9b1f-becbf6ccc45f', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('db7a6ce9-7822-5361-895c-3b9d6eb347eb', '40d770aa-e354-528c-9b1f-becbf6ccc45f', 9, $md$ix$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('5648bf37-7991-5907-84ee-fef8aee67285', 'ea3c1777-5af8-5add-a0ad-b82bef3b0689', 2, 'MATCHING_HEADING', 'READING', 2, $md$### Question 2

Questions 1-6
Questions 1-6
The reading passage has seven paragraphs,
A-G
Choose the correct heading for paragraphs
A-G
from the list below.
Write the correct number,
i-ix
, in boxes
1-6
on your answer sheet.
List of Headings
i
Unusual way of hatching the chicks
ii
Feeding habit of the red-footed booby
iii
Folding wings for purpose
iv
Rearing the young
v
Classification of boobies
vi
Diving for seafood
vii
Surviving mechanism during the food shortage period
viii
Mating and breeding
ix
Origin of the booby’s name
1
Paragraph A
2
Paragraph B
Example Answer
Paragraph
C ix
3
Paragraph D
4
Paragraph E
5
Paragraph F
6
Paragraph G

2 ____ Paragraph B$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ef61c14c-cedd-5285-8303-a9b1f34cc2ea', '5648bf37-7991-5907-84ee-fef8aee67285', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e0a9d9fd-35f9-55ed-9d75-588d29d3680f', '5648bf37-7991-5907-84ee-fef8aee67285', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('de019350-78bb-558c-86d7-670c2dfb3b21', '5648bf37-7991-5907-84ee-fef8aee67285', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c26defb1-0207-55e6-a87b-79b54a758dfd', '5648bf37-7991-5907-84ee-fef8aee67285', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8efd48c8-380f-50e4-b7e9-f5d27a070c51', '5648bf37-7991-5907-84ee-fef8aee67285', 5, $md$v$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2600c011-b067-53c9-b380-a26837872093', '5648bf37-7991-5907-84ee-fef8aee67285', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('55d31dfc-761d-5dae-a306-9c14c1ee0645', '5648bf37-7991-5907-84ee-fef8aee67285', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('317ba885-422e-5f24-80db-36f0e5ee4d54', '5648bf37-7991-5907-84ee-fef8aee67285', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('206e4fc7-df8a-5847-af49-0e2fc5bf5ba7', '5648bf37-7991-5907-84ee-fef8aee67285', 9, $md$ix$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('a2fc28f2-616b-5ff8-98ef-1560f70d5a14', 'ea3c1777-5af8-5add-a0ad-b82bef3b0689', 3, 'MATCHING_HEADING', 'READING', 2, $md$### Question 3

Questions 1-6
Questions 1-6
The reading passage has seven paragraphs,
A-G
Choose the correct heading for paragraphs
A-G
from the list below.
Write the correct number,
i-ix
, in boxes
1-6
on your answer sheet.
List of Headings
i
Unusual way of hatching the chicks
ii
Feeding habit of the red-footed booby
iii
Folding wings for purpose
iv
Rearing the young
v
Classification of boobies
vi
Diving for seafood
vii
Surviving mechanism during the food shortage period
viii
Mating and breeding
ix
Origin of the booby’s name
1
Paragraph A
2
Paragraph B
Example Answer
Paragraph
C ix
3
Paragraph D
4
Paragraph E
5
Paragraph F
6
Paragraph G

3 ____ Paragraph D$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ee870207-b5f9-5586-9455-06d6cfde3373', 'a2fc28f2-616b-5ff8-98ef-1560f70d5a14', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2dc07467-2b36-52ec-9d77-3e9dbb42db31', 'a2fc28f2-616b-5ff8-98ef-1560f70d5a14', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('476f82a3-54f9-55de-8222-87073d57c3d0', 'a2fc28f2-616b-5ff8-98ef-1560f70d5a14', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('641c844c-278f-5a25-b2ce-5cbaf4fd9595', 'a2fc28f2-616b-5ff8-98ef-1560f70d5a14', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('11da7def-788a-55e8-8f20-7a18a9a7cc23', 'a2fc28f2-616b-5ff8-98ef-1560f70d5a14', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9176a1df-66d4-5c99-b88f-d83a8eb4457d', 'a2fc28f2-616b-5ff8-98ef-1560f70d5a14', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fa61226a-097b-5ea4-accf-2480bf65dcde', 'a2fc28f2-616b-5ff8-98ef-1560f70d5a14', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('94aada36-e585-53f4-8960-02a2b0b833f7', 'a2fc28f2-616b-5ff8-98ef-1560f70d5a14', 8, $md$viii$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('627050ae-4d11-5122-8049-3ad605547f11', 'a2fc28f2-616b-5ff8-98ef-1560f70d5a14', 9, $md$ix$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('d43835b1-66c1-57b3-b801-f15dbb0882dc', 'ea3c1777-5af8-5add-a0ad-b82bef3b0689', 4, 'MATCHING_HEADING', 'READING', 2, $md$### Question 4

Questions 1-6
Questions 1-6
The reading passage has seven paragraphs,
A-G
Choose the correct heading for paragraphs
A-G
from the list below.
Write the correct number,
i-ix
, in boxes
1-6
on your answer sheet.
List of Headings
i
Unusual way of hatching the chicks
ii
Feeding habit of the red-footed booby
iii
Folding wings for purpose
iv
Rearing the young
v
Classification of boobies
vi
Diving for seafood
vii
Surviving mechanism during the food shortage period
viii
Mating and breeding
ix
Origin of the booby’s name
1
Paragraph A
2
Paragraph B
Example Answer
Paragraph
C ix
3
Paragraph D
4
Paragraph E
5
Paragraph F
6
Paragraph G

4 ____ Paragraph E$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('51404c97-623b-55a3-825d-9db0eeb07550', 'd43835b1-66c1-57b3-b801-f15dbb0882dc', 1, $md$i$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('feded89d-519f-55e9-8d28-b3ce71163a62', 'd43835b1-66c1-57b3-b801-f15dbb0882dc', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('13be9685-740d-5401-bfaa-b80aa4309386', 'd43835b1-66c1-57b3-b801-f15dbb0882dc', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('db3a3e13-4a8b-5ef0-9f05-951db81ac684', 'd43835b1-66c1-57b3-b801-f15dbb0882dc', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fbba4a58-e354-5fbf-a6bf-3bd9f04c09f2', 'd43835b1-66c1-57b3-b801-f15dbb0882dc', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4d5ccced-ee8a-5234-874a-291b2b3edf7a', 'd43835b1-66c1-57b3-b801-f15dbb0882dc', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a0067732-3cc8-546e-a0f6-14a7b99dd06b', 'd43835b1-66c1-57b3-b801-f15dbb0882dc', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0831d782-2abe-57f5-be15-5cd3a3461d72', 'd43835b1-66c1-57b3-b801-f15dbb0882dc', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('19ab82e5-b888-57d6-8bb3-ad2a6f81d6fc', 'd43835b1-66c1-57b3-b801-f15dbb0882dc', 9, $md$ix$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('6afafa68-5f4f-517c-9aa6-e771e627498e', 'ea3c1777-5af8-5add-a0ad-b82bef3b0689', 5, 'MATCHING_HEADING', 'READING', 3, $md$### Question 5

Questions 1-6
Questions 1-6
The reading passage has seven paragraphs,
A-G
Choose the correct heading for paragraphs
A-G
from the list below.
Write the correct number,
i-ix
, in boxes
1-6
on your answer sheet.
List of Headings
i
Unusual way of hatching the chicks
ii
Feeding habit of the red-footed booby
iii
Folding wings for purpose
iv
Rearing the young
v
Classification of boobies
vi
Diving for seafood
vii
Surviving mechanism during the food shortage period
viii
Mating and breeding
ix
Origin of the booby’s name
1
Paragraph A
2
Paragraph B
Example Answer
Paragraph
C ix
3
Paragraph D
4
Paragraph E
5
Paragraph F
6
Paragraph G

5 ____ Paragraph F$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0aa0909e-a9f1-53dd-a7ed-9e80277cc3e0', '6afafa68-5f4f-517c-9aa6-e771e627498e', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c5271ee3-367a-5bae-920a-494e738e4845', '6afafa68-5f4f-517c-9aa6-e771e627498e', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('11dcd066-24a5-5111-aa37-187b60ae8283', '6afafa68-5f4f-517c-9aa6-e771e627498e', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c544c482-7f40-5a81-ac95-a9ab07bcd472', '6afafa68-5f4f-517c-9aa6-e771e627498e', 4, $md$iv$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b6cb7083-7364-5060-970c-a20b7e2bc521', '6afafa68-5f4f-517c-9aa6-e771e627498e', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5e969e23-56e0-527a-8a29-d988de65e723', '6afafa68-5f4f-517c-9aa6-e771e627498e', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1cba9b09-7a87-501b-85b7-c55107984ccd', '6afafa68-5f4f-517c-9aa6-e771e627498e', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('01d9bfc9-a01a-58d3-8d04-2b0110a28418', '6afafa68-5f4f-517c-9aa6-e771e627498e', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e020b7b0-839e-5f93-b13d-6904d372969c', '6afafa68-5f4f-517c-9aa6-e771e627498e', 9, $md$ix$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('d498cd93-fa4c-5bdf-9282-db5f11e2198c', 'ea3c1777-5af8-5add-a0ad-b82bef3b0689', 6, 'MATCHING_HEADING', 'READING', 3, $md$### Question 6

Questions 1-6
Questions 1-6
The reading passage has seven paragraphs,
A-G
Choose the correct heading for paragraphs
A-G
from the list below.
Write the correct number,
i-ix
, in boxes
1-6
on your answer sheet.
List of Headings
i
Unusual way of hatching the chicks
ii
Feeding habit of the red-footed booby
iii
Folding wings for purpose
iv
Rearing the young
v
Classification of boobies
vi
Diving for seafood
vii
Surviving mechanism during the food shortage period
viii
Mating and breeding
ix
Origin of the booby’s name
1
Paragraph A
2
Paragraph B
Example Answer
Paragraph
C ix
3
Paragraph D
4
Paragraph E
5
Paragraph F
6
Paragraph G

6 ____ Paragraph G$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ec9e1545-fd7b-502a-8795-cf9f74624525', 'd498cd93-fa4c-5bdf-9282-db5f11e2198c', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f411dca1-7578-5609-ad44-07cdaca07039', 'd498cd93-fa4c-5bdf-9282-db5f11e2198c', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e8f82031-cca1-57e9-bbff-e8607aed5a7e', 'd498cd93-fa4c-5bdf-9282-db5f11e2198c', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('96380f91-9d9b-50ec-85c8-eb4cbd045af9', 'd498cd93-fa4c-5bdf-9282-db5f11e2198c', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0f22f1ab-40f2-5113-9a0d-86b930b9a618', 'd498cd93-fa4c-5bdf-9282-db5f11e2198c', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('29a4543b-e636-5f74-a492-57ea94de103c', 'd498cd93-fa4c-5bdf-9282-db5f11e2198c', 6, $md$vi$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3fcdbf35-6242-5651-8996-ef426091f3f9', 'd498cd93-fa4c-5bdf-9282-db5f11e2198c', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1dfe43db-d256-5701-a5df-67afcd3c66f5', 'd498cd93-fa4c-5bdf-9282-db5f11e2198c', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f506d821-60b9-5ac1-b94b-f74ae9485bef', 'd498cd93-fa4c-5bdf-9282-db5f11e2198c', 9, $md$ix$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('1d2b4b1c-e159-53cc-957d-36de9a4763b9', 'ea3c1777-5af8-5add-a0ad-b82bef3b0689', 7, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 7

Questions 7-9
Questions 7-9
Do the following statements agree with the information given in Reading Passage 1?
In boxes
7-9
on your answer sheet, write
TRUE
if the statement is true
FALSE
if the statement is false
NOT GIVEN
if the information is not given in the passage
7
Boobies are afraid of human approaching.
8
Female boobies eat more than the male ones.
9
When there is not sufficient food, the larger chicks will be fed at the expense of the survival of its smaller mates.

7 ____ Boobies are afraid of human approaching.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('544ac38b-b501-525a-9901-e2c89d5a0f86', '1d2b4b1c-e159-53cc-957d-36de9a4763b9', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('869c7e99-70dd-59d0-b226-ca3e440cbfe8', '1d2b4b1c-e159-53cc-957d-36de9a4763b9', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c0f49150-cd4f-5f7b-928a-64569e464f38', '1d2b4b1c-e159-53cc-957d-36de9a4763b9', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('7e03f93d-e2c9-5d1c-bdd9-275741706f61', 'ea3c1777-5af8-5add-a0ad-b82bef3b0689', 8, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 8

Questions 7-9
Questions 7-9
Do the following statements agree with the information given in Reading Passage 1?
In boxes
7-9
on your answer sheet, write
TRUE
if the statement is true
FALSE
if the statement is false
NOT GIVEN
if the information is not given in the passage
7
Boobies are afraid of human approaching.
8
Female boobies eat more than the male ones.
9
When there is not sufficient food, the larger chicks will be fed at the expense of the survival of its smaller mates.

8 ____ Female boobies eat more than the male ones.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('501f780a-63c7-5a4f-a968-17c7b71b6ce8', '7e03f93d-e2c9-5d1c-bdd9-275741706f61', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e11226eb-8da1-5076-897c-ef7ea820251d', '7e03f93d-e2c9-5d1c-bdd9-275741706f61', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('72f76a13-6fb9-5ebe-93c1-6aa3bf6864e4', '7e03f93d-e2c9-5d1c-bdd9-275741706f61', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('f33b868a-0dc1-5d51-b153-1de702094e76', 'ea3c1777-5af8-5add-a0ad-b82bef3b0689', 9, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 9

Questions 7-9
Questions 7-9
Do the following statements agree with the information given in Reading Passage 1?
In boxes
7-9
on your answer sheet, write
TRUE
if the statement is true
FALSE
if the statement is false
NOT GIVEN
if the information is not given in the passage
7
Boobies are afraid of human approaching.
8
Female boobies eat more than the male ones.
9
When there is not sufficient food, the larger chicks will be fed at the expense of the survival of its smaller mates.

9 ____ When there is not sufficient food, the larger chicks will be fed at the expense of the survival of its smaller mates.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('00b3ee00-4103-50d7-b225-d39b2e279d4d', 'f33b868a-0dc1-5d51-b153-1de702094e76', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8e194a2c-1d55-5e92-80f6-55c54a3c1cf4', 'f33b868a-0dc1-5d51-b153-1de702094e76', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bdbb48c8-29d6-5724-bb2e-d7f31d646bd0', 'f33b868a-0dc1-5d51-b153-1de702094e76', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('5ba8e68e-8904-5fd6-8bc1-c95a40a55335', 'ea3c1777-5af8-5add-a0ad-b82bef3b0689', 10, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 10

Questions 10 – 13
Questions 10 – 13
Complete the summary below.
Using
NO MORE THAN TWO WORDS
from the Reading Passage for each answer.
Write your answers in boxes
10-13
on your answer sheet.
The courtship of the Blue-footed Booby consists of the male flaunting his blue feet and dancing to impress the female. During the dance, the male will spread his wings and stamp his feet on the ground with his bills
10
. After mating, the booby’s unusual demeanor continues with ritual
11
that really serves no purpose. When the female Booby lays eggs, the parental boobies incubate the eggs beneath their
12
which contain
13
to transmit the heat, because of the lack of brood patches.

The courtship of the Blue-footed Booby consists of the male flaunting his blue feet and dancing to impress the female. During the dance, the male will spread his wings and stamp his feet on the ground with his bills 10 ____ . After mating, the booby’s unusual demeanor continues with ritual 11 ____ that really serves no purpose. When the female Booby lays eggs, the parental boobies incubate the eggs beneath their 12 ____ which contain 13 ____ to transmit the heat, because of the lack of brood patches.$md$, NULL, ARRAY['.*skypointing.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('f9ada2a6-9da2-56ae-8897-33b001c73922', 'ea3c1777-5af8-5add-a0ad-b82bef3b0689', 11, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 11

Questions 10 – 13
Questions 10 – 13
Complete the summary below.
Using
NO MORE THAN TWO WORDS
from the Reading Passage for each answer.
Write your answers in boxes
10-13
on your answer sheet.
The courtship of the Blue-footed Booby consists of the male flaunting his blue feet and dancing to impress the female. During the dance, the male will spread his wings and stamp his feet on the ground with his bills
10
. After mating, the booby’s unusual demeanor continues with ritual
11
that really serves no purpose. When the female Booby lays eggs, the parental boobies incubate the eggs beneath their
12
which contain
13
to transmit the heat, because of the lack of brood patches.

The courtship of the Blue-footed Booby consists of the male flaunting his blue feet and dancing to impress the female. During the dance, the male will spread his wings and stamp his feet on the ground with his bills 10 ____ . After mating, the booby’s unusual demeanor continues with ritual 11 ____ that really serves no purpose. When the female Booby lays eggs, the parental boobies incubate the eggs beneath their 12 ____ which contain 13 ____ to transmit the heat, because of the lack of brood patches.$md$, NULL, ARRAY['.*skypointing.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('2f7d32f8-b138-54c9-8abf-1739bf3b33ee', 'ea3c1777-5af8-5add-a0ad-b82bef3b0689', 12, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 12

Questions 10 – 13
Questions 10 – 13
Complete the summary below.
Using
NO MORE THAN TWO WORDS
from the Reading Passage for each answer.
Write your answers in boxes
10-13
on your answer sheet.
The courtship of the Blue-footed Booby consists of the male flaunting his blue feet and dancing to impress the female. During the dance, the male will spread his wings and stamp his feet on the ground with his bills
10
. After mating, the booby’s unusual demeanor continues with ritual
11
that really serves no purpose. When the female Booby lays eggs, the parental boobies incubate the eggs beneath their
12
which contain
13
to transmit the heat, because of the lack of brood patches.

The courtship of the Blue-footed Booby consists of the male flaunting his blue feet and dancing to impress the female. During the dance, the male will spread his wings and stamp his feet on the ground with his bills 10 ____ . After mating, the booby’s unusual demeanor continues with ritual 11 ____ that really serves no purpose. When the female Booby lays eggs, the parental boobies incubate the eggs beneath their 12 ____ which contain 13 ____ to transmit the heat, because of the lack of brood patches.$md$, NULL, ARRAY['.*skypointing.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('75edf613-9e0a-52b2-b59a-5b3e5c9e22b7', 'ea3c1777-5af8-5add-a0ad-b82bef3b0689', 13, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 13

Questions 10 – 13
Questions 10 – 13
Complete the summary below.
Using
NO MORE THAN TWO WORDS
from the Reading Passage for each answer.
Write your answers in boxes
10-13
on your answer sheet.
The courtship of the Blue-footed Booby consists of the male flaunting his blue feet and dancing to impress the female. During the dance, the male will spread his wings and stamp his feet on the ground with his bills
10
. After mating, the booby’s unusual demeanor continues with ritual
11
that really serves no purpose. When the female Booby lays eggs, the parental boobies incubate the eggs beneath their
12
which contain
13
to transmit the heat, because of the lack of brood patches.

The courtship of the Blue-footed Booby consists of the male flaunting his blue feet and dancing to impress the female. During the dance, the male will spread his wings and stamp his feet on the ground with his bills 10 ____ . After mating, the booby’s unusual demeanor continues with ritual 11 ____ that really serves no purpose. When the female Booby lays eggs, the parental boobies incubate the eggs beneath their 12 ____ which contain 13 ____ to transmit the heat, because of the lack of brood patches.$md$, NULL, ARRAY['.*skypointing.*']);

COMMIT;
