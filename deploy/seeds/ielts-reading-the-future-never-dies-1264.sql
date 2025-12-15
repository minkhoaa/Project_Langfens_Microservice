BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-the-future-never-dies-1264'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-the-future-never-dies-1264';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-the-future-never-dies-1264';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-the-future-never-dies-1264';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('edc9a92e-8635-50f8-9756-f4a9b6382d24', 'ielts-reading-the-future-never-dies-1264', $t$The future never dies?$t$, $md$## The future never dies?

Nguồn:
- Test: https://mini-ielts.com/1264/reading/the-future-never-dies
- Solution: https://mini-ielts.com/1264/view-solution/reading/the-future-never-dies$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('4d71f640-9934-5618-8e9d-857910e6d1fa', 'edc9a92e-8635-50f8-9756-f4a9b6382d24', 1, $t$Reading — The future never dies?$t$, $md$Read the passage and answer questions **1–13**.

### Passage: The future never dies?

The prospects for humanity and for the world as a whole are somewhere between glorious and dire. It is hard to be much more precise.

A

By ‘glorious’, I mean that our descendants – all who are born on to this Earth – could live very comfortably and securely, and could continue to do so for as long as the Earth can support life, which should be for a very long time indeed. We should at least be thinking in terms of the next million years. Furthermore, our descendants could continue to enjoy the company of other species – establishing a much better relationship with them than we have now. Other animals need not live in constant fear of us. Many of those fellow species now seem bound to become extinct, but a significant proportion could and should continue to live alongside us. Such a future may seem ideal, and so it is. Yet I do not believe it is fanciful. There is nothing in the physical fabric of the Earth or in our own biology to suggest that this is not possible.

B

‘Dire’ means that we human beings could be in deep trouble within the next few centuries, living but also dying in large numbers in political terror and from starvation, while huge numbers of our fellow creatures would simply disappear, leaving only the ones that we find convenient – chickens, cattle – or that we can’t shake off, like flies and mice. I’m taking it to be self-evident that glory is preferable.

C

Our future is not entirely in our own hands because the Earth has its own rules, is part of the solar system and is neither stable nor innately safe. Other planets in the solar system are quite beyond habitation, because their temperature is far too high or too low to be endured, and ours, too, in principle could tip either way. Even relatively unspectacular changes in the atmosphere could do the trick. The core of the Earth is hot, which in many ways is good for living creatures, but every now and again, the molten rock bursts through volcanoes on the surface. Among the biggest volcanic eruptions in recent memory was Mount St Helens, in the USA, which threw out a cubic kilometre of ash – fortunately, in an area where very few people live. In 1815, Tambora (in present-day Indonesia) expelled so much ash into the upper atmosphere that climatic effects seriously harmed food production around the world for the season after season. Entire civilisations have been destroyed by volcanoes.

D

Yet nothing we have so far experienced shows what volcanoes can really do. Yellowstone National Park in the USA occupies the caldera (the crater formed when a volcano collapses) of an exceedingly ancient volcano of extraordinary magnitude. Modem surveys show that its centre is now rising. Sometime in the next 200 million years, Yellowstone could erupt again, and when it does, the whole world will be transformed. Yellowstone could erupt tomorrow. But there’s a very good chance that it will give us another million years, and that surely is enough to be going on with. It seems sensible to assume that this will be the case.

E

The universe at large is dangerous, too: in particular, we share the sky with vast numbers of asteroids, and now and again, the come into our planet’s atmosphere. An asteroid the size of a small island, hitting the Earth at 15,000 kilometres an hour (a relatively modest speed by the standards of heavenly bodies), would strike the ocean bed like a rock in a puddle, send a tidal wave around the world as high as a small mountain and as fast as a jumbo jet, and propel us into an ice age that could last for centuries. There are plans to head off such disasters (including rockets to push approaching asteroids into new trajectories), but in truth, it’s down to luck.

F

On the other hand, the archaeological and the fossil evidence shows that no truly devastating asteroid has struck since the one that seems to have accounted for the extinction of the dinosaurs 65 million years ago. So again, there seems no immediate reason for despair. The Earth is indeed an uncertain place, in an uncertain universe, but with average luck, it should do us well enough. If the world does become inhospitable in the next few thousand or million years, then it will probably be our own fault. In short, despite the underlying uncertainty, our own future and that of our fellow creatures are very much in our own hands.

G

Given average luck on the geological and the cosmic scale, the difference between glory and disaster will be made and is being made, by politics. Certain kinds of political systems and strategies would predispose us to long-term survival (and indeed to comfort and security and pleasure of being alive), while others would take us more and more frenetically towards collapse. The broad point is, though, that we need to look at ourselves – humanity – and at the world in general in a quite new light. Our material problems are fundamentally those of biology. We need to think, and we need our politicians to think, biologically. Do that, and take the ideas seriously, and we are in with a chance. Ignore biology and we and our fellow creatures haven’t a hope.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('98d1b205-fe89-5524-813c-da23c80b9dc2', '4d71f640-9934-5618-8e9d-857910e6d1fa', 1, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 1

Questions 1-6
Questions 1-6
Do the following statements reflect the claims of the writer in Reading Passage?
In boxes
1-6
on your answer sheet write
YES
if the statement is true
NO
if the statement is false
NOT GIVEN
if the information is not given in the passage
1
It seems predictable that some species will disappear.
2
The nature of the Earth and human biology make it impossible for human beings to survive another million years.
3
An eruption by Yellowstone is likely to be more destructive than previous volcanic eruptions.
4
There is a greater chance of the Earth being hit by small asteroids than large ones.
5
If the world becomes uninhabitable, it is most likely to be as a result of a natural disaster.
6
Politicians currently in power seem unlikely to change their way of thinking.

1 ____ It seems predictable that some species will disappear.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('35b2a0f9-e32e-5ec6-8a03-b5f206b4c4c7', '98d1b205-fe89-5524-813c-da23c80b9dc2', 1, $md$YES$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a1962561-05f3-5a5c-acd1-c9986f4425cc', '98d1b205-fe89-5524-813c-da23c80b9dc2', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7e84d6eb-51ef-58f4-b6b8-5eb794e906e5', '98d1b205-fe89-5524-813c-da23c80b9dc2', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('7ad3fefa-d301-57d1-a79e-34873d3fe2d0', '4d71f640-9934-5618-8e9d-857910e6d1fa', 2, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 2

Questions 1-6
Questions 1-6
Do the following statements reflect the claims of the writer in Reading Passage?
In boxes
1-6
on your answer sheet write
YES
if the statement is true
NO
if the statement is false
NOT GIVEN
if the information is not given in the passage
1
It seems predictable that some species will disappear.
2
The nature of the Earth and human biology make it impossible for human beings to survive another million years.
3
An eruption by Yellowstone is likely to be more destructive than previous volcanic eruptions.
4
There is a greater chance of the Earth being hit by small asteroids than large ones.
5
If the world becomes uninhabitable, it is most likely to be as a result of a natural disaster.
6
Politicians currently in power seem unlikely to change their way of thinking.

2 ____ The nature of the Earth and human biology make it impossible for human beings to survive another million years.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('560aac30-beef-5547-a18d-c388eb9b3cbd', '7ad3fefa-d301-57d1-a79e-34873d3fe2d0', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('47d8a095-23b2-5a5a-ae40-5660fdcde649', '7ad3fefa-d301-57d1-a79e-34873d3fe2d0', 2, $md$NO$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('03ed585e-2d82-5c5c-b4cd-cef9f75c32aa', '7ad3fefa-d301-57d1-a79e-34873d3fe2d0', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('5801dff3-4bf3-567a-8cfd-0aae2086c1fb', '4d71f640-9934-5618-8e9d-857910e6d1fa', 3, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 3

Questions 1-6
Questions 1-6
Do the following statements reflect the claims of the writer in Reading Passage?
In boxes
1-6
on your answer sheet write
YES
if the statement is true
NO
if the statement is false
NOT GIVEN
if the information is not given in the passage
1
It seems predictable that some species will disappear.
2
The nature of the Earth and human biology make it impossible for human beings to survive another million years.
3
An eruption by Yellowstone is likely to be more destructive than previous volcanic eruptions.
4
There is a greater chance of the Earth being hit by small asteroids than large ones.
5
If the world becomes uninhabitable, it is most likely to be as a result of a natural disaster.
6
Politicians currently in power seem unlikely to change their way of thinking.

3 ____ An eruption by Yellowstone is likely to be more destructive than previous volcanic eruptions.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('57bea151-90ea-5a4c-860b-db7dd6b53178', '5801dff3-4bf3-567a-8cfd-0aae2086c1fb', 1, $md$YES$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f8a2bef9-49a4-599c-896e-7be25e502916', '5801dff3-4bf3-567a-8cfd-0aae2086c1fb', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('99920fe4-78bc-5870-a31b-7da93d74d657', '5801dff3-4bf3-567a-8cfd-0aae2086c1fb', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('e8f297d1-8c99-515e-b44f-fd885dc60137', '4d71f640-9934-5618-8e9d-857910e6d1fa', 4, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 4

Questions 1-6
Questions 1-6
Do the following statements reflect the claims of the writer in Reading Passage?
In boxes
1-6
on your answer sheet write
YES
if the statement is true
NO
if the statement is false
NOT GIVEN
if the information is not given in the passage
1
It seems predictable that some species will disappear.
2
The nature of the Earth and human biology make it impossible for human beings to survive another million years.
3
An eruption by Yellowstone is likely to be more destructive than previous volcanic eruptions.
4
There is a greater chance of the Earth being hit by small asteroids than large ones.
5
If the world becomes uninhabitable, it is most likely to be as a result of a natural disaster.
6
Politicians currently in power seem unlikely to change their way of thinking.

4 ____ There is a greater chance of the Earth being hit by small asteroids than large ones.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('aaac9def-614c-56ea-8d72-3aeb447f8fbe', 'e8f297d1-8c99-515e-b44f-fd885dc60137', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('469f5bbb-5372-5a6a-9be9-675fa07b835f', 'e8f297d1-8c99-515e-b44f-fd885dc60137', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ed15bd0e-c2a4-5f73-8a21-305d5e3b42f1', 'e8f297d1-8c99-515e-b44f-fd885dc60137', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('307e6897-960b-5af6-853e-8e08884fa801', '4d71f640-9934-5618-8e9d-857910e6d1fa', 5, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 5

Questions 1-6
Questions 1-6
Do the following statements reflect the claims of the writer in Reading Passage?
In boxes
1-6
on your answer sheet write
YES
if the statement is true
NO
if the statement is false
NOT GIVEN
if the information is not given in the passage
1
It seems predictable that some species will disappear.
2
The nature of the Earth and human biology make it impossible for human beings to survive another million years.
3
An eruption by Yellowstone is likely to be more destructive than previous volcanic eruptions.
4
There is a greater chance of the Earth being hit by small asteroids than large ones.
5
If the world becomes uninhabitable, it is most likely to be as a result of a natural disaster.
6
Politicians currently in power seem unlikely to change their way of thinking.

5 ____ If the world becomes uninhabitable, it is most likely to be as a result of a natural disaster.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ca92efef-0096-5146-b9b9-5d1d523f35ed', '307e6897-960b-5af6-853e-8e08884fa801', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d4c5e40b-6011-5304-818a-d554e47b1d96', '307e6897-960b-5af6-853e-8e08884fa801', 2, $md$NO$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a674f72e-6334-5ebd-a558-aba45b9b71e2', '307e6897-960b-5af6-853e-8e08884fa801', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('5dbc6f3d-53c2-5a55-9dc1-897f46fba279', '4d71f640-9934-5618-8e9d-857910e6d1fa', 6, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 6

Questions 1-6
Questions 1-6
Do the following statements reflect the claims of the writer in Reading Passage?
In boxes
1-6
on your answer sheet write
YES
if the statement is true
NO
if the statement is false
NOT GIVEN
if the information is not given in the passage
1
It seems predictable that some species will disappear.
2
The nature of the Earth and human biology make it impossible for human beings to survive another million years.
3
An eruption by Yellowstone is likely to be more destructive than previous volcanic eruptions.
4
There is a greater chance of the Earth being hit by small asteroids than large ones.
5
If the world becomes uninhabitable, it is most likely to be as a result of a natural disaster.
6
Politicians currently in power seem unlikely to change their way of thinking.

6 ____ Politicians currently in power seem unlikely to change their way of thinking.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('654b5239-5062-5efe-be84-d872393fa9f9', '5dbc6f3d-53c2-5a55-9dc1-897f46fba279', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f1530dea-4905-55b9-824b-0702a4b1b78d', '5dbc6f3d-53c2-5a55-9dc1-897f46fba279', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('092fac99-039d-5865-9dcd-4236ad884ce6', '5dbc6f3d-53c2-5a55-9dc1-897f46fba279', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('5f291f40-911d-5123-b08c-f200c52d49ec', '4d71f640-9934-5618-8e9d-857910e6d1fa', 7, 'TABLE_COMPLETION', 'READING', 3, $md$### Question 7

Question 7-12
Question 7-12
Complete the summary below.
Choose
NO MORE THAN TWO WORDS
from the passage for each answer.
Write your answers in boxes
7-12
on your answer sheet.
The Earth could become uninhabitable, like other planets, through a major change in the
7
. Volcanic eruptions of
8
can lead to shortages of
9
in a wide area. An asteroid hitting the Earth could create a
10
that would result in a new
11
. Plans are being made to use
12
to deflect asteroids heading for the Earth.

The Earth could become uninhabitable, like other planets, through a major change in the 7 ____ . Volcanic eruptions of 8 ____ can lead to shortages of 9 ____ in a wide area. An asteroid hitting the Earth could create a 10 ____ that would result in a new 11 ____ . Plans are being made to use 12 ____ to deflect asteroids heading for the Earth.$md$, NULL, ARRAY['.*temperature.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('628836cf-ab12-59f9-87cc-7de3be4d7351', '4d71f640-9934-5618-8e9d-857910e6d1fa', 8, 'TABLE_COMPLETION', 'READING', 3, $md$### Question 8

Question 7-12
Question 7-12
Complete the summary below.
Choose
NO MORE THAN TWO WORDS
from the passage for each answer.
Write your answers in boxes
7-12
on your answer sheet.
The Earth could become uninhabitable, like other planets, through a major change in the
7
. Volcanic eruptions of
8
can lead to shortages of
9
in a wide area. An asteroid hitting the Earth could create a
10
that would result in a new
11
. Plans are being made to use
12
to deflect asteroids heading for the Earth.

The Earth could become uninhabitable, like other planets, through a major change in the 7 ____ . Volcanic eruptions of 8 ____ can lead to shortages of 9 ____ in a wide area. An asteroid hitting the Earth could create a 10 ____ that would result in a new 11 ____ . Plans are being made to use 12 ____ to deflect asteroids heading for the Earth.$md$, NULL, ARRAY['.*temperature.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('327061dd-e14e-5c56-9791-3fe89ca95ff5', '4d71f640-9934-5618-8e9d-857910e6d1fa', 9, 'TABLE_COMPLETION', 'READING', 3, $md$### Question 9

Question 7-12
Question 7-12
Complete the summary below.
Choose
NO MORE THAN TWO WORDS
from the passage for each answer.
Write your answers in boxes
7-12
on your answer sheet.
The Earth could become uninhabitable, like other planets, through a major change in the
7
. Volcanic eruptions of
8
can lead to shortages of
9
in a wide area. An asteroid hitting the Earth could create a
10
that would result in a new
11
. Plans are being made to use
12
to deflect asteroids heading for the Earth.

The Earth could become uninhabitable, like other planets, through a major change in the 7 ____ . Volcanic eruptions of 8 ____ can lead to shortages of 9 ____ in a wide area. An asteroid hitting the Earth could create a 10 ____ that would result in a new 11 ____ . Plans are being made to use 12 ____ to deflect asteroids heading for the Earth.$md$, NULL, ARRAY['.*temperature.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('cccd096d-5efc-55aa-854d-e091178c8b10', '4d71f640-9934-5618-8e9d-857910e6d1fa', 10, 'TABLE_COMPLETION', 'READING', 4, $md$### Question 10

Question 7-12
Question 7-12
Complete the summary below.
Choose
NO MORE THAN TWO WORDS
from the passage for each answer.
Write your answers in boxes
7-12
on your answer sheet.
The Earth could become uninhabitable, like other planets, through a major change in the
7
. Volcanic eruptions of
8
can lead to shortages of
9
in a wide area. An asteroid hitting the Earth could create a
10
that would result in a new
11
. Plans are being made to use
12
to deflect asteroids heading for the Earth.

The Earth could become uninhabitable, like other planets, through a major change in the 7 ____ . Volcanic eruptions of 8 ____ can lead to shortages of 9 ____ in a wide area. An asteroid hitting the Earth could create a 10 ____ that would result in a new 11 ____ . Plans are being made to use 12 ____ to deflect asteroids heading for the Earth.$md$, NULL, ARRAY['.*temperature.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('6d4f3dbf-22d6-500c-ab88-122da68a4ca7', '4d71f640-9934-5618-8e9d-857910e6d1fa', 11, 'TABLE_COMPLETION', 'READING', 4, $md$### Question 11

Question 7-12
Question 7-12
Complete the summary below.
Choose
NO MORE THAN TWO WORDS
from the passage for each answer.
Write your answers in boxes
7-12
on your answer sheet.
The Earth could become uninhabitable, like other planets, through a major change in the
7
. Volcanic eruptions of
8
can lead to shortages of
9
in a wide area. An asteroid hitting the Earth could create a
10
that would result in a new
11
. Plans are being made to use
12
to deflect asteroids heading for the Earth.

The Earth could become uninhabitable, like other planets, through a major change in the 7 ____ . Volcanic eruptions of 8 ____ can lead to shortages of 9 ____ in a wide area. An asteroid hitting the Earth could create a 10 ____ that would result in a new 11 ____ . Plans are being made to use 12 ____ to deflect asteroids heading for the Earth.$md$, NULL, ARRAY['.*temperature.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('0c8e2efc-471b-5da4-a92f-16ed64e33966', '4d71f640-9934-5618-8e9d-857910e6d1fa', 12, 'TABLE_COMPLETION', 'READING', 4, $md$### Question 12

Question 7-12
Question 7-12
Complete the summary below.
Choose
NO MORE THAN TWO WORDS
from the passage for each answer.
Write your answers in boxes
7-12
on your answer sheet.
The Earth could become uninhabitable, like other planets, through a major change in the
7
. Volcanic eruptions of
8
can lead to shortages of
9
in a wide area. An asteroid hitting the Earth could create a
10
that would result in a new
11
. Plans are being made to use
12
to deflect asteroids heading for the Earth.

The Earth could become uninhabitable, like other planets, through a major change in the 7 ____ . Volcanic eruptions of 8 ____ can lead to shortages of 9 ____ in a wide area. An asteroid hitting the Earth could create a 10 ____ that would result in a new 11 ____ . Plans are being made to use 12 ____ to deflect asteroids heading for the Earth.$md$, NULL, ARRAY['.*temperature.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('b991a340-f493-5e5e-94ca-1edba0e3458a', '4d71f640-9934-5618-8e9d-857910e6d1fa', 13, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 13

Question 13
Question 13
Choose the correct letter
A
,
B
,
C
or
D
.
Write your answer in box
26
on your answer sheet.
26 What is the writer’s purpose in Reading Passage 2?
A
to propose a new theory about the causes of natural disasters
B
to prove that generally held beliefs about the future are all mistaken
C
to present a range of opinions currently held by scientists
D
to argue the need for a general change in behavior

Choose the correct letter A , B , C or D . Write your answer in box 26 on your answer sheet.$md$, NULL);

COMMIT;
