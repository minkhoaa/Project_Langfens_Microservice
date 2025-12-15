BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-australian-parrots-and-their-adaptation-to-habitat-change-1537'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-australian-parrots-and-their-adaptation-to-habitat-change-1537';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-australian-parrots-and-their-adaptation-to-habitat-change-1537';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-australian-parrots-and-their-adaptation-to-habitat-change-1537';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('c4fb7d11-e411-591c-9c08-8bdf5d581d36', 'ielts-reading-australian-parrots-and-their-adaptation-to-habitat-change-1537', $t$Australian parrots and their adaptation to habitat change$t$, $md$## Australian parrots and their adaptation to habitat change

Nguồn:
- Test: https://mini-ielts.com/1537/reading/australian-parrots-and-their-adaptation-to-habitat-change
- Solution: https://mini-ielts.com/1537/view-solution/reading/australian-parrots-and-their-adaptation-to-habitat-change$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('dd82ded9-288e-56c2-b3dd-8a5a60088627', 'c4fb7d11-e411-591c-9c08-8bdf5d581d36', 1, $t$Reading — Australian parrots and their adaptation to habitat change$t$, $md$Read the passage and answer questions **1–13**.

### Passage: Australian parrots and their adaptation to habitat change

A. Parrots are found across the tropic and in all southern hemisphere continents except Antarctica, but nowhere do the display such a richness of diversity and form as in Australia. One- sixth of the world’s 345 parrot species are found there, and Australia has long been renowned for the number and variety of its parrots.

B. In the 16th century, the German cartographer Mercator made a world map that included a place, somewhere near present-day Australia, that he named Terra Psittacorum – the Land of Parrots – and the first European settlers in Australia often referred to the country as Parrot Land. In 1865, the celebrated British naturalist and wildlife artist John Gould said: “No group of birds gives Australia so tropical and benign an air as the numerous species of this great family by which it is tenanted.

C. Parrots are descendants of an ancient line. Due to their great diversity, and since most species inhabit Africa, Australia and South America, it seems almost certain that parrots originated millions of years ago on the ancient southern continent of Gondwana, before it broke up into the separate southern hemisphere continents we know today. Much of Gondwana comprised vast rainforests intersected by huge slow-flowing rivers and expansive lakes, but by eight million years ago, great changes were underway. The center of the continent of Australia had begun to dry out, and the rainforests that once covered it gradually contracted to the continental margins, where, to a limited extent, they still exist today.

D. The creatures that remained in those shrinking rainforests had to adapt to the drier conditions or face extinction. Reacting to these desperate circumstances, the parrot family, typically found in jungles in other parts of the world, has populated some of Australia’s harshest environments. The parrots spread from ancestral forests through eucalypt woodlands to colonies the central deserts of Australia, and as a consequence they diversified into a wide range of species with adaptations that reflect the many changes animals and plants had to make to survive in these areas.

E. These evolutionary pressures helped mould keratin, the substance from which breaks are made into a range of tools capable of gathering the new food types favored by various species of parrot. The size of a parrot’s short, blunt beak and the length of that beak’s do curved upper section are related to the type of food each species eats. Some have comparatively long beaks that are perfect for extracting seeds from fruit; others have broader and stronger beaks that are designed for cracking hard seeds.

F. Differently shaped beaks are not the only adaptations that have been made during the developing relationship between parrots and their food plants. Like all of Australia’s many honey eating birds, the rainbow-coloured lorikeets and the flowers on which they feed have long co­evolved with features such as the shape and colour of the flowers adapted to the bird’s particular needs, and physical a example, red is the most I attractive colour to birds, and thus flowers which depend on birds for pollination are more often red, and lorikeets’ to gues have bristles which help them to collect as much pollen as possible.

G. Today, most of Australia’s parrots inhabit woodland and open forest, and their numbers decline towards both deserts and wetter areas. The majority are nomadic to some degree, moving around to take advantage of feeding and breeding places. Two of the dry country parrots, the pink and grey galah and the pink, white and yellow corella have expanded their ranges in recent years. They are among the species that have adapted well to the changes brought about by European settlement forest telling created grasslands where galahs and corellas thrive.

H. But other parrot species did not fare so well when their environments were altered. The clearing of large areas of rainforest is probably responsible for the disappearance of the double-eyed fig parrot, and numbers of ground parrots declined when a great part of their habitat was destroyed by the draining of coastal swamps. Even some parrot species that benefited from forest clearing at first are now comforted by a shortage of nesting sites due to further man-made changes.

I. New conditions also sometimes favour an incoming species over one that originally inhabited the area. For example, after farmers cleared large areas of forest on Kangaroo Island off the coast of South Australia, the island was colonised by galahs. They were soon going down holes and destroying black cockatoo eggs in order to take the hole for their own use. Their success precipitated a partial collapse in the black cockatoo population when the later lost the struggle for scarce nesting hollows.

J. There may be no final answer to ensuring an equitable balance between parrot species. Nest box programmers help ease the shortage of nesting sites in some places, but there are not enough, they are expensive and they are not an adequate substitute by large, old trees, such as the habitat they represent and nectar, pollen and seeds they provide. Competition between parrots for nest sites is a result of the changes we humans have made to the Earth. We are the most widespread and dangerous competitors that parrots have ever had to face, but we also have the knowledge and skill to maintain the wonderfully rich diversity of Australia’s parrots. All we need is the wild to do so.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('0a342ca6-7336-5d63-8f6f-20d9a82fbb67', 'dd82ded9-288e-56c2-b3dd-8a5a60088627', 1, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 1

Questions 1-6
Questions 1-6
Reading Passage has ten paragraphs A-J
Which paragraph contains the following information?
Write the correct letter, A-J in boxes 1-6 on your answer sheet
1
An example of how one parrot species may survive at the expense of another
2
A description of how plants may adapt to attract birds
3
Example of two parrot species which benefited from changes to the environment
4
How the varied Australian landscape resulted in a great variety of parrot species
5
A reason why most parrot species are native to the southern hemisphere
6
An example of a parrot species which did not survive changes to its habitat

1 ____ An example of how one parrot species may survive at the expense of another$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('961f0795-06a8-5018-83dd-975aa16a2747', '0a342ca6-7336-5d63-8f6f-20d9a82fbb67', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('01911020-9cd8-53c5-83c5-449602babcc8', '0a342ca6-7336-5d63-8f6f-20d9a82fbb67', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('08493c1b-2930-534f-8674-a153ea408dd8', '0a342ca6-7336-5d63-8f6f-20d9a82fbb67', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ca15cfd4-7262-59ab-882d-91dee97919e0', '0a342ca6-7336-5d63-8f6f-20d9a82fbb67', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0e404e7f-65d5-596b-bebd-abee4a468e82', '0a342ca6-7336-5d63-8f6f-20d9a82fbb67', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1c8e01f4-fd96-5e2b-a374-3de9e4d8dd2a', '0a342ca6-7336-5d63-8f6f-20d9a82fbb67', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d88a3c8a-1e96-5175-a07b-f164849c50c5', '0a342ca6-7336-5d63-8f6f-20d9a82fbb67', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f54c616a-982c-5825-b448-46f0e964621f', '0a342ca6-7336-5d63-8f6f-20d9a82fbb67', 8, $md$H$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e6f5c684-704e-5bf3-8948-64479a714d72', '0a342ca6-7336-5d63-8f6f-20d9a82fbb67', 9, $md$I$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('09ad71ce-ff62-5f97-b85a-0d1ee7cafaa7', '0a342ca6-7336-5d63-8f6f-20d9a82fbb67', 10, $md$J$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('aeabf0a0-1148-5eaf-87ab-bd2589004f27', 'dd82ded9-288e-56c2-b3dd-8a5a60088627', 2, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 2

Questions 1-6
Questions 1-6
Reading Passage has ten paragraphs A-J
Which paragraph contains the following information?
Write the correct letter, A-J in boxes 1-6 on your answer sheet
1
An example of how one parrot species may survive at the expense of another
2
A description of how plants may adapt to attract birds
3
Example of two parrot species which benefited from changes to the environment
4
How the varied Australian landscape resulted in a great variety of parrot species
5
A reason why most parrot species are native to the southern hemisphere
6
An example of a parrot species which did not survive changes to its habitat

2 ____ A description of how plants may adapt to attract birds$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ef7080d0-7fd3-5db2-83e2-02f1c3414c7e', 'aeabf0a0-1148-5eaf-87ab-bd2589004f27', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b70dc277-b44b-5c2b-aec3-f234c7a7689e', 'aeabf0a0-1148-5eaf-87ab-bd2589004f27', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fc44e97d-de19-5d00-a725-19ccabda2b4c', 'aeabf0a0-1148-5eaf-87ab-bd2589004f27', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('df479459-1c90-5bb8-a854-292b9ee743cb', 'aeabf0a0-1148-5eaf-87ab-bd2589004f27', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1b41464d-7eff-5bfd-8f6d-449e818f0518', 'aeabf0a0-1148-5eaf-87ab-bd2589004f27', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6d8696d0-2e22-5987-911a-8489fff81a0c', 'aeabf0a0-1148-5eaf-87ab-bd2589004f27', 6, $md$F$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('779a8dd9-687e-5623-9f6a-4ac6ad93466b', 'aeabf0a0-1148-5eaf-87ab-bd2589004f27', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('59c55db1-946c-52be-94f0-f61d2135d8af', 'aeabf0a0-1148-5eaf-87ab-bd2589004f27', 8, $md$H$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('53d31685-cd5b-5489-ad6e-c43fbe90156c', 'aeabf0a0-1148-5eaf-87ab-bd2589004f27', 9, $md$I$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('af4a350c-1813-5347-95fd-27430e0d73ee', 'aeabf0a0-1148-5eaf-87ab-bd2589004f27', 10, $md$J$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('80e7e2fc-8a36-5033-9f52-ef13b2638928', 'dd82ded9-288e-56c2-b3dd-8a5a60088627', 3, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 3

Questions 1-6
Questions 1-6
Reading Passage has ten paragraphs A-J
Which paragraph contains the following information?
Write the correct letter, A-J in boxes 1-6 on your answer sheet
1
An example of how one parrot species may survive at the expense of another
2
A description of how plants may adapt to attract birds
3
Example of two parrot species which benefited from changes to the environment
4
How the varied Australian landscape resulted in a great variety of parrot species
5
A reason why most parrot species are native to the southern hemisphere
6
An example of a parrot species which did not survive changes to its habitat

3 ____ Example of two parrot species which benefited from changes to the environment$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cc930e3f-d5ec-5aa1-be1f-9562cca17d0a', '80e7e2fc-8a36-5033-9f52-ef13b2638928', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f4183757-b0ae-54fb-8868-a2bf8f7e2a0f', '80e7e2fc-8a36-5033-9f52-ef13b2638928', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('054ee7ae-dcec-5dd4-9681-a607fc742217', '80e7e2fc-8a36-5033-9f52-ef13b2638928', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6d44b180-c62e-55b3-a440-09aafcf71294', '80e7e2fc-8a36-5033-9f52-ef13b2638928', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b44c5b73-de4b-5898-b582-1523145a6742', '80e7e2fc-8a36-5033-9f52-ef13b2638928', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('69fe89f0-5fcd-5576-ad11-4cdb4fb627fd', '80e7e2fc-8a36-5033-9f52-ef13b2638928', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('922a2e29-365d-5c3c-b07f-d4da9656e556', '80e7e2fc-8a36-5033-9f52-ef13b2638928', 7, $md$G$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7573017c-d6f2-5469-9b16-48c4a6bd1c75', '80e7e2fc-8a36-5033-9f52-ef13b2638928', 8, $md$H$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('23b034ea-f68c-53eb-8c60-f83177a88073', '80e7e2fc-8a36-5033-9f52-ef13b2638928', 9, $md$I$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b99585b5-d70c-536a-8b03-b745bf279488', '80e7e2fc-8a36-5033-9f52-ef13b2638928', 10, $md$J$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('b194d0be-995d-5fb2-bd12-5b4abacf2308', 'dd82ded9-288e-56c2-b3dd-8a5a60088627', 4, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 4

Questions 1-6
Questions 1-6
Reading Passage has ten paragraphs A-J
Which paragraph contains the following information?
Write the correct letter, A-J in boxes 1-6 on your answer sheet
1
An example of how one parrot species may survive at the expense of another
2
A description of how plants may adapt to attract birds
3
Example of two parrot species which benefited from changes to the environment
4
How the varied Australian landscape resulted in a great variety of parrot species
5
A reason why most parrot species are native to the southern hemisphere
6
An example of a parrot species which did not survive changes to its habitat

4 ____ How the varied Australian landscape resulted in a great variety of parrot species$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('198852ca-5841-5e20-8564-9af1a92cafa3', 'b194d0be-995d-5fb2-bd12-5b4abacf2308', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4ae9e338-93dd-5e9d-9ea2-cbd81d09e9c4', 'b194d0be-995d-5fb2-bd12-5b4abacf2308', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f777db5a-450d-5d0f-bb01-2b7c730ddcc6', 'b194d0be-995d-5fb2-bd12-5b4abacf2308', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0a9e5918-4c0a-5663-9d9b-62b8380e7124', 'b194d0be-995d-5fb2-bd12-5b4abacf2308', 4, $md$D$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('69999e3f-13de-5f12-a166-b9ab618a9764', 'b194d0be-995d-5fb2-bd12-5b4abacf2308', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ff9cc1a6-6b46-55d9-878f-25d69f1b9e1e', 'b194d0be-995d-5fb2-bd12-5b4abacf2308', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('20210503-f430-5ee1-a5fa-d1dec0a3cb26', 'b194d0be-995d-5fb2-bd12-5b4abacf2308', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8c1fe038-0fcf-559a-b988-94b505e6516e', 'b194d0be-995d-5fb2-bd12-5b4abacf2308', 8, $md$H$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2a702b6a-ee15-52ce-afde-e7963c7c6fce', 'b194d0be-995d-5fb2-bd12-5b4abacf2308', 9, $md$I$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ab9ec579-4308-5d12-81a4-51133d6d2c7b', 'b194d0be-995d-5fb2-bd12-5b4abacf2308', 10, $md$J$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('29685436-bead-59ba-ac4b-7588801aba80', 'dd82ded9-288e-56c2-b3dd-8a5a60088627', 5, 'MATCHING_INFORMATION', 'READING', 3, $md$### Question 5

Questions 1-6
Questions 1-6
Reading Passage has ten paragraphs A-J
Which paragraph contains the following information?
Write the correct letter, A-J in boxes 1-6 on your answer sheet
1
An example of how one parrot species may survive at the expense of another
2
A description of how plants may adapt to attract birds
3
Example of two parrot species which benefited from changes to the environment
4
How the varied Australian landscape resulted in a great variety of parrot species
5
A reason why most parrot species are native to the southern hemisphere
6
An example of a parrot species which did not survive changes to its habitat

5 ____ A reason why most parrot species are native to the southern hemisphere$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a01c28c4-a71e-539a-921d-78ff3fe8ca5b', '29685436-bead-59ba-ac4b-7588801aba80', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cde0a97f-bd2b-547b-84ca-b491942db7b6', '29685436-bead-59ba-ac4b-7588801aba80', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c8d783a7-da03-52f2-ab6f-644a84b4ffeb', '29685436-bead-59ba-ac4b-7588801aba80', 3, $md$C$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('accf15bf-10c8-545e-b3b0-85fcb4dbc4a5', '29685436-bead-59ba-ac4b-7588801aba80', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('39cefcbe-e652-5604-b428-3a240785581e', '29685436-bead-59ba-ac4b-7588801aba80', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('492456fe-247f-58c4-b045-d9a5cd57b3f1', '29685436-bead-59ba-ac4b-7588801aba80', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4c87550a-633d-51fa-9154-7ed2747aa21b', '29685436-bead-59ba-ac4b-7588801aba80', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ff1c2156-30ac-59c6-bb8b-5894aef34110', '29685436-bead-59ba-ac4b-7588801aba80', 8, $md$H$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2bd45e87-ddaa-5aad-9275-fe1dd034d48a', '29685436-bead-59ba-ac4b-7588801aba80', 9, $md$I$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('88f111d2-d5b4-5d87-8771-3916054d6f48', '29685436-bead-59ba-ac4b-7588801aba80', 10, $md$J$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('a672cf70-4d18-55b9-a23e-731136145f65', 'dd82ded9-288e-56c2-b3dd-8a5a60088627', 6, 'MATCHING_INFORMATION', 'READING', 3, $md$### Question 6

Questions 1-6
Questions 1-6
Reading Passage has ten paragraphs A-J
Which paragraph contains the following information?
Write the correct letter, A-J in boxes 1-6 on your answer sheet
1
An example of how one parrot species may survive at the expense of another
2
A description of how plants may adapt to attract birds
3
Example of two parrot species which benefited from changes to the environment
4
How the varied Australian landscape resulted in a great variety of parrot species
5
A reason why most parrot species are native to the southern hemisphere
6
An example of a parrot species which did not survive changes to its habitat

6 ____ An example of a parrot species which did not survive changes to its habitat$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e67b3208-5bc4-5ff7-b249-15735a618895', 'a672cf70-4d18-55b9-a23e-731136145f65', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1c2d3109-cdc3-5794-b43c-9db33854036f', 'a672cf70-4d18-55b9-a23e-731136145f65', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4a4dab0a-1f30-5a43-8d01-a7a2e28ca56a', 'a672cf70-4d18-55b9-a23e-731136145f65', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1e81ced7-851f-5939-94d2-e53472fec539', 'a672cf70-4d18-55b9-a23e-731136145f65', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f70b7f62-a8ce-55a2-bf34-003c921bff2b', 'a672cf70-4d18-55b9-a23e-731136145f65', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c6524265-e9f7-53cb-955e-b6016bc2764c', 'a672cf70-4d18-55b9-a23e-731136145f65', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('95af2fc2-3114-5c0a-8bd7-8e9b090f1a6a', 'a672cf70-4d18-55b9-a23e-731136145f65', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b0093573-adab-54e8-9403-ee6cdff18ff0', 'a672cf70-4d18-55b9-a23e-731136145f65', 8, $md$H$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e5e78ea4-f44f-596a-b704-b2807699a8c5', 'a672cf70-4d18-55b9-a23e-731136145f65', 9, $md$I$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2d7bb22b-1fd2-5f66-9a85-eec01fe0a391', 'a672cf70-4d18-55b9-a23e-731136145f65', 10, $md$J$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('1c2d57b7-9643-524f-b811-bca246750d0d', 'dd82ded9-288e-56c2-b3dd-8a5a60088627', 7, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 7

Questions 7-9
Questions 7-9
Choose the correct letter
A, B, c,
or
D
Write the correct letter in boxes 7-9 on your answer sheet
7.
The writer believes that most parrot species
A
Move from Africa and South America to Australia
B
Had ancestors in either Africa, Australia or South America
C
Had ancestors in a continent which later split up
D
Came from a continent now covered by water
8.
What does the Writer say about parrot's beak?
A
They are longer than those of other birds
B
They are made of a unique material
C
They are used more efficiently than those of other species
D
They are specially adapted to suit the diet
9.
Which of the following is
NOT
mentioned by the writer as a disadvantage of nesting boxes?
A
They cost too much
B
They need to be maintained
C
They provide only shelter, not food
D
They are too few of them

Choose the correct letter A, B, c, or D$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('9174f686-51e6-503b-a290-dea5bbb08286', 'dd82ded9-288e-56c2-b3dd-8a5a60088627', 8, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 8

Questions 7-9
Questions 7-9
Choose the correct letter
A, B, c,
or
D
Write the correct letter in boxes 7-9 on your answer sheet
7.
The writer believes that most parrot species
A
Move from Africa and South America to Australia
B
Had ancestors in either Africa, Australia or South America
C
Had ancestors in a continent which later split up
D
Came from a continent now covered by water
8.
What does the Writer say about parrot's beak?
A
They are longer than those of other birds
B
They are made of a unique material
C
They are used more efficiently than those of other species
D
They are specially adapted to suit the diet
9.
Which of the following is
NOT
mentioned by the writer as a disadvantage of nesting boxes?
A
They cost too much
B
They need to be maintained
C
They provide only shelter, not food
D
They are too few of them

Choose the correct letter A, B, c, or D$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('be929b92-606d-570d-9521-2a7713b19c1c', 'dd82ded9-288e-56c2-b3dd-8a5a60088627', 9, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 9

Questions 7-9
Questions 7-9
Choose the correct letter
A, B, c,
or
D
Write the correct letter in boxes 7-9 on your answer sheet
7.
The writer believes that most parrot species
A
Move from Africa and South America to Australia
B
Had ancestors in either Africa, Australia or South America
C
Had ancestors in a continent which later split up
D
Came from a continent now covered by water
8.
What does the Writer say about parrot's beak?
A
They are longer than those of other birds
B
They are made of a unique material
C
They are used more efficiently than those of other species
D
They are specially adapted to suit the diet
9.
Which of the following is
NOT
mentioned by the writer as a disadvantage of nesting boxes?
A
They cost too much
B
They need to be maintained
C
They provide only shelter, not food
D
They are too few of them

Choose the correct letter A, B, c, or D$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('d53630f2-122d-5f87-88c2-a66fc49dd1af', 'dd82ded9-288e-56c2-b3dd-8a5a60088627', 10, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 10

Questions 10-13
Questions 10-13
Complete the summary below
Choose
NO MORE THANH TWO WORDS AND/OR A NUMBER
from the passage for each answer.
Write your answers in boxes 10-13 on your answer sheet
Parrots in Australia
There are 345 varieties of parrot in existence and, of these,
10
live in Australia. As early as the
11
, the mapmaker
12
recognized that parrots lived in that part of the world.
13
, the famous painter of animals and birds, commented on the size and beauty of the Australian parrot family.

There are 345 varieties of parrot in existence and, of these, 10 ____ live in Australia. As early as the 11 ____ , the mapmaker 12 ____ recognized that parrots lived in that part of the world. 13 ____ , the famous painter of animals and birds, commented on the size and beauty of the Australian parrot family.$md$, NULL, ARRAY['.*one.*sixth.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('c084edbf-8884-5846-8b14-15fe31a18d84', 'dd82ded9-288e-56c2-b3dd-8a5a60088627', 11, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 11

Questions 10-13
Questions 10-13
Complete the summary below
Choose
NO MORE THANH TWO WORDS AND/OR A NUMBER
from the passage for each answer.
Write your answers in boxes 10-13 on your answer sheet
Parrots in Australia
There are 345 varieties of parrot in existence and, of these,
10
live in Australia. As early as the
11
, the mapmaker
12
recognized that parrots lived in that part of the world.
13
, the famous painter of animals and birds, commented on the size and beauty of the Australian parrot family.

There are 345 varieties of parrot in existence and, of these, 10 ____ live in Australia. As early as the 11 ____ , the mapmaker 12 ____ recognized that parrots lived in that part of the world. 13 ____ , the famous painter of animals and birds, commented on the size and beauty of the Australian parrot family.$md$, NULL, ARRAY['.*one.*sixth.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('9d7d409a-af21-5e89-b44e-16ba2b36695c', 'dd82ded9-288e-56c2-b3dd-8a5a60088627', 12, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 12

Questions 10-13
Questions 10-13
Complete the summary below
Choose
NO MORE THANH TWO WORDS AND/OR A NUMBER
from the passage for each answer.
Write your answers in boxes 10-13 on your answer sheet
Parrots in Australia
There are 345 varieties of parrot in existence and, of these,
10
live in Australia. As early as the
11
, the mapmaker
12
recognized that parrots lived in that part of the world.
13
, the famous painter of animals and birds, commented on the size and beauty of the Australian parrot family.

There are 345 varieties of parrot in existence and, of these, 10 ____ live in Australia. As early as the 11 ____ , the mapmaker 12 ____ recognized that parrots lived in that part of the world. 13 ____ , the famous painter of animals and birds, commented on the size and beauty of the Australian parrot family.$md$, NULL, ARRAY['.*one.*sixth.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('2821692a-f878-537a-9aa6-85e9f8cffe6c', 'dd82ded9-288e-56c2-b3dd-8a5a60088627', 13, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 13

Questions 10-13
Questions 10-13
Complete the summary below
Choose
NO MORE THANH TWO WORDS AND/OR A NUMBER
from the passage for each answer.
Write your answers in boxes 10-13 on your answer sheet
Parrots in Australia
There are 345 varieties of parrot in existence and, of these,
10
live in Australia. As early as the
11
, the mapmaker
12
recognized that parrots lived in that part of the world.
13
, the famous painter of animals and birds, commented on the size and beauty of the Australian parrot family.

There are 345 varieties of parrot in existence and, of these, 10 ____ live in Australia. As early as the 11 ____ , the mapmaker 12 ____ recognized that parrots lived in that part of the world. 13 ____ , the famous painter of animals and birds, commented on the size and beauty of the Australian parrot family.$md$, NULL, ARRAY['.*one.*sixth.*']);

COMMIT;
