BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-the-exploration-of-mars-1299'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-the-exploration-of-mars-1299';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-the-exploration-of-mars-1299';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-the-exploration-of-mars-1299';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('06c8df5c-e96d-50f2-8286-330167315d5d', 'ielts-reading-the-exploration-of-mars-1299', $t$The Exploration of Mars$t$, $md$## The Exploration of Mars

Nguồn:
- Test: https://mini-ielts.com/1299/reading/the-exploration-of-mars
- Solution: https://mini-ielts.com/1299/view-solution/reading/the-exploration-of-mars$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('12c22845-85f6-561d-b946-c7f65626819f', '06c8df5c-e96d-50f2-8286-330167315d5d', 1, $t$Reading — The Exploration of Mars$t$, $md$Read the passage and answer questions **1–14**.

### Passage: The Exploration of Mars

A . In 1877, Giovanni Schiaparelli, an Italian astronomer, made drawings and maps of the Martian surface that suggested strange features. The images from telescopes at this time were not as sharp as today’s. Schiaparelli said he could see a network of lines, or canali. In 1894, an American astronomer, Percival Lowell, made a series of observations of Mars from his own observations of Mars from his own observatory at Flagstaff, Arizona, USA. Lowell was convinced a great network of canals had been dug to irrigate crops for the Martian race! He suggested that each canal had fertile vegetation on either side, making them noticeable from Earth. Drawings and globes he made show a network of canals and oases all over the planet.

B . The idea that there was intelligent life on Mars gained strength in the late 19th century. In 1898, H.G. Wells wrote a science fiction classic, The War of the Worlds about an invading force of Martians who try to conquer Earth. They use highly advanced technology (advanced for 1898) to crush human resistance in their path. In 1917, Edgar Rice Burroughs wrote the first in a series of 11 novels about Mars. Strange beings and rampaging Martian monsters gripped the public’s imagination. A radio broadcast by Orson Welles on Halloween night in 1938 of The War of the Worlds caused widespread panic across America. People ran into the streets in their pyjamas-millions believed the dramatic reports of a Martian invasion.

C . Probes are very important to our understanding of other planets. Much of our recent knowledge comes from these robotic missions into space. The first images sent back from Mars came from Mariner 4 in July 1965. They showed a cratered and barren landscape, more like the surface of our moon than Earth. In 1969, Mariners 6 and 7 were launched and took 200 photographs of Mars’s southern hemisphere and pole on fly-by missions. But these showed little more information. In 1971, Mariner 9’s mission was to orbit the planet every 12 hours. In 1975, The USA sent two Viking probes to the planet, each with a lander and an orbiter. The Landers had sampler arms to scoop up Maritain rocks and did experiments to try and find signs of life. Although no life was found, they sent back the first colour pictures of the planet’s surface and atmosphere from pivoting cameras.

D . The Martian meteorite found in Earth aroused doubts to the above analysis. ALH84001 meteorite was discovered in December 1984 in Antarctica, by members of the ANSMET project; The sample was ejected from Mars about 17 million years ago and spent 11,000 years in or on the Antarctic ice sheets. Composition analysis by NASA revealed a kind of magnetite that on Earth, is only found in association with certain microorganisms. Some structures resembling the mineralized casts of terrestrial bacteria and their appendages fibrils or by-products occur in the rims of carbonate globules and pre-terrestrial aqueous alteration regions. The size and shape of the objects is consistent with Earthly fossilized nanobacteria but the existence of nanobacteria itself is still controversial.

E . In 1965, the Mariner 4 probe discovered that Mars had no global magnetic field that would protect the planet from potentially life-threatening cosmic radiation and solar radiation; observations made in the late 1990s by the Mars Global Surveyor confirmed this discovery. Scientists speculate that the lack of magnetic shielding helped the solar wind blow away much of Mars’s atmosphere over the course of several billion years. After mapping cosmic radiation levels at various depths on Mars, researchers have concluded that any life within the first several meters of the planet’s surface would be killed by lethal doses of cosmic radiation. In 2007, it was calculated that DNA and RNA damage by cosmic radiation would limit life on Mars to depths greater than 7.5 metres below the planet’s surface. Therefore, the best potential locations for discovering life on Mars may be at subsurface environments that have not been studied yet. Disappearance of the magnetic field may played an significant role in the process of Martian climate change. According to the valuation of the scientists, the climate of Mars gradually transits from warm and wet to cold and dry after magnetic field vanished.

F . NASA’s recent missions have focused on another question: whether Mars held lakes or oceans of liquid water on its surface in the ancient past. Scientists have found hematite, a mineral that forms in the presence of water. Thus, the mission of the Mars Exploration Rovers of 2004 was not to look for present or past life, but for evidence of liquid water on the surface of Mars in the planet’s ancient past. Liquid water, necessary for Earth life and for metabolism as generally conducted by species on Earth, cannot exist on the surface of Mars under its present low atmospheric pressure and temperature, except at the lowest shaded elevations for short periods and liquid water does not appear at the surface itself. In March 2004, NASA announced that its rover Opportunity had discovered evidence that Mars was, in the ancient past, a wet planet. This had raised hopes that evidence of past life might be found on the planet today. ESA confirmed that the Mars Express orbiter had directly detected huge reserves of water ice at Mars’ south pole in January 2004.

G . Researchers from the Center of Astrobiology (Spain) and the Catholic University of the North in Chile have found an ‘oasis’ of microorganisms two meters below the surface of the Atacama Desert, SOLID, a detector for signs of life which could be used in environments similar to subsoil on Mars. “We have named it a ‘microbial oasis’ because we found microorganisms developing in a habitat that was rich in rock salt and other highly hygroscopic compounds that absorb water” explained Victor Parro, researcher from the Center of Astrobiology in Spain. “If there are similar microbes on Mars or remains in similar conditions to the ones we have found in Atacama, we could detect them with instruments like SOLID” Parro highlighted.

H . Even more intriguing, however, is the alternative scenario by Spanish scientists: If those samples could be found to that use DNA, as Earthly life does, as their genetic code. It is extremely unlikely that such a highly specialised, complex molecule like DNA could have evolved separately on the two planets, indicating that there must be a common origin for Martian and Earthly life. Life based on DNA first appeared on Mars and then spread to Earth, where it then evolved into the myriad forms of plants and creatures that exist today. If this was found to be the case, we would have to face the logical conclusion: we are all Martian. If not, we would continue to search the life of signs.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('e255e763-aea5-5164-8151-e642dbcf007c', '12c22845-85f6-561d-b946-c7f65626819f', 1, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 1

Questions 1-6
Questions 1-6
The reading Passage has seven paragraphs
A-H.
Which paragraph contains the following information?
Write the correct letter
A- H
, in boxes
1-6
on your answer sheet.
1
Martian evidence on Earth
2
Mars and Earth may share the same life origin
3
certain agricultural construction was depicted specifically
4
the project which aims to identify life under similar condition of Mars
5
Mars had experienced terrifying climate transformation
6
Attempts in scientific investigation to find liquid water

1 ____ Martian evidence on Earth$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('71b5c5c8-63bc-55c0-9766-5b6d3503f0e0', 'e255e763-aea5-5164-8151-e642dbcf007c', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1d6d0b73-9513-53ab-a2fd-de8e317a8b69', 'e255e763-aea5-5164-8151-e642dbcf007c', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f6ba0995-7131-5eda-9aba-6f0422501c6b', 'e255e763-aea5-5164-8151-e642dbcf007c', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b7afb53e-1515-510d-949b-d0eb4a70e709', 'e255e763-aea5-5164-8151-e642dbcf007c', 4, $md$D$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('10dca9d3-4997-5716-b115-0a248581692c', 'e255e763-aea5-5164-8151-e642dbcf007c', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('41739df2-5128-5c10-9a78-5a5d202ffc49', 'e255e763-aea5-5164-8151-e642dbcf007c', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('deb14475-3ea2-51ec-a571-51facbae28f2', 'e255e763-aea5-5164-8151-e642dbcf007c', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('97d58038-7e32-5141-944d-7f02c295feda', 'e255e763-aea5-5164-8151-e642dbcf007c', 8, $md$H$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('d152ef24-ff85-58d8-a1dd-0fe550c26332', '12c22845-85f6-561d-b946-c7f65626819f', 2, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 2

Questions 1-6
Questions 1-6
The reading Passage has seven paragraphs
A-H.
Which paragraph contains the following information?
Write the correct letter
A- H
, in boxes
1-6
on your answer sheet.
1
Martian evidence on Earth
2
Mars and Earth may share the same life origin
3
certain agricultural construction was depicted specifically
4
the project which aims to identify life under similar condition of Mars
5
Mars had experienced terrifying climate transformation
6
Attempts in scientific investigation to find liquid water

2 ____ Mars and Earth may share the same life origin$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2be325cd-a3fb-51cb-84f4-20da47101179', 'd152ef24-ff85-58d8-a1dd-0fe550c26332', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c8bdac51-b05f-510e-8aaa-b41f760a4ae0', 'd152ef24-ff85-58d8-a1dd-0fe550c26332', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('397079ee-8e00-5c91-b6cc-ba4dbda1d01c', 'd152ef24-ff85-58d8-a1dd-0fe550c26332', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('04c1c909-d7b4-526f-aa85-864b797bb9ee', 'd152ef24-ff85-58d8-a1dd-0fe550c26332', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f5a1525c-a5fe-5f3f-b911-3b910198944f', 'd152ef24-ff85-58d8-a1dd-0fe550c26332', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6cd7d835-e5ae-5d52-90e4-5a99ec218945', 'd152ef24-ff85-58d8-a1dd-0fe550c26332', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ddf6979d-706c-5526-8308-4ade8e81b05a', 'd152ef24-ff85-58d8-a1dd-0fe550c26332', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fb260f79-2667-5421-a886-6ece4c5a4805', 'd152ef24-ff85-58d8-a1dd-0fe550c26332', 8, $md$H$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('83bd6b24-dad1-523d-9b24-352303174228', '12c22845-85f6-561d-b946-c7f65626819f', 3, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 3

Questions 1-6
Questions 1-6
The reading Passage has seven paragraphs
A-H.
Which paragraph contains the following information?
Write the correct letter
A- H
, in boxes
1-6
on your answer sheet.
1
Martian evidence on Earth
2
Mars and Earth may share the same life origin
3
certain agricultural construction was depicted specifically
4
the project which aims to identify life under similar condition of Mars
5
Mars had experienced terrifying climate transformation
6
Attempts in scientific investigation to find liquid water

3 ____ certain agricultural construction was depicted specifically$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3e07c7ea-9f55-5a7b-aa49-bf532f11a928', '83bd6b24-dad1-523d-9b24-352303174228', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('dcc4c779-2370-5917-8f67-0b304f3dfc9c', '83bd6b24-dad1-523d-9b24-352303174228', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a3383d80-7971-5bdc-bc5d-6371fbe13296', '83bd6b24-dad1-523d-9b24-352303174228', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('78956b71-68d8-5615-b9fe-6bd3ba70b515', '83bd6b24-dad1-523d-9b24-352303174228', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a97e1e2f-d96f-52d1-9632-a1f4b494e758', '83bd6b24-dad1-523d-9b24-352303174228', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('056a5c45-2937-5b2b-872b-63c99e66047a', '83bd6b24-dad1-523d-9b24-352303174228', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a8b98f08-0bdc-5af1-8b42-9122346589c6', '83bd6b24-dad1-523d-9b24-352303174228', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('29e0f988-1843-5dc7-b266-115b277c2f83', '83bd6b24-dad1-523d-9b24-352303174228', 8, $md$H$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('ab9a2663-1331-5e29-872e-c20af378c565', '12c22845-85f6-561d-b946-c7f65626819f', 4, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 4

Questions 1-6
Questions 1-6
The reading Passage has seven paragraphs
A-H.
Which paragraph contains the following information?
Write the correct letter
A- H
, in boxes
1-6
on your answer sheet.
1
Martian evidence on Earth
2
Mars and Earth may share the same life origin
3
certain agricultural construction was depicted specifically
4
the project which aims to identify life under similar condition of Mars
5
Mars had experienced terrifying climate transformation
6
Attempts in scientific investigation to find liquid water

4 ____ the project which aims to identify life under similar condition of Mars$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('799abf7c-9497-5028-8c80-1da723c39ce8', 'ab9a2663-1331-5e29-872e-c20af378c565', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('668d5746-763e-5928-9803-f7fd43f8c3f1', 'ab9a2663-1331-5e29-872e-c20af378c565', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2385d317-cb27-5652-bba7-a8e309e159c5', 'ab9a2663-1331-5e29-872e-c20af378c565', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('782b63a8-f2c8-5f8c-8aad-6c78d2acf47c', 'ab9a2663-1331-5e29-872e-c20af378c565', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('be1d91ad-ebed-547e-beb6-607d715ce901', 'ab9a2663-1331-5e29-872e-c20af378c565', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bf5ea183-517f-5a19-bebb-6b5ef7f1f65a', 'ab9a2663-1331-5e29-872e-c20af378c565', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9d324f85-c6ba-5c96-b2d5-80635f474adc', 'ab9a2663-1331-5e29-872e-c20af378c565', 7, $md$G$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7f1dfe66-20b4-56b0-af61-80cbc0a49a42', 'ab9a2663-1331-5e29-872e-c20af378c565', 8, $md$H$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('1fd9ba00-55c0-5120-94b9-bdad6fb1d1a3', '12c22845-85f6-561d-b946-c7f65626819f', 5, 'MATCHING_INFORMATION', 'READING', 3, $md$### Question 5

Questions 1-6
Questions 1-6
The reading Passage has seven paragraphs
A-H.
Which paragraph contains the following information?
Write the correct letter
A- H
, in boxes
1-6
on your answer sheet.
1
Martian evidence on Earth
2
Mars and Earth may share the same life origin
3
certain agricultural construction was depicted specifically
4
the project which aims to identify life under similar condition of Mars
5
Mars had experienced terrifying climate transformation
6
Attempts in scientific investigation to find liquid water

5 ____ Mars had experienced terrifying climate transformation$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4fb24fab-2a30-5913-8676-236c0ea1934a', '1fd9ba00-55c0-5120-94b9-bdad6fb1d1a3', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b57fd81d-6a44-54df-94ac-9e63b72342f7', '1fd9ba00-55c0-5120-94b9-bdad6fb1d1a3', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a51f7aa2-8074-5b65-9863-e3eeed2fc3c7', '1fd9ba00-55c0-5120-94b9-bdad6fb1d1a3', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('72be7109-16e8-5932-b373-33e9f0009bf8', '1fd9ba00-55c0-5120-94b9-bdad6fb1d1a3', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2a03dc6b-4b13-580b-84d0-ba4c0131a335', '1fd9ba00-55c0-5120-94b9-bdad6fb1d1a3', 5, $md$E$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7759e8cc-8b23-539f-b134-faed944ac239', '1fd9ba00-55c0-5120-94b9-bdad6fb1d1a3', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6ef37410-8d9a-5835-96c7-82a7fa4ab535', '1fd9ba00-55c0-5120-94b9-bdad6fb1d1a3', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1a543faa-bc0f-5eb9-a65b-48910232906b', '1fd9ba00-55c0-5120-94b9-bdad6fb1d1a3', 8, $md$H$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('f3af7b0e-8fdf-5b7f-84cc-3c07f41e7ba8', '12c22845-85f6-561d-b946-c7f65626819f', 6, 'MATCHING_INFORMATION', 'READING', 3, $md$### Question 6

Questions 1-6
Questions 1-6
The reading Passage has seven paragraphs
A-H.
Which paragraph contains the following information?
Write the correct letter
A- H
, in boxes
1-6
on your answer sheet.
1
Martian evidence on Earth
2
Mars and Earth may share the same life origin
3
certain agricultural construction was depicted specifically
4
the project which aims to identify life under similar condition of Mars
5
Mars had experienced terrifying climate transformation
6
Attempts in scientific investigation to find liquid water

6 ____ Attempts in scientific investigation to find liquid water$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('670eeb14-be21-5da3-b5a5-ab596bb4faed', 'f3af7b0e-8fdf-5b7f-84cc-3c07f41e7ba8', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('04828a9b-023a-5d7d-b6f5-65150ec3ed35', 'f3af7b0e-8fdf-5b7f-84cc-3c07f41e7ba8', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7a9d2281-2252-50dc-8ff6-319e8fd6fa79', 'f3af7b0e-8fdf-5b7f-84cc-3c07f41e7ba8', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e1c9fc0d-4875-5198-abbf-1cc0550a578d', 'f3af7b0e-8fdf-5b7f-84cc-3c07f41e7ba8', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5b9ba3f9-8728-56b5-a032-ebee5d0d4018', 'f3af7b0e-8fdf-5b7f-84cc-3c07f41e7ba8', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f4b40ef6-bff3-593d-a36d-cd8d1498b68c', 'f3af7b0e-8fdf-5b7f-84cc-3c07f41e7ba8', 6, $md$F$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a869b47f-9188-5a8d-91d1-031d67c24f2e', 'f3af7b0e-8fdf-5b7f-84cc-3c07f41e7ba8', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('11fee602-d182-56e5-909f-49b9ece07c2a', 'f3af7b0e-8fdf-5b7f-84cc-3c07f41e7ba8', 8, $md$H$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('8b592452-738a-5bc1-86a7-3c7f859ca597', '12c22845-85f6-561d-b946-c7f65626819f', 7, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 7

Questions 7-10
Questions 7-10
Choose the correct letter,
A, B, C or D.
Write your answers in boxes
7-10
on your answer sheet.
7. How did
Percival Lowell
describe Mars in this passage?
A
Perfect observation location is in Arizona.
B
Canals of Mars are broader than that of the earth,
C
Dedicated water and agriculture trace is similar to the earth.
D
Actively moving Martian lives are found by observation.
8. How did people change their point of view towards Mars
from 19th century
?
A
They experienced Martian attack.
B
They learned knowledge of mars through some literature works.
C
They learned new concept by listening famous radio program.
D
They attended lectures given by famous writers.
9. In 1960s, which information is correct about Mars by a number of Probes sent to the space?
A
It has a landscape full of rock and river
B
It was not as vivid as the earth
C
It contained the same substance as in the moon
D
It had different images from the following probes
10.What is the implication of project proceeded by technology called SOLID in
Atacama Desert?
A
It could be employed to explore organisms under Martian condition.
B
This technology could NOT be used to identify life on similar condition of Mars.
C
Atacama Desert is the only place that has a suitable environment for organisms.
D
Life had not yet been found yet in Atacama Desert.

Choose the correct letter, A, B, C or D. Write your answers in boxes 7-10 on your answer sheet.$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('a08bb6eb-6996-502c-a00b-128dde808eb0', '12c22845-85f6-561d-b946-c7f65626819f', 8, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 8

Questions 7-10
Questions 7-10
Choose the correct letter,
A, B, C or D.
Write your answers in boxes
7-10
on your answer sheet.
7. How did
Percival Lowell
describe Mars in this passage?
A
Perfect observation location is in Arizona.
B
Canals of Mars are broader than that of the earth,
C
Dedicated water and agriculture trace is similar to the earth.
D
Actively moving Martian lives are found by observation.
8. How did people change their point of view towards Mars
from 19th century
?
A
They experienced Martian attack.
B
They learned knowledge of mars through some literature works.
C
They learned new concept by listening famous radio program.
D
They attended lectures given by famous writers.
9. In 1960s, which information is correct about Mars by a number of Probes sent to the space?
A
It has a landscape full of rock and river
B
It was not as vivid as the earth
C
It contained the same substance as in the moon
D
It had different images from the following probes
10.What is the implication of project proceeded by technology called SOLID in
Atacama Desert?
A
It could be employed to explore organisms under Martian condition.
B
This technology could NOT be used to identify life on similar condition of Mars.
C
Atacama Desert is the only place that has a suitable environment for organisms.
D
Life had not yet been found yet in Atacama Desert.

Choose the correct letter, A, B, C or D. Write your answers in boxes 7-10 on your answer sheet.$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('2998fc3d-4764-5ccd-a18d-6aff538ed983', '12c22845-85f6-561d-b946-c7f65626819f', 9, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 9

Questions 7-10
Questions 7-10
Choose the correct letter,
A, B, C or D.
Write your answers in boxes
7-10
on your answer sheet.
7. How did
Percival Lowell
describe Mars in this passage?
A
Perfect observation location is in Arizona.
B
Canals of Mars are broader than that of the earth,
C
Dedicated water and agriculture trace is similar to the earth.
D
Actively moving Martian lives are found by observation.
8. How did people change their point of view towards Mars
from 19th century
?
A
They experienced Martian attack.
B
They learned knowledge of mars through some literature works.
C
They learned new concept by listening famous radio program.
D
They attended lectures given by famous writers.
9. In 1960s, which information is correct about Mars by a number of Probes sent to the space?
A
It has a landscape full of rock and river
B
It was not as vivid as the earth
C
It contained the same substance as in the moon
D
It had different images from the following probes
10.What is the implication of project proceeded by technology called SOLID in
Atacama Desert?
A
It could be employed to explore organisms under Martian condition.
B
This technology could NOT be used to identify life on similar condition of Mars.
C
Atacama Desert is the only place that has a suitable environment for organisms.
D
Life had not yet been found yet in Atacama Desert.

Choose the correct letter, A, B, C or D. Write your answers in boxes 7-10 on your answer sheet.$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('d9762f7b-3291-58f5-87cb-562d30bccd3a', '12c22845-85f6-561d-b946-c7f65626819f', 10, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 10

Questions 7-10
Questions 7-10
Choose the correct letter,
A, B, C or D.
Write your answers in boxes
7-10
on your answer sheet.
7. How did
Percival Lowell
describe Mars in this passage?
A
Perfect observation location is in Arizona.
B
Canals of Mars are broader than that of the earth,
C
Dedicated water and agriculture trace is similar to the earth.
D
Actively moving Martian lives are found by observation.
8. How did people change their point of view towards Mars
from 19th century
?
A
They experienced Martian attack.
B
They learned knowledge of mars through some literature works.
C
They learned new concept by listening famous radio program.
D
They attended lectures given by famous writers.
9. In 1960s, which information is correct about Mars by a number of Probes sent to the space?
A
It has a landscape full of rock and river
B
It was not as vivid as the earth
C
It contained the same substance as in the moon
D
It had different images from the following probes
10.What is the implication of project proceeded by technology called SOLID in
Atacama Desert?
A
It could be employed to explore organisms under Martian condition.
B
This technology could NOT be used to identify life on similar condition of Mars.
C
Atacama Desert is the only place that has a suitable environment for organisms.
D
Life had not yet been found yet in Atacama Desert.

Choose the correct letter, A, B, C or D. Write your answers in boxes 7-10 on your answer sheet.$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('0d1c7795-d7f7-5a43-b258-c85036a759bc', '12c22845-85f6-561d-b946-c7f65626819f', 11, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 11

Questions 11-14
Questions 11-14
Do the following statements agree with the information given in
Reading Passage
?
In boxes
11-14
on your answer sheet, write
TRUE
if the statement is true
FALSE
if the statement is false
NOT GIVEN
if the information is not given in the passage
3
11
Technology of Martian creature was superior than what human had at that time in every field according to The War of the Worlds
12
Proof sent by Viking probes has not been challenged yet
13
Analysis on meteorite from Mars found a substance which is connected to some germs
14
According to Victor Parro, their project will be deployed on Mars after they identified DNA substance on earth

11 ____ Technology of Martian creature was superior than what human had at that time in every field according to The War of the Worlds$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f12283d2-04b7-5b48-8764-828896dcfa5b', '0d1c7795-d7f7-5a43-b258-c85036a759bc', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('77fc715f-dd07-5ce1-bcc7-05eb7fe31b4c', '0d1c7795-d7f7-5a43-b258-c85036a759bc', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('53f000d8-8a8f-5b79-8fa6-fc51cf2a0041', '0d1c7795-d7f7-5a43-b258-c85036a759bc', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('48e5640a-dfde-5283-a4c7-1dee2a212366', '12c22845-85f6-561d-b946-c7f65626819f', 12, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 12

Questions 11-14
Questions 11-14
Do the following statements agree with the information given in
Reading Passage
?
In boxes
11-14
on your answer sheet, write
TRUE
if the statement is true
FALSE
if the statement is false
NOT GIVEN
if the information is not given in the passage
3
11
Technology of Martian creature was superior than what human had at that time in every field according to The War of the Worlds
12
Proof sent by Viking probes has not been challenged yet
13
Analysis on meteorite from Mars found a substance which is connected to some germs
14
According to Victor Parro, their project will be deployed on Mars after they identified DNA substance on earth

12 ____ Proof sent by Viking probes has not been challenged yet$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('05b3245c-7e3e-55d3-9e12-6d13b9194c91', '48e5640a-dfde-5283-a4c7-1dee2a212366', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6898d33e-1f10-5551-8136-f32cb81f7067', '48e5640a-dfde-5283-a4c7-1dee2a212366', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('91bd6076-64d1-57d6-88c6-cd63a648c5b8', '48e5640a-dfde-5283-a4c7-1dee2a212366', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('99d0fa83-d9bc-5d20-9094-583230fc7e01', '12c22845-85f6-561d-b946-c7f65626819f', 13, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 13

Questions 11-14
Questions 11-14
Do the following statements agree with the information given in
Reading Passage
?
In boxes
11-14
on your answer sheet, write
TRUE
if the statement is true
FALSE
if the statement is false
NOT GIVEN
if the information is not given in the passage
3
11
Technology of Martian creature was superior than what human had at that time in every field according to The War of the Worlds
12
Proof sent by Viking probes has not been challenged yet
13
Analysis on meteorite from Mars found a substance which is connected to some germs
14
According to Victor Parro, their project will be deployed on Mars after they identified DNA substance on earth

13 ____ Analysis on meteorite from Mars found a substance which is connected to some germs$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('18db9206-534c-53b4-ba74-21c8dd32c8ec', '99d0fa83-d9bc-5d20-9094-583230fc7e01', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b6ebfc43-66ca-5f4b-b66c-a0039903c4b5', '99d0fa83-d9bc-5d20-9094-583230fc7e01', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5a2345c4-4b50-5f1c-99df-87a02d13c272', '99d0fa83-d9bc-5d20-9094-583230fc7e01', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('65be9a7c-359a-5684-a364-d1643069b09d', '12c22845-85f6-561d-b946-c7f65626819f', 14, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 14

Questions 11-14
Questions 11-14
Do the following statements agree with the information given in
Reading Passage
?
In boxes
11-14
on your answer sheet, write
TRUE
if the statement is true
FALSE
if the statement is false
NOT GIVEN
if the information is not given in the passage
3
11
Technology of Martian creature was superior than what human had at that time in every field according to The War of the Worlds
12
Proof sent by Viking probes has not been challenged yet
13
Analysis on meteorite from Mars found a substance which is connected to some germs
14
According to Victor Parro, their project will be deployed on Mars after they identified DNA substance on earth

14 ____ According to Victor Parro, their project will be deployed on Mars after they identified DNA substance on earth$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ebda03fd-5dde-5fc7-b36d-70ccb0baaf94', '65be9a7c-359a-5684-a364-d1643069b09d', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8b849149-065d-5bd8-a9f5-1e19bd872845', '65be9a7c-359a-5684-a364-d1643069b09d', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3f0f632b-9fc6-5613-9b70-b75a9e489975', '65be9a7c-359a-5684-a364-d1643069b09d', 3, $md$NOT GIVEN$md$, true);

COMMIT;
