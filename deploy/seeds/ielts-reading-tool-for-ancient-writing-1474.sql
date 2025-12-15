BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-tool-for-ancient-writing-1474'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-tool-for-ancient-writing-1474';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-tool-for-ancient-writing-1474';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-tool-for-ancient-writing-1474';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('c970711e-e92d-5cb5-90b1-ff38115ac09d', 'ielts-reading-tool-for-ancient-writing-1474', $t$Tool for ancient writing$t$, $md$## Tool for ancient writing

Nguồn:
- Test: https://mini-ielts.com/1474/reading/tool-for-ancient-writing
- Solution: https://mini-ielts.com/1474/view-solution/reading/tool-for-ancient-writing$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('bb1c6200-4202-5374-af3e-90261e4d8fc7', 'c970711e-e92d-5cb5-90b1-ff38115ac09d', 1, $t$Reading — Tool for ancient writing$t$, $md$Read the passage and answer questions **1–11**.

### Passage: Tool for ancient writing

{A} With time, the record-keepers developed systematized symbols from their drawings. These symbols represented words and sentences but were easier and faster to draw and universally recognized for meaning. The discovery of clay made portable records possible (you can’t carry a cave wall around with you). Early merchants used clay tokens with pictographs to record the quantities of materials traded or shipped. These tokens date back to about 8,500 B.C. With the high volume and the repetition inherent in record keeping, pictographs evolved and slowly lost their picture detail. They became abstract figures representing sounds in spoken communication. The alphabet replaced pictographs between 1700 and 1500 B.C. in the Sinaitic world. The current Hebrew alphabet and writing became popular around 600 B.C. About 400 B.C. the Greek alphabet was developed. Greek was the first script written from left to right. From Greek followed the Byzantine and the Roman (later Latin) writings. In the beginning, all writing systems had only uppercase letters, when the writing instruments were refined enough for detailed faces, lowercase was used as well (around 600 A.D.)

{B} The earliest means of writing that approached pen and paper as we know them today was developed by the Greeks. They employed a writing stylus, made of metal, bone, or ivory, to placemarks upon wax-coated tablets. The tablets are made in hinged pairs, closed to protect the scribe’s notes. The first examples of handwriting (purely text messages made by hand) originated in Greece . The Grecian scholar, Cadmus invented the written letter – text messages on paper sent from one individual to another.

{C} Writing was advancing beyond chiselling pictures into stone or wedging pictographs into wet clay. The Chinese invented and perfected ‘Indian Ink’. Originally designed for blacking the surfaces of raised stone-carved hieroglyphics, the ink was a mixture of soot from pine smoke and lamp oil mixed with the gelatin of donkey skin and musk. The ink invented by the Chinese philosopher, Tien-Lcheu (2697 B.C.), became common by the year 1200 B.C. Other cultures developed inks using natural dyes and colours derived from berries, plants, and minerals. In early writings, different coloured inks had ritual meanings attached to each colour.

{D} The invention of inks paralleled the introduction of the paper. The early Egyptians, Romans, Greeks, and Hebrews, used papyrus and parchment papers. One of the oldest pieces of writing on papyrus known to us today is the Egyptian “Prisse Papyrus” which dates back to 2000 B.C. The Romans created a reed-pen perfect for parchment and ink, from the hollow tubular stems of marsh grasses, especially from the jointed bamboo plant. They converted bamboo stems into a primitive form of a fountain pen. They cut one end into the form of a pen nib or point. A writing fluid or ink filled the stem, squeezing the reed forced fluid to the nib

{E} By 400 A.D. a stable form of ink developed, a composite of iron salts , nutgalls, and gum, the basic formula, which was to remain in use for centuries. Its colour when first applied to paper was a bluish-black, rapidly turning into a darker black and then over the years fading to the familiar dull brown colour commonly seen in old documents. Wood-fiber paper was invented in China in 105 A.D. but it only became known about (due to Chinese secrecy) in Japan around 700 A.D. and was brought to Spain by the Arabs in 711 A.D. Paper was not widely used throughout Europe until paper mills were built in the late 14th century

{F} The writing instrument that dominated for the longest period in history (over one thousand years) was the quill pen. Introduced around 700 A.D., the quill is a pen made from a bird feather. The strongest quills were those taken from living birds in the spring from the five outer left wing feathers. The left wing was favoured because the feathers curved outward and away when used by a right-handed writer. Goose feathers were most common; swan feathers were of a premium grade being scarcer and more expensive. For making fine lines, crow feathers were the best, and then came the feathers of the eagle, owl, hawk, and turkey.

{G} There were also disadvantages associated with the use of quill pens, including a lengthy preparation time. The early European writing parchments made from animal skins required much scraping and cleaning. A lead and a ruler made margins. To sharpen the quill, the writer needed a special knife (origins of the term “pen-knife”.) Beneath the writer’s high-top desk was a coal stove, used to dry the ink as fast as possible.

H Plant-fiber paper became the primary medium for writing after another dramatic invention took place: Johannes Gutenberg invented the printing press with replaceable wooden or metal letters in 1436. Simpler kinds of printing e.g. stamps with names used much earlier in China, did not find their way to Europe. During the centuries, many newer printing technologies were developed based on Gutenberg’s printing machine e.g. offset printing.

{I} Articles written by hand had resembled printed letters until scholars began to change the form of writing, using capitals and small letters, writing with more of a slant and connecting letters. Gradually writing became more suitable to the speed the new writing instruments permitted. The credit of inventing Italian ‘running hand’ or cursive handwriting with its Roman capitals and small letters, goes to Aldus Manutius of Venice, who departed from the old set forms in 1495 A.D. By the end of the 16th century, the old Roman capitals and Greek letterforms transformed into the twenty-six alphabet letters we know today, both for upper and lower-case letters. When writers had both better inks and paper, and handwriting had developed into both an art form and an everyday occurrence, man’s inventive nature once again turned to improving the writing instrument, leading to the development of the modern fountain pens$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('00a9c3e3-3942-5547-ac58-5e031d226f22', 'bb1c6200-4202-5374-af3e-90261e4d8fc7', 3, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 3

Question 3
Question 3
What hurts the technique of producing wooden paper from popularity for a long time?
A
Scarcity
B
Complexity
C
Confidentiality by the inventors
D
High cost

What hurts the technique of producing wooden paper from popularity for a long time?$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('df8a12bc-c1bc-509e-999c-02a7054ad3c3', 'bb1c6200-4202-5374-af3e-90261e4d8fc7', 4, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 4

Questions 4-10
Questions 4-10
The reading Passage has eleven paragraphs A-I.
Which paragraph contains the following information?
Write the correct letter A-I, in boxes 4-10 on your answer sheet.
NB You may use any letter more than once.
4
the working principle of the primitive pens made of plant stems
5
a writing tool commonly implemented for the longest time
6
liquid for writing firstly devised by Chinese
7
majuscule scripts as the unique written form originally
8
the original invention of today’s correspondences
9
the mention of two basic writing instruments being invented coordinately
10
a design to safeguard the written content

4 ____ the working principle of the primitive pens made of plant stems$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6566cb11-e07c-5e72-8195-dd58cd1146ef', 'df8a12bc-c1bc-509e-999c-02a7054ad3c3', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('641b9777-25bf-57a9-b624-7b21241a2580', 'df8a12bc-c1bc-509e-999c-02a7054ad3c3', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2a8676a1-e304-5cdf-8e42-02e2115b128e', 'df8a12bc-c1bc-509e-999c-02a7054ad3c3', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4e379264-6c93-5ef4-bbd1-20d903bfa7a5', 'df8a12bc-c1bc-509e-999c-02a7054ad3c3', 4, $md$D$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e8feff77-c69b-5d33-b368-6829fe8a81d6', 'df8a12bc-c1bc-509e-999c-02a7054ad3c3', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d4691658-ce32-5ed9-b994-4c03c5707874', 'df8a12bc-c1bc-509e-999c-02a7054ad3c3', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3bd48c42-cd04-5660-98d4-648bfd532d72', 'df8a12bc-c1bc-509e-999c-02a7054ad3c3', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b85fef68-1aa3-51c9-be5f-d376e4556ecf', 'df8a12bc-c1bc-509e-999c-02a7054ad3c3', 8, $md$H$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2ecc8ee2-bb31-5b3a-982f-fc759000194d', 'df8a12bc-c1bc-509e-999c-02a7054ad3c3', 9, $md$I$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('e358b487-b3f9-5eca-a80b-fc556addffb3', 'bb1c6200-4202-5374-af3e-90261e4d8fc7', 5, 'MATCHING_INFORMATION', 'READING', 3, $md$### Question 5

Questions 4-10
Questions 4-10
The reading Passage has eleven paragraphs A-I.
Which paragraph contains the following information?
Write the correct letter A-I, in boxes 4-10 on your answer sheet.
NB You may use any letter more than once.
4
the working principle of the primitive pens made of plant stems
5
a writing tool commonly implemented for the longest time
6
liquid for writing firstly devised by Chinese
7
majuscule scripts as the unique written form originally
8
the original invention of today’s correspondences
9
the mention of two basic writing instruments being invented coordinately
10
a design to safeguard the written content

5 ____ a writing tool commonly implemented for the longest time$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e7e973f3-b8a8-5def-929a-2091eb6f5384', 'e358b487-b3f9-5eca-a80b-fc556addffb3', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d59f8a51-25f6-5cc1-a110-0413dd8bc2dd', 'e358b487-b3f9-5eca-a80b-fc556addffb3', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('70b9df8e-ff65-506c-825f-4ed3640e6f27', 'e358b487-b3f9-5eca-a80b-fc556addffb3', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6cd16763-ae70-568a-8e89-17360c38ea1a', 'e358b487-b3f9-5eca-a80b-fc556addffb3', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fd12af4d-b179-5375-807f-52da3b418c6f', 'e358b487-b3f9-5eca-a80b-fc556addffb3', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('de261625-238c-5829-84d4-279401dc3096', 'e358b487-b3f9-5eca-a80b-fc556addffb3', 6, $md$F$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('711f9540-e6e3-5c20-a367-8c4230b73f0b', 'e358b487-b3f9-5eca-a80b-fc556addffb3', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5f33cf9f-e6d3-5404-9705-6a4bed30e66f', 'e358b487-b3f9-5eca-a80b-fc556addffb3', 8, $md$H$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3e1b1d7d-7753-532a-ab69-324a218dcda7', 'e358b487-b3f9-5eca-a80b-fc556addffb3', 9, $md$I$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('c56bf8a9-6635-5afa-a138-7032bbaeb3fc', 'bb1c6200-4202-5374-af3e-90261e4d8fc7', 6, 'MATCHING_INFORMATION', 'READING', 3, $md$### Question 6

Questions 4-10
Questions 4-10
The reading Passage has eleven paragraphs A-I.
Which paragraph contains the following information?
Write the correct letter A-I, in boxes 4-10 on your answer sheet.
NB You may use any letter more than once.
4
the working principle of the primitive pens made of plant stems
5
a writing tool commonly implemented for the longest time
6
liquid for writing firstly devised by Chinese
7
majuscule scripts as the unique written form originally
8
the original invention of today’s correspondences
9
the mention of two basic writing instruments being invented coordinately
10
a design to safeguard the written content

6 ____ liquid for writing firstly devised by Chinese$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('935d5f02-47f3-58ca-a109-c45b3bb1fc5b', 'c56bf8a9-6635-5afa-a138-7032bbaeb3fc', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('845d80b7-4c35-52e0-b919-b756d4c28a4a', 'c56bf8a9-6635-5afa-a138-7032bbaeb3fc', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('00b1902e-68fe-5030-9e27-b016f58a4032', 'c56bf8a9-6635-5afa-a138-7032bbaeb3fc', 3, $md$C$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bbf9c4d8-d807-5bb2-80e3-117a7764c717', 'c56bf8a9-6635-5afa-a138-7032bbaeb3fc', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7e5275ec-528d-56ee-8702-9d055a4c6d48', 'c56bf8a9-6635-5afa-a138-7032bbaeb3fc', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('be97a973-4556-5db4-9df3-b59eb7125cb0', 'c56bf8a9-6635-5afa-a138-7032bbaeb3fc', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('415ee68b-a69f-5cb4-ac75-eddcc7b44a34', 'c56bf8a9-6635-5afa-a138-7032bbaeb3fc', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('66c22c01-ca39-56a0-ba09-2fcba1fe729a', 'c56bf8a9-6635-5afa-a138-7032bbaeb3fc', 8, $md$H$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9077a4ff-4f8d-5742-b89b-412a5858a295', 'c56bf8a9-6635-5afa-a138-7032bbaeb3fc', 9, $md$I$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('eb5148c0-6c15-52b6-98c5-5de28c6efc3c', 'bb1c6200-4202-5374-af3e-90261e4d8fc7', 7, 'MATCHING_INFORMATION', 'READING', 3, $md$### Question 7

Questions 4-10
Questions 4-10
The reading Passage has eleven paragraphs A-I.
Which paragraph contains the following information?
Write the correct letter A-I, in boxes 4-10 on your answer sheet.
NB You may use any letter more than once.
4
the working principle of the primitive pens made of plant stems
5
a writing tool commonly implemented for the longest time
6
liquid for writing firstly devised by Chinese
7
majuscule scripts as the unique written form originally
8
the original invention of today’s correspondences
9
the mention of two basic writing instruments being invented coordinately
10
a design to safeguard the written content

7 ____ majuscule scripts as the unique written form originally$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e316229c-ac4f-5cf7-9559-fc33f51228cb', 'eb5148c0-6c15-52b6-98c5-5de28c6efc3c', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ac486927-bd9a-5844-b972-1fece0fe90b1', 'eb5148c0-6c15-52b6-98c5-5de28c6efc3c', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('16442d4e-de4c-599f-8fee-4fff07644b62', 'eb5148c0-6c15-52b6-98c5-5de28c6efc3c', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('efe576b0-8d9b-5b36-a0d3-667f2949bd1d', 'eb5148c0-6c15-52b6-98c5-5de28c6efc3c', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('15773dc9-a178-5a5d-a286-1b9472e6ce1a', 'eb5148c0-6c15-52b6-98c5-5de28c6efc3c', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7c2bb878-39e1-5318-9721-b3e29b6233ba', 'eb5148c0-6c15-52b6-98c5-5de28c6efc3c', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1152d48a-c800-5dd7-9050-ad1b3f15f01b', 'eb5148c0-6c15-52b6-98c5-5de28c6efc3c', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('25c548f6-730e-5531-897f-bd7bba01b8ba', 'eb5148c0-6c15-52b6-98c5-5de28c6efc3c', 8, $md$H$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('014c6156-9b3c-5c65-a0ac-72991f4b0454', 'eb5148c0-6c15-52b6-98c5-5de28c6efc3c', 9, $md$I$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('dbe9ad80-b5db-59a4-80af-e2eb0552573c', 'bb1c6200-4202-5374-af3e-90261e4d8fc7', 8, 'MATCHING_INFORMATION', 'READING', 3, $md$### Question 8

Questions 4-10
Questions 4-10
The reading Passage has eleven paragraphs A-I.
Which paragraph contains the following information?
Write the correct letter A-I, in boxes 4-10 on your answer sheet.
NB You may use any letter more than once.
4
the working principle of the primitive pens made of plant stems
5
a writing tool commonly implemented for the longest time
6
liquid for writing firstly devised by Chinese
7
majuscule scripts as the unique written form originally
8
the original invention of today’s correspondences
9
the mention of two basic writing instruments being invented coordinately
10
a design to safeguard the written content

8 ____ the original invention of today’s correspondences$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4a43e83f-2c98-5c8a-9745-2bcf5ae9102b', 'dbe9ad80-b5db-59a4-80af-e2eb0552573c', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2be93c7e-3739-5dbb-82aa-e562269ac7dc', 'dbe9ad80-b5db-59a4-80af-e2eb0552573c', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('054533e2-5aea-51d0-878f-1b8116b55d53', 'dbe9ad80-b5db-59a4-80af-e2eb0552573c', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5d8bb0da-6967-5692-a7cb-7ae73945f1da', 'dbe9ad80-b5db-59a4-80af-e2eb0552573c', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fc2ad773-de29-56f7-a86e-6e6f93a5d517', 'dbe9ad80-b5db-59a4-80af-e2eb0552573c', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('92d01130-4291-527d-be11-7071fd86a39d', 'dbe9ad80-b5db-59a4-80af-e2eb0552573c', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3698bd56-509a-578a-b0f5-997eaf4ac1e9', 'dbe9ad80-b5db-59a4-80af-e2eb0552573c', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('072943c6-a979-55f9-ab82-2786c05effee', 'dbe9ad80-b5db-59a4-80af-e2eb0552573c', 8, $md$H$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3ec526c5-ff20-5e16-bf95-6fe601a8344e', 'dbe9ad80-b5db-59a4-80af-e2eb0552573c', 9, $md$I$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('cda5ec73-7ace-5e95-8620-1c2877c877f0', 'bb1c6200-4202-5374-af3e-90261e4d8fc7', 9, 'MATCHING_INFORMATION', 'READING', 3, $md$### Question 9

Questions 4-10
Questions 4-10
The reading Passage has eleven paragraphs A-I.
Which paragraph contains the following information?
Write the correct letter A-I, in boxes 4-10 on your answer sheet.
NB You may use any letter more than once.
4
the working principle of the primitive pens made of plant stems
5
a writing tool commonly implemented for the longest time
6
liquid for writing firstly devised by Chinese
7
majuscule scripts as the unique written form originally
8
the original invention of today’s correspondences
9
the mention of two basic writing instruments being invented coordinately
10
a design to safeguard the written content

9 ____ the mention of two basic writing instruments being invented coordinately$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('63bc72f6-7d81-56ad-8b01-b58d7100b04b', 'cda5ec73-7ace-5e95-8620-1c2877c877f0', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3a8d09da-ab6d-595d-b64b-39f78024253f', 'cda5ec73-7ace-5e95-8620-1c2877c877f0', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ebd68fb8-ae8e-51de-9c57-e5b32944436a', 'cda5ec73-7ace-5e95-8620-1c2877c877f0', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9828080b-feff-5241-b8b7-c9587ae7a020', 'cda5ec73-7ace-5e95-8620-1c2877c877f0', 4, $md$D$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c2b1845a-9a06-5770-9245-da49dc44a90e', 'cda5ec73-7ace-5e95-8620-1c2877c877f0', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('94585af8-e474-585d-9c71-4177d3bb6d74', 'cda5ec73-7ace-5e95-8620-1c2877c877f0', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('330b9332-13aa-5a9b-9c2a-3cc65c724e79', 'cda5ec73-7ace-5e95-8620-1c2877c877f0', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8a4fb384-7dd9-5098-b607-031caa49284f', 'cda5ec73-7ace-5e95-8620-1c2877c877f0', 8, $md$H$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f9caf910-e105-5759-b304-dd7463b3d7be', 'cda5ec73-7ace-5e95-8620-1c2877c877f0', 9, $md$I$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('01897f4a-92cc-5f9c-9597-a976cef300a4', 'bb1c6200-4202-5374-af3e-90261e4d8fc7', 10, 'MATCHING_INFORMATION', 'READING', 4, $md$### Question 10

Questions 4-10
Questions 4-10
The reading Passage has eleven paragraphs A-I.
Which paragraph contains the following information?
Write the correct letter A-I, in boxes 4-10 on your answer sheet.
NB You may use any letter more than once.
4
the working principle of the primitive pens made of plant stems
5
a writing tool commonly implemented for the longest time
6
liquid for writing firstly devised by Chinese
7
majuscule scripts as the unique written form originally
8
the original invention of today’s correspondences
9
the mention of two basic writing instruments being invented coordinately
10
a design to safeguard the written content

10 ____ a design to safeguard the written content$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c29e6b40-74a6-5498-bad0-5d714636e12c', '01897f4a-92cc-5f9c-9597-a976cef300a4', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('67a21ae2-4228-5f26-9bc2-dfab4eb2d493', '01897f4a-92cc-5f9c-9597-a976cef300a4', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5447d11f-573d-50f5-9648-e5c7d2bc6cfb', '01897f4a-92cc-5f9c-9597-a976cef300a4', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3db68f7c-0f75-5b84-a873-076e17f32d34', '01897f4a-92cc-5f9c-9597-a976cef300a4', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('54a046c1-cd9e-58c9-86bf-9b9c11f5a3f4', '01897f4a-92cc-5f9c-9597-a976cef300a4', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cea693af-9b11-5491-ac19-d3347310e3c6', '01897f4a-92cc-5f9c-9597-a976cef300a4', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6ee86d45-3564-5f93-9e12-a956ccaf3dd3', '01897f4a-92cc-5f9c-9597-a976cef300a4', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a3bbae25-6cd3-5e7d-a89b-67bc368c50bd', '01897f4a-92cc-5f9c-9597-a976cef300a4', 8, $md$H$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('dc1f146a-ac5c-5814-8e57-b0fbb4cd278d', '01897f4a-92cc-5f9c-9597-a976cef300a4', 9, $md$I$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('1ba60816-534b-58a5-95b3-29e59dcbdd27', 'bb1c6200-4202-5374-af3e-90261e4d8fc7', 11, 'SHORT_ANSWER', 'READING', 4, $md$### Question 11

Questions 11-13
Questions 11-13
Answer the s below.
Choose
NO MORE THAN THREE WORDS AND/OR A NUMBER
from the passage for each answer.
11 What makes it not so convenient to use the quill pens?
11
12 When did one more breakthrough occur following the popularity of paper of plant fibres?
12
13 What inventions were the results of human’s creative instinct of developing writing tools?
13

11 What makes it not so convenient to use the quill pens? 11 ____$md$, NULL, ARRAY['.*lengthy.*preparation.*time.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('4a247e8f-8e59-5515-9bc2-6159b1fdcda3', 'bb1c6200-4202-5374-af3e-90261e4d8fc7', 12, 'SHORT_ANSWER', 'READING', 4, $md$### Question 12

Questions 11-13
Questions 11-13
Answer the s below.
Choose
NO MORE THAN THREE WORDS AND/OR A NUMBER
from the passage for each answer.
11 What makes it not so convenient to use the quill pens?
11
12 When did one more breakthrough occur following the popularity of paper of plant fibres?
12
13 What inventions were the results of human’s creative instinct of developing writing tools?
13

12 When did one more breakthrough occur following the popularity of paper of plant fibres? 12 ____$md$, NULL, ARRAY['.*in.*1436.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('a181fe03-f64a-5990-a181-113322cbff70', 'bb1c6200-4202-5374-af3e-90261e4d8fc7', 13, 'SHORT_ANSWER', 'READING', 4, $md$### Question 13

Questions 11-13
Questions 11-13
Answer the s below.
Choose
NO MORE THAN THREE WORDS AND/OR A NUMBER
from the passage for each answer.
11 What makes it not so convenient to use the quill pens?
11
12 When did one more breakthrough occur following the popularity of paper of plant fibres?
12
13 What inventions were the results of human’s creative instinct of developing writing tools?
13

13 What inventions were the results of human’s creative instinct of developing writing tools? 13 ____$md$, NULL, ARRAY['.*modern.*fountain.*pens.*']);

COMMIT;
