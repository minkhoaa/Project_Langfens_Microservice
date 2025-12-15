BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-amateur-naturalists-1029'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-amateur-naturalists-1029';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-amateur-naturalists-1029';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-amateur-naturalists-1029';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('c434d1c8-62e1-5530-b7f0-948f284bcc3e', 'ielts-reading-amateur-naturalists-1029', $t$Amateur Naturalists$t$, $md$## Amateur Naturalists

Nguồn:
- Test: https://mini-ielts.com/1029/reading/amateur-naturalists
- Solution: https://mini-ielts.com/1029/view-solution/reading/amateur-naturalists$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('51bfef9f-7987-5b08-810b-5266d2158153', 'c434d1c8-62e1-5530-b7f0-948f284bcc3e', 1, $t$Reading — Amateur Naturalists$t$, $md$Read the passage and answer questions **1–14**.

### Passage: Amateur Naturalists

From the results of an annual Alaskan betting contest to sightings of migra­tory birds, ecologists are using a wealth of unusual data to predict the impact of climate change.

A Tim Sparks slides a small leather-bound notebook out of an envelope. The book's yellowing pages contain bee-keeping notes made between 1941 and 1969 by the late Walter Coates of Kilworth, Leicestershire. He adds it to his growing pile of local journals, birdwatchers' lists and gardening diaries. "We're uncovering about one major new record each month," he says, "I still get surprised." Around two centuries before Coates, Robert Marsham, a landowner from Norfolk in the east of England, began recording the life cycles of plants and animals on his estate - when the first wood anemones flowered, the dates on which the oaks burst into leaf and the rooks began nesting. Successive Marshams continued compiling these notes for 211 years.

B Today, such records are being put to uses that their authors could not pos­sibly have expected. These data sets, and others like them, are proving in­valuable to ecologists interested in the timing of biological events, or phen­ology. By combining the records with climate data, researchers can reveal how, for example, changes in temperature affect the arrival of spring, al­lowing ecologists to make improved predictions about the impact of climate change. A small band of researchers is combing through hundreds of years of records taken by thousands of amateur naturalists. And more systematic projects have also started up, producing an overwhelming response. "The amount of interest is almost frightening," says Sparks, a climate researcher at the Centre for Ecology and Hydrology in Monks Wood, Cambridgeshire.

C Sparks first became aware of the army of "closet phenologists”, as he de­scribes them, when a retiring colleague gave him the Marsham records . He now spends much of his time following leads from one historical data set to another. As news of his quest spreads, people tip him off to other historical records, and more amateur phenologists come out of their closets. The Brit­ish devotion to recording and collecting makes his job easier - one man from Kent sent him 30 years' worth of kitchen calendars, on which he had noted the date that his neighbour's magnolia tree flowered.

D Other researchers have unearthed data from equally odd sources. Rafe Sa­garin, an ecologist at Stanford University in California, recently studied records of a betting contest in which participants attempt to guess the exact time at which a specially erected wooden tripod will fall through the surface of a thawing river . The competition has taken place annually on the Tenana River in Alaska since 1917, and analysis of the results showed that the thaw now arrives five days earlier than it did when the contest began.

E Overall, such records have helped to show that, compared with 20 years ago, a raft of natural events now occur earlier across much of the northern hemi­sphere, from the opening of leaves to the return of birds from migration and the emergence of butterflies from hibernation. The data can also hint at how nature will change in the future. Together with models of climate change, amateurs' records could help guide conservation. Terry Root, an ecologist at the University of Michigan in Ann Arbor, has collected birdwatchers' counts of wildfowl taken between 1955 and 1996 on seasonal ponds in the Ameri­can Midwest and combined them with climate data and models of future warming. Her analysis shows that the increased droughts that the models predict could halve the breeding populations at the ponds. "The number of waterfowl in North America will most probably drop significantly with global warming," she says.

F But not all professionals are happy to use amateur data. " A lot of scientists won't touch them, they say they're too full of problems ," says Root. Because different observers can have different ideas of what constitutes, for example, an open snowdrop. "The biggest concern with ad hoc observations is how carefully and systematically they were taken," says Mark Schwartz of the University of Wisconsin, Milwaukee, who studies the interactions between plants and climate. "We need to know pretty precisely what a person's been observing - if they just say 'I noted when the leaves came out', it might not be that useful." Measuring the onset of autumn can be particularly problem­atic because deciding when leaves change colour is a more subjective pro­cess than noting when they appear.

G Overall, most phenologists are positive about the contribution that ama­teurs can make. "They get at the raw power of science: careful observation of the natural world ," says Sagarin. But the professionals also acknowledge the need for careful quality control. Root, for example, tries to gauge the quality of an amateur archive by interviewing its collector. "You always have to worry - things as trivial as vacations can affect measurement. I disregard a lot of records because they're not rigorous enough," she says. Others suggest that the right statistics can iron out some of the problems with amateur data. Together with colleagues at Wageningen University in the Netherlands, environmental scientist Arnold van Vliet is developing statistical techniques to account for the uncertainty in amateur phenological data . With the en­thusiasm of amateur phenologists evident from past records, professional researchers are now trying to create standardised recording schemes for fu­ture efforts. They hope that well-designed studies will generate a volume of observations large enough to drown out the idiosyncrasies of individual recorders. The data are cheap to collect, and can provide breadth in space, time and range of species. "It's very difficult to collect data on a large geo­graphical scale without enlisting an army of observers," says Root.

H Phenology also helps to drive home messages about climate change. " Be­cause the public understand these records, they accept them ," says Sparks. It can also illustrate potentially unpleasant consequences, he adds, such as the finding that more rat infestations are reported to local councils in warmer years. And getting people involved is great for public relations. " People are thrilled to think that the data they've been collecting as a hobby can be used for something scientific - it empowers them ," says Root.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('15c2dca3-b807-5402-b53d-309147bd611a', '51bfef9f-7987-5b08-810b-5266d2158153', 1, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 1

Questions 1-7
Questions 1-7
Reading Passage has eight paragraphs
A-H
.
Which paragraph contains the following information?
Write the correct letter
A-H
in boxes
1-7
on your answer sheet.
1
The definition of phenology
Locate
2
How Sparks first became aware of amateur records
Locate
3
How people reacted to their involvement in data collection
Locate
4
The necessity to encourage amateur data collection
Locate
5
A description of using amateur records to make predictions
Locate
6
Records of a competition providing clues to climate change
Locate
7
A description of a very old record compiled by generations of amateur naturalists
Locate

1 ____ The definition of phenology Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('69a151c0-d76f-5889-a561-2e5190993342', '15c2dca3-b807-5402-b53d-309147bd611a', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2ae82ced-a5cc-5a93-bdd3-bcc7cd5ab3fb', '15c2dca3-b807-5402-b53d-309147bd611a', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9307923a-3205-5175-bf05-d68e5c7cb644', '15c2dca3-b807-5402-b53d-309147bd611a', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ad5243ef-5085-5004-b45c-136baeda5541', '15c2dca3-b807-5402-b53d-309147bd611a', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8998d736-28fb-5d86-8b51-a6aa639764d7', '15c2dca3-b807-5402-b53d-309147bd611a', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('691f8683-44b8-5206-91be-0159c900c4dc', '15c2dca3-b807-5402-b53d-309147bd611a', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ad2e35b8-ad87-58c2-a8c6-f9ad73ab4332', '15c2dca3-b807-5402-b53d-309147bd611a', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0c1427fd-87af-5df2-99dd-0a2391d4e0e3', '15c2dca3-b807-5402-b53d-309147bd611a', 8, $md$H$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('737ac40e-e4fb-52b2-b7cb-972dcd5dfbf8', '51bfef9f-7987-5b08-810b-5266d2158153', 2, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 2

Questions 1-7
Questions 1-7
Reading Passage has eight paragraphs
A-H
.
Which paragraph contains the following information?
Write the correct letter
A-H
in boxes
1-7
on your answer sheet.
1
The definition of phenology
Locate
2
How Sparks first became aware of amateur records
Locate
3
How people reacted to their involvement in data collection
Locate
4
The necessity to encourage amateur data collection
Locate
5
A description of using amateur records to make predictions
Locate
6
Records of a competition providing clues to climate change
Locate
7
A description of a very old record compiled by generations of amateur naturalists
Locate

2 ____ How Sparks first became aware of amateur records Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('77553f99-5cda-5f46-83c9-b7aa8f41fee1', '737ac40e-e4fb-52b2-b7cb-972dcd5dfbf8', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2106623f-f3d4-5605-9603-70105e37c7ae', '737ac40e-e4fb-52b2-b7cb-972dcd5dfbf8', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3196fae2-0bf2-50dc-8976-026b0c0817b3', '737ac40e-e4fb-52b2-b7cb-972dcd5dfbf8', 3, $md$C$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3cd0706e-cd87-53cb-9974-0ef32ba70c92', '737ac40e-e4fb-52b2-b7cb-972dcd5dfbf8', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('95918f92-75ef-52e5-a72c-69e57dad7652', '737ac40e-e4fb-52b2-b7cb-972dcd5dfbf8', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1c5255f4-cca9-5faf-8447-f4d58fcd0f84', '737ac40e-e4fb-52b2-b7cb-972dcd5dfbf8', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('93bc4056-7740-521d-a791-bc23dd90d4e3', '737ac40e-e4fb-52b2-b7cb-972dcd5dfbf8', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9533d312-72b1-590d-852e-8837ad0b050d', '737ac40e-e4fb-52b2-b7cb-972dcd5dfbf8', 8, $md$H$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('b7e5107d-3ac2-533a-aae1-2bcbfefafbe7', '51bfef9f-7987-5b08-810b-5266d2158153', 3, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 3

Questions 1-7
Questions 1-7
Reading Passage has eight paragraphs
A-H
.
Which paragraph contains the following information?
Write the correct letter
A-H
in boxes
1-7
on your answer sheet.
1
The definition of phenology
Locate
2
How Sparks first became aware of amateur records
Locate
3
How people reacted to their involvement in data collection
Locate
4
The necessity to encourage amateur data collection
Locate
5
A description of using amateur records to make predictions
Locate
6
Records of a competition providing clues to climate change
Locate
7
A description of a very old record compiled by generations of amateur naturalists
Locate

3 ____ How people reacted to their involvement in data collection Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('24b1652c-ea45-5e9e-889d-87a9ef6a714e', 'b7e5107d-3ac2-533a-aae1-2bcbfefafbe7', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7ed00921-79e7-5a22-895e-5c820f5e9ece', 'b7e5107d-3ac2-533a-aae1-2bcbfefafbe7', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('08dbf824-eea9-5792-85d4-ca252495d001', 'b7e5107d-3ac2-533a-aae1-2bcbfefafbe7', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('54bc1d1d-65db-547d-96bd-bed0ab0d9df7', 'b7e5107d-3ac2-533a-aae1-2bcbfefafbe7', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('01e32a00-5133-58d8-81da-b2a49b948d20', 'b7e5107d-3ac2-533a-aae1-2bcbfefafbe7', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('61b64e66-e8e0-5835-a968-397c8b945ff6', 'b7e5107d-3ac2-533a-aae1-2bcbfefafbe7', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('defb4bc0-a2dd-5258-b745-2b33bf398589', 'b7e5107d-3ac2-533a-aae1-2bcbfefafbe7', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bb6ad74c-8255-5fae-be60-4619517a5ae2', 'b7e5107d-3ac2-533a-aae1-2bcbfefafbe7', 8, $md$H$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('8d3cc554-bb75-5bc7-a252-5cc98c9aead2', '51bfef9f-7987-5b08-810b-5266d2158153', 4, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 4

Questions 1-7
Questions 1-7
Reading Passage has eight paragraphs
A-H
.
Which paragraph contains the following information?
Write the correct letter
A-H
in boxes
1-7
on your answer sheet.
1
The definition of phenology
Locate
2
How Sparks first became aware of amateur records
Locate
3
How people reacted to their involvement in data collection
Locate
4
The necessity to encourage amateur data collection
Locate
5
A description of using amateur records to make predictions
Locate
6
Records of a competition providing clues to climate change
Locate
7
A description of a very old record compiled by generations of amateur naturalists
Locate

4 ____ The necessity to encourage amateur data collection Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('95ffea18-c519-52a6-8162-ae28a1ef5d9b', '8d3cc554-bb75-5bc7-a252-5cc98c9aead2', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('978fb0e9-0a5c-52c0-8226-6f72056d975d', '8d3cc554-bb75-5bc7-a252-5cc98c9aead2', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9a02330f-b0a9-5bc9-b72b-5d04d4a72c06', '8d3cc554-bb75-5bc7-a252-5cc98c9aead2', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3b6538f3-063c-54aa-b1db-3d294d4844ac', '8d3cc554-bb75-5bc7-a252-5cc98c9aead2', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e0368904-acf3-5ee5-9712-a458e40abd2d', '8d3cc554-bb75-5bc7-a252-5cc98c9aead2', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cff360f8-258c-59bf-8d45-b8b50376282e', '8d3cc554-bb75-5bc7-a252-5cc98c9aead2', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1eae2c6e-3692-5c21-a48a-883a7e614320', '8d3cc554-bb75-5bc7-a252-5cc98c9aead2', 7, $md$G$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d9191791-8beb-5cd1-9f5b-4d91d5589239', '8d3cc554-bb75-5bc7-a252-5cc98c9aead2', 8, $md$H$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('be4622e9-e708-59da-867e-94fab56e98b6', '51bfef9f-7987-5b08-810b-5266d2158153', 5, 'MATCHING_INFORMATION', 'READING', 3, $md$### Question 5

Questions 1-7
Questions 1-7
Reading Passage has eight paragraphs
A-H
.
Which paragraph contains the following information?
Write the correct letter
A-H
in boxes
1-7
on your answer sheet.
1
The definition of phenology
Locate
2
How Sparks first became aware of amateur records
Locate
3
How people reacted to their involvement in data collection
Locate
4
The necessity to encourage amateur data collection
Locate
5
A description of using amateur records to make predictions
Locate
6
Records of a competition providing clues to climate change
Locate
7
A description of a very old record compiled by generations of amateur naturalists
Locate

5 ____ A description of using amateur records to make predictions Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('36dda70a-7902-5304-8724-ac73c19c7b77', 'be4622e9-e708-59da-867e-94fab56e98b6', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('042f3e8c-fbb8-5ea6-a208-256b702a5118', 'be4622e9-e708-59da-867e-94fab56e98b6', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5d81299c-e98d-5f18-ad07-455c3b1df797', 'be4622e9-e708-59da-867e-94fab56e98b6', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('60a93f91-de80-5721-bc49-a80dc27c07cf', 'be4622e9-e708-59da-867e-94fab56e98b6', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8dcab648-2c10-56eb-9969-7c82fa62f363', 'be4622e9-e708-59da-867e-94fab56e98b6', 5, $md$E$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4bb1496b-8dae-5ca5-a92e-6a1eb257e9cf', 'be4622e9-e708-59da-867e-94fab56e98b6', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ac0468ed-0bb3-5e1d-b01d-f51302a3fc57', 'be4622e9-e708-59da-867e-94fab56e98b6', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7e62b05e-304a-5752-9e77-2de6090de944', 'be4622e9-e708-59da-867e-94fab56e98b6', 8, $md$H$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('ebfb8ff9-c901-5ca0-8143-5b4429035f93', '51bfef9f-7987-5b08-810b-5266d2158153', 6, 'MATCHING_INFORMATION', 'READING', 3, $md$### Question 6

Questions 1-7
Questions 1-7
Reading Passage has eight paragraphs
A-H
.
Which paragraph contains the following information?
Write the correct letter
A-H
in boxes
1-7
on your answer sheet.
1
The definition of phenology
Locate
2
How Sparks first became aware of amateur records
Locate
3
How people reacted to their involvement in data collection
Locate
4
The necessity to encourage amateur data collection
Locate
5
A description of using amateur records to make predictions
Locate
6
Records of a competition providing clues to climate change
Locate
7
A description of a very old record compiled by generations of amateur naturalists
Locate

6 ____ Records of a competition providing clues to climate change Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c60585ed-a56e-51a9-9466-bb3f2d9b7101', 'ebfb8ff9-c901-5ca0-8143-5b4429035f93', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('14cadbeb-1a4b-56b8-8d8a-12d3f96f3afd', 'ebfb8ff9-c901-5ca0-8143-5b4429035f93', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('01cd263b-d1a8-5d98-9443-a88fe54016c1', 'ebfb8ff9-c901-5ca0-8143-5b4429035f93', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cbbed395-34fd-5596-97a1-2506fe72e25a', 'ebfb8ff9-c901-5ca0-8143-5b4429035f93', 4, $md$D$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4c6ba884-3cfe-5839-80e2-e2b1680234f8', 'ebfb8ff9-c901-5ca0-8143-5b4429035f93', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('29ffad93-26aa-597a-bc86-bba080999755', 'ebfb8ff9-c901-5ca0-8143-5b4429035f93', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4b844f9c-7c49-582e-b5d7-37f3399b6369', 'ebfb8ff9-c901-5ca0-8143-5b4429035f93', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6d334ece-b3ac-5437-a964-2cf48a6b4cde', 'ebfb8ff9-c901-5ca0-8143-5b4429035f93', 8, $md$H$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('5991b1be-0640-56b4-b5fa-bc4e0d89864c', '51bfef9f-7987-5b08-810b-5266d2158153', 7, 'MATCHING_INFORMATION', 'READING', 3, $md$### Question 7

Questions 1-7
Questions 1-7
Reading Passage has eight paragraphs
A-H
.
Which paragraph contains the following information?
Write the correct letter
A-H
in boxes
1-7
on your answer sheet.
1
The definition of phenology
Locate
2
How Sparks first became aware of amateur records
Locate
3
How people reacted to their involvement in data collection
Locate
4
The necessity to encourage amateur data collection
Locate
5
A description of using amateur records to make predictions
Locate
6
Records of a competition providing clues to climate change
Locate
7
A description of a very old record compiled by generations of amateur naturalists
Locate

7 ____ A description of a very old record compiled by generations of amateur naturalists Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3d2bbac8-ba35-5648-88d0-0b4ca0b3ccb2', '5991b1be-0640-56b4-b5fa-bc4e0d89864c', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cc59c5fe-e65c-5999-b650-24d236ef37dd', '5991b1be-0640-56b4-b5fa-bc4e0d89864c', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('80ec1300-abe2-5d5c-80af-f29f3651086f', '5991b1be-0640-56b4-b5fa-bc4e0d89864c', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('692ea71e-3741-55d1-b6ee-a9ad599cc4a4', '5991b1be-0640-56b4-b5fa-bc4e0d89864c', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f58ca155-6d02-5a40-a18c-f6029cd42b5c', '5991b1be-0640-56b4-b5fa-bc4e0d89864c', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f693fcb2-11d6-5719-8a83-69b9b870b25d', '5991b1be-0640-56b4-b5fa-bc4e0d89864c', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0af67dfb-5b13-58cc-8430-f1bf7610fac7', '5991b1be-0640-56b4-b5fa-bc4e0d89864c', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d657b3df-7785-5e0c-9569-d66d6bc7db77', '5991b1be-0640-56b4-b5fa-bc4e0d89864c', 8, $md$H$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('60b3e85f-179f-5e1f-8f8f-29e40489b996', '51bfef9f-7987-5b08-810b-5266d2158153', 8, 'FORM_COMPLETION', 'READING', 3, $md$### Question 8

Questions 8-10
Questions 8-10
Complete the sentences below with
NO MORE THAN TWO WORDS
from the passage for each answer.
Write your answers in boxes
8-10
on your answer sheet.
8
Walter Coates’s records largely contain the information of
Locate
9
Robert Marsham is famous for recording the
of animals and plants on his land.
Locate
10
According to some phenologists, global warming may cause the number of waterfowl in North America to drop significantly due to increased
Locate

8 Walter Coates’s records largely contain the information of ____ Locate$md$, NULL, ARRAY['.*bee.*keeping.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('063923a8-9e7a-50f4-9a11-ad96b33d0fdd', '51bfef9f-7987-5b08-810b-5266d2158153', 9, 'FORM_COMPLETION', 'READING', 3, $md$### Question 9

Questions 8-10
Questions 8-10
Complete the sentences below with
NO MORE THAN TWO WORDS
from the passage for each answer.
Write your answers in boxes
8-10
on your answer sheet.
8
Walter Coates’s records largely contain the information of
Locate
9
Robert Marsham is famous for recording the
of animals and plants on his land.
Locate
10
According to some phenologists, global warming may cause the number of waterfowl in North America to drop significantly due to increased
Locate

9 Robert Marsham is famous for recording the ____ of animals and plants on his land. Locate$md$, NULL, ARRAY['.*life.*cycles.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('f72ba663-f052-5795-bdf9-5b0f49f27ff6', '51bfef9f-7987-5b08-810b-5266d2158153', 10, 'FORM_COMPLETION', 'READING', 4, $md$### Question 10

Questions 8-10
Questions 8-10
Complete the sentences below with
NO MORE THAN TWO WORDS
from the passage for each answer.
Write your answers in boxes
8-10
on your answer sheet.
8
Walter Coates’s records largely contain the information of
Locate
9
Robert Marsham is famous for recording the
of animals and plants on his land.
Locate
10
According to some phenologists, global warming may cause the number of waterfowl in North America to drop significantly due to increased
Locate

10 According to some phenologists, global warming may cause the number of waterfowl in North America to drop significantly due to increased ____ Locate$md$, NULL, ARRAY['.*droughts.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('1f99c6ad-460b-5cae-bbaf-185b3955fc91', '51bfef9f-7987-5b08-810b-5266d2158153', 11, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 11

Questions 11-14
Questions 11-14
Choose the correct letter
A, B, C
or
D
.
Write your answers in boxes
11-14
on your answer sheet.
11
Why do a lot of scientists discredit the data collected by amateurs?
A
Scientific methods were not used in data collection.
B
Amateur observers are not careful in recording their data.
C
Amateur data is not reliable.
D
Amateur data is produced by wrong candidates.
Locate
12
Mark Schwartz used the example of leaves to illustrate that
A
amateur records can’t be used.
B
amateur records are always unsystematic.
C
the colour change of leaves is hard to observe.
D
valuable information is often precise.
Locate
13
How do the scientists suggest amateur data should be used?
A
Using improved methods
B
Being more careful in observation
C
Using raw materials
D
Applying statistical techniques in data collection
Locate
14
What’s the implication of phenology for ordinary people?
A
It empowers the public.
B
It promotes public relations.
C
It warns people of animal infestation.
D
It raises awareness about climate change in the public.
Locate

Choose the correct letter A, B, C or D .$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('263941ca-9857-5d31-93e6-775660aa58fe', '51bfef9f-7987-5b08-810b-5266d2158153', 12, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 12

Questions 11-14
Questions 11-14
Choose the correct letter
A, B, C
or
D
.
Write your answers in boxes
11-14
on your answer sheet.
11
Why do a lot of scientists discredit the data collected by amateurs?
A
Scientific methods were not used in data collection.
B
Amateur observers are not careful in recording their data.
C
Amateur data is not reliable.
D
Amateur data is produced by wrong candidates.
Locate
12
Mark Schwartz used the example of leaves to illustrate that
A
amateur records can’t be used.
B
amateur records are always unsystematic.
C
the colour change of leaves is hard to observe.
D
valuable information is often precise.
Locate
13
How do the scientists suggest amateur data should be used?
A
Using improved methods
B
Being more careful in observation
C
Using raw materials
D
Applying statistical techniques in data collection
Locate
14
What’s the implication of phenology for ordinary people?
A
It empowers the public.
B
It promotes public relations.
C
It warns people of animal infestation.
D
It raises awareness about climate change in the public.
Locate

Choose the correct letter A, B, C or D .$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('3d07e8bc-319e-5efd-a955-6734e6b90c32', '51bfef9f-7987-5b08-810b-5266d2158153', 13, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 13

Questions 11-14
Questions 11-14
Choose the correct letter
A, B, C
or
D
.
Write your answers in boxes
11-14
on your answer sheet.
11
Why do a lot of scientists discredit the data collected by amateurs?
A
Scientific methods were not used in data collection.
B
Amateur observers are not careful in recording their data.
C
Amateur data is not reliable.
D
Amateur data is produced by wrong candidates.
Locate
12
Mark Schwartz used the example of leaves to illustrate that
A
amateur records can’t be used.
B
amateur records are always unsystematic.
C
the colour change of leaves is hard to observe.
D
valuable information is often precise.
Locate
13
How do the scientists suggest amateur data should be used?
A
Using improved methods
B
Being more careful in observation
C
Using raw materials
D
Applying statistical techniques in data collection
Locate
14
What’s the implication of phenology for ordinary people?
A
It empowers the public.
B
It promotes public relations.
C
It warns people of animal infestation.
D
It raises awareness about climate change in the public.
Locate

Choose the correct letter A, B, C or D .$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('51258938-63ec-5a5e-ba0d-d5d573cf5edc', '51bfef9f-7987-5b08-810b-5266d2158153', 14, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 14

Questions 11-14
Questions 11-14
Choose the correct letter
A, B, C
or
D
.
Write your answers in boxes
11-14
on your answer sheet.
11
Why do a lot of scientists discredit the data collected by amateurs?
A
Scientific methods were not used in data collection.
B
Amateur observers are not careful in recording their data.
C
Amateur data is not reliable.
D
Amateur data is produced by wrong candidates.
Locate
12
Mark Schwartz used the example of leaves to illustrate that
A
amateur records can’t be used.
B
amateur records are always unsystematic.
C
the colour change of leaves is hard to observe.
D
valuable information is often precise.
Locate
13
How do the scientists suggest amateur data should be used?
A
Using improved methods
B
Being more careful in observation
C
Using raw materials
D
Applying statistical techniques in data collection
Locate
14
What’s the implication of phenology for ordinary people?
A
It empowers the public.
B
It promotes public relations.
C
It warns people of animal infestation.
D
It raises awareness about climate change in the public.
Locate

Choose the correct letter A, B, C or D .$md$, NULL);

COMMIT;
