BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-cork-1140'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-cork-1140';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-cork-1140';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-cork-1140';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('8eb94ba7-4020-55ec-b169-89e5edc7249e', 'ielts-reading-cork-1140', $t$Cork$t$, $md$## Cork

Nguồn:
- Test: https://mini-ielts.com/1140/reading/cork
- Solution: https://mini-ielts.com/1140/view-solution/reading/cork$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('360a6462-9e96-589a-b69f-e1b34e9a1625', '8eb94ba7-4020-55ec-b169-89e5edc7249e', 1, $t$Reading — Cork$t$, $md$Read the passage and answer questions **1–13**.

### Passage: Cork

Cork - the thick bark of the cork oak tree (Quercus suber) - is a remarkable material. It is tough, elastic, buoyant, and fire-resistant, and suitable for a wide range of purposes. It has also been used for millennia: the ancient Egyptians sealed then sarcophagi (stone coffins) with cork, while the ancient Greeks and Romans used it for anything from beehives to sandals.

And the cork oak itself is an extraordinary tree. Its bark grows up to 20 cm in thickness, insulating the tree like a coat wrapped around the trunk and branches and keeping the inside at a constant 20°C all year round. Developed most probably as a defence against forest fires, the bark of the cork oak has a particular cellular structure - with about 40 million cells per cubic centimetre - that technology has never succeeded in replicating. The cells are filled with air, which is why cork is so buoyant. It also has an elasticity that means you can squash it and watch it spring back to its original size and shape when you release the pressure.

Cork oaks grow in a number of Mediterranean countries, including Portugal, Spain, Italy, Greece and Morocco. They flourish in warm, sunny climates where there is a minimum of 400 millimetres of rain per year, and no more than 800 millimetres. Like grape vines, the trees thrive in poor soil, putting down deep root in search of moisture and nutrients. Southern Portugal’s Alentejo region meets all of these requirements, which explains why, by the early 20th century, this region had become the world’s largest producer of cork, and why today it accounts for roughly half of all cork production around the world.

Most cork forests are family-owned. Many of these family businesses, and indeed many of the trees themselves, are around 200 years old. Cork production is, above all, an exercise in patience. From the planting of a cork sapling to the first harvest takes 25 years, and a gap of approximately a decade must separate harvests from an individual tree. And for top-quality cork, it’s necessary to wait a further 15 or 20 years. You even have to wait for the right kind of summer’s day to harvest cork. If the bark is stripped on a day when it’s too cold - or when the air is damp - the tree will be damaged.

Cork harvesting is a very specialised profession. No mechanical means of stripping cork bark has been invented, so the job is done by teams of highly skilled workers. First, they make vertical cuts down the bark using small sharp axes, then lever it away in pieces as large as they can manage. The most skilful cork- strippers prise away a semi-circular husk that runs the length of the trunk from just above ground level to the first branches. It is then dried on the ground for about four months, before being taken to factories, where it is boiled to kill any insects that might remain in the cork. Over 60% of cork then goes on to be made into traditional bottle stoppers, with most of the remainder being used in the construction trade, Corkboard and cork tiles are ideal for thermal and acoustic insulation, while granules of cork are used in the manufacture of concrete.

Recent years have seen the end of the virtual monopoly of cork as the material for bottle stoppers, due to concerns about the effect it may have on the contents of the bottle. This is caused by a chemical compound called 2,4,6-trichloroanisole (TCA), which forms through the interaction of plant phenols, chlorine and mould. The tiniest concentrations - as little as three or four parts to a trillion - can spoil the taste of the product contained in the bottle. The result has been a gradual yet steady move first towards plastic stoppers and, more recently, to aluminium screw caps. These substitutes are cheaper to manufacture and, in the case of screw caps, more convenient for the user.

The classic cork stopper does have several advantages, however. Firstly, its traditional image is more in keeping with that of the type of high quality goods with which it has long been associated. Secondly - and very importantly - cork is a sustainable product that can be recycled without difficulty. Moreover, cork forests are a resource which support local biodiversity , and prevent desertification in the regions where they are planted. So, given the current concerns about environmental issues, the future of this ancient material once again looks promising.

----------------------------------------------------

Great thanks to volunteer Lan Nguyen has contributed these explanations markings.

If you want to make a better world like this, please contact us.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('151684ac-d409-582c-90a5-ccefd8751e3d', '360a6462-9e96-589a-b69f-e1b34e9a1625', 1, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 1

Questions 1-5
Questions 1-5
Do the following statements agree with the information given in Reading Passage?
In boxes
1-5
on your answer sheet, write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
1
The cork oak has the thickest bark of any living tree.
2
Scientists have developed a synthetic cork with the same cellular structure as natural cork.
Locate
3
Individual cork oak trees must be left for 25 years between the first and second harvest.
Locate
4
Cork bark should be stripped in dry atmospheric conditions.
Locate
5
The only way to remove the bark from cork oak trees is by hand.
Locate

1 ____ The cork oak has the thickest bark of any living tree.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fe13bdd9-1b41-53a4-9c77-08b95590855b', '151684ac-d409-582c-90a5-ccefd8751e3d', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7ebd1a68-fa44-59f5-b3c5-05939ab48284', '151684ac-d409-582c-90a5-ccefd8751e3d', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('789c0fca-15ed-5eba-92b6-5e857edaa4a0', '151684ac-d409-582c-90a5-ccefd8751e3d', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('d2c65de2-2798-501f-8562-186e57d4b4b8', '360a6462-9e96-589a-b69f-e1b34e9a1625', 2, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 2

Questions 1-5
Questions 1-5
Do the following statements agree with the information given in Reading Passage?
In boxes
1-5
on your answer sheet, write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
1
The cork oak has the thickest bark of any living tree.
2
Scientists have developed a synthetic cork with the same cellular structure as natural cork.
Locate
3
Individual cork oak trees must be left for 25 years between the first and second harvest.
Locate
4
Cork bark should be stripped in dry atmospheric conditions.
Locate
5
The only way to remove the bark from cork oak trees is by hand.
Locate

2 ____ Scientists have developed a synthetic cork with the same cellular structure as natural cork. Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ccfd1aaf-f821-53fa-8d57-1019a65a258d', 'd2c65de2-2798-501f-8562-186e57d4b4b8', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('26cfcdfa-73fe-54c4-871f-5b94c553a3e8', 'd2c65de2-2798-501f-8562-186e57d4b4b8', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0ba7b17c-265c-5429-9933-3b2f349298d5', 'd2c65de2-2798-501f-8562-186e57d4b4b8', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('9b39e0fa-ef93-5fad-97b9-3133d67d8f27', '360a6462-9e96-589a-b69f-e1b34e9a1625', 3, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 3

Questions 1-5
Questions 1-5
Do the following statements agree with the information given in Reading Passage?
In boxes
1-5
on your answer sheet, write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
1
The cork oak has the thickest bark of any living tree.
2
Scientists have developed a synthetic cork with the same cellular structure as natural cork.
Locate
3
Individual cork oak trees must be left for 25 years between the first and second harvest.
Locate
4
Cork bark should be stripped in dry atmospheric conditions.
Locate
5
The only way to remove the bark from cork oak trees is by hand.
Locate

3 ____ Individual cork oak trees must be left for 25 years between the first and second harvest. Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('32804e1f-1e8b-5dee-8a8d-c570df3393a0', '9b39e0fa-ef93-5fad-97b9-3133d67d8f27', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4738def3-d37f-576a-8609-90e56fd53bb1', '9b39e0fa-ef93-5fad-97b9-3133d67d8f27', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('47609ff2-6ab2-5156-b921-d4f551865823', '9b39e0fa-ef93-5fad-97b9-3133d67d8f27', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('ea049c6d-0f86-5791-a136-9d4952956dad', '360a6462-9e96-589a-b69f-e1b34e9a1625', 4, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 4

Questions 1-5
Questions 1-5
Do the following statements agree with the information given in Reading Passage?
In boxes
1-5
on your answer sheet, write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
1
The cork oak has the thickest bark of any living tree.
2
Scientists have developed a synthetic cork with the same cellular structure as natural cork.
Locate
3
Individual cork oak trees must be left for 25 years between the first and second harvest.
Locate
4
Cork bark should be stripped in dry atmospheric conditions.
Locate
5
The only way to remove the bark from cork oak trees is by hand.
Locate

4 ____ Cork bark should be stripped in dry atmospheric conditions. Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('59392ccc-18ab-57ec-960e-3de5eb811f95', 'ea049c6d-0f86-5791-a136-9d4952956dad', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a39ae8bd-c1a1-5672-90e9-a7ccf2229a96', 'ea049c6d-0f86-5791-a136-9d4952956dad', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b5eb4398-086c-5dbb-a7f0-5f49964623e2', 'ea049c6d-0f86-5791-a136-9d4952956dad', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('6cbc2f4a-c827-5a91-a8d0-eb297a808eef', '360a6462-9e96-589a-b69f-e1b34e9a1625', 5, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 5

Questions 1-5
Questions 1-5
Do the following statements agree with the information given in Reading Passage?
In boxes
1-5
on your answer sheet, write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
1
The cork oak has the thickest bark of any living tree.
2
Scientists have developed a synthetic cork with the same cellular structure as natural cork.
Locate
3
Individual cork oak trees must be left for 25 years between the first and second harvest.
Locate
4
Cork bark should be stripped in dry atmospheric conditions.
Locate
5
The only way to remove the bark from cork oak trees is by hand.
Locate

5 ____ The only way to remove the bark from cork oak trees is by hand. Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e328aa61-1ee6-5b3a-ab00-6278db37fd34', '6cbc2f4a-c827-5a91-a8d0-eb297a808eef', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f42a3ecb-579e-5b9a-bb6c-e88079fc9f6c', '6cbc2f4a-c827-5a91-a8d0-eb297a808eef', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('41c96851-6928-5aa1-a3bb-4b33d7d89699', '6cbc2f4a-c827-5a91-a8d0-eb297a808eef', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('a2122346-6156-595d-8cef-61dab8234376', '360a6462-9e96-589a-b69f-e1b34e9a1625', 6, 'NOTE_COMPLETION', 'READING', 3, $md$### Question 6

Questions 6-13
Questions 6-13
Complete the notes below.
Choose
ONE WORD ONLY
from the passage for each answer.
Write your answers in boxes
6-13
on your answer sheet.
Comparison of aluminium screw caps and cork bottle stoppers
Advantages of aluminium screw caps
• do not affect the
6
of the bottle contents
Locate
• are
7
to produce
Locate
• are
8
to use
Locate
Advantages of cork bottle stoppers
• suit the
9
of quality products
Locate
• made from a
10
material
Locate
• easily
11
Locate
• cork forests aid
12
Locate
• cork forests stop
13
happening
Locate

• do not affect the 6 ____ of the bottle contents Locate$md$, NULL, ARRAY['.*taste.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('b191bf57-3086-5bf1-8259-8b4efeb9b076', '360a6462-9e96-589a-b69f-e1b34e9a1625', 7, 'NOTE_COMPLETION', 'READING', 3, $md$### Question 7

Questions 6-13
Questions 6-13
Complete the notes below.
Choose
ONE WORD ONLY
from the passage for each answer.
Write your answers in boxes
6-13
on your answer sheet.
Comparison of aluminium screw caps and cork bottle stoppers
Advantages of aluminium screw caps
• do not affect the
6
of the bottle contents
Locate
• are
7
to produce
Locate
• are
8
to use
Locate
Advantages of cork bottle stoppers
• suit the
9
of quality products
Locate
• made from a
10
material
Locate
• easily
11
Locate
• cork forests aid
12
Locate
• cork forests stop
13
happening
Locate

• are 7 ____ to produce Locate$md$, NULL, ARRAY['.*cheaper.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('07088d36-b1d0-549a-8c79-22487923a4b6', '360a6462-9e96-589a-b69f-e1b34e9a1625', 8, 'NOTE_COMPLETION', 'READING', 3, $md$### Question 8

Questions 6-13
Questions 6-13
Complete the notes below.
Choose
ONE WORD ONLY
from the passage for each answer.
Write your answers in boxes
6-13
on your answer sheet.
Comparison of aluminium screw caps and cork bottle stoppers
Advantages of aluminium screw caps
• do not affect the
6
of the bottle contents
Locate
• are
7
to produce
Locate
• are
8
to use
Locate
Advantages of cork bottle stoppers
• suit the
9
of quality products
Locate
• made from a
10
material
Locate
• easily
11
Locate
• cork forests aid
12
Locate
• cork forests stop
13
happening
Locate

• are 8 ____ to use Locate$md$, NULL, ARRAY['.*convenient.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('b9c61de6-daa3-5e76-a232-15173eb1f49a', '360a6462-9e96-589a-b69f-e1b34e9a1625', 9, 'NOTE_COMPLETION', 'READING', 3, $md$### Question 9

Questions 6-13
Questions 6-13
Complete the notes below.
Choose
ONE WORD ONLY
from the passage for each answer.
Write your answers in boxes
6-13
on your answer sheet.
Comparison of aluminium screw caps and cork bottle stoppers
Advantages of aluminium screw caps
• do not affect the
6
of the bottle contents
Locate
• are
7
to produce
Locate
• are
8
to use
Locate
Advantages of cork bottle stoppers
• suit the
9
of quality products
Locate
• made from a
10
material
Locate
• easily
11
Locate
• cork forests aid
12
Locate
• cork forests stop
13
happening
Locate

• suit the 9 ____ of quality products Locate$md$, NULL, ARRAY['.*image.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('887f937f-0a59-583d-90d0-17f66e4a37b2', '360a6462-9e96-589a-b69f-e1b34e9a1625', 10, 'NOTE_COMPLETION', 'READING', 4, $md$### Question 10

Questions 6-13
Questions 6-13
Complete the notes below.
Choose
ONE WORD ONLY
from the passage for each answer.
Write your answers in boxes
6-13
on your answer sheet.
Comparison of aluminium screw caps and cork bottle stoppers
Advantages of aluminium screw caps
• do not affect the
6
of the bottle contents
Locate
• are
7
to produce
Locate
• are
8
to use
Locate
Advantages of cork bottle stoppers
• suit the
9
of quality products
Locate
• made from a
10
material
Locate
• easily
11
Locate
• cork forests aid
12
Locate
• cork forests stop
13
happening
Locate

• made from a 10 ____ material Locate$md$, NULL, ARRAY['.*sustainable.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('f2a0f853-b6fe-5259-9fd5-b1405379161c', '360a6462-9e96-589a-b69f-e1b34e9a1625', 11, 'NOTE_COMPLETION', 'READING', 4, $md$### Question 11

Questions 6-13
Questions 6-13
Complete the notes below.
Choose
ONE WORD ONLY
from the passage for each answer.
Write your answers in boxes
6-13
on your answer sheet.
Comparison of aluminium screw caps and cork bottle stoppers
Advantages of aluminium screw caps
• do not affect the
6
of the bottle contents
Locate
• are
7
to produce
Locate
• are
8
to use
Locate
Advantages of cork bottle stoppers
• suit the
9
of quality products
Locate
• made from a
10
material
Locate
• easily
11
Locate
• cork forests aid
12
Locate
• cork forests stop
13
happening
Locate

• easily 11 ____ Locate$md$, NULL, ARRAY['.*recycled.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('855d9a3a-c239-5f70-ae70-8d4876219891', '360a6462-9e96-589a-b69f-e1b34e9a1625', 12, 'NOTE_COMPLETION', 'READING', 4, $md$### Question 12

Questions 6-13
Questions 6-13
Complete the notes below.
Choose
ONE WORD ONLY
from the passage for each answer.
Write your answers in boxes
6-13
on your answer sheet.
Comparison of aluminium screw caps and cork bottle stoppers
Advantages of aluminium screw caps
• do not affect the
6
of the bottle contents
Locate
• are
7
to produce
Locate
• are
8
to use
Locate
Advantages of cork bottle stoppers
• suit the
9
of quality products
Locate
• made from a
10
material
Locate
• easily
11
Locate
• cork forests aid
12
Locate
• cork forests stop
13
happening
Locate

• cork forests aid 12 ____ Locate$md$, NULL, ARRAY['.*biodiversity.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('10be1cd3-90b7-5451-be7b-249b8065fb1c', '360a6462-9e96-589a-b69f-e1b34e9a1625', 13, 'NOTE_COMPLETION', 'READING', 4, $md$### Question 13

Questions 6-13
Questions 6-13
Complete the notes below.
Choose
ONE WORD ONLY
from the passage for each answer.
Write your answers in boxes
6-13
on your answer sheet.
Comparison of aluminium screw caps and cork bottle stoppers
Advantages of aluminium screw caps
• do not affect the
6
of the bottle contents
Locate
• are
7
to produce
Locate
• are
8
to use
Locate
Advantages of cork bottle stoppers
• suit the
9
of quality products
Locate
• made from a
10
material
Locate
• easily
11
Locate
• cork forests aid
12
Locate
• cork forests stop
13
happening
Locate

• cork forests stop 13 ____ happening Locate$md$, NULL, ARRAY['.*desertification.*']);

COMMIT;
