BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-computer-provides-more-questions-than-answers-1346'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-computer-provides-more-questions-than-answers-1346';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-computer-provides-more-questions-than-answers-1346';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-computer-provides-more-questions-than-answers-1346';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('f262c23b-ee2a-55dc-bdef-8abf9b0e3449', 'ielts-reading-computer-provides-more-questions-than-answers-1346', $t$Computer Provides More Questions Than Answers$t$, $md$## Computer Provides More Questions Than Answers

Nguồn:
- Test: https://mini-ielts.com/1346/reading/computer-provides-more-questions-than-answers
- Solution: https://mini-ielts.com/1346/view-solution/reading/computer-provides-more-questions-than-answers$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('016d95a9-b0a2-5e6f-839e-f6bf54993e33', 'f262c23b-ee2a-55dc-bdef-8abf9b0e3449', 1, $t$Reading — Computer Provides More Questions Than Answers$t$, $md$Read the passage and answer questions **1–13**.

### Passage: Computer Provides More Questions Than Answers

A. The island of Antikythera lies 18 miles north of Crete, where the Aegean Sea meets the Mediterranean. Currents there can make shipping treacherous and one ship bound for ancient Rome never made it. The ship that sank there was a giant cargo vessel measuring nearly 500 feet long. It came to rest about 200 feet below the surface, where it stayed for more than 2,000 years until divers looking for sponges discovered the wreck a little more than a century ago.

B. Inside the hull were a number of bronze and marble statues. From the look of things, the ship seemed to be carrying luxury items, probably made in various Greek islands and bound for wealthy patrons in the growing Roman Empire. The statues were retrieved, along with a lot of other unimportant stuff, and stored. Nine months later, an enterprising archaeologist cleared off a layer of organic material from one of the pieces of junk and found that it looked like a gearwheel. It had inscriptions in Greek characters and seemed to have something to do with astronomy.

C. That piece of “ Junk” went on to become the most celebrated find from the shipwreck; it is displayed at the National Archaeological Museum of Athens. Research has shown that the wheel was part of a device so sophisticated that its complexity would not be matched for a thousand years — it was also the world’s first known analogue computer. The device is so famous that an international conference organized in Athens a couple of weeks ago had only one subject: the Antikythera Mechanism.

D. Every discovery about the device has raised new questions. Who built the device, and for what purpose? Why did the technology behind it disappear for the next thousand years? What does the device tell us about ancient Greek culture? And does the marvelous construction, and the precise knowledge of the movement of the sun and moon and Earth that it implies, tell us how the ancients grappled with ideas about determinism and human destiny?

E. “We have gear trains from the 9th century in Baghdad used for simpler displays of the solar and lunar motions relative to one another — they use eight gears,’ said Frangois Charette, a historian of science in Germany who wrote an editorial accompanying a new study of the mechanism two weeks ago in the journal Nature. “ In this case, we have more than 30 gears. To see it on a computer animation makes it mind-boggling. There is no doubt it was a technological masterpiece.”

F. The device was probably built between 100 and 140 BC, and the understanding of astronomy it displays seems to have been based on knowledge developed by the Babylonians around 300-700 BC, said Mike Edmunds, a professor of astrophysics at Cardiff University in Britain. He led a research team that reconstructed what the gear mechanism would have looked like by using advanced three- dimensional-imaging technology. The group also decoded a number of the inscriptions. The mechanism explores the relationship between lunar months __ the time it takes for the moon to cycle through its phases, say, full moon to the full moon -­and calendar years. The gears had to be cut precisely to reflect this complex relationship; 19 calendar years equal 235 lunar months.

G. By turning the gear mechanism, which included what Edmunds called a beautiful system of epicyclic gears that factored in the elliptical orbit of the moon, a person could check what the sky would have looked like on a date in the past, or how it would appear in the future. The mechanism was encased in a box with doors in front and back covered with inscriptions — a sort of instruction manual. Inside the front door were pointers indicating the date and the position of the sun, moon, and zodiac, while opening the back door revealed the relationship between calendar years and lunar months, and a mechanism to predict eclipses.

H. “If they needed to know when eclipses would occur, and this related to the rising and setting of stars and related them to dates and religious experiences, the mechanism would directly help，,” said Yanis Bitsakis, a physicist at the University of Athens who co-wrote the Nature paper. “It is a mechanical computer. You turn the handle and you have a date on the front.” Building it would have been expensive and required the interaction of astronomer, engineers, intellectuals, and craftspeople. Charette said the device overturned conventional ideas that the ancient Greeks were primarily ivory tower thinkers who did not deign to muddy their hands with technical stuff. It is a reminder, he said, that while the study of history often focuses on written texts, they can tell us only a fraction of what went on at a particular time.

I. Imagine a future historian encountering philosophy texts written in our time ~ and an aircraft engine. The books would tell that researcher what a few scholars were thinking today, but the engine would give them a far better window into how technology influenced our everyday lives. Charette said it was unlikely that the device was used by practitioners of astrology, then still in its infancy. More likely, he said, it was bound for a mantelpiece in some rich Roman’s home. Given that astronomers of the time already knew how to calculate the positions of the sun and the moon and to predict eclipses without the device, it would have been the equivalent of a device built for a planetarium today __ something to spur popular interest or at least claim bragging rights.

J. Why was the technology that went into the device lost? “The time this was built, the jackboot of Rome was coming through,” Edmunds said. “The Romans were good at town planning and sanitation but were not known for their interest in science.” The fact that the device was so complex, and that it was being shipped with a number of other luxury items, tells Edmunds that it is very unlikely to have been the one ever made. “Its sophistication is such that it can’t have been the only one,” Edmunds said. “There must have been a tradition of making them. We’re always hopeful a better one will surface.” Indeed, he said, he hopes that his study and the renewed interest in the Antikythera Mechanism will prompt second looks by both amateurs and professionals around the world. “The archaeological world may look in their cupboards and maybe say, That isn’t a bit of rusty old metal in the cupboard.”$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('78526edc-ba8b-5460-b654-9e5ad71b4d56', '016d95a9-b0a2-5e6f-839e-f6bf54993e33', 1, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 1

Questions 1-5
Questions 1-5
The Reading Passage has ten paragraphs
A-J
Which paragraph contains the following information?
Write the correct letter
A-J
, in boxes
1-5
on your answer sheet.
1
The content inside the wrecked ship
2
Ancient astronomers and craftsman might involve
3
The location of the Antikythera Mechanism
4
Details of how it was found
5
Appearance and structure of the mechanism

1 ____ The content inside the wrecked ship$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('75ac7a90-7568-57c2-abfa-840c12b1a277', '78526edc-ba8b-5460-b654-9e5ad71b4d56', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('761056e2-adde-5786-a682-5e6990eb87c1', '78526edc-ba8b-5460-b654-9e5ad71b4d56', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('668cb4e2-d325-552b-974a-299245252ce1', '78526edc-ba8b-5460-b654-9e5ad71b4d56', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c315b0da-cb9f-5fad-8db9-1f33ecbc54e7', '78526edc-ba8b-5460-b654-9e5ad71b4d56', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2212ed79-b958-5529-86ef-acf70ef14a88', '78526edc-ba8b-5460-b654-9e5ad71b4d56', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f3497a47-eb4a-55a1-994e-3b66c368fa9b', '78526edc-ba8b-5460-b654-9e5ad71b4d56', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6d275e37-9bcf-5b34-8f3c-9ffc2c0615a4', '78526edc-ba8b-5460-b654-9e5ad71b4d56', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('75fc9791-9c3a-5329-a8bb-6a45a24c84ab', '78526edc-ba8b-5460-b654-9e5ad71b4d56', 8, $md$H$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ad748122-534b-5f46-97ef-7bd4097d7fb5', '78526edc-ba8b-5460-b654-9e5ad71b4d56', 9, $md$I$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7c6c0eb1-803c-5b77-b284-520e5c99d466', '78526edc-ba8b-5460-b654-9e5ad71b4d56', 10, $md$J$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('bbd04a1d-f6cd-53b2-af1e-049bc6585b77', '016d95a9-b0a2-5e6f-839e-f6bf54993e33', 2, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 2

Questions 1-5
Questions 1-5
The Reading Passage has ten paragraphs
A-J
Which paragraph contains the following information?
Write the correct letter
A-J
, in boxes
1-5
on your answer sheet.
1
The content inside the wrecked ship
2
Ancient astronomers and craftsman might involve
3
The location of the Antikythera Mechanism
4
Details of how it was found
5
Appearance and structure of the mechanism

2 ____ Ancient astronomers and craftsman might involve$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('46ca4ead-02aa-5140-aa53-d4723179493b', 'bbd04a1d-f6cd-53b2-af1e-049bc6585b77', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7d5cc1d4-742b-5a34-a1a3-a9f66ebadf63', 'bbd04a1d-f6cd-53b2-af1e-049bc6585b77', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1e88725a-27ca-5828-b372-19470bf0c67c', 'bbd04a1d-f6cd-53b2-af1e-049bc6585b77', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3eb1df0e-4bb6-5d78-8bf4-387a1b81b93e', 'bbd04a1d-f6cd-53b2-af1e-049bc6585b77', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5d3964d5-2cf0-572d-b5c4-0a3d50580268', 'bbd04a1d-f6cd-53b2-af1e-049bc6585b77', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bdaa13e0-d183-5800-a7ea-6886c6337f1e', 'bbd04a1d-f6cd-53b2-af1e-049bc6585b77', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a8e0b04e-6eee-5852-b3b8-6109429c851a', 'bbd04a1d-f6cd-53b2-af1e-049bc6585b77', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8611e80b-47f4-5f24-81ed-cda0c70aad92', 'bbd04a1d-f6cd-53b2-af1e-049bc6585b77', 8, $md$H$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3f59e3ec-72a0-5ee3-8c5f-d6e1760624af', 'bbd04a1d-f6cd-53b2-af1e-049bc6585b77', 9, $md$I$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4b0cafca-e2e5-574c-8af6-1a6bdc802b1b', 'bbd04a1d-f6cd-53b2-af1e-049bc6585b77', 10, $md$J$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('00c988b1-a4fa-524b-b6b4-d5541d332fb6', '016d95a9-b0a2-5e6f-839e-f6bf54993e33', 3, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 3

Questions 1-5
Questions 1-5
The Reading Passage has ten paragraphs
A-J
Which paragraph contains the following information?
Write the correct letter
A-J
, in boxes
1-5
on your answer sheet.
1
The content inside the wrecked ship
2
Ancient astronomers and craftsman might involve
3
The location of the Antikythera Mechanism
4
Details of how it was found
5
Appearance and structure of the mechanism

3 ____ The location of the Antikythera Mechanism$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e00c3759-ef5f-5f58-9e1e-8cf374214de7', '00c988b1-a4fa-524b-b6b4-d5541d332fb6', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('79423a64-7829-5e98-931d-b480988c94b8', '00c988b1-a4fa-524b-b6b4-d5541d332fb6', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('51e6514a-f0b0-5b5e-aba9-ea19d03f3310', '00c988b1-a4fa-524b-b6b4-d5541d332fb6', 3, $md$C$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2f5b6dc3-5fd9-5c4f-a1ed-0556247c6a02', '00c988b1-a4fa-524b-b6b4-d5541d332fb6', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('35a5c068-6900-5033-8dcb-82b071ce89f2', '00c988b1-a4fa-524b-b6b4-d5541d332fb6', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bd681a32-762e-5177-b02e-bf7175b9270c', '00c988b1-a4fa-524b-b6b4-d5541d332fb6', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c7da990f-23c9-5614-8773-267601efde79', '00c988b1-a4fa-524b-b6b4-d5541d332fb6', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fcb5d19e-37fe-513c-b4a2-e442d174e771', '00c988b1-a4fa-524b-b6b4-d5541d332fb6', 8, $md$H$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a4f3ca14-02f7-53b3-b6f8-7c916f073145', '00c988b1-a4fa-524b-b6b4-d5541d332fb6', 9, $md$I$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fda02abe-fa0f-55e8-baf7-70fbc1709406', '00c988b1-a4fa-524b-b6b4-d5541d332fb6', 10, $md$J$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('3f79069a-942f-5fa6-ad51-51a2eb21901c', '016d95a9-b0a2-5e6f-839e-f6bf54993e33', 4, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 4

Questions 1-5
Questions 1-5
The Reading Passage has ten paragraphs
A-J
Which paragraph contains the following information?
Write the correct letter
A-J
, in boxes
1-5
on your answer sheet.
1
The content inside the wrecked ship
2
Ancient astronomers and craftsman might involve
3
The location of the Antikythera Mechanism
4
Details of how it was found
5
Appearance and structure of the mechanism

4 ____ Details of how it was found$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('74e3ba89-7136-5aae-bd32-af43ce1c908c', '3f79069a-942f-5fa6-ad51-51a2eb21901c', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e868bf35-cc4b-50b2-a419-9c266f85a07c', '3f79069a-942f-5fa6-ad51-51a2eb21901c', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6e768637-6b82-52ee-8e96-e776474c9664', '3f79069a-942f-5fa6-ad51-51a2eb21901c', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('394b2d4c-f57d-583e-9c4d-3a5dc6c6fa3c', '3f79069a-942f-5fa6-ad51-51a2eb21901c', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('652b90d4-53fd-559d-9642-9798a161c90d', '3f79069a-942f-5fa6-ad51-51a2eb21901c', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('34fd6f25-3fa0-5efd-b4ee-d3db1631e8ee', '3f79069a-942f-5fa6-ad51-51a2eb21901c', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e1da9f59-4654-5c6f-9627-319adca3f487', '3f79069a-942f-5fa6-ad51-51a2eb21901c', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('26ca8de9-7118-5a7e-a360-30acca24cfa8', '3f79069a-942f-5fa6-ad51-51a2eb21901c', 8, $md$H$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2eb3cfc3-eb23-56d6-846f-ce149e7fc211', '3f79069a-942f-5fa6-ad51-51a2eb21901c', 9, $md$I$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2de46b25-6ea3-5641-9fca-0584d153420f', '3f79069a-942f-5fa6-ad51-51a2eb21901c', 10, $md$J$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('a8a7e39c-4e74-5eaa-aa1b-f27ad0fdf3f8', '016d95a9-b0a2-5e6f-839e-f6bf54993e33', 5, 'MATCHING_INFORMATION', 'READING', 3, $md$### Question 5

Questions 1-5
Questions 1-5
The Reading Passage has ten paragraphs
A-J
Which paragraph contains the following information?
Write the correct letter
A-J
, in boxes
1-5
on your answer sheet.
1
The content inside the wrecked ship
2
Ancient astronomers and craftsman might involve
3
The location of the Antikythera Mechanism
4
Details of how it was found
5
Appearance and structure of the mechanism

5 ____ Appearance and structure of the mechanism$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e93c7c7d-59ee-55f3-a8ef-df41963d8718', 'a8a7e39c-4e74-5eaa-aa1b-f27ad0fdf3f8', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('36c9e01b-c129-54dc-a06a-928306129560', 'a8a7e39c-4e74-5eaa-aa1b-f27ad0fdf3f8', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('87592a2d-58ff-5997-9bb0-0dd8e9216447', 'a8a7e39c-4e74-5eaa-aa1b-f27ad0fdf3f8', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fb40a962-d179-5c27-9be5-c8a73c4e0cd4', 'a8a7e39c-4e74-5eaa-aa1b-f27ad0fdf3f8', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('84b9ad5b-3e08-5a81-930c-205cfa5287fb', 'a8a7e39c-4e74-5eaa-aa1b-f27ad0fdf3f8', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('735c1cc4-4559-5d6d-8ac0-14a1d0323a3f', 'a8a7e39c-4e74-5eaa-aa1b-f27ad0fdf3f8', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c36b2625-b49b-5c46-8511-bab34c49d04e', 'a8a7e39c-4e74-5eaa-aa1b-f27ad0fdf3f8', 7, $md$G$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a5129b22-7262-5cef-ab2f-029f4e170d3d', 'a8a7e39c-4e74-5eaa-aa1b-f27ad0fdf3f8', 8, $md$H$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3cd75332-ccc9-5fc0-8545-19d2c43ff139', 'a8a7e39c-4e74-5eaa-aa1b-f27ad0fdf3f8', 9, $md$I$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2c23f22b-ba6b-5a2c-88e6-ff69558f5f44', 'a8a7e39c-4e74-5eaa-aa1b-f27ad0fdf3f8', 10, $md$J$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('c5dcf7d3-0bf7-5059-a578-69ae8a2b92c0', '016d95a9-b0a2-5e6f-839e-f6bf54993e33', 6, 'SUMMARY_COMPLETION', 'READING', 3, $md$### Question 6

Questions 6-9
Questions 6-9
Complete the following summary of the paragraphs of Reading Passage, using
NO MORE THAN TWO WORDS
from the Reading Passage for each answer.
Write your answers in boxes
6-9
on your answer sheet.
An ancient huge sunk
6
was found accidentally by sponges searcher. The ship loaded with
7
such as bronze and sculptures. However, an archaeologist found a junk similar to a
8
which has Greek script on it. This inspiring and elaborated device was found to be the first
9
in the world

An ancient huge sunk 6 ____ was found accidentally by sponges searcher. The ship loaded with 7 ____ such as bronze and sculptures. However, an archaeologist found a junk similar to a 8 ____ which has Greek script on it. This inspiring and elaborated device was found to be the first 9 ____ in the world$md$, NULL, ARRAY['.*cargo.*vessel.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('91574bd7-6f36-5b47-8912-34faf48aa241', '016d95a9-b0a2-5e6f-839e-f6bf54993e33', 7, 'SUMMARY_COMPLETION', 'READING', 3, $md$### Question 7

Questions 6-9
Questions 6-9
Complete the following summary of the paragraphs of Reading Passage, using
NO MORE THAN TWO WORDS
from the Reading Passage for each answer.
Write your answers in boxes
6-9
on your answer sheet.
An ancient huge sunk
6
was found accidentally by sponges searcher. The ship loaded with
7
such as bronze and sculptures. However, an archaeologist found a junk similar to a
8
which has Greek script on it. This inspiring and elaborated device was found to be the first
9
in the world

An ancient huge sunk 6 ____ was found accidentally by sponges searcher. The ship loaded with 7 ____ such as bronze and sculptures. However, an archaeologist found a junk similar to a 8 ____ which has Greek script on it. This inspiring and elaborated device was found to be the first 9 ____ in the world$md$, NULL, ARRAY['.*cargo.*vessel.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('8a7f5dd9-a5ca-5ad8-8575-797c536aab2b', '016d95a9-b0a2-5e6f-839e-f6bf54993e33', 8, 'SUMMARY_COMPLETION', 'READING', 3, $md$### Question 8

Questions 6-9
Questions 6-9
Complete the following summary of the paragraphs of Reading Passage, using
NO MORE THAN TWO WORDS
from the Reading Passage for each answer.
Write your answers in boxes
6-9
on your answer sheet.
An ancient huge sunk
6
was found accidentally by sponges searcher. The ship loaded with
7
such as bronze and sculptures. However, an archaeologist found a junk similar to a
8
which has Greek script on it. This inspiring and elaborated device was found to be the first
9
in the world

An ancient huge sunk 6 ____ was found accidentally by sponges searcher. The ship loaded with 7 ____ such as bronze and sculptures. However, an archaeologist found a junk similar to a 8 ____ which has Greek script on it. This inspiring and elaborated device was found to be the first 9 ____ in the world$md$, NULL, ARRAY['.*cargo.*vessel.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('40ec992b-4258-5abb-98f1-32b2cbada2c5', '016d95a9-b0a2-5e6f-839e-f6bf54993e33', 9, 'SUMMARY_COMPLETION', 'READING', 3, $md$### Question 9

Questions 6-9
Questions 6-9
Complete the following summary of the paragraphs of Reading Passage, using
NO MORE THAN TWO WORDS
from the Reading Passage for each answer.
Write your answers in boxes
6-9
on your answer sheet.
An ancient huge sunk
6
was found accidentally by sponges searcher. The ship loaded with
7
such as bronze and sculptures. However, an archaeologist found a junk similar to a
8
which has Greek script on it. This inspiring and elaborated device was found to be the first
9
in the world

An ancient huge sunk 6 ____ was found accidentally by sponges searcher. The ship loaded with 7 ____ such as bronze and sculptures. However, an archaeologist found a junk similar to a 8 ____ which has Greek script on it. This inspiring and elaborated device was found to be the first 9 ____ in the world$md$, NULL, ARRAY['.*cargo.*vessel.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('52cdd0aa-f6a9-58c7-a8e8-e3738fcee11b', '016d95a9-b0a2-5e6f-839e-f6bf54993e33', 10, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 10

Questions 10-13
Questions 10-13
Use the information in the passage to match the people (listed
A-C
) with opinions or deeds below. Write the appropriate letters
A-F
in boxes
10-13
on your answer sheet.
NB
You may use any letter more than once
A
Yanis Bitsakis
B
Mike Edmunds
C
François Charette
10
More complicated than the previous device
11
Anticipate to find more Antikythera Mechanism in the future
12
Antikythera Mechanism was found related to the moon
13
Mechanism assisted ancient people to calculate the movement of stars.

10 ____ More complicated than the previous device$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('feecfba1-8ebf-556e-98fe-f855f999a21e', '52cdd0aa-f6a9-58c7-a8e8-e3738fcee11b', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d1308713-ad1c-5ed8-8d7c-c08eab968dbb', '52cdd0aa-f6a9-58c7-a8e8-e3738fcee11b', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e32f5ac2-367f-5484-a717-6aaba1df4e12', '52cdd0aa-f6a9-58c7-a8e8-e3738fcee11b', 3, $md$C$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('aa21f73e-448b-5042-9607-0c30a5ccbd5a', '016d95a9-b0a2-5e6f-839e-f6bf54993e33', 11, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 11

Questions 10-13
Questions 10-13
Use the information in the passage to match the people (listed
A-C
) with opinions or deeds below. Write the appropriate letters
A-F
in boxes
10-13
on your answer sheet.
NB
You may use any letter more than once
A
Yanis Bitsakis
B
Mike Edmunds
C
François Charette
10
More complicated than the previous device
11
Anticipate to find more Antikythera Mechanism in the future
12
Antikythera Mechanism was found related to the moon
13
Mechanism assisted ancient people to calculate the movement of stars.

11 ____ Anticipate to find more Antikythera Mechanism in the future$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7eea2b02-d9a6-5fc5-ae6f-6eb999b2094d', 'aa21f73e-448b-5042-9607-0c30a5ccbd5a', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('baa0571f-bc84-5695-b02d-221b6c1f8a7d', 'aa21f73e-448b-5042-9607-0c30a5ccbd5a', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('85d673b4-c3c8-5340-9680-3d3facb46117', 'aa21f73e-448b-5042-9607-0c30a5ccbd5a', 3, $md$C$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('120ad97b-dfce-5846-8984-27f29f9dd24e', '016d95a9-b0a2-5e6f-839e-f6bf54993e33', 12, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 12

Questions 10-13
Questions 10-13
Use the information in the passage to match the people (listed
A-C
) with opinions or deeds below. Write the appropriate letters
A-F
in boxes
10-13
on your answer sheet.
NB
You may use any letter more than once
A
Yanis Bitsakis
B
Mike Edmunds
C
François Charette
10
More complicated than the previous device
11
Anticipate to find more Antikythera Mechanism in the future
12
Antikythera Mechanism was found related to the moon
13
Mechanism assisted ancient people to calculate the movement of stars.

12 ____ Antikythera Mechanism was found related to the moon$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b5ad43d8-7bc2-54dc-8107-61efb6781611', '120ad97b-dfce-5846-8984-27f29f9dd24e', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('68ee0039-dceb-56ba-a427-19ab62987984', '120ad97b-dfce-5846-8984-27f29f9dd24e', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('866e73c4-6087-5b21-9a14-19db4947865e', '120ad97b-dfce-5846-8984-27f29f9dd24e', 3, $md$C$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('8df32a56-00ab-5e66-bb29-468f8616cdeb', '016d95a9-b0a2-5e6f-839e-f6bf54993e33', 13, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 13

Questions 10-13
Questions 10-13
Use the information in the passage to match the people (listed
A-C
) with opinions or deeds below. Write the appropriate letters
A-F
in boxes
10-13
on your answer sheet.
NB
You may use any letter more than once
A
Yanis Bitsakis
B
Mike Edmunds
C
François Charette
10
More complicated than the previous device
11
Anticipate to find more Antikythera Mechanism in the future
12
Antikythera Mechanism was found related to the moon
13
Mechanism assisted ancient people to calculate the movement of stars.

13 ____ Mechanism assisted ancient people to calculate the movement of stars.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('baa93e11-bb49-5a10-ad69-2000bb954c72', '8df32a56-00ab-5e66-bb29-468f8616cdeb', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('faa2c60b-799e-54e4-94c1-7b5d6a2d4087', '8df32a56-00ab-5e66-bb29-468f8616cdeb', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ce00f5e9-37ee-5411-951f-3e1a2c71e4d0', '8df32a56-00ab-5e66-bb29-468f8616cdeb', 3, $md$C$md$, false);

COMMIT;
