BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-yawning-1538'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-yawning-1538';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-yawning-1538';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-yawning-1538';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('60eb7e46-1389-55d0-a6c7-79951f98f805', 'ielts-reading-yawning-1538', $t$Yawning$t$, $md$## Yawning

Nguồn:
- Test: https://mini-ielts.com/1538/reading/yawning
- Solution: https://mini-ielts.com/1538/view-solution/reading/yawning$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('6df73ee8-545c-515b-ab4a-4afe82eedd6a', '60eb7e46-1389-55d0-a6c7-79951f98f805', 1, $t$Reading — Yawning$t$, $md$Read the passage and answer questions **1–14**.

### Passage: Yawning

How and why we yarn still presents problems for researchers in an area which has only recently been opened up to study

When Robert R Provine began studying yawning in the 1960s, it was difficult for him to convince research students of the merits of 'yawning science 1 . Although it may appear quirky to some, Provine's decision to study yawning was a logical extension of his research in developmental neuroscience.

The verb 'to yawn' is derived from the Old English ganien or ginian, meaning to gape or open wide. But in addition to gaping jaws, yawning has significant features that are easy to observe and analyse. Provine 'collected' yawns to study by using a variation of the contagion response*. He asked people to 'think about yawning' and, once they began to yawn to depress a button and that would record from the start of the yawn to the exhalation at its end.

Provine's early discoveries can be summanized as follows: the yawn is highly stereotyped but not invariant in its duration and form. It is an excellent example of the instinctive 'fixed action pattern' of classical animal-behavior study, or ethology. It is not a reflex (short-duration, rapid, proportional response to a simple stimulus), but, once started, a yawn progresses with the inevitability of a sneeze. The standard yawn runs its course over about six seconds on average, but its duration can range from about three seconds to much longer than the average. There are no half-yawns: this is an example of the typical intensity of fixed action patterns and a reason why you cannot stifle yawns. Just like a cough, yawns can come in bouts with a highly variable inter-yawn interval, which is generally about 68 seconds but rarely more than 70. There is no relation between yawn frequency and duration: producers of short or long yawns do not compensate by yawning more or less often. Furthermore, Provine's hypotheses about the form and function of yawning can be tested by three informative yawn variants which can be used to look at the roles of the nose, the mouth and the jaws.

i) The closed nose yawn

Subjects are asked to pinch their nose closed when they feel themselves start to yawn. Most subjects report being able to perform perfectly normal closed nose yawns. This indicates that the inhalation at the onset of a yawn, and the exhalation at its end, need not involve the nostrils - the mouth provides a sufficient airway.

ii) The clenched teeth yawn

Subjects are asked to clench their teeth when they feel themselves start to yawn but allow themselves to inhale normally through their open lips and clenched teeth. This variant gives one the sensation of being stuck mid­yawn. This shows that gaping of the jaws is an essential component of the fixed action pattern of the yawn, and unless it is accomplished, the program (or pattern) will not run to completion. The yawn is also shown to be more than a deep breath, because, unlike normal breathing, inhalation and exhalation cannot be performed so well through the clenched teeth as through the nose.

iii) The nose yawn

This variant tests the adequacy of the nasal airway to sustain a yawn. Unlike normal breathing, which can be performed equally well through mouth or nose, yawning is impossible via nasal inhalation alone. As with the clenched teeth yawn, the nose yawn provides the unfulfilling sensation of being stuck in mid-yawn. Exhalation, on the other hand, can be accomplished equally well through nose or mouth. Through thin methodology Provine demonstrated that inhalation through the oral airway and the gaping of jaws are necessary for normal yawns. The motor program for yawning will not run to completion without feedback that these parts of the program have been accomplished.

But yawning is a powerful, generalized movement that involves much more than airway maneuvres and jaw-gaping. When yawning you also stretch your facial muscles, tilt your head back, narrow or close your eyes, produce tears, salivate, open the Eustachian tubes of your middle ear and perform many other, yet unspecified, cardiovascular and respiratory acts. Perhaps the yawn shares components with other behaviour. For example, in the yawn a kind of 'slow sneeze 1 or is the sneeze a 'fast yawn'? Both share common respiratory and other features including jaw gaping, eye closing and head tilting.

