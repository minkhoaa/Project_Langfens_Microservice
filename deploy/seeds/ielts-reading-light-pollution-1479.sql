BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-light-pollution-1479'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-light-pollution-1479';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-light-pollution-1479';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-light-pollution-1479';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('967640b0-7a71-5395-a998-15a7a8edd251', 'ielts-reading-light-pollution-1479', $t$Light pollution$t$, $md$## Light pollution

Nguồn:
- Test: https://mini-ielts.com/1479/reading/light-pollution
- Solution: https://mini-ielts.com/1479/view-solution/reading/light-pollution$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('aaf14ca1-6f5f-57fd-ac02-01c331bc1266', '967640b0-7a71-5395-a998-15a7a8edd251', 1, $t$Reading — Light pollution$t$, $md$Read the passage and answer questions **1–13**.

### Passage: Light pollution

{A} If humans were truly at home under the light of the moon and stars, we would go into darkness happily, the midnight world as visible to us as it is to the vast number of nocturnal species on this planet. Instead, we are diurnal creatures, with eyes adapted to living in the sun’s light. This is a basic evolutionary fact, even though most of us don’t think of ourselves as diurnal beings any more than we think of ourselves as primates or mammals, or Earthlings. Yet it’s the only way to explain what we’ve done to the night: We’ve engineered it to receive us by filling it with light.

{B} This kind of engineering is no different than damming a river. Its benefits come with consequences—called light pollution—whose effects scientists are only now beginning to study. Light pollution is largely the result of bad lighting design, which allows artificial light to shine outward and upward into the sky, where it’s not wanted, instead of focusing it downward, where it is. Ill-designed lighting washes out the darkness of night and radically alters the light levels and light rhythms—to which many forms of life, including ourselves, have adapted.

{C} Now most of humanity lives under intersecting domes of reflected, refracted light, of scattering rays from overlit cities and suburbs, from light-flooded highways and factories. Nearly all of nighttime Europe is a nebula of light, as is most of the United States and all of Japan. In the south Atlantic the glow from a single fishing fleet squid fishermen during their prey with metal halide lamps—can be seen from space, burning brighter, in fact, than Buenos Aires or Rio de Janeiro.

{D} We’ve lit up the night as if it were an unoccupied country when nothing could be further from the truth. Among mammals alone, the number of nocturnal species is astonishing. Light is a powerful biological force, and in many species, it acts as a magnet, a process being studied by researchers such as Travis Longcore and Catherine Rich, co-founders of the Los Angeles-based Urban Wildlands Group. The effect is so powerful that scientists speak of songbirds and seabirds being “captured” by searchlights on land or by the light from gas flares on marine oil platforms, circling and circling in the thousands until they drop. Migrating at night, birds are apt to collide with brightly lit tall buildings; immature birds on their first journey suffer disproportionately.

{E} Insects, of course, cluster around streetlights, and feeding at those insect clusters is now ingrained in the lives of many bat species. In some Swiss valleys, the European lesser horseshoe bat began to vanish after streetlights were installed, perhaps because those valleys were suddenly filled with light-feeding pipistrelle bats. Other nocturnal mammals—including desert rodents, fruit bats, opossums, and badgers-forage more cautiously under the permanent full moon of light pollution because they’ve become easier targets for predators.

{F} Some birds—blackbirds and nightingales, among others—sing at unnatural hours in the presence of artificial light. Scientists have determined that long artificial days— and artificially short nights induce early breeding in a wide range of birds. And because a longer day allows for longer feeding, it can also affect migration schedules. One population of Bewick’s swans wintering in England put on fat more rapidly than usual, priming them to begin their Siberian migration early. The problem, of course, is that migration, like most other aspects of bird behaviour, is a precisely timed biological behaviour. Leaving early may mean arriving too soon for nesting conditions to be right

{G} Nesting sea turtles, which show a natural predisposition for dark beaches, find fewer and fewer of them to nest on. Their hatchlings, which gravitate toward the brighter, more reflective sea horizon, find themselves confused by artificial lighting behind the beach. In Florida alone, hatchling losses number in the hundreds of thousands every year. Frogs and toads living near brightly lit highways suffer nocturnal light levels that are as much as a million times brighter than normal, throwing nearly every aspect of their behaviour out of joint, including their nighttime breeding choruses.

{H} Of all the pollution we face, light pollution is perhaps the most easily remedied. Simple changes in lighting design and installation yield immediate changes in the amount of light spilt into the atmosphere and, often, immediate energy savings.

{I} It was once thought that light pollution only affected astronomers, who need to see the night sky in all its glorious clarity. And, in fact, some of the earliest civic efforts to control light pollution—in Flagstaff, Arizona, half a century ago—were made to protect the view from Lowell Observatory, which sits high above that city. Flagstaff has tightened its regulations since then, and in 2001 it was declared the first International Dark Sky City. By now the effort to control light pollution has spread around the globe. More and more cities and even entire countries, such as the Czech Republic, have committed themselves to reducing unwanted glare.

{J} Unlike astronomers, most of us may not need an undiminished view of the night sky for our work, but like most other creatures we do need darkness. Darkness is as essential to our biological welfare, to our internal clockwork, as light itself. The regular oscillation of waking and sleep in our lives, one of our circadian rhythms—is nothing less than a biological expression of the regular oscillation of light on Earth. So fundamental are these rhythms to our being that altering them is like altering gravity.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('06f9ab85-11c0-5c79-b6bb-2927beece575', 'aaf14ca1-6f5f-57fd-ac02-01c331bc1266', 1, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 1

Questions 1-6
Questions 1-6
The reading Passage has ten paragraphs A-J.
Which paragraph contains the following information?
Write the correct letter A-J, in boxes 1-6 on your answer sheet.
1
A reason that contributes to light pollution.
2
A city has lessened light pollution successfully.
3
The importance of darkness.
4
The popularity of light pollution in the world.
5
Methods to reduce light pollution.
6
The reason why we have changed the night.

1 ____ A reason that contributes to light pollution.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0754ec5c-6e14-5096-8366-cfcbda2e5d79', '06f9ab85-11c0-5c79-b6bb-2927beece575', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f05df05b-6d56-55e6-bcba-918a42cec968', '06f9ab85-11c0-5c79-b6bb-2927beece575', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7a575a7b-54d5-59e3-8050-3b267aa06a45', '06f9ab85-11c0-5c79-b6bb-2927beece575', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ca6112dc-245c-5f64-858b-1a5bebec7a41', '06f9ab85-11c0-5c79-b6bb-2927beece575', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fcb6292e-0b24-5f6f-b410-d0276581dc87', '06f9ab85-11c0-5c79-b6bb-2927beece575', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4727e11a-84a3-5674-9854-c478dbe29a76', '06f9ab85-11c0-5c79-b6bb-2927beece575', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9e127bba-a713-5b33-bd06-dc75c51153ea', '06f9ab85-11c0-5c79-b6bb-2927beece575', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('88422332-88f8-59cc-ba9a-7aba0308b62e', '06f9ab85-11c0-5c79-b6bb-2927beece575', 8, $md$H$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f6a37ae6-4101-525e-b98c-78fb10cbe71b', '06f9ab85-11c0-5c79-b6bb-2927beece575', 9, $md$I$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('eca8ffe6-c227-5d1b-be15-5cfe02136134', '06f9ab85-11c0-5c79-b6bb-2927beece575', 10, $md$J$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('5885b930-8116-5476-836f-9357bd95105b', 'aaf14ca1-6f5f-57fd-ac02-01c331bc1266', 2, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 2

Questions 1-6
Questions 1-6
The reading Passage has ten paragraphs A-J.
Which paragraph contains the following information?
Write the correct letter A-J, in boxes 1-6 on your answer sheet.
1
A reason that contributes to light pollution.
2
A city has lessened light pollution successfully.
3
The importance of darkness.
4
The popularity of light pollution in the world.
5
Methods to reduce light pollution.
6
The reason why we have changed the night.

2 ____ A city has lessened light pollution successfully.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('40ee3ea3-1a4b-5b61-966e-a2cb5640bc4e', '5885b930-8116-5476-836f-9357bd95105b', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3646f5de-5cf2-5cf7-a783-a76880cb1e78', '5885b930-8116-5476-836f-9357bd95105b', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('03db095d-525b-585e-a206-9960df2d1193', '5885b930-8116-5476-836f-9357bd95105b', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5682dd7c-38c0-5491-85c8-3d383a2a4318', '5885b930-8116-5476-836f-9357bd95105b', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9974fb02-fa28-5769-9493-df0b1a837d12', '5885b930-8116-5476-836f-9357bd95105b', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8cb0dc35-04e4-5748-93f8-891e3fef706d', '5885b930-8116-5476-836f-9357bd95105b', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a25fd9af-72dd-5750-ac33-206afe78ad96', '5885b930-8116-5476-836f-9357bd95105b', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7e144675-d21b-58b0-9be8-693b18aa41d7', '5885b930-8116-5476-836f-9357bd95105b', 8, $md$H$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4ae6a1e5-3837-5ffe-9158-ad5cb0752676', '5885b930-8116-5476-836f-9357bd95105b', 9, $md$I$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('71a8d271-e89e-54c4-a956-9b27e8df6872', '5885b930-8116-5476-836f-9357bd95105b', 10, $md$J$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('43decaaa-e9dc-552a-be4b-e10104cc71a9', 'aaf14ca1-6f5f-57fd-ac02-01c331bc1266', 3, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 3

Questions 1-6
Questions 1-6
The reading Passage has ten paragraphs A-J.
Which paragraph contains the following information?
Write the correct letter A-J, in boxes 1-6 on your answer sheet.
1
A reason that contributes to light pollution.
2
A city has lessened light pollution successfully.
3
The importance of darkness.
4
The popularity of light pollution in the world.
5
Methods to reduce light pollution.
6
The reason why we have changed the night.

3 ____ The importance of darkness.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7b2ccb94-45f1-55cf-afcb-ccce1e4457df', '43decaaa-e9dc-552a-be4b-e10104cc71a9', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('09be200f-b3d8-5e25-8781-2148eb9495e5', '43decaaa-e9dc-552a-be4b-e10104cc71a9', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3e5029e4-774b-572d-a9d7-b94c2404384a', '43decaaa-e9dc-552a-be4b-e10104cc71a9', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('46ec1ff9-4241-511c-9098-e73f55a9590b', '43decaaa-e9dc-552a-be4b-e10104cc71a9', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3ce99a96-1d10-52a6-a6bd-6489e7e85873', '43decaaa-e9dc-552a-be4b-e10104cc71a9', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7125d614-29ab-5d38-9852-bef93cdcc1ad', '43decaaa-e9dc-552a-be4b-e10104cc71a9', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6bdce979-37b2-564b-a511-a7d1182e2b47', '43decaaa-e9dc-552a-be4b-e10104cc71a9', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('611d5c74-58c6-5907-b400-ee51f10ed1c0', '43decaaa-e9dc-552a-be4b-e10104cc71a9', 8, $md$H$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('44bf560b-9a5b-5531-8071-24e123a4471f', '43decaaa-e9dc-552a-be4b-e10104cc71a9', 9, $md$I$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ea224d37-9bcc-5613-aa4c-1d696764f069', '43decaaa-e9dc-552a-be4b-e10104cc71a9', 10, $md$J$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('a534d50d-3422-53d5-839f-8807257f4ab6', 'aaf14ca1-6f5f-57fd-ac02-01c331bc1266', 4, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 4

Questions 1-6
Questions 1-6
The reading Passage has ten paragraphs A-J.
Which paragraph contains the following information?
Write the correct letter A-J, in boxes 1-6 on your answer sheet.
1
A reason that contributes to light pollution.
2
A city has lessened light pollution successfully.
3
The importance of darkness.
4
The popularity of light pollution in the world.
5
Methods to reduce light pollution.
6
The reason why we have changed the night.

4 ____ The popularity of light pollution in the world.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e3eee3c2-3531-5462-83c0-d20e0da8f217', 'a534d50d-3422-53d5-839f-8807257f4ab6', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c9c1b548-3d99-52b6-8a73-a1fdac01b8ec', 'a534d50d-3422-53d5-839f-8807257f4ab6', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cede8b70-c5ae-5a10-b8d8-2f8b6845d6c1', 'a534d50d-3422-53d5-839f-8807257f4ab6', 3, $md$C$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2fe6fca6-8b4e-53b4-9afd-fc2a5173a9eb', 'a534d50d-3422-53d5-839f-8807257f4ab6', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('56c90578-1425-5bc3-a424-408f5b2d06a6', 'a534d50d-3422-53d5-839f-8807257f4ab6', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e0b803e8-758e-5e15-989d-a01806c64dbb', 'a534d50d-3422-53d5-839f-8807257f4ab6', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('392d3337-2e8e-5c08-8ce4-4d73d70afe79', 'a534d50d-3422-53d5-839f-8807257f4ab6', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ba229090-de40-5e09-a0f6-f8cccddefbfb', 'a534d50d-3422-53d5-839f-8807257f4ab6', 8, $md$H$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8693aeae-322a-5afb-a607-76552aaa5e2b', 'a534d50d-3422-53d5-839f-8807257f4ab6', 9, $md$I$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d147d144-7027-5eb2-b28e-669fd4a003f3', 'a534d50d-3422-53d5-839f-8807257f4ab6', 10, $md$J$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('49f65053-24c6-524f-bbac-fa290c1f49a5', 'aaf14ca1-6f5f-57fd-ac02-01c331bc1266', 5, 'MATCHING_INFORMATION', 'READING', 3, $md$### Question 5

Questions 1-6
Questions 1-6
The reading Passage has ten paragraphs A-J.
Which paragraph contains the following information?
Write the correct letter A-J, in boxes 1-6 on your answer sheet.
1
A reason that contributes to light pollution.
2
A city has lessened light pollution successfully.
3
The importance of darkness.
4
The popularity of light pollution in the world.
5
Methods to reduce light pollution.
6
The reason why we have changed the night.

5 ____ Methods to reduce light pollution.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cdae473a-9bb6-50ef-80d4-10d68c67a565', '49f65053-24c6-524f-bbac-fa290c1f49a5', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a690d7c9-289a-57da-90b9-1ef397a8be1f', '49f65053-24c6-524f-bbac-fa290c1f49a5', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5987aa5d-4980-5f98-a142-ce8031dec73f', '49f65053-24c6-524f-bbac-fa290c1f49a5', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2c56511b-3df5-5811-95e2-8d4f819d4293', '49f65053-24c6-524f-bbac-fa290c1f49a5', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('15d705ac-e028-521d-b419-9a696983d565', '49f65053-24c6-524f-bbac-fa290c1f49a5', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('60e0aaab-b5ef-5425-bc1e-ee55fb8392b8', '49f65053-24c6-524f-bbac-fa290c1f49a5', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('77697e99-f1a3-5dfc-95a7-bcb7cb9a2247', '49f65053-24c6-524f-bbac-fa290c1f49a5', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('78dc47be-bd71-57f7-983f-d007d3b6a151', '49f65053-24c6-524f-bbac-fa290c1f49a5', 8, $md$H$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e3549f8e-90e2-5610-908c-77a04c0cc208', '49f65053-24c6-524f-bbac-fa290c1f49a5', 9, $md$I$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cf24356b-0eee-54ee-80cd-86ff7f46acc3', '49f65053-24c6-524f-bbac-fa290c1f49a5', 10, $md$J$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('ddaf56e8-b681-51c2-b882-14d31cb67b49', 'aaf14ca1-6f5f-57fd-ac02-01c331bc1266', 6, 'MATCHING_INFORMATION', 'READING', 3, $md$### Question 6

Questions 1-6
Questions 1-6
The reading Passage has ten paragraphs A-J.
Which paragraph contains the following information?
Write the correct letter A-J, in boxes 1-6 on your answer sheet.
1
A reason that contributes to light pollution.
2
A city has lessened light pollution successfully.
3
The importance of darkness.
4
The popularity of light pollution in the world.
5
Methods to reduce light pollution.
6
The reason why we have changed the night.

6 ____ The reason why we have changed the night.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7f4ad80d-01da-5b9e-b4a1-ed6a6f331d7d', 'ddaf56e8-b681-51c2-b882-14d31cb67b49', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2aca89f0-4d10-55d9-9855-b158e0a5e9e4', 'ddaf56e8-b681-51c2-b882-14d31cb67b49', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a02d4308-1c7a-5880-9ddc-484cbbc97ea7', 'ddaf56e8-b681-51c2-b882-14d31cb67b49', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d0dbbdac-03d9-53bc-9837-7281fc8068b2', 'ddaf56e8-b681-51c2-b882-14d31cb67b49', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e9cbe10e-993a-56b1-bef5-6b9baa9eef82', 'ddaf56e8-b681-51c2-b882-14d31cb67b49', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b2252e6c-2863-5a20-9be6-f7f0ac8c1fbe', 'ddaf56e8-b681-51c2-b882-14d31cb67b49', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('11a3d9b2-2e94-5fb8-b843-d163b80287e5', 'ddaf56e8-b681-51c2-b882-14d31cb67b49', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1844052c-bb7a-57ff-963c-31e9a5ff966d', 'ddaf56e8-b681-51c2-b882-14d31cb67b49', 8, $md$H$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d6b567a2-9910-53c0-a76c-5cc8da6bc75b', 'ddaf56e8-b681-51c2-b882-14d31cb67b49', 9, $md$I$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b1c7b36c-b93a-5e11-95c5-1ab6aba4bce2', 'ddaf56e8-b681-51c2-b882-14d31cb67b49', 10, $md$J$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('ce214920-767d-539e-9d9a-55323a1ff1fb', 'aaf14ca1-6f5f-57fd-ac02-01c331bc1266', 7, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 7

Questions 7-8
Questions 7-8
Choose the correct letter, A, B, C, or D.
Write your answers in boxes 7-8 on your answer sheet.
Question 7:
How does light pollution influence creatures?
A
by bad lighting design
B
by changing the cities and suburbs creatures are used to
C
by changing the directions of light
D
by changing the light creatures are used to
Question 8:
Some aspects of animals’ lives are affected by unwanted light, EXCEPT:
A
Migration
B
Reproduction
C
Natural life span
D
Feeding

Choose the correct letter, A, B, C, or D.$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('50b5e75f-f54a-518e-9a16-10b560246267', 'aaf14ca1-6f5f-57fd-ac02-01c331bc1266', 8, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 8

Questions 7-8
Questions 7-8
Choose the correct letter, A, B, C, or D.
Write your answers in boxes 7-8 on your answer sheet.
Question 7:
How does light pollution influence creatures?
A
by bad lighting design
B
by changing the cities and suburbs creatures are used to
C
by changing the directions of light
D
by changing the light creatures are used to
Question 8:
Some aspects of animals’ lives are affected by unwanted light, EXCEPT:
A
Migration
B
Reproduction
C
Natural life span
D
Feeding

Choose the correct letter, A, B, C, or D.$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('32ca847f-b620-552d-bf3c-f3bda20f15c9', 'aaf14ca1-6f5f-57fd-ac02-01c331bc1266', 9, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 9

Questions 9-13
Questions 9-13
Light pollution has affected many forms of life. Use the information in the passage to match the animals with the relevant information below. Write the appropriate letters A-G in boxes 9-13 on your answer sheet.
9
Songbirds
10
Horseshoe bat
11
Nightingales
12
Bewick’s swans
13
Sea turtles
(A)
eat too much and migrate in advance.
(B)
would not like to sing songs at night.
(C)
is attracted by the light and then a crash happens.
(D)
suffers from food shortages because of competitors.
(E)
have become easier targets for predators.
(F)
be active at unusual times.
(G)
have trouble inbreeding.

9 ____ Songbirds$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('925497e0-72e3-5804-a3ef-cd50a414fa0e', '32ca847f-b620-552d-bf3c-f3bda20f15c9', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a3ab0cc6-7f4f-5aeb-8982-cf22ca4a3a7f', '32ca847f-b620-552d-bf3c-f3bda20f15c9', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8e588227-fe48-5856-a33f-2c0ac9c3ff88', '32ca847f-b620-552d-bf3c-f3bda20f15c9', 3, $md$C$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2fb224f2-a14c-5728-8b6d-103ca9772078', '32ca847f-b620-552d-bf3c-f3bda20f15c9', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('11d79686-b975-5a87-b339-d0d4605703e5', '32ca847f-b620-552d-bf3c-f3bda20f15c9', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('868696e8-f621-5679-87fe-2567e121e227', '32ca847f-b620-552d-bf3c-f3bda20f15c9', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cef0bab1-60cb-5939-987a-483539319fa9', '32ca847f-b620-552d-bf3c-f3bda20f15c9', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('629c5a85-49f7-5642-9b53-03be8f8d2bb0', 'aaf14ca1-6f5f-57fd-ac02-01c331bc1266', 10, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 10

Questions 9-13
Questions 9-13
Light pollution has affected many forms of life. Use the information in the passage to match the animals with the relevant information below. Write the appropriate letters A-G in boxes 9-13 on your answer sheet.
9
Songbirds
10
Horseshoe bat
11
Nightingales
12
Bewick’s swans
13
Sea turtles
(A)
eat too much and migrate in advance.
(B)
would not like to sing songs at night.
(C)
is attracted by the light and then a crash happens.
(D)
suffers from food shortages because of competitors.
(E)
have become easier targets for predators.
(F)
be active at unusual times.
(G)
have trouble inbreeding.

10 ____ Horseshoe bat$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('856a466d-5a5b-58e8-bf50-b6e632a5dd28', '629c5a85-49f7-5642-9b53-03be8f8d2bb0', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('42bfeff7-5169-5810-b4f0-20891ee8d372', '629c5a85-49f7-5642-9b53-03be8f8d2bb0', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bd7c8796-ad0e-5ed9-a89a-72363ade50b1', '629c5a85-49f7-5642-9b53-03be8f8d2bb0', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('20f3041a-b201-5e2d-82ae-f5b97a19d933', '629c5a85-49f7-5642-9b53-03be8f8d2bb0', 4, $md$D$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cd4dbdda-85bf-5cb1-bbab-75fc92c63fd9', '629c5a85-49f7-5642-9b53-03be8f8d2bb0', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('93ef740f-e5eb-5876-a003-b001ef4a96fe', '629c5a85-49f7-5642-9b53-03be8f8d2bb0', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0dcbdad1-c8ec-5942-87d3-92e270c0c58d', '629c5a85-49f7-5642-9b53-03be8f8d2bb0', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('9ca5769e-0558-5f69-8637-c2b32a5cd258', 'aaf14ca1-6f5f-57fd-ac02-01c331bc1266', 11, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 11

Questions 9-13
Questions 9-13
Light pollution has affected many forms of life. Use the information in the passage to match the animals with the relevant information below. Write the appropriate letters A-G in boxes 9-13 on your answer sheet.
9
Songbirds
10
Horseshoe bat
11
Nightingales
12
Bewick’s swans
13
Sea turtles
(A)
eat too much and migrate in advance.
(B)
would not like to sing songs at night.
(C)
is attracted by the light and then a crash happens.
(D)
suffers from food shortages because of competitors.
(E)
have become easier targets for predators.
(F)
be active at unusual times.
(G)
have trouble inbreeding.

11 ____ Nightingales$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('155c7c82-e08f-599c-9930-bd8d4a265f8f', '9ca5769e-0558-5f69-8637-c2b32a5cd258', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a6552eb0-4972-5c31-aba3-48b7e97a087b', '9ca5769e-0558-5f69-8637-c2b32a5cd258', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('aaab871d-26df-5478-980c-f8b5e9ba56c5', '9ca5769e-0558-5f69-8637-c2b32a5cd258', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6578d151-7257-5685-93e1-ee8bb86ef54c', '9ca5769e-0558-5f69-8637-c2b32a5cd258', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('929bb3f3-5e0b-5030-b44b-8ecac8e3af1e', '9ca5769e-0558-5f69-8637-c2b32a5cd258', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f7859ae0-9a7b-5ba3-bea4-4bb3bb8abe0e', '9ca5769e-0558-5f69-8637-c2b32a5cd258', 6, $md$F$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4d342cba-f6df-5139-87c4-47374e121f1b', '9ca5769e-0558-5f69-8637-c2b32a5cd258', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('e5153db4-fe24-598c-9a8e-2d6b49b1b865', 'aaf14ca1-6f5f-57fd-ac02-01c331bc1266', 12, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 12

Questions 9-13
Questions 9-13
Light pollution has affected many forms of life. Use the information in the passage to match the animals with the relevant information below. Write the appropriate letters A-G in boxes 9-13 on your answer sheet.
9
Songbirds
10
Horseshoe bat
11
Nightingales
12
Bewick’s swans
13
Sea turtles
(A)
eat too much and migrate in advance.
(B)
would not like to sing songs at night.
(C)
is attracted by the light and then a crash happens.
(D)
suffers from food shortages because of competitors.
(E)
have become easier targets for predators.
(F)
be active at unusual times.
(G)
have trouble inbreeding.

12 ____ Bewick’s swans$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f3e5bcac-67bd-5d54-b652-b590d63d36c2', 'e5153db4-fe24-598c-9a8e-2d6b49b1b865', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('826ee538-3aaa-5dbb-b85c-999c892b82bd', 'e5153db4-fe24-598c-9a8e-2d6b49b1b865', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('530f342f-da8b-578c-b340-68ac2433a51e', 'e5153db4-fe24-598c-9a8e-2d6b49b1b865', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('da1bedf4-658e-542c-883d-8e7117bfb56c', 'e5153db4-fe24-598c-9a8e-2d6b49b1b865', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6f65d1dc-2456-54fe-a2d6-c03c6da99bfe', 'e5153db4-fe24-598c-9a8e-2d6b49b1b865', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b3a2b337-9929-53cb-a8be-5a04a6c7449d', 'e5153db4-fe24-598c-9a8e-2d6b49b1b865', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2af8edfc-e745-513c-8585-9b6ee2dc151d', 'e5153db4-fe24-598c-9a8e-2d6b49b1b865', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('5b600ae7-2fb3-5506-ac47-c8d851247021', 'aaf14ca1-6f5f-57fd-ac02-01c331bc1266', 13, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 13

Questions 9-13
Questions 9-13
Light pollution has affected many forms of life. Use the information in the passage to match the animals with the relevant information below. Write the appropriate letters A-G in boxes 9-13 on your answer sheet.
9
Songbirds
10
Horseshoe bat
11
Nightingales
12
Bewick’s swans
13
Sea turtles
(A)
eat too much and migrate in advance.
(B)
would not like to sing songs at night.
(C)
is attracted by the light and then a crash happens.
(D)
suffers from food shortages because of competitors.
(E)
have become easier targets for predators.
(F)
be active at unusual times.
(G)
have trouble inbreeding.

13 ____ Sea turtles$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('59e6c9d3-130d-568b-81ed-37eaa73b7eaa', '5b600ae7-2fb3-5506-ac47-c8d851247021', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('eb9f4512-5270-51c8-b7ea-a8eec515fca4', '5b600ae7-2fb3-5506-ac47-c8d851247021', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6674d9a2-d92a-51f3-8fe1-729d13dc07cc', '5b600ae7-2fb3-5506-ac47-c8d851247021', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1fc111f3-7251-53ee-b22c-cff83c4196c1', '5b600ae7-2fb3-5506-ac47-c8d851247021', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3bd5fdfe-6843-5505-9536-8c5dc74881e0', '5b600ae7-2fb3-5506-ac47-c8d851247021', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('be69528b-e6cd-5619-9c89-d313c394a072', '5b600ae7-2fb3-5506-ac47-c8d851247021', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6fe310fd-7726-52e5-92b4-debe755ff2af', '5b600ae7-2fb3-5506-ac47-c8d851247021', 7, $md$G$md$, true);

COMMIT;
