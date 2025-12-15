BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading--effort-and-science-to-win-1204'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading--effort-and-science-to-win-1204';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading--effort-and-science-to-win-1204';
DELETE FROM exams WHERE "Slug" = 'ielts-reading--effort-and-science-to-win-1204';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('bfe2f092-3913-52ea-ae65-ee969bd3ed61', 'ielts-reading--effort-and-science-to-win-1204', $t$EFFORT AND SCIENCE TO WIN$t$, $md$## EFFORT AND SCIENCE TO WIN

Nguồn:
- Test: https://mini-ielts.com/1204/reading/-effort-and-science-to-win
- Solution: https://mini-ielts.com/1204/view-solution/reading/-effort-and-science-to-win$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('f4fa1e51-e5fc-5e29-96de-f09f0dfbb204', 'bfe2f092-3913-52ea-ae65-ee969bd3ed61', 1, $t$Reading — EFFORT AND SCIENCE TO WIN$t$, $md$Read the passage and answer questions **1–13**.

### Passage: EFFORT AND SCIENCE TO WIN

Winning nowadays is not only a question of disciplined training: The triumph of victory today involves the collaboration of several medical specialists who combine their particular knowledge in an effort to help each athlete to reach their potential.

A. In Mexico, the Medicine Direction and .Applied Sciences of the National Commission of Deporte analyses all aspects of sports science from the role of the auditory system in sporting achievement to die power of the mind and its role in the ability to win. Everything, it seems, is open to scrutiny . Recently, the focus has been evaluating the visual acuity of cyclists and long distance runners but they also focus on the more traditional areas of sports research, among them psychology, nutrition, anthropology, biochemistry and odontology 1 . From budding child athletes as young as 9 to the more mature-aged sportsperson, the facility at Deporte has attracted some of Mexico’s most famous sporting and Olympic hopefuls.

B. “The study of elite athletes is now more scientific than ever” says doctor Francisco Javier Squares, “ after each competition, athletes are exposed to vigorous medical examinations and follow-up training in order to help US arrive at a program that is tailor-made. “The modern athlete has become big business, no longer is there a one-size-fits-all approach. For example, in the past two people both 1.70 meters tall and weighing 70 kilograms would have been given the same program of athletic conditioning – now this idea is obsolete. It may be that the first individual has 35 kgs of muscle and 15 kgs of fat and the other person, although the same height and weight may have 30 kgs of muscle and 20 kgs of fat. Through detailed scientific evaluation here at our facility in Deporte,” says Squares, “ … we are able to construct a very specific training programme for each individual.”

C. Whereas many countries in die world focus on the elevation of the glorious champion, the Mexican Olympic team takes a slightly different approach. Psychologically speaking an athlete must bring to his endeavour a healthy dose of humility. As Squares said, “ When an athlete wins for Mexico, it is always as a result of a combined team effort with many people operating behind the scenes to realise the sporting achievement. When an athlete stands on the dais, it is because of great effort on the part of many.”

D. As is often the case in some poorer countries, sportsmen and women are stifled in their development due to budgetary constraints . However this has not been a factor for consideration with the team in Mexico. The Mexican government has allocated a substantial sum of money for the provision of the latest equipment and laboratories for sports research. In fact, the quality of Mexico’s facilities puts them on a par with countries like Italy and Germany in terms of access to resources . One example of sophisticated equipment used at the Mexican facility is the hyperbaric chamber. This apparatus is used to enhance oxygen recovery after a vigorous physical workout. Says Squares, “When you breathe the air while inside a hyperbaric chamber the natural state of the oxygen does not change. Green plants produced the oxygen; modern technology just increases the air pressure. This does not change the molecular composition of oxygen. Increased pressure just allows oxygen to get into tissues better. Due to our purchase of the hyperbaric chamber , athletes are able to recover from an intense workout in a much shorter space of time. We typically use the chamber for sessions of 45 to 60 minutes daffy or three times per week.”

E. When pushed to the limit, the true indicator of fitness is not how hard the heart operates, but how quickly it can recover after an extreme workout. Therefore, another focus area of study for the team in Mexico has been the endurance of the heart. To measure this recovery rate, an electroencephalograph (EEG) is used. The EEG enables doctors to monitor the brainwave activity from sensors placed on the scalp. Athletes exert intense effort for a sustained period after which they are given time to rest and recover. During these periods between intense physical exertion and recovery, doctors are able to monitor any weaknesses in the way the heart responds . The CCG has had a big impact upon our ability to measure the muscular endurance of the heart.

F. In 1796, the life expectancy of a human being was between 25 and 36 years, in 1886 that number basically doubled to between 45 and 50. In 1996, the life expectancy of an average Mexican stood at around 75 years. People are living longer and this is due in large part to the advances of modern science. It is not all sophisticated medical equipment that is playing a part; although lesser in impact, basic advances in engineering are also greatly assisting. Take for example, a professional tennis player. In the past, most tennis players’ shoes were constructed with fabric and a solid rubber sole. These shoes were of poor construction and resulted in hip and foot injuries. Today the technology of shoe construction has radically changed. Now some shoes are injected with silicone and made of more comfortable, ergonomic 1 construction. This has helped not only the elite but also the recreational sportsperson and thus, helps in the preservation of the human body.

1 objects designed to be better adapted to the shape of the human body$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('23fc74a7-2690-5995-9eff-3090129bea14', 'f4fa1e51-e5fc-5e29-96de-f09f0dfbb204', 1, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 1

Questions 1-4
Questions 1-4
The passage has eight paragraphs labelled
A-F
Which paragraph contains the following information?
Write the correct letter
A-F
in boxes
1-4
on your answer sheet.
NB
You
may use
any
letter
more than once
.
1
the natural process of oxygen production
Locate
2
standard after-competition procedure
Locate
3
the areas of study undertaken to improve athletic performance
Locate
4
the Mexican viewpoint on winning
Locate

1 ____ the natural process of oxygen production Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e34d7e5b-a6a9-5a47-a412-5dd9917cec5d', '23fc74a7-2690-5995-9eff-3090129bea14', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('244f31f8-2aea-5769-9c10-23025a4e2626', '23fc74a7-2690-5995-9eff-3090129bea14', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('53bd4de6-af44-5484-bdde-4dd6b8103801', '23fc74a7-2690-5995-9eff-3090129bea14', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('37a9be9f-8a57-55db-8cec-52988b996a49', '23fc74a7-2690-5995-9eff-3090129bea14', 4, $md$D$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a1ed79ab-e575-581c-8a12-8516b716bf18', '23fc74a7-2690-5995-9eff-3090129bea14', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3e46488b-cfc7-5d8d-a39e-18ea162e0b46', '23fc74a7-2690-5995-9eff-3090129bea14', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('68205b08-2a8c-5b5f-afa2-6e2b9b349516', '23fc74a7-2690-5995-9eff-3090129bea14', 7, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('18ab98a3-47b2-5394-942d-b405cbafee20', '23fc74a7-2690-5995-9eff-3090129bea14', 8, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('592c3170-51fa-57ef-9f6b-8e36734a1cd5', '23fc74a7-2690-5995-9eff-3090129bea14', 9, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f85c2c78-8b59-554d-a207-9b0ed47a8aa1', '23fc74a7-2690-5995-9eff-3090129bea14', 10, $md$D$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2baebba1-ea9b-5973-bcbf-40cc1527e553', '23fc74a7-2690-5995-9eff-3090129bea14', 11, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f1405ade-0acc-5236-b747-7bda06dfc137', '23fc74a7-2690-5995-9eff-3090129bea14', 12, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d8b78262-7dd1-5ea9-a596-763732902c7f', '23fc74a7-2690-5995-9eff-3090129bea14', 13, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4047c345-eb81-52b4-ae93-9368053f4e1c', '23fc74a7-2690-5995-9eff-3090129bea14', 14, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('85ade3a2-1a33-55db-aa94-31489113f969', '23fc74a7-2690-5995-9eff-3090129bea14', 15, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a531c7b3-d6c5-55b2-8e38-7f846b0e4d39', '23fc74a7-2690-5995-9eff-3090129bea14', 16, $md$D$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('124bbae5-64ea-5fc6-b825-0a7e47d4b6be', '23fc74a7-2690-5995-9eff-3090129bea14', 17, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8d348487-d38f-5aff-972c-aee5a1a568ce', '23fc74a7-2690-5995-9eff-3090129bea14', 18, $md$F$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('44ee9fb2-5e95-5a9e-896e-9885d6771254', 'f4fa1e51-e5fc-5e29-96de-f09f0dfbb204', 2, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 2

Questions 1-4
Questions 1-4
The passage has eight paragraphs labelled
A-F
Which paragraph contains the following information?
Write the correct letter
A-F
in boxes
1-4
on your answer sheet.
NB
You
may use
any
letter
more than once
.
1
the natural process of oxygen production
Locate
2
standard after-competition procedure
Locate
3
the areas of study undertaken to improve athletic performance
Locate
4
the Mexican viewpoint on winning
Locate

2 ____ standard after-competition procedure Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a6813050-0da9-5b6f-9827-35576024587a', '44ee9fb2-5e95-5a9e-896e-9885d6771254', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d85dd352-7946-57fa-b943-d720916d95f4', '44ee9fb2-5e95-5a9e-896e-9885d6771254', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('eec586c0-c9d2-5fab-85cf-18eba2731aaa', '44ee9fb2-5e95-5a9e-896e-9885d6771254', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6734a0ff-bc7f-5b3a-9109-d5ea64352448', '44ee9fb2-5e95-5a9e-896e-9885d6771254', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f02222c0-b16f-5347-aa64-60295a0572f2', '44ee9fb2-5e95-5a9e-896e-9885d6771254', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('34820f4f-d603-5e72-819f-bc10a5253435', '44ee9fb2-5e95-5a9e-896e-9885d6771254', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b94f2438-8616-5cce-9b78-a1d525a642d9', '44ee9fb2-5e95-5a9e-896e-9885d6771254', 7, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b38f8bff-a946-59a3-aec0-2fde3b26d260', '44ee9fb2-5e95-5a9e-896e-9885d6771254', 8, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9bd219ad-44c6-5c3b-8ae7-0addfd1e7d14', '44ee9fb2-5e95-5a9e-896e-9885d6771254', 9, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('381b11f5-fbe1-5e6b-a4a1-379d57674bd3', '44ee9fb2-5e95-5a9e-896e-9885d6771254', 10, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('45a7aa0a-330a-50ad-a5b5-25071169f829', '44ee9fb2-5e95-5a9e-896e-9885d6771254', 11, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cc4691b5-3e9c-54f5-9a98-4b4fd9b141b8', '44ee9fb2-5e95-5a9e-896e-9885d6771254', 12, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('67997cd4-542e-52ac-9a9e-28205d677d73', '44ee9fb2-5e95-5a9e-896e-9885d6771254', 13, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c32500ed-ed8f-5e4e-9741-448735e71949', '44ee9fb2-5e95-5a9e-896e-9885d6771254', 14, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('473021f8-3760-51b2-b647-0e5ca6fcf361', '44ee9fb2-5e95-5a9e-896e-9885d6771254', 15, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5339a92d-866b-5666-9ba6-c800631da530', '44ee9fb2-5e95-5a9e-896e-9885d6771254', 16, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('365a4263-9641-5d13-b517-d319431ecd4e', '44ee9fb2-5e95-5a9e-896e-9885d6771254', 17, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b1d45089-61c8-5d19-ba2f-4f5341abcfd4', '44ee9fb2-5e95-5a9e-896e-9885d6771254', 18, $md$F$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('a98f5567-7444-5378-bab4-5b5f15b53b8f', 'f4fa1e51-e5fc-5e29-96de-f09f0dfbb204', 3, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 3

Questions 1-4
Questions 1-4
The passage has eight paragraphs labelled
A-F
Which paragraph contains the following information?
Write the correct letter
A-F
in boxes
1-4
on your answer sheet.
NB
You
may use
any
letter
more than once
.
1
the natural process of oxygen production
Locate
2
standard after-competition procedure
Locate
3
the areas of study undertaken to improve athletic performance
Locate
4
the Mexican viewpoint on winning
Locate

3 ____ the areas of study undertaken to improve athletic performance Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fdcb130f-b0ab-5460-a960-10dfd8d48c0c', 'a98f5567-7444-5378-bab4-5b5f15b53b8f', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a8b3acc9-f7a6-5b2b-9fd8-068990a9c262', 'a98f5567-7444-5378-bab4-5b5f15b53b8f', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('829a062a-6bdf-56bb-bc79-c91b808ad105', 'a98f5567-7444-5378-bab4-5b5f15b53b8f', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3fe06715-a4ad-5af1-8065-fd1413316e91', 'a98f5567-7444-5378-bab4-5b5f15b53b8f', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('de5ee1ce-8ae6-5de7-b657-9de2410ab734', 'a98f5567-7444-5378-bab4-5b5f15b53b8f', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('59cd19e7-2093-52fe-81b8-5949c6bdbc6b', 'a98f5567-7444-5378-bab4-5b5f15b53b8f', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d857fb55-d980-57ea-b1e0-6d901b7c445c', 'a98f5567-7444-5378-bab4-5b5f15b53b8f', 7, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1e7fd9a3-515b-5db3-90ee-3797101709dd', 'a98f5567-7444-5378-bab4-5b5f15b53b8f', 8, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4d59762a-b88a-580c-a402-af71dd2c9dfd', 'a98f5567-7444-5378-bab4-5b5f15b53b8f', 9, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1edbb788-1d41-5b4c-a6e2-c08c7f10edc0', 'a98f5567-7444-5378-bab4-5b5f15b53b8f', 10, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6d4ddda4-f88d-5d33-a63f-5ba32472f087', 'a98f5567-7444-5378-bab4-5b5f15b53b8f', 11, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e1e0b065-266e-5728-bb2c-846ddb33f9aa', 'a98f5567-7444-5378-bab4-5b5f15b53b8f', 12, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('55676b0b-1628-5e4e-863f-44ea27a7fa2c', 'a98f5567-7444-5378-bab4-5b5f15b53b8f', 13, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('596a7fd3-c986-592a-aa02-69aa5b6af3da', 'a98f5567-7444-5378-bab4-5b5f15b53b8f', 14, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c39308df-98db-517d-b4a4-a7443a62ea83', 'a98f5567-7444-5378-bab4-5b5f15b53b8f', 15, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9abbad92-b167-5b8f-9a9d-4a27718ea76f', 'a98f5567-7444-5378-bab4-5b5f15b53b8f', 16, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b6da50cf-763e-569b-9cac-4d4756be573c', 'a98f5567-7444-5378-bab4-5b5f15b53b8f', 17, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('75ca8d51-0953-5546-91a6-91946f156e80', 'a98f5567-7444-5378-bab4-5b5f15b53b8f', 18, $md$F$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('06b537fd-f0fb-577d-b367-46c3e374ff36', 'f4fa1e51-e5fc-5e29-96de-f09f0dfbb204', 4, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 4

Questions 1-4
Questions 1-4
The passage has eight paragraphs labelled
A-F
Which paragraph contains the following information?
Write the correct letter
A-F
in boxes
1-4
on your answer sheet.
NB
You
may use
any
letter
more than once
.
1
the natural process of oxygen production
Locate
2
standard after-competition procedure
Locate
3
the areas of study undertaken to improve athletic performance
Locate
4
the Mexican viewpoint on winning
Locate

4 ____ the Mexican viewpoint on winning Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d2f20928-5219-51a1-b895-1241a1f950e4', '06b537fd-f0fb-577d-b367-46c3e374ff36', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('08ac5ee8-f279-5f34-aaad-4e1c75e65b0a', '06b537fd-f0fb-577d-b367-46c3e374ff36', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9367d299-fe9b-54e7-b1f6-f398a7e9c655', '06b537fd-f0fb-577d-b367-46c3e374ff36', 3, $md$C$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('20e2eb04-443a-54e9-a546-d573f56f0d53', '06b537fd-f0fb-577d-b367-46c3e374ff36', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('22f7e9a7-da41-55e6-bdc6-aa7aaa8018c3', '06b537fd-f0fb-577d-b367-46c3e374ff36', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('348a86f9-2f9d-52b2-ac32-1e8976b5484c', '06b537fd-f0fb-577d-b367-46c3e374ff36', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('17d56076-d546-59fb-9a35-45ffba3e2fce', '06b537fd-f0fb-577d-b367-46c3e374ff36', 7, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('30c8ed15-1db2-5c6b-afee-2d3b0b7be2db', '06b537fd-f0fb-577d-b367-46c3e374ff36', 8, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e667576a-ab91-5c9e-98a5-5059617ae0da', '06b537fd-f0fb-577d-b367-46c3e374ff36', 9, $md$C$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fdc7bb00-ccfb-5e7f-a851-e1fd37cccdb9', '06b537fd-f0fb-577d-b367-46c3e374ff36', 10, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cd2d343c-d8ef-5093-a879-6b040761f556', '06b537fd-f0fb-577d-b367-46c3e374ff36', 11, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7d510e4c-7561-534f-b196-b65a2cd9fd3f', '06b537fd-f0fb-577d-b367-46c3e374ff36', 12, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2242b92e-a368-5fe1-9198-44456f31dbf6', '06b537fd-f0fb-577d-b367-46c3e374ff36', 13, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6c7e8e7d-b6d4-57a7-bae4-fafa50ec3ea3', '06b537fd-f0fb-577d-b367-46c3e374ff36', 14, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c824520c-5e32-5d55-9e21-adefba88c5d0', '06b537fd-f0fb-577d-b367-46c3e374ff36', 15, $md$C$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5aacaf97-17cf-5567-8887-b081b7580b4f', '06b537fd-f0fb-577d-b367-46c3e374ff36', 16, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7a8a61d9-5d39-5578-90ab-f04eb22c70f1', '06b537fd-f0fb-577d-b367-46c3e374ff36', 17, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9d59e69b-8897-5281-a4cc-0c178eb60cc6', '06b537fd-f0fb-577d-b367-46c3e374ff36', 18, $md$F$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('eb14a44f-d794-58c3-ad60-1b5ff37c7191', 'f4fa1e51-e5fc-5e29-96de-f09f0dfbb204', 5, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 5

Questions 5-7
Questions 5-7
Choose the correct letter
A, B, C, or D
.
Write your answers in boxes
5-7
on your answer sheet.
5.
The hyperbaric chamber
A
. helps athletes to breathe more easily.
B
. increases the level of oxygen an athlete breathes.
C
. decreases the pressure of the oxygen for Mexican athletes.
D
. speeds up recovery time for athletes.
Locate
6.
The electroencephalograph (EEC)
A
. measures how fast brainwaves move during exercise.
B
. helps doctors to determine heart problems.
C
. measures how hard the heart works during exercise.
D
. strengthens the heart muscle in athletes.
Locate
7.
The life-span of individuals in Mexico has increased due to
A
. medical improvements.
B
. more committed doctors.
C
. better made sporting equipment.
D
. advances in ergonomics.
Locate

Choose the correct letter A, B, C, or D .$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('337e5d9e-e718-5a32-9e89-ac98d7e6ddc8', 'f4fa1e51-e5fc-5e29-96de-f09f0dfbb204', 6, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 6

Questions 5-7
Questions 5-7
Choose the correct letter
A, B, C, or D
.
Write your answers in boxes
5-7
on your answer sheet.
5.
The hyperbaric chamber
A
. helps athletes to breathe more easily.
B
. increases the level of oxygen an athlete breathes.
C
. decreases the pressure of the oxygen for Mexican athletes.
D
. speeds up recovery time for athletes.
Locate
6.
The electroencephalograph (EEC)
A
. measures how fast brainwaves move during exercise.
B
. helps doctors to determine heart problems.
C
. measures how hard the heart works during exercise.
D
. strengthens the heart muscle in athletes.
Locate
7.
The life-span of individuals in Mexico has increased due to
A
. medical improvements.
B
. more committed doctors.
C
. better made sporting equipment.
D
. advances in ergonomics.
Locate

Choose the correct letter A, B, C, or D .$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('53ad6c3a-9256-5087-a365-8dc84c7260a6', 'f4fa1e51-e5fc-5e29-96de-f09f0dfbb204', 7, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 7

Questions 5-7
Questions 5-7
Choose the correct letter
A, B, C, or D
.
Write your answers in boxes
5-7
on your answer sheet.
5.
The hyperbaric chamber
A
. helps athletes to breathe more easily.
B
. increases the level of oxygen an athlete breathes.
C
. decreases the pressure of the oxygen for Mexican athletes.
D
. speeds up recovery time for athletes.
Locate
6.
The electroencephalograph (EEC)
A
. measures how fast brainwaves move during exercise.
B
. helps doctors to determine heart problems.
C
. measures how hard the heart works during exercise.
D
. strengthens the heart muscle in athletes.
Locate
7.
The life-span of individuals in Mexico has increased due to
A
. medical improvements.
B
. more committed doctors.
C
. better made sporting equipment.
D
. advances in ergonomics.
Locate

Choose the correct letter A, B, C, or D .$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('5171b6f1-6177-5428-9dc7-015fba2032ba', 'f4fa1e51-e5fc-5e29-96de-f09f0dfbb204', 8, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 8

Questions 8-13
Questions 8-13
Do the following statements agree with the information given in Reading Passage?
In boxes
8-13
on your answer sheet write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
8
There are limits to the level of sporting enquiry.
Locate
9
Specific athletic programs differ mostly between men and women
10
Mexico and Germany have similar sporting resources.
Locate
11
Lack of money is what stops athletic improvement in some poor countries.
Locate
12
Wealthy countries enjoy greater athletic success.
13
Mexican athletes have the support of their government.
Locate

8 ____ There are limits to the level of sporting enquiry. Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f38a7bae-8ea0-57c0-a1fa-212d6515769e', '5171b6f1-6177-5428-9dc7-015fba2032ba', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7391859c-9e9e-5a45-b6c1-33efb76b2c30', '5171b6f1-6177-5428-9dc7-015fba2032ba', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8818e9b2-7139-56fb-9e37-cbba54906995', '5171b6f1-6177-5428-9dc7-015fba2032ba', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('71ba2b10-980a-51cf-b5d1-332e6c764ae6', 'f4fa1e51-e5fc-5e29-96de-f09f0dfbb204', 9, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 9

Questions 8-13
Questions 8-13
Do the following statements agree with the information given in Reading Passage?
In boxes
8-13
on your answer sheet write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
8
There are limits to the level of sporting enquiry.
Locate
9
Specific athletic programs differ mostly between men and women
10
Mexico and Germany have similar sporting resources.
Locate
11
Lack of money is what stops athletic improvement in some poor countries.
Locate
12
Wealthy countries enjoy greater athletic success.
13
Mexican athletes have the support of their government.
Locate

9 ____ Specific athletic programs differ mostly between men and women$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('09423ef7-5e65-5674-b10f-c157b9c3051e', '71ba2b10-980a-51cf-b5d1-332e6c764ae6', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2d0f4989-3f15-5097-87af-f0994136691f', '71ba2b10-980a-51cf-b5d1-332e6c764ae6', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('47df0f36-f96a-5102-b3f2-fb8602d1d5b1', '71ba2b10-980a-51cf-b5d1-332e6c764ae6', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('d5f93168-ef3c-5f45-a72e-169f6ffbace3', 'f4fa1e51-e5fc-5e29-96de-f09f0dfbb204', 10, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 10

Questions 8-13
Questions 8-13
Do the following statements agree with the information given in Reading Passage?
In boxes
8-13
on your answer sheet write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
8
There are limits to the level of sporting enquiry.
Locate
9
Specific athletic programs differ mostly between men and women
10
Mexico and Germany have similar sporting resources.
Locate
11
Lack of money is what stops athletic improvement in some poor countries.
Locate
12
Wealthy countries enjoy greater athletic success.
13
Mexican athletes have the support of their government.
Locate

10 ____ Mexico and Germany have similar sporting resources. Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d15000c5-04a5-5a9b-adf0-b0a6f8dd24fe', 'd5f93168-ef3c-5f45-a72e-169f6ffbace3', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ebe13d45-c0b6-58bd-9d7a-d889ffea8807', 'd5f93168-ef3c-5f45-a72e-169f6ffbace3', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('39c74814-d7c3-5bfe-9039-368e3c4a1cf2', 'd5f93168-ef3c-5f45-a72e-169f6ffbace3', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('9ce7d207-1d0e-5ce5-acf7-a44f55e0301a', 'f4fa1e51-e5fc-5e29-96de-f09f0dfbb204', 11, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 11

Questions 8-13
Questions 8-13
Do the following statements agree with the information given in Reading Passage?
In boxes
8-13
on your answer sheet write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
8
There are limits to the level of sporting enquiry.
Locate
9
Specific athletic programs differ mostly between men and women
10
Mexico and Germany have similar sporting resources.
Locate
11
Lack of money is what stops athletic improvement in some poor countries.
Locate
12
Wealthy countries enjoy greater athletic success.
13
Mexican athletes have the support of their government.
Locate

11 ____ Lack of money is what stops athletic improvement in some poor countries. Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('721be0a3-abf3-51e1-97f4-9abdd3236c69', '9ce7d207-1d0e-5ce5-acf7-a44f55e0301a', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('62e0dee8-ed3c-57e4-9cb8-b5fafd4f3ebc', '9ce7d207-1d0e-5ce5-acf7-a44f55e0301a', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e0509904-e0bf-5905-8042-763b7a8f0a90', '9ce7d207-1d0e-5ce5-acf7-a44f55e0301a', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('58f169fc-82c4-5d95-9d6c-4bd9351e6df6', 'f4fa1e51-e5fc-5e29-96de-f09f0dfbb204', 12, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 12

Questions 8-13
Questions 8-13
Do the following statements agree with the information given in Reading Passage?
In boxes
8-13
on your answer sheet write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
8
There are limits to the level of sporting enquiry.
Locate
9
Specific athletic programs differ mostly between men and women
10
Mexico and Germany have similar sporting resources.
Locate
11
Lack of money is what stops athletic improvement in some poor countries.
Locate
12
Wealthy countries enjoy greater athletic success.
13
Mexican athletes have the support of their government.
Locate

12 ____ Wealthy countries enjoy greater athletic success.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('62491198-6c4f-56db-b9f3-01cca1a106eb', '58f169fc-82c4-5d95-9d6c-4bd9351e6df6', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5162ddc4-7e47-5dd4-b9dd-fe0ef020013c', '58f169fc-82c4-5d95-9d6c-4bd9351e6df6', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('988fc717-fd9c-566c-b428-228295c30221', '58f169fc-82c4-5d95-9d6c-4bd9351e6df6', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('4ac11fe6-f016-5433-abfe-a1959fe3382c', 'f4fa1e51-e5fc-5e29-96de-f09f0dfbb204', 13, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 13

Questions 8-13
Questions 8-13
Do the following statements agree with the information given in Reading Passage?
In boxes
8-13
on your answer sheet write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
8
There are limits to the level of sporting enquiry.
Locate
9
Specific athletic programs differ mostly between men and women
10
Mexico and Germany have similar sporting resources.
Locate
11
Lack of money is what stops athletic improvement in some poor countries.
Locate
12
Wealthy countries enjoy greater athletic success.
13
Mexican athletes have the support of their government.
Locate

13 ____ Mexican athletes have the support of their government. Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9e218e84-87c5-5af3-848e-e5751c6bc4cb', '4ac11fe6-f016-5433-abfe-a1959fe3382c', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('39b79ec6-7a4b-55f8-b951-204f3bb0ae61', '4ac11fe6-f016-5433-abfe-a1959fe3382c', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('784bd62d-42b9-57e0-9d3b-fae352ac2a64', '4ac11fe6-f016-5433-abfe-a1959fe3382c', 3, $md$NOT GIVEN$md$, false);

COMMIT;
