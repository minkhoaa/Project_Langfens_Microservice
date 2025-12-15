BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-biodiversity-1332'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-biodiversity-1332';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-biodiversity-1332';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-biodiversity-1332';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('7a92dabb-4737-5f0d-a276-9126473d0aa1', 'ielts-reading-biodiversity-1332', $t$Biodiversity$t$, $md$## Biodiversity

Nguồn:
- Test: https://mini-ielts.com/1332/reading/biodiversity
- Solution: https://mini-ielts.com/1332/view-solution/reading/biodiversity$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('8e98a0b5-c939-549c-bd24-9c92ff9b2fb9', '7a92dabb-4737-5f0d-a276-9126473d0aa1', 1, $t$Reading — Biodiversity$t$, $md$Read the passage and answer questions **1–13**.

### Passage: Biodiversity

A

It seems biodiversity has become a buzzword beloved of politicians, conservationists, protesters and scientists alike. But what exactly is it? The Convention on Biological Diversity, an international agreement to conserve and share the planet’s biological riches, provides a good working definition: biodiversity comprises every form of life, from the smallest microbe to the largest animal or plant, the genes that give them their specific characteristics and the ecosystems of which they are apart.

B

In October, the World Conservation Union (also known as the IUCN) published its updated Red List of Threatened Species, a roll call of 11,167 creatures facing extinction – 121 more than when the list was last published in 2000. But the new figures almost certainly underestimate the crisis. Some 1.2 million species of animal and 270,000 species of plant have been classified, but the well-being of only a fraction has been assessed. The resources are simply not available. The IUCN reports that 5714 plants are threatened, for example, but admits that only 4 per cent of known plants has been assessed. And, of course, there are thousands of species that we have yet to discover. Many of these could also be facing extinction.

C

It is important to develop a picture of the diversity of life on Earth now so that comparisons can be made in the future and trends identified. But it isn’t necessary to observe every single type of organism in an area to get a snapshot of the health of the ecosystem. In many habitats, there are species that are particularly susceptible to shifting conditions, and these can be used as indicator species.

D

In the media, it is usually large, charismatic animals such as pandas, elephants, tigers and whales that get all the attention when a loss of biodiversity is discussed. However, animals or plants far lower down the food chain are often the ones vital for preserving habitats – in the process saving the skins of those more glamorous species. There are known as keystone species.

E

By studying the complex feeding relationships within habitats, species can be identified that have a particularly important impact on the environment. For example, the members of the fig family are the staple food for hundreds of different species in many different countries, so important that scientists sometimes call figs “jungle burgers”. A whole range of animals, from tiny insects to birds and large mammals, feed on everything from the tree’s bark and leaves to its flowers and fruits. Many fig species have very specific pollinators. There are several dozen species of the fig tree in Costa Rica, and a different type of wasp has evolved to pollinate each one. Chris Lyle of the Natural History Museum in London – who is also involved in the Global Taxonomy Initiative of the Convention on Biological Diversity – points out that if fig trees are affected by global warming, pollution, disease or any other catastrophe, the loss of biodiversity will be enormous.

F

Similarly, sea otters play a major role in the survival of giant kelp forests along the coasts of California and Alaska. These “marine rainforests” provide a home for a wide range of other species. The kelp itself is the main food of purple and red sea urchins and in turn, the urchins are eaten by predators, particularly sea otters. They detach an urchin from the seabed then float to the surface and lie on their backs with the urchin shell on their tummy, smashing it open with a stone before eating the contents. Urchins that are not eaten tend to spend their time in rock crevices to avoid the predators. This allows the kelp to grow – and it can grow many centimetres in a day. As the forests form, bits of kelp break off and fall to the bottom to provide food for the urchins in their crevices. The sea otters thrive hunting for sea urchins in the kelp, and many other fish and invertebrates live among the fronds. The problems start when the sea otter population declines. As large predators they are vulnerable – their numbers are relatively small to disease or human hunters can wipe them out. The result is that the sea urchin population grows unchecked and they roam the seafloor eating young kelp fronds. This tends to keep the kelp very short and stops forests developing, which has a huge impact on biodiversity.

G

Conversely, keystone species can also make dangerous alien species: they can wreak havoc if they end up in the wrong ecosystem. The cactus moth, whose caterpillar is a voracious eater of prickly pear was introduced to Australia to control the rampant cacti. It was so successful that someone thought it would be a good idea to introduce it to Caribbean islands that had the same problem. It solved the cactus menace, but unfortunately, some of the moths have now reached the US mainland – borne on winds and in tourists’ luggage – where they are devastating the native cactus populations of Florida.

H

Organisations like the Convention on Biological Diversity work with groups such as the UN and with governments and scientists to raise awareness and fund research. A number of major international meetings – including the World Summit on Sustainable Development in Johannesburg this year – have set targets for governments around the world to slow the loss of biodiversity. And the CITES meeting in Santiago last month added several more names to its list of endangered species for which trade is controlled. Of course, these agreements will prove of limited value if some countries refuse to implement them.

I

There is cause for optimism, however. There seems to be a growing understanding of the need for sustainable agriculture and sustainable tourism to conserve biodiversity. Problems such as illegal logging are being tackled through sustainable forestry programmes, with the emphasis on minimising the use of rainforest hardwoods in the developed world and on rigorous replanting of whatever trees are harvested. CITES is playing its part by controlling trade in wood from endangered tree species. In the same way, sustainable farming techniques that minimise environmental damage and avoid monoculture.

J

Action at a national level often means investing in public education and awareness. Getting people like you and me involved can be very effective. Australia and many European countries are becoming increasingly efficient at recycling much of their domestic waste, for example, preserving natural resources and reducing the use of fossil fuels. This, in turn, has a direct effect on biodiversity by minimising pollution, and an indirect effect by reducing the number of greenhouse gases emitted from incinerators and landfill sites. Preserving ecosystems intact for future generations to enjoy is obviously important, but biodiversity is not some kind of optional extra. Variety may be “the spice of life”, but biological variety is also our life-support system.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('81319ea5-9a08-5f03-a75e-103eb8feab84', '8e98a0b5-c939-549c-bd24-9c92ff9b2fb9', 1, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 1

Questions 1-7
Questions 1-7
Do the following statements agree with the information given in Reading Passage ?
In boxes
1-7
on your answer sheet, write
TRUE
if the statement is true
FALSE
if the statement is false
NOT GIVEN
if the information is not given in the passage
1
The term “biodiversity” consists of living creatures and the environment that they live in.
2
There are species that have not been researched because it’s unnecessary to study all creatures.
3
It is not necessary to investigate all creatures in a certain place.
4
The press more often than not focuses on animals well-known.
5
There is a successful case that cactus moth plays a positive role in the US.
6
Usage of hardwoods is forbidden in some European countries.
7
Agriculture experts advise farmers to plant single crops in the field in terms of sustainable farming.

1 ____ The term “biodiversity” consists of living creatures and the environment that they live in.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a827a136-0b1a-5a55-8e2a-8e31eb351e54', '81319ea5-9a08-5f03-a75e-103eb8feab84', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('dbf76b50-3b99-5b63-9e14-ea0946eb58b0', '81319ea5-9a08-5f03-a75e-103eb8feab84', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3137c983-dfba-51d4-a4f5-e8eb779152ac', '81319ea5-9a08-5f03-a75e-103eb8feab84', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('f05c738f-60fb-5de3-a345-92cb6fd27e6f', '8e98a0b5-c939-549c-bd24-9c92ff9b2fb9', 2, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 2

Questions 1-7
Questions 1-7
Do the following statements agree with the information given in Reading Passage ?
In boxes
1-7
on your answer sheet, write
TRUE
if the statement is true
FALSE
if the statement is false
NOT GIVEN
if the information is not given in the passage
1
The term “biodiversity” consists of living creatures and the environment that they live in.
2
There are species that have not been researched because it’s unnecessary to study all creatures.
3
It is not necessary to investigate all creatures in a certain place.
4
The press more often than not focuses on animals well-known.
5
There is a successful case that cactus moth plays a positive role in the US.
6
Usage of hardwoods is forbidden in some European countries.
7
Agriculture experts advise farmers to plant single crops in the field in terms of sustainable farming.

2 ____ There are species that have not been researched because it’s unnecessary to study all creatures.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('701cb9e3-cda4-59c2-a6d0-1cd3ee1cbab9', 'f05c738f-60fb-5de3-a345-92cb6fd27e6f', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('65520d7f-fa49-5513-852f-101084053fcc', 'f05c738f-60fb-5de3-a345-92cb6fd27e6f', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('11101a5b-3654-5525-948c-4e365a660bc3', 'f05c738f-60fb-5de3-a345-92cb6fd27e6f', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('b10c19ed-b243-51cd-8969-0ab58edaa9ff', '8e98a0b5-c939-549c-bd24-9c92ff9b2fb9', 3, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 3

Questions 1-7
Questions 1-7
Do the following statements agree with the information given in Reading Passage ?
In boxes
1-7
on your answer sheet, write
TRUE
if the statement is true
FALSE
if the statement is false
NOT GIVEN
if the information is not given in the passage
1
The term “biodiversity” consists of living creatures and the environment that they live in.
2
There are species that have not been researched because it’s unnecessary to study all creatures.
3
It is not necessary to investigate all creatures in a certain place.
4
The press more often than not focuses on animals well-known.
5
There is a successful case that cactus moth plays a positive role in the US.
6
Usage of hardwoods is forbidden in some European countries.
7
Agriculture experts advise farmers to plant single crops in the field in terms of sustainable farming.

3 ____ It is not necessary to investigate all creatures in a certain place.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e405c7b0-e658-5a4e-b9e7-ef87826c78aa', 'b10c19ed-b243-51cd-8969-0ab58edaa9ff', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2ac5785d-519e-50fe-a4d6-9ce8bfab7abe', 'b10c19ed-b243-51cd-8969-0ab58edaa9ff', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c9acf338-6a20-5467-af51-407366c112d9', 'b10c19ed-b243-51cd-8969-0ab58edaa9ff', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('a907b72c-a5ea-564a-ae57-50d9f2400d65', '8e98a0b5-c939-549c-bd24-9c92ff9b2fb9', 4, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 4

Questions 1-7
Questions 1-7
Do the following statements agree with the information given in Reading Passage ?
In boxes
1-7
on your answer sheet, write
TRUE
if the statement is true
FALSE
if the statement is false
NOT GIVEN
if the information is not given in the passage
1
The term “biodiversity” consists of living creatures and the environment that they live in.
2
There are species that have not been researched because it’s unnecessary to study all creatures.
3
It is not necessary to investigate all creatures in a certain place.
4
The press more often than not focuses on animals well-known.
5
There is a successful case that cactus moth plays a positive role in the US.
6
Usage of hardwoods is forbidden in some European countries.
7
Agriculture experts advise farmers to plant single crops in the field in terms of sustainable farming.

4 ____ The press more often than not focuses on animals well-known.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('eeba5d35-f87f-55e4-b5a0-2163f1e33e22', 'a907b72c-a5ea-564a-ae57-50d9f2400d65', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9d8dd290-38a9-5f7e-ad4f-c7892baa288e', 'a907b72c-a5ea-564a-ae57-50d9f2400d65', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d8533d88-eab3-516b-b37c-b8a349173779', 'a907b72c-a5ea-564a-ae57-50d9f2400d65', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('713459eb-75a9-5d00-87f5-a784d9597222', '8e98a0b5-c939-549c-bd24-9c92ff9b2fb9', 5, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 5

Questions 1-7
Questions 1-7
Do the following statements agree with the information given in Reading Passage ?
In boxes
1-7
on your answer sheet, write
TRUE
if the statement is true
FALSE
if the statement is false
NOT GIVEN
if the information is not given in the passage
1
The term “biodiversity” consists of living creatures and the environment that they live in.
2
There are species that have not been researched because it’s unnecessary to study all creatures.
3
It is not necessary to investigate all creatures in a certain place.
4
The press more often than not focuses on animals well-known.
5
There is a successful case that cactus moth plays a positive role in the US.
6
Usage of hardwoods is forbidden in some European countries.
7
Agriculture experts advise farmers to plant single crops in the field in terms of sustainable farming.

5 ____ There is a successful case that cactus moth plays a positive role in the US.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('31245dd4-8d4b-559e-884b-bc41404da425', '713459eb-75a9-5d00-87f5-a784d9597222', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2cf6838d-b6c3-5826-951d-e06866ebfb4e', '713459eb-75a9-5d00-87f5-a784d9597222', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c75a1cbe-07d9-5b37-8728-fb14b6512022', '713459eb-75a9-5d00-87f5-a784d9597222', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('75e3c995-611d-581f-b0b5-dc5016a78e7e', '8e98a0b5-c939-549c-bd24-9c92ff9b2fb9', 6, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 6

Questions 1-7
Questions 1-7
Do the following statements agree with the information given in Reading Passage ?
In boxes
1-7
on your answer sheet, write
TRUE
if the statement is true
FALSE
if the statement is false
NOT GIVEN
if the information is not given in the passage
1
The term “biodiversity” consists of living creatures and the environment that they live in.
2
There are species that have not been researched because it’s unnecessary to study all creatures.
3
It is not necessary to investigate all creatures in a certain place.
4
The press more often than not focuses on animals well-known.
5
There is a successful case that cactus moth plays a positive role in the US.
6
Usage of hardwoods is forbidden in some European countries.
7
Agriculture experts advise farmers to plant single crops in the field in terms of sustainable farming.

6 ____ Usage of hardwoods is forbidden in some European countries.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('dd9cb2c1-737a-54ba-922c-55da1e3718bd', '75e3c995-611d-581f-b0b5-dc5016a78e7e', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('37828e40-e77f-5fe2-8ac0-d83732d31c99', '75e3c995-611d-581f-b0b5-dc5016a78e7e', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f0325947-19fd-5b57-bc29-57cab5ba83b9', '75e3c995-611d-581f-b0b5-dc5016a78e7e', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('68f7ce43-46f6-57b1-956f-b74855f84073', '8e98a0b5-c939-549c-bd24-9c92ff9b2fb9', 7, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 7

Questions 1-7
Questions 1-7
Do the following statements agree with the information given in Reading Passage ?
In boxes
1-7
on your answer sheet, write
TRUE
if the statement is true
FALSE
if the statement is false
NOT GIVEN
if the information is not given in the passage
1
The term “biodiversity” consists of living creatures and the environment that they live in.
2
There are species that have not been researched because it’s unnecessary to study all creatures.
3
It is not necessary to investigate all creatures in a certain place.
4
The press more often than not focuses on animals well-known.
5
There is a successful case that cactus moth plays a positive role in the US.
6
Usage of hardwoods is forbidden in some European countries.
7
Agriculture experts advise farmers to plant single crops in the field in terms of sustainable farming.

7 ____ Agriculture experts advise farmers to plant single crops in the field in terms of sustainable farming.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('57caf6a0-6997-5cb2-91ee-57e5ffa57dc1', '68f7ce43-46f6-57b1-956f-b74855f84073', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('267fc289-3f7d-55b7-b7ce-2f4eeeb9a347', '68f7ce43-46f6-57b1-956f-b74855f84073', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('50105263-9164-56fb-8b15-16d0c350ba0c', '68f7ce43-46f6-57b1-956f-b74855f84073', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('d1379671-9463-5aca-bafd-e4c2dc6c440e', '8e98a0b5-c939-549c-bd24-9c92ff9b2fb9', 8, 'SUMMARY_COMPLETION', 'READING', 3, $md$### Question 8

Questions 8-13
Questions 8-13
Complete the following summary of the paragraphs of Reading Passage, using
NO MORE THAN TWO WORDS
from the Reading Passage for each answer.
Write your answers in boxes 8-13 on your answer sheet.
Because of the ignorance brought by media, people tend to neglect significant creatures called
8
. Every creature has diet connections with others, such as
9
, which provide a majority of foods for other species. In some states of America, the decline in a number of sea otters leads to the boom of
10
. An impressing case is that imported
11
successfully tackles the plant cacti in
12
. However, the operation is needed for the government to increase its financial support in
13
.

Because of the ignorance brought by media, people tend to neglect significant creatures called 8 ____ . Every creature has diet connections with others, such as 9 ____ , which provide a majority of foods for other species. In some states of America, the decline in a number of sea otters leads to the boom of 10 ____ . An impressing case is that imported 11 ____ successfully tackles the plant cacti in 12 ____ . However, the operation is needed for the government to increase its financial support in 13 ____ .$md$, NULL, ARRAY['.*fig.*family.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('85a0272d-2529-5010-992b-4b6ae88e776a', '8e98a0b5-c939-549c-bd24-9c92ff9b2fb9', 9, 'SUMMARY_COMPLETION', 'READING', 3, $md$### Question 9

Questions 8-13
Questions 8-13
Complete the following summary of the paragraphs of Reading Passage, using
NO MORE THAN TWO WORDS
from the Reading Passage for each answer.
Write your answers in boxes 8-13 on your answer sheet.
Because of the ignorance brought by media, people tend to neglect significant creatures called
8
. Every creature has diet connections with others, such as
9
, which provide a majority of foods for other species. In some states of America, the decline in a number of sea otters leads to the boom of
10
. An impressing case is that imported
11
successfully tackles the plant cacti in
12
. However, the operation is needed for the government to increase its financial support in
13
.

Because of the ignorance brought by media, people tend to neglect significant creatures called 8 ____ . Every creature has diet connections with others, such as 9 ____ , which provide a majority of foods for other species. In some states of America, the decline in a number of sea otters leads to the boom of 10 ____ . An impressing case is that imported 11 ____ successfully tackles the plant cacti in 12 ____ . However, the operation is needed for the government to increase its financial support in 13 ____ .$md$, NULL, ARRAY['.*fig.*family.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('5a57c8ce-dfe6-5075-8857-9785138b8a8f', '8e98a0b5-c939-549c-bd24-9c92ff9b2fb9', 10, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 10

Questions 8-13
Questions 8-13
Complete the following summary of the paragraphs of Reading Passage, using
NO MORE THAN TWO WORDS
from the Reading Passage for each answer.
Write your answers in boxes 8-13 on your answer sheet.
Because of the ignorance brought by media, people tend to neglect significant creatures called
8
. Every creature has diet connections with others, such as
9
, which provide a majority of foods for other species. In some states of America, the decline in a number of sea otters leads to the boom of
10
. An impressing case is that imported
11
successfully tackles the plant cacti in
12
. However, the operation is needed for the government to increase its financial support in
13
.

Because of the ignorance brought by media, people tend to neglect significant creatures called 8 ____ . Every creature has diet connections with others, such as 9 ____ , which provide a majority of foods for other species. In some states of America, the decline in a number of sea otters leads to the boom of 10 ____ . An impressing case is that imported 11 ____ successfully tackles the plant cacti in 12 ____ . However, the operation is needed for the government to increase its financial support in 13 ____ .$md$, NULL, ARRAY['.*fig.*family.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('0534c65e-79ab-5cee-a6bb-a929b175ef76', '8e98a0b5-c939-549c-bd24-9c92ff9b2fb9', 11, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 11

Questions 8-13
Questions 8-13
Complete the following summary of the paragraphs of Reading Passage, using
NO MORE THAN TWO WORDS
from the Reading Passage for each answer.
Write your answers in boxes 8-13 on your answer sheet.
Because of the ignorance brought by media, people tend to neglect significant creatures called
8
. Every creature has diet connections with others, such as
9
, which provide a majority of foods for other species. In some states of America, the decline in a number of sea otters leads to the boom of
10
. An impressing case is that imported
11
successfully tackles the plant cacti in
12
. However, the operation is needed for the government to increase its financial support in
13
.

Because of the ignorance brought by media, people tend to neglect significant creatures called 8 ____ . Every creature has diet connections with others, such as 9 ____ , which provide a majority of foods for other species. In some states of America, the decline in a number of sea otters leads to the boom of 10 ____ . An impressing case is that imported 11 ____ successfully tackles the plant cacti in 12 ____ . However, the operation is needed for the government to increase its financial support in 13 ____ .$md$, NULL, ARRAY['.*fig.*family.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('38ea6da1-f311-5da8-a1ad-e25567ab1af8', '8e98a0b5-c939-549c-bd24-9c92ff9b2fb9', 12, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 12

Questions 8-13
Questions 8-13
Complete the following summary of the paragraphs of Reading Passage, using
NO MORE THAN TWO WORDS
from the Reading Passage for each answer.
Write your answers in boxes 8-13 on your answer sheet.
Because of the ignorance brought by media, people tend to neglect significant creatures called
8
. Every creature has diet connections with others, such as
9
, which provide a majority of foods for other species. In some states of America, the decline in a number of sea otters leads to the boom of
10
. An impressing case is that imported
11
successfully tackles the plant cacti in
12
. However, the operation is needed for the government to increase its financial support in
13
.

Because of the ignorance brought by media, people tend to neglect significant creatures called 8 ____ . Every creature has diet connections with others, such as 9 ____ , which provide a majority of foods for other species. In some states of America, the decline in a number of sea otters leads to the boom of 10 ____ . An impressing case is that imported 11 ____ successfully tackles the plant cacti in 12 ____ . However, the operation is needed for the government to increase its financial support in 13 ____ .$md$, NULL, ARRAY['.*fig.*family.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('a5a18452-8d7c-5492-8852-7358edc3eaa6', '8e98a0b5-c939-549c-bd24-9c92ff9b2fb9', 13, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 13

Questions 8-13
Questions 8-13
Complete the following summary of the paragraphs of Reading Passage, using
NO MORE THAN TWO WORDS
from the Reading Passage for each answer.
Write your answers in boxes 8-13 on your answer sheet.
Because of the ignorance brought by media, people tend to neglect significant creatures called
8
. Every creature has diet connections with others, such as
9
, which provide a majority of foods for other species. In some states of America, the decline in a number of sea otters leads to the boom of
10
. An impressing case is that imported
11
successfully tackles the plant cacti in
12
. However, the operation is needed for the government to increase its financial support in
13
.

Because of the ignorance brought by media, people tend to neglect significant creatures called 8 ____ . Every creature has diet connections with others, such as 9 ____ , which provide a majority of foods for other species. In some states of America, the decline in a number of sea otters leads to the boom of 10 ____ . An impressing case is that imported 11 ____ successfully tackles the plant cacti in 12 ____ . However, the operation is needed for the government to increase its financial support in 13 ____ .$md$, NULL, ARRAY['.*fig.*family.*']);

COMMIT;
