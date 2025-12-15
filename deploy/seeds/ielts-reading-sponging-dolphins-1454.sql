BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-sponging-dolphins-1454'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-sponging-dolphins-1454';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-sponging-dolphins-1454';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-sponging-dolphins-1454';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('4fe8c981-3688-52b3-bdfc-0ebbbb3a16bd', 'ielts-reading-sponging-dolphins-1454', $t$Sponging dolphins$t$, $md$## Sponging dolphins

Nguồn:
- Test: https://mini-ielts.com/1454/reading/sponging-dolphins
- Solution: https://mini-ielts.com/1454/view-solution/reading/sponging-dolphins$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('7c7b1624-6e1e-56e5-ab65-cb3de7040ed2', '4fe8c981-3688-52b3-bdfc-0ebbbb3a16bd', 1, $t$Reading — Sponging dolphins$t$, $md$Read the passage and answer questions **1–12**.

### Passage: Sponging dolphins

(A) In 1984, researchers spotted dolphins doing something unusual in Shark Bay, Western Australia. When the animals got hungry, they ripped a marine basket sponge from the sea floor and fitted it over their beaks like a person would fit a glove over a hand. The scientists suspected that as the dolphins foraged for fish, the sponges protected their beaks, or rostra, from the rocks and broken chunks of coral that litter the sea floor, making this behavior the first example of tool use in this species.

(B) The researchers surmised that a long time ago one ingenious Shark Bay dolphin figured out that by prodding the sediments with a sponge attached to her beak, she could stir up these swim bladder-less fish without being hurt. Eventually, such technique became popular among other dolphins. But why do dolphins go to all of this trouble when they could simply snag a fish from the open sea? The answer is that the bottom-dwelling fish are a lot more nutritious. Some species also don't have swim bladders, gas chambers that help other fish control their buoyancy as they travel up and down the water column. In the Bahamas, where dolphins are also known to forage for bottom-dwelling fish, dolphins hunt partly by echolocating these bladders, which give off a strong acoustic signal. That helps the cetaceans find prey even when it's buried in sea sand. But bottom-dwelling fish, such as barred sandperch, which are favored by some Shark Bay dolphins, don't have swim bladders and so are harder to find with echolocation. The sea floor is not nearly as soft here as it is in the Bahamas, so if dolphins want to probe for these fish, they risk injuring their rostra.

(C) Not every dolphin in Shark Bay hunts with sponges. "It's primarily done by females," says Janet Mann, a behavioral ecologist. She believes the female dolphins invented the method because of the "selective pressures they face while raising a calf as long as they do," about 4 to 5 years. "These clever dolphins have figured out a way to target fish that other dolphins cannot," she says, adding that even the local fishermen do not catch, or even know about, this particular species. Mann's previous research has shown that dolphin mothers pass the sponging method to their daughters and some of their sons, rare evidence of a cultural tradition in an animal other than humans. The team has documented three generations of sponging dolphins.

(D) The foraging technique came to light a few decades ago - very recently in evolutionary terms - when a local fisherman spotted what looked like a strange tumour on a dolphin’s nose. Researchers eventually worked out that the ‘tumour’ was a conically shaped sponge and it became apparent that the dolphins would spend considerable time searching for one the right shape to fit their nose. The sponge is used to scatter the sand gently on the sea floor and disturb buried fish. When a fish is spotted, the dolphin drops the sponge and gives chase. "It has been thought that behaviours which are exclusively learnt from one parent are not very stable. With our model we could now show that sponging can be a stable behaviour," said Dr Anna Kopps, a biologist at the University of New South Wales.

(E) By modelling the emergence of "sponger" dolphins in a computer simulation, the team of researchers could see different scenarios in which the skill could have spread among the dolphin population over the years. They then compared the results of these simulations with field data on the genetic relationship between the spongers, to estimate the role of mothers teaching their offspring in transmitting the skill. They found that if the likelihood of a sponger's offspring learning the ability was less than certain, the dolphins that did pick up the technique needed to gain a survival advantage from the skill, in order for the ability to pass on to the next generation. The model also allowed them to attempt to calculate the date that the behaviour was likely to have originated."The results suggested that sponging was innovated at least 120 to 180 years ago - it is only a best estimate," said Dr Kopps. Scientists discovered that although dolphins tried to teach the hunting technique to all their young, it was mainly female offspring that grasped the concept. Why male offspring rarely acquire the same skill remains unclear, though the team put forward one possible explanation: male bottlenose dolphins tend to form close bonds with other males, and such alliances aren't suited to seabed foraging, since it is a time-consuming, solitary activity.

(F) The US scientists say discovering a new tool is a direct sign of intelligence. “There’s a strong link between animals with larger brains and tool users. Bottlenose dolphins have a brain second in size only to humans.” said Janet Mann, a marine biologist who led the research. “Dolphins are already good at catching fish so they don’t need tools, but they’ve discovered this sponge makes their job easier. Working out how to use tools in a creative way like that is a hallmark of intelligence.” Mann admits we still do not understand dolphins well. “It’s hard to get inside their heads because their brains are constructed differently and it’s very hard to analyse their language, but they do seem very intelligent,” she said.

(G) Dolphins are also often seen engaging in playful behaviour and creating tools to use for entertainment. They have been observed to blow bubbles which they form into rings to play with. After creating the bubble ring, a dolphin will use its nose and body to maintain the shape of the bubble and keep it from floating to the surface. The study provides a "better understanding of the why and how of sponging" by the Shark Bay dolphins, says Louis Herman, a cognitive psychologist. The work "adds to previously documented" examples of "innovation by this highly intelligent species." Patterson's and Mann's results also "reinforce a pattern" often seen in other tool-using animals, says Simon Reader, a behavioral biologist. "Tool use appears to be almost a last option, taken when other options fail or are unavailable," he says, noting that woodpecker finches in the Galápagos Islands "turn to tool use only in arid areas," wielding cactus spines to extract grubs from tree branches. Using tools takes time and energy, Reader says, and animals tend to rely on them only when there's a guaranteed payoff, such as turning up a fatty fish that most other dolphins (and fishermen) know nothing about.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('c340acc3-3eb9-5479-8d5f-9f164b95eda6', '7c7b1624-6e1e-56e5-ab65-cb3de7040ed2', 1, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 1

Questions 1-7
Questions 1-7
Reading Passage has seven paragraphs,
A-G.
Which paragraph contains the following information?
Write the correct letter,
A-G
, in boxes 1-7 on your answer sheet.
1
Hallmark of intelligence
2
Fisrt example of dolphins using tools
3
Tool for entertainment
4
The reason why dolphins go through trouble of getting fish from the bottom of the ocean
5
The evidence of tradition in dolphins
6
The estimated time of sponging innovation
7
The observation of a local fisherman

1 ____ Hallmark of intelligence$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bb9d6625-ce70-587e-a972-b296caa63c7e', 'c340acc3-3eb9-5479-8d5f-9f164b95eda6', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ee06e9f9-f531-5578-8394-4fda0beeb79f', 'c340acc3-3eb9-5479-8d5f-9f164b95eda6', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('01bc3b6f-6b05-5879-9ad0-ecdc52740975', 'c340acc3-3eb9-5479-8d5f-9f164b95eda6', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0e8b7146-d2b6-57e9-848b-75612bfcabbb', 'c340acc3-3eb9-5479-8d5f-9f164b95eda6', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('30a29ffc-bfb1-5d7f-a980-6f8abbdeceb7', 'c340acc3-3eb9-5479-8d5f-9f164b95eda6', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4a336d87-3c52-52dd-b2c1-c04d889e88a2', 'c340acc3-3eb9-5479-8d5f-9f164b95eda6', 6, $md$F$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c4344912-8d24-5d28-b6dc-476d416c147e', 'c340acc3-3eb9-5479-8d5f-9f164b95eda6', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('ee4996e3-643b-5b14-94f9-ceab4e4f7c1c', '7c7b1624-6e1e-56e5-ab65-cb3de7040ed2', 2, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 2

Questions 1-7
Questions 1-7
Reading Passage has seven paragraphs,
A-G.
Which paragraph contains the following information?
Write the correct letter,
A-G
, in boxes 1-7 on your answer sheet.
1
Hallmark of intelligence
2
Fisrt example of dolphins using tools
3
Tool for entertainment
4
The reason why dolphins go through trouble of getting fish from the bottom of the ocean
5
The evidence of tradition in dolphins
6
The estimated time of sponging innovation
7
The observation of a local fisherman

2 ____ Fisrt example of dolphins using tools$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('954c2906-312b-568c-8d53-bddc6c83f892', 'ee4996e3-643b-5b14-94f9-ceab4e4f7c1c', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('851ff56a-d246-563d-8987-9732c6abdda3', 'ee4996e3-643b-5b14-94f9-ceab4e4f7c1c', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4f97f414-f00e-5be7-a185-1b47bd94fdff', 'ee4996e3-643b-5b14-94f9-ceab4e4f7c1c', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2ced186b-9e44-554c-81ae-6240df898eee', 'ee4996e3-643b-5b14-94f9-ceab4e4f7c1c', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fb6c0424-b96c-5f01-bac9-7db4fb6b71b4', 'ee4996e3-643b-5b14-94f9-ceab4e4f7c1c', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('43b607e9-14b2-5e10-9d2c-a4fe15f72c18', 'ee4996e3-643b-5b14-94f9-ceab4e4f7c1c', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c643fb3f-ea2f-5fcb-b84f-3c7a67df1bf4', 'ee4996e3-643b-5b14-94f9-ceab4e4f7c1c', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('bbd10786-191d-5fb7-ae2c-31908f8d8154', '7c7b1624-6e1e-56e5-ab65-cb3de7040ed2', 3, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 3

Questions 1-7
Questions 1-7
Reading Passage has seven paragraphs,
A-G.
Which paragraph contains the following information?
Write the correct letter,
A-G
, in boxes 1-7 on your answer sheet.
1
Hallmark of intelligence
2
Fisrt example of dolphins using tools
3
Tool for entertainment
4
The reason why dolphins go through trouble of getting fish from the bottom of the ocean
5
The evidence of tradition in dolphins
6
The estimated time of sponging innovation
7
The observation of a local fisherman

3 ____ Tool for entertainment$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('60e19212-cdb6-5b6b-9a9f-4bff20c38e24', 'bbd10786-191d-5fb7-ae2c-31908f8d8154', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fb1bdecf-f327-5456-80e7-6b21862407bf', 'bbd10786-191d-5fb7-ae2c-31908f8d8154', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('feb48e1c-7b68-5dc5-ae1e-b2d4b85b6944', 'bbd10786-191d-5fb7-ae2c-31908f8d8154', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2fec1f1a-077b-5711-975b-d40fb796ba8c', 'bbd10786-191d-5fb7-ae2c-31908f8d8154', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4284ad5f-5e97-5a19-b097-3be941a06883', 'bbd10786-191d-5fb7-ae2c-31908f8d8154', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1a486a50-0005-5bdd-aae0-555fcbf9cfcd', 'bbd10786-191d-5fb7-ae2c-31908f8d8154', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('16bc7ab0-e502-5493-a084-089218428aea', 'bbd10786-191d-5fb7-ae2c-31908f8d8154', 7, $md$G$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('cfd9e04c-9e02-50bf-906d-9d2455847e04', '7c7b1624-6e1e-56e5-ab65-cb3de7040ed2', 4, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 4

Questions 1-7
Questions 1-7
Reading Passage has seven paragraphs,
A-G.
Which paragraph contains the following information?
Write the correct letter,
A-G
, in boxes 1-7 on your answer sheet.
1
Hallmark of intelligence
2
Fisrt example of dolphins using tools
3
Tool for entertainment
4
The reason why dolphins go through trouble of getting fish from the bottom of the ocean
5
The evidence of tradition in dolphins
6
The estimated time of sponging innovation
7
The observation of a local fisherman

4 ____ The reason why dolphins go through trouble of getting fish from the bottom of the ocean$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('09a1714a-e0f4-5b69-b7a3-21f9d53ad804', 'cfd9e04c-9e02-50bf-906d-9d2455847e04', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('64237f90-0f3d-5b79-9071-c637de2c57c3', 'cfd9e04c-9e02-50bf-906d-9d2455847e04', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('47e97328-7f33-5688-8387-85f8195b63a4', 'cfd9e04c-9e02-50bf-906d-9d2455847e04', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7b1d3298-fc93-556b-adf6-abdd25dba226', 'cfd9e04c-9e02-50bf-906d-9d2455847e04', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('585e3956-86f4-5292-9085-d4feef6e8381', 'cfd9e04c-9e02-50bf-906d-9d2455847e04', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8327245e-e843-5c00-b3cd-9bb8c29ec641', 'cfd9e04c-9e02-50bf-906d-9d2455847e04', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d455e81d-b33e-5b9b-bce4-70b8acb80e55', 'cfd9e04c-9e02-50bf-906d-9d2455847e04', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('6edc1d40-e909-501d-8176-6d057b29a479', '7c7b1624-6e1e-56e5-ab65-cb3de7040ed2', 5, 'MATCHING_INFORMATION', 'READING', 3, $md$### Question 5

Questions 1-7
Questions 1-7
Reading Passage has seven paragraphs,
A-G.
Which paragraph contains the following information?
Write the correct letter,
A-G
, in boxes 1-7 on your answer sheet.
1
Hallmark of intelligence
2
Fisrt example of dolphins using tools
3
Tool for entertainment
4
The reason why dolphins go through trouble of getting fish from the bottom of the ocean
5
The evidence of tradition in dolphins
6
The estimated time of sponging innovation
7
The observation of a local fisherman

5 ____ The evidence of tradition in dolphins$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5ec04ae8-047a-53bb-8296-73f6fc22323a', '6edc1d40-e909-501d-8176-6d057b29a479', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('00898926-d12d-5806-a778-049bdd17240e', '6edc1d40-e909-501d-8176-6d057b29a479', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('601ad2e1-f5e3-5324-9ec7-0498ac721d1e', '6edc1d40-e909-501d-8176-6d057b29a479', 3, $md$C$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('da1e8a8f-626e-55e1-9abf-a11b12ae68ab', '6edc1d40-e909-501d-8176-6d057b29a479', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5143f95d-58a5-5573-8280-122cca3e9c65', '6edc1d40-e909-501d-8176-6d057b29a479', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4d766ad5-6bec-5ffa-8ea5-ad0f0964c2e0', '6edc1d40-e909-501d-8176-6d057b29a479', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('155b8e81-c174-5025-9083-5eea4f97580f', '6edc1d40-e909-501d-8176-6d057b29a479', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('bf8e807a-4626-5dc4-93ec-6dfcd332752d', '7c7b1624-6e1e-56e5-ab65-cb3de7040ed2', 6, 'MATCHING_INFORMATION', 'READING', 3, $md$### Question 6

Questions 1-7
Questions 1-7
Reading Passage has seven paragraphs,
A-G.
Which paragraph contains the following information?
Write the correct letter,
A-G
, in boxes 1-7 on your answer sheet.
1
Hallmark of intelligence
2
Fisrt example of dolphins using tools
3
Tool for entertainment
4
The reason why dolphins go through trouble of getting fish from the bottom of the ocean
5
The evidence of tradition in dolphins
6
The estimated time of sponging innovation
7
The observation of a local fisherman

6 ____ The estimated time of sponging innovation$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('da41f717-9efc-5137-9be3-0ada7849aaa6', 'bf8e807a-4626-5dc4-93ec-6dfcd332752d', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c89ec262-cb54-5af5-b2d6-c4f34542f53b', 'bf8e807a-4626-5dc4-93ec-6dfcd332752d', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ddcefb2a-9bae-5196-8a92-3c60a216f076', 'bf8e807a-4626-5dc4-93ec-6dfcd332752d', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('06758c43-e8c6-5ef3-a1bc-68edb088b867', 'bf8e807a-4626-5dc4-93ec-6dfcd332752d', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('88591a5a-e5cd-51e8-8bfd-527f4c185524', 'bf8e807a-4626-5dc4-93ec-6dfcd332752d', 5, $md$E$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2b1074c4-608c-52aa-a71e-128296f12203', 'bf8e807a-4626-5dc4-93ec-6dfcd332752d', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('45c1ca7e-6928-57d9-aa26-4d7d2e254545', 'bf8e807a-4626-5dc4-93ec-6dfcd332752d', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('14b42f65-7460-59cf-8b22-1c50d4c61a6f', '7c7b1624-6e1e-56e5-ab65-cb3de7040ed2', 7, 'MATCHING_INFORMATION', 'READING', 3, $md$### Question 7

Questions 1-7
Questions 1-7
Reading Passage has seven paragraphs,
A-G.
Which paragraph contains the following information?
Write the correct letter,
A-G
, in boxes 1-7 on your answer sheet.
1
Hallmark of intelligence
2
Fisrt example of dolphins using tools
3
Tool for entertainment
4
The reason why dolphins go through trouble of getting fish from the bottom of the ocean
5
The evidence of tradition in dolphins
6
The estimated time of sponging innovation
7
The observation of a local fisherman

7 ____ The observation of a local fisherman$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bf2acf16-2f83-52df-9c7b-f00f9837af7d', '14b42f65-7460-59cf-8b22-1c50d4c61a6f', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b553a7eb-978d-57a8-8764-338ce54633e2', '14b42f65-7460-59cf-8b22-1c50d4c61a6f', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1e6d1d65-20e5-5a0b-b035-0ab1f2e808de', '14b42f65-7460-59cf-8b22-1c50d4c61a6f', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('184e35d6-fe04-5dc4-90d4-6dab06f507c0', '14b42f65-7460-59cf-8b22-1c50d4c61a6f', 4, $md$D$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8188ae56-675d-508b-8693-94a3efec6be5', '14b42f65-7460-59cf-8b22-1c50d4c61a6f', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0337acc8-c273-58c3-b9c6-a44a3122f234', '14b42f65-7460-59cf-8b22-1c50d4c61a6f', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a340527f-f776-54d0-89ab-e489224c9cf2', '14b42f65-7460-59cf-8b22-1c50d4c61a6f', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('154369e9-f008-5c32-b64e-c0b947700046', '7c7b1624-6e1e-56e5-ab65-cb3de7040ed2', 8, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 8

Questions 8-12
Questions 8-12
Choose the correct letter,
A, B, C
or
D.
Write the correct letter in boxes 8-12 on your answer sheet.
8.
Dolphins use sponges for hunting fish because:
A
they like it.
B
it helps them get fish from the bottom of the ocean.
C
it makes hunting easier.
D
it helps them to get more fish during the hunt.
9.
All the following statements about dolphins are true,
EXCEPT
:
A
Females discovered the method of hunting with sponges.
B
The sponging method is passed by female dolphins to their daughters.
C
Male dolphins never use the sponging technique.
D
Three generations of sponging dolphins have been documented.
10.
Biologist Dr. Anna says that
A
sponging is very dangerous for dolphins.
B
dolphins do not inherit sponging method from their parents.
C
she has benn studying dolphins for a few decades now.
D
sponging can be a stable behaviour.
11.
With the computer simulation that modeled sponging, researchers
A
managed to find out approximately when sponging was originated.
B
were able to predict the behaviour of dolphins.
C
found out the true reason of sponging.
D
discovered a new way treating dolphins
12.
Accroding to Janet Mann
A
bottlenose dolphins have brain as big as humans have.
B
we can understand dolphins well now.
C
dolphins are very intellegent.
D
all of the above.

Choose the correct letter, A, B, C or D.$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('f4ab883d-b056-5b40-ac09-aa1fcdac3f97', '7c7b1624-6e1e-56e5-ab65-cb3de7040ed2', 9, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 9

Questions 8-12
Questions 8-12
Choose the correct letter,
A, B, C
or
D.
Write the correct letter in boxes 8-12 on your answer sheet.
8.
Dolphins use sponges for hunting fish because:
A
they like it.
B
it helps them get fish from the bottom of the ocean.
C
it makes hunting easier.
D
it helps them to get more fish during the hunt.
9.
All the following statements about dolphins are true,
EXCEPT
:
A
Females discovered the method of hunting with sponges.
B
The sponging method is passed by female dolphins to their daughters.
C
Male dolphins never use the sponging technique.
D
Three generations of sponging dolphins have been documented.
10.
Biologist Dr. Anna says that
A
sponging is very dangerous for dolphins.
B
dolphins do not inherit sponging method from their parents.
C
she has benn studying dolphins for a few decades now.
D
sponging can be a stable behaviour.
11.
With the computer simulation that modeled sponging, researchers
A
managed to find out approximately when sponging was originated.
B
were able to predict the behaviour of dolphins.
C
found out the true reason of sponging.
D
discovered a new way treating dolphins
12.
Accroding to Janet Mann
A
bottlenose dolphins have brain as big as humans have.
B
we can understand dolphins well now.
C
dolphins are very intellegent.
D
all of the above.

Choose the correct letter, A, B, C or D.$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('4303650a-53d4-5fba-becb-fd712853c609', '7c7b1624-6e1e-56e5-ab65-cb3de7040ed2', 10, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 10

Questions 8-12
Questions 8-12
Choose the correct letter,
A, B, C
or
D.
Write the correct letter in boxes 8-12 on your answer sheet.
8.
Dolphins use sponges for hunting fish because:
A
they like it.
B
it helps them get fish from the bottom of the ocean.
C
it makes hunting easier.
D
it helps them to get more fish during the hunt.
9.
All the following statements about dolphins are true,
EXCEPT
:
A
Females discovered the method of hunting with sponges.
B
The sponging method is passed by female dolphins to their daughters.
C
Male dolphins never use the sponging technique.
D
Three generations of sponging dolphins have been documented.
10.
Biologist Dr. Anna says that
A
sponging is very dangerous for dolphins.
B
dolphins do not inherit sponging method from their parents.
C
she has benn studying dolphins for a few decades now.
D
sponging can be a stable behaviour.
11.
With the computer simulation that modeled sponging, researchers
A
managed to find out approximately when sponging was originated.
B
were able to predict the behaviour of dolphins.
C
found out the true reason of sponging.
D
discovered a new way treating dolphins
12.
Accroding to Janet Mann
A
bottlenose dolphins have brain as big as humans have.
B
we can understand dolphins well now.
C
dolphins are very intellegent.
D
all of the above.

Choose the correct letter, A, B, C or D.$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('07f63bcb-63c7-5125-80ce-402b3ff36092', '7c7b1624-6e1e-56e5-ab65-cb3de7040ed2', 11, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 11

Questions 8-12
Questions 8-12
Choose the correct letter,
A, B, C
or
D.
Write the correct letter in boxes 8-12 on your answer sheet.
8.
Dolphins use sponges for hunting fish because:
A
they like it.
B
it helps them get fish from the bottom of the ocean.
C
it makes hunting easier.
D
it helps them to get more fish during the hunt.
9.
All the following statements about dolphins are true,
EXCEPT
:
A
Females discovered the method of hunting with sponges.
B
The sponging method is passed by female dolphins to their daughters.
C
Male dolphins never use the sponging technique.
D
Three generations of sponging dolphins have been documented.
10.
Biologist Dr. Anna says that
A
sponging is very dangerous for dolphins.
B
dolphins do not inherit sponging method from their parents.
C
she has benn studying dolphins for a few decades now.
D
sponging can be a stable behaviour.
11.
With the computer simulation that modeled sponging, researchers
A
managed to find out approximately when sponging was originated.
B
were able to predict the behaviour of dolphins.
C
found out the true reason of sponging.
D
discovered a new way treating dolphins
12.
Accroding to Janet Mann
A
bottlenose dolphins have brain as big as humans have.
B
we can understand dolphins well now.
C
dolphins are very intellegent.
D
all of the above.

Choose the correct letter, A, B, C or D.$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('5404dc3a-b31f-5ce7-85fe-1d3ec131aa9c', '7c7b1624-6e1e-56e5-ab65-cb3de7040ed2', 12, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 12

Questions 8-12
Questions 8-12
Choose the correct letter,
A, B, C
or
D.
Write the correct letter in boxes 8-12 on your answer sheet.
8.
Dolphins use sponges for hunting fish because:
A
they like it.
B
it helps them get fish from the bottom of the ocean.
C
it makes hunting easier.
D
it helps them to get more fish during the hunt.
9.
All the following statements about dolphins are true,
EXCEPT
:
A
Females discovered the method of hunting with sponges.
B
The sponging method is passed by female dolphins to their daughters.
C
Male dolphins never use the sponging technique.
D
Three generations of sponging dolphins have been documented.
10.
Biologist Dr. Anna says that
A
sponging is very dangerous for dolphins.
B
dolphins do not inherit sponging method from their parents.
C
she has benn studying dolphins for a few decades now.
D
sponging can be a stable behaviour.
11.
With the computer simulation that modeled sponging, researchers
A
managed to find out approximately when sponging was originated.
B
were able to predict the behaviour of dolphins.
C
found out the true reason of sponging.
D
discovered a new way treating dolphins
12.
Accroding to Janet Mann
A
bottlenose dolphins have brain as big as humans have.
B
we can understand dolphins well now.
C
dolphins are very intellegent.
D
all of the above.

Choose the correct letter, A, B, C or D.$md$, NULL);

COMMIT;
