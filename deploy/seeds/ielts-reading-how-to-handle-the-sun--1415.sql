BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-how-to-handle-the-sun--1415'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-how-to-handle-the-sun--1415';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-how-to-handle-the-sun--1415';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-how-to-handle-the-sun--1415';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('a7922ad7-5317-5b9b-bd6b-d4feb41f7974', 'ielts-reading-how-to-handle-the-sun--1415', $t$How to handle the Sun$t$, $md$## How to handle the Sun

Nguồn:
- Test: https://mini-ielts.com/1415/reading/how-to-handle-the-sun-
- Solution: https://mini-ielts.com/1415/view-solution/reading/how-to-handle-the-sun-$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('778f0934-0a04-5613-8ea6-796df20e9077', 'a7922ad7-5317-5b9b-bd6b-d4feb41f7974', 1, $t$Reading — How to handle the Sun$t$, $md$Read the passage and answer questions **1–14**.

### Passage: How to handle the Sun

A. The medical world appears to be divided on the effects of the sun upon the human body. From statements like, “There is no known relationship between a tan and health” to “perhaps sun-tanned skin absorbs the ultraviolet rays and converts them into helpful energy”, there are some things which are still the topic of research. Doctors agree on one of the benefits of the sun – vitamin D.

It is well known that vitamin D is acquired from the direct rays of the sun – an entirely separate miracle from sun tanning. The sun’s ultraviolet rays penetrate only a tiny amount into the human skin, but in the process, they irradiate an element in the skin called ergosterol, which is a substance that stores up reserves of vitamin D received from the sun. This is both healthy and beneficial for human skin.

B. All around the Western World, people have developed an obsession with the sun. In many western countries, a suntan has become the trade-mark of a healthy, active, outdoor person. The basic reddish hue just beneath the surface of our skin is the outward reflection of the millions of red corpuscles flowing through tiny blood vessels. This is most noticeable in the pure skin of a baby which can change in a moment from porcelain white (with anger or a switch in temperature) to crimson. In Caucasians, this colouring is somewhat hidden by an acquired layer of sun-made pigment, which varies in tone according to the complexion and occupation of the individual.

C. Locale plays a big part in the effectiveness of the suntan. Mountain tops and beaches are nonpareil sun spas because they receive far purer sunlight than the rest of the land. Urban areas with their smoke and smog act as a filter removing all the healthy properties of the sun. Perhaps the seashore is best of all, with its air estimated to have at least a fifth of a per cent more oxygen than inland ether – free of city and inland dust, tars, pollen, and allergens.

D. The sun has long been called nature’s greatest health giver and healer and has played a chief role at health resorts ever since August Rollier, the Swiss father of heliotherapy, opened his first high-Alps sanatorium in 1903. Dr. W. W. Coblenz suggests that the sun cure is a major factor in the treatment of at least 23 skin diseases, ranging from acne and eczema to ulcers and wounds. Another specialist, Dr. Richard Kovacs writes, “Sun treatment is often helpful to persons suffering from general debility – repeated colds, respiratory diseases, influenza and the like”.

After a long winter, the return to the sun writes Dr. Leonard Dodds, the British sunlight scholar, “is a general stimulus to the body, more potent if applied after a period when it has been lacking which gradually loses its effect if exposure is over prolonged, even when not excessive”.

E. Over many years of study, dermatologists have proven that excessive exposure to sunlight for years is responsible for a large proportion of skin cancer amongst the population. Those with the greatest chance of doing permanent damage to their skin are the year-round outdoor workers – 90% of which occurs on the heavily exposed hands and face. The first line of defense against permanent sun damage is the skin’s own natural fatty matter and sweat, which combine to form an oily acid surface shield against the ultraviolet rays.

At the beach, the saltwater washes away this natural oily coat, the hot sun overworks the sweat glands so that the excess becomes ineffective and the dry wind and hot sun combine to dehydrate the skin itself. Over the years, women have shown far greater wisdom in the care of their skin than men. Since the ladies of ancient Egypt first began to apply the fat of the so-called sacred temple cats to their faces, women have been tireless in waging this battle against damage to the skin from the sun. Both sexes now contribute annually to a multi-million dollar global sunscreen business.

F. Other pans of the human body which tend to suffer from exposure to the sun are the eyes and hair. Many years ago, optometrists undertook studies in America to examine the influence of the sun upon the eyes by studying Atlantic City lifeguards and found that even a few hours in the bright sun without sunglasses could cause a significant loss of vision – a loss that might take several weeks from which to recover.

So gradual was the change that the lifeguards were unaware that their sight had been affected. The solution to this problem was to introduce sunglasses as a standard part of the lifeguard uniform. These were dark enough to absorb the sun’s harmful UV rays and most of its infrared and ultraviolet rays.

G. Of a lesser impact is the effect of the sun upon the hair. The penalty of the sun parching is a brittle dryness. Haircare professionals recommend a nutritional cream treatment with a substance containing lanolin to bring your hair back its natural softness, these usually come in the form of leave-in conditioners, and should be applied frequently, just as you would a sunscreen for the skin. Or, easier still, wear a hat. Wearing a hat has a dual effect: it protects the hair and helps to prevent the most dangerous of outdoor afflictions: sunstroke.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('c71a646b-eaa9-5fd7-aec2-9eeb5038cb31', '778f0934-0a04-5613-8ea6-796df20e9077', 1, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 1

Question 1-4
Question 1-4
Look at the following people (Questions 1-4) and the list of statements below.
Match each person with the correct statement.
Write the correct letter A-H in boxes 1-4 on your answer sheet.
1.
Richard Kovacs
1
2.
August Rollier
2
3.
W. Coblenz
3
4.
Leonard Dodds
4
A.
believes that the benefits of the sun are not scientifically provable
B.
claims to have discovered the vitamin released in the skin by the sun
C.
suggests that the sun is an excellent healer
D.
invented the first sunscreen
E.
suggests that the sun assists with common illnesses
F.
thinks that initially, the sun is of benefit to the body
G.
is unsure about the benefits of the sun
H.
opened the first specialised hospital

1. Richard Kovacs 1 ____ 2. August Rollier 2 ____ 3. W. Coblenz 3 ____ 4. Leonard Dodds 4 ____$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('458b1d64-6815-5d12-a0c5-7346e5466dd2', 'c71a646b-eaa9-5fd7-aec2-9eeb5038cb31', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ce970ca6-c055-5f0c-a99d-040721e7db23', 'c71a646b-eaa9-5fd7-aec2-9eeb5038cb31', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('51ed6466-3127-5156-a720-27b00606c45d', 'c71a646b-eaa9-5fd7-aec2-9eeb5038cb31', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2b787332-9f5d-5091-928e-86cc9b7477b0', 'c71a646b-eaa9-5fd7-aec2-9eeb5038cb31', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('75930006-c812-562a-9c10-032a2f8e9630', 'c71a646b-eaa9-5fd7-aec2-9eeb5038cb31', 5, $md$E$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b6c87336-4999-5488-9211-8756908d2925', 'c71a646b-eaa9-5fd7-aec2-9eeb5038cb31', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('730a4515-1d40-5526-99cb-5c6d2c73c3fd', 'c71a646b-eaa9-5fd7-aec2-9eeb5038cb31', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('600069a4-a5be-5623-b5d9-accc7e087547', 'c71a646b-eaa9-5fd7-aec2-9eeb5038cb31', 8, $md$H$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('6939c9d0-f2b9-55da-be26-9b9126702ac8', '778f0934-0a04-5613-8ea6-796df20e9077', 2, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 2

Question 1-4
Question 1-4
Look at the following people (Questions 1-4) and the list of statements below.
Match each person with the correct statement.
Write the correct letter A-H in boxes 1-4 on your answer sheet.
1.
Richard Kovacs
1
2.
August Rollier
2
3.
W. Coblenz
3
4.
Leonard Dodds
4
A.
believes that the benefits of the sun are not scientifically provable
B.
claims to have discovered the vitamin released in the skin by the sun
C.
suggests that the sun is an excellent healer
D.
invented the first sunscreen
E.
suggests that the sun assists with common illnesses
F.
thinks that initially, the sun is of benefit to the body
G.
is unsure about the benefits of the sun
H.
opened the first specialised hospital

1. Richard Kovacs 1 ____ 2. August Rollier 2 ____ 3. W. Coblenz 3 ____ 4. Leonard Dodds 4 ____$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c4a49940-27b0-55e4-af2e-3662b3a69474', '6939c9d0-f2b9-55da-be26-9b9126702ac8', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('20667a8f-4d7d-51f7-ad06-0bb41b8a9ee6', '6939c9d0-f2b9-55da-be26-9b9126702ac8', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b15b26ac-97f9-5f19-bf10-d1d6d9a26585', '6939c9d0-f2b9-55da-be26-9b9126702ac8', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9a1e7e19-f03b-5ce2-9da6-0c56c5caf5c4', '6939c9d0-f2b9-55da-be26-9b9126702ac8', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4ab353e7-ee2c-5bd3-9006-b9e23defe8c9', '6939c9d0-f2b9-55da-be26-9b9126702ac8', 5, $md$E$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('63690c5b-7acf-5381-8095-6764481da982', '6939c9d0-f2b9-55da-be26-9b9126702ac8', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bfbc7f1f-04f4-5a39-93da-645aef17ea59', '6939c9d0-f2b9-55da-be26-9b9126702ac8', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b9bf88a3-aa12-52de-a1c6-40c8da0ddf5c', '6939c9d0-f2b9-55da-be26-9b9126702ac8', 8, $md$H$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('ff1870d8-1c24-5672-aaaf-b0187755c718', '778f0934-0a04-5613-8ea6-796df20e9077', 3, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 3

Question 1-4
Question 1-4
Look at the following people (Questions 1-4) and the list of statements below.
Match each person with the correct statement.
Write the correct letter A-H in boxes 1-4 on your answer sheet.
1.
Richard Kovacs
1
2.
August Rollier
2
3.
W. Coblenz
3
4.
Leonard Dodds
4
A.
believes that the benefits of the sun are not scientifically provable
B.
claims to have discovered the vitamin released in the skin by the sun
C.
suggests that the sun is an excellent healer
D.
invented the first sunscreen
E.
suggests that the sun assists with common illnesses
F.
thinks that initially, the sun is of benefit to the body
G.
is unsure about the benefits of the sun
H.
opened the first specialised hospital

1. Richard Kovacs 1 ____ 2. August Rollier 2 ____ 3. W. Coblenz 3 ____ 4. Leonard Dodds 4 ____$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('60956ebb-19bb-5ece-8285-15124bce3627', 'ff1870d8-1c24-5672-aaaf-b0187755c718', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f0b192c7-9ba1-53b5-9908-66f49a9636e9', 'ff1870d8-1c24-5672-aaaf-b0187755c718', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('af30c545-30ca-52ba-81ff-91088c285e87', 'ff1870d8-1c24-5672-aaaf-b0187755c718', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('50fef70a-1ee3-5279-866c-900a6efd9947', 'ff1870d8-1c24-5672-aaaf-b0187755c718', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bb5cbf28-6cc2-5b84-a9fd-11f547af08f1', 'ff1870d8-1c24-5672-aaaf-b0187755c718', 5, $md$E$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('deb6a48b-fa82-5334-b383-84e6692cbdfb', 'ff1870d8-1c24-5672-aaaf-b0187755c718', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b3a1960c-6c7f-5b3d-beea-e38d7098f3e4', 'ff1870d8-1c24-5672-aaaf-b0187755c718', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1b29b738-67cc-5f08-b076-4c902acfa520', 'ff1870d8-1c24-5672-aaaf-b0187755c718', 8, $md$H$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('8161c1e5-65fb-529c-a68f-8cb35358105f', '778f0934-0a04-5613-8ea6-796df20e9077', 4, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 4

Question 1-4
Question 1-4
Look at the following people (Questions 1-4) and the list of statements below.
Match each person with the correct statement.
Write the correct letter A-H in boxes 1-4 on your answer sheet.
1.
Richard Kovacs
1
2.
August Rollier
2
3.
W. Coblenz
3
4.
Leonard Dodds
4
A.
believes that the benefits of the sun are not scientifically provable
B.
claims to have discovered the vitamin released in the skin by the sun
C.
suggests that the sun is an excellent healer
D.
invented the first sunscreen
E.
suggests that the sun assists with common illnesses
F.
thinks that initially, the sun is of benefit to the body
G.
is unsure about the benefits of the sun
H.
opened the first specialised hospital

1. Richard Kovacs 1 ____ 2. August Rollier 2 ____ 3. W. Coblenz 3 ____ 4. Leonard Dodds 4 ____$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('08f06655-c166-5239-937a-8c4167972e61', '8161c1e5-65fb-529c-a68f-8cb35358105f', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b8d7b364-df6d-57ce-82d7-1ac77f5e2bac', '8161c1e5-65fb-529c-a68f-8cb35358105f', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ec202306-1de9-5d85-91ba-553b683949d1', '8161c1e5-65fb-529c-a68f-8cb35358105f', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5fc42603-926d-5b36-839b-9a2eb666b9e9', '8161c1e5-65fb-529c-a68f-8cb35358105f', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('06943355-b999-57ed-9900-db40beeb87cc', '8161c1e5-65fb-529c-a68f-8cb35358105f', 5, $md$E$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e4b937fe-da4d-5559-83da-d23926269d91', '8161c1e5-65fb-529c-a68f-8cb35358105f', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('522527e1-4bea-5a1d-9455-1295cbd9d49d', '8161c1e5-65fb-529c-a68f-8cb35358105f', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('16c58be9-01cf-5508-8620-9b0b5072099e', '8161c1e5-65fb-529c-a68f-8cb35358105f', 8, $md$H$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('dfcf9f18-49f9-52eb-a3cb-1dadf0fdd3ae', '778f0934-0a04-5613-8ea6-796df20e9077', 5, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 5

Question 5-9
Question 5-9
Do the following statements agree with the information given in Reading Passage?
TRUE
– if the statement agrees with the information
FALSE
– if the statement contradicts the information
NOT GIVEN
– if there is no information on this
5
Most doctors agree when it comes to the health benefits of the sun.
6
Beaches are best for a suntan because the air has far less pollution.
7
Women applied fat to their skin for protection from the sun.
8
Extended exposure of the eyes to the sun can lead to blindness.
9
The human eye cannot heal itself when it is damaged by the sun.

5 ____ Most doctors agree when it comes to the health benefits of the sun. 6 ____ Beaches are best for a suntan because the air has far less pollution. 7 ____ Women applied fat to their skin for protection from the sun. 8 ____ Extended exposure of the eyes to the sun can lead to blindness. 9 ____ The human eye cannot heal itself when it is damaged by the sun.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('60ca4498-96be-587e-aeea-a3d8741c764d', 'dfcf9f18-49f9-52eb-a3cb-1dadf0fdd3ae', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('80fa4d1b-d4aa-56bb-9b7b-8325555a5cb6', 'dfcf9f18-49f9-52eb-a3cb-1dadf0fdd3ae', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c3633a33-aa5c-552f-96fd-3de6645b5c0b', 'dfcf9f18-49f9-52eb-a3cb-1dadf0fdd3ae', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('28c96764-a852-5be3-b1a2-bedb099c8c88', '778f0934-0a04-5613-8ea6-796df20e9077', 6, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 6

Question 5-9
Question 5-9
Do the following statements agree with the information given in Reading Passage?
TRUE
– if the statement agrees with the information
FALSE
– if the statement contradicts the information
NOT GIVEN
– if there is no information on this
5
Most doctors agree when it comes to the health benefits of the sun.
6
Beaches are best for a suntan because the air has far less pollution.
7
Women applied fat to their skin for protection from the sun.
8
Extended exposure of the eyes to the sun can lead to blindness.
9
The human eye cannot heal itself when it is damaged by the sun.

5 ____ Most doctors agree when it comes to the health benefits of the sun. 6 ____ Beaches are best for a suntan because the air has far less pollution. 7 ____ Women applied fat to their skin for protection from the sun. 8 ____ Extended exposure of the eyes to the sun can lead to blindness. 9 ____ The human eye cannot heal itself when it is damaged by the sun.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e2afc44c-8c29-5bf3-9052-4601ef7505fe', '28c96764-a852-5be3-b1a2-bedb099c8c88', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2212fa5b-33a8-5307-af8a-715161047053', '28c96764-a852-5be3-b1a2-bedb099c8c88', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4627ee89-c3f3-56f4-a669-530638bffb25', '28c96764-a852-5be3-b1a2-bedb099c8c88', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('e6912b45-7807-5ab1-aaf9-e8b09ef7cfb0', '778f0934-0a04-5613-8ea6-796df20e9077', 7, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 7

Question 5-9
Question 5-9
Do the following statements agree with the information given in Reading Passage?
TRUE
– if the statement agrees with the information
FALSE
– if the statement contradicts the information
NOT GIVEN
– if there is no information on this
5
Most doctors agree when it comes to the health benefits of the sun.
6
Beaches are best for a suntan because the air has far less pollution.
7
Women applied fat to their skin for protection from the sun.
8
Extended exposure of the eyes to the sun can lead to blindness.
9
The human eye cannot heal itself when it is damaged by the sun.

5 ____ Most doctors agree when it comes to the health benefits of the sun. 6 ____ Beaches are best for a suntan because the air has far less pollution. 7 ____ Women applied fat to their skin for protection from the sun. 8 ____ Extended exposure of the eyes to the sun can lead to blindness. 9 ____ The human eye cannot heal itself when it is damaged by the sun.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d1850213-a19d-5be7-86df-a31dfb6186ad', 'e6912b45-7807-5ab1-aaf9-e8b09ef7cfb0', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ea84a7a9-8711-5f52-a383-7756a451fbb9', 'e6912b45-7807-5ab1-aaf9-e8b09ef7cfb0', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b99a15cd-78cf-56f2-9e15-83b440d8722b', 'e6912b45-7807-5ab1-aaf9-e8b09ef7cfb0', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('73c00ab2-3ee5-508c-bbfe-38f17858e966', '778f0934-0a04-5613-8ea6-796df20e9077', 8, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 8

Question 5-9
Question 5-9
Do the following statements agree with the information given in Reading Passage?
TRUE
– if the statement agrees with the information
FALSE
– if the statement contradicts the information
NOT GIVEN
– if there is no information on this
5
Most doctors agree when it comes to the health benefits of the sun.
6
Beaches are best for a suntan because the air has far less pollution.
7
Women applied fat to their skin for protection from the sun.
8
Extended exposure of the eyes to the sun can lead to blindness.
9
The human eye cannot heal itself when it is damaged by the sun.

5 ____ Most doctors agree when it comes to the health benefits of the sun. 6 ____ Beaches are best for a suntan because the air has far less pollution. 7 ____ Women applied fat to their skin for protection from the sun. 8 ____ Extended exposure of the eyes to the sun can lead to blindness. 9 ____ The human eye cannot heal itself when it is damaged by the sun.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ef1c9d85-dda7-5c48-ad8f-c2994e53f740', '73c00ab2-3ee5-508c-bbfe-38f17858e966', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('59ce19b6-b5c8-52f3-aa86-022da6bbef7f', '73c00ab2-3ee5-508c-bbfe-38f17858e966', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d082140e-8e5c-5855-99cb-4ed52244cec8', '73c00ab2-3ee5-508c-bbfe-38f17858e966', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('c43badbe-f323-546d-8ed9-604f4ff3d248', '778f0934-0a04-5613-8ea6-796df20e9077', 9, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 9

Question 5-9
Question 5-9
Do the following statements agree with the information given in Reading Passage?
TRUE
– if the statement agrees with the information
FALSE
– if the statement contradicts the information
NOT GIVEN
– if there is no information on this
5
Most doctors agree when it comes to the health benefits of the sun.
6
Beaches are best for a suntan because the air has far less pollution.
7
Women applied fat to their skin for protection from the sun.
8
Extended exposure of the eyes to the sun can lead to blindness.
9
The human eye cannot heal itself when it is damaged by the sun.

5 ____ Most doctors agree when it comes to the health benefits of the sun. 6 ____ Beaches are best for a suntan because the air has far less pollution. 7 ____ Women applied fat to their skin for protection from the sun. 8 ____ Extended exposure of the eyes to the sun can lead to blindness. 9 ____ The human eye cannot heal itself when it is damaged by the sun.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('37ad3068-42ca-5869-ad55-9573ff8aa693', 'c43badbe-f323-546d-8ed9-604f4ff3d248', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7026acf5-9978-554b-97dc-aa2d9e2f7de3', 'c43badbe-f323-546d-8ed9-604f4ff3d248', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('30fffacb-b91e-52ac-8b44-7d903e3a9adc', 'c43badbe-f323-546d-8ed9-604f4ff3d248', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('9c50a39f-6606-5ef2-bcab-14cd66d31b87', '778f0934-0a04-5613-8ea6-796df20e9077', 10, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 10

Question 10-14
Question 10-14
Complete the summary using the words from the box.
Handling the Sun
Many doctors agree that skin cancer can be caused by excessive exposure to the sun. As far as the human body is concerned, it is primarily the face and hands that are
10
. When human skin is exposed to the sun, the body has a defense: an
11
of the skin’s natural oils and acids. For some time, women have been more effective than men in
12
for their skin. Eyes are a significant part of the body that are negatively affected by the sun.
The damage often goes undetected because it happens quite
13
On the other hand, hair becomes quite dry and brittle when exposed to the sun for an extended period. A lanolin-based conditioner is recommended by hair care professionals to
14
this problem. Perhaps a simple hat may be the best solution for hair.
​
overcome
maintaining
located
mixed
quickly
extended
prolonged
blend
arrangement
succeed
combined
surprisingly
slowly
triumph
affected
caring
minding

Many doctors agree that skin cancer can be caused by excessive exposure to the sun. As far as the human body is concerned, it is primarily the face and hands that are 10 ____ . When human skin is exposed to the sun, the body has a defense: an 11 ____ of the skin’s natural oils and acids. For some time, women have been more effective than men in 12 ____ for their skin. Eyes are a significant part of the body that are negatively affected by the sun.$md$, NULL, ARRAY['.*affected.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('4548053b-b6b3-5360-8ce9-ab853634687c', '778f0934-0a04-5613-8ea6-796df20e9077', 11, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 11

Question 10-14
Question 10-14
Complete the summary using the words from the box.
Handling the Sun
Many doctors agree that skin cancer can be caused by excessive exposure to the sun. As far as the human body is concerned, it is primarily the face and hands that are
10
. When human skin is exposed to the sun, the body has a defense: an
11
of the skin’s natural oils and acids. For some time, women have been more effective than men in
12
for their skin. Eyes are a significant part of the body that are negatively affected by the sun.
The damage often goes undetected because it happens quite
13
On the other hand, hair becomes quite dry and brittle when exposed to the sun for an extended period. A lanolin-based conditioner is recommended by hair care professionals to
14
this problem. Perhaps a simple hat may be the best solution for hair.
​
overcome
maintaining
located
mixed
quickly
extended
prolonged
blend
arrangement
succeed
combined
surprisingly
slowly
triumph
affected
caring
minding

Many doctors agree that skin cancer can be caused by excessive exposure to the sun. As far as the human body is concerned, it is primarily the face and hands that are 10 ____ . When human skin is exposed to the sun, the body has a defense: an 11 ____ of the skin’s natural oils and acids. For some time, women have been more effective than men in 12 ____ for their skin. Eyes are a significant part of the body that are negatively affected by the sun.$md$, NULL, ARRAY['.*affected.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('ca9540a8-e829-5cdd-ac91-8d115c9fe82d', '778f0934-0a04-5613-8ea6-796df20e9077', 12, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 12

Question 10-14
Question 10-14
Complete the summary using the words from the box.
Handling the Sun
Many doctors agree that skin cancer can be caused by excessive exposure to the sun. As far as the human body is concerned, it is primarily the face and hands that are
10
. When human skin is exposed to the sun, the body has a defense: an
11
of the skin’s natural oils and acids. For some time, women have been more effective than men in
12
for their skin. Eyes are a significant part of the body that are negatively affected by the sun.
The damage often goes undetected because it happens quite
13
On the other hand, hair becomes quite dry and brittle when exposed to the sun for an extended period. A lanolin-based conditioner is recommended by hair care professionals to
14
this problem. Perhaps a simple hat may be the best solution for hair.
​
overcome
maintaining
located
mixed
quickly
extended
prolonged
blend
arrangement
succeed
combined
surprisingly
slowly
triumph
affected
caring
minding

Many doctors agree that skin cancer can be caused by excessive exposure to the sun. As far as the human body is concerned, it is primarily the face and hands that are 10 ____ . When human skin is exposed to the sun, the body has a defense: an 11 ____ of the skin’s natural oils and acids. For some time, women have been more effective than men in 12 ____ for their skin. Eyes are a significant part of the body that are negatively affected by the sun.$md$, NULL, ARRAY['.*affected.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('3e0ad66e-2195-5c08-bd02-352fc6e0de40', '778f0934-0a04-5613-8ea6-796df20e9077', 13, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 13

Question 10-14
Question 10-14
Complete the summary using the words from the box.
Handling the Sun
Many doctors agree that skin cancer can be caused by excessive exposure to the sun. As far as the human body is concerned, it is primarily the face and hands that are
10
. When human skin is exposed to the sun, the body has a defense: an
11
of the skin’s natural oils and acids. For some time, women have been more effective than men in
12
for their skin. Eyes are a significant part of the body that are negatively affected by the sun.
The damage often goes undetected because it happens quite
13
On the other hand, hair becomes quite dry and brittle when exposed to the sun for an extended period. A lanolin-based conditioner is recommended by hair care professionals to
14
this problem. Perhaps a simple hat may be the best solution for hair.
​
overcome
maintaining
located
mixed
quickly
extended
prolonged
blend
arrangement
succeed
combined
surprisingly
slowly
triumph
affected
caring
minding

The damage often goes undetected because it happens quite 13 ____ On the other hand, hair becomes quite dry and brittle when exposed to the sun for an extended period. A lanolin-based conditioner is recommended by hair care professionals to 14 ____ this problem. Perhaps a simple hat may be the best solution for hair.$md$, NULL, ARRAY['.*slowly.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('be3ea500-62d6-5333-af12-aab672015af0', '778f0934-0a04-5613-8ea6-796df20e9077', 14, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 14

Question 10-14
Question 10-14
Complete the summary using the words from the box.
Handling the Sun
Many doctors agree that skin cancer can be caused by excessive exposure to the sun. As far as the human body is concerned, it is primarily the face and hands that are
10
. When human skin is exposed to the sun, the body has a defense: an
11
of the skin’s natural oils and acids. For some time, women have been more effective than men in
12
for their skin. Eyes are a significant part of the body that are negatively affected by the sun.
The damage often goes undetected because it happens quite
13
On the other hand, hair becomes quite dry and brittle when exposed to the sun for an extended period. A lanolin-based conditioner is recommended by hair care professionals to
14
this problem. Perhaps a simple hat may be the best solution for hair.
​
overcome
maintaining
located
mixed
quickly
extended
prolonged
blend
arrangement
succeed
combined
surprisingly
slowly
triumph
affected
caring
minding

The damage often goes undetected because it happens quite 13 ____ On the other hand, hair becomes quite dry and brittle when exposed to the sun for an extended period. A lanolin-based conditioner is recommended by hair care professionals to 14 ____ this problem. Perhaps a simple hat may be the best solution for hair.$md$, NULL, ARRAY['.*slowly.*']);

COMMIT;
