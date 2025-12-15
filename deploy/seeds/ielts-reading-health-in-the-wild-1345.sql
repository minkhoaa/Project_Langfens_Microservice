BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-health-in-the-wild-1345'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-health-in-the-wild-1345';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-health-in-the-wild-1345';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-health-in-the-wild-1345';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('d2fd8515-0ff5-5ba8-856e-4255ffe3a0a9', 'ielts-reading-health-in-the-wild-1345', $t$Health in the Wild$t$, $md$## Health in the Wild

Nguồn:
- Test: https://mini-ielts.com/1345/reading/health-in-the-wild
- Solution: https://mini-ielts.com/1345/view-solution/reading/health-in-the-wild$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('871b986d-3e02-517f-915a-011b0a03df99', 'd2fd8515-0ff5-5ba8-856e-4255ffe3a0a9', 1, $t$Reading — Health in the Wild$t$, $md$Read the passage and answer questions **1–13**.

### Passage: Health in the Wild

A

For the past decade Dr Engel, a lecturer in environmental sciences at Britain’s Open University, has been collating examples of self-medicating behaviour in wild animals. She recently published a book on the subject. In a talk at the Edinburgh Science Festival earlier this month, she explained that the idea that animals can treat themselves has been regarded with some scepticism by her colleagues in the past. But a growing number of animal behaviourists now think that wild animals can and do deal with their own medical needs.

B

One example of self-medication was discovered in 1987. Michael Huffman and Mohamedi Seifu, working in the Mahale Mountains National Park in Tanzania, noticed that local chimpanzees suffering from intestinal worms would dose themselves with the pith of a plant called Veronia. This plant produces poisonous chemicals called terpenes. Its pith contains a strong enough concentration to kill gut parasites, but not so strong as to kill chimps (nor people, for that matter; locals use the pith for the same purpose). Given that the plant is known locally as “goat-killer”, however, it seems that not all animals are as smart as chimps and humans. Some consume it indiscriminately and succumb.

C

Since the Veronia-eating chimps were discovered, more evidence has emerged suggesting that animals often eat things for medical rather than nutritional reasons. Many species, for example, consume dirt a behaviour known as geophagy. Historically, the preferred explanation was that soil supplies minerals such as salt. But geophagy occurs in areas where the earth is not a useful source of minerals, and also in places where minerals can be more easily obtained from certain plants that are known to be rich in them. Clearly, the animals must be getting something else out of eating earth.

D

The current belief is that soil—and particularly the clay in it—helps to detoxify the defensive poisons that some plants produce in an attempt to prevent themselves from being eaten. Evidence for the detoxifying nature of clay came in 1999, from an experiment carried out on macaws by James Gilardi and his colleagues at the University of California, Davis. Macaws eat seeds containing alkaloids, a group of chemicals that has some notoriously toxic members, such as strychnine. In the wild, the birds are frequently seen perched on eroding riverbanks eating clay. Dr Gilardi fed one group of macaws a mixture of harmless alkaloid and clay, and a second group just the alkaloid. Several hours later, the macaws that had eaten the clay had 60% less alkaloid in their bloodstreams than those that had not, suggesting that the hypothesis is correct.

E

Other observations also support the idea that clay is detoxifying. Towards the tropics, the amount of toxic compounds in plants increases-and so does the amount of earth eaten by herbivores. Elephants lick clay from mud holes all year round, except in September when they are bingeing on fruit which, because it has evolved to be eaten, is not toxic. And the addition of clay to the diets of domestic cattle increases the amount of nutrients that they can absorb from their food by 10-20%.

F

A third instance of animal self-medication is the use of mechanical scours to get rid of gut parasites, in 1972 Richard Wrangham, a researcher at the Gombe Stream Reserve in Tanzania, noticed that chimpanzees were eating the leaves of a tree called Aspilia. The chimps chose the leaves carefully by testing them in their mouths. Having chosen a leaf, a chimp would fold it into a fan and swallow it. Some of the chimps were noticed wrinkling their noses as they swallowed these leaves, suggesting the experience was unpleasant. Later, undigested leaves were found on the forest floor.

G

Dr Wrangham rightly guessed that the leaves had a medicinal purpose—this was, indeed, one of the earliest interpretations of a behaviour pattern as self-medication. However, he guessed wrong about what the mechanism was. His (and everybody else’s) assumption was that Aspilia contained a drug, and this sparked more than two decades of phytochemical research to try to find out what chemical the chimps were after. But by the 1990s, chimps across Africa had been seen swallowing the leaves of 19 different species that seemed to have few suitable chemicals in common. The drug hypothesis was looking more and more dubious.

H

It was Dr Huffman who got to the bottom of the problem. He did so by watching what came out of the chimps, rather than concentrating on what went in. He found that the egested leaves were full of intestinal worms. The factor common to all 19 species of leaves swallowed by the chimps was that they were covered with microscopic hooks. These caught the worms and dragged them from their lodgings.

I

Following that observation, Dr Engel is now particularly excited about how knowledge of the way that animals look after themselves could be used to improve the health of livestock. People might also be able to learn a thing or two, and may, indeed, already have done so. Geophagy, for example, is a common behaviour in many parts of the world. The medical stalls in African markets frequently sell tablets made of different sorts of clays, appropriate to different medical conditions.

J

Africans brought to the Americas as slaves continued this tradition, which gave their owners one more excuse to affect to despise them. Yet, as Dr Engel points out, Rwandan mountain gorillas eat a type of clay rather similar to kaolinite – the main ingredient of many patent medicines sold over the counter in the West for digestive complaints. Dirt can sometimes be good for you, and to be “as sick as a parrot” may, after all, be a state to be desired.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('6971f0e3-fd3b-58f4-a96f-72744034283b', '871b986d-3e02-517f-915a-011b0a03df99', 1, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 1

Questions 1-4
Questions 1-4
Do the following statements agree with the information given in Reading Passage 1?
In boxes
1-4
on your answer sheet, write
TRUE
if the statement is true
FALSE
if the statement is false
NOT GIVEN
if the information is not given in the passage
1
It is for 10 years that Dr Engel has been working on animal self-medication.
2
In order to find plants for medication, animals usually need to walk a long distance.
3
Birds such as Macaw, are seen eating clay because it is a part of their natural diet.
4
According to Dr Engel, it is exciting that research into animal self-medication can be helpful in the invention of new painkillers.

1 ____ It is for 10 years that Dr Engel has been working on animal self-medication.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a7317331-3d07-5b02-b721-fcd6a3aae7ba', '6971f0e3-fd3b-58f4-a96f-72744034283b', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('49b59c37-f836-5741-9fad-c7ccf0093a16', '6971f0e3-fd3b-58f4-a96f-72744034283b', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9638f3be-8f1c-5bcf-979e-121f9d914ec2', '6971f0e3-fd3b-58f4-a96f-72744034283b', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('1e2a6abf-64e6-5e38-8120-1aa5d305d8c9', '871b986d-3e02-517f-915a-011b0a03df99', 2, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 2

Questions 1-4
Questions 1-4
Do the following statements agree with the information given in Reading Passage 1?
In boxes
1-4
on your answer sheet, write
TRUE
if the statement is true
FALSE
if the statement is false
NOT GIVEN
if the information is not given in the passage
1
It is for 10 years that Dr Engel has been working on animal self-medication.
2
In order to find plants for medication, animals usually need to walk a long distance.
3
Birds such as Macaw, are seen eating clay because it is a part of their natural diet.
4
According to Dr Engel, it is exciting that research into animal self-medication can be helpful in the invention of new painkillers.

2 ____ In order to find plants for medication, animals usually need to walk a long distance.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e1759a58-2176-5cdb-847b-3b5bde6588e1', '1e2a6abf-64e6-5e38-8120-1aa5d305d8c9', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6c429df8-7e15-5d71-959a-a240509af96d', '1e2a6abf-64e6-5e38-8120-1aa5d305d8c9', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('af5365e5-88f5-5090-8e0e-bf05e54a7e08', '1e2a6abf-64e6-5e38-8120-1aa5d305d8c9', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('0016e3b0-4a78-5a78-b66e-d6e5f4c7f22b', '871b986d-3e02-517f-915a-011b0a03df99', 3, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 3

Questions 1-4
Questions 1-4
Do the following statements agree with the information given in Reading Passage 1?
In boxes
1-4
on your answer sheet, write
TRUE
if the statement is true
FALSE
if the statement is false
NOT GIVEN
if the information is not given in the passage
1
It is for 10 years that Dr Engel has been working on animal self-medication.
2
In order to find plants for medication, animals usually need to walk a long distance.
3
Birds such as Macaw, are seen eating clay because it is a part of their natural diet.
4
According to Dr Engel, it is exciting that research into animal self-medication can be helpful in the invention of new painkillers.

3 ____ Birds such as Macaw, are seen eating clay because it is a part of their natural diet.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f89f9247-78be-5717-adfa-73afb96de5bf', '0016e3b0-4a78-5a78-b66e-d6e5f4c7f22b', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9e785e6b-52df-5cf9-ad9e-e4b48c4e6480', '0016e3b0-4a78-5a78-b66e-d6e5f4c7f22b', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1f871b10-03d5-51f8-ae4d-705c8d70f1a3', '0016e3b0-4a78-5a78-b66e-d6e5f4c7f22b', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('cda92654-aec7-50c5-bab5-214476303a77', '871b986d-3e02-517f-915a-011b0a03df99', 4, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 4

Questions 1-4
Questions 1-4
Do the following statements agree with the information given in Reading Passage 1?
In boxes
1-4
on your answer sheet, write
TRUE
if the statement is true
FALSE
if the statement is false
NOT GIVEN
if the information is not given in the passage
1
It is for 10 years that Dr Engel has been working on animal self-medication.
2
In order to find plants for medication, animals usually need to walk a long distance.
3
Birds such as Macaw, are seen eating clay because it is a part of their natural diet.
4
According to Dr Engel, it is exciting that research into animal self-medication can be helpful in the invention of new painkillers.

4 ____ According to Dr Engel, it is exciting that research into animal self-medication can be helpful in the invention of new painkillers.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ef505d17-3c80-54f5-80be-f811db3d3788', 'cda92654-aec7-50c5-bab5-214476303a77', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4bcec0f3-723b-574a-9ed0-ca1f442627f5', 'cda92654-aec7-50c5-bab5-214476303a77', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3a98a7bb-449d-58a5-b762-8a5a687f59fe', 'cda92654-aec7-50c5-bab5-214476303a77', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('d8631a15-db9c-5e96-926d-c249500d39bf', '871b986d-3e02-517f-915a-011b0a03df99', 5, 'NOTE_COMPLETION', 'READING', 3, $md$### Question 5

Questions 5-9
Questions 5-9
Complete the notes below using
NO MORE THAN ONE WORD
from the passage.
Write your answers in boxes
5-9
on your answer sheet.
Date
Name
Animal
Food
Mechanism
1987
Michael Huffman and Mohamedi Seifu
Chimpanzee
5
of Veronia
Contained chemicals named
6
which can kill parasites
1999
James Gilardi and his colleagues
Macaw
Seeds (contain
7
) and clay
Clay can
8
the poisonous contents in food
1972
Richard Wrangham
Chimpanzee
Leaves with tiny
9
on surface
Such leaves can catch and expel worms from intestines

5 ____ of Veronia$md$, NULL, ARRAY['.*pith.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('8cd8aa03-5992-5d1c-b64a-ca0c62162f65', '871b986d-3e02-517f-915a-011b0a03df99', 6, 'NOTE_COMPLETION', 'READING', 3, $md$### Question 6

Questions 5-9
Questions 5-9
Complete the notes below using
NO MORE THAN ONE WORD
from the passage.
Write your answers in boxes
5-9
on your answer sheet.
Date
Name
Animal
Food
Mechanism
1987
Michael Huffman and Mohamedi Seifu
Chimpanzee
5
of Veronia
Contained chemicals named
6
which can kill parasites
1999
James Gilardi and his colleagues
Macaw
Seeds (contain
7
) and clay
Clay can
8
the poisonous contents in food
1972
Richard Wrangham
Chimpanzee
Leaves with tiny
9
on surface
Such leaves can catch and expel worms from intestines

Contained chemicals named 6 ____ which can kill parasites$md$, NULL, ARRAY['.*terpenes.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('86305b7d-ab08-56a4-ad20-44ecf1f3cc4d', '871b986d-3e02-517f-915a-011b0a03df99', 7, 'NOTE_COMPLETION', 'READING', 3, $md$### Question 7

Questions 5-9
Questions 5-9
Complete the notes below using
NO MORE THAN ONE WORD
from the passage.
Write your answers in boxes
5-9
on your answer sheet.
Date
Name
Animal
Food
Mechanism
1987
Michael Huffman and Mohamedi Seifu
Chimpanzee
5
of Veronia
Contained chemicals named
6
which can kill parasites
1999
James Gilardi and his colleagues
Macaw
Seeds (contain
7
) and clay
Clay can
8
the poisonous contents in food
1972
Richard Wrangham
Chimpanzee
Leaves with tiny
9
on surface
Such leaves can catch and expel worms from intestines

Seeds (contain 7 ____ ) and clay$md$, NULL, ARRAY['.*alkaloids.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('5d0d557c-fc7f-5a6d-afd4-1bcbd935ab56', '871b986d-3e02-517f-915a-011b0a03df99', 8, 'NOTE_COMPLETION', 'READING', 3, $md$### Question 8

Questions 5-9
Questions 5-9
Complete the notes below using
NO MORE THAN ONE WORD
from the passage.
Write your answers in boxes
5-9
on your answer sheet.
Date
Name
Animal
Food
Mechanism
1987
Michael Huffman and Mohamedi Seifu
Chimpanzee
5
of Veronia
Contained chemicals named
6
which can kill parasites
1999
James Gilardi and his colleagues
Macaw
Seeds (contain
7
) and clay
Clay can
8
the poisonous contents in food
1972
Richard Wrangham
Chimpanzee
Leaves with tiny
9
on surface
Such leaves can catch and expel worms from intestines

Clay can 8 ____ the poisonous contents in food$md$, NULL, ARRAY['.*detoxify.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('bbc28272-e225-5bf6-8eb6-26ea5db2656e', '871b986d-3e02-517f-915a-011b0a03df99', 9, 'NOTE_COMPLETION', 'READING', 3, $md$### Question 9

Questions 5-9
Questions 5-9
Complete the notes below using
NO MORE THAN ONE WORD
from the passage.
Write your answers in boxes
5-9
on your answer sheet.
Date
Name
Animal
Food
Mechanism
1987
Michael Huffman and Mohamedi Seifu
Chimpanzee
5
of Veronia
Contained chemicals named
6
which can kill parasites
1999
James Gilardi and his colleagues
Macaw
Seeds (contain
7
) and clay
Clay can
8
the poisonous contents in food
1972
Richard Wrangham
Chimpanzee
Leaves with tiny
9
on surface
Such leaves can catch and expel worms from intestines

Leaves with tiny 9 ____ on surface$md$, NULL, ARRAY['.*hooks.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('c1d41281-8c90-5c37-a2db-bbd60dad671c', '871b986d-3e02-517f-915a-011b0a03df99', 10, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 10

Questions 10-13
Questions 10-13
Complete the summary below using words from the box.
Write your answers,
A-H
, in boxes
10-13
on your answer sheet.
Though often doubted, the self-medicating behaviour of animals has been supported by an increasing amount of evidence. One piece of evidence particularly deals with
10
, a soil-consuming behaviour commonly found across animals species, because the earth, often clay, can neutralize the
11
content of their diet. Such behaviour can also be found among humans in Africa, where people purchase
12
at market stalls as a kind of medication to their illnesses. Another example of this is found in chimps eating leaves of often
13
taste but with no apparent medicinal value until its unique structure came into light.
A
mineral
B
plants
C
unpleasant
D
toxic
E
clay tablets
F
nutritional
G
geophagy
H
harmless

Though often doubted, the self-medicating behaviour of animals has been supported by an increasing amount of evidence. One piece of evidence particularly deals with 10 ____ , a soil-consuming behaviour commonly found across animals species, because the earth, often clay, can neutralize the 11 ____ content of their diet. Such behaviour can also be found among humans in Africa, where people purchase 12 ____ at market stalls as a kind of medication to their illnesses. Another example of this is found in chimps eating leaves of often 13 ____ taste but with no apparent medicinal value until its unique structure came into light.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2a731586-57b9-50ef-b3b6-0be9c661d6e1', 'c1d41281-8c90-5c37-a2db-bbd60dad671c', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('baefedf6-b60b-5a1a-8389-baf07a84bccc', 'c1d41281-8c90-5c37-a2db-bbd60dad671c', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cd942dae-e1dc-569a-8328-bdf6b9dca1b0', 'c1d41281-8c90-5c37-a2db-bbd60dad671c', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0385a93d-7e3d-57f0-9445-aad89e8112ed', 'c1d41281-8c90-5c37-a2db-bbd60dad671c', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('741137c4-e3ba-58e6-8e24-57f6e2859d31', 'c1d41281-8c90-5c37-a2db-bbd60dad671c', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('825aac39-0f11-54ea-8ff1-d085cdcedbb9', 'c1d41281-8c90-5c37-a2db-bbd60dad671c', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c2b33243-c67d-5faf-b9f9-03acdb8fcabc', 'c1d41281-8c90-5c37-a2db-bbd60dad671c', 7, $md$G$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3b31f0ed-92f7-5e26-a8f9-7d694398a1b3', 'c1d41281-8c90-5c37-a2db-bbd60dad671c', 8, $md$H$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('4f3b0b5f-0e91-5ab4-ad2f-007f69e85976', '871b986d-3e02-517f-915a-011b0a03df99', 11, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 11

Questions 10-13
Questions 10-13
Complete the summary below using words from the box.
Write your answers,
A-H
, in boxes
10-13
on your answer sheet.
Though often doubted, the self-medicating behaviour of animals has been supported by an increasing amount of evidence. One piece of evidence particularly deals with
10
, a soil-consuming behaviour commonly found across animals species, because the earth, often clay, can neutralize the
11
content of their diet. Such behaviour can also be found among humans in Africa, where people purchase
12
at market stalls as a kind of medication to their illnesses. Another example of this is found in chimps eating leaves of often
13
taste but with no apparent medicinal value until its unique structure came into light.
A
mineral
B
plants
C
unpleasant
D
toxic
E
clay tablets
F
nutritional
G
geophagy
H
harmless

Though often doubted, the self-medicating behaviour of animals has been supported by an increasing amount of evidence. One piece of evidence particularly deals with 10 ____ , a soil-consuming behaviour commonly found across animals species, because the earth, often clay, can neutralize the 11 ____ content of their diet. Such behaviour can also be found among humans in Africa, where people purchase 12 ____ at market stalls as a kind of medication to their illnesses. Another example of this is found in chimps eating leaves of often 13 ____ taste but with no apparent medicinal value until its unique structure came into light.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('66ecbc62-9ca8-5375-b17d-50e33c2bfad2', '4f3b0b5f-0e91-5ab4-ad2f-007f69e85976', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1e6b6fc9-78ea-5e93-ad87-6ce512251721', '4f3b0b5f-0e91-5ab4-ad2f-007f69e85976', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('92e4690c-8d14-5f4f-8a0b-094559c38108', '4f3b0b5f-0e91-5ab4-ad2f-007f69e85976', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f1faa7fc-ef53-5156-8a6a-175aec66e498', '4f3b0b5f-0e91-5ab4-ad2f-007f69e85976', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f844e6a2-7441-5d20-b72a-1f68cdac52e1', '4f3b0b5f-0e91-5ab4-ad2f-007f69e85976', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('eea5a5c4-11b1-51a2-8d65-9dc709ebfe0e', '4f3b0b5f-0e91-5ab4-ad2f-007f69e85976', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('59770b7a-4375-5e43-8ed8-c85d00378d74', '4f3b0b5f-0e91-5ab4-ad2f-007f69e85976', 7, $md$G$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1b86d204-8b55-5fa8-828e-9097ba2a82f2', '4f3b0b5f-0e91-5ab4-ad2f-007f69e85976', 8, $md$H$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('38975964-e6e6-5824-8c66-573322507970', '871b986d-3e02-517f-915a-011b0a03df99', 12, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 12

Questions 10-13
Questions 10-13
Complete the summary below using words from the box.
Write your answers,
A-H
, in boxes
10-13
on your answer sheet.
Though often doubted, the self-medicating behaviour of animals has been supported by an increasing amount of evidence. One piece of evidence particularly deals with
10
, a soil-consuming behaviour commonly found across animals species, because the earth, often clay, can neutralize the
11
content of their diet. Such behaviour can also be found among humans in Africa, where people purchase
12
at market stalls as a kind of medication to their illnesses. Another example of this is found in chimps eating leaves of often
13
taste but with no apparent medicinal value until its unique structure came into light.
A
mineral
B
plants
C
unpleasant
D
toxic
E
clay tablets
F
nutritional
G
geophagy
H
harmless

Though often doubted, the self-medicating behaviour of animals has been supported by an increasing amount of evidence. One piece of evidence particularly deals with 10 ____ , a soil-consuming behaviour commonly found across animals species, because the earth, often clay, can neutralize the 11 ____ content of their diet. Such behaviour can also be found among humans in Africa, where people purchase 12 ____ at market stalls as a kind of medication to their illnesses. Another example of this is found in chimps eating leaves of often 13 ____ taste but with no apparent medicinal value until its unique structure came into light.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3ea1b552-3619-5c59-b32c-1fc3c11186a3', '38975964-e6e6-5824-8c66-573322507970', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6ac7d4ff-a10e-5f3b-94d7-c5340cd8504b', '38975964-e6e6-5824-8c66-573322507970', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('78f06d44-160c-54d6-bb01-9f8e8d11da70', '38975964-e6e6-5824-8c66-573322507970', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e97e21f1-538c-5b60-a66b-d64d6dc8da3f', '38975964-e6e6-5824-8c66-573322507970', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('77213999-15d2-59a6-9cb3-1fce49b4c93f', '38975964-e6e6-5824-8c66-573322507970', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2cf87d9d-afec-5c30-a2bf-1ab0d27ac44c', '38975964-e6e6-5824-8c66-573322507970', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('feb5c5e0-2304-5d4c-a25b-fd225a77370c', '38975964-e6e6-5824-8c66-573322507970', 7, $md$G$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8d85742e-1f6a-5ee9-a611-f4aa58ad15cf', '38975964-e6e6-5824-8c66-573322507970', 8, $md$H$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('8feed87d-e432-501b-833c-eeafaf1eaefc', '871b986d-3e02-517f-915a-011b0a03df99', 13, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 13

Questions 10-13
Questions 10-13
Complete the summary below using words from the box.
Write your answers,
A-H
, in boxes
10-13
on your answer sheet.
Though often doubted, the self-medicating behaviour of animals has been supported by an increasing amount of evidence. One piece of evidence particularly deals with
10
, a soil-consuming behaviour commonly found across animals species, because the earth, often clay, can neutralize the
11
content of their diet. Such behaviour can also be found among humans in Africa, where people purchase
12
at market stalls as a kind of medication to their illnesses. Another example of this is found in chimps eating leaves of often
13
taste but with no apparent medicinal value until its unique structure came into light.
A
mineral
B
plants
C
unpleasant
D
toxic
E
clay tablets
F
nutritional
G
geophagy
H
harmless

Though often doubted, the self-medicating behaviour of animals has been supported by an increasing amount of evidence. One piece of evidence particularly deals with 10 ____ , a soil-consuming behaviour commonly found across animals species, because the earth, often clay, can neutralize the 11 ____ content of their diet. Such behaviour can also be found among humans in Africa, where people purchase 12 ____ at market stalls as a kind of medication to their illnesses. Another example of this is found in chimps eating leaves of often 13 ____ taste but with no apparent medicinal value until its unique structure came into light.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('31dc27b8-de42-5d31-b400-553681e0b5ff', '8feed87d-e432-501b-833c-eeafaf1eaefc', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a16f2d3d-bb02-5efe-baa5-7dcdff2ef362', '8feed87d-e432-501b-833c-eeafaf1eaefc', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5cbdd1a8-366c-5dba-8ebc-597ad1d0d37d', '8feed87d-e432-501b-833c-eeafaf1eaefc', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('268b3dd2-fff8-5ce9-8f6e-6d5158f11a34', '8feed87d-e432-501b-833c-eeafaf1eaefc', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('911130dc-af1b-58f6-9caa-c182d62bd6f2', '8feed87d-e432-501b-833c-eeafaf1eaefc', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('31c5b50d-4fb9-5edf-b2d7-30d646f1fe72', '8feed87d-e432-501b-833c-eeafaf1eaefc', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('95662036-be3a-535f-8a33-0c471bf52fb6', '8feed87d-e432-501b-833c-eeafaf1eaefc', 7, $md$G$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('176235c6-a63c-5878-8a6b-efe4a4e04841', '8feed87d-e432-501b-833c-eeafaf1eaefc', 8, $md$H$md$, false);

COMMIT;
