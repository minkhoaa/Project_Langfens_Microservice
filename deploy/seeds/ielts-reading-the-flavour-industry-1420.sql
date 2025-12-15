BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-the-flavour-industry-1420'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-the-flavour-industry-1420';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-the-flavour-industry-1420';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-the-flavour-industry-1420';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('2d2d74a6-9d5a-5bab-b4c6-8476ef25638f', 'ielts-reading-the-flavour-industry-1420', $t$The Flavour Industry$t$, $md$## The Flavour Industry

Nguồn:
- Test: https://mini-ielts.com/1420/reading/the-flavour-industry
- Solution: https://mini-ielts.com/1420/view-solution/reading/the-flavour-industry$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('43315131-8c69-5394-9697-b5e5e272d114', '2d2d74a6-9d5a-5bab-b4c6-8476ef25638f', 1, $t$Reading — The Flavour Industry$t$, $md$Read the passage and answer questions **1–13**.

### Passage: The Flavour Industry

A. Read through the nutritional information on the food in your freezer, refrigerator or kitchen pantry, and you are likely to find a simple, innocuous-looking ingredient recurring on a number of products: “natural flavour”. The story of what natural flavour is, how it got into your food, and where it came from is the result of more complex processes than you might imagine.

B. During the 1980s, health watchdogs and nutritionists began turning their attention to cholesterol, a waxy steroid metabolite that we mainly consume from animal-sourced products such as cheese, egg yolks, beef, poultry, shrimp, and pork. Nutritionists blamed cholesterol for contributing to the growing rates of obesity, heart disease, diabetes, and several cancers in Western societies. As extensive recognition of the matter grew amongst the common people, McDonald’s stopped cooking their French fries in a mixture of cottonseed oil and beef tallow, and in 1990, the restaurant chain began using 100% vegetable oil instead.

C. This substantially lowered the amount of cholesterol in McDonald’s fries, but it created a new dilemma The beef tallow and cottonseed oil mixture gave the French fries high cholesterol content, but it also gifted them with a rich aroma and “mouth-feel” that even James Beard, an American food critic, admitted he enjoyed. Pure vegetable oil is bland in comparison. Looking at the current ingredients list of McDonald’s French fries, however, it is easy to see how they overcame this predicament. Aside from a few preservatives, there are essentially three main ingredients: potato, soybean oil, and the mysterious component of “natural flavour”.

D. Natural flavour also entered our diet through the rise in processed foods, which now make up over 90% (and growing) of the American diet, as well as representing a burgeoning industry in developing countries such as China and India Processed foods are essentially any foods that have been boxed, bagged, canned or packaged, and have a list of ingredients on the label. Sometimes, the processing involves adding a little sodium or sugar, and a few preservatives. Often, however, it is coloured, bleached, stabilized, emulsified, dehydrated, odour-concealed, and sweetened. This process typically saps any original flavour out of the product, and so, of course, flavour must be added back in as well.

E. Often this is “natural flavour”, but while the term may bring to mind images of fresh barley, hand-ground spices, and dried herbs being traded in a bustling street market, most of these natural sources are, in fact, engineered to culinary perfection in a set of factories and plants of the New Jersey Turnpike outside of New York. Here, firms such as International Flavors & Fragrances, Harmen & Keimer, Flavor Dynamics, Frutarom and Elan Chemical isolate and manufacture the tastes that are incorporated in much of what we eat and drink. The sweet, summery burst of naturally squeezed orange juice, the wood-smoked aroma in barbeque sauces, and the creamy, buttery, fresh taste in many dairy products do not come from sun-drenched meadows or backyard grills but are formed in the labs and test tubes of these flavour industry giants.

F. The scientists – dubbed “flavourists” who create the potent chemicals that set our olfactory senses to overdrive use a mix of techniques that have been refined over many years. Part of it is dense, intricate chemistry: spectrometers, gas chromatographs, and headspace-vapor analyzers can break down components of a flavor in amounts as minute as one part per billion. Not to be outdone, however, the human nose can isolate aromas down to three parts per trillion. Flavourists, therefore, consider their work as much an art as a science, and flavorism requires a nose “trained” with a delicate and poetic sense of balance.

G. Should we be wary of the industrialization of natural flavour? On its own, the trend may not present any clear reason for alarm. Nutritionists widely agree that the real assault on health in the last few decades stems from an “unholy trinity” of sugar, fat, and sodium in processed foods. The natural flavour on its own is not a health risk. It does play a role, however, in helping these processed foods to taste fresh and nutritious, even when they are not. So, while the natural flavor industry should not be considered the culprit, we might think of it as a willing accomplice.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('3f483ab5-efc2-5e9d-9b89-e24a2f99f886', '43315131-8c69-5394-9697-b5e5e272d114', 1, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 1

Questions 1-8
Questions 1-8
Reading Passage has seven paragraphs, A-G.
Which paragraph contains the following information?
Write the correct letter. A-G, in boxes 1-8 on your answer sheet.
NB
You may use
any letter more than once.
1
examples of companies that create natural flavors
2
an instance of a multinational franchise responding to public pressure
3
a statement on the health effects of natural flavors
4
an instance where a solution turns into a problem
5
a place in the home where one may encounter the term “natural flavor”
6
details about the transformation that takes place in processed grocery items
7
a comparison of personal and technological abilities in flavor detection
8
examples of diet-related health conditions

1 ____ examples of companies that create natural flavors$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1edade2b-cd2d-5668-87c0-b11d12c43e98', '3f483ab5-efc2-5e9d-9b89-e24a2f99f886', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e0032da1-286c-5a63-a4ba-094ef258207c', '3f483ab5-efc2-5e9d-9b89-e24a2f99f886', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('133309dc-bd13-52fa-8ebb-38053e708d58', '3f483ab5-efc2-5e9d-9b89-e24a2f99f886', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('da7bbebe-7087-52ae-b4cc-536af92b3352', '3f483ab5-efc2-5e9d-9b89-e24a2f99f886', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1f4ef5ed-7462-582c-9510-15dd2f201544', '3f483ab5-efc2-5e9d-9b89-e24a2f99f886', 5, $md$E$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ff442290-2653-5b10-9a17-677b1368f4bb', '3f483ab5-efc2-5e9d-9b89-e24a2f99f886', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('37291d31-97b2-553d-962e-3f70f321fafd', '3f483ab5-efc2-5e9d-9b89-e24a2f99f886', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('9dc5c9ff-0db5-5c34-aedf-e7bcb3658b6b', '43315131-8c69-5394-9697-b5e5e272d114', 2, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 2

Questions 1-8
Questions 1-8
Reading Passage has seven paragraphs, A-G.
Which paragraph contains the following information?
Write the correct letter. A-G, in boxes 1-8 on your answer sheet.
NB
You may use
any letter more than once.
1
examples of companies that create natural flavors
2
an instance of a multinational franchise responding to public pressure
3
a statement on the health effects of natural flavors
4
an instance where a solution turns into a problem
5
a place in the home where one may encounter the term “natural flavor”
6
details about the transformation that takes place in processed grocery items
7
a comparison of personal and technological abilities in flavor detection
8
examples of diet-related health conditions

2 ____ an instance of a multinational franchise responding to public pressure$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8e442fd2-4e00-5fc2-ac11-a44d01b3629b', '9dc5c9ff-0db5-5c34-aedf-e7bcb3658b6b', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('36192491-2309-5c56-853a-ec300fb6f764', '9dc5c9ff-0db5-5c34-aedf-e7bcb3658b6b', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('523283af-452e-5469-af6d-d93cf33cc0f6', '9dc5c9ff-0db5-5c34-aedf-e7bcb3658b6b', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5c4c9a37-8de2-5b91-a9ae-cbca99d24c0e', '9dc5c9ff-0db5-5c34-aedf-e7bcb3658b6b', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8dac5c7d-54fd-510f-bdb8-af29c78f6f14', '9dc5c9ff-0db5-5c34-aedf-e7bcb3658b6b', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('31659b58-aa32-5080-a87c-5e0421b3df8f', '9dc5c9ff-0db5-5c34-aedf-e7bcb3658b6b', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9b755d6b-0a65-5707-a16a-4007ecef5713', '9dc5c9ff-0db5-5c34-aedf-e7bcb3658b6b', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('b31cc7ab-1b04-5d8a-a19a-754833f88b79', '43315131-8c69-5394-9697-b5e5e272d114', 3, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 3

Questions 1-8
Questions 1-8
Reading Passage has seven paragraphs, A-G.
Which paragraph contains the following information?
Write the correct letter. A-G, in boxes 1-8 on your answer sheet.
NB
You may use
any letter more than once.
1
examples of companies that create natural flavors
2
an instance of a multinational franchise responding to public pressure
3
a statement on the health effects of natural flavors
4
an instance where a solution turns into a problem
5
a place in the home where one may encounter the term “natural flavor”
6
details about the transformation that takes place in processed grocery items
7
a comparison of personal and technological abilities in flavor detection
8
examples of diet-related health conditions

3 ____ a statement on the health effects of natural flavors$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('afdeb722-8d01-594a-8653-d319b8128839', 'b31cc7ab-1b04-5d8a-a19a-754833f88b79', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e14754dd-71da-540c-bc50-2bcceb97b12c', 'b31cc7ab-1b04-5d8a-a19a-754833f88b79', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b961db51-feac-58a2-a0d4-f82b424cf029', 'b31cc7ab-1b04-5d8a-a19a-754833f88b79', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4599a4f7-3639-5503-94df-7712a47c41b5', 'b31cc7ab-1b04-5d8a-a19a-754833f88b79', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ec1f5dd9-dc6c-5ee8-813d-92f43b07a07d', 'b31cc7ab-1b04-5d8a-a19a-754833f88b79', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('32de32ce-0721-5f31-8ada-af82ec78d239', 'b31cc7ab-1b04-5d8a-a19a-754833f88b79', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b017e115-e57e-5c96-b320-450e3bdf0113', 'b31cc7ab-1b04-5d8a-a19a-754833f88b79', 7, $md$G$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('fd2316f8-c163-5ea3-bd24-722b03c72ea9', '43315131-8c69-5394-9697-b5e5e272d114', 4, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 4

Questions 1-8
Questions 1-8
Reading Passage has seven paragraphs, A-G.
Which paragraph contains the following information?
Write the correct letter. A-G, in boxes 1-8 on your answer sheet.
NB
You may use
any letter more than once.
1
examples of companies that create natural flavors
2
an instance of a multinational franchise responding to public pressure
3
a statement on the health effects of natural flavors
4
an instance where a solution turns into a problem
5
a place in the home where one may encounter the term “natural flavor”
6
details about the transformation that takes place in processed grocery items
7
a comparison of personal and technological abilities in flavor detection
8
examples of diet-related health conditions

4 ____ an instance where a solution turns into a problem$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('18285358-9f1f-5b55-af7d-5a3e2d70909c', 'fd2316f8-c163-5ea3-bd24-722b03c72ea9', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a835fdda-4da6-59b3-b0b8-81b246e6b216', 'fd2316f8-c163-5ea3-bd24-722b03c72ea9', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b0335bdb-f523-5902-8717-dc1258b0e63b', 'fd2316f8-c163-5ea3-bd24-722b03c72ea9', 3, $md$C$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a56da8dc-0568-5bbe-95ac-4b20fec45cb9', 'fd2316f8-c163-5ea3-bd24-722b03c72ea9', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6a7faf43-e42c-5000-8f2d-14584917035b', 'fd2316f8-c163-5ea3-bd24-722b03c72ea9', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a8f54727-40e8-59e6-af54-c2220d1d526a', 'fd2316f8-c163-5ea3-bd24-722b03c72ea9', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a9eda751-c9cc-5b41-aa39-ead4736a345d', 'fd2316f8-c163-5ea3-bd24-722b03c72ea9', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('5381a577-3345-566d-845f-93af3bf733db', '43315131-8c69-5394-9697-b5e5e272d114', 5, 'MATCHING_INFORMATION', 'READING', 3, $md$### Question 5

Questions 1-8
Questions 1-8
Reading Passage has seven paragraphs, A-G.
Which paragraph contains the following information?
Write the correct letter. A-G, in boxes 1-8 on your answer sheet.
NB
You may use
any letter more than once.
1
examples of companies that create natural flavors
2
an instance of a multinational franchise responding to public pressure
3
a statement on the health effects of natural flavors
4
an instance where a solution turns into a problem
5
a place in the home where one may encounter the term “natural flavor”
6
details about the transformation that takes place in processed grocery items
7
a comparison of personal and technological abilities in flavor detection
8
examples of diet-related health conditions

5 ____ a place in the home where one may encounter the term “natural flavor”$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('764b69d9-64bf-58b9-b81a-4a41875ce5f0', '5381a577-3345-566d-845f-93af3bf733db', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1e1a2c25-b8d8-578f-b625-4c7ca6fda812', '5381a577-3345-566d-845f-93af3bf733db', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('088fe9fb-611d-5de6-826f-3d50b0962f23', '5381a577-3345-566d-845f-93af3bf733db', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('57391e03-e0b5-5fb7-aa83-fe9eb560b4ab', '5381a577-3345-566d-845f-93af3bf733db', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e76e6a55-ac92-5646-a278-e45220614ccf', '5381a577-3345-566d-845f-93af3bf733db', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6ba6da0b-6358-586f-bc26-8640832bae1e', '5381a577-3345-566d-845f-93af3bf733db', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ae3b0c83-9bd8-54c5-8723-7d188e399b73', '5381a577-3345-566d-845f-93af3bf733db', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('034e5ea2-4641-591c-b4b2-09f083136d0e', '43315131-8c69-5394-9697-b5e5e272d114', 6, 'MATCHING_INFORMATION', 'READING', 3, $md$### Question 6

Questions 1-8
Questions 1-8
Reading Passage has seven paragraphs, A-G.
Which paragraph contains the following information?
Write the correct letter. A-G, in boxes 1-8 on your answer sheet.
NB
You may use
any letter more than once.
1
examples of companies that create natural flavors
2
an instance of a multinational franchise responding to public pressure
3
a statement on the health effects of natural flavors
4
an instance where a solution turns into a problem
5
a place in the home where one may encounter the term “natural flavor”
6
details about the transformation that takes place in processed grocery items
7
a comparison of personal and technological abilities in flavor detection
8
examples of diet-related health conditions

6 ____ details about the transformation that takes place in processed grocery items$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fd14babd-9648-5e58-8b62-33cbfd2fb890', '034e5ea2-4641-591c-b4b2-09f083136d0e', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c47b448f-4944-5f22-9a1c-10c528f73a1d', '034e5ea2-4641-591c-b4b2-09f083136d0e', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bd296772-b87b-5fbb-8ab6-0fec4d00c05c', '034e5ea2-4641-591c-b4b2-09f083136d0e', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2247898b-d197-5d17-bfa1-fa88cea48a55', '034e5ea2-4641-591c-b4b2-09f083136d0e', 4, $md$D$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5a55a78e-8815-5803-aa7f-bb260d05ba5e', '034e5ea2-4641-591c-b4b2-09f083136d0e', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6d29cbbc-c05f-5927-954a-65d00df2e2dd', '034e5ea2-4641-591c-b4b2-09f083136d0e', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d44c14ff-b477-5faa-9bd4-d45c492035d2', '034e5ea2-4641-591c-b4b2-09f083136d0e', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('5d74ed79-f8cf-58f1-9cdb-7a397d7708b0', '43315131-8c69-5394-9697-b5e5e272d114', 7, 'MATCHING_INFORMATION', 'READING', 3, $md$### Question 7

Questions 1-8
Questions 1-8
Reading Passage has seven paragraphs, A-G.
Which paragraph contains the following information?
Write the correct letter. A-G, in boxes 1-8 on your answer sheet.
NB
You may use
any letter more than once.
1
examples of companies that create natural flavors
2
an instance of a multinational franchise responding to public pressure
3
a statement on the health effects of natural flavors
4
an instance where a solution turns into a problem
5
a place in the home where one may encounter the term “natural flavor”
6
details about the transformation that takes place in processed grocery items
7
a comparison of personal and technological abilities in flavor detection
8
examples of diet-related health conditions

7 ____ a comparison of personal and technological abilities in flavor detection$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4dea338e-e9bb-5d63-ad7d-a75d3e60ddeb', '5d74ed79-f8cf-58f1-9cdb-7a397d7708b0', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9ccde4dd-f244-51d6-87da-7a6847fa7feb', '5d74ed79-f8cf-58f1-9cdb-7a397d7708b0', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('63eb2be9-24c3-58a5-a069-b434501829a9', '5d74ed79-f8cf-58f1-9cdb-7a397d7708b0', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('62ef0f1b-9101-5ee9-8842-67c7df342648', '5d74ed79-f8cf-58f1-9cdb-7a397d7708b0', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('13275fbc-bed4-5d65-b0f7-168f1452cf4b', '5d74ed79-f8cf-58f1-9cdb-7a397d7708b0', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('170eb596-c076-5e37-99e6-59005e465a93', '5d74ed79-f8cf-58f1-9cdb-7a397d7708b0', 6, $md$F$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fc151f74-24ca-5824-bc13-7bce7c00bf27', '5d74ed79-f8cf-58f1-9cdb-7a397d7708b0', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('8d38ea9f-bed9-539b-8382-e1ca9af07996', '43315131-8c69-5394-9697-b5e5e272d114', 8, 'MATCHING_INFORMATION', 'READING', 3, $md$### Question 8

Questions 1-8
Questions 1-8
Reading Passage has seven paragraphs, A-G.
Which paragraph contains the following information?
Write the correct letter. A-G, in boxes 1-8 on your answer sheet.
NB
You may use
any letter more than once.
1
examples of companies that create natural flavors
2
an instance of a multinational franchise responding to public pressure
3
a statement on the health effects of natural flavors
4
an instance where a solution turns into a problem
5
a place in the home where one may encounter the term “natural flavor”
6
details about the transformation that takes place in processed grocery items
7
a comparison of personal and technological abilities in flavor detection
8
examples of diet-related health conditions

8 ____ examples of diet-related health conditions$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5487203c-b70b-5439-8ed6-60590d56b5ea', '8d38ea9f-bed9-539b-8382-e1ca9af07996', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('838635b4-15dd-54cc-a864-0cc9ac901155', '8d38ea9f-bed9-539b-8382-e1ca9af07996', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6c7e47f8-ae5f-5330-bef4-da5e4f36f8fc', '8d38ea9f-bed9-539b-8382-e1ca9af07996', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('68687648-f3e2-57b3-9b77-e5c3727e4bc7', '8d38ea9f-bed9-539b-8382-e1ca9af07996', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('15f68275-5a85-5422-9624-b18a9b3cdaa8', '8d38ea9f-bed9-539b-8382-e1ca9af07996', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('92c1b804-a8b9-548e-b433-425c549b17df', '8d38ea9f-bed9-539b-8382-e1ca9af07996', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5a14f7ff-0050-595c-b73b-054b1d693cbf', '8d38ea9f-bed9-539b-8382-e1ca9af07996', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('fc8cf1d4-fb8a-5966-a38f-931f536d2e4d', '43315131-8c69-5394-9697-b5e5e272d114', 9, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 9

Questions 9-12
Questions 9-12
Do the following statements agree with the information given in Reading Passage?
In boxes 9-12 on your answer sheet, write
TRUE
, if the statement agrees with the information
FALSE
, if the statement contradicts with the information
NOT
GIVEN
, if there is no information on this
9
On their own, vegetable oils do not have a strong flavor.
10
Soybean oil is lower in cholesterol than cottonseed oil.
11
Processed foods are becoming more popular in some Asian countries.
12
All food processing involves the use of natural flavors.

9 ____ On their own, vegetable oils do not have a strong flavor.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('41e73be7-d02e-56d4-9ecb-6ce2a353a5e6', 'fc8cf1d4-fb8a-5966-a38f-931f536d2e4d', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('270e7676-4ab7-5665-b108-96be0c533ba4', 'fc8cf1d4-fb8a-5966-a38f-931f536d2e4d', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f8fce8fc-6fcb-5512-964b-6d5d76b95d93', 'fc8cf1d4-fb8a-5966-a38f-931f536d2e4d', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('a599825a-b379-514b-80a9-dad7d1953453', '43315131-8c69-5394-9697-b5e5e272d114', 10, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 10

Questions 9-12
Questions 9-12
Do the following statements agree with the information given in Reading Passage?
In boxes 9-12 on your answer sheet, write
TRUE
, if the statement agrees with the information
FALSE
, if the statement contradicts with the information
NOT
GIVEN
, if there is no information on this
9
On their own, vegetable oils do not have a strong flavor.
10
Soybean oil is lower in cholesterol than cottonseed oil.
11
Processed foods are becoming more popular in some Asian countries.
12
All food processing involves the use of natural flavors.

10 ____ Soybean oil is lower in cholesterol than cottonseed oil.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0ec7e602-985e-56fe-9eac-ff4156a604d0', 'a599825a-b379-514b-80a9-dad7d1953453', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c7130be2-c047-59d4-907a-0350a04e989e', 'a599825a-b379-514b-80a9-dad7d1953453', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b756946e-4a9d-5110-b98e-82b40a12451a', 'a599825a-b379-514b-80a9-dad7d1953453', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('aea77447-aa13-58d9-acc5-8cc827190603', '43315131-8c69-5394-9697-b5e5e272d114', 11, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 11

Questions 9-12
Questions 9-12
Do the following statements agree with the information given in Reading Passage?
In boxes 9-12 on your answer sheet, write
TRUE
, if the statement agrees with the information
FALSE
, if the statement contradicts with the information
NOT
GIVEN
, if there is no information on this
9
On their own, vegetable oils do not have a strong flavor.
10
Soybean oil is lower in cholesterol than cottonseed oil.
11
Processed foods are becoming more popular in some Asian countries.
12
All food processing involves the use of natural flavors.

11 ____ Processed foods are becoming more popular in some Asian countries.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2d20aef0-b5f3-5948-ade6-0632a8f4419f', 'aea77447-aa13-58d9-acc5-8cc827190603', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a66f7f7e-ae30-5f1d-8bea-88e8cc679b10', 'aea77447-aa13-58d9-acc5-8cc827190603', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ce46797e-6ca3-55b6-a062-568b63a1901c', 'aea77447-aa13-58d9-acc5-8cc827190603', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('df0385c0-ab65-55bf-960b-8748ae38c2eb', '43315131-8c69-5394-9697-b5e5e272d114', 12, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 12

Questions 9-12
Questions 9-12
Do the following statements agree with the information given in Reading Passage?
In boxes 9-12 on your answer sheet, write
TRUE
, if the statement agrees with the information
FALSE
, if the statement contradicts with the information
NOT
GIVEN
, if there is no information on this
9
On their own, vegetable oils do not have a strong flavor.
10
Soybean oil is lower in cholesterol than cottonseed oil.
11
Processed foods are becoming more popular in some Asian countries.
12
All food processing involves the use of natural flavors.

12 ____ All food processing involves the use of natural flavors.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0450695e-16a3-5b13-b29f-89ef375899ef', 'df0385c0-ab65-55bf-960b-8748ae38c2eb', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e4d4a10c-309a-5221-b53d-5119a2df89e0', 'df0385c0-ab65-55bf-960b-8748ae38c2eb', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('143528b9-ccc9-556f-b1c1-c1ebe26490d6', 'df0385c0-ab65-55bf-960b-8748ae38c2eb', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('41440663-44f6-5e6c-9f71-2bde54e4a5c8', '43315131-8c69-5394-9697-b5e5e272d114', 13, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 13

Question 13
Question 13
Choose the correct letter. A B, C, or D and write it
on your answer sheet.
13. The writer of Reading Passage concludes that natural flavors…………………..
A
are the major cause of dietary health problems.
B
are unhealthy, but not as had as sugar, fat, and sodium.
C
have health benefits that other ingredients tend to cancel out.
D
help make unhealthy foods taste better.

Choose the correct letter. A B, C, or D and write it on your answer sheet.$md$, NULL);

COMMIT;
