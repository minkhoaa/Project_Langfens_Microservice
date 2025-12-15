BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-origin-of-species--continent-formation-1301'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-origin-of-species--continent-formation-1301';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-origin-of-species--continent-formation-1301';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-origin-of-species--continent-formation-1301';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('a13d0f73-4fca-5d43-a6e6-868413571482', 'ielts-reading-origin-of-species--continent-formation-1301', $t$Origin of Species & Continent Formation$t$, $md$## Origin of Species & Continent Formation

Nguồn:
- Test: https://mini-ielts.com/1301/reading/origin-of-species--continent-formation
- Solution: https://mini-ielts.com/1301/view-solution/reading/origin-of-species--continent-formation$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('732d0055-7869-5f27-bf8f-f8b1d0adffff', 'a13d0f73-4fca-5d43-a6e6-868413571482', 1, $t$Reading — Origin of Species & Continent Formation$t$, $md$Read the passage and answer questions **1–13**.

### Passage: Origin of Species & Continent Formation

A

THE FACT THAT there was once a Pangean supercontinent, a Panthalassa Ocean, and a Tethys Ocean, has profound implications for the evolution of multicellular life on Earth. These considerations were unknown to the scientists of the 19th century – making their scientific deductions even more remarkable. Quite independently of each other, Charles Darwin and his young contemporary Alfred Russel Wallace reached the conclusion that life had evolved by natural selection. Wallace later wrote in My Life of his own inspiration:

B

Why do some species die and some life? The answer was clearly that on the whole the best fitted lived. From the effects of disease the most healthy escaped; from enemies the strongest, the swiftest or the most cunning from famine the best hunters – then it suddenly flashed on me that this self-acting process would improve the race, because in every generation the inferior would inevitably be killed off and the superior would remain, that is, the fittest would survive.

C

Both Darwin’s and Wallace’s ideas about natural selection had been influenced by the essays of Thomas Malthus in his Principles of Population. Their conclusion, however, had been the direct result of their personal observation of animals and plants in widely separated geographic locations: Darwin from his experiences during the voyage of the Beagle , and particularly during the ship’s visit to the Galapagos Islands in the East Pacific in 1835; Wallace during his years of travel in the Amazon Basin and in the Indonesia-Australian Archipelago in the 1850s.

D

Darwin had been documenting his ideas on natural selection for many years when he received a paper on this selfsame subject from Wallace, who asked for Darwin’s opinion and help in getting it published. In July 1858, Charles Lyell and J. D Hooker, close friends of Darwin, pressed Darwin to present his conclusions so that he would not lose priority to an unknown naturalist. Presiding over the hastily called but now historic meeting of the Linnean Society in London, Lyell and Hooker explained to the distinguished members how “these two gentlemen” (who were absent: Wallace was abroad and Darwin chose not to attend), had “independently and unknown to one another, conceived the same very ingenious theory,”

E

Both Darwin and Wallace had realized that the anomalous distribution of species in particular regions had profound evolutionary significance. Subsequently, Darwin spent the rest of his days in almost total seclusion thinking and writing mainly about the origin of species. In contrast, Wallace applied himself to the science of biogeography, the study of the pattern and distribution of species, and its significance, resulting in the publication of a massive two-volume work the Geographical Distribution of Animals in 1876.

F

Wallace was a gentle and modest man, but also persistent and quietly courageous. He spent years working in the most arduous possible climates and terrains, particularly in the Malay archipelago, he made patient and detailed zoological observations and collected a huge number of specimens for museums and collectors-which is how he made a living. One result of his work was the conclusion that there is a distinct faunal boundary, called “Wallace’s line,” between an Asian realm of animals in Java, Bronco and the Philipiones and an Australian realm in New Guinea and Australia. In essence, this boundary posed a difficult question: How on Earth did plants and animals with a clear affinity to the Northern Hemisphere meet with their Southern Hemispheric counterparts along such a distinct Malaysian demarcation zone? Wallace was uncertain about demarcation on one particular island-Celebes, a curiously shaped place that is midway between the two groups. Initially, he assigned its flora-fauna to the Australian side of the line, but later he transferred it to the Asian side. Today we know the reason for his dilemma. 200MYA East and West Celebes were islands with their own natural history lying on opposite sides of the Tethys Ocean. They did not collide until about 15 MYA. The answer to the main question is that Wallace’s Line categorizes Laurasia-derived flora-fauna (the Asian) and Gondwana-derived flora-fauna (the Australian), fauna that had evolved on opposing shares of the Tethys. The closure of the Tethys Ocean today is manifested by the ongoing collision of Australia/New Guinea with Indochina/Indonesia and the continuing closure of the Mediterranean Sea – a remnant of the Western Tethys Ocean.

G

IN HIS ORIGIN OF CONTINENTS AND OCEANS, Wegener quoted at length from Wallace’s Geographical Distribution of Animals. According to Wegener’s reading, Wallace had identified three clear divisions of Australian animals, which supported his own theory of continental displacement. Wallace had shown that animals long established in southwestern Australia had an affinity with animals in South Africa, Madagascar, India, and Ceylon, but did not have an affinity with those in Asia. Wallace also showed that Australian marsupials and monotremes are clearly related to those in South America, the Moluccas, and various Pacific islands and that none are found in neighboring Indonesia. From this and related data, Wegener concluded that the then broadly accepted “landbridge” theory could not account for this distribution of animals and that only this theory of continental drift could explain it.

H

The theory that Wegener dismissed in preference to his own proposed that plants and animals had once migrated across now-submerged intercontinental landbridges. In 1885, one of Europe’s leading geologists, Eduard Suess, theorized that as the rigid Earth cools, its upper-crust shrinks and wrinkles like the withering skin of an aging apple. He suggested that the planet’s seas and oceans now fill the wrinkles between once-contiguous plateaus.

I

Today, we know that we live on a dynamic Earth with shifting, colliding and separating tectonic plates, not a “withering skin”, and the main debate in the field of biogeography has shifted. The discussion now concerns “dispersalism” versus “vicarianism”: unrestricted radiation of species on the one hand and the development of barriers to migration on the other. Dispersion is a short-term phenomenon – the daily or seasonal migration of species and their radiation to the limits of their natural environment on an extensive and continuous landmass. Vicarian evolution, however, depends upon the separation and isolation of a variety of species within the confines of natural barriers in the form of islands, lakes, or shallow seas – topographical features that take a long time to develop.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('756d4216-a227-536e-8c9b-721d18a00e6e', '732d0055-7869-5f27-bf8f-f8b1d0adffff', 1, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 1

Questions 1-5
Questions 1-5
Use the information in the passage to match the people (listed
A-E
) with opinions or deeds below.
Write the appropriate letters
A-E
in boxes
1-5
on your answer sheet.
A
Suess
B
Wallace
C
Darwin and Wallace
D
Wegener
E
Lyell and Hooker
1
urged Darwin to publish his scientific findings
2
Depicted physical feature of earth’s crust.
3
believed in continental drift theory while rejecting another one
4
Published works about wildlife distribution in a different region.
5
Evolution of species is based on selection by nature.

1 ____ urged Darwin to publish his scientific findings$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('02baaea5-2d7e-5ede-b8b3-3f1c492bad70', '756d4216-a227-536e-8c9b-721d18a00e6e', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8fc6eb5e-2fa9-5e74-9ccd-58bbca978aad', '756d4216-a227-536e-8c9b-721d18a00e6e', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5611ff1c-9565-56c0-822b-ff7fbe98dfff', '756d4216-a227-536e-8c9b-721d18a00e6e', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('48dc226f-2902-51d8-904a-abe489e63d25', '756d4216-a227-536e-8c9b-721d18a00e6e', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cf7969ed-2fd4-5383-95a9-6e92814230b9', '756d4216-a227-536e-8c9b-721d18a00e6e', 5, $md$E$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('29bbb4e5-0f56-5639-8a7f-f58fe374c173', '732d0055-7869-5f27-bf8f-f8b1d0adffff', 2, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 2

Questions 1-5
Questions 1-5
Use the information in the passage to match the people (listed
A-E
) with opinions or deeds below.
Write the appropriate letters
A-E
in boxes
1-5
on your answer sheet.
A
Suess
B
Wallace
C
Darwin and Wallace
D
Wegener
E
Lyell and Hooker
1
urged Darwin to publish his scientific findings
2
Depicted physical feature of earth’s crust.
3
believed in continental drift theory while rejecting another one
4
Published works about wildlife distribution in a different region.
5
Evolution of species is based on selection by nature.

2 ____ Depicted physical feature of earth’s crust.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9a0d10fa-8f4a-5365-a3a3-f91fe19fb8d4', '29bbb4e5-0f56-5639-8a7f-f58fe374c173', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('85e88e2f-8991-5a27-be7b-2cf8690d492b', '29bbb4e5-0f56-5639-8a7f-f58fe374c173', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('aa412f52-ce01-5311-98ee-84149d71fd55', '29bbb4e5-0f56-5639-8a7f-f58fe374c173', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('62985273-5cf4-5d51-9d5a-b39d1f805b8c', '29bbb4e5-0f56-5639-8a7f-f58fe374c173', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4006983b-c6bd-5f01-9854-b7ec49505ecd', '29bbb4e5-0f56-5639-8a7f-f58fe374c173', 5, $md$E$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('971181df-9fa6-5470-8181-88486578fdc8', '732d0055-7869-5f27-bf8f-f8b1d0adffff', 3, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 3

Questions 1-5
Questions 1-5
Use the information in the passage to match the people (listed
A-E
) with opinions or deeds below.
Write the appropriate letters
A-E
in boxes
1-5
on your answer sheet.
A
Suess
B
Wallace
C
Darwin and Wallace
D
Wegener
E
Lyell and Hooker
1
urged Darwin to publish his scientific findings
2
Depicted physical feature of earth’s crust.
3
believed in continental drift theory while rejecting another one
4
Published works about wildlife distribution in a different region.
5
Evolution of species is based on selection by nature.

3 ____ believed in continental drift theory while rejecting another one$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b9f5545e-1bbe-5aaf-90df-ec71b6fcd199', '971181df-9fa6-5470-8181-88486578fdc8', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5ce48a62-1a7b-5608-9175-293d9a7c20d4', '971181df-9fa6-5470-8181-88486578fdc8', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('dca4c974-d5ee-581f-9836-4843b5655ea3', '971181df-9fa6-5470-8181-88486578fdc8', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b0cb99a0-c5d8-5fa2-a9ab-1c5e4d3843c1', '971181df-9fa6-5470-8181-88486578fdc8', 4, $md$D$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('91b23d28-ff62-5173-b3b2-7259490c92bb', '971181df-9fa6-5470-8181-88486578fdc8', 5, $md$E$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('a180971b-4d3b-5af8-a859-fe46b27a9729', '732d0055-7869-5f27-bf8f-f8b1d0adffff', 4, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 4

Questions 1-5
Questions 1-5
Use the information in the passage to match the people (listed
A-E
) with opinions or deeds below.
Write the appropriate letters
A-E
in boxes
1-5
on your answer sheet.
A
Suess
B
Wallace
C
Darwin and Wallace
D
Wegener
E
Lyell and Hooker
1
urged Darwin to publish his scientific findings
2
Depicted physical feature of earth’s crust.
3
believed in continental drift theory while rejecting another one
4
Published works about wildlife distribution in a different region.
5
Evolution of species is based on selection by nature.

4 ____ Published works about wildlife distribution in a different region.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('303d9959-167b-5890-b184-5bf4c7c8854a', 'a180971b-4d3b-5af8-a859-fe46b27a9729', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('37e299b8-f7e2-565d-bdf4-87790c30ea4c', 'a180971b-4d3b-5af8-a859-fe46b27a9729', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6dadbd26-397a-554a-991b-6e9f69986194', 'a180971b-4d3b-5af8-a859-fe46b27a9729', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7254ad13-027e-53fb-9971-1c321c969280', 'a180971b-4d3b-5af8-a859-fe46b27a9729', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ae7256a7-333e-540e-a5bd-2ebc6bf842ab', 'a180971b-4d3b-5af8-a859-fe46b27a9729', 5, $md$E$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('59f4d88c-c8d4-584d-8f88-c42ee6ec3aa5', '732d0055-7869-5f27-bf8f-f8b1d0adffff', 5, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 5

Questions 1-5
Questions 1-5
Use the information in the passage to match the people (listed
A-E
) with opinions or deeds below.
Write the appropriate letters
A-E
in boxes
1-5
on your answer sheet.
A
Suess
B
Wallace
C
Darwin and Wallace
D
Wegener
E
Lyell and Hooker
1
urged Darwin to publish his scientific findings
2
Depicted physical feature of earth’s crust.
3
believed in continental drift theory while rejecting another one
4
Published works about wildlife distribution in a different region.
5
Evolution of species is based on selection by nature.

5 ____ Evolution of species is based on selection by nature.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('44df79fd-67a9-5a62-a896-fa8504004ad3', '59f4d88c-c8d4-584d-8f88-c42ee6ec3aa5', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fb4bd4f9-50df-5fdf-908f-33bfab178291', '59f4d88c-c8d4-584d-8f88-c42ee6ec3aa5', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9e1dcef7-ecaa-56ca-88e7-3c62107c8a8c', '59f4d88c-c8d4-584d-8f88-c42ee6ec3aa5', 3, $md$C$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('84efe61b-d3fb-52ab-ae2c-9888fbe7b4b8', '59f4d88c-c8d4-584d-8f88-c42ee6ec3aa5', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fd76b347-5f4f-5efe-9664-48ce2acff4fe', '59f4d88c-c8d4-584d-8f88-c42ee6ec3aa5', 5, $md$E$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('8055c5de-cb66-5c6f-a793-5bcbdfbeb19f', '732d0055-7869-5f27-bf8f-f8b1d0adffff', 6, 'MATCHING_INFORMATION', 'READING', 3, $md$### Question 6

Questions 6-8
Questions 6-8
The Reading Passage has nine paragraphs
A-I
Which paragraph contains the following information?
Write the correct letter
A-I
, in boxes
6-8
on your answer sheet.
6
Best adaptable animal survived on the planet.
7
Boundary called Wallace’s line found between Asia and Australia.
8
Animal relevance exists between Australia and Africa.

6 ____ Best adaptable animal survived on the planet.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('53093516-59ed-5c9c-9f06-28580bf8d0f8', '8055c5de-cb66-5c6f-a793-5bcbdfbeb19f', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('291fd5bb-e90f-5a0a-bd7d-8fc93d76bbf5', '8055c5de-cb66-5c6f-a793-5bcbdfbeb19f', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fe721387-36af-5eb4-8a1b-75db796a1bd8', '8055c5de-cb66-5c6f-a793-5bcbdfbeb19f', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a82b8184-01e7-501b-9d98-d1c5832f7b25', '8055c5de-cb66-5c6f-a793-5bcbdfbeb19f', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8e70a3cf-ed1b-5015-a58f-3aaec9deebf1', '8055c5de-cb66-5c6f-a793-5bcbdfbeb19f', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('69f205c9-39cb-55df-923f-a811f020aa1c', '8055c5de-cb66-5c6f-a793-5bcbdfbeb19f', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9473df14-3f03-559c-b93e-79efed1c6b90', '8055c5de-cb66-5c6f-a793-5bcbdfbeb19f', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1df46a16-1765-51a0-a2b5-00a41bf30c3f', '8055c5de-cb66-5c6f-a793-5bcbdfbeb19f', 8, $md$H$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e6c02109-8d37-58bd-8bf6-2595b65bfc1c', '8055c5de-cb66-5c6f-a793-5bcbdfbeb19f', 9, $md$I$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('1e7ac3fa-6d09-540b-9f6d-7dd7429edfdf', '732d0055-7869-5f27-bf8f-f8b1d0adffff', 7, 'MATCHING_INFORMATION', 'READING', 3, $md$### Question 7

Questions 6-8
Questions 6-8
The Reading Passage has nine paragraphs
A-I
Which paragraph contains the following information?
Write the correct letter
A-I
, in boxes
6-8
on your answer sheet.
6
Best adaptable animal survived on the planet.
7
Boundary called Wallace’s line found between Asia and Australia.
8
Animal relevance exists between Australia and Africa.

7 ____ Boundary called Wallace’s line found between Asia and Australia.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d1cc0e9f-8ccf-51d5-bef9-d84147b055b6', '1e7ac3fa-6d09-540b-9f6d-7dd7429edfdf', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('27e0981e-89b6-59c2-9f43-f5004f399709', '1e7ac3fa-6d09-540b-9f6d-7dd7429edfdf', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('071694d1-90e3-59e7-b518-b044afce93c4', '1e7ac3fa-6d09-540b-9f6d-7dd7429edfdf', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e7550255-d769-52ee-a8e0-1a2ed18a59b6', '1e7ac3fa-6d09-540b-9f6d-7dd7429edfdf', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6426fea7-60ff-5b33-8212-b829bafa58be', '1e7ac3fa-6d09-540b-9f6d-7dd7429edfdf', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3a1a734c-8d43-52e2-b905-239681cd28df', '1e7ac3fa-6d09-540b-9f6d-7dd7429edfdf', 6, $md$F$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d98341dd-02c7-57bb-b62d-8f75f9feafaf', '1e7ac3fa-6d09-540b-9f6d-7dd7429edfdf', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('160491ba-f5e2-5d01-a0b6-b17248930149', '1e7ac3fa-6d09-540b-9f6d-7dd7429edfdf', 8, $md$H$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1954fb74-cdf7-5355-836a-43ae1983eca5', '1e7ac3fa-6d09-540b-9f6d-7dd7429edfdf', 9, $md$I$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('aeca86ef-8a82-54d9-ac47-eb3e7a7db797', '732d0055-7869-5f27-bf8f-f8b1d0adffff', 8, 'MATCHING_INFORMATION', 'READING', 3, $md$### Question 8

Questions 6-8
Questions 6-8
The Reading Passage has nine paragraphs
A-I
Which paragraph contains the following information?
Write the correct letter
A-I
, in boxes
6-8
on your answer sheet.
6
Best adaptable animal survived on the planet.
7
Boundary called Wallace’s line found between Asia and Australia.
8
Animal relevance exists between Australia and Africa.

8 ____ Animal relevance exists between Australia and Africa.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2acfff10-7b07-541a-a8a3-e44a5b206321', 'aeca86ef-8a82-54d9-ac47-eb3e7a7db797', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bdc244d5-f019-59eb-9433-6ab1c886db75', 'aeca86ef-8a82-54d9-ac47-eb3e7a7db797', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('20f91081-4371-5814-a321-89e62126e878', 'aeca86ef-8a82-54d9-ac47-eb3e7a7db797', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1e7fe14b-171f-5ee6-8aee-f8bc72bb6055', 'aeca86ef-8a82-54d9-ac47-eb3e7a7db797', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9e083f1e-bd30-5018-abf7-64af8e8798e0', 'aeca86ef-8a82-54d9-ac47-eb3e7a7db797', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c68f962e-5e3d-5592-b328-7ea9da55a8aa', 'aeca86ef-8a82-54d9-ac47-eb3e7a7db797', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('04d887a3-a446-546a-ad50-6eb33e406d74', 'aeca86ef-8a82-54d9-ac47-eb3e7a7db797', 7, $md$G$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a5c2134c-c064-5a3c-a796-34c1e13d546c', 'aeca86ef-8a82-54d9-ac47-eb3e7a7db797', 8, $md$H$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a50bf1ea-1c9c-57f1-a9ac-aa016b6e8b03', 'aeca86ef-8a82-54d9-ac47-eb3e7a7db797', 9, $md$I$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('d28ee23b-b107-587d-bbd1-928e5a06cc6e', '732d0055-7869-5f27-bf8f-f8b1d0adffff', 9, 'SUMMARY_COMPLETION', 'READING', 3, $md$### Question 9

Questions 9-13
Questions 9-13
Complete the following summary of the paragraphs of Reading Passage.
Using
NO MORE THAN TWO WORDS
from the Reading Passage for each answer.
Write your answers in boxes
9-13
on your answer sheet.
Wegener found that continental drift instead of “land bridge” theory could explain strange species’ distribution phenomenon. In his theory, vegetation and wildlife
9
intercontinentally. However, Eduard Suess compared the wrinkle of crust to
10
of an old apple. Now it is well known that we are living on the planet where there are
11
in constant mobile states instead of what Suess described. Hot spot in biogeography is switched to concerns between two-terms: “
12
” and “
13
”

Wegener found that continental drift instead of “land bridge” theory could explain strange species’ distribution phenomenon. In his theory, vegetation and wildlife 9 ____ intercontinentally. However, Eduard Suess compared the wrinkle of crust to 10 ____ of an old apple. Now it is well known that we are living on the planet where there are 11 ____ in constant mobile states instead of what Suess described. Hot spot in biogeography is switched to concerns between two-terms: “ 12 ____ ” and “ 13 ____ ”$md$, NULL, ARRAY['.*migrated.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('35da213f-bf2a-50fc-85aa-729af2e6cfb8', '732d0055-7869-5f27-bf8f-f8b1d0adffff', 10, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 10

Questions 9-13
Questions 9-13
Complete the following summary of the paragraphs of Reading Passage.
Using
NO MORE THAN TWO WORDS
from the Reading Passage for each answer.
Write your answers in boxes
9-13
on your answer sheet.
Wegener found that continental drift instead of “land bridge” theory could explain strange species’ distribution phenomenon. In his theory, vegetation and wildlife
9
intercontinentally. However, Eduard Suess compared the wrinkle of crust to
10
of an old apple. Now it is well known that we are living on the planet where there are
11
in constant mobile states instead of what Suess described. Hot spot in biogeography is switched to concerns between two-terms: “
12
” and “
13
”

Wegener found that continental drift instead of “land bridge” theory could explain strange species’ distribution phenomenon. In his theory, vegetation and wildlife 9 ____ intercontinentally. However, Eduard Suess compared the wrinkle of crust to 10 ____ of an old apple. Now it is well known that we are living on the planet where there are 11 ____ in constant mobile states instead of what Suess described. Hot spot in biogeography is switched to concerns between two-terms: “ 12 ____ ” and “ 13 ____ ”$md$, NULL, ARRAY['.*migrated.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('7bbb95dc-a49b-558c-8f22-9cf6b6bf718b', '732d0055-7869-5f27-bf8f-f8b1d0adffff', 11, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 11

Questions 9-13
Questions 9-13
Complete the following summary of the paragraphs of Reading Passage.
Using
NO MORE THAN TWO WORDS
from the Reading Passage for each answer.
Write your answers in boxes
9-13
on your answer sheet.
Wegener found that continental drift instead of “land bridge” theory could explain strange species’ distribution phenomenon. In his theory, vegetation and wildlife
9
intercontinentally. However, Eduard Suess compared the wrinkle of crust to
10
of an old apple. Now it is well known that we are living on the planet where there are
11
in constant mobile states instead of what Suess described. Hot spot in biogeography is switched to concerns between two-terms: “
12
” and “
13
”

Wegener found that continental drift instead of “land bridge” theory could explain strange species’ distribution phenomenon. In his theory, vegetation and wildlife 9 ____ intercontinentally. However, Eduard Suess compared the wrinkle of crust to 10 ____ of an old apple. Now it is well known that we are living on the planet where there are 11 ____ in constant mobile states instead of what Suess described. Hot spot in biogeography is switched to concerns between two-terms: “ 12 ____ ” and “ 13 ____ ”$md$, NULL, ARRAY['.*migrated.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('90992aa4-8af7-549e-a0d1-e8f88d8d10cf', '732d0055-7869-5f27-bf8f-f8b1d0adffff', 12, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 12

Questions 9-13
Questions 9-13
Complete the following summary of the paragraphs of Reading Passage.
Using
NO MORE THAN TWO WORDS
from the Reading Passage for each answer.
Write your answers in boxes
9-13
on your answer sheet.
Wegener found that continental drift instead of “land bridge” theory could explain strange species’ distribution phenomenon. In his theory, vegetation and wildlife
9
intercontinentally. However, Eduard Suess compared the wrinkle of crust to
10
of an old apple. Now it is well known that we are living on the planet where there are
11
in constant mobile states instead of what Suess described. Hot spot in biogeography is switched to concerns between two-terms: “
12
” and “
13
”

Wegener found that continental drift instead of “land bridge” theory could explain strange species’ distribution phenomenon. In his theory, vegetation and wildlife 9 ____ intercontinentally. However, Eduard Suess compared the wrinkle of crust to 10 ____ of an old apple. Now it is well known that we are living on the planet where there are 11 ____ in constant mobile states instead of what Suess described. Hot spot in biogeography is switched to concerns between two-terms: “ 12 ____ ” and “ 13 ____ ”$md$, NULL, ARRAY['.*migrated.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('fdc1e45f-e099-56e1-92ba-9e4233ccdd9c', '732d0055-7869-5f27-bf8f-f8b1d0adffff', 13, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 13

Questions 9-13
Questions 9-13
Complete the following summary of the paragraphs of Reading Passage.
Using
NO MORE THAN TWO WORDS
from the Reading Passage for each answer.
Write your answers in boxes
9-13
on your answer sheet.
Wegener found that continental drift instead of “land bridge” theory could explain strange species’ distribution phenomenon. In his theory, vegetation and wildlife
9
intercontinentally. However, Eduard Suess compared the wrinkle of crust to
10
of an old apple. Now it is well known that we are living on the planet where there are
11
in constant mobile states instead of what Suess described. Hot spot in biogeography is switched to concerns between two-terms: “
12
” and “
13
”

Wegener found that continental drift instead of “land bridge” theory could explain strange species’ distribution phenomenon. In his theory, vegetation and wildlife 9 ____ intercontinentally. However, Eduard Suess compared the wrinkle of crust to 10 ____ of an old apple. Now it is well known that we are living on the planet where there are 11 ____ in constant mobile states instead of what Suess described. Hot spot in biogeography is switched to concerns between two-terms: “ 12 ____ ” and “ 13 ____ ”$md$, NULL, ARRAY['.*migrated.*']);

COMMIT;
