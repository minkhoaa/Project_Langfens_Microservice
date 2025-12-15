BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-the-tuatara-of-new-zealand-1445'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-the-tuatara-of-new-zealand-1445';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-the-tuatara-of-new-zealand-1445';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-the-tuatara-of-new-zealand-1445';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('1f199381-78f6-571f-8d9d-813e0c439cb0', 'ielts-reading-the-tuatara-of-new-zealand-1445', $t$The Tuatara of New Zealand$t$, $md$## The Tuatara of New Zealand

Nguồn:
- Test: https://mini-ielts.com/1445/reading/the-tuatara-of-new-zealand
- Solution: https://mini-ielts.com/1445/view-solution/reading/the-tuatara-of-new-zealand$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('86ed4d04-0343-5774-970b-8116173613fa', '1f199381-78f6-571f-8d9d-813e0c439cb0', 1, $t$Reading — The Tuatara of New Zealand$t$, $md$Read the passage and answer questions **1–13**.

### Passage: The Tuatara of New Zealand

Tuatara are lizard-like reptiles, found only in New Zealand. They are representative of ancient life forms Tuatara are the only living representatives of an ancient lineage of reptiles called Sphenodontia, which is over 250 million years old. Because tuatara still look like fossils of reptiles that lived during the age of dinosaurs, they are often called living fossils. Now just two species of tuatara survive, and only in New Zealand. One is the Brothers Island tuatara which, until recent re-introductions to sanctuaries (safe places for wildlife), only survived on North Brother Island. The other species is the common tuatara, which survives on many other offshore islands. Although the tuatara species appear similar, they have genetic differences. Tuatara bones have been found in many parts of New Zealand. Where dated, they are usually a few hundred to 5,000 years old. It is not known whether these bones are from the two living species or other species that are now extinct.

Many anatomical features distinguish tuatara from other living reptiles - for example, they have a defining pattern of openings in the skull and a unique type of haemoglobin in the blood, and males have no external reproductive organ. Adults are between 30 and 75 centimetres long, and weigh between 250 and 1.200 grams. Males are larger than females, and have more developed spines in the crest along the neck, back and tail.

The male tuatara courts the female by approaching her with a proud walk. Tuatara mate in late summer, and the female usually lays 6-10 eggs the following spring, in a shallow nest at ground level. She may guard the nest for a few nights, then return to her burrow underground. The eggs incubate for about a year, so hatchlings emerge about the time that eggs are being laid the following season. Evidence indicates the gender of tuatara hatchlings is determined by both genetic and environmental factors. It is said that it is more likely for warmer eggs to produce male tuatara, and cooler eggs to produce females. The hatchlings receive no parental care and need to find their own food.

Tuatara live for a relatively long time, reaching reproductive maturity at about 15 years, and may breed for many decades. Their maximum lifespan is not known for certain, but many tuatara have reached 80 years still looking vigorous and healthy. Tuatara live in underground burrows and are more active at night, but will come out during the day to bask in the sun. Both sexes are territorial, and males aggressively defend their territory by posing and fighting if necessary. Teeth are their main weapons, and a bite can cause serious injury. Tuatara are carnivorous, eating invertebrates, lizards and the baby seabirds with which they often share burrows.

Tuatara were once widespread and abundant on the New Zealand mainland, but when Polynesian settlers arrived in New Zealand, in about 1250-1300 AD, they brought with them Pacific rats which killed tuatara. By the time of European settlement, in the 1840s, tuatara were almost extinct on the New Zealand mainland. Some islands provided temporary havens, but soon these too began to be invaded by rats and other mammalian predators.

Gradually tuatara became restricted to 32 nearshore islands. Many of these islands were tiny, some as small as only one hectare. A few, such as the Poor Knights common tuatara lives on islands off the north-eastern coast of New Zealand, and on some islands in Cook Strait. The Brothers Island tuatara survived only on the of the Brothers Island tuatara have been created on Titi Island in the Marlborough Sounds, and on Somes Island in Wellington Harbour.

Tuatara can live in remarkably dense populations. Most tuatara islands have 50- 100 tuatara per square hectare - so an island of only 10 hectares may have a population of hundreds. Larger islands with many seabirds and invertebrates, which tuatara eat, may have greater densities. The largest population is on Stephens Island, where there are estimated to be as many as 2,500 per hectare in some places, and a total of at least 30,000. The total number of tuatara on all the islands is estimated to be between 50,000 and 100,000.

Legal protection, was granted to tuatara and the islands they occupied in 1895, but the reptiles continued to decline. Since then, active conservation management has reversed the decline, and new populations have become established on predator- free islands. In the mid-1980s the New Zealand Wildlife Service and its successor, the Department of Conservation, developed ways to eradicate rats from islands. Rats have now gone from almost all of the tuatara islands, making them safe for many threatened native species. In addition, the collection by conservationists of eggs for incubation in captivity, breeding in captivity, and moving tuatara to rat­islands off the Northland coast, or Stephens Island in Cook Strait, were never invaded by rats, and had few of the other mammals that threaten native animals. The tiny, 4 hectare North Brother Island, in Cook Strait. However, two new populations free islands, have increased the number of islands that are inhabited by tuatara to 37. Many new tuatara populations are planned for islands and mainland reserves that have been freed of predators.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('4954ec44-cf07-5444-b336-2f9ac70399d8', '86ed4d04-0343-5774-970b-8116173613fa', 1, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 1

Questions 1 - 6
Questions 1 - 6
Do the following statements agree with the information given in Reading Passage?
In boxes 1-6 on your answer sheet, write
TRUE if the statement agrees with the information
FALSE if the statement contradicts the information
NOT GIVEN if there is no information on this
1
The two living species of tuatara look alike
2
Many of the tuatara bones that have been found are millions of years old.
3
The tails of male tuatara are a different colour from the tails of female tuatara.
4
The female tuatara lays eggs in a burrow.
5
There are higher numbers of female hatchlings than males.
6
Once they have hatched, young tuatara have to look after themselves.

1 ____ The two living species of tuatara look alike$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('97862ec3-9dcb-5b5f-bc29-f8ca71a44dc9', '4954ec44-cf07-5444-b336-2f9ac70399d8', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b1f3ada3-0506-552f-a9c8-41ab8ace294f', '4954ec44-cf07-5444-b336-2f9ac70399d8', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1f56e7cc-16b7-5dc7-bea2-39741cb158e4', '4954ec44-cf07-5444-b336-2f9ac70399d8', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('2b5447f9-b208-59ac-a50c-ed67752bf135', '86ed4d04-0343-5774-970b-8116173613fa', 2, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 2

Questions 1 - 6
Questions 1 - 6
Do the following statements agree with the information given in Reading Passage?
In boxes 1-6 on your answer sheet, write
TRUE if the statement agrees with the information
FALSE if the statement contradicts the information
NOT GIVEN if there is no information on this
1
The two living species of tuatara look alike
2
Many of the tuatara bones that have been found are millions of years old.
3
The tails of male tuatara are a different colour from the tails of female tuatara.
4
The female tuatara lays eggs in a burrow.
5
There are higher numbers of female hatchlings than males.
6
Once they have hatched, young tuatara have to look after themselves.

2 ____ Many of the tuatara bones that have been found are millions of years old.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fe1a81d0-b5ed-59c2-954b-26cc68e44392', '2b5447f9-b208-59ac-a50c-ed67752bf135', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7f070a02-7ac7-56f0-85d5-be11bb2a3d6d', '2b5447f9-b208-59ac-a50c-ed67752bf135', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('15f0cf36-d720-558a-baca-3f105a751ce4', '2b5447f9-b208-59ac-a50c-ed67752bf135', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('f6827ffc-f74c-5d7a-a93d-62f95ff164c9', '86ed4d04-0343-5774-970b-8116173613fa', 3, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 3

Questions 1 - 6
Questions 1 - 6
Do the following statements agree with the information given in Reading Passage?
In boxes 1-6 on your answer sheet, write
TRUE if the statement agrees with the information
FALSE if the statement contradicts the information
NOT GIVEN if there is no information on this
1
The two living species of tuatara look alike
2
Many of the tuatara bones that have been found are millions of years old.
3
The tails of male tuatara are a different colour from the tails of female tuatara.
4
The female tuatara lays eggs in a burrow.
5
There are higher numbers of female hatchlings than males.
6
Once they have hatched, young tuatara have to look after themselves.

3 ____ The tails of male tuatara are a different colour from the tails of female tuatara.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a12a198a-e7d2-513b-a2bc-ab8cca010caa', 'f6827ffc-f74c-5d7a-a93d-62f95ff164c9', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7efe7abb-6a7f-54d0-b65d-885562b1654a', 'f6827ffc-f74c-5d7a-a93d-62f95ff164c9', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('20ef96f9-9258-5ad7-9bd3-65e02dcf313f', 'f6827ffc-f74c-5d7a-a93d-62f95ff164c9', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('2e740c6a-ad00-5b06-ad8a-fac37fcb173f', '86ed4d04-0343-5774-970b-8116173613fa', 4, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 4

Questions 1 - 6
Questions 1 - 6
Do the following statements agree with the information given in Reading Passage?
In boxes 1-6 on your answer sheet, write
TRUE if the statement agrees with the information
FALSE if the statement contradicts the information
NOT GIVEN if there is no information on this
1
The two living species of tuatara look alike
2
Many of the tuatara bones that have been found are millions of years old.
3
The tails of male tuatara are a different colour from the tails of female tuatara.
4
The female tuatara lays eggs in a burrow.
5
There are higher numbers of female hatchlings than males.
6
Once they have hatched, young tuatara have to look after themselves.

4 ____ The female tuatara lays eggs in a burrow.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('19668643-5e28-5e14-97d6-6c425fd5f72c', '2e740c6a-ad00-5b06-ad8a-fac37fcb173f', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('899a55cc-b5b2-57d0-b0dc-354821e6bafc', '2e740c6a-ad00-5b06-ad8a-fac37fcb173f', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('495d50e4-8af3-541a-ae1c-8dad700a35bf', '2e740c6a-ad00-5b06-ad8a-fac37fcb173f', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('a967f9ae-7780-5169-b29e-38a8e51001dc', '86ed4d04-0343-5774-970b-8116173613fa', 5, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 5

Questions 1 - 6
Questions 1 - 6
Do the following statements agree with the information given in Reading Passage?
In boxes 1-6 on your answer sheet, write
TRUE if the statement agrees with the information
FALSE if the statement contradicts the information
NOT GIVEN if there is no information on this
1
The two living species of tuatara look alike
2
Many of the tuatara bones that have been found are millions of years old.
3
The tails of male tuatara are a different colour from the tails of female tuatara.
4
The female tuatara lays eggs in a burrow.
5
There are higher numbers of female hatchlings than males.
6
Once they have hatched, young tuatara have to look after themselves.

5 ____ There are higher numbers of female hatchlings than males.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('77aac68d-d67d-5a76-8719-7adf9f1fff91', 'a967f9ae-7780-5169-b29e-38a8e51001dc', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5f58d2b6-328d-5ba4-9127-b21509d61835', 'a967f9ae-7780-5169-b29e-38a8e51001dc', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fd660c9c-586f-5751-9023-f0e6c197b7d6', 'a967f9ae-7780-5169-b29e-38a8e51001dc', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('bcbc1695-23d8-563b-8727-ad0b9e74d270', '86ed4d04-0343-5774-970b-8116173613fa', 6, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 6

Questions 1 - 6
Questions 1 - 6
Do the following statements agree with the information given in Reading Passage?
In boxes 1-6 on your answer sheet, write
TRUE if the statement agrees with the information
FALSE if the statement contradicts the information
NOT GIVEN if there is no information on this
1
The two living species of tuatara look alike
2
Many of the tuatara bones that have been found are millions of years old.
3
The tails of male tuatara are a different colour from the tails of female tuatara.
4
The female tuatara lays eggs in a burrow.
5
There are higher numbers of female hatchlings than males.
6
Once they have hatched, young tuatara have to look after themselves.

6 ____ Once they have hatched, young tuatara have to look after themselves.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4fa11421-49e2-5923-b6dc-7a88cc101c54', 'bcbc1695-23d8-563b-8727-ad0b9e74d270', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('311d898d-9d07-5b62-9167-8980c2dcfc3e', 'bcbc1695-23d8-563b-8727-ad0b9e74d270', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8d39224e-865c-5fa7-ae5c-249df11cff39', 'bcbc1695-23d8-563b-8727-ad0b9e74d270', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('e987a645-5b2b-5377-a14b-2436e5760bd6', '86ed4d04-0343-5774-970b-8116173613fa', 7, 'NOTE_COMPLETION', 'READING', 3, $md$### Question 7

Questions 7 -13
Questions 7 -13
Complete the notes below. Choose
ONE WORD AND/OR A
NUMBER
from the passage for each answer
Write your answers in boxes 7-13 on your answer sheet.
The tuatara
Lifespan
maximum lifespan unknown
many live to at least
7
years old
Behaviour
attack other creatures with their
8
eat young
9
that live in the same burrows, invertebrates and reptiles
Population
abundant until rats were introduced by
10
people
by the 1840s, hardly any tuatara found on the
11
islands off the north-eastern coast and in Cook Strait now home to the
12
tuatara
Brothers Island tuatara found on North Brother Island
density of tuatara on Stephens Island is up to
13
tuatara for every hectare
Protection of the species
tuatara population dropped until rats eradicated from islands
eggs were gathered by the Department of Conservation

many live to at least 7 ____ years old$md$, NULL, ARRAY['.*80.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('bd2c5e57-bfc6-5823-bf8b-6ef1767b2473', '86ed4d04-0343-5774-970b-8116173613fa', 8, 'NOTE_COMPLETION', 'READING', 3, $md$### Question 8

Questions 7 -13
Questions 7 -13
Complete the notes below. Choose
ONE WORD AND/OR A
NUMBER
from the passage for each answer
Write your answers in boxes 7-13 on your answer sheet.
The tuatara
Lifespan
maximum lifespan unknown
many live to at least
7
years old
Behaviour
attack other creatures with their
8
eat young
9
that live in the same burrows, invertebrates and reptiles
Population
abundant until rats were introduced by
10
people
by the 1840s, hardly any tuatara found on the
11
islands off the north-eastern coast and in Cook Strait now home to the
12
tuatara
Brothers Island tuatara found on North Brother Island
density of tuatara on Stephens Island is up to
13
tuatara for every hectare
Protection of the species
tuatara population dropped until rats eradicated from islands
eggs were gathered by the Department of Conservation

attack other creatures with their 8 ____$md$, NULL, ARRAY['.*tech.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('242a8148-c4bb-5afa-9bec-28d5ae77a8c3', '86ed4d04-0343-5774-970b-8116173613fa', 9, 'NOTE_COMPLETION', 'READING', 3, $md$### Question 9

Questions 7 -13
Questions 7 -13
Complete the notes below. Choose
ONE WORD AND/OR A
NUMBER
from the passage for each answer
Write your answers in boxes 7-13 on your answer sheet.
The tuatara
Lifespan
maximum lifespan unknown
many live to at least
7
years old
Behaviour
attack other creatures with their
8
eat young
9
that live in the same burrows, invertebrates and reptiles
Population
abundant until rats were introduced by
10
people
by the 1840s, hardly any tuatara found on the
11
islands off the north-eastern coast and in Cook Strait now home to the
12
tuatara
Brothers Island tuatara found on North Brother Island
density of tuatara on Stephens Island is up to
13
tuatara for every hectare
Protection of the species
tuatara population dropped until rats eradicated from islands
eggs were gathered by the Department of Conservation

eat young 9 ____ that live in the same burrows, invertebrates and reptiles$md$, NULL, ARRAY['.*seabirds.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('305a8b10-8f6b-5153-8eb9-202efeb17753', '86ed4d04-0343-5774-970b-8116173613fa', 10, 'NOTE_COMPLETION', 'READING', 4, $md$### Question 10

Questions 7 -13
Questions 7 -13
Complete the notes below. Choose
ONE WORD AND/OR A
NUMBER
from the passage for each answer
Write your answers in boxes 7-13 on your answer sheet.
The tuatara
Lifespan
maximum lifespan unknown
many live to at least
7
years old
Behaviour
attack other creatures with their
8
eat young
9
that live in the same burrows, invertebrates and reptiles
Population
abundant until rats were introduced by
10
people
by the 1840s, hardly any tuatara found on the
11
islands off the north-eastern coast and in Cook Strait now home to the
12
tuatara
Brothers Island tuatara found on North Brother Island
density of tuatara on Stephens Island is up to
13
tuatara for every hectare
Protection of the species
tuatara population dropped until rats eradicated from islands
eggs were gathered by the Department of Conservation

abundant until rats were introduced by 10 ____ people$md$, NULL, ARRAY['.*polynesian.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('4dd6f820-bcc7-50c0-a4c4-890262460cad', '86ed4d04-0343-5774-970b-8116173613fa', 11, 'NOTE_COMPLETION', 'READING', 4, $md$### Question 11

Questions 7 -13
Questions 7 -13
Complete the notes below. Choose
ONE WORD AND/OR A
NUMBER
from the passage for each answer
Write your answers in boxes 7-13 on your answer sheet.
The tuatara
Lifespan
maximum lifespan unknown
many live to at least
7
years old
Behaviour
attack other creatures with their
8
eat young
9
that live in the same burrows, invertebrates and reptiles
Population
abundant until rats were introduced by
10
people
by the 1840s, hardly any tuatara found on the
11
islands off the north-eastern coast and in Cook Strait now home to the
12
tuatara
Brothers Island tuatara found on North Brother Island
density of tuatara on Stephens Island is up to
13
tuatara for every hectare
Protection of the species
tuatara population dropped until rats eradicated from islands
eggs were gathered by the Department of Conservation

by the 1840s, hardly any tuatara found on the 11 ____$md$, NULL, ARRAY['.*mainland.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('8d007338-2bf7-5023-bb6c-d62219faae12', '86ed4d04-0343-5774-970b-8116173613fa', 12, 'NOTE_COMPLETION', 'READING', 4, $md$### Question 12

Questions 7 -13
Questions 7 -13
Complete the notes below. Choose
ONE WORD AND/OR A
NUMBER
from the passage for each answer
Write your answers in boxes 7-13 on your answer sheet.
The tuatara
Lifespan
maximum lifespan unknown
many live to at least
7
years old
Behaviour
attack other creatures with their
8
eat young
9
that live in the same burrows, invertebrates and reptiles
Population
abundant until rats were introduced by
10
people
by the 1840s, hardly any tuatara found on the
11
islands off the north-eastern coast and in Cook Strait now home to the
12
tuatara
Brothers Island tuatara found on North Brother Island
density of tuatara on Stephens Island is up to
13
tuatara for every hectare
Protection of the species
tuatara population dropped until rats eradicated from islands
eggs were gathered by the Department of Conservation

12 ____ tuatara$md$, NULL, ARRAY['.*common.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('38a4a89b-6f0a-530b-a9a6-172f3f1a4333', '86ed4d04-0343-5774-970b-8116173613fa', 13, 'NOTE_COMPLETION', 'READING', 4, $md$### Question 13

Questions 7 -13
Questions 7 -13
Complete the notes below. Choose
ONE WORD AND/OR A
NUMBER
from the passage for each answer
Write your answers in boxes 7-13 on your answer sheet.
The tuatara
Lifespan
maximum lifespan unknown
many live to at least
7
years old
Behaviour
attack other creatures with their
8
eat young
9
that live in the same burrows, invertebrates and reptiles
Population
abundant until rats were introduced by
10
people
by the 1840s, hardly any tuatara found on the
11
islands off the north-eastern coast and in Cook Strait now home to the
12
tuatara
Brothers Island tuatara found on North Brother Island
density of tuatara on Stephens Island is up to
13
tuatara for every hectare
Protection of the species
tuatara population dropped until rats eradicated from islands
eggs were gathered by the Department of Conservation

density of tuatara on Stephens Island is up to 13 ____ tuatara for every hectare$md$, NULL, ARRAY['.*2500.*']);

COMMIT;
