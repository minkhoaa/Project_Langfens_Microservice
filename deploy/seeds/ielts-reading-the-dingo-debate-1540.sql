BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-the-dingo-debate-1540'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-the-dingo-debate-1540';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-the-dingo-debate-1540';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-the-dingo-debate-1540';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('69868d59-1635-585a-81b4-ced8c76ad150', 'ielts-reading-the-dingo-debate-1540', $t$The dingo debate$t$, $md$## The dingo debate

Nguồn:
- Test: https://mini-ielts.com/1540/reading/the-dingo-debate
- Solution: https://mini-ielts.com/1540/view-solution/reading/the-dingo-debate$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('cd93ac07-eb5f-505b-8624-bafebea64869', '69868d59-1635-585a-81b4-ced8c76ad150', 1, $t$Reading — The dingo debate$t$, $md$Read the passage and answer questions **1–13**.

### Passage: The dingo debate

Graziers see them as pests, and poisoning is common, but some biologists think Australia’s dingoes are the best weapon in a war against imported cats and foxes.

A A plane flies a slow pattern over Carlton Hill station, a 3,600 square kilometre ranch in the Kimberley region in northwest Australia. As the plane circles, those aboard drop 1,000 small pieces of meat, one by one, onto the scrubland below, each piece laced with poison; this practice is known as baiting.

Besides 50,000 head of cattle, Carlton Hill is home to the dingo, Australia’s largest mammalian predator and the bane of a grazier's (cattle farmer's) life. Stuart McKechnie, manager of Carlton Hill, complains that graziers’ livelihoods are threatened when dingoes prey on cattle. But one man wants the baiting to end, and for dingoes to once again roam Australia’s wide-open spaces. According to Chris Johnson of James Cook University, ‘Australia needs more dingoes to protect our biodiversity.’

B About 4,000 years ago, Asian sailors introduced dingoes to Australia. Throughout the ensuing millennia, these descendants of the wolf spread across the continent and, as the Tasmanian tiger disappeared completely from Australia, dingoes became Australia’s top predators. As agricultural development took place, the European settlers found that they could not safely keep their livestock where dingoes roamed. So began one of the most sustained efforts at pest control in Australia’s history. Over the last 150 years, dingoes have been shot and poisoned, and fences have been used in an attempt to keep them away from livestock. But at the same time, as the European settlers tried to eliminate one native pest from Australia, they introduced more of their own.

C In 1860, the rabbit was unleashed on Australia by a wealthy landowner and by 1980 rabbits had covered most of the mainland. Rabbits provide huge prey base for two other introduced species: the feral (wild) cat and the red fox.

The Interaction between foxes, cats and rabbits is a huge problem for native mammals. In good years, rabbit numbers increase dramatically, and fox and cat populations grow quickly in response to the abundance of this prey. When bad seasons follow, rabbit numbers are significantly reduced - and the dwindling but still large fox and cat populations are left with little to eat besides native mammals.

D Australian mammals generally reproduce much more slowly than rabbits, cats and foxes - and adaption to prevent overpopulation in the arid environment, where food can be scarce and unreliable - and populations decline because they can’t grow fast enough to replace animals killed by the predators. Johnson says dingoes are the solution to this problem because they keep cat and fox populations under control. Besides regularly eating the smaller predators, dingoes will kill them simply to lessen competition.

Dingo packs live in large, stable territories and generally have only one fertile, which limits their rate of increase. In the 4,000 years that dingoes have been Australia, they have contributed to few, if any, extinctions, Johnsons says.

E Reaching out from a desolate spot where three states meet, for 2,500 km in either direction, is the world’s longest fence, two metres high and stretching from the coast in Queensland to the Great Australian Bight in South Australia; it is there to keep dingoes out of southeast, the fence separates the main types of livestock found in Australia. To the northwest of the fence, cattle predominate; to the southwest, sheep fill the landscape. In fact, Australia is a land dominated by these animals - 25 million cattle, 100 million sheep and just over 20 million people.

F While there is no argument that dingoes will prey on sheep if given the chance, they don’t hunt cattle once the calves are much past two or three weeks old, according to McKechnie. And a study in Queensland suggests that dingoes don’t even prey heavily on the newborn calves unless their staple prey disappears due to deteriorating conditions like drought.

