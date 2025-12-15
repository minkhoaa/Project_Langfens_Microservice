BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-soviets-new-working-week-1256'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-soviets-new-working-week-1256';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-soviets-new-working-week-1256';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-soviets-new-working-week-1256';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('0f6713e4-a23b-5338-9cff-efd492075259', 'ielts-reading-soviets-new-working-week-1256', $t$Soviet’s New Working Week$t$, $md$## Soviet’s New Working Week

Nguồn:
- Test: https://mini-ielts.com/1256/reading/soviets-new-working-week
- Solution: https://mini-ielts.com/1256/view-solution/reading/soviets-new-working-week$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('efc1977c-8698-56f0-bb70-5dd24ce0dc2c', '0f6713e4-a23b-5338-9cff-efd492075259', 1, $t$Reading — Soviet’s New Working Week$t$, $md$Read the passage and answer questions **1–14**.

### Passage: Soviet’s New Working Week

Historian investigates how Stalin changed the calendar to keep the Soviet people continually at work

A

“There are no fortresses that Bolsheviks cannot storm”. With these words, Stalin expressed the dynamic self-confidence of the Soviet Union’s Five Year Plan: weak and backward Russia was to turn overnight into a powerful modern industrial country. Between 1928 and 1932, production of coal, iron and steel increased at a fantastic rate, and new industrial cities sprang up, along with the world’s biggest dam. Everyone’s life was affected, as collectivised farming drove millions from the land to swell the industrial proletariat. Private enterprise disappeared in city and country, leaving the State supreme under the dictatorship of Stalin. Unlimited enthusiasm was the mood of the day, with the Communists believing that iron will and hard-working manpower alone would bring about a new world.

B

Enthusiasm spread to time itself, in the desire to make the state a huge efficient machine, where not a moment would be wasted, especially in the workplace. Lenin had already been intrigued by the ideas of the American Frederick Winslow Taylor (1856-1915), whose time-motion studies had discovered ways of stream-lining effort so that every worker could produce the maximum. The Bolsheviks were also great admirers of Henry Ford’s assembly line mass production and of his Fordson tractors that were imported by the thousands. The engineers who came with them to train their users helped spread what became a real cult of Ford. Emulating and surpassing such capitalist models formed part of the training of the new Soviet Man, a heroic figure whose unlimited capacity for work would benefit everyone in the dynamic new society. All this culminated in the Plan, which has been characterized as the triumph of the machine, where workers would become supremely efficient robot-like creatures.

C

Yet this was Communism whose goals had always included improving the lives of the proletariat. One major step in that direction was the sudden announcement in 1927 that reduced the working day from eight to seven hours. In January 1929, all Indus-tries were ordered to adopt the shorter day by the end of the Plan. Workers were also to have an extra hour off on the eve of Sundays and holidays. Typically though, the state took away more than it gave, for this was part of a scheme to increase production by establishing a three-shift system. This meant that the factories were open day and night and that many had to work at highly undesirable hours.

D

Hardly had that policy been announced, though, then Yuri Larin, who had been a close associate of Lenin and architect of his radical economic policy, came up with an idea for even greater efficiency. Workers were free and plants were closed on Sundays. Why not abolish that wasted day by instituting a continuous workweek so that the machines could operate to their full capacity every day of the week? When Larin presented his ides to the Congress of Soviets in May 1929, no one paid much attention. Soon after, though, he got the ear of Stalin, who approved. Suddenly, in June, the Soviet press was filled with articles praising the new scheme. In August, the Council of Peoples’ Commissars ordered that the continuous workweek be brought into immediate effect, during the height of enthusiasm for the Plan, whose goals the new schedule seemed guaranteed to forward.

E

The idea seemed simple enough but turned out to be very complicated in practice. Obviously, the workers couldn’t be made to work seven days a week, nor should their total work hours be increased. The solution was ingenious: a new five-day week would have the workers on the job for four days, with the fifth day free; holidays would be reduced from ten to five, and the extra hour off on the eve of rest days would be abolished. Staggering the rest-days between groups of workers meant that each worker would spend the same number of hours on the job, but the factories would be working a full 360 days a year instead of 300. The 360 divided neatly into 72 five-day weeks. Workers in each establishment (at first factories, then stores and offices) were divided into five groups, each assigned a colour which appeared on the new Uninterrupted Work Week calendars distributed all over the country. Colour-coding was a valuable mnemonic device since workers might have trouble remembering what their day off was going to be, for it would change every week. A glance at the colour on the calendar would reveal the free day, and allow workers to plan their activities. This system, however, did not apply to construction or seasonal occupations, which followed a six-day week, or to factories or mines which had to close regularly for maintenance: they also had a six-day week, whether interrupted (with the same day off for everyone) or continuous. In all cases, though, Sunday was treated like any other day.

F

Official propaganda touted the material and cultural benefits of the new scheme. Workers would get more rest; production and employment would increase (for more workers would be needed to keep the factories running continuously); the standard of living would improve. Leisure time would be more rationally employed, for cultural activities (theatre, clubs, sports) would no longer have to be crammed into a weekend, but could flourish every day, with their facilities far less crowded. Shopping would be easier for the same reasons. Ignorance and superstition, as represented by organized religion, would suffer a mortal blow, since 80 per cent of the workers would be on the job on any given Sunday. The only objection concerned the family, where normally more than one member was working: well, the Soviets insisted, the narrow family was har less important than the vast common good and besides, arrangements could be made for husband and wife to share a common schedule. In fact, the regime had long wanted to weaken or sideline the two greatest potential threats to its total dominance: organised religion and the nuclear family. Religion succumbed, but the family, as even Stalin finally had to admit, proved much more resistant.

G

The continuous work week, hailed as a Utopia where time itself was conquered and the sluggish Sunday abolished forever, spread like an epidemic. According to official figures, 63 per cent of industrial workers were so employed by April 1930; in June, all industry was ordered to convert during the next year. The fad reached its peak in October when it affected 73 per cent of workers. In fact, many managers simply claimed that their factories had gone over to the new week, without actually applying it. Conforming to the demands of the Plan was important; practical matters could wait. By then, though, problems were becoming obvious. Most serious (though never officially admitted), the workers hated it. Coordination of family schedules was virtually impossible and usually ignored, so husbands and wives only saw each other before or after work; rest days were empty without any loved ones to share them – even friends were likely to be on a different schedule. Confusion reigned: the new plan was introduced haphazardly, with some factories operating five-, six- and seven-day weeks at the same time, and the workers often not getting their rest days at all.

H

The Soviet government might have ignored all that (It didn’t depend on public approval), but the new week was far from having the vaunted effect on production. With the complicated rotation system, the work teams necessarily found themselves doing different kinds of work in successive weeks. Machines, no longer consistently in the hands of people how knew how to tend them, were often poorly maintained or even broken. Workers lost a sense of responsibility for the special tasks they had normally performed.

I

As a result, the new week started to lose ground. Stalin’s speech of June 1931, which criticised the “depersonalised labor” its too hasty application had brought, marked the beginning of the end. In November, the government ordered the widespread adoption of the six-day week, which had its own calendar, with regular breaks on the 6th, 12th, 18th, 24th, and 30th, with Sunday usually as a working day. By July 1935, only 26 per cent of workers still followed the continuous schedule, and the six-day week was soon on its way out. Finally, in 1940, as part of the general reversion to more traditional methods, both the continuous five-day week and the novel six-day week were abandoned, and Sunday returned as the universal day of rest. A bold but typically ill-conceived experiment was at an end.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('0f01608d-75f7-5e97-8d48-dd0ec08536ca', 'efc1977c-8698-56f0-bb70-5dd24ce0dc2c', 1, 'MATCHING_HEADING', 'READING', 2, $md$### Question 1

Questions 1-8
Questions 1-8
Reading Passage has nine paragraphs
A-I
Choose the correct heading for each paragraph from the list of headings below.
Write the correct number
i-xii
in boxes
1-8
on your answer sheet
List of Headings
i
Benefits of the new scheme and its resistance
ii
Making use of the once wasted weekends
iii
Cutting work hours for better efficiency
iv
Optimism of the great future
v
Negative effects on the production itself
vi
Soviet Union’s five-year plan
vii
The abolishment of the new work-week scheme
viii
The Ford model
ix
Reaction from factory workers and their families
x
The color-coding scheme
xi
Establishing a three-shift system
xii
Foreign inspiration
1
Paragraph A
2
Paragraph B
Example Answer
Paragraph
C
iii
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
8
Paragraph I

1 ____ Paragraph A$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('13ab0ef1-6240-5122-9cba-5c8cd43533ac', '0f01608d-75f7-5e97-8d48-dd0ec08536ca', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8a4815f8-b2d0-5bf3-ac7b-87c29cc35012', '0f01608d-75f7-5e97-8d48-dd0ec08536ca', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('141005a9-b62a-5f3f-974d-97e790b6224f', '0f01608d-75f7-5e97-8d48-dd0ec08536ca', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d1b07d3f-fc02-5db0-9874-3b7af7c725c2', '0f01608d-75f7-5e97-8d48-dd0ec08536ca', 4, $md$iv$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f4fd9d0c-3afa-5dd7-8b30-81784f2d7a62', '0f01608d-75f7-5e97-8d48-dd0ec08536ca', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('80897dd2-609a-5bb9-94de-3a9df6e8c710', '0f01608d-75f7-5e97-8d48-dd0ec08536ca', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('10409976-33fd-5c7c-8a2e-a015b40ec874', '0f01608d-75f7-5e97-8d48-dd0ec08536ca', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('38b98205-eecc-54ef-9dcc-420d0f890d42', '0f01608d-75f7-5e97-8d48-dd0ec08536ca', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('57d1eef9-218f-5285-9af4-8b49b141f1cf', '0f01608d-75f7-5e97-8d48-dd0ec08536ca', 9, $md$ix$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('378219d1-c45d-5f9e-9760-7c1dd692c774', '0f01608d-75f7-5e97-8d48-dd0ec08536ca', 10, $md$x$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5ff10c34-249c-51b4-ba6a-d723b8b913d5', '0f01608d-75f7-5e97-8d48-dd0ec08536ca', 11, $md$xi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fe2963ad-67f6-5148-a135-919d8a72357f', '0f01608d-75f7-5e97-8d48-dd0ec08536ca', 12, $md$xii$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('e5fbf5af-15a7-58a0-82d1-6ce7857a34fd', 'efc1977c-8698-56f0-bb70-5dd24ce0dc2c', 2, 'MATCHING_HEADING', 'READING', 2, $md$### Question 2

Questions 1-8
Questions 1-8
Reading Passage has nine paragraphs
A-I
Choose the correct heading for each paragraph from the list of headings below.
Write the correct number
i-xii
in boxes
1-8
on your answer sheet
List of Headings
i
Benefits of the new scheme and its resistance
ii
Making use of the once wasted weekends
iii
Cutting work hours for better efficiency
iv
Optimism of the great future
v
Negative effects on the production itself
vi
Soviet Union’s five-year plan
vii
The abolishment of the new work-week scheme
viii
The Ford model
ix
Reaction from factory workers and their families
x
The color-coding scheme
xi
Establishing a three-shift system
xii
Foreign inspiration
1
Paragraph A
2
Paragraph B
Example Answer
Paragraph
C
iii
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
8
Paragraph I

2 ____ Paragraph B$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7e8a5010-3dfb-5795-aa52-169702d443ab', 'e5fbf5af-15a7-58a0-82d1-6ce7857a34fd', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d20dfefa-81f6-56a4-9e04-36c119384180', 'e5fbf5af-15a7-58a0-82d1-6ce7857a34fd', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0018f3b9-9427-507b-805f-ddaa1837da06', 'e5fbf5af-15a7-58a0-82d1-6ce7857a34fd', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bbbea1f2-f0e8-56b2-bdad-7d862ec6cc77', 'e5fbf5af-15a7-58a0-82d1-6ce7857a34fd', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a2918c52-8c93-5e80-9b0c-19f281b1436f', 'e5fbf5af-15a7-58a0-82d1-6ce7857a34fd', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f432115c-cc49-5155-80fc-1f9a6bdce368', 'e5fbf5af-15a7-58a0-82d1-6ce7857a34fd', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e31b9b87-b2d0-523d-9db0-733840623088', 'e5fbf5af-15a7-58a0-82d1-6ce7857a34fd', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f918f4b6-4269-504f-94e4-0379a51b3c6d', 'e5fbf5af-15a7-58a0-82d1-6ce7857a34fd', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('85d77f37-cb0d-58b7-bcaf-f300e6f5e998', 'e5fbf5af-15a7-58a0-82d1-6ce7857a34fd', 9, $md$ix$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('497032a1-f941-5a5a-8992-92f9267570fa', 'e5fbf5af-15a7-58a0-82d1-6ce7857a34fd', 10, $md$x$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('dc61eb3f-060d-5764-9c1c-2849321a7eb4', 'e5fbf5af-15a7-58a0-82d1-6ce7857a34fd', 11, $md$xi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5278594b-aa0f-5999-a4e0-aa2a29b4b928', 'e5fbf5af-15a7-58a0-82d1-6ce7857a34fd', 12, $md$xii$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('5a5569fa-e433-53f0-9c9b-de70e349a934', 'efc1977c-8698-56f0-bb70-5dd24ce0dc2c', 3, 'MATCHING_HEADING', 'READING', 2, $md$### Question 3

Questions 1-8
Questions 1-8
Reading Passage has nine paragraphs
A-I
Choose the correct heading for each paragraph from the list of headings below.
Write the correct number
i-xii
in boxes
1-8
on your answer sheet
List of Headings
i
Benefits of the new scheme and its resistance
ii
Making use of the once wasted weekends
iii
Cutting work hours for better efficiency
iv
Optimism of the great future
v
Negative effects on the production itself
vi
Soviet Union’s five-year plan
vii
The abolishment of the new work-week scheme
viii
The Ford model
ix
Reaction from factory workers and their families
x
The color-coding scheme
xi
Establishing a three-shift system
xii
Foreign inspiration
1
Paragraph A
2
Paragraph B
Example Answer
Paragraph
C
iii
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
8
Paragraph I

3 ____ Paragraph D$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3d109e18-5b51-5b95-bc49-2bc0cbb8d1e9', '5a5569fa-e433-53f0-9c9b-de70e349a934', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('af502019-a28b-5093-bcc5-4206326029e9', '5a5569fa-e433-53f0-9c9b-de70e349a934', 2, $md$ii$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ff951d54-e606-5af6-90f6-ed16d9352ba0', '5a5569fa-e433-53f0-9c9b-de70e349a934', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3875d06d-7822-5b8d-9b02-74a16cfb9231', '5a5569fa-e433-53f0-9c9b-de70e349a934', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('751b3c78-6e08-5f16-9570-10576207adae', '5a5569fa-e433-53f0-9c9b-de70e349a934', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('80873f06-96f6-5552-8e63-6b4f837528fd', '5a5569fa-e433-53f0-9c9b-de70e349a934', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('afc2546e-1cac-5d54-90f7-3d244d56d526', '5a5569fa-e433-53f0-9c9b-de70e349a934', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('43c09d13-f99b-58a2-974d-b8d8d9cb743d', '5a5569fa-e433-53f0-9c9b-de70e349a934', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('efb7e6c5-8f21-5925-a7bb-525b4e937688', '5a5569fa-e433-53f0-9c9b-de70e349a934', 9, $md$ix$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fac8889d-b5cb-5164-948f-0f65e42365a2', '5a5569fa-e433-53f0-9c9b-de70e349a934', 10, $md$x$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2b5a4318-1bfe-5196-92b3-e2ad95994551', '5a5569fa-e433-53f0-9c9b-de70e349a934', 11, $md$xi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('18c15c3b-9e4c-5cb1-8e8f-2f417f4ea40e', '5a5569fa-e433-53f0-9c9b-de70e349a934', 12, $md$xii$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('edc59d3a-9a58-5a22-967a-d12bacba6e3e', 'efc1977c-8698-56f0-bb70-5dd24ce0dc2c', 4, 'MATCHING_HEADING', 'READING', 2, $md$### Question 4

Questions 1-8
Questions 1-8
Reading Passage has nine paragraphs
A-I
Choose the correct heading for each paragraph from the list of headings below.
Write the correct number
i-xii
in boxes
1-8
on your answer sheet
List of Headings
i
Benefits of the new scheme and its resistance
ii
Making use of the once wasted weekends
iii
Cutting work hours for better efficiency
iv
Optimism of the great future
v
Negative effects on the production itself
vi
Soviet Union’s five-year plan
vii
The abolishment of the new work-week scheme
viii
The Ford model
ix
Reaction from factory workers and their families
x
The color-coding scheme
xi
Establishing a three-shift system
xii
Foreign inspiration
1
Paragraph A
2
Paragraph B
Example Answer
Paragraph
C
iii
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
8
Paragraph I

4 ____ Paragraph E$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('049a154d-3ec1-52f0-a52f-9e1061e9df93', 'edc59d3a-9a58-5a22-967a-d12bacba6e3e', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4cf0b2f0-d16d-5279-abd4-19701d91f8d8', 'edc59d3a-9a58-5a22-967a-d12bacba6e3e', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d70fd2c4-f7c3-5748-be5d-1bbe6274de6b', 'edc59d3a-9a58-5a22-967a-d12bacba6e3e', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2b15c5f3-a994-5c4e-b8c0-5151a122d72b', 'edc59d3a-9a58-5a22-967a-d12bacba6e3e', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('216b1a11-0cc8-5c83-a49a-2ab1a5a80dfd', 'edc59d3a-9a58-5a22-967a-d12bacba6e3e', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7ddcb077-0350-524a-865e-9dfa021dc6af', 'edc59d3a-9a58-5a22-967a-d12bacba6e3e', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('24929bd0-d310-5484-80a2-33f9b629aff8', 'edc59d3a-9a58-5a22-967a-d12bacba6e3e', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7171a084-afc6-5ae9-975e-d903c2ecb8c1', 'edc59d3a-9a58-5a22-967a-d12bacba6e3e', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8c80e500-0573-5e34-81b3-ea044a4d3d9b', 'edc59d3a-9a58-5a22-967a-d12bacba6e3e', 9, $md$ix$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1ab23d68-97be-5786-9f54-a55ea4099e83', 'edc59d3a-9a58-5a22-967a-d12bacba6e3e', 10, $md$x$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d384c3c2-8942-53f8-8f3d-ab3fb2af72b8', 'edc59d3a-9a58-5a22-967a-d12bacba6e3e', 11, $md$xi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('afedb466-2c08-5dc5-95b2-dc590e9f4127', 'edc59d3a-9a58-5a22-967a-d12bacba6e3e', 12, $md$xii$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('45b27ec4-725c-5459-931d-39282c46303d', 'efc1977c-8698-56f0-bb70-5dd24ce0dc2c', 5, 'MATCHING_HEADING', 'READING', 3, $md$### Question 5

Questions 1-8
Questions 1-8
Reading Passage has nine paragraphs
A-I
Choose the correct heading for each paragraph from the list of headings below.
Write the correct number
i-xii
in boxes
1-8
on your answer sheet
List of Headings
i
Benefits of the new scheme and its resistance
ii
Making use of the once wasted weekends
iii
Cutting work hours for better efficiency
iv
Optimism of the great future
v
Negative effects on the production itself
vi
Soviet Union’s five-year plan
vii
The abolishment of the new work-week scheme
viii
The Ford model
ix
Reaction from factory workers and their families
x
The color-coding scheme
xi
Establishing a three-shift system
xii
Foreign inspiration
1
Paragraph A
2
Paragraph B
Example Answer
Paragraph
C
iii
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
8
Paragraph I

5 ____ Paragraph F$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ebac00dd-47d6-5a0c-b271-defc0f51df03', '45b27ec4-725c-5459-931d-39282c46303d', 1, $md$i$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bb0254ad-1d46-53a5-ac6a-b0121e1631c3', '45b27ec4-725c-5459-931d-39282c46303d', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a55ded7f-a914-5982-b7c4-dd7e8a209757', '45b27ec4-725c-5459-931d-39282c46303d', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2d21bfe6-5176-55b2-a34b-9fb4a33b2e58', '45b27ec4-725c-5459-931d-39282c46303d', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('739fa01c-a695-5bad-83ec-adf4624ff79a', '45b27ec4-725c-5459-931d-39282c46303d', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('03c0aa38-c507-5535-a15d-cd9793e10a4e', '45b27ec4-725c-5459-931d-39282c46303d', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1f598eb4-7bfd-5143-a806-c5122ad89e6d', '45b27ec4-725c-5459-931d-39282c46303d', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0d397c73-3e61-5056-8ab2-a2103fe86736', '45b27ec4-725c-5459-931d-39282c46303d', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('704c5346-22af-5acd-81e9-d8df45098026', '45b27ec4-725c-5459-931d-39282c46303d', 9, $md$ix$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a74daf07-3e34-58e8-9a73-2737c1b97a8a', '45b27ec4-725c-5459-931d-39282c46303d', 10, $md$x$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('096421a3-34c1-5c3f-9ce6-d5bde77dfba9', '45b27ec4-725c-5459-931d-39282c46303d', 11, $md$xi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5e8f4037-932a-5a94-8688-1f6164605471', '45b27ec4-725c-5459-931d-39282c46303d', 12, $md$xii$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('b9b0efda-7f75-5d46-8131-87a82f4816ae', 'efc1977c-8698-56f0-bb70-5dd24ce0dc2c', 6, 'MATCHING_HEADING', 'READING', 3, $md$### Question 6

Questions 1-8
Questions 1-8
Reading Passage has nine paragraphs
A-I
Choose the correct heading for each paragraph from the list of headings below.
Write the correct number
i-xii
in boxes
1-8
on your answer sheet
List of Headings
i
Benefits of the new scheme and its resistance
ii
Making use of the once wasted weekends
iii
Cutting work hours for better efficiency
iv
Optimism of the great future
v
Negative effects on the production itself
vi
Soviet Union’s five-year plan
vii
The abolishment of the new work-week scheme
viii
The Ford model
ix
Reaction from factory workers and their families
x
The color-coding scheme
xi
Establishing a three-shift system
xii
Foreign inspiration
1
Paragraph A
2
Paragraph B
Example Answer
Paragraph
C
iii
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
8
Paragraph I

6 ____ Paragraph G$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8b2601d5-9a8b-5224-a470-a8fe48407a64', 'b9b0efda-7f75-5d46-8131-87a82f4816ae', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a9cfc78d-c968-555d-9296-7e4b3b55c704', 'b9b0efda-7f75-5d46-8131-87a82f4816ae', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('224e1e35-a67a-5414-a5cb-09710432882f', 'b9b0efda-7f75-5d46-8131-87a82f4816ae', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('02b046f4-cfc1-5bb2-af23-799754e94a1d', 'b9b0efda-7f75-5d46-8131-87a82f4816ae', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e2d654bf-f388-5eaf-b52c-0f6724c64ffc', 'b9b0efda-7f75-5d46-8131-87a82f4816ae', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6123a8c4-a30d-5ef0-b0d6-bcd76b8758e2', 'b9b0efda-7f75-5d46-8131-87a82f4816ae', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('46aae232-392b-5c1e-982c-6118943989c0', 'b9b0efda-7f75-5d46-8131-87a82f4816ae', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('47922185-e4cd-5e80-9b2c-7e2dcf01a37a', 'b9b0efda-7f75-5d46-8131-87a82f4816ae', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('11fe9a37-781f-55b6-8ee1-c81cb988b285', 'b9b0efda-7f75-5d46-8131-87a82f4816ae', 9, $md$ix$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('523368f2-fcb8-53ac-86c5-4dba1c1e174f', 'b9b0efda-7f75-5d46-8131-87a82f4816ae', 10, $md$x$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('88edcdc5-bce0-55d6-a7bf-84e313f45d67', 'b9b0efda-7f75-5d46-8131-87a82f4816ae', 11, $md$xi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fd22d58d-a48c-5ce3-b279-1fcb8bd2a8c6', 'b9b0efda-7f75-5d46-8131-87a82f4816ae', 12, $md$xii$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('3794739c-14c5-57f2-b8be-9e4514280e5c', 'efc1977c-8698-56f0-bb70-5dd24ce0dc2c', 7, 'MATCHING_HEADING', 'READING', 3, $md$### Question 7

Questions 1-8
Questions 1-8
Reading Passage has nine paragraphs
A-I
Choose the correct heading for each paragraph from the list of headings below.
Write the correct number
i-xii
in boxes
1-8
on your answer sheet
List of Headings
i
Benefits of the new scheme and its resistance
ii
Making use of the once wasted weekends
iii
Cutting work hours for better efficiency
iv
Optimism of the great future
v
Negative effects on the production itself
vi
Soviet Union’s five-year plan
vii
The abolishment of the new work-week scheme
viii
The Ford model
ix
Reaction from factory workers and their families
x
The color-coding scheme
xi
Establishing a three-shift system
xii
Foreign inspiration
1
Paragraph A
2
Paragraph B
Example Answer
Paragraph
C
iii
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
8
Paragraph I

7 ____ Paragraph H$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('492c1859-f73c-558c-a960-8fd313e1275c', '3794739c-14c5-57f2-b8be-9e4514280e5c', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e5de312b-b914-56d2-8220-8ef9a6f62611', '3794739c-14c5-57f2-b8be-9e4514280e5c', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0c337f91-e5e9-5cee-bde0-1a98946c0a32', '3794739c-14c5-57f2-b8be-9e4514280e5c', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e7910d30-8fe1-5355-b358-e253e7ee10b1', '3794739c-14c5-57f2-b8be-9e4514280e5c', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fc4866fc-c8ec-5c11-994b-1a146555b3cd', '3794739c-14c5-57f2-b8be-9e4514280e5c', 5, $md$v$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a67914a2-97ab-5695-8559-47ae6e8596cb', '3794739c-14c5-57f2-b8be-9e4514280e5c', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('590c32e7-073c-57d4-8da1-0574e2171c7c', '3794739c-14c5-57f2-b8be-9e4514280e5c', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9812ac4f-0620-51fa-a626-0898bcf8ebe1', '3794739c-14c5-57f2-b8be-9e4514280e5c', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b10eee3b-0ccc-5554-bbf2-4466610f069c', '3794739c-14c5-57f2-b8be-9e4514280e5c', 9, $md$ix$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('833b6d84-2bdd-536d-abc7-0e5f4b398987', '3794739c-14c5-57f2-b8be-9e4514280e5c', 10, $md$x$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8f4f9dd1-a21c-50b8-98df-4646f798268b', '3794739c-14c5-57f2-b8be-9e4514280e5c', 11, $md$xi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c2641d46-e72d-5340-ad7d-4b74e3ff2316', '3794739c-14c5-57f2-b8be-9e4514280e5c', 12, $md$xii$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('e557af9a-abea-5021-98ca-ca810a3318c4', 'efc1977c-8698-56f0-bb70-5dd24ce0dc2c', 8, 'MATCHING_HEADING', 'READING', 3, $md$### Question 8

Questions 1-8
Questions 1-8
Reading Passage has nine paragraphs
A-I
Choose the correct heading for each paragraph from the list of headings below.
Write the correct number
i-xii
in boxes
1-8
on your answer sheet
List of Headings
i
Benefits of the new scheme and its resistance
ii
Making use of the once wasted weekends
iii
Cutting work hours for better efficiency
iv
Optimism of the great future
v
Negative effects on the production itself
vi
Soviet Union’s five-year plan
vii
The abolishment of the new work-week scheme
viii
The Ford model
ix
Reaction from factory workers and their families
x
The color-coding scheme
xi
Establishing a three-shift system
xii
Foreign inspiration
1
Paragraph A
2
Paragraph B
Example Answer
Paragraph
C
iii
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
8
Paragraph I

8 ____ Paragraph I$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0e026bbf-e802-5c52-87e3-8e6ef994681d', 'e557af9a-abea-5021-98ca-ca810a3318c4', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('80b02ec8-0851-5f93-aabc-45293ea77aa4', 'e557af9a-abea-5021-98ca-ca810a3318c4', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a4f5cf27-7c40-56c4-b3ff-c584da3125bc', 'e557af9a-abea-5021-98ca-ca810a3318c4', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('086072d9-208a-5d9a-bc9a-42e85d41363e', 'e557af9a-abea-5021-98ca-ca810a3318c4', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('96317ea8-a305-5efd-8d06-ec6ed1d97925', 'e557af9a-abea-5021-98ca-ca810a3318c4', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('01991bfa-b4f6-5912-b3bf-7226331b3c04', 'e557af9a-abea-5021-98ca-ca810a3318c4', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('155ad4af-521f-525d-8059-f6bfe978856e', 'e557af9a-abea-5021-98ca-ca810a3318c4', 7, $md$vii$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('dad2c5dc-1f6f-5489-9233-045d286198b8', 'e557af9a-abea-5021-98ca-ca810a3318c4', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0a75d1b7-5302-500a-ad75-1221cfc7ece0', 'e557af9a-abea-5021-98ca-ca810a3318c4', 9, $md$ix$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d36d437b-b5fc-5479-875c-4223a8caa550', 'e557af9a-abea-5021-98ca-ca810a3318c4', 10, $md$x$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fb6ab4d3-f5dd-54a6-9e37-7889e248717f', 'e557af9a-abea-5021-98ca-ca810a3318c4', 11, $md$xi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1c98f079-881e-56de-9cd5-3f3c4f93c7ff', 'e557af9a-abea-5021-98ca-ca810a3318c4', 12, $md$xii$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('66778691-a66c-57bd-9de3-23ed6634fc40', 'efc1977c-8698-56f0-bb70-5dd24ce0dc2c', 9, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 9

Questions 9-11
Questions 9-11
Choose the correct letter A, B, C or D.
Write your answers in boxes
9-11
on your answer sheet.
9. According to paragraph A, the Soviet’s five-year plan was a success because
A
Bolsheviks built a strong fortress.
B
Russia was weak and backward.
C
industrial production increased.
D
Stalin was confident about the Soviet’s potential.
10. Daily working hours were cut from eight to seven to
A
improve the lives of all people
B
boost industrial productivity.
C
get rid of undesirable work hours.
D
change the already establish three-shift work system.
11 Many factory managers claimed to have complied with the demands of the new work week because
A
they were pressurized by the state to do so.
B
they believed there would not be any practical problems.
C
they were able to apply it.
D
workers hated the new plan.

Choose the correct letter A, B, C or D. Write your answers in boxes 9-11 on your answer sheet.$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('525cfec5-524d-5412-a218-0cb445767dc1', 'efc1977c-8698-56f0-bb70-5dd24ce0dc2c', 10, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 10

Questions 9-11
Questions 9-11
Choose the correct letter A, B, C or D.
Write your answers in boxes
9-11
on your answer sheet.
9. According to paragraph A, the Soviet’s five-year plan was a success because
A
Bolsheviks built a strong fortress.
B
Russia was weak and backward.
C
industrial production increased.
D
Stalin was confident about the Soviet’s potential.
10. Daily working hours were cut from eight to seven to
A
improve the lives of all people
B
boost industrial productivity.
C
get rid of undesirable work hours.
D
change the already establish three-shift work system.
11 Many factory managers claimed to have complied with the demands of the new work week because
A
they were pressurized by the state to do so.
B
they believed there would not be any practical problems.
C
they were able to apply it.
D
workers hated the new plan.

Choose the correct letter A, B, C or D. Write your answers in boxes 9-11 on your answer sheet.$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('4e166ad0-b204-5801-833b-135a66d33ef9', 'efc1977c-8698-56f0-bb70-5dd24ce0dc2c', 11, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 11

Questions 9-11
Questions 9-11
Choose the correct letter A, B, C or D.
Write your answers in boxes
9-11
on your answer sheet.
9. According to paragraph A, the Soviet’s five-year plan was a success because
A
Bolsheviks built a strong fortress.
B
Russia was weak and backward.
C
industrial production increased.
D
Stalin was confident about the Soviet’s potential.
10. Daily working hours were cut from eight to seven to
A
improve the lives of all people
B
boost industrial productivity.
C
get rid of undesirable work hours.
D
change the already establish three-shift work system.
11 Many factory managers claimed to have complied with the demands of the new work week because
A
they were pressurized by the state to do so.
B
they believed there would not be any practical problems.
C
they were able to apply it.
D
workers hated the new plan.

Choose the correct letter A, B, C or D. Write your answers in boxes 9-11 on your answer sheet.$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('6706e186-e0eb-5e28-b0a9-6f0b32b512be', 'efc1977c-8698-56f0-bb70-5dd24ce0dc2c', 12, 'SHORT_ANSWER', 'READING', 4, $md$### Question 12

Questions 12-14
Questions 12-14
Answer the questions below using
NO MORE THAN TWO WORDS
from the passage for each answer.
Write your answers in boxes
12-14
on your answer sheet.
12.
Whose ides of continuous work week did Stalin approve and helped to implement?
12
13.
What method was used to help workers to remember the rotation of their off days?
13
14.
What was the most resistant force to the new work week scheme?
14

12. Whose ides of continuous work week did Stalin approve and helped to implement? 12 ____$md$, NULL, ARRAY['.*yuri.*larin.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('5ca717df-ad95-58f1-96e2-0ee5dde2d1db', 'efc1977c-8698-56f0-bb70-5dd24ce0dc2c', 13, 'SHORT_ANSWER', 'READING', 4, $md$### Question 13

Questions 12-14
Questions 12-14
Answer the questions below using
NO MORE THAN TWO WORDS
from the passage for each answer.
Write your answers in boxes
12-14
on your answer sheet.
12.
Whose ides of continuous work week did Stalin approve and helped to implement?
12
13.
What method was used to help workers to remember the rotation of their off days?
13
14.
What was the most resistant force to the new work week scheme?
14

13. What method was used to help workers to remember the rotation of their off days? 13 ____$md$, NULL, ARRAY['.*colour.*coding.*','.*colour.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('d1fa3ccb-cc8e-56d7-a643-d241a96a7943', 'efc1977c-8698-56f0-bb70-5dd24ce0dc2c', 14, 'SHORT_ANSWER', 'READING', 4, $md$### Question 14

Questions 12-14
Questions 12-14
Answer the questions below using
NO MORE THAN TWO WORDS
from the passage for each answer.
Write your answers in boxes
12-14
on your answer sheet.
12.
Whose ides of continuous work week did Stalin approve and helped to implement?
12
13.
What method was used to help workers to remember the rotation of their off days?
13
14.
What was the most resistant force to the new work week scheme?
14

14. What was the most resistant force to the new work week scheme? 14 ____$md$, NULL, ARRAY['.*family.*']);

COMMIT;
