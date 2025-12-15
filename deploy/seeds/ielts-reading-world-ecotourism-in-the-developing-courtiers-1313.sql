BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-world-ecotourism-in-the-developing-courtiers-1313'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-world-ecotourism-in-the-developing-courtiers-1313';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-world-ecotourism-in-the-developing-courtiers-1313';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-world-ecotourism-in-the-developing-courtiers-1313';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('24c68334-b0a0-5451-853a-dc5e3ce097e6', 'ielts-reading-world-ecotourism-in-the-developing-courtiers-1313', $t$World Ecotourism in the developing courtiers$t$, $md$## World Ecotourism in the developing courtiers

Nguồn:
- Test: https://mini-ielts.com/1313/reading/world-ecotourism-in-the-developing-courtiers
- Solution: https://mini-ielts.com/1313/view-solution/reading/world-ecotourism-in-the-developing-courtiers$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('96a68527-defc-5dcd-9c7a-9e9eb6e2c033', '24c68334-b0a0-5451-853a-dc5e3ce097e6', 1, $t$Reading — World Ecotourism in the developing courtiers$t$, $md$Read the passage and answer questions **1–13**.

### Passage: World Ecotourism in the developing courtiers

A

The Ecotourism Society defines ecotourism as “a responsible travel to natural areas which conserves the environment and improves the welfare of local people”. It is recognised as being particularly conducive to enriching and enhancing the standing of tourism, on the basis that this form of tourism respects the natural heritage and local populations and are in keeping with the carrying capacity of the sites.

B

Cuba

Cuba is undoubtedly an obvious site for ecotourism, with its picturesque beaches, underwater beauty, countryside landscapes, and ecological reserves. An educated population and improved infrastructure of roads and communications add to the mix. In the Caribbean region, Cuba is now the second most popular tourist destination.

Ecotourism is also seen as an environmental education opportunity to heighten both visitors’ and residents’ awareness of environmental and conservation issues, and even to inspire conservation action.

Ecotourism has also been credited with promoting peace, by providing opportunities for educational and cultural exchange. Tourists’ safety and health are guaranteed.

Raul Castro, brother of the Cuban president, started this initiative to rescue the Cuban tradition of herbal medicine and provide natural medicines for its healthcare system. The school at Las Terrazas Eco-Tourism Community teaches herbal healthcare and children learn not only how to use medicinal herbs, but also to grow them in the school garden for teas, tinctures, ointments and creams.

In Cuba, ecotourism has the potential to alleviate poverty by bringing money into the economy and creating jobs. In addition to the environmental impacts of these efforts, the area works on developing community employment opportunities for locals, in conjunction with ecotourism.

C

South America

In terms of South America, it might be the place which shows the shortcoming of ecotourism. Histoplasma capsulatum (see chapter “Histoplasmosis and HIV”), a dimorphic fungus, is the most common endemic mycosis the United States,(12) and is associated with exposure to a bat or bird droppings. Most recently, outbreaks have been reported in healthy travelers who returned from Central and South America after engaging in recreational activities associated with spelunking, adventure tourism, and ecotourism. It is quite often to see tourists neglected sanitation while travelling. After engaging in high-risk activities, boots should be hosed off and clothing placed in airtight plastic bags for laundering. HIV-infected travelers should avoid risky behaviors or environments, such as exploring caves, particularly those that contain bat droppings.

D

Nowhere is the keen eye and intimate knowledge of ecotourism are more amidst this fantastic biodiversity, as we explore remote realms rich in wildlife rather than a nature adventure. A sustainable tour is significant for ecotourism, one in which we can grow hand in hand with nature and our community, respecting everything that makes us privileged. Travelers get great joy from every step that takes forward on this endless but exciting journey towards sustainability. The primary threats to South American’s tropical forests are deforestation caused by agricultural expansion, cattle ranching, logging, oil extraction and spills, mining, illegal coca farming, and colonization initiatives. Deforestation has shrunk territories belonging to indigenous peoples and wiped out more than 90% of the population. Many are taking leading roles in sustainable tourism even as they introduce protected regions to more travelers.

E

East Africa

In East Africa, significantly reducing such illegal hunting and allowing wildlife populations to recover would allow the generation of significant economic benefits through trophy hunting and potentially ecotourism. “Illegal hunting is an extremely inefficient use of wildlife resources because it fails to capture the value of wildlife achievable through alternative forms of use such as trophy hunting and ecotourism,” said Peter Lindsey, author of the new study. Most residents believed that ecotourism could solve this circumstance. They have passion for local community empowerment, loves photography and writes to laud current local conservation efforts, create environmental awareness and promote ecotourism.

F

Indonesia

In Indonesia, ecotourism started to become an important concept from 1995, in order to strengthen the domestic travelling movement, the local government targeting the right markets is a prerequisite for successful ecotourism. The market segment for Indonesian ecotourism consists of: (i) “The silent generation”, 55-64 year-old people who are wealthy enough, generally well-educated and have no dependent children, and can travel for four weeks; (ii) “The baby boom generation”, junior successful executives aged 35-54 years, who are likely to be travelling with their family and children (spending 2-3 weeks on travel) – travelling for them is a stress reliever; and (iii) the “X generation”, aged 18-29 years, who love to do ecotours as backpackers – they are generally students who can travel for 3-12 months with monthly expenditure of US$300-500. It is suggested that the promotion of Indonesian ecotourism products should aim to reach these various cohorts of tourists. The country welcomes diverse levels of travelers.

G

On the other hand, ecotourism provides as many services as traditional tourism. Nestled between Mexico, Guatemala and the Caribbean Sea is the country of Belize. It is the wonderful place for Hamanasi honeymoon, a bottle of champagne upon arrival, three meals daily, private service on one night of your stay and a choice of adventures depending on the length of your stay. It also offers six-night and seven-night honeymoon packages. A variety of specially tailored tours, including the Brimstone Hill Fortress, and a trip to a neighboring island. Guided tours include rainforest, volcano and off-road plantation tours. Gregory Pereira, an extremely knowledgeable and outgoing hiking and tour guide, says the following about his tours: “All of our tours on St.Kitts include transportation by specially modified Land Rovers, a picnic of island pastries and local fruit, fresh tropical juices, CSR, a qualified island guide and a full liability insurance coverage for participants.

H

Kodai is an ultimate splendor spot for those who love being close to mother nature. They say every bird must sing it’s own throat while we say every traveler should find his own way out of variegated and unblemished paths of deep valleys and steep mountains. The cheese factory here exports a great quantity of cheese to various countries across the globe. It is located in the center of the forest. Many travelers are attracted by the delicious cheese. The ecotourism is very famous this different eating experience.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('0a14c218-3369-5a05-a30c-3479669de9f9', '96a68527-defc-5dcd-9c7a-9e9eb6e2c033', 1, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 1

Questions 1-5
Questions 1-5
Use the information in the passage to match the place (listed
A-D
) with opinions or deeds below.
Write the appropriate letters
A-D
in boxes
1-5
on your answer sheet.
NB
You may use any letter more than once
.
A
Cuba
B
East Africa
C
South America
D
Indonesia
1
a place to improve local education to help tourists
2
a place suitable for both rich and poor travelers
3
a place where could easily get fungus
4
a place taking a method to stop unlawful poaching
5
a place where the healthcare system is developed

1 ____ a place to improve local education to help tourists$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5b03acf8-01f1-595a-b7e9-0903e78537c4', '0a14c218-3369-5a05-a30c-3479669de9f9', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('768755cd-eabf-56f1-ac6d-68076fce5644', '0a14c218-3369-5a05-a30c-3479669de9f9', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f330978c-00b3-5665-a04c-e896dc91b3b9', '0a14c218-3369-5a05-a30c-3479669de9f9', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('600cb8ca-bda0-5978-b70d-82b91736c17f', '0a14c218-3369-5a05-a30c-3479669de9f9', 4, $md$D$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('41c57796-3f47-5963-bbfb-e2ea3efac80c', '96a68527-defc-5dcd-9c7a-9e9eb6e2c033', 2, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 2

Questions 1-5
Questions 1-5
Use the information in the passage to match the place (listed
A-D
) with opinions or deeds below.
Write the appropriate letters
A-D
in boxes
1-5
on your answer sheet.
NB
You may use any letter more than once
.
A
Cuba
B
East Africa
C
South America
D
Indonesia
1
a place to improve local education to help tourists
2
a place suitable for both rich and poor travelers
3
a place where could easily get fungus
4
a place taking a method to stop unlawful poaching
5
a place where the healthcare system is developed

2 ____ a place suitable for both rich and poor travelers$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9d128a43-4439-5afe-a035-1c35f6eb7325', '41c57796-3f47-5963-bbfb-e2ea3efac80c', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fb40ad19-9a58-505d-9523-9439e20a61d0', '41c57796-3f47-5963-bbfb-e2ea3efac80c', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7c94507a-4d80-510f-8413-cccdb8ed6689', '41c57796-3f47-5963-bbfb-e2ea3efac80c', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6165e0c6-165e-5cbf-a00e-b4acbe0e5f94', '41c57796-3f47-5963-bbfb-e2ea3efac80c', 4, $md$D$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('d239a213-aeb3-5c6c-a5a1-1840d6c18ee7', '96a68527-defc-5dcd-9c7a-9e9eb6e2c033', 3, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 3

Questions 1-5
Questions 1-5
Use the information in the passage to match the place (listed
A-D
) with opinions or deeds below.
Write the appropriate letters
A-D
in boxes
1-5
on your answer sheet.
NB
You may use any letter more than once
.
A
Cuba
B
East Africa
C
South America
D
Indonesia
1
a place to improve local education to help tourists
2
a place suitable for both rich and poor travelers
3
a place where could easily get fungus
4
a place taking a method to stop unlawful poaching
5
a place where the healthcare system is developed

3 ____ a place where could easily get fungus$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('02aa55f3-0ef8-54eb-90a0-1458e7548c69', 'd239a213-aeb3-5c6c-a5a1-1840d6c18ee7', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('314639cf-cadd-5ce2-8912-cc7532f71ede', 'd239a213-aeb3-5c6c-a5a1-1840d6c18ee7', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a1cf6304-765b-502c-ac79-c4ab4f6912e6', 'd239a213-aeb3-5c6c-a5a1-1840d6c18ee7', 3, $md$C$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('74b42d27-39a4-5142-9dc4-c2edf4c15664', 'd239a213-aeb3-5c6c-a5a1-1840d6c18ee7', 4, $md$D$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('794d86fd-53e0-5cdc-9070-68fc0351a09f', '96a68527-defc-5dcd-9c7a-9e9eb6e2c033', 4, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 4

Questions 1-5
Questions 1-5
Use the information in the passage to match the place (listed
A-D
) with opinions or deeds below.
Write the appropriate letters
A-D
in boxes
1-5
on your answer sheet.
NB
You may use any letter more than once
.
A
Cuba
B
East Africa
C
South America
D
Indonesia
1
a place to improve local education to help tourists
2
a place suitable for both rich and poor travelers
3
a place where could easily get fungus
4
a place taking a method to stop unlawful poaching
5
a place where the healthcare system is developed

4 ____ a place taking a method to stop unlawful poaching$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('47978480-65e1-5f27-aeac-1540f9b5539d', '794d86fd-53e0-5cdc-9070-68fc0351a09f', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('46585adb-dcb4-5a97-b4dc-16040bfeebc1', '794d86fd-53e0-5cdc-9070-68fc0351a09f', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5a552451-1aea-5f7a-87f4-326317b75c6b', '794d86fd-53e0-5cdc-9070-68fc0351a09f', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('68db01b2-595c-5740-a3fe-e2db3c01d215', '794d86fd-53e0-5cdc-9070-68fc0351a09f', 4, $md$D$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('13c5dd0d-7883-5496-badf-373052fdc209', '96a68527-defc-5dcd-9c7a-9e9eb6e2c033', 5, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 5

Questions 1-5
Questions 1-5
Use the information in the passage to match the place (listed
A-D
) with opinions or deeds below.
Write the appropriate letters
A-D
in boxes
1-5
on your answer sheet.
NB
You may use any letter more than once
.
A
Cuba
B
East Africa
C
South America
D
Indonesia
1
a place to improve local education to help tourists
2
a place suitable for both rich and poor travelers
3
a place where could easily get fungus
4
a place taking a method to stop unlawful poaching
5
a place where the healthcare system is developed

5 ____ a place where the healthcare system is developed$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2ab19d92-cdfc-5c27-b967-c80e067134ec', '13c5dd0d-7883-5496-badf-373052fdc209', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7f7b4e0b-4bfd-5eec-9c75-ad7e7bba48a4', '13c5dd0d-7883-5496-badf-373052fdc209', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('94773414-2254-51b7-bb03-df035eac1ed7', '13c5dd0d-7883-5496-badf-373052fdc209', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1abd5749-ee1e-58a1-a759-8ebbe499ccdb', '13c5dd0d-7883-5496-badf-373052fdc209', 4, $md$D$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('45286ab1-7e10-5308-8f1c-d72e80bfaad5', '96a68527-defc-5dcd-9c7a-9e9eb6e2c033', 6, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 6

Questions 6-9
Questions 6-9
Use the information in the passage to match the companies (listed
A-D
) with opinions or deeds below.
Write the appropriate letters
A
,
B
,
C
or
D
in boxes
6-9
on your answer sheet.
A
eating the local fruits at the same time
B
find job opportunities in the community
C
which is situated in the heart of the jungle
D
with private and comfortable service
6
Visiting the cheese factory
7
Enjoying the honeymoon
8
Having the picnic while
9
The residents in Cuba could

6 ____ Visiting the cheese factory$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8a88cdf9-1fb5-5e7a-b403-429ca200c0da', '45286ab1-7e10-5308-8f1c-d72e80bfaad5', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8bfdf099-1360-5bcf-aa3e-97baa3c47331', '45286ab1-7e10-5308-8f1c-d72e80bfaad5', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b968c8d0-15f1-5174-bcab-efac84e5332d', '45286ab1-7e10-5308-8f1c-d72e80bfaad5', 3, $md$C$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a1fff052-adc6-5022-81ed-a95a6d7e5407', '45286ab1-7e10-5308-8f1c-d72e80bfaad5', 4, $md$D$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('f598f43e-7684-5b24-b78d-838d72a4ecaf', '96a68527-defc-5dcd-9c7a-9e9eb6e2c033', 7, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 7

Questions 6-9
Questions 6-9
Use the information in the passage to match the companies (listed
A-D
) with opinions or deeds below.
Write the appropriate letters
A
,
B
,
C
or
D
in boxes
6-9
on your answer sheet.
A
eating the local fruits at the same time
B
find job opportunities in the community
C
which is situated in the heart of the jungle
D
with private and comfortable service
6
Visiting the cheese factory
7
Enjoying the honeymoon
8
Having the picnic while
9
The residents in Cuba could

7 ____ Enjoying the honeymoon$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('08d2a82b-fba9-50cd-9600-76b37faedeef', 'f598f43e-7684-5b24-b78d-838d72a4ecaf', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7f7b160a-9752-58cc-94fa-5db53c45371a', 'f598f43e-7684-5b24-b78d-838d72a4ecaf', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c5963c08-1a96-50f3-8af1-2d15ca645d60', 'f598f43e-7684-5b24-b78d-838d72a4ecaf', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2c376df9-c46f-5489-b488-99a6ebc08588', 'f598f43e-7684-5b24-b78d-838d72a4ecaf', 4, $md$D$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('d7e770e3-bece-5cee-97b0-d61b9336cc43', '96a68527-defc-5dcd-9c7a-9e9eb6e2c033', 8, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 8

Questions 6-9
Questions 6-9
Use the information in the passage to match the companies (listed
A-D
) with opinions or deeds below.
Write the appropriate letters
A
,
B
,
C
or
D
in boxes
6-9
on your answer sheet.
A
eating the local fruits at the same time
B
find job opportunities in the community
C
which is situated in the heart of the jungle
D
with private and comfortable service
6
Visiting the cheese factory
7
Enjoying the honeymoon
8
Having the picnic while
9
The residents in Cuba could

8 ____ Having the picnic while$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ad9f494c-3a96-5b78-90b2-af27ba4b30a8', 'd7e770e3-bece-5cee-97b0-d61b9336cc43', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9bd58216-b80d-5033-bc3b-2585c0a2467c', 'd7e770e3-bece-5cee-97b0-d61b9336cc43', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d214ec13-481d-5177-8aa0-d0fb5bebe33e', 'd7e770e3-bece-5cee-97b0-d61b9336cc43', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('44d93272-5b84-51cf-a272-d7e5a023d035', 'd7e770e3-bece-5cee-97b0-d61b9336cc43', 4, $md$D$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('88a6b55c-fe38-5207-936a-83778637f347', '96a68527-defc-5dcd-9c7a-9e9eb6e2c033', 9, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 9

Questions 6-9
Questions 6-9
Use the information in the passage to match the companies (listed
A-D
) with opinions or deeds below.
Write the appropriate letters
A
,
B
,
C
or
D
in boxes
6-9
on your answer sheet.
A
eating the local fruits at the same time
B
find job opportunities in the community
C
which is situated in the heart of the jungle
D
with private and comfortable service
6
Visiting the cheese factory
7
Enjoying the honeymoon
8
Having the picnic while
9
The residents in Cuba could

9 ____ The residents in Cuba could$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('69420b02-d292-58cd-a433-3972b812acf0', '88a6b55c-fe38-5207-936a-83778637f347', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('eda9c3ff-855a-5495-bcfb-0addc67bc98a', '88a6b55c-fe38-5207-936a-83778637f347', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('efad7185-5735-5a75-9333-26c5c805ace4', '88a6b55c-fe38-5207-936a-83778637f347', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('21b59e45-ed9c-5b80-a835-f0d4c9473cae', '88a6b55c-fe38-5207-936a-83778637f347', 4, $md$D$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('1190c27d-2c8b-53e9-8877-88c342d4e246', '96a68527-defc-5dcd-9c7a-9e9eb6e2c033', 10, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 10

Questions 10-13
Questions 10-13
Summary
Complete the following summary of the paragraphs of Reading Passage
Using
NO MORE THAN TWO WORDS
from the Reading Passage for each answer.
Write your answers in boxes
10-13
on your answer sheet.
Ecotourism is not a nature
10
but a
11
tour. The reason why South America promotes ecotourism is due to the destruction of
12
. In addition, East Africa also encourages this kind of tourism for cutting the
13
in order to save wild animals.

Ecotourism is not a nature 10 ____ but a 11 ____ tour. The reason why South America promotes ecotourism is due to the destruction of 12 ____ . In addition, East Africa also encourages this kind of tourism for cutting the 13 ____ in order to save wild animals.$md$, NULL, ARRAY['.*adventure.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('cfef908f-0d69-5647-8972-6375ab612201', '96a68527-defc-5dcd-9c7a-9e9eb6e2c033', 11, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 11

Questions 10-13
Questions 10-13
Summary
Complete the following summary of the paragraphs of Reading Passage
Using
NO MORE THAN TWO WORDS
from the Reading Passage for each answer.
Write your answers in boxes
10-13
on your answer sheet.
Ecotourism is not a nature
10
but a
11
tour. The reason why South America promotes ecotourism is due to the destruction of
12
. In addition, East Africa also encourages this kind of tourism for cutting the
13
in order to save wild animals.

Ecotourism is not a nature 10 ____ but a 11 ____ tour. The reason why South America promotes ecotourism is due to the destruction of 12 ____ . In addition, East Africa also encourages this kind of tourism for cutting the 13 ____ in order to save wild animals.$md$, NULL, ARRAY['.*adventure.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('a8cb349b-30d7-595e-be44-ff57f49444dc', '96a68527-defc-5dcd-9c7a-9e9eb6e2c033', 12, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 12

Questions 10-13
Questions 10-13
Summary
Complete the following summary of the paragraphs of Reading Passage
Using
NO MORE THAN TWO WORDS
from the Reading Passage for each answer.
Write your answers in boxes
10-13
on your answer sheet.
Ecotourism is not a nature
10
but a
11
tour. The reason why South America promotes ecotourism is due to the destruction of
12
. In addition, East Africa also encourages this kind of tourism for cutting the
13
in order to save wild animals.

Ecotourism is not a nature 10 ____ but a 11 ____ tour. The reason why South America promotes ecotourism is due to the destruction of 12 ____ . In addition, East Africa also encourages this kind of tourism for cutting the 13 ____ in order to save wild animals.$md$, NULL, ARRAY['.*adventure.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('9688d549-87d5-5f93-a15e-f88135932476', '96a68527-defc-5dcd-9c7a-9e9eb6e2c033', 13, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 13

Questions 10-13
Questions 10-13
Summary
Complete the following summary of the paragraphs of Reading Passage
Using
NO MORE THAN TWO WORDS
from the Reading Passage for each answer.
Write your answers in boxes
10-13
on your answer sheet.
Ecotourism is not a nature
10
but a
11
tour. The reason why South America promotes ecotourism is due to the destruction of
12
. In addition, East Africa also encourages this kind of tourism for cutting the
13
in order to save wild animals.

Ecotourism is not a nature 10 ____ but a 11 ____ tour. The reason why South America promotes ecotourism is due to the destruction of 12 ____ . In addition, East Africa also encourages this kind of tourism for cutting the 13 ____ in order to save wild animals.$md$, NULL, ARRAY['.*adventure.*']);

COMMIT;
