BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-the-iceman--1459'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-the-iceman--1459';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-the-iceman--1459';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-the-iceman--1459';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('288f109c-b24d-5514-982b-4d9681640220', 'ielts-reading-the-iceman--1459', $t$The iceman$t$, $md$## The iceman

Nguồn:
- Test: https://mini-ielts.com/1459/reading/the-iceman-
- Solution: https://mini-ielts.com/1459/view-solution/reading/the-iceman-$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('6bd84456-c2fb-5c71-8614-82d2f79e143f', '288f109c-b24d-5514-982b-4d9681640220', 1, $t$Reading — The iceman$t$, $md$Read the passage and answer questions **1–13**.

### Passage: The iceman

| | The iceman It was late spring or early summer. The man hurried through a forest he knew well, wincing from the pain in his injured right hand and pausing occasionally to listen for sounds that he was being pursued. As he fled up the slope, the yellow pollen of the hornbeam blossoms fell like an invisible rain, salting the water and food he consumed when he stopped to rest. Five thousand years later, the Neolithic hunter we call the Iceman would still bear traces of this ancient dusting inside his body-a microscopic record of the time of year it was when he passed through this forest and into the nearby mountains, where fate would finally catch up with him. Since hikers discovered his mummified corpse in 1991 in a rocky hollow high in the Otztal Alps on Italy's border with Austria, scientists have used ever more sophisticated tools and intellectual cunning to reconstruct the life and times of the Iceman, the oldest intact member of the human family. We know that he was a small, sinewy, and, for his times, rather elderly man in his mid-40s. Judging from the precious, copper-bladed ax found with him, we suspect that he was a person of considerable social significance. He set off on his journey wearing three layers of garments and sturdy shoes with bearskin soles. He was well equipped with a flint- tipped dagger, a little fire-starting kit, and a birchbark container holding embers wrapped in maple leaves. Yet he also headed into a harsh wilderness curiously under-armed: The arrows in his deerskin quiver were only half finished, as if he had recently fired all his munitions and was in the process of hastily replenishing them. And he was traveling with a long, roughly shaped stalk of yew-an unfinished longbow, yet to be notched and strung. Why? When it comes to the Iceman, there has never been a shortage of questions, or theories to answer them. During the 16 years that scientists have poked, prodded, incised, and x-rayed his body, they have dressed him up in speculations that have not worn nearly as well as his rustic garments. At one time or another, he has been mistakenly described as a lost shepherd, a shaman, a victim of ritual sacrifice, and even a vegan. But all these theories fade in the face of the most startling new fact scientists have learned about the Iceman. Although we still don't know exactly what happened up there on that alpine ridge, we now know that he was murdered, and died very quickly, in the rocky hollow where his body was found. "Even five years ago, the story was that he fled up there and walked around in the snow and probably died of exposure," said Klaus Oeggl, an archaeobotanist at the University of Innsbruck. "Now it's all changed. It's more like a paleo crime scene." The object of all this intense scientific attention is a freeze-dried slab of human jerky, which since 1998 has resided in a refrigerated, high-tech chamber in the South Tyrol Museum of Archaeology in Bolzano, Italy. The temptation to conduct fresh experiments on the body rises with every new twist of technology, each revealing uncannily precise details about his life. Using a sophisticated analysis of isotopes in one of the Iceman's teeth, for example, scientists led by Wolfgang Muller (now at the Royal Holloway, University of London) have shown that he probably grew up in the Valle Isarco, an extensive north-south valley that includes the modern- day town of Bressanone. Isotope levels in his bones, meanwhile, match those in the soil and water of two alpine valleys farther west, the Vai Senales and the Vai Venosta. Muller's team has also analyzed microscopic chips of mica recovered from the Iceman's intestines, which were probably ingested accidentally in food made from stone-ground grain; geologic ages of the mica best match a small area limited to the lower Vai Venosta. The Iceman probably set off on his final journey from this very area, near where the modern-day Adige and Senales Rivers meet. We also know that he was not in good health when he headed up into the mountains. The one surviving fingernail recovered from his remains suggests that he suffered three episodes of significant disease during the last six months of life, the last bout only two months prior to his death. Doctors inspecting the contents of his intestines have found eggs of the whipworm parasite, so he may well have suffered from stomach distress. But he was not too sick to eat. In 2002, Franco Rollo and colleagues at the University of Camerino in Italy analyzed tiny amounts of food residue from the mummy's intestines. A day or two before his death, the Iceman had eaten a piece of wild goat and some plant food. Archaeobotanists have used equally clever analyses of pollen and plant fragments to plot the Iceman's last movements. James Dickson of the University of Glasgow has identified no less than 80 distinct species of mosses and liverworts in, on, or near the Iceman's body. The most prominent moss, Neckera complanata, still grows at several sites in the valleys to the south, in some cases quite near known prehistoric sites. According to Dickson, a clot of stems found in the Iceman's possession suggests he was probably using the moss to wrap food, although other ancient peoples used similar mosses as toilet paper. Taken together, the evidence strongly indicates that the Iceman’s last journey began in the low-altitude deciduous forests to the south, in the springtime when the hop hornbeams were in bloom. But it may not have been a straight hike into the mountains. Oeggl has also found traces of pine pollen in the Iceman's digestive tract, both above and below the hornbeam pollen. This suggests that he may have climbed to a higher altitude where pine trees grow in mixed coniferous forests, then descended to the lower altitude of the hop hornbeams, and finally ascended again into the pine forests in his last day or two. Why? No one knows. But perhaps he wanted to avoid the steep, thickly wooded gorge of the lower Vai Senales-especially if he was in a hurry.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('55f8f027-0760-5c05-9ff4-5f3f6250c25c', '6bd84456-c2fb-5c71-8614-82d2f79e143f', 1, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 1

Questions 1-5
Questions 1-5
The reading passage has eight paragraphs A-H . Which paragraph contains the following information?
Write the correct letter A-H, in boxes 1-5 on your answer sheet.
NB you may use any letter more than once
1
the last area in which the iceman might live and stay.
2
a mass of special plant was discovered and used to analyze the iceman's movements.
3
a scientist analyzes the iceman's last hike depending on pollen.
4
the time and area the iceman was found.
5
the iceman's body had been out of condition for months before his death.

1 ____ the last area in which the iceman might live and stay.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1ef9e6a8-f3c6-513f-b18a-b537ae8fb148', '55f8f027-0760-5c05-9ff4-5f3f6250c25c', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5583768a-1e39-5f1c-bf8c-dd007714425c', '55f8f027-0760-5c05-9ff4-5f3f6250c25c', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2cf499a5-a719-5e7b-b0f7-1ba91ccfc242', '55f8f027-0760-5c05-9ff4-5f3f6250c25c', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('735c53f3-6cd9-5a59-8a18-5acfb2d2df8f', '55f8f027-0760-5c05-9ff4-5f3f6250c25c', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('275327af-aa79-5b9d-adec-1c96ef1720e4', '55f8f027-0760-5c05-9ff4-5f3f6250c25c', 5, $md$E$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0013764e-1272-5a01-87e2-d9a624ac60fc', '55f8f027-0760-5c05-9ff4-5f3f6250c25c', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('87243182-cccd-5f36-b843-658b24c6bf1b', '55f8f027-0760-5c05-9ff4-5f3f6250c25c', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('71d76225-60a0-54f5-be22-dfa38834c93d', '55f8f027-0760-5c05-9ff4-5f3f6250c25c', 8, $md$H$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('3499cd13-2aab-5d66-b902-077c79b1a8ee', '6bd84456-c2fb-5c71-8614-82d2f79e143f', 2, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 2

Questions 1-5
Questions 1-5
The reading passage has eight paragraphs A-H . Which paragraph contains the following information?
Write the correct letter A-H, in boxes 1-5 on your answer sheet.
NB you may use any letter more than once
1
the last area in which the iceman might live and stay.
2
a mass of special plant was discovered and used to analyze the iceman's movements.
3
a scientist analyzes the iceman's last hike depending on pollen.
4
the time and area the iceman was found.
5
the iceman's body had been out of condition for months before his death.

2 ____ a mass of special plant was discovered and used to analyze the iceman's movements.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('852bbc0d-e6bc-5083-877a-654fe7db7d6a', '3499cd13-2aab-5d66-b902-077c79b1a8ee', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('dc05d142-8523-57f0-9a8c-b0480e801738', '3499cd13-2aab-5d66-b902-077c79b1a8ee', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('755a6ec1-faaa-5fc4-8d6a-101df56a143f', '3499cd13-2aab-5d66-b902-077c79b1a8ee', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fef4eae8-75bb-59e2-9d20-ceb57e952708', '3499cd13-2aab-5d66-b902-077c79b1a8ee', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b07c0526-7f6f-5084-ade0-085f1253fafd', '3499cd13-2aab-5d66-b902-077c79b1a8ee', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d42e9352-75b2-5cb7-9338-cf961d8ca954', '3499cd13-2aab-5d66-b902-077c79b1a8ee', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8aca1b7b-5ef5-53fb-abe2-fc61ca47ac3a', '3499cd13-2aab-5d66-b902-077c79b1a8ee', 7, $md$G$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8d5b915e-8f77-5416-b46b-125580241f52', '3499cd13-2aab-5d66-b902-077c79b1a8ee', 8, $md$H$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('833dce08-14ab-5d88-91ac-ca276712fe21', '6bd84456-c2fb-5c71-8614-82d2f79e143f', 3, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 3

Questions 1-5
Questions 1-5
The reading passage has eight paragraphs A-H . Which paragraph contains the following information?
Write the correct letter A-H, in boxes 1-5 on your answer sheet.
NB you may use any letter more than once
1
the last area in which the iceman might live and stay.
2
a mass of special plant was discovered and used to analyze the iceman's movements.
3
a scientist analyzes the iceman's last hike depending on pollen.
4
the time and area the iceman was found.
5
the iceman's body had been out of condition for months before his death.

3 ____ a scientist analyzes the iceman's last hike depending on pollen.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5dfc67b4-e237-5e81-898f-9cda980e1fc2', '833dce08-14ab-5d88-91ac-ca276712fe21', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1a7e168f-1575-5be0-8a7a-3138b261a728', '833dce08-14ab-5d88-91ac-ca276712fe21', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fb8d375f-ab3d-5c79-93cd-38f1767e5bbf', '833dce08-14ab-5d88-91ac-ca276712fe21', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2eeb23ad-7531-5884-8ddf-9ad174197a97', '833dce08-14ab-5d88-91ac-ca276712fe21', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a227c28c-eb66-5998-93de-5f8843bedc67', '833dce08-14ab-5d88-91ac-ca276712fe21', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('80a29bef-eb93-50bb-8626-efcaa64596d6', '833dce08-14ab-5d88-91ac-ca276712fe21', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('82fcc7bd-d361-5f91-bba6-32739e928973', '833dce08-14ab-5d88-91ac-ca276712fe21', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2fdbd040-98c8-5d5c-b656-07e9af73f9a0', '833dce08-14ab-5d88-91ac-ca276712fe21', 8, $md$H$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('f5bee29b-6b94-5b2c-b38f-751618435935', '6bd84456-c2fb-5c71-8614-82d2f79e143f', 4, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 4

Questions 1-5
Questions 1-5
The reading passage has eight paragraphs A-H . Which paragraph contains the following information?
Write the correct letter A-H, in boxes 1-5 on your answer sheet.
NB you may use any letter more than once
1
the last area in which the iceman might live and stay.
2
a mass of special plant was discovered and used to analyze the iceman's movements.
3
a scientist analyzes the iceman's last hike depending on pollen.
4
the time and area the iceman was found.
5
the iceman's body had been out of condition for months before his death.

4 ____ the time and area the iceman was found.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('406b07a8-0f18-5633-9a4d-c1180e3d21df', 'f5bee29b-6b94-5b2c-b38f-751618435935', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('eb4c371c-041b-55c8-ab12-4b98caad809b', 'f5bee29b-6b94-5b2c-b38f-751618435935', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5cfae176-1e7e-5ec2-a872-e0c9f7a89b65', 'f5bee29b-6b94-5b2c-b38f-751618435935', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('32b0f395-503a-59ff-99ef-b6ddee338313', 'f5bee29b-6b94-5b2c-b38f-751618435935', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c92d5e72-2b3a-5940-bbe5-afed85082329', 'f5bee29b-6b94-5b2c-b38f-751618435935', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('766f5ea1-9c7a-590c-ad87-90c165ca5bcb', 'f5bee29b-6b94-5b2c-b38f-751618435935', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ec647c6e-a293-59cc-8784-0d4a97097ab7', 'f5bee29b-6b94-5b2c-b38f-751618435935', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('00ca8105-e6bd-546a-862b-a174607bc432', 'f5bee29b-6b94-5b2c-b38f-751618435935', 8, $md$H$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('1677efe7-869b-51b8-95e7-7eb0040d42e8', '6bd84456-c2fb-5c71-8614-82d2f79e143f', 5, 'MATCHING_INFORMATION', 'READING', 3, $md$### Question 5

Questions 1-5
Questions 1-5
The reading passage has eight paragraphs A-H . Which paragraph contains the following information?
Write the correct letter A-H, in boxes 1-5 on your answer sheet.
NB you may use any letter more than once
1
the last area in which the iceman might live and stay.
2
a mass of special plant was discovered and used to analyze the iceman's movements.
3
a scientist analyzes the iceman's last hike depending on pollen.
4
the time and area the iceman was found.
5
the iceman's body had been out of condition for months before his death.

5 ____ the iceman's body had been out of condition for months before his death.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6cc27bd9-9cba-58b0-86b9-4a9c900907d6', '1677efe7-869b-51b8-95e7-7eb0040d42e8', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b035cf5c-9166-504d-9458-5663bbb44c0c', '1677efe7-869b-51b8-95e7-7eb0040d42e8', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8542efc7-006f-5e04-9fe8-7e3969d02b65', '1677efe7-869b-51b8-95e7-7eb0040d42e8', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fa39cf58-d5de-53c1-a314-00469fe5cfe5', '1677efe7-869b-51b8-95e7-7eb0040d42e8', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ac9ba2d6-03c7-5044-a348-e2b178f3b267', '1677efe7-869b-51b8-95e7-7eb0040d42e8', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6de9d041-f723-5af6-8136-db1d24345f23', '1677efe7-869b-51b8-95e7-7eb0040d42e8', 6, $md$F$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f6b497fc-fc28-5c9e-9d84-db801b3500d3', '1677efe7-869b-51b8-95e7-7eb0040d42e8', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('14123494-4c8c-561f-a394-e8eb1746aa89', '1677efe7-869b-51b8-95e7-7eb0040d42e8', 8, $md$H$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('97ae78a1-492e-5fb3-a0d3-16aed63cc9d0', '6bd84456-c2fb-5c71-8614-82d2f79e143f', 6, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 6

Questions 6-9
Questions 6-9
Do the following statements agree with the information in Reading Passage?
In boxes 6-9 on your answer sheet write
TRUE
if the statement is true
FALSE
if the statement is false
NOT GIVEN
if the information is not given in the passage
6
According to the author, there must be another complete human corpse older than the iceman
7
The iceman might be the leader of his society, and he was very rich.
8
Scientists guessed the iceman's Information perfectly, and finally got the real cause of his death.
9
By testing the iceman's body, we know where he came from

6 ____ According to the author, there must be another complete human corpse older than the iceman$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('09444c9e-b80d-5f70-b815-8036a97da93f', '97ae78a1-492e-5fb3-a0d3-16aed63cc9d0', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4f97fadf-398b-5241-8c0e-5e6f8cbc08cb', '97ae78a1-492e-5fb3-a0d3-16aed63cc9d0', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4687ea1b-b8bf-578a-ae45-ce2c06a8cea8', '97ae78a1-492e-5fb3-a0d3-16aed63cc9d0', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('9a3f2924-e30e-5f9d-86ed-2c5fadbcac18', '6bd84456-c2fb-5c71-8614-82d2f79e143f', 7, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 7

Questions 6-9
Questions 6-9
Do the following statements agree with the information in Reading Passage?
In boxes 6-9 on your answer sheet write
TRUE
if the statement is true
FALSE
if the statement is false
NOT GIVEN
if the information is not given in the passage
6
According to the author, there must be another complete human corpse older than the iceman
7
The iceman might be the leader of his society, and he was very rich.
8
Scientists guessed the iceman's Information perfectly, and finally got the real cause of his death.
9
By testing the iceman's body, we know where he came from

7 ____ The iceman might be the leader of his society, and he was very rich.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9b2215e3-b9a2-5cde-ac09-c04f056f0851', '9a3f2924-e30e-5f9d-86ed-2c5fadbcac18', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c9b9ab6c-3d93-5486-b251-c52025b8dc73', '9a3f2924-e30e-5f9d-86ed-2c5fadbcac18', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a9f1595f-8de8-5b81-a7d3-7c7098815478', '9a3f2924-e30e-5f9d-86ed-2c5fadbcac18', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('9fccde28-b07b-5b05-bfd3-5920ca5d2889', '6bd84456-c2fb-5c71-8614-82d2f79e143f', 8, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 8

Questions 6-9
Questions 6-9
Do the following statements agree with the information in Reading Passage?
In boxes 6-9 on your answer sheet write
TRUE
if the statement is true
FALSE
if the statement is false
NOT GIVEN
if the information is not given in the passage
6
According to the author, there must be another complete human corpse older than the iceman
7
The iceman might be the leader of his society, and he was very rich.
8
Scientists guessed the iceman's Information perfectly, and finally got the real cause of his death.
9
By testing the iceman's body, we know where he came from

8 ____ Scientists guessed the iceman's Information perfectly, and finally got the real cause of his death.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cb2ebc24-b497-559d-bb76-cc69e2dcedd2', '9fccde28-b07b-5b05-bfd3-5920ca5d2889', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7744a561-c3cc-52fd-a825-fd9c9c0320ff', '9fccde28-b07b-5b05-bfd3-5920ca5d2889', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f9000449-6abd-55d3-ab11-3bf4a7a84021', '9fccde28-b07b-5b05-bfd3-5920ca5d2889', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('f673a115-e02b-5e77-b8ed-bd9fea952f21', '6bd84456-c2fb-5c71-8614-82d2f79e143f', 9, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 9

Questions 6-9
Questions 6-9
Do the following statements agree with the information in Reading Passage?
In boxes 6-9 on your answer sheet write
TRUE
if the statement is true
FALSE
if the statement is false
NOT GIVEN
if the information is not given in the passage
6
According to the author, there must be another complete human corpse older than the iceman
7
The iceman might be the leader of his society, and he was very rich.
8
Scientists guessed the iceman's Information perfectly, and finally got the real cause of his death.
9
By testing the iceman's body, we know where he came from

9 ____ By testing the iceman's body, we know where he came from$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7191bc6f-8648-5b84-b640-06c854f8cad3', 'f673a115-e02b-5e77-b8ed-bd9fea952f21', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a509b9af-8265-5dc2-bb41-ea673643e8a5', 'f673a115-e02b-5e77-b8ed-bd9fea952f21', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('918a4816-7774-5cb9-931f-8d8ab54ac0f2', 'f673a115-e02b-5e77-b8ed-bd9fea952f21', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('762ea1bf-e13d-5992-957e-b2e3f67b844b', '6bd84456-c2fb-5c71-8614-82d2f79e143f', 10, 'SENTENCE_COMPLETION', 'READING', 4, $md$### Question 10

Question 10-13
Question 10-13
Complete the sentences below
Choose
NO MORE THAN TWO WORDS
from the passage for each answer.
Write your answers in boxes
10-13
on your answer sheet.
10. The iceman has been placed in a
10
room since 1998.
11. The iceman might get
11
for eggs of the whipworm parasite were found in his gut.
12. There are a variety of mosses and liverworts found around the iceman such as
12
13. The route of the iceman’s last movement might not be
13

10. The iceman has been placed in a 10 ____ room since 1998.$md$, NULL, ARRAY['.*refrigerated.*high.*tech.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('983f0d99-0a49-5ba3-9362-f43956dd28f3', '6bd84456-c2fb-5c71-8614-82d2f79e143f', 11, 'SENTENCE_COMPLETION', 'READING', 4, $md$### Question 11

Question 10-13
Question 10-13
Complete the sentences below
Choose
NO MORE THAN TWO WORDS
from the passage for each answer.
Write your answers in boxes
10-13
on your answer sheet.
10. The iceman has been placed in a
10
room since 1998.
11. The iceman might get
11
for eggs of the whipworm parasite were found in his gut.
12. There are a variety of mosses and liverworts found around the iceman such as
12
13. The route of the iceman’s last movement might not be
13

11. The iceman might get 11 ____ for eggs of the whipworm parasite were found in his gut.$md$, NULL, ARRAY['.*stomach.*distress.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('d1d4346f-8ff0-5d9d-bdf4-62074d5ec178', '6bd84456-c2fb-5c71-8614-82d2f79e143f', 12, 'SENTENCE_COMPLETION', 'READING', 4, $md$### Question 12

Question 10-13
Question 10-13
Complete the sentences below
Choose
NO MORE THAN TWO WORDS
from the passage for each answer.
Write your answers in boxes
10-13
on your answer sheet.
10. The iceman has been placed in a
10
room since 1998.
11. The iceman might get
11
for eggs of the whipworm parasite were found in his gut.
12. There are a variety of mosses and liverworts found around the iceman such as
12
13. The route of the iceman’s last movement might not be
13

12. There are a variety of mosses and liverworts found around the iceman such as 12 ____$md$, NULL, ARRAY['.*neckera.*complanata.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('fafb5a0b-65ab-5a3e-8c3b-2be35e729a8e', '6bd84456-c2fb-5c71-8614-82d2f79e143f', 13, 'SENTENCE_COMPLETION', 'READING', 4, $md$### Question 13

Question 10-13
Question 10-13
Complete the sentences below
Choose
NO MORE THAN TWO WORDS
from the passage for each answer.
Write your answers in boxes
10-13
on your answer sheet.
10. The iceman has been placed in a
10
room since 1998.
11. The iceman might get
11
for eggs of the whipworm parasite were found in his gut.
12. There are a variety of mosses and liverworts found around the iceman such as
12
13. The route of the iceman’s last movement might not be
13

13. The route of the iceman’s last movement might not be 13 ____$md$, NULL, ARRAY['.*straight.*']);

COMMIT;
