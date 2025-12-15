BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-the-romantic-poets-1244'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-the-romantic-poets-1244';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-the-romantic-poets-1244';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-the-romantic-poets-1244';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('dfb17d4a-255c-523f-99be-d6a5d34fa76b', 'ielts-reading-the-romantic-poets-1244', $t$The Romantic Poets$t$, $md$## The Romantic Poets

Nguồn:
- Test: https://mini-ielts.com/1244/reading/the-romantic-poets
- Solution: https://mini-ielts.com/1244/view-solution/reading/the-romantic-poets$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('e95c3fe0-7c53-5f55-9082-0f4dae04424f', 'dfb17d4a-255c-523f-99be-d6a5d34fa76b', 1, $t$Reading — The Romantic Poets$t$, $md$Read the passage and answer questions **1–14**.

### Passage: The Romantic Poets

One of the most evocative eras in the history of poetry must surely be that of the Romantic Movement. During the late eighteenth and early nineteenth centuries a group of poets created a new mood in literary objectives, casting off their predecessors’ styles in favour of a gripping and forceful art which endures with us to this day.

Five poets emerged as the main constituents of this movement – William Wordsworth, Samuel Taylor Coleridge, George Gordon Byron, Percy Bysshe Shelley and John Keats. The strength of their works lies undoubtedly in the power of their imagination. Indeed, imagination was the most critical attribute of the Romantic poets. Each poet had the ability to portray remarkable images and visions, although differing to a certain degree in their intensity and presentation. Nature, mythology and emotion were of great importance and were used to explore the feelings of the poet himself.

The lives of the poets often overlapped and tragedy was typical in most of them. Byron was born in London in 1788. The family moved to Aberdeen soon after, where Byron was brought up until he inherited the family seat of Newstead Abbey in Nottinghamshire from his great uncle. He graduated from Cambridge University in 1808 and left England the following year to embark on a tour of the Mediterranean . During this tour, he developed a passion for Greece which would later lead to his death in 1824. He left for Switzerland in 1816 where he was introduced to Shelley.

Shelley was bom to a wealthy family in 1792. He was educated at Eton and then went on to Oxford. Shelley was not happy in England, where his colourful lifestyle and unorthodox beliefs made him unpopular with the establishment In 1818 he left for Italy, where he was reunited with Byron. However, the friendship was tragically brought to an end in July 1822, when Shelley was drowned in a boating accident off the Italian coast. In somewhat dramatic form, Shelley’s body was cremated on the beach, witnessed by a small group of friends, including Byron.

Historically, Shelley and Byron are considered to have been the most outspoken and radical of the Romantic poets. By contrast, Wordsworth appears to have been of a pleasant and acceptable personality, even receiving the status of Poet Laureate in 1843. He was born in 1770 in Cockermouth, Cumbria. By the time he entered his early teens, both his parents had died. As he grew older, Wordsworth developed a passion for writing.

In 1798 Wordsworth published a collection of poems with Coleridge, whom he had met, a few years earlier, when he settled in Somerset with his sister Dorothy. He married in 1802 and, as time passed, he deserted his former political views and became increasingly acceptable to popular society. Indeed, at the time of his death in the spring of 1850, he had become one of the most sought-after poets of his time.

Wordsworth shared some of the years at Dove Cottage in Somerset with his friend and poetical contemporary, Coleridge. Coleridge was born in Devon in 1772. He was a bright young scholar but never achieved the same prolific output of his fellow Romantic poets . In 1804 he left for a position in Malta for three years. On his return he separated from his wife and went to live with the Wordsworths, where he produced a regular periodical.

With failing health , he later moved to London. In 1816 he went to stay with a doctor and his family. He remained with them until his death in 1834. During these latter years, his poetry was abandoned for other forms of writing equally outstanding in their own right.

Perhaps the most tragic of the Romantic poets was Keats. Keats was born in London in 1795. Similar to Wordsworth, both his parents had died by his early teens. He studied as a surgeon, qualifying in 1816. However, poetry was his great passion and he decided to devote himself to writing. For much of his adult life Keats was in poor health and fell gravely ill in early 1820. He knew he was dying and in the September of that year he left for Rome hoping that the more agreeable climate might ease his suffering . Keats died of consumption in February 1821 at the age of twenty-five.

It is sad that such tragedy often accompanies those of outstanding artistic genius. We can only wonder at the possible outcome had they all lived to an old age. Perhaps even Byron and Shelley would have mellowed with the years, like Wordsworth. However, the contribution to poetry by all five writers is immeasurable. They introduced the concepts of individualism and imagination , allowing us to explore our own visions of beauty without retribution. We are not now required to restrain our thoughts and poetry to that of the socially acceptable.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('b6a751a6-16e9-5178-aa5b-4fa08f22b88a', 'e95c3fe0-7c53-5f55-9082-0f4dae04424f', 1, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 1

Questions 1-6
Questions 1-6
Do the following statements agree with the information given in Reading Passage 3?
Write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
1
The Romantic Movement lasted for more than a century.
2
The Romantic poets adopted a style dissimilar to that of poets who had come before them.
3
Unfortunately, the works of the Romantics had no lasting impression on art.
4
The Romantics had no respect for any style of poetry apart from their own.
5
The Romantics were gifted with a strong sense of imagination.
6
Much of the Romantics’ poetry was inspired by the natural world.

1 ____ The Romantic Movement lasted for more than a century.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('63166733-fef0-5ec7-90a1-0a43022ed7e0', 'b6a751a6-16e9-5178-aa5b-4fa08f22b88a', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('13c35a1b-0fd7-5a9e-a193-4e3332827e79', 'b6a751a6-16e9-5178-aa5b-4fa08f22b88a', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('55a517bf-46e5-576e-a480-581b008a1ff2', 'b6a751a6-16e9-5178-aa5b-4fa08f22b88a', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('7b297b29-0232-534e-a430-c4f3e5f933e3', 'e95c3fe0-7c53-5f55-9082-0f4dae04424f', 2, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 2

Questions 1-6
Questions 1-6
Do the following statements agree with the information given in Reading Passage 3?
Write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
1
The Romantic Movement lasted for more than a century.
2
The Romantic poets adopted a style dissimilar to that of poets who had come before them.
3
Unfortunately, the works of the Romantics had no lasting impression on art.
4
The Romantics had no respect for any style of poetry apart from their own.
5
The Romantics were gifted with a strong sense of imagination.
6
Much of the Romantics’ poetry was inspired by the natural world.

2 ____ The Romantic poets adopted a style dissimilar to that of poets who had come before them.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7fed9a6d-8dfa-597a-bef1-f8065e08bac3', '7b297b29-0232-534e-a430-c4f3e5f933e3', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1aad937f-cb7b-5514-be06-8ddecec1f2cc', '7b297b29-0232-534e-a430-c4f3e5f933e3', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c6c8e9b7-b673-5592-a95c-f91e2881b817', '7b297b29-0232-534e-a430-c4f3e5f933e3', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('d6a5afa6-26ff-55f0-8a30-4218a33f6e7d', 'e95c3fe0-7c53-5f55-9082-0f4dae04424f', 3, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 3

Questions 1-6
Questions 1-6
Do the following statements agree with the information given in Reading Passage 3?
Write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
1
The Romantic Movement lasted for more than a century.
2
The Romantic poets adopted a style dissimilar to that of poets who had come before them.
3
Unfortunately, the works of the Romantics had no lasting impression on art.
4
The Romantics had no respect for any style of poetry apart from their own.
5
The Romantics were gifted with a strong sense of imagination.
6
Much of the Romantics’ poetry was inspired by the natural world.

3 ____ Unfortunately, the works of the Romantics had no lasting impression on art.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ea29a6f9-10ae-5d68-a5bf-289ed7fd4281', 'd6a5afa6-26ff-55f0-8a30-4218a33f6e7d', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('10f362bf-094a-50de-9803-8bea763a9f89', 'd6a5afa6-26ff-55f0-8a30-4218a33f6e7d', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c6fada03-4c60-5ff9-952f-24bbb9e3191e', 'd6a5afa6-26ff-55f0-8a30-4218a33f6e7d', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('f6d1154e-612f-5bb2-b0b2-13f0f8a6b6d0', 'e95c3fe0-7c53-5f55-9082-0f4dae04424f', 4, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 4

Questions 1-6
Questions 1-6
Do the following statements agree with the information given in Reading Passage 3?
Write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
1
The Romantic Movement lasted for more than a century.
2
The Romantic poets adopted a style dissimilar to that of poets who had come before them.
3
Unfortunately, the works of the Romantics had no lasting impression on art.
4
The Romantics had no respect for any style of poetry apart from their own.
5
The Romantics were gifted with a strong sense of imagination.
6
Much of the Romantics’ poetry was inspired by the natural world.

4 ____ The Romantics had no respect for any style of poetry apart from their own.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('acf89736-d375-5512-a7a9-a5bf8e039ba0', 'f6d1154e-612f-5bb2-b0b2-13f0f8a6b6d0', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6affd615-73bc-5f3f-a815-5f477a2f3c20', 'f6d1154e-612f-5bb2-b0b2-13f0f8a6b6d0', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d418b0de-5292-53e5-884b-a5342ea398db', 'f6d1154e-612f-5bb2-b0b2-13f0f8a6b6d0', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('6999595e-b7f6-571d-9742-1176fedc7f52', 'e95c3fe0-7c53-5f55-9082-0f4dae04424f', 5, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 5

Questions 1-6
Questions 1-6
Do the following statements agree with the information given in Reading Passage 3?
Write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
1
The Romantic Movement lasted for more than a century.
2
The Romantic poets adopted a style dissimilar to that of poets who had come before them.
3
Unfortunately, the works of the Romantics had no lasting impression on art.
4
The Romantics had no respect for any style of poetry apart from their own.
5
The Romantics were gifted with a strong sense of imagination.
6
Much of the Romantics’ poetry was inspired by the natural world.

5 ____ The Romantics were gifted with a strong sense of imagination.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('40129b37-35b5-5391-ae6c-92e1d75a033b', '6999595e-b7f6-571d-9742-1176fedc7f52', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('edb51240-2e40-59d4-83d1-53171658724d', '6999595e-b7f6-571d-9742-1176fedc7f52', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fde8883c-6f30-5975-9d29-19a6690d0160', '6999595e-b7f6-571d-9742-1176fedc7f52', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('5fbd8140-a91b-577f-8c9d-0b3d21bdc08b', 'e95c3fe0-7c53-5f55-9082-0f4dae04424f', 6, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 6

Questions 1-6
Questions 1-6
Do the following statements agree with the information given in Reading Passage 3?
Write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
1
The Romantic Movement lasted for more than a century.
2
The Romantic poets adopted a style dissimilar to that of poets who had come before them.
3
Unfortunately, the works of the Romantics had no lasting impression on art.
4
The Romantics had no respect for any style of poetry apart from their own.
5
The Romantics were gifted with a strong sense of imagination.
6
Much of the Romantics’ poetry was inspired by the natural world.

6 ____ Much of the Romantics’ poetry was inspired by the natural world.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ff1ad6d7-38ca-5b66-9c93-6e3d722cdd22', '5fbd8140-a91b-577f-8c9d-0b3d21bdc08b', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('45f21129-26e1-5d9a-8d8d-931e04635810', '5fbd8140-a91b-577f-8c9d-0b3d21bdc08b', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5231d0fe-acae-53c2-adf0-3d33f70ec0d2', '5fbd8140-a91b-577f-8c9d-0b3d21bdc08b', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('58289404-fd2b-57ab-b70f-c373d398e56f', 'e95c3fe0-7c53-5f55-9082-0f4dae04424f', 7, 'TABLE_COMPLETION', 'READING', 3, $md$### Question 7

Questions 7-13
Questions 7-13
Complete the table below
Write
NO MORE THAN THREE WORDS
for each answer.
Date of birth
Education
Byron
1788
Cambridge University
went on a journey around
7
; came to love
8
Shelley
1972
Eton and Oxford University
some people disapproved of
9
and the beliefs he held
Wordsworth
1770
became more accepted when he changed his
10
Coleridge
1772
bright scholar
his
11
was smaller than the other Romantic poets’; left the Wordsworths due to
12
Keats
1795
qualified as a surgeon
left England for a change of
13

went on a journey around 7 ____ ; came to love 8 ____$md$, NULL, ARRAY['.*the.*mediterranean.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('f4ebf093-eeac-549d-b52a-30867112616b', 'e95c3fe0-7c53-5f55-9082-0f4dae04424f', 8, 'TABLE_COMPLETION', 'READING', 3, $md$### Question 8

Questions 7-13
Questions 7-13
Complete the table below
Write
NO MORE THAN THREE WORDS
for each answer.
Date of birth
Education
Byron
1788
Cambridge University
went on a journey around
7
; came to love
8
Shelley
1972
Eton and Oxford University
some people disapproved of
9
and the beliefs he held
Wordsworth
1770
became more accepted when he changed his
10
Coleridge
1772
bright scholar
his
11
was smaller than the other Romantic poets’; left the Wordsworths due to
12
Keats
1795
qualified as a surgeon
left England for a change of
13

went on a journey around 7 ____ ; came to love 8 ____$md$, NULL, ARRAY['.*the.*mediterranean.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('65218f04-58e3-5d86-aaf4-d4c3dd6fc649', 'e95c3fe0-7c53-5f55-9082-0f4dae04424f', 9, 'TABLE_COMPLETION', 'READING', 3, $md$### Question 9

Questions 7-13
Questions 7-13
Complete the table below
Write
NO MORE THAN THREE WORDS
for each answer.
Date of birth
Education
Byron
1788
Cambridge University
went on a journey around
7
; came to love
8
Shelley
1972
Eton and Oxford University
some people disapproved of
9
and the beliefs he held
Wordsworth
1770
became more accepted when he changed his
10
Coleridge
1772
bright scholar
his
11
was smaller than the other Romantic poets’; left the Wordsworths due to
12
Keats
1795
qualified as a surgeon
left England for a change of
13

some people disapproved of 9 ____ and the beliefs he held$md$, NULL, ARRAY['.*his.*colourful.*lifestyle.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('eae5f3e2-7ca1-5b21-b89c-9b67abd816b8', 'e95c3fe0-7c53-5f55-9082-0f4dae04424f', 10, 'TABLE_COMPLETION', 'READING', 4, $md$### Question 10

Questions 7-13
Questions 7-13
Complete the table below
Write
NO MORE THAN THREE WORDS
for each answer.
Date of birth
Education
Byron
1788
Cambridge University
went on a journey around
7
; came to love
8
Shelley
1972
Eton and Oxford University
some people disapproved of
9
and the beliefs he held
Wordsworth
1770
became more accepted when he changed his
10
Coleridge
1772
bright scholar
his
11
was smaller than the other Romantic poets’; left the Wordsworths due to
12
Keats
1795
qualified as a surgeon
left England for a change of
13

became more accepted when he changed his 10 ____$md$, NULL, ARRAY['.*political.*views.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('f7918e70-6f3e-5e24-a824-61e66220e485', 'e95c3fe0-7c53-5f55-9082-0f4dae04424f', 11, 'TABLE_COMPLETION', 'READING', 4, $md$### Question 11

Questions 7-13
Questions 7-13
Complete the table below
Write
NO MORE THAN THREE WORDS
for each answer.
Date of birth
Education
Byron
1788
Cambridge University
went on a journey around
7
; came to love
8
Shelley
1972
Eton and Oxford University
some people disapproved of
9
and the beliefs he held
Wordsworth
1770
became more accepted when he changed his
10
Coleridge
1772
bright scholar
his
11
was smaller than the other Romantic poets’; left the Wordsworths due to
12
Keats
1795
qualified as a surgeon
left England for a change of
13

his 11 ____ was smaller than the other Romantic poets’; left the Wordsworths due to 12 ____$md$, NULL, ARRAY['.*output.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('703d2dab-5614-57c8-90fc-727c2f6e262e', 'e95c3fe0-7c53-5f55-9082-0f4dae04424f', 12, 'TABLE_COMPLETION', 'READING', 4, $md$### Question 12

Questions 7-13
Questions 7-13
Complete the table below
Write
NO MORE THAN THREE WORDS
for each answer.
Date of birth
Education
Byron
1788
Cambridge University
went on a journey around
7
; came to love
8
Shelley
1972
Eton and Oxford University
some people disapproved of
9
and the beliefs he held
Wordsworth
1770
became more accepted when he changed his
10
Coleridge
1772
bright scholar
his
11
was smaller than the other Romantic poets’; left the Wordsworths due to
12
Keats
1795
qualified as a surgeon
left England for a change of
13

his 11 ____ was smaller than the other Romantic poets’; left the Wordsworths due to 12 ____$md$, NULL, ARRAY['.*output.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('cdfffc05-11e4-5692-b670-421b85881307', 'e95c3fe0-7c53-5f55-9082-0f4dae04424f', 13, 'TABLE_COMPLETION', 'READING', 4, $md$### Question 13

Questions 7-13
Questions 7-13
Complete the table below
Write
NO MORE THAN THREE WORDS
for each answer.
Date of birth
Education
Byron
1788
Cambridge University
went on a journey around
7
; came to love
8
Shelley
1972
Eton and Oxford University
some people disapproved of
9
and the beliefs he held
Wordsworth
1770
became more accepted when he changed his
10
Coleridge
1772
bright scholar
his
11
was smaller than the other Romantic poets’; left the Wordsworths due to
12
Keats
1795
qualified as a surgeon
left England for a change of
13

left England for a change of 13 ____$md$, NULL, ARRAY['.*climate.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('73823aa4-bcef-5982-af6e-2b0e7316a709', 'e95c3fe0-7c53-5f55-9082-0f4dae04424f', 14, 'SENTENCE_COMPLETION', 'READING', 4, $md$### Question 14

Question 14
Question 14
Complete the sentence.
Choose
NO MORE THAN THREE WORDS
from the passage for the answer.
14
According to the writer, the Romantic poets left us with the ideas of

14 According to the writer, the Romantic poets left us with the ideas of ____$md$, NULL, ARRAY['.*individualism.*and.*imagination.*']);

COMMIT;
