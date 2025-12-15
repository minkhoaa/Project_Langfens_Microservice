BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-putting-the-brakes-on-climate-change-are-hydrogen-cars-the-answer-1400'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-putting-the-brakes-on-climate-change-are-hydrogen-cars-the-answer-1400';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-putting-the-brakes-on-climate-change-are-hydrogen-cars-the-answer-1400';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-putting-the-brakes-on-climate-change-are-hydrogen-cars-the-answer-1400';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('8dff6757-9415-52ed-ab93-f687e5d05af3', 'ielts-reading-putting-the-brakes-on-climate-change-are-hydrogen-cars-the-answer-1400', $t$Putting the brakes on climate change: Are hydrogen cars the answer?$t$, $md$## Putting the brakes on climate change: Are hydrogen cars the answer?

Nguồn:
- Test: https://mini-ielts.com/1400/reading/putting-the-brakes-on-climate-change-are-hydrogen-cars-the-answer
- Solution: https://mini-ielts.com/1400/view-solution/reading/putting-the-brakes-on-climate-change-are-hydrogen-cars-the-answer$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('546bfa04-4052-5f53-8e41-46f86379c408', '8dff6757-9415-52ed-ab93-f687e5d05af3', 1, $t$Reading — Putting the brakes on climate change: Are hydrogen cars the answer?$t$, $md$Read the passage and answer questions **1–14**.

### Passage: Putting the brakes on climate change: Are hydrogen cars the answer?

A

It is tempting to think that the conservation of coral reefs and rainforests is a separate issue from traffic and air pollution. But it is not. Scientists are now confident that rapid changes in the Earth’s climate are already disrupting and altering many wildlife habitats. Pollution from vehicles is a big part of the problem.

B

The United Nation’s Climate Change Panel has estimated that the global average temperature rise expected by the year 2100 could be as much as 6°C, causing forest fires and dieback on land and coral bleaching in the ocean. Few species, if any, will be immune from the changes in temperature, rainfall and sea levels. The panel believes that if such catastrophic temperature rises are to be avoided, the quantity of greenhouse gases, especially carbon dioxide, being released into the atmosphere must be reduced. That will depend on slowing the rate of deforestation and, more crucially, finding alternatives to coal, oil and gas as our principal energy sources.

C

Technologies do exist to reduce or eliminate carbon dioxide as a waste product of our energy consumption. Wind power and solar power are both spreading fast, but what are we doing about traffic? Electric cars are one possible option, but their range and the time it takes to charge their batteries pose serious limitations. However, the technology that shows the most potential to make cars climate-friendly is fuel-cell technology. This was actually invented in the late nineteenth century, but because the world’s motor industry put its effort into developing the combustion engine, it was never refined for mass production. One of the first prototype fuel-cell-powered vehicles have been built by the Ford Motor Company. It is like a conventional car, only with better acceleration and a smoother ride. Ford engineers expect to be able to produce a virtually silent vehicle in the future.

D

So what’s the process involved – and is there a catch? Hydrogen goes into the fuel tank, producing electricity. The only emission from the exhaust pipe is water. The fuel-cell is, in some ways similar to a battery, but unlike a battery, it does not run down. As long as hydrogen and oxygen are supplied to the cell, it will keep on generating electricity. Some cells work off methane and a few use liquid fuels such as methanol, but fuel-ceils using hydrogen probably have the most potential. Furthermore, they need not be limited to transport. Fuel-cells can be made in a huge range of size, small enough for portable computers or large enough for power stations. They have no moving parts and therefore need no oil. They just need a supply of hydrogen. The big question, then, is where to get it from.

E

One source of hydrogen is water. But to exploit the abundant resource, electricity is needed, and if the electricity is produced by a coal-fired power station or other fossil fuel, then the overall carbon reduction benefit of the fuel-cell disappears. Renewable sources, such as wind and solar power, do not produce enough energy for it to be economically viable to use them in the ‘manufacture’ of hydrogen as a transport fuel. Another source of hydrogen is, however, available and could provide a supply pending the development of more efficient and cheaper renewable energy technologies. By splitting natural gas (methane) into its constituent parts, hydrogen and carbon dioxide are produced. One way round the problem of what to do with the carbon dioxide could be to store it back below ground – so-called geological sequestration. Oil companies, such as Norway’s Statoil, are experimenting with storing carbon dioxide below ground in oil and gas wells.

F

With freak weather conditions, arguably caused by global warming, frequently in the headlines, the urgent need to get fuel-cell vehicles will be available in most showrooms. Even now, fuel-cell buses are operating in the US, while in Germany a courier company is planning to take delivery of fuel-cell-powered vans in the near future. The fact that centrally-run fleets of buses and vans are the first fuel-cell vehicles identifies another challenge – fuel distribution. The refueling facilities necessary to top up hydrogen-powered vehicles are available only in a very few places at present. Public transport and delivery firms are logical places to start since their vehicles are operated from central depots.

G

Fuel-cell technology is being developed right across the automotive industry. This technology could have a major impact in slowing down climate change, but further investment is needed if the industry – and the world’s wildlife – is to have a long-term future.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('01792263-d653-54e5-9a9b-b24a809c6316', '546bfa04-4052-5f53-8e41-46f86379c408', 1, 'MATCHING_HEADING', 'READING', 2, $md$### Question 1

Questions 1-6
Questions 1-6
Reading Passage has seven paragraphs,
A-G
.
Choose the correct heading for paragraphs
A-F
from the list of headings below.
Write the correct number,
i-ix
, in boxes
1-6
on your answer sheet.
List of Headings
i
Action already taken by the United Nations
ii
Marketing the hydrogen car
iii
Making the new technology available worldwide
iv
Some negative predictions from one group of experts
v
How the new vehicle technology works
vi
The history of fuel-cell technology
vii
A holistic view of climatic change
viii
Locating the essential ingredient
ix
Sustaining car manufacture
1
Paragraph A
2
Paragraph B
3
Paragraph C
4
Paragraph D
5
Paragraph E
6
Paragraph F

1 ____ Paragraph A$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2f3b033b-9c9f-5d1d-b4bc-4fd91e955e8d', '01792263-d653-54e5-9a9b-b24a809c6316', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c3d23c11-34e4-5d77-b467-b9cbd150635e', '01792263-d653-54e5-9a9b-b24a809c6316', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('159eec6e-e5a8-52fd-9b7d-ea2d8adaa441', '01792263-d653-54e5-9a9b-b24a809c6316', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ab53bc10-01af-54d2-a9b4-c9417ffa5978', '01792263-d653-54e5-9a9b-b24a809c6316', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ee7ad77c-08f2-5d8d-b21f-737de07e81a7', '01792263-d653-54e5-9a9b-b24a809c6316', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('94e4872f-23cb-5108-90a9-fbf698aff602', '01792263-d653-54e5-9a9b-b24a809c6316', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0fac14b2-7571-5b32-a802-cc29a67cf298', '01792263-d653-54e5-9a9b-b24a809c6316', 7, $md$vii$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3a817d64-0c8f-522c-b917-ba7679bfc83f', '01792263-d653-54e5-9a9b-b24a809c6316', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4ed3e26d-ace9-51b5-9f55-9bf982ffdcea', '01792263-d653-54e5-9a9b-b24a809c6316', 9, $md$ix$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('0fbc7355-ddff-564e-b897-a524f9379d65', '546bfa04-4052-5f53-8e41-46f86379c408', 2, 'MATCHING_HEADING', 'READING', 2, $md$### Question 2

Questions 1-6
Questions 1-6
Reading Passage has seven paragraphs,
A-G
.
Choose the correct heading for paragraphs
A-F
from the list of headings below.
Write the correct number,
i-ix
, in boxes
1-6
on your answer sheet.
List of Headings
i
Action already taken by the United Nations
ii
Marketing the hydrogen car
iii
Making the new technology available worldwide
iv
Some negative predictions from one group of experts
v
How the new vehicle technology works
vi
The history of fuel-cell technology
vii
A holistic view of climatic change
viii
Locating the essential ingredient
ix
Sustaining car manufacture
1
Paragraph A
2
Paragraph B
3
Paragraph C
4
Paragraph D
5
Paragraph E
6
Paragraph F

2 ____ Paragraph B$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8c8d3ab4-a63b-53a3-a859-fe243815b42a', '0fbc7355-ddff-564e-b897-a524f9379d65', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('881a4de1-cf49-5306-a7c0-7d9549dd3fef', '0fbc7355-ddff-564e-b897-a524f9379d65', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('77bb703e-9574-5414-8351-0bad52494b37', '0fbc7355-ddff-564e-b897-a524f9379d65', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('31c02ebc-bfc2-57ef-bb35-f2f900d69276', '0fbc7355-ddff-564e-b897-a524f9379d65', 4, $md$iv$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('77813536-a0c1-5dc1-b6b0-5544fa1baa51', '0fbc7355-ddff-564e-b897-a524f9379d65', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ebcf299a-d88e-50cf-a51b-a9f25ef6fbfb', '0fbc7355-ddff-564e-b897-a524f9379d65', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9df21666-790b-53fe-b219-48551d8ccaae', '0fbc7355-ddff-564e-b897-a524f9379d65', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a567702d-eb5e-5168-b4fc-da45948ba939', '0fbc7355-ddff-564e-b897-a524f9379d65', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('89d2c6c1-1475-5a06-92e9-b54ee1592cd9', '0fbc7355-ddff-564e-b897-a524f9379d65', 9, $md$ix$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('c68f5fbb-836e-5093-9e9d-2b875db5c488', '546bfa04-4052-5f53-8e41-46f86379c408', 3, 'MATCHING_HEADING', 'READING', 2, $md$### Question 3

Questions 1-6
Questions 1-6
Reading Passage has seven paragraphs,
A-G
.
Choose the correct heading for paragraphs
A-F
from the list of headings below.
Write the correct number,
i-ix
, in boxes
1-6
on your answer sheet.
List of Headings
i
Action already taken by the United Nations
ii
Marketing the hydrogen car
iii
Making the new technology available worldwide
iv
Some negative predictions from one group of experts
v
How the new vehicle technology works
vi
The history of fuel-cell technology
vii
A holistic view of climatic change
viii
Locating the essential ingredient
ix
Sustaining car manufacture
1
Paragraph A
2
Paragraph B
3
Paragraph C
4
Paragraph D
5
Paragraph E
6
Paragraph F

3 ____ Paragraph C$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c840fe92-77c0-596f-aa9e-06c3ae510014', 'c68f5fbb-836e-5093-9e9d-2b875db5c488', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('89d657b5-2353-50ee-8d69-050cae65e4a0', 'c68f5fbb-836e-5093-9e9d-2b875db5c488', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cb943b5f-4dcd-554f-8d5d-1e17fa8a8fc5', 'c68f5fbb-836e-5093-9e9d-2b875db5c488', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4c419fcd-943e-5e46-bef0-73499245a0c1', 'c68f5fbb-836e-5093-9e9d-2b875db5c488', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c2b996d1-2f1c-5b82-b869-d93a028d438b', 'c68f5fbb-836e-5093-9e9d-2b875db5c488', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('dabfb9c6-a49c-5291-9031-b1d0c4f4229c', 'c68f5fbb-836e-5093-9e9d-2b875db5c488', 6, $md$vi$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8e222e47-63ef-541f-9936-54df64a0ab8b', 'c68f5fbb-836e-5093-9e9d-2b875db5c488', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f185529b-7e8f-59c6-b4f0-bf0facff1689', 'c68f5fbb-836e-5093-9e9d-2b875db5c488', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cd7ed306-325d-519b-a82a-f9578c43ab30', 'c68f5fbb-836e-5093-9e9d-2b875db5c488', 9, $md$ix$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('3174af20-5f75-5400-a160-b238945acca6', '546bfa04-4052-5f53-8e41-46f86379c408', 4, 'MATCHING_HEADING', 'READING', 2, $md$### Question 4

Questions 1-6
Questions 1-6
Reading Passage has seven paragraphs,
A-G
.
Choose the correct heading for paragraphs
A-F
from the list of headings below.
Write the correct number,
i-ix
, in boxes
1-6
on your answer sheet.
List of Headings
i
Action already taken by the United Nations
ii
Marketing the hydrogen car
iii
Making the new technology available worldwide
iv
Some negative predictions from one group of experts
v
How the new vehicle technology works
vi
The history of fuel-cell technology
vii
A holistic view of climatic change
viii
Locating the essential ingredient
ix
Sustaining car manufacture
1
Paragraph A
2
Paragraph B
3
Paragraph C
4
Paragraph D
5
Paragraph E
6
Paragraph F

4 ____ Paragraph D$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d8174200-f528-59bf-85f3-992948489b67', '3174af20-5f75-5400-a160-b238945acca6', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a79fdf78-99f3-52b7-aaab-cb37325bcdbd', '3174af20-5f75-5400-a160-b238945acca6', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('598e06cf-d829-589f-96c2-f132202ae45a', '3174af20-5f75-5400-a160-b238945acca6', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ca9a7e47-0049-5739-85f8-a9f8512b5f6e', '3174af20-5f75-5400-a160-b238945acca6', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('92f6e7ec-5e38-571c-bded-e4a092051138', '3174af20-5f75-5400-a160-b238945acca6', 5, $md$v$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('722a9446-597e-566b-8f7a-c1312dc1bc5e', '3174af20-5f75-5400-a160-b238945acca6', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f05b8da5-e817-57d3-a18e-7bfad575853a', '3174af20-5f75-5400-a160-b238945acca6', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('be77b495-383e-583c-8717-2e089d3241a2', '3174af20-5f75-5400-a160-b238945acca6', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('275955d4-c082-5a67-939b-99e4155e38c4', '3174af20-5f75-5400-a160-b238945acca6', 9, $md$ix$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('6b97d638-fb72-5a2a-9ece-66d0da62fb04', '546bfa04-4052-5f53-8e41-46f86379c408', 5, 'MATCHING_HEADING', 'READING', 3, $md$### Question 5

Questions 1-6
Questions 1-6
Reading Passage has seven paragraphs,
A-G
.
Choose the correct heading for paragraphs
A-F
from the list of headings below.
Write the correct number,
i-ix
, in boxes
1-6
on your answer sheet.
List of Headings
i
Action already taken by the United Nations
ii
Marketing the hydrogen car
iii
Making the new technology available worldwide
iv
Some negative predictions from one group of experts
v
How the new vehicle technology works
vi
The history of fuel-cell technology
vii
A holistic view of climatic change
viii
Locating the essential ingredient
ix
Sustaining car manufacture
1
Paragraph A
2
Paragraph B
3
Paragraph C
4
Paragraph D
5
Paragraph E
6
Paragraph F

5 ____ Paragraph E$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e46d3cf3-e37e-5cf8-997b-732d0d757c3b', '6b97d638-fb72-5a2a-9ece-66d0da62fb04', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a54964b9-fbdb-5612-a9a1-3965a3ac1ef1', '6b97d638-fb72-5a2a-9ece-66d0da62fb04', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4ca06bae-4e1d-5be3-b811-0a1ae333532e', '6b97d638-fb72-5a2a-9ece-66d0da62fb04', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('12bfd858-304f-5a19-9631-e80351a2b853', '6b97d638-fb72-5a2a-9ece-66d0da62fb04', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('917d04de-ca8d-517c-9374-dee7fdcb6b3a', '6b97d638-fb72-5a2a-9ece-66d0da62fb04', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('88e91982-b3bb-5e8e-b527-38a1ab9192c6', '6b97d638-fb72-5a2a-9ece-66d0da62fb04', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d4cea36e-ee40-5847-8647-dabf3c9e42c1', '6b97d638-fb72-5a2a-9ece-66d0da62fb04', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fa587020-e3a2-564a-9abd-0cfde653b6ad', '6b97d638-fb72-5a2a-9ece-66d0da62fb04', 8, $md$viii$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1e1fff2e-f9e3-58e7-b49b-f2747e54f17d', '6b97d638-fb72-5a2a-9ece-66d0da62fb04', 9, $md$ix$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('078f1c76-7831-5e8f-9e66-710ec4786dc0', '546bfa04-4052-5f53-8e41-46f86379c408', 6, 'MATCHING_HEADING', 'READING', 3, $md$### Question 6

Questions 1-6
Questions 1-6
Reading Passage has seven paragraphs,
A-G
.
Choose the correct heading for paragraphs
A-F
from the list of headings below.
Write the correct number,
i-ix
, in boxes
1-6
on your answer sheet.
List of Headings
i
Action already taken by the United Nations
ii
Marketing the hydrogen car
iii
Making the new technology available worldwide
iv
Some negative predictions from one group of experts
v
How the new vehicle technology works
vi
The history of fuel-cell technology
vii
A holistic view of climatic change
viii
Locating the essential ingredient
ix
Sustaining car manufacture
1
Paragraph A
2
Paragraph B
3
Paragraph C
4
Paragraph D
5
Paragraph E
6
Paragraph F

6 ____ Paragraph F$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ab1ca968-fd3f-54b0-b8e5-669aaa88392d', '078f1c76-7831-5e8f-9e66-710ec4786dc0', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('990c910f-49d8-584b-88cc-b33387c0eb82', '078f1c76-7831-5e8f-9e66-710ec4786dc0', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('018e176f-74f0-5157-aeb3-4ffe3d88c3cf', '078f1c76-7831-5e8f-9e66-710ec4786dc0', 3, $md$iii$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1f2766ec-9c67-5ffb-8ad0-ab95499a9d9b', '078f1c76-7831-5e8f-9e66-710ec4786dc0', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cf5e853e-c949-5f91-923f-032289322e26', '078f1c76-7831-5e8f-9e66-710ec4786dc0', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c9dfc996-2851-5234-b851-40aaa2781d1b', '078f1c76-7831-5e8f-9e66-710ec4786dc0', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('219cb46c-4343-54b5-90b9-9516d37d1be3', '078f1c76-7831-5e8f-9e66-710ec4786dc0', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0a29cfaa-6a12-52ca-a940-1318ce7c6808', '078f1c76-7831-5e8f-9e66-710ec4786dc0', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0b87f7e2-d64d-5920-8d0f-a63324e9ed4c', '078f1c76-7831-5e8f-9e66-710ec4786dc0', 9, $md$ix$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('c188946e-6a79-59ea-93d1-0e17d2cfe1c9', '546bfa04-4052-5f53-8e41-46f86379c408', 7, 'SENTENCE_COMPLETION', 'READING', 3, $md$### Question 7

Questions 7-10
Questions 7-10
Complete the sentences below.
Choose
NO MORE THAN TWO WORDS
from the passage for each answer.
Write your answers in boxes
7-10
on your answer sheet.
7. In the late nineteenth century, the car industry invested in the development of the
7
, rather than fuel-cell technology.
8. Ford engineers predict that they will eventually design an almost
8
car.
9. While a fuel-cell lasts longer, some aspects of it are comparable to a
9
.
10. Fuel-cells can come in many sizes and can be used in power stations and in
10
as well as in vehicles.

7. In the late nineteenth century, the car industry invested in the development of the 7 ____ , rather than fuel-cell technology.$md$, NULL, ARRAY['.*combustion.*engine.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('c1c5c5d0-e211-538b-9847-ee60c36b6888', '546bfa04-4052-5f53-8e41-46f86379c408', 8, 'SENTENCE_COMPLETION', 'READING', 3, $md$### Question 8

Questions 7-10
Questions 7-10
Complete the sentences below.
Choose
NO MORE THAN TWO WORDS
from the passage for each answer.
Write your answers in boxes
7-10
on your answer sheet.
7. In the late nineteenth century, the car industry invested in the development of the
7
, rather than fuel-cell technology.
8. Ford engineers predict that they will eventually design an almost
8
car.
9. While a fuel-cell lasts longer, some aspects of it are comparable to a
9
.
10. Fuel-cells can come in many sizes and can be used in power stations and in
10
as well as in vehicles.

8. Ford engineers predict that they will eventually design an almost 8 ____ car.$md$, NULL, ARRAY['.*silent.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('0fbde765-d5a6-5e22-943f-0fb4cd1d167f', '546bfa04-4052-5f53-8e41-46f86379c408', 9, 'SENTENCE_COMPLETION', 'READING', 3, $md$### Question 9

Questions 7-10
Questions 7-10
Complete the sentences below.
Choose
NO MORE THAN TWO WORDS
from the passage for each answer.
Write your answers in boxes
7-10
on your answer sheet.
7. In the late nineteenth century, the car industry invested in the development of the
7
, rather than fuel-cell technology.
8. Ford engineers predict that they will eventually design an almost
8
car.
9. While a fuel-cell lasts longer, some aspects of it are comparable to a
9
.
10. Fuel-cells can come in many sizes and can be used in power stations and in
10
as well as in vehicles.

9. While a fuel-cell lasts longer, some aspects of it are comparable to a 9 ____ .$md$, NULL, ARRAY['.*battery.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('381f94a4-4406-51bf-a541-7faddac7731d', '546bfa04-4052-5f53-8e41-46f86379c408', 10, 'SENTENCE_COMPLETION', 'READING', 4, $md$### Question 10

Questions 7-10
Questions 7-10
Complete the sentences below.
Choose
NO MORE THAN TWO WORDS
from the passage for each answer.
Write your answers in boxes
7-10
on your answer sheet.
7. In the late nineteenth century, the car industry invested in the development of the
7
, rather than fuel-cell technology.
8. Ford engineers predict that they will eventually design an almost
8
car.
9. While a fuel-cell lasts longer, some aspects of it are comparable to a
9
.
10. Fuel-cells can come in many sizes and can be used in power stations and in
10
as well as in vehicles.

10. Fuel-cells can come in many sizes and can be used in power stations and in 10 ____ as well as in vehicles.$md$, NULL, ARRAY['.*portable.*computers.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('d022f18d-b6e3-5e09-9cf5-3a1f0f62b6f8', '546bfa04-4052-5f53-8e41-46f86379c408', 11, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 11

Questions 11-14
Questions 11-14
Do the following statements agree, with the information given in Reading Passage?
In boxes
11-14
on your answer sheet, write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
11
Using electricity produced by burning fossil fuels to access sources of hydrogen may increase the positive effect of the fuel-cell.
12
The oil company Statoil in Norway owns gas wells in other parts of the world.
13
Public transport is leading the way in the application of fuel-cell technology.
14
More funding is necessary to ensure the success of the fuel-cell vehicle industry.

11 ____ Using electricity produced by burning fossil fuels to access sources of hydrogen may increase the positive effect of the fuel-cell.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1b1fc0e1-479b-5889-bfcb-85964ebe9253', 'd022f18d-b6e3-5e09-9cf5-3a1f0f62b6f8', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d765ebb8-9ec0-5a66-a044-3de8b41d87a7', 'd022f18d-b6e3-5e09-9cf5-3a1f0f62b6f8', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b36fbd9e-0f9a-5387-af86-0a16a3af846b', 'd022f18d-b6e3-5e09-9cf5-3a1f0f62b6f8', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('c0d01a00-835f-51be-9769-36154a649044', '546bfa04-4052-5f53-8e41-46f86379c408', 12, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 12

Questions 11-14
Questions 11-14
Do the following statements agree, with the information given in Reading Passage?
In boxes
11-14
on your answer sheet, write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
11
Using electricity produced by burning fossil fuels to access sources of hydrogen may increase the positive effect of the fuel-cell.
12
The oil company Statoil in Norway owns gas wells in other parts of the world.
13
Public transport is leading the way in the application of fuel-cell technology.
14
More funding is necessary to ensure the success of the fuel-cell vehicle industry.

12 ____ The oil company Statoil in Norway owns gas wells in other parts of the world.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cb5f5b89-e0b7-5db2-b8eb-791032fdda09', 'c0d01a00-835f-51be-9769-36154a649044', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('220ca09a-a20f-5c7b-a79e-fc9665d4920e', 'c0d01a00-835f-51be-9769-36154a649044', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ab255207-c17e-5539-b80d-412fc8b3f5ed', 'c0d01a00-835f-51be-9769-36154a649044', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('4bbd22f0-7ae7-5d55-82a5-d4ac56171c5a', '546bfa04-4052-5f53-8e41-46f86379c408', 13, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 13

Questions 11-14
Questions 11-14
Do the following statements agree, with the information given in Reading Passage?
In boxes
11-14
on your answer sheet, write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
11
Using electricity produced by burning fossil fuels to access sources of hydrogen may increase the positive effect of the fuel-cell.
12
The oil company Statoil in Norway owns gas wells in other parts of the world.
13
Public transport is leading the way in the application of fuel-cell technology.
14
More funding is necessary to ensure the success of the fuel-cell vehicle industry.

13 ____ Public transport is leading the way in the application of fuel-cell technology.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('183e3ec8-1a9e-54dc-a291-e95208200008', '4bbd22f0-7ae7-5d55-82a5-d4ac56171c5a', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('658c05a3-2cc4-5df9-91df-b9fabcc4d03c', '4bbd22f0-7ae7-5d55-82a5-d4ac56171c5a', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f3fcfe03-b74f-595d-b2df-536020a59d77', '4bbd22f0-7ae7-5d55-82a5-d4ac56171c5a', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('f21f7db7-cbf1-5eff-9120-541a4614ea74', '546bfa04-4052-5f53-8e41-46f86379c408', 14, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 14

Questions 11-14
Questions 11-14
Do the following statements agree, with the information given in Reading Passage?
In boxes
11-14
on your answer sheet, write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
11
Using electricity produced by burning fossil fuels to access sources of hydrogen may increase the positive effect of the fuel-cell.
12
The oil company Statoil in Norway owns gas wells in other parts of the world.
13
Public transport is leading the way in the application of fuel-cell technology.
14
More funding is necessary to ensure the success of the fuel-cell vehicle industry.

14 ____ More funding is necessary to ensure the success of the fuel-cell vehicle industry.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('42eb4adf-0c1b-50a7-850d-e40f0bc1bc76', 'f21f7db7-cbf1-5eff-9120-541a4614ea74', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a5deb3a7-2d91-5d11-b4ba-e4d4d2277065', 'f21f7db7-cbf1-5eff-9120-541a4614ea74', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('39720d89-6772-56ab-8f57-f33df78c67c8', 'f21f7db7-cbf1-5eff-9120-541a4614ea74', 3, $md$NOT GIVEN$md$, false);

COMMIT;
