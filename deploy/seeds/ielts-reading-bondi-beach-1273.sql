BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-bondi-beach-1273'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-bondi-beach-1273';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-bondi-beach-1273';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-bondi-beach-1273';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('8b54a1bf-fa79-5367-adfe-2d01131a99dd', 'ielts-reading-bondi-beach-1273', $t$Bondi Beach$t$, $md$## Bondi Beach

Nguồn:
- Test: https://mini-ielts.com/1273/reading/bondi-beach
- Solution: https://mini-ielts.com/1273/view-solution/reading/bondi-beach$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('2bea6306-a9c2-5165-8001-873422f904e7', '8b54a1bf-fa79-5367-adfe-2d01131a99dd', 1, $t$Reading — Bondi Beach$t$, $md$Read the passage and answer questions **1–13**.

### Passage: Bondi Beach

A

Bondi Beach, Australia’s most famous beach, is located in the suburb of Bondi, in the Local Government Area of Waverley, seven kilometers from the centre of Sydney. “Bondi” or “Boondi” is an Aboriginal word meaning water breaking over rocks or the sound of breaking waves. The Australian Museum records that Bondi means a place where a flight of nullas took place. There are Aboriginal Rock carving on the northern end of the beach at Ben Buckler and south of Bondi Beach near McKenzies Beach on the coastal walk.

B

The indigenous people of the area at the time of European settlement have generally been welcomed to as the Sydney people or the Eora (Eora means “the people”). One theory describes the Eora as a sub-group of the Darug language group which occupied the Cumberland Plain west to the Blue Mountains. However, another theory suggests that they were a distinct language group of their own. There is no clear evidence for the name or names of the particular band(s) of the Eora that roamed what is now the Waverley area. A number of place names within Waverley, most famously Bondi, have been based on words derived from Aboriginal languages of the Sydney region.

C

From the mid-1800s Bondi Beach was a favourite location for family outings and picnics. The beginnings of the suburb go back to 1809, when the early road builder, William Roberts, received from Governor Bligh a grant of 81 hectares of what is now most of the business and residential area of Bondi Beach. In 1851, Edward Smith Hall and Francis O’Brien purchased 200 acres of the Bondi area that embraced almost the whole frontage of Bondi Beach, and it was named the “The Bondi Estate.” Between 1855 and 1877 O’Brien purchased Hall’s share of the land, renamed the land the “O’Brien Estate,” and made the beach and the surrounding land available to the public as a picnic ground and amusement resort. As the beach became increasingly popular, O’Brien threatened to stop public beach access. However, the Municipal Council believed that the Government needed to intervene to make the beach a public reserve.

D

During the 1900s beach became associated with health, leisure and democracy – a playground everyone could enjoy equally. Bondi Beach was a working-class suburb throughout most of the twentieth century with migrant people from New Zealand comprising the majority of the local population. The first tramway reached the beach in 1884. Following this, tram became the first public transportation in Bondi. As an alternative, this action changed the rule that only rich people can enjoy the beach. By the 1930s Bondi was drawing not only local visitors but also people from elsewhere in Australia and overseas. Advertising at the time referred to Bondi Beach as the “Playground of the Pacific”.

E

There is a growing trend that people prefer having to relax near seaside instead of living unhealthily in cities. The increasing popularity of sea bathing during the late 1800s and early 1900s raised concerns about public safety and how to prevent people from drowning. In response, the world’s first formally documented surf lifesaving club, the Bondi Surf Bathers’ Life Saving Club, was formed in 1907. This was powerfully reinforced by the dramatic events of “Black Sunday” at Bondi in 1938. Some 35,000 people were on the beach and a large group of lifesavers were about to start a surf race when three freak waves hit the beach, sweeping hundreds of people out to sea. Lifesavers rescued 300 people. The largest mass rescue in the history of surf bathing, it confirmed the place of the lifesaver in the national imagination.

F

Bondi Beach is the endpoint of the City to Surf Fun Run which is held each year in August. Australian surf carnivals further instilled this image. A Royal Surf Carnival was held at Bondi Beach for Queen Elizabeth II during her first visited in Australia in 1954. Since 1867, there have been over fifty visits by a member of the British Royal Family to Australia. In addition to many activities, the Bondi Beach Markets is open every Sunday. Many wealthy people spend Christmas Day at the beach. However, the shortage of houses occurs when lots of people crushed to the seaside. Manly is the seashore town which solved this problem. However, people still choose Bondi as the satisfied destination rather than Manly.

G

Bondi Beach has a commercial area along Campbell Parade and adjacent side streets, featuring many popular cafes, restaurants, and hotels, with views of the contemporary beach. It is depicted as wholly modern and European. In the last decade, Bondi Beaches’ unique position has seen a dramatic rise in svelte houses and apartments to take advantage of the views and scent of the sea. The valley running down to the beach is the famous world over for its view of distinctive red-tiled roofs. Those architectures are deeply influenced by British coastal town.

H

Bondi Beach hosted the beach volleyball competition at the 2000 Summer Olympics. A temporary 10,000-seat stadium, a much smaller stadium, 2 warm-up courts, and 3 training courts were set up to host the tournament. The Bondi Beach Volleyball Stadium was constructed for it and stood for just six weeks. Campaigners oppose both the social and environmental consequences of the development. The stadium will divide the beach in two and seriously restrict public access for swimming, walking, and other forms of outdoor recreation. People protest for their human rights of having a pure seaside and argue for health life in Bondi.

I

“They’re prepared to risk lives and risk the Bondi beach environment for the sake of eight days of volleyball”, said Stephen Uniacke, a construction lawyer involved in the campaign. Other environmental concerns include the possibility that soil dredged up from below the sand will acidify when brought to the surface.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('e8f70abd-c793-5946-914d-a5aa69723aca', '2bea6306-a9c2-5165-8001-873422f904e7', 1, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 1

Questions 1-5
Questions 1-5
Do the following statements agree with the information given in Reading Passage 1?
In boxes
1-5
on your answer sheet, write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT
GIVEN
if there is no information on this
1
The name of the Bondi beach is first called by the British settlers.
2
The aboriginal culture in Australia is different when compared with European culture.
3
Bondi beach area holds many contemporary hotels
4
The seaside town in Bondi is affected by British culture for its characteristic red color
5
Living near Bondi seashore is not beneficial for health.

1 ____ The name of the Bondi beach is first called by the British settlers.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cbec38ba-d648-56eb-ba21-04a3ce756080', 'e8f70abd-c793-5946-914d-a5aa69723aca', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ed4293a9-83c8-5b29-a1fe-41fb192f457e', 'e8f70abd-c793-5946-914d-a5aa69723aca', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1662bf5a-73f5-5baf-ac14-eb5fa1fea3b3', 'e8f70abd-c793-5946-914d-a5aa69723aca', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('2ca0ca19-0814-510c-9dc1-b90f90069ed4', '2bea6306-a9c2-5165-8001-873422f904e7', 2, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 2

Questions 1-5
Questions 1-5
Do the following statements agree with the information given in Reading Passage 1?
In boxes
1-5
on your answer sheet, write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT
GIVEN
if there is no information on this
1
The name of the Bondi beach is first called by the British settlers.
2
The aboriginal culture in Australia is different when compared with European culture.
3
Bondi beach area holds many contemporary hotels
4
The seaside town in Bondi is affected by British culture for its characteristic red color
5
Living near Bondi seashore is not beneficial for health.

2 ____ The aboriginal culture in Australia is different when compared with European culture.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('65c0c679-7384-592e-89c2-1ff848b5b14c', '2ca0ca19-0814-510c-9dc1-b90f90069ed4', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('316ba93c-ec62-52ed-b077-16fd4ec522fa', '2ca0ca19-0814-510c-9dc1-b90f90069ed4', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3adbd5e2-ffa9-5938-8db1-15638a363a12', '2ca0ca19-0814-510c-9dc1-b90f90069ed4', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('2afdd4a9-421b-52e6-90a0-90bb5531290e', '2bea6306-a9c2-5165-8001-873422f904e7', 3, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 3

Questions 1-5
Questions 1-5
Do the following statements agree with the information given in Reading Passage 1?
In boxes
1-5
on your answer sheet, write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT
GIVEN
if there is no information on this
1
The name of the Bondi beach is first called by the British settlers.
2
The aboriginal culture in Australia is different when compared with European culture.
3
Bondi beach area holds many contemporary hotels
4
The seaside town in Bondi is affected by British culture for its characteristic red color
5
Living near Bondi seashore is not beneficial for health.

3 ____ Bondi beach area holds many contemporary hotels$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('976ae16a-e056-57f4-913a-cb0e6acf511c', '2afdd4a9-421b-52e6-90a0-90bb5531290e', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4c674449-31f6-591b-8f28-c229a91721f9', '2afdd4a9-421b-52e6-90a0-90bb5531290e', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('66ba8d0c-2350-5030-a9a1-1c26368f7432', '2afdd4a9-421b-52e6-90a0-90bb5531290e', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('da500945-a4bc-56fb-b171-66a19e2e424b', '2bea6306-a9c2-5165-8001-873422f904e7', 4, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 4

Questions 1-5
Questions 1-5
Do the following statements agree with the information given in Reading Passage 1?
In boxes
1-5
on your answer sheet, write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT
GIVEN
if there is no information on this
1
The name of the Bondi beach is first called by the British settlers.
2
The aboriginal culture in Australia is different when compared with European culture.
3
Bondi beach area holds many contemporary hotels
4
The seaside town in Bondi is affected by British culture for its characteristic red color
5
Living near Bondi seashore is not beneficial for health.

4 ____ The seaside town in Bondi is affected by British culture for its characteristic red color$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2dcb6ab9-6773-5c99-b692-b75b4184ccf0', 'da500945-a4bc-56fb-b171-66a19e2e424b', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('97be3fa5-26b9-54b9-b9e2-58f9bd8fd04f', 'da500945-a4bc-56fb-b171-66a19e2e424b', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c0546239-cf13-5037-8661-76132ca67029', 'da500945-a4bc-56fb-b171-66a19e2e424b', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('8b060c75-af8a-51e9-9459-5f33d9373fe1', '2bea6306-a9c2-5165-8001-873422f904e7', 5, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 5

Questions 1-5
Questions 1-5
Do the following statements agree with the information given in Reading Passage 1?
In boxes
1-5
on your answer sheet, write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT
GIVEN
if there is no information on this
1
The name of the Bondi beach is first called by the British settlers.
2
The aboriginal culture in Australia is different when compared with European culture.
3
Bondi beach area holds many contemporary hotels
4
The seaside town in Bondi is affected by British culture for its characteristic red color
5
Living near Bondi seashore is not beneficial for health.

5 ____ Living near Bondi seashore is not beneficial for health.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e3aa4a2e-c482-5b42-9a9c-b1e5f20a546b', '8b060c75-af8a-51e9-9459-5f33d9373fe1', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7f7e709f-bb0f-5e6f-b3eb-be4958b226eb', '8b060c75-af8a-51e9-9459-5f33d9373fe1', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('57af02d8-7bf9-5b63-9462-1801c518efc6', '8b060c75-af8a-51e9-9459-5f33d9373fe1', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('8045684a-14c1-52e0-86a3-1b6e40e95cef', '2bea6306-a9c2-5165-8001-873422f904e7', 6, 'SHORT_ANSWER', 'READING', 3, $md$### Question 6

Questions 6-9
Questions 6-9
Answer the questions below using
NO MORE THAN TWO WORDS AND/OR NUMBERS
from the passage for each answer.
Write your answers in boxes
6-9
on your answer sheet
6
At the end of the 19th century, which public transport did people use to go to Bondi?
7
When did the British Royalty first visit Bondi?
8
Which Olympic event did Bondi hold in the 2000 Sydney Olympic games?
9
What would be damaged if the stadium was built for that Olympic event?

6 ____ At the end of the 19th century, which public transport did people use to go to Bondi?$md$, NULL, ARRAY['.*tram.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('0b85139f-4fec-5482-93d2-bc821db0b8cd', '2bea6306-a9c2-5165-8001-873422f904e7', 7, 'SHORT_ANSWER', 'READING', 3, $md$### Question 7

Questions 6-9
Questions 6-9
Answer the questions below using
NO MORE THAN TWO WORDS AND/OR NUMBERS
from the passage for each answer.
Write your answers in boxes
6-9
on your answer sheet
6
At the end of the 19th century, which public transport did people use to go to Bondi?
7
When did the British Royalty first visit Bondi?
8
Which Olympic event did Bondi hold in the 2000 Sydney Olympic games?
9
What would be damaged if the stadium was built for that Olympic event?

7 ____ When did the British Royalty first visit Bondi?$md$, NULL, ARRAY['.*1954.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('6ada0f65-3a75-529d-bbed-f049372b799f', '2bea6306-a9c2-5165-8001-873422f904e7', 8, 'SHORT_ANSWER', 'READING', 3, $md$### Question 8

Questions 6-9
Questions 6-9
Answer the questions below using
NO MORE THAN TWO WORDS AND/OR NUMBERS
from the passage for each answer.
Write your answers in boxes
6-9
on your answer sheet
6
At the end of the 19th century, which public transport did people use to go to Bondi?
7
When did the British Royalty first visit Bondi?
8
Which Olympic event did Bondi hold in the 2000 Sydney Olympic games?
9
What would be damaged if the stadium was built for that Olympic event?

8 ____ Which Olympic event did Bondi hold in the 2000 Sydney Olympic games?$md$, NULL, ARRAY['.*beach.*volleyball.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('847dea30-0c5e-558a-a8fa-fb0eac422c54', '2bea6306-a9c2-5165-8001-873422f904e7', 9, 'SHORT_ANSWER', 'READING', 3, $md$### Question 9

Questions 6-9
Questions 6-9
Answer the questions below using
NO MORE THAN TWO WORDS AND/OR NUMBERS
from the passage for each answer.
Write your answers in boxes
6-9
on your answer sheet
6
At the end of the 19th century, which public transport did people use to go to Bondi?
7
When did the British Royalty first visit Bondi?
8
Which Olympic event did Bondi hold in the 2000 Sydney Olympic games?
9
What would be damaged if the stadium was built for that Olympic event?

9 ____ What would be damaged if the stadium was built for that Olympic event?$md$, NULL, ARRAY['.*environment.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('beb7c09e-e822-5e96-8ba0-a8977ac50095', '2bea6306-a9c2-5165-8001-873422f904e7', 10, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 10

Questions 10-13
Questions 10-13
Summary
Complete the following summary of the paragraphs of Reading Passage, using
NO MORE THAN
TWO WORDS
from the Reading Passage for each answer.
Write your answers in boxes
10-13
on your answer sheet.
Bondi beach holds the feature sports activities every year, which attracts lo of
10
. Choosing to live at this place during the holidays. But local accommodation cannot meet with the expanding population, a nearby town of
11
. is the first suburb site to support the solution, yet people prefer
12
as their best choice. Its seaside buildings are well-known in the world for the special scenic colored
13
on buildings and the joyful smell from the sea.

Bondi beach holds the feature sports activities every year, which attracts lo of 10 ____ . Choosing to live at this place during the holidays. But local accommodation cannot meet with the expanding population, a nearby town of 11 ____ . is the first suburb site to support the solution, yet people prefer 12 ____ as their best choice. Its seaside buildings are well-known in the world for the special scenic colored 13 ____ on buildings and the joyful smell from the sea.$md$, NULL, ARRAY['.*wealthy.*people.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('47d32eae-5f60-5ac9-8228-43c4939161d0', '2bea6306-a9c2-5165-8001-873422f904e7', 11, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 11

Questions 10-13
Questions 10-13
Summary
Complete the following summary of the paragraphs of Reading Passage, using
NO MORE THAN
TWO WORDS
from the Reading Passage for each answer.
Write your answers in boxes
10-13
on your answer sheet.
Bondi beach holds the feature sports activities every year, which attracts lo of
10
. Choosing to live at this place during the holidays. But local accommodation cannot meet with the expanding population, a nearby town of
11
. is the first suburb site to support the solution, yet people prefer
12
as their best choice. Its seaside buildings are well-known in the world for the special scenic colored
13
on buildings and the joyful smell from the sea.

Bondi beach holds the feature sports activities every year, which attracts lo of 10 ____ . Choosing to live at this place during the holidays. But local accommodation cannot meet with the expanding population, a nearby town of 11 ____ . is the first suburb site to support the solution, yet people prefer 12 ____ as their best choice. Its seaside buildings are well-known in the world for the special scenic colored 13 ____ on buildings and the joyful smell from the sea.$md$, NULL, ARRAY['.*wealthy.*people.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('7eecde28-83c5-5798-9510-45384cb5b225', '2bea6306-a9c2-5165-8001-873422f904e7', 12, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 12

Questions 10-13
Questions 10-13
Summary
Complete the following summary of the paragraphs of Reading Passage, using
NO MORE THAN
TWO WORDS
from the Reading Passage for each answer.
Write your answers in boxes
10-13
on your answer sheet.
Bondi beach holds the feature sports activities every year, which attracts lo of
10
. Choosing to live at this place during the holidays. But local accommodation cannot meet with the expanding population, a nearby town of
11
. is the first suburb site to support the solution, yet people prefer
12
as their best choice. Its seaside buildings are well-known in the world for the special scenic colored
13
on buildings and the joyful smell from the sea.

Bondi beach holds the feature sports activities every year, which attracts lo of 10 ____ . Choosing to live at this place during the holidays. But local accommodation cannot meet with the expanding population, a nearby town of 11 ____ . is the first suburb site to support the solution, yet people prefer 12 ____ as their best choice. Its seaside buildings are well-known in the world for the special scenic colored 13 ____ on buildings and the joyful smell from the sea.$md$, NULL, ARRAY['.*wealthy.*people.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('f1863a57-829f-57e1-aa9e-afdf8efbcb6b', '2bea6306-a9c2-5165-8001-873422f904e7', 13, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 13

Questions 10-13
Questions 10-13
Summary
Complete the following summary of the paragraphs of Reading Passage, using
NO MORE THAN
TWO WORDS
from the Reading Passage for each answer.
Write your answers in boxes
10-13
on your answer sheet.
Bondi beach holds the feature sports activities every year, which attracts lo of
10
. Choosing to live at this place during the holidays. But local accommodation cannot meet with the expanding population, a nearby town of
11
. is the first suburb site to support the solution, yet people prefer
12
as their best choice. Its seaside buildings are well-known in the world for the special scenic colored
13
on buildings and the joyful smell from the sea.

Bondi beach holds the feature sports activities every year, which attracts lo of 10 ____ . Choosing to live at this place during the holidays. But local accommodation cannot meet with the expanding population, a nearby town of 11 ____ . is the first suburb site to support the solution, yet people prefer 12 ____ as their best choice. Its seaside buildings are well-known in the world for the special scenic colored 13 ____ on buildings and the joyful smell from the sea.$md$, NULL, ARRAY['.*wealthy.*people.*']);

COMMIT;
