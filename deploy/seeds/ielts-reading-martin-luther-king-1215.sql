BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-martin-luther-king-1215'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-martin-luther-king-1215';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-martin-luther-king-1215';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-martin-luther-king-1215';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('06edd9a8-9d28-53c4-9075-1db1f2d3f389', 'ielts-reading-martin-luther-king-1215', $t$Martin Luther King$t$, $md$## Martin Luther King

Nguồn:
- Test: https://mini-ielts.com/1215/reading/martin-luther-king
- Solution: https://mini-ielts.com/1215/view-solution/reading/martin-luther-king$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('dde7097c-7d02-5a26-a1e9-06564158df59', '06edd9a8-9d28-53c4-9075-1db1f2d3f389', 1, $t$Reading — Martin Luther King$t$, $md$Read the passage and answer questions **1–14**.

### Passage: Martin Luther King

A

Martin Luther King was born on January 15, 1929, in Atlanta, Georgia. He was the son of the Reverend Martin Luther King, Sr. and Alberta Williams King. He had an older sister, Willie Christine King, and a younger brother Alfred Daniel Williams King. Growing up in Atlanta, King attended Booker T. Washington High School . He skipped ninth and twelfth grade, and entered Morehouse College at age fifteen without formally graduating from high school. From the time that Martin was born, he knew that black people and white people had different rights in certain parts of America. If a black family wanted to eat at a restaurant, they had to sit in a separate section of the restaurant. They had to sit at the back of the cinema, and even use separate toilets. Worse, and perhaps even more humiliating still, in many southern states, if a black man was on a bus and all the seats were taken, he would have to endure the indignity of relinquishing his own seat to a white man. King could never understand the terrible injustice of this .

In 1948, he graduated with a Bachelor of Arts degree in sociology. Later, King began doctoral studies in systematic theology at Boston University and received his Doctor of Philosophy on June 5, 1955. King married Coretta Scott, on June 18, 1953 and they had four children.

B

Returning to the South to become pastor of a Baptist Church in Montgomery, Alabama, King first achieved national renown when he helped mobilise the black boycott of the Montgomery bus system in 1955. This was organised after Rosa Parks, a black woman, refused to give up her seat on the bus to a white man – in the segregated south, black people could only sit at the back of the bus. The 382-day boycott led the bus company to change its regulations, and the Supreme Court declared such segrega­tion unconstitutional .

C

In 1957 King was active in the organisation of the Southern Leadership Christian Conference (SCLC), formed to co-ordinate protests against discrimination. He advocated non-violent direct action based on the methods of Gandhi , who led protests against British rule in India culminating in India’s independence in 1947. In 1963, King led mass protests against dis­criminatory practices in Birmingham, Alabama, where the white population were violently resisting desegregation . The city was dubbed ‘Bombingham’ as attacks against civil rights protesters increased, and King was arrested and jailed for his part in the protests.

D

After his release, King participated in the enormous civil rights march, in Washington, in August 1963, and delivered his famous ‘I have a dream’ speech , predicting a day when the promise of freedom and equality for all would become a reality in America. In 1964 he was awarded the Nobel Peace Prize. In 1965, he led a campaign to register blacks to vote . The same year the US Congress passed the Voting Rights Act out­lawing the discriminatory practices that had barred blacks from voting in the south.

E

As the civil rights movement became increasingly radicalised, King found that his message of peaceful protest was not shared by many in the younger generation . King began to protest against the Vietnam War and poverty levels in the US. On March 29, 1968, King went to Memphis, Tennessee, in support of the black sanitary public works employees who had been on strike since March 12 for higher wages and better treat­ment. In one incident, black street repair­men had received pay for two hours when they were sent home because of bad weath­er, but white employees had been paid for the full day. King could not bear to stand by and let such patent acts of racism go unno­ticed. He moved to unite his people, and all the peoples of America on the receiving end of discriminatory practices, to protest for their rights, peacefully but steadfastly.

F

On his trip to Memphis, King was booked into room 306 at the Lorraine Motel, owned by Walter Bailey. King was shot at 6:01 p.m. April 4, 1968 while he was standing on the motel’s second-floor balcony. King was rushed to St. Joseph’s Hospital, where doc­tors opened his chest and performed manu­al heart massage. He was pronounced dead at 7:05 p.m. King’s autopsy revealed that although he was only 39 years old, he had the heart of a 60-year-old man.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('e7e768ee-5b82-5894-bcc7-3bb89d71e950', 'dde7097c-7d02-5a26-a1e9-06564158df59', 1, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 1

Questions 1-5
Questions 1-5
Choose the correct letter
A
,
B
,
C
or
D
.
1.
From a young age Martin Luther King
A
wanted to protest for the rights of black people.
B
could not understand why black people were treated differently.
C
was not allowed to go to the cinema or to restaurants.
D
was aware that black people were being humiliated in many northern states.
Locate
2
. What initially made Martin Luther King famous?
A
the black boycott of the Montgomery bus system
B
becoming a pastor at a Baptist Church
C
when Rosa Parks refused to give up her seat on a bus
D
when he persuaded Rosa Parks not to give up her bus seat to a white man
Locate
3.
What influenced Martin Luther King regarding non-violence?
A
India’s independence in 1947
B
Christianity
C
the Southern Leadership Christian Conference
D
the methods of Gandhi
Locate
4.
What did Martin Luther King fight for in 1965?
A
the right of black people to vote
B
the actions of the US Congress
C
the right to win the Nobel Peace Prize
D
the right of black people to travel abroad
Locate
5.
How did Martin Luther King feel about the civil rights movement?
A
It was helping the war in Vietnam.
B
It brought the younger generation together.
C
It had been exploited by politicians who wanted to get more votes.
D
The protesters sometimes behaved too violently.
Locate

Choose the correct letter A , B , C or D .$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('cb9b787b-1ba3-5c2a-a86d-923518025a94', 'dde7097c-7d02-5a26-a1e9-06564158df59', 2, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 2

Questions 1-5
Questions 1-5
Choose the correct letter
A
,
B
,
C
or
D
.
1.
From a young age Martin Luther King
A
wanted to protest for the rights of black people.
B
could not understand why black people were treated differently.
C
was not allowed to go to the cinema or to restaurants.
D
was aware that black people were being humiliated in many northern states.
Locate
2
. What initially made Martin Luther King famous?
A
the black boycott of the Montgomery bus system
B
becoming a pastor at a Baptist Church
C
when Rosa Parks refused to give up her seat on a bus
D
when he persuaded Rosa Parks not to give up her bus seat to a white man
Locate
3.
What influenced Martin Luther King regarding non-violence?
A
India’s independence in 1947
B
Christianity
C
the Southern Leadership Christian Conference
D
the methods of Gandhi
Locate
4.
What did Martin Luther King fight for in 1965?
A
the right of black people to vote
B
the actions of the US Congress
C
the right to win the Nobel Peace Prize
D
the right of black people to travel abroad
Locate
5.
How did Martin Luther King feel about the civil rights movement?
A
It was helping the war in Vietnam.
B
It brought the younger generation together.
C
It had been exploited by politicians who wanted to get more votes.
D
The protesters sometimes behaved too violently.
Locate

Choose the correct letter A , B , C or D .$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('60980571-f32f-560b-8854-eadc246273b2', 'dde7097c-7d02-5a26-a1e9-06564158df59', 3, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 3

Questions 1-5
Questions 1-5
Choose the correct letter
A
,
B
,
C
or
D
.
1.
From a young age Martin Luther King
A
wanted to protest for the rights of black people.
B
could not understand why black people were treated differently.
C
was not allowed to go to the cinema or to restaurants.
D
was aware that black people were being humiliated in many northern states.
Locate
2
. What initially made Martin Luther King famous?
A
the black boycott of the Montgomery bus system
B
becoming a pastor at a Baptist Church
C
when Rosa Parks refused to give up her seat on a bus
D
when he persuaded Rosa Parks not to give up her bus seat to a white man
Locate
3.
What influenced Martin Luther King regarding non-violence?
A
India’s independence in 1947
B
Christianity
C
the Southern Leadership Christian Conference
D
the methods of Gandhi
Locate
4.
What did Martin Luther King fight for in 1965?
A
the right of black people to vote
B
the actions of the US Congress
C
the right to win the Nobel Peace Prize
D
the right of black people to travel abroad
Locate
5.
How did Martin Luther King feel about the civil rights movement?
A
It was helping the war in Vietnam.
B
It brought the younger generation together.
C
It had been exploited by politicians who wanted to get more votes.
D
The protesters sometimes behaved too violently.
Locate

Choose the correct letter A , B , C or D .$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('4c6b4063-9272-539b-927c-e86f93544bc6', 'dde7097c-7d02-5a26-a1e9-06564158df59', 4, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 4

Questions 1-5
Questions 1-5
Choose the correct letter
A
,
B
,
C
or
D
.
1.
From a young age Martin Luther King
A
wanted to protest for the rights of black people.
B
could not understand why black people were treated differently.
C
was not allowed to go to the cinema or to restaurants.
D
was aware that black people were being humiliated in many northern states.
Locate
2
. What initially made Martin Luther King famous?
A
the black boycott of the Montgomery bus system
B
becoming a pastor at a Baptist Church
C
when Rosa Parks refused to give up her seat on a bus
D
when he persuaded Rosa Parks not to give up her bus seat to a white man
Locate
3.
What influenced Martin Luther King regarding non-violence?
A
India’s independence in 1947
B
Christianity
C
the Southern Leadership Christian Conference
D
the methods of Gandhi
Locate
4.
What did Martin Luther King fight for in 1965?
A
the right of black people to vote
B
the actions of the US Congress
C
the right to win the Nobel Peace Prize
D
the right of black people to travel abroad
Locate
5.
How did Martin Luther King feel about the civil rights movement?
A
It was helping the war in Vietnam.
B
It brought the younger generation together.
C
It had been exploited by politicians who wanted to get more votes.
D
The protesters sometimes behaved too violently.
Locate

Choose the correct letter A , B , C or D .$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('c1b3fb0b-4ff1-596d-bfd4-c8bee36f9c8f', 'dde7097c-7d02-5a26-a1e9-06564158df59', 5, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 5

Questions 1-5
Questions 1-5
Choose the correct letter
A
,
B
,
C
or
D
.
1.
From a young age Martin Luther King
A
wanted to protest for the rights of black people.
B
could not understand why black people were treated differently.
C
was not allowed to go to the cinema or to restaurants.
D
was aware that black people were being humiliated in many northern states.
Locate
2
. What initially made Martin Luther King famous?
A
the black boycott of the Montgomery bus system
B
becoming a pastor at a Baptist Church
C
when Rosa Parks refused to give up her seat on a bus
D
when he persuaded Rosa Parks not to give up her bus seat to a white man
Locate
3.
What influenced Martin Luther King regarding non-violence?
A
India’s independence in 1947
B
Christianity
C
the Southern Leadership Christian Conference
D
the methods of Gandhi
Locate
4.
What did Martin Luther King fight for in 1965?
A
the right of black people to vote
B
the actions of the US Congress
C
the right to win the Nobel Peace Prize
D
the right of black people to travel abroad
Locate
5.
How did Martin Luther King feel about the civil rights movement?
A
It was helping the war in Vietnam.
B
It brought the younger generation together.
C
It had been exploited by politicians who wanted to get more votes.
D
The protesters sometimes behaved too violently.
Locate

Choose the correct letter A , B , C or D .$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('f13051b7-114c-5baf-be65-45cf12ccb159', 'dde7097c-7d02-5a26-a1e9-06564158df59', 6, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 6

Questions 6-8
Questions 6-8
Do the following statements agree with the information given in Reading Passage? In spaces
6-8
below, write
TRUE
if the statements agrees with the information
FALSE
if the statements contradicts the information
NOT GIVEN
if there is no information on this
6
. The black boycott of the Montgomery bus system was a success.
Locate
7
. In 1963 the white people in Alabama wanted desegregation.
Locate
8
. Martin Luther King achieved a lot in his protest against the Vietnam War.

6 ____ . The black boycott of the Montgomery bus system was a success. Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('743e242e-2b8b-51a7-b227-a4a7d401b980', 'f13051b7-114c-5baf-be65-45cf12ccb159', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('694f6d88-bc5d-57a5-ab93-f7627547489f', 'f13051b7-114c-5baf-be65-45cf12ccb159', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a1453cb1-b3df-5870-8d24-32a13193289f', 'f13051b7-114c-5baf-be65-45cf12ccb159', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('e24456c8-6567-5b9d-9471-5b3d98d8cf7b', 'dde7097c-7d02-5a26-a1e9-06564158df59', 7, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 7

Questions 6-8
Questions 6-8
Do the following statements agree with the information given in Reading Passage? In spaces
6-8
below, write
TRUE
if the statements agrees with the information
FALSE
if the statements contradicts the information
NOT GIVEN
if there is no information on this
6
. The black boycott of the Montgomery bus system was a success.
Locate
7
. In 1963 the white people in Alabama wanted desegregation.
Locate
8
. Martin Luther King achieved a lot in his protest against the Vietnam War.

7 ____ . In 1963 the white people in Alabama wanted desegregation. Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1bfd1e64-9f78-5a2d-ba38-d28f26ee9121', 'e24456c8-6567-5b9d-9471-5b3d98d8cf7b', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7a9ddc75-3b07-5eb6-b1b4-e17870846a6b', 'e24456c8-6567-5b9d-9471-5b3d98d8cf7b', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ca1c3de1-826c-572d-8d27-1e8264e91f38', 'e24456c8-6567-5b9d-9471-5b3d98d8cf7b', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('868f78c7-175d-5754-97e5-dd8d3f73dd2b', 'dde7097c-7d02-5a26-a1e9-06564158df59', 8, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 8

Questions 6-8
Questions 6-8
Do the following statements agree with the information given in Reading Passage? In spaces
6-8
below, write
TRUE
if the statements agrees with the information
FALSE
if the statements contradicts the information
NOT GIVEN
if there is no information on this
6
. The black boycott of the Montgomery bus system was a success.
Locate
7
. In 1963 the white people in Alabama wanted desegregation.
Locate
8
. Martin Luther King achieved a lot in his protest against the Vietnam War.

8 ____ . Martin Luther King achieved a lot in his protest against the Vietnam War.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6e6906ab-0411-55f1-af53-aa756e3c9b23', '868f78c7-175d-5754-97e5-dd8d3f73dd2b', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('471bf87e-b7f8-5aca-afd7-336bf88c233a', '868f78c7-175d-5754-97e5-dd8d3f73dd2b', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('18bacb75-1672-5504-8f2a-1fde739cce9b', '868f78c7-175d-5754-97e5-dd8d3f73dd2b', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('4aa88ee9-b994-5aa7-9a42-f2a086fe4577', 'dde7097c-7d02-5a26-a1e9-06564158df59', 9, 'MATCHING_HEADING', 'READING', 3, $md$### Question 9

Questions 9-14
Questions 9-14
Reading Passage has 6 paragraphs.
Choose the correct heading for each paragraph
A-F
, from the list of headings.
Write the correct number,
i-viii,
in spaces
9-14
below.
i
the memorable speec
ii
Unhappy about violence
iii
A tragic incident
iv
Protests and action
v
The background of an iconic man
vi
Making his mark internationally
vii
Difficult childhood
vii
Black street repairmen
9
. Paragraph A
Locate
10
.Paragraph
11
. Paragraph C
Locate
12
. Paragraph D
Locate
13
. Paragraph E
Locate
14
. Paragraph F
Locate

9 ____ . Paragraph A Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d367a1c2-4b95-54fa-8acf-21ea0edb77c4', '4aa88ee9-b994-5aa7-9a42-f2a086fe4577', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('dd8a663f-ad2e-58bf-a7dc-c4b9704b846f', '4aa88ee9-b994-5aa7-9a42-f2a086fe4577', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('553d2565-70e1-5d54-adf4-ea2666bfda03', '4aa88ee9-b994-5aa7-9a42-f2a086fe4577', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('480d29ad-890c-5d56-9eed-87baea01971b', '4aa88ee9-b994-5aa7-9a42-f2a086fe4577', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f1f6f8b1-6506-5e14-a9a9-f07eadfc524f', '4aa88ee9-b994-5aa7-9a42-f2a086fe4577', 5, $md$v$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('295c99ce-f0d4-56c4-9962-14f6412e78c0', '4aa88ee9-b994-5aa7-9a42-f2a086fe4577', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('96263c46-612e-55c9-a8ac-3b08f627c11d', '4aa88ee9-b994-5aa7-9a42-f2a086fe4577', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0f3d0381-f319-5b63-a5eb-272a57c25157', '4aa88ee9-b994-5aa7-9a42-f2a086fe4577', 8, $md$viii$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('7c5a9afc-76fc-50ab-97ee-b20cb55d6e99', 'dde7097c-7d02-5a26-a1e9-06564158df59', 10, 'MATCHING_HEADING', 'READING', 4, $md$### Question 10

Questions 9-14
Questions 9-14
Reading Passage has 6 paragraphs.
Choose the correct heading for each paragraph
A-F
, from the list of headings.
Write the correct number,
i-viii,
in spaces
9-14
below.
i
the memorable speec
ii
Unhappy about violence
iii
A tragic incident
iv
Protests and action
v
The background of an iconic man
vi
Making his mark internationally
vii
Difficult childhood
vii
Black street repairmen
9
. Paragraph A
Locate
10
.Paragraph
11
. Paragraph C
Locate
12
. Paragraph D
Locate
13
. Paragraph E
Locate
14
. Paragraph F
Locate

10 ____ .Paragraph$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b6af7949-b0fc-5e6b-a0a9-3cb6b4274171', '7c5a9afc-76fc-50ab-97ee-b20cb55d6e99', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3e74f686-67c9-559b-ab41-2c7feaa1be92', '7c5a9afc-76fc-50ab-97ee-b20cb55d6e99', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d53e764d-e706-5e44-bb55-30a79754524e', '7c5a9afc-76fc-50ab-97ee-b20cb55d6e99', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('872c954b-403c-5363-9ba9-5e3495912d89', '7c5a9afc-76fc-50ab-97ee-b20cb55d6e99', 4, $md$iv$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('30d1fefd-1e79-5a1b-9df3-b9ee478074d1', '7c5a9afc-76fc-50ab-97ee-b20cb55d6e99', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('53c7c700-1431-5cbe-b1fb-702b69e3f4b9', '7c5a9afc-76fc-50ab-97ee-b20cb55d6e99', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4a369910-da0e-5802-b9c8-2473ba42aded', '7c5a9afc-76fc-50ab-97ee-b20cb55d6e99', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6aedf087-9fd6-5996-9361-07a798307592', '7c5a9afc-76fc-50ab-97ee-b20cb55d6e99', 8, $md$viii$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('b1cfe927-a3a0-587b-b6c7-dc870d2f8f78', 'dde7097c-7d02-5a26-a1e9-06564158df59', 11, 'MATCHING_HEADING', 'READING', 4, $md$### Question 11

Questions 9-14
Questions 9-14
Reading Passage has 6 paragraphs.
Choose the correct heading for each paragraph
A-F
, from the list of headings.
Write the correct number,
i-viii,
in spaces
9-14
below.
i
the memorable speec
ii
Unhappy about violence
iii
A tragic incident
iv
Protests and action
v
The background of an iconic man
vi
Making his mark internationally
vii
Difficult childhood
vii
Black street repairmen
9
. Paragraph A
Locate
10
.Paragraph
11
. Paragraph C
Locate
12
. Paragraph D
Locate
13
. Paragraph E
Locate
14
. Paragraph F
Locate

11 ____ . Paragraph C Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('14ada26e-4949-5903-a7c4-89021ddf6f49', 'b1cfe927-a3a0-587b-b6c7-dc870d2f8f78', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('824c1f86-9fcc-5ee3-b5ac-f904d5a2f683', 'b1cfe927-a3a0-587b-b6c7-dc870d2f8f78', 2, $md$ii$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0d3acd71-6cd4-51aa-9956-245ced1f773c', 'b1cfe927-a3a0-587b-b6c7-dc870d2f8f78', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e19813de-69eb-5add-ab10-2a9c07b305f1', 'b1cfe927-a3a0-587b-b6c7-dc870d2f8f78', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7bef6ad4-bbe1-5751-bdcf-3a05c5a07d29', 'b1cfe927-a3a0-587b-b6c7-dc870d2f8f78', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b9bc0765-9cb4-5117-8342-361ec27f0440', 'b1cfe927-a3a0-587b-b6c7-dc870d2f8f78', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f7b04dde-8cfb-5b3e-9a64-d11468eec068', 'b1cfe927-a3a0-587b-b6c7-dc870d2f8f78', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b85984f0-2a61-5e72-9749-2fa617b59ebc', 'b1cfe927-a3a0-587b-b6c7-dc870d2f8f78', 8, $md$viii$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('4833041a-96f9-5f1a-ac84-77afb793ded1', 'dde7097c-7d02-5a26-a1e9-06564158df59', 12, 'MATCHING_HEADING', 'READING', 4, $md$### Question 12

Questions 9-14
Questions 9-14
Reading Passage has 6 paragraphs.
Choose the correct heading for each paragraph
A-F
, from the list of headings.
Write the correct number,
i-viii,
in spaces
9-14
below.
i
the memorable speec
ii
Unhappy about violence
iii
A tragic incident
iv
Protests and action
v
The background of an iconic man
vi
Making his mark internationally
vii
Difficult childhood
vii
Black street repairmen
9
. Paragraph A
Locate
10
.Paragraph
11
. Paragraph C
Locate
12
. Paragraph D
Locate
13
. Paragraph E
Locate
14
. Paragraph F
Locate

12 ____ . Paragraph D Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('535f8be0-441c-5c46-87db-0031af948ec4', '4833041a-96f9-5f1a-ac84-77afb793ded1', 1, $md$i$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b0bc6afd-d863-5ee9-938a-94877ab17d3d', '4833041a-96f9-5f1a-ac84-77afb793ded1', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2b588670-bf33-5323-9e93-38cbdd140604', '4833041a-96f9-5f1a-ac84-77afb793ded1', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5f51eae2-18c8-5646-a594-83fd39827c21', '4833041a-96f9-5f1a-ac84-77afb793ded1', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7fdb03dc-173a-5a45-93b7-bbeeacf74688', '4833041a-96f9-5f1a-ac84-77afb793ded1', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8ae64e53-f731-57c8-b803-04f473855387', '4833041a-96f9-5f1a-ac84-77afb793ded1', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('493cdd26-1dc7-5d9d-ae89-5469175fcf69', '4833041a-96f9-5f1a-ac84-77afb793ded1', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0615e7e4-726b-5283-b161-517d85f77fb9', '4833041a-96f9-5f1a-ac84-77afb793ded1', 8, $md$viii$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('963d7f7f-c67c-57f6-882a-b3f02a5695e9', 'dde7097c-7d02-5a26-a1e9-06564158df59', 13, 'MATCHING_HEADING', 'READING', 4, $md$### Question 13

Questions 9-14
Questions 9-14
Reading Passage has 6 paragraphs.
Choose the correct heading for each paragraph
A-F
, from the list of headings.
Write the correct number,
i-viii,
in spaces
9-14
below.
i
the memorable speec
ii
Unhappy about violence
iii
A tragic incident
iv
Protests and action
v
The background of an iconic man
vi
Making his mark internationally
vii
Difficult childhood
vii
Black street repairmen
9
. Paragraph A
Locate
10
.Paragraph
11
. Paragraph C
Locate
12
. Paragraph D
Locate
13
. Paragraph E
Locate
14
. Paragraph F
Locate

13 ____ . Paragraph E Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2d20dc67-dde5-5ea3-9eac-4e9ab1a21154', '963d7f7f-c67c-57f6-882a-b3f02a5695e9', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('17ccee18-b301-5acb-b150-5ce456341f86', '963d7f7f-c67c-57f6-882a-b3f02a5695e9', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ed6915e7-ec8f-5753-8cc7-f3e4c8229de7', '963d7f7f-c67c-57f6-882a-b3f02a5695e9', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4f9db5aa-05e0-5609-ba83-a15b415f710a', '963d7f7f-c67c-57f6-882a-b3f02a5695e9', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('02147b86-4c73-5498-a43c-7be8a78d4f86', '963d7f7f-c67c-57f6-882a-b3f02a5695e9', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('79eb9341-9a75-5c4e-a9c6-6c44ac2adb65', '963d7f7f-c67c-57f6-882a-b3f02a5695e9', 6, $md$vi$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('abc502e6-8ea0-5234-8add-85e0200ba7e3', '963d7f7f-c67c-57f6-882a-b3f02a5695e9', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e678da74-44ce-5915-bf86-d1b9e8b0b645', '963d7f7f-c67c-57f6-882a-b3f02a5695e9', 8, $md$viii$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('ae0c6aeb-fa58-505f-9e8c-26d9dd743e88', 'dde7097c-7d02-5a26-a1e9-06564158df59', 14, 'MATCHING_HEADING', 'READING', 4, $md$### Question 14

Questions 9-14
Questions 9-14
Reading Passage has 6 paragraphs.
Choose the correct heading for each paragraph
A-F
, from the list of headings.
Write the correct number,
i-viii,
in spaces
9-14
below.
i
the memorable speec
ii
Unhappy about violence
iii
A tragic incident
iv
Protests and action
v
The background of an iconic man
vi
Making his mark internationally
vii
Difficult childhood
vii
Black street repairmen
9
. Paragraph A
Locate
10
.Paragraph
11
. Paragraph C
Locate
12
. Paragraph D
Locate
13
. Paragraph E
Locate
14
. Paragraph F
Locate

14 ____ . Paragraph F Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c68ee6d1-378b-5884-9647-9ccd1ec9c5a8', 'ae0c6aeb-fa58-505f-9e8c-26d9dd743e88', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('574fdaa2-d65d-5a2a-b904-4cb80d5f9c23', 'ae0c6aeb-fa58-505f-9e8c-26d9dd743e88', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('13dc604c-d3b4-5b7a-b752-06b280187608', 'ae0c6aeb-fa58-505f-9e8c-26d9dd743e88', 3, $md$iii$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('03dad252-65ea-5d58-bccc-252db4416fd8', 'ae0c6aeb-fa58-505f-9e8c-26d9dd743e88', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('14f22815-5df1-5cea-9eb1-55cda0072f20', 'ae0c6aeb-fa58-505f-9e8c-26d9dd743e88', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('30909814-b173-5937-89b8-5ea6ea993a13', 'ae0c6aeb-fa58-505f-9e8c-26d9dd743e88', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4522c0ad-85e7-53c3-83d5-77c2c58a7f78', 'ae0c6aeb-fa58-505f-9e8c-26d9dd743e88', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('92e3052e-85de-51d8-9b51-801e50c60fda', 'ae0c6aeb-fa58-505f-9e8c-26d9dd743e88', 8, $md$viii$md$, false);

COMMIT;
