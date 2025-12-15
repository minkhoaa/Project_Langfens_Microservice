BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-william-gilbert-and-magnetism-1027'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-william-gilbert-and-magnetism-1027';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-william-gilbert-and-magnetism-1027';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-william-gilbert-and-magnetism-1027';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('1b13f942-330a-5175-b295-81042e2969e8', 'ielts-reading-william-gilbert-and-magnetism-1027', $t$William Gilbert and Magnetism$t$, $md$## William Gilbert and Magnetism

Nguồn:
- Test: https://mini-ielts.com/1027/reading/william-gilbert-and-magnetism
- Solution: https://mini-ielts.com/1027/view-solution/reading/william-gilbert-and-magnetism$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('2af2263d-c511-599c-9907-7f3ab11911fe', '1b13f942-330a-5175-b295-81042e2969e8', 1, $t$Reading — William Gilbert and Magnetism$t$, $md$Read the passage and answer questions **1–10**.

### Passage: William Gilbert and Magnetism

A - Pioneers of the early science

The 16th and 17th centuries saw two great pioneers of modern science : Galileo and Gilbert. The impact of their findings is eminent. Gilbert was the first modern scientist, also the accredited father of the science of electricity and magnetism, an Englishman of learning and a physician at the court of Elizabeth. Prior to him, all that was known of electricity and magnetism was what the ancients knew, nothing more than that the lodestone possessed magnetic properties and that amber and jet, when rubbed, would attract bits of paper or other substances of small specific gravity. However, he is less well known than he deserves .

B - Early years of Gilbert

Gilbert’s birth pre-dated Galileo . Born in an eminent local family in Colchester County in the UK, on May 24, 1544, he went to grammar school, and then studied medicine at St John’s College, Cambridge, graduating in 1573. Later he travelled in the continent and eventually settled down in London.

C - Professional and social recognition

He was a very successful and eminent doctor . All this culminated in his election to the president of the Royal Science Society. He was also appointed personal physician to the Queen (Elizabeth I), and later knighted by the Queen. Lie faith­fully served her until her death. However, he didn’t outlive the Queen for long and died on November 30, 1603, only a few months after his appointment as personal physician to King James.

D - His change of focus

Gilbert was first interested in chemistry but later changed his focus due to the large portion of mysticism of alchemy involved (such as the transmutation of metal). He gradually developed his interest in physics after the great minds of the ancient, particularly about the knowledge the ancient Greeks had about lodestones, strange minerals with the power to attract iron. In the meantime, Britain became a major seafaring nation in 1588 when the Spanish Armada was defeat­ed, opening the way to British settlement of America. British ships depended on the magnetic compass, yet no one understood why it worked. Did the Pole Star attract it, as Columbus once speculated; or was there a magnetic mountain at the pole, as described in Odyssey, which ships would never approach, because the sail­ors thought its pull would yank out all their iron nails and fittings? For nearly 20 years, William Gilbert conducted ingenious experiments to understand magnet­ism. His works include On the Magnet, Magnetic Bodies, and the Great Magnet of the Earth.

E - His discovery about magnetism

Gilbert’s discovery was so important to modern physics. He investigated the nature of magnetism and electricity . He even coined the word “electric”. Though the early beliefs of magnetism were also largely entangled with superstitions such as that rubbing garlic on lodestone can neutralise its magnetism, one example being that sailors even believed the smell of garlic would even interfere with the action of compass, which is why helmsmen were forbidden to eat it near a ship’s compass. Gilbert also found that metals can be magnetised by rubbing mater­ials such as fur, plastic or the like on them. He named the ends of a magnet “north pole” and “south pole”. The magnetic poles can attract or repel, depending on polarity. In addition, however, ordinary iron is always attracted to a magnet. Though he started to study the relationship between magnetism and electricity, sadly he didn’t complete it. His research of static electricity using amber and jet only demonstrated that objects with electrical charges can work like magnets attracting small pieces of paper and stuff. It is a French guy named du Fay that discovered that there are actually two electrical charges, positive and negative.

F - Questioning traditional astronomy

He also questioned the traditional astronomical beliefs . Though a Copernican, he didn’t express in his quintessential beliefs whether the earth is at the centre of the universe or in orbit around the sun. However, he believed that stars are not equidistant from the earth but have their own earth-like planets orbiting around them . The earth itself is like a giant magnet, which is also why compasses always point north. They spin on an axis that is aligned with the earth’s polarity . He even likened the polarity of the magnet to the polarity of the earth and built an entire magnetic philosophy on this analogy. In his explanation, magnetism is the soul of the earth. Thus a perfectly spherical lodestone, when aligned with the earth’s poles, would wobble all by itself in 24 hours. Further, he also believed that the sun and other stars wobble just like the earth does around a crystal core, and speculated that the moon might also be a magnet caused to orbit by its magnetic attraction to the earth. This was perhaps the first proposal that a force might cause a heavenly orbit.

G - What was new about his scientific research method

His research method was revolutionary in that he used experiments rather than pure logic and reasoning like the ancient Greek philosophers did. It was a new attitude towards scientific investigation. Until then, scientific experiments were not in fashion. It was because of this scientific attitude, together with his contri­bution to our knowledge of magnetism, that a unit of magneto motive force, also known as magnetic potential, was named Gilbert in his honour. His approach of careful observation and experimentation rather than the authoritative opinion or deductive philosophy of others had laid the very foundation for modern science.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('bbffe73b-ef0d-5505-b0ba-07cf10486930', '2af2263d-c511-599c-9907-7f3ab11911fe', 1, 'MATCHING_HEADING', 'READING', 2, $md$### Question 1

Questions 1-7
Questions 1-7
Reading Passage has seven paragraphs
A-G
.
Choose the correct heading for each paragraph from the list of headings below.
Write the correct number
i-x
in boxes
1-7
on your answer sheet.
List of headings
i
Early years of Gilbert
ii
What was new about his scientific research method
iii
The development of chemistry
iv
Questioning traditional astronomy
v
Pioneers of the early science
vi
Professional and social recognition
vii
Becoming the president of the Royal Science Society
viii
The great works of Gilbert
ix
His discovery about magnetism
x
His change of focus
1
Paragraph A
Locate
2
Paragraph B
Locate
3
Paragraph C
Locate
4
Paragraph D
Locate
5
Paragraph E
Locate
6
Paragraph F
Locate
7
Paragraph G
Locate

1 ____ Paragraph A Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c83e58ba-55db-5075-a448-9be08d21af08', 'bbffe73b-ef0d-5505-b0ba-07cf10486930', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9a135302-4798-54dd-ba44-0a61f046ce22', 'bbffe73b-ef0d-5505-b0ba-07cf10486930', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('22dfaa1a-466d-5e18-b09b-77f27f96b248', 'bbffe73b-ef0d-5505-b0ba-07cf10486930', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('480f5653-bb68-5859-b301-235c03100484', 'bbffe73b-ef0d-5505-b0ba-07cf10486930', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('106f0586-723c-5dd2-8c7d-f22c175f1468', 'bbffe73b-ef0d-5505-b0ba-07cf10486930', 5, $md$v$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('21831718-e758-50b6-a4d0-6c215181f53e', 'bbffe73b-ef0d-5505-b0ba-07cf10486930', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1a5ad3d4-8fc9-55b3-a0c8-a06b4a836e7d', 'bbffe73b-ef0d-5505-b0ba-07cf10486930', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('09702f13-8bae-5b30-9ac1-06808ab6c826', 'bbffe73b-ef0d-5505-b0ba-07cf10486930', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b1b8a6e6-08bd-563c-8494-d2cb17b42336', 'bbffe73b-ef0d-5505-b0ba-07cf10486930', 9, $md$ix$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('170d994d-f1b9-50c2-a19a-f40a90748888', 'bbffe73b-ef0d-5505-b0ba-07cf10486930', 10, $md$x$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('7cb2ba84-37ef-51ea-b66b-cd489442064e', '2af2263d-c511-599c-9907-7f3ab11911fe', 2, 'MATCHING_HEADING', 'READING', 2, $md$### Question 2

Questions 1-7
Questions 1-7
Reading Passage has seven paragraphs
A-G
.
Choose the correct heading for each paragraph from the list of headings below.
Write the correct number
i-x
in boxes
1-7
on your answer sheet.
List of headings
i
Early years of Gilbert
ii
What was new about his scientific research method
iii
The development of chemistry
iv
Questioning traditional astronomy
v
Pioneers of the early science
vi
Professional and social recognition
vii
Becoming the president of the Royal Science Society
viii
The great works of Gilbert
ix
His discovery about magnetism
x
His change of focus
1
Paragraph A
Locate
2
Paragraph B
Locate
3
Paragraph C
Locate
4
Paragraph D
Locate
5
Paragraph E
Locate
6
Paragraph F
Locate
7
Paragraph G
Locate

2 ____ Paragraph B Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b6daf0d1-ca02-5397-8592-b60e288fedaf', '7cb2ba84-37ef-51ea-b66b-cd489442064e', 1, $md$i$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('137ae4c9-80ab-51e9-b7a9-566c2ac8af78', '7cb2ba84-37ef-51ea-b66b-cd489442064e', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c6853f64-25c0-56f8-9add-21b5925f3e0c', '7cb2ba84-37ef-51ea-b66b-cd489442064e', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('eec957f8-4b5e-5532-b724-6df080112a44', '7cb2ba84-37ef-51ea-b66b-cd489442064e', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('be21bd1a-eacb-52fa-b97d-f4b5ef393a06', '7cb2ba84-37ef-51ea-b66b-cd489442064e', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('020caff7-317f-5872-950e-7a2d458c0ee2', '7cb2ba84-37ef-51ea-b66b-cd489442064e', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e29cb071-6d12-50a2-bd4a-74754989eef4', '7cb2ba84-37ef-51ea-b66b-cd489442064e', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('51892079-1ba1-5f6f-b4de-130420063f6b', '7cb2ba84-37ef-51ea-b66b-cd489442064e', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('69aea88c-d7ae-52c0-83fe-14faae48b253', '7cb2ba84-37ef-51ea-b66b-cd489442064e', 9, $md$ix$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4c954a7d-6900-5a38-816b-eb6f3de2510d', '7cb2ba84-37ef-51ea-b66b-cd489442064e', 10, $md$x$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('da6fca06-474e-51d7-b8ba-920f0dfa864f', '2af2263d-c511-599c-9907-7f3ab11911fe', 3, 'MATCHING_HEADING', 'READING', 2, $md$### Question 3

Questions 1-7
Questions 1-7
Reading Passage has seven paragraphs
A-G
.
Choose the correct heading for each paragraph from the list of headings below.
Write the correct number
i-x
in boxes
1-7
on your answer sheet.
List of headings
i
Early years of Gilbert
ii
What was new about his scientific research method
iii
The development of chemistry
iv
Questioning traditional astronomy
v
Pioneers of the early science
vi
Professional and social recognition
vii
Becoming the president of the Royal Science Society
viii
The great works of Gilbert
ix
His discovery about magnetism
x
His change of focus
1
Paragraph A
Locate
2
Paragraph B
Locate
3
Paragraph C
Locate
4
Paragraph D
Locate
5
Paragraph E
Locate
6
Paragraph F
Locate
7
Paragraph G
Locate

3 ____ Paragraph C Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e2f57cb8-4860-5131-8fe6-de6477e9bfcf', 'da6fca06-474e-51d7-b8ba-920f0dfa864f', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5fe10b02-29b6-58a1-8d04-3a22782a2d25', 'da6fca06-474e-51d7-b8ba-920f0dfa864f', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e5cec104-3ad9-5c77-b242-604553e53398', 'da6fca06-474e-51d7-b8ba-920f0dfa864f', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('db04a4f4-9b61-5e7a-95f6-b2d506ddbb8b', 'da6fca06-474e-51d7-b8ba-920f0dfa864f', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e9b8a5bc-1b9f-5929-b421-0c6639411d23', 'da6fca06-474e-51d7-b8ba-920f0dfa864f', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2a7f368c-b55d-5365-8ea3-5d05c2743ee9', 'da6fca06-474e-51d7-b8ba-920f0dfa864f', 6, $md$vi$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9dde98ee-9a5d-5735-b497-878787410ebf', 'da6fca06-474e-51d7-b8ba-920f0dfa864f', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d2981756-b5ff-537c-a71d-9d94d8112144', 'da6fca06-474e-51d7-b8ba-920f0dfa864f', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e3f01d3a-3153-5dd9-a02b-68f1eae6b278', 'da6fca06-474e-51d7-b8ba-920f0dfa864f', 9, $md$ix$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6b79d2c1-2170-501f-8fc2-324b241b9ebc', 'da6fca06-474e-51d7-b8ba-920f0dfa864f', 10, $md$x$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('4ce31988-8867-5746-a705-d8e07b5331f4', '2af2263d-c511-599c-9907-7f3ab11911fe', 4, 'MATCHING_HEADING', 'READING', 2, $md$### Question 4

Questions 1-7
Questions 1-7
Reading Passage has seven paragraphs
A-G
.
Choose the correct heading for each paragraph from the list of headings below.
Write the correct number
i-x
in boxes
1-7
on your answer sheet.
List of headings
i
Early years of Gilbert
ii
What was new about his scientific research method
iii
The development of chemistry
iv
Questioning traditional astronomy
v
Pioneers of the early science
vi
Professional and social recognition
vii
Becoming the president of the Royal Science Society
viii
The great works of Gilbert
ix
His discovery about magnetism
x
His change of focus
1
Paragraph A
Locate
2
Paragraph B
Locate
3
Paragraph C
Locate
4
Paragraph D
Locate
5
Paragraph E
Locate
6
Paragraph F
Locate
7
Paragraph G
Locate

4 ____ Paragraph D Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2902644e-ef36-5bc7-b788-ef31beec31cf', '4ce31988-8867-5746-a705-d8e07b5331f4', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8a7e19a3-2ed7-53f0-9777-f723e8802ca0', '4ce31988-8867-5746-a705-d8e07b5331f4', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('31d12f72-fa7e-57e2-aeac-18c2c2dbf074', '4ce31988-8867-5746-a705-d8e07b5331f4', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('806de1a4-5fe0-5272-932f-a99da03e312e', '4ce31988-8867-5746-a705-d8e07b5331f4', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('35347126-f0f8-5231-9200-7a7fdb53d11f', '4ce31988-8867-5746-a705-d8e07b5331f4', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('82524cf2-dbc2-5ef7-a41c-0b4fd85e6b4b', '4ce31988-8867-5746-a705-d8e07b5331f4', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ffe34b97-336f-53c4-92fc-8bb29befab98', '4ce31988-8867-5746-a705-d8e07b5331f4', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a7dbc9f2-d4cf-5e37-b852-ed31ee8dbf07', '4ce31988-8867-5746-a705-d8e07b5331f4', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d84a616f-1685-5222-b7e2-e3a8f79ddf23', '4ce31988-8867-5746-a705-d8e07b5331f4', 9, $md$ix$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5289c9ac-0046-5532-bb17-de67e9b1eac8', '4ce31988-8867-5746-a705-d8e07b5331f4', 10, $md$x$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('4b46fec6-0414-5afe-9c24-fda7b816e1af', '2af2263d-c511-599c-9907-7f3ab11911fe', 5, 'MATCHING_HEADING', 'READING', 3, $md$### Question 5

Questions 1-7
Questions 1-7
Reading Passage has seven paragraphs
A-G
.
Choose the correct heading for each paragraph from the list of headings below.
Write the correct number
i-x
in boxes
1-7
on your answer sheet.
List of headings
i
Early years of Gilbert
ii
What was new about his scientific research method
iii
The development of chemistry
iv
Questioning traditional astronomy
v
Pioneers of the early science
vi
Professional and social recognition
vii
Becoming the president of the Royal Science Society
viii
The great works of Gilbert
ix
His discovery about magnetism
x
His change of focus
1
Paragraph A
Locate
2
Paragraph B
Locate
3
Paragraph C
Locate
4
Paragraph D
Locate
5
Paragraph E
Locate
6
Paragraph F
Locate
7
Paragraph G
Locate

5 ____ Paragraph E Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0492ddac-7aee-5f76-8aa9-bfbf18dfe372', '4b46fec6-0414-5afe-9c24-fda7b816e1af', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4df19850-fd73-51b9-99eb-70f4623382c5', '4b46fec6-0414-5afe-9c24-fda7b816e1af', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b34a81be-b0e9-5f6a-a220-823126bc0e8d', '4b46fec6-0414-5afe-9c24-fda7b816e1af', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('136634d2-46d6-5dce-b28e-424b96f6e509', '4b46fec6-0414-5afe-9c24-fda7b816e1af', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a2631db0-13c9-5e5d-a224-c4bf0be4394e', '4b46fec6-0414-5afe-9c24-fda7b816e1af', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('928417c3-e6f1-53b8-8582-3942fce02549', '4b46fec6-0414-5afe-9c24-fda7b816e1af', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7a55be0b-0096-5ff9-afd1-5de944796761', '4b46fec6-0414-5afe-9c24-fda7b816e1af', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('dd1f69b0-8761-5b06-9d41-f5968d65fbbb', '4b46fec6-0414-5afe-9c24-fda7b816e1af', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('350bb468-c8a6-5ccf-a041-149121e0ebe9', '4b46fec6-0414-5afe-9c24-fda7b816e1af', 9, $md$ix$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('22bbeb0f-776a-5b85-b99b-0074c16628f3', '4b46fec6-0414-5afe-9c24-fda7b816e1af', 10, $md$x$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('610e4110-2ab8-51b4-a38b-4f222837428b', '2af2263d-c511-599c-9907-7f3ab11911fe', 6, 'MATCHING_HEADING', 'READING', 3, $md$### Question 6

Questions 1-7
Questions 1-7
Reading Passage has seven paragraphs
A-G
.
Choose the correct heading for each paragraph from the list of headings below.
Write the correct number
i-x
in boxes
1-7
on your answer sheet.
List of headings
i
Early years of Gilbert
ii
What was new about his scientific research method
iii
The development of chemistry
iv
Questioning traditional astronomy
v
Pioneers of the early science
vi
Professional and social recognition
vii
Becoming the president of the Royal Science Society
viii
The great works of Gilbert
ix
His discovery about magnetism
x
His change of focus
1
Paragraph A
Locate
2
Paragraph B
Locate
3
Paragraph C
Locate
4
Paragraph D
Locate
5
Paragraph E
Locate
6
Paragraph F
Locate
7
Paragraph G
Locate

6 ____ Paragraph F Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f075eb33-d19f-5799-b65b-526658946a94', '610e4110-2ab8-51b4-a38b-4f222837428b', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c2b07c93-ca80-5338-a499-3cc613baf264', '610e4110-2ab8-51b4-a38b-4f222837428b', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('332413a9-ed94-528e-9132-a2c1fcec5155', '610e4110-2ab8-51b4-a38b-4f222837428b', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c600c60f-4332-5674-9559-d09f0ad1265f', '610e4110-2ab8-51b4-a38b-4f222837428b', 4, $md$iv$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e12d230b-d418-50cd-8527-a3b2f10a6dd5', '610e4110-2ab8-51b4-a38b-4f222837428b', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e80bb031-cb63-5d9e-a67a-ce2a1d4ac7f8', '610e4110-2ab8-51b4-a38b-4f222837428b', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('347c6fe5-125e-519d-a79c-95cc4625d557', '610e4110-2ab8-51b4-a38b-4f222837428b', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2cc230b7-7bf4-5944-a852-742eee140811', '610e4110-2ab8-51b4-a38b-4f222837428b', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f82efc82-eaea-5210-84c8-677d492518c2', '610e4110-2ab8-51b4-a38b-4f222837428b', 9, $md$ix$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('18d55500-c91f-5478-b0e5-51b87cd56c76', '610e4110-2ab8-51b4-a38b-4f222837428b', 10, $md$x$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('45758b90-f875-5fb6-84f8-f1e4c2c9fa4d', '2af2263d-c511-599c-9907-7f3ab11911fe', 7, 'MATCHING_HEADING', 'READING', 3, $md$### Question 7

Questions 1-7
Questions 1-7
Reading Passage has seven paragraphs
A-G
.
Choose the correct heading for each paragraph from the list of headings below.
Write the correct number
i-x
in boxes
1-7
on your answer sheet.
List of headings
i
Early years of Gilbert
ii
What was new about his scientific research method
iii
The development of chemistry
iv
Questioning traditional astronomy
v
Pioneers of the early science
vi
Professional and social recognition
vii
Becoming the president of the Royal Science Society
viii
The great works of Gilbert
ix
His discovery about magnetism
x
His change of focus
1
Paragraph A
Locate
2
Paragraph B
Locate
3
Paragraph C
Locate
4
Paragraph D
Locate
5
Paragraph E
Locate
6
Paragraph F
Locate
7
Paragraph G
Locate

7 ____ Paragraph G Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('47300e62-120b-5e03-8bd1-ea8173df2e0f', '45758b90-f875-5fb6-84f8-f1e4c2c9fa4d', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a9a20a7d-db31-59d2-80c9-5d73467bdd60', '45758b90-f875-5fb6-84f8-f1e4c2c9fa4d', 2, $md$ii$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9f3cbc3f-4584-5d1f-8f76-a77aa82a69a2', '45758b90-f875-5fb6-84f8-f1e4c2c9fa4d', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3b9b7077-cac7-5be7-b4dd-6e7c73ffd872', '45758b90-f875-5fb6-84f8-f1e4c2c9fa4d', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6cb1cddc-1da2-58c2-bd54-25ec77538a80', '45758b90-f875-5fb6-84f8-f1e4c2c9fa4d', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4e703822-c792-52d5-ab6c-f9504c76fa90', '45758b90-f875-5fb6-84f8-f1e4c2c9fa4d', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('36f474af-e400-532a-9758-a1b89bc2af33', '45758b90-f875-5fb6-84f8-f1e4c2c9fa4d', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('df14aca7-0f6f-53ab-addb-b262f8bec505', '45758b90-f875-5fb6-84f8-f1e4c2c9fa4d', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('db2985ae-5465-5ebb-9794-fb3af73c8b4a', '45758b90-f875-5fb6-84f8-f1e4c2c9fa4d', 9, $md$ix$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('72b774e1-ced9-5e7a-b346-002ec20e7d5e', '45758b90-f875-5fb6-84f8-f1e4c2c9fa4d', 10, $md$x$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('1128b9ef-56b5-54aa-afce-c72444e4c5d8', '2af2263d-c511-599c-9907-7f3ab11911fe', 8, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 8

Questions 8-10
Questions 8-10
Do the following statements agree with the information given in Reading Passage?
In boxes
8-10
on your answer sheet, write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
8
He is less famous than he should be.
Locate
9
He was famous as a doctor before he was employed by the Queen.
Locate
10
He lost faith in the medical theories of his time.

8 ____ He is less famous than he should be. Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('493781dc-e220-5444-8bbd-f8a94aa1d06a', '1128b9ef-56b5-54aa-afce-c72444e4c5d8', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ce97edd6-92c6-5917-8910-b5741cc7c616', '1128b9ef-56b5-54aa-afce-c72444e4c5d8', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4086434a-8083-51a9-8250-2358d5f71a6d', '1128b9ef-56b5-54aa-afce-c72444e4c5d8', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('1195820a-0ac7-5c7a-8b13-7540bf462ac9', '2af2263d-c511-599c-9907-7f3ab11911fe', 9, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 9

Questions 8-10
Questions 8-10
Do the following statements agree with the information given in Reading Passage?
In boxes
8-10
on your answer sheet, write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
8
He is less famous than he should be.
Locate
9
He was famous as a doctor before he was employed by the Queen.
Locate
10
He lost faith in the medical theories of his time.

9 ____ He was famous as a doctor before he was employed by the Queen. Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3d48bb98-8a31-52fc-ae83-c32144f39c55', '1195820a-0ac7-5c7a-8b13-7540bf462ac9', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('dc769b79-50e2-5aab-9c83-ccb657f6acd0', '1195820a-0ac7-5c7a-8b13-7540bf462ac9', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('14ee6be5-25c9-5fd5-9fb7-5aa62ac04703', '1195820a-0ac7-5c7a-8b13-7540bf462ac9', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('4afdd04e-2ff0-551d-a3cf-0b11b29008c7', '2af2263d-c511-599c-9907-7f3ab11911fe', 10, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 10

Questions 8-10
Questions 8-10
Do the following statements agree with the information given in Reading Passage?
In boxes
8-10
on your answer sheet, write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
8
He is less famous than he should be.
Locate
9
He was famous as a doctor before he was employed by the Queen.
Locate
10
He lost faith in the medical theories of his time.

10 ____ He lost faith in the medical theories of his time.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9afb6b99-5ccb-5e99-b215-062ddd8eb7af', '4afdd04e-2ff0-551d-a3cf-0b11b29008c7', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5a37ac09-9fc3-5099-9d24-eac4def2b18b', '4afdd04e-2ff0-551d-a3cf-0b11b29008c7', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ee69fc80-2082-545a-af95-8938d078a8b0', '4afdd04e-2ff0-551d-a3cf-0b11b29008c7', 3, $md$NOT GIVEN$md$, true);

COMMIT;
