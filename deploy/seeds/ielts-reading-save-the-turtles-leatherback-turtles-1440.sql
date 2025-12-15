BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-save-the-turtles-leatherback-turtles-1440'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-save-the-turtles-leatherback-turtles-1440';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-save-the-turtles-leatherback-turtles-1440';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-save-the-turtles-leatherback-turtles-1440';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('03593f38-edf7-564f-ba79-40bcdaf78bf2', 'ielts-reading-save-the-turtles-leatherback-turtles-1440', $t$Save the Turtles (Leatherback turtles)$t$, $md$## Save the Turtles (Leatherback turtles)

Nguồn:
- Test: https://mini-ielts.com/1440/reading/save-the-turtles-leatherback-turtles
- Solution: https://mini-ielts.com/1440/view-solution/reading/save-the-turtles-leatherback-turtles$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('1fd6a2e0-a904-527c-9926-7a4f5fd9000f', '03593f38-edf7-564f-ba79-40bcdaf78bf2', 1, $t$Reading — Save the Turtles (Leatherback turtles)$t$, $md$Read the passage and answer questions **1–13**.

### Passage: Save the Turtles (Leatherback turtles)

| | Save the Turtles (Leatherback turtles) Leatherback turtles follow the general sea turtle body plan of having a large, flattened, round body with two pairs of very large flippers and a short tail. Like other sea turtles, the leatherback’s flattened forelimbs are adapted for swimming in the open ocean. Claws are absent from both pairs of flippers. The Leatherback’s flippers arc the largest in proportion to its body among extant sea turtles. Leatherback’s front flippers can grow up to 2.7 meters (9 ft) in large specimens, the largest flippers (even in comparison to its body) of any sea turtle. As the last surviving member of its family, the leatherback turtle has several distinguishing characteristics that differentiate it from other sea turtles. Its most notable feature is that it lacks the bony carapace of the other extant sea turtles. During the past month, four turtles have washed up along Irish coasts from Wexford to Kerry. These turtles arc more typical of warmer waters and only occur in Irish waters when they stray off course. It is likely that they may have originated from Florida, America. Two specimens have been taken to Coastal and Marine Resources Centre (stored at the National Maritime College), University College Cork, where a necropsy (post mortem for animals) will be conducted to establish their age, sex and their exact origin. During this same period, two leatherback turtles were found in Scotland, and a rare Kemp’s Ridley turtle was found in Wales, thus making it an exceptional month for stranded turtles in Ireland and the UK. Actually, There has been extensive research conducted regarding the sea turtles’ abilities to return to their nesting regions and sometimes exact locations from hundreds of miles away. In the water, their path is greatly affected by powerful currents. Despite their limited vision, and lack of landmarks in the open water, turtles are able to retrace their migratory paths. Some explanations of this phenomenon have found that sea turtles can detect the angle and intensity of the earth’s magnetic fields. However, Loggerhead turtles are not normally found in Irish waters, because water temperatures here are far too cold for their survival. Instead, adult loggerheads prefer the warmers waters of the Mediterranean, the Caribbean and North America’s east coast. The four turtles that were found have probably originated from the North American population of loggerheads. However it will require genetic analysis to confirm this assumption. It is thought that after leaving their nesting beach as hatchlings (when they measure 4.5 cm in length), these tiny turtles enter the North Atlantic Gyre (a giant circular ocean current) that takes them from America, across to Europe (Azores area), down towards North Africa, before being transported back again to America via a different current. This remarkable round trip may take many years during which these tiny turtles grow by several centimetres a year. Loggerheads may circulate around the North Atlantic several times before they settle in the coastal waters of Florida or the Caribbean. These four turtles were probably on their way around the Atlantic when they strayed a bit too far north from the Gulf Stream. Once they did, their fate was sealed, as the cooler waters of the North East Atlantic are too cold for loggerheads (unlike leatherback turtles which have many anatomical and physiological adaptations to enable them to swim in our seas). Once in cool waters, the body of a loggerhead begins to shut down as they get ‘cold stunned’, then get hypothermia and die. Leatherbacks are in immanent danger of extinction. A critical factor (among others) is the harvesting of eggs from nests. Valued as a food delicacy, Leatherback eggs are falsely touted to have aphrodisiacal properties in some cultures. The leatherback, unlike the Green Sea turtle, is not often killed for its meat; however, the increase in human populations coupled with the growing black market trade has escalated their egg depletion, other critical factors causing the leatherbacks’ decline are pollution such as plastics (leatherbacks eat this debris thinking it is jellyfish; fishing practices such as longline fishing and gill nets, and development on habitat areas. Scientists have estimated that there are only about 35,000 Leatherback turtles in the world. We are often unable to understand the critical impact a species has on the environment—that is, until that species becomes extinct. Even if we do not know the role a creature plays in the health of the environment, past lessons have taught US enough to know that every animal and plant is one important link in the integral chain of nature. Some scientists now speculate that the Leatherback may play an important role in the recovery of diminishing fish populations. Since the Leatherback consumes its weight in jellyfish per day, it helps to keep Jellyfish populations in check. Jellyfish consume large quantities of fish larvae. The rapid decline in Leatherback populations over the last 50 years has been accompanied by a significant increase in jellyfish and a marked decrease in fish in our oceans. Saving sea turtles is an International endeavor.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('a5ad4ffb-6e2c-5e58-914c-309fe096dfe7', '1fd6a2e0-a904-527c-9926-7a4f5fd9000f', 1, 'MATCHING_HEADING', 'READING', 2, $md$### Question 1

Question 1-6
Question 1-6
Choose the most suitable headings for paragraphs B-G from the list of headings below.
Write appropriate numbers
(i-x)
in boxes
1 -6
on your answer sheet.
NB There are more headings than paragraphs, so you will not use them all.
List of Headings
Sea turtles are found in unusual locations
Unique features of the Leatherbacks
The Leatherback’s contribution
Methods used for routes tracking
Predict the migration routes
Remains multiplicity within the species
The progress of hatching
The fate of the lost turles
How trips suppose to look like?
Factors leading to population decline
1
Paragraph B
2
Paragraph C
3
Paragraph D
4
Paragraph E
5
Paragraph F
6
Paragraph G

1 ____ Paragraph B$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8c807b61-2ecd-5e23-8859-9551f951cff5', 'a5ad4ffb-6e2c-5e58-914c-309fe096dfe7', 1, $md$i$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4f6973ca-9f3a-5ea3-ae6a-d4fbfd057489', 'a5ad4ffb-6e2c-5e58-914c-309fe096dfe7', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bae597e7-c598-5741-9cfb-4bbc04d45804', 'a5ad4ffb-6e2c-5e58-914c-309fe096dfe7', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8bf80b74-fc9e-5ada-9b45-4e7c7c16ff9d', 'a5ad4ffb-6e2c-5e58-914c-309fe096dfe7', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8b9a2512-5aa2-53c6-af0f-eb0425ddc523', 'a5ad4ffb-6e2c-5e58-914c-309fe096dfe7', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('858460df-1a05-50f0-9337-9a66689b418d', 'a5ad4ffb-6e2c-5e58-914c-309fe096dfe7', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1c4f1c90-33f7-5140-9eb7-eaab441d2fa1', 'a5ad4ffb-6e2c-5e58-914c-309fe096dfe7', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6cdf774a-f567-528c-9db2-929bc5515b90', 'a5ad4ffb-6e2c-5e58-914c-309fe096dfe7', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('84cba845-ad64-5871-a569-b92223f5b1c1', 'a5ad4ffb-6e2c-5e58-914c-309fe096dfe7', 9, $md$ix$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('610d1e6a-3edb-51dd-b683-1c148815b236', 'a5ad4ffb-6e2c-5e58-914c-309fe096dfe7', 10, $md$x$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('d00b8287-48f4-502b-8826-ce5e9eb30036', '1fd6a2e0-a904-527c-9926-7a4f5fd9000f', 2, 'MATCHING_HEADING', 'READING', 2, $md$### Question 2

Question 1-6
Question 1-6
Choose the most suitable headings for paragraphs B-G from the list of headings below.
Write appropriate numbers
(i-x)
in boxes
1 -6
on your answer sheet.
NB There are more headings than paragraphs, so you will not use them all.
List of Headings
Sea turtles are found in unusual locations
Unique features of the Leatherbacks
The Leatherback’s contribution
Methods used for routes tracking
Predict the migration routes
Remains multiplicity within the species
The progress of hatching
The fate of the lost turles
How trips suppose to look like?
Factors leading to population decline
1
Paragraph B
2
Paragraph C
3
Paragraph D
4
Paragraph E
5
Paragraph F
6
Paragraph G

2 ____ Paragraph C$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('19694ab2-0e17-56cb-aa6b-707597726d72', 'd00b8287-48f4-502b-8826-ce5e9eb30036', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('80642c1f-5d36-53d1-ba2d-0c2cc799ab81', 'd00b8287-48f4-502b-8826-ce5e9eb30036', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a11908cf-aebc-5f34-8de5-7ce7f04384fa', 'd00b8287-48f4-502b-8826-ce5e9eb30036', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('de7ed09b-e8f4-5c77-b8e9-fc4384900cc0', 'd00b8287-48f4-502b-8826-ce5e9eb30036', 4, $md$iv$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ef7760d4-5846-5161-8956-c2ceb31650bd', 'd00b8287-48f4-502b-8826-ce5e9eb30036', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3411a140-ec39-544c-810c-d4d3874b475d', 'd00b8287-48f4-502b-8826-ce5e9eb30036', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8d64de3d-7ddb-5779-bfb6-daa2285210ec', 'd00b8287-48f4-502b-8826-ce5e9eb30036', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('84d5fe91-2de8-5eca-92af-07002d5f6b22', 'd00b8287-48f4-502b-8826-ce5e9eb30036', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('067c673e-77d8-58ec-80f7-10045de4210f', 'd00b8287-48f4-502b-8826-ce5e9eb30036', 9, $md$ix$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7646823e-681c-59e2-acf1-d9663b19e356', 'd00b8287-48f4-502b-8826-ce5e9eb30036', 10, $md$x$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('933968eb-6e35-54be-9651-c45835909995', '1fd6a2e0-a904-527c-9926-7a4f5fd9000f', 3, 'MATCHING_HEADING', 'READING', 2, $md$### Question 3

Question 1-6
Question 1-6
Choose the most suitable headings for paragraphs B-G from the list of headings below.
Write appropriate numbers
(i-x)
in boxes
1 -6
on your answer sheet.
NB There are more headings than paragraphs, so you will not use them all.
List of Headings
Sea turtles are found in unusual locations
Unique features of the Leatherbacks
The Leatherback’s contribution
Methods used for routes tracking
Predict the migration routes
Remains multiplicity within the species
The progress of hatching
The fate of the lost turles
How trips suppose to look like?
Factors leading to population decline
1
Paragraph B
2
Paragraph C
3
Paragraph D
4
Paragraph E
5
Paragraph F
6
Paragraph G

3 ____ Paragraph D$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('789d339e-6d6b-5884-8c72-e7cda3dddc0f', '933968eb-6e35-54be-9651-c45835909995', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ac9f882f-1f55-5bdf-82b2-bd8d90470b4b', '933968eb-6e35-54be-9651-c45835909995', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('09a15a78-a32c-56ff-8804-1433b9f871e5', '933968eb-6e35-54be-9651-c45835909995', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8510c12b-dc65-569e-901e-ec4bf7d3a519', '933968eb-6e35-54be-9651-c45835909995', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4c4df427-00f0-5eb8-a9af-5703901e0c4d', '933968eb-6e35-54be-9651-c45835909995', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('81343ca1-32db-5209-8364-8ede264300bf', '933968eb-6e35-54be-9651-c45835909995', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0061ea8e-780b-5fcb-b483-cb40a2cbd49d', '933968eb-6e35-54be-9651-c45835909995', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('256ab04b-8d0c-5180-8de3-45a26b3d44a3', '933968eb-6e35-54be-9651-c45835909995', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('13fb9e47-28ed-5c1a-a390-5e236a9dfff0', '933968eb-6e35-54be-9651-c45835909995', 9, $md$ix$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2845aa58-6199-5deb-911d-5cc100a32a32', '933968eb-6e35-54be-9651-c45835909995', 10, $md$x$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('82549f76-a9c9-51ce-9bd8-c9222cee077c', '1fd6a2e0-a904-527c-9926-7a4f5fd9000f', 4, 'MATCHING_HEADING', 'READING', 2, $md$### Question 4

Question 1-6
Question 1-6
Choose the most suitable headings for paragraphs B-G from the list of headings below.
Write appropriate numbers
(i-x)
in boxes
1 -6
on your answer sheet.
NB There are more headings than paragraphs, so you will not use them all.
List of Headings
Sea turtles are found in unusual locations
Unique features of the Leatherbacks
The Leatherback’s contribution
Methods used for routes tracking
Predict the migration routes
Remains multiplicity within the species
The progress of hatching
The fate of the lost turles
How trips suppose to look like?
Factors leading to population decline
1
Paragraph B
2
Paragraph C
3
Paragraph D
4
Paragraph E
5
Paragraph F
6
Paragraph G

4 ____ Paragraph E$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('23a9d088-b847-5d56-bc6c-dc32e49ee070', '82549f76-a9c9-51ce-9bd8-c9222cee077c', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('22cf6687-eb4d-59a0-a5b3-295f900b5cab', '82549f76-a9c9-51ce-9bd8-c9222cee077c', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('143a7c87-2a85-5f0f-b40c-8d8a23533903', '82549f76-a9c9-51ce-9bd8-c9222cee077c', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0a2a93c8-1005-5c9a-8b5e-5ef32b72aec1', '82549f76-a9c9-51ce-9bd8-c9222cee077c', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e2482642-1ee8-51db-a959-48c79b4122af', '82549f76-a9c9-51ce-9bd8-c9222cee077c', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('25ed28f5-25d0-5d61-b453-13366ed912fe', '82549f76-a9c9-51ce-9bd8-c9222cee077c', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b195c203-a341-59c8-aa06-de1f7f1fc522', '82549f76-a9c9-51ce-9bd8-c9222cee077c', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e6ec1b4b-7f1f-57a8-9ca9-ef78a7ad1ef1', '82549f76-a9c9-51ce-9bd8-c9222cee077c', 8, $md$viii$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('19d7ed28-b71e-5d81-810c-29cc9f6c23c6', '82549f76-a9c9-51ce-9bd8-c9222cee077c', 9, $md$ix$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5aab23da-c28f-5240-85ea-dc892c077059', '82549f76-a9c9-51ce-9bd8-c9222cee077c', 10, $md$x$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('d0f8f9d6-7c3f-54ec-b57e-baf11890caaf', '1fd6a2e0-a904-527c-9926-7a4f5fd9000f', 5, 'MATCHING_HEADING', 'READING', 3, $md$### Question 5

Question 1-6
Question 1-6
Choose the most suitable headings for paragraphs B-G from the list of headings below.
Write appropriate numbers
(i-x)
in boxes
1 -6
on your answer sheet.
NB There are more headings than paragraphs, so you will not use them all.
List of Headings
Sea turtles are found in unusual locations
Unique features of the Leatherbacks
The Leatherback’s contribution
Methods used for routes tracking
Predict the migration routes
Remains multiplicity within the species
The progress of hatching
The fate of the lost turles
How trips suppose to look like?
Factors leading to population decline
1
Paragraph B
2
Paragraph C
3
Paragraph D
4
Paragraph E
5
Paragraph F
6
Paragraph G

5 ____ Paragraph F$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cf67533d-1642-55f5-8d70-49c7e38c4d1b', 'd0f8f9d6-7c3f-54ec-b57e-baf11890caaf', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('30e182f3-070a-5ef3-a49f-a952025dcacc', 'd0f8f9d6-7c3f-54ec-b57e-baf11890caaf', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('be3d282d-e01b-531b-a81d-68dda2b70eec', 'd0f8f9d6-7c3f-54ec-b57e-baf11890caaf', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('016fdfea-cd4e-5c5c-bb16-b820bae75fbb', 'd0f8f9d6-7c3f-54ec-b57e-baf11890caaf', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('add127f4-20b5-5417-8fd7-9d59ec383330', 'd0f8f9d6-7c3f-54ec-b57e-baf11890caaf', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bcfb6d03-1ab4-5d94-91c3-e85c43e9713e', 'd0f8f9d6-7c3f-54ec-b57e-baf11890caaf', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8b83971d-92c7-57e8-a021-04799802862a', 'd0f8f9d6-7c3f-54ec-b57e-baf11890caaf', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('24ce2064-1272-5907-8103-cf25e5ad34a3', 'd0f8f9d6-7c3f-54ec-b57e-baf11890caaf', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('41919fc0-cc11-54e9-bb59-67f93bc6403e', 'd0f8f9d6-7c3f-54ec-b57e-baf11890caaf', 9, $md$ix$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('43163ed7-d9d8-5f18-9286-20d93219a66e', 'd0f8f9d6-7c3f-54ec-b57e-baf11890caaf', 10, $md$x$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('661d339a-714c-5805-998f-273c71fad824', '1fd6a2e0-a904-527c-9926-7a4f5fd9000f', 6, 'MATCHING_HEADING', 'READING', 3, $md$### Question 6

Question 1-6
Question 1-6
Choose the most suitable headings for paragraphs B-G from the list of headings below.
Write appropriate numbers
(i-x)
in boxes
1 -6
on your answer sheet.
NB There are more headings than paragraphs, so you will not use them all.
List of Headings
Sea turtles are found in unusual locations
Unique features of the Leatherbacks
The Leatherback’s contribution
Methods used for routes tracking
Predict the migration routes
Remains multiplicity within the species
The progress of hatching
The fate of the lost turles
How trips suppose to look like?
Factors leading to population decline
1
Paragraph B
2
Paragraph C
3
Paragraph D
4
Paragraph E
5
Paragraph F
6
Paragraph G

6 ____ Paragraph G$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d72f0371-1f5c-5618-b43a-eaae6257b359', '661d339a-714c-5805-998f-273c71fad824', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('46f305d7-0747-56d2-8aa7-3a032994347b', '661d339a-714c-5805-998f-273c71fad824', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c0b34a68-77b4-5a99-8110-8702e37cbd1b', '661d339a-714c-5805-998f-273c71fad824', 3, $md$iii$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('71b7ffa6-2330-5f2f-ae34-308ed17d28b6', '661d339a-714c-5805-998f-273c71fad824', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('49c71935-fac0-54cf-a818-caf7398a5ce9', '661d339a-714c-5805-998f-273c71fad824', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2a399bd9-ca3b-5979-bee7-9d995b4d9f10', '661d339a-714c-5805-998f-273c71fad824', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3467963b-dba0-5a38-9841-c4378ca2a542', '661d339a-714c-5805-998f-273c71fad824', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c09ba322-a1c2-51d2-b93d-17d0f0ac619c', '661d339a-714c-5805-998f-273c71fad824', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3390bcee-a8ee-52e4-adf2-dca797dcfaab', '661d339a-714c-5805-998f-273c71fad824', 9, $md$ix$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2c69ce79-086c-5516-817f-0e4feeb415b8', '661d339a-714c-5805-998f-273c71fad824', 10, $md$x$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('65a19b01-35b2-5202-9fdb-54f185e6ad42', '1fd6a2e0-a904-527c-9926-7a4f5fd9000f', 7, 'SHORT_ANSWER', 'READING', 3, $md$### Question 7

Question 7 -13
Question 7 -13
Choose words from the passage to answer the questions 7-13.
Write
NO MORE THAN THREE WORDS
for each answer.
7
How many Leatherback turtles are there in the world?
8
What is the most noticeable difference between other sea turtles and leatherbacks?
9
What candle therback turtles to die in Irish waters?
10
Where did the four turtles probably come from?
11
By which means can sea turtles retrace their migratory paths?
12
For what purpose are Green Sea turtles killed by people?
13
What kind of species will benefits from a decline in Leatherback populations?

7 ____ How many Leatherback turtles are there in the world?$md$, NULL, ARRAY['.*35.*000.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('c354bbb0-00e4-50c6-8eef-1693363be507', '1fd6a2e0-a904-527c-9926-7a4f5fd9000f', 8, 'SHORT_ANSWER', 'READING', 3, $md$### Question 8

Question 7 -13
Question 7 -13
Choose words from the passage to answer the questions 7-13.
Write
NO MORE THAN THREE WORDS
for each answer.
7
How many Leatherback turtles are there in the world?
8
What is the most noticeable difference between other sea turtles and leatherbacks?
9
What candle therback turtles to die in Irish waters?
10
Where did the four turtles probably come from?
11
By which means can sea turtles retrace their migratory paths?
12
For what purpose are Green Sea turtles killed by people?
13
What kind of species will benefits from a decline in Leatherback populations?

8 ____ What is the most noticeable difference between other sea turtles and leatherbacks?$md$, NULL, ARRAY['.*the.*bony.*carapace.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('d4a8d47d-b930-5218-812f-e469609e6bef', '1fd6a2e0-a904-527c-9926-7a4f5fd9000f', 9, 'SHORT_ANSWER', 'READING', 3, $md$### Question 9

Question 7 -13
Question 7 -13
Choose words from the passage to answer the questions 7-13.
Write
NO MORE THAN THREE WORDS
for each answer.
7
How many Leatherback turtles are there in the world?
8
What is the most noticeable difference between other sea turtles and leatherbacks?
9
What candle therback turtles to die in Irish waters?
10
Where did the four turtles probably come from?
11
By which means can sea turtles retrace their migratory paths?
12
For what purpose are Green Sea turtles killed by people?
13
What kind of species will benefits from a decline in Leatherback populations?

9 ____ What candle therback turtles to die in Irish waters?$md$, NULL, ARRAY['.*cold.*waters.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('6af49669-1658-5140-b7bb-e20d371a2d63', '1fd6a2e0-a904-527c-9926-7a4f5fd9000f', 10, 'SHORT_ANSWER', 'READING', 4, $md$### Question 10

Question 7 -13
Question 7 -13
Choose words from the passage to answer the questions 7-13.
Write
NO MORE THAN THREE WORDS
for each answer.
7
How many Leatherback turtles are there in the world?
8
What is the most noticeable difference between other sea turtles and leatherbacks?
9
What candle therback turtles to die in Irish waters?
10
Where did the four turtles probably come from?
11
By which means can sea turtles retrace their migratory paths?
12
For what purpose are Green Sea turtles killed by people?
13
What kind of species will benefits from a decline in Leatherback populations?

10 ____ Where did the four turtles probably come from?$md$, NULL, ARRAY['.*florida.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('dfb2c5e0-6ef1-52bc-803f-9231cf412b30', '1fd6a2e0-a904-527c-9926-7a4f5fd9000f', 11, 'SHORT_ANSWER', 'READING', 4, $md$### Question 11

Question 7 -13
Question 7 -13
Choose words from the passage to answer the questions 7-13.
Write
NO MORE THAN THREE WORDS
for each answer.
7
How many Leatherback turtles are there in the world?
8
What is the most noticeable difference between other sea turtles and leatherbacks?
9
What candle therback turtles to die in Irish waters?
10
Where did the four turtles probably come from?
11
By which means can sea turtles retrace their migratory paths?
12
For what purpose are Green Sea turtles killed by people?
13
What kind of species will benefits from a decline in Leatherback populations?

11 ____ By which means can sea turtles retrace their migratory paths?$md$, NULL, ARRAY['.*magnetic.*fields.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('53333a76-2256-5a12-8968-b7997ab97670', '1fd6a2e0-a904-527c-9926-7a4f5fd9000f', 12, 'SHORT_ANSWER', 'READING', 4, $md$### Question 12

Question 7 -13
Question 7 -13
Choose words from the passage to answer the questions 7-13.
Write
NO MORE THAN THREE WORDS
for each answer.
7
How many Leatherback turtles are there in the world?
8
What is the most noticeable difference between other sea turtles and leatherbacks?
9
What candle therback turtles to die in Irish waters?
10
Where did the four turtles probably come from?
11
By which means can sea turtles retrace their migratory paths?
12
For what purpose are Green Sea turtles killed by people?
13
What kind of species will benefits from a decline in Leatherback populations?

12 ____ For what purpose are Green Sea turtles killed by people?$md$, NULL, ARRAY['.*its.*meat.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('9f39f187-84f5-527f-98b1-744168ca1163', '1fd6a2e0-a904-527c-9926-7a4f5fd9000f', 13, 'SHORT_ANSWER', 'READING', 4, $md$### Question 13

Question 7 -13
Question 7 -13
Choose words from the passage to answer the questions 7-13.
Write
NO MORE THAN THREE WORDS
for each answer.
7
How many Leatherback turtles are there in the world?
8
What is the most noticeable difference between other sea turtles and leatherbacks?
9
What candle therback turtles to die in Irish waters?
10
Where did the four turtles probably come from?
11
By which means can sea turtles retrace their migratory paths?
12
For what purpose are Green Sea turtles killed by people?
13
What kind of species will benefits from a decline in Leatherback populations?

13 ____ What kind of species will benefits from a decline in Leatherback populations?$md$, NULL, ARRAY['.*jellyfish.*']);

COMMIT;