This study, co-authored by Lee Alien of the Robert Wicks Research Centre in Queensland, suggests that the aggressive baiting programs used against dingoes may actually be counter-productive for graziers. When dingoes are removed from an area by baiting m the area is recolonized by younger, more solitary dingoes. These animals aren’t capable of going after the large prey like kangaroos, so they turn to calves. In their study, some of the highest rates of calf predation occurred in areas that had been baited.

G Mark Clifford, general manager of a firm that manages over 200,000 head of cattle, is not convinced by Allen’s assertion. Clifford says, ‘It’s obvious if we drop or loosen control on dingoes, we are going to lose more calves.’ He doesn’t believe that dingoes will go after kangaroos when calves are around. Nor is he persuaded of dingoes’ supposed ecological benefits, saying he is not convinced that they manage to catch cats that often, believing they are more likely to catch small native animals instead.

H McKechnie agrees that dingoes kill the wallabies (small native animals) that compete with his cattle for food, but points out that in parts of Westers Australia, there are no fixes, and not very many cats. He doesn’t see how relaxing controls on dingoes in his area will improve the ecological balance.

Johnson sees a need for a change in philosophy on the part of graziers. ‘There might be a number of different ways of thinking through dingo management in cattle country,’ he says. ‘At the moment, though, that hasn’t got through to graziers. There’s still just on prescription, and that is to bait as widely as possible.’$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('85ea1411-2901-5f96-b540-aa58ca2ae496', 'cd93ac07-eb5f-505b-8624-bafebea64869', 1, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 1

Questions 1-7
Questions 1-7
Reading Passage has eight sections, A-H.
Which sections contains the following information?
Write the correct letter, A-H, in boxes 1-7 on your answer sheet.
NB
You may use any letter more than once.
1
a description of a barrier designed to stop dingoes, which also divides two kinds of non-natives animals
2
how dingoes ensure that rival species do not dominate
3
a reference to a widespread non-native species that other animals feed on
4
a
mention of the dingo’s arrival in Australia
5
research which has proved
that
dingoes
have
resorted to eating young
livestock
6
a
description of a method used to kill dingoes
7
the
way that the structure of dingo groups affects how quickly their
numbers grow

1 ____ a description of a barrier designed to stop dingoes, which also divides two kinds of non-natives animals$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a4f96b07-df7a-5120-96e3-7a0e47dbcb24', '85ea1411-2901-5f96-b540-aa58ca2ae496', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('89d69ea1-5f45-5396-aaf6-8e76a23df492', '85ea1411-2901-5f96-b540-aa58ca2ae496', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c4464e9c-f05d-5b14-b47d-9556afeaa019', '85ea1411-2901-5f96-b540-aa58ca2ae496', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ddda88c9-52e4-5598-9b52-c98f46e98c80', '85ea1411-2901-5f96-b540-aa58ca2ae496', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('70531596-7847-5d58-8a12-de7888070dae', '85ea1411-2901-5f96-b540-aa58ca2ae496', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a3ef9068-09b2-5818-85b6-6b949e5caa79', '85ea1411-2901-5f96-b540-aa58ca2ae496', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('dfe1d9a1-255c-58e5-b3ef-c95febd5a348', '85ea1411-2901-5f96-b540-aa58ca2ae496', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f6cd2b9c-94a1-5708-bd98-136d8e21cb34', '85ea1411-2901-5f96-b540-aa58ca2ae496', 8, $md$H$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('98402a05-c8f7-5ebf-8e95-f9f87f8177b9', 'cd93ac07-eb5f-505b-8624-bafebea64869', 2, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 2

Questions 1-7
Questions 1-7
Reading Passage has eight sections, A-H.
Which sections contains the following information?
Write the correct letter, A-H, in boxes 1-7 on your answer sheet.
NB
You may use any letter more than once.
1
a description of a barrier designed to stop dingoes, which also divides two kinds of non-natives animals
2
how dingoes ensure that rival species do not dominate
3
a reference to a widespread non-native species that other animals feed on
4
a
mention of the dingo’s arrival in Australia
5
research which has proved
that
dingoes
have
resorted to eating young
livestock
6
a
description of a method used to kill dingoes
7
the
way that the structure of dingo groups affects how quickly their
numbers grow

2 ____ how dingoes ensure that rival species do not dominate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('01493ed2-3df7-5e01-86c9-45aef8c39266', '98402a05-c8f7-5ebf-8e95-f9f87f8177b9', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('dca31b9e-9a18-52de-81ad-3ce2773b13b9', '98402a05-c8f7-5ebf-8e95-f9f87f8177b9', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0afdd81f-159e-54df-a256-58907f8214d9', '98402a05-c8f7-5ebf-8e95-f9f87f8177b9', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8316680c-302c-5205-86a6-0af893bd1331', '98402a05-c8f7-5ebf-8e95-f9f87f8177b9', 4, $md$D$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d22aa627-6db1-5fa1-9c28-ddb693615c63', '98402a05-c8f7-5ebf-8e95-f9f87f8177b9', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('709f1bfa-31fe-5605-863a-7894d4c0199e', '98402a05-c8f7-5ebf-8e95-f9f87f8177b9', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a35630f1-c603-5fc9-90dd-0751d8644ea5', '98402a05-c8f7-5ebf-8e95-f9f87f8177b9', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a45bf94f-f913-5d93-b4d8-12d7ebec137e', '98402a05-c8f7-5ebf-8e95-f9f87f8177b9', 8, $md$H$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('e451b35c-c40d-584a-87ad-7563e057cfca', 'cd93ac07-eb5f-505b-8624-bafebea64869', 3, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 3

Questions 1-7
Questions 1-7
Reading Passage has eight sections, A-H.
Which sections contains the following information?
Write the correct letter, A-H, in boxes 1-7 on your answer sheet.
NB
You may use any letter more than once.
1
a description of a barrier designed to stop dingoes, which also divides two kinds of non-natives animals
2
how dingoes ensure that rival species do not dominate
3
a reference to a widespread non-native species that other animals feed on
4
a
mention of the dingo’s arrival in Australia
5
research which has proved
that
dingoes
have
resorted to eating young
livestock
6
a
description of a method used to kill dingoes
7
the
way that the structure of dingo groups affects how quickly their
numbers grow

3 ____ a reference to a widespread non-native species that other animals feed on$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c39d2306-5b6c-5ab2-acbe-2418ee6f0290', 'e451b35c-c40d-584a-87ad-7563e057cfca', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1d9bec9f-d506-532f-a2a9-71a34a23e986', 'e451b35c-c40d-584a-87ad-7563e057cfca', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2c667efa-daf6-5ce9-9981-aec2fd249ebf', 'e451b35c-c40d-584a-87ad-7563e057cfca', 3, $md$C$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bf58cfc5-fd6f-511b-8e27-6a0538601a39', 'e451b35c-c40d-584a-87ad-7563e057cfca', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('67a5e025-b483-5680-9349-f393c523ae7a', 'e451b35c-c40d-584a-87ad-7563e057cfca', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('132f415e-2e7c-5c58-ae6d-f6ac3e53f28f', 'e451b35c-c40d-584a-87ad-7563e057cfca', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('10d4ee61-a6fa-5745-8a6f-54dff341797e', 'e451b35c-c40d-584a-87ad-7563e057cfca', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7797edc4-4d2e-5a14-9988-23bdef15ec49', 'e451b35c-c40d-584a-87ad-7563e057cfca', 8, $md$H$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('56162fdd-5f07-5f4b-849a-3ce23510c5db', 'cd93ac07-eb5f-505b-8624-bafebea64869', 4, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 4

Questions 1-7
Questions 1-7
Reading Passage has eight sections, A-H.
Which sections contains the following information?
Write the correct letter, A-H, in boxes 1-7 on your answer sheet.
NB
You may use any letter more than once.
1
a description of a barrier designed to stop dingoes, which also divides two kinds of non-natives animals
2
how dingoes ensure that rival species do not dominate
3
a reference to a widespread non-native species that other animals feed on
4
a
mention of the dingo’s arrival in Australia
5
research which has proved
that
dingoes
have
resorted to eating young
livestock
6
a
description of a method used to kill dingoes
7
the
way that the structure of dingo groups affects how quickly their
numbers grow

4 ____ a mention of the dingo’s arrival in Australia$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8d6ff4ad-e614-5951-9e6d-511845a95622', '56162fdd-5f07-5f4b-849a-3ce23510c5db', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fef29978-a509-52b9-91f0-f71f7f00bc84', '56162fdd-5f07-5f4b-849a-3ce23510c5db', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('62d233f7-f768-58dd-9175-cd0981a9264f', '56162fdd-5f07-5f4b-849a-3ce23510c5db', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('94dafe2e-b930-531f-a4e7-f9247f91431f', '56162fdd-5f07-5f4b-849a-3ce23510c5db', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('43c357cf-05d0-5f0d-be73-8afb97fa09fb', '56162fdd-5f07-5f4b-849a-3ce23510c5db', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c19e89c8-d833-514a-bdc0-1666ed49a476', '56162fdd-5f07-5f4b-849a-3ce23510c5db', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('182ca65c-e132-5822-ad86-1ac7737c1901', '56162fdd-5f07-5f4b-849a-3ce23510c5db', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ec81cc77-f2b8-5970-ac78-3a529cad296e', '56162fdd-5f07-5f4b-849a-3ce23510c5db', 8, $md$H$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('abf26514-c3ce-57e2-b2c1-c1d3220188b9', 'cd93ac07-eb5f-505b-8624-bafebea64869', 5, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 5

Questions 1-7
Questions 1-7
Reading Passage has eight sections, A-H.
Which sections contains the following information?
Write the correct letter, A-H, in boxes 1-7 on your answer sheet.
NB
You may use any letter more than once.
1
a description of a barrier designed to stop dingoes, which also divides two kinds of non-natives animals
2
how dingoes ensure that rival species do not dominate
3
a reference to a widespread non-native species that other animals feed on
4
a
mention of the dingo’s arrival in Australia
5
research which has proved
that
dingoes
have
resorted to eating young
livestock
6
a
description of a method used to kill dingoes
7
the
way that the structure of dingo groups affects how quickly their
numbers grow

5 ____ research which has proved that dingoes have resorted to eating young livestock$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2f150fd7-639b-5c2d-91c4-eedf27fcef2c', 'abf26514-c3ce-57e2-b2c1-c1d3220188b9', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('33e6a6aa-dad8-5b1d-b470-c80ef3746254', 'abf26514-c3ce-57e2-b2c1-c1d3220188b9', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9e49e943-5c46-5387-bf17-0b323ca829d9', 'abf26514-c3ce-57e2-b2c1-c1d3220188b9', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a70e0d7d-8093-559b-b554-2086c304fed5', 'abf26514-c3ce-57e2-b2c1-c1d3220188b9', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b55ac763-cd2b-563f-81e0-3d65aa735e71', 'abf26514-c3ce-57e2-b2c1-c1d3220188b9', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('31365849-7595-5afe-b98e-9be667a1fd2e', 'abf26514-c3ce-57e2-b2c1-c1d3220188b9', 6, $md$F$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('daf11926-cd97-57a7-bd5c-5e2cd0828282', 'abf26514-c3ce-57e2-b2c1-c1d3220188b9', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0a70a6f7-c6aa-5c61-a5f7-fc378fd4c8a9', 'abf26514-c3ce-57e2-b2c1-c1d3220188b9', 8, $md$H$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('afd49450-7854-5d1f-aa9d-178014a9e877', 'cd93ac07-eb5f-505b-8624-bafebea64869', 6, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 6

Questions 1-7
Questions 1-7
Reading Passage has eight sections, A-H.
Which sections contains the following information?
Write the correct letter, A-H, in boxes 1-7 on your answer sheet.
NB
You may use any letter more than once.
1
a description of a barrier designed to stop dingoes, which also divides two kinds of non-natives animals
2
how dingoes ensure that rival species do not dominate
3
a reference to a widespread non-native species that other animals feed on
4
a
mention of the dingo’s arrival in Australia
5
research which has proved
that
dingoes
have
resorted to eating young
livestock
6
a
description of a method used to kill dingoes
7
the
way that the structure of dingo groups affects how quickly their
numbers grow

6 ____ a description of a method used to kill dingoes$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0472dd91-00e4-5f44-87e7-a92992935c89', 'afd49450-7854-5d1f-aa9d-178014a9e877', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4fc97065-0d83-5a7a-95e1-53c99d5bd857', 'afd49450-7854-5d1f-aa9d-178014a9e877', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1cd9a05a-c0c4-5108-935a-66ecfc4a8666', 'afd49450-7854-5d1f-aa9d-178014a9e877', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9dd50c96-62e4-5e78-922e-8c7ff4d2bf61', 'afd49450-7854-5d1f-aa9d-178014a9e877', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('81970d7e-98ff-5827-b833-ef3b7dfa1f0e', 'afd49450-7854-5d1f-aa9d-178014a9e877', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e6e9d2b3-7ca3-5e82-9d79-905841845fea', 'afd49450-7854-5d1f-aa9d-178014a9e877', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3e543192-39d6-5b8d-a0d5-c9e5825fdd7e', 'afd49450-7854-5d1f-aa9d-178014a9e877', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fc537663-f6f6-5c32-aa0a-8cbfadb78f6f', 'afd49450-7854-5d1f-aa9d-178014a9e877', 8, $md$H$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('99d76a80-21ec-5187-8aeb-d0bc2e88a8ba', 'cd93ac07-eb5f-505b-8624-bafebea64869', 7, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 7

Questions 1-7
Questions 1-7
Reading Passage has eight sections, A-H.
Which sections contains the following information?
Write the correct letter, A-H, in boxes 1-7 on your answer sheet.
NB
You may use any letter more than once.
1
a description of a barrier designed to stop dingoes, which also divides two kinds of non-natives animals
2
how dingoes ensure that rival species do not dominate
3
a reference to a widespread non-native species that other animals feed on
4
a
mention of the dingo’s arrival in Australia
5
research which has proved
that
dingoes
have
resorted to eating young
livestock
6
a
description of a method used to kill dingoes
7
the
way that the structure of dingo groups affects how quickly their
numbers grow

7 ____ the way that the structure of dingo groups affects how quickly their numbers grow$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('73a935c3-eca5-5bb8-985f-6075d8c5ef71', '99d76a80-21ec-5187-8aeb-d0bc2e88a8ba', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b4676597-b95d-515d-9c7c-462bf6afa286', '99d76a80-21ec-5187-8aeb-d0bc2e88a8ba', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ea7d5423-4dca-56e0-a5b3-54b46cae12fc', '99d76a80-21ec-5187-8aeb-d0bc2e88a8ba', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('beb35bfe-995d-5637-b57d-71ede8ea537b', '99d76a80-21ec-5187-8aeb-d0bc2e88a8ba', 4, $md$D$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('600b86fd-cd3c-54fe-9fd6-181f0bc1a2d6', '99d76a80-21ec-5187-8aeb-d0bc2e88a8ba', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bbc81ea4-628a-541d-9798-ad06d5126a5a', '99d76a80-21ec-5187-8aeb-d0bc2e88a8ba', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4d7c1a35-752d-536e-8c14-c714de399d5b', '99d76a80-21ec-5187-8aeb-d0bc2e88a8ba', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('feb894b9-43db-5acc-94d7-2d5666397d41', '99d76a80-21ec-5187-8aeb-d0bc2e88a8ba', 8, $md$H$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('8a33035c-0185-5668-8cba-899e339f65e5', 'cd93ac07-eb5f-505b-8624-bafebea64869', 8, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 8

Questions 8-10
Questions 8-10
Look
at the following statements (Questions 8-10) and the list of people
below.
Match
each statement with the correct person, A, B, c or D.
Write
the correct letter,
A, B, C
or
D,
in boxes 8-10 on your answer sheet.
8
Dingoes tend to hunt native animals rather than hunting other non-native
predators.
9
The presence of dingoes puts the income of some people
at
risk.
10
Dingoes have had little impact on the dying out of animal species in
Australia.
List of People
A Stuart McKechnie
B Chris Johnson
C Lee Allen
D Mark Clifford

8 ____ Dingoes tend to hunt native animals rather than hunting other non-native predators.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6e899389-4dc4-5167-9740-92baa0d4ed10', '8a33035c-0185-5668-8cba-899e339f65e5', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('21d0332d-0ef7-533f-8874-5fb4b2f9f872', '8a33035c-0185-5668-8cba-899e339f65e5', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f14f9050-d3e7-51aa-9db0-e2762f4f0e47', '8a33035c-0185-5668-8cba-899e339f65e5', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('30d11bfc-cee9-5d73-a673-86199c2a6d09', '8a33035c-0185-5668-8cba-899e339f65e5', 4, $md$D$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('80e88b25-bfc2-588d-9419-f7160498dfed', 'cd93ac07-eb5f-505b-8624-bafebea64869', 9, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 9

Questions 8-10
Questions 8-10
Look
at the following statements (Questions 8-10) and the list of people
below.
Match
each statement with the correct person, A, B, c or D.
Write
the correct letter,
A, B, C
or
D,
in boxes 8-10 on your answer sheet.
8
Dingoes tend to hunt native animals rather than hunting other non-native
predators.
9
The presence of dingoes puts the income of some people
at
risk.
10
Dingoes have had little impact on the dying out of animal species in
Australia.
List of People
A Stuart McKechnie
B Chris Johnson
C Lee Allen
D Mark Clifford

9 ____ The presence of dingoes puts the income of some people at risk.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('16c21d55-fead-5473-a8e5-e72bd46bdedc', '80e88b25-bfc2-588d-9419-f7160498dfed', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e1240480-cf99-516e-b239-69886c6728d9', '80e88b25-bfc2-588d-9419-f7160498dfed', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('14837756-28a0-55fd-b6a5-04fe10f1dbc5', '80e88b25-bfc2-588d-9419-f7160498dfed', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5a57da90-d0bc-54ad-8975-dfb8eff6a44f', '80e88b25-bfc2-588d-9419-f7160498dfed', 4, $md$D$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('b59be70e-7bd6-5575-b591-390ed8bd4442', 'cd93ac07-eb5f-505b-8624-bafebea64869', 10, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 10

Questions 8-10
Questions 8-10
Look
at the following statements (Questions 8-10) and the list of people
below.
Match
each statement with the correct person, A, B, c or D.
Write
the correct letter,
A, B, C
or
D,
in boxes 8-10 on your answer sheet.
8
Dingoes tend to hunt native animals rather than hunting other non-native
predators.
9
The presence of dingoes puts the income of some people
at
risk.
10
Dingoes have had little impact on the dying out of animal species in
Australia.
List of People
A Stuart McKechnie
B Chris Johnson
C Lee Allen
D Mark Clifford

10 ____ Dingoes have had little impact on the dying out of animal species in Australia.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('62f25f10-0b36-57bd-af13-abf10521a34b', 'b59be70e-7bd6-5575-b591-390ed8bd4442', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6a75ca1f-3b5e-54f2-8d5f-bfeee50854d8', 'b59be70e-7bd6-5575-b591-390ed8bd4442', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('149f7a28-564e-55ae-8e43-e9b35c15c502', 'b59be70e-7bd6-5575-b591-390ed8bd4442', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('696a9d66-8263-52a5-a3b7-bf1544d9a83d', 'b59be70e-7bd6-5575-b591-390ed8bd4442', 4, $md$D$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('c2316f3e-ff63-57f8-b427-c2349c7ce139', 'cd93ac07-eb5f-505b-8624-bafebea64869', 11, 'SENTENCE_COMPLETION', 'READING', 4, $md$### Question 11

Questions 11-13
Questions 11-13
Complete the sentences below.
Choose
NO MORE THAN TWO WORDS
from the passage for each answer.
Write your answers in boxes 11-13 on your answer sheet.
11. The dingo replaced the
11
as the main predatory animal in Australia.
12. Foxes and cats are more likely to hunt native animals when there are fewer
12
13. Australian animals reproduce at a slow rate as a natural way of avoiding
13

11. The dingo replaced the 11 ____ as the main predatory animal in Australia.$md$, NULL, ARRAY['.*tasmanian.*tiger.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('9d48fff8-e059-570d-8c49-127b6e0865c2', 'cd93ac07-eb5f-505b-8624-bafebea64869', 12, 'SENTENCE_COMPLETION', 'READING', 4, $md$### Question 12

Questions 11-13
Questions 11-13
Complete the sentences below.
Choose
NO MORE THAN TWO WORDS
from the passage for each answer.
Write your answers in boxes 11-13 on your answer sheet.
11. The dingo replaced the
11
as the main predatory animal in Australia.
12. Foxes and cats are more likely to hunt native animals when there are fewer
12
13. Australian animals reproduce at a slow rate as a natural way of avoiding
13

12. Foxes and cats are more likely to hunt native animals when there are fewer 12 ____$md$, NULL, ARRAY['.*rabbits.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('9bb08983-a4af-5f33-808a-c3220c89b5b5', 'cd93ac07-eb5f-505b-8624-bafebea64869', 13, 'SENTENCE_COMPLETION', 'READING', 4, $md$### Question 13

Questions 11-13
Questions 11-13
Complete the sentences below.
Choose
NO MORE THAN TWO WORDS
from the passage for each answer.
Write your answers in boxes 11-13 on your answer sheet.
11. The dingo replaced the
11
as the main predatory animal in Australia.
12. Foxes and cats are more likely to hunt native animals when there are fewer
12
13. Australian animals reproduce at a slow rate as a natural way of avoiding
13

13. Australian animals reproduce at a slow rate as a natural way of avoiding 13 ____$md$, NULL, ARRAY['.*overpopulation.*']);

COMMIT;
