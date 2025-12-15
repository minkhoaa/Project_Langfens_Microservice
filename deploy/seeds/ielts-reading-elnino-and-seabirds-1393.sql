BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-elnino-and-seabirds-1393'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-elnino-and-seabirds-1393';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-elnino-and-seabirds-1393';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-elnino-and-seabirds-1393';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('4e90bd73-1e49-5bf0-bb50-364da60e632e', 'ielts-reading-elnino-and-seabirds-1393', $t$Elnino and Seabirds$t$, $md$## Elnino and Seabirds

Nguồn:
- Test: https://mini-ielts.com/1393/reading/elnino-and-seabirds
- Solution: https://mini-ielts.com/1393/view-solution/reading/elnino-and-seabirds$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('e91e4054-2f31-56b4-8a2b-c2ef2c646e12', '4e90bd73-1e49-5bf0-bb50-364da60e632e', 1, $t$Reading — Elnino and Seabirds$t$, $md$Read the passage and answer questions **1–13**.

### Passage: Elnino and Seabirds

A Rhythm of the seasons cannot always be relied upon. At times the tropical Pacific Ocean and large expanses of the global atmosphere seem to be marching to the beat of a different drummer, disrupting the normal patterns of countless species of plants and animals along with hundreds of millions of human beings. So they want anticipate these occasional lapses in the march of the seasons and help societies plan accordingly, scientists are seeking to understand these competing rhythms: the strongest of which is the alternation between the “normal climate” and a different but still recurrent set of climatic conditions in the Pacific region called El Nino.

B Seabirds are prominent and highly visible components of marine ecosystems that will be affected by global climate change. The Bering Sea region is particularly important to seabirds; populations there are larger and more diverse than in any similar region in North America—over 90% of seabirds breeding in the continental United States are found in this region. Seabirds, so named because they spend at least 80% of their lives at sea, are dependent upon marine resources for food. As prey availability changes in response to climatically driven factors such as surface sea temperature and extent of sea ice, so will populations of seabirds be affected.

C Seabirds are valued as indicators of healthy marine ecosystems and provide a “vicarious use value” or existence value—people appreciate and value seabirds simply because they are there and enjoy them through venues such as pictures, nature programs, and written accounts without ever directly observing seabirds in their native environment. A direct measure of this value is demonstrated by Federal legislation that established specific national wildlife refuges to protect seabirds and international treaty obligations that provide additional protection for seabirds. Seabirds are also an important subsistence resource for many who live within the Bering Sea Region. Furthermore, the rich knowledge base about seabirds makes them a valuable resource as indicator species for measurement of change in the marine environment.

D The most abundant breeding species in Alaska are northern fulmars, storm-petrels, kittiwakes, murres, auklets and puffins. These species also form the largest colonies. Fulmars, storm-petrels and kittiwakes are surface feeders, picking their prey from the surface or just below the surface; murres, auklets, and puffins dive for their food. Fulmars nest primarily on island groups in and around the Bering Sea. They take a wide variety of prey (e.g., fish, squid, zooplankton, jellyfish) from the surface or just below the surface. Storm-petrels are strictly nocturnal and nest below ground in either burrows or crevices between rocks. They forage on zooplankton and squid; in some areas they are dependent upon small fish such as capelin and sand lance caught at the surface. Black-legged kittiwakes are widespread throughout Alaska, Canada and Eurasia while red-legged kittiwakes are found only in the Bering Sea region. Both are surface feeders although black-legged kittiwakes feed primarily on small fish and forage over the continental shelf and shelf break; red-legged kittiwakes feed primarily on myctophids and will forage beyond the shelf break.

E Marine mammals have exhibited similar signs of food stress in recent years. Harbor seals at Tugidak Island in the Gulf of Alaska declined by about 85% between 1976 and 1988 . Steller sea lion populations declined by 36% in the Gulf of Alaska between 1977 and 1985 , and by another 59% between 1985 and . Northern fur seals declined about 35% by 1986 from their average numbers in the 1970s, although numbers had rebounded somewhat (20%) by 1990 . Associated with the declines in Steller sea lions are declines in birth rate, fewer breeding females, fewer pups, decreased adult body condition, decreased juvenile survival, and a change in population age structure.

F Walker noticed that monsoon seasons with low-index conditions are often marked by drought in Australia, Indonesia, India, and parts of Africa. He also claimed that low-index winters tend to be unusually mild in western Canada. One of his British colleagues chided him in print for suggesting that climatic conditions over such widely separated regions of the globe could be linked. In his reply Walker predicted, correctly, that an explanation would be forthcoming, but that it would require a knowledge of wind patterns above ground level, which were not routinely being observed at that time.

G The need for long-term time series It seems obvious that without good baseline data ornithologists are doomed to be surprised by the arrival of El Nino every few years. Even when ornithologists and ecologists are at hand to take advantage of an incoming El Nino, lack of preexisting data, and of monitoring afterwards, makes it difficult 134 F.M. Jaksic & J.M. Farina to understand responses of birds to the successive El Nino, La Nina, and “normal” years. Indeed, according to Jaksic, during the last century there were 12 El Nino years and 12 La Nina years, thus leaving about 76 ‘normal’ years in between. Thus, by heavily concentrating attention on only 12% of the time span El Nino, and of neglecting possibly another 12% , ornithologists are essentially ignoring what happens during 76% of the time. This situation may be remedied only as long as data are logged on a regular or continuous basis, that is, as long-term time series. The recipe prescribed by Schreiber & Schreiber to understand El Nino, effects on birds still stands: ‘…carry out long-term studies that will shed further light on the interactions between global atmospheric cycles, oceanographic phenomena, and avian populations.’

H Populations of seabirds in Alaska are larger and more diverse than any similar region in the Northern Hemisphere. The extensive coastal estuaries and offshore waters of Alaska provide breeding, feeding and migrating habitats for 66 species of seabirds. At least 38 species of seabirds, over 50 million individuals, breed in Alaska. Eight Alaskan species breed only here and in adjacent Siberia. Five additional species range through the North Pacific, but their populations are concentrated in Alaska. In addition to breeding grounds, Alaskan waters also provide important wintering habitat for birds that breed in Canada and Eurasia. Shearwaters, which breed in the southern hemisphere, are the most numerous species in Alaskan waters during the summer.

I As another indication that food has been limiting in recent years, several largescale die-offs of seabirds, mostly surface-feeding species, have been observed in the Gulf of Alaska during the last decade, most notably in 1983, 1989，and 1993 . But Hatch thinks that it is too early to decide the these die-offs reports are somehow connected with effect of El nino. Byrd and Tobish believe that high rainfall can affect survival of chicks in earthen burrows, and incidence of big storms with high winds during the chick-rearing period can cause mortality for chicks of species nesting on cliff-ledges, but this view has not been considered as convincing evidence.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('2d68013c-f116-51b5-b6c3-5ba0a55f8033', 'e91e4054-2f31-56b4-8a2b-c2ef2c646e12', 1, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 1

Questions 1-4
Questions 1-4
Choose the correct letter, A, B, C or D. Write your answers in boxes
1-4
on your answer sheet.
1. Why do scientists want to investigate El Nino phenomenon at beginning of the paragraph ?
A
To learn patterns of creatures that live in marine environment.
B
Assist us to map out because it disturbs normal cycle of for wildlife and human.
C
It has profound theory for both the academic side and practical side.
D
Tropical Pacific Ocean is where El Nino affects most.
2. Why do scientists use seabirds as important subjects when observe climate change World-widely?
A
Seabirds affected by prey changes according to the temperature and ice.
B
Its size is large enough to be observed.
C
El Nino affects seabirds more than other sea creatures.
D
North America is situated in the area where El Nino affects most.
3. What happened for Marine mammals that live in Tugidak Island in Gulf of Alaska?
A
Number of seals declined about 85% from the mid of 20th century.
B
Number of Steller sea lion declined while Number seals grew.
C
Birth rate and breeding females declined on the Tugidak Island.
D
The situation of mammals on the island is not that worse than we expected.
4. According to J. Walker, what happens in the monsoon seasons notably?
A
Flood and drought seriously damage almost everywhere of the planet.
B
Walker’s prediction would soon come true.
C
Drought only affects some parts of Africa.
D
Drought will affect somewhere of the earth such as Australia and Indonesia.

Choose the correct letter, A, B, C or D. Write your answers in boxes 1-4 on your answer sheet.$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('bcc3a9fe-47ce-561f-b155-e0151b68a640', 'e91e4054-2f31-56b4-8a2b-c2ef2c646e12', 2, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 2

Questions 1-4
Questions 1-4
Choose the correct letter, A, B, C or D. Write your answers in boxes
1-4
on your answer sheet.
1. Why do scientists want to investigate El Nino phenomenon at beginning of the paragraph ?
A
To learn patterns of creatures that live in marine environment.
B
Assist us to map out because it disturbs normal cycle of for wildlife and human.
C
It has profound theory for both the academic side and practical side.
D
Tropical Pacific Ocean is where El Nino affects most.
2. Why do scientists use seabirds as important subjects when observe climate change World-widely?
A
Seabirds affected by prey changes according to the temperature and ice.
B
Its size is large enough to be observed.
C
El Nino affects seabirds more than other sea creatures.
D
North America is situated in the area where El Nino affects most.
3. What happened for Marine mammals that live in Tugidak Island in Gulf of Alaska?
A
Number of seals declined about 85% from the mid of 20th century.
B
Number of Steller sea lion declined while Number seals grew.
C
Birth rate and breeding females declined on the Tugidak Island.
D
The situation of mammals on the island is not that worse than we expected.
4. According to J. Walker, what happens in the monsoon seasons notably?
A
Flood and drought seriously damage almost everywhere of the planet.
B
Walker’s prediction would soon come true.
C
Drought only affects some parts of Africa.
D
Drought will affect somewhere of the earth such as Australia and Indonesia.

Choose the correct letter, A, B, C or D. Write your answers in boxes 1-4 on your answer sheet.$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('3384d676-c32f-59d4-932b-d0e37688d569', 'e91e4054-2f31-56b4-8a2b-c2ef2c646e12', 3, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 3

Questions 1-4
Questions 1-4
Choose the correct letter, A, B, C or D. Write your answers in boxes
1-4
on your answer sheet.
1. Why do scientists want to investigate El Nino phenomenon at beginning of the paragraph ?
A
To learn patterns of creatures that live in marine environment.
B
Assist us to map out because it disturbs normal cycle of for wildlife and human.
C
It has profound theory for both the academic side and practical side.
D
Tropical Pacific Ocean is where El Nino affects most.
2. Why do scientists use seabirds as important subjects when observe climate change World-widely?
A
Seabirds affected by prey changes according to the temperature and ice.
B
Its size is large enough to be observed.
C
El Nino affects seabirds more than other sea creatures.
D
North America is situated in the area where El Nino affects most.
3. What happened for Marine mammals that live in Tugidak Island in Gulf of Alaska?
A
Number of seals declined about 85% from the mid of 20th century.
B
Number of Steller sea lion declined while Number seals grew.
C
Birth rate and breeding females declined on the Tugidak Island.
D
The situation of mammals on the island is not that worse than we expected.
4. According to J. Walker, what happens in the monsoon seasons notably?
A
Flood and drought seriously damage almost everywhere of the planet.
B
Walker’s prediction would soon come true.
C
Drought only affects some parts of Africa.
D
Drought will affect somewhere of the earth such as Australia and Indonesia.

Choose the correct letter, A, B, C or D. Write your answers in boxes 1-4 on your answer sheet.$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('13410472-9e24-539b-9c87-726f3b145c9c', 'e91e4054-2f31-56b4-8a2b-c2ef2c646e12', 4, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 4

Questions 1-4
Questions 1-4
Choose the correct letter, A, B, C or D. Write your answers in boxes
1-4
on your answer sheet.
1. Why do scientists want to investigate El Nino phenomenon at beginning of the paragraph ?
A
To learn patterns of creatures that live in marine environment.
B
Assist us to map out because it disturbs normal cycle of for wildlife and human.
C
It has profound theory for both the academic side and practical side.
D
Tropical Pacific Ocean is where El Nino affects most.
2. Why do scientists use seabirds as important subjects when observe climate change World-widely?
A
Seabirds affected by prey changes according to the temperature and ice.
B
Its size is large enough to be observed.
C
El Nino affects seabirds more than other sea creatures.
D
North America is situated in the area where El Nino affects most.
3. What happened for Marine mammals that live in Tugidak Island in Gulf of Alaska?
A
Number of seals declined about 85% from the mid of 20th century.
B
Number of Steller sea lion declined while Number seals grew.
C
Birth rate and breeding females declined on the Tugidak Island.
D
The situation of mammals on the island is not that worse than we expected.
4. According to J. Walker, what happens in the monsoon seasons notably?
A
Flood and drought seriously damage almost everywhere of the planet.
B
Walker’s prediction would soon come true.
C
Drought only affects some parts of Africa.
D
Drought will affect somewhere of the earth such as Australia and Indonesia.

Choose the correct letter, A, B, C or D. Write your answers in boxes 1-4 on your answer sheet.$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('914f66e1-8815-51ad-94c5-c8be1b752ab0', 'e91e4054-2f31-56b4-8a2b-c2ef2c646e12', 5, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 5

Questions 5-13
Questions 5-13
Do the following statements agree with the information given in Reading Passage?
In boxes 5-13
on your answer sheet, write
TRUE
if the sataement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
5
Seabirds are regarded as precious indicators of changes in oceanic environment.
6
Seabirds such as Fulmars and Murres feed by the characteristic of prey in different ways.
7
Steller sea lions only decline in birth rate and fewer pups, but the whole population wouldn’t be affected by the changes.
8
With reply of Walker’s colleague, knowledge of wind patterns will be very helpful.
9
It is difficult to investigate El Nino for ornithologists and ecologist because lack of available statistics and inspections.
10
Habit of seabirds in Alaska is similar to those in the Northern Hemisphere.
11
Number of Shearwaters in the southern hemisphere feed most during the summer.
12
Hatch thinks that it is too early to determine all the problems that are caused by El Nino.
13
Byrd and Tobish think that heavy rainfall and storms cause mortality for chicks, which has already been a convincing proof.

5 ____ Seabirds are regarded as precious indicators of changes in oceanic environment.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2e57a101-eb23-5cf5-9803-1fbf37a555e7', '914f66e1-8815-51ad-94c5-c8be1b752ab0', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8055f408-88d3-5a43-a0df-fc27861e1ae4', '914f66e1-8815-51ad-94c5-c8be1b752ab0', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6f823911-d363-543f-a84d-beacba4ed369', '914f66e1-8815-51ad-94c5-c8be1b752ab0', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('04d7c940-00cf-5ca4-9e45-09e25264c367', 'e91e4054-2f31-56b4-8a2b-c2ef2c646e12', 6, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 6

Questions 5-13
Questions 5-13
Do the following statements agree with the information given in Reading Passage?
In boxes 5-13
on your answer sheet, write
TRUE
if the sataement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
5
Seabirds are regarded as precious indicators of changes in oceanic environment.
6
Seabirds such as Fulmars and Murres feed by the characteristic of prey in different ways.
7
Steller sea lions only decline in birth rate and fewer pups, but the whole population wouldn’t be affected by the changes.
8
With reply of Walker’s colleague, knowledge of wind patterns will be very helpful.
9
It is difficult to investigate El Nino for ornithologists and ecologist because lack of available statistics and inspections.
10
Habit of seabirds in Alaska is similar to those in the Northern Hemisphere.
11
Number of Shearwaters in the southern hemisphere feed most during the summer.
12
Hatch thinks that it is too early to determine all the problems that are caused by El Nino.
13
Byrd and Tobish think that heavy rainfall and storms cause mortality for chicks, which has already been a convincing proof.

6 ____ Seabirds such as Fulmars and Murres feed by the characteristic of prey in different ways.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a737e967-5cde-5a5b-b22d-7237b222a3a8', '04d7c940-00cf-5ca4-9e45-09e25264c367', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b76ac6be-0458-59ac-9bfb-55f06cfd8012', '04d7c940-00cf-5ca4-9e45-09e25264c367', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('16ff24a5-4d11-5ec8-bd5d-facf3b5c8520', '04d7c940-00cf-5ca4-9e45-09e25264c367', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('37405dd8-3fc9-5e72-90ba-dbd049a57f43', 'e91e4054-2f31-56b4-8a2b-c2ef2c646e12', 7, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 7

Questions 5-13
Questions 5-13
Do the following statements agree with the information given in Reading Passage?
In boxes 5-13
on your answer sheet, write
TRUE
if the sataement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
5
Seabirds are regarded as precious indicators of changes in oceanic environment.
6
Seabirds such as Fulmars and Murres feed by the characteristic of prey in different ways.
7
Steller sea lions only decline in birth rate and fewer pups, but the whole population wouldn’t be affected by the changes.
8
With reply of Walker’s colleague, knowledge of wind patterns will be very helpful.
9
It is difficult to investigate El Nino for ornithologists and ecologist because lack of available statistics and inspections.
10
Habit of seabirds in Alaska is similar to those in the Northern Hemisphere.
11
Number of Shearwaters in the southern hemisphere feed most during the summer.
12
Hatch thinks that it is too early to determine all the problems that are caused by El Nino.
13
Byrd and Tobish think that heavy rainfall and storms cause mortality for chicks, which has already been a convincing proof.

7 ____ Steller sea lions only decline in birth rate and fewer pups, but the whole population wouldn’t be affected by the changes.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ea557882-b4c4-5bf3-a261-50cd43413385', '37405dd8-3fc9-5e72-90ba-dbd049a57f43', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b78e506d-7c27-59af-b396-0ed6e1489f43', '37405dd8-3fc9-5e72-90ba-dbd049a57f43', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0c3ff27a-cf08-5bdc-96e1-73c81e4936df', '37405dd8-3fc9-5e72-90ba-dbd049a57f43', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('5e645f7b-7737-5359-a51a-94c3875fc7f5', 'e91e4054-2f31-56b4-8a2b-c2ef2c646e12', 8, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 8

Questions 5-13
Questions 5-13
Do the following statements agree with the information given in Reading Passage?
In boxes 5-13
on your answer sheet, write
TRUE
if the sataement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
5
Seabirds are regarded as precious indicators of changes in oceanic environment.
6
Seabirds such as Fulmars and Murres feed by the characteristic of prey in different ways.
7
Steller sea lions only decline in birth rate and fewer pups, but the whole population wouldn’t be affected by the changes.
8
With reply of Walker’s colleague, knowledge of wind patterns will be very helpful.
9
It is difficult to investigate El Nino for ornithologists and ecologist because lack of available statistics and inspections.
10
Habit of seabirds in Alaska is similar to those in the Northern Hemisphere.
11
Number of Shearwaters in the southern hemisphere feed most during the summer.
12
Hatch thinks that it is too early to determine all the problems that are caused by El Nino.
13
Byrd and Tobish think that heavy rainfall and storms cause mortality for chicks, which has already been a convincing proof.

8 ____ With reply of Walker’s colleague, knowledge of wind patterns will be very helpful.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5b2968ca-3736-5de6-93d2-430285f10e72', '5e645f7b-7737-5359-a51a-94c3875fc7f5', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('db7745fe-4e36-56cb-b2de-6375ffd19ffb', '5e645f7b-7737-5359-a51a-94c3875fc7f5', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('df57f4b6-7006-5469-8710-eb00eb25c842', '5e645f7b-7737-5359-a51a-94c3875fc7f5', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('ac188b29-609a-5835-9307-b9a2048ac4a4', 'e91e4054-2f31-56b4-8a2b-c2ef2c646e12', 9, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 9

Questions 5-13
Questions 5-13
Do the following statements agree with the information given in Reading Passage?
In boxes 5-13
on your answer sheet, write
TRUE
if the sataement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
5
Seabirds are regarded as precious indicators of changes in oceanic environment.
6
Seabirds such as Fulmars and Murres feed by the characteristic of prey in different ways.
7
Steller sea lions only decline in birth rate and fewer pups, but the whole population wouldn’t be affected by the changes.
8
With reply of Walker’s colleague, knowledge of wind patterns will be very helpful.
9
It is difficult to investigate El Nino for ornithologists and ecologist because lack of available statistics and inspections.
10
Habit of seabirds in Alaska is similar to those in the Northern Hemisphere.
11
Number of Shearwaters in the southern hemisphere feed most during the summer.
12
Hatch thinks that it is too early to determine all the problems that are caused by El Nino.
13
Byrd and Tobish think that heavy rainfall and storms cause mortality for chicks, which has already been a convincing proof.

9 ____ It is difficult to investigate El Nino for ornithologists and ecologist because lack of available statistics and inspections.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b91f95bf-fab9-5d2f-8624-609aa4f6ec01', 'ac188b29-609a-5835-9307-b9a2048ac4a4', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('952665af-3a79-57a0-9bdd-1f101023f057', 'ac188b29-609a-5835-9307-b9a2048ac4a4', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c8916fc5-7077-5a11-9aac-db7d21510b7b', 'ac188b29-609a-5835-9307-b9a2048ac4a4', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('5e85d61a-1d92-5b40-ae10-13373bfe9e65', 'e91e4054-2f31-56b4-8a2b-c2ef2c646e12', 10, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 10

Questions 5-13
Questions 5-13
Do the following statements agree with the information given in Reading Passage?
In boxes 5-13
on your answer sheet, write
TRUE
if the sataement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
5
Seabirds are regarded as precious indicators of changes in oceanic environment.
6
Seabirds such as Fulmars and Murres feed by the characteristic of prey in different ways.
7
Steller sea lions only decline in birth rate and fewer pups, but the whole population wouldn’t be affected by the changes.
8
With reply of Walker’s colleague, knowledge of wind patterns will be very helpful.
9
It is difficult to investigate El Nino for ornithologists and ecologist because lack of available statistics and inspections.
10
Habit of seabirds in Alaska is similar to those in the Northern Hemisphere.
11
Number of Shearwaters in the southern hemisphere feed most during the summer.
12
Hatch thinks that it is too early to determine all the problems that are caused by El Nino.
13
Byrd and Tobish think that heavy rainfall and storms cause mortality for chicks, which has already been a convincing proof.

10 ____ Habit of seabirds in Alaska is similar to those in the Northern Hemisphere.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('06f6e312-e918-5314-97ba-4bd4f4ddb079', '5e85d61a-1d92-5b40-ae10-13373bfe9e65', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ece301ba-ddfb-588c-b9b3-8a97801c4e3b', '5e85d61a-1d92-5b40-ae10-13373bfe9e65', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e7d6aac6-e5d4-58f8-aa4e-1ce34c496523', '5e85d61a-1d92-5b40-ae10-13373bfe9e65', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('276e3722-5abe-5fb5-947a-e6c0989f88c5', 'e91e4054-2f31-56b4-8a2b-c2ef2c646e12', 11, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 11

Questions 5-13
Questions 5-13
Do the following statements agree with the information given in Reading Passage?
In boxes 5-13
on your answer sheet, write
TRUE
if the sataement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
5
Seabirds are regarded as precious indicators of changes in oceanic environment.
6
Seabirds such as Fulmars and Murres feed by the characteristic of prey in different ways.
7
Steller sea lions only decline in birth rate and fewer pups, but the whole population wouldn’t be affected by the changes.
8
With reply of Walker’s colleague, knowledge of wind patterns will be very helpful.
9
It is difficult to investigate El Nino for ornithologists and ecologist because lack of available statistics and inspections.
10
Habit of seabirds in Alaska is similar to those in the Northern Hemisphere.
11
Number of Shearwaters in the southern hemisphere feed most during the summer.
12
Hatch thinks that it is too early to determine all the problems that are caused by El Nino.
13
Byrd and Tobish think that heavy rainfall and storms cause mortality for chicks, which has already been a convincing proof.

11 ____ Number of Shearwaters in the southern hemisphere feed most during the summer.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a95f9d54-7e7a-54fe-969e-b8b9cd49c5fb', '276e3722-5abe-5fb5-947a-e6c0989f88c5', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('94cab93c-09e7-56c7-858d-9b456b5b4f91', '276e3722-5abe-5fb5-947a-e6c0989f88c5', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f4497b6f-f9d9-5332-9671-939f1d8f913f', '276e3722-5abe-5fb5-947a-e6c0989f88c5', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('ad764068-e73c-511f-9dce-a88301b0d565', 'e91e4054-2f31-56b4-8a2b-c2ef2c646e12', 12, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 12

Questions 5-13
Questions 5-13
Do the following statements agree with the information given in Reading Passage?
In boxes 5-13
on your answer sheet, write
TRUE
if the sataement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
5
Seabirds are regarded as precious indicators of changes in oceanic environment.
6
Seabirds such as Fulmars and Murres feed by the characteristic of prey in different ways.
7
Steller sea lions only decline in birth rate and fewer pups, but the whole population wouldn’t be affected by the changes.
8
With reply of Walker’s colleague, knowledge of wind patterns will be very helpful.
9
It is difficult to investigate El Nino for ornithologists and ecologist because lack of available statistics and inspections.
10
Habit of seabirds in Alaska is similar to those in the Northern Hemisphere.
11
Number of Shearwaters in the southern hemisphere feed most during the summer.
12
Hatch thinks that it is too early to determine all the problems that are caused by El Nino.
13
Byrd and Tobish think that heavy rainfall and storms cause mortality for chicks, which has already been a convincing proof.

12 ____ Hatch thinks that it is too early to determine all the problems that are caused by El Nino.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9f49a641-d20e-5bc2-b03b-eeb43fae74cd', 'ad764068-e73c-511f-9dce-a88301b0d565', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1df016d8-052d-512f-9bde-d59f76bb4125', 'ad764068-e73c-511f-9dce-a88301b0d565', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7f17353f-527e-51a2-a363-ba115843379c', 'ad764068-e73c-511f-9dce-a88301b0d565', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('4916d7e7-8de1-57ad-83e2-3de4d971a492', 'e91e4054-2f31-56b4-8a2b-c2ef2c646e12', 13, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 13

Questions 5-13
Questions 5-13
Do the following statements agree with the information given in Reading Passage?
In boxes 5-13
on your answer sheet, write
TRUE
if the sataement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
5
Seabirds are regarded as precious indicators of changes in oceanic environment.
6
Seabirds such as Fulmars and Murres feed by the characteristic of prey in different ways.
7
Steller sea lions only decline in birth rate and fewer pups, but the whole population wouldn’t be affected by the changes.
8
With reply of Walker’s colleague, knowledge of wind patterns will be very helpful.
9
It is difficult to investigate El Nino for ornithologists and ecologist because lack of available statistics and inspections.
10
Habit of seabirds in Alaska is similar to those in the Northern Hemisphere.
11
Number of Shearwaters in the southern hemisphere feed most during the summer.
12
Hatch thinks that it is too early to determine all the problems that are caused by El Nino.
13
Byrd and Tobish think that heavy rainfall and storms cause mortality for chicks, which has already been a convincing proof.

13 ____ Byrd and Tobish think that heavy rainfall and storms cause mortality for chicks, which has already been a convincing proof.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ef4e6112-abc2-5968-8686-12ae4ff15d99', '4916d7e7-8de1-57ad-83e2-3de4d971a492', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0287ab63-836d-5a8e-8ef8-6eca38baed3a', '4916d7e7-8de1-57ad-83e2-3de4d971a492', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('121839c4-206e-5e61-84cc-7da7a689bb90', '4916d7e7-8de1-57ad-83e2-3de4d971a492', 3, $md$NOT GIVEN$md$, false);

COMMIT;