Yawning and stretching share properties and may be performed together as parts of a global motor complex. Studies by J I p deVries et al. in the early 1980s, charting movement in the developing foet US using ultrasound, observed a link between yawning and stretching. The most extraordinary demonstration of the yawn-stretch linkage occurs in many people paralyzed on one side of their body because of brain damage caused by a stroke, the prominent British neurologist Sir Francis Walshe noted in 1923 that when these people yawn, they are startled and mystified to observe that their otherwise paralyzed arm rises and flexes automatically in what neurologists term an 'associated response'. Yawning apparently activates undamaged, unconsciously controlled connections between the brain and the motor system, causing the paralyzed limb to move. It is not known whether the associated response is a positive prognosis for recovery, nor whether yawning is therapeutic for prevention of muscular deterioration.

Provine speculated that, in general, yawning may have many functions, and selecting a single function from the available options may be an unrealistic goal. Yawning appears to be associated with a change of behavioral state, switching from one activity to another. Yawning is also a reminder that ancient and unconscious behavior linking US to the animal world lurks beneath the veneer of culture, rationality and language.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('456977cb-2fb5-5e82-9cc0-0a71b5c9faac', '6df73ee8-545c-515b-ab4a-4afe82eedd6a', 1, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 1

Questions 1-6
Questions 1-6
Complete the summary below using the list of words, A-K, below
Write the correct letter, A-K, in boxes 1-6 on your answer sheet.
Provine's early findings on yawns
Through his observation of yawns, Province was able to confirm that
1
do not exist.
Just like a
2
, yawns cannot be interrupted after they have begun. This is because yawns occur as a
3
rather than a stimulus response as was previously thought.
In measuring the time taken to yawn, provive found that a typical yawn lasts about
4
.. He also found that it is a common for people to yawn a number of times in quick succession with the yawns usually being around
5
apart. When studying whether length and rate were
connected. Province concluded that people who yawn less do not necessarily produce
6
to make up for this.
A
form and function
B
long yawns
C
3 seconds
D
fixed action pattern
E
68 seconds
F
short yawns
G
reflex
H
sneeze
I
short duration
J
6 seconds
K
half-yawns

Through his observation of yawns, Province was able to confirm that 1 ____ do not exist.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bdc822dc-851e-568d-853f-3a126f818d14', '456977cb-2fb5-5e82-9cc0-0a71b5c9faac', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('15f5c136-4c2f-5c96-a977-44a9442fc2dc', '456977cb-2fb5-5e82-9cc0-0a71b5c9faac', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0d9057a5-4859-54ad-8cbe-593b47342018', '456977cb-2fb5-5e82-9cc0-0a71b5c9faac', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('91ab98e3-8022-5fdc-a8aa-018e3678fd7d', '456977cb-2fb5-5e82-9cc0-0a71b5c9faac', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ff0ceb2c-0b5f-59d3-83ce-f3cb3afc52f7', '456977cb-2fb5-5e82-9cc0-0a71b5c9faac', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('212eba34-757f-545e-903c-47cf01c7e0cc', '456977cb-2fb5-5e82-9cc0-0a71b5c9faac', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0003312b-deca-5f2a-ac4a-c0f5733a9b8b', '456977cb-2fb5-5e82-9cc0-0a71b5c9faac', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b3776cb3-d1fc-5003-be38-5739e13d0bf1', '456977cb-2fb5-5e82-9cc0-0a71b5c9faac', 8, $md$H$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('427d7550-afa0-5e79-83e1-742d0f967fa1', '456977cb-2fb5-5e82-9cc0-0a71b5c9faac', 9, $md$I$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7b208b82-93a8-5980-b918-f949e425cb42', '456977cb-2fb5-5e82-9cc0-0a71b5c9faac', 10, $md$J$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('98a5c5e9-e32d-580a-8120-4f8b7071557a', '456977cb-2fb5-5e82-9cc0-0a71b5c9faac', 11, $md$K$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('1bc4cb7c-1260-54c3-8aef-89e6adc2f5b9', '6df73ee8-545c-515b-ab4a-4afe82eedd6a', 2, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 2

Questions 1-6
Questions 1-6
Complete the summary below using the list of words, A-K, below
Write the correct letter, A-K, in boxes 1-6 on your answer sheet.
Provine's early findings on yawns
Through his observation of yawns, Province was able to confirm that
1
do not exist.
Just like a
2
, yawns cannot be interrupted after they have begun. This is because yawns occur as a
3
rather than a stimulus response as was previously thought.
In measuring the time taken to yawn, provive found that a typical yawn lasts about
4
.. He also found that it is a common for people to yawn a number of times in quick succession with the yawns usually being around
5
apart. When studying whether length and rate were
connected. Province concluded that people who yawn less do not necessarily produce
6
to make up for this.
A
form and function
B
long yawns
C
3 seconds
D
fixed action pattern
E
68 seconds
F
short yawns
G
reflex
H
sneeze
I
short duration
J
6 seconds
K
half-yawns

Just like a 2 ____ , yawns cannot be interrupted after they have begun. This is because yawns occur as a 3 ____ rather than a stimulus response as was previously thought.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c97d5856-6124-5185-969c-7a58818e2c3d', '1bc4cb7c-1260-54c3-8aef-89e6adc2f5b9', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('378a6562-d437-5c41-80a2-28fa3f876274', '1bc4cb7c-1260-54c3-8aef-89e6adc2f5b9', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5863d37b-28da-5784-bbcd-f04f41fa59d3', '1bc4cb7c-1260-54c3-8aef-89e6adc2f5b9', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c988a6cb-c5cd-5499-91be-b4f784cbbf3b', '1bc4cb7c-1260-54c3-8aef-89e6adc2f5b9', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('95d97dc4-374f-5a95-9387-be3bfd07554f', '1bc4cb7c-1260-54c3-8aef-89e6adc2f5b9', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('122199b8-7923-58ba-9455-0170c5ac96ba', '1bc4cb7c-1260-54c3-8aef-89e6adc2f5b9', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4c77072f-167f-51ac-97c1-e3e1bfb47725', '1bc4cb7c-1260-54c3-8aef-89e6adc2f5b9', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('884d56e8-db99-5f7d-9529-3b8dcfa2d965', '1bc4cb7c-1260-54c3-8aef-89e6adc2f5b9', 8, $md$H$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('864c3df0-7dd3-596d-b41f-849bf971b0ce', '1bc4cb7c-1260-54c3-8aef-89e6adc2f5b9', 9, $md$I$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9679274e-512c-57df-b590-08443990cfc2', '1bc4cb7c-1260-54c3-8aef-89e6adc2f5b9', 10, $md$J$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('99f478df-e2fa-57fa-b6e0-ce70ddb0b92b', '1bc4cb7c-1260-54c3-8aef-89e6adc2f5b9', 11, $md$K$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('5d2987a4-6512-5a6d-ba5f-bab10694dd17', '6df73ee8-545c-515b-ab4a-4afe82eedd6a', 3, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 3

Questions 1-6
Questions 1-6
Complete the summary below using the list of words, A-K, below
Write the correct letter, A-K, in boxes 1-6 on your answer sheet.
Provine's early findings on yawns
Through his observation of yawns, Province was able to confirm that
1
do not exist.
Just like a
2
, yawns cannot be interrupted after they have begun. This is because yawns occur as a
3
rather than a stimulus response as was previously thought.
In measuring the time taken to yawn, provive found that a typical yawn lasts about
4
.. He also found that it is a common for people to yawn a number of times in quick succession with the yawns usually being around
5
apart. When studying whether length and rate were
connected. Province concluded that people who yawn less do not necessarily produce
6
to make up for this.
A
form and function
B
long yawns
C
3 seconds
D
fixed action pattern
E
68 seconds
F
short yawns
G
reflex
H
sneeze
I
short duration
J
6 seconds
K
half-yawns

Just like a 2 ____ , yawns cannot be interrupted after they have begun. This is because yawns occur as a 3 ____ rather than a stimulus response as was previously thought.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1a4048f3-5fca-5ea4-a3c8-1c5804bcd04c', '5d2987a4-6512-5a6d-ba5f-bab10694dd17', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9dad6039-f0e2-5a1e-8444-89dc97b95289', '5d2987a4-6512-5a6d-ba5f-bab10694dd17', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('943813f9-929d-5306-8277-a27d3e103d7e', '5d2987a4-6512-5a6d-ba5f-bab10694dd17', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9b5d302d-054b-571d-812f-ddd9920b42cf', '5d2987a4-6512-5a6d-ba5f-bab10694dd17', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('de0042b1-2740-550f-adf2-de132e3e6ef4', '5d2987a4-6512-5a6d-ba5f-bab10694dd17', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e1a850d1-a299-5b5a-a0a5-7578f8101608', '5d2987a4-6512-5a6d-ba5f-bab10694dd17', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('dd1f4953-bfd6-5dad-a0fd-b63cc9a07ee3', '5d2987a4-6512-5a6d-ba5f-bab10694dd17', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('83dcb36d-514c-5d35-9c6d-384b3e4a4861', '5d2987a4-6512-5a6d-ba5f-bab10694dd17', 8, $md$H$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4e55dc77-c545-5c6a-9646-bebf7ec5374d', '5d2987a4-6512-5a6d-ba5f-bab10694dd17', 9, $md$I$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a0baa403-aa85-5fe0-a934-b0acab51f218', '5d2987a4-6512-5a6d-ba5f-bab10694dd17', 10, $md$J$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e6bce8d1-1797-5522-a3fa-d4edeef7d380', '5d2987a4-6512-5a6d-ba5f-bab10694dd17', 11, $md$K$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('d0b73344-0998-5ad7-8b94-98f060c30d14', '6df73ee8-545c-515b-ab4a-4afe82eedd6a', 4, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 4

Questions 1-6
Questions 1-6
Complete the summary below using the list of words, A-K, below
Write the correct letter, A-K, in boxes 1-6 on your answer sheet.
Provine's early findings on yawns
Through his observation of yawns, Province was able to confirm that
1
do not exist.
Just like a
2
, yawns cannot be interrupted after they have begun. This is because yawns occur as a
3
rather than a stimulus response as was previously thought.
In measuring the time taken to yawn, provive found that a typical yawn lasts about
4
.. He also found that it is a common for people to yawn a number of times in quick succession with the yawns usually being around
5
apart. When studying whether length and rate were
connected. Province concluded that people who yawn less do not necessarily produce
6
to make up for this.
A
form and function
B
long yawns
C
3 seconds
D
fixed action pattern
E
68 seconds
F
short yawns
G
reflex
H
sneeze
I
short duration
J
6 seconds
K
half-yawns

In measuring the time taken to yawn, provive found that a typical yawn lasts about 4 ____ .. He also found that it is a common for people to yawn a number of times in quick succession with the yawns usually being around 5 ____ apart. When studying whether length and rate were$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('166f6bcb-5160-54b9-a9fa-17de10da738c', 'd0b73344-0998-5ad7-8b94-98f060c30d14', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('60247672-c417-507b-a31e-49ea26ed6b97', 'd0b73344-0998-5ad7-8b94-98f060c30d14', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ded8a61f-f83c-5750-b931-ac5a1a4723e8', 'd0b73344-0998-5ad7-8b94-98f060c30d14', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('16eaafba-4d01-59f8-80ec-83b3c6defb05', 'd0b73344-0998-5ad7-8b94-98f060c30d14', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8a19b1a8-f28f-5999-a40d-d70a8e9ad2be', 'd0b73344-0998-5ad7-8b94-98f060c30d14', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8610640d-4e2c-5513-8c5f-d6a2866f451a', 'd0b73344-0998-5ad7-8b94-98f060c30d14', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b01a019d-4ed9-51c7-9f81-524add7b1846', 'd0b73344-0998-5ad7-8b94-98f060c30d14', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('55e8ac66-db1a-5052-8c2e-61c7c175ee19', 'd0b73344-0998-5ad7-8b94-98f060c30d14', 8, $md$H$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a68c2f9e-52af-537e-a642-e69fe50f2536', 'd0b73344-0998-5ad7-8b94-98f060c30d14', 9, $md$I$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('14c79555-3fbc-52e1-8295-f5d1ee08ad7c', 'd0b73344-0998-5ad7-8b94-98f060c30d14', 10, $md$J$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('70488d28-9caa-5c2b-808c-164754643fc8', 'd0b73344-0998-5ad7-8b94-98f060c30d14', 11, $md$K$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('72571f2f-2015-56d9-9847-774cc183aced', '6df73ee8-545c-515b-ab4a-4afe82eedd6a', 5, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 5

Questions 1-6
Questions 1-6
Complete the summary below using the list of words, A-K, below
Write the correct letter, A-K, in boxes 1-6 on your answer sheet.
Provine's early findings on yawns
Through his observation of yawns, Province was able to confirm that
1
do not exist.
Just like a
2
, yawns cannot be interrupted after they have begun. This is because yawns occur as a
3
rather than a stimulus response as was previously thought.
In measuring the time taken to yawn, provive found that a typical yawn lasts about
4
.. He also found that it is a common for people to yawn a number of times in quick succession with the yawns usually being around
5
apart. When studying whether length and rate were
connected. Province concluded that people who yawn less do not necessarily produce
6
to make up for this.
A
form and function
B
long yawns
C
3 seconds
D
fixed action pattern
E
68 seconds
F
short yawns
G
reflex
H
sneeze
I
short duration
J
6 seconds
K
half-yawns

In measuring the time taken to yawn, provive found that a typical yawn lasts about 4 ____ .. He also found that it is a common for people to yawn a number of times in quick succession with the yawns usually being around 5 ____ apart. When studying whether length and rate were$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fd85bf49-c132-58a1-bce9-eb3a5d2b4f72', '72571f2f-2015-56d9-9847-774cc183aced', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('12ac8261-7a89-5eec-9064-a2ad0d6887ee', '72571f2f-2015-56d9-9847-774cc183aced', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('04b4c16c-14a1-55da-b72e-6e1780f0bbcc', '72571f2f-2015-56d9-9847-774cc183aced', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('90fea030-87ba-58aa-b37a-585a50bb6ef9', '72571f2f-2015-56d9-9847-774cc183aced', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d9dec340-5728-5df0-afb4-fa8465a34145', '72571f2f-2015-56d9-9847-774cc183aced', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f6d9e789-b107-5f59-9a0e-a61569447e81', '72571f2f-2015-56d9-9847-774cc183aced', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('76c135b1-8e52-5399-9266-dd794d1c8147', '72571f2f-2015-56d9-9847-774cc183aced', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('492a7f82-f5ee-5102-9350-e39f3e21df8d', '72571f2f-2015-56d9-9847-774cc183aced', 8, $md$H$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a6eec31c-2c1d-546c-ab4d-b6a994917d80', '72571f2f-2015-56d9-9847-774cc183aced', 9, $md$I$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2b00339e-0480-5bf8-8232-05e30bb4758d', '72571f2f-2015-56d9-9847-774cc183aced', 10, $md$J$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f3027c19-c96c-5feb-83cc-9dabf856a5ee', '72571f2f-2015-56d9-9847-774cc183aced', 11, $md$K$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('fba0e9c4-1f47-54aa-989c-7ff23b508697', '6df73ee8-545c-515b-ab4a-4afe82eedd6a', 6, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 6

Questions 1-6
Questions 1-6
Complete the summary below using the list of words, A-K, below
Write the correct letter, A-K, in boxes 1-6 on your answer sheet.
Provine's early findings on yawns
Through his observation of yawns, Province was able to confirm that
1
do not exist.
Just like a
2
, yawns cannot be interrupted after they have begun. This is because yawns occur as a
3
rather than a stimulus response as was previously thought.
In measuring the time taken to yawn, provive found that a typical yawn lasts about
4
.. He also found that it is a common for people to yawn a number of times in quick succession with the yawns usually being around
5
apart. When studying whether length and rate were
connected. Province concluded that people who yawn less do not necessarily produce
6
to make up for this.
A
form and function
B
long yawns
C
3 seconds
D
fixed action pattern
E
68 seconds
F
short yawns
G
reflex
H
sneeze
I
short duration
J
6 seconds
K
half-yawns

connected. Province concluded that people who yawn less do not necessarily produce 6 ____ to make up for this.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('50ac56dd-db59-586a-a0e2-eadf8152a61c', 'fba0e9c4-1f47-54aa-989c-7ff23b508697', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('28af10f0-392e-554d-9bd0-b5647f10ed61', 'fba0e9c4-1f47-54aa-989c-7ff23b508697', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('69f4571d-e0d7-56c6-8814-9bd2aa471ae8', 'fba0e9c4-1f47-54aa-989c-7ff23b508697', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c75b98f0-1599-54fa-b02a-7b207107b05e', 'fba0e9c4-1f47-54aa-989c-7ff23b508697', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('50006662-6750-598c-b17d-7d1355f15172', 'fba0e9c4-1f47-54aa-989c-7ff23b508697', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('31405f3d-c3e8-5a61-b98c-1a2618f2ffeb', 'fba0e9c4-1f47-54aa-989c-7ff23b508697', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f38c7d44-3c68-50a8-8a3b-cdf6783ea2bd', 'fba0e9c4-1f47-54aa-989c-7ff23b508697', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e59bc358-f157-5114-9d5f-01c5dcdb93ab', 'fba0e9c4-1f47-54aa-989c-7ff23b508697', 8, $md$H$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f2877d4b-5720-5b2d-939c-ca034a6fb6b4', 'fba0e9c4-1f47-54aa-989c-7ff23b508697', 9, $md$I$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4a02acc6-fcec-5025-9ecf-c7862b3467ab', 'fba0e9c4-1f47-54aa-989c-7ff23b508697', 10, $md$J$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2b51978f-5751-5f52-a778-032ba059df56', 'fba0e9c4-1f47-54aa-989c-7ff23b508697', 11, $md$K$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('1f0f12d1-b2d7-5c3e-95eb-a38b3d796c61', '6df73ee8-545c-515b-ab4a-4afe82eedd6a', 7, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 7

Questions 7-11
Questions 7-11
Choose the correct letter, A
, B, C
or
D.
Write the correct letter in boxes 7-11 on your answer sheet.
7. What did Provine conclude from his 'closed nose yawn1 experiment?
A
Ending a yawn requires use of the nostrils.
B
You can yawn without breathing through your nose
C
Breathing through the nose produces a silent yawn.
D
The role of the nose in yawning needs further investigation.
8. Provine's clenched teeth yawn's experiment shows that
A
yawning is unconnected with fatigue.
B
a yawn is the equivalent of a deep intake of breath.
C
you have to be able to open your mouth wide to yawn.
D
breathing with the teeth together is as efficient as through the nose.
9. The nose yawn experiment was used to test weather yawning
A
can be stopped after it has stated
B
is the result of motor programing
C
involves both inhalation and exhalation.
D
can be accomplished only through the nose.
10. In people paralyzed on one side because of brain damage
A
yawning may involve only one side of the face.
B
the yawing response indicates that recovery is likely
C
movement in paralysed arm is stimulated by yawming
D
yawning can be used as an example to prevent muscle wasting.
11. In the last paragraph, the writer concludes that
A
yawning is a sign of boredom.
B
we yawn is spite of the development of our species
C
yawning is a more passive activity than we Imagine
D
we are stimulated to yawn when our brain activity is low.

Choose the correct letter, A , B, C or D.$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('05a607ff-5d75-5e77-bd0a-4cdf1c1c4bed', '6df73ee8-545c-515b-ab4a-4afe82eedd6a', 8, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 8

Questions 7-11
Questions 7-11
Choose the correct letter, A
, B, C
or
D.
Write the correct letter in boxes 7-11 on your answer sheet.
7. What did Provine conclude from his 'closed nose yawn1 experiment?
A
Ending a yawn requires use of the nostrils.
B
You can yawn without breathing through your nose
C
Breathing through the nose produces a silent yawn.
D
The role of the nose in yawning needs further investigation.
8. Provine's clenched teeth yawn's experiment shows that
A
yawning is unconnected with fatigue.
B
a yawn is the equivalent of a deep intake of breath.
C
you have to be able to open your mouth wide to yawn.
D
breathing with the teeth together is as efficient as through the nose.
9. The nose yawn experiment was used to test weather yawning
A
can be stopped after it has stated
B
is the result of motor programing
C
involves both inhalation and exhalation.
D
can be accomplished only through the nose.
10. In people paralyzed on one side because of brain damage
A
yawning may involve only one side of the face.
B
the yawing response indicates that recovery is likely
C
movement in paralysed arm is stimulated by yawming
D
yawning can be used as an example to prevent muscle wasting.
11. In the last paragraph, the writer concludes that
A
yawning is a sign of boredom.
B
we yawn is spite of the development of our species
C
yawning is a more passive activity than we Imagine
D
we are stimulated to yawn when our brain activity is low.

Choose the correct letter, A , B, C or D.$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('af2f55b9-9b67-5727-a288-6063dabd940b', '6df73ee8-545c-515b-ab4a-4afe82eedd6a', 9, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 9

Questions 7-11
Questions 7-11
Choose the correct letter, A
, B, C
or
D.
Write the correct letter in boxes 7-11 on your answer sheet.
7. What did Provine conclude from his 'closed nose yawn1 experiment?
A
Ending a yawn requires use of the nostrils.
B
You can yawn without breathing through your nose
C
Breathing through the nose produces a silent yawn.
D
The role of the nose in yawning needs further investigation.
8. Provine's clenched teeth yawn's experiment shows that
A
yawning is unconnected with fatigue.
B
a yawn is the equivalent of a deep intake of breath.
C
you have to be able to open your mouth wide to yawn.
D
breathing with the teeth together is as efficient as through the nose.
9. The nose yawn experiment was used to test weather yawning
A
can be stopped after it has stated
B
is the result of motor programing
C
involves both inhalation and exhalation.
D
can be accomplished only through the nose.
10. In people paralyzed on one side because of brain damage
A
yawning may involve only one side of the face.
B
the yawing response indicates that recovery is likely
C
movement in paralysed arm is stimulated by yawming
D
yawning can be used as an example to prevent muscle wasting.
11. In the last paragraph, the writer concludes that
A
yawning is a sign of boredom.
B
we yawn is spite of the development of our species
C
yawning is a more passive activity than we Imagine
D
we are stimulated to yawn when our brain activity is low.

Choose the correct letter, A , B, C or D.$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('d3da7072-c450-5c5a-9ea7-320eadc0a1a3', '6df73ee8-545c-515b-ab4a-4afe82eedd6a', 10, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 10

Questions 7-11
Questions 7-11
Choose the correct letter, A
, B, C
or
D.
Write the correct letter in boxes 7-11 on your answer sheet.
7. What did Provine conclude from his 'closed nose yawn1 experiment?
A
Ending a yawn requires use of the nostrils.
B
You can yawn without breathing through your nose
C
Breathing through the nose produces a silent yawn.
D
The role of the nose in yawning needs further investigation.
8. Provine's clenched teeth yawn's experiment shows that
A
yawning is unconnected with fatigue.
B
a yawn is the equivalent of a deep intake of breath.
C
you have to be able to open your mouth wide to yawn.
D
breathing with the teeth together is as efficient as through the nose.
9. The nose yawn experiment was used to test weather yawning
A
can be stopped after it has stated
B
is the result of motor programing
C
involves both inhalation and exhalation.
D
can be accomplished only through the nose.
10. In people paralyzed on one side because of brain damage
A
yawning may involve only one side of the face.
B
the yawing response indicates that recovery is likely
C
movement in paralysed arm is stimulated by yawming
D
yawning can be used as an example to prevent muscle wasting.
11. In the last paragraph, the writer concludes that
A
yawning is a sign of boredom.
B
we yawn is spite of the development of our species
C
yawning is a more passive activity than we Imagine
D
we are stimulated to yawn when our brain activity is low.

Choose the correct letter, A , B, C or D.$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('7ab94c82-d53a-5aaf-924f-51d2a4853df5', '6df73ee8-545c-515b-ab4a-4afe82eedd6a', 11, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 11

Questions 7-11
Questions 7-11
Choose the correct letter, A
, B, C
or
D.
Write the correct letter in boxes 7-11 on your answer sheet.
7. What did Provine conclude from his 'closed nose yawn1 experiment?
A
Ending a yawn requires use of the nostrils.
B
You can yawn without breathing through your nose
C
Breathing through the nose produces a silent yawn.
D
The role of the nose in yawning needs further investigation.
8. Provine's clenched teeth yawn's experiment shows that
A
yawning is unconnected with fatigue.
B
a yawn is the equivalent of a deep intake of breath.
C
you have to be able to open your mouth wide to yawn.
D
breathing with the teeth together is as efficient as through the nose.
9. The nose yawn experiment was used to test weather yawning
A
can be stopped after it has stated
B
is the result of motor programing
C
involves both inhalation and exhalation.
D
can be accomplished only through the nose.
10. In people paralyzed on one side because of brain damage
A
yawning may involve only one side of the face.
B
the yawing response indicates that recovery is likely
C
movement in paralysed arm is stimulated by yawming
D
yawning can be used as an example to prevent muscle wasting.
11. In the last paragraph, the writer concludes that
A
yawning is a sign of boredom.
B
we yawn is spite of the development of our species
C
yawning is a more passive activity than we Imagine
D
we are stimulated to yawn when our brain activity is low.

Choose the correct letter, A , B, C or D.$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('2b453b8c-cdd2-5e27-8624-47a53d7156a5', '6df73ee8-545c-515b-ab4a-4afe82eedd6a', 12, 'YES_NO_NOT_GIVEN', 'READING', 4, $md$### Question 12

Questions 12-14
Questions 12-14
Questions 12-14
Do the following statements agree with the claims of the writer in Reading Passage?
In boxes
12-14
on your answer sheet, write
YES
if the statement agrees with the views of the writer
NO
if the statement contradicts the views of the writer
NOT GIVEN if it is impossible to say what the writer thinks about this
12
Research students were initially reluctant to appreciate the value of Provine's studies.
13
When foetuses yawn and stretch they are learning how to control movement.
14
According to Provine, referring to only one function is probably inadequate to explain why people yawn.

12 ____ Research students were initially reluctant to appreciate the value of Provine's studies.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7230be22-3afe-588f-9610-40ff9b2dc3e0', '2b453b8c-cdd2-5e27-8624-47a53d7156a5', 1, $md$YES$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d791d6b1-5ef0-52e8-92ba-b22c661cb80c', '2b453b8c-cdd2-5e27-8624-47a53d7156a5', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e60095ff-9195-5c3c-895f-882ce837c856', '2b453b8c-cdd2-5e27-8624-47a53d7156a5', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('a73701af-b4c2-521a-a5a6-17702cbf2f8c', '6df73ee8-545c-515b-ab4a-4afe82eedd6a', 13, 'YES_NO_NOT_GIVEN', 'READING', 4, $md$### Question 13

Questions 12-14
Questions 12-14
Questions 12-14
Do the following statements agree with the claims of the writer in Reading Passage?
In boxes
12-14
on your answer sheet, write
YES
if the statement agrees with the views of the writer
NO
if the statement contradicts the views of the writer
NOT GIVEN if it is impossible to say what the writer thinks about this
12
Research students were initially reluctant to appreciate the value of Provine's studies.
13
When foetuses yawn and stretch they are learning how to control movement.
14
According to Provine, referring to only one function is probably inadequate to explain why people yawn.

13 ____ When foetuses yawn and stretch they are learning how to control movement.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('244a4ce5-19c4-5e38-a847-f40dbe35d8f6', 'a73701af-b4c2-521a-a5a6-17702cbf2f8c', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('13868e03-ee1c-5804-afe5-834ba0a4f07f', 'a73701af-b4c2-521a-a5a6-17702cbf2f8c', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('419e4ae0-5056-5abe-8b0c-6c191571c83d', 'a73701af-b4c2-521a-a5a6-17702cbf2f8c', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('69e48485-6863-5aeb-8320-0d42ca767c6d', '6df73ee8-545c-515b-ab4a-4afe82eedd6a', 14, 'YES_NO_NOT_GIVEN', 'READING', 4, $md$### Question 14

Questions 12-14
Questions 12-14
Questions 12-14
Do the following statements agree with the claims of the writer in Reading Passage?
In boxes
12-14
on your answer sheet, write
YES
if the statement agrees with the views of the writer
NO
if the statement contradicts the views of the writer
NOT GIVEN if it is impossible to say what the writer thinks about this
12
Research students were initially reluctant to appreciate the value of Provine's studies.
13
When foetuses yawn and stretch they are learning how to control movement.
14
According to Provine, referring to only one function is probably inadequate to explain why people yawn.

14 ____ According to Provine, referring to only one function is probably inadequate to explain why people yawn.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('adc9d45d-20df-5d7a-862a-883f0acaa9f4', '69e48485-6863-5aeb-8320-0d42ca767c6d', 1, $md$YES$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a222ecaf-caf6-5d56-97f9-d6bfb54257cb', '69e48485-6863-5aeb-8320-0d42ca767c6d', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('eb001986-7438-5ca0-a407-936aed7b8c35', '69e48485-6863-5aeb-8320-0d42ca767c6d', 3, $md$NOT GIVEN$md$, false);

COMMIT;
