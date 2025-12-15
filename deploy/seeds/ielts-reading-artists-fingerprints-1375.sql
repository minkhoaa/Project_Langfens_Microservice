BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-artists-fingerprints-1375'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-artists-fingerprints-1375';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-artists-fingerprints-1375';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-artists-fingerprints-1375';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('f1d779ca-c025-5f48-8ade-7640c451df8d', 'ielts-reading-artists-fingerprints-1375', $t$Artists’ Fingerprints$t$, $md$## Artists’ Fingerprints

Nguồn:
- Test: https://mini-ielts.com/1375/reading/artists-fingerprints
- Solution: https://mini-ielts.com/1375/view-solution/reading/artists-fingerprints$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('955cdd2f-488d-5b09-b776-0fb5b35ef041', 'f1d779ca-c025-5f48-8ade-7640c451df8d', 1, $t$Reading — Artists’ Fingerprints$t$, $md$Read the passage and answer questions **1–12**.

### Passage: Artists’ Fingerprints

Works of art often bear the fingerprints of the artist who created them. Such crucial evidence usually goes unnoticed even by connoisseurs, art experts, and conservators. If present, such evidence could be valuable in clarifying questions about authorship and dating.

{A} The unique character of ridges on our hands has been recognized for thousands of years. The study of ancient pottery for example reveals the utilization of fingerprint impressions in the clay as a maker’s mark. In prehistoric times, we find examples of handprints in cave paintings. Only as recently as 1858 did Sir William Herschel establish its use for identification. In 1888, Sir Francis Galton undertook to refine and formulate Herschel’s observations. Identification by fingerprint was first adopted in England in 1905 and received general acceptance worldwide in 1908.

{B} The combination of a number of characteristics in a given finger impression is specific to a particular print. The placing of reliance on fingerprint evidence has always been on the assumption that no two fingers can have identical ridge characteristics. Galton’s mathematical conclusions predicted the possible existence of some 64 billion different fingerprint patterns. The functionality of this technique is that the probability for the existence of two identical finger impressions from different individuals is nil and no such possibility has ever been noticed in any part of the world at any time.

{C} The individuality of a fingerprint is not determined by its general shape or pattern but by the careful study of its ridge characteristics. Since at a scene of the crime, usually only partial prints are found, comparison of a relatively small number of characteristics is accepted in legal practice. In a judicial proceeding, a point-by-point comparison must be demonstrated by the fingerprint expert. This is exactly the principle that must be followed in art-related fingerprint issues.

{D} Artists in the area of the visual arts use their hands for creation. Their tools, such as brushes often isolate them from the surface they are working on. Inaccurate deposits of paint are often corrected by modelling with the fingertip. Some artists used the fingertip to soften the marks left by the brush by gently tapping or stroking the still wet surface. In some instances, the fingertip was used for literally ‘stamping’ the fine network of ridges onto the painting.

{E} The eventual authentication of a painting by J. M. W. Turner entitled Landscape with Rainbow in 1993 is a good illustration of the process. The painting was discovered in the early 1980s. Biros took the painting to the Tate Gallery, in London, to show it to the world’s leading Turner experts and connoisseurs. The verdict was unanimous – the painting was a tattered imitation. However, fingerprint evidence was discovered on the painting during restoration, appropriately documented, and re-examined by a veteran expert from the RCMP. A match was found between a fingerprint on “Landscape with Rainbow and fingerprints photographed on another Turner painting, ‘Chichester Canal’. When an independent fingerprint examination by John Manners of the West Yorkshire Police confirmed the conclusions that the fingerprints on both paintings were identical, the unbelievers changed their minds. In addition, it is well known that Turner always worked alone and had no assistants. This reduces the chances of accidental contribution substantially. The painting, originally bought for a few hundred dollars, finally sold for close to $200,000 at auction at Phillips in London in 1995.

{F} In 1998, three envelopes containing old correspondence had been purchased in an antique shop. One of the envelopes postmarked April 2, 1915, was found to contain a drawing folded in half. The drawing depicts a woman’s head. It is executed in red chalk with an inscription written in reverse with brown ink. The design is faded and worn. Some spots suggest foxing and subsequent discolouration. The paper is yellowed and contaminated.

{G} The newly discovered design bears great similarity to that of the Head of St Anne by Leonardo da Vinci, (RL 12533) in the Windsor Collection since 1629. The medium is different, red chalk being used instead of black. The scale of the two images is different so offsetting (copying by contact transference) is not a satisfactory explanation for the new drawing. When the paper was first examined, several fingerprints were noticed on the verso. One of them was found clear and containing many ridges suitable for comparison, however, no analysis was done at the time due to the lack of reference material. Many of Leonardo’s works are not easily accessible and fingerprint data either does not exist or is not published.

{H} By chance, on March 30, 1999, several clear and usable fingerprints were found on an unusually good detail photo in a publication on Leonardo. The photograph of Leonardo’s St Jerome, in the Vatican Museum, revealed no less than 16 partial fingertip marks. The importance of this is that the fingerprints are left in the still-wet paint and without doubt, the use of the fingertip served to model paint. Since the authorship of the painting of St Jerome is unquestioned by scholarship and has always been ascribed to Leonardo, the conclusion that these fingerprints are his would be hard to argue against.

{I} The fingerprints on the St Jerome illustration were scanned and enlarged so comparisons could be made with the fingerprint on the newly discovered drawing. One of them proved to match. The result of our analyses was presented on March 31, 1999, to fingerprint examiner Staff Sergeant André Turcotte for an independent assessment. He agreed with the findings and confirmed the conclusion. The fingerprint on the St Jerome painting in the Vatican and the newly discovered drawing were created by the same finger.

{J] Remember, the authentication approach should rest on strict considerations and rigorous methodology. Only prints that are clearly from the original creative process are admitted for consideration. The reference samples should ideally come from unquestioned works of art with good provenance. Spurious contributors must be eliminated such as assistants who may have touched the painting while still wet. A match is never made unless corroborated by at least one fully trained and experienced fingerprint examiner.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('40aba4ee-d380-5a34-8ea9-826493697598', '955cdd2f-488d-5b09-b776-0fb5b35ef041', 1, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 1

Questions 1-4
Questions 1-4
The reading Passage has ten paragraphs A-J.
Which paragraph contains the following information?
Write the correct letter A-J, in boxes 1-4 on your answer sheet.
1
Mention of fingerprint identification in the legal process.
2
The author’s advice on fingerprint authentication of arts.
3
The use of fingerprints in ancient times.
4
The medium comparison between two drawings.

1 ____ Mention of fingerprint identification in the legal process.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f286f951-1751-5f0d-ac3f-3ed96c25b869', '40aba4ee-d380-5a34-8ea9-826493697598', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8db2ba91-baf2-5e39-ad79-9e6676537134', '40aba4ee-d380-5a34-8ea9-826493697598', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6c24b53f-9828-5ea1-95e1-55bdee26c152', '40aba4ee-d380-5a34-8ea9-826493697598', 3, $md$C$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0dc923b9-7d05-52bf-91b8-160e7b832bb8', '40aba4ee-d380-5a34-8ea9-826493697598', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('144e622d-9b12-5c4a-853f-3aa3171093cb', '40aba4ee-d380-5a34-8ea9-826493697598', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fe7b3bf1-7883-54b4-bd31-fa0351b4c325', '40aba4ee-d380-5a34-8ea9-826493697598', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e8d10d58-0d9b-539e-8519-6b886b9d1c8f', '40aba4ee-d380-5a34-8ea9-826493697598', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('afb25d8c-4c32-59f0-b4ee-1f0676a03ccf', '40aba4ee-d380-5a34-8ea9-826493697598', 8, $md$H$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bc50e837-7c49-5948-9296-4517e566c705', '40aba4ee-d380-5a34-8ea9-826493697598', 9, $md$I$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('57d98dbc-f9e9-59d2-b69c-6b90660ce6e3', '40aba4ee-d380-5a34-8ea9-826493697598', 10, $md$J$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('5bde69fb-4dcd-5e56-b904-c0fba394d3bf', '955cdd2f-488d-5b09-b776-0fb5b35ef041', 2, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 2

Questions 1-4
Questions 1-4
The reading Passage has ten paragraphs A-J.
Which paragraph contains the following information?
Write the correct letter A-J, in boxes 1-4 on your answer sheet.
1
Mention of fingerprint identification in the legal process.
2
The author’s advice on fingerprint authentication of arts.
3
The use of fingerprints in ancient times.
4
The medium comparison between two drawings.

2 ____ The author’s advice on fingerprint authentication of arts.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9beddbb0-4c58-5698-8756-8b587e9bd91a', '5bde69fb-4dcd-5e56-b904-c0fba394d3bf', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fa0fe238-5899-596e-97d5-ea3443989b12', '5bde69fb-4dcd-5e56-b904-c0fba394d3bf', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('53545b16-6caf-532a-ba2c-b5b6ad16d18a', '5bde69fb-4dcd-5e56-b904-c0fba394d3bf', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9c049934-6e4f-5d77-b70b-4ec36b1afe38', '5bde69fb-4dcd-5e56-b904-c0fba394d3bf', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f2cfb118-3591-5c86-bea2-fb1febf4da3c', '5bde69fb-4dcd-5e56-b904-c0fba394d3bf', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('86f23162-8255-5d16-b037-aa986bcc227a', '5bde69fb-4dcd-5e56-b904-c0fba394d3bf', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7763b363-3313-502d-b28d-7a00dd0ff905', '5bde69fb-4dcd-5e56-b904-c0fba394d3bf', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4b785838-f3c7-55f6-a879-855991fd72cd', '5bde69fb-4dcd-5e56-b904-c0fba394d3bf', 8, $md$H$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ea468c03-5ddd-5ff8-9a2e-8f06f8072fa7', '5bde69fb-4dcd-5e56-b904-c0fba394d3bf', 9, $md$I$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('06ce363e-a914-5768-82d3-2f5d50b329eb', '5bde69fb-4dcd-5e56-b904-c0fba394d3bf', 10, $md$J$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('bf95401f-2385-5d5f-8b41-bc1853f10ef1', '955cdd2f-488d-5b09-b776-0fb5b35ef041', 3, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 3

Questions 1-4
Questions 1-4
The reading Passage has ten paragraphs A-J.
Which paragraph contains the following information?
Write the correct letter A-J, in boxes 1-4 on your answer sheet.
1
Mention of fingerprint identification in the legal process.
2
The author’s advice on fingerprint authentication of arts.
3
The use of fingerprints in ancient times.
4
The medium comparison between two drawings.

3 ____ The use of fingerprints in ancient times.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3508bb38-4a1b-58cb-be13-e60f2e7fdcaf', 'bf95401f-2385-5d5f-8b41-bc1853f10ef1', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b61b6b29-25af-5c87-900e-7a9a2ada2bd8', 'bf95401f-2385-5d5f-8b41-bc1853f10ef1', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('78378027-897a-5879-b669-fdb455a7fa32', 'bf95401f-2385-5d5f-8b41-bc1853f10ef1', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('82857b26-21de-547d-8cd3-979fc81db61d', 'bf95401f-2385-5d5f-8b41-bc1853f10ef1', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('85dca878-1831-52f1-ae96-302804c8738a', 'bf95401f-2385-5d5f-8b41-bc1853f10ef1', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d29ac364-821c-533e-9e75-d31010106a99', 'bf95401f-2385-5d5f-8b41-bc1853f10ef1', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1139e8f2-adeb-5fbf-b434-bcc5925d7902', 'bf95401f-2385-5d5f-8b41-bc1853f10ef1', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cb924255-5038-5c29-ab6c-26c46a485163', 'bf95401f-2385-5d5f-8b41-bc1853f10ef1', 8, $md$H$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('51558318-9c27-5079-8497-bb72ca2e5992', 'bf95401f-2385-5d5f-8b41-bc1853f10ef1', 9, $md$I$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a0b5818b-69b3-519f-ac2f-3e027b990b37', 'bf95401f-2385-5d5f-8b41-bc1853f10ef1', 10, $md$J$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('faba4a3a-90a3-5780-917f-04a3926bc718', '955cdd2f-488d-5b09-b776-0fb5b35ef041', 4, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 4

Questions 1-4
Questions 1-4
The reading Passage has ten paragraphs A-J.
Which paragraph contains the following information?
Write the correct letter A-J, in boxes 1-4 on your answer sheet.
1
Mention of fingerprint identification in the legal process.
2
The author’s advice on fingerprint authentication of arts.
3
The use of fingerprints in ancient times.
4
The medium comparison between two drawings.

4 ____ The medium comparison between two drawings.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e3b5262b-5028-5f18-a9ad-d3e54362f070', 'faba4a3a-90a3-5780-917f-04a3926bc718', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0db00043-8947-5725-ab71-b9b93a7c36bd', 'faba4a3a-90a3-5780-917f-04a3926bc718', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b783222f-3d9b-5f85-b759-c5ab82681931', 'faba4a3a-90a3-5780-917f-04a3926bc718', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('94430296-b0b4-5e53-bd43-ec586736f628', 'faba4a3a-90a3-5780-917f-04a3926bc718', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c7d00574-974d-5d8f-abdb-72c9006f806d', 'faba4a3a-90a3-5780-917f-04a3926bc718', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1f135d94-691c-5347-bc8a-42f1f95dc0fd', 'faba4a3a-90a3-5780-917f-04a3926bc718', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7747c930-f7c1-5be5-a0e7-458a81b45228', 'faba4a3a-90a3-5780-917f-04a3926bc718', 7, $md$G$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6bde7dfc-2c8a-5840-8055-3565fef69dc9', 'faba4a3a-90a3-5780-917f-04a3926bc718', 8, $md$H$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('aa23cf21-c7cc-5f2c-b860-c7152cac0a8c', 'faba4a3a-90a3-5780-917f-04a3926bc718', 9, $md$I$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c28e2703-4298-562e-a7a0-d50a21af44e8', 'faba4a3a-90a3-5780-917f-04a3926bc718', 10, $md$J$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('9cf2cb4f-4ad7-50f4-90cb-563b24f2453e', '955cdd2f-488d-5b09-b776-0fb5b35ef041', 5, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 5

Questions 5-9
Questions 5-9
Complete each sentence with the correct ending A-I below.
Write the correct letters in boxes 5-9 on your answer sheet.
5
The fingerprint in ancient pottery
6
The science of fingerprint identification
7
The authentication of a painting without a signature
8
Landscape with Rainbow
9
When painting, artists
(A)
might use fingers to remove unwanted paint left by brushes.
(B)
revealed the utilization of clay.
(C)
was first used on Galton’s mathematical assumption.
(D)
was left to identify the person who made it.
(E)
was restored at a high expense.
(F)
was finally determined at an appropriate price.
(G)
has been accepted as a reliable system available.
(H)
was preserved at the Windsor Collection.
(I)
could be authenticated by comparing fingerprints from other sources.

5 ____ The fingerprint in ancient pottery$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('43c7df1d-32e8-5def-97e4-ccaaeb0d3b02', '9cf2cb4f-4ad7-50f4-90cb-563b24f2453e', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9eb5b07f-5b9b-5ae4-86bb-e3eef48d32cc', '9cf2cb4f-4ad7-50f4-90cb-563b24f2453e', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2a65d82e-eceb-5075-91c5-983c7821f22d', '9cf2cb4f-4ad7-50f4-90cb-563b24f2453e', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b266d26b-6b50-5dc4-b9c1-08569479381e', '9cf2cb4f-4ad7-50f4-90cb-563b24f2453e', 4, $md$D$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('93818cfe-7f5c-5cd2-8261-20d6191b31dc', '9cf2cb4f-4ad7-50f4-90cb-563b24f2453e', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ea745ad8-d28e-5a64-9dab-e46f6782f00e', '9cf2cb4f-4ad7-50f4-90cb-563b24f2453e', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c1daa5d5-63bf-53ae-b2c9-4cf81ef7c15d', '9cf2cb4f-4ad7-50f4-90cb-563b24f2453e', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fdc02ad1-ee20-5de9-828c-2283c4381051', '9cf2cb4f-4ad7-50f4-90cb-563b24f2453e', 8, $md$H$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('da3f7bbe-ef38-5366-9bdc-e2ad196e9d91', '9cf2cb4f-4ad7-50f4-90cb-563b24f2453e', 9, $md$I$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('734ab60b-0c05-5bae-acf8-45facef40c2f', '955cdd2f-488d-5b09-b776-0fb5b35ef041', 6, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 6

Questions 5-9
Questions 5-9
Complete each sentence with the correct ending A-I below.
Write the correct letters in boxes 5-9 on your answer sheet.
5
The fingerprint in ancient pottery
6
The science of fingerprint identification
7
The authentication of a painting without a signature
8
Landscape with Rainbow
9
When painting, artists
(A)
might use fingers to remove unwanted paint left by brushes.
(B)
revealed the utilization of clay.
(C)
was first used on Galton’s mathematical assumption.
(D)
was left to identify the person who made it.
(E)
was restored at a high expense.
(F)
was finally determined at an appropriate price.
(G)
has been accepted as a reliable system available.
(H)
was preserved at the Windsor Collection.
(I)
could be authenticated by comparing fingerprints from other sources.

6 ____ The science of fingerprint identification$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8c2ddf1a-aaa2-5d0b-90dd-911542fbead3', '734ab60b-0c05-5bae-acf8-45facef40c2f', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f541df08-6e2e-542b-82e8-2d1074f5e410', '734ab60b-0c05-5bae-acf8-45facef40c2f', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('aa53a72e-7002-599e-a62b-37aa6aa8da45', '734ab60b-0c05-5bae-acf8-45facef40c2f', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('436e7727-91b3-5ed8-8543-a9af68d3f764', '734ab60b-0c05-5bae-acf8-45facef40c2f', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0ba36533-c6d1-58a2-90a1-cb9dc1c23e1d', '734ab60b-0c05-5bae-acf8-45facef40c2f', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('69be4a79-57d0-5d59-9fa6-693787efe4d5', '734ab60b-0c05-5bae-acf8-45facef40c2f', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('75438e00-59c0-5ecd-b581-04dddaeb1ea6', '734ab60b-0c05-5bae-acf8-45facef40c2f', 7, $md$G$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bf8d3498-a8fd-5627-993c-7ca3c9202010', '734ab60b-0c05-5bae-acf8-45facef40c2f', 8, $md$H$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('71bb8c54-f66f-5c37-998e-30a2a5e9c094', '734ab60b-0c05-5bae-acf8-45facef40c2f', 9, $md$I$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('e470374b-918e-5701-aee7-566fdc9eaa1f', '955cdd2f-488d-5b09-b776-0fb5b35ef041', 7, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 7

Questions 5-9
Questions 5-9
Complete each sentence with the correct ending A-I below.
Write the correct letters in boxes 5-9 on your answer sheet.
5
The fingerprint in ancient pottery
6
The science of fingerprint identification
7
The authentication of a painting without a signature
8
Landscape with Rainbow
9
When painting, artists
(A)
might use fingers to remove unwanted paint left by brushes.
(B)
revealed the utilization of clay.
(C)
was first used on Galton’s mathematical assumption.
(D)
was left to identify the person who made it.
(E)
was restored at a high expense.
(F)
was finally determined at an appropriate price.
(G)
has been accepted as a reliable system available.
(H)
was preserved at the Windsor Collection.
(I)
could be authenticated by comparing fingerprints from other sources.

7 ____ The authentication of a painting without a signature$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9db16b1d-4fca-5ab9-9ae2-ecbae13ace4e', 'e470374b-918e-5701-aee7-566fdc9eaa1f', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a087cf8a-a758-52e5-be18-1a14d2a3ba6b', 'e470374b-918e-5701-aee7-566fdc9eaa1f', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0582b97a-8166-5417-93c1-daba13f5e4ff', 'e470374b-918e-5701-aee7-566fdc9eaa1f', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('68c5156c-e27a-57ed-b130-ec6f85d0a838', 'e470374b-918e-5701-aee7-566fdc9eaa1f', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8d337735-859e-5ac5-9e46-4b0c3a6a4803', 'e470374b-918e-5701-aee7-566fdc9eaa1f', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b0da8a6b-da20-5c16-b6cc-9f75b1194e89', 'e470374b-918e-5701-aee7-566fdc9eaa1f', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5b8004da-1de6-5dc7-8980-43bee6698eb6', 'e470374b-918e-5701-aee7-566fdc9eaa1f', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e5c53374-3d4b-5099-b9f1-b22d6c14ca72', 'e470374b-918e-5701-aee7-566fdc9eaa1f', 8, $md$H$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f7f64519-0bd3-5ae4-8a8f-17b620ffc798', 'e470374b-918e-5701-aee7-566fdc9eaa1f', 9, $md$I$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('48fa2806-16ac-5f5f-9659-0b0f2094bd22', '955cdd2f-488d-5b09-b776-0fb5b35ef041', 8, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 8

Questions 5-9
Questions 5-9
Complete each sentence with the correct ending A-I below.
Write the correct letters in boxes 5-9 on your answer sheet.
5
The fingerprint in ancient pottery
6
The science of fingerprint identification
7
The authentication of a painting without a signature
8
Landscape with Rainbow
9
When painting, artists
(A)
might use fingers to remove unwanted paint left by brushes.
(B)
revealed the utilization of clay.
(C)
was first used on Galton’s mathematical assumption.
(D)
was left to identify the person who made it.
(E)
was restored at a high expense.
(F)
was finally determined at an appropriate price.
(G)
has been accepted as a reliable system available.
(H)
was preserved at the Windsor Collection.
(I)
could be authenticated by comparing fingerprints from other sources.

8 ____ Landscape with Rainbow$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('88ee6eac-486d-5e35-aae9-d28f8a969dd2', '48fa2806-16ac-5f5f-9659-0b0f2094bd22', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('194655cf-da9d-5486-807c-fbc44105fb73', '48fa2806-16ac-5f5f-9659-0b0f2094bd22', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3e3870d2-fe9a-5ad9-9cb6-614a10fe1082', '48fa2806-16ac-5f5f-9659-0b0f2094bd22', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d329cd19-5033-5196-927b-e224d6c739c6', '48fa2806-16ac-5f5f-9659-0b0f2094bd22', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c4180ad0-ed5c-5eda-b82b-3c30b15496a7', '48fa2806-16ac-5f5f-9659-0b0f2094bd22', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('570958ad-bbda-5f11-b3ed-1a29ecb42e10', '48fa2806-16ac-5f5f-9659-0b0f2094bd22', 6, $md$F$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('03c616cb-7013-55e0-a372-c39a33c595ee', '48fa2806-16ac-5f5f-9659-0b0f2094bd22', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ba0c2493-af22-51ad-809f-cf9b57e5dd4e', '48fa2806-16ac-5f5f-9659-0b0f2094bd22', 8, $md$H$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6de577f4-64af-503d-86da-57e146d7034e', '48fa2806-16ac-5f5f-9659-0b0f2094bd22', 9, $md$I$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('667ecf58-319c-569e-8030-3a3dd74798fd', '955cdd2f-488d-5b09-b776-0fb5b35ef041', 9, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 9

Questions 5-9
Questions 5-9
Complete each sentence with the correct ending A-I below.
Write the correct letters in boxes 5-9 on your answer sheet.
5
The fingerprint in ancient pottery
6
The science of fingerprint identification
7
The authentication of a painting without a signature
8
Landscape with Rainbow
9
When painting, artists
(A)
might use fingers to remove unwanted paint left by brushes.
(B)
revealed the utilization of clay.
(C)
was first used on Galton’s mathematical assumption.
(D)
was left to identify the person who made it.
(E)
was restored at a high expense.
(F)
was finally determined at an appropriate price.
(G)
has been accepted as a reliable system available.
(H)
was preserved at the Windsor Collection.
(I)
could be authenticated by comparing fingerprints from other sources.

9 ____ When painting, artists$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('edee77c1-8bf3-589d-bc17-5994056efb08', '667ecf58-319c-569e-8030-3a3dd74798fd', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e3901b4e-afa9-5d1d-b985-3638a51c4ae4', '667ecf58-319c-569e-8030-3a3dd74798fd', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('42e8c218-db83-5b97-a457-9c64b1f70541', '667ecf58-319c-569e-8030-3a3dd74798fd', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d0c3efe5-8954-5da7-aa7f-7e4c03442eb9', '667ecf58-319c-569e-8030-3a3dd74798fd', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7a762f3b-2946-5e55-aa51-740919862938', '667ecf58-319c-569e-8030-3a3dd74798fd', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('945c9b00-3ff6-5edf-b16c-ee1abc50c607', '667ecf58-319c-569e-8030-3a3dd74798fd', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('96116e00-6bcb-5407-bb7f-6f0070de744d', '667ecf58-319c-569e-8030-3a3dd74798fd', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0d9b1a6e-3140-5f5a-99d0-8c7f8467ed90', '667ecf58-319c-569e-8030-3a3dd74798fd', 8, $md$H$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9104e442-b9c3-58b9-8760-9093a7981fd0', '667ecf58-319c-569e-8030-3a3dd74798fd', 9, $md$I$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('43629ec6-a0a5-5f03-b837-9c139a450ced', '955cdd2f-488d-5b09-b776-0fb5b35ef041', 10, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 10

Questions 10-12
Questions 10-12
Choose the correct letter, A, B, C, or D.
Write your answers in boxes 10-12 on your answer sheet
.
Question 10:
The attribution of Landscape with Rainbow to Turner
A
was in overwhelming consensus at the beginning.
B
was first brought forward by the West Yorkshire Police.
C
was rejected by the Biros.
D
was not exactly located for years.
Question 11:-
The drawing of a woman’s head contained in the envelope
A
was finished in 1915.
B
was executed in brown ink.
C
was in poor condition.
D
was folded for protection.
Question 12:-
The drawing of The Head of St Anne
A
is the work of Leonardo da Vinci
B
is softer due to fading and contamination.
C
bears some fingerprints on the verso.
D
is in the Vatican Museum.

Choose the correct letter, A, B, C, or D.$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('9b6f8e40-3552-52a3-8646-a059949443a7', '955cdd2f-488d-5b09-b776-0fb5b35ef041', 11, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 11

Questions 10-12
Questions 10-12
Choose the correct letter, A, B, C, or D.
Write your answers in boxes 10-12 on your answer sheet
.
Question 10:
The attribution of Landscape with Rainbow to Turner
A
was in overwhelming consensus at the beginning.
B
was first brought forward by the West Yorkshire Police.
C
was rejected by the Biros.
D
was not exactly located for years.
Question 11:-
The drawing of a woman’s head contained in the envelope
A
was finished in 1915.
B
was executed in brown ink.
C
was in poor condition.
D
was folded for protection.
Question 12:-
The drawing of The Head of St Anne
A
is the work of Leonardo da Vinci
B
is softer due to fading and contamination.
C
bears some fingerprints on the verso.
D
is in the Vatican Museum.

Choose the correct letter, A, B, C, or D.$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('3ba0c162-176b-554f-bbd7-a46ede8b2edd', '955cdd2f-488d-5b09-b776-0fb5b35ef041', 12, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 12

Questions 10-12
Questions 10-12
Choose the correct letter, A, B, C, or D.
Write your answers in boxes 10-12 on your answer sheet
.
Question 10:
The attribution of Landscape with Rainbow to Turner
A
was in overwhelming consensus at the beginning.
B
was first brought forward by the West Yorkshire Police.
C
was rejected by the Biros.
D
was not exactly located for years.
Question 11:-
The drawing of a woman’s head contained in the envelope
A
was finished in 1915.
B
was executed in brown ink.
C
was in poor condition.
D
was folded for protection.
Question 12:-
The drawing of The Head of St Anne
A
is the work of Leonardo da Vinci
B
is softer due to fading and contamination.
C
bears some fingerprints on the verso.
D
is in the Vatican Museum.

Choose the correct letter, A, B, C, or D.$md$, NULL);

COMMIT;
