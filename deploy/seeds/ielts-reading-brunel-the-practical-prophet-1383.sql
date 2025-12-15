BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-brunel-the-practical-prophet-1383'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-brunel-the-practical-prophet-1383';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-brunel-the-practical-prophet-1383';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-brunel-the-practical-prophet-1383';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('120deb42-4bf2-5daf-ae09-7b2d34ca192d', 'ielts-reading-brunel-the-practical-prophet-1383', $t$Brunel: ‘The Practical Prophet’$t$, $md$## Brunel: ‘The Practical Prophet’

Nguồn:
- Test: https://mini-ielts.com/1383/reading/brunel-the-practical-prophet
- Solution: https://mini-ielts.com/1383/view-solution/reading/brunel-the-practical-prophet$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('1872740a-c437-51da-ae77-553148bf5750', '120deb42-4bf2-5daf-ae09-7b2d34ca192d', 1, $t$Reading — Brunel: ‘The Practical Prophet’$t$, $md$Read the passage and answer questions **1–13**.

### Passage: Brunel: ‘The Practical Prophet’

A

In the frontispiece of his book on Brunel, Peter Hay quotes from Nicholson’s British Encyclopaedia of 1909 as follows: ‘Engineers are extremely necessary for these purposes; wherefore it is requisite that, besides being ingenious, they should be brave in proportion.’ His father, Sir Marc Isambard Brunel (1769-1849), was himself a famous engineer, of French parents. He eventually settled in Britain and married the Sophia Kingdom, an English woman whom he had known in France in earlier days. Their only son Isambard was born on 9 April 1806. He was sent to France at the age of 14 to study mathematics and science and was 16 when he returned to England to work with his father. Sir Marc was then building his famous tunnel under the River Thames. Isambard was recuperating near Bristol from injuries received in a tunnel cave-in when he became involved with his own first major project.

–The Suspension Bridge ion the Avon Gorge

B

The span of Brunel’s bridge was over 700ft, longer than any existing when it was designed, and the height above water about 245ft. The technical challenges of this engineering project were immense, and Brunel dealt with them with his usual, thoroughness and ingenuity. Two design competitions were held, and the great bridge designer Thomas Telford was the committee’s expert. Brunel presented four designs. He went beyond technicalities to include arguments based on, among other things, the grace of his tower design. Unfortunately, he only got so far as to put up the end piers in his lifetime. The Clifton Suspension Bridge was completed in his honor by his engineering friends in1864 and is still in use.

The Great Western Railway

C

While Brunel was still in Bristol, and with the Avon Bridge project stopped or going slowly, he became aware that the civic authorities saw the need for a railway link to London. Railway location was controversial since private landowners and towns had to be dealt with. Mainly, the landed gentry did not want a messy, noisy railway anywhere near them. The Duke of Wellington (of Waterloo fame) was certainly against it. Again Brunel showed great skill in presenting his arguments to the various committees and individuals. BruneI built his railway with a broad gauge (7ft) instead of the standard 4ft 8½in, which had been used for lines already installed. There is no doubt that the broad gauge gave superior ride and stability, but it was fighting a standard.

Atmospheric railway:

D

Brunel’s ready acceptance of new ideas overpowered good engineering judgment (at least in hindsight) when he advocated the installation of an atmospheric railway in South Devon. It had the great attraction of doing away with the locomotive and potentially could deal with steeper gradients. Since this connecting arm had to run along the slit, it had to be opened through a flap as the train progressed, but closed airtight behind it. Materials were not up to it, and this arrangement was troublesome and expensive to keep in repair. After a year of frustration, the system was abandoned. Brunel admitted his failure and took responsibility. He also took no fee for his work, setting a good professional example.

Brunel’s ships:

E

The idea of using steam to power ships to cross the ocean appealed to Brunel. When his GWR company directors complained about the great length of their railway (it was only about 100 miles), Isambard jokingly suggested that they could even make it longer—why not go all the way to New York and call the link the Great Western. The “Great Western” was the first steamship to engage in transatlantic service. Brunel formed the Great Western Steamship Company and construction started on the ship in Bristol in 1836. Built of wood and 236ft long, the Great Western was launched in 1837 and powered by sail and paddlewheels. The first trip to New York took just 15 days, and 14 days to return. This was a great success, a one way trip under sail would take more than a month. The Great Western was the firsts steamship to engage in transatlantic service and made 74 crossings to New York.

F

Having done so well with the Great Western, Brunel immediately got to work on an even bigger ship. Great Britain was made of iron and also built-in Bristol, 322ft in length. The initial design was for the ship to be driven by paddle wheels, but Brunel had seen one of the first propeller-driven ships to arrive in Britain, and he abandoned his plans for paddlewheel propulsion. The ship was launched in 1843 and was the first screw-driven iron ship to cross the Atlantic. Great Britain ran aground early in its career but was repaired, sold, and sailed for years to Australia, and other parts of the world, setting the standard for ocean travel. In the early 1970s, the old ship was rescued from the Falklands and is now under restoration in Bristol.

G

Conventional wisdom in Brunel’s day was that steamships could not carry enough coal to make long ocean voyages. But he correctly figured out that this was a case where size mattered. He set out to design the biggest ship ever, five times larger than any ship built up to that time. Big enough to carry fuel to get to Australia without refueling, in addition, it would carry 4,000 passengers.

The Great Eastern was 692ft long, with a displacement of about 32,000 tons. Construction began in 1854 on the Thames at Millwall. Brunel had chosen John Scott Russell to build the ship. He was a well-established engineer and naval architect, but the contract did not go well. Among other things, Scott Russell was very low in his estimates and money was soon a problem. Construction came to a standstill in 1856 and Brunel himself had to take over the work. But Brunel was nothing if not determined and by September 1859, after a delayed and problem -ridden launch, the Great Eastern was ready for the maiden voyage, Brunei was too sick to go, but it was just as well because only a few hours out there was an explosion in the engine room which would have destroyed a lesser ship. Brunel died within a week or so of the accident. The great ship never carried 4,000 passengers (among other things, the Suez Canal came along) and although it made several transatlantic crossings, it was not a financial success. Shortly after the Great Eastern began working life, the American entrepreneur Cyrus Field and his backers were looking for a ship big enough to carry 5,000 tons of telegraphic cable, which was to be laid on the ocean floor from Ireland to Newfoundland. Although Brunel did not have it in mind, the Great Eastern was an excellent vessel for this work on July 27, 1866. It successfully completed the connection and a hundred years of transatlantic communication by cable began. The ship continued this career for several years, used for laying cables in many parts of the world.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('34fde5f2-ebc3-518d-bcaf-04917c5e7cf7', '1872740a-c437-51da-ae77-553148bf5750', 1, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 1

Questions 1-6
Questions 1-6
Use the information in the passage to match the project Brunel did (listed
A-G
) with opinions or deeds below.
Write the appropriate letters
A-G
, in boxes
1-6
on your answer sheet.
A
River Thames Tunnel
B
Clifton Suspension Bridge
C
Atmospheric Railway
D
Great Britain
E
The Great Western
F
Great Western Railway
G
The Great Eastern
1
The project of construction that I.K.Brunel was not responsible for.
2
The project had stopped due to inconvenience and high maintaining cost.
3
The project was honored to yet not completed by Brunel himself.
4
The project had a budget problem although built by a famous engineer.
5
Serious problem happened and delayed repeatedly.
6
The first one to cross the Atlantic Ocean in mankind history.

1 ____ The project of construction that I.K.Brunel was not responsible for.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3326308a-8046-5079-a0f4-079ac0345c3f', '34fde5f2-ebc3-518d-bcaf-04917c5e7cf7', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('debac5c7-9d5e-5dc6-988c-599238bcfebc', '34fde5f2-ebc3-518d-bcaf-04917c5e7cf7', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('889a834e-1234-5ae9-bf44-460bcb47f97f', '34fde5f2-ebc3-518d-bcaf-04917c5e7cf7', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c70b1104-b986-55fa-be32-b9e42f540f9d', '34fde5f2-ebc3-518d-bcaf-04917c5e7cf7', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bce595aa-7c43-5ee3-bc8b-859c922468b5', '34fde5f2-ebc3-518d-bcaf-04917c5e7cf7', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e4aa6283-17e3-54f9-b712-f5206039e653', '34fde5f2-ebc3-518d-bcaf-04917c5e7cf7', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('91702a7e-526c-5058-bb6d-b3c242da5670', '34fde5f2-ebc3-518d-bcaf-04917c5e7cf7', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('079ed731-cb85-51b5-b25f-87a47bf0ff12', '1872740a-c437-51da-ae77-553148bf5750', 2, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 2

Questions 1-6
Questions 1-6
Use the information in the passage to match the project Brunel did (listed
A-G
) with opinions or deeds below.
Write the appropriate letters
A-G
, in boxes
1-6
on your answer sheet.
A
River Thames Tunnel
B
Clifton Suspension Bridge
C
Atmospheric Railway
D
Great Britain
E
The Great Western
F
Great Western Railway
G
The Great Eastern
1
The project of construction that I.K.Brunel was not responsible for.
2
The project had stopped due to inconvenience and high maintaining cost.
3
The project was honored to yet not completed by Brunel himself.
4
The project had a budget problem although built by a famous engineer.
5
Serious problem happened and delayed repeatedly.
6
The first one to cross the Atlantic Ocean in mankind history.

2 ____ The project had stopped due to inconvenience and high maintaining cost.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4d9b9a71-2096-521d-bee8-1ea52424d908', '079ed731-cb85-51b5-b25f-87a47bf0ff12', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9010d8ef-3a25-5bb9-8810-d872a15e6c0f', '079ed731-cb85-51b5-b25f-87a47bf0ff12', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3d2f4340-9d6e-57c9-bbb4-f1b02087eb4d', '079ed731-cb85-51b5-b25f-87a47bf0ff12', 3, $md$C$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('306d1984-af0a-59cd-8522-90388381722b', '079ed731-cb85-51b5-b25f-87a47bf0ff12', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cfbf4dd7-c933-521a-8aa2-b152da556427', '079ed731-cb85-51b5-b25f-87a47bf0ff12', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('564e1300-18c7-5bef-bf53-424baa2a961d', '079ed731-cb85-51b5-b25f-87a47bf0ff12', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f39a7ddd-9c8a-5b72-809e-baafee7c4a65', '079ed731-cb85-51b5-b25f-87a47bf0ff12', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('6e251739-de2c-5195-a885-f22d576213d1', '1872740a-c437-51da-ae77-553148bf5750', 3, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 3

Questions 1-6
Questions 1-6
Use the information in the passage to match the project Brunel did (listed
A-G
) with opinions or deeds below.
Write the appropriate letters
A-G
, in boxes
1-6
on your answer sheet.
A
River Thames Tunnel
B
Clifton Suspension Bridge
C
Atmospheric Railway
D
Great Britain
E
The Great Western
F
Great Western Railway
G
The Great Eastern
1
The project of construction that I.K.Brunel was not responsible for.
2
The project had stopped due to inconvenience and high maintaining cost.
3
The project was honored to yet not completed by Brunel himself.
4
The project had a budget problem although built by a famous engineer.
5
Serious problem happened and delayed repeatedly.
6
The first one to cross the Atlantic Ocean in mankind history.

3 ____ The project was honored to yet not completed by Brunel himself.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3b964c94-a0b2-5b4e-af17-f29c3c418422', '6e251739-de2c-5195-a885-f22d576213d1', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('00213dd9-221a-565e-8031-08a7a3c495a2', '6e251739-de2c-5195-a885-f22d576213d1', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0164fef2-ed82-5bb3-8d14-754dab6fe87f', '6e251739-de2c-5195-a885-f22d576213d1', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('06848875-f79c-5057-b0a6-15757b8035b5', '6e251739-de2c-5195-a885-f22d576213d1', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bb09aa56-26d5-53a5-a64b-9d8c26a518a8', '6e251739-de2c-5195-a885-f22d576213d1', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('81a408de-e5c5-5008-ad21-db66bc56ae7b', '6e251739-de2c-5195-a885-f22d576213d1', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6f07c691-fa75-59fa-b692-2f9d37009c10', '6e251739-de2c-5195-a885-f22d576213d1', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('0b55f53d-4fc7-5823-ac8d-9fac00c68b68', '1872740a-c437-51da-ae77-553148bf5750', 4, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 4

Questions 1-6
Questions 1-6
Use the information in the passage to match the project Brunel did (listed
A-G
) with opinions or deeds below.
Write the appropriate letters
A-G
, in boxes
1-6
on your answer sheet.
A
River Thames Tunnel
B
Clifton Suspension Bridge
C
Atmospheric Railway
D
Great Britain
E
The Great Western
F
Great Western Railway
G
The Great Eastern
1
The project of construction that I.K.Brunel was not responsible for.
2
The project had stopped due to inconvenience and high maintaining cost.
3
The project was honored to yet not completed by Brunel himself.
4
The project had a budget problem although built by a famous engineer.
5
Serious problem happened and delayed repeatedly.
6
The first one to cross the Atlantic Ocean in mankind history.

4 ____ The project had a budget problem although built by a famous engineer.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('623c2e06-1582-5eff-9a13-f98758a77634', '0b55f53d-4fc7-5823-ac8d-9fac00c68b68', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('08240869-b1e4-5052-9946-a8b6a1314c5a', '0b55f53d-4fc7-5823-ac8d-9fac00c68b68', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('92143e41-519a-596c-85a5-5a7d5bd6b19e', '0b55f53d-4fc7-5823-ac8d-9fac00c68b68', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('669d0f63-d736-50e0-bc41-c8b1dd9f4583', '0b55f53d-4fc7-5823-ac8d-9fac00c68b68', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('008b2e38-8007-50a0-bc45-0c2bac106fd4', '0b55f53d-4fc7-5823-ac8d-9fac00c68b68', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c6717cbf-2149-598a-a8de-e04d3f1bddbc', '0b55f53d-4fc7-5823-ac8d-9fac00c68b68', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f1be1563-131d-5e03-846b-16a09ccdc76a', '0b55f53d-4fc7-5823-ac8d-9fac00c68b68', 7, $md$G$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('ee9318d5-67c9-50b6-ba53-00d53c1cd8e9', '1872740a-c437-51da-ae77-553148bf5750', 5, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 5

Questions 1-6
Questions 1-6
Use the information in the passage to match the project Brunel did (listed
A-G
) with opinions or deeds below.
Write the appropriate letters
A-G
, in boxes
1-6
on your answer sheet.
A
River Thames Tunnel
B
Clifton Suspension Bridge
C
Atmospheric Railway
D
Great Britain
E
The Great Western
F
Great Western Railway
G
The Great Eastern
1
The project of construction that I.K.Brunel was not responsible for.
2
The project had stopped due to inconvenience and high maintaining cost.
3
The project was honored to yet not completed by Brunel himself.
4
The project had a budget problem although built by a famous engineer.
5
Serious problem happened and delayed repeatedly.
6
The first one to cross the Atlantic Ocean in mankind history.

5 ____ Serious problem happened and delayed repeatedly.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('52113b49-21b4-59f5-bf11-debc5510861a', 'ee9318d5-67c9-50b6-ba53-00d53c1cd8e9', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('61d2212d-286d-5491-a681-424071d5e55f', 'ee9318d5-67c9-50b6-ba53-00d53c1cd8e9', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3a598cec-14c9-542b-9303-3c192f607f0c', 'ee9318d5-67c9-50b6-ba53-00d53c1cd8e9', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b3bb7af9-b7a2-55c1-a3c5-a5b7f4059e6a', 'ee9318d5-67c9-50b6-ba53-00d53c1cd8e9', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e2043b60-83ab-5beb-aac9-9a8cf955ca4a', 'ee9318d5-67c9-50b6-ba53-00d53c1cd8e9', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('753ac86d-a470-5838-83f9-c898f45c8748', 'ee9318d5-67c9-50b6-ba53-00d53c1cd8e9', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9ca48bb4-e00d-5065-9498-1b41cb630a24', 'ee9318d5-67c9-50b6-ba53-00d53c1cd8e9', 7, $md$G$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('f16acf34-b363-5be6-9062-e109360cec79', '1872740a-c437-51da-ae77-553148bf5750', 6, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 6

Questions 1-6
Questions 1-6
Use the information in the passage to match the project Brunel did (listed
A-G
) with opinions or deeds below.
Write the appropriate letters
A-G
, in boxes
1-6
on your answer sheet.
A
River Thames Tunnel
B
Clifton Suspension Bridge
C
Atmospheric Railway
D
Great Britain
E
The Great Western
F
Great Western Railway
G
The Great Eastern
1
The project of construction that I.K.Brunel was not responsible for.
2
The project had stopped due to inconvenience and high maintaining cost.
3
The project was honored to yet not completed by Brunel himself.
4
The project had a budget problem although built by a famous engineer.
5
Serious problem happened and delayed repeatedly.
6
The first one to cross the Atlantic Ocean in mankind history.

6 ____ The first one to cross the Atlantic Ocean in mankind history.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f9409578-19da-5867-85d1-8231baae39bc', 'f16acf34-b363-5be6-9062-e109360cec79', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fd89b08c-9dc0-5079-8e46-0ed47ad22f17', 'f16acf34-b363-5be6-9062-e109360cec79', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ef36768b-ac2f-5f5b-9c4a-cfd54c327981', 'f16acf34-b363-5be6-9062-e109360cec79', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c5290b4e-3146-59c9-b3cd-f39ae83f42da', 'f16acf34-b363-5be6-9062-e109360cec79', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9fc1f444-1971-5bbb-be6f-bd634f6e8b48', 'f16acf34-b363-5be6-9062-e109360cec79', 5, $md$E$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7a8e420a-b61b-5dbe-abb0-44ff6665c91d', 'f16acf34-b363-5be6-9062-e109360cec79', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2a36d9b7-6ac6-5e93-9e6a-2816c1142c7c', 'f16acf34-b363-5be6-9062-e109360cec79', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('68b923d7-1c20-5c3a-ad77-129b2c517ebd', '1872740a-c437-51da-ae77-553148bf5750', 7, 'MATCHING_INFORMATION', 'READING', 3, $md$### Question 7

Questions 7-9
Questions 7-9
The reading Passage has seven paragraphs
A-G
.
Which paragraph contains the following information?
Write the correct letter
A-G
, in boxes
7-9
on your answer sheet
NB
You may use any letter more than once.
7
There was a great ship setting the criteria for the journey of the ocean.
8
An ambitious project which seemed to be applied in an unplanned service later.
9
Brunel showed his talent of inter-personal skills with landlords and finally, the project had been gone through.

7 ____ There was a great ship setting the criteria for the journey of the ocean.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('77c783b3-ee72-5159-b65d-2142f18056e7', '68b923d7-1c20-5c3a-ad77-129b2c517ebd', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('54c89148-7130-5298-a4db-047fdf3e6fb5', '68b923d7-1c20-5c3a-ad77-129b2c517ebd', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('dc4a0c3a-584a-538a-b373-93d761379e4c', '68b923d7-1c20-5c3a-ad77-129b2c517ebd', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4e07a0e4-7cc2-5ee8-8247-ed59805b7c8d', '68b923d7-1c20-5c3a-ad77-129b2c517ebd', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('665022fa-eded-5fab-81ad-4432028065e3', '68b923d7-1c20-5c3a-ad77-129b2c517ebd', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('45b9de5e-d8df-5f72-a038-24a4aa552675', '68b923d7-1c20-5c3a-ad77-129b2c517ebd', 6, $md$F$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('af3cb379-ee7f-550b-a05b-d670128e53a0', '68b923d7-1c20-5c3a-ad77-129b2c517ebd', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('ac78feaa-e3fd-5b55-911d-7281d395a69d', '1872740a-c437-51da-ae77-553148bf5750', 8, 'MATCHING_INFORMATION', 'READING', 3, $md$### Question 8

Questions 7-9
Questions 7-9
The reading Passage has seven paragraphs
A-G
.
Which paragraph contains the following information?
Write the correct letter
A-G
, in boxes
7-9
on your answer sheet
NB
You may use any letter more than once.
7
There was a great ship setting the criteria for the journey of the ocean.
8
An ambitious project which seemed to be applied in an unplanned service later.
9
Brunel showed his talent of inter-personal skills with landlords and finally, the project had been gone through.

8 ____ An ambitious project which seemed to be applied in an unplanned service later.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b6913817-901f-51c3-bdff-52e84c1058c4', 'ac78feaa-e3fd-5b55-911d-7281d395a69d', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0986fd9d-7958-5492-b411-f6ad265fa2c4', 'ac78feaa-e3fd-5b55-911d-7281d395a69d', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7af4d362-f5aa-5d1e-809b-d9fafdb28f06', 'ac78feaa-e3fd-5b55-911d-7281d395a69d', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('54e7958b-e5ca-5748-b96c-2c9ae85a00e8', 'ac78feaa-e3fd-5b55-911d-7281d395a69d', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ac7f93e2-8cc1-5fdf-9bc5-0c46a41a20aa', 'ac78feaa-e3fd-5b55-911d-7281d395a69d', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b901ad24-24e6-5423-a9e6-318dcc8436b5', 'ac78feaa-e3fd-5b55-911d-7281d395a69d', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5f57ba2f-dc94-5272-bcb5-97aa920967f9', 'ac78feaa-e3fd-5b55-911d-7281d395a69d', 7, $md$G$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('4c9faeb3-3e9e-53b5-ac4b-01df2da995d9', '1872740a-c437-51da-ae77-553148bf5750', 9, 'MATCHING_INFORMATION', 'READING', 3, $md$### Question 9

Questions 7-9
Questions 7-9
The reading Passage has seven paragraphs
A-G
.
Which paragraph contains the following information?
Write the correct letter
A-G
, in boxes
7-9
on your answer sheet
NB
You may use any letter more than once.
7
There was a great ship setting the criteria for the journey of the ocean.
8
An ambitious project which seemed to be applied in an unplanned service later.
9
Brunel showed his talent of inter-personal skills with landlords and finally, the project had been gone through.

9 ____ Brunel showed his talent of inter-personal skills with landlords and finally, the project had been gone through.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('91015ecf-d4fa-5070-81da-b72dabeb5f71', '4c9faeb3-3e9e-53b5-ac4b-01df2da995d9', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('12dceaae-c087-58d9-837d-6743c07417ec', '4c9faeb3-3e9e-53b5-ac4b-01df2da995d9', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('002314d2-a144-5d8a-9732-d01ad37525f1', '4c9faeb3-3e9e-53b5-ac4b-01df2da995d9', 3, $md$C$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1581dc5e-0ad4-52ca-b602-4a1c994a0c0e', '4c9faeb3-3e9e-53b5-ac4b-01df2da995d9', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cd35a715-ed74-5e07-b2e4-50bc3c27eb96', '4c9faeb3-3e9e-53b5-ac4b-01df2da995d9', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('eda8211c-891e-5ffb-9623-7b8574fc88d1', '4c9faeb3-3e9e-53b5-ac4b-01df2da995d9', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('922854e2-9589-527a-8aef-44fc3db2cd8e', '4c9faeb3-3e9e-53b5-ac4b-01df2da995d9', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('69d74370-2e1b-5f39-8c32-8f327364e35a', '1872740a-c437-51da-ae77-553148bf5750', 10, 'TABLE_COMPLETION', 'READING', 4, $md$### Question 10

Questions 10-13
Questions 10-13
Complete the following summary of the paragraphs of Reading Passage
Using
NO MORE THAN TWO WORDS
from the Reading Passage for each answer.
Write your answers in boxes
10-13
on your answer sheet.
The Great Eastern was specially designed with a
10
for carrying more fuels and was to take a long voyage to
11
; However due to physical condition, Brunel couldn’t be able to go with the maiden voyage. Actually, the Great Eastern was unprofitable and the great ship never crossed
12
. But soon after there was an ironic opportunity for the Great Eastern which was used to carry and to lay huge
13
in Atlantic Ocean floor.

The Great Eastern was specially designed with a 10 ____ for carrying more fuels and was to take a long voyage to 11 ____ ; However due to physical condition, Brunel couldn’t be able to go with the maiden voyage. Actually, the Great Eastern was unprofitable and the great ship never crossed 12 ____ . But soon after there was an ironic opportunity for the Great Eastern which was used to carry and to lay huge 13 ____ in Atlantic Ocean floor.$md$, NULL, ARRAY['.*the.*biggest.*ship.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('4d0b88ca-1329-5b42-9527-8837e3cc6383', '1872740a-c437-51da-ae77-553148bf5750', 11, 'TABLE_COMPLETION', 'READING', 4, $md$### Question 11

Questions 10-13
Questions 10-13
Complete the following summary of the paragraphs of Reading Passage
Using
NO MORE THAN TWO WORDS
from the Reading Passage for each answer.
Write your answers in boxes
10-13
on your answer sheet.
The Great Eastern was specially designed with a
10
for carrying more fuels and was to take a long voyage to
11
; However due to physical condition, Brunel couldn’t be able to go with the maiden voyage. Actually, the Great Eastern was unprofitable and the great ship never crossed
12
. But soon after there was an ironic opportunity for the Great Eastern which was used to carry and to lay huge
13
in Atlantic Ocean floor.

The Great Eastern was specially designed with a 10 ____ for carrying more fuels and was to take a long voyage to 11 ____ ; However due to physical condition, Brunel couldn’t be able to go with the maiden voyage. Actually, the Great Eastern was unprofitable and the great ship never crossed 12 ____ . But soon after there was an ironic opportunity for the Great Eastern which was used to carry and to lay huge 13 ____ in Atlantic Ocean floor.$md$, NULL, ARRAY['.*the.*biggest.*ship.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('b868c75e-e59d-57cb-86a8-e14a3f4b8054', '1872740a-c437-51da-ae77-553148bf5750', 12, 'TABLE_COMPLETION', 'READING', 4, $md$### Question 12

Questions 10-13
Questions 10-13
Complete the following summary of the paragraphs of Reading Passage
Using
NO MORE THAN TWO WORDS
from the Reading Passage for each answer.
Write your answers in boxes
10-13
on your answer sheet.
The Great Eastern was specially designed with a
10
for carrying more fuels and was to take a long voyage to
11
; However due to physical condition, Brunel couldn’t be able to go with the maiden voyage. Actually, the Great Eastern was unprofitable and the great ship never crossed
12
. But soon after there was an ironic opportunity for the Great Eastern which was used to carry and to lay huge
13
in Atlantic Ocean floor.

The Great Eastern was specially designed with a 10 ____ for carrying more fuels and was to take a long voyage to 11 ____ ; However due to physical condition, Brunel couldn’t be able to go with the maiden voyage. Actually, the Great Eastern was unprofitable and the great ship never crossed 12 ____ . But soon after there was an ironic opportunity for the Great Eastern which was used to carry and to lay huge 13 ____ in Atlantic Ocean floor.$md$, NULL, ARRAY['.*the.*biggest.*ship.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('786471c3-8b94-5ce3-9e9b-516c11656f56', '1872740a-c437-51da-ae77-553148bf5750', 13, 'TABLE_COMPLETION', 'READING', 4, $md$### Question 13

Questions 10-13
Questions 10-13
Complete the following summary of the paragraphs of Reading Passage
Using
NO MORE THAN TWO WORDS
from the Reading Passage for each answer.
Write your answers in boxes
10-13
on your answer sheet.
The Great Eastern was specially designed with a
10
for carrying more fuels and was to take a long voyage to
11
; However due to physical condition, Brunel couldn’t be able to go with the maiden voyage. Actually, the Great Eastern was unprofitable and the great ship never crossed
12
. But soon after there was an ironic opportunity for the Great Eastern which was used to carry and to lay huge
13
in Atlantic Ocean floor.

The Great Eastern was specially designed with a 10 ____ for carrying more fuels and was to take a long voyage to 11 ____ ; However due to physical condition, Brunel couldn’t be able to go with the maiden voyage. Actually, the Great Eastern was unprofitable and the great ship never crossed 12 ____ . But soon after there was an ironic opportunity for the Great Eastern which was used to carry and to lay huge 13 ____ in Atlantic Ocean floor.$md$, NULL, ARRAY['.*the.*biggest.*ship.*']);

COMMIT;
