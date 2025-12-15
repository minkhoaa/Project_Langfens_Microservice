BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-three-ways-to-levitate-a-magic-carpet-1225'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-three-ways-to-levitate-a-magic-carpet-1225';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-three-ways-to-levitate-a-magic-carpet-1225';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-three-ways-to-levitate-a-magic-carpet-1225';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('39968529-52d7-57d5-8be9-34cba199a7a6', 'ielts-reading-three-ways-to-levitate-a-magic-carpet-1225', $t$Three ways to Levitate a Magic Carpet$t$, $md$## Three ways to Levitate a Magic Carpet

Nguồn:
- Test: https://mini-ielts.com/1225/reading/three-ways-to-levitate-a-magic-carpet
- Solution: https://mini-ielts.com/1225/view-solution/reading/three-ways-to-levitate-a-magic-carpet$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('41aff34a-82ad-5a80-bd5e-3f4cf8727490', '39968529-52d7-57d5-8be9-34cba199a7a6', 1, $t$Reading — Three ways to Levitate a Magic Carpet$t$, $md$Read the passage and answer questions **1–13**.

### Passage: Three ways to Levitate a Magic Carpet

It sounds like a science fiction joke, but it isn’t. What do you get when you turn an invisibility cloak on its side? A mini flying carpet. So say physicists who believe the same exotic materials used to make cloaking devices could also be used to levitate tiny objects. In a further breakthrough, two other research groups have come a step closer to cracking the mysteries of levitation.

Scientists have levitated objects before, most famously using powerful magnetic fields to levitate a frog. But that technique, using the repulsive force of a giant magnet, requires large amounts of energy. In contrast, the latest theories exploit the natural smaller amounts of energy produced by the quantum fluctuations of empty space.

In May 2006, two research teams led by Ulf Leonhardt at St Andrew’s University, UK, and John Pendry at Imperial College, London, independently proposed that an invisibility cloak could be created from exotic materials with abnormal optical properties. Such a cloaking device – working in the microwave region – was manufactured later that year.

The device was formed from so-called ‘meta materia Is’ exotic materials made from complex arrays of metal units and wires. The metal units are smaller than the wavelength of light and so the materials can be engineered to precisely control how electromagnetic light waves travel around them. They can transform space, tricking electromagnetic waves into moving along directions they otherwise wouldn’t,’says Leonhardt.

Leonhardt and his colleague Thomas Philbin, also at St Andrew’s University, realised that this property could also be exploited to levitate extremely small objects. They propose inserting a metamaterial between two so-called Casimir plates. When two such plates are brought very close together, the vacuum between them becomes filled with quantum fluctuations of the electromagnetic field. As two plates are brought closer together, fewer fluctuations can occur within the gap between them, but on the outer sides of the plates, the fluctuations are unconstrained. This causes a pressure difference on either side of the plates, forcing the plates to stick together, in a phenomenon called the Casimir effect.

Leonhardt and Philbin believe that inserting a section of metamaterial between the plates will disrupt the quantum fluctuations of the electromagnetic field. In particular, metamaterials have a negative refractive index, so that electromagnetic light waves entering a metamaterial bend in the opposite way than expected, says Leonhardt.That will cause the Casimir force to act in the opposite direction – forcing the upper plate to levitate. The work will appear in the New Journal of Physics.

Federico Capasso, an expert on the Casimir effect at Harvard University in Boston, is impressed.’Using metamaterials to reverse the Casimir effect is a very clever idea,’ he says.

However, he points out that because metamaterials are difficult to engineer, it’s unlikely that they could be used to levitate objects in the near future.

But there are good signs that quantum levitation could be achieved much sooner, by other methods. Umar Mohideen at the University of California Riverside and his colleagues have successfully manipulated the strength of the Casimir force by increasing the reflectivity of one of the plates, so that it reflects virtual particles more efficiently. Modifying the strength of the Casimir force is the first step towards reversing it, says team member Galina Klimchitskaya at North-West Technical University in St Petersburg, Russia.

Capasso and his colleagues have also been working on an alternative scheme to harness a repulsive Casimir effect Their calculations show that a repulsive Casimir force could be set up between a 42.7 micrometre-wide gold-coated polystyrene sphere and a silicon dioxide plate, if the two are immersed in ethanol. ‘Although the Casimir force between any two substances – the ethanol and gold, the gold and the silicon dioxide, or the silicon dioxide and the ethanol – is positive, the relative strengths of attraction are different, and when you combine the materials, you should see the gold sphere levitate,’ he says.

Capasso’s early experiments suggest that such repulsion could occur, and that in turn could be used to levitate one object above another.’It’s very early work, and we still need to make certain this is really happening, but we are slowly building up experimental evidence for quantum levitation,’says Capasso, who presented his results at a conference on Coherence and Quantum Optics in Rochester, New York, in June.

This is a very exciting experimental result because it is the first demonstration that we can engineer a repulsive Casimir force,’ says Leonhardt.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('b790a78f-8c5a-5334-90dd-60ba1f15cd89', '41aff34a-82ad-5a80-bd5e-3f4cf8727490', 1, 'YES_NO_NOT_GIVEN', 'READING', 2, $md$### Question 1

Questions 1-5
Questions 1-5
Do the following statements agree with the claims of the writer in Reading Passage 3? Write
YES
if the statement agrees with the writers claims
NO
if the statement contradicts the writers claims
NOT GIVEN
if it is impossible to say what the writer thinks about this
1
A mini flying carpet is a possibility according to some scientists.
2
Cloaking devices can be used for levitation.
3
Scientists now know all about levitation.
4
Things can be transported from place to place using empty space technology.
5
The most recent research into levitation has made use of large magnets.

1 ____ A mini flying carpet is a possibility according to some scientists.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c0cb725d-9977-53a0-b17f-453f057057d8', 'b790a78f-8c5a-5334-90dd-60ba1f15cd89', 1, $md$YES$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('618bde45-5db8-5daf-954d-5572ca0d80af', 'b790a78f-8c5a-5334-90dd-60ba1f15cd89', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('395ce6d0-fef1-51d6-8940-5c57900185b0', 'b790a78f-8c5a-5334-90dd-60ba1f15cd89', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('f47d6b8f-ffb2-5b5b-ac35-402708793cc9', '41aff34a-82ad-5a80-bd5e-3f4cf8727490', 2, 'YES_NO_NOT_GIVEN', 'READING', 2, $md$### Question 2

Questions 1-5
Questions 1-5
Do the following statements agree with the claims of the writer in Reading Passage 3? Write
YES
if the statement agrees with the writers claims
NO
if the statement contradicts the writers claims
NOT GIVEN
if it is impossible to say what the writer thinks about this
1
A mini flying carpet is a possibility according to some scientists.
2
Cloaking devices can be used for levitation.
3
Scientists now know all about levitation.
4
Things can be transported from place to place using empty space technology.
5
The most recent research into levitation has made use of large magnets.

2 ____ Cloaking devices can be used for levitation.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('624fe38f-4b54-5d7d-a3f6-4ed3d3eebb7e', 'f47d6b8f-ffb2-5b5b-ac35-402708793cc9', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c6201c2f-d968-57d4-971a-7461beab7b0e', 'f47d6b8f-ffb2-5b5b-ac35-402708793cc9', 2, $md$NO$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2a4af0c8-a0f1-5955-8198-b110d1e7b860', 'f47d6b8f-ffb2-5b5b-ac35-402708793cc9', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('e0e7f067-d08c-547f-97dc-a8ae5545c561', '41aff34a-82ad-5a80-bd5e-3f4cf8727490', 3, 'YES_NO_NOT_GIVEN', 'READING', 2, $md$### Question 3

Questions 1-5
Questions 1-5
Do the following statements agree with the claims of the writer in Reading Passage 3? Write
YES
if the statement agrees with the writers claims
NO
if the statement contradicts the writers claims
NOT GIVEN
if it is impossible to say what the writer thinks about this
1
A mini flying carpet is a possibility according to some scientists.
2
Cloaking devices can be used for levitation.
3
Scientists now know all about levitation.
4
Things can be transported from place to place using empty space technology.
5
The most recent research into levitation has made use of large magnets.

3 ____ Scientists now know all about levitation.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d58732ae-6ab9-557a-8562-ff10c8bf0f00', 'e0e7f067-d08c-547f-97dc-a8ae5545c561', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7da775fb-ccf6-5da4-abdb-7ac961b469b2', 'e0e7f067-d08c-547f-97dc-a8ae5545c561', 2, $md$NO$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ca773e50-65aa-57f2-86d6-f9506b035517', 'e0e7f067-d08c-547f-97dc-a8ae5545c561', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('fe6f2a57-e2ff-5144-8af3-12b7ce23a522', '41aff34a-82ad-5a80-bd5e-3f4cf8727490', 4, 'YES_NO_NOT_GIVEN', 'READING', 2, $md$### Question 4

Questions 1-5
Questions 1-5
Do the following statements agree with the claims of the writer in Reading Passage 3? Write
YES
if the statement agrees with the writers claims
NO
if the statement contradicts the writers claims
NOT GIVEN
if it is impossible to say what the writer thinks about this
1
A mini flying carpet is a possibility according to some scientists.
2
Cloaking devices can be used for levitation.
3
Scientists now know all about levitation.
4
Things can be transported from place to place using empty space technology.
5
The most recent research into levitation has made use of large magnets.

4 ____ Things can be transported from place to place using empty space technology.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('234a5b18-b556-500b-b5b3-a2bfca0187e1', 'fe6f2a57-e2ff-5144-8af3-12b7ce23a522', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('52c2c7d3-8523-5df4-ad27-e1a8e054e77c', 'fe6f2a57-e2ff-5144-8af3-12b7ce23a522', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8feb7645-fa26-5daf-bb8f-0edb6658bb4e', 'fe6f2a57-e2ff-5144-8af3-12b7ce23a522', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('ae0d9a50-7db2-5527-97f9-bba7cd2461ea', '41aff34a-82ad-5a80-bd5e-3f4cf8727490', 5, 'YES_NO_NOT_GIVEN', 'READING', 3, $md$### Question 5

Questions 1-5
Questions 1-5
Do the following statements agree with the claims of the writer in Reading Passage 3? Write
YES
if the statement agrees with the writers claims
NO
if the statement contradicts the writers claims
NOT GIVEN
if it is impossible to say what the writer thinks about this
1
A mini flying carpet is a possibility according to some scientists.
2
Cloaking devices can be used for levitation.
3
Scientists now know all about levitation.
4
Things can be transported from place to place using empty space technology.
5
The most recent research into levitation has made use of large magnets.

5 ____ The most recent research into levitation has made use of large magnets.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5ea5655f-0efb-51a5-9f96-07794734a51b', 'ae0d9a50-7db2-5527-97f9-bba7cd2461ea', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f2ce3d9a-b7bb-5aff-b54a-ac47f2ad9c5e', 'ae0d9a50-7db2-5527-97f9-bba7cd2461ea', 2, $md$NO$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5ece68c4-45ed-58b6-9ff0-0ddba7243e5a', 'ae0d9a50-7db2-5527-97f9-bba7cd2461ea', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('62b55eb1-8d1c-5ed8-95ba-25f5a9432013', '41aff34a-82ad-5a80-bd5e-3f4cf8727490', 6, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 6

Questions 6-10
Questions 6-10
Choose the correct letter,
A, B, C
or
D
.
6
Ulf Leonhardt and John Pendry
A
worked together on a project in 2006.
B
both came up with the same idea.
C
invented the microwave oven.
D
used only basic objects in their research.
7
Metamaterials are
A
similar to light, but with a smaller wavelength.
B
a combination of simple metals and wires.
C
able to change where electromagnetic waves go.
D
engineered when light waves travel around them.
8
The importance of the Casimir effect is that it
A
doesn’t require a vacuum in order to work.
B
increases the number of plates that can be used.
C
creates large and frequent fluctuations.
D
creates pressure difference and stickiness.
9
Leonhardt and Philbin think that putting a metamaterial between two plates will
A
cause the top plate to rise above the bottom plate.
B
stop electromagnetic light waves bending.
C
stop the Casimir force from working.
D
not affect electromagnetic fluctuations.
10
Why is it important to change the strength of the Casimir force?
A
to reflect the plates
B
to help reverse the force
C
to see virtual particles better
D
to enable other scientists to progress

Choose the correct letter, A, B, C or D .$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('d22743b3-1812-5846-8073-9ed32bcf6ff8', '41aff34a-82ad-5a80-bd5e-3f4cf8727490', 7, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 7

Questions 6-10
Questions 6-10
Choose the correct letter,
A, B, C
or
D
.
6
Ulf Leonhardt and John Pendry
A
worked together on a project in 2006.
B
both came up with the same idea.
C
invented the microwave oven.
D
used only basic objects in their research.
7
Metamaterials are
A
similar to light, but with a smaller wavelength.
B
a combination of simple metals and wires.
C
able to change where electromagnetic waves go.
D
engineered when light waves travel around them.
8
The importance of the Casimir effect is that it
A
doesn’t require a vacuum in order to work.
B
increases the number of plates that can be used.
C
creates large and frequent fluctuations.
D
creates pressure difference and stickiness.
9
Leonhardt and Philbin think that putting a metamaterial between two plates will
A
cause the top plate to rise above the bottom plate.
B
stop electromagnetic light waves bending.
C
stop the Casimir force from working.
D
not affect electromagnetic fluctuations.
10
Why is it important to change the strength of the Casimir force?
A
to reflect the plates
B
to help reverse the force
C
to see virtual particles better
D
to enable other scientists to progress

Choose the correct letter, A, B, C or D .$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('5943b004-b547-5592-8b34-4a8b8a347e6a', '41aff34a-82ad-5a80-bd5e-3f4cf8727490', 8, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 8

Questions 6-10
Questions 6-10
Choose the correct letter,
A, B, C
or
D
.
6
Ulf Leonhardt and John Pendry
A
worked together on a project in 2006.
B
both came up with the same idea.
C
invented the microwave oven.
D
used only basic objects in their research.
7
Metamaterials are
A
similar to light, but with a smaller wavelength.
B
a combination of simple metals and wires.
C
able to change where electromagnetic waves go.
D
engineered when light waves travel around them.
8
The importance of the Casimir effect is that it
A
doesn’t require a vacuum in order to work.
B
increases the number of plates that can be used.
C
creates large and frequent fluctuations.
D
creates pressure difference and stickiness.
9
Leonhardt and Philbin think that putting a metamaterial between two plates will
A
cause the top plate to rise above the bottom plate.
B
stop electromagnetic light waves bending.
C
stop the Casimir force from working.
D
not affect electromagnetic fluctuations.
10
Why is it important to change the strength of the Casimir force?
A
to reflect the plates
B
to help reverse the force
C
to see virtual particles better
D
to enable other scientists to progress

Choose the correct letter, A, B, C or D .$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('6bce3e67-21f9-53c1-b2a3-20fbfaebef49', '41aff34a-82ad-5a80-bd5e-3f4cf8727490', 9, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 9

Questions 6-10
Questions 6-10
Choose the correct letter,
A, B, C
or
D
.
6
Ulf Leonhardt and John Pendry
A
worked together on a project in 2006.
B
both came up with the same idea.
C
invented the microwave oven.
D
used only basic objects in their research.
7
Metamaterials are
A
similar to light, but with a smaller wavelength.
B
a combination of simple metals and wires.
C
able to change where electromagnetic waves go.
D
engineered when light waves travel around them.
8
The importance of the Casimir effect is that it
A
doesn’t require a vacuum in order to work.
B
increases the number of plates that can be used.
C
creates large and frequent fluctuations.
D
creates pressure difference and stickiness.
9
Leonhardt and Philbin think that putting a metamaterial between two plates will
A
cause the top plate to rise above the bottom plate.
B
stop electromagnetic light waves bending.
C
stop the Casimir force from working.
D
not affect electromagnetic fluctuations.
10
Why is it important to change the strength of the Casimir force?
A
to reflect the plates
B
to help reverse the force
C
to see virtual particles better
D
to enable other scientists to progress

Choose the correct letter, A, B, C or D .$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('fc80b662-c0ab-5b7b-9c4e-60f7c0099397', '41aff34a-82ad-5a80-bd5e-3f4cf8727490', 10, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 10

Questions 6-10
Questions 6-10
Choose the correct letter,
A, B, C
or
D
.
6
Ulf Leonhardt and John Pendry
A
worked together on a project in 2006.
B
both came up with the same idea.
C
invented the microwave oven.
D
used only basic objects in their research.
7
Metamaterials are
A
similar to light, but with a smaller wavelength.
B
a combination of simple metals and wires.
C
able to change where electromagnetic waves go.
D
engineered when light waves travel around them.
8
The importance of the Casimir effect is that it
A
doesn’t require a vacuum in order to work.
B
increases the number of plates that can be used.
C
creates large and frequent fluctuations.
D
creates pressure difference and stickiness.
9
Leonhardt and Philbin think that putting a metamaterial between two plates will
A
cause the top plate to rise above the bottom plate.
B
stop electromagnetic light waves bending.
C
stop the Casimir force from working.
D
not affect electromagnetic fluctuations.
10
Why is it important to change the strength of the Casimir force?
A
to reflect the plates
B
to help reverse the force
C
to see virtual particles better
D
to enable other scientists to progress

Choose the correct letter, A, B, C or D .$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('eb37f0b6-bb08-5913-ac88-4de08038609a', '41aff34a-82ad-5a80-bd5e-3f4cf8727490', 11, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 11

Questions 11-13
Questions 11-13
Complete each sentence with the correct ending
A-F
below.
11
Capasso is unconvinced that
12
Capasso has calculated that
13
Capasso has admitted that
A
gold can be used to produce levitation.
B
a particular type of ethanol has to be used.
C
the levitation will last for only a few seconds.
D
using metamaterials will help lead to levitation in the short term.
E
his experiment will be extremely costly to perform.
F
his idea is still only a theory.

11 ____ Capasso is unconvinced that$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4741620d-56d9-55dd-903a-8ac26898b6a2', 'eb37f0b6-bb08-5913-ac88-4de08038609a', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f6ce4a3a-2a7a-552f-b404-68e01b417ea1', 'eb37f0b6-bb08-5913-ac88-4de08038609a', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e7831bd3-1a97-5ea2-b1fb-f8220dccbb69', 'eb37f0b6-bb08-5913-ac88-4de08038609a', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9a951668-30f9-5358-9e91-d46532284d8e', 'eb37f0b6-bb08-5913-ac88-4de08038609a', 4, $md$D$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1bcb8319-eb55-5561-95d2-f9f3c0f0fee1', 'eb37f0b6-bb08-5913-ac88-4de08038609a', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bbe1e4a8-1d49-5452-be7b-52e91e9d0b35', 'eb37f0b6-bb08-5913-ac88-4de08038609a', 6, $md$F$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('63548ef0-b015-5750-bcd3-6e0b215b8001', '41aff34a-82ad-5a80-bd5e-3f4cf8727490', 12, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 12

Questions 11-13
Questions 11-13
Complete each sentence with the correct ending
A-F
below.
11
Capasso is unconvinced that
12
Capasso has calculated that
13
Capasso has admitted that
A
gold can be used to produce levitation.
B
a particular type of ethanol has to be used.
C
the levitation will last for only a few seconds.
D
using metamaterials will help lead to levitation in the short term.
E
his experiment will be extremely costly to perform.
F
his idea is still only a theory.

12 ____ Capasso has calculated that$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('619cd7bb-0a72-5cba-91a1-0e41efb0e578', '63548ef0-b015-5750-bcd3-6e0b215b8001', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b21679d6-694a-5312-b1fb-85f9f362776c', '63548ef0-b015-5750-bcd3-6e0b215b8001', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9bc1f90a-d5d9-5317-825f-2769a62dfcbd', '63548ef0-b015-5750-bcd3-6e0b215b8001', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('94efe61b-c652-5f2b-8092-e276d41430f3', '63548ef0-b015-5750-bcd3-6e0b215b8001', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('542bdee1-4732-591f-8439-f92dd68f359f', '63548ef0-b015-5750-bcd3-6e0b215b8001', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f8460c4b-fc5f-5bcb-ac25-29a84d92c8fe', '63548ef0-b015-5750-bcd3-6e0b215b8001', 6, $md$F$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('9aa9122b-9113-5875-9ecc-3037a45ca9d7', '41aff34a-82ad-5a80-bd5e-3f4cf8727490', 13, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 13

Questions 11-13
Questions 11-13
Complete each sentence with the correct ending
A-F
below.
11
Capasso is unconvinced that
12
Capasso has calculated that
13
Capasso has admitted that
A
gold can be used to produce levitation.
B
a particular type of ethanol has to be used.
C
the levitation will last for only a few seconds.
D
using metamaterials will help lead to levitation in the short term.
E
his experiment will be extremely costly to perform.
F
his idea is still only a theory.

13 ____ Capasso has admitted that$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5223b06c-c801-5f57-ae5a-e0d9d3f25390', '9aa9122b-9113-5875-9ecc-3037a45ca9d7', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f4e6cbbf-73f6-5af1-9cc2-5bd555f234dd', '9aa9122b-9113-5875-9ecc-3037a45ca9d7', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('293f1b8d-da69-5b3b-9ca8-bce57f8f2cc1', '9aa9122b-9113-5875-9ecc-3037a45ca9d7', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('049e7ea7-857f-5a95-94c5-de75974d3594', '9aa9122b-9113-5875-9ecc-3037a45ca9d7', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ad13a40e-3b19-59d9-b0b7-2f8e9922ecd4', '9aa9122b-9113-5875-9ecc-3037a45ca9d7', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('da396bba-42e7-50ea-a562-88f92f76dd71', '9aa9122b-9113-5875-9ecc-3037a45ca9d7', 6, $md$F$md$, true);

COMMIT;
