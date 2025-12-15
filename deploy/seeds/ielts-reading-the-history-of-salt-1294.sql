BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-the-history-of-salt-1294'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-the-history-of-salt-1294';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-the-history-of-salt-1294';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-the-history-of-salt-1294';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('271cdc48-3813-5240-a9cb-1e9cd646c5e3', 'ielts-reading-the-history-of-salt-1294', $t$The History Of Salt$t$, $md$## The History Of Salt

Nguồn:
- Test: https://mini-ielts.com/1294/reading/the-history-of-salt
- Solution: https://mini-ielts.com/1294/view-solution/reading/the-history-of-salt$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('ea6f1bc5-333e-5295-909c-e849c8b3e6ef', '271cdc48-3813-5240-a9cb-1e9cd646c5e3', 1, $t$Reading — The History Of Salt$t$, $md$Read the passage and answer questions **1–11**.

### Passage: The History Of Salt

Salt is so simple and plentiful that we almost take it for granted. In chemical terms, salt is the combination of a sodium ion with a chloride ion, making it one of the most basic molecules on earth. It is also one of the most plentiful: it has been estimated that salt deposits under the state of Kansas alone could supply the entire world’s needs for the next 250,000 years.

But salt is also an essential element. Without it, life itself would be impossible since the human body requires the mineral in order to function properly. The concentration of sodium ions in the blood is directly related to the regulation of safe body fluid levels. And while we are all familiar with its many uses in cooking, we may not be aware that this element is used in some 14,000 commercial applications. From manufacturing pulp and paper to setting dyes in textiles and fabric, from producing soaps and detergents to making our roads safe in winter, salt plays an essential part in our daily lives.

Salt has a long and influential role in world history. From the dawn of civilization, it has been a key factor in economic, religious, social and political development. In every corner of the world, it has been the subject of superstition, folklore, and warfare, and has even been used as currency.

As a precious and portable commodity, salt has long been a cornerstone of economies throughout history. In fact, researcher M.R. Bloch conjectured that civilization began along the edges of the desert because of the natural surface deposits of salt found there. Bloch also believed that the first war – likely fought near the ancient city of Essalt on the Jordan River – could have been fought over the city’s precious supplies of the mineral.

In 2200 BC, the Chinese emperor Hsia Yu levied one of the first known taxes. He taxed salt. In Tibet, Marco Polo noted that tiny cakes of salt were pressed with images of the Grand Khan to be used as coins and to this day among the nomads of Ethiopia’s Danakil Plains it is still used as money. Greek slave traders often bartered it for slaves, giving rise to the expression that someone was “not worth his salt.” Roman legionnaires were paid in salt – a solarium, the Latin origin of the word “salary.”

Merchants in 12th-century Timbuktu – the gateway to the Sahara Desert and the seat of scholars – valued this mineral as highly as books and gold. In France, Charles of Anjou levied the “gabelle,” a salt tax, in 1259 to finance his conquest of the Kingdom of Naples. Outrage over the gabelle fueled the French Revolution. Though the revolutionaries eliminated the tax shortly after Louis XVI, the Republic of France re-established the gabelle in the early 19th Century; only in 1946 was it removed from the books.

The Erie Canal, an engineering marvel that connected the Great Lakes to New York’s Hudson River in 1825, was called “the ditch that salt built.” Salt tax revenues paid for half the cost of construction of the canal. The British monarchy supported itself with high salt taxes, leading to a bustling black market for the white crystal. In 1 785, the Earl of Dundonald wrote that every year in England, 10,000 people were arrested for salt smuggling. And protesting against British rule in 1930, Mahatma Gandhi led a 200-mile march to the Arabian Ocean to collect untaxed salt for India’s poor.

In religion and culture, salt long held an important place with Greek worshippers consecrating it in their rituals. Further, in the Buddhist tradition, salt repels evil spirits, which is why it is customary to throw it over your- shoulder before entering your house after a funeral: it scares off any evil spirits that may be clinging to your back. Shinto religion also uses it to purify an area. Before sumo wrestlers enter the ring for a match – which is, in reality, an elaborate Shinto rite – a handful is thrown into the center to drive off malevolent spirits.

In the Southwest of the United States, the Pueblo worship the Salt Mother. Other native tribes had significant restrictions on who was permitted to eat salt. Hopi legend holds that the angry Warrior Twins punished mankind by placing valuable salt deposits far from civilization, requiring hard work and bravery to harvest the precious mineral. In 1933, the Dalai Lama was buried sitting up in a bed of salt. Today, a gift of salt endures in India as a potent symbol of good luck and a reference to Mahatma Gandhi’s liberation of India.

The effects of salt deficiency are highlighted in times of war, when human bodies and national economies are strained to their limits. Thousands of Napoleon’s troops died during the French retreat from Moscow due to inadequate wound healing and lowered resistance to disease – the results of salt deficiency.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('6e7e8232-294b-551e-a950-52659dad36ec', 'ea6f1bc5-333e-5295-909c-e849c8b3e6ef', 4, 'SUMMARY_COMPLETION', 'READING', 2, $md$### Question 4

Questions 4-8
Questions 4-8
Complete the summary.
Choose NO MORE THAN TWO WORDS from the passage for each answer. Write your answers in boxes 4-8 on your answer sheet.
Salt is such a
4
.that people would not be able to live without it. As well as its uses in cooking, this basic mineral has thousands of business
5
.ranging from making paper to the manufacture of soap. Being a prized and
6
, it has played a major part in the economies of many countries. As such, salt has not only led to war but has also been used to raise
7
by governments in many parts of the world. There are also many instances of its place in religion and culture, being used as a means to get rid of evil
8
.

Salt is such a 4 ____ .that people would not be able to live without it. As well as its uses in cooking, this basic mineral has thousands of business 5 ____ .ranging from making paper to the manufacture of soap. Being a prized and 6 ____ , it has played a major part in the economies of many countries. As such, salt has not only led to war but has also been used to raise 7 ____ by governments in many parts of the world. There are also many instances of its place in religion and culture, being used as a means to get rid of evil 8 ____ .$md$, NULL, ARRAY['.*essential.*element.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('0f43ab3c-406d-5f58-a496-5b5142d63c83', 'ea6f1bc5-333e-5295-909c-e849c8b3e6ef', 5, 'SUMMARY_COMPLETION', 'READING', 3, $md$### Question 5

Questions 4-8
Questions 4-8
Complete the summary.
Choose NO MORE THAN TWO WORDS from the passage for each answer. Write your answers in boxes 4-8 on your answer sheet.
Salt is such a
4
.that people would not be able to live without it. As well as its uses in cooking, this basic mineral has thousands of business
5
.ranging from making paper to the manufacture of soap. Being a prized and
6
, it has played a major part in the economies of many countries. As such, salt has not only led to war but has also been used to raise
7
by governments in many parts of the world. There are also many instances of its place in religion and culture, being used as a means to get rid of evil
8
.

Salt is such a 4 ____ .that people would not be able to live without it. As well as its uses in cooking, this basic mineral has thousands of business 5 ____ .ranging from making paper to the manufacture of soap. Being a prized and 6 ____ , it has played a major part in the economies of many countries. As such, salt has not only led to war but has also been used to raise 7 ____ by governments in many parts of the world. There are also many instances of its place in religion and culture, being used as a means to get rid of evil 8 ____ .$md$, NULL, ARRAY['.*essential.*element.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('89d8894b-0b8f-51d5-8477-8b6813423af1', 'ea6f1bc5-333e-5295-909c-e849c8b3e6ef', 6, 'SUMMARY_COMPLETION', 'READING', 3, $md$### Question 6

Questions 4-8
Questions 4-8
Complete the summary.
Choose NO MORE THAN TWO WORDS from the passage for each answer. Write your answers in boxes 4-8 on your answer sheet.
Salt is such a
4
.that people would not be able to live without it. As well as its uses in cooking, this basic mineral has thousands of business
5
.ranging from making paper to the manufacture of soap. Being a prized and
6
, it has played a major part in the economies of many countries. As such, salt has not only led to war but has also been used to raise
7
by governments in many parts of the world. There are also many instances of its place in religion and culture, being used as a means to get rid of evil
8
.

Salt is such a 4 ____ .that people would not be able to live without it. As well as its uses in cooking, this basic mineral has thousands of business 5 ____ .ranging from making paper to the manufacture of soap. Being a prized and 6 ____ , it has played a major part in the economies of many countries. As such, salt has not only led to war but has also been used to raise 7 ____ by governments in many parts of the world. There are also many instances of its place in religion and culture, being used as a means to get rid of evil 8 ____ .$md$, NULL, ARRAY['.*essential.*element.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('e648e74b-45fa-5d7b-b067-250300530fc1', 'ea6f1bc5-333e-5295-909c-e849c8b3e6ef', 7, 'SUMMARY_COMPLETION', 'READING', 3, $md$### Question 7

Questions 4-8
Questions 4-8
Complete the summary.
Choose NO MORE THAN TWO WORDS from the passage for each answer. Write your answers in boxes 4-8 on your answer sheet.
Salt is such a
4
.that people would not be able to live without it. As well as its uses in cooking, this basic mineral has thousands of business
5
.ranging from making paper to the manufacture of soap. Being a prized and
6
, it has played a major part in the economies of many countries. As such, salt has not only led to war but has also been used to raise
7
by governments in many parts of the world. There are also many instances of its place in religion and culture, being used as a means to get rid of evil
8
.

Salt is such a 4 ____ .that people would not be able to live without it. As well as its uses in cooking, this basic mineral has thousands of business 5 ____ .ranging from making paper to the manufacture of soap. Being a prized and 6 ____ , it has played a major part in the economies of many countries. As such, salt has not only led to war but has also been used to raise 7 ____ by governments in many parts of the world. There are also many instances of its place in religion and culture, being used as a means to get rid of evil 8 ____ .$md$, NULL, ARRAY['.*essential.*element.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('ff5e32dc-8337-5de6-84ba-24abcfa09764', 'ea6f1bc5-333e-5295-909c-e849c8b3e6ef', 8, 'SUMMARY_COMPLETION', 'READING', 3, $md$### Question 8

Questions 4-8
Questions 4-8
Complete the summary.
Choose NO MORE THAN TWO WORDS from the passage for each answer. Write your answers in boxes 4-8 on your answer sheet.
Salt is such a
4
.that people would not be able to live without it. As well as its uses in cooking, this basic mineral has thousands of business
5
.ranging from making paper to the manufacture of soap. Being a prized and
6
, it has played a major part in the economies of many countries. As such, salt has not only led to war but has also been used to raise
7
by governments in many parts of the world. There are also many instances of its place in religion and culture, being used as a means to get rid of evil
8
.

Salt is such a 4 ____ .that people would not be able to live without it. As well as its uses in cooking, this basic mineral has thousands of business 5 ____ .ranging from making paper to the manufacture of soap. Being a prized and 6 ____ , it has played a major part in the economies of many countries. As such, salt has not only led to war but has also been used to raise 7 ____ by governments in many parts of the world. There are also many instances of its place in religion and culture, being used as a means to get rid of evil 8 ____ .$md$, NULL, ARRAY['.*essential.*element.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('71abd500-bd69-56eb-a57f-ab1659fb2520', 'ea6f1bc5-333e-5295-909c-e849c8b3e6ef', 9, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 9

Questions 9-14
Questions 9-14
Do the following statements agree with the information in Reading Passage?
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information about the statement
9
It has been suggested that salt was responsible for the first war
10
The first tax on salt was imposed by a Chinese emperor
11
Salt is no longer used as a form of currency
12
Most of the money for the construction of the Erie Canal came from salt taxes
13
Hopi legend believes that salt deposits were placed far away from civilization to penalize mankind
14
A lack of salt is connected with the deaths of many of Napoleon’s soldiers during the French retreat from Moscow

9 ____ It has been suggested that salt was responsible for the first war$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('84d92e2c-f63f-54ae-9a8d-bb7cde8b99eb', '71abd500-bd69-56eb-a57f-ab1659fb2520', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e538494c-932a-5dc0-b00a-cf193df27ff2', '71abd500-bd69-56eb-a57f-ab1659fb2520', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7cb654bf-c779-5bea-9f86-d94ce519ffeb', '71abd500-bd69-56eb-a57f-ab1659fb2520', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('df7391a5-45b9-5c86-8a81-1db35b753a52', 'ea6f1bc5-333e-5295-909c-e849c8b3e6ef', 10, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 10

Questions 9-14
Questions 9-14
Do the following statements agree with the information in Reading Passage?
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information about the statement
9
It has been suggested that salt was responsible for the first war
10
The first tax on salt was imposed by a Chinese emperor
11
Salt is no longer used as a form of currency
12
Most of the money for the construction of the Erie Canal came from salt taxes
13
Hopi legend believes that salt deposits were placed far away from civilization to penalize mankind
14
A lack of salt is connected with the deaths of many of Napoleon’s soldiers during the French retreat from Moscow

10 ____ The first tax on salt was imposed by a Chinese emperor$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e479f608-8732-55c1-88aa-d6011efd4382', 'df7391a5-45b9-5c86-8a81-1db35b753a52', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('68a7cb69-5c45-551b-9e18-108f63a405f8', 'df7391a5-45b9-5c86-8a81-1db35b753a52', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('687f4c93-8584-55a5-b603-f7b45086bbae', 'df7391a5-45b9-5c86-8a81-1db35b753a52', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('19fdb622-4788-57d9-937e-7b9cfd5e9790', 'ea6f1bc5-333e-5295-909c-e849c8b3e6ef', 11, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 11

Questions 9-14
Questions 9-14
Do the following statements agree with the information in Reading Passage?
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information about the statement
9
It has been suggested that salt was responsible for the first war
10
The first tax on salt was imposed by a Chinese emperor
11
Salt is no longer used as a form of currency
12
Most of the money for the construction of the Erie Canal came from salt taxes
13
Hopi legend believes that salt deposits were placed far away from civilization to penalize mankind
14
A lack of salt is connected with the deaths of many of Napoleon’s soldiers during the French retreat from Moscow

11 ____ Salt is no longer used as a form of currency$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7fd43d41-4222-5e39-a035-1d05151e7eef', '19fdb622-4788-57d9-937e-7b9cfd5e9790', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('402ba8da-b8d7-52eb-abd7-e7a69df4dd16', '19fdb622-4788-57d9-937e-7b9cfd5e9790', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b2457e5a-1940-54d5-8b97-609d109ffbd4', '19fdb622-4788-57d9-937e-7b9cfd5e9790', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('91fed878-6a84-5721-9683-0e631e28a394', 'ea6f1bc5-333e-5295-909c-e849c8b3e6ef', 12, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 12

Questions 9-14
Questions 9-14
Do the following statements agree with the information in Reading Passage?
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information about the statement
9
It has been suggested that salt was responsible for the first war
10
The first tax on salt was imposed by a Chinese emperor
11
Salt is no longer used as a form of currency
12
Most of the money for the construction of the Erie Canal came from salt taxes
13
Hopi legend believes that salt deposits were placed far away from civilization to penalize mankind
14
A lack of salt is connected with the deaths of many of Napoleon’s soldiers during the French retreat from Moscow

12 ____ Most of the money for the construction of the Erie Canal came from salt taxes$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a8eb9a1e-ba9d-533b-8eca-1bbcf58e59d9', '91fed878-6a84-5721-9683-0e631e28a394', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b0a98c79-8012-5f0f-8822-01f0b8e167d3', '91fed878-6a84-5721-9683-0e631e28a394', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('88496225-6d40-50aa-9aec-185cc57e2b07', '91fed878-6a84-5721-9683-0e631e28a394', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('f1cc16d7-2ed1-5eb7-9867-c3fdfc83602f', 'ea6f1bc5-333e-5295-909c-e849c8b3e6ef', 13, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 13

Questions 9-14
Questions 9-14
Do the following statements agree with the information in Reading Passage?
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information about the statement
9
It has been suggested that salt was responsible for the first war
10
The first tax on salt was imposed by a Chinese emperor
11
Salt is no longer used as a form of currency
12
Most of the money for the construction of the Erie Canal came from salt taxes
13
Hopi legend believes that salt deposits were placed far away from civilization to penalize mankind
14
A lack of salt is connected with the deaths of many of Napoleon’s soldiers during the French retreat from Moscow

13 ____ Hopi legend believes that salt deposits were placed far away from civilization to penalize mankind$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6c34ad58-748d-5ff3-9aed-bb6a3505296c', 'f1cc16d7-2ed1-5eb7-9867-c3fdfc83602f', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2fc42a19-58c5-55b8-be3d-5a7727b70a4a', 'f1cc16d7-2ed1-5eb7-9867-c3fdfc83602f', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('98bddbd9-e29c-5fb0-a5b5-33bb8f019afa', 'f1cc16d7-2ed1-5eb7-9867-c3fdfc83602f', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('3289898c-d1c7-5c4c-b349-04a65c1c5888', 'ea6f1bc5-333e-5295-909c-e849c8b3e6ef', 14, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 14

Questions 9-14
Questions 9-14
Do the following statements agree with the information in Reading Passage?
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information about the statement
9
It has been suggested that salt was responsible for the first war
10
The first tax on salt was imposed by a Chinese emperor
11
Salt is no longer used as a form of currency
12
Most of the money for the construction of the Erie Canal came from salt taxes
13
Hopi legend believes that salt deposits were placed far away from civilization to penalize mankind
14
A lack of salt is connected with the deaths of many of Napoleon’s soldiers during the French retreat from Moscow

14 ____ A lack of salt is connected with the deaths of many of Napoleon’s soldiers during the French retreat from Moscow$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3dba21ba-f36b-566e-8cd6-75ad8a9ac7a0', '3289898c-d1c7-5c4c-b349-04a65c1c5888', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e65e4043-badf-5f8c-bd9a-d91fe1dec739', '3289898c-d1c7-5c4c-b349-04a65c1c5888', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bade45c6-7fec-5751-9f27-615e44a0421a', '3289898c-d1c7-5c4c-b349-04a65c1c5888', 3, $md$NOT GIVEN$md$, false);

COMMIT;
