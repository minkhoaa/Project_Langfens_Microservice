BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-keeping-the-water-away-1452'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-keeping-the-water-away-1452';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-keeping-the-water-away-1452';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-keeping-the-water-away-1452';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('3f60670f-c8af-59a4-ad5e-9427cf005e0e', 'ielts-reading-keeping-the-water-away-1452', $t$Keeping the water away$t$, $md$## Keeping the water away

Nguồn:
- Test: https://mini-ielts.com/1452/reading/keeping-the-water-away
- Solution: https://mini-ielts.com/1452/view-solution/reading/keeping-the-water-away$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('c916b4b0-cc70-577a-9306-0b1acf97fedb', '3f60670f-c8af-59a4-ad5e-9427cf005e0e', 1, $t$Reading — Keeping the water away$t$, $md$Read the passage and answer questions **1–11**.

### Passage: Keeping the water away

New approaches to flood control$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('cdd7c2b7-c44c-5576-b737-06e749c72861', 'c916b4b0-cc70-577a-9306-0b1acf97fedb', 1, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 1

Questions 1-6
Questions 1-6
Reading Passage 2 has seven paragraphs,
A-G,
Which paragraph contains the following information?
Write the correct letter. A-G, in boxes 1-6 on your answer sheet
1
how legislation has forced building designers to improve water use
2
two reasons why one river was isolated from its food plain
3
how natural water courses in the past assisted flood control
4
an example of flood control on one river, affecting three countries
5
a country which has partly destroyed one of its most typical features in order to control water
6
the writer's comment on the comparative cost effectiveness of traditional flood control and newer methods

1 ____ how legislation has forced building designers to improve water use$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b2c46344-af09-5c2e-baeb-bf317a5523da', 'cdd7c2b7-c44c-5576-b737-06e749c72861', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5ba565a6-d600-5552-ab02-01d855b88124', 'cdd7c2b7-c44c-5576-b737-06e749c72861', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('854a9d28-c39d-5a9e-8c21-e469591838da', 'cdd7c2b7-c44c-5576-b737-06e749c72861', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('134cdf4b-bb50-5d5c-b1af-fe533c1f6a51', 'cdd7c2b7-c44c-5576-b737-06e749c72861', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1a6dd71a-62d9-587c-b635-61c168dbf6e2', 'cdd7c2b7-c44c-5576-b737-06e749c72861', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3aaf79cf-fcbb-5de1-906f-a98c6b816f65', 'cdd7c2b7-c44c-5576-b737-06e749c72861', 6, $md$F$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f5097efb-8b82-5b2d-ab2c-66b013c5d65b', 'cdd7c2b7-c44c-5576-b737-06e749c72861', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('2097b5c5-30dd-5674-95fb-9aecce4f6059', 'c916b4b0-cc70-577a-9306-0b1acf97fedb', 2, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 2

Questions 1-6
Questions 1-6
Reading Passage 2 has seven paragraphs,
A-G,
Which paragraph contains the following information?
Write the correct letter. A-G, in boxes 1-6 on your answer sheet
1
how legislation has forced building designers to improve water use
2
two reasons why one river was isolated from its food plain
3
how natural water courses in the past assisted flood control
4
an example of flood control on one river, affecting three countries
5
a country which has partly destroyed one of its most typical features in order to control water
6
the writer's comment on the comparative cost effectiveness of traditional flood control and newer methods

2 ____ two reasons why one river was isolated from its food plain$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0371548f-20f0-55e4-a281-c019a9b0c835', '2097b5c5-30dd-5674-95fb-9aecce4f6059', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('dab2471a-d3d2-5807-8064-7fd9265f16f5', '2097b5c5-30dd-5674-95fb-9aecce4f6059', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5c70d19f-6329-504a-b149-1c8b8d2ef8ec', '2097b5c5-30dd-5674-95fb-9aecce4f6059', 3, $md$C$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fbfe0eed-909e-5974-bbbb-aa9f0a265e2e', '2097b5c5-30dd-5674-95fb-9aecce4f6059', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f321f37c-c57a-5dd0-aa67-86f449f7829a', '2097b5c5-30dd-5674-95fb-9aecce4f6059', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('511647ee-2bd3-5733-95e0-c50a8577acad', '2097b5c5-30dd-5674-95fb-9aecce4f6059', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b7c0bbde-d568-5507-9a5a-3285213c1042', '2097b5c5-30dd-5674-95fb-9aecce4f6059', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('f903edf7-e0ea-5744-af63-ba35fc43dc3f', 'c916b4b0-cc70-577a-9306-0b1acf97fedb', 3, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 3

Questions 1-6
Questions 1-6
Reading Passage 2 has seven paragraphs,
A-G,
Which paragraph contains the following information?
Write the correct letter. A-G, in boxes 1-6 on your answer sheet
1
how legislation has forced building designers to improve water use
2
two reasons why one river was isolated from its food plain
3
how natural water courses in the past assisted flood control
4
an example of flood control on one river, affecting three countries
5
a country which has partly destroyed one of its most typical features in order to control water
6
the writer's comment on the comparative cost effectiveness of traditional flood control and newer methods

3 ____ how natural water courses in the past assisted flood control$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('61a02329-6aab-5672-aa2c-6127db58bffb', 'f903edf7-e0ea-5744-af63-ba35fc43dc3f', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('27821963-2366-5111-a665-352ab5152794', 'f903edf7-e0ea-5744-af63-ba35fc43dc3f', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('20939449-7dfb-5406-a9b6-ebea3232802d', 'f903edf7-e0ea-5744-af63-ba35fc43dc3f', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('103adfe1-ce7d-51bd-aaf6-8162ae441377', 'f903edf7-e0ea-5744-af63-ba35fc43dc3f', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('048946fd-3ab2-5939-905d-346aaf3ed317', 'f903edf7-e0ea-5744-af63-ba35fc43dc3f', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('420e7644-dbe2-5326-94e1-5fee278f2801', 'f903edf7-e0ea-5744-af63-ba35fc43dc3f', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('afeb7313-8d4f-5d6d-80f3-8da6f3921a6e', 'f903edf7-e0ea-5744-af63-ba35fc43dc3f', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('b0d4c30e-6496-51b0-b722-fbc6c05ee58e', 'c916b4b0-cc70-577a-9306-0b1acf97fedb', 4, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 4

Questions 1-6
Questions 1-6
Reading Passage 2 has seven paragraphs,
A-G,
Which paragraph contains the following information?
Write the correct letter. A-G, in boxes 1-6 on your answer sheet
1
how legislation has forced building designers to improve water use
2
two reasons why one river was isolated from its food plain
3
how natural water courses in the past assisted flood control
4
an example of flood control on one river, affecting three countries
5
a country which has partly destroyed one of its most typical features in order to control water
6
the writer's comment on the comparative cost effectiveness of traditional flood control and newer methods

4 ____ an example of flood control on one river, affecting three countries$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('076de370-749a-5dbc-a9f7-41089e50c39a', 'b0d4c30e-6496-51b0-b722-fbc6c05ee58e', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b23cf97a-383f-524b-8b42-053dde0a905c', 'b0d4c30e-6496-51b0-b722-fbc6c05ee58e', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9bc7bb34-fd43-5e70-8879-ef9d434ed283', 'b0d4c30e-6496-51b0-b722-fbc6c05ee58e', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d9a0b017-add7-5ebb-aee4-cab41947bedb', 'b0d4c30e-6496-51b0-b722-fbc6c05ee58e', 4, $md$D$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b8126810-a056-5649-96ee-7c5fe7946d0d', 'b0d4c30e-6496-51b0-b722-fbc6c05ee58e', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('72d2190a-e86a-52d7-a782-d7a0c9d6b735', 'b0d4c30e-6496-51b0-b722-fbc6c05ee58e', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bb6bdb80-7627-56f4-9eae-02ed1548570b', 'b0d4c30e-6496-51b0-b722-fbc6c05ee58e', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('fb33ab18-f1d2-5c29-8f27-938b346d54f6', 'c916b4b0-cc70-577a-9306-0b1acf97fedb', 5, 'MATCHING_INFORMATION', 'READING', 3, $md$### Question 5

Questions 1-6
Questions 1-6
Reading Passage 2 has seven paragraphs,
A-G,
Which paragraph contains the following information?
Write the correct letter. A-G, in boxes 1-6 on your answer sheet
1
how legislation has forced building designers to improve water use
2
two reasons why one river was isolated from its food plain
3
how natural water courses in the past assisted flood control
4
an example of flood control on one river, affecting three countries
5
a country which has partly destroyed one of its most typical features in order to control water
6
the writer's comment on the comparative cost effectiveness of traditional flood control and newer methods

5 ____ a country which has partly destroyed one of its most typical features in order to control water$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('19d1cc2e-336e-5648-a4ec-0beabf47b274', 'fb33ab18-f1d2-5c29-8f27-938b346d54f6', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('638557d5-2d6f-53b8-91c6-9684a412231e', 'fb33ab18-f1d2-5c29-8f27-938b346d54f6', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cb09408d-97a3-5cd3-8db0-862d2d475f4a', 'fb33ab18-f1d2-5c29-8f27-938b346d54f6', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2a6dafa3-62d2-5969-8c82-1bb8e4ef04cc', 'fb33ab18-f1d2-5c29-8f27-938b346d54f6', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c1f20f1d-967d-53d4-becb-d4d707719d5c', 'fb33ab18-f1d2-5c29-8f27-938b346d54f6', 5, $md$E$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('54807bd9-0210-5405-be49-9190e58652e3', 'fb33ab18-f1d2-5c29-8f27-938b346d54f6', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5c195d93-83fe-5a74-b7fb-e4f85549ecb3', 'fb33ab18-f1d2-5c29-8f27-938b346d54f6', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('2a240e99-efb4-55dc-9b89-6ef54a323575', 'c916b4b0-cc70-577a-9306-0b1acf97fedb', 6, 'MATCHING_INFORMATION', 'READING', 3, $md$### Question 6

Questions 1-6
Questions 1-6
Reading Passage 2 has seven paragraphs,
A-G,
Which paragraph contains the following information?
Write the correct letter. A-G, in boxes 1-6 on your answer sheet
1
how legislation has forced building designers to improve water use
2
two reasons why one river was isolated from its food plain
3
how natural water courses in the past assisted flood control
4
an example of flood control on one river, affecting three countries
5
a country which has partly destroyed one of its most typical features in order to control water
6
the writer's comment on the comparative cost effectiveness of traditional flood control and newer methods

6 ____ the writer's comment on the comparative cost effectiveness of traditional flood control and newer methods$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bed0352d-797f-5544-b538-2508a61c5622', '2a240e99-efb4-55dc-9b89-6ef54a323575', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9816af99-f66d-580a-86b6-00e1d054cb73', '2a240e99-efb4-55dc-9b89-6ef54a323575', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('92183005-40a8-5f85-8dd7-677ee3ebd08e', '2a240e99-efb4-55dc-9b89-6ef54a323575', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6bb452db-a84c-57a6-a59a-11788d8338bc', '2a240e99-efb4-55dc-9b89-6ef54a323575', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fdce85dd-8633-58bc-bb91-394f1c5ea3e6', '2a240e99-efb4-55dc-9b89-6ef54a323575', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('86092daf-d204-59b1-874f-81271c38045b', '2a240e99-efb4-55dc-9b89-6ef54a323575', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e323fe42-487b-528c-8acf-5fe8da0e79fe', '2a240e99-efb4-55dc-9b89-6ef54a323575', 7, $md$G$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('476530e7-7fa8-5cbc-96e1-dd8402dca968', 'c916b4b0-cc70-577a-9306-0b1acf97fedb', 9, 'SENTENCE_COMPLETION', 'READING', 3, $md$### Question 9

Questions 9-13
Questions 9-13
Complete the sentences below.
Choose
NO MORE THAN MO WORDS
from the passage for each answer. Write your answers in boxes 9-13 on your answer sheet.
9. Some of the most severe floods for many centuries have recently occurred in parts of
9
10. The Rhine and the
10
rivers have experienced similar problems with water control
11. An area near Oxford will flooded to protect the city of
11
12. Planners who wish to allow water to pass more freely through city surfaces are called
12
13.A proposal for part of the city of
13
could show whether small-scale water projects could apply on a large scale.

9. Some of the most severe floods for many centuries have recently occurred in parts of 9 ____$md$, NULL, ARRAY['.*europe.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('82a0469c-ab29-5689-a9eb-51227a3d6109', 'c916b4b0-cc70-577a-9306-0b1acf97fedb', 10, 'SENTENCE_COMPLETION', 'READING', 4, $md$### Question 10

Questions 9-13
Questions 9-13
Complete the sentences below.
Choose
NO MORE THAN MO WORDS
from the passage for each answer. Write your answers in boxes 9-13 on your answer sheet.
9. Some of the most severe floods for many centuries have recently occurred in parts of
9
10. The Rhine and the
10
rivers have experienced similar problems with water control
11. An area near Oxford will flooded to protect the city of
11
12. Planners who wish to allow water to pass more freely through city surfaces are called
12
13.A proposal for part of the city of
13
could show whether small-scale water projects could apply on a large scale.

10. The Rhine and the 10 ____ rivers have experienced similar problems with water control$md$, NULL, ARRAY['.*mississippi.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('b26bd78d-9bcb-5c73-8cad-8d1861fdeb6d', 'c916b4b0-cc70-577a-9306-0b1acf97fedb', 11, 'SENTENCE_COMPLETION', 'READING', 4, $md$### Question 11

Questions 9-13
Questions 9-13
Complete the sentences below.
Choose
NO MORE THAN MO WORDS
from the passage for each answer. Write your answers in boxes 9-13 on your answer sheet.
9. Some of the most severe floods for many centuries have recently occurred in parts of
9
10. The Rhine and the
10
rivers have experienced similar problems with water control
11. An area near Oxford will flooded to protect the city of
11
12. Planners who wish to allow water to pass more freely through city surfaces are called
12
13.A proposal for part of the city of
13
could show whether small-scale water projects could apply on a large scale.

11. An area near Oxford will flooded to protect the city of 11 ____$md$, NULL, ARRAY['.*london.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('3423a8f9-d1c2-5f52-9d21-c91471638ef2', 'c916b4b0-cc70-577a-9306-0b1acf97fedb', 12, 'SENTENCE_COMPLETION', 'READING', 4, $md$### Question 12

Questions 9-13
Questions 9-13
Complete the sentences below.
Choose
NO MORE THAN MO WORDS
from the passage for each answer. Write your answers in boxes 9-13 on your answer sheet.
9. Some of the most severe floods for many centuries have recently occurred in parts of
9
10. The Rhine and the
10
rivers have experienced similar problems with water control
11. An area near Oxford will flooded to protect the city of
11
12. Planners who wish to allow water to pass more freely through city surfaces are called
12
13.A proposal for part of the city of
13
could show whether small-scale water projects could apply on a large scale.

12. Planners who wish to allow water to pass more freely through city surfaces are called 12 ____$md$, NULL, ARRAY['.*soft.*engineers.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('4227b905-b54e-541d-9f24-4a9a26b02686', 'c916b4b0-cc70-577a-9306-0b1acf97fedb', 13, 'SENTENCE_COMPLETION', 'READING', 4, $md$### Question 13

Questions 9-13
Questions 9-13
Complete the sentences below.
Choose
NO MORE THAN MO WORDS
from the passage for each answer. Write your answers in boxes 9-13 on your answer sheet.
9. Some of the most severe floods for many centuries have recently occurred in parts of
9
10. The Rhine and the
10
rivers have experienced similar problems with water control
11. An area near Oxford will flooded to protect the city of
11
12. Planners who wish to allow water to pass more freely through city surfaces are called
12
13.A proposal for part of the city of
13
could show whether small-scale water projects could apply on a large scale.

13.A proposal for part of the city of 13 ____ could show whether small-scale water projects could apply on a large scale.$md$, NULL, ARRAY['.*los.*angeles.*']);

COMMIT;
