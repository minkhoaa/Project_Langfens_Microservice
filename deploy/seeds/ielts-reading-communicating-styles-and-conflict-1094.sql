BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-communicating-styles-and-conflict-1094'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-communicating-styles-and-conflict-1094';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-communicating-styles-and-conflict-1094';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-communicating-styles-and-conflict-1094';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('3cdb51b0-9354-529f-b17e-4247dcb8e522', 'ielts-reading-communicating-styles-and-conflict-1094', $t$Communicating Styles and Conflict$t$, $md$## Communicating Styles and Conflict

Nguồn:
- Test: https://mini-ielts.com/1094/reading/communicating-styles-and-conflict
- Solution: https://mini-ielts.com/1094/view-solution/reading/communicating-styles-and-conflict$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('2a842cd9-487f-5809-a78a-21af3f2b5899', '3cdb51b0-9354-529f-b17e-4247dcb8e522', 1, $t$Reading — Communicating Styles and Conflict$t$, $md$Read the passage and answer questions **1–14**.

### Passage: Communicating Styles and Conflict

Knowing your communication style and having a mix of styles on your team can provide a positive force for resolving conflict.

A - Physical explanation

As far back as Hippocrates’ time (460-370B.C.), people have tried to understand other people by characterizing them according to personality type or temperament . Hippocrates believed t here were four different body fluids that influenced four basic types of temperament . His work was further developed 500 years later by Galen. These days there are any number of self-assessment tools that relate to the basic descriptions developed by Galen, although we no longer believe the source to be the types of body fluid that dominate our systems.

B - The benefits of understanding communication styles

The values in self-assessments that help determine personality style . Learning styles, communication styles, conflict-handling styles, or other aspects of individuals is that they help depersonalize conflict in interpersonal relationships. The depersonalization occurs when you realize that others aren’t trying to be difficult, but they need different or more information than you do. They’re not intending to be rude: they are so focused on the task they forget about greeting people. They would like to work faster but not at the risk of damaging the relationships needed to get the job done. They understand there is a job to do. But it can only be done right with the appropriate information, which takes time to collect. When used appropriately, understanding communication styles can help resolve conflict on teams. Very rarely are conflicts true personality issues. Usually they are issues of style, information needs, or focus.

C - Summarising personality types

Hippocrates and later Galen determined there were four basic temperaments: sanguine, phlegmatic, melancholic and choleric . These descriptions were developed centuries ago and are still somewhat apt, although you could update the wording. In today’s world, they translate into the four fairly common communication styles described below:

D - A lively person who encourages

The sanguine person would be the expressive or spirited style of communication. These people speak in pictures. They invest a lot of emotion and energy in their communication and often speak quickly. Putting their whole body into it. They are easily sidetracked onto a story that may or may not illustrate the point they are trying to make. Because of their enthusiasm, they are great team motivators . They are concerned about people and relationships. Their high levels of energy can come on strong at times and their focus is usually on the bigger picture, which means they sometimes miss the details or the proper order of things. These people find conflict or differences of opinion invigorating and love to engage in a spirited discussion. They love change and are constantly looking for new and exciting adventures .

E - Factual and analytical personality

Tile phlegmatic person - cool and persevering - translates into the technical or systematic communication style . This style of communication is focused on facts and technical details. Phlegmatic people have an orderly methodical way of approaching tasks, and their focus is very much on the task, not on the people, emotions, or concerns that the task may evoke. The focus is also more on the details necessary to accomplish a task. Sometimes the details overwhelm the big picture and focus needs to be brought back to the context of the task. People with this style think the facts should speak for themselves, and they are not as comfortable with conflict. They need time to adapt to change and need to understand both the logic of it and the steps involved.

F - Cautious and caring

Tile melancholic person who is soft hearted and oriented toward doing things for others translates into the considerate or sympathetic communication style . A person with this communication style is focused on people and relationships. They are good listeners and do things for other people-sometimes to the detriment of getting things done for themselves. They want to solicit everyone’s opinion and make sure everyone is comfortable with whatever is required to get the job done. At times this focus on others can distract from the task at hand. Because they are so concerned with the needs of others and smoothing over issues, they do not like conflict. They believe that change threatens the status quo and tends to make people feel uneasy, so people with this communication style, like phlegmatic people need time to consider the changes in order to adapt to them.

G - Demanding and unsympathetic personality

The choleric temperament translates into the bold or direct style of communication. People with this style are brief in their communication - the fewer words the better. They are big picture thinkers and love to be involved in many things at once. They are focused on tasks and outcomes and often forget that the people involved in carrying out the tasks have needs . They don’t do detail work easily and as a result can often underestimate how much time it takes to achieve the task. Because they are so direct, they often seem forceful and can be very intimidating to others. They usually would welcome someone challenging them. But most other styles are afraid to do so. They also thrive on change, the more the better.

H - Combined styles for workplace

A well-functioning team should have all of these communication styles for true effectiveness . All teams need to focus on the task, and they need to take care of relationships in order to achieve those tasks. They need the big picture perspective or the context of their work, and they need the details to be identified and taken care of for success. We all have aspects of each style within us. Some of us can easily move from one style to another and adapt our style to the needs of the situation at hand-whether the focus is on tasks or relationships. For others, a dominant style is very evident, and it is more challenging to see the situation from the perspective of another style. The work environment can influence communication styles either by the type of work that is required or by the predominance of one style reflected in that environment . Some people use one style at work and another at home.

The good news about communication styles is that we have the ability to develop flexibility in our styles. The greater the flexibility we have, the more skilled we usually are at handling possible and actual conflicts. Usually it has to be relevant to us to do so, either because we think it is important or because there are incentives in our environment to encourage it. The key is that we have to want to become flexible with our communication style. As Henry Ford said, “Whether you think you can or you can’t, you’re right!”$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('5783c8d0-3522-5d94-ab12-eaa0b16b2236', '2a842cd9-487f-5809-a78a-21af3f2b5899', 1, 'MATCHING_HEADING', 'READING', 2, $md$### Question 1

Questions 1-8
Questions 1-8
Reading Passage has eight sections
A-H
.
Choose the correct heading for each section from the list of headings below.
Write the correct number
i-x
in boxes
1-8
on your answer sheet.
List of Headings
i
Summarising personality types
ii
Combined styles for workplace
iii
Physical explanation
iv
A lively person who encourages
v
Demanding and unsympathetic personality
vi
Lazy and careless personality
vii
The benefits of understanding communication styles
viii
Cautious and caring
ix
Factual and analytical personality
x
Self-assessment determines one’s temperament
1
Section A
Locate
2
Section B
Locate
3
Section C
Locate
4
Section D
Locate
5
Section E
Locate
6
Section F
Locate
7
Section G
Locate
8
Section H
Locate

1 ____ Section A Locate 2 ____ Section B Locate 3 ____ Section C Locate 4 ____ Section D Locate 5 ____ Section E Locate 6 ____ Section F Locate 7 ____ Section G Locate 8 ____ Section H Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('13f67ea8-9a0b-5bd1-8338-807dcede687d', '5783c8d0-3522-5d94-ab12-eaa0b16b2236', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('712d83a1-d99d-59b5-95c0-000eb68de2bb', '5783c8d0-3522-5d94-ab12-eaa0b16b2236', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('307c6b2f-c175-53c0-ac93-87cae3e726bf', '5783c8d0-3522-5d94-ab12-eaa0b16b2236', 3, $md$iii$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0adc9d8a-9f1b-54e8-95fc-df3ab90d2fd9', '5783c8d0-3522-5d94-ab12-eaa0b16b2236', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6cc2ff03-0422-51b1-b3af-dfd05fc73c1b', '5783c8d0-3522-5d94-ab12-eaa0b16b2236', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e4edb8b7-2f3f-54a4-b8a8-a079b75be1a8', '5783c8d0-3522-5d94-ab12-eaa0b16b2236', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('734ac23b-62f8-57d8-896f-249da5fad2d1', '5783c8d0-3522-5d94-ab12-eaa0b16b2236', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b5ddf384-d9fc-526c-ac5e-9744d0343e13', '5783c8d0-3522-5d94-ab12-eaa0b16b2236', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e299f433-0275-50b2-bafd-2a04debd72e6', '5783c8d0-3522-5d94-ab12-eaa0b16b2236', 9, $md$ix$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cd46773a-d9ee-5b78-a69a-e04b4372e8be', '5783c8d0-3522-5d94-ab12-eaa0b16b2236', 10, $md$x$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('6dc61148-8aa5-5baf-88f4-d632dfae4684', '2a842cd9-487f-5809-a78a-21af3f2b5899', 2, 'MATCHING_HEADING', 'READING', 2, $md$### Question 2

Questions 1-8
Questions 1-8
Reading Passage has eight sections
A-H
.
Choose the correct heading for each section from the list of headings below.
Write the correct number
i-x
in boxes
1-8
on your answer sheet.
List of Headings
i
Summarising personality types
ii
Combined styles for workplace
iii
Physical explanation
iv
A lively person who encourages
v
Demanding and unsympathetic personality
vi
Lazy and careless personality
vii
The benefits of understanding communication styles
viii
Cautious and caring
ix
Factual and analytical personality
x
Self-assessment determines one’s temperament
1
Section A
Locate
2
Section B
Locate
3
Section C
Locate
4
Section D
Locate
5
Section E
Locate
6
Section F
Locate
7
Section G
Locate
8
Section H
Locate

1 ____ Section A Locate 2 ____ Section B Locate 3 ____ Section C Locate 4 ____ Section D Locate 5 ____ Section E Locate 6 ____ Section F Locate 7 ____ Section G Locate 8 ____ Section H Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('017ade01-59b5-536b-8a0d-cebc6e9d9c2d', '6dc61148-8aa5-5baf-88f4-d632dfae4684', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4d5f3eab-d04a-5d94-b257-05279c73c051', '6dc61148-8aa5-5baf-88f4-d632dfae4684', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('22bdc7d6-ca5d-5858-a9b9-620e05146f0d', '6dc61148-8aa5-5baf-88f4-d632dfae4684', 3, $md$iii$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b7c45732-1515-51a0-b4ce-04081867bf2b', '6dc61148-8aa5-5baf-88f4-d632dfae4684', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3420031e-8448-58a4-91a9-432f9e862a51', '6dc61148-8aa5-5baf-88f4-d632dfae4684', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('eb8cd01a-9471-5b5a-b30c-fe0b81518014', '6dc61148-8aa5-5baf-88f4-d632dfae4684', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ac8341e2-74d9-5bae-8841-3598e72c5024', '6dc61148-8aa5-5baf-88f4-d632dfae4684', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8dcd1adc-c360-5621-9d2c-37f1b939b332', '6dc61148-8aa5-5baf-88f4-d632dfae4684', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2475e696-c423-5a22-bfd4-db4a0d5a260a', '6dc61148-8aa5-5baf-88f4-d632dfae4684', 9, $md$ix$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d049b5d6-bb96-5974-92c1-d1de7ca97a4e', '6dc61148-8aa5-5baf-88f4-d632dfae4684', 10, $md$x$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('8d831462-5d0a-58ea-b683-a8dac43c8237', '2a842cd9-487f-5809-a78a-21af3f2b5899', 3, 'MATCHING_HEADING', 'READING', 2, $md$### Question 3

Questions 1-8
Questions 1-8
Reading Passage has eight sections
A-H
.
Choose the correct heading for each section from the list of headings below.
Write the correct number
i-x
in boxes
1-8
on your answer sheet.
List of Headings
i
Summarising personality types
ii
Combined styles for workplace
iii
Physical explanation
iv
A lively person who encourages
v
Demanding and unsympathetic personality
vi
Lazy and careless personality
vii
The benefits of understanding communication styles
viii
Cautious and caring
ix
Factual and analytical personality
x
Self-assessment determines one’s temperament
1
Section A
Locate
2
Section B
Locate
3
Section C
Locate
4
Section D
Locate
5
Section E
Locate
6
Section F
Locate
7
Section G
Locate
8
Section H
Locate

1 ____ Section A Locate 2 ____ Section B Locate 3 ____ Section C Locate 4 ____ Section D Locate 5 ____ Section E Locate 6 ____ Section F Locate 7 ____ Section G Locate 8 ____ Section H Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b09eead0-523b-5e92-a430-e63833801e80', '8d831462-5d0a-58ea-b683-a8dac43c8237', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b6033ef5-47e9-5441-9617-a55769308913', '8d831462-5d0a-58ea-b683-a8dac43c8237', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3890d2e7-7130-5ffa-ba83-9b82ff4fe672', '8d831462-5d0a-58ea-b683-a8dac43c8237', 3, $md$iii$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('07fe0e4f-9e17-551b-aece-93ccd2f24213', '8d831462-5d0a-58ea-b683-a8dac43c8237', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('22e9d1c7-b292-5645-b26c-5117571c3071', '8d831462-5d0a-58ea-b683-a8dac43c8237', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('70a7991f-9d83-5bf5-88c7-9ebfb2f210f5', '8d831462-5d0a-58ea-b683-a8dac43c8237', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ba98ab88-7a88-5189-9634-444f092ca1e2', '8d831462-5d0a-58ea-b683-a8dac43c8237', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1fd45d8c-f24e-5301-9706-3de80ba298fc', '8d831462-5d0a-58ea-b683-a8dac43c8237', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('81d81cd7-cafa-5374-801b-eb9eaed1f867', '8d831462-5d0a-58ea-b683-a8dac43c8237', 9, $md$ix$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c060edd8-f8d0-52d6-9f68-1fd2b80cf213', '8d831462-5d0a-58ea-b683-a8dac43c8237', 10, $md$x$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('4912cfcb-ac15-5496-a5b5-631b2dfc6e88', '2a842cd9-487f-5809-a78a-21af3f2b5899', 4, 'MATCHING_HEADING', 'READING', 2, $md$### Question 4

Questions 1-8
Questions 1-8
Reading Passage has eight sections
A-H
.
Choose the correct heading for each section from the list of headings below.
Write the correct number
i-x
in boxes
1-8
on your answer sheet.
List of Headings
i
Summarising personality types
ii
Combined styles for workplace
iii
Physical explanation
iv
A lively person who encourages
v
Demanding and unsympathetic personality
vi
Lazy and careless personality
vii
The benefits of understanding communication styles
viii
Cautious and caring
ix
Factual and analytical personality
x
Self-assessment determines one’s temperament
1
Section A
Locate
2
Section B
Locate
3
Section C
Locate
4
Section D
Locate
5
Section E
Locate
6
Section F
Locate
7
Section G
Locate
8
Section H
Locate

1 ____ Section A Locate 2 ____ Section B Locate 3 ____ Section C Locate 4 ____ Section D Locate 5 ____ Section E Locate 6 ____ Section F Locate 7 ____ Section G Locate 8 ____ Section H Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('368795d1-cd26-5ed7-a8b0-1424e796b778', '4912cfcb-ac15-5496-a5b5-631b2dfc6e88', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5fdfbc13-0457-5a3a-9dc9-8e4da6e70f4d', '4912cfcb-ac15-5496-a5b5-631b2dfc6e88', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('107fe605-563b-5cc3-ace8-c8950059bb36', '4912cfcb-ac15-5496-a5b5-631b2dfc6e88', 3, $md$iii$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b3824776-0c42-5fd3-9700-affa42db871a', '4912cfcb-ac15-5496-a5b5-631b2dfc6e88', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bc329bd2-b3ae-51bd-9289-62c914ec376d', '4912cfcb-ac15-5496-a5b5-631b2dfc6e88', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ec1e1917-8e36-5a9f-8cf4-f7ddd2516366', '4912cfcb-ac15-5496-a5b5-631b2dfc6e88', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c983adb2-fe77-56be-b131-60ad5b388931', '4912cfcb-ac15-5496-a5b5-631b2dfc6e88', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('50cc6ff6-eea3-5ce5-9317-7a83c3d05d70', '4912cfcb-ac15-5496-a5b5-631b2dfc6e88', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('958c2685-385c-5f63-920b-fef86f06447a', '4912cfcb-ac15-5496-a5b5-631b2dfc6e88', 9, $md$ix$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cdc0b8c3-81d1-5a99-ae79-391ae3e55f50', '4912cfcb-ac15-5496-a5b5-631b2dfc6e88', 10, $md$x$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('89b306c3-6335-507e-aeca-8be9a3610284', '2a842cd9-487f-5809-a78a-21af3f2b5899', 5, 'MATCHING_HEADING', 'READING', 3, $md$### Question 5

Questions 1-8
Questions 1-8
Reading Passage has eight sections
A-H
.
Choose the correct heading for each section from the list of headings below.
Write the correct number
i-x
in boxes
1-8
on your answer sheet.
List of Headings
i
Summarising personality types
ii
Combined styles for workplace
iii
Physical explanation
iv
A lively person who encourages
v
Demanding and unsympathetic personality
vi
Lazy and careless personality
vii
The benefits of understanding communication styles
viii
Cautious and caring
ix
Factual and analytical personality
x
Self-assessment determines one’s temperament
1
Section A
Locate
2
Section B
Locate
3
Section C
Locate
4
Section D
Locate
5
Section E
Locate
6
Section F
Locate
7
Section G
Locate
8
Section H
Locate

1 ____ Section A Locate 2 ____ Section B Locate 3 ____ Section C Locate 4 ____ Section D Locate 5 ____ Section E Locate 6 ____ Section F Locate 7 ____ Section G Locate 8 ____ Section H Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8ff82fcb-63f5-5a5f-bb7a-f9cb3552019e', '89b306c3-6335-507e-aeca-8be9a3610284', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e5f0c918-685c-568f-ba83-b4789fc00a81', '89b306c3-6335-507e-aeca-8be9a3610284', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('540725fe-ec98-5f1e-ba4a-4516bd4f772c', '89b306c3-6335-507e-aeca-8be9a3610284', 3, $md$iii$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('44eee455-58ab-5bb6-9efd-e029666a3f75', '89b306c3-6335-507e-aeca-8be9a3610284', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d621969b-7e72-5136-ab11-3504bb42cbe9', '89b306c3-6335-507e-aeca-8be9a3610284', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9b6b23b0-ddd3-5366-9826-845993772695', '89b306c3-6335-507e-aeca-8be9a3610284', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a19c4358-b983-55d8-a6f2-10a57d41d9d3', '89b306c3-6335-507e-aeca-8be9a3610284', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('64696030-e5a6-5983-80fc-7f32ca6be3e9', '89b306c3-6335-507e-aeca-8be9a3610284', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0cecee10-066e-54bd-8fee-cbc8aa1ba25f', '89b306c3-6335-507e-aeca-8be9a3610284', 9, $md$ix$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ad1a4413-7a81-5480-8714-4c3207a2c5d5', '89b306c3-6335-507e-aeca-8be9a3610284', 10, $md$x$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('67e8e7bf-8331-5dab-953e-29bae26458e1', '2a842cd9-487f-5809-a78a-21af3f2b5899', 6, 'MATCHING_HEADING', 'READING', 3, $md$### Question 6

Questions 1-8
Questions 1-8
Reading Passage has eight sections
A-H
.
Choose the correct heading for each section from the list of headings below.
Write the correct number
i-x
in boxes
1-8
on your answer sheet.
List of Headings
i
Summarising personality types
ii
Combined styles for workplace
iii
Physical explanation
iv
A lively person who encourages
v
Demanding and unsympathetic personality
vi
Lazy and careless personality
vii
The benefits of understanding communication styles
viii
Cautious and caring
ix
Factual and analytical personality
x
Self-assessment determines one’s temperament
1
Section A
Locate
2
Section B
Locate
3
Section C
Locate
4
Section D
Locate
5
Section E
Locate
6
Section F
Locate
7
Section G
Locate
8
Section H
Locate

1 ____ Section A Locate 2 ____ Section B Locate 3 ____ Section C Locate 4 ____ Section D Locate 5 ____ Section E Locate 6 ____ Section F Locate 7 ____ Section G Locate 8 ____ Section H Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f7c5d1a8-dfd9-575e-bbb6-b945cc346bb4', '67e8e7bf-8331-5dab-953e-29bae26458e1', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1bccdb9d-17ff-5922-ad7c-8e1aec0ef238', '67e8e7bf-8331-5dab-953e-29bae26458e1', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('56bb3d7f-f96a-5c6f-b16a-2d759332a697', '67e8e7bf-8331-5dab-953e-29bae26458e1', 3, $md$iii$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e800219c-11f8-53d1-9ad6-6154ba371199', '67e8e7bf-8331-5dab-953e-29bae26458e1', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ba43808a-7b0b-5b5b-b70f-014865ce27fc', '67e8e7bf-8331-5dab-953e-29bae26458e1', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c26ff6b0-9e2c-5aef-8b17-c2d3aac9194b', '67e8e7bf-8331-5dab-953e-29bae26458e1', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8f341ac1-5125-52d7-b26e-d1b2fc5add21', '67e8e7bf-8331-5dab-953e-29bae26458e1', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f9beced0-bac2-5d6d-bfc0-1f75ba5797ea', '67e8e7bf-8331-5dab-953e-29bae26458e1', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1d4682c2-efa9-5080-bf6e-4a9b0967a80a', '67e8e7bf-8331-5dab-953e-29bae26458e1', 9, $md$ix$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7b646553-ed9b-5a75-9f16-87c2835481e4', '67e8e7bf-8331-5dab-953e-29bae26458e1', 10, $md$x$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('9047eedb-51bd-5d2b-8733-61252e5b7e86', '2a842cd9-487f-5809-a78a-21af3f2b5899', 7, 'MATCHING_HEADING', 'READING', 3, $md$### Question 7

Questions 1-8
Questions 1-8
Reading Passage has eight sections
A-H
.
Choose the correct heading for each section from the list of headings below.
Write the correct number
i-x
in boxes
1-8
on your answer sheet.
List of Headings
i
Summarising personality types
ii
Combined styles for workplace
iii
Physical explanation
iv
A lively person who encourages
v
Demanding and unsympathetic personality
vi
Lazy and careless personality
vii
The benefits of understanding communication styles
viii
Cautious and caring
ix
Factual and analytical personality
x
Self-assessment determines one’s temperament
1
Section A
Locate
2
Section B
Locate
3
Section C
Locate
4
Section D
Locate
5
Section E
Locate
6
Section F
Locate
7
Section G
Locate
8
Section H
Locate

1 ____ Section A Locate 2 ____ Section B Locate 3 ____ Section C Locate 4 ____ Section D Locate 5 ____ Section E Locate 6 ____ Section F Locate 7 ____ Section G Locate 8 ____ Section H Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8333e7c8-6bda-5a6c-af20-ba8517eba261', '9047eedb-51bd-5d2b-8733-61252e5b7e86', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1f6ecd89-603c-5c50-832c-19b51f9be02f', '9047eedb-51bd-5d2b-8733-61252e5b7e86', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5d2e1423-e93b-50d6-882e-506a17ee7c3c', '9047eedb-51bd-5d2b-8733-61252e5b7e86', 3, $md$iii$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('841f703a-3c4a-56e2-86f0-08491e2149f4', '9047eedb-51bd-5d2b-8733-61252e5b7e86', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('804ef9f7-af7e-5357-b076-0c9228d4abb4', '9047eedb-51bd-5d2b-8733-61252e5b7e86', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c4f3c9a3-5ea7-546e-85a6-7db70eff7225', '9047eedb-51bd-5d2b-8733-61252e5b7e86', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1600dca2-aeb1-5089-a30e-56ec5305e95f', '9047eedb-51bd-5d2b-8733-61252e5b7e86', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5f2d8697-bf26-53be-8b52-db540dbf99f8', '9047eedb-51bd-5d2b-8733-61252e5b7e86', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('42477d0b-7ea9-5d7c-b668-51c357143a35', '9047eedb-51bd-5d2b-8733-61252e5b7e86', 9, $md$ix$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5ab9e008-050f-53c2-b497-4f490feae110', '9047eedb-51bd-5d2b-8733-61252e5b7e86', 10, $md$x$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('56db9210-2b1b-52eb-aa3a-38c4a83adfed', '2a842cd9-487f-5809-a78a-21af3f2b5899', 8, 'MATCHING_HEADING', 'READING', 3, $md$### Question 8

Questions 1-8
Questions 1-8
Reading Passage has eight sections
A-H
.
Choose the correct heading for each section from the list of headings below.
Write the correct number
i-x
in boxes
1-8
on your answer sheet.
List of Headings
i
Summarising personality types
ii
Combined styles for workplace
iii
Physical explanation
iv
A lively person who encourages
v
Demanding and unsympathetic personality
vi
Lazy and careless personality
vii
The benefits of understanding communication styles
viii
Cautious and caring
ix
Factual and analytical personality
x
Self-assessment determines one’s temperament
1
Section A
Locate
2
Section B
Locate
3
Section C
Locate
4
Section D
Locate
5
Section E
Locate
6
Section F
Locate
7
Section G
Locate
8
Section H
Locate

1 ____ Section A Locate 2 ____ Section B Locate 3 ____ Section C Locate 4 ____ Section D Locate 5 ____ Section E Locate 6 ____ Section F Locate 7 ____ Section G Locate 8 ____ Section H Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bdeb59e2-ee38-5487-97a4-5d8669120e20', '56db9210-2b1b-52eb-aa3a-38c4a83adfed', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c51185ea-1489-5939-99b4-07a63ded3289', '56db9210-2b1b-52eb-aa3a-38c4a83adfed', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('427c6e26-308f-5062-9cb6-592f40345a46', '56db9210-2b1b-52eb-aa3a-38c4a83adfed', 3, $md$iii$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a78eb7de-54e5-55b1-b4ac-de84f83c19d1', '56db9210-2b1b-52eb-aa3a-38c4a83adfed', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7adac2b8-f1b1-5bd3-8142-495f69bb165b', '56db9210-2b1b-52eb-aa3a-38c4a83adfed', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a0fab44d-c812-5c3c-92e8-0ee8109f670e', '56db9210-2b1b-52eb-aa3a-38c4a83adfed', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2d332384-57ab-579f-a4e7-8f2d38f38d58', '56db9210-2b1b-52eb-aa3a-38c4a83adfed', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a3632c2b-fac6-5795-b3a3-dbdd7e60d759', '56db9210-2b1b-52eb-aa3a-38c4a83adfed', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3784ff93-6300-5bab-a44d-d39bc1b061d7', '56db9210-2b1b-52eb-aa3a-38c4a83adfed', 9, $md$ix$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a45eb5ab-552c-5fc7-9ab1-08c112d9ed62', '56db9210-2b1b-52eb-aa3a-38c4a83adfed', 10, $md$x$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('3f9b4899-34d3-5b8b-ad72-2ac2c0964244', '2a842cd9-487f-5809-a78a-21af3f2b5899', 9, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 9

Questions 9-13
Questions 9-13
Do the following statements agree with the information given in Reading Passage?
In boxes
9-13
on your answer sheet, write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
9
It is believed that sanguine people dislike variety.
Locate
10
Melancholic and phlegmatic people have similar characteristics.
Locate
11
Managers often select their best employees according to personality types.
12
It is possible to change one’s personality type.
Locate
13
Workplace environment can affect which communication style is most effective.
Locate

9 ____ It is believed that sanguine people dislike variety. Locate 10 ____ Melancholic and phlegmatic people have similar characteristics. Locate 11 ____ Managers often select their best employees according to personality types. 12 ____ It is possible to change one’s personality type. Locate 13 ____ Workplace environment can affect which communication style is most effective. Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ad93ca25-5b46-54df-b640-6a519ef9d736', '3f9b4899-34d3-5b8b-ad72-2ac2c0964244', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('eb23c113-4143-524d-b98b-53f59be8fee6', '3f9b4899-34d3-5b8b-ad72-2ac2c0964244', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b9c13fd5-16bd-54a9-8969-ccb6559151eb', '3f9b4899-34d3-5b8b-ad72-2ac2c0964244', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('4464a01c-32c0-5649-a353-638d3b7757c3', '2a842cd9-487f-5809-a78a-21af3f2b5899', 10, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 10

Questions 9-13
Questions 9-13
Do the following statements agree with the information given in Reading Passage?
In boxes
9-13
on your answer sheet, write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
9
It is believed that sanguine people dislike variety.
Locate
10
Melancholic and phlegmatic people have similar characteristics.
Locate
11
Managers often select their best employees according to personality types.
12
It is possible to change one’s personality type.
Locate
13
Workplace environment can affect which communication style is most effective.
Locate

9 ____ It is believed that sanguine people dislike variety. Locate 10 ____ Melancholic and phlegmatic people have similar characteristics. Locate 11 ____ Managers often select their best employees according to personality types. 12 ____ It is possible to change one’s personality type. Locate 13 ____ Workplace environment can affect which communication style is most effective. Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('80a57f6c-dc25-5805-bd28-c0c88adfe441', '4464a01c-32c0-5649-a353-638d3b7757c3', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('eeb1fc27-df2b-5179-892d-9dd2dfb7bfcc', '4464a01c-32c0-5649-a353-638d3b7757c3', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d93ed1dd-d498-5ad9-8d78-545f8a31ff0e', '4464a01c-32c0-5649-a353-638d3b7757c3', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('8793f6a6-170a-5d74-ae62-fd262d1aca85', '2a842cd9-487f-5809-a78a-21af3f2b5899', 11, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 11

Questions 9-13
Questions 9-13
Do the following statements agree with the information given in Reading Passage?
In boxes
9-13
on your answer sheet, write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
9
It is believed that sanguine people dislike variety.
Locate
10
Melancholic and phlegmatic people have similar characteristics.
Locate
11
Managers often select their best employees according to personality types.
12
It is possible to change one’s personality type.
Locate
13
Workplace environment can affect which communication style is most effective.
Locate

9 ____ It is believed that sanguine people dislike variety. Locate 10 ____ Melancholic and phlegmatic people have similar characteristics. Locate 11 ____ Managers often select their best employees according to personality types. 12 ____ It is possible to change one’s personality type. Locate 13 ____ Workplace environment can affect which communication style is most effective. Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a3d67474-a2ed-5519-8b7a-89e5be155aa1', '8793f6a6-170a-5d74-ae62-fd262d1aca85', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('866c1a8c-a38d-5167-bf11-f80bb0b134e3', '8793f6a6-170a-5d74-ae62-fd262d1aca85', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('86abd9fa-388b-50ca-b836-683cebf45163', '8793f6a6-170a-5d74-ae62-fd262d1aca85', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('559ce128-8c26-5abc-9ec8-42a90e13aad6', '2a842cd9-487f-5809-a78a-21af3f2b5899', 12, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 12

Questions 9-13
Questions 9-13
Do the following statements agree with the information given in Reading Passage?
In boxes
9-13
on your answer sheet, write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
9
It is believed that sanguine people dislike variety.
Locate
10
Melancholic and phlegmatic people have similar characteristics.
Locate
11
Managers often select their best employees according to personality types.
12
It is possible to change one’s personality type.
Locate
13
Workplace environment can affect which communication style is most effective.
Locate

9 ____ It is believed that sanguine people dislike variety. Locate 10 ____ Melancholic and phlegmatic people have similar characteristics. Locate 11 ____ Managers often select their best employees according to personality types. 12 ____ It is possible to change one’s personality type. Locate 13 ____ Workplace environment can affect which communication style is most effective. Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6583e445-6c09-54cc-805d-0246e983a01c', '559ce128-8c26-5abc-9ec8-42a90e13aad6', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1088624e-e725-5af3-b06b-7f41d3d65cd2', '559ce128-8c26-5abc-9ec8-42a90e13aad6', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5da200ad-70aa-55b6-93a0-f23020527994', '559ce128-8c26-5abc-9ec8-42a90e13aad6', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('f298cd66-74c5-5d64-b1c1-3e3508a7dfec', '2a842cd9-487f-5809-a78a-21af3f2b5899', 13, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 13

Questions 9-13
Questions 9-13
Do the following statements agree with the information given in Reading Passage?
In boxes
9-13
on your answer sheet, write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
9
It is believed that sanguine people dislike variety.
Locate
10
Melancholic and phlegmatic people have similar characteristics.
Locate
11
Managers often select their best employees according to personality types.
12
It is possible to change one’s personality type.
Locate
13
Workplace environment can affect which communication style is most effective.
Locate

9 ____ It is believed that sanguine people dislike variety. Locate 10 ____ Melancholic and phlegmatic people have similar characteristics. Locate 11 ____ Managers often select their best employees according to personality types. 12 ____ It is possible to change one’s personality type. Locate 13 ____ Workplace environment can affect which communication style is most effective. Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b923353c-92dc-580f-9f75-e68152ef5e5d', 'f298cd66-74c5-5d64-b1c1-3e3508a7dfec', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0faee0a8-433d-5aec-85f8-c65ce575aace', 'f298cd66-74c5-5d64-b1c1-3e3508a7dfec', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('26d04a28-6549-5acb-bc4f-3a0c5b3b2d33', 'f298cd66-74c5-5d64-b1c1-3e3508a7dfec', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('67111873-2c3e-55ce-93e0-d89213412875', '2a842cd9-487f-5809-a78a-21af3f2b5899', 14, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 14

Question 14
Question 14
Choose the correct letter
A, B, C
or
D
.
Write your answers in box
14
on your answer sheet.
14
. The writer believes using self-assessment tools can
A
help to develop one’s personality.
B
help to understand colleagues’ behaviour.
C
improve one’s relationship with the employer.
D
directly resolve conflicts.
Locate

Choose the correct letter A, B, C or D . Write your answers in box 14 on your answer sheet.$md$, NULL);

COMMIT;
