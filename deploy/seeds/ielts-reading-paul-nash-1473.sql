BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-paul-nash-1473'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-paul-nash-1473';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-paul-nash-1473';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-paul-nash-1473';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('16dfb8fc-8c1a-5d14-94e2-474ce8bfa074', 'ielts-reading-paul-nash-1473', $t$Paul Nash$t$, $md$## Paul Nash

Nguồn:
- Test: https://mini-ielts.com/1473/reading/paul-nash
- Solution: https://mini-ielts.com/1473/view-solution/reading/paul-nash$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('f596be4c-376d-5151-b08d-9527f30116a0', '16dfb8fc-8c1a-5d14-94e2-474ce8bfa074', 1, $t$Reading — Paul Nash$t$, $md$Read the passage and answer questions **1–9**.

### Passage: Paul Nash

{A} Paul Nash, the elder son of William Nash and his first wife, Caroline Jackson, was born in London on 11th May 1889. His father was a successful lawyer who became the Recorder of Abingdon. According to Ronald Blythe: “In 1901 the family returned to its native Buckinghamshire , where the garden of Wood Lane House at Iver Heath, and the countryside of the Chiltern Hills, with its sculptural beeches and chalky contours, were early influences on the development of the three children. Their lives were overshadowed by their mother’s mental illness and Nash himself was greatly helped by his nurse who, with some elderly neighbors, introduced him to the universe of plants.”

{B} Nash was educated at St. Paul’s School and the Slade School of Art, where he met Dora Carrington. Unlike some of his contemporaries at the Slade School, Nash remained untouched by the two post-impressionist exhibitions organized by Roger Fry in 1910 and 1912. Instead, he was influenced by the work of William Blake. He also became a close friend of Gordon Bottomley, who took a keen interest in his career.

{C} Nash had his first one-man show, of ink and wash drawings, at the Carfax Gallery in 1912. The following year he shared an exhibition at the Dorian Leigh Gallery with his brother, John Nash. Myfanwy Piper has added: “Nash had a noteworthy sense of order and of the niceties of presentation; his pictures were beautifully framed, drawings mounted, his studio precisely and decoratively tidy, and oddments which he collected were worked up into compositions.”

{D} Paul Nash was strongly attracted to Dora Carrington: He later recalled: “Carrington… was the dominating personality, I got an introduction to her and eventually won her regard by lending her my braces for a fancy-dress party. We were on the top of a bus and she wanted them then and there.”

{E} On the outbreak Nash considered the possibility of joining the British Army. He told a friend: “I am not keen to rush off and be a soldier. The whole damnable war is too horrible of course and I am all against killing anybody, speaking off-hand, but besides all that I believe both Jack and I might be more useful as ambulance and red cross men, and to that end we are training. Nash enlisted in the Artists’ Rifles. He told Gordon Bottomley: “I have joined the Artists’ London Regiment of Territorials, the old Corps which started with Rossetti, Leighton, and Millais as members in 1860. Every man must do his bit in this horrible business so I have given up painting. There are many nice creatures in my company and I enjoy the burst of exercise – marching, drilling all day in the open air about the pleasant parts of Regents Park and Hampstead Heath.”

{F} In March 1917 he was sent to the Western Front Nash, who took part in the offensive at Ypres, had reached the rank of lieutenant in the Hampshire Regiment by 1916. Whenever possible, Nash made sketches of life in the trenches. In May 1917 he was invalided home after a non-military accident. While recuperating in London, Nash worked from his sketches to produce a series of war paintings . This work was well-received when exhibited later that year. As a result of this exhibition, Charles Masterman, head of the government’s War Propaganda Bureau (WPB), and the advice of Edward Marsh and William Rothenstein, it was decided to recruit Nash as a war artist. In November 1917 in the immediate aftermath of the battle of Passchendaele Nash returned to France.

{G} Nash was unhappy with his work as a member of the War Propaganda Bureau. He wrote at the time: “I am no longer an artist. I am a messenger who will bring back word from the men who are fighting to those who want the war to go on forever. Feeble, inarticulate will be my message, but it will have a bitter truth and may burn their lousy souls.” However, as Myfanwy Piper has pointed out: “The drawings he made then, of shorn trees in ruined and flooded landscapes, were the works that made Nash’s reputation. They were shown at the Leicester Galleries in 1918 together with his first efforts at oil painting, in which he was self-taught and quickly successful, though his drawings made in the field had a more immediate public impact.

{H} In 1919 Nash moved to Dymchurch in Kent, beginning his well-known series of pictures of the sea, the breakwaters, and the long wall that prevents the sea from flooding Romney Marsh. This included the Winter Sea and Dymchurch Steps. Nash also painted the landscapes of the Chiltern Hills. In 1924 and 1928 he had successful exhibitions at the Leicester Galleries. Despite this popular acclaim in 1929, his work became more abstract. In 1933 Nash founded Unit One, the group of experimental painters, sculptors, and architects.

{I} During the Second World War Nash was employed by the Ministry of Information and the Air Ministry and paintings produced by him during this period include the Battle of Britain and Totes Meer. His biographer, Myfanwy Piper, has argued: “This war disturbed Nash but did not change his art as the last one had. His style and his habits were formed, and in the new war, he treated his new subjects as he had treated those he had been thinking about for so long. His late paintings, both oils, and watercolors are alternately brilliant and somber in color with the light of setting suns and rising moons spreading over wooded and hilly landscapes. “Paul Nash died at 35 Boscombe Spa Road, Bournemouth, on 11th July 1946.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('716f8cb2-fafc-5d07-8769-a536941a504f', 'f596be4c-376d-5151-b08d-9527f30116a0', 5, 'MATCHING_INFORMATION', 'READING', 3, $md$### Question 5

Questions 5-10
Questions 5-10
The reading Passage has eleven paragraphs A-I.
Write the correct letter A-I, in boxes 5-10 on your answer sheet.
Which paragraph contains the following information?
NB You may use any letter more than once
.
5
a charming lady in Nash’s eyes
6
Nash’s passion for following particularly appreciated artists
7
Nash’s works with contrast elements
8
the true cause for Nash to join the military service
9
the noticeable impact on Nash’s growth exerted from the rearing environment
10
high praise for Nash’s unique taste of presenting his works

5 ____ a charming lady in Nash’s eyes$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9ecf6006-9788-5ef5-b208-d9929e353b02', '716f8cb2-fafc-5d07-8769-a536941a504f', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2a30a254-98f5-568e-a00d-fbf2d2eeef30', '716f8cb2-fafc-5d07-8769-a536941a504f', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e615e5e1-cf88-519e-8781-a3db7f470124', '716f8cb2-fafc-5d07-8769-a536941a504f', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('50c55129-3a56-5a30-ade5-85fe35027eed', '716f8cb2-fafc-5d07-8769-a536941a504f', 4, $md$D$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fb3b115d-20b4-5003-b492-20fdf88676fc', '716f8cb2-fafc-5d07-8769-a536941a504f', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2dd9a82e-0bc3-5026-a13f-777a9809b3f0', '716f8cb2-fafc-5d07-8769-a536941a504f', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8489d8d0-b9b8-5e59-a246-5f73b344a334', '716f8cb2-fafc-5d07-8769-a536941a504f', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('834676f8-b781-5d1d-bf8d-669c81c60752', '716f8cb2-fafc-5d07-8769-a536941a504f', 8, $md$H$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('679220ae-227b-57e2-a3f7-340cd7df4235', '716f8cb2-fafc-5d07-8769-a536941a504f', 9, $md$I$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('7f858045-a9c9-5414-8fd0-951f1b50fd36', 'f596be4c-376d-5151-b08d-9527f30116a0', 6, 'MATCHING_INFORMATION', 'READING', 3, $md$### Question 6

Questions 5-10
Questions 5-10
The reading Passage has eleven paragraphs A-I.
Write the correct letter A-I, in boxes 5-10 on your answer sheet.
Which paragraph contains the following information?
NB You may use any letter more than once
.
5
a charming lady in Nash’s eyes
6
Nash’s passion for following particularly appreciated artists
7
Nash’s works with contrast elements
8
the true cause for Nash to join the military service
9
the noticeable impact on Nash’s growth exerted from the rearing environment
10
high praise for Nash’s unique taste of presenting his works

6 ____ Nash’s passion for following particularly appreciated artists$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('292b582e-3a41-5c3c-8dd1-bddbfde0978a', '7f858045-a9c9-5414-8fd0-951f1b50fd36', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a9bce33f-b249-5570-a98d-5a8b77ac09ab', '7f858045-a9c9-5414-8fd0-951f1b50fd36', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5e4ae0f5-de13-5ae6-a048-83351db1d5b1', '7f858045-a9c9-5414-8fd0-951f1b50fd36', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6a7caedc-fb4b-53c2-a3d7-a2752639f42e', '7f858045-a9c9-5414-8fd0-951f1b50fd36', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('681ea5b6-f960-53f8-b3b8-77b9e5a22f48', '7f858045-a9c9-5414-8fd0-951f1b50fd36', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bd50cd21-d74b-5c33-8982-7615c7cf63cb', '7f858045-a9c9-5414-8fd0-951f1b50fd36', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('72c0a557-e503-5dd8-99e6-6c8ad04ca924', '7f858045-a9c9-5414-8fd0-951f1b50fd36', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7f1c5add-0d62-5edd-b299-891595324b8f', '7f858045-a9c9-5414-8fd0-951f1b50fd36', 8, $md$H$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e67c0887-18f4-5fd7-bb86-b59e9ec3c9a3', '7f858045-a9c9-5414-8fd0-951f1b50fd36', 9, $md$I$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('9b53f03e-83ee-52b2-b808-9cf0ead8a999', 'f596be4c-376d-5151-b08d-9527f30116a0', 7, 'MATCHING_INFORMATION', 'READING', 3, $md$### Question 7

Questions 5-10
Questions 5-10
The reading Passage has eleven paragraphs A-I.
Write the correct letter A-I, in boxes 5-10 on your answer sheet.
Which paragraph contains the following information?
NB You may use any letter more than once
.
5
a charming lady in Nash’s eyes
6
Nash’s passion for following particularly appreciated artists
7
Nash’s works with contrast elements
8
the true cause for Nash to join the military service
9
the noticeable impact on Nash’s growth exerted from the rearing environment
10
high praise for Nash’s unique taste of presenting his works

7 ____ Nash’s works with contrast elements$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('15ae841c-c367-5ff1-a39c-e0f485bf607b', '9b53f03e-83ee-52b2-b808-9cf0ead8a999', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('39732527-08b6-5ad5-94ad-04289683765d', '9b53f03e-83ee-52b2-b808-9cf0ead8a999', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f84ad5ec-b00f-57a8-b7b5-036802d0bc63', '9b53f03e-83ee-52b2-b808-9cf0ead8a999', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e701bb67-c34f-5990-84fe-ab9a8945d059', '9b53f03e-83ee-52b2-b808-9cf0ead8a999', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6c6ba03e-b53d-5c77-8613-8ba235b9a08f', '9b53f03e-83ee-52b2-b808-9cf0ead8a999', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('21d109b9-6217-5267-b4e8-b188c8e35d51', '9b53f03e-83ee-52b2-b808-9cf0ead8a999', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('dff7399b-e593-54ed-bc19-2aeb186596f4', '9b53f03e-83ee-52b2-b808-9cf0ead8a999', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0d614740-181e-58c2-8db4-4e11038189d6', '9b53f03e-83ee-52b2-b808-9cf0ead8a999', 8, $md$H$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('03d7dc31-1443-5cd5-812a-071c7fc3b884', '9b53f03e-83ee-52b2-b808-9cf0ead8a999', 9, $md$I$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('f0499289-03e0-5bfb-854f-b8788ddbdf84', 'f596be4c-376d-5151-b08d-9527f30116a0', 8, 'MATCHING_INFORMATION', 'READING', 3, $md$### Question 8

Questions 5-10
Questions 5-10
The reading Passage has eleven paragraphs A-I.
Write the correct letter A-I, in boxes 5-10 on your answer sheet.
Which paragraph contains the following information?
NB You may use any letter more than once
.
5
a charming lady in Nash’s eyes
6
Nash’s passion for following particularly appreciated artists
7
Nash’s works with contrast elements
8
the true cause for Nash to join the military service
9
the noticeable impact on Nash’s growth exerted from the rearing environment
10
high praise for Nash’s unique taste of presenting his works

8 ____ the true cause for Nash to join the military service$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d7c2e45e-96ec-5e61-bdab-9acf87829857', 'f0499289-03e0-5bfb-854f-b8788ddbdf84', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cfeaec20-429b-586f-b537-a2c30075a4db', 'f0499289-03e0-5bfb-854f-b8788ddbdf84', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c7cee723-5a78-523b-8bc1-4b29a4cdfdfa', 'f0499289-03e0-5bfb-854f-b8788ddbdf84', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5ef4f498-ac71-5ac7-96f1-631050b173f3', 'f0499289-03e0-5bfb-854f-b8788ddbdf84', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('21c6b1be-d5a1-50fa-99b5-6934e3bb2ee1', 'f0499289-03e0-5bfb-854f-b8788ddbdf84', 5, $md$E$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1ab60ada-43d3-5390-b8db-2d3bebe1fbc6', 'f0499289-03e0-5bfb-854f-b8788ddbdf84', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fb3bc736-f1c7-5382-a82c-7cf08b6402c4', 'f0499289-03e0-5bfb-854f-b8788ddbdf84', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2ee51b33-c0c0-5243-bee7-dd0318e7ab81', 'f0499289-03e0-5bfb-854f-b8788ddbdf84', 8, $md$H$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b5fb0620-d820-5c46-8c6e-8c572e8e6778', 'f0499289-03e0-5bfb-854f-b8788ddbdf84', 9, $md$I$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('557074c3-f93c-5b8b-b471-19c980ced57b', 'f596be4c-376d-5151-b08d-9527f30116a0', 9, 'MATCHING_INFORMATION', 'READING', 3, $md$### Question 9

Questions 5-10
Questions 5-10
The reading Passage has eleven paragraphs A-I.
Write the correct letter A-I, in boxes 5-10 on your answer sheet.
Which paragraph contains the following information?
NB You may use any letter more than once
.
5
a charming lady in Nash’s eyes
6
Nash’s passion for following particularly appreciated artists
7
Nash’s works with contrast elements
8
the true cause for Nash to join the military service
9
the noticeable impact on Nash’s growth exerted from the rearing environment
10
high praise for Nash’s unique taste of presenting his works

9 ____ the noticeable impact on Nash’s growth exerted from the rearing environment$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ae4ed0cb-8bb7-5516-bbf9-89b4bfd0bd65', '557074c3-f93c-5b8b-b471-19c980ced57b', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d0a3c156-b3a5-55be-9483-134985561940', '557074c3-f93c-5b8b-b471-19c980ced57b', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('38087af9-5097-5517-932f-77b95d0d9c4f', '557074c3-f93c-5b8b-b471-19c980ced57b', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('357551dd-fcf9-56bb-aaa9-bc7299d083c2', '557074c3-f93c-5b8b-b471-19c980ced57b', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('47a943f0-8b77-57cf-8fb5-4942da644ccb', '557074c3-f93c-5b8b-b471-19c980ced57b', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8a332424-de8c-57b8-bec3-d314d5f55008', '557074c3-f93c-5b8b-b471-19c980ced57b', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fc0d76ea-ba1b-5137-bc7c-7e400b5c9de9', '557074c3-f93c-5b8b-b471-19c980ced57b', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c209558a-e81e-538c-aba8-dab0c9824fa1', '557074c3-f93c-5b8b-b471-19c980ced57b', 8, $md$H$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('21e23fb4-ea81-58a9-83e4-805f35de43e4', '557074c3-f93c-5b8b-b471-19c980ced57b', 9, $md$I$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('618e9528-bcca-55ac-aaac-e3959258e027', 'f596be4c-376d-5151-b08d-9527f30116a0', 10, 'MATCHING_INFORMATION', 'READING', 4, $md$### Question 10

Questions 5-10
Questions 5-10
The reading Passage has eleven paragraphs A-I.
Write the correct letter A-I, in boxes 5-10 on your answer sheet.
Which paragraph contains the following information?
NB You may use any letter more than once
.
5
a charming lady in Nash’s eyes
6
Nash’s passion for following particularly appreciated artists
7
Nash’s works with contrast elements
8
the true cause for Nash to join the military service
9
the noticeable impact on Nash’s growth exerted from the rearing environment
10
high praise for Nash’s unique taste of presenting his works

10 ____ high praise for Nash’s unique taste of presenting his works$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6ea5d4cc-4503-5a8e-93ed-2ae8639aeb66', '618e9528-bcca-55ac-aaac-e3959258e027', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('98f8cf8a-4f27-5ddd-855d-5670b22629ac', '618e9528-bcca-55ac-aaac-e3959258e027', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('54996493-0b00-5a77-b837-63cf3a5bc4d6', '618e9528-bcca-55ac-aaac-e3959258e027', 3, $md$C$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('469a7488-f6c6-547e-8af5-06d874f1f788', '618e9528-bcca-55ac-aaac-e3959258e027', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fcd56a72-fe10-5ecc-ac00-d38bb0a792e4', '618e9528-bcca-55ac-aaac-e3959258e027', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fdb2bb3d-2be6-5f47-acfc-b988931edfb2', '618e9528-bcca-55ac-aaac-e3959258e027', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('293f0319-4c6a-553b-b905-269b6cde1520', '618e9528-bcca-55ac-aaac-e3959258e027', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('77e83dca-63d2-5f01-9753-283ee7fd5943', '618e9528-bcca-55ac-aaac-e3959258e027', 8, $md$H$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c3d07bf1-d4ae-5f48-8d16-c51c33103ff5', '618e9528-bcca-55ac-aaac-e3959258e027', 9, $md$I$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('464ea05f-5718-57ae-aacd-c639cecec6bd', 'f596be4c-376d-5151-b08d-9527f30116a0', 11, 'SHORT_ANSWER', 'READING', 4, $md$### Question 11

Questions 11-13
Questions 11-13
Answer the questions below.
Choose
NO MORE THAN THREE WORDS AND/OR A NUMBER
from the passage for each answer.
Question 11:- Because of a popular display of Nash’s works created in the army, what did his leader designate him as?
11
Question 12:- How did Nash learn oil painting?
12
Question 13:- What change took place for Nash’s painting style in the late second decade of the twentieth century?
13

Question 11:- Because of a popular display of Nash’s works created in the army, what did his leader designate him as? 11 ____$md$, NULL, ARRAY['.*a.*war.*artist.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('8851d8d7-e206-5434-b136-2b9f2a4089c6', 'f596be4c-376d-5151-b08d-9527f30116a0', 12, 'SHORT_ANSWER', 'READING', 4, $md$### Question 12

Questions 11-13
Questions 11-13
Answer the questions below.
Choose
NO MORE THAN THREE WORDS AND/OR A NUMBER
from the passage for each answer.
Question 11:- Because of a popular display of Nash’s works created in the army, what did his leader designate him as?
11
Question 12:- How did Nash learn oil painting?
12
Question 13:- What change took place for Nash’s painting style in the late second decade of the twentieth century?
13

Question 12:- How did Nash learn oil painting? 12 ____$md$, NULL, ARRAY['.*self.*taught.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('74ae7c3c-e91f-5edb-84b1-91a3378e9f33', 'f596be4c-376d-5151-b08d-9527f30116a0', 13, 'SHORT_ANSWER', 'READING', 4, $md$### Question 13

Questions 11-13
Questions 11-13
Answer the questions below.
Choose
NO MORE THAN THREE WORDS AND/OR A NUMBER
from the passage for each answer.
Question 11:- Because of a popular display of Nash’s works created in the army, what did his leader designate him as?
11
Question 12:- How did Nash learn oil painting?
12
Question 13:- What change took place for Nash’s painting style in the late second decade of the twentieth century?
13

Question 13:- What change took place for Nash’s painting style in the late second decade of the twentieth century? 13 ____$md$, NULL, ARRAY['.*more.*abstract.*']);

COMMIT;
