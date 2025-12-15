BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-australias-megafauna-controversy--1453'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-australias-megafauna-controversy--1453';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-australias-megafauna-controversy--1453';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-australias-megafauna-controversy--1453';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('5682bcc7-6b51-5b39-a3e5-896f9ad9d299', 'ielts-reading-australias-megafauna-controversy--1453', $t$Australia's Megafauna Controversy$t$, $md$## Australia's Megafauna Controversy

Nguồn:
- Test: https://mini-ielts.com/1453/reading/australias-megafauna-controversy-
- Solution: https://mini-ielts.com/1453/view-solution/reading/australias-megafauna-controversy-$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('03e04f16-1bb3-5809-b003-534f1d145deb', '5682bcc7-6b51-5b39-a3e5-896f9ad9d299', 1, $t$Reading — Australia's Megafauna Controversy$t$, $md$Read the passage and answer questions **1–14**.

### Passage: Australia's Megafauna Controversy

Just how long did humans live side by side with megafauna in Australia? Barry Brook, Richard Gillespie and Paul Martin dispute previous claims of a lengthy coexistence

Over the past 50 millennia, Australia has witnessed the extinction of many species of large animals, including a rhinoceros-sized wombat and goannas the size of crocodiles Debate about the possible cause of these extinctions has continued for more than 150 years and one the crucial questions raised is how long humans and megafauna coexisted in Australia. We need to know the overlap of time to make an informed choice between the two main theories regarding the causes of these extinctions. If humans and megafauna coexisted for a protracted period then climate change is the more likely cause. However, if the megafauna became extinct shortly after the arrival of humans, then humans are the likely culprits

The archaeological site at Cuddie Springs in eastern Australia appears to be well preserved. This dusty claypan holds within its sediments a rich cache of flaked stone and seed-grinding tools, and side by side with these clear signals of human culture are the bones of a dozen or more species of megafauna. Drs Judith Field and Stephen Wroe of the University of Sydney, who excavated the site, claim that it provides unequivocal evidence of a long overlap of humans and megafauna, and conclude that aridity leading up to the last Ice Age brought about their eventual demise. In the long-standing explanation of this site, artefacts such as stone tools and extinct animals remain were deposited over many thousands of years in an ephemeral lake- a body of water existing for a relatively short time - and remained in place and undisturbed until the present day.

There is no disputing the close association of bones and stones at Cuddie Springs, as both are found 1 to 1.7 metres below the modern surface. The dating of these layers is accurate: ages for the sediments were obtained through radiocarbon dating of charcoal fragments and luminescence dating of sand grains from the same levels (revealing when a sample was last exposed to sunlight). Intriguingly, some of the stone show surface features indicating their use for processing plants, and a few even have well-preserved blood and hair residues suggesting they were used in butchering animals.

But is the case proposed by Field aside Wroe clear-cut? We carried out a reanalyse of the scientific data from Cuddie Springs that brings into question their conclusions. The amount of anthropological evidence found at the site is remarkable: we estimate there are more than 3 tonnes of charcoal and more than 300 tonnes of stone buried there. Field and Wroe estimate that there are approximately 20 million artefacts. This plethora of tools is hard to reconcile with a site that was only available for occupation when the lake was dry. Furthermore, no cultural features such as oven pits have been discovered. If the sediment layers have remained undisturbed since being laid down, as Field and Wroe contend, then the ages of those sediments should increase with depth. However, our analysis revealed a number of inconsistencies.

First, the charcoal samples are all roughly 36,000 years old. Second, sand in the two upper levels is considerably younger than charcoal from the same levels. Third, Field and Wroe say that the tools and seed-grinding stones used for plant and animal processing are accient, yet they are very similar to implements found elsewhere that were in use only a few thousand years ago. Also interest is the fact that a deep drill core made a mere 60 metres from the site recovered no stone artefact or fossil bones whatsoever. These points suggests strongly that the sediments have been moved about and some of the old charcoal has been re-deposited in younger layers. Indeed, one sample of cow bone found I metre below the surface came from sediments where charcoal dated at 6,000 and 23,000 years old is mixed with 17,000-year-old sand. The megafauna bones themselves have not yet dated, although new technological developments make this a possibility in the near future.

We propose that the archaeologists have actually been sampling the debris carried by ancient flood channels beneath the site, including charcoal transported from bushfires that intermittently occurred within the catchment. Flood events more likely explain the accumulation of megafauna remains, and could have mixed old bones With fresh deposits. European graziers also disturbed the site in 1876 by constructing a well to provide water their cattle. Given the expense of well-digging, we speculate that the graziers made sure it was protected from the damage caused by cattle hooves by lining the surface with small stones collected from further afield, including prehistoric quarries. This Idea Is consistent with the thin layer of stones spread over a large area, with cattle occasionally breaking through the gravel surface and forcing the stone and even cattle bones deeper into the waterlogged soil.

The lack of conclusive evidence that humans and megafauna coexisted for a lengthy period casts doubt on Field and Wroe's assertion that climate change was responsible for the extinction of Australia's megafauna. However, we do not suggest that newly arrived, well-armed hunters systematically slaughtered all the large beasts they encountered. Recent studies based on the biology of modern-day large

Mammals, combined with observations of people who still practise a traditional hunter­gatherer lifestyle, reveal an unexpected paradox and suggest a further possible explanation as to what happened. Using a mathematical model, It was found that a group of 10 people killing only one juvenile Diprotodon each year would be sufficient to bring about the extinction of that spaces within 1,000 years. This suggests that here, as in other parts of the word, the arrival of humans in lands previously inhabited only by animals created a volatile combination in which large animals fared badly.

Note: The Diprotodon (a rhinoceros-sized wombat), an example of Australia’s now extinct megafauna$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('4d796a41-3f09-5c13-b142-df214df0f28d', '03e04f16-1bb3-5809-b003-534f1d145deb', 1, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 1

Questions 1-4
Questions 1-4
Do the following statements agree with the claims of the writer in Reading Passage? In boxes 1-4 on your answer sheet, write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
1
Field and Wroe argue that findings at the Cuddie Springs site show that people lived in this area at the same time as megafauna.
2
Field and Wroe believe it is likely that smaller megafauna species survived the last Ice Age
3
The writers believe that the dating of earth up to 1.7m below the present surface at Cuddie Springs is unreliable.
4
Some artefacts found at Cuddie Springs were preserved well enough to reveal their function

1 ____ Field and Wroe argue that findings at the Cuddie Springs site show that people lived in this area at the same time as megafauna.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('35036a99-d27f-58ce-a47c-8449d1c9eeba', '4d796a41-3f09-5c13-b142-df214df0f28d', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('57c815ca-dedc-586b-8515-9effb277ffee', '4d796a41-3f09-5c13-b142-df214df0f28d', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b6e314dd-1cc1-5603-a7f2-b146bc53f30f', '4d796a41-3f09-5c13-b142-df214df0f28d', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('6cc58ffc-16e6-585f-8833-97d506f1b182', '03e04f16-1bb3-5809-b003-534f1d145deb', 2, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 2

Questions 1-4
Questions 1-4
Do the following statements agree with the claims of the writer in Reading Passage? In boxes 1-4 on your answer sheet, write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
1
Field and Wroe argue that findings at the Cuddie Springs site show that people lived in this area at the same time as megafauna.
2
Field and Wroe believe it is likely that smaller megafauna species survived the last Ice Age
3
The writers believe that the dating of earth up to 1.7m below the present surface at Cuddie Springs is unreliable.
4
Some artefacts found at Cuddie Springs were preserved well enough to reveal their function

2 ____ Field and Wroe believe it is likely that smaller megafauna species survived the last Ice Age$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bbf45b58-0479-539f-a3b6-a98dc85de6f5', '6cc58ffc-16e6-585f-8833-97d506f1b182', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0da09443-4e72-5ed7-b681-75d7ff896187', '6cc58ffc-16e6-585f-8833-97d506f1b182', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b00c8910-ece7-561b-83b9-64fc3453d378', '6cc58ffc-16e6-585f-8833-97d506f1b182', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('e4eb5361-5808-5141-9875-a02a36072df8', '03e04f16-1bb3-5809-b003-534f1d145deb', 3, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 3

Questions 1-4
Questions 1-4
Do the following statements agree with the claims of the writer in Reading Passage? In boxes 1-4 on your answer sheet, write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
1
Field and Wroe argue that findings at the Cuddie Springs site show that people lived in this area at the same time as megafauna.
2
Field and Wroe believe it is likely that smaller megafauna species survived the last Ice Age
3
The writers believe that the dating of earth up to 1.7m below the present surface at Cuddie Springs is unreliable.
4
Some artefacts found at Cuddie Springs were preserved well enough to reveal their function

3 ____ The writers believe that the dating of earth up to 1.7m below the present surface at Cuddie Springs is unreliable.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e3142dfb-cacf-5c20-9ba8-c0a4e7b3d4df', 'e4eb5361-5808-5141-9875-a02a36072df8', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7ff12360-6e5c-5b8e-bd6f-afcdc69e68f6', 'e4eb5361-5808-5141-9875-a02a36072df8', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e4fca3d0-2c68-52bf-92ed-562363e865c7', 'e4eb5361-5808-5141-9875-a02a36072df8', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('2da80022-866e-5f1d-b872-e742d4612458', '03e04f16-1bb3-5809-b003-534f1d145deb', 4, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 4

Questions 1-4
Questions 1-4
Do the following statements agree with the claims of the writer in Reading Passage? In boxes 1-4 on your answer sheet, write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
1
Field and Wroe argue that findings at the Cuddie Springs site show that people lived in this area at the same time as megafauna.
2
Field and Wroe believe it is likely that smaller megafauna species survived the last Ice Age
3
The writers believe that the dating of earth up to 1.7m below the present surface at Cuddie Springs is unreliable.
4
Some artefacts found at Cuddie Springs were preserved well enough to reveal their function

4 ____ Some artefacts found at Cuddie Springs were preserved well enough to reveal their function$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f437ffba-2130-586e-88bc-79a8e6890af8', '2da80022-866e-5f1d-b872-e742d4612458', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('db09a3bd-58a9-5784-ac9b-4d29243423f8', '2da80022-866e-5f1d-b872-e742d4612458', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('90e7c188-03ce-5a54-821b-54a733d9e313', '2da80022-866e-5f1d-b872-e742d4612458', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('39c7ab8c-df34-5753-81df-2a7ae34d1720', '03e04f16-1bb3-5809-b003-534f1d145deb', 5, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 5

Questions 5-9
Questions 5-9
Complete the summary using the list of words, A-l, below
Write the correct letter, A-l in boxes 5-9 on your answer sheet
The writers’ arguments against Field and Wroe's analysis of the scientific data
from Cuddie Springs
One objection to Field and Wroe's interpretation is the large quantity of charcoal,
5
and artefacts found at Cuddie Springs. Such large numbers of artefacts would impossible if the area had been covered with
6
for a period. There is also a complete lack of man-made structures, for instance those used for
7
.
Other evidence that doubt on Field and Wroe’s claim is the fact that while some material in the highest levels of sediment is 36,000 years old, the
8
in the same levels is much more recent. The tools used to process plants and animals may also be newer than Field and Wroe believe. Further evidence against human occupation of the area is the absence of tools and
9
a short distance away.
A seeds
B stone
C sand
D cooking
E deep drill core
F water
G fossil bones
H sediment
I storage

One objection to Field and Wroe's interpretation is the large quantity of charcoal, 5 ____ and artefacts found at Cuddie Springs. Such large numbers of artefacts would impossible if the area had been covered with 6 ____ for a period. There is also a complete lack of man-made structures, for instance those used for 7 ____ .$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4a188ec0-f9bb-57b6-826d-6b2cf9b58f0f', '39c7ab8c-df34-5753-81df-2a7ae34d1720', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('58d45b3b-5d93-5c70-8382-07367dc5fefd', '39c7ab8c-df34-5753-81df-2a7ae34d1720', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0b562d4d-a48a-5291-aeb3-a06cb0f469df', '39c7ab8c-df34-5753-81df-2a7ae34d1720', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('10c24784-3ba7-526d-a803-be09ae776912', '39c7ab8c-df34-5753-81df-2a7ae34d1720', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('81c2d1c6-c60b-54fd-9646-36ec4f5523a7', '39c7ab8c-df34-5753-81df-2a7ae34d1720', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('258767a4-adf4-5287-a4f2-6fbd3d24b656', '39c7ab8c-df34-5753-81df-2a7ae34d1720', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('65dcf6c1-4ec6-560d-b985-8ed909c84a4e', '39c7ab8c-df34-5753-81df-2a7ae34d1720', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('738502fe-b9f2-5f93-9092-15c1562c60bf', '39c7ab8c-df34-5753-81df-2a7ae34d1720', 8, $md$H$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d70e267e-589b-5fa9-b057-4bfa663b5aca', '39c7ab8c-df34-5753-81df-2a7ae34d1720', 9, $md$I$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('b74ef4f9-8dcf-57c2-9dbc-b05a2675d192', '03e04f16-1bb3-5809-b003-534f1d145deb', 6, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 6

Questions 5-9
Questions 5-9
Complete the summary using the list of words, A-l, below
Write the correct letter, A-l in boxes 5-9 on your answer sheet
The writers’ arguments against Field and Wroe's analysis of the scientific data
from Cuddie Springs
One objection to Field and Wroe's interpretation is the large quantity of charcoal,
5
and artefacts found at Cuddie Springs. Such large numbers of artefacts would impossible if the area had been covered with
6
for a period. There is also a complete lack of man-made structures, for instance those used for
7
.
Other evidence that doubt on Field and Wroe’s claim is the fact that while some material in the highest levels of sediment is 36,000 years old, the
8
in the same levels is much more recent. The tools used to process plants and animals may also be newer than Field and Wroe believe. Further evidence against human occupation of the area is the absence of tools and
9
a short distance away.
A seeds
B stone
C sand
D cooking
E deep drill core
F water
G fossil bones
H sediment
I storage

One objection to Field and Wroe's interpretation is the large quantity of charcoal, 5 ____ and artefacts found at Cuddie Springs. Such large numbers of artefacts would impossible if the area had been covered with 6 ____ for a period. There is also a complete lack of man-made structures, for instance those used for 7 ____ .$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('555465ba-618b-5cbc-87e5-deba4214ab2e', 'b74ef4f9-8dcf-57c2-9dbc-b05a2675d192', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b58e3fc3-a62f-50b7-bd46-be7aa7930670', 'b74ef4f9-8dcf-57c2-9dbc-b05a2675d192', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3d58dd7a-7bbc-5820-8abd-0c9fe25e34c4', 'b74ef4f9-8dcf-57c2-9dbc-b05a2675d192', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a55276a8-baaa-5d4a-bda8-3fd7beda6fa7', 'b74ef4f9-8dcf-57c2-9dbc-b05a2675d192', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4252eba9-f9ea-5799-a8c9-54fe7c768ec0', 'b74ef4f9-8dcf-57c2-9dbc-b05a2675d192', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b55b85f6-b503-5579-9f25-e34c7150900d', 'b74ef4f9-8dcf-57c2-9dbc-b05a2675d192', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('71a39efd-9e6a-5cae-ad02-eb0fb58137c7', 'b74ef4f9-8dcf-57c2-9dbc-b05a2675d192', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3e469c99-1a4f-5ace-84e4-b091a7ea77a5', 'b74ef4f9-8dcf-57c2-9dbc-b05a2675d192', 8, $md$H$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5454eb20-573c-58f6-be85-140b7a7e6cc3', 'b74ef4f9-8dcf-57c2-9dbc-b05a2675d192', 9, $md$I$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('9a7c782f-e0f7-513d-989f-f728739a0a35', '03e04f16-1bb3-5809-b003-534f1d145deb', 7, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 7

Questions 5-9
Questions 5-9
Complete the summary using the list of words, A-l, below
Write the correct letter, A-l in boxes 5-9 on your answer sheet
The writers’ arguments against Field and Wroe's analysis of the scientific data
from Cuddie Springs
One objection to Field and Wroe's interpretation is the large quantity of charcoal,
5
and artefacts found at Cuddie Springs. Such large numbers of artefacts would impossible if the area had been covered with
6
for a period. There is also a complete lack of man-made structures, for instance those used for
7
.
Other evidence that doubt on Field and Wroe’s claim is the fact that while some material in the highest levels of sediment is 36,000 years old, the
8
in the same levels is much more recent. The tools used to process plants and animals may also be newer than Field and Wroe believe. Further evidence against human occupation of the area is the absence of tools and
9
a short distance away.
A seeds
B stone
C sand
D cooking
E deep drill core
F water
G fossil bones
H sediment
I storage

One objection to Field and Wroe's interpretation is the large quantity of charcoal, 5 ____ and artefacts found at Cuddie Springs. Such large numbers of artefacts would impossible if the area had been covered with 6 ____ for a period. There is also a complete lack of man-made structures, for instance those used for 7 ____ .$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('72873289-1a73-540c-a46a-e299974d2333', '9a7c782f-e0f7-513d-989f-f728739a0a35', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('75901c2e-e6c6-52d3-8592-160c5cb5eb49', '9a7c782f-e0f7-513d-989f-f728739a0a35', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('38c99eaa-bee9-5c88-a776-cac37416f4b6', '9a7c782f-e0f7-513d-989f-f728739a0a35', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5437f8f7-9114-59c3-ad7b-9c0bb7d35de1', '9a7c782f-e0f7-513d-989f-f728739a0a35', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('397e8012-b1c2-5a16-84e8-9fb0129ee0d0', '9a7c782f-e0f7-513d-989f-f728739a0a35', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('aaf97908-2662-5ad7-9990-8b60beba5116', '9a7c782f-e0f7-513d-989f-f728739a0a35', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('40034b95-dce2-5c68-b761-106eb9394974', '9a7c782f-e0f7-513d-989f-f728739a0a35', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2620abe8-508f-594f-85c0-6d8215479487', '9a7c782f-e0f7-513d-989f-f728739a0a35', 8, $md$H$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f01c212e-7c54-5e43-999e-b8e041d5488f', '9a7c782f-e0f7-513d-989f-f728739a0a35', 9, $md$I$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('4e6ff6e7-20a2-585f-b4f2-09aac9c077f1', '03e04f16-1bb3-5809-b003-534f1d145deb', 8, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 8

Questions 5-9
Questions 5-9
Complete the summary using the list of words, A-l, below
Write the correct letter, A-l in boxes 5-9 on your answer sheet
The writers’ arguments against Field and Wroe's analysis of the scientific data
from Cuddie Springs
One objection to Field and Wroe's interpretation is the large quantity of charcoal,
5
and artefacts found at Cuddie Springs. Such large numbers of artefacts would impossible if the area had been covered with
6
for a period. There is also a complete lack of man-made structures, for instance those used for
7
.
Other evidence that doubt on Field and Wroe’s claim is the fact that while some material in the highest levels of sediment is 36,000 years old, the
8
in the same levels is much more recent. The tools used to process plants and animals may also be newer than Field and Wroe believe. Further evidence against human occupation of the area is the absence of tools and
9
a short distance away.
A seeds
B stone
C sand
D cooking
E deep drill core
F water
G fossil bones
H sediment
I storage

Other evidence that doubt on Field and Wroe’s claim is the fact that while some material in the highest levels of sediment is 36,000 years old, the 8 ____ in the same levels is much more recent. The tools used to process plants and animals may also be newer than Field and Wroe believe. Further evidence against human occupation of the area is the absence of tools and 9 ____ a short distance away.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('14cc8102-06b1-567b-8373-c53ecb2ad837', '4e6ff6e7-20a2-585f-b4f2-09aac9c077f1', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3b01110a-56e6-5304-9faf-30a70a6dfd92', '4e6ff6e7-20a2-585f-b4f2-09aac9c077f1', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('416767cf-d437-5283-89da-48ecd1103a29', '4e6ff6e7-20a2-585f-b4f2-09aac9c077f1', 3, $md$C$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b511c825-c014-55df-a8e2-5cccbca7bab1', '4e6ff6e7-20a2-585f-b4f2-09aac9c077f1', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cf42fa50-4ffa-510d-a6fe-b2093aa36051', '4e6ff6e7-20a2-585f-b4f2-09aac9c077f1', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b47edd19-37c5-5844-95e5-5911239f659a', '4e6ff6e7-20a2-585f-b4f2-09aac9c077f1', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('26ef9d50-eda4-5a49-bcf4-d9154f9bd76c', '4e6ff6e7-20a2-585f-b4f2-09aac9c077f1', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2f384863-1741-533b-8bf1-612e38f0746f', '4e6ff6e7-20a2-585f-b4f2-09aac9c077f1', 8, $md$H$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b28478c0-947a-5331-938b-b855a5bcb919', '4e6ff6e7-20a2-585f-b4f2-09aac9c077f1', 9, $md$I$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('2d67d99f-b9d9-53a5-a5a2-b6bcdbb90029', '03e04f16-1bb3-5809-b003-534f1d145deb', 9, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 9

Questions 5-9
Questions 5-9
Complete the summary using the list of words, A-l, below
Write the correct letter, A-l in boxes 5-9 on your answer sheet
The writers’ arguments against Field and Wroe's analysis of the scientific data
from Cuddie Springs
One objection to Field and Wroe's interpretation is the large quantity of charcoal,
5
and artefacts found at Cuddie Springs. Such large numbers of artefacts would impossible if the area had been covered with
6
for a period. There is also a complete lack of man-made structures, for instance those used for
7
.
Other evidence that doubt on Field and Wroe’s claim is the fact that while some material in the highest levels of sediment is 36,000 years old, the
8
in the same levels is much more recent. The tools used to process plants and animals may also be newer than Field and Wroe believe. Further evidence against human occupation of the area is the absence of tools and
9
a short distance away.
A seeds
B stone
C sand
D cooking
E deep drill core
F water
G fossil bones
H sediment
I storage

Other evidence that doubt on Field and Wroe’s claim is the fact that while some material in the highest levels of sediment is 36,000 years old, the 8 ____ in the same levels is much more recent. The tools used to process plants and animals may also be newer than Field and Wroe believe. Further evidence against human occupation of the area is the absence of tools and 9 ____ a short distance away.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b1811b43-49f0-5a35-9006-5920ac7acec9', '2d67d99f-b9d9-53a5-a5a2-b6bcdbb90029', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a5d65356-a99b-55e7-a29b-f0021d70ef29', '2d67d99f-b9d9-53a5-a5a2-b6bcdbb90029', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c36bba1e-ee39-553e-977f-0911eddf0070', '2d67d99f-b9d9-53a5-a5a2-b6bcdbb90029', 3, $md$C$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('56be33f4-e426-5e6e-98d7-33392e09c1e3', '2d67d99f-b9d9-53a5-a5a2-b6bcdbb90029', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('aabaa286-0c4f-5e8d-9ae3-c4c51f2a6f26', '2d67d99f-b9d9-53a5-a5a2-b6bcdbb90029', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5ee110b2-647b-55ab-acc5-06343f344cbc', '2d67d99f-b9d9-53a5-a5a2-b6bcdbb90029', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('002e1fd7-f78e-5c0a-9eb6-0d7d6f5311fc', '2d67d99f-b9d9-53a5-a5a2-b6bcdbb90029', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9bc41a34-afa2-52df-abc3-646aac117b9d', '2d67d99f-b9d9-53a5-a5a2-b6bcdbb90029', 8, $md$H$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('eab22596-5060-5ecd-8d94-464e32faaeea', '2d67d99f-b9d9-53a5-a5a2-b6bcdbb90029', 9, $md$I$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('d8bcfb6c-b38c-5f32-ae61-525bfd830260', '03e04f16-1bb3-5809-b003-534f1d145deb', 10, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 10

Questions 10-14
Questions 10-14
Choose the letter,
A, B, c or D.
Write the correct letter in boxes 10-14 on your answer sheet.
10. What conclusions did the writers reach about the inconsistencies in the data from Cuddie Springs?
A
The different layers of sediment have been mixed over time.
B
The sand evidence is unhelpful and should be disregarded.
C
The area needs to be re-examined when technology improves.
D
The charcoal found in the area cannot be dated.
11. According to the writers, what impact could a natural phenomenon have had on this site?
A
Floods could have caused the death of the megafauna.
B
Floods could have disturbed the archaeological evidence.
C
Bushfires could have prevented humans from settling in the area for any length of time
D
Bushfires could have destroyed much of the evidence left by megafauna and humans.
12. What did the writers speculate about the people who lived at this site in 1876?
A
They bred cattle whose bones could have been confused with megafauna
B
They found that the soil was too waterlogged for farming
C
They allowed cattle to move around freely at the site
D
They brought stones there from another area
13. In the final paragraph what suggestion do the writers hide about Australia’s megafauna?
A
A rapid change in climate may have been responsible for the extinction of the megafauna.
B
Megafauna could have died out as a result of small numbers being killed year after year.
C
The population of humans at that time was probably insufficient to cause the extinction of the megafauna.
D
The extinction of ancient animals should not be compared to that of modern-day species.
14. Which of the following best represents the writers' criticism of Field and Wroe?
A
Their methods were not well thought out
B
Their excavations did not go deep enough.
C
Their technology failed to obtain precise data.
D
Their conclusions were based on inconsistent data.40##qa

Choose the letter, A, B, c or D.$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('1c748081-906a-5419-8f0b-1edceb9d4cd3', '03e04f16-1bb3-5809-b003-534f1d145deb', 11, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 11

Questions 10-14
Questions 10-14
Choose the letter,
A, B, c or D.
Write the correct letter in boxes 10-14 on your answer sheet.
10. What conclusions did the writers reach about the inconsistencies in the data from Cuddie Springs?
A
The different layers of sediment have been mixed over time.
B
The sand evidence is unhelpful and should be disregarded.
C
The area needs to be re-examined when technology improves.
D
The charcoal found in the area cannot be dated.
11. According to the writers, what impact could a natural phenomenon have had on this site?
A
Floods could have caused the death of the megafauna.
B
Floods could have disturbed the archaeological evidence.
C
Bushfires could have prevented humans from settling in the area for any length of time
D
Bushfires could have destroyed much of the evidence left by megafauna and humans.
12. What did the writers speculate about the people who lived at this site in 1876?
A
They bred cattle whose bones could have been confused with megafauna
B
They found that the soil was too waterlogged for farming
C
They allowed cattle to move around freely at the site
D
They brought stones there from another area
13. In the final paragraph what suggestion do the writers hide about Australia’s megafauna?
A
A rapid change in climate may have been responsible for the extinction of the megafauna.
B
Megafauna could have died out as a result of small numbers being killed year after year.
C
The population of humans at that time was probably insufficient to cause the extinction of the megafauna.
D
The extinction of ancient animals should not be compared to that of modern-day species.
14. Which of the following best represents the writers' criticism of Field and Wroe?
A
Their methods were not well thought out
B
Their excavations did not go deep enough.
C
Their technology failed to obtain precise data.
D
Their conclusions were based on inconsistent data.40##qa

Choose the letter, A, B, c or D.$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('dff264f3-86a0-5bf0-ad87-4ad9140fa258', '03e04f16-1bb3-5809-b003-534f1d145deb', 12, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 12

Questions 10-14
Questions 10-14
Choose the letter,
A, B, c or D.
Write the correct letter in boxes 10-14 on your answer sheet.
10. What conclusions did the writers reach about the inconsistencies in the data from Cuddie Springs?
A
The different layers of sediment have been mixed over time.
B
The sand evidence is unhelpful and should be disregarded.
C
The area needs to be re-examined when technology improves.
D
The charcoal found in the area cannot be dated.
11. According to the writers, what impact could a natural phenomenon have had on this site?
A
Floods could have caused the death of the megafauna.
B
Floods could have disturbed the archaeological evidence.
C
Bushfires could have prevented humans from settling in the area for any length of time
D
Bushfires could have destroyed much of the evidence left by megafauna and humans.
12. What did the writers speculate about the people who lived at this site in 1876?
A
They bred cattle whose bones could have been confused with megafauna
B
They found that the soil was too waterlogged for farming
C
They allowed cattle to move around freely at the site
D
They brought stones there from another area
13. In the final paragraph what suggestion do the writers hide about Australia’s megafauna?
A
A rapid change in climate may have been responsible for the extinction of the megafauna.
B
Megafauna could have died out as a result of small numbers being killed year after year.
C
The population of humans at that time was probably insufficient to cause the extinction of the megafauna.
D
The extinction of ancient animals should not be compared to that of modern-day species.
14. Which of the following best represents the writers' criticism of Field and Wroe?
A
Their methods were not well thought out
B
Their excavations did not go deep enough.
C
Their technology failed to obtain precise data.
D
Their conclusions were based on inconsistent data.40##qa

Choose the letter, A, B, c or D.$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('8ebd82cf-9c69-5864-8693-4d22b9c2803a', '03e04f16-1bb3-5809-b003-534f1d145deb', 13, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 13

Questions 10-14
Questions 10-14
Choose the letter,
A, B, c or D.
Write the correct letter in boxes 10-14 on your answer sheet.
10. What conclusions did the writers reach about the inconsistencies in the data from Cuddie Springs?
A
The different layers of sediment have been mixed over time.
B
The sand evidence is unhelpful and should be disregarded.
C
The area needs to be re-examined when technology improves.
D
The charcoal found in the area cannot be dated.
11. According to the writers, what impact could a natural phenomenon have had on this site?
A
Floods could have caused the death of the megafauna.
B
Floods could have disturbed the archaeological evidence.
C
Bushfires could have prevented humans from settling in the area for any length of time
D
Bushfires could have destroyed much of the evidence left by megafauna and humans.
12. What did the writers speculate about the people who lived at this site in 1876?
A
They bred cattle whose bones could have been confused with megafauna
B
They found that the soil was too waterlogged for farming
C
They allowed cattle to move around freely at the site
D
They brought stones there from another area
13. In the final paragraph what suggestion do the writers hide about Australia’s megafauna?
A
A rapid change in climate may have been responsible for the extinction of the megafauna.
B
Megafauna could have died out as a result of small numbers being killed year after year.
C
The population of humans at that time was probably insufficient to cause the extinction of the megafauna.
D
The extinction of ancient animals should not be compared to that of modern-day species.
14. Which of the following best represents the writers' criticism of Field and Wroe?
A
Their methods were not well thought out
B
Their excavations did not go deep enough.
C
Their technology failed to obtain precise data.
D
Their conclusions were based on inconsistent data.40##qa

Choose the letter, A, B, c or D.$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('dae5cfc6-615a-5450-a063-46d0d2763117', '03e04f16-1bb3-5809-b003-534f1d145deb', 14, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 14

Questions 10-14
Questions 10-14
Choose the letter,
A, B, c or D.
Write the correct letter in boxes 10-14 on your answer sheet.
10. What conclusions did the writers reach about the inconsistencies in the data from Cuddie Springs?
A
The different layers of sediment have been mixed over time.
B
The sand evidence is unhelpful and should be disregarded.
C
The area needs to be re-examined when technology improves.
D
The charcoal found in the area cannot be dated.
11. According to the writers, what impact could a natural phenomenon have had on this site?
A
Floods could have caused the death of the megafauna.
B
Floods could have disturbed the archaeological evidence.
C
Bushfires could have prevented humans from settling in the area for any length of time
D
Bushfires could have destroyed much of the evidence left by megafauna and humans.
12. What did the writers speculate about the people who lived at this site in 1876?
A
They bred cattle whose bones could have been confused with megafauna
B
They found that the soil was too waterlogged for farming
C
They allowed cattle to move around freely at the site
D
They brought stones there from another area
13. In the final paragraph what suggestion do the writers hide about Australia’s megafauna?
A
A rapid change in climate may have been responsible for the extinction of the megafauna.
B
Megafauna could have died out as a result of small numbers being killed year after year.
C
The population of humans at that time was probably insufficient to cause the extinction of the megafauna.
D
The extinction of ancient animals should not be compared to that of modern-day species.
14. Which of the following best represents the writers' criticism of Field and Wroe?
A
Their methods were not well thought out
B
Their excavations did not go deep enough.
C
Their technology failed to obtain precise data.
D
Their conclusions were based on inconsistent data.40##qa

Choose the letter, A, B, c or D.$md$, NULL);

COMMIT;
