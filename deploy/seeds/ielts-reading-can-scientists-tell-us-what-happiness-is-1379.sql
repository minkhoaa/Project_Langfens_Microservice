BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-can-scientists-tell-us-what-happiness-is-1379'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-can-scientists-tell-us-what-happiness-is-1379';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-can-scientists-tell-us-what-happiness-is-1379';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-can-scientists-tell-us-what-happiness-is-1379';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('fe6898cc-f483-5980-a2cd-f0a3adf68ba3', 'ielts-reading-can-scientists-tell-us-what-happiness-is-1379', $t$Can Scientists tell us: What happiness is?$t$, $md$## Can Scientists tell us: What happiness is?

Nguồn:
- Test: https://mini-ielts.com/1379/reading/can-scientists-tell-us-what-happiness-is
- Solution: https://mini-ielts.com/1379/view-solution/reading/can-scientists-tell-us-what-happiness-is$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('09bc5a9f-d3bf-5ba4-810c-207bd5f71fae', 'fe6898cc-f483-5980-a2cd-f0a3adf68ba3', 1, $t$Reading — Can Scientists tell us: What happiness is?$t$, $md$Read the passage and answer questions **1–13**.

### Passage: Can Scientists tell us: What happiness is?

A

Economists accept that if people describe themselves as happy, then they are happy. However, psychologists differentiate between levels of happiness. The most immediate type involves a feeling; pleasure or joy. But sometimes happiness is a judgment that life is satisfying, and does not imply an emotional state. Esteemed psychologist Martin Seligman has spearheaded an effort to study the science of happiness. The bad news is that we’re not wired to be happy. The good news is that we can do something about it. Since its origins in a Leipzig laboratory 130 years ago, psychology has had little to say about goodness and contentment. Mostly psychologists have concerned themselves with weakness and misery. There are libraries full of theories about why we get sad, worried, and angry. It hasn’t been respectable science to study what happens when lives go well. Positive experiences, such as joy, kindness, altruism and heroism, have mainly been ignored. For every 100 psychology papers dealing with anxiety or depression, only one concerns a positive trait.

B

A few pioneers in experimental psychology bucked the trend. Professor Alice Isen of Cornell University and colleagues have demonstrated how positive emotions make people think faster and more creatively. Showing how easy it is to give people an intellectual boost, Isen divided doctors making a tricky diagnosis into three groups: one received candy, one read humanistic statements about medicine, one was a control group. The doctors who had candy displayed the most creative thinking and worked more efficiently. Inspired by Isen and others, Seligman got stuck in. He raised millions of dollars of research money and funded 50 research groups involving 150 scientists across the world. Four positive psychology centres opened, decorated in cheerful colours and furnished with sofas and baby-sitters. There were get-togethers on Mexican beaches where psychologists would snorkel and eat fajitas, then form “pods” to discuss subjects such as wonder and awe. A thousand therapists were coached in the new science.

C

But critics are demanding answers to big questions. What is the point of defining levels of haziness and classifying the virtues? Aren’t these concepts vague and impossible to pin down? Can you justify spending funds to research positive states when there are problems such as famine, flood and epidemic depression to be solved? Seligman knows his work can be belittled alongside trite notions such as “the power of positive thinking”. His plan to stop the new science floating “on the waves of self- improvement fashion” is to make sure it is anchored to positive philosophy above, and to positive biology below.

D

And this takes us back to our evolutionary past Homo sapiens evolved during the Pleistocene era (1.8 m to 10,000 years ago), a time of hardship and turmoil. It was the Ice Age, and our ancestors endured long freezes as glaciers formed, then ferocious floods as the ice masses melted. We shared the planet with terrifying creatures such as mammoths, elephant-sized ground sloths and sabre-toothed cats. But by the end of the Pleistocene, all these animals were extinct. Humans, on the other hand, had evolved large brains and used their intelligence to make fire and sophisticated tools, to develop talk and social rituals. Survival in a time of adversity forged our brains into a persistent mould. Professor Seligman says: “Because our brain evolved during a time of ice, flood and famine, we have a catastrophic brain. The way the brain works is looking for what’s wrong. The problem is, that worked in the Pleistocene era. It favoured you, but it doesn’t work in the modem world”.

E

Although most people rate themselves as happy, there is a wealth of evidence to show that negative thinking is deeply ingrained in the human psyche. Experiments show that we remember failures more vividly than success. We dwell on what went badly, not what went well. Of the six universal emotions, four anger, fear, disgust and sadness are negative and only one, joy, is positive. (The sixth, surprise, is neutral). According to the psychologist Daniel Nettle, author of Happiness, and one of the Royal Institution lectures, the negative emotion each tells us “something bad has happened” and suggest a different course of action.

F

What is it about the structure of the brain that underlies our bias towards negative thinking? And is there a biology of joy? At Iowa University, neuroscientist studied what happens when people are shown pleasant and unpleasant pictures. When subjects see landscapes or dolphins playing, part of the frontal lobe of the brain becomes active. But when they are shown unpleasant images a bird covered in oil, or a dead soldier with part of his face missing the response comes from more primitive parts of the brain. The ability to feel negative emotions derives from an ancient danger-recognition system formed early in the brain’s evolution. The pre-frontal cortex, which registers happiness, is the part used for higher thinking, an area that evolved later in human history.

G

Our difficulty, according to Daniel Nettle, is that the brain systems for liking and wanting are separate. Wanting involves two ancient regions the amygdala and the nucleus accumbens that communicate using the chemical dopamine to form the brain’s reward system. They are involved in anticipating the pleasure of eating and in addiction to drugs. A rat will press a bar repeatedly， ignoring sexually available partners, to receive electrical stimulation of the “wanting” parts of the brain. But having received brain stimulation, the rat eats more but shows no sign of enjoying the food it craved. In humans, a drug like nicotine produces much craving but little pleasure.

H

In essence, what the biology lesson tells us is that negative emotions are fundamental to the human condition and it’s no wonder they are difficult to eradicate. At the same time, by a trick of nature, our brains are designed to crave but never really achieve lasting happiness.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('b70210d3-0737-5886-930f-d9dbfde390ec', '09bc5a9f-d3bf-5ba4-810c-207bd5f71fae', 1, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 1

Questions 1-7
Questions 1-7
The reading Passage has seven paragraphs
A-H
.
Which paragraph contains the following information?
Write the correct letter
A-H
, in boxes
1-7
on your answer sheet.
1
An experiment involving dividing several groups one of which received positive icon
2
Review of a poorly researched psychology area
3
Contrast being made about the brains’ action as response to positive or negative stimulus
4
The skeptical attitude toward the research seemed to be a waste of fund
5
a substance that produces much wanting instead of much liking
6
a conclusion that lasting happiness is hardly obtained because of the nature of brains
7
One description that listed the human emotional categories.

1 ____ An experiment involving dividing several groups one of which received positive icon$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4cc4e5bd-c170-58ad-8ab8-a3404e2c2db1', 'b70210d3-0737-5886-930f-d9dbfde390ec', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('171ff0f3-92fd-5829-a0b7-14f549f3323c', 'b70210d3-0737-5886-930f-d9dbfde390ec', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('202f77b7-8937-5e61-9cdf-a6e72ddcb3ee', 'b70210d3-0737-5886-930f-d9dbfde390ec', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('491f552a-93ba-5997-8cdb-ed6382c2d7c3', 'b70210d3-0737-5886-930f-d9dbfde390ec', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1b0b88e6-65ea-5d62-97bd-54442f352936', 'b70210d3-0737-5886-930f-d9dbfde390ec', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d8a4b80c-ef83-51d5-8cf0-016217bdff01', 'b70210d3-0737-5886-930f-d9dbfde390ec', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6d110176-e529-57d2-a823-220c673165f4', 'b70210d3-0737-5886-930f-d9dbfde390ec', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1a49c976-b7f2-5dd7-b424-9cd1bda4d120', 'b70210d3-0737-5886-930f-d9dbfde390ec', 8, $md$H$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('f6e7ba9c-d540-5f38-96ed-c15d365667b5', '09bc5a9f-d3bf-5ba4-810c-207bd5f71fae', 2, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 2

Questions 1-7
Questions 1-7
The reading Passage has seven paragraphs
A-H
.
Which paragraph contains the following information?
Write the correct letter
A-H
, in boxes
1-7
on your answer sheet.
1
An experiment involving dividing several groups one of which received positive icon
2
Review of a poorly researched psychology area
3
Contrast being made about the brains’ action as response to positive or negative stimulus
4
The skeptical attitude toward the research seemed to be a waste of fund
5
a substance that produces much wanting instead of much liking
6
a conclusion that lasting happiness is hardly obtained because of the nature of brains
7
One description that listed the human emotional categories.

2 ____ Review of a poorly researched psychology area$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7ee6dcd4-f833-58be-b061-4a5142d21681', 'f6e7ba9c-d540-5f38-96ed-c15d365667b5', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4990a719-db94-5362-a12b-d732ad46a1ce', 'f6e7ba9c-d540-5f38-96ed-c15d365667b5', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('52e0a653-005d-510b-a606-0e29f8fbee0a', 'f6e7ba9c-d540-5f38-96ed-c15d365667b5', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('939a8d3c-fe0d-562d-915d-3bf0f07a7944', 'f6e7ba9c-d540-5f38-96ed-c15d365667b5', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cf0c0735-9f85-5fd9-961f-290ad3a065f0', 'f6e7ba9c-d540-5f38-96ed-c15d365667b5', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f4e6efd8-6e85-5272-8ec1-2077798659a2', 'f6e7ba9c-d540-5f38-96ed-c15d365667b5', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('41a2c0de-a8bb-5a4e-8651-eb1942f8194f', 'f6e7ba9c-d540-5f38-96ed-c15d365667b5', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fb400c55-92a0-5b2e-ad19-73384ef18985', 'f6e7ba9c-d540-5f38-96ed-c15d365667b5', 8, $md$H$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('566a957c-7fc1-5065-876f-457e9f79e42f', '09bc5a9f-d3bf-5ba4-810c-207bd5f71fae', 3, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 3

Questions 1-7
Questions 1-7
The reading Passage has seven paragraphs
A-H
.
Which paragraph contains the following information?
Write the correct letter
A-H
, in boxes
1-7
on your answer sheet.
1
An experiment involving dividing several groups one of which received positive icon
2
Review of a poorly researched psychology area
3
Contrast being made about the brains’ action as response to positive or negative stimulus
4
The skeptical attitude toward the research seemed to be a waste of fund
5
a substance that produces much wanting instead of much liking
6
a conclusion that lasting happiness is hardly obtained because of the nature of brains
7
One description that listed the human emotional categories.

3 ____ Contrast being made about the brains’ action as response to positive or negative stimulus$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6035749b-ec9e-5034-9321-29b2d1f8824f', '566a957c-7fc1-5065-876f-457e9f79e42f', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b4bec93b-48cb-5d4e-bd83-d9ec137a284c', '566a957c-7fc1-5065-876f-457e9f79e42f', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9b7b7441-51ff-5af5-884c-41cdf501a22c', '566a957c-7fc1-5065-876f-457e9f79e42f', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('88106dc6-0801-5b2b-b955-0552a366bb85', '566a957c-7fc1-5065-876f-457e9f79e42f', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d67a9c79-f6b7-5629-9feb-3a5333edb10b', '566a957c-7fc1-5065-876f-457e9f79e42f', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('10aae99d-9ea0-52b3-b2ee-33b94c7437ff', '566a957c-7fc1-5065-876f-457e9f79e42f', 6, $md$F$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b085e2a8-9a6c-52f5-ba6e-0739c9b0df23', '566a957c-7fc1-5065-876f-457e9f79e42f', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0cae9ad6-261e-55ed-ba32-6eb759e7489d', '566a957c-7fc1-5065-876f-457e9f79e42f', 8, $md$H$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('660a930c-07ed-5add-8a6d-6f194cbbf4c3', '09bc5a9f-d3bf-5ba4-810c-207bd5f71fae', 4, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 4

Questions 1-7
Questions 1-7
The reading Passage has seven paragraphs
A-H
.
Which paragraph contains the following information?
Write the correct letter
A-H
, in boxes
1-7
on your answer sheet.
1
An experiment involving dividing several groups one of which received positive icon
2
Review of a poorly researched psychology area
3
Contrast being made about the brains’ action as response to positive or negative stimulus
4
The skeptical attitude toward the research seemed to be a waste of fund
5
a substance that produces much wanting instead of much liking
6
a conclusion that lasting happiness is hardly obtained because of the nature of brains
7
One description that listed the human emotional categories.

4 ____ The skeptical attitude toward the research seemed to be a waste of fund$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5b6b3939-d03c-55ac-a5ed-4d2950b599db', '660a930c-07ed-5add-8a6d-6f194cbbf4c3', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5f78950f-f508-5b15-9d95-6d29d18cb46b', '660a930c-07ed-5add-8a6d-6f194cbbf4c3', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8450e389-dd6f-5485-b9ec-9febb16548dd', '660a930c-07ed-5add-8a6d-6f194cbbf4c3', 3, $md$C$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3b1591b8-575a-50b6-8955-3073462646d6', '660a930c-07ed-5add-8a6d-6f194cbbf4c3', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('402d0b1c-1b1a-5a86-a183-3d2f9f281322', '660a930c-07ed-5add-8a6d-6f194cbbf4c3', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cdab4a4d-e512-5ed3-9364-58df586b0a7f', '660a930c-07ed-5add-8a6d-6f194cbbf4c3', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c9eb068c-34e7-5b2f-982d-8076c8561efe', '660a930c-07ed-5add-8a6d-6f194cbbf4c3', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3e9e078c-f0e0-5fce-ab0a-ec2a38bc4480', '660a930c-07ed-5add-8a6d-6f194cbbf4c3', 8, $md$H$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('fe6fb903-2616-50c1-a642-de2c64a619b3', '09bc5a9f-d3bf-5ba4-810c-207bd5f71fae', 5, 'MATCHING_INFORMATION', 'READING', 3, $md$### Question 5

Questions 1-7
Questions 1-7
The reading Passage has seven paragraphs
A-H
.
Which paragraph contains the following information?
Write the correct letter
A-H
, in boxes
1-7
on your answer sheet.
1
An experiment involving dividing several groups one of which received positive icon
2
Review of a poorly researched psychology area
3
Contrast being made about the brains’ action as response to positive or negative stimulus
4
The skeptical attitude toward the research seemed to be a waste of fund
5
a substance that produces much wanting instead of much liking
6
a conclusion that lasting happiness is hardly obtained because of the nature of brains
7
One description that listed the human emotional categories.

5 ____ a substance that produces much wanting instead of much liking$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cc358b9f-a24a-54b8-98c4-8282a4b14a12', 'fe6fb903-2616-50c1-a642-de2c64a619b3', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d3bc2593-bba3-5ce9-80a2-9811e2e29ce7', 'fe6fb903-2616-50c1-a642-de2c64a619b3', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d2ee620a-f9fa-51bb-a629-e2b5568026e4', 'fe6fb903-2616-50c1-a642-de2c64a619b3', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f02b7992-b77e-5ffe-950b-cf4c113b94f3', 'fe6fb903-2616-50c1-a642-de2c64a619b3', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('188d81e3-9fe8-537c-805e-9f1ee8997d27', 'fe6fb903-2616-50c1-a642-de2c64a619b3', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4c39665b-d710-5a5a-a639-06030bae2d70', 'fe6fb903-2616-50c1-a642-de2c64a619b3', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8b2fe6aa-fb54-544d-846b-57d93509b5da', 'fe6fb903-2616-50c1-a642-de2c64a619b3', 7, $md$G$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7ad92ab8-cc47-5537-8a2a-211278722a55', 'fe6fb903-2616-50c1-a642-de2c64a619b3', 8, $md$H$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('98d553fc-9d38-512f-8747-53f6c5d4074b', '09bc5a9f-d3bf-5ba4-810c-207bd5f71fae', 6, 'MATCHING_INFORMATION', 'READING', 3, $md$### Question 6

Questions 1-7
Questions 1-7
The reading Passage has seven paragraphs
A-H
.
Which paragraph contains the following information?
Write the correct letter
A-H
, in boxes
1-7
on your answer sheet.
1
An experiment involving dividing several groups one of which received positive icon
2
Review of a poorly researched psychology area
3
Contrast being made about the brains’ action as response to positive or negative stimulus
4
The skeptical attitude toward the research seemed to be a waste of fund
5
a substance that produces much wanting instead of much liking
6
a conclusion that lasting happiness is hardly obtained because of the nature of brains
7
One description that listed the human emotional categories.

6 ____ a conclusion that lasting happiness is hardly obtained because of the nature of brains$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('574a01ed-cb64-5e0c-b873-3d0912795206', '98d553fc-9d38-512f-8747-53f6c5d4074b', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('871a5166-547a-56a9-96fa-c253f0f822f8', '98d553fc-9d38-512f-8747-53f6c5d4074b', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f8d57e68-d31f-5889-8d88-af8ef51a2d2a', '98d553fc-9d38-512f-8747-53f6c5d4074b', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5ebc54f3-5977-578e-9db4-626f83e91b11', '98d553fc-9d38-512f-8747-53f6c5d4074b', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0447c595-1363-5543-a351-0d75750073e9', '98d553fc-9d38-512f-8747-53f6c5d4074b', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('dc52ad22-3dbf-540d-bf08-11d13fe73a29', '98d553fc-9d38-512f-8747-53f6c5d4074b', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d2f14c83-6ee9-59f3-bf7d-86279012d87c', '98d553fc-9d38-512f-8747-53f6c5d4074b', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a5eb66c0-76b0-57bb-a9b2-b78037679d7b', '98d553fc-9d38-512f-8747-53f6c5d4074b', 8, $md$H$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('76fdb301-f7d4-5164-9d3f-8b04464c687a', '09bc5a9f-d3bf-5ba4-810c-207bd5f71fae', 7, 'MATCHING_INFORMATION', 'READING', 3, $md$### Question 7

Questions 1-7
Questions 1-7
The reading Passage has seven paragraphs
A-H
.
Which paragraph contains the following information?
Write the correct letter
A-H
, in boxes
1-7
on your answer sheet.
1
An experiment involving dividing several groups one of which received positive icon
2
Review of a poorly researched psychology area
3
Contrast being made about the brains’ action as response to positive or negative stimulus
4
The skeptical attitude toward the research seemed to be a waste of fund
5
a substance that produces much wanting instead of much liking
6
a conclusion that lasting happiness is hardly obtained because of the nature of brains
7
One description that listed the human emotional categories.

7 ____ One description that listed the human emotional categories.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d6894b72-5f4f-5e42-a186-5173c063d2d3', '76fdb301-f7d4-5164-9d3f-8b04464c687a', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2ffcc097-f5c2-5dd4-a988-8242f35f9a72', '76fdb301-f7d4-5164-9d3f-8b04464c687a', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('069bdc18-9f1a-5755-be29-cbcbf55d9a67', '76fdb301-f7d4-5164-9d3f-8b04464c687a', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('53135e51-2288-5d42-81c3-80da85ed36b5', '76fdb301-f7d4-5164-9d3f-8b04464c687a', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('18b3faaf-a7df-5c79-b2c3-8debed739df2', '76fdb301-f7d4-5164-9d3f-8b04464c687a', 5, $md$E$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5fdf82bf-0c5a-5fe0-b35c-447ab400baa8', '76fdb301-f7d4-5164-9d3f-8b04464c687a', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('83123af3-d7d3-5adb-a822-d6f5b7375269', '76fdb301-f7d4-5164-9d3f-8b04464c687a', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('55ad80ef-029c-559a-8b7a-e7efd9e5c55a', '76fdb301-f7d4-5164-9d3f-8b04464c687a', 8, $md$H$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('1e44fb7b-7229-5e81-9325-b67b0f08cda9', '09bc5a9f-d3bf-5ba4-810c-207bd5f71fae', 8, 'SUMMARY_COMPLETION', 'READING', 3, $md$### Question 8

Questions 8-12
Questions 8-12
Complete the following summary of the paragraphs of Reading Passage
Using
NO MORE THAN FOUR WORDS
from the Reading Passage for each answer.
Write your answers in boxes
8-12
on your answer sheet.
A few pioneers in experimental psychology study what happens when lives go well. Professor Alice divided doctors, making a tricky experiment, into three groups: besides the one control group, the other two either are asked to read humanistic statements about drugs or received
8
The latter displayed the most creative thinking and worked more efficiently. Since critics are questioning the significance of the
9
for both levels of happiness and classification for the virtues. Professor Seligman countered in an evolutional theory: survival in a time of adversity forged our brains into the way of thinking for what’s wrong because we have a
10
.
There is bountiful of evidence to show that negative thinking is deeply built in the human psyche. Later, at Iowa University, neuroscientists studied the active parts in brains to contrast when people are shown pleasant and unpleasant pictures. When positive images like
11
are shown, part of the frontal lobe of the brain becomes active. But when they are shown unpleasant image, the response comes from
12
of the brain.

A few pioneers in experimental psychology study what happens when lives go well. Professor Alice divided doctors, making a tricky experiment, into three groups: besides the one control group, the other two either are asked to read humanistic statements about drugs or received 8 ____ The latter displayed the most creative thinking and worked more efficiently. Since critics are questioning the significance of the 9 ____ for both levels of happiness and classification for the virtues. Professor Seligman countered in an evolutional theory: survival in a time of adversity forged our brains into the way of thinking for what’s wrong because we have a 10 ____ .$md$, NULL, ARRAY['.*candy.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('2434862c-f18d-58a9-b45b-8acd670f7b9c', '09bc5a9f-d3bf-5ba4-810c-207bd5f71fae', 9, 'SUMMARY_COMPLETION', 'READING', 3, $md$### Question 9

Questions 8-12
Questions 8-12
Complete the following summary of the paragraphs of Reading Passage
Using
NO MORE THAN FOUR WORDS
from the Reading Passage for each answer.
Write your answers in boxes
8-12
on your answer sheet.
A few pioneers in experimental psychology study what happens when lives go well. Professor Alice divided doctors, making a tricky experiment, into three groups: besides the one control group, the other two either are asked to read humanistic statements about drugs or received
8
The latter displayed the most creative thinking and worked more efficiently. Since critics are questioning the significance of the
9
for both levels of happiness and classification for the virtues. Professor Seligman countered in an evolutional theory: survival in a time of adversity forged our brains into the way of thinking for what’s wrong because we have a
10
.
There is bountiful of evidence to show that negative thinking is deeply built in the human psyche. Later, at Iowa University, neuroscientists studied the active parts in brains to contrast when people are shown pleasant and unpleasant pictures. When positive images like
11
are shown, part of the frontal lobe of the brain becomes active. But when they are shown unpleasant image, the response comes from
12
of the brain.

A few pioneers in experimental psychology study what happens when lives go well. Professor Alice divided doctors, making a tricky experiment, into three groups: besides the one control group, the other two either are asked to read humanistic statements about drugs or received 8 ____ The latter displayed the most creative thinking and worked more efficiently. Since critics are questioning the significance of the 9 ____ for both levels of happiness and classification for the virtues. Professor Seligman countered in an evolutional theory: survival in a time of adversity forged our brains into the way of thinking for what’s wrong because we have a 10 ____ .$md$, NULL, ARRAY['.*candy.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('00d5b8bd-8e25-5e4c-80ef-b625cb97f1cb', '09bc5a9f-d3bf-5ba4-810c-207bd5f71fae', 10, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 10

Questions 8-12
Questions 8-12
Complete the following summary of the paragraphs of Reading Passage
Using
NO MORE THAN FOUR WORDS
from the Reading Passage for each answer.
Write your answers in boxes
8-12
on your answer sheet.
A few pioneers in experimental psychology study what happens when lives go well. Professor Alice divided doctors, making a tricky experiment, into three groups: besides the one control group, the other two either are asked to read humanistic statements about drugs or received
8
The latter displayed the most creative thinking and worked more efficiently. Since critics are questioning the significance of the
9
for both levels of happiness and classification for the virtues. Professor Seligman countered in an evolutional theory: survival in a time of adversity forged our brains into the way of thinking for what’s wrong because we have a
10
.
There is bountiful of evidence to show that negative thinking is deeply built in the human psyche. Later, at Iowa University, neuroscientists studied the active parts in brains to contrast when people are shown pleasant and unpleasant pictures. When positive images like
11
are shown, part of the frontal lobe of the brain becomes active. But when they are shown unpleasant image, the response comes from
12
of the brain.

A few pioneers in experimental psychology study what happens when lives go well. Professor Alice divided doctors, making a tricky experiment, into three groups: besides the one control group, the other two either are asked to read humanistic statements about drugs or received 8 ____ The latter displayed the most creative thinking and worked more efficiently. Since critics are questioning the significance of the 9 ____ for both levels of happiness and classification for the virtues. Professor Seligman countered in an evolutional theory: survival in a time of adversity forged our brains into the way of thinking for what’s wrong because we have a 10 ____ .$md$, NULL, ARRAY['.*candy.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('9956aa48-03a5-51ea-a3b0-9b6252eef8d0', '09bc5a9f-d3bf-5ba4-810c-207bd5f71fae', 11, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 11

Questions 8-12
Questions 8-12
Complete the following summary of the paragraphs of Reading Passage
Using
NO MORE THAN FOUR WORDS
from the Reading Passage for each answer.
Write your answers in boxes
8-12
on your answer sheet.
A few pioneers in experimental psychology study what happens when lives go well. Professor Alice divided doctors, making a tricky experiment, into three groups: besides the one control group, the other two either are asked to read humanistic statements about drugs or received
8
The latter displayed the most creative thinking and worked more efficiently. Since critics are questioning the significance of the
9
for both levels of happiness and classification for the virtues. Professor Seligman countered in an evolutional theory: survival in a time of adversity forged our brains into the way of thinking for what’s wrong because we have a
10
.
There is bountiful of evidence to show that negative thinking is deeply built in the human psyche. Later, at Iowa University, neuroscientists studied the active parts in brains to contrast when people are shown pleasant and unpleasant pictures. When positive images like
11
are shown, part of the frontal lobe of the brain becomes active. But when they are shown unpleasant image, the response comes from
12
of the brain.

There is bountiful of evidence to show that negative thinking is deeply built in the human psyche. Later, at Iowa University, neuroscientists studied the active parts in brains to contrast when people are shown pleasant and unpleasant pictures. When positive images like 11 ____ are shown, part of the frontal lobe of the brain becomes active. But when they are shown unpleasant image, the response comes from 12 ____ of the brain.$md$, NULL, ARRAY['.*landscapes.*or.*dolphins.*playing.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('8a0b94e6-b3f2-542f-a385-287d48df18fc', '09bc5a9f-d3bf-5ba4-810c-207bd5f71fae', 12, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 12

Questions 8-12
Questions 8-12
Complete the following summary of the paragraphs of Reading Passage
Using
NO MORE THAN FOUR WORDS
from the Reading Passage for each answer.
Write your answers in boxes
8-12
on your answer sheet.
A few pioneers in experimental psychology study what happens when lives go well. Professor Alice divided doctors, making a tricky experiment, into three groups: besides the one control group, the other two either are asked to read humanistic statements about drugs or received
8
The latter displayed the most creative thinking and worked more efficiently. Since critics are questioning the significance of the
9
for both levels of happiness and classification for the virtues. Professor Seligman countered in an evolutional theory: survival in a time of adversity forged our brains into the way of thinking for what’s wrong because we have a
10
.
There is bountiful of evidence to show that negative thinking is deeply built in the human psyche. Later, at Iowa University, neuroscientists studied the active parts in brains to contrast when people are shown pleasant and unpleasant pictures. When positive images like
11
are shown, part of the frontal lobe of the brain becomes active. But when they are shown unpleasant image, the response comes from
12
of the brain.

There is bountiful of evidence to show that negative thinking is deeply built in the human psyche. Later, at Iowa University, neuroscientists studied the active parts in brains to contrast when people are shown pleasant and unpleasant pictures. When positive images like 11 ____ are shown, part of the frontal lobe of the brain becomes active. But when they are shown unpleasant image, the response comes from 12 ____ of the brain.$md$, NULL, ARRAY['.*landscapes.*or.*dolphins.*playing.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('0cb15458-3798-55a9-b7b9-6db28565f653', '09bc5a9f-d3bf-5ba4-810c-207bd5f71fae', 13, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 13

Question 13
Question 13
Choose the correct letter,
A
,
B
,
C
or
D
.
Write your answers in boxes
13
on your answer sheet.
According to Daniel Nettle in the last two paragraphs, what is true as the scientists can tell us about happiness
A
Brain systems always mix liking and wanting together.
B
Negative emotions can be easily rid of if we think positively.
C
Happiness is like nicotine we are craving for but get little pleasure.
D
The inner mechanism of human brains does not assist us to achieve durable happiness

Choose the correct letter, A , B , C or D .$md$, NULL);

COMMIT;
