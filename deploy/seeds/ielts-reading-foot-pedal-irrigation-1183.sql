BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-foot-pedal-irrigation-1183'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-foot-pedal-irrigation-1183';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-foot-pedal-irrigation-1183';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-foot-pedal-irrigation-1183';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('9ed82281-1023-5cd2-94ad-a1dbd5185090', 'ielts-reading-foot-pedal-irrigation-1183', $t$Foot Pedal Irrigation$t$, $md$## Foot Pedal Irrigation

Nguồn:
- Test: https://mini-ielts.com/1183/reading/foot-pedal-irrigation
- Solution: https://mini-ielts.com/1183/view-solution/reading/foot-pedal-irrigation$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('139f627b-6007-5879-9590-484b39c2a306', '9ed82281-1023-5cd2-94ad-a1dbd5185090', 1, $t$Reading — Foot Pedal Irrigation$t$, $md$Read the passage and answer questions **1–13**.

### Passage: Foot Pedal Irrigation

A Until now, governments and development agencies have tried to tackle the problem through large-scale projects: gigantic dams, sprawling, irrigation canals and vast new fields of high-yield crops introduced during the Green Revolution, the famous campaign to increase grain harvests in developing nations. Traditional irrigation, however, has degraded the soil in many areas, and the reservoirs behind dams can quickly fill up with silt, reducing their storage capacity and depriving downstream farmers of fertile sediments. Furthermore, although the Green Revolution has greatly expanded worldwide farm production since 1950 , poverty stubbornly persists in Africa, Asia and Latin America. Continued improvements in the productivity of large farms may play the main role in boosting food supply, but local efforts to provide cheap, individual irrigation systems to small farms may offer a better way to lift people out of poverty.

B The Green Revolution was designed to increase the overall food supply, not to raise the incomes of the rural poor, so it should be no surprise that it did not eradicate poverty or hunger. India, for example, has been self-sufficient in food for 15 years, and its granaries are full, but more than 200 million Indians – one fifth of the country’s population – are malnourished because they cannot afford the food they need and because the country’s safety nets are deficient. In 2000, 189 nations committed to the Millennium Development Goals, which called for cutting world poverty in half by 2015. With business as usual, however, we have little hope of achieving most of the Millennium goals, no matter how much money rich countries contribute to poor ones.

C The supply-driven strategies of the Green Revolution, however, may not help subsistence farmers, who must play to their strengths to compete in the global marketplace. The average size of a family farm is less than four acres in India, 1.8 acres in Bangladesh and about half an acre in China. Combines and other modern farming tools are too expensive to be used on such small areas. An Indian farmer selling surplus wheat grown on his one-acre plot could not possibly compete with the highly efficient and subsidized Canadian wheat farms that typically stretch over thousands of acres. Instead subsistence farmers should exploit the fact that their labor costs are the lowest in the world, giving them a comparative advantage in growing and selling high-value, intensely farmed crops.

D Paul Polak saw firsthand the need for a small-scale strategy in 1981 when he met Abdul Rahman, a farmer in the Noakhali district of Bangladesh. From his three quarter-acre plots of rain-fed rice fields, Abdul could grow only 700 kilograms of rice each year – 300 kilograms less than what he needed to feed his family. During the three months before the October rice harvest came in, Abdul and his wife had to watch silently while their three children survived on one meal a day or less. As Polak walked with him through the scattered fields he had inherited from his father, Polak asked what he needed to move out of poverty. “ Control of water for my crops ,” he said, “at a price I can afford.”

E Soon Polak learned about a simple device that could help Abdul achieve his goal: the treadle pump. Developed in the late 1970s by Norwegian engineer Gunnar Barnes, the pump is operated by a person walking in place on a pair of treadles and two handle arms made of bamboo . Properly adjusted and maintained, it can be operated several hours a day without tiring the users. Each treadle pump has two cylinders which are made of engineering plastic. The diameter of a cylinder is 100.5mm and the height is 280mm. The pump is capable of working up to a maximum depth of 7 meters. Operation beyond 7 meters is not recommended to preserve the integrity of the rubber components. The pump mechanism has piston and foot valve assemblies. The treadle action creates alternate strokes in the two pistons that lift the water in pulses.

F The human-powered pump can irrigate half an acre of vegetables and costs only $25 (including the expense of drilling a tube well down to the groundwater). Abdul heard about the treadle pump from a cousin and was one of the first farmers in Bangladesh to buy one. He borrowed the $25 from an uncle and easily repaid the loan four months later. During the five-month dry season, when Bangladeshis typically farm very little, Abdul used the treadle pump to grow a quarter-acre of chili peppers, tomatoes, cabbage and eggplants. He also improved the yield of one of his rice plots by irrigating it. His family ate some of the vegetables and sold the rest at the village market, earning a net profit of $100. With his new income, Abdul was able to buy rice for his family to eat, keep his two sons in school until they were 16 and set aside a little money for his daughter’s dowry. When Polak visited him again in 1984, he had doubled the size of his vegetable plot and replaced the thatched roof on his house with corrugated tin . His family was raising a calf and some chickens. He told me that the treadle pump was a gift from God.

G Bangladesh is particularly well suited for the treadle pump because a huge reservoir of groundwater lies just a few meters below the farmers’ feet. In the early 1980s IDE initiated a campaign to market the pump, encouraging 75 small private-sector companies to manufacture the devices and several thousand village dealers and tube-well drillers to sell and install them. Over the next 12 years one and a half million farm families purchased treadle pumps, which increased the farmers’ net income by a total of $150 million a year. The cost of IDE’s market-creation activities was only $12 million, leveraged by the investment of $37.5 million from the farmers themselves. In contrast, the expense of building a conventional dam and canal system to irrigate an equivalent area of farmland would be in the range of $2,000 per acre, or $1.5 billion.

--------------------

Great thanks to volunteer Sanjeet has contributed these explanations markings.

If you want to make a better world like this, please contact us.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('1f62bcfd-c664-5db2-8fe2-29bd8ba9b2ce', '139f627b-6007-5879-9590-484b39c2a306', 1, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 1

Questions 1 - 6
Questions 1 - 6
Do the following statements agree with the information given in Reading Passage?
In boxes
1
–
6
on your answer sheet, write
TRUE
if the statement agrees with the view of the writer
FALSE
if the statement contradicts the view of the writer
NOT GIVEN
if it is impossible to say what the writer thinks about this
1
It is more effective to resolve poverty or food problem in large scale rather than in small scale.
Locate
2
Construction of gigantic dams costs more time in developing countries.
3
Green revolution foiled to increase global crop production from the mid of 20th century.
Locate
4
Agricultural production in Bangladesh declined in last decade.
5
Farmer Abdul Rahman knew how to increase production himself.
Locate
6
Small pump spread into big project in Bangladesh in the past decade.
Locate

1 ____ It is more effective to resolve poverty or food problem in large scale rather than in small scale. Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a29cf969-6d4e-548d-bedc-41d104a881ef', '1f62bcfd-c664-5db2-8fe2-29bd8ba9b2ce', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e9a0fdef-a88b-5ccf-b539-73b9421ffd08', '1f62bcfd-c664-5db2-8fe2-29bd8ba9b2ce', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7feb16ac-2e62-5962-be17-68e46d4445a7', '1f62bcfd-c664-5db2-8fe2-29bd8ba9b2ce', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('582385f3-fa45-5b2d-887f-ab58b215fe21', '139f627b-6007-5879-9590-484b39c2a306', 2, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 2

Questions 1 - 6
Questions 1 - 6
Do the following statements agree with the information given in Reading Passage?
In boxes
1
–
6
on your answer sheet, write
TRUE
if the statement agrees with the view of the writer
FALSE
if the statement contradicts the view of the writer
NOT GIVEN
if it is impossible to say what the writer thinks about this
1
It is more effective to resolve poverty or food problem in large scale rather than in small scale.
Locate
2
Construction of gigantic dams costs more time in developing countries.
3
Green revolution foiled to increase global crop production from the mid of 20th century.
Locate
4
Agricultural production in Bangladesh declined in last decade.
5
Farmer Abdul Rahman knew how to increase production himself.
Locate
6
Small pump spread into big project in Bangladesh in the past decade.
Locate

2 ____ Construction of gigantic dams costs more time in developing countries.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('40f496ae-be36-5534-9d40-95076077eede', '582385f3-fa45-5b2d-887f-ab58b215fe21', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('44090733-051b-5b5e-bb62-b90a7a27fb24', '582385f3-fa45-5b2d-887f-ab58b215fe21', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6c517cc0-e566-53de-ac9a-ebacbd21df72', '582385f3-fa45-5b2d-887f-ab58b215fe21', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('521b3c61-0a30-576f-96d8-2ce7a5232789', '139f627b-6007-5879-9590-484b39c2a306', 3, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 3

Questions 1 - 6
Questions 1 - 6
Do the following statements agree with the information given in Reading Passage?
In boxes
1
–
6
on your answer sheet, write
TRUE
if the statement agrees with the view of the writer
FALSE
if the statement contradicts the view of the writer
NOT GIVEN
if it is impossible to say what the writer thinks about this
1
It is more effective to resolve poverty or food problem in large scale rather than in small scale.
Locate
2
Construction of gigantic dams costs more time in developing countries.
3
Green revolution foiled to increase global crop production from the mid of 20th century.
Locate
4
Agricultural production in Bangladesh declined in last decade.
5
Farmer Abdul Rahman knew how to increase production himself.
Locate
6
Small pump spread into big project in Bangladesh in the past decade.
Locate

3 ____ Green revolution foiled to increase global crop production from the mid of 20th century. Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8551f4e2-7003-53bc-b791-4e9a4af22f6b', '521b3c61-0a30-576f-96d8-2ce7a5232789', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('99a1e074-b9da-553d-aca0-32d4a35c582a', '521b3c61-0a30-576f-96d8-2ce7a5232789', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('28c56277-d5f2-5188-910e-9453ce8c0c1c', '521b3c61-0a30-576f-96d8-2ce7a5232789', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('0f5fa602-95e4-565d-984d-237c7bf224d7', '139f627b-6007-5879-9590-484b39c2a306', 4, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 4

Questions 1 - 6
Questions 1 - 6
Do the following statements agree with the information given in Reading Passage?
In boxes
1
–
6
on your answer sheet, write
TRUE
if the statement agrees with the view of the writer
FALSE
if the statement contradicts the view of the writer
NOT GIVEN
if it is impossible to say what the writer thinks about this
1
It is more effective to resolve poverty or food problem in large scale rather than in small scale.
Locate
2
Construction of gigantic dams costs more time in developing countries.
3
Green revolution foiled to increase global crop production from the mid of 20th century.
Locate
4
Agricultural production in Bangladesh declined in last decade.
5
Farmer Abdul Rahman knew how to increase production himself.
Locate
6
Small pump spread into big project in Bangladesh in the past decade.
Locate

4 ____ Agricultural production in Bangladesh declined in last decade.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('74818e7c-736b-5950-b44c-a40d509cb470', '0f5fa602-95e4-565d-984d-237c7bf224d7', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('25887ebb-37e4-5bf3-9cb7-d3628c3fe4cb', '0f5fa602-95e4-565d-984d-237c7bf224d7', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ce04ada3-35a3-5e29-bcc6-a5cd32310075', '0f5fa602-95e4-565d-984d-237c7bf224d7', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('d44119a4-affc-5b2f-9e99-5ae5a7c8dbb0', '139f627b-6007-5879-9590-484b39c2a306', 5, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 5

Questions 1 - 6
Questions 1 - 6
Do the following statements agree with the information given in Reading Passage?
In boxes
1
–
6
on your answer sheet, write
TRUE
if the statement agrees with the view of the writer
FALSE
if the statement contradicts the view of the writer
NOT GIVEN
if it is impossible to say what the writer thinks about this
1
It is more effective to resolve poverty or food problem in large scale rather than in small scale.
Locate
2
Construction of gigantic dams costs more time in developing countries.
3
Green revolution foiled to increase global crop production from the mid of 20th century.
Locate
4
Agricultural production in Bangladesh declined in last decade.
5
Farmer Abdul Rahman knew how to increase production himself.
Locate
6
Small pump spread into big project in Bangladesh in the past decade.
Locate

5 ____ Farmer Abdul Rahman knew how to increase production himself. Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1adbeb11-09cd-585d-ba28-e9eb1d83bdb6', 'd44119a4-affc-5b2f-9e99-5ae5a7c8dbb0', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('79f4ad92-6d0f-50c8-a13a-8c7ad3c33b7f', 'd44119a4-affc-5b2f-9e99-5ae5a7c8dbb0', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('04abfe46-cc5c-5f47-b8e6-e57762656e93', 'd44119a4-affc-5b2f-9e99-5ae5a7c8dbb0', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('4ec848cd-0e34-50fc-8f8a-c2bb0f12660b', '139f627b-6007-5879-9590-484b39c2a306', 6, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 6

Questions 1 - 6
Questions 1 - 6
Do the following statements agree with the information given in Reading Passage?
In boxes
1
–
6
on your answer sheet, write
TRUE
if the statement agrees with the view of the writer
FALSE
if the statement contradicts the view of the writer
NOT GIVEN
if it is impossible to say what the writer thinks about this
1
It is more effective to resolve poverty or food problem in large scale rather than in small scale.
Locate
2
Construction of gigantic dams costs more time in developing countries.
3
Green revolution foiled to increase global crop production from the mid of 20th century.
Locate
4
Agricultural production in Bangladesh declined in last decade.
5
Farmer Abdul Rahman knew how to increase production himself.
Locate
6
Small pump spread into big project in Bangladesh in the past decade.
Locate

6 ____ Small pump spread into big project in Bangladesh in the past decade. Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9c8828ed-c41e-57e6-ae44-c323bc0a0290', '4ec848cd-0e34-50fc-8f8a-c2bb0f12660b', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1eda299f-d8a1-53ee-8af1-a92ab0caf931', '4ec848cd-0e34-50fc-8f8a-c2bb0f12660b', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ca3f1e64-bc1e-5314-9e40-5c30de63693b', '4ec848cd-0e34-50fc-8f8a-c2bb0f12660b', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('90098557-82ff-557e-b3d3-278eef90fa35', '139f627b-6007-5879-9590-484b39c2a306', 7, 'SHORT_ANSWER', 'READING', 3, $md$### Question 7

Questions 7 – 10
Questions 7 – 10
Filling the blanks in diagram of treadle pump’s each parts.
Choose
NO MORE THAN THREE WORDS AND/OR A NUMBER
from the passage for each answer.
7
Locate
8
Locate
9
Locate
10
Locate

7 ____ Locate$md$, NULL, ARRAY['.*bamboo.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('69297eb9-0ed6-5fbd-8980-5fa513aea2d4', '139f627b-6007-5879-9590-484b39c2a306', 8, 'SHORT_ANSWER', 'READING', 3, $md$### Question 8

Questions 7 – 10
Questions 7 – 10
Filling the blanks in diagram of treadle pump’s each parts.
Choose
NO MORE THAN THREE WORDS AND/OR A NUMBER
from the passage for each answer.
7
Locate
8
Locate
9
Locate
10
Locate

8 ____ Locate$md$, NULL, ARRAY['.*cylinders.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('39ab4e53-fc65-5815-adc3-4be61d2980e1', '139f627b-6007-5879-9590-484b39c2a306', 9, 'SHORT_ANSWER', 'READING', 3, $md$### Question 9

Questions 7 – 10
Questions 7 – 10
Filling the blanks in diagram of treadle pump’s each parts.
Choose
NO MORE THAN THREE WORDS AND/OR A NUMBER
from the passage for each answer.
7
Locate
8
Locate
9
Locate
10
Locate

9 ____ Locate$md$, NULL, ARRAY['.*piston.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('aff2eb50-e53d-5e3a-865a-e10429e5b48d', '139f627b-6007-5879-9590-484b39c2a306', 10, 'SHORT_ANSWER', 'READING', 4, $md$### Question 10

Questions 7 – 10
Questions 7 – 10
Filling the blanks in diagram of treadle pump’s each parts.
Choose
NO MORE THAN THREE WORDS AND/OR A NUMBER
from the passage for each answer.
7
Locate
8
Locate
9
Locate
10
Locate

10 ____ Locate$md$, NULL, ARRAY['.*7.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('9dcab98e-e449-57b1-9bc1-b9fdfb649520', '139f627b-6007-5879-9590-484b39c2a306', 11, 'SHORT_ANSWER', 'READING', 4, $md$### Question 11

Questions 11 – 13
Questions 11 – 13
Answer the questions below.
Choose
NO MORE THAN THREE WORDS AND/OR A NUMBER
from the passage for each answer.
11
How large area can a treadle pump irrigate the field at a low level of expense?
11
Locate
12
What is Abdul’s new roof made of?
12
Locate
13
How much did Bangladesh farmers invest by IDE’s stimulation?
13
Locate

11 How large area can a treadle pump irrigate the field at a low level of expense? 11 ____ Locate$md$, NULL, ARRAY['.*1.*','.*2.*an.*acre.*','.*half.*an.*acre.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('fc8d824b-0df9-5b02-a60f-9b2c1acd2fb0', '139f627b-6007-5879-9590-484b39c2a306', 12, 'SHORT_ANSWER', 'READING', 4, $md$### Question 12

Questions 11 – 13
Questions 11 – 13
Answer the questions below.
Choose
NO MORE THAN THREE WORDS AND/OR A NUMBER
from the passage for each answer.
11
How large area can a treadle pump irrigate the field at a low level of expense?
11
Locate
12
What is Abdul’s new roof made of?
12
Locate
13
How much did Bangladesh farmers invest by IDE’s stimulation?
13
Locate

12 What is Abdul’s new roof made of? 12 ____ Locate$md$, NULL, ARRAY['.*corrugated.*tin.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('5bdc9e45-8c28-5f69-9f4f-8d3734d15e6d', '139f627b-6007-5879-9590-484b39c2a306', 13, 'SHORT_ANSWER', 'READING', 4, $md$### Question 13

Questions 11 – 13
Questions 11 – 13
Answer the questions below.
Choose
NO MORE THAN THREE WORDS AND/OR A NUMBER
from the passage for each answer.
11
How large area can a treadle pump irrigate the field at a low level of expense?
11
Locate
12
What is Abdul’s new roof made of?
12
Locate
13
How much did Bangladesh farmers invest by IDE’s stimulation?
13
Locate

13 How much did Bangladesh farmers invest by IDE’s stimulation? 13 ____ Locate$md$, NULL, ARRAY['.*37.*5.*million.*','.*37.*5.*million.*dollars.*']);

COMMIT;
