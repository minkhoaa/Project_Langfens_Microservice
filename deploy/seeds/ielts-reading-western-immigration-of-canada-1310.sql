BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-western-immigration-of-canada-1310'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-western-immigration-of-canada-1310';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-western-immigration-of-canada-1310';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-western-immigration-of-canada-1310';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('332e8e71-3c8e-50d9-845b-5914dbbe1787', 'ielts-reading-western-immigration-of-canada-1310', $t$Western Immigration of Canada$t$, $md$## Western Immigration of Canada

Nguồn:
- Test: https://mini-ielts.com/1310/reading/western-immigration-of-canada
- Solution: https://mini-ielts.com/1310/view-solution/reading/western-immigration-of-canada$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('7be15ce1-fb67-56a2-9f50-eab93f75c813', '332e8e71-3c8e-50d9-845b-5914dbbe1787', 1, $t$Reading — Western Immigration of Canada$t$, $md$Read the passage and answer questions **1–13**.

### Passage: Western Immigration of Canada

A

By the mid-1870s Canada wanted an immigrant population of agricultural settlers established in the West. No urban centres existed on the prairies in the 1870s, and rural settlement was the focus of the federal government’s attention. The western rural settlement was desired, as it would provide homesteads for the sons and daughters of eastern farmers, as eastern agricultural landfilled to capacity. As well, eastern farmers and politicians viewed western Canada, with its broad expanses of unpopulated land, as a prime location for expanding Canada’s agricultural output, especially in terms of wheat production to serve the markets of eastern Canada.

B

To bolster Canada’s population and agricultural output, the federal government took steps to secure western land. The Dominion of Canada purchased Rupert’s Land from the Hudson’s Bay Company in 1870. In 1872, the federal government enacted the Dominion Lands Act. This act enabled settlers to acquire 160 acres of free land, as long as settlers remained on their land for a period of three years, made certain minor improvements to the land, and paid a $10.00 registration fee. The Canadian government also created a Mounted Police Force in 1873. The Mounties journeyed west to secure the area for future settlers. By 1876 the NWMP had established themselves in the West. The major posts included Swan River, Fort Saskatchewan, Fort Calgary, Fort Walsh and Fort Macleod. All of these initiatives attracted a number of eastern-Canadian settlers, as well as European and American immigrants, to Canada’s West, and particularly to the area of Manitoba.

C

The surest way to protect Canadian territory, and to achieve the secondary goal for joining British Columbia to the rest of the country, was to import large numbers of Eastern Canadian and British settlers. Settling the West also made imperative the building of a transcontinental railway. The railway would work to create an east-west economy, in which western Canada would feed the growing urban industrial population of the east, and in return become a market for eastern Canadian manufactured goods.

D

Winnipeg became the metropolis of the West during this period. Winnipeg’s growth before 1900 was the result of a combination of land speculation, growth of housing starts, and the federal government’s solution in 1881 of Winnipeg as a major stop along the CPR. This decision culminated in a land boom between 1881 and 1883 which resulted in the transformation of hamlets like Portage la Prairie and Brandon into towns, and a large increase in Manitoba’s population. Soon, Winnipeg stood at the junction of three transcontinental railway lines which employed thousands in rail yards. Winnipeg also became the major processor of agricultural products for the surrounding hinterland.

E

The majority of settlers to Winnipeg, and the surrounding countryside, during this early period, were primarily Protestant English-speaking settlers from Ontario and the British Isles. These settlers established Winnipeg upon a British-Ontarian ethos which came to dominate the society’s social, political, and economic spirit. This British-Ontarian ethnic homogeneity, however, did not last very long. Increasing numbers of foreign immigrants, especially from Austria-Hungary and Ukraine soon added a new ethnic element to the recent British, the older First Nation Métis, and Selkirk’s settler population base. Settling the West with (in particular) Eastern Canadians and British immigrant offered the advantage of safeguarding the 49th parallel from the threat of American take-over, had not the Minnesota legislature passed a resolution which provided for the annexation of the Red River district. The Red River in 1870 was the most important settlement on the Canadian prairies. It contained 11,963 inhabitants of whom 9,700 were Métis and First Nations. But neighbouring Minnesota already had a population of over 100,000.

F

Not all of the settlers who came to western Canada in the 1880s, however, desired to remain there. In the 1870s and 1880s, economic depression kept the value of Canada’s staple exports low, which discouraged many from permanent settlement in the West. Countries including Brazil, Argentina, Australia, New Zealand and the United States competed with Canada for immigrants. Many immigrants and thousands of Canadians chose to settle in the accessible and attractive American frontier. Canada before 1891 has been called “a huge demographic railway station” where thousands of men, women, and children were constantly going and coming, and where the number of departures invariably exceeded that of arrivals.”

G

By 1891 Eastern Canada had its share of both large urban centres and problems associated with city life. While the booming economic centres of Toronto and Montreal were complete with electricity and telephones in the cities’ wealthiest areas by the turn of the century, slum conditions characterised the poorest areas like the district known as ‘the Ward’ in Toronto. Chickens and pigs ran through the streets; privy buckets spilled onto backyards and lanes creating cesspools in urban slums. These same social reformers believed that rural living, in stark contrast to urban, would lead to a healthy, moral, and charitable way of life. Social reformers praised the ability of fresh air, hard work, and open spaces for ‘Canadianizing’ immigrants. Agricultural pursuits were seen as especially fitting for attaining this ‘moral’ and family-oriented way of life, in opposition to the single male-dominated atmosphere of the cities. Certainly, agriculture played an important part in the Canadian economy in 1891. One-third of the workforce worked on farms.

H

The Canadian government presented Canada’s attractions to potential overseas migrants in several ways. The government offered free or cheap land to potential agriculturists. As well, the government established agents and/or agencies for the purpose of attracting emigrants overseas. Assisted passage schemes, bonuses and commissions to agents and settlers and pamphlets also attracted some immigrants to Canada. The most influential form of attracting others to Canada, however, remained the letters home written by emigrants already in Canada. Letters from trusted friends and family members. Letters home often contained exaggerations of the ‘wonder of the new world.’ Migrant workers and settlers already in Canada did not want to disappoint, or worry, their family and friends at home. Embellished tales of good fortune and happiness often succeeded in encouraging others to come.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('af67beab-effb-5843-ac08-c1d76bd58cca', '7be15ce1-fb67-56a2-9f50-eab93f75c813', 1, 'MATCHING_HEADING', 'READING', 2, $md$### Question 1

Questions 1-7
Questions 1-7
The Reading Passage has eight paragraphs
A-H
Choose the correct heading for paragraphs
A-H
from the list below.
Write the correct number,
i-xii
, in boxes
1-7
on your answer sheet
List of Headings
i
Not all would stay in Canada forever
ii
Government’s safeguard in the West
iii
Eastern Canada is full
iv
Built-up to the new infrastructure
v
An exclusive British domination in Ontario established ever since
vi
Ethnics and language make-up
vii
Pursuing a pure life
viii
Police recruited from mid-class families
ix
Demand of western immigration
x
Early major urban development of the West
xi
Attracting urban environment
xii
Advertising of Western Canada
Example:
Paragraph
A
ix
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
7
Paragraph H

1 ____ Paragraph B$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fa5cc0d0-3d66-546c-be4e-b71f1097bb01', 'af67beab-effb-5843-ac08-c1d76bd58cca', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('67ab061b-6597-5b57-bcfa-2f6eb54c6db3', 'af67beab-effb-5843-ac08-c1d76bd58cca', 2, $md$ii$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fc8b6f1e-8ac2-53da-ad69-afda14e22160', 'af67beab-effb-5843-ac08-c1d76bd58cca', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5e67464c-3f38-5e94-86a5-2dd339b8ee64', 'af67beab-effb-5843-ac08-c1d76bd58cca', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('619538b6-1ce4-594a-9a9a-a1af8ce625b3', 'af67beab-effb-5843-ac08-c1d76bd58cca', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3fa82a17-4351-5773-a8ca-5a70d9952066', 'af67beab-effb-5843-ac08-c1d76bd58cca', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('17182b02-796c-51c2-a898-e04573fdad69', 'af67beab-effb-5843-ac08-c1d76bd58cca', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a4430968-2b45-52ef-9bb6-11ac0a301e1e', 'af67beab-effb-5843-ac08-c1d76bd58cca', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('accf736f-fb90-56f3-b2e3-bbe08bd742e8', 'af67beab-effb-5843-ac08-c1d76bd58cca', 9, $md$ix$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ca1f3370-4613-5347-97fe-41f34148bc0f', 'af67beab-effb-5843-ac08-c1d76bd58cca', 10, $md$x$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c7224c8d-a585-5240-9e8b-892af7aea224', 'af67beab-effb-5843-ac08-c1d76bd58cca', 11, $md$xi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ace6ad22-2fe6-590c-a0b8-e018f9a1774c', 'af67beab-effb-5843-ac08-c1d76bd58cca', 12, $md$xii$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('0c9db8b6-f401-5623-af50-59123df801d5', '7be15ce1-fb67-56a2-9f50-eab93f75c813', 2, 'MATCHING_HEADING', 'READING', 2, $md$### Question 2

Questions 1-7
Questions 1-7
The Reading Passage has eight paragraphs
A-H
Choose the correct heading for paragraphs
A-H
from the list below.
Write the correct number,
i-xii
, in boxes
1-7
on your answer sheet
List of Headings
i
Not all would stay in Canada forever
ii
Government’s safeguard in the West
iii
Eastern Canada is full
iv
Built-up to the new infrastructure
v
An exclusive British domination in Ontario established ever since
vi
Ethnics and language make-up
vii
Pursuing a pure life
viii
Police recruited from mid-class families
ix
Demand of western immigration
x
Early major urban development of the West
xi
Attracting urban environment
xii
Advertising of Western Canada
Example:
Paragraph
A
ix
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
7
Paragraph H

2 ____ Paragraph C$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a2f89b9a-6dcb-54ed-bf56-9b4c437c5040', '0c9db8b6-f401-5623-af50-59123df801d5', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5ed5455f-e85c-5de0-a587-fef5a3e0f6c7', '0c9db8b6-f401-5623-af50-59123df801d5', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('610864d1-19c2-5773-a154-f5aef117226b', '0c9db8b6-f401-5623-af50-59123df801d5', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ee007582-1916-5c05-867b-3e32d19ea2f2', '0c9db8b6-f401-5623-af50-59123df801d5', 4, $md$iv$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('641637f2-8942-575c-a6cf-68707ebba798', '0c9db8b6-f401-5623-af50-59123df801d5', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('618b9af3-21ff-52c3-abfa-fe1f7332da74', '0c9db8b6-f401-5623-af50-59123df801d5', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f85be8d9-9e9a-55f7-9669-8f40d29ace45', '0c9db8b6-f401-5623-af50-59123df801d5', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d35082b6-ffdf-5559-bb72-4b8d60aa9e75', '0c9db8b6-f401-5623-af50-59123df801d5', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('419098a8-f415-5c07-8cd0-764295aa12fc', '0c9db8b6-f401-5623-af50-59123df801d5', 9, $md$ix$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b83790ca-e252-5380-908e-0f26acaf4dd9', '0c9db8b6-f401-5623-af50-59123df801d5', 10, $md$x$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2ec33f26-91f0-5775-bd6e-54053e4cf58e', '0c9db8b6-f401-5623-af50-59123df801d5', 11, $md$xi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('dc914921-6bf1-5654-8198-035366e5e1be', '0c9db8b6-f401-5623-af50-59123df801d5', 12, $md$xii$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('489aae10-fcbf-52a8-98d4-f901be241022', '7be15ce1-fb67-56a2-9f50-eab93f75c813', 3, 'MATCHING_HEADING', 'READING', 2, $md$### Question 3

Questions 1-7
Questions 1-7
The Reading Passage has eight paragraphs
A-H
Choose the correct heading for paragraphs
A-H
from the list below.
Write the correct number,
i-xii
, in boxes
1-7
on your answer sheet
List of Headings
i
Not all would stay in Canada forever
ii
Government’s safeguard in the West
iii
Eastern Canada is full
iv
Built-up to the new infrastructure
v
An exclusive British domination in Ontario established ever since
vi
Ethnics and language make-up
vii
Pursuing a pure life
viii
Police recruited from mid-class families
ix
Demand of western immigration
x
Early major urban development of the West
xi
Attracting urban environment
xii
Advertising of Western Canada
Example:
Paragraph
A
ix
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
7
Paragraph H

3 ____ Paragraph D$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f61ecb20-3855-5760-b8e9-1dfba74e965f', '489aae10-fcbf-52a8-98d4-f901be241022', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c1a7acfd-d7b9-5bd8-aa5a-2ddf350b88e2', '489aae10-fcbf-52a8-98d4-f901be241022', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('40a80552-bb42-596f-842e-7f865c679cb6', '489aae10-fcbf-52a8-98d4-f901be241022', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cb4d6f36-8c48-585a-a773-d945d1f89af2', '489aae10-fcbf-52a8-98d4-f901be241022', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('10b5f4c2-a821-559b-a348-0e791add3d5c', '489aae10-fcbf-52a8-98d4-f901be241022', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('da4f55a6-3c53-5ce1-a514-07b09410f8d2', '489aae10-fcbf-52a8-98d4-f901be241022', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2025bfe2-8c92-5a53-87da-4083ae71495c', '489aae10-fcbf-52a8-98d4-f901be241022', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('87b2dfb8-fb93-5d31-a805-de8de8d39faa', '489aae10-fcbf-52a8-98d4-f901be241022', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d135cdcb-566d-5e9a-811d-ce4f29e3fb9a', '489aae10-fcbf-52a8-98d4-f901be241022', 9, $md$ix$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c2600ea9-88ec-5032-a90a-6a3e59df3260', '489aae10-fcbf-52a8-98d4-f901be241022', 10, $md$x$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('505ee6a4-cf48-5879-897d-f283ef456f87', '489aae10-fcbf-52a8-98d4-f901be241022', 11, $md$xi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('73d09548-49ba-5629-b910-9bf2966aa150', '489aae10-fcbf-52a8-98d4-f901be241022', 12, $md$xii$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('03b07ea3-6c7a-52ba-bf80-1f50de126110', '7be15ce1-fb67-56a2-9f50-eab93f75c813', 4, 'MATCHING_HEADING', 'READING', 2, $md$### Question 4

Questions 1-7
Questions 1-7
The Reading Passage has eight paragraphs
A-H
Choose the correct heading for paragraphs
A-H
from the list below.
Write the correct number,
i-xii
, in boxes
1-7
on your answer sheet
List of Headings
i
Not all would stay in Canada forever
ii
Government’s safeguard in the West
iii
Eastern Canada is full
iv
Built-up to the new infrastructure
v
An exclusive British domination in Ontario established ever since
vi
Ethnics and language make-up
vii
Pursuing a pure life
viii
Police recruited from mid-class families
ix
Demand of western immigration
x
Early major urban development of the West
xi
Attracting urban environment
xii
Advertising of Western Canada
Example:
Paragraph
A
ix
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
7
Paragraph H

4 ____ Paragraph E$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('71dd03db-1a44-51d4-a09b-174d5711c8c7', '03b07ea3-6c7a-52ba-bf80-1f50de126110', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ee0afd24-65f7-5b6a-afd0-8814f1f77639', '03b07ea3-6c7a-52ba-bf80-1f50de126110', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f9b2dffa-2c12-55c6-9bf9-e0369259f23e', '03b07ea3-6c7a-52ba-bf80-1f50de126110', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('727d91ae-3a18-5fbf-8f67-d7329ef5a408', '03b07ea3-6c7a-52ba-bf80-1f50de126110', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d5b5a6ac-6639-51e9-af34-565853147c23', '03b07ea3-6c7a-52ba-bf80-1f50de126110', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('67c05642-b78f-5e93-b6f1-b09024975b57', '03b07ea3-6c7a-52ba-bf80-1f50de126110', 6, $md$vi$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7656fcbb-d42f-58e1-bb1b-b2b1fa56fa03', '03b07ea3-6c7a-52ba-bf80-1f50de126110', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('710b26a5-3250-5118-96e5-26ebe041f7d3', '03b07ea3-6c7a-52ba-bf80-1f50de126110', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('048491bf-aa6d-5923-9eec-229047a2addc', '03b07ea3-6c7a-52ba-bf80-1f50de126110', 9, $md$ix$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d0620679-5ae1-5594-a826-cfcdd6976d1e', '03b07ea3-6c7a-52ba-bf80-1f50de126110', 10, $md$x$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fbec1072-e564-59b1-aaf9-e0e96dcd2ae6', '03b07ea3-6c7a-52ba-bf80-1f50de126110', 11, $md$xi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3268659c-cd2f-5084-af98-31ff6ff1afd7', '03b07ea3-6c7a-52ba-bf80-1f50de126110', 12, $md$xii$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('f9804644-c1b9-5f19-9678-638f0d600d92', '7be15ce1-fb67-56a2-9f50-eab93f75c813', 5, 'MATCHING_HEADING', 'READING', 3, $md$### Question 5

Questions 1-7
Questions 1-7
The Reading Passage has eight paragraphs
A-H
Choose the correct heading for paragraphs
A-H
from the list below.
Write the correct number,
i-xii
, in boxes
1-7
on your answer sheet
List of Headings
i
Not all would stay in Canada forever
ii
Government’s safeguard in the West
iii
Eastern Canada is full
iv
Built-up to the new infrastructure
v
An exclusive British domination in Ontario established ever since
vi
Ethnics and language make-up
vii
Pursuing a pure life
viii
Police recruited from mid-class families
ix
Demand of western immigration
x
Early major urban development of the West
xi
Attracting urban environment
xii
Advertising of Western Canada
Example:
Paragraph
A
ix
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
7
Paragraph H

5 ____ Paragraph F$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8e584cd8-dfb9-5ef5-a5d8-f6ebfe16900b', 'f9804644-c1b9-5f19-9678-638f0d600d92', 1, $md$i$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e6907be8-449c-538b-8760-ce67d6ebea45', 'f9804644-c1b9-5f19-9678-638f0d600d92', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3caac884-99df-5c7e-b882-a9e430486230', 'f9804644-c1b9-5f19-9678-638f0d600d92', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c3af9fa1-1745-532e-9494-a1d7d049d445', 'f9804644-c1b9-5f19-9678-638f0d600d92', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9af0d66e-01fa-5c5c-9222-5fb0e57f2069', 'f9804644-c1b9-5f19-9678-638f0d600d92', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('272f3f98-6b9f-51bd-9e69-cd436b3614bb', 'f9804644-c1b9-5f19-9678-638f0d600d92', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('41448189-eb26-5288-8539-fa168befe0b2', 'f9804644-c1b9-5f19-9678-638f0d600d92', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1d6c3876-1699-56ca-a501-db15f8e87cf3', 'f9804644-c1b9-5f19-9678-638f0d600d92', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('745ddf92-a54c-5d64-91d3-6d1e30886d7c', 'f9804644-c1b9-5f19-9678-638f0d600d92', 9, $md$ix$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('71ac9f3e-f315-5c13-96bc-ef58c182d88f', 'f9804644-c1b9-5f19-9678-638f0d600d92', 10, $md$x$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f67662f7-ce75-5502-b69d-b0f4759adb5f', 'f9804644-c1b9-5f19-9678-638f0d600d92', 11, $md$xi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6f90fbe8-f74b-505f-b473-221d1c3d677a', 'f9804644-c1b9-5f19-9678-638f0d600d92', 12, $md$xii$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('7cb68d76-fd7c-58b0-8b78-72f1d7800b9c', '7be15ce1-fb67-56a2-9f50-eab93f75c813', 6, 'MATCHING_HEADING', 'READING', 3, $md$### Question 6

Questions 1-7
Questions 1-7
The Reading Passage has eight paragraphs
A-H
Choose the correct heading for paragraphs
A-H
from the list below.
Write the correct number,
i-xii
, in boxes
1-7
on your answer sheet
List of Headings
i
Not all would stay in Canada forever
ii
Government’s safeguard in the West
iii
Eastern Canada is full
iv
Built-up to the new infrastructure
v
An exclusive British domination in Ontario established ever since
vi
Ethnics and language make-up
vii
Pursuing a pure life
viii
Police recruited from mid-class families
ix
Demand of western immigration
x
Early major urban development of the West
xi
Attracting urban environment
xii
Advertising of Western Canada
Example:
Paragraph
A
ix
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
7
Paragraph H

6 ____ Paragraph G$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('91fa1c04-7bf6-5718-ad30-85f04cd44273', '7cb68d76-fd7c-58b0-8b78-72f1d7800b9c', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('28f3c59e-9cd3-513a-a33c-b8e32aaae4ee', '7cb68d76-fd7c-58b0-8b78-72f1d7800b9c', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f08e7ac2-1195-5be7-b018-71cc63108de4', '7cb68d76-fd7c-58b0-8b78-72f1d7800b9c', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3b2df67f-d8bd-5d28-a015-72ab01d5aff8', '7cb68d76-fd7c-58b0-8b78-72f1d7800b9c', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d4a6ae46-5c85-53ae-a125-cd06bb6fd142', '7cb68d76-fd7c-58b0-8b78-72f1d7800b9c', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ec7d2e75-918d-5583-adc1-95e29e160215', '7cb68d76-fd7c-58b0-8b78-72f1d7800b9c', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b38654bb-9bf9-5ca1-8645-e497d8364007', '7cb68d76-fd7c-58b0-8b78-72f1d7800b9c', 7, $md$vii$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5d4c92dd-fb58-591b-94b6-7dacf58c6b8c', '7cb68d76-fd7c-58b0-8b78-72f1d7800b9c', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9b17450c-1d4e-5703-a088-eadfc7b019aa', '7cb68d76-fd7c-58b0-8b78-72f1d7800b9c', 9, $md$ix$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('19a02a76-4e33-5e03-85a9-f831e7ba4668', '7cb68d76-fd7c-58b0-8b78-72f1d7800b9c', 10, $md$x$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('091970a4-b047-52a6-84ec-3aaacfdb4b80', '7cb68d76-fd7c-58b0-8b78-72f1d7800b9c', 11, $md$xi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bc10671f-44c5-58cd-baa7-8a5e718919ac', '7cb68d76-fd7c-58b0-8b78-72f1d7800b9c', 12, $md$xii$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('5312ea24-79e8-505a-8060-99f9f8bdd8a3', '7be15ce1-fb67-56a2-9f50-eab93f75c813', 7, 'MATCHING_HEADING', 'READING', 3, $md$### Question 7

Questions 1-7
Questions 1-7
The Reading Passage has eight paragraphs
A-H
Choose the correct heading for paragraphs
A-H
from the list below.
Write the correct number,
i-xii
, in boxes
1-7
on your answer sheet
List of Headings
i
Not all would stay in Canada forever
ii
Government’s safeguard in the West
iii
Eastern Canada is full
iv
Built-up to the new infrastructure
v
An exclusive British domination in Ontario established ever since
vi
Ethnics and language make-up
vii
Pursuing a pure life
viii
Police recruited from mid-class families
ix
Demand of western immigration
x
Early major urban development of the West
xi
Attracting urban environment
xii
Advertising of Western Canada
Example:
Paragraph
A
ix
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
7
Paragraph H

7 ____ Paragraph H$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a9591973-339e-50f5-8cea-106d5025754a', '5312ea24-79e8-505a-8060-99f9f8bdd8a3', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('89da119b-a0d8-54a0-91b6-aa49c1ecb2ab', '5312ea24-79e8-505a-8060-99f9f8bdd8a3', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6546e2bb-27ef-5b12-9bad-b8b302fcecb3', '5312ea24-79e8-505a-8060-99f9f8bdd8a3', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('76fe7881-ecd0-5be0-864c-a5d2df5c29b7', '5312ea24-79e8-505a-8060-99f9f8bdd8a3', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('30abaa63-dd38-5578-8080-31db3cc2a4e3', '5312ea24-79e8-505a-8060-99f9f8bdd8a3', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e77b42aa-d67e-59c7-bd28-23ac728d816f', '5312ea24-79e8-505a-8060-99f9f8bdd8a3', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f6e2dfde-d04f-5f6e-b4e9-a99a97589c41', '5312ea24-79e8-505a-8060-99f9f8bdd8a3', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('33093d7e-397d-51fc-bf0b-3d83dfdef5a4', '5312ea24-79e8-505a-8060-99f9f8bdd8a3', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('55e6397f-f81b-5ad1-8dfd-981bbcd32ef1', '5312ea24-79e8-505a-8060-99f9f8bdd8a3', 9, $md$ix$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('019431ad-fcf3-5f7a-b364-67a5e1ad2232', '5312ea24-79e8-505a-8060-99f9f8bdd8a3', 10, $md$x$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9fe8d68f-8f56-5106-b40e-938a4d2cce8a', '5312ea24-79e8-505a-8060-99f9f8bdd8a3', 11, $md$xi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d48bbc47-098a-5912-bf0e-62825718d53c', '5312ea24-79e8-505a-8060-99f9f8bdd8a3', 12, $md$xii$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('d62ae908-fb47-5831-bcad-7136c8a4c8ab', '7be15ce1-fb67-56a2-9f50-eab93f75c813', 8, 'SUMMARY_COMPLETION', 'READING', 3, $md$### Question 8

Questions 8-13
Questions 8-13
Complete the following summary of the paragraphs of Reading Passage
Using
NO MORE THAN TWO WORDS
from the Reading Passage for each answer.
Write your answers in boxes
8-13
on your answer sheet.
With the saturation of Eastern Canada, the Western rural area would supply
8
. for the descendants of easterners. Politicians also declared that Western is got potential to increase
9
of Canada according to
10
crop that consumed in the East. The federal government started to prepare and made it happen. First, the government bought land from a private
11
, and legally offered a certain area to people who stayed for a qualifying period of time. Then, mounted
12
was found to secure the land. However, the best way to protect citizens was to build a
13
to transport the migrants and goods between the West and the East.

With the saturation of Eastern Canada, the Western rural area would supply 8 ____ . for the descendants of easterners. Politicians also declared that Western is got potential to increase 9 ____ of Canada according to 10 ____ crop that consumed in the East. The federal government started to prepare and made it happen. First, the government bought land from a private 11 ____ , and legally offered a certain area to people who stayed for a qualifying period of time. Then, mounted 12 ____ was found to secure the land. However, the best way to protect citizens was to build a 13 ____ to transport the migrants and goods between the West and the East.$md$, NULL, ARRAY['.*homesteads.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('c9185c6a-6463-5183-b951-93639761d376', '7be15ce1-fb67-56a2-9f50-eab93f75c813', 9, 'SUMMARY_COMPLETION', 'READING', 3, $md$### Question 9

Questions 8-13
Questions 8-13
Complete the following summary of the paragraphs of Reading Passage
Using
NO MORE THAN TWO WORDS
from the Reading Passage for each answer.
Write your answers in boxes
8-13
on your answer sheet.
With the saturation of Eastern Canada, the Western rural area would supply
8
. for the descendants of easterners. Politicians also declared that Western is got potential to increase
9
of Canada according to
10
crop that consumed in the East. The federal government started to prepare and made it happen. First, the government bought land from a private
11
, and legally offered a certain area to people who stayed for a qualifying period of time. Then, mounted
12
was found to secure the land. However, the best way to protect citizens was to build a
13
to transport the migrants and goods between the West and the East.

With the saturation of Eastern Canada, the Western rural area would supply 8 ____ . for the descendants of easterners. Politicians also declared that Western is got potential to increase 9 ____ of Canada according to 10 ____ crop that consumed in the East. The federal government started to prepare and made it happen. First, the government bought land from a private 11 ____ , and legally offered a certain area to people who stayed for a qualifying period of time. Then, mounted 12 ____ was found to secure the land. However, the best way to protect citizens was to build a 13 ____ to transport the migrants and goods between the West and the East.$md$, NULL, ARRAY['.*homesteads.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('2af1c38a-bf5c-53fa-80bb-30ce79a604f6', '7be15ce1-fb67-56a2-9f50-eab93f75c813', 10, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 10

Questions 8-13
Questions 8-13
Complete the following summary of the paragraphs of Reading Passage
Using
NO MORE THAN TWO WORDS
from the Reading Passage for each answer.
Write your answers in boxes
8-13
on your answer sheet.
With the saturation of Eastern Canada, the Western rural area would supply
8
. for the descendants of easterners. Politicians also declared that Western is got potential to increase
9
of Canada according to
10
crop that consumed in the East. The federal government started to prepare and made it happen. First, the government bought land from a private
11
, and legally offered a certain area to people who stayed for a qualifying period of time. Then, mounted
12
was found to secure the land. However, the best way to protect citizens was to build a
13
to transport the migrants and goods between the West and the East.

With the saturation of Eastern Canada, the Western rural area would supply 8 ____ . for the descendants of easterners. Politicians also declared that Western is got potential to increase 9 ____ of Canada according to 10 ____ crop that consumed in the East. The federal government started to prepare and made it happen. First, the government bought land from a private 11 ____ , and legally offered a certain area to people who stayed for a qualifying period of time. Then, mounted 12 ____ was found to secure the land. However, the best way to protect citizens was to build a 13 ____ to transport the migrants and goods between the West and the East.$md$, NULL, ARRAY['.*homesteads.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('60ff8247-35c7-5d85-b736-6bdefee18ace', '7be15ce1-fb67-56a2-9f50-eab93f75c813', 11, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 11

Questions 8-13
Questions 8-13
Complete the following summary of the paragraphs of Reading Passage
Using
NO MORE THAN TWO WORDS
from the Reading Passage for each answer.
Write your answers in boxes
8-13
on your answer sheet.
With the saturation of Eastern Canada, the Western rural area would supply
8
. for the descendants of easterners. Politicians also declared that Western is got potential to increase
9
of Canada according to
10
crop that consumed in the East. The federal government started to prepare and made it happen. First, the government bought land from a private
11
, and legally offered a certain area to people who stayed for a qualifying period of time. Then, mounted
12
was found to secure the land. However, the best way to protect citizens was to build a
13
to transport the migrants and goods between the West and the East.

With the saturation of Eastern Canada, the Western rural area would supply 8 ____ . for the descendants of easterners. Politicians also declared that Western is got potential to increase 9 ____ of Canada according to 10 ____ crop that consumed in the East. The federal government started to prepare and made it happen. First, the government bought land from a private 11 ____ , and legally offered a certain area to people who stayed for a qualifying period of time. Then, mounted 12 ____ was found to secure the land. However, the best way to protect citizens was to build a 13 ____ to transport the migrants and goods between the West and the East.$md$, NULL, ARRAY['.*homesteads.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('5d4c34fc-b33c-5fdc-b9ee-f13901a73634', '7be15ce1-fb67-56a2-9f50-eab93f75c813', 12, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 12

Questions 8-13
Questions 8-13
Complete the following summary of the paragraphs of Reading Passage
Using
NO MORE THAN TWO WORDS
from the Reading Passage for each answer.
Write your answers in boxes
8-13
on your answer sheet.
With the saturation of Eastern Canada, the Western rural area would supply
8
. for the descendants of easterners. Politicians also declared that Western is got potential to increase
9
of Canada according to
10
crop that consumed in the East. The federal government started to prepare and made it happen. First, the government bought land from a private
11
, and legally offered a certain area to people who stayed for a qualifying period of time. Then, mounted
12
was found to secure the land. However, the best way to protect citizens was to build a
13
to transport the migrants and goods between the West and the East.

With the saturation of Eastern Canada, the Western rural area would supply 8 ____ . for the descendants of easterners. Politicians also declared that Western is got potential to increase 9 ____ of Canada according to 10 ____ crop that consumed in the East. The federal government started to prepare and made it happen. First, the government bought land from a private 11 ____ , and legally offered a certain area to people who stayed for a qualifying period of time. Then, mounted 12 ____ was found to secure the land. However, the best way to protect citizens was to build a 13 ____ to transport the migrants and goods between the West and the East.$md$, NULL, ARRAY['.*homesteads.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('ce689046-4c32-573a-be11-72e143220713', '7be15ce1-fb67-56a2-9f50-eab93f75c813', 13, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 13

Questions 8-13
Questions 8-13
Complete the following summary of the paragraphs of Reading Passage
Using
NO MORE THAN TWO WORDS
from the Reading Passage for each answer.
Write your answers in boxes
8-13
on your answer sheet.
With the saturation of Eastern Canada, the Western rural area would supply
8
. for the descendants of easterners. Politicians also declared that Western is got potential to increase
9
of Canada according to
10
crop that consumed in the East. The federal government started to prepare and made it happen. First, the government bought land from a private
11
, and legally offered a certain area to people who stayed for a qualifying period of time. Then, mounted
12
was found to secure the land. However, the best way to protect citizens was to build a
13
to transport the migrants and goods between the West and the East.

With the saturation of Eastern Canada, the Western rural area would supply 8 ____ . for the descendants of easterners. Politicians also declared that Western is got potential to increase 9 ____ of Canada according to 10 ____ crop that consumed in the East. The federal government started to prepare and made it happen. First, the government bought land from a private 11 ____ , and legally offered a certain area to people who stayed for a qualifying period of time. Then, mounted 12 ____ was found to secure the land. However, the best way to protect citizens was to build a 13 ____ to transport the migrants and goods between the West and the East.$md$, NULL, ARRAY['.*homesteads.*']);

COMMIT;
