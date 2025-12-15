BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-koalas--1257'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-koalas--1257';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-koalas--1257';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-koalas--1257';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('51af86e3-182b-5e06-bfff-39d8fcd8da64', 'ielts-reading-koalas--1257', $t$Koalas$t$, $md$## Koalas

Nguồn:
- Test: https://mini-ielts.com/1257/reading/koalas-
- Solution: https://mini-ielts.com/1257/view-solution/reading/koalas-$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('cd6d1b21-373c-50ee-b3af-3a63878f592e', '51af86e3-182b-5e06-bfff-39d8fcd8da64', 1, $t$Reading — Koalas$t$, $md$Read the passage and answer questions **1–13**.

### Passage: Koalas

A . Koalas are just too nice for their own good. And except for the occasional baby taken by birds of prey, koalas have no natural enemies. In an ideal world, the life of an arboreal couch potato would be perfectly safe and acceptable.

B . Just two hundred years ago, koalas flourished across Australia. Now they seem to be in decline, but exact numbers are not available as the species would not seem to be ‘under threat’. Their problem, however, has been man, more specifically, the white man. Koala and aborigine had co-existed peacefully for centuries.

C . Today koalas are found only in scattered pockets of southeast Australia, where they seem to be at risk on several fronts. The koala’s only food source, the eucalyptus tree has declined. In the past 200 years, a third of Australia’s eucalyptus forests have disappeared. Koalas have been killed by parasites, chlamydia epidemics and a tumour-causing retro-virus. And every year 11000 are killed by cars, ironically most of them in wildlife sanctuaries, and thousands are killed by poachers. Some are also taken illegally as pets. The animals usually soon die, but they are easily replaced.

D . Bush fires pose another threat. The horrific ones that raged in New South Wales recently killed between 100 and 1000 koalas. Many that were taken into sanctuaries and shelters were found to have burnt their paws on the glowing embers. But zoologists say that the species should recover. The koalas will be aided by the eucalyptus, which grows quickly and is already burgeoning forth after the fires. So the main problem to their survival is their slow reproductive rate – they produce only one baby a year over a reproductive lifespan of about nine years.

E . The latest problem for the species is perhaps more insidious. With plush, grey fur, dark amber eyes and button nose, koalas are cuddliness incarnate. Australian zoos and wildlife parks have taken advantage of their uncomplaining attitudes, and charge visitors to be photographed hugging the furry bundles. But people may not realise how cruel this is, but because of the koala’s delicate disposition, constant handling can push an already precariously balanced physiology over the edge.

F . Koalas only eat the foliage of certain species of eucalyptus trees, between 600 and 1250 grams a day. The tough leaves are packed with cellulose, tannins, aromatic oils and precursors of toxic cyanides. To handle this cocktail, koalas have a specialised digestive system. Cellulose- digesting bacteria in the break down fibre, while a specially adapted gut and liver process the toxins. To digest their food properly, koalas must sit still for 21 hours every day.

G . Koalas are the epitome of innocence and inoffensiveness. Although they are capable of ripping open a man’s arm with their needle-sharp claws, or giving a nasty nip, they simply wouldn’t. If you upset a koala, it may blink or swallow, or hiccup. But attack? No way! Koalas are just not aggressive. They use their claws to grip the hard smooth bark of eucalyptus trees.

H . They are also very sensitive, and the slightest upset can prevent them from breeding, cause them to go off their food, and succumb to gut infections. Koalas are stoic creatures and put on a brave face until they are at death’s door. One day they may appear healthy, the next they could be dead. Captive koalas have to be weighed daily to check that they are feeding properly. A sudden loss of weight is usually the only warning keepers have that their charge is ill. Only two keepers plus a vet were allowed to handle London Zoo’s koalas, as these creatures are only comfortable with people they know. A request for the koala to be taken to meet the Queen was refused because of the distress this would have caused the marsupial. Sadly, London’s Zoo no longer has a koala. Two years ago the female koala died of a cancer caused by a retrovirus. When they come into heat, female koalas become more active, and start losing weight, but after about sixteen days, heat ends and the weight piles back on. London’s koala did not. Surgery revealed hundreds of pea-sized tumours.

Almost every zoo in Australia has koalas – the marsupial has become the Animal Ambassador of the nation, but nowhere outside Australia would handling by the public be allowed. Koala cuddling screams in the face of every rule of good care. First, some zoos allow koalas to be passed from stranger to stranger, many children who love to squeeze. Secondly, most people have no idea of how to handle the animals; they like to cling on to their handler, all in their own good time and use his or her arm as a tree. For such reasons, the Association of Fauna and Marine parks, an Australian conservation society is campaigning to ban koala cuddling. Policy on koala handling is determined by state government authorities. “And the largest of the numbers in the Australian Nature Conservation Agency, with the aim of instituting national guidelines. Following a wave of publicity, some zoos and wildlife parks have stopped turning their koalas into photo.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('f70e46b8-07ac-5213-9d98-3b174f40b2b5', 'cd6d1b21-373c-50ee-b3af-3a63878f592e', 1, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 1

Questions 1-5
Questions 1-5
Choose the correct letter, A, B, C or D.
Write the correct letter in boxes 1-5 on your answer sheet.
1. The main reason why koala declined is that they are killed EXCEPT FOR
A
by poachers
B
by diseases they got
C
giving too many birth yet survived little!
D
accidents on the road
2. What can help koalas folly digest their food?
A
toxic substance in the leaves
B
organs that dissolve the fibres
C
remaining inactive for a period to digest
D
eating eucalyptus trees
3. What would koalas do when facing the dangerous situation?
A
show signs of being offended
B
counter attack furiously
C
use sharp claws to rip the man
D
use claws to grip the bark of trees.
4. In what ways Australian zoos exploit koalas?
A
encourage people to breed koalas as pets
B
allow tourists to hug the koalas
C
put them on the trees as a symbol
D
establish a koala campaign
5. What would the government do to protect koalas from being endangered?
A
introduce koala protection guidelines
B
close some of the zoos
C
encourage people to resist visiting the zoos
D
persuade the public to learn more knowledge

Choose the correct letter, A, B, C or D. Write the correct letter in boxes 1-5 on your answer sheet. 1. The main reason why koala declined is that they are killed EXCEPT FOR$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('6e54b7e1-a670-58f5-9cd6-61c5ad445e84', 'cd6d1b21-373c-50ee-b3af-3a63878f592e', 2, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 2

Questions 1-5
Questions 1-5
Choose the correct letter, A, B, C or D.
Write the correct letter in boxes 1-5 on your answer sheet.
1. The main reason why koala declined is that they are killed EXCEPT FOR
A
by poachers
B
by diseases they got
C
giving too many birth yet survived little!
D
accidents on the road
2. What can help koalas folly digest their food?
A
toxic substance in the leaves
B
organs that dissolve the fibres
C
remaining inactive for a period to digest
D
eating eucalyptus trees
3. What would koalas do when facing the dangerous situation?
A
show signs of being offended
B
counter attack furiously
C
use sharp claws to rip the man
D
use claws to grip the bark of trees.
4. In what ways Australian zoos exploit koalas?
A
encourage people to breed koalas as pets
B
allow tourists to hug the koalas
C
put them on the trees as a symbol
D
establish a koala campaign
5. What would the government do to protect koalas from being endangered?
A
introduce koala protection guidelines
B
close some of the zoos
C
encourage people to resist visiting the zoos
D
persuade the public to learn more knowledge

Choose the correct letter, A, B, C or D. Write the correct letter in boxes 1-5 on your answer sheet. 1. The main reason why koala declined is that they are killed EXCEPT FOR$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('7469d53f-95cc-5666-8f66-f1bfc9e8dd0a', 'cd6d1b21-373c-50ee-b3af-3a63878f592e', 3, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 3

Questions 1-5
Questions 1-5
Choose the correct letter, A, B, C or D.
Write the correct letter in boxes 1-5 on your answer sheet.
1. The main reason why koala declined is that they are killed EXCEPT FOR
A
by poachers
B
by diseases they got
C
giving too many birth yet survived little!
D
accidents on the road
2. What can help koalas folly digest their food?
A
toxic substance in the leaves
B
organs that dissolve the fibres
C
remaining inactive for a period to digest
D
eating eucalyptus trees
3. What would koalas do when facing the dangerous situation?
A
show signs of being offended
B
counter attack furiously
C
use sharp claws to rip the man
D
use claws to grip the bark of trees.
4. In what ways Australian zoos exploit koalas?
A
encourage people to breed koalas as pets
B
allow tourists to hug the koalas
C
put them on the trees as a symbol
D
establish a koala campaign
5. What would the government do to protect koalas from being endangered?
A
introduce koala protection guidelines
B
close some of the zoos
C
encourage people to resist visiting the zoos
D
persuade the public to learn more knowledge

Choose the correct letter, A, B, C or D. Write the correct letter in boxes 1-5 on your answer sheet. 1. The main reason why koala declined is that they are killed EXCEPT FOR$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('fc7ab3af-0831-5a28-899b-5368da64d440', 'cd6d1b21-373c-50ee-b3af-3a63878f592e', 4, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 4

Questions 1-5
Questions 1-5
Choose the correct letter, A, B, C or D.
Write the correct letter in boxes 1-5 on your answer sheet.
1. The main reason why koala declined is that they are killed EXCEPT FOR
A
by poachers
B
by diseases they got
C
giving too many birth yet survived little!
D
accidents on the road
2. What can help koalas folly digest their food?
A
toxic substance in the leaves
B
organs that dissolve the fibres
C
remaining inactive for a period to digest
D
eating eucalyptus trees
3. What would koalas do when facing the dangerous situation?
A
show signs of being offended
B
counter attack furiously
C
use sharp claws to rip the man
D
use claws to grip the bark of trees.
4. In what ways Australian zoos exploit koalas?
A
encourage people to breed koalas as pets
B
allow tourists to hug the koalas
C
put them on the trees as a symbol
D
establish a koala campaign
5. What would the government do to protect koalas from being endangered?
A
introduce koala protection guidelines
B
close some of the zoos
C
encourage people to resist visiting the zoos
D
persuade the public to learn more knowledge

Choose the correct letter, A, B, C or D. Write the correct letter in boxes 1-5 on your answer sheet. 1. The main reason why koala declined is that they are killed EXCEPT FOR$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('c927b686-51e5-5204-8d4e-8fcdcb1cb4bd', 'cd6d1b21-373c-50ee-b3af-3a63878f592e', 5, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 5

Questions 1-5
Questions 1-5
Choose the correct letter, A, B, C or D.
Write the correct letter in boxes 1-5 on your answer sheet.
1. The main reason why koala declined is that they are killed EXCEPT FOR
A
by poachers
B
by diseases they got
C
giving too many birth yet survived little!
D
accidents on the road
2. What can help koalas folly digest their food?
A
toxic substance in the leaves
B
organs that dissolve the fibres
C
remaining inactive for a period to digest
D
eating eucalyptus trees
3. What would koalas do when facing the dangerous situation?
A
show signs of being offended
B
counter attack furiously
C
use sharp claws to rip the man
D
use claws to grip the bark of trees.
4. In what ways Australian zoos exploit koalas?
A
encourage people to breed koalas as pets
B
allow tourists to hug the koalas
C
put them on the trees as a symbol
D
establish a koala campaign
5. What would the government do to protect koalas from being endangered?
A
introduce koala protection guidelines
B
close some of the zoos
C
encourage people to resist visiting the zoos
D
persuade the public to learn more knowledge

Choose the correct letter, A, B, C or D. Write the correct letter in boxes 1-5 on your answer sheet. 1. The main reason why koala declined is that they are killed EXCEPT FOR$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('b923cbc9-e291-5f33-98dd-56380ad9a35a', 'cd6d1b21-373c-50ee-b3af-3a63878f592e', 6, 'YES_NO_NOT_GIVEN', 'READING', 3, $md$### Question 6

Questions 6-12
Questions 6-12
Do the following statements agree with the information given in
Reading Passage 1
In boxes
6-12
on your answer sheet, write
YES
if the statement agrees with the information
NO
if the statement contradicts the information
NOT GIVEN
if there is no information on this passage
6
New coming human settlers caused danger to koalas.
7
Koalas can still be seen in most of the places in Australia.
8
It takes decade for the eucalyptus trees to recover after the fire.
9
Koalas will fight each other when food becomes scarce.
10
It is not easy to notice that koalas are ill.
11
Koalas are easily infected with human contagious disease via cuddling
12
Koalas like to hold a person’s arm when they are embraced.

6 ____ New coming human settlers caused danger to koalas.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('990fdce7-74b8-5b81-931b-1f80f5744ff9', 'b923cbc9-e291-5f33-98dd-56380ad9a35a', 1, $md$YES$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f57f0573-a8d2-5dd9-aa3f-874784eaaa04', 'b923cbc9-e291-5f33-98dd-56380ad9a35a', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f5db08f9-a4de-5f0f-8583-2921ef4d369e', 'b923cbc9-e291-5f33-98dd-56380ad9a35a', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('920f8869-dfdc-570a-b4d7-3e21438e426d', 'cd6d1b21-373c-50ee-b3af-3a63878f592e', 7, 'YES_NO_NOT_GIVEN', 'READING', 3, $md$### Question 7

Questions 6-12
Questions 6-12
Do the following statements agree with the information given in
Reading Passage 1
In boxes
6-12
on your answer sheet, write
YES
if the statement agrees with the information
NO
if the statement contradicts the information
NOT GIVEN
if there is no information on this passage
6
New coming human settlers caused danger to koalas.
7
Koalas can still be seen in most of the places in Australia.
8
It takes decade for the eucalyptus trees to recover after the fire.
9
Koalas will fight each other when food becomes scarce.
10
It is not easy to notice that koalas are ill.
11
Koalas are easily infected with human contagious disease via cuddling
12
Koalas like to hold a person’s arm when they are embraced.

7 ____ Koalas can still be seen in most of the places in Australia.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e25b57f6-b983-5bcc-af3b-98836ade6518', '920f8869-dfdc-570a-b4d7-3e21438e426d', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('58392ca9-cd22-5a79-8043-01041cb17289', '920f8869-dfdc-570a-b4d7-3e21438e426d', 2, $md$NO$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b25777ea-ffb5-55b3-8759-2fd1662d5229', '920f8869-dfdc-570a-b4d7-3e21438e426d', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('c2a830eb-57a0-5708-8da5-3bee96c2b9ca', 'cd6d1b21-373c-50ee-b3af-3a63878f592e', 8, 'YES_NO_NOT_GIVEN', 'READING', 3, $md$### Question 8

Questions 6-12
Questions 6-12
Do the following statements agree with the information given in
Reading Passage 1
In boxes
6-12
on your answer sheet, write
YES
if the statement agrees with the information
NO
if the statement contradicts the information
NOT GIVEN
if there is no information on this passage
6
New coming human settlers caused danger to koalas.
7
Koalas can still be seen in most of the places in Australia.
8
It takes decade for the eucalyptus trees to recover after the fire.
9
Koalas will fight each other when food becomes scarce.
10
It is not easy to notice that koalas are ill.
11
Koalas are easily infected with human contagious disease via cuddling
12
Koalas like to hold a person’s arm when they are embraced.

8 ____ It takes decade for the eucalyptus trees to recover after the fire.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3e987d79-6ffb-5964-b061-9259756eb9d1', 'c2a830eb-57a0-5708-8da5-3bee96c2b9ca', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c9a45086-88af-5a58-a7f5-178569090426', 'c2a830eb-57a0-5708-8da5-3bee96c2b9ca', 2, $md$NO$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('45f09dd7-70da-5580-bb36-5e3ba5b8d3cb', 'c2a830eb-57a0-5708-8da5-3bee96c2b9ca', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('74da75c5-3d1a-5075-b1dc-67d96c4aa1f4', 'cd6d1b21-373c-50ee-b3af-3a63878f592e', 9, 'YES_NO_NOT_GIVEN', 'READING', 3, $md$### Question 9

Questions 6-12
Questions 6-12
Do the following statements agree with the information given in
Reading Passage 1
In boxes
6-12
on your answer sheet, write
YES
if the statement agrees with the information
NO
if the statement contradicts the information
NOT GIVEN
if there is no information on this passage
6
New coming human settlers caused danger to koalas.
7
Koalas can still be seen in most of the places in Australia.
8
It takes decade for the eucalyptus trees to recover after the fire.
9
Koalas will fight each other when food becomes scarce.
10
It is not easy to notice that koalas are ill.
11
Koalas are easily infected with human contagious disease via cuddling
12
Koalas like to hold a person’s arm when they are embraced.

9 ____ Koalas will fight each other when food becomes scarce.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0be8f4ec-057c-5ca2-bbc1-a68dc4d79c76', '74da75c5-3d1a-5075-b1dc-67d96c4aa1f4', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8946f2fe-c2f6-58ed-ba13-8cc18da8c50c', '74da75c5-3d1a-5075-b1dc-67d96c4aa1f4', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('700be77f-b351-511e-ba94-0ac49ba207d3', '74da75c5-3d1a-5075-b1dc-67d96c4aa1f4', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('c21715ba-3363-52ef-9a2c-808fbcdfa767', 'cd6d1b21-373c-50ee-b3af-3a63878f592e', 10, 'YES_NO_NOT_GIVEN', 'READING', 4, $md$### Question 10

Questions 6-12
Questions 6-12
Do the following statements agree with the information given in
Reading Passage 1
In boxes
6-12
on your answer sheet, write
YES
if the statement agrees with the information
NO
if the statement contradicts the information
NOT GIVEN
if there is no information on this passage
6
New coming human settlers caused danger to koalas.
7
Koalas can still be seen in most of the places in Australia.
8
It takes decade for the eucalyptus trees to recover after the fire.
9
Koalas will fight each other when food becomes scarce.
10
It is not easy to notice that koalas are ill.
11
Koalas are easily infected with human contagious disease via cuddling
12
Koalas like to hold a person’s arm when they are embraced.

10 ____ It is not easy to notice that koalas are ill.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0738f816-3365-510f-92e7-8206021cf97f', 'c21715ba-3363-52ef-9a2c-808fbcdfa767', 1, $md$YES$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8d1424cb-8ad7-5004-8267-a5242596034b', 'c21715ba-3363-52ef-9a2c-808fbcdfa767', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cd27e276-12f3-502d-af7e-6b423afc414d', 'c21715ba-3363-52ef-9a2c-808fbcdfa767', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('4d1cf403-6c25-57a6-bbe1-8c7b44766abc', 'cd6d1b21-373c-50ee-b3af-3a63878f592e', 11, 'YES_NO_NOT_GIVEN', 'READING', 4, $md$### Question 11

Questions 6-12
Questions 6-12
Do the following statements agree with the information given in
Reading Passage 1
In boxes
6-12
on your answer sheet, write
YES
if the statement agrees with the information
NO
if the statement contradicts the information
NOT GIVEN
if there is no information on this passage
6
New coming human settlers caused danger to koalas.
7
Koalas can still be seen in most of the places in Australia.
8
It takes decade for the eucalyptus trees to recover after the fire.
9
Koalas will fight each other when food becomes scarce.
10
It is not easy to notice that koalas are ill.
11
Koalas are easily infected with human contagious disease via cuddling
12
Koalas like to hold a person’s arm when they are embraced.

11 ____ Koalas are easily infected with human contagious disease via cuddling$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7a69d284-6cdc-58a2-a35f-0aa2123de83b', '4d1cf403-6c25-57a6-bbe1-8c7b44766abc', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e3f73941-9e9a-5b26-ae3b-727c1a3d3121', '4d1cf403-6c25-57a6-bbe1-8c7b44766abc', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5de4ff0e-714c-5450-a574-35cd0bd62087', '4d1cf403-6c25-57a6-bbe1-8c7b44766abc', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('1d65a8d4-edc8-547f-87ff-f1a283198390', 'cd6d1b21-373c-50ee-b3af-3a63878f592e', 12, 'YES_NO_NOT_GIVEN', 'READING', 4, $md$### Question 12

Questions 6-12
Questions 6-12
Do the following statements agree with the information given in
Reading Passage 1
In boxes
6-12
on your answer sheet, write
YES
if the statement agrees with the information
NO
if the statement contradicts the information
NOT GIVEN
if there is no information on this passage
6
New coming human settlers caused danger to koalas.
7
Koalas can still be seen in most of the places in Australia.
8
It takes decade for the eucalyptus trees to recover after the fire.
9
Koalas will fight each other when food becomes scarce.
10
It is not easy to notice that koalas are ill.
11
Koalas are easily infected with human contagious disease via cuddling
12
Koalas like to hold a person’s arm when they are embraced.

12 ____ Koalas like to hold a person’s arm when they are embraced.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1bb81a8e-20ea-553e-bdaf-ae91613bdcf5', '1d65a8d4-edc8-547f-87ff-f1a283198390', 1, $md$YES$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d7508c8c-2ac0-5774-a755-b1c7ebfbfdd4', '1d65a8d4-edc8-547f-87ff-f1a283198390', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('57c216e0-e3c3-5a4b-9059-6f8b88fe0432', '1d65a8d4-edc8-547f-87ff-f1a283198390', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('eb74a908-8945-5c67-9efe-01d0a9c2bdd2', 'cd6d1b21-373c-50ee-b3af-3a63878f592e', 13, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 13

Questions 13
Questions 13
Choose the correct letter,
A, B, C or D.
Write the correct letter in boxes
13
on your answer sheet.
From your opinion this article written by
A
a journalist who write for magazine
B
a zoo keeper in London Zoo.
C
a tourist who traveling back from Australia
D
a government official who studies koalas to establish a law

Choose the correct letter, A, B, C or D. Write the correct letter in boxes 13 on your answer sheet. From your opinion this article written by$md$, NULL);

COMMIT;
