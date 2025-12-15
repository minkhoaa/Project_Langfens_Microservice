BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-the-sense-of-flavour-2-1489'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-the-sense-of-flavour-2-1489';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-the-sense-of-flavour-2-1489';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-the-sense-of-flavour-2-1489';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('36e020a3-8346-578d-af3f-269dd783fd20', 'ielts-reading-the-sense-of-flavour-2-1489', $t$The sense of flavour 2$t$, $md$## The sense of flavour 2

Nguồn:
- Test: https://mini-ielts.com/1489/reading/the-sense-of-flavour-2
- Solution: https://mini-ielts.com/1489/view-solution/reading/the-sense-of-flavour-2$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('78409809-bdf9-5166-9770-56950c8a55af', '36e020a3-8346-578d-af3f-269dd783fd20', 1, $t$Reading — The sense of flavour 2$t$, $md$Read the passage and answer questions **1–13**.

### Passage: The sense of flavour 2

{A} Scientists now believe that human beings acquired the sense of taste as a way to avoid being poisoned. Edible plants generally taste sweet; deadly ones, bitter. Taste is supposed to help us differentiate food that’s good for us from food that’s not. The taste buds on our tongues can detect the presence of half a dozen or so basic tastes, including sweet, sour, bitter, salty, and umami (a taste discovered by Japanese researchers , a rich and full sense of deliciousness triggered by amino acids in foods such as shellfish, mushrooms, potatoes, and seaweed). Tastebuds offers a limited means of detection, however, compared with the human olfactory system, which can perceive thousands of different chemical aromas. Indeed, ‘flavor’ is primarily the smell of gases being released by the chemicals you’ve just put in your mouth. The aroma of food can be responsible for as much as 90% of its flavor.

{B} The act of drinking, sucking or chewing a substance releases its volatile gases. They flow out of the mouth and up the nostrils, or up the passageway at the back of the mouth, to a thin layer of nerve cells called the olfactory epithelium, located at the base of the nose, right between the eyes. The brain combines the complex smell signals from the epithelium with the simple taste signals from the tongue, assigns a flavor to what’s in your mouth, and decides if it’s something you want to eat.

{C} Babies like sweet tastes and reject bitter ones; we know this because scientists have rubbed various flavors inside the mouths of infants and then recorded their facial reactions. A person’s food preferences, like his or her personality, are formed during the first few years of life, through a process of socialization. Toddlers can learn to enjoy hot and spicy food, bland health food, or fast food, depending upon what the people around them eat. The human sense of smell is still not fully understood. It is greatly affected by psychological factors and expectations. The mind filters out the overwhelming majority of chemical aromas that surround us, focusing intently on some, ignoring others. People can grow accustomed to bad smells or good smells; they stop noticing what once seemed overpowering.

{D} Aroma and memory are somehow inextricably linked. A smell can suddenly evoke a long-forgotten moment. The flavours of childhood foods seem to leave an indelible mark, and adults often return to them, without always knowing why. These ‘comfort foods’ become a source of pleasure and reassurance a fact that fast-food chains work hard to promote Childhood memories of Happy Meals can translate into frequent adult visits to McDonald’s’, like those of the chain’s ‘heavy users’, the customers who eat there four or five times a week.

{E} The human craving for flavour has been a large unacknowledged and unexamined force in history. Royal empires have been built, unexplored lands have been traversed, great religions and philosophies have been forever changed by the spice trade. In 1492, Christopher Columbus set sail in order to try to find new seasonings and thus to make his fortune with this most desired commodity of that time. Today, the influence of flavour in the world marketplace is no less decisive. The rise and fall of corporate empires – soft-drink companies, snack-food companies, and fast-food chains – is frequently determined by how their products taste.

{F} The flavor industry emerged in the mid-1800s, as processed foods began to be manufactured on a large scale. Recognizing the need for flavor additives, the early food processors turned to perfume companies that had years of experience working with essential oils and volatile aromas. The great perfume houses of England, France, and the Netherlands produced many of the first flavor compounds. In the early part of the 20th century, Germany’s powerful chemical industry assumed the lead in flavour production. Legend has it that a German scientist discovered methyl anthranilate, one of the first artificial flavours, by accident while mixing chemicals in his laboratory. Suddenly, the lab was filled with the sweet smell of grapes. Methyl anthranilate later became the chief flavoring compound of manufactured grape juice.

{G} The quality that people seek most of all in a food, its flavour, is usually present in a quantity too infinitesimal to be measured by any traditional culinary terms such as ounces or teaspoons. Today’s sophisticated spectrometers, gas chromatograph, and headspace vapor analyzers provide a detailed map of a food’s flavour components, detecting chemical aromas in amounts as low as one part per billion. The human nose, however, is still more sensitive than any machine yet invented. A nose can detect aromas present in quantities of a few parts per trillion. Complex aromas, such as those of coffee or roasted meat, may be composed of gases from nearly a thousand different chemicals. The chemical that provides the dominant flavour of bell pepper can be tasted in amounts as low as 0.02 parts per billion; one drop is sufficient to add flavour to the amount of water needed to fill five average-sized swimming pools$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('7ad43c5b-9181-586a-96a6-98316018a1bc', '78409809-bdf9-5166-9770-56950c8a55af', 1, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 1

Questions 1-5
Questions 1-5
Do the following statements agree with the information given in The Passage?
In boxes 1 – 5 on the answer sheet write
TRUE
if the statement is True
FALSE
if the statement is false
NOT GIVEN
If the information is not given in the passage
1
The brain determines which aromas we are aware of.
2
The sense of taste is as efficient as the sense of smell.
3
Personal tastes in food are developed in infancy.
4
Christopher Columbus found many different spices on his travels.
5
In the mid-1880s, man-made flavors were originally invented on purpose.

1 ____ The brain determines which aromas we are aware of.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2b6ce903-f1e7-53cb-aa08-6b6e0fbb9164', '7ad43c5b-9181-586a-96a6-98316018a1bc', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8de44ea3-e189-5429-b9d9-946e2690854d', '7ad43c5b-9181-586a-96a6-98316018a1bc', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0441591d-137e-55c5-af2d-7cc2609a509b', '7ad43c5b-9181-586a-96a6-98316018a1bc', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('fddfef17-8edc-543b-bed1-69373340dd68', '78409809-bdf9-5166-9770-56950c8a55af', 2, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 2

Questions 1-5
Questions 1-5
Do the following statements agree with the information given in The Passage?
In boxes 1 – 5 on the answer sheet write
TRUE
if the statement is True
FALSE
if the statement is false
NOT GIVEN
If the information is not given in the passage
1
The brain determines which aromas we are aware of.
2
The sense of taste is as efficient as the sense of smell.
3
Personal tastes in food are developed in infancy.
4
Christopher Columbus found many different spices on his travels.
5
In the mid-1880s, man-made flavors were originally invented on purpose.

2 ____ The sense of taste is as efficient as the sense of smell.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('33e2b258-3659-53bb-a213-958c02b070d4', 'fddfef17-8edc-543b-bed1-69373340dd68', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b1ae6048-d061-5a52-9a3b-c7ac33424a2d', 'fddfef17-8edc-543b-bed1-69373340dd68', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b4223cf7-6715-5785-a950-cf4ae01f0d9d', 'fddfef17-8edc-543b-bed1-69373340dd68', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('c664544f-2a60-5196-82fa-f1472ed8547b', '78409809-bdf9-5166-9770-56950c8a55af', 3, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 3

Questions 1-5
Questions 1-5
Do the following statements agree with the information given in The Passage?
In boxes 1 – 5 on the answer sheet write
TRUE
if the statement is True
FALSE
if the statement is false
NOT GIVEN
If the information is not given in the passage
1
The brain determines which aromas we are aware of.
2
The sense of taste is as efficient as the sense of smell.
3
Personal tastes in food are developed in infancy.
4
Christopher Columbus found many different spices on his travels.
5
In the mid-1880s, man-made flavors were originally invented on purpose.

3 ____ Personal tastes in food are developed in infancy.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c1c6d416-6221-5c20-89bd-86c158ecf6b9', 'c664544f-2a60-5196-82fa-f1472ed8547b', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c30b7f1c-982e-5f64-bf2c-06d737a396bc', 'c664544f-2a60-5196-82fa-f1472ed8547b', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('96a70796-e26e-5f76-aef6-32d97965cc0e', 'c664544f-2a60-5196-82fa-f1472ed8547b', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('9bb45f70-dcb2-55fc-912a-d45115ccd7cd', '78409809-bdf9-5166-9770-56950c8a55af', 4, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 4

Questions 1-5
Questions 1-5
Do the following statements agree with the information given in The Passage?
In boxes 1 – 5 on the answer sheet write
TRUE
if the statement is True
FALSE
if the statement is false
NOT GIVEN
If the information is not given in the passage
1
The brain determines which aromas we are aware of.
2
The sense of taste is as efficient as the sense of smell.
3
Personal tastes in food are developed in infancy.
4
Christopher Columbus found many different spices on his travels.
5
In the mid-1880s, man-made flavors were originally invented on purpose.

4 ____ Christopher Columbus found many different spices on his travels.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f5d5a435-bef1-596d-9d96-c7d5706b10bd', '9bb45f70-dcb2-55fc-912a-d45115ccd7cd', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('993ce350-ff30-5e96-9d84-fb4ea678a124', '9bb45f70-dcb2-55fc-912a-d45115ccd7cd', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fb46f61f-b8d7-53d3-8cb7-2d02491b1066', '9bb45f70-dcb2-55fc-912a-d45115ccd7cd', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('19daca0d-21f7-50df-aedc-282e39cc5569', '78409809-bdf9-5166-9770-56950c8a55af', 5, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 5

Questions 1-5
Questions 1-5
Do the following statements agree with the information given in The Passage?
In boxes 1 – 5 on the answer sheet write
TRUE
if the statement is True
FALSE
if the statement is false
NOT GIVEN
If the information is not given in the passage
1
The brain determines which aromas we are aware of.
2
The sense of taste is as efficient as the sense of smell.
3
Personal tastes in food are developed in infancy.
4
Christopher Columbus found many different spices on his travels.
5
In the mid-1880s, man-made flavors were originally invented on purpose.

5 ____ In the mid-1880s, man-made flavors were originally invented on purpose.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b99be693-6041-5a55-a993-319c994f4b81', '19daca0d-21f7-50df-aedc-282e39cc5569', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7976c43f-4ef7-5372-8c7a-d97bb27dd5ff', '19daca0d-21f7-50df-aedc-282e39cc5569', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f550eaf2-4322-5c12-9fcf-ff110e09465e', '19daca0d-21f7-50df-aedc-282e39cc5569', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('8e3a5c71-53ab-5257-862f-3de2dbf62c4f', '78409809-bdf9-5166-9770-56950c8a55af', 6, 'SENTENCE_COMPLETION', 'READING', 3, $md$### Question 6

Questions 6-11
Questions 6-11
Complete the sentence below. Choose
ONE word
from The Passage for each answer. Write your answers in boxes 6 – 11 on your answer sheet
It is thought that the sense of taste was
6
in order to
7
the foods which are harmless to us from those that are not
8
. The sense of smell, which gives us the flavour we detect in our food, helps us to take pleasure in our food. Indeed this
9
for flavour was, in the past, the reason why so many explorers ventured to distant lands to bring back new
10
.which were greatly sought after in Europe. Here they were used in cooking to enhance the usual
11
and unappetizing dishes eaten by rich and poor alike.

It is thought that the sense of taste was 6 ____ in order to 7 ____ the foods which are harmless to us from those that are not 8 ____ . The sense of smell, which gives us the flavour we detect in our food, helps us to take pleasure in our food. Indeed this 9 ____ for flavour was, in the past, the reason why so many explorers ventured to distant lands to bring back new 10 ____ .which were greatly sought after in Europe. Here they were used in cooking to enhance the usual 11 ____ and unappetizing dishes eaten by rich and poor alike.$md$, NULL, ARRAY['.*acquired.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('ccb3573a-1bad-5c7e-9311-f9068f9cf1a5', '78409809-bdf9-5166-9770-56950c8a55af', 7, 'SENTENCE_COMPLETION', 'READING', 3, $md$### Question 7

Questions 6-11
Questions 6-11
Complete the sentence below. Choose
ONE word
from The Passage for each answer. Write your answers in boxes 6 – 11 on your answer sheet
It is thought that the sense of taste was
6
in order to
7
the foods which are harmless to us from those that are not
8
. The sense of smell, which gives us the flavour we detect in our food, helps us to take pleasure in our food. Indeed this
9
for flavour was, in the past, the reason why so many explorers ventured to distant lands to bring back new
10
.which were greatly sought after in Europe. Here they were used in cooking to enhance the usual
11
and unappetizing dishes eaten by rich and poor alike.

It is thought that the sense of taste was 6 ____ in order to 7 ____ the foods which are harmless to us from those that are not 8 ____ . The sense of smell, which gives us the flavour we detect in our food, helps us to take pleasure in our food. Indeed this 9 ____ for flavour was, in the past, the reason why so many explorers ventured to distant lands to bring back new 10 ____ .which were greatly sought after in Europe. Here they were used in cooking to enhance the usual 11 ____ and unappetizing dishes eaten by rich and poor alike.$md$, NULL, ARRAY['.*acquired.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('bfb1304b-605a-5e9a-b512-41220497b65b', '78409809-bdf9-5166-9770-56950c8a55af', 8, 'SENTENCE_COMPLETION', 'READING', 3, $md$### Question 8

Questions 6-11
Questions 6-11
Complete the sentence below. Choose
ONE word
from The Passage for each answer. Write your answers in boxes 6 – 11 on your answer sheet
It is thought that the sense of taste was
6
in order to
7
the foods which are harmless to us from those that are not
8
. The sense of smell, which gives us the flavour we detect in our food, helps us to take pleasure in our food. Indeed this
9
for flavour was, in the past, the reason why so many explorers ventured to distant lands to bring back new
10
.which were greatly sought after in Europe. Here they were used in cooking to enhance the usual
11
and unappetizing dishes eaten by rich and poor alike.

It is thought that the sense of taste was 6 ____ in order to 7 ____ the foods which are harmless to us from those that are not 8 ____ . The sense of smell, which gives us the flavour we detect in our food, helps us to take pleasure in our food. Indeed this 9 ____ for flavour was, in the past, the reason why so many explorers ventured to distant lands to bring back new 10 ____ .which were greatly sought after in Europe. Here they were used in cooking to enhance the usual 11 ____ and unappetizing dishes eaten by rich and poor alike.$md$, NULL, ARRAY['.*acquired.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('91b88a5d-bbb3-5bdb-90c9-8fad5915c92a', '78409809-bdf9-5166-9770-56950c8a55af', 9, 'SENTENCE_COMPLETION', 'READING', 3, $md$### Question 9

Questions 6-11
Questions 6-11
Complete the sentence below. Choose
ONE word
from The Passage for each answer. Write your answers in boxes 6 – 11 on your answer sheet
It is thought that the sense of taste was
6
in order to
7
the foods which are harmless to us from those that are not
8
. The sense of smell, which gives us the flavour we detect in our food, helps us to take pleasure in our food. Indeed this
9
for flavour was, in the past, the reason why so many explorers ventured to distant lands to bring back new
10
.which were greatly sought after in Europe. Here they were used in cooking to enhance the usual
11
and unappetizing dishes eaten by rich and poor alike.

It is thought that the sense of taste was 6 ____ in order to 7 ____ the foods which are harmless to us from those that are not 8 ____ . The sense of smell, which gives us the flavour we detect in our food, helps us to take pleasure in our food. Indeed this 9 ____ for flavour was, in the past, the reason why so many explorers ventured to distant lands to bring back new 10 ____ .which were greatly sought after in Europe. Here they were used in cooking to enhance the usual 11 ____ and unappetizing dishes eaten by rich and poor alike.$md$, NULL, ARRAY['.*acquired.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('8bdaf4c0-7235-5ca6-b7ce-e0bae6908dbc', '78409809-bdf9-5166-9770-56950c8a55af', 10, 'SENTENCE_COMPLETION', 'READING', 4, $md$### Question 10

Questions 6-11
Questions 6-11
Complete the sentence below. Choose
ONE word
from The Passage for each answer. Write your answers in boxes 6 – 11 on your answer sheet
It is thought that the sense of taste was
6
in order to
7
the foods which are harmless to us from those that are not
8
. The sense of smell, which gives us the flavour we detect in our food, helps us to take pleasure in our food. Indeed this
9
for flavour was, in the past, the reason why so many explorers ventured to distant lands to bring back new
10
.which were greatly sought after in Europe. Here they were used in cooking to enhance the usual
11
and unappetizing dishes eaten by rich and poor alike.

It is thought that the sense of taste was 6 ____ in order to 7 ____ the foods which are harmless to us from those that are not 8 ____ . The sense of smell, which gives us the flavour we detect in our food, helps us to take pleasure in our food. Indeed this 9 ____ for flavour was, in the past, the reason why so many explorers ventured to distant lands to bring back new 10 ____ .which were greatly sought after in Europe. Here they were used in cooking to enhance the usual 11 ____ and unappetizing dishes eaten by rich and poor alike.$md$, NULL, ARRAY['.*acquired.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('51810c77-5c06-5e5e-8fc1-3b94ec8c7276', '78409809-bdf9-5166-9770-56950c8a55af', 11, 'SENTENCE_COMPLETION', 'READING', 4, $md$### Question 11

Questions 6-11
Questions 6-11
Complete the sentence below. Choose
ONE word
from The Passage for each answer. Write your answers in boxes 6 – 11 on your answer sheet
It is thought that the sense of taste was
6
in order to
7
the foods which are harmless to us from those that are not
8
. The sense of smell, which gives us the flavour we detect in our food, helps us to take pleasure in our food. Indeed this
9
for flavour was, in the past, the reason why so many explorers ventured to distant lands to bring back new
10
.which were greatly sought after in Europe. Here they were used in cooking to enhance the usual
11
and unappetizing dishes eaten by rich and poor alike.

It is thought that the sense of taste was 6 ____ in order to 7 ____ the foods which are harmless to us from those that are not 8 ____ . The sense of smell, which gives us the flavour we detect in our food, helps us to take pleasure in our food. Indeed this 9 ____ for flavour was, in the past, the reason why so many explorers ventured to distant lands to bring back new 10 ____ .which were greatly sought after in Europe. Here they were used in cooking to enhance the usual 11 ____ and unappetizing dishes eaten by rich and poor alike.$md$, NULL, ARRAY['.*acquired.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('b6c32b25-c540-5208-aa08-615ac2bbe9d6', '78409809-bdf9-5166-9770-56950c8a55af', 12, 'SHORT_ANSWER', 'READING', 4, $md$### Question 12

Question 12-13
Question 12-13
Write
NO MORE THAN TWO WORDS
from Reading Passage 1 for each answer.
Write your answers in boxes 12-13 on your answer sheet
12. We associate certain smells with the past as they are
12
13. Modern technology is able to help determine the minute quantities of
13
found in food.

12. We associate certain smells with the past as they are 12 ____$md$, NULL, ARRAY['.*indelible.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('a2f51283-5603-5b91-b221-ba4b02e5aee6', '78409809-bdf9-5166-9770-56950c8a55af', 13, 'SHORT_ANSWER', 'READING', 4, $md$### Question 13

Question 12-13
Question 12-13
Write
NO MORE THAN TWO WORDS
from Reading Passage 1 for each answer.
Write your answers in boxes 12-13 on your answer sheet
12. We associate certain smells with the past as they are
12
13. Modern technology is able to help determine the minute quantities of
13
found in food.

13. Modern technology is able to help determine the minute quantities of 13 ____ found in food.$md$, NULL, ARRAY['.*chemical.*aromas.*']);

COMMIT;
