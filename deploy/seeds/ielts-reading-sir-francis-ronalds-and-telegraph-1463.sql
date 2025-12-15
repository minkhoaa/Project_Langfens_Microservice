BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-sir-francis-ronalds-and-telegraph-1463'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-sir-francis-ronalds-and-telegraph-1463';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-sir-francis-ronalds-and-telegraph-1463';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-sir-francis-ronalds-and-telegraph-1463';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('16eddd76-7008-5ef5-bc06-76c0ba9e16f2', 'ielts-reading-sir-francis-ronalds-and-telegraph-1463', $t$Sir Francis Ronalds and Telegraph$t$, $md$## Sir Francis Ronalds and Telegraph

Nguồn:
- Test: https://mini-ielts.com/1463/reading/sir-francis-ronalds-and-telegraph
- Solution: https://mini-ielts.com/1463/view-solution/reading/sir-francis-ronalds-and-telegraph$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('389326cc-32e7-5ed5-ae71-77d9ba63f809', '16eddd76-7008-5ef5-bc06-76c0ba9e16f2', 1, $t$Reading — Sir Francis Ronalds and Telegraph$t$, $md$Read the passage and answer questions **1–14**.

### Passage: Sir Francis Ronalds and Telegraph

| | Sir Francis Ronalds and Telegraph RONALDS, Sir FRANCIS (1788-1873), inventor of the electric telegraph and meteorologist, son of Francis Ronalds, a London merchant, and of his wife, Jane, daughter of William Field, was born in London on 21 Feb. 1788. Ronalds was educated at a private school at Cheshunt by the Rev. E. Cogan. At an early age he displayed a taste for experiment, and he acquired great skill later in practical mechanics and draughtsman ship. Under the influence of Jean Andre de Luc (1727- 1817), whose acquaintance he made in 1814, he began to devote himself to practical electricity. In 1814 and 1815 he published several papers on electricity in Tilloch’s 'Philosophical Magazine,' one of which records an ingenious use of De Luc's 'electric column' as a motive power for a clock. Ronalds's name is chiefly remembered as the inventor of an electric telegraph. Since 1753, when the first proposal for an electric telegraph worked by statical electricity was made by a writer signing 'C. ' (said to be Charles Morrison) in the 'Scots Magazine', successive advances had been made abroad by Volta, Le Sage, Lomond, Cavallo, Salva, and others; but much was needed to perfect the invention. In 1816 Francis Ronalds, then living at Upper Mall, Hammersmith, built in his back garden two frames to accommodate eight miles of wire for his new invention of an electrostatic telegraph. It used clockwork-driven rotating dials, engraved with letters of the alphabet and numbers, synchronized with each other, at both ends of the circuit. For the past three or four years, encouraged by the octogenarian Swiss meteorologist, Jean Andre De Luc, Ronalds had been enthusiastically experimenting with electrostatic clockwork devices. When someone desired to send a message he earthed the wire at his end at the moment when the dial indicated the desired letter. At the receiving end the pith balls would fall together when earthed and the recipient noted the letter showing on his dial at that moment. The system was slow and depended on the two dials staying in step, but Ronalds successfully transmitted and received letters over 150 meters of wire ; later he succeeded in sending messages through eight miles of iron wire suspended above his garden in London. After sending messages along his wires on the frame, he developed another version in which the wires were enclosed in glass tubes buried in the ground. At each end of the line a clockwork mechanism turned synchronously revolving discs with letters on them. A frictional-electricity machine kept the wire continuously charged, while at each end two pith balls hung from the wire on silk threads, and since they were similarly charged from the wire they stayed apart. Ronalds 'S instrument was of real practical use, and the brilliant idea of using synchronously rotating discs, now employed in the Hughes printing apparatus, was entirely his own. The only defect in his invention was the comparative slowness with which a succession of symbols could be transmitted. With communications between London and Portsmouth in mind, he believed his telegraph would work over distances of 800km. In the same year, Ronalds wrote to offer his invention to the Admiralty. In fact, in 1806, Ralph Wedgwood submitted a telegraph based on frictional electricity to the Admiralty, but was told that the semaphore was sufficient for the country. In a pamphlet he suggested the establishment of a telegraph system with public offices in different centers. Francis Ronalds, in 1816, brought a similar telegraph of his invention to the notice of the Admiralty, and was politely informed that 'telegraphs of any kind are now wholly unnecessary.' John Barrow, Secretary to the Admiralty, replied that "Telegraphs of any kind are now wholly unnecessary; and no other than the one now in use will be adopted." (The one in use was a semaphore system. Only a year after the end of the Napoleonic Wars, the Admiralty saw no need for improved communications, even though the semaphore was usable only in daylight and good weather. After this disappointment, Ronalds set off for the continent. He travelled throughout Europe and the Eastern Mediterranean, taking notes, sketching and collecting scientific books between 1816 and 1823. He had begun collecting his large library of works on electricity and kindred subjects. The last activity formed the beginnings of the Ronalds Library, left in trust to the IEE (now the IET) after his death. In a small pamphlet published in 1823, Ronalds described his invention and listed some of its possible uses, "Why should not government govern at Portsmouth almost as promptly as in Downing Street? Why should our defaulters escape by default of our foggy climate? Let US have Electrical Conversazione offices communicating with each other all over the kingdom if we can." In 1825 he invented and patented a perspective tracing instrument, intended to facilitate drawing from nature, which he improved about 1828, and described in a work called 'Mechanical Perspective.' These instruments seem to be the only ones for which he took out patents. However, Ronalds never patented his invention in electric telegraph. Ronalds seems to have made few or no practical contributions to science. In the meanwhile, one person did benefit from this work-Charles Wheatstone who saw the telegraph as a boy. When Charles Wheatstone was quite a child, his father had seen the Ronalds telegraph at work. Later, the invention of an electric telegraph had been marvelously developed by Wheatstone, who had seen many of the Hammersmith experiments, in conjunction with Mr. William Fothergill Cooke, and these two men together devised and patented in 1837 the first electric telegraph used publicly and commercially in England. When, in 1855, a controversy arose between Wheatstone and Cooke with regard to their respective shares in the invention, Wheatstone at once acknowledged his direct debt to Ronalds, and Cooke, though less fully, acknowledged the priority of Ronalds's work; Until 1855 Ronalds's share in the invention had been forgotten by the public. Early in 1843 Ronalds was made honorary director and superintendent of the Meteorological Observatory, which was then established at Kew by the British Association for the Advancement of Science. He began work on a system for registering meteorological data using photography and this time was awarded a grant to continue his work. A similar system was developed independently by Charles Brooke, aided like Ronalds by grants from the Royal Society, had invented independently about this time. But the British Association confirmed Ronalds's priority. This was the beginning of automatic, accurate recording of meteorological data and remained in use for some years after Ronalds's death. Ronalds lived long enough to see his prophecies come to fruition and to receive belated official recognition: in 1870, three years before he died, he was knighted by Queen Elizabeth I, for his "early and remarkable labors in telegraphic investigations."$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('4d5892a1-858a-5135-b60b-8cf4cef2c410', '389326cc-32e7-5ed5-ae71-77d9ba63f809', 1, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 1

Question 1-5
Question 1-5
Matching the
each
correct
year
to the
historical event
in the passage,
and write the correct answer into box of 1-5 in the answer sheet
A
1753
B
1806
c
1816
D
1823
E
1825
F
1837
G
1843
1
When did Francis Ronalds achieve a satisfactory result in the electricity experiment conducted first time?
2
When was the first proposal of an electric telegraph based on static electricity?
3
When did Ronalds get patent of his invention firstly?
4
Ronalds first made it known and revealed the applicable significance of his telegram to public.
5
The contribution being done by Ronalds' invention in meteorological data

1 ____ When did Francis Ronalds achieve a satisfactory result in the electricity experiment conducted first time?$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('244350d3-e5c8-5568-8ab7-ca4febfc2b4a', '4d5892a1-858a-5135-b60b-8cf4cef2c410', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ba2489bd-9cb6-5db7-89c2-c259f8c4fa0f', '4d5892a1-858a-5135-b60b-8cf4cef2c410', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('63a787d7-ade6-514f-bf8e-5248472d828e', '4d5892a1-858a-5135-b60b-8cf4cef2c410', 3, $md$C$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('43b31844-b9b9-51eb-893f-60c1fd098f1f', '4d5892a1-858a-5135-b60b-8cf4cef2c410', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('298598d2-4286-5e67-a863-7e289ee9a021', '4d5892a1-858a-5135-b60b-8cf4cef2c410', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e9918c39-9ca7-52cd-acbe-ebcbcbf147ae', '4d5892a1-858a-5135-b60b-8cf4cef2c410', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c2466e55-0159-5937-a701-07968fd97f1f', '4d5892a1-858a-5135-b60b-8cf4cef2c410', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('4e9765fb-7766-5f0e-a95d-0572e132f36f', '389326cc-32e7-5ed5-ae71-77d9ba63f809', 2, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 2

Question 1-5
Question 1-5
Matching the
each
correct
year
to the
historical event
in the passage,
and write the correct answer into box of 1-5 in the answer sheet
A
1753
B
1806
c
1816
D
1823
E
1825
F
1837
G
1843
1
When did Francis Ronalds achieve a satisfactory result in the electricity experiment conducted first time?
2
When was the first proposal of an electric telegraph based on static electricity?
3
When did Ronalds get patent of his invention firstly?
4
Ronalds first made it known and revealed the applicable significance of his telegram to public.
5
The contribution being done by Ronalds' invention in meteorological data

2 ____ When was the first proposal of an electric telegraph based on static electricity?$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('157908a8-e79e-5401-8ddc-8490880d5129', '4e9765fb-7766-5f0e-a95d-0572e132f36f', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('694f8485-18e6-5a9a-a83b-29d8ae21bf6c', '4e9765fb-7766-5f0e-a95d-0572e132f36f', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('da91e146-aa2a-5c48-b4fc-366d44d5e290', '4e9765fb-7766-5f0e-a95d-0572e132f36f', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('edc587fb-78a1-583d-8cd0-742e8e85c6cc', '4e9765fb-7766-5f0e-a95d-0572e132f36f', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4ffd811f-017b-5566-a04f-5b44a0055def', '4e9765fb-7766-5f0e-a95d-0572e132f36f', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('48f2932c-3d5a-5f4e-a3b0-e9e20550116a', '4e9765fb-7766-5f0e-a95d-0572e132f36f', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('36a343c9-256d-5946-aa21-ef443f2f3af1', '4e9765fb-7766-5f0e-a95d-0572e132f36f', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('f5a32a10-5a90-5560-acc0-e0c837ad7226', '389326cc-32e7-5ed5-ae71-77d9ba63f809', 3, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 3

Question 1-5
Question 1-5
Matching the
each
correct
year
to the
historical event
in the passage,
and write the correct answer into box of 1-5 in the answer sheet
A
1753
B
1806
c
1816
D
1823
E
1825
F
1837
G
1843
1
When did Francis Ronalds achieve a satisfactory result in the electricity experiment conducted first time?
2
When was the first proposal of an electric telegraph based on static electricity?
3
When did Ronalds get patent of his invention firstly?
4
Ronalds first made it known and revealed the applicable significance of his telegram to public.
5
The contribution being done by Ronalds' invention in meteorological data

3 ____ When did Ronalds get patent of his invention firstly?$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9ca91834-1d99-571b-96d7-de3aa6d269c1', 'f5a32a10-5a90-5560-acc0-e0c837ad7226', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1ef463b5-8247-5ea7-8904-2e61fa2b2b4c', 'f5a32a10-5a90-5560-acc0-e0c837ad7226', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6f86f08c-3ec1-5e92-a4b0-92099d99be13', 'f5a32a10-5a90-5560-acc0-e0c837ad7226', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b9202af9-78a3-576f-8be2-d25d344dd52f', 'f5a32a10-5a90-5560-acc0-e0c837ad7226', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('94f64ce8-1862-5cf5-b828-6748b0171337', 'f5a32a10-5a90-5560-acc0-e0c837ad7226', 5, $md$E$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b128d8fa-d7a1-5779-9eb3-199dee17ec27', 'f5a32a10-5a90-5560-acc0-e0c837ad7226', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('dead4dda-a5a4-5f75-b265-edce8ba9f98f', 'f5a32a10-5a90-5560-acc0-e0c837ad7226', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('3cb8f006-999d-52f8-9049-15ccd32a60c0', '389326cc-32e7-5ed5-ae71-77d9ba63f809', 4, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 4

Question 1-5
Question 1-5
Matching the
each
correct
year
to the
historical event
in the passage,
and write the correct answer into box of 1-5 in the answer sheet
A
1753
B
1806
c
1816
D
1823
E
1825
F
1837
G
1843
1
When did Francis Ronalds achieve a satisfactory result in the electricity experiment conducted first time?
2
When was the first proposal of an electric telegraph based on static electricity?
3
When did Ronalds get patent of his invention firstly?
4
Ronalds first made it known and revealed the applicable significance of his telegram to public.
5
The contribution being done by Ronalds' invention in meteorological data

4 ____ Ronalds first made it known and revealed the applicable significance of his telegram to public.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3606acab-8b66-535d-b45c-3ff5f203bb56', '3cb8f006-999d-52f8-9049-15ccd32a60c0', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ce019fef-b29a-5bc2-8f58-e4b4188a34db', '3cb8f006-999d-52f8-9049-15ccd32a60c0', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e08fe85c-f185-5765-8d0b-d97ba6d3c4eb', '3cb8f006-999d-52f8-9049-15ccd32a60c0', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('90c30baf-95e5-5616-ade3-74d1174fa74e', '3cb8f006-999d-52f8-9049-15ccd32a60c0', 4, $md$D$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4c72aa29-5d70-5d1f-9c92-d0bc06478787', '3cb8f006-999d-52f8-9049-15ccd32a60c0', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('47394c10-7b6b-5ae0-9e37-a82b3466e34a', '3cb8f006-999d-52f8-9049-15ccd32a60c0', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2b98a634-9de1-5fcd-92fc-3d706eb7edcf', '3cb8f006-999d-52f8-9049-15ccd32a60c0', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('c58f94b6-12a7-527c-ab94-0d6d3cf0fde1', '389326cc-32e7-5ed5-ae71-77d9ba63f809', 5, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 5

Question 1-5
Question 1-5
Matching the
each
correct
year
to the
historical event
in the passage,
and write the correct answer into box of 1-5 in the answer sheet
A
1753
B
1806
c
1816
D
1823
E
1825
F
1837
G
1843
1
When did Francis Ronalds achieve a satisfactory result in the electricity experiment conducted first time?
2
When was the first proposal of an electric telegraph based on static electricity?
3
When did Ronalds get patent of his invention firstly?
4
Ronalds first made it known and revealed the applicable significance of his telegram to public.
5
The contribution being done by Ronalds' invention in meteorological data

5 ____ The contribution being done by Ronalds' invention in meteorological data$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cb180971-f958-5cf5-9e1c-3d211571b280', 'c58f94b6-12a7-527c-ab94-0d6d3cf0fde1', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('214e272a-dea1-566b-a7d7-95a188697934', 'c58f94b6-12a7-527c-ab94-0d6d3cf0fde1', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('928f9f44-c3c6-5966-b8c5-9c95c321bcd0', 'c58f94b6-12a7-527c-ab94-0d6d3cf0fde1', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cdb9bb0c-b00c-55c0-9d83-60b40deb9083', 'c58f94b6-12a7-527c-ab94-0d6d3cf0fde1', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5fc08558-d61d-500e-89b1-e70e777c0600', 'c58f94b6-12a7-527c-ab94-0d6d3cf0fde1', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f2dcc00c-44c5-5e1c-b064-564bf1f8929d', 'c58f94b6-12a7-527c-ab94-0d6d3cf0fde1', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('56cebf37-a136-5ea7-9aa9-22903be667f1', 'c58f94b6-12a7-527c-ab94-0d6d3cf0fde1', 7, $md$G$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('94baf431-6ada-5345-b896-4c3d00050f42', '389326cc-32e7-5ed5-ae71-77d9ba63f809', 6, 'SHORT_ANSWER', 'READING', 3, $md$### Question 6

Question 6-9
Question 6-9
Answer the questions below.
Choose
NO MORE THAN FOUR WORDS AND/OR A NUMBER
from the passage for each answer.
Write your answers in boxes 6-9 on your answer sheet.
6. What were carved in the experimental dials when doing Ronalds' experiment this in garden?
6
7. What were enclosed with the buried telegram wires when Ronalds did the improved experiment?
7
8. What is the greatest distance Ronalds believed his telegram can send?
8
9. What kind of power supplied to keeping the wire charged continuously?
9

6. What were carved in the experimental dials when doing Ronalds' experiment this in garden? 6 ____$md$, NULL, ARRAY['.*letters.*and.*numbers.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('0cf06981-ec16-593e-b8dc-223a332f83fc', '389326cc-32e7-5ed5-ae71-77d9ba63f809', 7, 'SHORT_ANSWER', 'READING', 3, $md$### Question 7

Question 6-9
Question 6-9
Answer the questions below.
Choose
NO MORE THAN FOUR WORDS AND/OR A NUMBER
from the passage for each answer.
Write your answers in boxes 6-9 on your answer sheet.
6. What were carved in the experimental dials when doing Ronalds' experiment this in garden?
6
7. What were enclosed with the buried telegram wires when Ronalds did the improved experiment?
7
8. What is the greatest distance Ronalds believed his telegram can send?
8
9. What kind of power supplied to keeping the wire charged continuously?
9

7. What were enclosed with the buried telegram wires when Ronalds did the improved experiment? 7 ____$md$, NULL, ARRAY['.*glass.*tubes.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('38cbe986-2467-553a-b31d-36cb5b5276d8', '389326cc-32e7-5ed5-ae71-77d9ba63f809', 8, 'SHORT_ANSWER', 'READING', 3, $md$### Question 8

Question 6-9
Question 6-9
Answer the questions below.
Choose
NO MORE THAN FOUR WORDS AND/OR A NUMBER
from the passage for each answer.
Write your answers in boxes 6-9 on your answer sheet.
6. What were carved in the experimental dials when doing Ronalds' experiment this in garden?
6
7. What were enclosed with the buried telegram wires when Ronalds did the improved experiment?
7
8. What is the greatest distance Ronalds believed his telegram can send?
8
9. What kind of power supplied to keeping the wire charged continuously?
9

8. What is the greatest distance Ronalds believed his telegram can send? 8 ____$md$, NULL, ARRAY['.*800km.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('1efec92a-c0d1-512a-94f7-c9cc9c9acb4e', '389326cc-32e7-5ed5-ae71-77d9ba63f809', 9, 'SHORT_ANSWER', 'READING', 3, $md$### Question 9

Question 6-9
Question 6-9
Answer the questions below.
Choose
NO MORE THAN FOUR WORDS AND/OR A NUMBER
from the passage for each answer.
Write your answers in boxes 6-9 on your answer sheet.
6. What were carved in the experimental dials when doing Ronalds' experiment this in garden?
6
7. What were enclosed with the buried telegram wires when Ronalds did the improved experiment?
7
8. What is the greatest distance Ronalds believed his telegram can send?
8
9. What kind of power supplied to keeping the wire charged continuously?
9

9. What kind of power supplied to keeping the wire charged continuously? 9 ____$md$, NULL, ARRAY['.*frictional.*electricity.*machine.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('6f17033b-4153-5e6f-ae43-1c084cf6f2d0', '389326cc-32e7-5ed5-ae71-77d9ba63f809', 10, 'MATCHING_INFORMATION', 'READING', 4, $md$### Question 10

Question 10-14
Question 10-14
The passage has paragraphs as A-l; which paragraph contains the following information?
Write the appropriate letter A-l for box 10-14 on your answer sheet.
10
the fundamental aims of mapmaking remain unchanged.
11
the possibilities of satellite mapping are infinite.
12
There is a commercial use of the telegram.
13
There is a contributory influence on Ronalds from a fellow he got to know.
14
Ronalds’s proposal was rejected as the preceding reference to another application.

10 ____ the fundamental aims of mapmaking remain unchanged. 11 ____ the possibilities of satellite mapping are infinite. 12 ____ There is a commercial use of the telegram. 13 ____ There is a contributory influence on Ronalds from a fellow he got to know. 14 ____ Ronalds’s proposal was rejected as the preceding reference to another application.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('99b6056a-524d-5e1f-b8de-f0ba54e0330a', '6f17033b-4153-5e6f-ae43-1c084cf6f2d0', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b4b3e0cb-0373-56f1-b04d-84ba13973a79', '6f17033b-4153-5e6f-ae43-1c084cf6f2d0', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c5667897-d534-553d-9a13-5e6297a770b3', '6f17033b-4153-5e6f-ae43-1c084cf6f2d0', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d8ac9e25-805c-5f3d-9d65-1e506e894664', '6f17033b-4153-5e6f-ae43-1c084cf6f2d0', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('04fcce3c-a081-5620-8eca-b89231d42583', '6f17033b-4153-5e6f-ae43-1c084cf6f2d0', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('970a85e8-8a6b-53f6-9347-d41abff540c7', '6f17033b-4153-5e6f-ae43-1c084cf6f2d0', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cf17da36-4e46-5503-a152-68564109e4ae', '6f17033b-4153-5e6f-ae43-1c084cf6f2d0', 7, $md$G$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('dfeebc1d-e000-5ce0-9b7a-85a2a17a6624', '6f17033b-4153-5e6f-ae43-1c084cf6f2d0', 8, $md$H$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('df2250f9-3c4f-582f-94c6-e9c5450aca7d', '6f17033b-4153-5e6f-ae43-1c084cf6f2d0', 9, $md$I$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('7d7ecbba-d3c2-5828-8d5d-fc10d50f02b7', '389326cc-32e7-5ed5-ae71-77d9ba63f809', 11, 'MATCHING_INFORMATION', 'READING', 4, $md$### Question 11

Question 10-14
Question 10-14
The passage has paragraphs as A-l; which paragraph contains the following information?
Write the appropriate letter A-l for box 10-14 on your answer sheet.
10
the fundamental aims of mapmaking remain unchanged.
11
the possibilities of satellite mapping are infinite.
12
There is a commercial use of the telegram.
13
There is a contributory influence on Ronalds from a fellow he got to know.
14
Ronalds’s proposal was rejected as the preceding reference to another application.

10 ____ the fundamental aims of mapmaking remain unchanged. 11 ____ the possibilities of satellite mapping are infinite. 12 ____ There is a commercial use of the telegram. 13 ____ There is a contributory influence on Ronalds from a fellow he got to know. 14 ____ Ronalds’s proposal was rejected as the preceding reference to another application.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0f5c1eb4-dcfb-54f0-883c-212cafdd20f0', '7d7ecbba-d3c2-5828-8d5d-fc10d50f02b7', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0bfceae0-4fe7-52f9-a871-4e8ee4401aa7', '7d7ecbba-d3c2-5828-8d5d-fc10d50f02b7', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('25a79e1c-817c-5b49-8532-b485662128ac', '7d7ecbba-d3c2-5828-8d5d-fc10d50f02b7', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8c120761-718f-5aa0-b1ff-cd2e8af17eac', '7d7ecbba-d3c2-5828-8d5d-fc10d50f02b7', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('693a7ef7-6141-55e8-9b19-11c22d768d17', '7d7ecbba-d3c2-5828-8d5d-fc10d50f02b7', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bb0317f3-971c-5a59-9aec-767e006dbf0b', '7d7ecbba-d3c2-5828-8d5d-fc10d50f02b7', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('46c72e38-cd58-5677-b38f-afe85ef05322', '7d7ecbba-d3c2-5828-8d5d-fc10d50f02b7', 7, $md$G$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('583842f1-d2a3-5602-8d3c-87dc694adead', '7d7ecbba-d3c2-5828-8d5d-fc10d50f02b7', 8, $md$H$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('eac7e642-15f6-5c92-af05-7c1b76e74bb2', '7d7ecbba-d3c2-5828-8d5d-fc10d50f02b7', 9, $md$I$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('c4f706e6-a13b-5125-a8df-b0cd64341c0a', '389326cc-32e7-5ed5-ae71-77d9ba63f809', 12, 'MATCHING_INFORMATION', 'READING', 4, $md$### Question 12

Question 10-14
Question 10-14
The passage has paragraphs as A-l; which paragraph contains the following information?
Write the appropriate letter A-l for box 10-14 on your answer sheet.
10
the fundamental aims of mapmaking remain unchanged.
11
the possibilities of satellite mapping are infinite.
12
There is a commercial use of the telegram.
13
There is a contributory influence on Ronalds from a fellow he got to know.
14
Ronalds’s proposal was rejected as the preceding reference to another application.

10 ____ the fundamental aims of mapmaking remain unchanged. 11 ____ the possibilities of satellite mapping are infinite. 12 ____ There is a commercial use of the telegram. 13 ____ There is a contributory influence on Ronalds from a fellow he got to know. 14 ____ Ronalds’s proposal was rejected as the preceding reference to another application.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('abcc3fc3-4e9e-50cd-8645-c75e2ecdd074', 'c4f706e6-a13b-5125-a8df-b0cd64341c0a', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f991feaf-a8de-5e12-b681-8375ba93f5c4', 'c4f706e6-a13b-5125-a8df-b0cd64341c0a', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('700db6e7-b980-5fe4-9985-fc7d2e94e153', 'c4f706e6-a13b-5125-a8df-b0cd64341c0a', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('52fa4016-ef49-5143-9dfa-bc8322d42e88', 'c4f706e6-a13b-5125-a8df-b0cd64341c0a', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a39906bc-19e3-572e-ba19-0b34ddb9898e', 'c4f706e6-a13b-5125-a8df-b0cd64341c0a', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('90d2b085-4c00-5436-aa8f-74bb8c21688d', 'c4f706e6-a13b-5125-a8df-b0cd64341c0a', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8b2b161e-be27-59ff-9447-c4469a6274f9', 'c4f706e6-a13b-5125-a8df-b0cd64341c0a', 7, $md$G$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a10d1289-ed52-512c-adb9-47d040544257', 'c4f706e6-a13b-5125-a8df-b0cd64341c0a', 8, $md$H$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6ea53de5-cae8-50bb-a0f4-0064b099540f', 'c4f706e6-a13b-5125-a8df-b0cd64341c0a', 9, $md$I$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('852ff986-81ab-5f77-83c1-a51b52f429c6', '389326cc-32e7-5ed5-ae71-77d9ba63f809', 13, 'MATCHING_INFORMATION', 'READING', 4, $md$### Question 13

Question 10-14
Question 10-14
The passage has paragraphs as A-l; which paragraph contains the following information?
Write the appropriate letter A-l for box 10-14 on your answer sheet.
10
the fundamental aims of mapmaking remain unchanged.
11
the possibilities of satellite mapping are infinite.
12
There is a commercial use of the telegram.
13
There is a contributory influence on Ronalds from a fellow he got to know.
14
Ronalds’s proposal was rejected as the preceding reference to another application.

10 ____ the fundamental aims of mapmaking remain unchanged. 11 ____ the possibilities of satellite mapping are infinite. 12 ____ There is a commercial use of the telegram. 13 ____ There is a contributory influence on Ronalds from a fellow he got to know. 14 ____ Ronalds’s proposal was rejected as the preceding reference to another application.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5c936037-c77e-5021-84f8-2fab989b3c69', '852ff986-81ab-5f77-83c1-a51b52f429c6', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3331eee9-bf8c-54cc-a38f-85bd352f40eb', '852ff986-81ab-5f77-83c1-a51b52f429c6', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d3c0956d-95d8-5b81-8d92-02612e422cf0', '852ff986-81ab-5f77-83c1-a51b52f429c6', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bfd40d2c-d066-5f9d-b918-1b1bbd331b40', '852ff986-81ab-5f77-83c1-a51b52f429c6', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1576adb8-9dec-5a8e-ab4d-c61927e5eed7', '852ff986-81ab-5f77-83c1-a51b52f429c6', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a7773431-70ed-5ba2-8d6c-67d581375b3f', '852ff986-81ab-5f77-83c1-a51b52f429c6', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('25f750b0-82f8-568d-9a45-552ef5db28a3', '852ff986-81ab-5f77-83c1-a51b52f429c6', 7, $md$G$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ac892107-2fdc-5edb-aaac-8f690ec6e6e9', '852ff986-81ab-5f77-83c1-a51b52f429c6', 8, $md$H$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('17c8211e-0280-54c5-92e8-9e0805fb9bc1', '852ff986-81ab-5f77-83c1-a51b52f429c6', 9, $md$I$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('5b3a3fa3-ab85-55a3-b335-0e9574f7d91d', '389326cc-32e7-5ed5-ae71-77d9ba63f809', 14, 'MATCHING_INFORMATION', 'READING', 4, $md$### Question 14

Question 10-14
Question 10-14
The passage has paragraphs as A-l; which paragraph contains the following information?
Write the appropriate letter A-l for box 10-14 on your answer sheet.
10
the fundamental aims of mapmaking remain unchanged.
11
the possibilities of satellite mapping are infinite.
12
There is a commercial use of the telegram.
13
There is a contributory influence on Ronalds from a fellow he got to know.
14
Ronalds’s proposal was rejected as the preceding reference to another application.

10 ____ the fundamental aims of mapmaking remain unchanged. 11 ____ the possibilities of satellite mapping are infinite. 12 ____ There is a commercial use of the telegram. 13 ____ There is a contributory influence on Ronalds from a fellow he got to know. 14 ____ Ronalds’s proposal was rejected as the preceding reference to another application.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a2de0808-d3c1-5195-812d-b53355bd5eb0', '5b3a3fa3-ab85-55a3-b335-0e9574f7d91d', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d496e25b-e532-5ff3-a21a-1055b4633793', '5b3a3fa3-ab85-55a3-b335-0e9574f7d91d', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f029b6d9-a407-5b52-9bda-11904392dadf', '5b3a3fa3-ab85-55a3-b335-0e9574f7d91d', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('38c51f53-74de-566b-8092-79e1bc31be3d', '5b3a3fa3-ab85-55a3-b335-0e9574f7d91d', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3beedd42-1cea-58d7-9706-efba91551d15', '5b3a3fa3-ab85-55a3-b335-0e9574f7d91d', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2846815d-27f7-5feb-aa7d-5fd98ec4ad25', '5b3a3fa3-ab85-55a3-b335-0e9574f7d91d', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0f2f2ea0-c543-57dd-ab39-7a5d1961dc15', '5b3a3fa3-ab85-55a3-b335-0e9574f7d91d', 7, $md$G$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b268225d-87a5-5349-9537-68f30e852746', '5b3a3fa3-ab85-55a3-b335-0e9574f7d91d', 8, $md$H$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('602e9b2e-73a7-5b94-93a4-77e94b59ed8d', '5b3a3fa3-ab85-55a3-b335-0e9574f7d91d', 9, $md$I$md$, false);

COMMIT;
