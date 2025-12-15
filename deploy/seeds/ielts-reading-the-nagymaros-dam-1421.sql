BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-the-nagymaros-dam-1421'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-the-nagymaros-dam-1421';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-the-nagymaros-dam-1421';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-the-nagymaros-dam-1421';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('6d1f2572-25ba-5ca7-ae6f-fad5523c4198', 'ielts-reading-the-nagymaros-dam-1421', $t$The Nagymaros Dam$t$, $md$## The Nagymaros Dam

Nguồn:
- Test: https://mini-ielts.com/1421/reading/the-nagymaros-dam
- Solution: https://mini-ielts.com/1421/view-solution/reading/the-nagymaros-dam$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('8acafa7f-f4f5-5e82-a513-c91546144e68', '6d1f2572-25ba-5ca7-ae6f-fad5523c4198', 1, $t$Reading — The Nagymaros Dam$t$, $md$Read the passage and answer questions **1–14**.

### Passage: The Nagymaros Dam

When Janos Vargha, a biologist from the Hungarian Academy of Sciences, began a new career as a writer with a small monthly nature magazine called Buvar, it was 9 years after the story behind the fall of the Berlin Wall had started to unfold. During his early research, he went to a beauty spot on the river Danube outside Budapest known as the Danube Bend to interview local officials about plans to build a small park on the site of an ancient Hungarian capital.

One official mentioned that passing this tree-lined curve in the river, a popular tourism spot for Hungarians was monotonous. Also, it was to be submerged by a giant hydroelectric dam in secret by a much-feared state agency known simply as the Water Management.

Vargha investigated and learned that the Nagymaros dam (pronounced “nosh-marosh”) would cause pollution, destroy underground water reserves, dry out wetlands and wreck the unique ecosystem of central Europe’s longest river. Unfortunately, nobody objected. “Of course, I wrote an article. But there was a director of the Water Management on the magazine’s editorial board. The last time, he went to the printers and stopped the presses, the article was never published. I was frustrated and angry, but I was ultimately interested in why they cared to ban my article,” he remembers today.

He found that the Nagymaros dam was part of a joint project with neighbouring Czechoslovakia to produce hydroelectricity, irrigate farms and enhance navigation. They would build two dams and re-engineer the Danube for 200 kilometres where it created the border between them. “The Russians were working together, too. They wanted to take their big ships from the Black Sea right up the Danube to the border with Austria.”

Vargha was soon under vigorous investigation, and some of his articles got past the censors. He gathered supporters for some years, but he was one of only a few people who believed the dam should be stopped. He was hardly surprised when the Water Management refused to debate the project in public. After a public meeting, the bureaucrats had pulled out at the last minute. Vargha knew he had to take the next step. “We decided it wasn’t enough to talk and write, so we set up an organization, the Danube Circle. We announced that we didn’t agree with censorship. We would act as if we were living in a democracy.” he says.

The Danube Circle was illegal and the secret publications it produced turned out to be samizdat leaflets. In an extraordinary act of defiance, it gathered 10,000 signatures for a petition objecting to the dam and made links with environmentalists in the west, inviting them to Budapest for a press conference.

The Hungarian government enforced a news blackout on the dam, but articles about the Danube Circle began to be published and appear in the western media. In 1985, the Circle and Vargha, a public spokesman, won the Right Livelihood award known as the alternative Nobel prize. Officials told Vargha he should not take the prize but he ignored them. The following year when Austrian environmentalists joined a protest in Budapest, they were met with tear gas and batons. Then the Politburo had Vargha taken from his new job as editor of the Hungarian version of Scientific American.

The dam became a focus for opposition to the hated regime. Communists tried to hold back the waters in the Danube and resist the will of the people. Vargha says, “Opposing the state directly was still hard.” “Objecting to the dam was less of a hazard, but it was still considered a resistance to the state.”

Under increasing pressure from the anti-dam movement, the Hungarian Communist Party was divided. Vargha says, “Reformists found that the dam was not very popular and economical. It would be cheaper to generate electricity by burning coal or nuclear power.” “But hardliners were standing for Stalinist ideas of large dams which mean symbols of progress.” Environmental issues seemed to be a weak point of east European communism in its final years. During the 1970s under the support of the Young Communist Leagues, a host of environmental groups had been founded. Party officials saw them as a harmless product of youthful idealism created by Boy Scouts and natural history societies.

Green idealism steadily became a focal point for political opposition. In Czechoslovakia, the human rights of Charter 77 took up environmentalism. The green-minded people of both Poland and Estonia participated in the Friends of the Earth International to protest against air pollution. Bulgarian environmentalists built a resistance group, called Ecoglasnost, which held huge rallies in 1989. Big water engineering projects were potent symbols of the old Stalinism.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('ae38634b-0817-5aae-9482-a3fd3efc8946', '8acafa7f-f4f5-5e82-a513-c91546144e68', 1, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 1

Questions 1-8
Questions 1-8
Complete the summary, using the list of words and phrases,
A-L
, below.
Write the correct letter,
A-L
, in boxes
1-8
on your answer sheet.
The story of the fall of the Berlin Wall had started to unfold 9 years earlier, Janos Vargha visited the river Danube out of Budapest to discuss a matter of
1
with executives. However, unfortunately, the tree-lined curve in the river was
2
by a colossal dam which caused a lot of fear. He noticed the negative impact of the Nagymaros dam would be
3
on the ecosystem around the main river. Besides, the dam was engineering public works, generating hydroelectricity, irrigating farmlands and developing sailing trade which was
4
with a border of Czechoslovakia.
After one public meeting, Vargha
5
the Danube Circle for showing the autonomy of the people in a democracy. Despite every effort, he who would eventually become the editor of the Hungarian edition was
6
by the Politburo. Fortunately, with plenty of pressure from the anti-dam movement, east European communism’s final symbol was opposed by the
7
. Overall, between political processing and environmentalists have been on a
8
of views.
A
severe
B
discharged
C
constructing a park of small-scale
D
passed
E
reformist
F
swallowed up
G
separated
H
favourable
I
established
J
collision
K
combined
L
environmentalists

The story of the fall of the Berlin Wall had started to unfold 9 years earlier, Janos Vargha visited the river Danube out of Budapest to discuss a matter of 1 ____ with executives. However, unfortunately, the tree-lined curve in the river was 2 ____ by a colossal dam which caused a lot of fear. He noticed the negative impact of the Nagymaros dam would be 3 ____ on the ecosystem around the main river. Besides, the dam was engineering public works, generating hydroelectricity, irrigating farmlands and developing sailing trade which was 4 ____ with a border of Czechoslovakia.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('714e0cba-9a9e-5346-b033-d4019c1420f7', 'ae38634b-0817-5aae-9482-a3fd3efc8946', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5be7bad8-4215-5d48-b413-280d4ac7d024', 'ae38634b-0817-5aae-9482-a3fd3efc8946', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ed1e3cee-6366-56c1-93de-a6cce464a27d', 'ae38634b-0817-5aae-9482-a3fd3efc8946', 3, $md$C$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d134f2c8-c511-58da-b751-93e74ad94fa9', 'ae38634b-0817-5aae-9482-a3fd3efc8946', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8d0a7163-a6ea-5f8d-8059-1ead7c90fd99', 'ae38634b-0817-5aae-9482-a3fd3efc8946', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2dec6afc-6207-544d-b3e5-f9092374712c', 'ae38634b-0817-5aae-9482-a3fd3efc8946', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('eb37c69c-d092-5ccb-9ddf-c99e65deeb8d', 'ae38634b-0817-5aae-9482-a3fd3efc8946', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f678b794-3e2d-5eac-b237-a8506e209106', 'ae38634b-0817-5aae-9482-a3fd3efc8946', 8, $md$H$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5c395629-a1d2-51cb-8654-7086a44cf54d', 'ae38634b-0817-5aae-9482-a3fd3efc8946', 9, $md$I$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b84e8aad-54de-5b50-af1c-c47178db5b00', 'ae38634b-0817-5aae-9482-a3fd3efc8946', 10, $md$J$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('59559b7b-c7a3-52dd-8994-271ff7bb9653', 'ae38634b-0817-5aae-9482-a3fd3efc8946', 11, $md$K$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('03110853-a58d-5f95-9dc7-08579a47a126', 'ae38634b-0817-5aae-9482-a3fd3efc8946', 12, $md$L$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('e605f6b5-3362-5ae4-9388-2d2fae347c77', '8acafa7f-f4f5-5e82-a513-c91546144e68', 2, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 2

Questions 1-8
Questions 1-8
Complete the summary, using the list of words and phrases,
A-L
, below.
Write the correct letter,
A-L
, in boxes
1-8
on your answer sheet.
The story of the fall of the Berlin Wall had started to unfold 9 years earlier, Janos Vargha visited the river Danube out of Budapest to discuss a matter of
1
with executives. However, unfortunately, the tree-lined curve in the river was
2
by a colossal dam which caused a lot of fear. He noticed the negative impact of the Nagymaros dam would be
3
on the ecosystem around the main river. Besides, the dam was engineering public works, generating hydroelectricity, irrigating farmlands and developing sailing trade which was
4
with a border of Czechoslovakia.
After one public meeting, Vargha
5
the Danube Circle for showing the autonomy of the people in a democracy. Despite every effort, he who would eventually become the editor of the Hungarian edition was
6
by the Politburo. Fortunately, with plenty of pressure from the anti-dam movement, east European communism’s final symbol was opposed by the
7
. Overall, between political processing and environmentalists have been on a
8
of views.
A
severe
B
discharged
C
constructing a park of small-scale
D
passed
E
reformist
F
swallowed up
G
separated
H
favourable
I
established
J
collision
K
combined
L
environmentalists

The story of the fall of the Berlin Wall had started to unfold 9 years earlier, Janos Vargha visited the river Danube out of Budapest to discuss a matter of 1 ____ with executives. However, unfortunately, the tree-lined curve in the river was 2 ____ by a colossal dam which caused a lot of fear. He noticed the negative impact of the Nagymaros dam would be 3 ____ on the ecosystem around the main river. Besides, the dam was engineering public works, generating hydroelectricity, irrigating farmlands and developing sailing trade which was 4 ____ with a border of Czechoslovakia.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1e77073c-c758-5562-a2b3-cd0f08957b7b', 'e605f6b5-3362-5ae4-9388-2d2fae347c77', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6c0a0c58-2a35-5ab6-9feb-217c81984623', 'e605f6b5-3362-5ae4-9388-2d2fae347c77', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8b3e4e2a-d532-5535-b12d-cc5f29141283', 'e605f6b5-3362-5ae4-9388-2d2fae347c77', 3, $md$C$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c33eb5a6-5661-5dc6-99af-ce0a974282f6', 'e605f6b5-3362-5ae4-9388-2d2fae347c77', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('db632b97-723f-5805-8328-41e9d89c8afe', 'e605f6b5-3362-5ae4-9388-2d2fae347c77', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('76fbb561-ff33-5803-95a3-4fc8cae6f16a', 'e605f6b5-3362-5ae4-9388-2d2fae347c77', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('83324727-a23b-5ce8-9a54-9280475fd0e3', 'e605f6b5-3362-5ae4-9388-2d2fae347c77', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0571185a-09c9-58db-b589-994f27cd1d94', 'e605f6b5-3362-5ae4-9388-2d2fae347c77', 8, $md$H$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4c516b9a-6230-5152-977e-f83d11fecb6c', 'e605f6b5-3362-5ae4-9388-2d2fae347c77', 9, $md$I$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('246990b2-45cf-501a-bf8d-13bab40416d2', 'e605f6b5-3362-5ae4-9388-2d2fae347c77', 10, $md$J$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4047895b-c8aa-52b5-9604-f26643e855f3', 'e605f6b5-3362-5ae4-9388-2d2fae347c77', 11, $md$K$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1a821801-5428-5a07-993a-b0a1383d376d', 'e605f6b5-3362-5ae4-9388-2d2fae347c77', 12, $md$L$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('552fdbe3-032e-57bc-af17-39c0a1071377', '8acafa7f-f4f5-5e82-a513-c91546144e68', 3, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 3

Questions 1-8
Questions 1-8
Complete the summary, using the list of words and phrases,
A-L
, below.
Write the correct letter,
A-L
, in boxes
1-8
on your answer sheet.
The story of the fall of the Berlin Wall had started to unfold 9 years earlier, Janos Vargha visited the river Danube out of Budapest to discuss a matter of
1
with executives. However, unfortunately, the tree-lined curve in the river was
2
by a colossal dam which caused a lot of fear. He noticed the negative impact of the Nagymaros dam would be
3
on the ecosystem around the main river. Besides, the dam was engineering public works, generating hydroelectricity, irrigating farmlands and developing sailing trade which was
4
with a border of Czechoslovakia.
After one public meeting, Vargha
5
the Danube Circle for showing the autonomy of the people in a democracy. Despite every effort, he who would eventually become the editor of the Hungarian edition was
6
by the Politburo. Fortunately, with plenty of pressure from the anti-dam movement, east European communism’s final symbol was opposed by the
7
. Overall, between political processing and environmentalists have been on a
8
of views.
A
severe
B
discharged
C
constructing a park of small-scale
D
passed
E
reformist
F
swallowed up
G
separated
H
favourable
I
established
J
collision
K
combined
L
environmentalists

The story of the fall of the Berlin Wall had started to unfold 9 years earlier, Janos Vargha visited the river Danube out of Budapest to discuss a matter of 1 ____ with executives. However, unfortunately, the tree-lined curve in the river was 2 ____ by a colossal dam which caused a lot of fear. He noticed the negative impact of the Nagymaros dam would be 3 ____ on the ecosystem around the main river. Besides, the dam was engineering public works, generating hydroelectricity, irrigating farmlands and developing sailing trade which was 4 ____ with a border of Czechoslovakia.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('574bb955-f3b6-50b1-af05-81ff2a9ad93d', '552fdbe3-032e-57bc-af17-39c0a1071377', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1ba36db6-ef66-5a21-bb4b-c9f898e63b57', '552fdbe3-032e-57bc-af17-39c0a1071377', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f50cef43-35e7-5d59-95a2-f9e8ae8accc8', '552fdbe3-032e-57bc-af17-39c0a1071377', 3, $md$C$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c54f3e43-0030-59a9-9314-1ba5df5caaeb', '552fdbe3-032e-57bc-af17-39c0a1071377', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c16828b3-e74d-5006-a8bc-60c6df19a8fe', '552fdbe3-032e-57bc-af17-39c0a1071377', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c65fbac8-0feb-509c-ba12-3f7b46c08028', '552fdbe3-032e-57bc-af17-39c0a1071377', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c712df35-34f5-53b5-bb24-c16462b6d257', '552fdbe3-032e-57bc-af17-39c0a1071377', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8e550c92-43c7-55ab-8681-577ac88ced45', '552fdbe3-032e-57bc-af17-39c0a1071377', 8, $md$H$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1c3b2c5f-01fe-52cb-81a7-d3879f2a2faf', '552fdbe3-032e-57bc-af17-39c0a1071377', 9, $md$I$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('513db397-4315-5ea8-ad5b-cbef623ab5ff', '552fdbe3-032e-57bc-af17-39c0a1071377', 10, $md$J$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0bc1ce4b-30b7-58cf-b769-7aa7fa25f446', '552fdbe3-032e-57bc-af17-39c0a1071377', 11, $md$K$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('078e8deb-ec2a-5687-9bf7-32c4cc5d2ce4', '552fdbe3-032e-57bc-af17-39c0a1071377', 12, $md$L$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('f5e217a0-7e22-5e2e-a4be-ae83cb554a30', '8acafa7f-f4f5-5e82-a513-c91546144e68', 4, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 4

Questions 1-8
Questions 1-8
Complete the summary, using the list of words and phrases,
A-L
, below.
Write the correct letter,
A-L
, in boxes
1-8
on your answer sheet.
The story of the fall of the Berlin Wall had started to unfold 9 years earlier, Janos Vargha visited the river Danube out of Budapest to discuss a matter of
1
with executives. However, unfortunately, the tree-lined curve in the river was
2
by a colossal dam which caused a lot of fear. He noticed the negative impact of the Nagymaros dam would be
3
on the ecosystem around the main river. Besides, the dam was engineering public works, generating hydroelectricity, irrigating farmlands and developing sailing trade which was
4
with a border of Czechoslovakia.
After one public meeting, Vargha
5
the Danube Circle for showing the autonomy of the people in a democracy. Despite every effort, he who would eventually become the editor of the Hungarian edition was
6
by the Politburo. Fortunately, with plenty of pressure from the anti-dam movement, east European communism’s final symbol was opposed by the
7
. Overall, between political processing and environmentalists have been on a
8
of views.
A
severe
B
discharged
C
constructing a park of small-scale
D
passed
E
reformist
F
swallowed up
G
separated
H
favourable
I
established
J
collision
K
combined
L
environmentalists

The story of the fall of the Berlin Wall had started to unfold 9 years earlier, Janos Vargha visited the river Danube out of Budapest to discuss a matter of 1 ____ with executives. However, unfortunately, the tree-lined curve in the river was 2 ____ by a colossal dam which caused a lot of fear. He noticed the negative impact of the Nagymaros dam would be 3 ____ on the ecosystem around the main river. Besides, the dam was engineering public works, generating hydroelectricity, irrigating farmlands and developing sailing trade which was 4 ____ with a border of Czechoslovakia.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('67b726b2-865e-5a43-86fb-a7fc5703e88b', 'f5e217a0-7e22-5e2e-a4be-ae83cb554a30', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('993ff576-b8fa-5b8b-98b3-5c7d7b1e2379', 'f5e217a0-7e22-5e2e-a4be-ae83cb554a30', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f9b6818e-ac31-5bda-8a02-94e18d894a68', 'f5e217a0-7e22-5e2e-a4be-ae83cb554a30', 3, $md$C$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5a1fdae6-9d60-5880-a23a-45ef0f412c14', 'f5e217a0-7e22-5e2e-a4be-ae83cb554a30', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3cdae81d-1fb3-5530-8b8e-8c12415d7c53', 'f5e217a0-7e22-5e2e-a4be-ae83cb554a30', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a6bad824-3b6c-58a0-92da-829b92d0c0b4', 'f5e217a0-7e22-5e2e-a4be-ae83cb554a30', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c99d5274-05b3-522c-a81e-66daa45a7506', 'f5e217a0-7e22-5e2e-a4be-ae83cb554a30', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f0e9455c-9b81-54fe-8c41-a6bf2e9e5512', 'f5e217a0-7e22-5e2e-a4be-ae83cb554a30', 8, $md$H$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7bb21dc0-889b-5f87-9e21-513f97c451cd', 'f5e217a0-7e22-5e2e-a4be-ae83cb554a30', 9, $md$I$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ec66e1df-258a-5e84-9022-5bfc3ed8426e', 'f5e217a0-7e22-5e2e-a4be-ae83cb554a30', 10, $md$J$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6ef7ea97-7dfe-518e-a241-84793755e87a', 'f5e217a0-7e22-5e2e-a4be-ae83cb554a30', 11, $md$K$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('705b8f85-a733-5c0e-9e36-6b993936d3a1', 'f5e217a0-7e22-5e2e-a4be-ae83cb554a30', 12, $md$L$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('542fd806-5150-5c10-8e57-fa3ffd61d282', '8acafa7f-f4f5-5e82-a513-c91546144e68', 5, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 5

Questions 1-8
Questions 1-8
Complete the summary, using the list of words and phrases,
A-L
, below.
Write the correct letter,
A-L
, in boxes
1-8
on your answer sheet.
The story of the fall of the Berlin Wall had started to unfold 9 years earlier, Janos Vargha visited the river Danube out of Budapest to discuss a matter of
1
with executives. However, unfortunately, the tree-lined curve in the river was
2
by a colossal dam which caused a lot of fear. He noticed the negative impact of the Nagymaros dam would be
3
on the ecosystem around the main river. Besides, the dam was engineering public works, generating hydroelectricity, irrigating farmlands and developing sailing trade which was
4
with a border of Czechoslovakia.
After one public meeting, Vargha
5
the Danube Circle for showing the autonomy of the people in a democracy. Despite every effort, he who would eventually become the editor of the Hungarian edition was
6
by the Politburo. Fortunately, with plenty of pressure from the anti-dam movement, east European communism’s final symbol was opposed by the
7
. Overall, between political processing and environmentalists have been on a
8
of views.
A
severe
B
discharged
C
constructing a park of small-scale
D
passed
E
reformist
F
swallowed up
G
separated
H
favourable
I
established
J
collision
K
combined
L
environmentalists

After one public meeting, Vargha 5 ____ the Danube Circle for showing the autonomy of the people in a democracy. Despite every effort, he who would eventually become the editor of the Hungarian edition was 6 ____ by the Politburo. Fortunately, with plenty of pressure from the anti-dam movement, east European communism’s final symbol was opposed by the 7 ____ . Overall, between political processing and environmentalists have been on a 8 ____ of views.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f181261a-0cfb-54a6-97f2-f8a8e17d8068', '542fd806-5150-5c10-8e57-fa3ffd61d282', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('10780e0f-2ca0-5ff3-b743-16dcda87a815', '542fd806-5150-5c10-8e57-fa3ffd61d282', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8767c553-994d-58c7-9dc3-626e2f5db95f', '542fd806-5150-5c10-8e57-fa3ffd61d282', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('25033378-9977-566e-a16f-335cf7d22e70', '542fd806-5150-5c10-8e57-fa3ffd61d282', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3db86ad9-43a9-591f-879b-591d802a52a6', '542fd806-5150-5c10-8e57-fa3ffd61d282', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('60751db2-bc24-5607-b897-62eef2df402b', '542fd806-5150-5c10-8e57-fa3ffd61d282', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('26a637f7-90f1-5afe-86dd-17b2406142ab', '542fd806-5150-5c10-8e57-fa3ffd61d282', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fdb8d8ba-c555-582e-9b7b-bc69c09a4f76', '542fd806-5150-5c10-8e57-fa3ffd61d282', 8, $md$H$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('06b3edbe-934e-5171-9082-7b47b12ec8a6', '542fd806-5150-5c10-8e57-fa3ffd61d282', 9, $md$I$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('22ddccea-b746-53c0-8590-06d2235213d9', '542fd806-5150-5c10-8e57-fa3ffd61d282', 10, $md$J$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c92deaff-8723-5af1-b1ad-568f02dfc355', '542fd806-5150-5c10-8e57-fa3ffd61d282', 11, $md$K$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1d9bca5e-fbc6-5ff8-83e9-209e76c35dbc', '542fd806-5150-5c10-8e57-fa3ffd61d282', 12, $md$L$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('0d6b3af2-6bc6-52d9-afc9-8c688937c55c', '8acafa7f-f4f5-5e82-a513-c91546144e68', 6, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 6

Questions 1-8
Questions 1-8
Complete the summary, using the list of words and phrases,
A-L
, below.
Write the correct letter,
A-L
, in boxes
1-8
on your answer sheet.
The story of the fall of the Berlin Wall had started to unfold 9 years earlier, Janos Vargha visited the river Danube out of Budapest to discuss a matter of
1
with executives. However, unfortunately, the tree-lined curve in the river was
2
by a colossal dam which caused a lot of fear. He noticed the negative impact of the Nagymaros dam would be
3
on the ecosystem around the main river. Besides, the dam was engineering public works, generating hydroelectricity, irrigating farmlands and developing sailing trade which was
4
with a border of Czechoslovakia.
After one public meeting, Vargha
5
the Danube Circle for showing the autonomy of the people in a democracy. Despite every effort, he who would eventually become the editor of the Hungarian edition was
6
by the Politburo. Fortunately, with plenty of pressure from the anti-dam movement, east European communism’s final symbol was opposed by the
7
. Overall, between political processing and environmentalists have been on a
8
of views.
A
severe
B
discharged
C
constructing a park of small-scale
D
passed
E
reformist
F
swallowed up
G
separated
H
favourable
I
established
J
collision
K
combined
L
environmentalists

After one public meeting, Vargha 5 ____ the Danube Circle for showing the autonomy of the people in a democracy. Despite every effort, he who would eventually become the editor of the Hungarian edition was 6 ____ by the Politburo. Fortunately, with plenty of pressure from the anti-dam movement, east European communism’s final symbol was opposed by the 7 ____ . Overall, between political processing and environmentalists have been on a 8 ____ of views.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6a648026-b122-5c2c-b0c9-3990a2991251', '0d6b3af2-6bc6-52d9-afc9-8c688937c55c', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f03d1f13-567f-5f5c-aa03-a379db3a2707', '0d6b3af2-6bc6-52d9-afc9-8c688937c55c', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('de002585-a2d2-5c3c-90bb-4eeb503e8a1b', '0d6b3af2-6bc6-52d9-afc9-8c688937c55c', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ef277e42-88d6-51d5-9d2e-23fd3970da4c', '0d6b3af2-6bc6-52d9-afc9-8c688937c55c', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2d9d8901-3d0c-56f1-ab1c-9819b61f1f1e', '0d6b3af2-6bc6-52d9-afc9-8c688937c55c', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('86d84130-cb77-57c4-9815-6757befd85e5', '0d6b3af2-6bc6-52d9-afc9-8c688937c55c', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bf4f9a71-10c5-5416-a56b-064275a0dba2', '0d6b3af2-6bc6-52d9-afc9-8c688937c55c', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5cb85cdf-1dd8-530d-9d8a-15e15f3f49b4', '0d6b3af2-6bc6-52d9-afc9-8c688937c55c', 8, $md$H$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a3e4bea7-7fd1-573c-a37d-050034e01133', '0d6b3af2-6bc6-52d9-afc9-8c688937c55c', 9, $md$I$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6ea68751-bfc3-5d3d-96ff-ea2ad7613f5d', '0d6b3af2-6bc6-52d9-afc9-8c688937c55c', 10, $md$J$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('025fa8ca-0275-5a5a-9d66-cb74ba4d9b9f', '0d6b3af2-6bc6-52d9-afc9-8c688937c55c', 11, $md$K$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('86435b6d-e290-589f-b3c7-89928c151a8d', '0d6b3af2-6bc6-52d9-afc9-8c688937c55c', 12, $md$L$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('1b4bd179-9b42-5ea2-9046-b8eda15d8b73', '8acafa7f-f4f5-5e82-a513-c91546144e68', 7, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 7

Questions 1-8
Questions 1-8
Complete the summary, using the list of words and phrases,
A-L
, below.
Write the correct letter,
A-L
, in boxes
1-8
on your answer sheet.
The story of the fall of the Berlin Wall had started to unfold 9 years earlier, Janos Vargha visited the river Danube out of Budapest to discuss a matter of
1
with executives. However, unfortunately, the tree-lined curve in the river was
2
by a colossal dam which caused a lot of fear. He noticed the negative impact of the Nagymaros dam would be
3
on the ecosystem around the main river. Besides, the dam was engineering public works, generating hydroelectricity, irrigating farmlands and developing sailing trade which was
4
with a border of Czechoslovakia.
After one public meeting, Vargha
5
the Danube Circle for showing the autonomy of the people in a democracy. Despite every effort, he who would eventually become the editor of the Hungarian edition was
6
by the Politburo. Fortunately, with plenty of pressure from the anti-dam movement, east European communism’s final symbol was opposed by the
7
. Overall, between political processing and environmentalists have been on a
8
of views.
A
severe
B
discharged
C
constructing a park of small-scale
D
passed
E
reformist
F
swallowed up
G
separated
H
favourable
I
established
J
collision
K
combined
L
environmentalists

After one public meeting, Vargha 5 ____ the Danube Circle for showing the autonomy of the people in a democracy. Despite every effort, he who would eventually become the editor of the Hungarian edition was 6 ____ by the Politburo. Fortunately, with plenty of pressure from the anti-dam movement, east European communism’s final symbol was opposed by the 7 ____ . Overall, between political processing and environmentalists have been on a 8 ____ of views.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d4325b83-3a43-5aeb-94f5-376dd2c72cfa', '1b4bd179-9b42-5ea2-9046-b8eda15d8b73', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('92b17d20-7f0a-50ce-894c-bee48a073c09', '1b4bd179-9b42-5ea2-9046-b8eda15d8b73', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ed832afc-2557-5f89-8879-1ad4104eec61', '1b4bd179-9b42-5ea2-9046-b8eda15d8b73', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('02d00021-c894-5b6a-adeb-25c12431448e', '1b4bd179-9b42-5ea2-9046-b8eda15d8b73', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('137653c0-a6b4-5f58-b1dd-7ea0d367eed7', '1b4bd179-9b42-5ea2-9046-b8eda15d8b73', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('801cd71a-b832-5702-81eb-097c5ac13982', '1b4bd179-9b42-5ea2-9046-b8eda15d8b73', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b7b5be5a-de0f-5655-80e1-f0942cdfa54a', '1b4bd179-9b42-5ea2-9046-b8eda15d8b73', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6eca907f-1fba-5244-8513-bc395f8a19d0', '1b4bd179-9b42-5ea2-9046-b8eda15d8b73', 8, $md$H$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('48a6ed30-649a-5c12-a407-35e1751ec3aa', '1b4bd179-9b42-5ea2-9046-b8eda15d8b73', 9, $md$I$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('175129bd-5064-56f0-9456-13fa320dccfa', '1b4bd179-9b42-5ea2-9046-b8eda15d8b73', 10, $md$J$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2909538a-9c39-5f00-b02d-4c5b84f7048b', '1b4bd179-9b42-5ea2-9046-b8eda15d8b73', 11, $md$K$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c85b7aac-5b6e-5478-89e3-bf0dcf5bd1be', '1b4bd179-9b42-5ea2-9046-b8eda15d8b73', 12, $md$L$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('e5c0283a-4634-51d2-9ad6-09f7422aeb9d', '8acafa7f-f4f5-5e82-a513-c91546144e68', 8, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 8

Questions 1-8
Questions 1-8
Complete the summary, using the list of words and phrases,
A-L
, below.
Write the correct letter,
A-L
, in boxes
1-8
on your answer sheet.
The story of the fall of the Berlin Wall had started to unfold 9 years earlier, Janos Vargha visited the river Danube out of Budapest to discuss a matter of
1
with executives. However, unfortunately, the tree-lined curve in the river was
2
by a colossal dam which caused a lot of fear. He noticed the negative impact of the Nagymaros dam would be
3
on the ecosystem around the main river. Besides, the dam was engineering public works, generating hydroelectricity, irrigating farmlands and developing sailing trade which was
4
with a border of Czechoslovakia.
After one public meeting, Vargha
5
the Danube Circle for showing the autonomy of the people in a democracy. Despite every effort, he who would eventually become the editor of the Hungarian edition was
6
by the Politburo. Fortunately, with plenty of pressure from the anti-dam movement, east European communism’s final symbol was opposed by the
7
. Overall, between political processing and environmentalists have been on a
8
of views.
A
severe
B
discharged
C
constructing a park of small-scale
D
passed
E
reformist
F
swallowed up
G
separated
H
favourable
I
established
J
collision
K
combined
L
environmentalists

After one public meeting, Vargha 5 ____ the Danube Circle for showing the autonomy of the people in a democracy. Despite every effort, he who would eventually become the editor of the Hungarian edition was 6 ____ by the Politburo. Fortunately, with plenty of pressure from the anti-dam movement, east European communism’s final symbol was opposed by the 7 ____ . Overall, between political processing and environmentalists have been on a 8 ____ of views.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('18791ed2-1d73-58ba-888d-f947a9f8575f', 'e5c0283a-4634-51d2-9ad6-09f7422aeb9d', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('439fcc78-6dbb-5d5b-a71e-efb5a084115a', 'e5c0283a-4634-51d2-9ad6-09f7422aeb9d', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('54cc538e-2770-57a2-be2c-fae83aa9887f', 'e5c0283a-4634-51d2-9ad6-09f7422aeb9d', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0c2bfac5-bb74-58e0-b575-9d5a09497477', 'e5c0283a-4634-51d2-9ad6-09f7422aeb9d', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('63ae9011-d0e6-59b0-9549-11a1a9faf8a3', 'e5c0283a-4634-51d2-9ad6-09f7422aeb9d', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5b0f0977-3cad-5000-ae0c-39a85f9fe88c', 'e5c0283a-4634-51d2-9ad6-09f7422aeb9d', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('17f2ca0d-f984-5f96-ba32-c2a718b06ce1', 'e5c0283a-4634-51d2-9ad6-09f7422aeb9d', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fe5f782b-8373-53a7-9541-4005f3feff09', 'e5c0283a-4634-51d2-9ad6-09f7422aeb9d', 8, $md$H$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4678bd6b-3db0-51a9-af82-6cbbc76c9671', 'e5c0283a-4634-51d2-9ad6-09f7422aeb9d', 9, $md$I$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b28b09df-4664-5786-a5e7-7db61334fe1a', 'e5c0283a-4634-51d2-9ad6-09f7422aeb9d', 10, $md$J$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2aff62af-efc3-5e47-be68-cb1aa4966f47', 'e5c0283a-4634-51d2-9ad6-09f7422aeb9d', 11, $md$K$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c7b4c043-50fb-5805-a7d8-7b0d2333991e', 'e5c0283a-4634-51d2-9ad6-09f7422aeb9d', 12, $md$L$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('a48e44fe-18ef-5c3e-9bae-0215677e5ec2', '8acafa7f-f4f5-5e82-a513-c91546144e68', 9, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 9

Questions 9-13
Questions 9-13
Do the following statements reflect the claims of the writer in Reading Passage ?
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
Janos Vargha predicted that the Nagymaros dam would wreck the natural atmosphere before it was built.
10
The Nagymaros dam’s project was managed by the Russians only.
11
The Danube Circle was an unauthorised group for opposing the dam.
12
The Politburo accepted Vargha as editor of the Hungarian edition.
13
The human rights Charter 77 in Czechoslovakia accepted green thoughts.

9 ____ Janos Vargha predicted that the Nagymaros dam would wreck the natural atmosphere before it was built.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('56e585d4-2a91-5c03-8abe-dd9b93c80612', 'a48e44fe-18ef-5c3e-9bae-0215677e5ec2', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cbdff48d-3990-5616-a4b8-12645e5e3019', 'a48e44fe-18ef-5c3e-9bae-0215677e5ec2', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('37aaaa26-04fa-5bbb-8253-a3aa760218ab', 'a48e44fe-18ef-5c3e-9bae-0215677e5ec2', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('f5b185d8-8306-55f1-a58e-9eea2db4a973', '8acafa7f-f4f5-5e82-a513-c91546144e68', 10, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 10

Questions 9-13
Questions 9-13
Do the following statements reflect the claims of the writer in Reading Passage ?
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
Janos Vargha predicted that the Nagymaros dam would wreck the natural atmosphere before it was built.
10
The Nagymaros dam’s project was managed by the Russians only.
11
The Danube Circle was an unauthorised group for opposing the dam.
12
The Politburo accepted Vargha as editor of the Hungarian edition.
13
The human rights Charter 77 in Czechoslovakia accepted green thoughts.

10 ____ The Nagymaros dam’s project was managed by the Russians only.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('90e0b9ee-0136-508c-8687-775f122762dc', 'f5b185d8-8306-55f1-a58e-9eea2db4a973', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('556d122c-10c2-54c4-aa8c-5cd8b53cfbbb', 'f5b185d8-8306-55f1-a58e-9eea2db4a973', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a175e761-9a31-5bd7-ba4b-8d0a4770ad52', 'f5b185d8-8306-55f1-a58e-9eea2db4a973', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('76142be3-c49c-50e0-9eeb-48cef7d434c4', '8acafa7f-f4f5-5e82-a513-c91546144e68', 11, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 11

Questions 9-13
Questions 9-13
Do the following statements reflect the claims of the writer in Reading Passage ?
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
Janos Vargha predicted that the Nagymaros dam would wreck the natural atmosphere before it was built.
10
The Nagymaros dam’s project was managed by the Russians only.
11
The Danube Circle was an unauthorised group for opposing the dam.
12
The Politburo accepted Vargha as editor of the Hungarian edition.
13
The human rights Charter 77 in Czechoslovakia accepted green thoughts.

11 ____ The Danube Circle was an unauthorised group for opposing the dam.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('dbe58b4d-2c26-5aca-b19f-5254e4c7fed0', '76142be3-c49c-50e0-9eeb-48cef7d434c4', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('eb3be6ae-9e6d-5986-8b8a-f85e042c8c16', '76142be3-c49c-50e0-9eeb-48cef7d434c4', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('10a7ae17-d5b0-538e-b405-3c39c55032c7', '76142be3-c49c-50e0-9eeb-48cef7d434c4', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('06644a5b-de73-53e2-afb9-cbf8735a896b', '8acafa7f-f4f5-5e82-a513-c91546144e68', 12, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 12

Questions 9-13
Questions 9-13
Do the following statements reflect the claims of the writer in Reading Passage ?
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
Janos Vargha predicted that the Nagymaros dam would wreck the natural atmosphere before it was built.
10
The Nagymaros dam’s project was managed by the Russians only.
11
The Danube Circle was an unauthorised group for opposing the dam.
12
The Politburo accepted Vargha as editor of the Hungarian edition.
13
The human rights Charter 77 in Czechoslovakia accepted green thoughts.

12 ____ The Politburo accepted Vargha as editor of the Hungarian edition.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('407fd0e5-6492-5687-9118-4e79e507a3ed', '06644a5b-de73-53e2-afb9-cbf8735a896b', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('93a09803-97d6-581e-9711-48aa20d3d98f', '06644a5b-de73-53e2-afb9-cbf8735a896b', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2929bfb5-1ec0-5e75-9587-b9e31b442c0d', '06644a5b-de73-53e2-afb9-cbf8735a896b', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('c5718435-05fd-5f2d-b8b5-061b962e8781', '8acafa7f-f4f5-5e82-a513-c91546144e68', 13, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 13

Questions 9-13
Questions 9-13
Do the following statements reflect the claims of the writer in Reading Passage ?
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
Janos Vargha predicted that the Nagymaros dam would wreck the natural atmosphere before it was built.
10
The Nagymaros dam’s project was managed by the Russians only.
11
The Danube Circle was an unauthorised group for opposing the dam.
12
The Politburo accepted Vargha as editor of the Hungarian edition.
13
The human rights Charter 77 in Czechoslovakia accepted green thoughts.

13 ____ The human rights Charter 77 in Czechoslovakia accepted green thoughts.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('387d56d2-7359-596f-9c64-4f53f950cdca', 'c5718435-05fd-5f2d-b8b5-061b962e8781', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0e533a0a-6f8d-5ebd-a5fb-4c399e85ce08', 'c5718435-05fd-5f2d-b8b5-061b962e8781', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f38cc0ff-91bf-5b69-8b9e-0795dae5ba92', 'c5718435-05fd-5f2d-b8b5-061b962e8781', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('39c3322c-ffb0-549d-adc1-7f6da46fd956', '8acafa7f-f4f5-5e82-a513-c91546144e68', 14, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 14

Questions 14
Questions 14
Choose the correct letter,
A
,
B
,
C
or
D
.
Write the correct letter in boxe
14
on your answer sheet.
14.
In this passage, the Nagymaros dam’s main purpose was
A
related to Russian Water Management.
B
to develop a source of electronic power, farming and sail.
C
to connect the Black Sea and the Danube.
D
to develop a beauty spot on the river Danube.

Choose the correct letter, A , B , C or D .$md$, NULL);

COMMIT;
