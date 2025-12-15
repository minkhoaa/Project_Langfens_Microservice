BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-the-history-of-the-invention-of-plastics-1492'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-the-history-of-the-invention-of-plastics-1492';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-the-history-of-the-invention-of-plastics-1492';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-the-history-of-the-invention-of-plastics-1492';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('c7470cc3-bd9a-5ae9-898b-597c9d8c7071', 'ielts-reading-the-history-of-the-invention-of-plastics-1492', $t$The History of the Invention of Plastics$t$, $md$## The History of the Invention of Plastics

Nguồn:
- Test: https://mini-ielts.com/1492/reading/the-history-of-the-invention-of-plastics
- Solution: https://mini-ielts.com/1492/view-solution/reading/the-history-of-the-invention-of-plastics$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('6c76f4bd-cf6d-50a3-a5b3-c4d1de9afe3c', 'c7470cc3-bd9a-5ae9-898b-597c9d8c7071', 1, $t$Reading — The History of the Invention of Plastics$t$, $md$Read the passage and answer questions **1–14**.

### Passage: The History of the Invention of Plastics

{A} Natural polymers include such familiar substances as silk, rubber, and cotton. Plastics are artificial polymers. Plastics are used on a daily basis throughout the world. The word plastic is a common term that is used for many materials of a synthetic or semi-synthetic nature. The term was derived from the Greek plastikos, which means “fit for molding.” Plastics are a wide variety of combinations of properties when viewed as a whole. They are used for shellac, cellulose, rubber, and asphalt. We also synthetically manufacture items such as clothing, packaging, automobiles, electronics, aircraft, medical supplies, and recreational items. The list could go on and on and it is obvious that much of what we have today would not be possible without plastics.

{B} In the early part of the twentieth century, a big boom occurred in polymer chemistry when polymer materials such as nylon and Kevlar came on the scene. Much of the work done with polymers focuses on improvement while using existing technologies, but chemists do have opportunities ahead. There is a need for the development of new applications for polymers, always looking for less expensive materials that can replace what is used now. Chemists have to be more aware of what the market yearns for, such as products with a green emphasis, polymers that break down or are environmentally friendly. Concerns such as these have brought new activity to the science arena and there are always new discoveries to be made.

{C} The evolution of the chemistry behind plastics is mind-numbing, and the uses for plastics are endless. In the Middle Ages, when scientists first started to experiment, plastics were derived from organic natural sources, such as egg and blood proteins. It wasn’t until the 19th and 20thcenturies that the plastics we know today were created. Many Americans will recognize the name Goodyear , it was Charles Goodyear who began the modern-day plastic revolution when he vulcanized rubber in 1839, paving the way for the tire. Prior to his discovery, products made with rubber did not hold up well in warm temperatures or climates. Rubber is only one source of plastic, however, and three key inventors followed Goodyear’s path and took plastic from a nearly unusable hard substance to the invaluable man-made resource it is today.

{D} The son of a brass lock manufacturer, Alexander Parkes was born in Birmingham, England in 1813. Parkes was raised around metal fabrication. In his first job he worked as an apprentice at Birmingham’s brass foundry, owned by Samuel S. Messengers and Sons. Parkes switched his attention from brass work to electroplating when he went to work for George and Henry Elkington. It was there Parkes developed his inventive spirit. Parkes’ first patent, awarded in 1841, dealt with electroplating delicate items such as flowers, but throughout his career Parkes reportedly held more than 80 patents on his works with both metals and plastics.Parkes is credited with inventing the first man-made plastic, which he patented as Parkesine in 1856. Parkes introduced this combination of nitrocellulose and solvents to England in 1862 at the London International Exhibition. While Parkesine itself did not prove to be a successful material in its original formulation, it was too flammable, it laid the groundwork for successful derivative materials from future inventors. One of those inventors being John Wesley Hyatt.

{E} What Alexander Parkes started, John Wesley Hyatt took to the next level. Hyatt was born in Starkey, New York in 1837, and patented several hundred inventions. Hyatt’s link to plastics comes in the form of the game of billiards. Billiard balls were originally made of ivory, a commodity that was in steep decline in the 1800s. Most likely inspired by the $10,000 reward being offered, Hyatt took on the challenge of finding a substitute material to manufacture billiard balls. Hyatt’s experiments began with a combination of Parkes’ Parkesine, a solid form of nitrocellulose, and another English inventor, Frederick Scott Archer, discovery of liquid nitrocellulose. Hyatt combined two to create celluloid, which he patented in 1870.

{F} Celluloid was used for numerous products, including billiard balls for Hyatt’s own company rather than his former employer . Celluloid also produced false teeth, combs, baby rattles, and piano keys. Despite its replacement by newer synthetic materials in today’s marketplace, Hyatt’s patented version of celluloid is still used to produce ping-pong balls. There is no doubt that the invention of celluloid was the next important rung in the plastic manufacturing ladder, including the use of celluloid in film production.

{G} Much like Parkes’ invention led to Hyatt’s success, Hyatt’s celluloid influenced Leo Baekeland. This Belgium-born chemist paved the way for George Eastman, of Eastman Kodak, to build the photographic empire we know today. Born in 1863, Baekeland’s first invention was Velox, a paper that allowed photographs to be taken in artificial light. Eastman purchased the Velox process from Baekeland for a reported $750,000 in 1899. Baekeland used that money to fund his own in-home laboratory.

{H} Baekeland moved his experiments from photography paper to synthetic resins, and invented Bakelite, a combination of phenol and formaldehyde in 1907. Bakelite was officially patented in 1909. Bakelite was a hard, yet moldable, plastic, and was considered the product that led the world into the Age of Plastics. Bakelite was used in everything from buttons to art deco furniture to television sets. While these items are made from different types of materials today, Bakelite is still used in the production of items such as car brakes and materials used in the space shuttle.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('d8af5a9c-2756-584d-a26c-6b642958bebd', '6c76f4bd-cf6d-50a3-a5b3-c4d1de9afe3c', 1, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 1

Questions 1-5
Questions 1-5
Use the information in the passage to match the inventors, chemists or companies (listed A-F) with opinions or deeds below. Write the appropriate letters A-F in boxes 1-5 on your answer sheet.
(A)
Alexander Parkes
(B)
Charles Goodyear
(C)
John Wesley Hyatt
(D)
Frederick Scott Archer
(E)
Leo Baekeland
(F)
George Eastman
1
Invested a considerable amount of money in buying a technique that had a huge impact on the success of his well-known business.
2
Invented a chemical formula that was successful only in a lab experimental stage yet marked the beginning of an important era.
3
Had a lab sustained by his own capital.
4
In the motivation of an attractive financial incentive, successfully created a succedaneum based on the work accomplished by chemists prior to him.
5
Established a famous business on auto parts.

1 ____ Invested a considerable amount of money in buying a technique that had a huge impact on the success of his well-known business.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('809cad16-d11b-510a-9542-268bbc53a61a', 'd8af5a9c-2756-584d-a26c-6b642958bebd', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d699adb0-b9b7-5ce1-b7ab-6f68eb56e3bc', 'd8af5a9c-2756-584d-a26c-6b642958bebd', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('aec24803-22d4-59d7-856a-932ef8c29bd4', 'd8af5a9c-2756-584d-a26c-6b642958bebd', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7901e94b-dd74-59c6-bd3b-474e1bfabfb9', 'd8af5a9c-2756-584d-a26c-6b642958bebd', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('81a3c4df-9955-548b-bc8a-8993b4eaf8a1', 'd8af5a9c-2756-584d-a26c-6b642958bebd', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4f9a49ab-1d87-5b9e-a02d-18308b492476', 'd8af5a9c-2756-584d-a26c-6b642958bebd', 6, $md$F$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('77e1ab49-3346-56eb-9389-782d61c8c8ef', '6c76f4bd-cf6d-50a3-a5b3-c4d1de9afe3c', 2, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 2

Questions 1-5
Questions 1-5
Use the information in the passage to match the inventors, chemists or companies (listed A-F) with opinions or deeds below. Write the appropriate letters A-F in boxes 1-5 on your answer sheet.
(A)
Alexander Parkes
(B)
Charles Goodyear
(C)
John Wesley Hyatt
(D)
Frederick Scott Archer
(E)
Leo Baekeland
(F)
George Eastman
1
Invested a considerable amount of money in buying a technique that had a huge impact on the success of his well-known business.
2
Invented a chemical formula that was successful only in a lab experimental stage yet marked the beginning of an important era.
3
Had a lab sustained by his own capital.
4
In the motivation of an attractive financial incentive, successfully created a succedaneum based on the work accomplished by chemists prior to him.
5
Established a famous business on auto parts.

2 ____ Invented a chemical formula that was successful only in a lab experimental stage yet marked the beginning of an important era.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('51507ec0-84f9-55c5-944e-16a4ea6dc5ae', '77e1ab49-3346-56eb-9389-782d61c8c8ef', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7d8f4338-e458-50fb-bd97-c673cbf22c05', '77e1ab49-3346-56eb-9389-782d61c8c8ef', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('30675487-a711-5c75-ab1a-da960757ebbb', '77e1ab49-3346-56eb-9389-782d61c8c8ef', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0a0253a0-b06d-5b7f-843e-370e665073c7', '77e1ab49-3346-56eb-9389-782d61c8c8ef', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('98e6795c-827f-5150-b7bc-147112ccec87', '77e1ab49-3346-56eb-9389-782d61c8c8ef', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9a5e0adf-2fe4-5462-b90a-518de01a153b', '77e1ab49-3346-56eb-9389-782d61c8c8ef', 6, $md$F$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('79e48d03-2a48-5e08-a9b2-b1ff98241cb6', '6c76f4bd-cf6d-50a3-a5b3-c4d1de9afe3c', 3, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 3

Questions 1-5
Questions 1-5
Use the information in the passage to match the inventors, chemists or companies (listed A-F) with opinions or deeds below. Write the appropriate letters A-F in boxes 1-5 on your answer sheet.
(A)
Alexander Parkes
(B)
Charles Goodyear
(C)
John Wesley Hyatt
(D)
Frederick Scott Archer
(E)
Leo Baekeland
(F)
George Eastman
1
Invested a considerable amount of money in buying a technique that had a huge impact on the success of his well-known business.
2
Invented a chemical formula that was successful only in a lab experimental stage yet marked the beginning of an important era.
3
Had a lab sustained by his own capital.
4
In the motivation of an attractive financial incentive, successfully created a succedaneum based on the work accomplished by chemists prior to him.
5
Established a famous business on auto parts.

3 ____ Had a lab sustained by his own capital.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2f009aea-31be-54e9-ad12-d83156fbacf0', '79e48d03-2a48-5e08-a9b2-b1ff98241cb6', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('907b4442-9b90-5cce-b234-41c29ec4327e', '79e48d03-2a48-5e08-a9b2-b1ff98241cb6', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0ca02ed8-8457-5e4e-9c3a-a59333d1f6ca', '79e48d03-2a48-5e08-a9b2-b1ff98241cb6', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f61ef612-c436-53ad-b7b7-7418c265f18f', '79e48d03-2a48-5e08-a9b2-b1ff98241cb6', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a4eea0cd-7002-5ab4-8636-936dbf8df9f9', '79e48d03-2a48-5e08-a9b2-b1ff98241cb6', 5, $md$E$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d59739e5-a782-51d2-a64a-315438ed2f28', '79e48d03-2a48-5e08-a9b2-b1ff98241cb6', 6, $md$F$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('9b4e8ede-1d84-51cf-b6dc-aa989d07366c', '6c76f4bd-cf6d-50a3-a5b3-c4d1de9afe3c', 4, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 4

Questions 1-5
Questions 1-5
Use the information in the passage to match the inventors, chemists or companies (listed A-F) with opinions or deeds below. Write the appropriate letters A-F in boxes 1-5 on your answer sheet.
(A)
Alexander Parkes
(B)
Charles Goodyear
(C)
John Wesley Hyatt
(D)
Frederick Scott Archer
(E)
Leo Baekeland
(F)
George Eastman
1
Invested a considerable amount of money in buying a technique that had a huge impact on the success of his well-known business.
2
Invented a chemical formula that was successful only in a lab experimental stage yet marked the beginning of an important era.
3
Had a lab sustained by his own capital.
4
In the motivation of an attractive financial incentive, successfully created a succedaneum based on the work accomplished by chemists prior to him.
5
Established a famous business on auto parts.

4 ____ In the motivation of an attractive financial incentive, successfully created a succedaneum based on the work accomplished by chemists prior to him.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('141bc46e-bc30-5d07-a816-cca3e6508a7e', '9b4e8ede-1d84-51cf-b6dc-aa989d07366c', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('19ee16c7-296f-503b-931b-c0abb246e04e', '9b4e8ede-1d84-51cf-b6dc-aa989d07366c', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e149f2eb-1971-5cb3-a4a4-fff359c0204a', '9b4e8ede-1d84-51cf-b6dc-aa989d07366c', 3, $md$C$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('30416f9e-d127-5dac-ac2f-b8189d3ab13a', '9b4e8ede-1d84-51cf-b6dc-aa989d07366c', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7243ca59-03e4-5376-a73a-45e1a5bc9930', '9b4e8ede-1d84-51cf-b6dc-aa989d07366c', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fdcada1a-1cc4-5537-b275-416e7dfa17b4', '9b4e8ede-1d84-51cf-b6dc-aa989d07366c', 6, $md$F$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('91722a0d-133b-5dd1-8263-9c0bf8307dde', '6c76f4bd-cf6d-50a3-a5b3-c4d1de9afe3c', 5, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 5

Questions 1-5
Questions 1-5
Use the information in the passage to match the inventors, chemists or companies (listed A-F) with opinions or deeds below. Write the appropriate letters A-F in boxes 1-5 on your answer sheet.
(A)
Alexander Parkes
(B)
Charles Goodyear
(C)
John Wesley Hyatt
(D)
Frederick Scott Archer
(E)
Leo Baekeland
(F)
George Eastman
1
Invested a considerable amount of money in buying a technique that had a huge impact on the success of his well-known business.
2
Invented a chemical formula that was successful only in a lab experimental stage yet marked the beginning of an important era.
3
Had a lab sustained by his own capital.
4
In the motivation of an attractive financial incentive, successfully created a succedaneum based on the work accomplished by chemists prior to him.
5
Established a famous business on auto parts.

5 ____ Established a famous business on auto parts.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ac7af81c-192c-52f1-ba62-da1212cc9fd1', '91722a0d-133b-5dd1-8263-9c0bf8307dde', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('514f10a1-c365-51de-9f46-de1443c3ae26', '91722a0d-133b-5dd1-8263-9c0bf8307dde', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('75a8cdae-ddd7-5770-8171-dbc6318f32df', '91722a0d-133b-5dd1-8263-9c0bf8307dde', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('07963b89-a137-5449-889d-a5d4b8c9dcf1', '91722a0d-133b-5dd1-8263-9c0bf8307dde', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a4d1397e-7c34-5a7f-9ce5-231502042e4d', '91722a0d-133b-5dd1-8263-9c0bf8307dde', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ef45ae25-3004-58e7-830c-0189c96d200c', '91722a0d-133b-5dd1-8263-9c0bf8307dde', 6, $md$F$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('11683263-fc6b-526d-aff3-21c7d04f5067', '6c76f4bd-cf6d-50a3-a5b3-c4d1de9afe3c', 6, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 6

Questions 6-9
Questions 6-9
Do the following statements agree with the information given in IELTS Data Reading Passage 230 – The History of the Invention of Plastics Reading Passage? In boxes 6-9 on your answer sheet, write
TRUE
if the statement is True
FALSE
if the statement is false
NOT GIVEN
If the information is not given in the passage
6
Silk, cotton as well as plastics have something in common.
7
There are sometimes conflicts between what the chemists are trying on and what the markets are driving for.
8
The majority of Alexander Parkes’ patents lie in two major fields.
9
The importance of celluloid has completely faded out of in commercial use because of the occurrence of other alternative products.

6 ____ Silk, cotton as well as plastics have something in common.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3c2580c5-26f9-5b79-8c67-ea0084c420af', '11683263-fc6b-526d-aff3-21c7d04f5067', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cfa4763e-ae47-5f80-8913-81adf424c751', '11683263-fc6b-526d-aff3-21c7d04f5067', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4cd7e913-eb2f-549e-8556-cf92a2b7047b', '11683263-fc6b-526d-aff3-21c7d04f5067', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('8cc7fbc1-186f-5f8f-93bc-e88e5c84310f', '6c76f4bd-cf6d-50a3-a5b3-c4d1de9afe3c', 7, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 7

Questions 6-9
Questions 6-9
Do the following statements agree with the information given in IELTS Data Reading Passage 230 – The History of the Invention of Plastics Reading Passage? In boxes 6-9 on your answer sheet, write
TRUE
if the statement is True
FALSE
if the statement is false
NOT GIVEN
If the information is not given in the passage
6
Silk, cotton as well as plastics have something in common.
7
There are sometimes conflicts between what the chemists are trying on and what the markets are driving for.
8
The majority of Alexander Parkes’ patents lie in two major fields.
9
The importance of celluloid has completely faded out of in commercial use because of the occurrence of other alternative products.

7 ____ There are sometimes conflicts between what the chemists are trying on and what the markets are driving for.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5c1762c4-55bb-5595-bf81-0667cb33b26a', '8cc7fbc1-186f-5f8f-93bc-e88e5c84310f', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2a6be30c-ea0d-5320-a280-1d9fdfebea77', '8cc7fbc1-186f-5f8f-93bc-e88e5c84310f', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5440612c-e0a8-53aa-9817-ff1931e92f7d', '8cc7fbc1-186f-5f8f-93bc-e88e5c84310f', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('a0e9ae72-9a94-5e8d-97d8-5a1bce54e0c7', '6c76f4bd-cf6d-50a3-a5b3-c4d1de9afe3c', 8, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 8

Questions 6-9
Questions 6-9
Do the following statements agree with the information given in IELTS Data Reading Passage 230 – The History of the Invention of Plastics Reading Passage? In boxes 6-9 on your answer sheet, write
TRUE
if the statement is True
FALSE
if the statement is false
NOT GIVEN
If the information is not given in the passage
6
Silk, cotton as well as plastics have something in common.
7
There are sometimes conflicts between what the chemists are trying on and what the markets are driving for.
8
The majority of Alexander Parkes’ patents lie in two major fields.
9
The importance of celluloid has completely faded out of in commercial use because of the occurrence of other alternative products.

8 ____ The majority of Alexander Parkes’ patents lie in two major fields.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e2efd9ba-92d5-5c05-9901-445ef7867b98', 'a0e9ae72-9a94-5e8d-97d8-5a1bce54e0c7', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('41930626-91fc-5381-b1f9-0d5eb9945aab', 'a0e9ae72-9a94-5e8d-97d8-5a1bce54e0c7', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('131fb5f3-3625-5b6d-9ec3-6454a1a90be1', 'a0e9ae72-9a94-5e8d-97d8-5a1bce54e0c7', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('b4c015e6-5f0d-590a-b251-2bb1861ec9ad', '6c76f4bd-cf6d-50a3-a5b3-c4d1de9afe3c', 9, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 9

Questions 6-9
Questions 6-9
Do the following statements agree with the information given in IELTS Data Reading Passage 230 – The History of the Invention of Plastics Reading Passage? In boxes 6-9 on your answer sheet, write
TRUE
if the statement is True
FALSE
if the statement is false
NOT GIVEN
If the information is not given in the passage
6
Silk, cotton as well as plastics have something in common.
7
There are sometimes conflicts between what the chemists are trying on and what the markets are driving for.
8
The majority of Alexander Parkes’ patents lie in two major fields.
9
The importance of celluloid has completely faded out of in commercial use because of the occurrence of other alternative products.

9 ____ The importance of celluloid has completely faded out of in commercial use because of the occurrence of other alternative products.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('89bc4d57-e2d1-576c-8c03-8ec6a8ee7534', 'b4c015e6-5f0d-590a-b251-2bb1861ec9ad', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ae30d2ee-8b1c-5e3c-8ee3-f688f0857eb3', 'b4c015e6-5f0d-590a-b251-2bb1861ec9ad', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('15039937-44e4-5db3-a709-86fc7dc7c53b', 'b4c015e6-5f0d-590a-b251-2bb1861ec9ad', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('ec6dc28e-a8b9-553b-af5d-8efe03c584f4', '6c76f4bd-cf6d-50a3-a5b3-c4d1de9afe3c', 10, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 10

Questions 10-14
Questions 10-14
Complete the following summary of the paragraphs of Reading Passage, using
No More than Three words
from the Reading Passage for each answer. Write your answers in boxes 10-14 on your answer sheet.
Alexander Parkes, a well-known chemist, was brought up in an industrial city surrounded by
10
. He began his work by learning in a
11
in his hometown and later fostered his
12
during his time working for other employers. He started his journey of getting over 80 patents in the field of
13
ever since then.
Although his most important invention Parkesine, made up of
14
and regarded as the first artificial plastic did not get a big success because of some shortcomings, Parkes had paved the road for other coming scientists in plastic chemistry.

Alexander Parkes, a well-known chemist, was brought up in an industrial city surrounded by 10 ____ . He began his work by learning in a 11 ____ in his hometown and later fostered his 12 ____ during his time working for other employers. He started his journey of getting over 80 patents in the field of 13 ____ ever since then.$md$, NULL, ARRAY['.*metal.*fabrication.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('6dcb365b-27dc-5eec-babb-16d1c0915e0e', '6c76f4bd-cf6d-50a3-a5b3-c4d1de9afe3c', 11, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 11

Questions 10-14
Questions 10-14
Complete the following summary of the paragraphs of Reading Passage, using
No More than Three words
from the Reading Passage for each answer. Write your answers in boxes 10-14 on your answer sheet.
Alexander Parkes, a well-known chemist, was brought up in an industrial city surrounded by
10
. He began his work by learning in a
11
in his hometown and later fostered his
12
during his time working for other employers. He started his journey of getting over 80 patents in the field of
13
ever since then.
Although his most important invention Parkesine, made up of
14
and regarded as the first artificial plastic did not get a big success because of some shortcomings, Parkes had paved the road for other coming scientists in plastic chemistry.

Alexander Parkes, a well-known chemist, was brought up in an industrial city surrounded by 10 ____ . He began his work by learning in a 11 ____ in his hometown and later fostered his 12 ____ during his time working for other employers. He started his journey of getting over 80 patents in the field of 13 ____ ever since then.$md$, NULL, ARRAY['.*metal.*fabrication.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('e84798dd-153d-5c83-b23b-443f73a85ee5', '6c76f4bd-cf6d-50a3-a5b3-c4d1de9afe3c', 12, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 12

Questions 10-14
Questions 10-14
Complete the following summary of the paragraphs of Reading Passage, using
No More than Three words
from the Reading Passage for each answer. Write your answers in boxes 10-14 on your answer sheet.
Alexander Parkes, a well-known chemist, was brought up in an industrial city surrounded by
10
. He began his work by learning in a
11
in his hometown and later fostered his
12
during his time working for other employers. He started his journey of getting over 80 patents in the field of
13
ever since then.
Although his most important invention Parkesine, made up of
14
and regarded as the first artificial plastic did not get a big success because of some shortcomings, Parkes had paved the road for other coming scientists in plastic chemistry.

Alexander Parkes, a well-known chemist, was brought up in an industrial city surrounded by 10 ____ . He began his work by learning in a 11 ____ in his hometown and later fostered his 12 ____ during his time working for other employers. He started his journey of getting over 80 patents in the field of 13 ____ ever since then.$md$, NULL, ARRAY['.*metal.*fabrication.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('6d7b68b6-57a6-5169-94cc-b8850a90541e', '6c76f4bd-cf6d-50a3-a5b3-c4d1de9afe3c', 13, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 13

Questions 10-14
Questions 10-14
Complete the following summary of the paragraphs of Reading Passage, using
No More than Three words
from the Reading Passage for each answer. Write your answers in boxes 10-14 on your answer sheet.
Alexander Parkes, a well-known chemist, was brought up in an industrial city surrounded by
10
. He began his work by learning in a
11
in his hometown and later fostered his
12
during his time working for other employers. He started his journey of getting over 80 patents in the field of
13
ever since then.
Although his most important invention Parkesine, made up of
14
and regarded as the first artificial plastic did not get a big success because of some shortcomings, Parkes had paved the road for other coming scientists in plastic chemistry.

Alexander Parkes, a well-known chemist, was brought up in an industrial city surrounded by 10 ____ . He began his work by learning in a 11 ____ in his hometown and later fostered his 12 ____ during his time working for other employers. He started his journey of getting over 80 patents in the field of 13 ____ ever since then.$md$, NULL, ARRAY['.*metal.*fabrication.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('c6b52e83-bf16-5ab1-9346-441d0ac4d8a7', '6c76f4bd-cf6d-50a3-a5b3-c4d1de9afe3c', 14, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 14

Questions 10-14
Questions 10-14
Complete the following summary of the paragraphs of Reading Passage, using
No More than Three words
from the Reading Passage for each answer. Write your answers in boxes 10-14 on your answer sheet.
Alexander Parkes, a well-known chemist, was brought up in an industrial city surrounded by
10
. He began his work by learning in a
11
in his hometown and later fostered his
12
during his time working for other employers. He started his journey of getting over 80 patents in the field of
13
ever since then.
Although his most important invention Parkesine, made up of
14
and regarded as the first artificial plastic did not get a big success because of some shortcomings, Parkes had paved the road for other coming scientists in plastic chemistry.

Although his most important invention Parkesine, made up of 14 ____ and regarded as the first artificial plastic did not get a big success because of some shortcomings, Parkes had paved the road for other coming scientists in plastic chemistry.$md$, NULL, ARRAY['.*nitrocellulose.*and.*solvents.*']);

COMMIT;
