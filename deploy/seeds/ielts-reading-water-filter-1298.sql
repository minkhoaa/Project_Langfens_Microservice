BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-water-filter-1298'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-water-filter-1298';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-water-filter-1298';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-water-filter-1298';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('0a4f42ff-e5ea-52d3-bb6e-76f695a93367', 'ielts-reading-water-filter-1298', $t$Water Filter$t$, $md$## Water Filter

Nguồn:
- Test: https://mini-ielts.com/1298/reading/water-filter
- Solution: https://mini-ielts.com/1298/view-solution/reading/water-filter$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('2d751526-3b03-51e7-bc8c-b38d7132d1c9', '0a4f42ff-e5ea-52d3-bb6e-76f695a93367', 1, $t$Reading — Water Filter$t$, $md$Read the passage and answer questions **1–13**.

### Passage: Water Filter

A . An ingenious invention is set to bring clean water to the third world, and while the science may be cutting edge, the materials are extremely down to earth. A handful of clay yesterday’s coffee grounds and some cow manure are the ingredients that could bring clean, safe drinking water to much of the third world.

B . The simple new technology, developed by ANU materials scientist Mr. Tony Flynn, allows water filters to be made from commonly available materials and fired on the ground using cow manure as the source of heat, without the need for a kiln. The filters have been tested and shown to remove common pathogens (disease-producing organisms) including E-coli. Unlike other water filtering devices, the filters are simple and inexpensive to make. “They are very simple to explain and demonstrate and can be made by anyone, anywhere,” says Mr. Flynn. “They don’t require any western technology. All you need is terracotta clay, a compliant cow and a match.”

C . The production of the filters is extremely simple. Take a handful of dry, crushed clay, mix it with a handful of organic material, such as used tea leaves, coffee grounds or rice hulls , add enough water to make a stiff biscuit-like mixture and form a cylindrical pot that has one end closed, then dry it in the sun. According to Mr. Flynn, used coffee grounds have given the best results to date. Next, surround the pots with straw; put them in a mound of cow manure, light the straw and then top up the burning manure as required. In less than 60 minutes the filters are finished. The walls of the finished pot should be about as thick as an adult’s index. The properties of cow manure are vital as the fuel can reach a temperature of 700 degrees in half an hour and will be up to 950 degrees after another 20 to 30 minutes. The manure makes a good fuel because it is very high in organic material that bums readily and quickly; the manure has to be dry and is best used exactly as found in the field, there is no need to break it up or process it any further.

D . “A potter’s din is an expensive item and can could take up to four or five hours to get upto 800 degrees. It needs expensive or scarce fuel, such as gas or wood to heat it and experience to run it. With no technology, no insulation and nothing other than a pile of cow manure and a match, none of these restrictions apply,” Mr. Flynn says.

E . It is also helpful that, like terracotta clay and organic material, cow dung is freely available across the developing world. “A cow is a natural fuel factory. My understanding is that cow dung as a fuel would be pretty much the same wherever you would find it.” Just as using manure as a fuel for domestic uses is not a new idea, the porosity of clay is something that potters have known about for years, and something that as a former ceramics lecturer in the ANU School of Art, Mr. Flynn is well aware of. The difference is that rather than viewing the porous nature of the material as a problem — after all not many people want a pot that won’t hold water — his filters capitalize on this property.

F . Other commercial ceramic filters do exist, but, even if available, with prices starting at US$5 each, they are often outside the budgets of most people in the developing world. The filtration process is simple, but effective. The basic principle is that there are passages through the filter that are wide enough for water droplets to pass through, but too narrow for pathogens. Tests with the deadly E-coli bacterium have seen the filters remove 96.4 to 99.8 per cent of the pathogen — well within safe levels. Using only one filter it takes two hours to filter a litre of water. The use of organic material, which burns away after firing, helps produce the structure in which pathogens will become trapped. It overcomes the potential problems of finer clays that may not let water through and also means that cracks are soon halted. And like clay and cow dung, it is universally available.

G . The invention was born out of a World Vision project involving the Manatuto community in East Timor The charity wanted to help set up a small industry manufacturing water filters, but initial research found the local clay to be too fine — a problem solved by the addition of organic material. While the AF problems of producing a working ceramic filter in East Timor were overcome, the solution was kiln-based and particular to that community’s materials and couldn’t be applied elsewhere. Manure firing, with no requirement for a kiln, has made this zero technology approach available anywhere it is needed. With all the components being widely available, Mr. Flynn says there is no reason the technology couldn’t be applied throughout the developing world, and with no plans to patent his idea, there will be no legal obstacles to it being adopted in any community that needs it. “Everyone has a right to clean water, these filters have the potential to enable anyone in the world to drink water safely,” says Mr. Flynn.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('d77e3a1f-3acb-5d30-ab7c-1ccb3719c468', '2d751526-3b03-51e7-bc8c-b38d7132d1c9', 1, 'SHORT_ANSWER', 'READING', 2, $md$### Question 1

Questions 1-6
Questions 1-6
Complete the flow chart, using
NO MORE THAN TWO WORDS
from the Reading Passage for each answer.
Write your answers in boxes
1-6
on your answer sheet.
Guide to Making Water Filters
Step one: combination of
1
and organic material, with sufficient
2
to create a thick mixture sun dried.
Step two: pack
3
around the cylinders place them in
4
which is as burning fuel for firing (maximum temperature:
5
) filter being baked in under
6

Step one: combination of 1 ____ and organic material, with sufficient 2 ____ to create a thick mixture sun dried.$md$, NULL, ARRAY['.*clay.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('2914fd85-edca-5069-b52d-31520600cbcc', '2d751526-3b03-51e7-bc8c-b38d7132d1c9', 2, 'SHORT_ANSWER', 'READING', 2, $md$### Question 2

Questions 1-6
Questions 1-6
Complete the flow chart, using
NO MORE THAN TWO WORDS
from the Reading Passage for each answer.
Write your answers in boxes
1-6
on your answer sheet.
Guide to Making Water Filters
Step one: combination of
1
and organic material, with sufficient
2
to create a thick mixture sun dried.
Step two: pack
3
around the cylinders place them in
4
which is as burning fuel for firing (maximum temperature:
5
) filter being baked in under
6

Step one: combination of 1 ____ and organic material, with sufficient 2 ____ to create a thick mixture sun dried.$md$, NULL, ARRAY['.*clay.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('e34d4857-bf81-5d06-a982-ab98e66d61e1', '2d751526-3b03-51e7-bc8c-b38d7132d1c9', 3, 'SHORT_ANSWER', 'READING', 2, $md$### Question 3

Questions 1-6
Questions 1-6
Complete the flow chart, using
NO MORE THAN TWO WORDS
from the Reading Passage for each answer.
Write your answers in boxes
1-6
on your answer sheet.
Guide to Making Water Filters
Step one: combination of
1
and organic material, with sufficient
2
to create a thick mixture sun dried.
Step two: pack
3
around the cylinders place them in
4
which is as burning fuel for firing (maximum temperature:
5
) filter being baked in under
6

Step two: pack 3 ____ around the cylinders place them in 4 ____ which is as burning fuel for firing (maximum temperature: 5 ____ ) filter being baked in under 6 ____$md$, NULL, ARRAY['.*straw.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('0f19a8db-f758-571f-89fc-33b48082d5eb', '2d751526-3b03-51e7-bc8c-b38d7132d1c9', 4, 'SHORT_ANSWER', 'READING', 2, $md$### Question 4

Questions 1-6
Questions 1-6
Complete the flow chart, using
NO MORE THAN TWO WORDS
from the Reading Passage for each answer.
Write your answers in boxes
1-6
on your answer sheet.
Guide to Making Water Filters
Step one: combination of
1
and organic material, with sufficient
2
to create a thick mixture sun dried.
Step two: pack
3
around the cylinders place them in
4
which is as burning fuel for firing (maximum temperature:
5
) filter being baked in under
6

Step two: pack 3 ____ around the cylinders place them in 4 ____ which is as burning fuel for firing (maximum temperature: 5 ____ ) filter being baked in under 6 ____$md$, NULL, ARRAY['.*straw.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('04e7ca36-de09-5fc9-9a7c-c9c911058e19', '2d751526-3b03-51e7-bc8c-b38d7132d1c9', 5, 'SHORT_ANSWER', 'READING', 3, $md$### Question 5

Questions 1-6
Questions 1-6
Complete the flow chart, using
NO MORE THAN TWO WORDS
from the Reading Passage for each answer.
Write your answers in boxes
1-6
on your answer sheet.
Guide to Making Water Filters
Step one: combination of
1
and organic material, with sufficient
2
to create a thick mixture sun dried.
Step two: pack
3
around the cylinders place them in
4
which is as burning fuel for firing (maximum temperature:
5
) filter being baked in under
6

Step two: pack 3 ____ around the cylinders place them in 4 ____ which is as burning fuel for firing (maximum temperature: 5 ____ ) filter being baked in under 6 ____$md$, NULL, ARRAY['.*straw.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('288eb59b-ffa3-5707-8c67-7e7c2e898705', '2d751526-3b03-51e7-bc8c-b38d7132d1c9', 6, 'SHORT_ANSWER', 'READING', 3, $md$### Question 6

Questions 1-6
Questions 1-6
Complete the flow chart, using
NO MORE THAN TWO WORDS
from the Reading Passage for each answer.
Write your answers in boxes
1-6
on your answer sheet.
Guide to Making Water Filters
Step one: combination of
1
and organic material, with sufficient
2
to create a thick mixture sun dried.
Step two: pack
3
around the cylinders place them in
4
which is as burning fuel for firing (maximum temperature:
5
) filter being baked in under
6

Step two: pack 3 ____ around the cylinders place them in 4 ____ which is as burning fuel for firing (maximum temperature: 5 ____ ) filter being baked in under 6 ____$md$, NULL, ARRAY['.*straw.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('3acd590b-2564-5370-a0f8-5795e09a0aa0', '2d751526-3b03-51e7-bc8c-b38d7132d1c9', 7, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 7

Questions 7-10
Questions 7-10
Do the following statements agree with the information given in
Reading Passage
?
In boxes
7-10
on your answer sheet, write
TRUE
if the statement is true
FALSE
if the statement is false
NOT GIVEN
if the information is not given in the passage
7
It takes half an hour for the manure to reach 950 degrees
8
Clay was initially found to be unsuitable for pot making
9
Coffee grounds are twice as effective as other materials
10
E-coli is the most difficult bacteria to combat

7 ____ It takes half an hour for the manure to reach 950 degrees$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c52b9632-e505-59be-a536-373f7a765466', '3acd590b-2564-5370-a0f8-5795e09a0aa0', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d2714252-0d5d-584a-ab78-b9f8dd9c7223', '3acd590b-2564-5370-a0f8-5795e09a0aa0', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cbfb68d7-793f-5be7-8c1c-4d631a0180d0', '3acd590b-2564-5370-a0f8-5795e09a0aa0', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('96a3c0ea-4133-54fb-bba5-27a622da8382', '2d751526-3b03-51e7-bc8c-b38d7132d1c9', 8, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 8

Questions 7-10
Questions 7-10
Do the following statements agree with the information given in
Reading Passage
?
In boxes
7-10
on your answer sheet, write
TRUE
if the statement is true
FALSE
if the statement is false
NOT GIVEN
if the information is not given in the passage
7
It takes half an hour for the manure to reach 950 degrees
8
Clay was initially found to be unsuitable for pot making
9
Coffee grounds are twice as effective as other materials
10
E-coli is the most difficult bacteria to combat

8 ____ Clay was initially found to be unsuitable for pot making$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('88bb9ddb-7af1-538d-8192-c302bd43b503', '96a3c0ea-4133-54fb-bba5-27a622da8382', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8f631634-4021-5f41-b3e1-ce462fe61ce0', '96a3c0ea-4133-54fb-bba5-27a622da8382', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('859c139b-dfa9-5c71-980d-cde255b3ed1b', '96a3c0ea-4133-54fb-bba5-27a622da8382', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('b4f84934-051d-593a-a54d-04b359a0cbb5', '2d751526-3b03-51e7-bc8c-b38d7132d1c9', 9, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 9

Questions 7-10
Questions 7-10
Do the following statements agree with the information given in
Reading Passage
?
In boxes
7-10
on your answer sheet, write
TRUE
if the statement is true
FALSE
if the statement is false
NOT GIVEN
if the information is not given in the passage
7
It takes half an hour for the manure to reach 950 degrees
8
Clay was initially found to be unsuitable for pot making
9
Coffee grounds are twice as effective as other materials
10
E-coli is the most difficult bacteria to combat

9 ____ Coffee grounds are twice as effective as other materials$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d524bf84-4ac6-51ba-9fb7-4d0d530d549e', 'b4f84934-051d-593a-a54d-04b359a0cbb5', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a8e7f613-7aa4-5080-a6c8-9587b74d94f6', 'b4f84934-051d-593a-a54d-04b359a0cbb5', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('40c4ce93-378d-5dd4-9f47-20377c6e802e', 'b4f84934-051d-593a-a54d-04b359a0cbb5', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('e72a165b-3cf4-5640-bd6f-1a430162289e', '2d751526-3b03-51e7-bc8c-b38d7132d1c9', 10, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 10

Questions 7-10
Questions 7-10
Do the following statements agree with the information given in
Reading Passage
?
In boxes
7-10
on your answer sheet, write
TRUE
if the statement is true
FALSE
if the statement is false
NOT GIVEN
if the information is not given in the passage
7
It takes half an hour for the manure to reach 950 degrees
8
Clay was initially found to be unsuitable for pot making
9
Coffee grounds are twice as effective as other materials
10
E-coli is the most difficult bacteria to combat

10 ____ E-coli is the most difficult bacteria to combat$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5bdf33f1-fc91-527b-ab03-2154930b113e', 'e72a165b-3cf4-5640-bd6f-1a430162289e', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('68631c7a-3b78-57fd-8a42-4c7db53f0b1a', 'e72a165b-3cf4-5640-bd6f-1a430162289e', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c525f8c5-c41b-57ff-87a6-113f00e8c785', 'e72a165b-3cf4-5640-bd6f-1a430162289e', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('10e48a95-4234-59a0-86f5-a3794ece7b02', '2d751526-3b03-51e7-bc8c-b38d7132d1c9', 11, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 11

Questions 11-13
Questions 11-13
Choose the correct letter,
A, B, C or D.
Write your answers in boxes
11-13
on your answer sheet.
11. When making the pot, the thickness of the wall
A
is large enough to let the pathogens to pass.
B
varied according to the temperature of the fuel,
C
should be the same as an adult’s forefinger.
D
is not mentioned by Mr. Flynn.
12. What is true about
the charity, it
A
failed in searching the appropriate materials.
B
successfully manufacture a kiln based ceramic filter to be sold worldwide
C
found that the local clay are good enough.
D
intended to help build a local filter production factory.
13. Mr. Flynn’s design is purposely not being patented
A
because he hopes it can be freely used around the world
B
because he doesn’t think the technology is perfect enough,
C
because there are some legal obstacles.
D
because the design has already been applied thoroughly.

Choose the correct letter, A, B, C or D.$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('09485f72-139c-50d4-9850-a398b5561ea8', '2d751526-3b03-51e7-bc8c-b38d7132d1c9', 12, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 12

Questions 11-13
Questions 11-13
Choose the correct letter,
A, B, C or D.
Write your answers in boxes
11-13
on your answer sheet.
11. When making the pot, the thickness of the wall
A
is large enough to let the pathogens to pass.
B
varied according to the temperature of the fuel,
C
should be the same as an adult’s forefinger.
D
is not mentioned by Mr. Flynn.
12. What is true about
the charity, it
A
failed in searching the appropriate materials.
B
successfully manufacture a kiln based ceramic filter to be sold worldwide
C
found that the local clay are good enough.
D
intended to help build a local filter production factory.
13. Mr. Flynn’s design is purposely not being patented
A
because he hopes it can be freely used around the world
B
because he doesn’t think the technology is perfect enough,
C
because there are some legal obstacles.
D
because the design has already been applied thoroughly.

Choose the correct letter, A, B, C or D.$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('d269ff53-44d1-5d30-a445-d59aabcc4f5e', '2d751526-3b03-51e7-bc8c-b38d7132d1c9', 13, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 13

Questions 11-13
Questions 11-13
Choose the correct letter,
A, B, C or D.
Write your answers in boxes
11-13
on your answer sheet.
11. When making the pot, the thickness of the wall
A
is large enough to let the pathogens to pass.
B
varied according to the temperature of the fuel,
C
should be the same as an adult’s forefinger.
D
is not mentioned by Mr. Flynn.
12. What is true about
the charity, it
A
failed in searching the appropriate materials.
B
successfully manufacture a kiln based ceramic filter to be sold worldwide
C
found that the local clay are good enough.
D
intended to help build a local filter production factory.
13. Mr. Flynn’s design is purposely not being patented
A
because he hopes it can be freely used around the world
B
because he doesn’t think the technology is perfect enough,
C
because there are some legal obstacles.
D
because the design has already been applied thoroughly.

Choose the correct letter, A, B, C or D.$md$, NULL);

COMMIT;
