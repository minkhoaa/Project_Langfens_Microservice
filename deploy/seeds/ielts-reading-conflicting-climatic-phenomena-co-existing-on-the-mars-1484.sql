BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-conflicting-climatic-phenomena-co-existing-on-the-mars-1484'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-conflicting-climatic-phenomena-co-existing-on-the-mars-1484';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-conflicting-climatic-phenomena-co-existing-on-the-mars-1484';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-conflicting-climatic-phenomena-co-existing-on-the-mars-1484';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('eb8abf4f-2c12-5cd8-9fd4-2e57b634a3cd', 'ielts-reading-conflicting-climatic-phenomena-co-existing-on-the-mars-1484', $t$Conflicting climatic phenomena co-existing on the Mars$t$, $md$## Conflicting climatic phenomena co-existing on the Mars

Nguồn:
- Test: https://mini-ielts.com/1484/reading/conflicting-climatic-phenomena-co-existing-on-the-mars
- Solution: https://mini-ielts.com/1484/view-solution/reading/conflicting-climatic-phenomena-co-existing-on-the-mars$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('e26b9253-bad1-5bbf-8833-73d17ed87ce4', 'eb8abf4f-2c12-5cd8-9fd4-2e57b634a3cd', 1, $t$Reading — Conflicting climatic phenomena co-existing on the Mars$t$, $md$Read the passage and answer questions **1–13**.

### Passage: Conflicting climatic phenomena co-existing on the Mars

A On Mars, signs of wetness keep pouring in: deeply carved river valleys, vast deltas and widespread remnants of evaporating seas have convinced many experts that liquid water may have covered large parts of the Red Planet for a billion years or more. But most efforts to explain how Martian climate ever permitted such clement conditions come up dry. Bitterly cold and parched today, Mars needed a potent greenhouse atmosphere to sustain its watery past. A thick layer of heat-trapping carbon dioxide from volcanoes probably shrouded the young planet, but climate models indicate time and again that C02 alone could not have kept the surface above freezing.

B Now, inspired by the surprising discovery that sulfur minerals are pervasive in the Martian soil, scientists are beginning to suspect that C02 had a warm-up partner: sulfur dioxide (S02). Like C02, S02 is a common gas emitted when volcanoes erupt, a frequent occurrence on Mars when it was still young. A hundredth or even a thousandth of a percent S02 in Mars's early atmosphere could have provided the extra boost of greenhouse warming that the Red Planet needed to stay wet, explains geochemist Daniel p. Schrag of Harvard University.

C That may not sound like much, but for many gases, even minuscule concentrations are hard to maintain. On our home planet, S02 provides no significant long-term warmth because it combines almost instantly with oxygen in the atmosphere to form sulfate, a type of salt. Early Mars would have been virtually free of atmospheric oxygen, though, so S02 would have stuck around much longer.

D "When you take away oxygen, it's a profound change, and the atmosphere works really differently," Schrag remarks. According to Schrag and his colleagues, that difference also implies that S02 would have played a starring role in the Martian water cycle—thus resolving another climate conundrum, namely, a lack of certain rocks.

E Schrag's team contends that on early Mars, much of the S02 would have combined with airborne water droplets and fallen as sulfurous acid rain, rather than transforming into a salt as on Earth. The resulting acidity would have inhibited the formation of thick layers of limestone and other carbonate rocks. Researchers assumed Mars would be chock-full of carbonate rocks because their formation is such a fundamental consequence of the humid, C02-rich atmosphere. Over millions of years, this rock-forming process has sequestered enough of the carbon dioxide spewed from earthly volcanoes to limit the buildup of the gas in the atmosphere. stifling this C02-sequestration step on early Mars would have forced more of the gas to accumulate in the atmosphere—another way S02 could have boosted greenhouse warming, Schrag suggests.

F Some scientists doubt that S02 was really up to these climatic tasks . Even in an oxygen-free atmosphere, S02 is still extremely fragile; the sun's ultraviolet radiation splits apart S02 molecules quite readily, points out James F. Kasting, an atmospheric chemist at Pennsylvania state University. In Easting's computer models of Earth's early climate, which is often compared with that of early Mars, this photochemical destruction capped S02 concentrations at one thousandth as much as Schrag and his colleagues describe. "There may be ways to make this idea work," Kasting says. "But it would take some detailed modeling to convince skeptics, including me, that it is actually feasible."

G Schrag admits that the details are uncertain, but he cites estimates by other researchers who suggest that early Martian volcanoes could have spewed enough S02 to keep pace with the S02 destroyed photochemically. Previous findings also indicate that a thick C02 atmosphere would have effectively scattered the most destructive wavelengths of ultraviolet radiation—yet another example of an apparently mutually beneficial partnership between C02 and S02 on early Mars.

H Kasting maintains that an S02 climate feedback could not have made early Mars as warm as Earth, but he does allow for the possibility that S02 concentrations may have remained high enough to keep the planet partly defrosted, with perhaps enough rainfall to form river valleys. Over that point, Schrag does not quibble. "Our hypothesis doesn't depend at all on whether there was a big ocean, a few lakes or just a few little puddles," he says. " Warm doesn't mean warm like the Amazon. It could mean warm like Iceland— just warm enough to create those river valleys . " with S02, it only takes a little. If sulfur dioxide warmed early Mars, as a new hypothesis suggests, minerals called sulfites would have formed in standing water at the surface. No sulfites have yet turned up, possibly because no one was looking for them. The next-generation rover, the Mars Science Laboratory, is well equipped for the search. Scheduled to launch in 2009, the rover (shown here in an artist's conception) will be the first to carry an x-ray diffractometer, which can scan and identify the crystal structure of any mineral it encounters.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('77216b8f-8106-56ed-a8ff-2a4c934d731b', 'e26b9253-bad1-5bbf-8833-73d17ed87ce4', 1, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 1

Questions 1-6
Questions 1-6
The reading Passage has seven paragraphs A-H.
Which paragraph contains the following information?
Write the correct letter
A-H,
in boxes
1-6
on your answer sheet.
NB
You may use any letter more than once.
1
A problem indirectly solved by SO2
2
A device with an astounding ability for detection
3
A potential contributor to the warmth of the Mars interacting with CO2
4
The destructive effect brought by the sunlight proposed by the opponents
5
A specific condition on early Mars to guarantee the SO2 to maintain in the atmosphere for a long time
6
Conflicting climatic phenomena co-existing on the Mars

1 ____ A problem indirectly solved by SO2$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a7b0935e-3936-5b8e-a281-237bee1d299a', '77216b8f-8106-56ed-a8ff-2a4c934d731b', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9cbcb845-e92a-56bd-b03b-8362a4f01a6f', '77216b8f-8106-56ed-a8ff-2a4c934d731b', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('877f3795-d96a-518f-b295-7936124c5829', '77216b8f-8106-56ed-a8ff-2a4c934d731b', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2b76e734-ef6c-52be-a73d-ccac539ad696', '77216b8f-8106-56ed-a8ff-2a4c934d731b', 4, $md$D$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b301be7e-be6e-511a-906a-36c029102ba5', '77216b8f-8106-56ed-a8ff-2a4c934d731b', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5ed4dcdf-6826-5a9f-b61f-d0dd02e19b93', '77216b8f-8106-56ed-a8ff-2a4c934d731b', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('56c1c732-bc0f-5f52-a1cc-7fa58dfc5598', '77216b8f-8106-56ed-a8ff-2a4c934d731b', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('35afb196-cb2c-54be-a39d-de4e22687253', '77216b8f-8106-56ed-a8ff-2a4c934d731b', 8, $md$H$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('75f6f26f-ba74-5d0c-b16a-172fc746147c', 'e26b9253-bad1-5bbf-8833-73d17ed87ce4', 2, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 2

Questions 1-6
Questions 1-6
The reading Passage has seven paragraphs A-H.
Which paragraph contains the following information?
Write the correct letter
A-H,
in boxes
1-6
on your answer sheet.
NB
You may use any letter more than once.
1
A problem indirectly solved by SO2
2
A device with an astounding ability for detection
3
A potential contributor to the warmth of the Mars interacting with CO2
4
The destructive effect brought by the sunlight proposed by the opponents
5
A specific condition on early Mars to guarantee the SO2 to maintain in the atmosphere for a long time
6
Conflicting climatic phenomena co-existing on the Mars

2 ____ A device with an astounding ability for detection$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8249a835-140e-50cf-a94f-2230267aed64', '75f6f26f-ba74-5d0c-b16a-172fc746147c', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2c2fb130-f520-526d-8b0e-79860cca3102', '75f6f26f-ba74-5d0c-b16a-172fc746147c', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ee37d20d-6bb3-59fd-9314-13bb03bd39e0', '75f6f26f-ba74-5d0c-b16a-172fc746147c', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('431ab2bf-77cf-5898-a2cf-396684f7a88f', '75f6f26f-ba74-5d0c-b16a-172fc746147c', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cbed5648-e6d2-5c09-a5fc-9c63e62009ab', '75f6f26f-ba74-5d0c-b16a-172fc746147c', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c4bb6d46-9369-5bcf-9b4d-d9c96c6ed32e', '75f6f26f-ba74-5d0c-b16a-172fc746147c', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e96f7187-35a7-5c79-bbc6-1cc4eb81fab5', '75f6f26f-ba74-5d0c-b16a-172fc746147c', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9fbb7859-05e5-5146-8427-2bf2702539bb', '75f6f26f-ba74-5d0c-b16a-172fc746147c', 8, $md$H$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('d9675d2b-3adb-580c-b5d5-1fece4746411', 'e26b9253-bad1-5bbf-8833-73d17ed87ce4', 3, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 3

Questions 1-6
Questions 1-6
The reading Passage has seven paragraphs A-H.
Which paragraph contains the following information?
Write the correct letter
A-H,
in boxes
1-6
on your answer sheet.
NB
You may use any letter more than once.
1
A problem indirectly solved by SO2
2
A device with an astounding ability for detection
3
A potential contributor to the warmth of the Mars interacting with CO2
4
The destructive effect brought by the sunlight proposed by the opponents
5
A specific condition on early Mars to guarantee the SO2 to maintain in the atmosphere for a long time
6
Conflicting climatic phenomena co-existing on the Mars

3 ____ A potential contributor to the warmth of the Mars interacting with CO2$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('adeff800-35be-53ac-9cf3-91b22fdaa67b', 'd9675d2b-3adb-580c-b5d5-1fece4746411', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('32834626-a22b-543b-9808-84772352bf09', 'd9675d2b-3adb-580c-b5d5-1fece4746411', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fcf11830-e22d-5b4c-aabc-1f6129af7780', 'd9675d2b-3adb-580c-b5d5-1fece4746411', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1cdee173-ea76-54b9-a078-b9c63c0cb718', 'd9675d2b-3adb-580c-b5d5-1fece4746411', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('04cb1542-5401-5788-bfae-93f14aed9c45', 'd9675d2b-3adb-580c-b5d5-1fece4746411', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('507aafb8-9ace-5ae5-9ed8-a463f8867dce', 'd9675d2b-3adb-580c-b5d5-1fece4746411', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3f630259-cfc0-57df-82c2-be28f9d1b707', 'd9675d2b-3adb-580c-b5d5-1fece4746411', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ac8374b5-6e05-5781-add6-5cefe088073a', 'd9675d2b-3adb-580c-b5d5-1fece4746411', 8, $md$H$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('07ca7064-7c8d-5759-8400-5cc7b06e3331', 'e26b9253-bad1-5bbf-8833-73d17ed87ce4', 4, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 4

Questions 1-6
Questions 1-6
The reading Passage has seven paragraphs A-H.
Which paragraph contains the following information?
Write the correct letter
A-H,
in boxes
1-6
on your answer sheet.
NB
You may use any letter more than once.
1
A problem indirectly solved by SO2
2
A device with an astounding ability for detection
3
A potential contributor to the warmth of the Mars interacting with CO2
4
The destructive effect brought by the sunlight proposed by the opponents
5
A specific condition on early Mars to guarantee the SO2 to maintain in the atmosphere for a long time
6
Conflicting climatic phenomena co-existing on the Mars

4 ____ The destructive effect brought by the sunlight proposed by the opponents$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('77d2df4b-2da5-513b-bd00-c1c8a9d4d22e', '07ca7064-7c8d-5759-8400-5cc7b06e3331', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('05399d7b-8e5c-51fc-8f62-4a349be35a9e', '07ca7064-7c8d-5759-8400-5cc7b06e3331', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c2426e1e-7d04-5b3c-8640-bfdb9ac25116', '07ca7064-7c8d-5759-8400-5cc7b06e3331', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2b35c8c7-403c-568e-b7af-dcdd4a3fd59a', '07ca7064-7c8d-5759-8400-5cc7b06e3331', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d70b578d-50df-5d90-8a32-19d9b13646ae', '07ca7064-7c8d-5759-8400-5cc7b06e3331', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1d52fad9-06ed-5c69-a9de-df73f1ced9a8', '07ca7064-7c8d-5759-8400-5cc7b06e3331', 6, $md$F$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0e3029bd-d333-5573-9348-c32f7e9df82b', '07ca7064-7c8d-5759-8400-5cc7b06e3331', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('352ece25-f1e5-594c-8cc7-763138a8c0ef', '07ca7064-7c8d-5759-8400-5cc7b06e3331', 8, $md$H$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('9a0e4f41-9ebf-5514-a605-62b2ec3ec6a8', 'e26b9253-bad1-5bbf-8833-73d17ed87ce4', 5, 'MATCHING_INFORMATION', 'READING', 3, $md$### Question 5

Questions 1-6
Questions 1-6
The reading Passage has seven paragraphs A-H.
Which paragraph contains the following information?
Write the correct letter
A-H,
in boxes
1-6
on your answer sheet.
NB
You may use any letter more than once.
1
A problem indirectly solved by SO2
2
A device with an astounding ability for detection
3
A potential contributor to the warmth of the Mars interacting with CO2
4
The destructive effect brought by the sunlight proposed by the opponents
5
A specific condition on early Mars to guarantee the SO2 to maintain in the atmosphere for a long time
6
Conflicting climatic phenomena co-existing on the Mars

5 ____ A specific condition on early Mars to guarantee the SO2 to maintain in the atmosphere for a long time$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('84152ea5-3d59-5fa3-a175-fd32d8828c43', '9a0e4f41-9ebf-5514-a605-62b2ec3ec6a8', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('32f706f3-8c7a-5c00-8f5f-8620341011dc', '9a0e4f41-9ebf-5514-a605-62b2ec3ec6a8', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('be9cf41d-7fc9-595c-8f2b-f79f00783d1c', '9a0e4f41-9ebf-5514-a605-62b2ec3ec6a8', 3, $md$C$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('891b62ca-06b9-5eff-a509-ccb367ef7d98', '9a0e4f41-9ebf-5514-a605-62b2ec3ec6a8', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('824fb1cb-31b7-52e6-a89e-6f2e810b037c', '9a0e4f41-9ebf-5514-a605-62b2ec3ec6a8', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ee71f830-ad09-5a70-8c9d-753964287c38', '9a0e4f41-9ebf-5514-a605-62b2ec3ec6a8', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b12c18ad-88b9-5fc2-91ae-a026083b300d', '9a0e4f41-9ebf-5514-a605-62b2ec3ec6a8', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('85224cbf-4afa-5e6b-a051-95642b8cd4c7', '9a0e4f41-9ebf-5514-a605-62b2ec3ec6a8', 8, $md$H$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('c5e4a026-4a1d-5a22-9146-da204dbf2751', 'e26b9253-bad1-5bbf-8833-73d17ed87ce4', 6, 'MATCHING_INFORMATION', 'READING', 3, $md$### Question 6

Questions 1-6
Questions 1-6
The reading Passage has seven paragraphs A-H.
Which paragraph contains the following information?
Write the correct letter
A-H,
in boxes
1-6
on your answer sheet.
NB
You may use any letter more than once.
1
A problem indirectly solved by SO2
2
A device with an astounding ability for detection
3
A potential contributor to the warmth of the Mars interacting with CO2
4
The destructive effect brought by the sunlight proposed by the opponents
5
A specific condition on early Mars to guarantee the SO2 to maintain in the atmosphere for a long time
6
Conflicting climatic phenomena co-existing on the Mars

6 ____ Conflicting climatic phenomena co-existing on the Mars$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('92921ef4-f228-586f-b84b-f9df356a1974', 'c5e4a026-4a1d-5a22-9146-da204dbf2751', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('710a4e5f-5d96-5a47-a23d-c8378dc41e57', 'c5e4a026-4a1d-5a22-9146-da204dbf2751', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6fb6a603-96e5-5132-9463-44934b50e1ba', 'c5e4a026-4a1d-5a22-9146-da204dbf2751', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('816751b6-4c2e-5e43-8cad-cf3a144305b5', 'c5e4a026-4a1d-5a22-9146-da204dbf2751', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('89aaec1c-d5e8-5627-a74e-4c44b69b9995', 'c5e4a026-4a1d-5a22-9146-da204dbf2751', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a758ae6e-f6ae-5366-800f-da6a012d21e5', 'c5e4a026-4a1d-5a22-9146-da204dbf2751', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('02992e4d-d5ff-59aa-a039-06c881b76b52', 'c5e4a026-4a1d-5a22-9146-da204dbf2751', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6997e2d5-5253-5e0e-8f7d-f1cbd69dd1e5', 'c5e4a026-4a1d-5a22-9146-da204dbf2751', 8, $md$H$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('b9f3957c-7f87-518c-8ec5-81f87a7f0998', 'e26b9253-bad1-5bbf-8833-73d17ed87ce4', 7, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 7

Questions 7-9
Questions 7-9
Do the following statements agree with the information given in Reading Passage?
In boxes 7-9 on your answer sheet, write
TRUE
if the statement is true
FALSE
if the statement is false
NOT GIVEN
if the information is not given in the passage
7
Schrag has provided concrete proofs to fight against the skeptics for his view.
8
More and more evidences show up to be in favor of the leading role SO2 has for the warming up the Mars.
9
The sulfites have not been detected probably because of no concern for them.

7 ____ Schrag has provided concrete proofs to fight against the skeptics for his view.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b46179ad-a190-5e58-9d4d-9737e23d4df8', 'b9f3957c-7f87-518c-8ec5-81f87a7f0998', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d549a33e-bfd4-5cb8-b11d-e63b3c2426e1', 'b9f3957c-7f87-518c-8ec5-81f87a7f0998', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6f2e7a29-f565-5291-bb67-20c403575dd3', 'b9f3957c-7f87-518c-8ec5-81f87a7f0998', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('7d68dd09-0eb8-5d67-8e40-f1e34cc466a7', 'e26b9253-bad1-5bbf-8833-73d17ed87ce4', 8, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 8

Questions 7-9
Questions 7-9
Do the following statements agree with the information given in Reading Passage?
In boxes 7-9 on your answer sheet, write
TRUE
if the statement is true
FALSE
if the statement is false
NOT GIVEN
if the information is not given in the passage
7
Schrag has provided concrete proofs to fight against the skeptics for his view.
8
More and more evidences show up to be in favor of the leading role SO2 has for the warming up the Mars.
9
The sulfites have not been detected probably because of no concern for them.

8 ____ More and more evidences show up to be in favor of the leading role SO2 has for the warming up the Mars.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('efc47791-f30b-5be7-8b33-832797a1c2c9', '7d68dd09-0eb8-5d67-8e40-f1e34cc466a7', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('36df59db-64d0-5426-8237-e0efd851cc53', '7d68dd09-0eb8-5d67-8e40-f1e34cc466a7', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9c209b99-5351-5b84-9e41-6a7c4bac4277', '7d68dd09-0eb8-5d67-8e40-f1e34cc466a7', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('3ae808c8-7336-56f0-9f14-e7ef3a4528df', 'e26b9253-bad1-5bbf-8833-73d17ed87ce4', 9, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 9

Questions 7-9
Questions 7-9
Do the following statements agree with the information given in Reading Passage?
In boxes 7-9 on your answer sheet, write
TRUE
if the statement is true
FALSE
if the statement is false
NOT GIVEN
if the information is not given in the passage
7
Schrag has provided concrete proofs to fight against the skeptics for his view.
8
More and more evidences show up to be in favor of the leading role SO2 has for the warming up the Mars.
9
The sulfites have not been detected probably because of no concern for them.

9 ____ The sulfites have not been detected probably because of no concern for them.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a789970b-0263-58c7-9b77-ac2b8c99233c', '3ae808c8-7336-56f0-9f14-e7ef3a4528df', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('04fcdd46-266a-5aaa-b719-d03d2d8e60b4', '3ae808c8-7336-56f0-9f14-e7ef3a4528df', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a4548f38-197b-55d8-9c37-048e9b35ef36', '3ae808c8-7336-56f0-9f14-e7ef3a4528df', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('a33bb83b-5ece-595a-b00c-10b1d8990d4b', 'e26b9253-bad1-5bbf-8833-73d17ed87ce4', 10, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 10

Questions 10-13
Questions 10-13
Summary
Complete the following summary of the paragraphs of Reading Passage, using No
More than Three
words from the Reading Passage for each answer. Write your answers in boxes 10-13 on your answer sheet.
An opinion held by Schrag’s team indicates that
10
formed from the integration of SO2 with
11
would have stopped the built up of thick layers of limestone as well as certain carbonate rocks. Wetness and abundance in CO2 could directly result in the good production rocky layer of
12
. As time went by, sufficient CO2 was emitted from the volcanoes and restricted the formation of the gas in the afr. To stop this process made SO2 possible to accelerate
13

An opinion held by Schrag’s team indicates that 10 ____ formed from the integration of SO2 with 11 ____ would have stopped the built up of thick layers of limestone as well as certain carbonate rocks. Wetness and abundance in CO2 could directly result in the good production rocky layer of 12 ____ . As time went by, sufficient CO2 was emitted from the volcanoes and restricted the formation of the gas in the afr. To stop this process made SO2 possible to accelerate 13 ____$md$, NULL, ARRAY['.*sulfurous.*acid.*rain.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('d5fb9214-415d-5dac-8709-8b83e1086761', 'e26b9253-bad1-5bbf-8833-73d17ed87ce4', 11, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 11

Questions 10-13
Questions 10-13
Summary
Complete the following summary of the paragraphs of Reading Passage, using No
More than Three
words from the Reading Passage for each answer. Write your answers in boxes 10-13 on your answer sheet.
An opinion held by Schrag’s team indicates that
10
formed from the integration of SO2 with
11
would have stopped the built up of thick layers of limestone as well as certain carbonate rocks. Wetness and abundance in CO2 could directly result in the good production rocky layer of
12
. As time went by, sufficient CO2 was emitted from the volcanoes and restricted the formation of the gas in the afr. To stop this process made SO2 possible to accelerate
13

An opinion held by Schrag’s team indicates that 10 ____ formed from the integration of SO2 with 11 ____ would have stopped the built up of thick layers of limestone as well as certain carbonate rocks. Wetness and abundance in CO2 could directly result in the good production rocky layer of 12 ____ . As time went by, sufficient CO2 was emitted from the volcanoes and restricted the formation of the gas in the afr. To stop this process made SO2 possible to accelerate 13 ____$md$, NULL, ARRAY['.*sulfurous.*acid.*rain.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('7dd91bb8-ad7c-5cce-ad4e-b910fc2c12c6', 'e26b9253-bad1-5bbf-8833-73d17ed87ce4', 12, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 12

Questions 10-13
Questions 10-13
Summary
Complete the following summary of the paragraphs of Reading Passage, using No
More than Three
words from the Reading Passage for each answer. Write your answers in boxes 10-13 on your answer sheet.
An opinion held by Schrag’s team indicates that
10
formed from the integration of SO2 with
11
would have stopped the built up of thick layers of limestone as well as certain carbonate rocks. Wetness and abundance in CO2 could directly result in the good production rocky layer of
12
. As time went by, sufficient CO2 was emitted from the volcanoes and restricted the formation of the gas in the afr. To stop this process made SO2 possible to accelerate
13

An opinion held by Schrag’s team indicates that 10 ____ formed from the integration of SO2 with 11 ____ would have stopped the built up of thick layers of limestone as well as certain carbonate rocks. Wetness and abundance in CO2 could directly result in the good production rocky layer of 12 ____ . As time went by, sufficient CO2 was emitted from the volcanoes and restricted the formation of the gas in the afr. To stop this process made SO2 possible to accelerate 13 ____$md$, NULL, ARRAY['.*sulfurous.*acid.*rain.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('51791242-1a26-5c0f-9d8e-a05d4ac052f0', 'e26b9253-bad1-5bbf-8833-73d17ed87ce4', 13, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 13

Questions 10-13
Questions 10-13
Summary
Complete the following summary of the paragraphs of Reading Passage, using No
More than Three
words from the Reading Passage for each answer. Write your answers in boxes 10-13 on your answer sheet.
An opinion held by Schrag’s team indicates that
10
formed from the integration of SO2 with
11
would have stopped the built up of thick layers of limestone as well as certain carbonate rocks. Wetness and abundance in CO2 could directly result in the good production rocky layer of
12
. As time went by, sufficient CO2 was emitted from the volcanoes and restricted the formation of the gas in the afr. To stop this process made SO2 possible to accelerate
13

An opinion held by Schrag’s team indicates that 10 ____ formed from the integration of SO2 with 11 ____ would have stopped the built up of thick layers of limestone as well as certain carbonate rocks. Wetness and abundance in CO2 could directly result in the good production rocky layer of 12 ____ . As time went by, sufficient CO2 was emitted from the volcanoes and restricted the formation of the gas in the afr. To stop this process made SO2 possible to accelerate 13 ____$md$, NULL, ARRAY['.*sulfurous.*acid.*rain.*']);

COMMIT;
