BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-crisis-freshwater-1493'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-crisis-freshwater-1493';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-crisis-freshwater-1493';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-crisis-freshwater-1493';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('53b8c995-2024-5c8b-9bb6-567b7514b4cf', 'ielts-reading-crisis-freshwater-1493', $t$Crisis! freshwater$t$, $md$## Crisis! freshwater

Nguồn:
- Test: https://mini-ielts.com/1493/reading/crisis-freshwater
- Solution: https://mini-ielts.com/1493/view-solution/reading/crisis-freshwater$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('3602cf6f-47ee-5859-a2a3-0a77c24f491b', '53b8c995-2024-5c8b-9bb6-567b7514b4cf', 1, $t$Reading — Crisis! freshwater$t$, $md$Read the passage and answer questions **1–13**.

### Passage: Crisis! freshwater

A . As in New Delhi and Phoenix, policymakers worldwide wield great power over how water resources and managed. Wise use of such power will become increasingly important as the years go by because the world’s demand for freshwater is currently overtaking its ready supply in many places, and this situation shows no sign of abating.

B . That the problem is well-known makes it no less disturbing: today one out of six people, more than a billion, suffer inadequate access to safe freshwater. By 2025, according to data released by the United Nations, the freshwater resources of more than half the countries across the globe will undergo either stress- for example, when people increasingly demand more water than is available or safe for use-or outright shortages. By mid-century, as much as three-quarters of the earth’s population could face scarcities of freshwater.

C . Scientists expect water scarcity to become more common in large part because the world’s population is rising and many people are getting richer (thus expanding demand) and because global climate change is exacerbating aridity and reducing supply in many regions. What is more, many water sources are threatened by faulty waste disposal, releases of industrial pollutants, fertilizer runoff, and coastal influxes of saltwater into aquifers as groundwater is depleted.

D . Because lack of access to water can lead to starvation, disease, political instability, and even armed conflict, failure to take action can have broad and grave consequences. Fortunately, to a great extent, the technologies and policy tools required to conserve existing freshwater and to secure more of it are known among which several seem particularly effective. What is needed now is action. Governments and authorities at every level have to formulate and execute plans for implementing the political, economic, and technological measures that can ensure water security now and in the coming decades.

E . The world’s water problems require, as a start, an understanding of how much freshwater each person requires, along with knowledge of the factors that impede supply and increase demand in different parts of the world. Main Falkenmark of the Stockholm International Water Institute and other experts estimate that, on average, each person on the earth needs a minimum of 1000 cubic meters (m3) of water. The minimum water each person requires for drinking, hygiene, and growing food. The volume is equivalent to two-fifths of an Olympic-size swimming pool.

F . Much of the Americas and northern Eurasia enjoy abundant water supplies. But several regions are beset by greater or lesser degrees of “physical” scarcity-whereby demand exceeds local availability. Other areas, among them Central Africa, parts of the Indian subcontinent, and Southeast Asia contend with “economic” water scarcity limit access even though sufficient supplies are available.

G. More than half of the precipitation that falls on land is never available for capture or storage because it evaporates from the ground or transpires from plants; this fraction is called blue-water sources-rivers, lakes, wetlands, and aquifers-that people can tap directly. Farm irrigation from these free-flowing bodies is the biggest single human use of freshwater resources, but the intense local demand they create often drains the surroundings of ready supplies.

H . Lots of water, but not always where it is needed one hundred and ten thousand cubic kilometers of precipitation, nearly 10 times the volume of Lake Superior, falls from the sky onto the earth’s land surface every year. This huge quantity would easily fulfill the requirements of everyone on the planet if the water arrived where and when people needed it. But much of it cannot be captured (top), and the rest is disturbed unevenly (bottom). Green water (61.1% of total precipitation): absorbed by soil and plants, then released back into the air: unavailable for withdrawal. Bluewater (38.8% of total precipitation): collected in rivers, lakes, wetlands, and groundwater: available for withdrawal before it evaporates or reaches the ocean. These figures may not add up to 100% because of rounding. Only 1.5% is directly used by people.

I . Waters run away in tremendous wildfires in recent years. The economic actors had all taken their share reasonably enough: they just did not consider the needs of the natural environment, which suffered greatly when its inadequate supply was reduced to critical levels by drought. The members of the Murray-Darling Basin Commission are now frantically trying to extricate themselves from the disastrous results of their misallocation of the total water resource. Given the difficulties of sensibly apportioning the water supply within a single nation, imagine the complexities of doing so for international river basins such as that of the Jordan River, which borders on Lebanon, Syria, Israel, the Palestinian areas, and Jordan, all of which have claims to the shared, but limited, supply in an extremely parched region. The struggle for freshwater has contributed to civil and military disputes in the area. Only continuing negotiations and compromises have kept this tense situation under control.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('ef466d5c-ca39-509b-aa77-7c7ced1d338d', '3602cf6f-47ee-5859-a2a3-0a77c24f491b', 1, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 1

Questions 1-5
Questions 1-5
Do the following statements agree with the information given in Reading Passage? In boxes 1-5 on your answer sheet, write
TRUE If the statement is true
FALSE If the statement is false
NOT GIVEN If the information is not given in the passage
1
The prospect for the need for freshwater worldwide is obscure.
2
To some extent, the challenge for freshwater is alleviated by common recognition.
3
Researchers arrive at the specific conclusion about the water crisis based on persuasive consideration of several factors.
4
The fact that people do not actually cherish the usage of water scarcity.
5
Controversy can’t be avoided for adjacent nations over the water resource.

1 ____ The prospect for the need for freshwater worldwide is obscure.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b71a27be-022f-5bfc-8545-853682bdc4b6', 'ef466d5c-ca39-509b-aa77-7c7ced1d338d', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c2f90d11-8b9a-5e01-98c3-851cd8ca556c', 'ef466d5c-ca39-509b-aa77-7c7ced1d338d', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('54de146b-2d1f-5420-b7af-7bd2b499603b', 'ef466d5c-ca39-509b-aa77-7c7ced1d338d', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('05df6cdb-b4fd-5141-ba48-79abc424b4dc', '3602cf6f-47ee-5859-a2a3-0a77c24f491b', 2, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 2

Questions 1-5
Questions 1-5
Do the following statements agree with the information given in Reading Passage? In boxes 1-5 on your answer sheet, write
TRUE If the statement is true
FALSE If the statement is false
NOT GIVEN If the information is not given in the passage
1
The prospect for the need for freshwater worldwide is obscure.
2
To some extent, the challenge for freshwater is alleviated by common recognition.
3
Researchers arrive at the specific conclusion about the water crisis based on persuasive consideration of several factors.
4
The fact that people do not actually cherish the usage of water scarcity.
5
Controversy can’t be avoided for adjacent nations over the water resource.

2 ____ To some extent, the challenge for freshwater is alleviated by common recognition.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8f944ae3-a15c-577c-92c6-49a6e4df62c3', '05df6cdb-b4fd-5141-ba48-79abc424b4dc', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('44f4ef2b-4df7-5ce9-a18b-726f922f2b89', '05df6cdb-b4fd-5141-ba48-79abc424b4dc', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4b633584-e97c-54cf-8d46-6ce1608f35d3', '05df6cdb-b4fd-5141-ba48-79abc424b4dc', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('411dd6b4-65ff-55a4-9593-ffd4eee2b912', '3602cf6f-47ee-5859-a2a3-0a77c24f491b', 3, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 3

Questions 1-5
Questions 1-5
Do the following statements agree with the information given in Reading Passage? In boxes 1-5 on your answer sheet, write
TRUE If the statement is true
FALSE If the statement is false
NOT GIVEN If the information is not given in the passage
1
The prospect for the need for freshwater worldwide is obscure.
2
To some extent, the challenge for freshwater is alleviated by common recognition.
3
Researchers arrive at the specific conclusion about the water crisis based on persuasive consideration of several factors.
4
The fact that people do not actually cherish the usage of water scarcity.
5
Controversy can’t be avoided for adjacent nations over the water resource.

3 ____ Researchers arrive at the specific conclusion about the water crisis based on persuasive consideration of several factors.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('60604482-8131-512c-b37b-c60fb27ec568', '411dd6b4-65ff-55a4-9593-ffd4eee2b912', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6286c39b-9b95-5bc3-aaa5-d51f14065359', '411dd6b4-65ff-55a4-9593-ffd4eee2b912', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d8ac1f1e-ab61-5a5b-91ca-9152bc94819a', '411dd6b4-65ff-55a4-9593-ffd4eee2b912', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('dded2b63-5547-5805-8612-c8a1167049e2', '3602cf6f-47ee-5859-a2a3-0a77c24f491b', 4, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 4

Questions 1-5
Questions 1-5
Do the following statements agree with the information given in Reading Passage? In boxes 1-5 on your answer sheet, write
TRUE If the statement is true
FALSE If the statement is false
NOT GIVEN If the information is not given in the passage
1
The prospect for the need for freshwater worldwide is obscure.
2
To some extent, the challenge for freshwater is alleviated by common recognition.
3
Researchers arrive at the specific conclusion about the water crisis based on persuasive consideration of several factors.
4
The fact that people do not actually cherish the usage of water scarcity.
5
Controversy can’t be avoided for adjacent nations over the water resource.

4 ____ The fact that people do not actually cherish the usage of water scarcity.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4d625704-7b29-521f-9f24-0c339c1af8c8', 'dded2b63-5547-5805-8612-c8a1167049e2', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('77d2888b-fe37-5879-9626-cfb89560430b', 'dded2b63-5547-5805-8612-c8a1167049e2', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('33423875-dfad-5d9d-8071-632d3314ef87', 'dded2b63-5547-5805-8612-c8a1167049e2', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('37c5a426-8a6a-5415-9aaa-86af839c47b7', '3602cf6f-47ee-5859-a2a3-0a77c24f491b', 5, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 5

Questions 1-5
Questions 1-5
Do the following statements agree with the information given in Reading Passage? In boxes 1-5 on your answer sheet, write
TRUE If the statement is true
FALSE If the statement is false
NOT GIVEN If the information is not given in the passage
1
The prospect for the need for freshwater worldwide is obscure.
2
To some extent, the challenge for freshwater is alleviated by common recognition.
3
Researchers arrive at the specific conclusion about the water crisis based on persuasive consideration of several factors.
4
The fact that people do not actually cherish the usage of water scarcity.
5
Controversy can’t be avoided for adjacent nations over the water resource.

5 ____ Controversy can’t be avoided for adjacent nations over the water resource.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('36c540ee-d8f9-5516-9a39-c4b30fefd9ed', '37c5a426-8a6a-5415-9aaa-86af839c47b7', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('51918ad2-0174-570e-b4af-f929e9ef1a9c', '37c5a426-8a6a-5415-9aaa-86af839c47b7', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('348824c3-f935-5519-99f1-e6af7cb37d1d', '37c5a426-8a6a-5415-9aaa-86af839c47b7', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('2ef30f2b-1b11-57dc-89e8-dcd4dca2b0f8', '3602cf6f-47ee-5859-a2a3-0a77c24f491b', 6, 'MATCHING_INFORMATION', 'READING', 3, $md$### Question 6

Questions 6-10
Questions 6-10
The readings Passage has eleven paragraphs A-I
Which paragraph contains the following information?
Write the correct letter A-I, in boxes 6-10 on your answer sheet.
NB
You may use any letter more than once.
6
The uneven distribution of water around the world.
7
other factors regarding nature bothering people who make the policies.
8
Joint efforts needed to carry out the detailed solutions combined with various aspects.
9
No always-in-time match available between the requirements and the actual rainfall.
10
The lower limit of the amount of fresh water for a person to survive.

6 ____ The uneven distribution of water around the world.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('de469f6b-f5f6-5944-82f4-656f64ce0892', '2ef30f2b-1b11-57dc-89e8-dcd4dca2b0f8', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('21cb577a-cdfc-5c45-9a96-dbbf63cdb792', '2ef30f2b-1b11-57dc-89e8-dcd4dca2b0f8', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('96b73e61-f05f-5500-91ca-6a3ed0f02d6b', '2ef30f2b-1b11-57dc-89e8-dcd4dca2b0f8', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('22366d91-0684-5b16-8ca6-4684840e692b', '2ef30f2b-1b11-57dc-89e8-dcd4dca2b0f8', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('08cd5312-aecf-5977-b885-6dc724350df8', '2ef30f2b-1b11-57dc-89e8-dcd4dca2b0f8', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('027d2f81-ab23-5224-850c-56c435b1cee2', '2ef30f2b-1b11-57dc-89e8-dcd4dca2b0f8', 6, $md$F$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('748310aa-3c98-5398-b391-b465dd1f887d', '2ef30f2b-1b11-57dc-89e8-dcd4dca2b0f8', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('790756e6-8008-5861-b09c-c2241d4e74fb', '2ef30f2b-1b11-57dc-89e8-dcd4dca2b0f8', 8, $md$H$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0eb04320-75aa-52cd-a030-619a98585918', '2ef30f2b-1b11-57dc-89e8-dcd4dca2b0f8', 9, $md$I$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('c454973e-238f-5b10-b704-3687574c00f9', '3602cf6f-47ee-5859-a2a3-0a77c24f491b', 7, 'MATCHING_INFORMATION', 'READING', 3, $md$### Question 7

Questions 6-10
Questions 6-10
The readings Passage has eleven paragraphs A-I
Which paragraph contains the following information?
Write the correct letter A-I, in boxes 6-10 on your answer sheet.
NB
You may use any letter more than once.
6
The uneven distribution of water around the world.
7
other factors regarding nature bothering people who make the policies.
8
Joint efforts needed to carry out the detailed solutions combined with various aspects.
9
No always-in-time match available between the requirements and the actual rainfall.
10
The lower limit of the amount of fresh water for a person to survive.

7 ____ other factors regarding nature bothering people who make the policies.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9e3c9f81-2f29-59f5-8a69-1d600dd73f4c', 'c454973e-238f-5b10-b704-3687574c00f9', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('500cfcc1-30bb-5bef-885a-d5dcffe222b2', 'c454973e-238f-5b10-b704-3687574c00f9', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('43556a91-8e10-5931-aeff-aca19a41b156', 'c454973e-238f-5b10-b704-3687574c00f9', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d4a0e047-e899-5dc5-a122-b11efaa30fff', 'c454973e-238f-5b10-b704-3687574c00f9', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3866b4b7-3ce4-5509-a3ef-80b464a17822', 'c454973e-238f-5b10-b704-3687574c00f9', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b4175e1a-7da7-5994-8a76-6357229bfd65', 'c454973e-238f-5b10-b704-3687574c00f9', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5c471090-f7e2-5e4f-8a47-a8f3e830ae83', 'c454973e-238f-5b10-b704-3687574c00f9', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('55673466-9e86-5b86-a3d8-55d0f988284f', 'c454973e-238f-5b10-b704-3687574c00f9', 8, $md$H$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8badee13-272f-5536-b3ac-955686b52a7f', 'c454973e-238f-5b10-b704-3687574c00f9', 9, $md$I$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('960db505-9193-577f-99be-0c6fa078a8c8', '3602cf6f-47ee-5859-a2a3-0a77c24f491b', 8, 'MATCHING_INFORMATION', 'READING', 3, $md$### Question 8

Questions 6-10
Questions 6-10
The readings Passage has eleven paragraphs A-I
Which paragraph contains the following information?
Write the correct letter A-I, in boxes 6-10 on your answer sheet.
NB
You may use any letter more than once.
6
The uneven distribution of water around the world.
7
other factors regarding nature bothering people who make the policies.
8
Joint efforts needed to carry out the detailed solutions combined with various aspects.
9
No always-in-time match available between the requirements and the actual rainfall.
10
The lower limit of the amount of fresh water for a person to survive.

8 ____ Joint efforts needed to carry out the detailed solutions combined with various aspects.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('404d54f2-9d6b-5a0d-92c0-a5ad8402ad3d', '960db505-9193-577f-99be-0c6fa078a8c8', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bed6ad94-ea13-5a8a-a518-aac6daaecc60', '960db505-9193-577f-99be-0c6fa078a8c8', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c17ecb67-2093-59b7-82aa-081e2fb0e9f6', '960db505-9193-577f-99be-0c6fa078a8c8', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8ffe9768-05b4-58e9-b2e8-72036efdbb05', '960db505-9193-577f-99be-0c6fa078a8c8', 4, $md$D$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f8984686-e1bf-51be-b925-b74a467bea5b', '960db505-9193-577f-99be-0c6fa078a8c8', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('02ba67a5-0a99-5a3d-bfac-7002a227ab51', '960db505-9193-577f-99be-0c6fa078a8c8', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8bd470f8-3f02-5226-bf8e-0b21bfa70378', '960db505-9193-577f-99be-0c6fa078a8c8', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('717d5a43-9609-508d-a441-47ff4b0db629', '960db505-9193-577f-99be-0c6fa078a8c8', 8, $md$H$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('71f9e252-76d6-56ed-9632-c5318c43e81e', '960db505-9193-577f-99be-0c6fa078a8c8', 9, $md$I$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('ba3691aa-fd33-59e8-95d9-14de6acb40d7', '3602cf6f-47ee-5859-a2a3-0a77c24f491b', 9, 'MATCHING_INFORMATION', 'READING', 3, $md$### Question 9

Questions 6-10
Questions 6-10
The readings Passage has eleven paragraphs A-I
Which paragraph contains the following information?
Write the correct letter A-I, in boxes 6-10 on your answer sheet.
NB
You may use any letter more than once.
6
The uneven distribution of water around the world.
7
other factors regarding nature bothering people who make the policies.
8
Joint efforts needed to carry out the detailed solutions combined with various aspects.
9
No always-in-time match available between the requirements and the actual rainfall.
10
The lower limit of the amount of fresh water for a person to survive.

9 ____ No always-in-time match available between the requirements and the actual rainfall.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('325063dc-7f97-5a93-b045-fee04cabd305', 'ba3691aa-fd33-59e8-95d9-14de6acb40d7', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c2d4dc44-922e-560c-8d50-f1e496686c20', 'ba3691aa-fd33-59e8-95d9-14de6acb40d7', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('28622d71-5f0b-5729-9585-a58f47b659d5', 'ba3691aa-fd33-59e8-95d9-14de6acb40d7', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('aafb5af1-7969-5d77-9a07-fbd9d35ba76f', 'ba3691aa-fd33-59e8-95d9-14de6acb40d7', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('31628b0e-91b7-5a6b-b6b1-2791672e6229', 'ba3691aa-fd33-59e8-95d9-14de6acb40d7', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8aa389e5-39a5-5b69-b45e-5ba7ba5e46b0', 'ba3691aa-fd33-59e8-95d9-14de6acb40d7', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f0ac0280-7245-5bb0-bf0d-36c234b96792', 'ba3691aa-fd33-59e8-95d9-14de6acb40d7', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('81a3125a-3920-519f-804c-6179260475b7', 'ba3691aa-fd33-59e8-95d9-14de6acb40d7', 8, $md$H$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('75f8a0b5-b1b0-52e6-a14f-f04cd6922caf', 'ba3691aa-fd33-59e8-95d9-14de6acb40d7', 9, $md$I$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('14f5a374-4f3e-573e-bccf-9832ba2bb017', '3602cf6f-47ee-5859-a2a3-0a77c24f491b', 10, 'MATCHING_INFORMATION', 'READING', 4, $md$### Question 10

Questions 6-10
Questions 6-10
The readings Passage has eleven paragraphs A-I
Which paragraph contains the following information?
Write the correct letter A-I, in boxes 6-10 on your answer sheet.
NB
You may use any letter more than once.
6
The uneven distribution of water around the world.
7
other factors regarding nature bothering people who make the policies.
8
Joint efforts needed to carry out the detailed solutions combined with various aspects.
9
No always-in-time match available between the requirements and the actual rainfall.
10
The lower limit of the amount of fresh water for a person to survive.

10 ____ The lower limit of the amount of fresh water for a person to survive.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('17bfc61c-6d09-5c57-b84b-f5befd057b65', '14f5a374-4f3e-573e-bccf-9832ba2bb017', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1624613c-33e9-5ce1-b65f-4da18d63551a', '14f5a374-4f3e-573e-bccf-9832ba2bb017', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c6fe75a4-73ed-52a0-933a-de88b1afa6e1', '14f5a374-4f3e-573e-bccf-9832ba2bb017', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('00e8adf9-5a55-5d53-b79c-ef00782cca2b', '14f5a374-4f3e-573e-bccf-9832ba2bb017', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b36feebb-f3ec-5409-bef3-850387a29483', '14f5a374-4f3e-573e-bccf-9832ba2bb017', 5, $md$E$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5f2dee57-be05-5614-a8f3-7e56f2c30418', '14f5a374-4f3e-573e-bccf-9832ba2bb017', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('debb717d-5ace-5e80-9e79-c271586f2df2', '14f5a374-4f3e-573e-bccf-9832ba2bb017', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0438a7e1-f485-5718-8d46-19e85b7b6e5b', '14f5a374-4f3e-573e-bccf-9832ba2bb017', 8, $md$H$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('93a614cd-9206-5438-8cec-c2ee0f34efcf', '14f5a374-4f3e-573e-bccf-9832ba2bb017', 9, $md$I$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('05a49f39-a1e9-54fd-b5de-8a0708aed009', '3602cf6f-47ee-5859-a2a3-0a77c24f491b', 11, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 11

Questions 11-13
Questions 11-13
Complete the following summary of the paragraphs of Reading Passage, using
No More than Three words
from the Reading Passage for each answer. Write your answers in boxes
11
–
13
on your answer sheet.
Many severe problems like starvation and military actions etc result from the storage of water which sometimes for some areas seems
11
because of unavailability but other regions suffer another kind of scarcity for insufficient support.
12
of the rainfall can’t be achieved because of evaporation.
Some other parts form the
13
which can be used immediately. Water to irrigate the farmland takes a considerable amount along with the use for cities and industries and the extended need from the people involved.

Many severe problems like starvation and military actions etc result from the storage of water which sometimes for some areas seems 11 ____ because of unavailability but other regions suffer another kind of scarcity for insufficient support. 12 ____ of the rainfall can’t be achieved because of evaporation. Some other parts form the 13 ____ which can be used immediately. Water to irrigate the farmland takes a considerable amount along with the use for cities and industries and the extended need from the people involved.$md$, NULL, ARRAY['.*physical.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('06ab9ebd-3c0f-5e85-ab0b-c2fbbf68779f', '3602cf6f-47ee-5859-a2a3-0a77c24f491b', 12, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 12

Questions 11-13
Questions 11-13
Complete the following summary of the paragraphs of Reading Passage, using
No More than Three words
from the Reading Passage for each answer. Write your answers in boxes
11
–
13
on your answer sheet.
Many severe problems like starvation and military actions etc result from the storage of water which sometimes for some areas seems
11
because of unavailability but other regions suffer another kind of scarcity for insufficient support.
12
of the rainfall can’t be achieved because of evaporation.
Some other parts form the
13
which can be used immediately. Water to irrigate the farmland takes a considerable amount along with the use for cities and industries and the extended need from the people involved.

Many severe problems like starvation and military actions etc result from the storage of water which sometimes for some areas seems 11 ____ because of unavailability but other regions suffer another kind of scarcity for insufficient support. 12 ____ of the rainfall can’t be achieved because of evaporation. Some other parts form the 13 ____ which can be used immediately. Water to irrigate the farmland takes a considerable amount along with the use for cities and industries and the extended need from the people involved.$md$, NULL, ARRAY['.*physical.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('8e9549ca-9aa7-5873-bd5a-93b0063e550e', '3602cf6f-47ee-5859-a2a3-0a77c24f491b', 13, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 13

Questions 11-13
Questions 11-13
Complete the following summary of the paragraphs of Reading Passage, using
No More than Three words
from the Reading Passage for each answer. Write your answers in boxes
11
–
13
on your answer sheet.
Many severe problems like starvation and military actions etc result from the storage of water which sometimes for some areas seems
11
because of unavailability but other regions suffer another kind of scarcity for insufficient support.
12
of the rainfall can’t be achieved because of evaporation.
Some other parts form the
13
which can be used immediately. Water to irrigate the farmland takes a considerable amount along with the use for cities and industries and the extended need from the people involved.

Some other parts form the 13 ____ which can be used immediately. Water to irrigate the farmland takes a considerable amount along with the use for cities and industries and the extended need from the people involved.$md$, NULL, ARRAY['.*blue.*water.*']);

COMMIT;
