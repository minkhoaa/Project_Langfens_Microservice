BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-the-dugong-sea-cow-1405'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-the-dugong-sea-cow-1405';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-the-dugong-sea-cow-1405';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-the-dugong-sea-cow-1405';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('4d135d0b-96e2-5783-ad4e-e032dadae9cc', 'ielts-reading-the-dugong-sea-cow-1405', $t$The dugong: sea cow$t$, $md$## The dugong: sea cow

Nguồn:
- Test: https://mini-ielts.com/1405/reading/the-dugong-sea-cow
- Solution: https://mini-ielts.com/1405/view-solution/reading/the-dugong-sea-cow$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('7848c0d1-634d-5f61-9686-8d45b6553e0b', '4d135d0b-96e2-5783-ad4e-e032dadae9cc', 1, $t$Reading — The dugong: sea cow$t$, $md$Read the passage and answer questions **1–13**.

### Passage: The dugong: sea cow

Dugongs are herbivorous mammals that spend their entire lives in the sea. Their close relatives the manatees also venture into or live in freshwater. Together dugongs and manatees make up the order Sirenia or sea cows, so-named because dugongs and manatees are thought to have given rise to the myth of the mermaids or sirens of the sea.

A

The dugong, which is a large marine mammal which, together with the manatees, looks rather like a cross between a rotund dolphin and a walrus. Its body, flippers and fluke resemble those of a dolphin but it has no dorsal fin. Its head looks somewhat like that of a walrus without the long tusks.

B

Dugongs, along with other Sirenians whose diet consists mainly of sea-grass; and the distribution of dugongs very closely follows that of these marine flowering plants. As seagrasses grow rooted in the sediment, they are limited by the availability of light. Consequently they are found predominantly in shallow coastal waters, and so too are dugongs. But, this is not the whole story. Dugongs do not eat all species of seagrass, preferring seagrass of higher nitrogen and lower fibre content.

C

Due to their poor eyesight, dugongs often use smell to locate edible plants. They also have a strong tactile sense, and feel their surroundings with their long sensitive bristles. They will dig up an entire plant and then shake it to remove the sand before eating it. They have been known to collect a pile of plants in one area before eating them. The flexible and muscular upper lip is used to dig out the plants. When eating they ingest the whole plant, including the roots, although when this is impossible they will feed on just the leaves. A wide variety of seagrass has been found in dugong stomach contents, and evidence exists they will eat algae when seagrass is scarce. Although almost completely herbivorous, they will occasionally eat invertebrates such as jellyfish, sea squirts, and shellfish.

D

A heavily grazed seagrass bed looks like a lawn mown by a drunk. Dugongs graze apparently at random within a seagrass bed, their trails meandering in all directions across the bottom. This is rather an inefficient means of removing seagrass that results in numerous small tufts remaining. And this is where the dugongs derive some advantage from their inefficiency. The species that recover most quickly from this disturbance, spreading out vegetatively from the remaining tufts, are those that dugongs like to eat. In addition, the new growth found in these areas tends to be exactly what hungry dugongs like.

E

Dugongs are semi-nomadic, often travelling long distances in search of food, but staying within a certain range their entire life. Large numbers often move together from one area to another. It is thought that these movements are caused by changes in seagrass availability. Their memory allows them to return to specific points after long travels. Dugong movements mostly occur within a localised area of seagrass beds, and animals in the same region show individualistic patterns of movement.

F

Recorded numbers of dugongs are generally believed to be lower than actual numbers, due to a lack of accurate surveys. Despite this, the dugong population is thought to be shrinking, with a worldwide decline of 20 per cent in the last 90 years. They have disappeared from the waters of Hong Kong, Mauritius, and Taiwan, as well as parts of Cambodia, Japan, the Philippines and Vietnam. Further disappearances are likely. (In the late 1960s, herds of up to 500 dugongs were observed off the coast of East Africa and nearby islands. However, current populations in this area are extremely small, numbering 50 and below, and it is thought likely they will become extinct. The eastern side of the Red Sea is the home of large populations numbering in the hundreds, and similar populations are thought to exist on the western side. In the 1980s, it was estimated there could be as many as 4,000 dugongs in the Red Sea. The Persian Gulf has the second-largest dugong population in the world, inhabiting most of the southern coast, and the current population is believed to be around 7,500. Australia is home to the largest population, stretching from Shark Bay in Western Australia to Moreton Bay in Queensland. The population of Shark Bay is thought to be stable with over 10,000 dugongs.)

G

Experience from various parts of northern Australia suggests that Extreme weather such as cyclones and floods can destroy hundreds of square kilometres of seagrass meadows, as well as washing dugongs ashore. The recovery of seagrass meadows and the spread of seagrass into new areas, or areas where it has been destroyed, can take over a decade. For example, about 900 km2 of seagrass was lost in Hervey Bay in 1992, probably because of murky water from flooding of local rivers, and run-off turbulence from a cyclone three weeks later. Such events can cause extensive damage to seagrass communities through severe wave action, shifting sand and reduction in saltiness and light levels. Prior to the 1992 floods, the extensive seagrasses in Hervey Bay supported an estimated 1750 dugongs. Eight months after the floods the affected area was estimated to support only about 70 dugongs. Most animals presumably survived by moving to neighbouring areas. However, many died attempting to move to greener pastures, with emaciated carcasses washing up on beaches up to 900km away.

H

If dugongs do not get enough to eat they may calve later and produce fewer young. Food shortages can be caused by many factors, such as a loss of habitat, death and decline in quality of seagrass, and a disturbance of feeding caused by human activity. Sewage, detergents, heavy metal, hypersaline water, herbicides, and other waste products all negatively affect seagrass meadows. Human activity such as mining, trawling, dredging, land-reclamation, and boat propeller scarring also cause an increase in sedimentation which smothers seagrass and prevents light from reaching it. This is the most significant negative factor affecting seagrass. One of the dugong’s preferred species of seagrass, Halophila ovalis, declines rapidly due to lack of light, dying completely after 30 days.

I

Despite being legally protected in many countries, the main causes of population decline remain anthropogenic and include hunting, habitat degradation, and fishing-related fatalities. Entanglement in fishing nets has caused many deaths, although there are no precise statistics. Most issues with industrial fishing occur in deeper waters where dugong populations are low, with local fishing being the main risk in shallower waters. As dugongs cannot stay As dugongs cannot stay underwater for a very long period, they are highly prone to deaths due to entanglement. The use of shark nets has historically caused large numbers of deaths, and they have been eliminated in most areas and replaced with baited hooks. Hunting has historically been a problem too, although in most areas they are no longer hunted, with the exception of certain indigenous communities. In areas such as northern Australia, hunting remains the greatest impact on the dugong population$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('7cf86b29-350a-584d-9d3a-7b44bbf277e0', '7848c0d1-634d-5f61-9686-8d45b6553e0b', 1, 'SUMMARY_COMPLETION', 'READING', 2, $md$### Question 1

Questions 1-4
Questions 1-4
Summary
Complete the following summary of the paragraphs of Reading Passage, using
NO MORE THAN TWO WORDS
from the Reading Passage for each answer.
Write your answers in boxes
1-4
on your answer sheet.
Dugongs are herbivorous mammals that spend their entire lives in the sea. Yet Dugongs are picky on their feeding Seagrass, and only chose seagrass with higher
1
and lower fibre. To compensate for their poor eyesight, they use their
2
to feel their surroundings.
It is like Dugongs are “farming” seagrass. They often leave
3
randomly in all directions across the sea bed. Dugongs prefer eating the newly grew seagrass recovering from the tiny
4
left behind by the grazing dugongs.

Dugongs are herbivorous mammals that spend their entire lives in the sea. Yet Dugongs are picky on their feeding Seagrass, and only chose seagrass with higher 1 ____ and lower fibre. To compensate for their poor eyesight, they use their 2 ____ to feel their surroundings.$md$, NULL, ARRAY['.*nitrogen.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('c3ee8bcd-6276-53b9-94ea-9754133f8abb', '7848c0d1-634d-5f61-9686-8d45b6553e0b', 2, 'SUMMARY_COMPLETION', 'READING', 2, $md$### Question 2

Questions 1-4
Questions 1-4
Summary
Complete the following summary of the paragraphs of Reading Passage, using
NO MORE THAN TWO WORDS
from the Reading Passage for each answer.
Write your answers in boxes
1-4
on your answer sheet.
Dugongs are herbivorous mammals that spend their entire lives in the sea. Yet Dugongs are picky on their feeding Seagrass, and only chose seagrass with higher
1
and lower fibre. To compensate for their poor eyesight, they use their
2
to feel their surroundings.
It is like Dugongs are “farming” seagrass. They often leave
3
randomly in all directions across the sea bed. Dugongs prefer eating the newly grew seagrass recovering from the tiny
4
left behind by the grazing dugongs.

Dugongs are herbivorous mammals that spend their entire lives in the sea. Yet Dugongs are picky on their feeding Seagrass, and only chose seagrass with higher 1 ____ and lower fibre. To compensate for their poor eyesight, they use their 2 ____ to feel their surroundings.$md$, NULL, ARRAY['.*nitrogen.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('3db667f1-09fb-527c-86b4-cc009d80133d', '7848c0d1-634d-5f61-9686-8d45b6553e0b', 3, 'SUMMARY_COMPLETION', 'READING', 2, $md$### Question 3

Questions 1-4
Questions 1-4
Summary
Complete the following summary of the paragraphs of Reading Passage, using
NO MORE THAN TWO WORDS
from the Reading Passage for each answer.
Write your answers in boxes
1-4
on your answer sheet.
Dugongs are herbivorous mammals that spend their entire lives in the sea. Yet Dugongs are picky on their feeding Seagrass, and only chose seagrass with higher
1
and lower fibre. To compensate for their poor eyesight, they use their
2
to feel their surroundings.
It is like Dugongs are “farming” seagrass. They often leave
3
randomly in all directions across the sea bed. Dugongs prefer eating the newly grew seagrass recovering from the tiny
4
left behind by the grazing dugongs.

It is like Dugongs are “farming” seagrass. They often leave 3 ____ randomly in all directions across the sea bed. Dugongs prefer eating the newly grew seagrass recovering from the tiny 4 ____ left behind by the grazing dugongs.$md$, NULL, ARRAY['.*trails.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('23326fcd-8e44-5e41-8513-2c1272b940ee', '7848c0d1-634d-5f61-9686-8d45b6553e0b', 4, 'SUMMARY_COMPLETION', 'READING', 2, $md$### Question 4

Questions 1-4
Questions 1-4
Summary
Complete the following summary of the paragraphs of Reading Passage, using
NO MORE THAN TWO WORDS
from the Reading Passage for each answer.
Write your answers in boxes
1-4
on your answer sheet.
Dugongs are herbivorous mammals that spend their entire lives in the sea. Yet Dugongs are picky on their feeding Seagrass, and only chose seagrass with higher
1
and lower fibre. To compensate for their poor eyesight, they use their
2
to feel their surroundings.
It is like Dugongs are “farming” seagrass. They often leave
3
randomly in all directions across the sea bed. Dugongs prefer eating the newly grew seagrass recovering from the tiny
4
left behind by the grazing dugongs.

It is like Dugongs are “farming” seagrass. They often leave 3 ____ randomly in all directions across the sea bed. Dugongs prefer eating the newly grew seagrass recovering from the tiny 4 ____ left behind by the grazing dugongs.$md$, NULL, ARRAY['.*trails.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('092d85ec-ae65-58c7-a474-760bbcd486a7', '7848c0d1-634d-5f61-9686-8d45b6553e0b', 5, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 5

Questions 5-9
Questions 5-9
Do the following statements agree with the information given in Reading Passage?
In boxes
5-9
on your answer sheet, write
TRUE
if the statement is True
FALSE
if the statement is false
NOT
GIVEN
If the information is not given in the passage
5
The dugong will keep eating up the plant completely when they begin to feed.
6
It takes more than ten years for the re-growth of seagrass where it has been grazed by Dugongs.
7
Even in facing food shortages, the strong individuals will not compete with the weak small ones for food.
8
It is thought that the dugong rarely returns to the old habitats when they finished the plant.
9
Coastal industrial fishing poses the greatest danger to dugongs which are prone to be killed due to entanglement.

5 ____ The dugong will keep eating up the plant completely when they begin to feed.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a795c5bf-700b-53ba-a349-dd8f8aa1104b', '092d85ec-ae65-58c7-a474-760bbcd486a7', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('42473783-5ef2-5422-a4da-44a8d740fd89', '092d85ec-ae65-58c7-a474-760bbcd486a7', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b9ed7836-f6ef-5671-8830-5d303ff6bcc1', '092d85ec-ae65-58c7-a474-760bbcd486a7', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('83f446e4-123b-5fea-a689-e45741fbc8cf', '7848c0d1-634d-5f61-9686-8d45b6553e0b', 6, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 6

Questions 5-9
Questions 5-9
Do the following statements agree with the information given in Reading Passage?
In boxes
5-9
on your answer sheet, write
TRUE
if the statement is True
FALSE
if the statement is false
NOT
GIVEN
If the information is not given in the passage
5
The dugong will keep eating up the plant completely when they begin to feed.
6
It takes more than ten years for the re-growth of seagrass where it has been grazed by Dugongs.
7
Even in facing food shortages, the strong individuals will not compete with the weak small ones for food.
8
It is thought that the dugong rarely returns to the old habitats when they finished the plant.
9
Coastal industrial fishing poses the greatest danger to dugongs which are prone to be killed due to entanglement.

6 ____ It takes more than ten years for the re-growth of seagrass where it has been grazed by Dugongs.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e0f7d137-4f46-5e9a-8b81-6fc28de7252c', '83f446e4-123b-5fea-a689-e45741fbc8cf', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('faf4138e-4edf-563b-b977-ab70849a944c', '83f446e4-123b-5fea-a689-e45741fbc8cf', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('23b7ea43-a9bb-5b27-baf0-292a50632349', '83f446e4-123b-5fea-a689-e45741fbc8cf', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('beb88bef-ecc3-523f-982b-d00cc0b1cc64', '7848c0d1-634d-5f61-9686-8d45b6553e0b', 7, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 7

Questions 5-9
Questions 5-9
Do the following statements agree with the information given in Reading Passage?
In boxes
5-9
on your answer sheet, write
TRUE
if the statement is True
FALSE
if the statement is false
NOT
GIVEN
If the information is not given in the passage
5
The dugong will keep eating up the plant completely when they begin to feed.
6
It takes more than ten years for the re-growth of seagrass where it has been grazed by Dugongs.
7
Even in facing food shortages, the strong individuals will not compete with the weak small ones for food.
8
It is thought that the dugong rarely returns to the old habitats when they finished the plant.
9
Coastal industrial fishing poses the greatest danger to dugongs which are prone to be killed due to entanglement.

7 ____ Even in facing food shortages, the strong individuals will not compete with the weak small ones for food.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fe51b99e-5329-573d-a396-a357f962ebe9', 'beb88bef-ecc3-523f-982b-d00cc0b1cc64', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d6602198-a508-5990-a789-79978c1fbee2', 'beb88bef-ecc3-523f-982b-d00cc0b1cc64', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8c5a50cf-8122-5b80-bede-ef7b97d70661', 'beb88bef-ecc3-523f-982b-d00cc0b1cc64', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('d933be6e-741d-5fb2-9dd7-f98220530092', '7848c0d1-634d-5f61-9686-8d45b6553e0b', 8, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 8

Questions 5-9
Questions 5-9
Do the following statements agree with the information given in Reading Passage?
In boxes
5-9
on your answer sheet, write
TRUE
if the statement is True
FALSE
if the statement is false
NOT
GIVEN
If the information is not given in the passage
5
The dugong will keep eating up the plant completely when they begin to feed.
6
It takes more than ten years for the re-growth of seagrass where it has been grazed by Dugongs.
7
Even in facing food shortages, the strong individuals will not compete with the weak small ones for food.
8
It is thought that the dugong rarely returns to the old habitats when they finished the plant.
9
Coastal industrial fishing poses the greatest danger to dugongs which are prone to be killed due to entanglement.

8 ____ It is thought that the dugong rarely returns to the old habitats when they finished the plant.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0f469890-6594-5092-a6b7-e01b8d5d97c0', 'd933be6e-741d-5fb2-9dd7-f98220530092', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6056d15c-a7e6-564f-a9aa-c68993ca7fb9', 'd933be6e-741d-5fb2-9dd7-f98220530092', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1700afbf-6be4-54d4-84f2-d3a06b9d1fa2', 'd933be6e-741d-5fb2-9dd7-f98220530092', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('e43cafff-1c92-550a-bd8a-282c6503a639', '7848c0d1-634d-5f61-9686-8d45b6553e0b', 9, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 9

Questions 5-9
Questions 5-9
Do the following statements agree with the information given in Reading Passage?
In boxes
5-9
on your answer sheet, write
TRUE
if the statement is True
FALSE
if the statement is false
NOT
GIVEN
If the information is not given in the passage
5
The dugong will keep eating up the plant completely when they begin to feed.
6
It takes more than ten years for the re-growth of seagrass where it has been grazed by Dugongs.
7
Even in facing food shortages, the strong individuals will not compete with the weak small ones for food.
8
It is thought that the dugong rarely returns to the old habitats when they finished the plant.
9
Coastal industrial fishing poses the greatest danger to dugongs which are prone to be killed due to entanglement.

9 ____ Coastal industrial fishing poses the greatest danger to dugongs which are prone to be killed due to entanglement.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e482b40d-a656-57b5-8f67-ff7f0bde54f8', 'e43cafff-1c92-550a-bd8a-282c6503a639', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ef8be8e2-8374-5104-b95b-6f05a4ce2595', 'e43cafff-1c92-550a-bd8a-282c6503a639', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a4e31d70-172a-5f69-8dd4-b92ecc96cbb1', 'e43cafff-1c92-550a-bd8a-282c6503a639', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('734e3a86-be77-534f-ae54-dc9939aa2816', '7848c0d1-634d-5f61-9686-8d45b6553e0b', 10, 'SHORT_ANSWER', 'READING', 4, $md$### Question 10

Questions 10-13
Questions 10-13
Answer the questions below.
Choose
NO MORE THAN TWO WORDS AND/OR A NUMBER
from the passage for each answer.
10 What is Dugong in resemblance to yet as people can easily tell them apart from the manatees by its tail?
10
11 What is the major reason Dugongs traveled long distances in herds from one place to another?
11
12 What number, has estimated to be, of dugong’s population before the 1992 floods in Hervey Bay took place?
12
13 What is thought to be the lethal danger when dugongs were often trapped in?
13

10 What is Dugong in resemblance to yet as people can easily tell them apart from the manatees by its tail? 10 ____$md$, NULL, ARRAY['.*dolphin.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('e0b1758c-0262-5723-9f0a-eabcd4e553a2', '7848c0d1-634d-5f61-9686-8d45b6553e0b', 11, 'SHORT_ANSWER', 'READING', 4, $md$### Question 11

Questions 10-13
Questions 10-13
Answer the questions below.
Choose
NO MORE THAN TWO WORDS AND/OR A NUMBER
from the passage for each answer.
10 What is Dugong in resemblance to yet as people can easily tell them apart from the manatees by its tail?
10
11 What is the major reason Dugongs traveled long distances in herds from one place to another?
11
12 What number, has estimated to be, of dugong’s population before the 1992 floods in Hervey Bay took place?
12
13 What is thought to be the lethal danger when dugongs were often trapped in?
13

11 What is the major reason Dugongs traveled long distances in herds from one place to another? 11 ____$md$, NULL, ARRAY['.*sea.*grass.*availability.*','.*food.*shortage.*','.*seagrass.*shortage.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('f096610d-c737-5f57-9108-62b505448c11', '7848c0d1-634d-5f61-9686-8d45b6553e0b', 12, 'SHORT_ANSWER', 'READING', 4, $md$### Question 12

Questions 10-13
Questions 10-13
Answer the questions below.
Choose
NO MORE THAN TWO WORDS AND/OR A NUMBER
from the passage for each answer.
10 What is Dugong in resemblance to yet as people can easily tell them apart from the manatees by its tail?
10
11 What is the major reason Dugongs traveled long distances in herds from one place to another?
11
12 What number, has estimated to be, of dugong’s population before the 1992 floods in Hervey Bay took place?
12
13 What is thought to be the lethal danger when dugongs were often trapped in?
13

12 What number, has estimated to be, of dugong’s population before the 1992 floods in Hervey Bay took place? 12 ____$md$, NULL, ARRAY['.*1750.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('ed09f1b3-4c6a-5b46-8a14-44df7a138b5c', '7848c0d1-634d-5f61-9686-8d45b6553e0b', 13, 'SHORT_ANSWER', 'READING', 4, $md$### Question 13

Questions 10-13
Questions 10-13
Answer the questions below.
Choose
NO MORE THAN TWO WORDS AND/OR A NUMBER
from the passage for each answer.
10 What is Dugong in resemblance to yet as people can easily tell them apart from the manatees by its tail?
10
11 What is the major reason Dugongs traveled long distances in herds from one place to another?
11
12 What number, has estimated to be, of dugong’s population before the 1992 floods in Hervey Bay took place?
12
13 What is thought to be the lethal danger when dugongs were often trapped in?
13

13 What is thought to be the lethal danger when dugongs were often trapped in? 13 ____$md$, NULL, ARRAY['.*fishing.*net.*']);

COMMIT;
