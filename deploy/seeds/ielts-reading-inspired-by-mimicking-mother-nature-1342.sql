BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-inspired-by-mimicking-mother-nature-1342'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-inspired-by-mimicking-mother-nature-1342';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-inspired-by-mimicking-mother-nature-1342';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-inspired-by-mimicking-mother-nature-1342';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('e249dae9-a4b1-5984-a45c-eabe6c3be33e', 'ielts-reading-inspired-by-mimicking-mother-nature-1342', $t$Inspired by Mimicking Mother Nature$t$, $md$## Inspired by Mimicking Mother Nature

Nguồn:
- Test: https://mini-ielts.com/1342/reading/inspired-by-mimicking-mother-nature
- Solution: https://mini-ielts.com/1342/view-solution/reading/inspired-by-mimicking-mother-nature$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('47aaaca8-024e-5cec-9488-47fdda3a8053', 'e249dae9-a4b1-5984-a45c-eabe6c3be33e', 1, $t$Reading — Inspired by Mimicking Mother Nature$t$, $md$Read the passage and answer questions **1–14**.

### Passage: Inspired by Mimicking Mother Nature

{A} Researchers and designers around the globe endeavor to create new technologies that, by honoring the tenets of life, are both highly efficient and often environmentally friendly. And while biomimicry is not a new concept (Leonardo da Vinci looked to nature to design his flying machines, for example, and pharmaceutical companies have long been miming plant organisms in synthetic drugs), there is a greater need for products and manufacturing processes that use a minimum of energy, materials, and toxins. What’s more, due to technological advancements and a newfound spirit of innovation among designers, there are now myriad ways to mimic Mother Nature’s best assets.

{B} “We have a perfect storm happening right now,” says Jay Harman, an inventor and CEO of PAX Scientific, which designs fans, mixers, and pumps to achieve maximum efficiency by imitating the natural flow of fluids. “Shapes in nature are extremely simple once you understand them, but to understand what geometries are at play, and to adapt them, is a very complex process. We only just recently have had the computer power and manufacturing capability to produce these types of shapes.” “If we could capture nature’s efficiencies across the board, we could decrease dependency on fuel by at least 50 percent,” Harman says. “What we’re finding already with the tools and methodology we have right now is that we can reduce energy consumption by between 30 and 40 percent.”

{C} It’s only recently that mainstream companies have begun to equate biomimicry with the bottom line. DaimlerChrysler, for example, introduced a prototype car modeled on a coral reef fish. Despite its boxy, cube-shaped body, which defies a long-held aerodynamic standard in automotive design (the raindrop shape), the streamlined boxfish proved to be aerodynamically ideal and the unique construction of its skin—numerous hexagonal, bony plates—a perfect recipe for designing a car of maximum strength with minimal weight.

{D} Companies and communities are flocking to Janine Benyus, author of the landmark book Biomimicry: Innovation Inspired by Nature (Perennial, 2002) and cofounder of the Biomimicry Guild, which seats biologists at the table with researchers and designers at companies such as Nike, Interface carpets, Novell, and Procter & Gamble. Their objective is to marry industrial problems with natural solutions.

{E} Benyus, who hopes companies will ultimately transcend mere product design to embrace nature on a more holistic level, breaks biomimicry into three tiers. On a basic (albeit complicated) level, industry will mimic nature’s precise and efficient shapes, structures, and geometries. The microstructure of the lotus leaf, for example, causes raindrops to bead and run off immediately, while self-cleaning and drying its surface—a discovery that the British paint company Sto has exploited in a line of building paints. The layered structure of a butterfly wing or a peacock plume, which creates iridescent color by refracting light, is being mimicked by cosmetics giant L’Oreal in a soon-to-be-released line of eye shadow, lipstick, and nail varnish.

{F} The next level of biomimicry involves imitating natural processes and biochemical “recipes”: Engineers and scientists are now looking at the nasal glands of seabirds to solve the problem of desalination; the abalone’s ability to self-assemble its incredibly durable shell in water, using local ingredients, has inspired an alternative to the conventional, and often toxic, “heat, beat, and treat” manufacturing method. How other organisms deal with harmful bacteria can also be instructive: Researchers for the Australian company Biosignal, for instance, observed a seaweed that lives in an environment teeming with microbes to figure out how it kept free of the same sorts of bacterial colonies, called biofilms, that cause plaque on your teeth and clog up your bathroom drain. They determined that the seaweed uses natural chemicals, called furanones, that jam the cell-to-cell signaling systems that allow bacteria to communicate and gather.

{G} Ultimately, the most sophisticated application of biomimicry, according to Benyus, is when a company starts seeing itself as an organism in an economic ecosystem that must make thrifty use of limited resources and creates symbiotic relationships with other organisms. A boardroom approach at this level begins with imagining any given company, or collection of industries, as a forest, prairie, or coral reef, with its own “food web”(manufacturing inputs and outputs) and asking whether waste products from one manufacturing process can be used, or perhaps sold, as an ingredient for another industrial activity. For instance, Geoffrey Coates, a chemist at Cornell, has developed a biodegradable plastic synthesized from carbon dioxide and limonene (a major component in the oil extracted from citrus rind) and is working with a cement factory to trap their waste CO2 and use it as an ingredient.

{H} Zero Emissions Research and Initiatives (ZERI), a global network of scientists, entrepreneurs, and educators, has initiated eco industrial projects that attempt to find ways to reuse all wastes as raw materials for other processes. Storm Brewing in Newfoundland, Canada—in one of a growing number of projects around the world applying ZERI principles—is using spent grains, a by-product of the beer-making process, to make bread and grow mushrooms.

As industries continue to adopt nature’s models, entire manufacturing processes could operate locally, with local ingredients like the factories that use liquefied beach sand to make windshields. As more scientists and engineers begin to embrace biomimicry, natural organisms will come to be regarded as mentors, their processes deemed masterful.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('95d17bae-e986-5cd6-97d8-6257ce752d34', '47aaaca8-024e-5cec-9488-47fdda3a8053', 1, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 1

Questions 1-6
Questions 1-6
Look at the following descriptions mentioned in the Reading Passage. Match the three kinds of levels (A-C) listed below the descriptions. Write the appropriate letters, A-C, in boxes 1-6 on your answer sheet.
(A)
First level: mimic nature’s precise and efficient shapes, structures, and geometries
(B)
Second level: imitating natural processes and biochemical ‘recipes’
(C)
Third level: creates symbiotic relationships with other like organisms
1
Synthesized Plastic, developed together with cement factory, can recycle waste gas.
2
Cosmetics companies produce a series of shine cosmetics colours
3
People are inspired how to remove excess salt inspired by nature.
4
Daimler Chrysler introduced a fish-shaped car.
5
Marine plan company integrated itself into a part in economic ecosystem
6
natural chemicals developed based on seaweed known to kill bacteria

1 ____ Synthesized Plastic, developed together with cement factory, can recycle waste gas.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('50708d7c-199a-539f-8797-3be0cb4331c6', '95d17bae-e986-5cd6-97d8-6257ce752d34', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1a64b598-54d2-55cb-a666-5a36ff45e1ea', '95d17bae-e986-5cd6-97d8-6257ce752d34', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c5d81e54-2f19-53a9-84b8-b5996231578e', '95d17bae-e986-5cd6-97d8-6257ce752d34', 3, $md$C$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('a9bf887f-54c1-5931-ac32-a4c3d7470bcb', '47aaaca8-024e-5cec-9488-47fdda3a8053', 2, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 2

Questions 1-6
Questions 1-6
Look at the following descriptions mentioned in the Reading Passage. Match the three kinds of levels (A-C) listed below the descriptions. Write the appropriate letters, A-C, in boxes 1-6 on your answer sheet.
(A)
First level: mimic nature’s precise and efficient shapes, structures, and geometries
(B)
Second level: imitating natural processes and biochemical ‘recipes’
(C)
Third level: creates symbiotic relationships with other like organisms
1
Synthesized Plastic, developed together with cement factory, can recycle waste gas.
2
Cosmetics companies produce a series of shine cosmetics colours
3
People are inspired how to remove excess salt inspired by nature.
4
Daimler Chrysler introduced a fish-shaped car.
5
Marine plan company integrated itself into a part in economic ecosystem
6
natural chemicals developed based on seaweed known to kill bacteria

2 ____ Cosmetics companies produce a series of shine cosmetics colours$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6970facc-daa1-54a0-8290-afa99611152f', 'a9bf887f-54c1-5931-ac32-a4c3d7470bcb', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1b14fd1c-5c65-5894-a8b7-edd426b7b0a0', 'a9bf887f-54c1-5931-ac32-a4c3d7470bcb', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5c054e83-85d7-5328-b857-18878444e31f', 'a9bf887f-54c1-5931-ac32-a4c3d7470bcb', 3, $md$C$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('a23c5080-4a03-57d5-bacb-ebabeff845c3', '47aaaca8-024e-5cec-9488-47fdda3a8053', 3, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 3

Questions 1-6
Questions 1-6
Look at the following descriptions mentioned in the Reading Passage. Match the three kinds of levels (A-C) listed below the descriptions. Write the appropriate letters, A-C, in boxes 1-6 on your answer sheet.
(A)
First level: mimic nature’s precise and efficient shapes, structures, and geometries
(B)
Second level: imitating natural processes and biochemical ‘recipes’
(C)
Third level: creates symbiotic relationships with other like organisms
1
Synthesized Plastic, developed together with cement factory, can recycle waste gas.
2
Cosmetics companies produce a series of shine cosmetics colours
3
People are inspired how to remove excess salt inspired by nature.
4
Daimler Chrysler introduced a fish-shaped car.
5
Marine plan company integrated itself into a part in economic ecosystem
6
natural chemicals developed based on seaweed known to kill bacteria

3 ____ People are inspired how to remove excess salt inspired by nature.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('92319dec-3939-5397-8cd8-db0f8a234d4a', 'a23c5080-4a03-57d5-bacb-ebabeff845c3', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('837a8a16-88c6-5674-81fc-1473bddb0055', 'a23c5080-4a03-57d5-bacb-ebabeff845c3', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('275e400e-cf30-5a55-b7e7-c2d0802cf3be', 'a23c5080-4a03-57d5-bacb-ebabeff845c3', 3, $md$C$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('a68c4356-1ea6-502d-8c1e-5c46a983b921', '47aaaca8-024e-5cec-9488-47fdda3a8053', 4, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 4

Questions 1-6
Questions 1-6
Look at the following descriptions mentioned in the Reading Passage. Match the three kinds of levels (A-C) listed below the descriptions. Write the appropriate letters, A-C, in boxes 1-6 on your answer sheet.
(A)
First level: mimic nature’s precise and efficient shapes, structures, and geometries
(B)
Second level: imitating natural processes and biochemical ‘recipes’
(C)
Third level: creates symbiotic relationships with other like organisms
1
Synthesized Plastic, developed together with cement factory, can recycle waste gas.
2
Cosmetics companies produce a series of shine cosmetics colours
3
People are inspired how to remove excess salt inspired by nature.
4
Daimler Chrysler introduced a fish-shaped car.
5
Marine plan company integrated itself into a part in economic ecosystem
6
natural chemicals developed based on seaweed known to kill bacteria

4 ____ Daimler Chrysler introduced a fish-shaped car.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b8d841ee-365c-5b65-8ea4-d6c767791167', 'a68c4356-1ea6-502d-8c1e-5c46a983b921', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7bac27e9-1f15-5f52-a5f9-a3880fad03e9', 'a68c4356-1ea6-502d-8c1e-5c46a983b921', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ddcfa690-7041-5cc3-8738-057cdec52c36', 'a68c4356-1ea6-502d-8c1e-5c46a983b921', 3, $md$C$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('71a69734-4fad-5aba-a779-d25f73fb47c5', '47aaaca8-024e-5cec-9488-47fdda3a8053', 5, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 5

Questions 1-6
Questions 1-6
Look at the following descriptions mentioned in the Reading Passage. Match the three kinds of levels (A-C) listed below the descriptions. Write the appropriate letters, A-C, in boxes 1-6 on your answer sheet.
(A)
First level: mimic nature’s precise and efficient shapes, structures, and geometries
(B)
Second level: imitating natural processes and biochemical ‘recipes’
(C)
Third level: creates symbiotic relationships with other like organisms
1
Synthesized Plastic, developed together with cement factory, can recycle waste gas.
2
Cosmetics companies produce a series of shine cosmetics colours
3
People are inspired how to remove excess salt inspired by nature.
4
Daimler Chrysler introduced a fish-shaped car.
5
Marine plan company integrated itself into a part in economic ecosystem
6
natural chemicals developed based on seaweed known to kill bacteria

5 ____ Marine plan company integrated itself into a part in economic ecosystem$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('088e42e6-3b61-5dba-b3d8-c5065d7f7e41', '71a69734-4fad-5aba-a779-d25f73fb47c5', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('199221c6-29ec-5759-8a0c-3bec927c4a18', '71a69734-4fad-5aba-a779-d25f73fb47c5', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e80eca61-b7cb-5d02-91f3-e610898ec2e7', '71a69734-4fad-5aba-a779-d25f73fb47c5', 3, $md$C$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('bc0b6a7b-770c-5091-9125-2d6b1ba95de3', '47aaaca8-024e-5cec-9488-47fdda3a8053', 6, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 6

Questions 1-6
Questions 1-6
Look at the following descriptions mentioned in the Reading Passage. Match the three kinds of levels (A-C) listed below the descriptions. Write the appropriate letters, A-C, in boxes 1-6 on your answer sheet.
(A)
First level: mimic nature’s precise and efficient shapes, structures, and geometries
(B)
Second level: imitating natural processes and biochemical ‘recipes’
(C)
Third level: creates symbiotic relationships with other like organisms
1
Synthesized Plastic, developed together with cement factory, can recycle waste gas.
2
Cosmetics companies produce a series of shine cosmetics colours
3
People are inspired how to remove excess salt inspired by nature.
4
Daimler Chrysler introduced a fish-shaped car.
5
Marine plan company integrated itself into a part in economic ecosystem
6
natural chemicals developed based on seaweed known to kill bacteria

6 ____ natural chemicals developed based on seaweed known to kill bacteria$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('81608614-980d-54c2-b9ae-7e1c0796b743', 'bc0b6a7b-770c-5091-9125-2d6b1ba95de3', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1f861b69-7b08-5ad4-81a6-00cfaecb3ff8', 'bc0b6a7b-770c-5091-9125-2d6b1ba95de3', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cf49bb1f-222e-5fa8-9051-9accfe1333d7', 'bc0b6a7b-770c-5091-9125-2d6b1ba95de3', 3, $md$C$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('7ec61e2f-a31c-5dac-b3c0-cfc4f1aea9c5', '47aaaca8-024e-5cec-9488-47fdda3a8053', 7, 'YES_NO_NOT_GIVEN', 'READING', 3, $md$### Question 7

Questions 7-14
Questions 7-14
Do the following statements agree with the information given in the Reading Passage? In boxes 7-14 on your answer sheet, write
YES
if the statement agrees with the writer
NO
if the statement does not agree with the writer
NOT GIVEN
if there is no information about this in the passage
7
Biomimicry is a totally new concept that has been unveiled recently.
8
Leonardo da Vinci has been the first designer to mimic nature
9
Scientists believe it involves more than mimicking the shape to capture the design in nature
10
We can save the utilisation of energy by up to 40% if we take advantage of the current findings.
11
Daimler Chrysler’s prototype car modelled on a coral reef fish is a best-seller.
12
Some great companies and communities themselves are seeking solutions beyond their own industrial scope
13
The British paint company Sto did not make the microstructure of the lotus leaf,applicable
14
a Canadian beer Company increased the production the by applying ZERI principles

7 ____ Biomimicry is a totally new concept that has been unveiled recently.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('394fbc6b-d1f5-50a0-bb45-5b2d00a475d7', '7ec61e2f-a31c-5dac-b3c0-cfc4f1aea9c5', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('83ee79c5-7b87-533a-8b54-2d46fdcbb067', '7ec61e2f-a31c-5dac-b3c0-cfc4f1aea9c5', 2, $md$NO$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4298201d-fb87-50b9-898d-9999ac076bab', '7ec61e2f-a31c-5dac-b3c0-cfc4f1aea9c5', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('6ea55664-422c-5421-8661-106905914fd6', '47aaaca8-024e-5cec-9488-47fdda3a8053', 8, 'YES_NO_NOT_GIVEN', 'READING', 3, $md$### Question 8

Questions 7-14
Questions 7-14
Do the following statements agree with the information given in the Reading Passage? In boxes 7-14 on your answer sheet, write
YES
if the statement agrees with the writer
NO
if the statement does not agree with the writer
NOT GIVEN
if there is no information about this in the passage
7
Biomimicry is a totally new concept that has been unveiled recently.
8
Leonardo da Vinci has been the first designer to mimic nature
9
Scientists believe it involves more than mimicking the shape to capture the design in nature
10
We can save the utilisation of energy by up to 40% if we take advantage of the current findings.
11
Daimler Chrysler’s prototype car modelled on a coral reef fish is a best-seller.
12
Some great companies and communities themselves are seeking solutions beyond their own industrial scope
13
The British paint company Sto did not make the microstructure of the lotus leaf,applicable
14
a Canadian beer Company increased the production the by applying ZERI principles

8 ____ Leonardo da Vinci has been the first designer to mimic nature$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ff567bdd-1cf8-549a-b1c0-9c2274ec12ac', '6ea55664-422c-5421-8661-106905914fd6', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('85190c4f-f012-5d73-bbfa-46c3b713565e', '6ea55664-422c-5421-8661-106905914fd6', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2926d045-cb88-5811-bbbd-339f69bbf0fe', '6ea55664-422c-5421-8661-106905914fd6', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('f60921eb-0df6-5175-9df1-ba36a8bb8caf', '47aaaca8-024e-5cec-9488-47fdda3a8053', 9, 'YES_NO_NOT_GIVEN', 'READING', 3, $md$### Question 9

Questions 7-14
Questions 7-14
Do the following statements agree with the information given in the Reading Passage? In boxes 7-14 on your answer sheet, write
YES
if the statement agrees with the writer
NO
if the statement does not agree with the writer
NOT GIVEN
if there is no information about this in the passage
7
Biomimicry is a totally new concept that has been unveiled recently.
8
Leonardo da Vinci has been the first designer to mimic nature
9
Scientists believe it involves more than mimicking the shape to capture the design in nature
10
We can save the utilisation of energy by up to 40% if we take advantage of the current findings.
11
Daimler Chrysler’s prototype car modelled on a coral reef fish is a best-seller.
12
Some great companies and communities themselves are seeking solutions beyond their own industrial scope
13
The British paint company Sto did not make the microstructure of the lotus leaf,applicable
14
a Canadian beer Company increased the production the by applying ZERI principles

9 ____ Scientists believe it involves more than mimicking the shape to capture the design in nature$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('38e1d7cc-80ae-5732-af40-bbcd7987a88e', 'f60921eb-0df6-5175-9df1-ba36a8bb8caf', 1, $md$YES$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a7e244a2-de6d-5fe0-8701-5d6c9d27e832', 'f60921eb-0df6-5175-9df1-ba36a8bb8caf', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8a89c242-e8b5-5e09-9cbc-ff2bf378cdd0', 'f60921eb-0df6-5175-9df1-ba36a8bb8caf', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('b61e0bc8-9f26-5b8d-94f7-b81c88978f81', '47aaaca8-024e-5cec-9488-47fdda3a8053', 10, 'YES_NO_NOT_GIVEN', 'READING', 4, $md$### Question 10

Questions 7-14
Questions 7-14
Do the following statements agree with the information given in the Reading Passage? In boxes 7-14 on your answer sheet, write
YES
if the statement agrees with the writer
NO
if the statement does not agree with the writer
NOT GIVEN
if there is no information about this in the passage
7
Biomimicry is a totally new concept that has been unveiled recently.
8
Leonardo da Vinci has been the first designer to mimic nature
9
Scientists believe it involves more than mimicking the shape to capture the design in nature
10
We can save the utilisation of energy by up to 40% if we take advantage of the current findings.
11
Daimler Chrysler’s prototype car modelled on a coral reef fish is a best-seller.
12
Some great companies and communities themselves are seeking solutions beyond their own industrial scope
13
The British paint company Sto did not make the microstructure of the lotus leaf,applicable
14
a Canadian beer Company increased the production the by applying ZERI principles

10 ____ We can save the utilisation of energy by up to 40% if we take advantage of the current findings.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ed6a3049-82a8-5d55-b90e-ceb00e7ed914', 'b61e0bc8-9f26-5b8d-94f7-b81c88978f81', 1, $md$YES$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f0b3cdd7-e8d2-543f-b5a1-4ab2212b5fe7', 'b61e0bc8-9f26-5b8d-94f7-b81c88978f81', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d8bf89fb-0e4e-5e1e-b5fe-28e354ac52e3', 'b61e0bc8-9f26-5b8d-94f7-b81c88978f81', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('3181451e-4714-5fa1-8ed4-df49eec05928', '47aaaca8-024e-5cec-9488-47fdda3a8053', 11, 'YES_NO_NOT_GIVEN', 'READING', 4, $md$### Question 11

Questions 7-14
Questions 7-14
Do the following statements agree with the information given in the Reading Passage? In boxes 7-14 on your answer sheet, write
YES
if the statement agrees with the writer
NO
if the statement does not agree with the writer
NOT GIVEN
if there is no information about this in the passage
7
Biomimicry is a totally new concept that has been unveiled recently.
8
Leonardo da Vinci has been the first designer to mimic nature
9
Scientists believe it involves more than mimicking the shape to capture the design in nature
10
We can save the utilisation of energy by up to 40% if we take advantage of the current findings.
11
Daimler Chrysler’s prototype car modelled on a coral reef fish is a best-seller.
12
Some great companies and communities themselves are seeking solutions beyond their own industrial scope
13
The British paint company Sto did not make the microstructure of the lotus leaf,applicable
14
a Canadian beer Company increased the production the by applying ZERI principles

11 ____ Daimler Chrysler’s prototype car modelled on a coral reef fish is a best-seller.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0a313778-b6f9-5078-9555-061dd582395b', '3181451e-4714-5fa1-8ed4-df49eec05928', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0a073c90-25e6-5e5f-99e4-1a50f9a3c1f4', '3181451e-4714-5fa1-8ed4-df49eec05928', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9d2deb6c-17de-556d-aaa9-d670cb2e0c8b', '3181451e-4714-5fa1-8ed4-df49eec05928', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('5a9a615f-7047-5426-ac22-48397321de31', '47aaaca8-024e-5cec-9488-47fdda3a8053', 12, 'YES_NO_NOT_GIVEN', 'READING', 4, $md$### Question 12

Questions 7-14
Questions 7-14
Do the following statements agree with the information given in the Reading Passage? In boxes 7-14 on your answer sheet, write
YES
if the statement agrees with the writer
NO
if the statement does not agree with the writer
NOT GIVEN
if there is no information about this in the passage
7
Biomimicry is a totally new concept that has been unveiled recently.
8
Leonardo da Vinci has been the first designer to mimic nature
9
Scientists believe it involves more than mimicking the shape to capture the design in nature
10
We can save the utilisation of energy by up to 40% if we take advantage of the current findings.
11
Daimler Chrysler’s prototype car modelled on a coral reef fish is a best-seller.
12
Some great companies and communities themselves are seeking solutions beyond their own industrial scope
13
The British paint company Sto did not make the microstructure of the lotus leaf,applicable
14
a Canadian beer Company increased the production the by applying ZERI principles

12 ____ Some great companies and communities themselves are seeking solutions beyond their own industrial scope$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8effceda-c729-5c0b-84e3-4abecc327b71', '5a9a615f-7047-5426-ac22-48397321de31', 1, $md$YES$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d83ce401-18b3-5cd0-b230-7469b5c43f24', '5a9a615f-7047-5426-ac22-48397321de31', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('466423bd-abe3-574f-a6dd-822361f5447f', '5a9a615f-7047-5426-ac22-48397321de31', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('5d1b0851-8573-5ce9-a13b-d75bcca088d4', '47aaaca8-024e-5cec-9488-47fdda3a8053', 13, 'YES_NO_NOT_GIVEN', 'READING', 4, $md$### Question 13

Questions 7-14
Questions 7-14
Do the following statements agree with the information given in the Reading Passage? In boxes 7-14 on your answer sheet, write
YES
if the statement agrees with the writer
NO
if the statement does not agree with the writer
NOT GIVEN
if there is no information about this in the passage
7
Biomimicry is a totally new concept that has been unveiled recently.
8
Leonardo da Vinci has been the first designer to mimic nature
9
Scientists believe it involves more than mimicking the shape to capture the design in nature
10
We can save the utilisation of energy by up to 40% if we take advantage of the current findings.
11
Daimler Chrysler’s prototype car modelled on a coral reef fish is a best-seller.
12
Some great companies and communities themselves are seeking solutions beyond their own industrial scope
13
The British paint company Sto did not make the microstructure of the lotus leaf,applicable
14
a Canadian beer Company increased the production the by applying ZERI principles

13 ____ The British paint company Sto did not make the microstructure of the lotus leaf,applicable$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2abc8e4a-678f-5e05-af85-335938441b7a', '5d1b0851-8573-5ce9-a13b-d75bcca088d4', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('37b76f51-707c-5cb2-878f-8867eda93130', '5d1b0851-8573-5ce9-a13b-d75bcca088d4', 2, $md$NO$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e8ad887e-d89b-5c55-bdb2-0a3a858aa978', '5d1b0851-8573-5ce9-a13b-d75bcca088d4', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('7eaa9ea1-57e9-5e84-90cc-4430801408d5', '47aaaca8-024e-5cec-9488-47fdda3a8053', 14, 'YES_NO_NOT_GIVEN', 'READING', 4, $md$### Question 14

Questions 7-14
Questions 7-14
Do the following statements agree with the information given in the Reading Passage? In boxes 7-14 on your answer sheet, write
YES
if the statement agrees with the writer
NO
if the statement does not agree with the writer
NOT GIVEN
if there is no information about this in the passage
7
Biomimicry is a totally new concept that has been unveiled recently.
8
Leonardo da Vinci has been the first designer to mimic nature
9
Scientists believe it involves more than mimicking the shape to capture the design in nature
10
We can save the utilisation of energy by up to 40% if we take advantage of the current findings.
11
Daimler Chrysler’s prototype car modelled on a coral reef fish is a best-seller.
12
Some great companies and communities themselves are seeking solutions beyond their own industrial scope
13
The British paint company Sto did not make the microstructure of the lotus leaf,applicable
14
a Canadian beer Company increased the production the by applying ZERI principles

14 ____ a Canadian beer Company increased the production the by applying ZERI principles$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6ac1431c-2890-5751-997a-6444c7bb2cc4', '7eaa9ea1-57e9-5e84-90cc-4430801408d5', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f5dc25a8-1b9a-5523-a8f9-82a78dffddbe', '7eaa9ea1-57e9-5e84-90cc-4430801408d5', 2, $md$NO$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ba892a56-7b74-5e7c-b2a2-a29e9ecc941f', '7eaa9ea1-57e9-5e84-90cc-4430801408d5', 3, $md$NOT GIVEN$md$, false);

COMMIT;
