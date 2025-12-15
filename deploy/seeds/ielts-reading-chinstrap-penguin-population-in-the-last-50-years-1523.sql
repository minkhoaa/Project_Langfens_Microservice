BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-chinstrap-penguin-population-in-the-last-50-years-1523'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-chinstrap-penguin-population-in-the-last-50-years-1523';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-chinstrap-penguin-population-in-the-last-50-years-1523';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-chinstrap-penguin-population-in-the-last-50-years-1523';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('bf56e6f4-8603-5554-9b74-76d00e1bb158', 'ielts-reading-chinstrap-penguin-population-in-the-last-50-years-1523', $t$Chinstrap Penguin Population In The Last 50 Years$t$, $md$## Chinstrap Penguin Population In The Last 50 Years

Nguồn:
- Test: https://mini-ielts.com/1523/reading/chinstrap-penguin-population-in-the-last-50-years
- Solution: https://mini-ielts.com/1523/view-solution/reading/chinstrap-penguin-population-in-the-last-50-years$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('cffbfc1a-6f36-540d-9cfd-ee11984464a1', 'bf56e6f4-8603-5554-9b74-76d00e1bb158', 1, $t$Reading — Chinstrap Penguin Population In The Last 50 Years$t$, $md$Read the passage and answer questions **1–13**.

### Passage: Chinstrap Penguin Population In The Last 50 Years

| | Chinstrap Penguin Population In The Last 50 Years The chinstrap penguin has a cap of black plumage, a white face, and a continuous band of black feathers extending from one side of the head to the other, the “chinstrap.” The northern part of the Antarctic Peninsula, several Antarctic and subantarctic islands, and the uninhabited Balleny Islands between Antarctica and New Zealand are the habitats of the species. Antarctic penguin colonies in some parts of the Antarctic have declined over the last 50 years, mostly because of climate change, researchers say. The colonies of chinstrap penguins, also known as ringed or bearded penguins, have dramatically dropped since they were last surveyed almost 50 years ago, scientists discovered. The findings became surprising because, until now, the chinstraps have been deemed of “least concern” by the International Union for Conservation of Nature (IUCN). “We really didn’t know what to expect, and then we found this huge decline on Elephant Island,” Noah Strycker, an ornithologist and penguin researcher at Stony Brook University, told CNN from Greenpeace’s Esperanza ship in the Antarctic. “It’s a little bit worrying as it means that something is shifting in the ecosystem and the fall in penguin numbers is reflecting that shift.” Every colony of Elephant Island, which is a crucial penguin habitat northeast of the Antarctic Peninsula, when surveyed, experienced a population fall, as per the independent researchers who joined a Greenpeace expedition to the region. Elephant Island was last surveyed in 1971, and there were 122,550 pairs of penguins across all colonies. However, the recent count revealed just 52,786 pairs with a drop of almost 60%. On Elephant Island, the size of the population change varied from colony to colony, and the most significant decline was recorded at a colony known as Chinstrap Camp, which is 77%. Just the days after temperatures hit an all-time high in the Antarctic with 18.3 Celsius (64.94 Fahrenheit) recorded on February 6, the latest study is published. The previous high 17.5 C (63.5 F) was recorded in March 2015. Scientists recorded the temperature at Argentina’s Esperanza research station, according to the meteorological agency of the country. The reduced sea ice and warmer oceans due to climate change have led to less krill, the main component of the penguins’ diet. “Climate change is probably the underlying factor, and the effects are rippling through the food chain,” Strycker said. “Penguins, seals, and whales all depend on krill, which depends on ice. So if climate change affects the ice, that impacts on everything else.” Heather J. Lynch, associate professor of ecology and evolution at New York’s Stony Brook University and one of the expedition’s research leads, said: “Such significant declines in penguin numbers suggest that the Southern Ocean’s ecosystem has fundamentally changed in the last 50 years and that the impacts of this are rippling up the food web to species like chinstrap penguins.” She added that “while several factors may have a role to play, all the evidence we have pointed to climate change as being responsible for the changes we are seeing.” However, some good news was also there, as the researchers reported an increase in gentoo penguins population in neighbouring colonies, beyond Elephant Island. “It’s interesting, as a tale of two penguins on the Antarctic Peninsula,” said Strycker. “Gentoo is a species from further north and they appear to be colonizing the area and are actually increasing in numbers.” The Greenpeace ship Esperanza has been documenting the threat to the oceans worldwide and taking the scientists for travelling abroad. For the first time, the Low Island in the South Shetland Islands, north of the Antarctic Peninsula, has been surveyed properly. The manual and drone techniques are used by the researchers, from Stony Brook and Northeastern University in Boston, to survey a series of significant but relatively unknown colonies of chinstrap penguin here. The results are, however, not yet available. Greenpeace has been campaigning for the three Antarctic sanctuaries that it would establish to offer protection to many of the colonies surveyed. These would be off-limits to humans. Louisa Casson, Greenpeace Oceans Campaigner, said in a statement: “Penguins are an iconic species, but this new research shows how the climate emergency is decimating their numbers and having far-reaching impacts on wildlife in the most remote corners of Earth. This is a critical year for our oceans. “Governments must respond to the science and agree on a strong Global Ocean Treaty at the United Nations this spring that can create a network of ocean sanctuaries to protect marine life and help these creatures adapt to our rapidly changing climate.”$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('fcb30b95-a7c0-542d-b6f8-083b443d5326', 'cffbfc1a-6f36-540d-9cfd-ee11984464a1', 1, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 1

Question 1 - 7
Question 1 - 7
The Reading Passage has 8 paragraphs labelled A-H.
Which paragraph contains the following information?
Write the correct letter A-H in boxes.
NB You may use any letter more than once.
1
the highest temperatures ever.
2
the difference between current and past records on penguin population.
3
places where people cannot go to.
4
places where chinstrap penguins live.
5
measures to protect ocean species.
6
factors contributing to the decline in the amount of food available.
7
description of a specific species.

1 ____ the highest temperatures ever.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('985bda5c-a5b4-50b0-9f71-5151bab735e4', 'fcb30b95-a7c0-542d-b6f8-083b443d5326', 1, $md$: A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('eae9b681-2910-54c0-85f1-73d60631e093', 'fcb30b95-a7c0-542d-b6f8-083b443d5326', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a6ad26da-9854-5d5a-b06f-0a9030131a75', 'fcb30b95-a7c0-542d-b6f8-083b443d5326', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('294e2a7c-73b5-563c-9169-539c49cfc855', 'fcb30b95-a7c0-542d-b6f8-083b443d5326', 4, $md$D$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b7a0dff5-4f53-565f-be30-d8091f6b4595', 'fcb30b95-a7c0-542d-b6f8-083b443d5326', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ee11c563-7120-5cc9-96ee-03d0a3ed408a', 'fcb30b95-a7c0-542d-b6f8-083b443d5326', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('827442ca-e84a-5f96-96e1-17fdfd0126c9', 'fcb30b95-a7c0-542d-b6f8-083b443d5326', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f842452c-3a58-5ff4-a29e-ab1aade6c5c6', 'fcb30b95-a7c0-542d-b6f8-083b443d5326', 8, $md$H$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('05e2998f-35c5-576a-95d6-fb566f74aece', 'cffbfc1a-6f36-540d-9cfd-ee11984464a1', 2, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 2

Question 1 - 7
Question 1 - 7
The Reading Passage has 8 paragraphs labelled A-H.
Which paragraph contains the following information?
Write the correct letter A-H in boxes.
NB You may use any letter more than once.
1
the highest temperatures ever.
2
the difference between current and past records on penguin population.
3
places where people cannot go to.
4
places where chinstrap penguins live.
5
measures to protect ocean species.
6
factors contributing to the decline in the amount of food available.
7
description of a specific species.

2 ____ the difference between current and past records on penguin population.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('20b8b337-690e-5e9f-9364-8354f9049ad4', '05e2998f-35c5-576a-95d6-fb566f74aece', 1, $md$: A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ec8f9279-2ef9-5c07-9846-4c56cb8a903b', '05e2998f-35c5-576a-95d6-fb566f74aece', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8ead4c5c-a51c-5934-9749-af78156dd2cd', '05e2998f-35c5-576a-95d6-fb566f74aece', 3, $md$C$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('98d7cbd8-b804-51b4-8605-de8fd8633f62', '05e2998f-35c5-576a-95d6-fb566f74aece', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cc43fdd3-86a2-5374-8ae4-67523a20e157', '05e2998f-35c5-576a-95d6-fb566f74aece', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d853f018-e929-5f01-a071-7dc65456126e', '05e2998f-35c5-576a-95d6-fb566f74aece', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('06e8518d-dcca-5025-b84a-6161f46f5109', '05e2998f-35c5-576a-95d6-fb566f74aece', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fcbf4d22-5780-58b1-84ff-2c6984c216f8', '05e2998f-35c5-576a-95d6-fb566f74aece', 8, $md$H$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('8e5745c0-239a-53dd-a457-ab292c9db08b', 'cffbfc1a-6f36-540d-9cfd-ee11984464a1', 3, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 3

Question 1 - 7
Question 1 - 7
The Reading Passage has 8 paragraphs labelled A-H.
Which paragraph contains the following information?
Write the correct letter A-H in boxes.
NB You may use any letter more than once.
1
the highest temperatures ever.
2
the difference between current and past records on penguin population.
3
places where people cannot go to.
4
places where chinstrap penguins live.
5
measures to protect ocean species.
6
factors contributing to the decline in the amount of food available.
7
description of a specific species.

3 ____ places where people cannot go to.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('470f1fcc-d9f5-54ac-a852-9047a6f84e55', '8e5745c0-239a-53dd-a457-ab292c9db08b', 1, $md$: A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c02ff790-b542-5a1b-a220-13cf3c979ca5', '8e5745c0-239a-53dd-a457-ab292c9db08b', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('48b89efc-4fa9-579f-b2ef-de57eaa573f2', '8e5745c0-239a-53dd-a457-ab292c9db08b', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('726675a5-add1-52f5-b0f2-2f462011562f', '8e5745c0-239a-53dd-a457-ab292c9db08b', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('209dec3e-4783-59d0-aaf8-d556152311e6', '8e5745c0-239a-53dd-a457-ab292c9db08b', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a99bfd59-9833-5358-9e69-e6583e48b2c7', '8e5745c0-239a-53dd-a457-ab292c9db08b', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8d24c4fa-f066-51fc-97f1-841cd4bc823e', '8e5745c0-239a-53dd-a457-ab292c9db08b', 7, $md$G$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b8620b81-0ab0-5f48-95cf-758472b51388', '8e5745c0-239a-53dd-a457-ab292c9db08b', 8, $md$H$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('69769f83-e832-5f5f-9a7e-99a6b9ede9d9', 'cffbfc1a-6f36-540d-9cfd-ee11984464a1', 4, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 4

Question 1 - 7
Question 1 - 7
The Reading Passage has 8 paragraphs labelled A-H.
Which paragraph contains the following information?
Write the correct letter A-H in boxes.
NB You may use any letter more than once.
1
the highest temperatures ever.
2
the difference between current and past records on penguin population.
3
places where people cannot go to.
4
places where chinstrap penguins live.
5
measures to protect ocean species.
6
factors contributing to the decline in the amount of food available.
7
description of a specific species.

4 ____ places where chinstrap penguins live.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9ba1c2ac-074e-5638-950f-781078b44711', '69769f83-e832-5f5f-9a7e-99a6b9ede9d9', 1, $md$: A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('623a0eb9-5fd9-53ea-9300-affcbf8f08e8', '69769f83-e832-5f5f-9a7e-99a6b9ede9d9', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b94b8457-0679-521f-8d17-b42675df782a', '69769f83-e832-5f5f-9a7e-99a6b9ede9d9', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8fbc393c-ad52-52c4-8a62-63a8fd3ca73f', '69769f83-e832-5f5f-9a7e-99a6b9ede9d9', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5ba5ae44-5e27-5aff-ad41-f42e20f2c135', '69769f83-e832-5f5f-9a7e-99a6b9ede9d9', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ce07b2b8-4206-5c1f-ab31-8fa2040ae5f3', '69769f83-e832-5f5f-9a7e-99a6b9ede9d9', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d2c64bb5-e593-5ff0-8ea5-cac24a1701b9', '69769f83-e832-5f5f-9a7e-99a6b9ede9d9', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a2086099-758e-5650-8099-562db1f5323b', '69769f83-e832-5f5f-9a7e-99a6b9ede9d9', 8, $md$H$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('f29b5d41-3765-5f82-9486-0967f52cf8bf', 'cffbfc1a-6f36-540d-9cfd-ee11984464a1', 5, 'MATCHING_INFORMATION', 'READING', 3, $md$### Question 5

Question 1 - 7
Question 1 - 7
The Reading Passage has 8 paragraphs labelled A-H.
Which paragraph contains the following information?
Write the correct letter A-H in boxes.
NB You may use any letter more than once.
1
the highest temperatures ever.
2
the difference between current and past records on penguin population.
3
places where people cannot go to.
4
places where chinstrap penguins live.
5
measures to protect ocean species.
6
factors contributing to the decline in the amount of food available.
7
description of a specific species.

5 ____ measures to protect ocean species.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b747dee9-3ab3-5500-b09f-2aed3d15d7c7', 'f29b5d41-3765-5f82-9486-0967f52cf8bf', 1, $md$: A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a6a454b8-d27c-51b2-90f5-2baf795c7ae5', 'f29b5d41-3765-5f82-9486-0967f52cf8bf', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8a795421-fbdd-5422-ae0b-4aca6543e0c0', 'f29b5d41-3765-5f82-9486-0967f52cf8bf', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('dc2be50d-bfb2-565d-898f-a6e062dfa149', 'f29b5d41-3765-5f82-9486-0967f52cf8bf', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('aaa2f9b0-1571-5ce6-aba8-7e111e2ad3a4', 'f29b5d41-3765-5f82-9486-0967f52cf8bf', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('62b15201-6a5f-5201-8ee8-ce1b0109ae53', 'f29b5d41-3765-5f82-9486-0967f52cf8bf', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3062a77e-42f1-5983-88ed-8187e0821ddf', 'f29b5d41-3765-5f82-9486-0967f52cf8bf', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ddc205a6-844b-5b78-8df2-e1201c9a1bff', 'f29b5d41-3765-5f82-9486-0967f52cf8bf', 8, $md$H$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('5b2b1c98-e261-5b94-bc35-f42397decf8b', 'cffbfc1a-6f36-540d-9cfd-ee11984464a1', 6, 'MATCHING_INFORMATION', 'READING', 3, $md$### Question 6

Question 1 - 7
Question 1 - 7
The Reading Passage has 8 paragraphs labelled A-H.
Which paragraph contains the following information?
Write the correct letter A-H in boxes.
NB You may use any letter more than once.
1
the highest temperatures ever.
2
the difference between current and past records on penguin population.
3
places where people cannot go to.
4
places where chinstrap penguins live.
5
measures to protect ocean species.
6
factors contributing to the decline in the amount of food available.
7
description of a specific species.

6 ____ factors contributing to the decline in the amount of food available.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fe8f1bfe-ac18-5f1f-baaa-4f62e205f07e', '5b2b1c98-e261-5b94-bc35-f42397decf8b', 1, $md$: A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('44aada62-1492-5e6c-8ae0-acb76c088911', '5b2b1c98-e261-5b94-bc35-f42397decf8b', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6e018ebb-0c78-5a63-b8a5-a7d2c8e5f143', '5b2b1c98-e261-5b94-bc35-f42397decf8b', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6c5938cc-fc85-53e1-9c21-425278059aec', '5b2b1c98-e261-5b94-bc35-f42397decf8b', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('055c09bb-b806-5cf5-add1-53183175e3d4', '5b2b1c98-e261-5b94-bc35-f42397decf8b', 5, $md$E$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('71586eda-b48c-5d75-8848-76761bbd0c44', '5b2b1c98-e261-5b94-bc35-f42397decf8b', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('459c7980-5d23-5fbf-b56c-1bbe8cb10128', '5b2b1c98-e261-5b94-bc35-f42397decf8b', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('db882e55-b7da-5fd1-bc1d-8a132c5bca9a', '5b2b1c98-e261-5b94-bc35-f42397decf8b', 8, $md$H$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('6b121dcc-8807-508a-9569-a85edccdc2ab', 'cffbfc1a-6f36-540d-9cfd-ee11984464a1', 7, 'MATCHING_INFORMATION', 'READING', 3, $md$### Question 7

Question 1 - 7
Question 1 - 7
The Reading Passage has 8 paragraphs labelled A-H.
Which paragraph contains the following information?
Write the correct letter A-H in boxes.
NB You may use any letter more than once.
1
the highest temperatures ever.
2
the difference between current and past records on penguin population.
3
places where people cannot go to.
4
places where chinstrap penguins live.
5
measures to protect ocean species.
6
factors contributing to the decline in the amount of food available.
7
description of a specific species.

7 ____ description of a specific species.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('aa495ac4-e929-55b8-b34f-cba49feaec59', '6b121dcc-8807-508a-9569-a85edccdc2ab', 1, $md$: A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ad0c2133-852f-5735-9bad-d19aa9690511', '6b121dcc-8807-508a-9569-a85edccdc2ab', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('77b0c7da-bba2-5fdb-a973-951da03859a7', '6b121dcc-8807-508a-9569-a85edccdc2ab', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8cffb553-97d8-5243-967f-a29f61685c9b', '6b121dcc-8807-508a-9569-a85edccdc2ab', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1f14e6f4-5b2c-59de-816e-f813ac06ce91', '6b121dcc-8807-508a-9569-a85edccdc2ab', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9438b0b1-d4b9-5efb-b0e9-7ee72fb500c0', '6b121dcc-8807-508a-9569-a85edccdc2ab', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a1a44646-dbc0-5b95-aa51-da72819ca5e5', '6b121dcc-8807-508a-9569-a85edccdc2ab', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7926a80c-da81-5e7d-b1ec-86e6cba898e0', '6b121dcc-8807-508a-9569-a85edccdc2ab', 8, $md$H$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('4889fcdd-d863-5f02-952d-2d77a65ccd15', 'cffbfc1a-6f36-540d-9cfd-ee11984464a1', 8, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 8

Question 8-10
Question 8-10
Choose TRUE if the statement agrees with the information given in the text,
choose FALSE if the statement contradicts the information,
or choose NOT GIVEN if there is no information on this.
8
The IUCN showed little concern about the fall in penguin numbers.
9
Climate change is a reason for the changes in the food chain of chinstrap penguins.
10
Gentoo penguins are not affected by climate change.

8 ____ The IUCN showed little concern about the fall in penguin numbers.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bf0d049c-efac-5971-9de8-465454383cd9', '4889fcdd-d863-5f02-952d-2d77a65ccd15', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f76a4240-1437-5267-b3e7-34a1a3176c67', '4889fcdd-d863-5f02-952d-2d77a65ccd15', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a3dad228-c1a9-57d2-a162-ca5197521419', '4889fcdd-d863-5f02-952d-2d77a65ccd15', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('0f0b8f0f-b42f-5e33-b2dd-7b5ba0a78a17', 'cffbfc1a-6f36-540d-9cfd-ee11984464a1', 9, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 9

Question 8-10
Question 8-10
Choose TRUE if the statement agrees with the information given in the text,
choose FALSE if the statement contradicts the information,
or choose NOT GIVEN if there is no information on this.
8
The IUCN showed little concern about the fall in penguin numbers.
9
Climate change is a reason for the changes in the food chain of chinstrap penguins.
10
Gentoo penguins are not affected by climate change.

9 ____ Climate change is a reason for the changes in the food chain of chinstrap penguins.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d6ea49af-d75a-5035-8a62-8ad5f78b730f', '0f0b8f0f-b42f-5e33-b2dd-7b5ba0a78a17', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('67ce9222-8f7e-5857-a119-1f8ffe8acd43', '0f0b8f0f-b42f-5e33-b2dd-7b5ba0a78a17', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9c1e4fdb-38ec-5eaf-80c5-693c87fa4f7f', '0f0b8f0f-b42f-5e33-b2dd-7b5ba0a78a17', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('fcab2954-ad6a-59a6-84be-966d54b6c7bf', 'cffbfc1a-6f36-540d-9cfd-ee11984464a1', 10, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 10

Question 8-10
Question 8-10
Choose TRUE if the statement agrees with the information given in the text,
choose FALSE if the statement contradicts the information,
or choose NOT GIVEN if there is no information on this.
8
The IUCN showed little concern about the fall in penguin numbers.
9
Climate change is a reason for the changes in the food chain of chinstrap penguins.
10
Gentoo penguins are not affected by climate change.

10 ____ Gentoo penguins are not affected by climate change.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bb8f4b13-3953-596f-a89b-65530904f6c1', 'fcab2954-ad6a-59a6-84be-966d54b6c7bf', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('af1f7c9f-e214-51cd-9ee4-e1bef051ac17', 'fcab2954-ad6a-59a6-84be-966d54b6c7bf', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ad3804df-ff84-5bf2-9bd3-91a5113a18d3', 'fcab2954-ad6a-59a6-84be-966d54b6c7bf', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('a004d1c9-358b-5df7-aa58-3cc8fb49cc88', 'cffbfc1a-6f36-540d-9cfd-ee11984464a1', 11, 'NOTE_COMPLETION', 'READING', 4, $md$### Question 11

Question 11 - 13
Question 11 - 13
Complete the note below.
Choose
ONLY ONE WORD
from the passage for each answer.
The Greenpeace ship has been used to:
record the
11
to marine life over the world.
carry the
12
overseas.
Build
13
to protect many surveyed colonies.

record the 11 ____ to marine life over the world.$md$, NULL, ARRAY['.*threat.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('1edf9d9b-987e-5ac5-8903-3ee4f39dac65', 'cffbfc1a-6f36-540d-9cfd-ee11984464a1', 12, 'NOTE_COMPLETION', 'READING', 4, $md$### Question 12

Question 11 - 13
Question 11 - 13
Complete the note below.
Choose
ONLY ONE WORD
from the passage for each answer.
The Greenpeace ship has been used to:
record the
11
to marine life over the world.
carry the
12
overseas.
Build
13
to protect many surveyed colonies.

carry the 12 ____ overseas.$md$, NULL, ARRAY['.*scientists.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('79dfc003-e66f-5346-a29a-55516068f5a0', 'cffbfc1a-6f36-540d-9cfd-ee11984464a1', 13, 'NOTE_COMPLETION', 'READING', 4, $md$### Question 13

Question 11 - 13
Question 11 - 13
Complete the note below.
Choose
ONLY ONE WORD
from the passage for each answer.
The Greenpeace ship has been used to:
record the
11
to marine life over the world.
carry the
12
overseas.
Build
13
to protect many surveyed colonies.

Build 13 ____ to protect many surveyed colonies.$md$, NULL, ARRAY['.*sanctuaries.*']);

COMMIT;
