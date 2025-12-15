BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-spider-silk-2-1377'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-spider-silk-2-1377';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-spider-silk-2-1377';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-spider-silk-2-1377';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('f3d185a3-29d5-5245-ac76-7ecfb2b888a6', 'ielts-reading-spider-silk-2-1377', $t$Spider silk 2$t$, $md$## Spider silk 2

Nguồn:
- Test: https://mini-ielts.com/1377/reading/spider-silk-2
- Solution: https://mini-ielts.com/1377/view-solution/reading/spider-silk-2$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('5ac9a9d2-b611-5b52-8a8a-8b01e43bc7e7', 'f3d185a3-29d5-5245-ac76-7ecfb2b888a6', 1, $t$Reading — Spider silk 2$t$, $md$Read the passage and answer questions **1–13**.

### Passage: Spider silk 2

A strong, light bio-material made by genes from spiders could transform construction and industry

A

Scientists have succeeded in copying the silk-producing genes of the Golden Orb Weaver spider and are using them to create a synthetic material which they believe is the model for a new generation of advanced bio-materials. The new material, biosilk, which has been spun for the first time by researchers at DuPont, has an enormous range of potential uses in construction and manufacturing.

B

The attraction of the silk spun by the spider is a combination of great strength and enormous elasticity, which man-made fibres have been unable to replicate. On an equal-weight basis, spider silk is far stronger than steel and it is estimated that if a single strand could be made about 10m in diameter, it would be strong enough to stop a jumbo jet in flight. A third important factor is that it is extremely light. Army scientists are already looking at the possibilities of using it for lightweight, bulletproof vests and parachutes.

C

For some time, biochemists have been trying to synthesise the drag-line silk of the Golden Orb Weaver. The drag-line silk, which forms the radial arms of the web, is stronger than the other parts of the web and some biochemists believe a synthetic version could prove to be as important a material as nylon, which has been around for 50 years, since the discoveries of Wallace Carothers and his team ushered in the age of polymers.

D

To recreate the material, scientists, including Randolph Lewis at the University of Wyoming, first examined the silk-producing gland of the spider. ‘We took out the glands that produce the silk and looked at the coding for the protein material they make, which is spun into a web. We then went looking for clones with the right DNA,’ he says.

E

At DuPont, researchers have used both yeast and bacteria as hosts to grow the raw material, which they have spun into fibres. Robert Dorsch, DuPont’s director of biochemical development, says the globules of protein, comparable with marbles in an egg, are harvested and processed. ‘We break open the bacteria, separate out the globules of protein and use them as the raw starting material. With yeast, the gene system can be designed so that the material excretes the protein outside the yeast for better access,’ he says.

F

‘The bacteria and the yeast produce the same protein, equivalent to that which the spider uses in the draglines of the web. The spider mixes the protein into a water-based solution and then spins it into a solid fibre in one go. Since we are not as clever as the spider and we are not using such sophisticated organisms, we substituted man-made approaches and dissolved the protein in chemical solvents, which are then spun to push the material through small holes to form the solid fibre.’

G

Researchers at DuPont say they envisage many possible uses for a new biosilk material. They say that earthquake-resistant suspension bridges hung from cables of synthetic spider silk fibres may become a reality. Stronger ropes, safer seat belts, shoe soles that do not wear out so quickly and tough new clothing are among the other applications. Biochemists such as Lewis see the potential range of uses of biosilk as almost limitless. ‘It is very strong and retains elasticity: there are no man-made materials that can mimic both these properties. It is also a biological material with all the advantages that have over petrochemicals,’ he says.

H

At DuPont’s laboratories, Dorsch is excited by the prospect of new super-strong materials but he warns they are many years away. ‘We are at an early stage but theoretical predictions are that we will wind up with a very strong, tough material, with an ability to absorb shock, which is stronger and tougher than the man-made materials that are conventionally available to us,’ he says.

I

The spider is not the only creature that has aroused the interest of material scientists. They have also become envious of the natural adhesive secreted by the sea mussel. It produces a protein adhesive to attach itself to rocks. It is tedious and expensive to extract the protein from the mussel, so researchers have already produced a synthetic gene for use in surrogate bacteria.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('c05baad1-2ee1-542e-8161-f985bcd81e82', '5ac9a9d2-b611-5b52-8a8a-8b01e43bc7e7', 1, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 1

Questions 1-5
Questions 1-5
Reading Passage 1 has nine paragraphs,
A-I
Which paragraph contains the following information?
Write the correct letter,
A-I
, in boxes
1-5
on your answer sheet.
1
a comparison of the ways two materials are used to replace silk-producing glands
2
predictions regarding the availability of the synthetic silk
3
ongoing research into other synthetic materials
4
the research into the part of the spider that manufactures silk
5
the possible application of the silk in civil engineering

1 ____ a comparison of the ways two materials are used to replace silk-producing glands$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9ac6c108-63bb-5cfc-89f4-6b3116e36119', 'c05baad1-2ee1-542e-8161-f985bcd81e82', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('605977fe-df9f-5e7d-a2de-028af8b1beb9', 'c05baad1-2ee1-542e-8161-f985bcd81e82', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('966bcc49-4b15-5ed5-a47a-b9cb53d0936f', 'c05baad1-2ee1-542e-8161-f985bcd81e82', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8c082548-c9d2-55aa-844b-287ca3ca702a', 'c05baad1-2ee1-542e-8161-f985bcd81e82', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7dedc8dc-c0f3-5257-8b60-4ff93019cb46', 'c05baad1-2ee1-542e-8161-f985bcd81e82', 5, $md$E$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7f0a4b2e-8796-5676-aa34-e6d16d4ce3e1', 'c05baad1-2ee1-542e-8161-f985bcd81e82', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('763bcde7-0feb-5643-aab8-00e8ebaaeed0', 'c05baad1-2ee1-542e-8161-f985bcd81e82', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7283a13b-f7a5-56b1-b36d-975da0a57361', 'c05baad1-2ee1-542e-8161-f985bcd81e82', 8, $md$H$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9b2d292e-2222-5a0f-b3d0-187cf0164568', 'c05baad1-2ee1-542e-8161-f985bcd81e82', 9, $md$I$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('138a603b-5fec-5ccc-933d-7c1a3f2f4331', '5ac9a9d2-b611-5b52-8a8a-8b01e43bc7e7', 2, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 2

Questions 1-5
Questions 1-5
Reading Passage 1 has nine paragraphs,
A-I
Which paragraph contains the following information?
Write the correct letter,
A-I
, in boxes
1-5
on your answer sheet.
1
a comparison of the ways two materials are used to replace silk-producing glands
2
predictions regarding the availability of the synthetic silk
3
ongoing research into other synthetic materials
4
the research into the part of the spider that manufactures silk
5
the possible application of the silk in civil engineering

2 ____ predictions regarding the availability of the synthetic silk$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cafdc04c-3663-53ce-9a5f-7018c77229a0', '138a603b-5fec-5ccc-933d-7c1a3f2f4331', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ab6b2a1d-6330-59c9-974b-bcef095ac6ec', '138a603b-5fec-5ccc-933d-7c1a3f2f4331', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0314ee90-c174-50f7-b1b7-59ce1bd84c51', '138a603b-5fec-5ccc-933d-7c1a3f2f4331', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a2a51d53-da79-5d44-98c0-65aff3dd4aa4', '138a603b-5fec-5ccc-933d-7c1a3f2f4331', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3f9c9231-b3da-5e48-a385-761ada74e999', '138a603b-5fec-5ccc-933d-7c1a3f2f4331', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6b832648-137e-5262-8329-e68f036220c4', '138a603b-5fec-5ccc-933d-7c1a3f2f4331', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f668e0ef-8c58-5c70-aa09-e3a02344c13c', '138a603b-5fec-5ccc-933d-7c1a3f2f4331', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8a3790e4-3601-524a-b747-9a5805655a07', '138a603b-5fec-5ccc-933d-7c1a3f2f4331', 8, $md$H$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f49096dc-cc6b-5ecd-9261-6806113c5b0d', '138a603b-5fec-5ccc-933d-7c1a3f2f4331', 9, $md$I$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('2d5a1c19-0fdd-57ad-a60c-71ea1e3f9427', '5ac9a9d2-b611-5b52-8a8a-8b01e43bc7e7', 3, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 3

Questions 1-5
Questions 1-5
Reading Passage 1 has nine paragraphs,
A-I
Which paragraph contains the following information?
Write the correct letter,
A-I
, in boxes
1-5
on your answer sheet.
1
a comparison of the ways two materials are used to replace silk-producing glands
2
predictions regarding the availability of the synthetic silk
3
ongoing research into other synthetic materials
4
the research into the part of the spider that manufactures silk
5
the possible application of the silk in civil engineering

3 ____ ongoing research into other synthetic materials$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d4a1087e-8c29-59b5-8bf5-97aef62fe30a', '2d5a1c19-0fdd-57ad-a60c-71ea1e3f9427', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('09c9f7c9-3069-5c7d-b3c4-dab89e62b67e', '2d5a1c19-0fdd-57ad-a60c-71ea1e3f9427', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('80939bcb-e3c5-5a85-9a08-811f62451115', '2d5a1c19-0fdd-57ad-a60c-71ea1e3f9427', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5846b3ca-6b8f-589f-87fe-2fd260271670', '2d5a1c19-0fdd-57ad-a60c-71ea1e3f9427', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('eeb0054c-b6df-5dc1-a6f6-7b6257de48d8', '2d5a1c19-0fdd-57ad-a60c-71ea1e3f9427', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('337d7ce9-2265-5fb5-ae39-164b294327e1', '2d5a1c19-0fdd-57ad-a60c-71ea1e3f9427', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5898aec0-e333-5d90-bf82-d7838a46b234', '2d5a1c19-0fdd-57ad-a60c-71ea1e3f9427', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4a0d8999-82b2-5b77-a7cd-454fccee421a', '2d5a1c19-0fdd-57ad-a60c-71ea1e3f9427', 8, $md$H$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1f73cf73-e580-5862-9fa6-c254bbaa7fd5', '2d5a1c19-0fdd-57ad-a60c-71ea1e3f9427', 9, $md$I$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('c907e03d-22ab-5b88-a780-9d39df0afbfc', '5ac9a9d2-b611-5b52-8a8a-8b01e43bc7e7', 4, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 4

Questions 1-5
Questions 1-5
Reading Passage 1 has nine paragraphs,
A-I
Which paragraph contains the following information?
Write the correct letter,
A-I
, in boxes
1-5
on your answer sheet.
1
a comparison of the ways two materials are used to replace silk-producing glands
2
predictions regarding the availability of the synthetic silk
3
ongoing research into other synthetic materials
4
the research into the part of the spider that manufactures silk
5
the possible application of the silk in civil engineering

4 ____ the research into the part of the spider that manufactures silk$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d607ab5e-c852-5132-80dc-2db9bd39a8c7', 'c907e03d-22ab-5b88-a780-9d39df0afbfc', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('58e500fe-9f1f-5532-adf9-2ef140751479', 'c907e03d-22ab-5b88-a780-9d39df0afbfc', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d4ed34ed-611f-5d01-92a7-0468e059f540', 'c907e03d-22ab-5b88-a780-9d39df0afbfc', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0fcf4f48-5c13-58d0-aec8-68af9e648dca', 'c907e03d-22ab-5b88-a780-9d39df0afbfc', 4, $md$D$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('30cd4ebc-5b6e-5d09-ad39-cdcdb943bdd4', 'c907e03d-22ab-5b88-a780-9d39df0afbfc', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8ed98b48-cf78-54a1-a8cd-0c525881ac07', 'c907e03d-22ab-5b88-a780-9d39df0afbfc', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1064809a-b54b-5319-8e04-058c77d2daec', 'c907e03d-22ab-5b88-a780-9d39df0afbfc', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2235f93d-cb38-5f48-9288-ced92cb515d1', 'c907e03d-22ab-5b88-a780-9d39df0afbfc', 8, $md$H$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4c810b8d-0fbe-5fa6-bbab-0f69be4b2f1d', 'c907e03d-22ab-5b88-a780-9d39df0afbfc', 9, $md$I$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('d99014b4-c517-5555-87d9-f0b5cca7138b', '5ac9a9d2-b611-5b52-8a8a-8b01e43bc7e7', 5, 'MATCHING_INFORMATION', 'READING', 3, $md$### Question 5

Questions 1-5
Questions 1-5
Reading Passage 1 has nine paragraphs,
A-I
Which paragraph contains the following information?
Write the correct letter,
A-I
, in boxes
1-5
on your answer sheet.
1
a comparison of the ways two materials are used to replace silk-producing glands
2
predictions regarding the availability of the synthetic silk
3
ongoing research into other synthetic materials
4
the research into the part of the spider that manufactures silk
5
the possible application of the silk in civil engineering

5 ____ the possible application of the silk in civil engineering$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2282c70e-ca2f-5e3b-b9db-7c276bba37d4', 'd99014b4-c517-5555-87d9-f0b5cca7138b', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b166eb16-38fe-5b00-aca4-c2c2c54f71b6', 'd99014b4-c517-5555-87d9-f0b5cca7138b', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3421b1ed-e6b9-5167-81b5-7152260c5a3b', 'd99014b4-c517-5555-87d9-f0b5cca7138b', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('59648992-53a6-5210-95ef-5e3b086375db', 'd99014b4-c517-5555-87d9-f0b5cca7138b', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c765ba9c-cd8d-53c2-ac21-d778dac987ff', 'd99014b4-c517-5555-87d9-f0b5cca7138b', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7c5e2c32-b8ac-527d-b804-96cb89bde3c6', 'd99014b4-c517-5555-87d9-f0b5cca7138b', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ac0a1dc6-afbc-593e-91d4-880174bb57a3', 'd99014b4-c517-5555-87d9-f0b5cca7138b', 7, $md$G$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b5653d3d-216f-5fbe-9135-79f5b67047f7', 'd99014b4-c517-5555-87d9-f0b5cca7138b', 8, $md$H$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('281ca8b4-4f4e-58c1-afed-8e6ee1fc9c80', 'd99014b4-c517-5555-87d9-f0b5cca7138b', 9, $md$I$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('bfbc4c4c-4016-56d1-8914-2990454d6852', '5ac9a9d2-b611-5b52-8a8a-8b01e43bc7e7', 6, 'SHORT_ANSWER', 'READING', 3, $md$### Question 6

Questions 6-10
Questions 6-10
Complete the flow-chart below.
Choose
NO MORE THAN TWO WORDS
from the passage for each answer.
Write your answers in boxes
6-10
on your answer sheet.
Synthetic gene grown in
6
or
7
↓
globules of
8
.
↓
dissolved in
9
↓
passed through
10
↓
to produce a solid fibre

Synthetic gene grown in 6 ____ or 7 ____$md$, NULL, ARRAY['.*yeast.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('69ae3fd2-c99f-5de2-a2da-57b143a2f288', '5ac9a9d2-b611-5b52-8a8a-8b01e43bc7e7', 7, 'SHORT_ANSWER', 'READING', 3, $md$### Question 7

Questions 6-10
Questions 6-10
Complete the flow-chart below.
Choose
NO MORE THAN TWO WORDS
from the passage for each answer.
Write your answers in boxes
6-10
on your answer sheet.
Synthetic gene grown in
6
or
7
↓
globules of
8
.
↓
dissolved in
9
↓
passed through
10
↓
to produce a solid fibre

Synthetic gene grown in 6 ____ or 7 ____$md$, NULL, ARRAY['.*yeast.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('51365046-2a87-575f-92a1-89265b767727', '5ac9a9d2-b611-5b52-8a8a-8b01e43bc7e7', 8, 'SHORT_ANSWER', 'READING', 3, $md$### Question 8

Questions 6-10
Questions 6-10
Complete the flow-chart below.
Choose
NO MORE THAN TWO WORDS
from the passage for each answer.
Write your answers in boxes
6-10
on your answer sheet.
Synthetic gene grown in
6
or
7
↓
globules of
8
.
↓
dissolved in
9
↓
passed through
10
↓
to produce a solid fibre

globules of 8 ____ .$md$, NULL, ARRAY['.*protein.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('5df2b479-473b-50aa-a47b-a259359b7ebf', '5ac9a9d2-b611-5b52-8a8a-8b01e43bc7e7', 9, 'SHORT_ANSWER', 'READING', 3, $md$### Question 9

Questions 6-10
Questions 6-10
Complete the flow-chart below.
Choose
NO MORE THAN TWO WORDS
from the passage for each answer.
Write your answers in boxes
6-10
on your answer sheet.
Synthetic gene grown in
6
or
7
↓
globules of
8
.
↓
dissolved in
9
↓
passed through
10
↓
to produce a solid fibre

dissolved in 9 ____$md$, NULL, ARRAY['.*chemical.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('e9df0136-22e7-5c39-98e8-fcca4c4edace', '5ac9a9d2-b611-5b52-8a8a-8b01e43bc7e7', 10, 'SHORT_ANSWER', 'READING', 4, $md$### Question 10

Questions 6-10
Questions 6-10
Complete the flow-chart below.
Choose
NO MORE THAN TWO WORDS
from the passage for each answer.
Write your answers in boxes
6-10
on your answer sheet.
Synthetic gene grown in
6
or
7
↓
globules of
8
.
↓
dissolved in
9
↓
passed through
10
↓
to produce a solid fibre

passed through 10 ____$md$, NULL, ARRAY['.*holes.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('3d5f4ed3-eb12-5e39-93fe-638e5ad1a4be', '5ac9a9d2-b611-5b52-8a8a-8b01e43bc7e7', 11, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 11

Questions 11-13
Questions 11-13
Do the following statements agree with the information given in Reading Passage?
In boxes
11-13
on your answer sheet, write
TRUE
if the statement is true
FALSE
if the statement is false
NOT
GIVEN
if the information is not given in the passage
11
Biosilk has already replaced nylon in parachute manufacture.
12
The spider produces silk of varying strengths.
13
Lewis and Dorsch co-operated in the synthetic production of silk.

11 ____ Biosilk has already replaced nylon in parachute manufacture.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4ee97759-2a74-55d7-b4bd-9252da32901c', '3d5f4ed3-eb12-5e39-93fe-638e5ad1a4be', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('45959c23-f0fd-5071-bccc-69ca89525e31', '3d5f4ed3-eb12-5e39-93fe-638e5ad1a4be', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('83b679d8-a3ef-569e-bc04-8d42073f8f0c', '3d5f4ed3-eb12-5e39-93fe-638e5ad1a4be', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('847a44b2-4d53-50da-bcf5-1281e66d2c36', '5ac9a9d2-b611-5b52-8a8a-8b01e43bc7e7', 12, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 12

Questions 11-13
Questions 11-13
Do the following statements agree with the information given in Reading Passage?
In boxes
11-13
on your answer sheet, write
TRUE
if the statement is true
FALSE
if the statement is false
NOT
GIVEN
if the information is not given in the passage
11
Biosilk has already replaced nylon in parachute manufacture.
12
The spider produces silk of varying strengths.
13
Lewis and Dorsch co-operated in the synthetic production of silk.

12 ____ The spider produces silk of varying strengths.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8b9e7e0b-1515-5051-8e3f-a144d184a685', '847a44b2-4d53-50da-bcf5-1281e66d2c36', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f7921342-d822-5fec-a881-164cdc77c761', '847a44b2-4d53-50da-bcf5-1281e66d2c36', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3eb02a75-000e-54bb-9f39-a90a3e6b6093', '847a44b2-4d53-50da-bcf5-1281e66d2c36', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('7d3417aa-353b-54c7-8a34-2d699c053d37', '5ac9a9d2-b611-5b52-8a8a-8b01e43bc7e7', 13, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 13

Questions 11-13
Questions 11-13
Do the following statements agree with the information given in Reading Passage?
In boxes
11-13
on your answer sheet, write
TRUE
if the statement is true
FALSE
if the statement is false
NOT
GIVEN
if the information is not given in the passage
11
Biosilk has already replaced nylon in parachute manufacture.
12
The spider produces silk of varying strengths.
13
Lewis and Dorsch co-operated in the synthetic production of silk.

13 ____ Lewis and Dorsch co-operated in the synthetic production of silk.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('76bbab7f-61db-53b0-844b-1a03b242fdda', '7d3417aa-353b-54c7-8a34-2d699c053d37', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('268361d4-e2ef-5db8-aff7-2abd76571d94', '7d3417aa-353b-54c7-8a34-2d699c053d37', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7ccce520-8dd9-514a-b934-6628785b2df0', '7d3417aa-353b-54c7-8a34-2d699c053d37', 3, $md$NOT GIVEN$md$, true);

COMMIT;
