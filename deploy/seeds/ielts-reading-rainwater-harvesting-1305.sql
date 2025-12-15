BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-rainwater-harvesting-1305'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-rainwater-harvesting-1305';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-rainwater-harvesting-1305';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-rainwater-harvesting-1305';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('2527cae9-7fb8-597d-aadd-76ef3c056317', 'ielts-reading-rainwater-harvesting-1305', $t$Rainwater Harvesting$t$, $md$## Rainwater Harvesting

Nguồn:
- Test: https://mini-ielts.com/1305/reading/rainwater-harvesting
- Solution: https://mini-ielts.com/1305/view-solution/reading/rainwater-harvesting$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('aea2de3e-52df-5edc-bc1d-aeb9f057ee05', '2527cae9-7fb8-597d-aadd-76ef3c056317', 1, $t$Reading — Rainwater Harvesting$t$, $md$Read the passage and answer questions **1–13**.

### Passage: Rainwater Harvesting

| | Rainwater Harvesting For two years southern Sri Lanka suffered a prolonged drought, described by locals as “the worst in 50 years”. Some areas didn’t see a successful crop for four or five consecutive seasons. Livestock died, water in wells dropped to dangerously low levels, children were increasingly malnourished and school attendance has fallen. An estimated 1.6 million people were affected. A Muthukandiya is a village in Moneragala district, one of the drought-stricken areas in the “dry zone” of southern Sri Lanka, where half the country’s population of 18 million lives. Rainfall in the area varies greatly from year to year, often bringing extreme dry spells in between monsoons. But this drought was much worse than usual. Despite some rain in November, only half of Moneragala’s 1,400 tube wells were in working order by March. The drought devastated supplies of rice and freshwater fish, the staple diet of inland villages. Many local industries closed down and villagers headed for the towns in search of work. B The villagers of muthukandiya arrived in the 1970s as part of a government resettlement scheme. Each family was given six acres of land, with no irrigation system. Because crop production, which relies entirely on rainfall, is insufficient to support most families, the village economy relies on men and women working as day-laborers in nearby sugar-cane plantations. Three wells have been dug to provide domestic water, but these run dry for much of the year. Women and children may spend several hours each day walking up to three miles (five kilometers) to fetch water for drinking, washing, and cooking. C In 1998, communities in the district discussed water problems with Practical Action South Asia. What followed was a drought mitigation initiative based on a low-cost “rainwater harvesting” technology already used in Sri Lanka and elsewhere in the region. It uses tanks to collect and store rain channeled by gutters and pipes as it runs off the roofs of houses. D Despite an indigenous tradition of rain-water harvesting and irrigation systems going back to the third century BC, policy-makers in modern times have often overlooked the value of such technologies, and it is only recently that officials have taken much interest in household-level structures. Government and other programmes have, however, been top-down in their conception and application, installing tanks free of charge without providing training in the skills needed to build and maintain them properly. Practical Action South Asia’s project deliberately took a different approach, aiming to build up a local skills base among builders and users of the tanks, and to create structures and systems so that communities can manage their own rainwater harvesting schemes. E The community of Muthukandiya was involved throughout. Two meetings were held where villagers analysed their water problems, developed a mitigation plan and selected the rainwater harvesting technology. Two local masons received several days’ on-the-job training in building the 5,000-litre household storage tanks: surface tanks out of Ferro-cement and underground tanks out of brick. Each system, including tank, pipes, gutters and filters, cost US$195 – equivalent to a month’s income for an average village family. Just over half the cost was provided by the community, in the form of materials and unskilled labour. Practical Action South Asia contributed the rest, including cement, transport and payment for the skilled labour. Households learned how to use and maintain the tanks, and the whole community was trained to keep domestic water supplies clean. A village rainwater harvesting society was set up to run the project. To date, 37 families in and around Muthukandiya have storage tanks. Evaluations show clearly that households with rainwater storage tanks have considerably more water for domestic needs than households relying entirely on wells and ponds. During the driest months, households with tanks may have up to twice as much water available. Their water is much cleaner, too. F Nandawathie, a widow in the village, has taken full advantage of the opportunities that rainwater harvesting has brought her family. With a better water supply now close at hand, she began by growing a few vegetables. The income from selling these helped her to open a small shop on her doorstep. This increased her earnings still further, enabling her to apply for a loan to install solar power in her house. She is now thinking of building another tank in her garden so that she can grow more vegetables. Nandawathie also feels safer now that she no longer has to fetch water from the village well in the early morning or late evening. She says that her children no longer complain so much of diarrhoea. And her daughter Sandamalee has more time for school work. G In the short term, and on a small scale, the project has clearly been a success. The challenge lies in making such initiatives sustainable and expanding their coverage. At a purely technical level, rainwater harvesting is evidently sustainable. In Muthukandiya, the skills required to build and maintain storage tanks were taught fairly easily and can be shared by the two trained masons, who are now finding work with other development agencies in the district. H The non-structural elements of the work, especially it’s financial and organizational, present a bigger challenge. A revolving fund was set up, with households that had already benefited agreeing to contribute a small monthly amount to pay for maintenance, repairs and new tanks. However, it appears that the revolving fund concept was not fully understood and it has proved difficult to get households to contribute. Recovering costs from interventions that do not generate income directly will always be a difficult proposition, although this can be overcome if the process is explained more fully at the outset. I The Muthkandiya initiative was planned as a demonstration project, to show that community-based drought mitigation through rainwater harvesting was feasible. Several other organizations have begun their own projects using the same approach. The feasibility of introducing larger tanks is being investigated. J However, a lot of effort and patience are needed to generate the interest, develop the skills and organize the management structures needed to implement sustainable community-based projects. It will probably be some time before rainwater harvesting technologies can spread rapidly and spontaneously across the district’s villages, without external support.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('bf2d3f7a-8721-5e98-b4bc-bdee3432bf61', 'aea2de3e-52df-5edc-bc1d-aeb9f057ee05', 1, 'SHORT_ANSWER', 'READING', 2, $md$### Question 1

Questions 1-6
Questions 1-6
Answer the questions below
Choose
NO MORE THAN THREE WORDS AND/OR A NUMBER
from the passage for each answer.
1
What is the major way for local people make barely support of living in Muthukandiya village?
1
2
Where can adult workers make extra money from in daytime?
2
3
What has been dug to supply water for daily household life?
3
4
In which year did the plan of a new project to lessen the effect of drought begins?
4
5
Where do the gutters and pipes collect rainwater from?
5
6
What helps the family obtain more water for domestic needs than those relying on only wells and ponds?
6

Answer the questions below Choose NO MORE THAN THREE WORDS AND/OR A NUMBER from the passage for each answer. 1 What is the major way for local people make barely support of living in Muthukandiya village? 1 ____ 2 Where can adult workers make extra money from in daytime? 2 ____ 3 What has been dug to supply water for daily household life? 3 ____ 4 In which year did the plan of a new project to lessen the effect of drought begins? 4 ____ 5 Where do the gutters and pipes collect rainwater from? 5 ____ 6 What helps the family obtain more water for domestic needs than those relying on only wells and ponds? 6 ____$md$, NULL, ARRAY['.*crop.*production.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('171cd838-4e37-5478-a6ee-60e270b4a239', 'aea2de3e-52df-5edc-bc1d-aeb9f057ee05', 2, 'SHORT_ANSWER', 'READING', 2, $md$### Question 2

Questions 1-6
Questions 1-6
Answer the questions below
Choose
NO MORE THAN THREE WORDS AND/OR A NUMBER
from the passage for each answer.
1
What is the major way for local people make barely support of living in Muthukandiya village?
1
2
Where can adult workers make extra money from in daytime?
2
3
What has been dug to supply water for daily household life?
3
4
In which year did the plan of a new project to lessen the effect of drought begins?
4
5
Where do the gutters and pipes collect rainwater from?
5
6
What helps the family obtain more water for domestic needs than those relying on only wells and ponds?
6

Answer the questions below Choose NO MORE THAN THREE WORDS AND/OR A NUMBER from the passage for each answer. 1 What is the major way for local people make barely support of living in Muthukandiya village? 1 ____ 2 Where can adult workers make extra money from in daytime? 2 ____ 3 What has been dug to supply water for daily household life? 3 ____ 4 In which year did the plan of a new project to lessen the effect of drought begins? 4 ____ 5 Where do the gutters and pipes collect rainwater from? 5 ____ 6 What helps the family obtain more water for domestic needs than those relying on only wells and ponds? 6 ____$md$, NULL, ARRAY['.*crop.*production.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('8a3888ba-067d-52b4-b0b9-a03c8634d8c1', 'aea2de3e-52df-5edc-bc1d-aeb9f057ee05', 3, 'SHORT_ANSWER', 'READING', 2, $md$### Question 3

Questions 1-6
Questions 1-6
Answer the questions below
Choose
NO MORE THAN THREE WORDS AND/OR A NUMBER
from the passage for each answer.
1
What is the major way for local people make barely support of living in Muthukandiya village?
1
2
Where can adult workers make extra money from in daytime?
2
3
What has been dug to supply water for daily household life?
3
4
In which year did the plan of a new project to lessen the effect of drought begins?
4
5
Where do the gutters and pipes collect rainwater from?
5
6
What helps the family obtain more water for domestic needs than those relying on only wells and ponds?
6

Answer the questions below Choose NO MORE THAN THREE WORDS AND/OR A NUMBER from the passage for each answer. 1 What is the major way for local people make barely support of living in Muthukandiya village? 1 ____ 2 Where can adult workers make extra money from in daytime? 2 ____ 3 What has been dug to supply water for daily household life? 3 ____ 4 In which year did the plan of a new project to lessen the effect of drought begins? 4 ____ 5 Where do the gutters and pipes collect rainwater from? 5 ____ 6 What helps the family obtain more water for domestic needs than those relying on only wells and ponds? 6 ____$md$, NULL, ARRAY['.*crop.*production.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('9dab03d9-0bcc-5fc5-835e-2b269aa3d7cb', 'aea2de3e-52df-5edc-bc1d-aeb9f057ee05', 4, 'SHORT_ANSWER', 'READING', 2, $md$### Question 4

Questions 1-6
Questions 1-6
Answer the questions below
Choose
NO MORE THAN THREE WORDS AND/OR A NUMBER
from the passage for each answer.
1
What is the major way for local people make barely support of living in Muthukandiya village?
1
2
Where can adult workers make extra money from in daytime?
2
3
What has been dug to supply water for daily household life?
3
4
In which year did the plan of a new project to lessen the effect of drought begins?
4
5
Where do the gutters and pipes collect rainwater from?
5
6
What helps the family obtain more water for domestic needs than those relying on only wells and ponds?
6

Answer the questions below Choose NO MORE THAN THREE WORDS AND/OR A NUMBER from the passage for each answer. 1 What is the major way for local people make barely support of living in Muthukandiya village? 1 ____ 2 Where can adult workers make extra money from in daytime? 2 ____ 3 What has been dug to supply water for daily household life? 3 ____ 4 In which year did the plan of a new project to lessen the effect of drought begins? 4 ____ 5 Where do the gutters and pipes collect rainwater from? 5 ____ 6 What helps the family obtain more water for domestic needs than those relying on only wells and ponds? 6 ____$md$, NULL, ARRAY['.*crop.*production.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('8dea78c5-4535-5815-88fa-4db9c88c4c2c', 'aea2de3e-52df-5edc-bc1d-aeb9f057ee05', 5, 'SHORT_ANSWER', 'READING', 3, $md$### Question 5

Questions 1-6
Questions 1-6
Answer the questions below
Choose
NO MORE THAN THREE WORDS AND/OR A NUMBER
from the passage for each answer.
1
What is the major way for local people make barely support of living in Muthukandiya village?
1
2
Where can adult workers make extra money from in daytime?
2
3
What has been dug to supply water for daily household life?
3
4
In which year did the plan of a new project to lessen the effect of drought begins?
4
5
Where do the gutters and pipes collect rainwater from?
5
6
What helps the family obtain more water for domestic needs than those relying on only wells and ponds?
6

Answer the questions below Choose NO MORE THAN THREE WORDS AND/OR A NUMBER from the passage for each answer. 1 What is the major way for local people make barely support of living in Muthukandiya village? 1 ____ 2 Where can adult workers make extra money from in daytime? 2 ____ 3 What has been dug to supply water for daily household life? 3 ____ 4 In which year did the plan of a new project to lessen the effect of drought begins? 4 ____ 5 Where do the gutters and pipes collect rainwater from? 5 ____ 6 What helps the family obtain more water for domestic needs than those relying on only wells and ponds? 6 ____$md$, NULL, ARRAY['.*crop.*production.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('fcf51af3-37b0-559c-a7cc-9d6144bbb87a', 'aea2de3e-52df-5edc-bc1d-aeb9f057ee05', 6, 'SHORT_ANSWER', 'READING', 3, $md$### Question 6

Questions 1-6
Questions 1-6
Answer the questions below
Choose
NO MORE THAN THREE WORDS AND/OR A NUMBER
from the passage for each answer.
1
What is the major way for local people make barely support of living in Muthukandiya village?
1
2
Where can adult workers make extra money from in daytime?
2
3
What has been dug to supply water for daily household life?
3
4
In which year did the plan of a new project to lessen the effect of drought begins?
4
5
Where do the gutters and pipes collect rainwater from?
5
6
What helps the family obtain more water for domestic needs than those relying on only wells and ponds?
6

Answer the questions below Choose NO MORE THAN THREE WORDS AND/OR A NUMBER from the passage for each answer. 1 What is the major way for local people make barely support of living in Muthukandiya village? 1 ____ 2 Where can adult workers make extra money from in daytime? 2 ____ 3 What has been dug to supply water for daily household life? 3 ____ 4 In which year did the plan of a new project to lessen the effect of drought begins? 4 ____ 5 Where do the gutters and pipes collect rainwater from? 5 ____ 6 What helps the family obtain more water for domestic needs than those relying on only wells and ponds? 6 ____$md$, NULL, ARRAY['.*crop.*production.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('b8fecc34-c18e-5916-aa16-af657b845664', 'aea2de3e-52df-5edc-bc1d-aeb9f057ee05', 7, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 7

Questions 7-13
Questions 7-13
Do the following statements agree with the information given in Reading Passage 1?
In boxes 7-13 on your answer sheet, write
YES
if the statement is true
NO
if the statement is false
NOT GIVEN
if the information is not given in the passage
7
Most of the government’s actions and other programs have somewhat failed.
8
Masons were trained for the constructing parts of the rainwater harvesting system.
9
The cost of rainwater harvesting systems was shared by local villagers and the local government.
10
Tanks increase both the amount and quality of the water for domestic use.
11
To send her daughter to school, a widow had to work for a job in a rainwater harvesting scheme.
12
Households benefited began to pay part of the maintenance or repairs.
13
Training two masons at the same time is much more preferable to training a single one.

Do the following statements agree with the information given in Reading Passage 1? In boxes 7-13 on your answer sheet, write YES if the statement is true NO if the statement is false NOT GIVEN if the information is not given in the passage 7 ____ Most of the government’s actions and other programs have somewhat failed. 8 ____ Masons were trained for the constructing parts of the rainwater harvesting system. 9 ____ The cost of rainwater harvesting systems was shared by local villagers and the local government. 10 ____ Tanks increase both the amount and quality of the water for domestic use. 11 ____ To send her daughter to school, a widow had to work for a job in a rainwater harvesting scheme. 12 ____ Households benefited began to pay part of the maintenance or repairs. 13 ____ Training two masons at the same time is much more preferable to training a single one.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7e533364-c8c4-5eea-82bc-7fbbda606f33', 'b8fecc34-c18e-5916-aa16-af657b845664', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('64916c0d-33c2-5484-8fae-0bd29ed7d9ad', 'b8fecc34-c18e-5916-aa16-af657b845664', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f675fc3b-f0cd-55dd-b916-4a296dcdc8c6', 'b8fecc34-c18e-5916-aa16-af657b845664', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('3a9f0cf7-5357-546d-be21-a9761801adea', 'aea2de3e-52df-5edc-bc1d-aeb9f057ee05', 8, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 8

Questions 7-13
Questions 7-13
Do the following statements agree with the information given in Reading Passage 1?
In boxes 7-13 on your answer sheet, write
YES
if the statement is true
NO
if the statement is false
NOT GIVEN
if the information is not given in the passage
7
Most of the government’s actions and other programs have somewhat failed.
8
Masons were trained for the constructing parts of the rainwater harvesting system.
9
The cost of rainwater harvesting systems was shared by local villagers and the local government.
10
Tanks increase both the amount and quality of the water for domestic use.
11
To send her daughter to school, a widow had to work for a job in a rainwater harvesting scheme.
12
Households benefited began to pay part of the maintenance or repairs.
13
Training two masons at the same time is much more preferable to training a single one.

Do the following statements agree with the information given in Reading Passage 1? In boxes 7-13 on your answer sheet, write YES if the statement is true NO if the statement is false NOT GIVEN if the information is not given in the passage 7 ____ Most of the government’s actions and other programs have somewhat failed. 8 ____ Masons were trained for the constructing parts of the rainwater harvesting system. 9 ____ The cost of rainwater harvesting systems was shared by local villagers and the local government. 10 ____ Tanks increase both the amount and quality of the water for domestic use. 11 ____ To send her daughter to school, a widow had to work for a job in a rainwater harvesting scheme. 12 ____ Households benefited began to pay part of the maintenance or repairs. 13 ____ Training two masons at the same time is much more preferable to training a single one.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1ac683bb-8880-5e69-ae69-e8a1b474371b', '3a9f0cf7-5357-546d-be21-a9761801adea', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bca743d5-4cbd-58b6-8d26-68b60d163b2a', '3a9f0cf7-5357-546d-be21-a9761801adea', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a3af2f7f-6b5b-5e3d-b2db-04907e50602b', '3a9f0cf7-5357-546d-be21-a9761801adea', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('378bc42f-2ef4-589d-bfe1-5f05f7955b52', 'aea2de3e-52df-5edc-bc1d-aeb9f057ee05', 9, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 9

Questions 7-13
Questions 7-13
Do the following statements agree with the information given in Reading Passage 1?
In boxes 7-13 on your answer sheet, write
YES
if the statement is true
NO
if the statement is false
NOT GIVEN
if the information is not given in the passage
7
Most of the government’s actions and other programs have somewhat failed.
8
Masons were trained for the constructing parts of the rainwater harvesting system.
9
The cost of rainwater harvesting systems was shared by local villagers and the local government.
10
Tanks increase both the amount and quality of the water for domestic use.
11
To send her daughter to school, a widow had to work for a job in a rainwater harvesting scheme.
12
Households benefited began to pay part of the maintenance or repairs.
13
Training two masons at the same time is much more preferable to training a single one.

Do the following statements agree with the information given in Reading Passage 1? In boxes 7-13 on your answer sheet, write YES if the statement is true NO if the statement is false NOT GIVEN if the information is not given in the passage 7 ____ Most of the government’s actions and other programs have somewhat failed. 8 ____ Masons were trained for the constructing parts of the rainwater harvesting system. 9 ____ The cost of rainwater harvesting systems was shared by local villagers and the local government. 10 ____ Tanks increase both the amount and quality of the water for domestic use. 11 ____ To send her daughter to school, a widow had to work for a job in a rainwater harvesting scheme. 12 ____ Households benefited began to pay part of the maintenance or repairs. 13 ____ Training two masons at the same time is much more preferable to training a single one.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9d75dfef-4ef8-5a07-a1f9-2db8fe5339ef', '378bc42f-2ef4-589d-bfe1-5f05f7955b52', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('98c44b84-dd04-5201-9fa4-2efee6e58c6a', '378bc42f-2ef4-589d-bfe1-5f05f7955b52', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('44b85e25-96c1-5b96-81df-59459cb877aa', '378bc42f-2ef4-589d-bfe1-5f05f7955b52', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('6a23210c-1c4b-59b1-a5bd-8964400d2276', 'aea2de3e-52df-5edc-bc1d-aeb9f057ee05', 10, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 10

Questions 7-13
Questions 7-13
Do the following statements agree with the information given in Reading Passage 1?
In boxes 7-13 on your answer sheet, write
YES
if the statement is true
NO
if the statement is false
NOT GIVEN
if the information is not given in the passage
7
Most of the government’s actions and other programs have somewhat failed.
8
Masons were trained for the constructing parts of the rainwater harvesting system.
9
The cost of rainwater harvesting systems was shared by local villagers and the local government.
10
Tanks increase both the amount and quality of the water for domestic use.
11
To send her daughter to school, a widow had to work for a job in a rainwater harvesting scheme.
12
Households benefited began to pay part of the maintenance or repairs.
13
Training two masons at the same time is much more preferable to training a single one.

Do the following statements agree with the information given in Reading Passage 1? In boxes 7-13 on your answer sheet, write YES if the statement is true NO if the statement is false NOT GIVEN if the information is not given in the passage 7 ____ Most of the government’s actions and other programs have somewhat failed. 8 ____ Masons were trained for the constructing parts of the rainwater harvesting system. 9 ____ The cost of rainwater harvesting systems was shared by local villagers and the local government. 10 ____ Tanks increase both the amount and quality of the water for domestic use. 11 ____ To send her daughter to school, a widow had to work for a job in a rainwater harvesting scheme. 12 ____ Households benefited began to pay part of the maintenance or repairs. 13 ____ Training two masons at the same time is much more preferable to training a single one.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8ddbb3a0-fac6-5c18-85ba-e1666c3c8816', '6a23210c-1c4b-59b1-a5bd-8964400d2276', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('caf10972-217a-53eb-a138-594661594807', '6a23210c-1c4b-59b1-a5bd-8964400d2276', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5bbfe54e-21d0-52ca-ab28-c64a441dbb95', '6a23210c-1c4b-59b1-a5bd-8964400d2276', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('a90ebe0a-894b-5bb4-8fb0-a9be8c0ca9e5', 'aea2de3e-52df-5edc-bc1d-aeb9f057ee05', 11, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 11

Questions 7-13
Questions 7-13
Do the following statements agree with the information given in Reading Passage 1?
In boxes 7-13 on your answer sheet, write
YES
if the statement is true
NO
if the statement is false
NOT GIVEN
if the information is not given in the passage
7
Most of the government’s actions and other programs have somewhat failed.
8
Masons were trained for the constructing parts of the rainwater harvesting system.
9
The cost of rainwater harvesting systems was shared by local villagers and the local government.
10
Tanks increase both the amount and quality of the water for domestic use.
11
To send her daughter to school, a widow had to work for a job in a rainwater harvesting scheme.
12
Households benefited began to pay part of the maintenance or repairs.
13
Training two masons at the same time is much more preferable to training a single one.

Do the following statements agree with the information given in Reading Passage 1? In boxes 7-13 on your answer sheet, write YES if the statement is true NO if the statement is false NOT GIVEN if the information is not given in the passage 7 ____ Most of the government’s actions and other programs have somewhat failed. 8 ____ Masons were trained for the constructing parts of the rainwater harvesting system. 9 ____ The cost of rainwater harvesting systems was shared by local villagers and the local government. 10 ____ Tanks increase both the amount and quality of the water for domestic use. 11 ____ To send her daughter to school, a widow had to work for a job in a rainwater harvesting scheme. 12 ____ Households benefited began to pay part of the maintenance or repairs. 13 ____ Training two masons at the same time is much more preferable to training a single one.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4b8a331b-c2a8-5fb9-a599-f7150aa39b68', 'a90ebe0a-894b-5bb4-8fb0-a9be8c0ca9e5', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cda00e46-0705-5d2e-a235-2c479b1db27d', 'a90ebe0a-894b-5bb4-8fb0-a9be8c0ca9e5', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f5741aa6-3a12-5aa9-902d-d9f2de3ffca1', 'a90ebe0a-894b-5bb4-8fb0-a9be8c0ca9e5', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('95f976cf-3148-5116-9adc-cb91c016afd4', 'aea2de3e-52df-5edc-bc1d-aeb9f057ee05', 12, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 12

Questions 7-13
Questions 7-13
Do the following statements agree with the information given in Reading Passage 1?
In boxes 7-13 on your answer sheet, write
YES
if the statement is true
NO
if the statement is false
NOT GIVEN
if the information is not given in the passage
7
Most of the government’s actions and other programs have somewhat failed.
8
Masons were trained for the constructing parts of the rainwater harvesting system.
9
The cost of rainwater harvesting systems was shared by local villagers and the local government.
10
Tanks increase both the amount and quality of the water for domestic use.
11
To send her daughter to school, a widow had to work for a job in a rainwater harvesting scheme.
12
Households benefited began to pay part of the maintenance or repairs.
13
Training two masons at the same time is much more preferable to training a single one.

Do the following statements agree with the information given in Reading Passage 1? In boxes 7-13 on your answer sheet, write YES if the statement is true NO if the statement is false NOT GIVEN if the information is not given in the passage 7 ____ Most of the government’s actions and other programs have somewhat failed. 8 ____ Masons were trained for the constructing parts of the rainwater harvesting system. 9 ____ The cost of rainwater harvesting systems was shared by local villagers and the local government. 10 ____ Tanks increase both the amount and quality of the water for domestic use. 11 ____ To send her daughter to school, a widow had to work for a job in a rainwater harvesting scheme. 12 ____ Households benefited began to pay part of the maintenance or repairs. 13 ____ Training two masons at the same time is much more preferable to training a single one.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('152f0e2b-2224-5a8d-a93e-5d48565c16a7', '95f976cf-3148-5116-9adc-cb91c016afd4', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cacd62b6-4ca2-5263-98fa-09a74cebcad3', '95f976cf-3148-5116-9adc-cb91c016afd4', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f580504e-412e-598f-abdc-3f69127e2f9e', '95f976cf-3148-5116-9adc-cb91c016afd4', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('5deaf86d-bcbb-5905-9370-55c863ccf191', 'aea2de3e-52df-5edc-bc1d-aeb9f057ee05', 13, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 13

Questions 7-13
Questions 7-13
Do the following statements agree with the information given in Reading Passage 1?
In boxes 7-13 on your answer sheet, write
YES
if the statement is true
NO
if the statement is false
NOT GIVEN
if the information is not given in the passage
7
Most of the government’s actions and other programs have somewhat failed.
8
Masons were trained for the constructing parts of the rainwater harvesting system.
9
The cost of rainwater harvesting systems was shared by local villagers and the local government.
10
Tanks increase both the amount and quality of the water for domestic use.
11
To send her daughter to school, a widow had to work for a job in a rainwater harvesting scheme.
12
Households benefited began to pay part of the maintenance or repairs.
13
Training two masons at the same time is much more preferable to training a single one.

Do the following statements agree with the information given in Reading Passage 1? In boxes 7-13 on your answer sheet, write YES if the statement is true NO if the statement is false NOT GIVEN if the information is not given in the passage 7 ____ Most of the government’s actions and other programs have somewhat failed. 8 ____ Masons were trained for the constructing parts of the rainwater harvesting system. 9 ____ The cost of rainwater harvesting systems was shared by local villagers and the local government. 10 ____ Tanks increase both the amount and quality of the water for domestic use. 11 ____ To send her daughter to school, a widow had to work for a job in a rainwater harvesting scheme. 12 ____ Households benefited began to pay part of the maintenance or repairs. 13 ____ Training two masons at the same time is much more preferable to training a single one.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0c53050a-a286-588a-b06d-6f8e4b2b6657', '5deaf86d-bcbb-5905-9370-55c863ccf191', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6839ebb3-1410-5c32-9fd1-1ac02cc3899a', '5deaf86d-bcbb-5905-9370-55c863ccf191', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fd0b9f43-ca7b-5499-84d0-8dc8ee71da79', '5deaf86d-bcbb-5905-9370-55c863ccf191', 3, $md$NOT GIVEN$md$, true);

COMMIT;
