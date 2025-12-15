BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-satellite-technology-1268'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-satellite-technology-1268';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-satellite-technology-1268';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-satellite-technology-1268';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('cf768d19-da36-556f-95d8-4ab557617034', 'ielts-reading-satellite-technology-1268', $t$Satellite Technology$t$, $md$## Satellite Technology

Nguồn:
- Test: https://mini-ielts.com/1268/reading/satellite-technology
- Solution: https://mini-ielts.com/1268/view-solution/reading/satellite-technology$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('73c0ffc5-ae5f-5291-bcc1-a7856cfca0f8', 'cf768d19-da36-556f-95d8-4ab557617034', 1, $t$Reading — Satellite Technology$t$, $md$Read the passage and answer questions **1–13**.

### Passage: Satellite Technology

The space-age began with the launch of the Russian artificial satellite Sputnik in 1957 and developed further with the race to the moon between the United States and Russia. This rivalry was characterized by advanced technology and huge budgets. In this process, there were spectacular successes, some failures, but also many spin-offs.

Europe, Japan, China, and India quickly joined this space club of the superpowers. With the advent of relatively low-cost high-performance mini-satellites and launchers, the acquisition of indigenous space capabilities by smaller nations in Asia has become possible. How, in what manner, and for what purpose will these capabilities be realized?

A

Rocket technology has progressed considerably since the days of ‘fire arrows’ (bamboo poles filled with gunpowder) first used in China around 500 BC, and, during the Sung Dynasty, to repel Mongol invaders at the battle of Kaifeng (Kai-fung fu) in AD 1232. These ancient rockets stand in stark contrast to the present-day Chinese rocket launch vehicles, called the ‘Long March’, intended to place a Chinese astronaut in space by 2005 and, perhaps, to achieve a Chinese moon-landing by the end of the decade.

B

In the last decade, there has been a dramatic growth in space activities in Asia both in the utilization of space-based services and the production of satellites and launchers. This rapid expansion has led many commentators and analysts to predict that Asia will become a world space power. The space-age has had dramatic effects worldwide with direct developments in space technology influencing telecommunications, meteorological forecasting, earth resource and environmental monitoring, and disaster mitigation (flood, forest fires, and oil spills). Asian nations have been particularly eager to embrace these developments.

C

New and innovative uses for satellites are constantly being explored with potential revolutionary effects, such as in the field of health and telemedicine, distance education, crime prevention (piracy on the high seas), food and agricultural planning and production (rice crop monitoring). Space in Asia is very much influenced by the competitive commercial space sector, the emergence of low-cost mini-satellites, and the globalization of industrial and financial markets. It is not evident how Asian space will develop in the coming decades in the face of these trends. It is, however, important to understand and assess the factors and forces that shape Asian space activities and development in determining its possible consequences for the region.

D

At present, three Asian nations, Japan, China, and India, have comprehensive end-to-end space capabilities and possess a complete space infrastructure: space technology, satellite manufacturing, rockets, and spaceports. Already self-sufficient in terms of satellite design and manufacturing, South Korea is currently attempting to join their ranks with its plans to develop a launch site and spaceport. Additionally, nations in Southeast Asia as well as those bordering the Indian subcontinent (Nepal, Pakistan, and Bangladesh), have, or are starting to develop indigenous space programmes. The Association of Southeast Asian Nations (ASEAN) has, in varying degrees, embraced space applications using foreign technology and over the past five years or so its space activities have been expanding. Southeast Asia is predicted to become the largest and fastest-growing market for commercial space products and applications, driven by telecommunications (mobile and fixed services), the Internet, and remote sensing applications. In the development of this technology, many non-technical factors, such as economics, politics, culture, and history, interact and play important roles, which in turn affect Asian technology.

E

Asia and Southeast Asia, in particular, suffers from a long list of recurrent large-scale environmental problems including storms and flooding, forest fires and deforestation, and crop failures. Thus the space application that has attracted the most attention in this region is remote sensing. Remote sensing satellites equipped with instruments to take photographs of the ground at different wavelengths provide essential information for natural resource accounting, environmental management, disaster prevention and monitoring, land-use mapping, and sustainable development planning. Progress in these applications has been rapid and impressive. ASEAN members, unlike Japan, China, and India, do not have their own remote sensing satellites, however, most of its member nations have facilities to receive, process, and interpret such data from American and European satellites. In particular, Thailand, Malaysia, and Singapore have world-class remote sensing processing facilities and research programmes. ASEAN has plans to develop (and launch) its own satellites and in particular remote sensing satellites. Japan is regarded as the dominant space power in Asia and its record of successes and quality of technologies are equal to those of the West. In view of the technological challenges and high risks involved in space activities, a very long, and expensive, the learning curve has been followed to obtain those successes achieved. Japan, s satellite manufacturing was based on the old and traditional defense and military procurement methodologies as practiced in the US and Europe.

F

In recent years there have been fundamental changes in the way satellites are designed and built to drastically reduce costs. The emergence of ‘small satellites’ and their quick adoption by Asian countries as a way to develop low-cost satellite technology and rapidly establish a space capability has given these countries the possibility to shorten their learning curve by a decade or more. The global increase of technology transfer mechanisms and use of readily available commercial technology to replace costly space and military-standard components may very well result in a highly competitive Asian satellite manufacturing industry.

G

The laws of physics are the same in Tokyo as in Toulouse, and the principles of electronics and mechanics know no political or cultural boundaries. However, no such immutability applies to engineer practices and management; they are very much influenced by education, culture, and history. These factors, in turn, have an effect on costs, lead times, product designs and, eventually, international sales. Many Asian nations are sending their engineers to be trained in the West. Highly experienced, they return to work in the growing Asian space industry. Will this acquisition of technical expertise, coupled perhaps with the world-renowned Japanese manufacturing and management techniques, be applied to build world-class satellites and reduce costs?$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('bcd73757-8f83-5b76-af17-a3063cb979a0', '73c0ffc5-ae5f-5291-bcc1-a7856cfca0f8', 1, 'MATCHING_HEADING', 'READING', 2, $md$### Question 1

Questions 1-5
Questions 1-5
The reading passage has seven paragraphs,
A-G
Choose the correct heading for paragraphs
A-G
from the list below.
Write the correct number,
i-ix
, in boxes
1-5
on your answer sheet.
List of Headings
i
Western countries provide essential assistance
ii
Unbalanced development for an essential space technology
iii
Innovative application compelled by competition
iv
An ancient invention which is related to the future
v
Military purpose of the satellite
vi
Rockets for application in ancient China
vii
Space development in Asia in the past
viii
Non-technology factors counts
ix
competitive edge gained by more economically feasible satellite
1
Paragraph
A
2
Paragraph
B
3
Paragraph
C
Paragraph D
Example: Current space technology development in Asia
4
Paragraph
E
5
Paragraph
F

1 ____ Paragraph A$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cd303cac-0f25-56bd-b6a4-e4ee4a8a9b33', 'bcd73757-8f83-5b76-af17-a3063cb979a0', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('97f95fdb-ffe7-5468-9495-895ec4215e49', 'bcd73757-8f83-5b76-af17-a3063cb979a0', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('15ad7eff-f959-5322-8fb2-fdc359a0593a', 'bcd73757-8f83-5b76-af17-a3063cb979a0', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4d0326a0-f497-5baf-8c8d-955b02490b58', 'bcd73757-8f83-5b76-af17-a3063cb979a0', 4, $md$iv$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c8c1f755-bb7b-5661-8327-285b3ff1edea', 'bcd73757-8f83-5b76-af17-a3063cb979a0', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2d9cdd05-a6c1-5c66-9437-3943d4dfb9fb', 'bcd73757-8f83-5b76-af17-a3063cb979a0', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('84ce0bf7-e636-51fd-8b20-e432db725bfe', 'bcd73757-8f83-5b76-af17-a3063cb979a0', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a498313a-f48f-5089-a278-96058bdc4a1a', 'bcd73757-8f83-5b76-af17-a3063cb979a0', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('96c51506-5d65-5fac-86c1-6eb6dc3664bd', 'bcd73757-8f83-5b76-af17-a3063cb979a0', 9, $md$ix$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('59c812dd-7e96-5c1e-ba71-465940032bbe', '73c0ffc5-ae5f-5291-bcc1-a7856cfca0f8', 2, 'MATCHING_HEADING', 'READING', 2, $md$### Question 2

Questions 1-5
Questions 1-5
The reading passage has seven paragraphs,
A-G
Choose the correct heading for paragraphs
A-G
from the list below.
Write the correct number,
i-ix
, in boxes
1-5
on your answer sheet.
List of Headings
i
Western countries provide essential assistance
ii
Unbalanced development for an essential space technology
iii
Innovative application compelled by competition
iv
An ancient invention which is related to the future
v
Military purpose of the satellite
vi
Rockets for application in ancient China
vii
Space development in Asia in the past
viii
Non-technology factors counts
ix
competitive edge gained by more economically feasible satellite
1
Paragraph
A
2
Paragraph
B
3
Paragraph
C
Paragraph D
Example: Current space technology development in Asia
4
Paragraph
E
5
Paragraph
F

2 ____ Paragraph B$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ab984288-9048-54fe-b4a4-672053f70aae', '59c812dd-7e96-5c1e-ba71-465940032bbe', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('272d73ce-9150-5985-8307-74a9e205a947', '59c812dd-7e96-5c1e-ba71-465940032bbe', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f72c2521-f42c-57bf-b738-0018b1fe0be6', '59c812dd-7e96-5c1e-ba71-465940032bbe', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('acb2bf01-7e30-5d01-84fd-9e96b61429ba', '59c812dd-7e96-5c1e-ba71-465940032bbe', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('89881b45-6eb7-55dc-8b7c-54cb621a7cd5', '59c812dd-7e96-5c1e-ba71-465940032bbe', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('45dc5f27-1143-5d42-bf1e-1b27a35f5540', '59c812dd-7e96-5c1e-ba71-465940032bbe', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3a4401ec-0a51-55b0-9867-88147d72dcbe', '59c812dd-7e96-5c1e-ba71-465940032bbe', 7, $md$vii$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e4365fb6-16d9-5d5f-b5e3-7cfff59aad1d', '59c812dd-7e96-5c1e-ba71-465940032bbe', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5f814bf9-9d04-5e2d-b90b-c300555d6821', '59c812dd-7e96-5c1e-ba71-465940032bbe', 9, $md$ix$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('c7ead325-ca39-5a58-8a02-fe76ed45fe30', '73c0ffc5-ae5f-5291-bcc1-a7856cfca0f8', 3, 'MATCHING_HEADING', 'READING', 2, $md$### Question 3

Questions 1-5
Questions 1-5
The reading passage has seven paragraphs,
A-G
Choose the correct heading for paragraphs
A-G
from the list below.
Write the correct number,
i-ix
, in boxes
1-5
on your answer sheet.
List of Headings
i
Western countries provide essential assistance
ii
Unbalanced development for an essential space technology
iii
Innovative application compelled by competition
iv
An ancient invention which is related to the future
v
Military purpose of the satellite
vi
Rockets for application in ancient China
vii
Space development in Asia in the past
viii
Non-technology factors counts
ix
competitive edge gained by more economically feasible satellite
1
Paragraph
A
2
Paragraph
B
3
Paragraph
C
Paragraph D
Example: Current space technology development in Asia
4
Paragraph
E
5
Paragraph
F

3 ____ Paragraph C$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('115e5520-73bd-5720-be93-c894dfe20ddc', 'c7ead325-ca39-5a58-8a02-fe76ed45fe30', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c4ac5b06-0f0b-5160-8ff6-d8826034b05b', 'c7ead325-ca39-5a58-8a02-fe76ed45fe30', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('34b668b8-53b8-53dc-a0a8-5fe41f005411', 'c7ead325-ca39-5a58-8a02-fe76ed45fe30', 3, $md$iii$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0f9de5de-1254-51ce-8231-d9fe0b5abd04', 'c7ead325-ca39-5a58-8a02-fe76ed45fe30', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c2631595-14a9-58ba-89de-334b6769da93', 'c7ead325-ca39-5a58-8a02-fe76ed45fe30', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5bf63bed-730a-5add-b22e-7aca29776495', 'c7ead325-ca39-5a58-8a02-fe76ed45fe30', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('686c2d46-eaae-5131-a113-f5067f0fe69b', 'c7ead325-ca39-5a58-8a02-fe76ed45fe30', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('af874cf0-ec60-58c8-b9c2-cee23116d8ad', 'c7ead325-ca39-5a58-8a02-fe76ed45fe30', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8032323d-50a8-5ec3-9060-83be0623594f', 'c7ead325-ca39-5a58-8a02-fe76ed45fe30', 9, $md$ix$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('42a11d45-6f82-54d0-a27a-aadf413043c9', '73c0ffc5-ae5f-5291-bcc1-a7856cfca0f8', 4, 'MATCHING_HEADING', 'READING', 2, $md$### Question 4

Questions 1-5
Questions 1-5
The reading passage has seven paragraphs,
A-G
Choose the correct heading for paragraphs
A-G
from the list below.
Write the correct number,
i-ix
, in boxes
1-5
on your answer sheet.
List of Headings
i
Western countries provide essential assistance
ii
Unbalanced development for an essential space technology
iii
Innovative application compelled by competition
iv
An ancient invention which is related to the future
v
Military purpose of the satellite
vi
Rockets for application in ancient China
vii
Space development in Asia in the past
viii
Non-technology factors counts
ix
competitive edge gained by more economically feasible satellite
1
Paragraph
A
2
Paragraph
B
3
Paragraph
C
Paragraph D
Example: Current space technology development in Asia
4
Paragraph
E
5
Paragraph
F

4 ____ Paragraph E$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('90d16785-6e78-5f76-8cfe-c0e2c4310585', '42a11d45-6f82-54d0-a27a-aadf413043c9', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8ba1084a-8f03-59e1-b59e-42022ec10487', '42a11d45-6f82-54d0-a27a-aadf413043c9', 2, $md$ii$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('200df3c5-767b-5dbc-8e00-cd189f849686', '42a11d45-6f82-54d0-a27a-aadf413043c9', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c80ee715-1b95-56a7-aca4-61473ec8ce65', '42a11d45-6f82-54d0-a27a-aadf413043c9', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('17628ec9-34e0-59ce-b0bc-f1e3bf7064aa', '42a11d45-6f82-54d0-a27a-aadf413043c9', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('38986ce6-4ddb-5900-bda1-20486505b840', '42a11d45-6f82-54d0-a27a-aadf413043c9', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e7d0c5c9-b9db-55ab-a859-303e6cb64f46', '42a11d45-6f82-54d0-a27a-aadf413043c9', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a034f53a-bc7e-5c8f-8303-a6ab845b0870', '42a11d45-6f82-54d0-a27a-aadf413043c9', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('45cc8fee-cce1-58c9-b010-c51459a3211f', '42a11d45-6f82-54d0-a27a-aadf413043c9', 9, $md$ix$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('d6cd221c-176e-5081-abd3-939c511af585', '73c0ffc5-ae5f-5291-bcc1-a7856cfca0f8', 5, 'MATCHING_HEADING', 'READING', 3, $md$### Question 5

Questions 1-5
Questions 1-5
The reading passage has seven paragraphs,
A-G
Choose the correct heading for paragraphs
A-G
from the list below.
Write the correct number,
i-ix
, in boxes
1-5
on your answer sheet.
List of Headings
i
Western countries provide essential assistance
ii
Unbalanced development for an essential space technology
iii
Innovative application compelled by competition
iv
An ancient invention which is related to the future
v
Military purpose of the satellite
vi
Rockets for application in ancient China
vii
Space development in Asia in the past
viii
Non-technology factors counts
ix
competitive edge gained by more economically feasible satellite
1
Paragraph
A
2
Paragraph
B
3
Paragraph
C
Paragraph D
Example: Current space technology development in Asia
4
Paragraph
E
5
Paragraph
F

5 ____ Paragraph F$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9953c41f-45ab-53da-879e-372135f78b2a', 'd6cd221c-176e-5081-abd3-939c511af585', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e4d8ec0a-739a-508b-884e-32515dd90f72', 'd6cd221c-176e-5081-abd3-939c511af585', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ea26e0b5-1a1f-59da-a841-cf5e932847dd', 'd6cd221c-176e-5081-abd3-939c511af585', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fbc147c6-1e5a-5e20-b4a3-328ec6a1ba77', 'd6cd221c-176e-5081-abd3-939c511af585', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0c59db4a-6c42-58a6-af3c-2687b5b1c733', 'd6cd221c-176e-5081-abd3-939c511af585', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('36b861c4-6856-5d1c-9b79-d5f988efa360', 'd6cd221c-176e-5081-abd3-939c511af585', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2cef3177-8b42-5e45-80e9-e4109d343706', 'd6cd221c-176e-5081-abd3-939c511af585', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('57f7623a-6bbb-5e74-ab00-47a41b0771df', 'd6cd221c-176e-5081-abd3-939c511af585', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('00b4451d-9d8c-5c4d-b39f-a81364053c4d', 'd6cd221c-176e-5081-abd3-939c511af585', 9, $md$ix$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('78ce325e-189a-539d-81d1-3f9bd9c6cd2b', '73c0ffc5-ae5f-5291-bcc1-a7856cfca0f8', 6, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 6

Questions 6-9
Questions 6-9
Match the following reasons for each question according to the information given in the passage
Write the correct letter
A-F
, in boxes 6-9 on your answer sheet.
A
Because it helps administrate the crops.
B
Because there are some unapproachable areas.
C
Because the economic level in that area is low.
D
Because there are influences from some other social factors.
E
Because it can be used in non-peaceful purpose.
F
Because disasters such as bush fire happened in Southeast Asia.
6
Why
remote-photographic technology
is used to resolve environmental problems?
7
Why satellites technology is used in the medicine area?
8
Why Asian countries satellite technology is limited for development?
9
Why satellites technology is deployed in an agricultural area?

6 ____ Why remote-photographic technology is used to resolve environmental problems?$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('65f9f69d-01b8-5c38-b55d-a8824b9eb673', '78ce325e-189a-539d-81d1-3f9bd9c6cd2b', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e4f4daca-4020-583e-8d66-b1cc1c6c84e1', '78ce325e-189a-539d-81d1-3f9bd9c6cd2b', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('dedfff49-e5fd-5255-9d7b-6c3530e0c714', '78ce325e-189a-539d-81d1-3f9bd9c6cd2b', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f67fe877-2dd7-52df-b748-969dcbcc17f6', '78ce325e-189a-539d-81d1-3f9bd9c6cd2b', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bfabceb6-01a7-52b5-ace5-c5e534a3a600', '78ce325e-189a-539d-81d1-3f9bd9c6cd2b', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('64755942-140a-567c-ae99-6db9afa6ae3a', '78ce325e-189a-539d-81d1-3f9bd9c6cd2b', 6, $md$F$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('1dfcc202-9cfe-5642-bac3-1646937e6719', '73c0ffc5-ae5f-5291-bcc1-a7856cfca0f8', 7, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 7

Questions 6-9
Questions 6-9
Match the following reasons for each question according to the information given in the passage
Write the correct letter
A-F
, in boxes 6-9 on your answer sheet.
A
Because it helps administrate the crops.
B
Because there are some unapproachable areas.
C
Because the economic level in that area is low.
D
Because there are influences from some other social factors.
E
Because it can be used in non-peaceful purpose.
F
Because disasters such as bush fire happened in Southeast Asia.
6
Why
remote-photographic technology
is used to resolve environmental problems?
7
Why satellites technology is used in the medicine area?
8
Why Asian countries satellite technology is limited for development?
9
Why satellites technology is deployed in an agricultural area?

7 ____ Why satellites technology is used in the medicine area?$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e5664683-9075-5bd5-84a2-47bdb3d4479c', '1dfcc202-9cfe-5642-bac3-1646937e6719', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('805972b4-c82b-571c-9527-8c079fe25518', '1dfcc202-9cfe-5642-bac3-1646937e6719', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('56eccbaa-05b7-5e54-9c22-d5b25c8c998b', '1dfcc202-9cfe-5642-bac3-1646937e6719', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fc8938ec-b48c-5967-ab49-dedbd304f49c', '1dfcc202-9cfe-5642-bac3-1646937e6719', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('38b56af1-9f4e-505a-a7ce-062739a41315', '1dfcc202-9cfe-5642-bac3-1646937e6719', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2295cb5e-347f-5cfe-a1fa-2837580b2fb7', '1dfcc202-9cfe-5642-bac3-1646937e6719', 6, $md$F$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('ab3a635d-84ef-5c4b-913d-1ee1616a4939', '73c0ffc5-ae5f-5291-bcc1-a7856cfca0f8', 8, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 8

Questions 6-9
Questions 6-9
Match the following reasons for each question according to the information given in the passage
Write the correct letter
A-F
, in boxes 6-9 on your answer sheet.
A
Because it helps administrate the crops.
B
Because there are some unapproachable areas.
C
Because the economic level in that area is low.
D
Because there are influences from some other social factors.
E
Because it can be used in non-peaceful purpose.
F
Because disasters such as bush fire happened in Southeast Asia.
6
Why
remote-photographic technology
is used to resolve environmental problems?
7
Why satellites technology is used in the medicine area?
8
Why Asian countries satellite technology is limited for development?
9
Why satellites technology is deployed in an agricultural area?

8 ____ Why Asian countries satellite technology is limited for development?$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('86d75f4a-5af9-5255-834b-3e95d53f841e', 'ab3a635d-84ef-5c4b-913d-1ee1616a4939', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e604c591-8966-5643-84f8-f5ab00e5d341', 'ab3a635d-84ef-5c4b-913d-1ee1616a4939', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0c0f2f3a-635c-5cbd-840e-356d73a25153', 'ab3a635d-84ef-5c4b-913d-1ee1616a4939', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('39ac7094-8098-5c73-9609-b93d72eae498', 'ab3a635d-84ef-5c4b-913d-1ee1616a4939', 4, $md$D$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d035a801-bb4a-5452-8e08-0001f72f5583', 'ab3a635d-84ef-5c4b-913d-1ee1616a4939', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f79a8f7a-6d1f-5f03-8d51-03e7bbca7bb6', 'ab3a635d-84ef-5c4b-913d-1ee1616a4939', 6, $md$F$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('22f27a1e-1bec-5578-bf28-5c21a4e8e17a', '73c0ffc5-ae5f-5291-bcc1-a7856cfca0f8', 9, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 9

Questions 6-9
Questions 6-9
Match the following reasons for each question according to the information given in the passage
Write the correct letter
A-F
, in boxes 6-9 on your answer sheet.
A
Because it helps administrate the crops.
B
Because there are some unapproachable areas.
C
Because the economic level in that area is low.
D
Because there are influences from some other social factors.
E
Because it can be used in non-peaceful purpose.
F
Because disasters such as bush fire happened in Southeast Asia.
6
Why
remote-photographic technology
is used to resolve environmental problems?
7
Why satellites technology is used in the medicine area?
8
Why Asian countries satellite technology is limited for development?
9
Why satellites technology is deployed in an agricultural area?

9 ____ Why satellites technology is deployed in an agricultural area?$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('942e3c79-a0ca-5e6f-9e1f-0f6a79b46f59', '22f27a1e-1bec-5578-bf28-5c21a4e8e17a', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4b20cbc5-5610-5e0f-8e97-2b48f84eb8e3', '22f27a1e-1bec-5578-bf28-5c21a4e8e17a', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7e67c929-a233-5e10-8251-c94363e23444', '22f27a1e-1bec-5578-bf28-5c21a4e8e17a', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('069e2f3e-a0b6-5737-a840-2827776184b7', '22f27a1e-1bec-5578-bf28-5c21a4e8e17a', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f7eacd67-fdd9-54bc-8d87-8cffc4375db9', '22f27a1e-1bec-5578-bf28-5c21a4e8e17a', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b0f7a08d-f701-50ee-b141-56e3d6b6cbdb', '22f27a1e-1bec-5578-bf28-5c21a4e8e17a', 6, $md$F$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('77db8435-4dc1-5dc6-a801-6ec2979023d6', '73c0ffc5-ae5f-5291-bcc1-a7856cfca0f8', 10, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 10

Questions 10-13
Questions 10-13
Do the following statements agree with the information given in Reading Passage?
In boxes
10-13
on your answer sheet, write
TRUE
if the statement is true
FALSE
if the statement is false
NOT GIVEN
if the information is not given in the passage
10
Ancient China had already deployed rockets as a military purpose as early as 500 years ago.
11
Space technology has enhanced the literacy of Asia.
12
photos taken by satellites with certain technology help predict some natural catastrophes prevention and surveillance.
13
commercial competition constitutes a boosting factor to Asian technology development.

10 ____ Ancient China had already deployed rockets as a military purpose as early as 500 years ago.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d3c8da20-8b2c-5229-8c4c-b3327e1c1404', '77db8435-4dc1-5dc6-a801-6ec2979023d6', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d6ad58ed-ebae-5074-84eb-74cfe7c5a099', '77db8435-4dc1-5dc6-a801-6ec2979023d6', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4323a15d-f12b-5b8b-b4b8-651b7976168c', '77db8435-4dc1-5dc6-a801-6ec2979023d6', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('011a1326-6949-5fbc-b5ba-7207f8ec3491', '73c0ffc5-ae5f-5291-bcc1-a7856cfca0f8', 11, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 11

Questions 10-13
Questions 10-13
Do the following statements agree with the information given in Reading Passage?
In boxes
10-13
on your answer sheet, write
TRUE
if the statement is true
FALSE
if the statement is false
NOT GIVEN
if the information is not given in the passage
10
Ancient China had already deployed rockets as a military purpose as early as 500 years ago.
11
Space technology has enhanced the literacy of Asia.
12
photos taken by satellites with certain technology help predict some natural catastrophes prevention and surveillance.
13
commercial competition constitutes a boosting factor to Asian technology development.

11 ____ Space technology has enhanced the literacy of Asia.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('245a4232-5e84-5674-8d7f-7537f918931f', '011a1326-6949-5fbc-b5ba-7207f8ec3491', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1976e946-f4fb-549f-aa48-b4507f8ef972', '011a1326-6949-5fbc-b5ba-7207f8ec3491', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('45652061-87ec-51c9-8334-620efab9e650', '011a1326-6949-5fbc-b5ba-7207f8ec3491', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('f50888ef-aac6-5213-a32f-5f7773bf3474', '73c0ffc5-ae5f-5291-bcc1-a7856cfca0f8', 12, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 12

Questions 10-13
Questions 10-13
Do the following statements agree with the information given in Reading Passage?
In boxes
10-13
on your answer sheet, write
TRUE
if the statement is true
FALSE
if the statement is false
NOT GIVEN
if the information is not given in the passage
10
Ancient China had already deployed rockets as a military purpose as early as 500 years ago.
11
Space technology has enhanced the literacy of Asia.
12
photos taken by satellites with certain technology help predict some natural catastrophes prevention and surveillance.
13
commercial competition constitutes a boosting factor to Asian technology development.

12 ____ photos taken by satellites with certain technology help predict some natural catastrophes prevention and surveillance.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('950455e3-0e10-5289-852e-c64c69261ae5', 'f50888ef-aac6-5213-a32f-5f7773bf3474', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('37f20d81-7461-53b5-9682-4bced96ff99f', 'f50888ef-aac6-5213-a32f-5f7773bf3474', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e0559111-a0b8-5790-9d38-abef7ec239ea', 'f50888ef-aac6-5213-a32f-5f7773bf3474', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('8e776f47-7329-5021-89f5-8c398b56031c', '73c0ffc5-ae5f-5291-bcc1-a7856cfca0f8', 13, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 13

Questions 10-13
Questions 10-13
Do the following statements agree with the information given in Reading Passage?
In boxes
10-13
on your answer sheet, write
TRUE
if the statement is true
FALSE
if the statement is false
NOT GIVEN
if the information is not given in the passage
10
Ancient China had already deployed rockets as a military purpose as early as 500 years ago.
11
Space technology has enhanced the literacy of Asia.
12
photos taken by satellites with certain technology help predict some natural catastrophes prevention and surveillance.
13
commercial competition constitutes a boosting factor to Asian technology development.

13 ____ commercial competition constitutes a boosting factor to Asian technology development.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4dd60b3e-8575-5751-bd07-7d3b1d8d0a80', '8e776f47-7329-5021-89f5-8c398b56031c', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('02acbb27-e97c-5055-a6e3-7dde587cbd4d', '8e776f47-7329-5021-89f5-8c398b56031c', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('78d62c41-51d8-5c0e-bc76-0a890f634683', '8e776f47-7329-5021-89f5-8c398b56031c', 3, $md$NOT GIVEN$md$, false);

COMMIT;
