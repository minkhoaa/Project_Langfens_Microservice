BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-water-treatment-2-reed-bed-1357'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-water-treatment-2-reed-bed-1357';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-water-treatment-2-reed-bed-1357';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-water-treatment-2-reed-bed-1357';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('b65252bb-4c5d-5d3d-a9c5-a11a63af55d1', 'ielts-reading-water-treatment-2-reed-bed-1357', $t$Water Treatment 2: Reed Bed$t$, $md$## Water Treatment 2: Reed Bed

Nguồn:
- Test: https://mini-ielts.com/1357/reading/water-treatment-2-reed-bed
- Solution: https://mini-ielts.com/1357/view-solution/reading/water-treatment-2-reed-bed$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('d5108509-9d23-529e-b22f-8e99790151cc', 'b65252bb-4c5d-5d3d-a9c5-a11a63af55d1', 1, $t$Reading — Water Treatment 2: Reed Bed$t$, $md$Read the passage and answer questions **1–11**.

### Passage: Water Treatment 2: Reed Bed

In recent years, it has been shown that plants, more accurately roots, play a crucial part in purifying dirty water before it enters seas and rivers. In 15th-century Britain, dirty water was purified by passing through the wetlands. People began to realize that the “natural” way of water purification was effective. Nowadays subsurface flow wetlands (SSFW) are a common alternative in Europe for the treatment of wastewater in rural areas, Mainly in the last 10 to 12 years there has been a significant growth in the number and size of the systems in use. The conventional mechanism of water purification used in big cities where there are large volumes of water to be purified is inappropriate in rural areas.

The common reed has the ability to transfer oxygen from its leaves, down through its stem and rhizomes, and out via its root system. As a result of this action, a very high population of microorganisms occurs in the root system, in zones of aerobic, anoxic, and anaerobic conditions. As the waste water moves very slowly through the mass of reed roots, this liquid can be successfully treated. The reason why they are so effective is often because within the bed’s root sector, natural biological, physical and chemical processes interact with one another to degrade or remove a good range of pollutants.

Dirty water from households, farms and factories consume a lot of oxygen in the water, which will lead to the death of aquatic creatures. Several aquatic plants are important in purifying water. They not only absorb carbon dioxide and release oxygen into the water, improving the environment for fish, but absorb nutrients from the welter as well. Britain and the G.S. differ in their preference of plants to purify water. Bulrushes (Scirpus spp.) and rushes (Juncus spp.) are excellent water purifiers. They remove excess nutrients from the water as well as oil and bacteria such as Escherichia coli and Salmonella. However, algae grow freely in summer and die off in winter. Their remains foul the bottom of the pool.

Artificial reed beds purify water in both horizontal and downflow ways. The reeds succeed best when a dense layer of root hairs has formed. It takes three years for the roots to fully develop. Which type of wetland a certain country applies varies widely depending on the country in Europe and its main lines of development. Besides the development of horizontal or vertical flow wetlands for wastewater treatment, the use of wetlands for sludge treatment has been very successful in Europe. Some special design lines offer the retention of microbiological organisms in constructed wetlands, the treatment of agricultural wastewater, treatment of some kinds of industrial wastewater, and the control of diffuse pollution.

If the water is slightly polluted, a horizontal system is used. Horizontal-flow wetlands may be of two types: free-water surface-flow (FWF) or sub-surface water-flow (SSF). In the former the effluent flows freely above the sand/gravel bed in which the reeds etc. are planted; in the latter effluent passes through the sand/gravel bed. In FWF-type wetlands, effluent is treated by plant stems, leaves and rhizomes. Such FWF wetlands are densely planted and typically have water-depths of less than 0.4m. However, dense planting can limit the diffusion of oxygen into the water.

These systems work particularly well for low strength effluents or effluents that have undergone some forms of pretreatment and play an invaluable role in tertiary treatment and the polishing of effluents. The horizontal reed flow system uses a long reed bed, where the liquid slowly flows horizontally through. The length of the reed bed is about 100 meters. The downside of horizontal reed beds is that they use up lots of land space and they do take quite a long time to produce clean water.

A vertical flow (downflow) reed bed is a sealed, gravel filled trench with reeds growing in it. The reeds in a downflow system are planted in a bed 60cm deep. In vertical flow reed beds, the wastewater is applied to the top of the reed bed, flows down through a rhizome zone with sludge as a substrate, then through a root zone with sand as a substrate, followed by a layer of gravel for drainage, and is collected in an under drainage system of large stones.

The effluent flows onto the surface of the bed and percolates slowly through the different layers into an outlet pipe, which leads to a horizontal flow bed where it is cleaned by millions of bacteria, algae, fungi, and microorganisms that digest the waste, including sewage. There is no standing water so there should be no unpleasant smells.

Vertical flow reed bed systems are much more effective than horizontal flow reedbeds not only in reducing biochemical oxygen demanded (BOD) and suspended solids (SS) levels but also in reducing ammonia levels and eliminating smells. Usually considerably smaller than horizontal flow beds, they are capable of handling muc stronger effluents which contain heavily polluted matters and have a longer lifetime value. A vertical reed bed system works more efficiently than a horizontal reed bed system, but it requires more management, and its reed beds are often operated for a few days then rested, so several beds and a distribution system are needed.

The natural way of water purification has many advantages over the conventional mechanism. The natural way requires less expenditure for installation, operation and maintenance. Besides, it looks attractive and can improve the surrounding landscape. Reed beds are natural habitats found in floodplains, waterlogged depressions and estuaries. The natural bed systems are a biologically proved, an environmentally friendly and visually unobtrusive way of treating wastewater, and have the extra virtue of frequently being better than mechanical wastewater treatment systems.

Over the medium to long term reed bed systems are, in most cases, more cost effective to install than any other wastewater treatment. They are naturally environmentally sound protecting groundwater, dams, creeks, rivers and estuaries.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('e80f7ba1-0c1c-5845-986f-42d1bef4eadf', 'd5108509-9d23-529e-b22f-8e99790151cc', 1, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 1

Questions 1-3
Questions 1-3
Do the following statements agree with the information given in Reading Passage?
In boxes 14-16 on your answer sheet, write
TRUE
FALSE
NOT GIVEN
if the statement agrees with the information
if the statement contradicts the information
if there is no information on this
1
The reed bed system is a conventional method for water treatment in urban areas.
2
In the reed roots, there is a series of processes that help break down the pollutants.
3
Escherichia coli is the most difficult bacteria to eliminate.

1 ____ The reed bed system is a conventional method for water treatment in urban areas. 2 ____ In the reed roots, there is a series of processes that help break down the pollutants. 3 ____ Escherichia coli is the most difficult bacteria to eliminate.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0fa494bf-b4f3-53a5-8a14-58bdefadfad0', 'e80f7ba1-0c1c-5845-986f-42d1bef4eadf', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('05032e6f-677e-5f0d-b8b5-37bea17c9649', 'e80f7ba1-0c1c-5845-986f-42d1bef4eadf', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1e738ded-2bb7-5ba1-a53a-aa75e57af1d7', 'e80f7ba1-0c1c-5845-986f-42d1bef4eadf', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('04012a96-4b0a-5f17-b763-dad1637bd6ac', 'd5108509-9d23-529e-b22f-8e99790151cc', 2, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 2

Questions 1-3
Questions 1-3
Do the following statements agree with the information given in Reading Passage?
In boxes 14-16 on your answer sheet, write
TRUE
FALSE
NOT GIVEN
if the statement agrees with the information
if the statement contradicts the information
if there is no information on this
1
The reed bed system is a conventional method for water treatment in urban areas.
2
In the reed roots, there is a series of processes that help break down the pollutants.
3
Escherichia coli is the most difficult bacteria to eliminate.

1 ____ The reed bed system is a conventional method for water treatment in urban areas. 2 ____ In the reed roots, there is a series of processes that help break down the pollutants. 3 ____ Escherichia coli is the most difficult bacteria to eliminate.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6d0fc73d-d203-5201-b1ba-02d61b43f01f', '04012a96-4b0a-5f17-b763-dad1637bd6ac', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9206d3ac-c3ef-5161-99cc-6fd2ebaee02a', '04012a96-4b0a-5f17-b763-dad1637bd6ac', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5625b401-349d-52d2-8464-d4c4cfb8500f', '04012a96-4b0a-5f17-b763-dad1637bd6ac', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('a295e53d-ed96-528e-83d9-ea6ccc20ec8b', 'd5108509-9d23-529e-b22f-8e99790151cc', 3, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 3

Questions 1-3
Questions 1-3
Do the following statements agree with the information given in Reading Passage?
In boxes 14-16 on your answer sheet, write
TRUE
FALSE
NOT GIVEN
if the statement agrees with the information
if the statement contradicts the information
if there is no information on this
1
The reed bed system is a conventional method for water treatment in urban areas.
2
In the reed roots, there is a series of processes that help break down the pollutants.
3
Escherichia coli is the most difficult bacteria to eliminate.

1 ____ The reed bed system is a conventional method for water treatment in urban areas. 2 ____ In the reed roots, there is a series of processes that help break down the pollutants. 3 ____ Escherichia coli is the most difficult bacteria to eliminate.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1d18d5f8-dbeb-5735-8fbc-f23298e04df7', 'a295e53d-ed96-528e-83d9-ea6ccc20ec8b', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8c6130d8-5247-5e04-bdf9-a9700b8a4618', 'a295e53d-ed96-528e-83d9-ea6ccc20ec8b', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('41b76897-e956-5017-b562-2cf1ae0e1ded', 'a295e53d-ed96-528e-83d9-ea6ccc20ec8b', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('7248f1fc-130f-58a6-b909-7df952550f24', 'd5108509-9d23-529e-b22f-8e99790151cc', 4, 'SHORT_ANSWER', 'READING', 2, $md$### Question 4

Questions 4-6
Questions 4-6
Complete the diagram below.
Choose
NO MORE THAN THREE WORDS
from the passage for each answer.
4
5
6

4 ____$md$, NULL, ARRAY['.*sludge.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('f3ec691d-bfd4-5868-97e7-6a1cfdb62f75', 'd5108509-9d23-529e-b22f-8e99790151cc', 5, 'SHORT_ANSWER', 'READING', 3, $md$### Question 5

Questions 4-6
Questions 4-6
Complete the diagram below.
Choose
NO MORE THAN THREE WORDS
from the passage for each answer.
4
5
6

5 ____$md$, NULL, ARRAY['.*sand.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('3f3ef416-18aa-540e-89d7-2442b7f7e5d9', 'd5108509-9d23-529e-b22f-8e99790151cc', 6, 'SHORT_ANSWER', 'READING', 3, $md$### Question 6

Questions 4-6
Questions 4-6
Complete the diagram below.
Choose
NO MORE THAN THREE WORDS
from the passage for each answer.
4
5
6

6 ____$md$, NULL, ARRAY['.*gravel.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('72f593f9-e742-5ba4-87e4-1d6ca4bed687', 'd5108509-9d23-529e-b22f-8e99790151cc', 7, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 7

Question 7-11
Question 7-11
Use the information in the passage to match the advantages and disadvantages of the two systems: horizontal flow system and down-flow system (listed A—H) below.
Write the appropriate letters A-H in boxes
7-11
on your answer sheet.
The advantage of the downflow system is
7
; however,
8
and
9
. The two advantages of the horizontal system are
10
and
11
. In comparison with the downflow system, the horizontal system is less effective.
A. it requires several beds
B. it is easier to construct
C. it builds on a gradient
D. it doesn’t need much attention
E. it produces less sludges
F. it isn’t always working
G. it needs deeper bed
H. it can deal with more heavily polluted water

The advantage of the downflow system is 7 ____ ; however, 8 ____ and 9 ____ . The two advantages of the horizontal system are 10 ____ and 11 ____ . In comparison with the downflow system, the horizontal system is less effective. A. it requires several beds B. it is easier to construct C. it builds on a gradient D. it doesn’t need much attention E. it produces less sludges F. it isn’t always working G. it needs deeper bed H. it can deal with more heavily polluted water$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a8c425e3-2360-52ef-bc8c-51abb8c7c8aa', '72f593f9-e742-5ba4-87e4-1d6ca4bed687', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d6d2c5ce-9256-5890-ae70-aa7dfc736fea', '72f593f9-e742-5ba4-87e4-1d6ca4bed687', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1231bba7-41f3-585e-a4fd-d5c81fe702a9', '72f593f9-e742-5ba4-87e4-1d6ca4bed687', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a93caa3b-99cc-5cf2-bac4-c761922f3a7a', '72f593f9-e742-5ba4-87e4-1d6ca4bed687', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('890697e8-9082-5caa-8366-332c6cb2f39a', '72f593f9-e742-5ba4-87e4-1d6ca4bed687', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2b87a560-262f-5e51-b486-d1606331f04c', '72f593f9-e742-5ba4-87e4-1d6ca4bed687', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('29cc3d80-d3a7-5bb9-b4a5-295401643069', '72f593f9-e742-5ba4-87e4-1d6ca4bed687', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a574763f-c7bb-5355-8d83-affc59fe8c5a', '72f593f9-e742-5ba4-87e4-1d6ca4bed687', 8, $md$H$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('dc6cd511-00cd-5b48-9db6-ca9f2b1bb382', 'd5108509-9d23-529e-b22f-8e99790151cc', 8, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 8

Question 7-11
Question 7-11
Use the information in the passage to match the advantages and disadvantages of the two systems: horizontal flow system and down-flow system (listed A—H) below.
Write the appropriate letters A-H in boxes
7-11
on your answer sheet.
The advantage of the downflow system is
7
; however,
8
and
9
. The two advantages of the horizontal system are
10
and
11
. In comparison with the downflow system, the horizontal system is less effective.
A. it requires several beds
B. it is easier to construct
C. it builds on a gradient
D. it doesn’t need much attention
E. it produces less sludges
F. it isn’t always working
G. it needs deeper bed
H. it can deal with more heavily polluted water

The advantage of the downflow system is 7 ____ ; however, 8 ____ and 9 ____ . The two advantages of the horizontal system are 10 ____ and 11 ____ . In comparison with the downflow system, the horizontal system is less effective. A. it requires several beds B. it is easier to construct C. it builds on a gradient D. it doesn’t need much attention E. it produces less sludges F. it isn’t always working G. it needs deeper bed H. it can deal with more heavily polluted water$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bafb7ab0-f1bf-567c-afde-6e28324e1776', 'dc6cd511-00cd-5b48-9db6-ca9f2b1bb382', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f45aafb6-9ec3-5e63-96f9-e83d001c2a64', 'dc6cd511-00cd-5b48-9db6-ca9f2b1bb382', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('838e304b-aed9-513a-adaf-5762b96e697a', 'dc6cd511-00cd-5b48-9db6-ca9f2b1bb382', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a9fc556e-3422-5e33-aa29-546341faabaa', 'dc6cd511-00cd-5b48-9db6-ca9f2b1bb382', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('899fbf85-fcff-55d5-88df-2b1077fbc34b', 'dc6cd511-00cd-5b48-9db6-ca9f2b1bb382', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0c78caa8-23c6-5824-b358-b3d9fad03d0c', 'dc6cd511-00cd-5b48-9db6-ca9f2b1bb382', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c38ea460-dda3-500b-b6b4-b70b89086ec6', 'dc6cd511-00cd-5b48-9db6-ca9f2b1bb382', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e7331304-dc2b-5d2f-b2b3-d0c6b55b92d8', 'dc6cd511-00cd-5b48-9db6-ca9f2b1bb382', 8, $md$H$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('0905acfa-5094-5759-bbf5-07c37e3d7598', 'd5108509-9d23-529e-b22f-8e99790151cc', 9, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 9

Question 7-11
Question 7-11
Use the information in the passage to match the advantages and disadvantages of the two systems: horizontal flow system and down-flow system (listed A—H) below.
Write the appropriate letters A-H in boxes
7-11
on your answer sheet.
The advantage of the downflow system is
7
; however,
8
and
9
. The two advantages of the horizontal system are
10
and
11
. In comparison with the downflow system, the horizontal system is less effective.
A. it requires several beds
B. it is easier to construct
C. it builds on a gradient
D. it doesn’t need much attention
E. it produces less sludges
F. it isn’t always working
G. it needs deeper bed
H. it can deal with more heavily polluted water

The advantage of the downflow system is 7 ____ ; however, 8 ____ and 9 ____ . The two advantages of the horizontal system are 10 ____ and 11 ____ . In comparison with the downflow system, the horizontal system is less effective. A. it requires several beds B. it is easier to construct C. it builds on a gradient D. it doesn’t need much attention E. it produces less sludges F. it isn’t always working G. it needs deeper bed H. it can deal with more heavily polluted water$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e73cac02-1369-5f07-9390-1abbc4476b9a', '0905acfa-5094-5759-bbf5-07c37e3d7598', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a7e98cfb-4667-5f35-b386-63fd84c7d087', '0905acfa-5094-5759-bbf5-07c37e3d7598', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d7dcd45a-d739-5e5e-8a2d-6bbc6fcbcaf8', '0905acfa-5094-5759-bbf5-07c37e3d7598', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4641f3e6-6add-5feb-991f-b8324a7a898b', '0905acfa-5094-5759-bbf5-07c37e3d7598', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('faf83580-e84b-59dc-a3c6-63290c92c91e', '0905acfa-5094-5759-bbf5-07c37e3d7598', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b28a2c5c-c236-5f1c-8435-7a478a853451', '0905acfa-5094-5759-bbf5-07c37e3d7598', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6434d391-d8eb-5be8-ba45-195256ad1966', '0905acfa-5094-5759-bbf5-07c37e3d7598', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('abe7ea68-056e-5cb0-b7e8-16e4342f8147', '0905acfa-5094-5759-bbf5-07c37e3d7598', 8, $md$H$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('cf685264-d23c-5f3f-a134-1eb75bd593a0', 'd5108509-9d23-529e-b22f-8e99790151cc', 10, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 10

Question 7-11
Question 7-11
Use the information in the passage to match the advantages and disadvantages of the two systems: horizontal flow system and down-flow system (listed A—H) below.
Write the appropriate letters A-H in boxes
7-11
on your answer sheet.
The advantage of the downflow system is
7
; however,
8
and
9
. The two advantages of the horizontal system are
10
and
11
. In comparison with the downflow system, the horizontal system is less effective.
A. it requires several beds
B. it is easier to construct
C. it builds on a gradient
D. it doesn’t need much attention
E. it produces less sludges
F. it isn’t always working
G. it needs deeper bed
H. it can deal with more heavily polluted water

The advantage of the downflow system is 7 ____ ; however, 8 ____ and 9 ____ . The two advantages of the horizontal system are 10 ____ and 11 ____ . In comparison with the downflow system, the horizontal system is less effective. A. it requires several beds B. it is easier to construct C. it builds on a gradient D. it doesn’t need much attention E. it produces less sludges F. it isn’t always working G. it needs deeper bed H. it can deal with more heavily polluted water$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('67c6d8e7-ba2e-5c5c-be9b-35a9be3847f3', 'cf685264-d23c-5f3f-a134-1eb75bd593a0', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('02dce226-be2f-56b2-a2e7-d5b7d5c97cba', 'cf685264-d23c-5f3f-a134-1eb75bd593a0', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f085e790-6727-5949-8d73-1378c3bda9ae', 'cf685264-d23c-5f3f-a134-1eb75bd593a0', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6f64e4f3-9c01-5553-9cb1-faa3c7449189', 'cf685264-d23c-5f3f-a134-1eb75bd593a0', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b5a8f71b-bbbd-5249-acb3-f8b6280eac78', 'cf685264-d23c-5f3f-a134-1eb75bd593a0', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fe33dba8-f1b2-5f46-9732-7f741afde3fb', 'cf685264-d23c-5f3f-a134-1eb75bd593a0', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e1491e30-406f-5b9b-b7b3-70e2db7ad5c9', 'cf685264-d23c-5f3f-a134-1eb75bd593a0', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('446909a2-c1b5-566e-8ce2-7d62a62ac2d5', 'cf685264-d23c-5f3f-a134-1eb75bd593a0', 8, $md$H$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('4c6da248-11e1-5198-ae4f-f991b1f06ba5', 'd5108509-9d23-529e-b22f-8e99790151cc', 11, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 11

Question 7-11
Question 7-11
Use the information in the passage to match the advantages and disadvantages of the two systems: horizontal flow system and down-flow system (listed A—H) below.
Write the appropriate letters A-H in boxes
7-11
on your answer sheet.
The advantage of the downflow system is
7
; however,
8
and
9
. The two advantages of the horizontal system are
10
and
11
. In comparison with the downflow system, the horizontal system is less effective.
A. it requires several beds
B. it is easier to construct
C. it builds on a gradient
D. it doesn’t need much attention
E. it produces less sludges
F. it isn’t always working
G. it needs deeper bed
H. it can deal with more heavily polluted water

The advantage of the downflow system is 7 ____ ; however, 8 ____ and 9 ____ . The two advantages of the horizontal system are 10 ____ and 11 ____ . In comparison with the downflow system, the horizontal system is less effective. A. it requires several beds B. it is easier to construct C. it builds on a gradient D. it doesn’t need much attention E. it produces less sludges F. it isn’t always working G. it needs deeper bed H. it can deal with more heavily polluted water$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7acce91c-c1bd-5c61-ad3f-76c83617fcad', '4c6da248-11e1-5198-ae4f-f991b1f06ba5', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f48f671e-1879-5f65-993d-281f58e660de', '4c6da248-11e1-5198-ae4f-f991b1f06ba5', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1240a28e-34e6-57ee-9bb2-322533918611', '4c6da248-11e1-5198-ae4f-f991b1f06ba5', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('df526992-f23b-5960-96b8-0730914a9d1f', '4c6da248-11e1-5198-ae4f-f991b1f06ba5', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e83f97b5-bfc4-5a53-8d0b-dbb8014980b8', '4c6da248-11e1-5198-ae4f-f991b1f06ba5', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e38a91f5-30f9-58ac-a937-79719f1e8c50', '4c6da248-11e1-5198-ae4f-f991b1f06ba5', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c2348703-577d-5931-8bad-ad7f12063263', '4c6da248-11e1-5198-ae4f-f991b1f06ba5', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b6faf45a-516f-5269-b179-122144ee8435', '4c6da248-11e1-5198-ae4f-f991b1f06ba5', 8, $md$H$md$, true);

COMMIT;
