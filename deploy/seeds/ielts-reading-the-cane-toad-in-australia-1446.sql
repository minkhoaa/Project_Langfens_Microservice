BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-the-cane-toad-in-australia-1446'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-the-cane-toad-in-australia-1446';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-the-cane-toad-in-australia-1446';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-the-cane-toad-in-australia-1446';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('feed981c-f6ea-5680-9c08-64cff20d5e58', 'ielts-reading-the-cane-toad-in-australia-1446', $t$The Cane Toad in Australia$t$, $md$## The Cane Toad in Australia

Nguồn:
- Test: https://mini-ielts.com/1446/reading/the-cane-toad-in-australia
- Solution: https://mini-ielts.com/1446/view-solution/reading/the-cane-toad-in-australia$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('f882c9d7-7080-5aa9-a922-28e5c5017667', 'feed981c-f6ea-5680-9c08-64cff20d5e58', 1, $t$Reading — The Cane Toad in Australia$t$, $md$Read the passage and answer questions **1–13**.

### Passage: The Cane Toad in Australia

Paragraph A

The cane toad was introduced into Australia in 1935 to control sugar cane pests in Queensland. One hundred and one cane toads arnved at Edmonton in June in 1935. Breeding occurred almost immediately. The cane toad is tough and adaptable, as well as being poisonous throughout Its life cycle, and has few predators in Australia.

Paragraph B

Cane toads are large heavily-built amphibians with dry, warty skin. They have a bony head and over their eyes are bony ndges that meet above the nose They sit upright and move in short rapid hops. Their hind feet have leathery webbing between the toes and their front feet are unwebbed. Adult cane toads have large swellings - the parotoid glands - on each shoulder behind the eardrum. Cane toads may be grey, yellowish, olive-brown or reddish-brown, and their bellies are pale with dark mottling. Average-sized adults are ten to fifteen centimetres long. The largest female measured in Queensland was twenty-four centimetres long and weighed one point three kilograms Male cane toads are smaller and wartier than females. Dunng the breeding season males develop dark lumps (nuptial pads) on their first two fingers; these help them cling to a female while mating. Their mating call is a long loud purnng tnll. Cane toad spawn is exclusive in Australia. It is laid in long strings of transparent jelly enclosing double rows of black eggs The spawn tangles in dense dark masses around water plants, and hangs in ropy strands if picked up

Paragraph c

The natural range of cane toads extends from the southern United States to tropical South Amenca. In 2002, cane toads occurred throughout the eastern and northern half of Queensland and have extended their range to the river catchments surrounding Kakadu National Park in the Northern Temtory. In New South Wales, they occur as far south as Yamba and Port Macquarie.

Paragraph D

Cane toads tolerate a broad range of environmental and climatic conditions and appear to be able to adjust and survive in almost any environment system, including sea water for short penods of time. This to a large extent explains their success in their spreading in Australia. Cane toads are found in environments ranging from sand dunes and coastal heath to the margins of rainforest and mangroves. They are most abundant in open clearings in urban areas, and in grassland and woodland.

Paragraph E

Cane toads eat almost anything they can swallow, including pet food, carrion and household scraps, but most of their food consists of living insects Beetles, honey bees. ants, winged termites, cnckets and bugs are eaten in abundance Marine snails, smaller toads and native

frogs, small snakes, and small mammals are occasionally eaten by cane toads. The tadpoles of cane toads eat algae and other aquatic plants which they rasp off with five rows of tiny peg-like teeth. They also filter organic matter from the water. Large tadpoles sometimes eat cane toad eggs

Paragraph F

Cane toads were introduced to Australia to eat French s Cane Beetle and the Greyback Cane Beetle The whitegrub larvae of these beetles eat the roots of sugar cane and kill or stunt the plants. The Australian Bureau of Sugar Experimental Stations imported about a hundred toads from Hawaii to the Meringa Experimental Station near Cairns. The toads bred quickly and more than three thousand were released in the sugar cane plantations of north Queensland in July 1935. At that time, some naturalists and scientists warned of the dangers of liberating cane toads in Australia. Their protests resulted in a brief moratohum on the release of toads, but releases resumed in 1936. The protestors were right. Firstly, cane toads compete for the resources of native animals, like food, which affects native populations. Secondly, cane toads don't have as many established predators as native animals and so their population grows quickly. Finally, some native animals who would normally feed on frogs try to eat toads and get poisoned.

Paragraph G

All stages of the cane toad's life-cycle are poisonous. No humans have died in Australia from cane toad poison, but overseas, people have died after eating toads and even soup made from boiled toad eggs Cane toads are also poisonous to pets. In Hawaii, up to fifty dogs a year have died after having cane toads in their mouths Signs of dogs being poisoned through ingestion include profuse salivation, twitching, vomiting, shallow breathing, and collapse of the hind limbs. Death may occur by cardiac arrest within fifteen minutes. A cane toad responds to threat by turning side-on so Its parotoid glands are directed towards the attacker. The poison usually oozes out of the glands, but toads can squirt a fine spray for a short distance if they want. The poison is absorbed through mucous membranes such as eyes, mouth and nose, and in humans may cause intense pain, temporary blindness and inflammation$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('88151bad-1423-5fea-90aa-df05a3f2da20', 'f882c9d7-7080-5aa9-a922-28e5c5017667', 1, 'MATCHING_HEADING', 'READING', 2, $md$### Question 1

Questions 1-6
Questions 1-6
The reading passage
The Cane Toad in Australia
has paragraphs (A - G).
From the list of headings below (i - X) choose the most suitable headings for paragraphs B - G
Write the appropriate number (i - X) in boxes 1-6 on your answer sheet.
NB There are more headings than paragraphs, so you will not use them all
Example
Answer
Paragraph A
v
i
Diet
ii
Habitat
iii
Pollution Effects
iv
Danger
V
Arrival In Australia
Vi
Food for Snakes
vii
Identification
viii
Captivity
ix
Distribution
x
Environmental Impacts
1
Paragraph B
2
Paragraph C
3
Paragraph D
4
Paragraph E
5
Paragraph F
6
Paragraph G

1 ____$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('93752ef6-88b8-5a31-8138-02c285a430cd', '88151bad-1423-5fea-90aa-df05a3f2da20', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3e29bf8b-1f38-52e2-b631-0164549d9698', '88151bad-1423-5fea-90aa-df05a3f2da20', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8c652c29-490b-5a6e-8940-24168309701e', '88151bad-1423-5fea-90aa-df05a3f2da20', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('787fdb89-54ff-56c1-9ad6-502fe19a70e7', '88151bad-1423-5fea-90aa-df05a3f2da20', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('91c347c5-9d91-5d44-a3c4-91bbbcb71993', '88151bad-1423-5fea-90aa-df05a3f2da20', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0781a0c8-3b96-55e3-92e6-1efba48dabae', '88151bad-1423-5fea-90aa-df05a3f2da20', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1c0d3937-42a8-5411-bd13-aab3017eac22', '88151bad-1423-5fea-90aa-df05a3f2da20', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c421c311-9b66-5c62-b3b6-213ee02d9de4', '88151bad-1423-5fea-90aa-df05a3f2da20', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7f91893f-b502-5ac4-aadc-61815dd4d374', '88151bad-1423-5fea-90aa-df05a3f2da20', 9, $md$ix$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e79c7fce-cd07-5e2a-950e-7eeda8925b2c', '88151bad-1423-5fea-90aa-df05a3f2da20', 10, $md$x$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('7dad82c3-c06d-5919-83f3-57568bc60923', 'f882c9d7-7080-5aa9-a922-28e5c5017667', 2, 'MATCHING_HEADING', 'READING', 2, $md$### Question 2

Questions 1-6
Questions 1-6
The reading passage
The Cane Toad in Australia
has paragraphs (A - G).
From the list of headings below (i - X) choose the most suitable headings for paragraphs B - G
Write the appropriate number (i - X) in boxes 1-6 on your answer sheet.
NB There are more headings than paragraphs, so you will not use them all
Example
Answer
Paragraph A
v
i
Diet
ii
Habitat
iii
Pollution Effects
iv
Danger
V
Arrival In Australia
Vi
Food for Snakes
vii
Identification
viii
Captivity
ix
Distribution
x
Environmental Impacts
1
Paragraph B
2
Paragraph C
3
Paragraph D
4
Paragraph E
5
Paragraph F
6
Paragraph G

2 ____$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('86b870ef-736e-58fc-baee-d43fe1b291a1', '7dad82c3-c06d-5919-83f3-57568bc60923', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4850169b-bf30-5c3e-befd-02e81ef8c768', '7dad82c3-c06d-5919-83f3-57568bc60923', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d97196b3-b88a-5875-a13a-ea3efbb264a6', '7dad82c3-c06d-5919-83f3-57568bc60923', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c54fb16e-e4f2-599f-b2c3-5bc459c91cbf', '7dad82c3-c06d-5919-83f3-57568bc60923', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7137b52b-adf1-587a-a350-027832cbe799', '7dad82c3-c06d-5919-83f3-57568bc60923', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1dfcbe07-7a2f-5ea7-8b2f-06861616d155', '7dad82c3-c06d-5919-83f3-57568bc60923', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3bad10c9-4d42-51e5-b80c-d71fada094bc', '7dad82c3-c06d-5919-83f3-57568bc60923', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5aba77c7-edce-5977-81ad-37294f685c11', '7dad82c3-c06d-5919-83f3-57568bc60923', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('67c603dd-1413-5114-9d51-d441fcdd8bf7', '7dad82c3-c06d-5919-83f3-57568bc60923', 9, $md$ix$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ab8837fe-5af4-5617-ae86-d48f6ce22db0', '7dad82c3-c06d-5919-83f3-57568bc60923', 10, $md$x$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('14bc4e99-ae53-5fab-9fdc-d49df1ec4dc3', 'f882c9d7-7080-5aa9-a922-28e5c5017667', 3, 'MATCHING_HEADING', 'READING', 2, $md$### Question 3

Questions 1-6
Questions 1-6
The reading passage
The Cane Toad in Australia
has paragraphs (A - G).
From the list of headings below (i - X) choose the most suitable headings for paragraphs B - G
Write the appropriate number (i - X) in boxes 1-6 on your answer sheet.
NB There are more headings than paragraphs, so you will not use them all
Example
Answer
Paragraph A
v
i
Diet
ii
Habitat
iii
Pollution Effects
iv
Danger
V
Arrival In Australia
Vi
Food for Snakes
vii
Identification
viii
Captivity
ix
Distribution
x
Environmental Impacts
1
Paragraph B
2
Paragraph C
3
Paragraph D
4
Paragraph E
5
Paragraph F
6
Paragraph G

3 ____$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ac66240a-3d4b-524f-bf18-439034161431', '14bc4e99-ae53-5fab-9fdc-d49df1ec4dc3', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('00a1b106-43a9-5d36-952d-e36d0b176915', '14bc4e99-ae53-5fab-9fdc-d49df1ec4dc3', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('635a83ca-9d49-5f67-b8c1-d81062531292', '14bc4e99-ae53-5fab-9fdc-d49df1ec4dc3', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5fdcb7ad-6957-591a-938d-87bf63e35fed', '14bc4e99-ae53-5fab-9fdc-d49df1ec4dc3', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('21c990ac-f667-5fc6-968d-3502a48f2702', '14bc4e99-ae53-5fab-9fdc-d49df1ec4dc3', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6af10f2f-c3fb-50e0-8673-4586582bf7ef', '14bc4e99-ae53-5fab-9fdc-d49df1ec4dc3', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('792f981e-3f86-5860-9146-1ffbee478a18', '14bc4e99-ae53-5fab-9fdc-d49df1ec4dc3', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b831cc01-9a53-57d8-9854-ae04cfca9633', '14bc4e99-ae53-5fab-9fdc-d49df1ec4dc3', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('deb8d7bf-cb5d-535b-a4cc-4b29c5a646d0', '14bc4e99-ae53-5fab-9fdc-d49df1ec4dc3', 9, $md$ix$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ed4ab516-395a-59f2-9f61-b7b5ab22e197', '14bc4e99-ae53-5fab-9fdc-d49df1ec4dc3', 10, $md$x$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('a78ae1ec-84d8-5e35-86be-2076276964ea', 'f882c9d7-7080-5aa9-a922-28e5c5017667', 4, 'MATCHING_HEADING', 'READING', 2, $md$### Question 4

Questions 1-6
Questions 1-6
The reading passage
The Cane Toad in Australia
has paragraphs (A - G).
From the list of headings below (i - X) choose the most suitable headings for paragraphs B - G
Write the appropriate number (i - X) in boxes 1-6 on your answer sheet.
NB There are more headings than paragraphs, so you will not use them all
Example
Answer
Paragraph A
v
i
Diet
ii
Habitat
iii
Pollution Effects
iv
Danger
V
Arrival In Australia
Vi
Food for Snakes
vii
Identification
viii
Captivity
ix
Distribution
x
Environmental Impacts
1
Paragraph B
2
Paragraph C
3
Paragraph D
4
Paragraph E
5
Paragraph F
6
Paragraph G

4 ____$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ef5f133c-5096-507b-bf26-78183f8faef3', 'a78ae1ec-84d8-5e35-86be-2076276964ea', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('25e4de2c-e686-5e0e-b8e8-dc8783d8b930', 'a78ae1ec-84d8-5e35-86be-2076276964ea', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a8aca979-9f25-5e62-a0d8-f8b0f96d2947', 'a78ae1ec-84d8-5e35-86be-2076276964ea', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6079d5b6-c22e-5af4-83b9-dbb6eb703d0d', 'a78ae1ec-84d8-5e35-86be-2076276964ea', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9573e221-f434-556c-8fc1-a06a99e132cf', 'a78ae1ec-84d8-5e35-86be-2076276964ea', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a1843638-d314-5ca5-b44d-581a6116e391', 'a78ae1ec-84d8-5e35-86be-2076276964ea', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5dd89380-67c8-5977-b87a-7d45b6ca58af', 'a78ae1ec-84d8-5e35-86be-2076276964ea', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('663c07a1-23c7-5230-9866-c3db9ded6846', 'a78ae1ec-84d8-5e35-86be-2076276964ea', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e682d9a3-08a2-5f7e-aac4-38ad12f5e0d0', 'a78ae1ec-84d8-5e35-86be-2076276964ea', 9, $md$ix$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d36d9d89-6f05-550d-a648-4f8662d0a893', 'a78ae1ec-84d8-5e35-86be-2076276964ea', 10, $md$x$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('96a32307-9017-5d5c-ba25-29d870b05ea7', 'f882c9d7-7080-5aa9-a922-28e5c5017667', 5, 'MATCHING_HEADING', 'READING', 3, $md$### Question 5

Questions 1-6
Questions 1-6
The reading passage
The Cane Toad in Australia
has paragraphs (A - G).
From the list of headings below (i - X) choose the most suitable headings for paragraphs B - G
Write the appropriate number (i - X) in boxes 1-6 on your answer sheet.
NB There are more headings than paragraphs, so you will not use them all
Example
Answer
Paragraph A
v
i
Diet
ii
Habitat
iii
Pollution Effects
iv
Danger
V
Arrival In Australia
Vi
Food for Snakes
vii
Identification
viii
Captivity
ix
Distribution
x
Environmental Impacts
1
Paragraph B
2
Paragraph C
3
Paragraph D
4
Paragraph E
5
Paragraph F
6
Paragraph G

5 ____$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('eee7bef0-4e31-55a5-b3e0-1c1c684f9a91', '96a32307-9017-5d5c-ba25-29d870b05ea7', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c3f5bf9c-6c44-53b2-bf0e-772d37f5fa72', '96a32307-9017-5d5c-ba25-29d870b05ea7', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f10ca50a-6e6c-5df2-9fed-2a233f0dfa72', '96a32307-9017-5d5c-ba25-29d870b05ea7', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8c6bdf83-5438-5fc3-8ca1-7f74c87ed647', '96a32307-9017-5d5c-ba25-29d870b05ea7', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6b8d9df3-7b1a-5b5c-9f95-f05bcd1e3438', '96a32307-9017-5d5c-ba25-29d870b05ea7', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a18d10cb-6e3f-501c-942c-579179c2e2a8', '96a32307-9017-5d5c-ba25-29d870b05ea7', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0edc8298-6c2f-53bb-895b-8abe483d39ca', '96a32307-9017-5d5c-ba25-29d870b05ea7', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d5b4cce8-f30d-54bd-8521-864e3b0e1422', '96a32307-9017-5d5c-ba25-29d870b05ea7', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('90dad099-a70d-53e7-a14e-bbdce43eaac6', '96a32307-9017-5d5c-ba25-29d870b05ea7', 9, $md$ix$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('564d9b0c-6a89-561b-a115-1fdfabf79dde', '96a32307-9017-5d5c-ba25-29d870b05ea7', 10, $md$x$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('4696bbf9-b52a-5cf1-a164-e406834e6ab3', 'f882c9d7-7080-5aa9-a922-28e5c5017667', 6, 'MATCHING_HEADING', 'READING', 3, $md$### Question 6

Questions 1-6
Questions 1-6
The reading passage
The Cane Toad in Australia
has paragraphs (A - G).
From the list of headings below (i - X) choose the most suitable headings for paragraphs B - G
Write the appropriate number (i - X) in boxes 1-6 on your answer sheet.
NB There are more headings than paragraphs, so you will not use them all
Example
Answer
Paragraph A
v
i
Diet
ii
Habitat
iii
Pollution Effects
iv
Danger
V
Arrival In Australia
Vi
Food for Snakes
vii
Identification
viii
Captivity
ix
Distribution
x
Environmental Impacts
1
Paragraph B
2
Paragraph C
3
Paragraph D
4
Paragraph E
5
Paragraph F
6
Paragraph G

6 ____$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('97872447-1c17-5ea8-84eb-5802409c201f', '4696bbf9-b52a-5cf1-a164-e406834e6ab3', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('150272af-6f7c-5e12-b082-207cc3021de5', '4696bbf9-b52a-5cf1-a164-e406834e6ab3', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5a2f0ebd-a2c4-5673-be4d-be1ff84b8229', '4696bbf9-b52a-5cf1-a164-e406834e6ab3', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('815441e2-722a-5567-88da-d57b19438cb0', '4696bbf9-b52a-5cf1-a164-e406834e6ab3', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9c6346f8-7ceb-5b24-b81a-64434a2d2f71', '4696bbf9-b52a-5cf1-a164-e406834e6ab3', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('03c00588-da62-5ac7-80fe-a05544c372ed', '4696bbf9-b52a-5cf1-a164-e406834e6ab3', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4defcb7a-f9b5-51b4-8e91-5a389b6afcd9', '4696bbf9-b52a-5cf1-a164-e406834e6ab3', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('373037e2-0a39-53c9-8630-e6e005629202', '4696bbf9-b52a-5cf1-a164-e406834e6ab3', 8, $md$viii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('41b1c16a-a02e-5663-9ffe-fdda74dd6766', '4696bbf9-b52a-5cf1-a164-e406834e6ab3', 9, $md$ix$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('84935caf-5e27-5ee8-a639-6e80edd27ff2', '4696bbf9-b52a-5cf1-a164-e406834e6ab3', 10, $md$x$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('2f924ffa-6f86-5048-bf2e-683908ef3564', 'f882c9d7-7080-5aa9-a922-28e5c5017667', 7, 'MATCHING_INFORMATION', 'READING', 3, $md$### Question 7

Questions 7-10
Questions 7-10
Reading Passage
The Cane Toad in Australia,
has 7 paragraphs (A - G). Which paragraphs offer information on the following ideas? Write the appropriate letters (A - G) in boxes 7-10 on your answer sheet.
7
Male cane toads grow protuberances dunng mating penods.
8
The cane toad's unique way of laying eggs in Australia.
9
Opposition to Vie introduction of cane toads in Australia.
10
The danger of eating cane toad eggs

7 ____ Male cane toads grow protuberances dunng mating penods.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0c57acbd-6df2-558d-8db0-f471d0450e78', '2f924ffa-6f86-5048-bf2e-683908ef3564', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a43b1350-d66d-5d28-9789-f7e6a0470634', '2f924ffa-6f86-5048-bf2e-683908ef3564', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('61a6f469-712e-5f2b-8d99-f55a52e2f7e6', '2f924ffa-6f86-5048-bf2e-683908ef3564', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0992f4a5-f83a-5281-94a0-bc2c2ec0b938', '2f924ffa-6f86-5048-bf2e-683908ef3564', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('95cb1c0e-4bba-55af-ab28-67fce1c88c75', '2f924ffa-6f86-5048-bf2e-683908ef3564', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1f7d3098-8b64-5533-963c-24d92c6a720b', '2f924ffa-6f86-5048-bf2e-683908ef3564', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3c959ec5-1c15-5a30-a92b-3cc9b25f9d6f', '2f924ffa-6f86-5048-bf2e-683908ef3564', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('5bcb75fb-3f11-516c-9a2e-9f1014d94d76', 'f882c9d7-7080-5aa9-a922-28e5c5017667', 8, 'MATCHING_INFORMATION', 'READING', 3, $md$### Question 8

Questions 7-10
Questions 7-10
Reading Passage
The Cane Toad in Australia,
has 7 paragraphs (A - G). Which paragraphs offer information on the following ideas? Write the appropriate letters (A - G) in boxes 7-10 on your answer sheet.
7
Male cane toads grow protuberances dunng mating penods.
8
The cane toad's unique way of laying eggs in Australia.
9
Opposition to Vie introduction of cane toads in Australia.
10
The danger of eating cane toad eggs

8 ____ The cane toad's unique way of laying eggs in Australia.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0965def4-b398-5f98-b2fd-a0490dec756c', '5bcb75fb-3f11-516c-9a2e-9f1014d94d76', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('85e8ce09-8cf7-5c62-81f1-bcc498bcf448', '5bcb75fb-3f11-516c-9a2e-9f1014d94d76', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e4bd59e6-3296-5681-92fb-1bbd2935f406', '5bcb75fb-3f11-516c-9a2e-9f1014d94d76', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('da116248-5831-5abf-b165-675b8f3b1dec', '5bcb75fb-3f11-516c-9a2e-9f1014d94d76', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9b30bd2d-82c5-58da-8c4f-4f08475473c9', '5bcb75fb-3f11-516c-9a2e-9f1014d94d76', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('054b6640-ab16-583a-bca6-6ffbe376ce64', '5bcb75fb-3f11-516c-9a2e-9f1014d94d76', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7544fcd0-541f-5d4b-b08b-2d86553b3742', '5bcb75fb-3f11-516c-9a2e-9f1014d94d76', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('050dd18e-8f3d-5c69-a5e3-4fa948e4e0c4', 'f882c9d7-7080-5aa9-a922-28e5c5017667', 9, 'MATCHING_INFORMATION', 'READING', 3, $md$### Question 9

Questions 7-10
Questions 7-10
Reading Passage
The Cane Toad in Australia,
has 7 paragraphs (A - G). Which paragraphs offer information on the following ideas? Write the appropriate letters (A - G) in boxes 7-10 on your answer sheet.
7
Male cane toads grow protuberances dunng mating penods.
8
The cane toad's unique way of laying eggs in Australia.
9
Opposition to Vie introduction of cane toads in Australia.
10
The danger of eating cane toad eggs

9 ____ Opposition to Vie introduction of cane toads in Australia.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c38ee11a-c229-5a1f-baed-4753306cca13', '050dd18e-8f3d-5c69-a5e3-4fa948e4e0c4', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e0ccd2c1-48f6-59c8-ab3a-c6d235375009', '050dd18e-8f3d-5c69-a5e3-4fa948e4e0c4', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fb7140d0-5851-5693-96a4-0a01aeb802b1', '050dd18e-8f3d-5c69-a5e3-4fa948e4e0c4', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b654c5b0-1859-55c5-9716-1b1efeef7df1', '050dd18e-8f3d-5c69-a5e3-4fa948e4e0c4', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a011278f-cb1a-5eb8-96cf-220e081cf0f4', '050dd18e-8f3d-5c69-a5e3-4fa948e4e0c4', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('436a9cf6-b925-52b9-b90b-44d230d34f48', '050dd18e-8f3d-5c69-a5e3-4fa948e4e0c4', 6, $md$F$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('05ce4699-577a-5b6b-830d-1117eae6afa9', '050dd18e-8f3d-5c69-a5e3-4fa948e4e0c4', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('19ff1207-70d8-57a0-a78e-a265456e7449', 'f882c9d7-7080-5aa9-a922-28e5c5017667', 10, 'MATCHING_INFORMATION', 'READING', 4, $md$### Question 10

Questions 7-10
Questions 7-10
Reading Passage
The Cane Toad in Australia,
has 7 paragraphs (A - G). Which paragraphs offer information on the following ideas? Write the appropriate letters (A - G) in boxes 7-10 on your answer sheet.
7
Male cane toads grow protuberances dunng mating penods.
8
The cane toad's unique way of laying eggs in Australia.
9
Opposition to Vie introduction of cane toads in Australia.
10
The danger of eating cane toad eggs

10 ____ The danger of eating cane toad eggs$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('43fee280-2388-549b-ae33-0f23e52b0a7e', '19ff1207-70d8-57a0-a78e-a265456e7449', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8c0284c4-91bf-5d87-be66-e44b07446cd7', '19ff1207-70d8-57a0-a78e-a265456e7449', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fd490408-c059-5fce-b9e2-7b26a580e327', '19ff1207-70d8-57a0-a78e-a265456e7449', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e91dee9e-e8cd-5e6d-878b-355d045fd142', '19ff1207-70d8-57a0-a78e-a265456e7449', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('45565197-7cf5-563c-878e-d7510b0ac954', '19ff1207-70d8-57a0-a78e-a265456e7449', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f74ab76e-1a59-5391-9640-99fd56024b29', '19ff1207-70d8-57a0-a78e-a265456e7449', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('17a83ead-da4f-5720-94c6-af3bd88df045', '19ff1207-70d8-57a0-a78e-a265456e7449', 7, $md$G$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('fadf5aad-03fe-5ccf-8a32-d8aacc097cbf', 'f882c9d7-7080-5aa9-a922-28e5c5017667', 11, 'SHORT_ANSWER', 'READING', 4, $md$### Question 11

Questions 11-13
Questions 11-13
Complete each of the following statements (Questions 11-13) with words taken from the box below.
Write your answers in boxes 38 - 40 on your answer sheet.
11. When suspended, the eggs of the cane toad resemble
11
12. Cane toads were introduced into Australia in order to stop beetle young eating sugar cane
12
13. The text says that dogs affected by cane toad poisoning may have problems with
13
flowers
heanng
hair
walking
leaves
roots
smelling
tadpoles
stalks
rope
seeds
sleeping

11. When suspended, the eggs of the cane toad resemble 11 ____$md$, NULL, ARRAY['.*rope.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('4ada216d-3bcc-5410-8362-50cf0369dff1', 'f882c9d7-7080-5aa9-a922-28e5c5017667', 12, 'SHORT_ANSWER', 'READING', 4, $md$### Question 12

Questions 11-13
Questions 11-13
Complete each of the following statements (Questions 11-13) with words taken from the box below.
Write your answers in boxes 38 - 40 on your answer sheet.
11. When suspended, the eggs of the cane toad resemble
11
12. Cane toads were introduced into Australia in order to stop beetle young eating sugar cane
12
13. The text says that dogs affected by cane toad poisoning may have problems with
13
flowers
heanng
hair
walking
leaves
roots
smelling
tadpoles
stalks
rope
seeds
sleeping

12. Cane toads were introduced into Australia in order to stop beetle young eating sugar cane 12 ____$md$, NULL, ARRAY['.*roots.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('178a5b25-1e24-5061-850f-4f6260e7e728', 'f882c9d7-7080-5aa9-a922-28e5c5017667', 13, 'SHORT_ANSWER', 'READING', 4, $md$### Question 13

Questions 11-13
Questions 11-13
Complete each of the following statements (Questions 11-13) with words taken from the box below.
Write your answers in boxes 38 - 40 on your answer sheet.
11. When suspended, the eggs of the cane toad resemble
11
12. Cane toads were introduced into Australia in order to stop beetle young eating sugar cane
12
13. The text says that dogs affected by cane toad poisoning may have problems with
13
flowers
heanng
hair
walking
leaves
roots
smelling
tadpoles
stalks
rope
seeds
sleeping

13. The text says that dogs affected by cane toad poisoning may have problems with 13 ____$md$, NULL, ARRAY['.*walking.*']);

COMMIT;
