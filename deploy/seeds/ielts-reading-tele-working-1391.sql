BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-tele-working-1391'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-tele-working-1391';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-tele-working-1391';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-tele-working-1391';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('10ac0af7-4153-54e9-8368-ab613a0e2e1e', 'ielts-reading-tele-working-1391', $t$Tele-working$t$, $md$## Tele-working

Nguồn:
- Test: https://mini-ielts.com/1391/reading/tele-working
- Solution: https://mini-ielts.com/1391/view-solution/reading/tele-working$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('e3c19bf4-280a-593e-b6cc-846711ff1d86', '10ac0af7-4153-54e9-8368-ab613a0e2e1e', 1, $t$Reading — Tele-working$t$, $md$Read the passage and answer questions **1–13**.

### Passage: Tele-working

A

Teleworking – working remotely from an office- is said to have many benefits for organisations, the environment and society. It provokes mixed reactions from its acolytes and those that experience it first-hand. Whether you like it or not, it is true to say that work is no longer dependent on geography and this opens up a range of opportunities for working in new ways and environments.

B

The surveys show “that the productivity increase is not primarily because of longer working hours (as is sometimes suggested). Although prevalent, working more is just one of a number of influencing factors, and not the most important.” An unusual comparison of the performance of teleworkers with a closely matched control group of non-teleworkers found that not only was productivity higher but also that absenteeism and error rates were lower.

C

Two other areas where SUSTEL has added to the economic impact knowledge base is its effect on absenteeism and space utilisation. In the case of absenteeism, over 60 per cent of those surveyed stated that telework had enabled them to work when they were prevented from reaching a work location (usually through illness or transport problems). Around half the cases also identified substantial reductions in space requirements – to the point where one organisation had completely done away with a central office. Changes in non-commuting travel on weekends: home-bases workers, which includes a substantial population of people who are not telecommuters, spend more time shopping out of the home than traditional workers.

D

Half-time telecommuting could reduce carbon emissions by over 51 million metric tons a year—the equivalent of taking all of New York’s commuters off the road. Additional carbon footprint savings will come from reduced: office energy, roadway repairs, urban heating, office construction, business travel, paper usage (as electronic documents replace paper). Although energy utilization will continue to grow as we expand our industry and improve our standard of living, efficient use of energy will always be of prime importance. By telecommuting to work instead of using more conventional methods, there is a great potential to save energy. The three major areas where energy can be conserved are Vehicle-related materials and resources; Highway-related materials and resources; and work-related materials and resources.

E

A tremendous amount of energy is required to produce transportation equipment such as automobiles, buses, trains and jet aircraft. If telecommuting is promoted, there will be less use of this equipment and less energy will be required for production, maintenance and repair of this equipment. Fuel resources and gases needed to operate this equipment will be reduced, as well the building and repair of highways and maintenance requires a large consumption of energy, not only in the operation of the highway construction and repair equipment but also in the manufacture and transportation of the required materials An increase in the percentage of people telecommuting to work will decrease the need for expanded highways and associated road maintenance. The first two areas related to getting to work.

F

Socially, the SUSTEL research found that most survey respondents felt that teleworking gave them a better quality of life and work-life balance. Many also reported health benefits. A significant number also stated that they were using local services more and becoming more involved in their local communities. The loss of teamwork and team spirit within teleworking populations was tackled through ideas such as Oracle’s ‘FUNctional’ offices. Designed to increase communication and interaction when people are at the office, they are bright and focused around a central cafe to stimulate ideas and face-to-face contact.

G

The finding that many teleworkers report both longer working hours and a better quality of life is paradoxical. More time working is usually associated with increased stress, domestic tension and other factors that reduce the quality of life. One possible explanation is that, for many individuals, their increased working hours will be less than the time they have saved in commuting. Hence, they still have more time available for family and other activities. For some, the stress associated with commuting (especially for long distances) may be less than that arising from additional working time. Perhaps most significantly, teleworking can in effect create time through opportunities for multi-tasking or greater control of activities. As one survey respondent noted. “Although the amount of time has not changed it has made the weekends freer, as domestic activities can be fitted in during lunchtimes or early morning.”

H

When you work in an office or a cubicle and something goes wrong with any hardware or software you have the option of calling in the IT man. In fact, all of the equipment that you use at the office is supported by technical staff. That means regular updates and maintenance for various and sundry office tools like land-line phones, computers, internet connections, laptops, cell phones, printers, and other office equipment is all up to you when you work from home, you’ll surely encounter technical problems and when you do, where do you get the support and help you need? If your computer hard drive crashed today, would you have the funds to replace it?$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('8aaee3ed-09ae-5322-8d08-59307c624287', 'e3c19bf4-280a-593e-b6cc-846711ff1d86', 1, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 1

Questions 1-8
Questions 1-8
Complete the summary using the list of words,
A-N
below.
Write the correct letter,
A-N
, in boxes
1-8
on your answer sheet.
Teleworking has been said to have many benefits for both society and companies. Survey identified that telecommuters spend more time on
1
than those traditional workers on changes in non-commuting travel on weekends. It also is beneficial to the environment as it reduces the
2
in the atmosphere from decreased street repairs, city heating, or even
3
as staff in office could send documents
4
Apart from that, other materials such as Vehicle-related, Highway-related and
5
materials will also be saved. Traditionally, a large amount of energy is needed to make
6
, e.g. Public transportation and private cars. With the rise of telecommuting, resources and
7
will be saved. And conservation goes to the energy and materials consumed in all
8
A
pollution
B
internet energy
C
paper usage
D
construction and maintenance
E
materials
F
shopping
G
productivity
H
fuels and gases
I
electronically
J
IT
K
equipment L company
M
work-related
N
geography

Teleworking has been said to have many benefits for both society and companies. Survey identified that telecommuters spend more time on 1 ____ than those traditional workers on changes in non-commuting travel on weekends. It also is beneficial to the environment as it reduces the 2 ____ in the atmosphere from decreased street repairs, city heating, or even 3 ____ as staff in office could send documents 4 ____ Apart from that, other materials such as Vehicle-related, Highway-related and 5 ____ materials will also be saved. Traditionally, a large amount of energy is needed to make 6 ____ , e.g. Public transportation and private cars. With the rise of telecommuting, resources and 7 ____ will be saved. And conservation goes to the energy and materials consumed in all 8 ____$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bdecb59a-e9c0-5544-bdab-d8d4e517109f', '8aaee3ed-09ae-5322-8d08-59307c624287', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('eec83138-7673-5005-9d2d-c449ab66c4c4', '8aaee3ed-09ae-5322-8d08-59307c624287', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e9bc3fe1-2bad-5610-9aeb-6233dfe0b594', '8aaee3ed-09ae-5322-8d08-59307c624287', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('41ad3b20-6462-5a72-99f9-0d5ec3042eca', '8aaee3ed-09ae-5322-8d08-59307c624287', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3c955056-3da7-5e7d-b0cc-163c6f298866', '8aaee3ed-09ae-5322-8d08-59307c624287', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0d9d95ea-2fcb-54f6-9da9-5fbd7c3d4e9c', '8aaee3ed-09ae-5322-8d08-59307c624287', 6, $md$F$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1b821efc-4b08-5111-bb84-898cbeac638d', '8aaee3ed-09ae-5322-8d08-59307c624287', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('060b63b6-b022-57e6-b0b9-748a807ed435', '8aaee3ed-09ae-5322-8d08-59307c624287', 8, $md$H$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2fb1b190-039b-58a1-90d7-368e6ab8cd20', '8aaee3ed-09ae-5322-8d08-59307c624287', 9, $md$I$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('940c91b9-43c0-56b0-9d31-48b02d275395', '8aaee3ed-09ae-5322-8d08-59307c624287', 10, $md$J$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4fa20bcd-cab9-5cf8-bcb8-cc6114eab09a', '8aaee3ed-09ae-5322-8d08-59307c624287', 11, $md$K$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('49047e1f-fe9e-5fb2-b604-b3866a3aa83f', '8aaee3ed-09ae-5322-8d08-59307c624287', 12, $md$M$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('04d9d5de-84e7-58bd-a896-ce1d67754389', '8aaee3ed-09ae-5322-8d08-59307c624287', 13, $md$N$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('b2734921-1910-5fa3-afd6-4b85b37ed7f3', 'e3c19bf4-280a-593e-b6cc-846711ff1d86', 2, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 2

Questions 1-8
Questions 1-8
Complete the summary using the list of words,
A-N
below.
Write the correct letter,
A-N
, in boxes
1-8
on your answer sheet.
Teleworking has been said to have many benefits for both society and companies. Survey identified that telecommuters spend more time on
1
than those traditional workers on changes in non-commuting travel on weekends. It also is beneficial to the environment as it reduces the
2
in the atmosphere from decreased street repairs, city heating, or even
3
as staff in office could send documents
4
Apart from that, other materials such as Vehicle-related, Highway-related and
5
materials will also be saved. Traditionally, a large amount of energy is needed to make
6
, e.g. Public transportation and private cars. With the rise of telecommuting, resources and
7
will be saved. And conservation goes to the energy and materials consumed in all
8
A
pollution
B
internet energy
C
paper usage
D
construction and maintenance
E
materials
F
shopping
G
productivity
H
fuels and gases
I
electronically
J
IT
K
equipment L company
M
work-related
N
geography

Teleworking has been said to have many benefits for both society and companies. Survey identified that telecommuters spend more time on 1 ____ than those traditional workers on changes in non-commuting travel on weekends. It also is beneficial to the environment as it reduces the 2 ____ in the atmosphere from decreased street repairs, city heating, or even 3 ____ as staff in office could send documents 4 ____ Apart from that, other materials such as Vehicle-related, Highway-related and 5 ____ materials will also be saved. Traditionally, a large amount of energy is needed to make 6 ____ , e.g. Public transportation and private cars. With the rise of telecommuting, resources and 7 ____ will be saved. And conservation goes to the energy and materials consumed in all 8 ____$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('113deae2-d52c-5ec1-8b31-19c60d51580a', 'b2734921-1910-5fa3-afd6-4b85b37ed7f3', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a7f31aa4-7909-58f9-8640-ca14c4fcc2a7', 'b2734921-1910-5fa3-afd6-4b85b37ed7f3', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('37b81c9f-6623-55b0-bbe4-b0e39a48bfe1', 'b2734921-1910-5fa3-afd6-4b85b37ed7f3', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2f7164ac-2716-5a45-89c7-a4c1f4c84ae7', 'b2734921-1910-5fa3-afd6-4b85b37ed7f3', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7a557fb9-965e-58c8-a611-ab3127c9ffe4', 'b2734921-1910-5fa3-afd6-4b85b37ed7f3', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('94bb3adc-eddf-5326-802b-8bc679191e64', 'b2734921-1910-5fa3-afd6-4b85b37ed7f3', 6, $md$F$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f87529ad-452f-5570-b0ed-152bdae2130a', 'b2734921-1910-5fa3-afd6-4b85b37ed7f3', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5c371733-d114-53dd-88af-fd34c4440734', 'b2734921-1910-5fa3-afd6-4b85b37ed7f3', 8, $md$H$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cf9eab7a-42b8-55e2-9d5c-d42359e9b97f', 'b2734921-1910-5fa3-afd6-4b85b37ed7f3', 9, $md$I$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('40f67375-89f6-5490-89ad-4c64863551a5', 'b2734921-1910-5fa3-afd6-4b85b37ed7f3', 10, $md$J$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1eff3cb1-7a1c-55ef-9b41-9972db51ce35', 'b2734921-1910-5fa3-afd6-4b85b37ed7f3', 11, $md$K$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('adf22730-47c0-552a-8175-94455ebc5b88', 'b2734921-1910-5fa3-afd6-4b85b37ed7f3', 12, $md$M$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('776372e3-9ea6-5935-82c1-e2f7369c09f2', 'b2734921-1910-5fa3-afd6-4b85b37ed7f3', 13, $md$N$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('b5538930-125a-50d9-a70c-dd4d6362290e', 'e3c19bf4-280a-593e-b6cc-846711ff1d86', 3, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 3

Questions 1-8
Questions 1-8
Complete the summary using the list of words,
A-N
below.
Write the correct letter,
A-N
, in boxes
1-8
on your answer sheet.
Teleworking has been said to have many benefits for both society and companies. Survey identified that telecommuters spend more time on
1
than those traditional workers on changes in non-commuting travel on weekends. It also is beneficial to the environment as it reduces the
2
in the atmosphere from decreased street repairs, city heating, or even
3
as staff in office could send documents
4
Apart from that, other materials such as Vehicle-related, Highway-related and
5
materials will also be saved. Traditionally, a large amount of energy is needed to make
6
, e.g. Public transportation and private cars. With the rise of telecommuting, resources and
7
will be saved. And conservation goes to the energy and materials consumed in all
8
A
pollution
B
internet energy
C
paper usage
D
construction and maintenance
E
materials
F
shopping
G
productivity
H
fuels and gases
I
electronically
J
IT
K
equipment L company
M
work-related
N
geography

Teleworking has been said to have many benefits for both society and companies. Survey identified that telecommuters spend more time on 1 ____ than those traditional workers on changes in non-commuting travel on weekends. It also is beneficial to the environment as it reduces the 2 ____ in the atmosphere from decreased street repairs, city heating, or even 3 ____ as staff in office could send documents 4 ____ Apart from that, other materials such as Vehicle-related, Highway-related and 5 ____ materials will also be saved. Traditionally, a large amount of energy is needed to make 6 ____ , e.g. Public transportation and private cars. With the rise of telecommuting, resources and 7 ____ will be saved. And conservation goes to the energy and materials consumed in all 8 ____$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('80207d1f-a3cb-52c4-91b0-eca7b022602a', 'b5538930-125a-50d9-a70c-dd4d6362290e', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('154133b1-1d36-5220-8628-9845a4b730b9', 'b5538930-125a-50d9-a70c-dd4d6362290e', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2e903aa8-a3f5-52e8-b1ee-0655af271148', 'b5538930-125a-50d9-a70c-dd4d6362290e', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2d870bf3-e691-599f-aa9f-344a9dfaa43e', 'b5538930-125a-50d9-a70c-dd4d6362290e', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f7992bb8-aebe-56ae-ad16-67f7e73bd405', 'b5538930-125a-50d9-a70c-dd4d6362290e', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9fc95d49-4257-5d01-a46d-28a4d63369a8', 'b5538930-125a-50d9-a70c-dd4d6362290e', 6, $md$F$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d676556f-b8bd-5333-ae03-87cb10c72a00', 'b5538930-125a-50d9-a70c-dd4d6362290e', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fb675037-678d-53bf-a10b-6461e39e6587', 'b5538930-125a-50d9-a70c-dd4d6362290e', 8, $md$H$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e7b3d56e-4d2f-5513-9f6b-a1618ad7705a', 'b5538930-125a-50d9-a70c-dd4d6362290e', 9, $md$I$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e0e80146-abbf-5218-877b-6577d7086b91', 'b5538930-125a-50d9-a70c-dd4d6362290e', 10, $md$J$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3ad02f61-77f3-5f47-b56f-9ad472ead197', 'b5538930-125a-50d9-a70c-dd4d6362290e', 11, $md$K$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e1e11483-c9f8-58a0-a0f9-cc6ea5b1d343', 'b5538930-125a-50d9-a70c-dd4d6362290e', 12, $md$M$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8e51e42d-ca3e-5ec9-b172-e18f81773c9d', 'b5538930-125a-50d9-a70c-dd4d6362290e', 13, $md$N$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('16ab8b6f-d51b-5122-b4e2-d607cf01c418', 'e3c19bf4-280a-593e-b6cc-846711ff1d86', 4, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 4

Questions 1-8
Questions 1-8
Complete the summary using the list of words,
A-N
below.
Write the correct letter,
A-N
, in boxes
1-8
on your answer sheet.
Teleworking has been said to have many benefits for both society and companies. Survey identified that telecommuters spend more time on
1
than those traditional workers on changes in non-commuting travel on weekends. It also is beneficial to the environment as it reduces the
2
in the atmosphere from decreased street repairs, city heating, or even
3
as staff in office could send documents
4
Apart from that, other materials such as Vehicle-related, Highway-related and
5
materials will also be saved. Traditionally, a large amount of energy is needed to make
6
, e.g. Public transportation and private cars. With the rise of telecommuting, resources and
7
will be saved. And conservation goes to the energy and materials consumed in all
8
A
pollution
B
internet energy
C
paper usage
D
construction and maintenance
E
materials
F
shopping
G
productivity
H
fuels and gases
I
electronically
J
IT
K
equipment L company
M
work-related
N
geography

Teleworking has been said to have many benefits for both society and companies. Survey identified that telecommuters spend more time on 1 ____ than those traditional workers on changes in non-commuting travel on weekends. It also is beneficial to the environment as it reduces the 2 ____ in the atmosphere from decreased street repairs, city heating, or even 3 ____ as staff in office could send documents 4 ____ Apart from that, other materials such as Vehicle-related, Highway-related and 5 ____ materials will also be saved. Traditionally, a large amount of energy is needed to make 6 ____ , e.g. Public transportation and private cars. With the rise of telecommuting, resources and 7 ____ will be saved. And conservation goes to the energy and materials consumed in all 8 ____$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a5110c06-fb19-53a8-b5ca-1251aedd7e7a', '16ab8b6f-d51b-5122-b4e2-d607cf01c418', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('16d11574-1184-5689-859e-ee3d0a8d3f7f', '16ab8b6f-d51b-5122-b4e2-d607cf01c418', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b0c538ad-db2f-559b-960b-35008886fd6e', '16ab8b6f-d51b-5122-b4e2-d607cf01c418', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fdb52204-493c-571b-b1ad-435ae585a790', '16ab8b6f-d51b-5122-b4e2-d607cf01c418', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e8da2ec1-7cd6-5786-825b-041ac4b79874', '16ab8b6f-d51b-5122-b4e2-d607cf01c418', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ee352ab7-1d0b-5b2b-8262-661ce1196d26', '16ab8b6f-d51b-5122-b4e2-d607cf01c418', 6, $md$F$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('53025a72-47dc-5251-9ac8-494d368bdce2', '16ab8b6f-d51b-5122-b4e2-d607cf01c418', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8e290444-0c4e-5aa8-a46f-f02bf501b0e0', '16ab8b6f-d51b-5122-b4e2-d607cf01c418', 8, $md$H$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f075de38-8bd6-5012-8ec6-edd331f08b6a', '16ab8b6f-d51b-5122-b4e2-d607cf01c418', 9, $md$I$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c0e40e34-9fe0-5aeb-9ea0-f1c8287fe9d2', '16ab8b6f-d51b-5122-b4e2-d607cf01c418', 10, $md$J$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fba4030f-7338-5a74-9bcd-b4adab151164', '16ab8b6f-d51b-5122-b4e2-d607cf01c418', 11, $md$K$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e506019c-c6f7-55f2-b898-4469decba094', '16ab8b6f-d51b-5122-b4e2-d607cf01c418', 12, $md$M$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ae1cb8dc-d594-5ff7-9553-9d61c6a7dd81', '16ab8b6f-d51b-5122-b4e2-d607cf01c418', 13, $md$N$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('ab0bf094-2891-52c3-a4e7-e4c9571aa203', 'e3c19bf4-280a-593e-b6cc-846711ff1d86', 5, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 5

Questions 1-8
Questions 1-8
Complete the summary using the list of words,
A-N
below.
Write the correct letter,
A-N
, in boxes
1-8
on your answer sheet.
Teleworking has been said to have many benefits for both society and companies. Survey identified that telecommuters spend more time on
1
than those traditional workers on changes in non-commuting travel on weekends. It also is beneficial to the environment as it reduces the
2
in the atmosphere from decreased street repairs, city heating, or even
3
as staff in office could send documents
4
Apart from that, other materials such as Vehicle-related, Highway-related and
5
materials will also be saved. Traditionally, a large amount of energy is needed to make
6
, e.g. Public transportation and private cars. With the rise of telecommuting, resources and
7
will be saved. And conservation goes to the energy and materials consumed in all
8
A
pollution
B
internet energy
C
paper usage
D
construction and maintenance
E
materials
F
shopping
G
productivity
H
fuels and gases
I
electronically
J
IT
K
equipment L company
M
work-related
N
geography

Teleworking has been said to have many benefits for both society and companies. Survey identified that telecommuters spend more time on 1 ____ than those traditional workers on changes in non-commuting travel on weekends. It also is beneficial to the environment as it reduces the 2 ____ in the atmosphere from decreased street repairs, city heating, or even 3 ____ as staff in office could send documents 4 ____ Apart from that, other materials such as Vehicle-related, Highway-related and 5 ____ materials will also be saved. Traditionally, a large amount of energy is needed to make 6 ____ , e.g. Public transportation and private cars. With the rise of telecommuting, resources and 7 ____ will be saved. And conservation goes to the energy and materials consumed in all 8 ____$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a937266f-6ce7-5ea5-b028-3ac6ea15cc95', 'ab0bf094-2891-52c3-a4e7-e4c9571aa203', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('65e32004-7714-53b6-a091-cc28b634d321', 'ab0bf094-2891-52c3-a4e7-e4c9571aa203', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('261e3b7e-9ab1-51f6-865a-ef7d68f43b61', 'ab0bf094-2891-52c3-a4e7-e4c9571aa203', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ed98e484-b954-5bab-9d3f-0a206a364ff3', 'ab0bf094-2891-52c3-a4e7-e4c9571aa203', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5768d3db-b306-5508-88db-d4f158ff528d', 'ab0bf094-2891-52c3-a4e7-e4c9571aa203', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4680c694-cf67-5076-9ae1-454ac786aa0f', 'ab0bf094-2891-52c3-a4e7-e4c9571aa203', 6, $md$F$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3f98a9b2-5e6d-5a58-8788-6f77d69b1e5f', 'ab0bf094-2891-52c3-a4e7-e4c9571aa203', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b9d93f86-f255-5495-bb05-4f1e464bb360', 'ab0bf094-2891-52c3-a4e7-e4c9571aa203', 8, $md$H$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6b49e2b0-4fd5-5aaa-9d82-3ec9e0a1a0dd', 'ab0bf094-2891-52c3-a4e7-e4c9571aa203', 9, $md$I$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('66014e04-15bc-51a6-b418-20938ec5621e', 'ab0bf094-2891-52c3-a4e7-e4c9571aa203', 10, $md$J$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ea3f8b42-d4b2-56b3-85c2-111d60f9daa6', 'ab0bf094-2891-52c3-a4e7-e4c9571aa203', 11, $md$K$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5a41f9f7-fbdc-58c0-a4d8-16ab35309c63', 'ab0bf094-2891-52c3-a4e7-e4c9571aa203', 12, $md$M$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9000504a-f88f-52e5-8851-bb69de37bca1', 'ab0bf094-2891-52c3-a4e7-e4c9571aa203', 13, $md$N$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('0f54944e-7919-5125-a98d-ad5d0ff3ced4', 'e3c19bf4-280a-593e-b6cc-846711ff1d86', 6, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 6

Questions 1-8
Questions 1-8
Complete the summary using the list of words,
A-N
below.
Write the correct letter,
A-N
, in boxes
1-8
on your answer sheet.
Teleworking has been said to have many benefits for both society and companies. Survey identified that telecommuters spend more time on
1
than those traditional workers on changes in non-commuting travel on weekends. It also is beneficial to the environment as it reduces the
2
in the atmosphere from decreased street repairs, city heating, or even
3
as staff in office could send documents
4
Apart from that, other materials such as Vehicle-related, Highway-related and
5
materials will also be saved. Traditionally, a large amount of energy is needed to make
6
, e.g. Public transportation and private cars. With the rise of telecommuting, resources and
7
will be saved. And conservation goes to the energy and materials consumed in all
8
A
pollution
B
internet energy
C
paper usage
D
construction and maintenance
E
materials
F
shopping
G
productivity
H
fuels and gases
I
electronically
J
IT
K
equipment L company
M
work-related
N
geography

Teleworking has been said to have many benefits for both society and companies. Survey identified that telecommuters spend more time on 1 ____ than those traditional workers on changes in non-commuting travel on weekends. It also is beneficial to the environment as it reduces the 2 ____ in the atmosphere from decreased street repairs, city heating, or even 3 ____ as staff in office could send documents 4 ____ Apart from that, other materials such as Vehicle-related, Highway-related and 5 ____ materials will also be saved. Traditionally, a large amount of energy is needed to make 6 ____ , e.g. Public transportation and private cars. With the rise of telecommuting, resources and 7 ____ will be saved. And conservation goes to the energy and materials consumed in all 8 ____$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c96fa7db-a4be-57f0-a1ae-189d0827bdb9', '0f54944e-7919-5125-a98d-ad5d0ff3ced4', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bef62b38-ab8a-5067-a66d-2f6c2b5d04dd', '0f54944e-7919-5125-a98d-ad5d0ff3ced4', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('172f27e3-3a62-5d1e-a6e5-cb9bebf9f1ed', '0f54944e-7919-5125-a98d-ad5d0ff3ced4', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3121eb66-06f8-514b-b323-1aecaa211a8a', '0f54944e-7919-5125-a98d-ad5d0ff3ced4', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7cd422fc-6c49-5adb-aaea-002735951d01', '0f54944e-7919-5125-a98d-ad5d0ff3ced4', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a045fa65-1be3-5752-9cb8-19c146063f4b', '0f54944e-7919-5125-a98d-ad5d0ff3ced4', 6, $md$F$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('eb626888-da21-5b09-af47-a16a989fcb7d', '0f54944e-7919-5125-a98d-ad5d0ff3ced4', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2649590f-2625-5d95-a83d-72079712cf8a', '0f54944e-7919-5125-a98d-ad5d0ff3ced4', 8, $md$H$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1e1f4b52-46b4-5983-8216-a3edfb1d9d4b', '0f54944e-7919-5125-a98d-ad5d0ff3ced4', 9, $md$I$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('facf06ba-f0bc-592b-810e-17bbc58f8fc9', '0f54944e-7919-5125-a98d-ad5d0ff3ced4', 10, $md$J$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('25d83647-6230-5959-8f52-1d8eb21ed9fa', '0f54944e-7919-5125-a98d-ad5d0ff3ced4', 11, $md$K$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('36bc1ddb-c681-55ea-b1fc-4f5b2636f545', '0f54944e-7919-5125-a98d-ad5d0ff3ced4', 12, $md$M$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3667c6ce-9525-5108-9283-3c0c8a726e55', '0f54944e-7919-5125-a98d-ad5d0ff3ced4', 13, $md$N$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('d44570a3-6536-5241-99c5-1b026d978d63', 'e3c19bf4-280a-593e-b6cc-846711ff1d86', 7, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 7

Questions 1-8
Questions 1-8
Complete the summary using the list of words,
A-N
below.
Write the correct letter,
A-N
, in boxes
1-8
on your answer sheet.
Teleworking has been said to have many benefits for both society and companies. Survey identified that telecommuters spend more time on
1
than those traditional workers on changes in non-commuting travel on weekends. It also is beneficial to the environment as it reduces the
2
in the atmosphere from decreased street repairs, city heating, or even
3
as staff in office could send documents
4
Apart from that, other materials such as Vehicle-related, Highway-related and
5
materials will also be saved. Traditionally, a large amount of energy is needed to make
6
, e.g. Public transportation and private cars. With the rise of telecommuting, resources and
7
will be saved. And conservation goes to the energy and materials consumed in all
8
A
pollution
B
internet energy
C
paper usage
D
construction and maintenance
E
materials
F
shopping
G
productivity
H
fuels and gases
I
electronically
J
IT
K
equipment L company
M
work-related
N
geography

Teleworking has been said to have many benefits for both society and companies. Survey identified that telecommuters spend more time on 1 ____ than those traditional workers on changes in non-commuting travel on weekends. It also is beneficial to the environment as it reduces the 2 ____ in the atmosphere from decreased street repairs, city heating, or even 3 ____ as staff in office could send documents 4 ____ Apart from that, other materials such as Vehicle-related, Highway-related and 5 ____ materials will also be saved. Traditionally, a large amount of energy is needed to make 6 ____ , e.g. Public transportation and private cars. With the rise of telecommuting, resources and 7 ____ will be saved. And conservation goes to the energy and materials consumed in all 8 ____$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f5249514-d76a-53a6-8f0d-6a197b1b0284', 'd44570a3-6536-5241-99c5-1b026d978d63', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('001d20b8-58eb-5111-96d0-b2527969f9fe', 'd44570a3-6536-5241-99c5-1b026d978d63', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6303bdb0-6aac-5925-9c65-21e926ace12a', 'd44570a3-6536-5241-99c5-1b026d978d63', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2539e5af-afc8-5095-89a0-dee851cf52a0', 'd44570a3-6536-5241-99c5-1b026d978d63', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('935bf194-7f6d-5787-bda4-53f8fb2fe64a', 'd44570a3-6536-5241-99c5-1b026d978d63', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('dbefc5b1-ff47-575f-a96c-a57e7dcc9e0c', 'd44570a3-6536-5241-99c5-1b026d978d63', 6, $md$F$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('af3678ef-6d3d-5ee8-a8ff-b10eb02941d8', 'd44570a3-6536-5241-99c5-1b026d978d63', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fd98e401-8228-579e-a274-53e1249ca97e', 'd44570a3-6536-5241-99c5-1b026d978d63', 8, $md$H$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a08f8c25-4676-5bb7-b265-c96d083bce96', 'd44570a3-6536-5241-99c5-1b026d978d63', 9, $md$I$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('036f22b9-3174-5ab1-8535-014099179e5f', 'd44570a3-6536-5241-99c5-1b026d978d63', 10, $md$J$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('64af0138-a2e3-5ea6-b4fb-91574b9baaf0', 'd44570a3-6536-5241-99c5-1b026d978d63', 11, $md$K$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('514d5fff-4b8f-5b62-a6c0-ece4ec15c3ca', 'd44570a3-6536-5241-99c5-1b026d978d63', 12, $md$M$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e9f2690e-5487-5bc7-b1ca-725966b5adfd', 'd44570a3-6536-5241-99c5-1b026d978d63', 13, $md$N$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('8127af22-3fd6-54f0-94f1-ea11cd22bbe0', 'e3c19bf4-280a-593e-b6cc-846711ff1d86', 8, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 8

Questions 1-8
Questions 1-8
Complete the summary using the list of words,
A-N
below.
Write the correct letter,
A-N
, in boxes
1-8
on your answer sheet.
Teleworking has been said to have many benefits for both society and companies. Survey identified that telecommuters spend more time on
1
than those traditional workers on changes in non-commuting travel on weekends. It also is beneficial to the environment as it reduces the
2
in the atmosphere from decreased street repairs, city heating, or even
3
as staff in office could send documents
4
Apart from that, other materials such as Vehicle-related, Highway-related and
5
materials will also be saved. Traditionally, a large amount of energy is needed to make
6
, e.g. Public transportation and private cars. With the rise of telecommuting, resources and
7
will be saved. And conservation goes to the energy and materials consumed in all
8
A
pollution
B
internet energy
C
paper usage
D
construction and maintenance
E
materials
F
shopping
G
productivity
H
fuels and gases
I
electronically
J
IT
K
equipment L company
M
work-related
N
geography

Teleworking has been said to have many benefits for both society and companies. Survey identified that telecommuters spend more time on 1 ____ than those traditional workers on changes in non-commuting travel on weekends. It also is beneficial to the environment as it reduces the 2 ____ in the atmosphere from decreased street repairs, city heating, or even 3 ____ as staff in office could send documents 4 ____ Apart from that, other materials such as Vehicle-related, Highway-related and 5 ____ materials will also be saved. Traditionally, a large amount of energy is needed to make 6 ____ , e.g. Public transportation and private cars. With the rise of telecommuting, resources and 7 ____ will be saved. And conservation goes to the energy and materials consumed in all 8 ____$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f7ffbdc1-a32f-5491-b836-ce2133ff1274', '8127af22-3fd6-54f0-94f1-ea11cd22bbe0', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('054c5d5c-cc1f-528a-bac4-5cd0fada29e1', '8127af22-3fd6-54f0-94f1-ea11cd22bbe0', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f4bc75a8-5f23-5038-90bd-3f0ec4c46653', '8127af22-3fd6-54f0-94f1-ea11cd22bbe0', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('173d90de-75e1-5ea1-b80a-918e6fb17b62', '8127af22-3fd6-54f0-94f1-ea11cd22bbe0', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fe810b81-574d-5e09-b7ce-af0fa8a2c844', '8127af22-3fd6-54f0-94f1-ea11cd22bbe0', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('19c5fbda-d0ae-5103-9a9e-4b45609277ca', '8127af22-3fd6-54f0-94f1-ea11cd22bbe0', 6, $md$F$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('00aa9597-beb2-5cea-a5fc-988c23eafae0', '8127af22-3fd6-54f0-94f1-ea11cd22bbe0', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('47755663-3171-57de-bd97-2409a623b5e1', '8127af22-3fd6-54f0-94f1-ea11cd22bbe0', 8, $md$H$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c0953535-98a0-5c32-a754-5cfdf16487f6', '8127af22-3fd6-54f0-94f1-ea11cd22bbe0', 9, $md$I$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d3d0d54c-d423-5456-9970-0adbbee445cc', '8127af22-3fd6-54f0-94f1-ea11cd22bbe0', 10, $md$J$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8a5dbc24-f561-5e36-bb79-cda98e7f7650', '8127af22-3fd6-54f0-94f1-ea11cd22bbe0', 11, $md$K$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('09e5c149-23cc-59ce-b573-e917cdda2af1', '8127af22-3fd6-54f0-94f1-ea11cd22bbe0', 12, $md$M$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('224080d8-8cfb-56ea-8b4d-db76175561ff', '8127af22-3fd6-54f0-94f1-ea11cd22bbe0', 13, $md$N$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('1eb12133-6714-5747-850a-2876d516dc29', 'e3c19bf4-280a-593e-b6cc-846711ff1d86', 9, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 9

Questions 9-12
Questions 9-12
Complete each sentence with the correct ending,
A-F
, below.
Write the correct letter,
A-F
, in box
9-12
on your answer sheet.
9
More working time is often connected with:
10
Oracle’s Functional idea aims to improve:
11
When you work at office equipments such as computers and printers are maintained by:
12
When work from home using hardware and software:
A
stress and tension.
B
consumption of goods.
C
the problem of less communication with colleagues.
D
many problems when equipment doesn’t work.
E
transport equipment such as automobiles.
F
technical supporters.

9 ____ More working time is often connected with:$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d3d3dbc7-38f7-5b7c-b45d-bbf60ddae33c', '1eb12133-6714-5747-850a-2876d516dc29', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a9560e50-8264-5bad-90fa-3a91724b93b8', '1eb12133-6714-5747-850a-2876d516dc29', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b0bd1aa7-9730-5554-a4e4-1bbdbcabbfb9', '1eb12133-6714-5747-850a-2876d516dc29', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7b721ec2-c2d6-581c-8647-a2e5c4907bd8', '1eb12133-6714-5747-850a-2876d516dc29', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('65eea068-55c4-505c-82ff-d8d47a31fbc7', '1eb12133-6714-5747-850a-2876d516dc29', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1ef19d29-4e42-5316-bd30-fb49ec6c552d', '1eb12133-6714-5747-850a-2876d516dc29', 6, $md$F$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('59e33c04-a6fc-5dea-9393-dabd22390417', 'e3c19bf4-280a-593e-b6cc-846711ff1d86', 10, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 10

Questions 9-12
Questions 9-12
Complete each sentence with the correct ending,
A-F
, below.
Write the correct letter,
A-F
, in box
9-12
on your answer sheet.
9
More working time is often connected with:
10
Oracle’s Functional idea aims to improve:
11
When you work at office equipments such as computers and printers are maintained by:
12
When work from home using hardware and software:
A
stress and tension.
B
consumption of goods.
C
the problem of less communication with colleagues.
D
many problems when equipment doesn’t work.
E
transport equipment such as automobiles.
F
technical supporters.

10 ____ Oracle’s Functional idea aims to improve:$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('22310455-c453-58a5-9c2e-06f2ec00e1cd', '59e33c04-a6fc-5dea-9393-dabd22390417', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1a397093-b9b6-5e96-b4bd-4b6b0d581dc0', '59e33c04-a6fc-5dea-9393-dabd22390417', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7d33451f-edb1-5038-ae99-b4856f5eb070', '59e33c04-a6fc-5dea-9393-dabd22390417', 3, $md$C$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f8d29ed6-61bb-55c2-b56a-8cd238097950', '59e33c04-a6fc-5dea-9393-dabd22390417', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0aabf9ac-6675-56f3-9798-39a5a6ae69f3', '59e33c04-a6fc-5dea-9393-dabd22390417', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3746791c-f943-54bb-aa81-75bd311198ce', '59e33c04-a6fc-5dea-9393-dabd22390417', 6, $md$F$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('cad86b21-9d03-583b-a867-d9da6046d669', 'e3c19bf4-280a-593e-b6cc-846711ff1d86', 11, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 11

Questions 9-12
Questions 9-12
Complete each sentence with the correct ending,
A-F
, below.
Write the correct letter,
A-F
, in box
9-12
on your answer sheet.
9
More working time is often connected with:
10
Oracle’s Functional idea aims to improve:
11
When you work at office equipments such as computers and printers are maintained by:
12
When work from home using hardware and software:
A
stress and tension.
B
consumption of goods.
C
the problem of less communication with colleagues.
D
many problems when equipment doesn’t work.
E
transport equipment such as automobiles.
F
technical supporters.

11 ____ When you work at office equipments such as computers and printers are maintained by:$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1898d832-e674-50d4-bdcc-b5cec603d035', 'cad86b21-9d03-583b-a867-d9da6046d669', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8dc10628-4cf2-5206-bd3f-51ba497a6da2', 'cad86b21-9d03-583b-a867-d9da6046d669', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2494c777-7808-5709-92a5-ccfc80072441', 'cad86b21-9d03-583b-a867-d9da6046d669', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('446cab87-c5e9-53a2-8147-15ee41409c74', 'cad86b21-9d03-583b-a867-d9da6046d669', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0acf9ced-4d7f-5e87-99f1-f7ee8aef4bb3', 'cad86b21-9d03-583b-a867-d9da6046d669', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('de936c55-79cd-5de0-bb1f-de936315490b', 'cad86b21-9d03-583b-a867-d9da6046d669', 6, $md$F$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('02fceabb-06ea-5657-8074-68e59a005c01', 'e3c19bf4-280a-593e-b6cc-846711ff1d86', 12, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 12

Questions 9-12
Questions 9-12
Complete each sentence with the correct ending,
A-F
, below.
Write the correct letter,
A-F
, in box
9-12
on your answer sheet.
9
More working time is often connected with:
10
Oracle’s Functional idea aims to improve:
11
When you work at office equipments such as computers and printers are maintained by:
12
When work from home using hardware and software:
A
stress and tension.
B
consumption of goods.
C
the problem of less communication with colleagues.
D
many problems when equipment doesn’t work.
E
transport equipment such as automobiles.
F
technical supporters.

12 ____ When work from home using hardware and software:$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('72315f02-8419-5444-9d22-b38d9614dcc9', '02fceabb-06ea-5657-8074-68e59a005c01', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7d5a6b16-b210-5cf9-92c0-696e680fe67f', '02fceabb-06ea-5657-8074-68e59a005c01', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('83cfa36c-bd37-5284-bc3e-c677a5374f09', '02fceabb-06ea-5657-8074-68e59a005c01', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e20c49eb-f22d-53c4-84fa-03549a5c0cf1', '02fceabb-06ea-5657-8074-68e59a005c01', 4, $md$D$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6aaf5dff-2c83-5f11-a8a5-a63d028e32e4', '02fceabb-06ea-5657-8074-68e59a005c01', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('92c8578a-ba8a-5c79-8bf5-7deb2588a7fb', '02fceabb-06ea-5657-8074-68e59a005c01', 6, $md$F$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('b76305a8-c920-584e-8bb1-01f35c266a10', 'e3c19bf4-280a-593e-b6cc-846711ff1d86', 13, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 13

Questions 13
Questions 13
Answer the question
13
and choose correct letter
A
,
B
,
C
or
D
.
Implied in the passage, what is the author’s attitude toward Telework?
A
surprised by its fast growth
B
unconcerned about the future pattern
C
believe it is generally positive and encouraging
D
worried in the economical problems arise

Answer the question 13 and choose correct letter A , B , C or D .$md$, NULL);

COMMIT;
