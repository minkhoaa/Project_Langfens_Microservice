BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-bodie-americas-most-famous-ghost-town-1464'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-bodie-americas-most-famous-ghost-town-1464';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-bodie-americas-most-famous-ghost-town-1464';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-bodie-americas-most-famous-ghost-town-1464';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('35a30701-7cd7-5957-8bd9-9c2b7db5a590', 'ielts-reading-bodie-americas-most-famous-ghost-town-1464', $t$Bodie: America's most famous ghost town$t$, $md$## Bodie: America's most famous ghost town

Nguồn:
- Test: https://mini-ielts.com/1464/reading/bodie-americas-most-famous-ghost-town
- Solution: https://mini-ielts.com/1464/view-solution/reading/bodie-americas-most-famous-ghost-town$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('6a36747b-1c14-5ccf-926a-8d8023764624', '35a30701-7cd7-5957-8bd9-9c2b7db5a590', 1, $t$Reading — Bodie: America's most famous ghost town$t$, $md$Read the passage and answer questions **1–13**.

### Passage: Bodie: America's most famous ghost town

If you peek inside on of the broken- down buildings in Bodie, California, you might see dust- covered furniture an old muffin pan, rusty tins, and broken kerosene lamps or a fully stocked general store with original wooden boxes and shelves with tin cans Situated in a sagebrush- covered valley in the eastern foothills of the Sierra Nevada mountain range the old gold­mining town, once busy with life began in the 1870s, when prospective miners arrived in the town in hopes of finding gold and becoming wealthy. By the 1940s, the golds was gone and the last mine closed. Today not many structures remain in Bodie, there is about 20 percent of the number that stood in the 1870a, when the town had up to 8.000 inhabitants.

In the 1870s, thirty mines were built and began producing large pieces of gold in large quantities. The standard Company was one of the first factories in American to extract the remaining traces of gold using electricity. Chemical processing was done in two stages. In the first stage, workers washed ground up ore over copper sheets covered with gold- grabbing mercury, then they heated in to release and condense the mercury, and turned the melted mixture into the shape of golf bars. In a second stage devised to obtain any remaining gold and silver particles, the one, now the consistency of sand was soaked in watered- down potassium cyanide. This drew the metals out into a form that could be trapped by trays containing small pieces of zine. This process went on for about 70 years, until the gold mines dried up.

When the California state Parks Department took over Bodie in 1962, it began a program of “arrested decay,’ maintaining the run- down structures just as they appeared at the time the department acquired the town.

According to Charley Spiller, a Bodie maintenance mechanic, the greatest enemies of preservation are wind, which can gust up to 100 miles an hour on nearby mountains, and snow, which average 13 feet a year. When snow gets into a building and sits and.... Into the floors, the condition of the floors gets worse, and they often rot. Currently, a team of three or four workers spends six months of each year.

Strengthening walls, repairing roofs, and replacing smashed windows. Spiller and his team rebuild walls using pine similar to the native Jeffrey pine that was originally used without constant attention, most houses would fall apart. Nearby towns similar to Bodie have already disappeared because, for one reason or another, they weren’t maintained.

While the staff work to preserve the site’s empty look, a variety of natural life lives on in the remains of the town. California ground squirrels tunnel into the shrub- covered earth, feeding on meadow grass and bitterbrush. Coyotes- and from time to time a mountain lion, bobcat, or bear- amble through the town. As people left their homes in Bodies and no one else moved in, the houses became popular havens for species that thrive in the empty places, such as deer, mice, snakes, and lizards. Trillions of microbes, life forms invisible to the human eye, also live in the soil, some of which can consume the toxic mercury and cyanide by- products of mining. One microbial ecologist found that deserts, like the one in Bodie, contain up to twice as many bacterial species, roughly 10,000 per 10 square meters, as do acidic rainforest soils. The deserts of the American West, where thousands of ghost towns stand, are therefore surprisingly full of life.

It is the life that left Bodies, however, that most interests the tourists who visit.’ Ghost towns like Bodie, 1 cultural geographer Dydia DeLyser explains, 1 are a powerful draw because they are perceived as authentic- actual abandoned towns presented more or less as they were left, and therefore as they once were Delyser says that visitors examine their originality, asking questions like’ was all this stuff really just left here? Or “was it all set up to make it look like a ghost town? If would be a mistake, Delyser says, for anyone to think that the plates on the table or other items at Bodie were left behind in a rush to escape.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('a4a6ed39-bb2d-5b71-83f5-324bb1b3106c', '6a36747b-1c14-5ccf-926a-8d8023764624', 1, 'NOTE_COMPLETION', 'READING', 2, $md$### Question 1

Questions 1-7
Questions 1-7
Complete the notes below.
Choose
ONE WORD AND/ OR A NUMBER from
the Passage for each answer.
Write your answers in boxes 1-7 on your answer sheet.
Bodie’s past
About Bodie
Located in a
1
in the Sierra Nevada.
In the 1870s attracted people who wanted to be
2
in order to get rich.
Saw the end of gold production in the 1940s.
Now has about
3
Of the original buildings.
Gold mining and milling
Large- scale production of gold
Extraction of smaller amounts of gold required
4
Extraction by chemical processing involved:
First stage:
Ore was rinsed over mercury- covered sheets of
5
Melted mixture was formed into bars
Second stage (to filter any leftover gold or silver particles):
Ore with texture like
6
was immersed in potassium cyanide.
Mentals were taken out and caught in containers filled with
7

Located in a 1 ____ in the Sierra Nevada.$md$, NULL, ARRAY['.*valley.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('ebe7974e-c1bc-5a90-92bf-a2428e20a496', '6a36747b-1c14-5ccf-926a-8d8023764624', 2, 'NOTE_COMPLETION', 'READING', 2, $md$### Question 2

Questions 1-7
Questions 1-7
Complete the notes below.
Choose
ONE WORD AND/ OR A NUMBER from
the Passage for each answer.
Write your answers in boxes 1-7 on your answer sheet.
Bodie’s past
About Bodie
Located in a
1
in the Sierra Nevada.
In the 1870s attracted people who wanted to be
2
in order to get rich.
Saw the end of gold production in the 1940s.
Now has about
3
Of the original buildings.
Gold mining and milling
Large- scale production of gold
Extraction of smaller amounts of gold required
4
Extraction by chemical processing involved:
First stage:
Ore was rinsed over mercury- covered sheets of
5
Melted mixture was formed into bars
Second stage (to filter any leftover gold or silver particles):
Ore with texture like
6
was immersed in potassium cyanide.
Mentals were taken out and caught in containers filled with
7

In the 1870s attracted people who wanted to be 2 ____ in order to get rich.$md$, NULL, ARRAY['.*miners.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('132d45c5-e2a9-5647-9318-6bcb160d4b11', '6a36747b-1c14-5ccf-926a-8d8023764624', 3, 'NOTE_COMPLETION', 'READING', 2, $md$### Question 3

Questions 1-7
Questions 1-7
Complete the notes below.
Choose
ONE WORD AND/ OR A NUMBER from
the Passage for each answer.
Write your answers in boxes 1-7 on your answer sheet.
Bodie’s past
About Bodie
Located in a
1
in the Sierra Nevada.
In the 1870s attracted people who wanted to be
2
in order to get rich.
Saw the end of gold production in the 1940s.
Now has about
3
Of the original buildings.
Gold mining and milling
Large- scale production of gold
Extraction of smaller amounts of gold required
4
Extraction by chemical processing involved:
First stage:
Ore was rinsed over mercury- covered sheets of
5
Melted mixture was formed into bars
Second stage (to filter any leftover gold or silver particles):
Ore with texture like
6
was immersed in potassium cyanide.
Mentals were taken out and caught in containers filled with
7

Now has about 3 ____ Of the original buildings.$md$, NULL, ARRAY['.*20.*percent.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('0940c850-24b7-58f0-84a1-ceb47ecf6dbb', '6a36747b-1c14-5ccf-926a-8d8023764624', 4, 'NOTE_COMPLETION', 'READING', 2, $md$### Question 4

Questions 1-7
Questions 1-7
Complete the notes below.
Choose
ONE WORD AND/ OR A NUMBER from
the Passage for each answer.
Write your answers in boxes 1-7 on your answer sheet.
Bodie’s past
About Bodie
Located in a
1
in the Sierra Nevada.
In the 1870s attracted people who wanted to be
2
in order to get rich.
Saw the end of gold production in the 1940s.
Now has about
3
Of the original buildings.
Gold mining and milling
Large- scale production of gold
Extraction of smaller amounts of gold required
4
Extraction by chemical processing involved:
First stage:
Ore was rinsed over mercury- covered sheets of
5
Melted mixture was formed into bars
Second stage (to filter any leftover gold or silver particles):
Ore with texture like
6
was immersed in potassium cyanide.
Mentals were taken out and caught in containers filled with
7

Extraction of smaller amounts of gold required 4 ____$md$, NULL, ARRAY['.*electricity.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('c37b2d31-3691-562e-b494-ed87eb65e39f', '6a36747b-1c14-5ccf-926a-8d8023764624', 5, 'NOTE_COMPLETION', 'READING', 3, $md$### Question 5

Questions 1-7
Questions 1-7
Complete the notes below.
Choose
ONE WORD AND/ OR A NUMBER from
the Passage for each answer.
Write your answers in boxes 1-7 on your answer sheet.
Bodie’s past
About Bodie
Located in a
1
in the Sierra Nevada.
In the 1870s attracted people who wanted to be
2
in order to get rich.
Saw the end of gold production in the 1940s.
Now has about
3
Of the original buildings.
Gold mining and milling
Large- scale production of gold
Extraction of smaller amounts of gold required
4
Extraction by chemical processing involved:
First stage:
Ore was rinsed over mercury- covered sheets of
5
Melted mixture was formed into bars
Second stage (to filter any leftover gold or silver particles):
Ore with texture like
6
was immersed in potassium cyanide.
Mentals were taken out and caught in containers filled with
7

Ore was rinsed over mercury- covered sheets of 5 ____$md$, NULL, ARRAY['.*copper.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('dc9c3d51-66c0-55e9-aed6-11c08a7e7e4e', '6a36747b-1c14-5ccf-926a-8d8023764624', 6, 'NOTE_COMPLETION', 'READING', 3, $md$### Question 6

Questions 1-7
Questions 1-7
Complete the notes below.
Choose
ONE WORD AND/ OR A NUMBER from
the Passage for each answer.
Write your answers in boxes 1-7 on your answer sheet.
Bodie’s past
About Bodie
Located in a
1
in the Sierra Nevada.
In the 1870s attracted people who wanted to be
2
in order to get rich.
Saw the end of gold production in the 1940s.
Now has about
3
Of the original buildings.
Gold mining and milling
Large- scale production of gold
Extraction of smaller amounts of gold required
4
Extraction by chemical processing involved:
First stage:
Ore was rinsed over mercury- covered sheets of
5
Melted mixture was formed into bars
Second stage (to filter any leftover gold or silver particles):
Ore with texture like
6
was immersed in potassium cyanide.
Mentals were taken out and caught in containers filled with
7

Ore with texture like 6 ____ was immersed in potassium cyanide.$md$, NULL, ARRAY['.*sand.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('ce6143d1-8bb6-5b7e-a547-b140f7d96252', '6a36747b-1c14-5ccf-926a-8d8023764624', 7, 'NOTE_COMPLETION', 'READING', 3, $md$### Question 7

Questions 1-7
Questions 1-7
Complete the notes below.
Choose
ONE WORD AND/ OR A NUMBER from
the Passage for each answer.
Write your answers in boxes 1-7 on your answer sheet.
Bodie’s past
About Bodie
Located in a
1
in the Sierra Nevada.
In the 1870s attracted people who wanted to be
2
in order to get rich.
Saw the end of gold production in the 1940s.
Now has about
3
Of the original buildings.
Gold mining and milling
Large- scale production of gold
Extraction of smaller amounts of gold required
4
Extraction by chemical processing involved:
First stage:
Ore was rinsed over mercury- covered sheets of
5
Melted mixture was formed into bars
Second stage (to filter any leftover gold or silver particles):
Ore with texture like
6
was immersed in potassium cyanide.
Mentals were taken out and caught in containers filled with
7

Mentals were taken out and caught in containers filled with 7 ____$md$, NULL, ARRAY['.*zinc.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('383b0508-354b-565e-8a2c-932ba15eb75f', '6a36747b-1c14-5ccf-926a-8d8023764624', 8, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 8

Question 8-13
Question 8-13
Do the following statements agree with the information given in Reading Passage 1?
In boxed 8-13 on your answer sheet, wrire
TRUE if the statement agree with the information
FALE if the statement contradicts the information
NOT GIVEN if there is no information on this.
8
Wind and snow are the most difficult factors Bodie preservationists have to deal with
9
The maintenance team in Bodie was unable to locate the Jeffrey pine the settlers
10
Lack of funding has caused other towns like Bodie to disappear.
11
Many people left Bodie when wild animals started living in their homes.
12
Acidic rainforest soils tend to contain move microbes than the soil found in places like.
13
Some tourists doubt that items in Bodie were really used by people who lived there.

8 ____ Wind and snow are the most difficult factors Bodie preservationists have to deal with$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('251c4f98-e192-5ccb-8e86-1e430b41aa3e', '383b0508-354b-565e-8a2c-932ba15eb75f', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('23fcb46b-0ced-5f31-9841-8f14ee3d947a', '383b0508-354b-565e-8a2c-932ba15eb75f', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('877ae121-15f5-5e90-a124-e322c6d2365b', '383b0508-354b-565e-8a2c-932ba15eb75f', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('2c952745-f236-536d-99f7-82e7954e226e', '6a36747b-1c14-5ccf-926a-8d8023764624', 9, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 9

Question 8-13
Question 8-13
Do the following statements agree with the information given in Reading Passage 1?
In boxed 8-13 on your answer sheet, wrire
TRUE if the statement agree with the information
FALE if the statement contradicts the information
NOT GIVEN if there is no information on this.
8
Wind and snow are the most difficult factors Bodie preservationists have to deal with
9
The maintenance team in Bodie was unable to locate the Jeffrey pine the settlers
10
Lack of funding has caused other towns like Bodie to disappear.
11
Many people left Bodie when wild animals started living in their homes.
12
Acidic rainforest soils tend to contain move microbes than the soil found in places like.
13
Some tourists doubt that items in Bodie were really used by people who lived there.

9 ____ The maintenance team in Bodie was unable to locate the Jeffrey pine the settlers$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4706913c-87a6-59f9-9074-3346579f7153', '2c952745-f236-536d-99f7-82e7954e226e', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0fb43faf-9e91-5be8-8dcd-8f8a6a838e9e', '2c952745-f236-536d-99f7-82e7954e226e', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('81240552-01c9-586f-9c45-96ac22cf3dfe', '2c952745-f236-536d-99f7-82e7954e226e', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('6769cf4d-8549-5f44-93f1-bfce999219dc', '6a36747b-1c14-5ccf-926a-8d8023764624', 10, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 10

Question 8-13
Question 8-13
Do the following statements agree with the information given in Reading Passage 1?
In boxed 8-13 on your answer sheet, wrire
TRUE if the statement agree with the information
FALE if the statement contradicts the information
NOT GIVEN if there is no information on this.
8
Wind and snow are the most difficult factors Bodie preservationists have to deal with
9
The maintenance team in Bodie was unable to locate the Jeffrey pine the settlers
10
Lack of funding has caused other towns like Bodie to disappear.
11
Many people left Bodie when wild animals started living in their homes.
12
Acidic rainforest soils tend to contain move microbes than the soil found in places like.
13
Some tourists doubt that items in Bodie were really used by people who lived there.

10 ____ Lack of funding has caused other towns like Bodie to disappear.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6f2c846a-f396-5fef-84f6-28cc9c998670', '6769cf4d-8549-5f44-93f1-bfce999219dc', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f8361f53-3fd1-5081-8bf6-0a37c1c321e1', '6769cf4d-8549-5f44-93f1-bfce999219dc', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a1b5ec7b-1a4e-5201-9f46-709b374028cf', '6769cf4d-8549-5f44-93f1-bfce999219dc', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('5e2178fa-a685-5eb5-8047-1ef2964c03db', '6a36747b-1c14-5ccf-926a-8d8023764624', 11, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 11

Question 8-13
Question 8-13
Do the following statements agree with the information given in Reading Passage 1?
In boxed 8-13 on your answer sheet, wrire
TRUE if the statement agree with the information
FALE if the statement contradicts the information
NOT GIVEN if there is no information on this.
8
Wind and snow are the most difficult factors Bodie preservationists have to deal with
9
The maintenance team in Bodie was unable to locate the Jeffrey pine the settlers
10
Lack of funding has caused other towns like Bodie to disappear.
11
Many people left Bodie when wild animals started living in their homes.
12
Acidic rainforest soils tend to contain move microbes than the soil found in places like.
13
Some tourists doubt that items in Bodie were really used by people who lived there.

11 ____ Many people left Bodie when wild animals started living in their homes.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b2fc59f8-60f0-5ceb-9fcc-442cd2aa3785', '5e2178fa-a685-5eb5-8047-1ef2964c03db', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('afda400a-7368-573c-8936-d1c516392e48', '5e2178fa-a685-5eb5-8047-1ef2964c03db', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('73c4e6dc-acb3-5bbc-af55-50992e0b6e0b', '5e2178fa-a685-5eb5-8047-1ef2964c03db', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('8929bc46-9cf0-5c03-80b3-226130199153', '6a36747b-1c14-5ccf-926a-8d8023764624', 12, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 12

Question 8-13
Question 8-13
Do the following statements agree with the information given in Reading Passage 1?
In boxed 8-13 on your answer sheet, wrire
TRUE if the statement agree with the information
FALE if the statement contradicts the information
NOT GIVEN if there is no information on this.
8
Wind and snow are the most difficult factors Bodie preservationists have to deal with
9
The maintenance team in Bodie was unable to locate the Jeffrey pine the settlers
10
Lack of funding has caused other towns like Bodie to disappear.
11
Many people left Bodie when wild animals started living in their homes.
12
Acidic rainforest soils tend to contain move microbes than the soil found in places like.
13
Some tourists doubt that items in Bodie were really used by people who lived there.

12 ____ Acidic rainforest soils tend to contain move microbes than the soil found in places like.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cda53325-248c-57ec-aced-fb514a10cc02', '8929bc46-9cf0-5c03-80b3-226130199153', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4ae76c14-282e-5b55-9ea1-9105e6bffc38', '8929bc46-9cf0-5c03-80b3-226130199153', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d9d77b43-e1cc-58d6-b039-77ea3fe5f281', '8929bc46-9cf0-5c03-80b3-226130199153', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('0ab11d31-904d-574f-a054-9c4b50d7df11', '6a36747b-1c14-5ccf-926a-8d8023764624', 13, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 13

Question 8-13
Question 8-13
Do the following statements agree with the information given in Reading Passage 1?
In boxed 8-13 on your answer sheet, wrire
TRUE if the statement agree with the information
FALE if the statement contradicts the information
NOT GIVEN if there is no information on this.
8
Wind and snow are the most difficult factors Bodie preservationists have to deal with
9
The maintenance team in Bodie was unable to locate the Jeffrey pine the settlers
10
Lack of funding has caused other towns like Bodie to disappear.
11
Many people left Bodie when wild animals started living in their homes.
12
Acidic rainforest soils tend to contain move microbes than the soil found in places like.
13
Some tourists doubt that items in Bodie were really used by people who lived there.

13 ____ Some tourists doubt that items in Bodie were really used by people who lived there.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5d734b63-2829-5d8b-b54a-04975a882e92', '0ab11d31-904d-574f-a054-9c4b50d7df11', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3252cc29-88d0-5c62-a309-17a0994707e1', '0ab11d31-904d-574f-a054-9c4b50d7df11', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d6bd8fbd-a9c7-53e8-becf-c61f966087c6', '0ab11d31-904d-574f-a054-9c4b50d7df11', 3, $md$NOT GIVEN$md$, false);

COMMIT;
