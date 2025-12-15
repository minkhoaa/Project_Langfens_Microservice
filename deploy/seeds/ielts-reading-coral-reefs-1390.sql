BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-coral-reefs-1390'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-coral-reefs-1390';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-coral-reefs-1390';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-coral-reefs-1390';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('50843752-1f5e-5b0b-987a-62a6ddf9919c', 'ielts-reading-coral-reefs-1390', $t$Coral reefs$t$, $md$## Coral reefs

Nguồn:
- Test: https://mini-ielts.com/1390/reading/coral-reefs
- Solution: https://mini-ielts.com/1390/view-solution/reading/coral-reefs$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('95f690d7-7700-5c9a-b768-23b6c82d7c7d', '50843752-1f5e-5b0b-987a-62a6ddf9919c', 1, $t$Reading — Coral reefs$t$, $md$Read the passage and answer questions **1–13**.

### Passage: Coral reefs

Coral reefs are underwater structures made from calcium carbonate secreted by corals. Coral reefs are colonies of tiny living animals found in marine waters that contain few nutrients. Most coral reefs are built from stony corals, which in turn consist of polyps that cluster in groups.

A

Coral reefs are estimated to cover 284,300 km2 just under 0.1% of the oceans‘ surface area, about half the area of France. The Indo-Pacific region accounts for 91.9% of this total area. Southeast Asia accounts for 32.3% of that figure, while the Pacific including Australia accounts for 40.8%. Atlantic and Caribbean coral reefs account for 7.6%. Yet often called ―rainforests of the sea‖, coral reefs form some of the most diverse ecosystems on Earth. They provide a home for 25% of all marine species, including fish, mollusks worms, crustaceans, echinoderms, sponges, tunicates and other cnidarians. Paradoxically, coral reefs flourish even though they are surrounded by ocean waters that provide few nutrients. They are most commonly found at shallow depths in tropical waters, but deep water and cold water corals also exist on smaller scales in other areas. Although corals exist both in temperate and tropical waters, shallow-water reefs form only in a zone extending from 30°N to 30°S of the equator. Deepwater coral can exist at greater depths and colder temperatures at much higher latitudes, as far north as Norway. Coral reefs are rare along the American and African west coasts. This is due primarily to upwelling and strong cold coastal currents that reduce water temperatures in these areas (respectively the Peru, Benguela and Canary streams). Corals are seldom found along the coastline of South Asia from the eastern tip of India (Madras) to the Bangladesh and Myanmar borders. They are also rare along the coast around northeastern South America and Bangladesh due to the freshwater released from the Amazon and Ganges Rivers, respectively.

B

Coral reefs deliver ecosystem services to tourism, fisheries and coastline protection. The global economic value of coral reefs has been estimated at as much as $US375 billion per year. Coral reefs protect shorelines by absorbing wave energy, and many small islands would not exist without their reef to protect them.

C

The value of reefs in biodiverse regions can be even higher. In parts of Indonesia and the Caribbean where tourism is the main use, reefs are estimated to be worth US$1 million per square kilometer, based on the cost of maintaining sandy beaches and the value of attracting snorkelers and scuba divers. Meanwhile, a recent study of the Great Barrier Reef in Australia found that the reef is worth more to the country as an intact ecosystem than an extractive reserve for fishing. Each year more than 1.8 million tourists visit the reef, spending an estimated AU$4.3 billion (Australian dollars) on reef-related industries from diving to boat rental to posh island resort stays. In the Caribbean, says UNEP, the net annual benefits from diver tourism were US$2 billion in 2000 with US$625 million spent directly on diving on reefs. Further, reef tourism is an important source of employment, especially for some of the world‘s poorest people. UNEP says that of the estimated 30 million small-scale fishers in the developing world, most are dependent to a greater or lesser extent on coral reefs. In the Philippines, for example, more than one million small-scale fishers depend directly on coral reefs for their livelihoods. The report estimates that reef fisheries were worth between $15,000 and $150,000 per square kilometer a year, while fish caught for aquariums were worth $500 a kilogram against $6 for fish caught as food. The aquarium fish export industry supports around 50,000 people and generates some US$5.5 million a year in Sri Lanka along.

D

Unfortunately, coral reefs are dying around the world. In particular, coral mining, agricultural and urban runoff, pollution (organic and inorganic), disease, and the digging of canals and access into islands and bays are localized threats to coral ecosystems. Broader threats are sea temperature rise, sea-level rise and pH changes from ocean acidification, all associated with greenhouse gas emissions. Some current fishing practices are destructive and unsustainable. These include cyanide fishing, overfishing and blast fishing. Although cyanide fishing supplies live reef fish for the tropical aquarium market, most fish caught using this method are sold in restaurants, primarily in Asia, where live fish are prized for their freshness. To catch fish with cyanide, fishers dive down to the reef and squirt cyanide in coral crevices and on the fast-moving fish, to stun the fish making them easy to catch. Overfishing is another leading cause for coral reef degradation. Often, too many fish are taken from one reef to sustain a population in that area. Poor fishing practices, such as banging on the reef with sticks (muro-ami), destroy coral formations that normally function as fish habitat. In some instances, people fish with explosives (blast fishing), which blast apart the surrounding coral.

E

Tourist resorts that empty their sewage directly into the water surrounding coral reefs contribute to coral reef degradation. Wastes kept in poorly maintained septic tanks can also leak into surrounding groundwater, eventually seeping out to the reefs. Careless boating, diving, snorkeling and fishing can also damage coral reefs. Whenever people grab, kick, and walk on, or stir up sediment in the reefs, they contribute to coral reef destruction. Corals are also harmed or killed when people drop anchors on them or when people collect coral.

F

To find answers for these problems, scientists and researchers study the various factors that impact reefs. The list includes the ocean‘s role as a carbon dioxide sink, atmospheric changes, ultraviolet light, ocean acidification, viruses, impacts of dust storms carrying agents to far-flung reefs, pollutants, algal blooms and others. Reefs are threatened well beyond coastal areas. General estimates show approximately 10% of the worlds coral reefs are dead. About 60% of the world‘s reefs are at risk due to destructive, human-related activities. The threat to the health of reefs is particularly strong in Southeast Asia, where 80% of reefs are endangered.

G

In Australia, the Great Barrier Reef is protected by the Great Barrier Reef Marine Park Authority and is the subject of much legislation, including a biodiversity action plan. Inhabitants of Ahus Island, Manus Province, Papua New Guinea, have followed a generations-old practice of restricting fishing in six areas of their reef lagoon. Their cultural traditions allow line fishing, but not net or spearfishing. The result is both the biomass and individual fish sizes are significantly larger in these areas than in places where fishing is unrestricted.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('6985b667-9cb2-53e4-931c-36ecdb719cd5', '95f690d7-7700-5c9a-b768-23b6c82d7c7d', 1, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 1

Questions 1-6
Questions 1-6
The reading Passage has seven paragraphs
A-G
.
Which paragraph contains the following information?
Write the correct letter
A-G
, in boxes
1-6
on your answer sheet.
NB
You may use any letter more than once.
1
Geographical Location of the world‘s coral reef
2
How does coral reef benefit economy locally
3
The statistics of coral reef‘s economic significance
4
The listed reasons for the declining number of coral reef
5
Physical approach to the coral reef by people
6
Unsustainable fishing methods are applied in regions of the world

1 ____ Geographical Location of the world‘s coral reef$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('96ecbaaf-810e-5834-a380-6af6f757618f', '6985b667-9cb2-53e4-931c-36ecdb719cd5', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7d9cdaa6-2ffc-5952-81f4-88edcf4eafdb', '6985b667-9cb2-53e4-931c-36ecdb719cd5', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d4ad2ca9-17df-5e91-8d9b-d96bfbc02ca0', '6985b667-9cb2-53e4-931c-36ecdb719cd5', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('43bd0904-e752-516b-b2ba-56180a6791f3', '6985b667-9cb2-53e4-931c-36ecdb719cd5', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2dd12125-d34a-5eaa-bc22-c57ca13a9627', '6985b667-9cb2-53e4-931c-36ecdb719cd5', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('676f0915-e2ff-5c04-8aab-23ce34894435', '6985b667-9cb2-53e4-931c-36ecdb719cd5', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('62fa38df-eb17-59b8-8220-b191facdbfee', '6985b667-9cb2-53e4-931c-36ecdb719cd5', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('f5c8b98e-4943-5209-a917-ee122b8590d1', '95f690d7-7700-5c9a-b768-23b6c82d7c7d', 2, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 2

Questions 1-6
Questions 1-6
The reading Passage has seven paragraphs
A-G
.
Which paragraph contains the following information?
Write the correct letter
A-G
, in boxes
1-6
on your answer sheet.
NB
You may use any letter more than once.
1
Geographical Location of the world‘s coral reef
2
How does coral reef benefit economy locally
3
The statistics of coral reef‘s economic significance
4
The listed reasons for the declining number of coral reef
5
Physical approach to the coral reef by people
6
Unsustainable fishing methods are applied in regions of the world

2 ____ How does coral reef benefit economy locally$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('13a3ea55-6031-5180-a980-42edd09fb24e', 'f5c8b98e-4943-5209-a917-ee122b8590d1', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3c98fbb1-7d6a-5d41-914d-8c608b09c4cc', 'f5c8b98e-4943-5209-a917-ee122b8590d1', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('252ede4a-e4a1-50fd-a3dc-c04e3f187dd5', 'f5c8b98e-4943-5209-a917-ee122b8590d1', 3, $md$C$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e8758816-82fb-5063-b628-3e2f7cbccbd6', 'f5c8b98e-4943-5209-a917-ee122b8590d1', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5a77b66e-437b-51f9-b7ba-710a106e5775', 'f5c8b98e-4943-5209-a917-ee122b8590d1', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9a5d2223-1a3f-5bf1-a14c-999273629a04', 'f5c8b98e-4943-5209-a917-ee122b8590d1', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('095131bc-48e3-5c6a-88a1-f7ffc6c81b98', 'f5c8b98e-4943-5209-a917-ee122b8590d1', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('0de7be07-c0e8-5a47-9edf-8750aecdc298', '95f690d7-7700-5c9a-b768-23b6c82d7c7d', 3, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 3

Questions 1-6
Questions 1-6
The reading Passage has seven paragraphs
A-G
.
Which paragraph contains the following information?
Write the correct letter
A-G
, in boxes
1-6
on your answer sheet.
NB
You may use any letter more than once.
1
Geographical Location of the world‘s coral reef
2
How does coral reef benefit economy locally
3
The statistics of coral reef‘s economic significance
4
The listed reasons for the declining number of coral reef
5
Physical approach to the coral reef by people
6
Unsustainable fishing methods are applied in regions of the world

3 ____ The statistics of coral reef‘s economic significance$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('261d7eb7-1adf-58b6-ad4c-f57701322398', '0de7be07-c0e8-5a47-9edf-8750aecdc298', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('69f64b93-714f-51e2-8614-37d78b792773', '0de7be07-c0e8-5a47-9edf-8750aecdc298', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('48b63cb6-157d-5a01-ba9f-7d91743393b2', '0de7be07-c0e8-5a47-9edf-8750aecdc298', 3, $md$C$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('37825678-6b3f-51a1-a4b3-59a5ea1e557c', '0de7be07-c0e8-5a47-9edf-8750aecdc298', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('79cffb8d-d279-5a3d-ab96-369d5f848314', '0de7be07-c0e8-5a47-9edf-8750aecdc298', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ea9ee6a7-3a36-5455-be0d-52dd0df97397', '0de7be07-c0e8-5a47-9edf-8750aecdc298', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cc8cd7ce-00f3-5818-a31b-c8d10f17b330', '0de7be07-c0e8-5a47-9edf-8750aecdc298', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('d5028008-bdea-5954-b55b-67f925e21bf9', '95f690d7-7700-5c9a-b768-23b6c82d7c7d', 4, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 4

Questions 1-6
Questions 1-6
The reading Passage has seven paragraphs
A-G
.
Which paragraph contains the following information?
Write the correct letter
A-G
, in boxes
1-6
on your answer sheet.
NB
You may use any letter more than once.
1
Geographical Location of the world‘s coral reef
2
How does coral reef benefit economy locally
3
The statistics of coral reef‘s economic significance
4
The listed reasons for the declining number of coral reef
5
Physical approach to the coral reef by people
6
Unsustainable fishing methods are applied in regions of the world

4 ____ The listed reasons for the declining number of coral reef$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('708e9fff-80ae-54fb-84b5-2ac076c880cc', 'd5028008-bdea-5954-b55b-67f925e21bf9', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('018f72ce-4a4e-5cc8-84b1-29b5a74f4975', 'd5028008-bdea-5954-b55b-67f925e21bf9', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f976d418-f03a-50a4-8316-0998f6fe3752', 'd5028008-bdea-5954-b55b-67f925e21bf9', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('626d3159-91f0-5dd9-8c15-488ba6627805', 'd5028008-bdea-5954-b55b-67f925e21bf9', 4, $md$D$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4bbc9fe6-2eec-5fa1-82ca-09b9e05abbc0', 'd5028008-bdea-5954-b55b-67f925e21bf9', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fb1ed439-3fcd-5025-9b39-6f183a13b339', 'd5028008-bdea-5954-b55b-67f925e21bf9', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('73687ffa-b2f9-5a8e-833b-5e22b7e9ea44', 'd5028008-bdea-5954-b55b-67f925e21bf9', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('5ef56ee4-2b91-5226-88d5-e0a3fc7a07ab', '95f690d7-7700-5c9a-b768-23b6c82d7c7d', 5, 'MATCHING_INFORMATION', 'READING', 3, $md$### Question 5

Questions 1-6
Questions 1-6
The reading Passage has seven paragraphs
A-G
.
Which paragraph contains the following information?
Write the correct letter
A-G
, in boxes
1-6
on your answer sheet.
NB
You may use any letter more than once.
1
Geographical Location of the world‘s coral reef
2
How does coral reef benefit economy locally
3
The statistics of coral reef‘s economic significance
4
The listed reasons for the declining number of coral reef
5
Physical approach to the coral reef by people
6
Unsustainable fishing methods are applied in regions of the world

5 ____ Physical approach to the coral reef by people$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ef996fa4-71b4-5b67-872d-6da14c688b21', '5ef56ee4-2b91-5226-88d5-e0a3fc7a07ab', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('873c87d7-ba60-5a35-8bb7-737d05c53044', '5ef56ee4-2b91-5226-88d5-e0a3fc7a07ab', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('663624cd-b2fa-5c79-ac88-f2fd19f16691', '5ef56ee4-2b91-5226-88d5-e0a3fc7a07ab', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('da6392ce-0e75-5f90-8999-6aa5aa6bef25', '5ef56ee4-2b91-5226-88d5-e0a3fc7a07ab', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8ef092c1-4f1a-5348-9406-7a6071be0141', '5ef56ee4-2b91-5226-88d5-e0a3fc7a07ab', 5, $md$E$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('16adfd1d-d343-5f11-87b0-d013dc1924a6', '5ef56ee4-2b91-5226-88d5-e0a3fc7a07ab', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('be48efcd-fb64-55ea-99dc-f71cffc13de5', '5ef56ee4-2b91-5226-88d5-e0a3fc7a07ab', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('23bb402a-d145-580b-ae8b-965ae950a19b', '95f690d7-7700-5c9a-b768-23b6c82d7c7d', 6, 'MATCHING_INFORMATION', 'READING', 3, $md$### Question 6

Questions 1-6
Questions 1-6
The reading Passage has seven paragraphs
A-G
.
Which paragraph contains the following information?
Write the correct letter
A-G
, in boxes
1-6
on your answer sheet.
NB
You may use any letter more than once.
1
Geographical Location of the world‘s coral reef
2
How does coral reef benefit economy locally
3
The statistics of coral reef‘s economic significance
4
The listed reasons for the declining number of coral reef
5
Physical approach to the coral reef by people
6
Unsustainable fishing methods are applied in regions of the world

6 ____ Unsustainable fishing methods are applied in regions of the world$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5f20d9b2-3d8d-593e-914e-7ad40e2ff709', '23bb402a-d145-580b-ae8b-965ae950a19b', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8dc96c4c-e231-5817-ac3f-2e6c669e64af', '23bb402a-d145-580b-ae8b-965ae950a19b', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ee1ac1e0-e1f5-597d-9fcf-cf7266e85a3f', '23bb402a-d145-580b-ae8b-965ae950a19b', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('98a0d70c-1d88-5ea4-8444-facd91f9b8c1', '23bb402a-d145-580b-ae8b-965ae950a19b', 4, $md$D$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('896484e8-890c-50ac-a64f-983e1e13ce80', '23bb402a-d145-580b-ae8b-965ae950a19b', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4d721e22-1564-5c30-a368-e5799d149e77', '23bb402a-d145-580b-ae8b-965ae950a19b', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5a6bda48-ec3f-5baf-8d6f-5f156a0364a1', '23bb402a-d145-580b-ae8b-965ae950a19b', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('feb1bdcb-c9a2-5a3e-a742-5d778130bbbd', '95f690d7-7700-5c9a-b768-23b6c82d7c7d', 7, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 7

Questions 7-12
Questions 7-12
Do the following statements agree with the information given in
Reading Passage
?
Write your answers in boxes
7-12
on your answer sheet.
TRUE
if the statement is true
FALSE
if the statement is false
NOT GIVEN
if the information is not given in the passage
7
Coral reefs provide habitat to a variety of marine life.
8
Coral reef distributes around the ocean disproportionally.
9
Coral reef is increasingly important for scientific purpose.
10
Coral reefs are greatly exchanged among and exported to other counties.
11
Reef tourism is of economic essence generally for some poor people.
12
As with other fishing business, coral fishery is not suitable to women and children.

7 ____ Coral reefs provide habitat to a variety of marine life.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cb1d9c37-520b-5f2e-9f0c-9b29c4424053', 'feb1bdcb-c9a2-5a3e-a742-5d778130bbbd', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0784e471-7125-50f8-8b78-3011a5215e93', 'feb1bdcb-c9a2-5a3e-a742-5d778130bbbd', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1076c94c-d7bb-51e4-9ae7-f9c0cdfc4a69', 'feb1bdcb-c9a2-5a3e-a742-5d778130bbbd', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('77da485e-9cd8-521d-af4c-b728c859102d', '95f690d7-7700-5c9a-b768-23b6c82d7c7d', 8, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 8

Questions 7-12
Questions 7-12
Do the following statements agree with the information given in
Reading Passage
?
Write your answers in boxes
7-12
on your answer sheet.
TRUE
if the statement is true
FALSE
if the statement is false
NOT GIVEN
if the information is not given in the passage
7
Coral reefs provide habitat to a variety of marine life.
8
Coral reef distributes around the ocean disproportionally.
9
Coral reef is increasingly important for scientific purpose.
10
Coral reefs are greatly exchanged among and exported to other counties.
11
Reef tourism is of economic essence generally for some poor people.
12
As with other fishing business, coral fishery is not suitable to women and children.

8 ____ Coral reef distributes around the ocean disproportionally.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('938b6ad1-9cbf-598f-8063-e502430f7d3f', '77da485e-9cd8-521d-af4c-b728c859102d', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3a334d76-e079-5cd4-8efd-b142d861eeb9', '77da485e-9cd8-521d-af4c-b728c859102d', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f5a7c9c6-3aae-5821-b573-f00f97c5e73b', '77da485e-9cd8-521d-af4c-b728c859102d', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('b26b156a-b49c-52b8-a9c4-e73ddec8b94e', '95f690d7-7700-5c9a-b768-23b6c82d7c7d', 9, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 9

Questions 7-12
Questions 7-12
Do the following statements agree with the information given in
Reading Passage
?
Write your answers in boxes
7-12
on your answer sheet.
TRUE
if the statement is true
FALSE
if the statement is false
NOT GIVEN
if the information is not given in the passage
7
Coral reefs provide habitat to a variety of marine life.
8
Coral reef distributes around the ocean disproportionally.
9
Coral reef is increasingly important for scientific purpose.
10
Coral reefs are greatly exchanged among and exported to other counties.
11
Reef tourism is of economic essence generally for some poor people.
12
As with other fishing business, coral fishery is not suitable to women and children.

9 ____ Coral reef is increasingly important for scientific purpose.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7fdaed9c-53fa-570d-bb3f-fd0a064534b9', 'b26b156a-b49c-52b8-a9c4-e73ddec8b94e', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a7aead55-af95-5d18-a91d-58223ba14bfa', 'b26b156a-b49c-52b8-a9c4-e73ddec8b94e', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('40fea10a-ccfc-59f6-ab6a-e44d992f6e1e', 'b26b156a-b49c-52b8-a9c4-e73ddec8b94e', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('8dd0df5e-2871-5fe7-a7f5-2bf99caf413e', '95f690d7-7700-5c9a-b768-23b6c82d7c7d', 10, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 10

Questions 7-12
Questions 7-12
Do the following statements agree with the information given in
Reading Passage
?
Write your answers in boxes
7-12
on your answer sheet.
TRUE
if the statement is true
FALSE
if the statement is false
NOT GIVEN
if the information is not given in the passage
7
Coral reefs provide habitat to a variety of marine life.
8
Coral reef distributes around the ocean disproportionally.
9
Coral reef is increasingly important for scientific purpose.
10
Coral reefs are greatly exchanged among and exported to other counties.
11
Reef tourism is of economic essence generally for some poor people.
12
As with other fishing business, coral fishery is not suitable to women and children.

10 ____ Coral reefs are greatly exchanged among and exported to other counties.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e3f36341-a7cc-5265-9631-8ae1fe2d2e83', '8dd0df5e-2871-5fe7-a7f5-2bf99caf413e', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9edaf314-6370-518f-965d-dbf2cc9f4201', '8dd0df5e-2871-5fe7-a7f5-2bf99caf413e', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3134df54-8281-5413-a433-5f2a24a82073', '8dd0df5e-2871-5fe7-a7f5-2bf99caf413e', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('ffaeb85d-c89e-592f-a53f-05c2e22ed63b', '95f690d7-7700-5c9a-b768-23b6c82d7c7d', 11, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 11

Questions 7-12
Questions 7-12
Do the following statements agree with the information given in
Reading Passage
?
Write your answers in boxes
7-12
on your answer sheet.
TRUE
if the statement is true
FALSE
if the statement is false
NOT GIVEN
if the information is not given in the passage
7
Coral reefs provide habitat to a variety of marine life.
8
Coral reef distributes around the ocean disproportionally.
9
Coral reef is increasingly important for scientific purpose.
10
Coral reefs are greatly exchanged among and exported to other counties.
11
Reef tourism is of economic essence generally for some poor people.
12
As with other fishing business, coral fishery is not suitable to women and children.

11 ____ Reef tourism is of economic essence generally for some poor people.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c0a6c4ad-34a6-57d6-a00c-c7aadb7be1d6', 'ffaeb85d-c89e-592f-a53f-05c2e22ed63b', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a1c9e4b1-1a16-5bc1-b5c7-e85f8a951193', 'ffaeb85d-c89e-592f-a53f-05c2e22ed63b', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('61243447-b1d2-5bc5-8801-e404924080d8', 'ffaeb85d-c89e-592f-a53f-05c2e22ed63b', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('97033af3-9151-5a91-b8bb-851563b9b28b', '95f690d7-7700-5c9a-b768-23b6c82d7c7d', 12, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 12

Questions 7-12
Questions 7-12
Do the following statements agree with the information given in
Reading Passage
?
Write your answers in boxes
7-12
on your answer sheet.
TRUE
if the statement is true
FALSE
if the statement is false
NOT GIVEN
if the information is not given in the passage
7
Coral reefs provide habitat to a variety of marine life.
8
Coral reef distributes around the ocean disproportionally.
9
Coral reef is increasingly important for scientific purpose.
10
Coral reefs are greatly exchanged among and exported to other counties.
11
Reef tourism is of economic essence generally for some poor people.
12
As with other fishing business, coral fishery is not suitable to women and children.

12 ____ As with other fishing business, coral fishery is not suitable to women and children.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('67506d7e-9f81-5075-beab-3e5eda5412b6', '97033af3-9151-5a91-b8bb-851563b9b28b', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e4c0a382-0dd1-5569-8244-28bf78215744', '97033af3-9151-5a91-b8bb-851563b9b28b', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b6d0ee0c-74f2-5a6e-9474-8602e87dcf55', '97033af3-9151-5a91-b8bb-851563b9b28b', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('0862707f-f1df-5bcd-bd43-cb3af57f619c', '95f690d7-7700-5c9a-b768-23b6c82d7c7d', 13, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 13

Question 13
Question 13
Choose the correct letter,
A
，
B
，
C or D.
Write your answers in boxes
13
on your answer sheet.
What is the main purpose of this passage?
A
Demonstrate how coral reef growth in the ocean
B
To tell that coral reef is widely used as a scientific project
C
Present the general benefits and an alarming situation of coral reef
D
To show the vital efforts made to protect the coral reef in Australia

Choose the correct letter, A ， B ， C or D.$md$, NULL);

COMMIT;
