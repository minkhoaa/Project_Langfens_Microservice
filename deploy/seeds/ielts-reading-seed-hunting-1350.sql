BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-seed-hunting-1350'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-seed-hunting-1350';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-seed-hunting-1350';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-seed-hunting-1350';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('c8a88529-3277-59e9-81bf-0adf9bf64868', 'ielts-reading-seed-hunting-1350', $t$Seed Hunting$t$, $md$## Seed Hunting

Nguồn:
- Test: https://mini-ielts.com/1350/reading/seed-hunting
- Solution: https://mini-ielts.com/1350/view-solution/reading/seed-hunting$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('4d0b8dc9-1482-5660-95c9-8d76c8298c06', 'c8a88529-3277-59e9-81bf-0adf9bf64868', 1, $t$Reading — Seed Hunting$t$, $md$Read the passage and answer questions **1–11**.

### Passage: Seed Hunting

A

With a quarter of the world’s plants set to vanish within the next 50 years, Dough Alexander reports on the scientists working against the clock the preserve the Earth’s botanical heritage. They travel the four corners of the globe, scouring jungles, forests and savannas. But they’re not looking for ancient artefacts, lost treasure or undiscovered tombs. Just pods. It may lack the romantic allure of archaeology or the whiff of danger that accompanies going after a big game, but seed hunting is an increasingly serious business. Some seek seeds for profit-hunters in the employ of biotechnology firms, pharmaceutical companies and private corporations on the lookout for species that will yield the drugs or crops of the future. Others collect to conserve, working to halt the sad slide into extinction facing so many plant species.

B

Among the pioneers of this botanical treasure hunt was John Tradescant, an English royal gardener who brought back plants and seeds from his journeys abroad in the early 1600s. Later, the English botanist Sir Joseph Banks – who was the first director of the Royal Botanic Gardens at Kew and travelled with Captain James Cook on his voyages near the end of the 18th century – was so driven to expand his collections that he sent botanists around the world at his own expense.

C

Those heady days of exploration and discovery may be over, but they have been replaced by a pressing need to preserve our natural history for the future. This modern mission drives hunters such as Dr Michiel van Slageren, a good-natured Dutchman who often sports a wide-brimmed hat in the field – he could easily be mistaken for the cinematic hero Indiana Jones. He and three other seed hunters work at the Millennium Seed Bank, an 80 million [pounds sterling] international conservation project that aims to protect the world’s most endangered wild plant species.

D

The group’s headquarters are in a modern glass-and-concrete structure on a 200-hectare Estate at Wakehurst Place in the West Sussex countryside. Within its underground vaults are 260 million dried seeds from 122 countries, all stored at -20 Celsius to survive for centuries. Among the 5,100 species represented are virtually all of Britain’s 1,400 native seed-bearing plants, the most complete such collection of any country’s flora.

E

Overseen by the Royal botanic gardens, the Millennium Seed Bank is the world’s largest wild-plant depository. It aims to collect 24,000 species by 2010. The reason is simple: thanks to humanity’s effort, an estimated 25 per cent of the world’s plants are on the verge of extinction and may vanish within 50 years. We’re currently responsible for habitat destruction on an unprecedented scale, and during the past 400 years, plant species extinction rates have been about 70 times greater than those indicated by the geological record as being ‘normal’. Experts predict that during the next 50 years further one billion hectares of wilderness will be converted to farmland in developing countries alone.

F

The implications of this loss are enormous. Besides providing staple food crops, plants are a source of many machines and the principal supply of fuel and building materials in many parts of the world. They also protect soil and help regulate the climate. Yet, across the globe, plant species are being driven to extinction before their potential benefits are discovered.

G

The world Conservation Union has listed 5,714 threatened species is sure to be much higher. In the UK alone, 300 wild plant species are classified as endangered. The Millennium Seed Bank aims to ensure that even if a plant becomes extinct in the wild, it won’t be lost forever. Stored seeds can be used the help restore damaged or destroyed the environment or in scientific research to find new benefits for society- in medicine, agriculture or local industry- that would otherwise be lost.

H

Seed banks are an insurance policy to protect the world’s plant heritage for the future, explains Dr Paul Smith, another Kew seed hunter. “Seed conservation techniques were originally developed by farmers,” he says. “Storage is the basis what we do, conserving seeds until you can use them just as in farming,” Smith says there’s no reason why any plant species should become extinct, given today’s technology. But he admits that the biggest challenge is finding, naming and categorizing all the world’s plants. And someone has to gather these seeds before it’s too late. “There aren’t a lot of people out there doing this,” he says. “The key is to know the flora from a particular area, and that knowledge takes years to acquire.”

I

There are about 1,470 seedbanks scattered around the globe, with a combined total of 5.4 million samples, of which perhaps two million are distinct non-duplicates. Most preserve genetic material for agriculture use in order to ensure crop diversity; others aim to conserve wild species, although only 15 per cent of all banked plants is wild.

J

Many seed banks are themselves under threat due to a lack of funds. Last year, Imperial College, London, examined crop collections from 151 countries and found that while the number of plant samples had increased in two-thirds of the countries, the budget had been cut in a quarter and remained static in another 35 per cent. The UN’s Food and Agriculture Organization and the Consultative Group on International Agricultural Research has since set up the Global Conservation Trust, which aims to raise the US $260 million to protect seed banks in perpetuity.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('cf0826b3-38d1-5244-8b25-0b68ea34c429', '4d0b8dc9-1482-5660-95c9-8d76c8298c06', 1, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 1

Questions 1-6
Questions 1-6
Do the following statements agree with the information given in Reading Passage?
In boxes
1-6
on your answer sheet, write
TRUE
if the statement is true
FALSE
if the statement is false
NOT GIVEN
if the information is not given in the passage
1
The purpose of collecting seeds now is different from the past.
2
The millennium seed bank is the earliest seed bank.
3
One of the major threats for plant species extinction is farmland expansion into wildness.
4
The approach that scientists apply to store seeds is similar to that used by farmers.
5
technological development is the only hope to save plant species.
6
The works of seed conservation are often limited by financial problems.

1 ____ The purpose of collecting seeds now is different from the past.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e174f683-b7b9-5d27-b0a7-68c9205acecc', 'cf0826b3-38d1-5244-8b25-0b68ea34c429', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b9326493-5e1f-5abf-bedf-8f0e7f488f66', 'cf0826b3-38d1-5244-8b25-0b68ea34c429', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e7ea97dc-1c0d-50ec-ae76-d9d7875960da', 'cf0826b3-38d1-5244-8b25-0b68ea34c429', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('a110cde4-568e-5ec1-86bf-cc26decef7e3', '4d0b8dc9-1482-5660-95c9-8d76c8298c06', 2, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 2

Questions 1-6
Questions 1-6
Do the following statements agree with the information given in Reading Passage?
In boxes
1-6
on your answer sheet, write
TRUE
if the statement is true
FALSE
if the statement is false
NOT GIVEN
if the information is not given in the passage
1
The purpose of collecting seeds now is different from the past.
2
The millennium seed bank is the earliest seed bank.
3
One of the major threats for plant species extinction is farmland expansion into wildness.
4
The approach that scientists apply to store seeds is similar to that used by farmers.
5
technological development is the only hope to save plant species.
6
The works of seed conservation are often limited by financial problems.

2 ____ The millennium seed bank is the earliest seed bank.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('10c575d3-9522-5f41-9b55-88af5f0fa8f7', 'a110cde4-568e-5ec1-86bf-cc26decef7e3', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ed8db904-09a6-59ca-9c7e-540ee1b92da0', 'a110cde4-568e-5ec1-86bf-cc26decef7e3', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f7a9808f-7178-5719-a22f-8113897ee4de', 'a110cde4-568e-5ec1-86bf-cc26decef7e3', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('2001dc61-e808-5f0c-98ae-2b93868bbc45', '4d0b8dc9-1482-5660-95c9-8d76c8298c06', 3, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 3

Questions 1-6
Questions 1-6
Do the following statements agree with the information given in Reading Passage?
In boxes
1-6
on your answer sheet, write
TRUE
if the statement is true
FALSE
if the statement is false
NOT GIVEN
if the information is not given in the passage
1
The purpose of collecting seeds now is different from the past.
2
The millennium seed bank is the earliest seed bank.
3
One of the major threats for plant species extinction is farmland expansion into wildness.
4
The approach that scientists apply to store seeds is similar to that used by farmers.
5
technological development is the only hope to save plant species.
6
The works of seed conservation are often limited by financial problems.

3 ____ One of the major threats for plant species extinction is farmland expansion into wildness.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b4fdf200-7b2e-5a69-a091-4ce135decbec', '2001dc61-e808-5f0c-98ae-2b93868bbc45', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d582afd8-39b3-5975-b1a0-b43264d77486', '2001dc61-e808-5f0c-98ae-2b93868bbc45', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6b3da7f9-05c7-589a-b35d-3b43f97dc911', '2001dc61-e808-5f0c-98ae-2b93868bbc45', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('c3c25bad-54e7-5007-afd1-aa412b50f969', '4d0b8dc9-1482-5660-95c9-8d76c8298c06', 4, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 4

Questions 1-6
Questions 1-6
Do the following statements agree with the information given in Reading Passage?
In boxes
1-6
on your answer sheet, write
TRUE
if the statement is true
FALSE
if the statement is false
NOT GIVEN
if the information is not given in the passage
1
The purpose of collecting seeds now is different from the past.
2
The millennium seed bank is the earliest seed bank.
3
One of the major threats for plant species extinction is farmland expansion into wildness.
4
The approach that scientists apply to store seeds is similar to that used by farmers.
5
technological development is the only hope to save plant species.
6
The works of seed conservation are often limited by financial problems.

4 ____ The approach that scientists apply to store seeds is similar to that used by farmers.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('dacf3627-8221-5d7a-a097-0d686e5e6b0b', 'c3c25bad-54e7-5007-afd1-aa412b50f969', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2c7f9648-9e0e-5c34-9f9b-00f4243b3de3', 'c3c25bad-54e7-5007-afd1-aa412b50f969', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2b74ac10-01d0-5303-86bf-b43cfa295141', 'c3c25bad-54e7-5007-afd1-aa412b50f969', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('bed18b38-10f9-5f4a-aad2-33e914bba8c0', '4d0b8dc9-1482-5660-95c9-8d76c8298c06', 5, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 5

Questions 1-6
Questions 1-6
Do the following statements agree with the information given in Reading Passage?
In boxes
1-6
on your answer sheet, write
TRUE
if the statement is true
FALSE
if the statement is false
NOT GIVEN
if the information is not given in the passage
1
The purpose of collecting seeds now is different from the past.
2
The millennium seed bank is the earliest seed bank.
3
One of the major threats for plant species extinction is farmland expansion into wildness.
4
The approach that scientists apply to store seeds is similar to that used by farmers.
5
technological development is the only hope to save plant species.
6
The works of seed conservation are often limited by financial problems.

5 ____ technological development is the only hope to save plant species.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8bb10a3c-9961-544d-8ec3-d180166d42ce', 'bed18b38-10f9-5f4a-aad2-33e914bba8c0', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c84bae1d-0194-5230-adf0-653477a5badb', 'bed18b38-10f9-5f4a-aad2-33e914bba8c0', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3cb7a149-bed5-5150-b8c4-f90d275b15f3', 'bed18b38-10f9-5f4a-aad2-33e914bba8c0', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('e5102310-b410-59bd-9f1b-1172bef939a8', '4d0b8dc9-1482-5660-95c9-8d76c8298c06', 6, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 6

Questions 1-6
Questions 1-6
Do the following statements agree with the information given in Reading Passage?
In boxes
1-6
on your answer sheet, write
TRUE
if the statement is true
FALSE
if the statement is false
NOT GIVEN
if the information is not given in the passage
1
The purpose of collecting seeds now is different from the past.
2
The millennium seed bank is the earliest seed bank.
3
One of the major threats for plant species extinction is farmland expansion into wildness.
4
The approach that scientists apply to store seeds is similar to that used by farmers.
5
technological development is the only hope to save plant species.
6
The works of seed conservation are often limited by financial problems.

6 ____ The works of seed conservation are often limited by financial problems.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f912c62e-98fe-5091-b103-471eac986f07', 'e5102310-b410-59bd-9f1b-1172bef939a8', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('87825ecf-2613-5e20-a2f5-5a5b2be40afc', 'e5102310-b410-59bd-9f1b-1172bef939a8', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('66746fa4-9a50-5392-af11-a03c07fb6fc0', 'e5102310-b410-59bd-9f1b-1172bef939a8', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('796cfc9a-f621-5eca-8a95-c3d14b2b8fb9', '4d0b8dc9-1482-5660-95c9-8d76c8298c06', 7, 'SUMMARY_COMPLETION', 'READING', 3, $md$### Question 7

Questions 7-11
Questions 7-11
Summary
Complete the following summary of the paragraphs of Reading Passage,
Using
NO MORE THAN THREE WORDS
from the Reading Passage for each answer.
Write your answers in boxes
7-11
on your answer sheet.
Some people collect seeds for the purpose of protecting certain species from
7
; others collect seeds for their ability to produce
8
. They are called seed hunters. The
9
. Of them included both gardeners and botanists, such as
10
, who financially supported collectors out of his own pocket. The seeds collected are usually stored in seed banks, one of which is the famous millennium seed bank, where seeds are all stored in the
11
at a low temperature.

Some people collect seeds for the purpose of protecting certain species from 7 ____ ; others collect seeds for their ability to produce 8 ____ . They are called seed hunters. The 9 ____ . Of them included both gardeners and botanists, such as 10 ____ , who financially supported collectors out of his own pocket. The seeds collected are usually stored in seed banks, one of which is the famous millennium seed bank, where seeds are all stored in the 11 ____ at a low temperature.$md$, NULL, ARRAY['.*extinction.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('a3541212-9d23-5059-b9ec-f38ed9a7299d', '4d0b8dc9-1482-5660-95c9-8d76c8298c06', 8, 'SUMMARY_COMPLETION', 'READING', 3, $md$### Question 8

Questions 7-11
Questions 7-11
Summary
Complete the following summary of the paragraphs of Reading Passage,
Using
NO MORE THAN THREE WORDS
from the Reading Passage for each answer.
Write your answers in boxes
7-11
on your answer sheet.
Some people collect seeds for the purpose of protecting certain species from
7
; others collect seeds for their ability to produce
8
. They are called seed hunters. The
9
. Of them included both gardeners and botanists, such as
10
, who financially supported collectors out of his own pocket. The seeds collected are usually stored in seed banks, one of which is the famous millennium seed bank, where seeds are all stored in the
11
at a low temperature.

Some people collect seeds for the purpose of protecting certain species from 7 ____ ; others collect seeds for their ability to produce 8 ____ . They are called seed hunters. The 9 ____ . Of them included both gardeners and botanists, such as 10 ____ , who financially supported collectors out of his own pocket. The seeds collected are usually stored in seed banks, one of which is the famous millennium seed bank, where seeds are all stored in the 11 ____ at a low temperature.$md$, NULL, ARRAY['.*extinction.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('9d8ee173-f755-5dd2-96b5-8f0e5bda489c', '4d0b8dc9-1482-5660-95c9-8d76c8298c06', 9, 'SUMMARY_COMPLETION', 'READING', 3, $md$### Question 9

Questions 7-11
Questions 7-11
Summary
Complete the following summary of the paragraphs of Reading Passage,
Using
NO MORE THAN THREE WORDS
from the Reading Passage for each answer.
Write your answers in boxes
7-11
on your answer sheet.
Some people collect seeds for the purpose of protecting certain species from
7
; others collect seeds for their ability to produce
8
. They are called seed hunters. The
9
. Of them included both gardeners and botanists, such as
10
, who financially supported collectors out of his own pocket. The seeds collected are usually stored in seed banks, one of which is the famous millennium seed bank, where seeds are all stored in the
11
at a low temperature.

Some people collect seeds for the purpose of protecting certain species from 7 ____ ; others collect seeds for their ability to produce 8 ____ . They are called seed hunters. The 9 ____ . Of them included both gardeners and botanists, such as 10 ____ , who financially supported collectors out of his own pocket. The seeds collected are usually stored in seed banks, one of which is the famous millennium seed bank, where seeds are all stored in the 11 ____ at a low temperature.$md$, NULL, ARRAY['.*extinction.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('c6592cee-880a-5d3d-98d4-62449fdbb785', '4d0b8dc9-1482-5660-95c9-8d76c8298c06', 10, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 10

Questions 7-11
Questions 7-11
Summary
Complete the following summary of the paragraphs of Reading Passage,
Using
NO MORE THAN THREE WORDS
from the Reading Passage for each answer.
Write your answers in boxes
7-11
on your answer sheet.
Some people collect seeds for the purpose of protecting certain species from
7
; others collect seeds for their ability to produce
8
. They are called seed hunters. The
9
. Of them included both gardeners and botanists, such as
10
, who financially supported collectors out of his own pocket. The seeds collected are usually stored in seed banks, one of which is the famous millennium seed bank, where seeds are all stored in the
11
at a low temperature.

Some people collect seeds for the purpose of protecting certain species from 7 ____ ; others collect seeds for their ability to produce 8 ____ . They are called seed hunters. The 9 ____ . Of them included both gardeners and botanists, such as 10 ____ , who financially supported collectors out of his own pocket. The seeds collected are usually stored in seed banks, one of which is the famous millennium seed bank, where seeds are all stored in the 11 ____ at a low temperature.$md$, NULL, ARRAY['.*extinction.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('72a9f79f-5528-5d78-8850-a5771c7ace22', '4d0b8dc9-1482-5660-95c9-8d76c8298c06', 11, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 11

Questions 7-11
Questions 7-11
Summary
Complete the following summary of the paragraphs of Reading Passage,
Using
NO MORE THAN THREE WORDS
from the Reading Passage for each answer.
Write your answers in boxes
7-11
on your answer sheet.
Some people collect seeds for the purpose of protecting certain species from
7
; others collect seeds for their ability to produce
8
. They are called seed hunters. The
9
. Of them included both gardeners and botanists, such as
10
, who financially supported collectors out of his own pocket. The seeds collected are usually stored in seed banks, one of which is the famous millennium seed bank, where seeds are all stored in the
11
at a low temperature.

Some people collect seeds for the purpose of protecting certain species from 7 ____ ; others collect seeds for their ability to produce 8 ____ . They are called seed hunters. The 9 ____ . Of them included both gardeners and botanists, such as 10 ____ , who financially supported collectors out of his own pocket. The seeds collected are usually stored in seed banks, one of which is the famous millennium seed bank, where seeds are all stored in the 11 ____ at a low temperature.$md$, NULL, ARRAY['.*extinction.*']);

COMMIT;
