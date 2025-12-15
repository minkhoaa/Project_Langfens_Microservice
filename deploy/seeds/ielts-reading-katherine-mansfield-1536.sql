BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-katherine-mansfield-1536'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-katherine-mansfield-1536';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-katherine-mansfield-1536';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-katherine-mansfield-1536';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('3fdee633-a377-560f-aea3-dbdf42c70446', 'ielts-reading-katherine-mansfield-1536', $t$Katherine Mansfield$t$, $md$## Katherine Mansfield

Nguồn:
- Test: https://mini-ielts.com/1536/reading/katherine-mansfield
- Solution: https://mini-ielts.com/1536/view-solution/reading/katherine-mansfield$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('d529480a-79c1-59af-b956-300c00e3d11a', '3fdee633-a377-560f-aea3-dbdf42c70446', 1, $t$Reading — Katherine Mansfield$t$, $md$Read the passage and answer questions **1–13**.

### Passage: Katherine Mansfield

Katherine Mansfield was a modernist writer of short fiction who was born and brought up in New Zealand

Katherine Mansfield Beauchamp Murry was born in 1888, into a prominent family in Wellington, New Zealand. She became one of New Zealand's best-known writers, using the pen name of Katherine Mansfield. The daughter of a banker, and born into a middle-class family, she was also a first cousin of Countess Elizabeth von Arnim, a distinguished novelist in her time. Mansfield had two older sisters and a younger brother. Her father, Harold Beauchamp, went on to become the chairman of the Bank of New Zealand. In 1893, the Mansfield family moved to Karori, a suburb of Wellington, where Mansfield would spend the happiest years of her childhood; she later used her memories of this time as an inspiration for her Prelude story.

Her first published stories appeared in the High School Reporter and the Wellington Girls 7 High School magazine in 1898 and 1899. In 1902, she developed strong feelings for a musician who played the cello, Arnold Trowell, although her feelings were not, for the most past, returned. Mansfield herself was an accomplished cellist, having received lesion from Trowell's father. Mansfied wrote in her journals of feeling isolated to some extent in New Zealand, and, in general terms of her interest in the Maori people ( New Zealand's native people), who were often portrayed in a sympathetic light in her later stories, such as How Pearl Button was Kidnapped

She moved to London in 1903, where she attended Queen's college, along with her two sisters. Manfield recommenced playing the cello, an occupation that she believed, during her time at Queen's, she would take up professionally. She also began contributing to the college newspaper, with such a dedication to it that she eventually became its editor. She was particularly interested in the works of the French writers of this period and on the 19 th - century British writer, Oscar Wilde, and she was appreciated amongst fellow students at Queen's for her lively and charismatic approach to life and work. She met follow writer Ida Baker, a South African, at the college, and the pair became lifelong friends. Mansfield did not actively support the suffragette movement in the Uk. Women in New Zeland had gained the right to vote in 1893.

Mansfield first began journeying into the other parts of Europe in the period 1903-1906, mainly to Belgium and Germany. After finishing her schooling in England, she returned to her New Zealand home in 1906, only then beginning to write short stories in a serious way. She had several works published in Australia in a magazine called Native Comparison, which was her first paid writing work, and by this time she had her mind set on becoming a professional writer. It was also the first occasion on which she used the pseudonym "k.Mansfied".

Mansfield rapidly grew discontented with the provincial New Zealand lifestyle, and with her family. Two years later she headed again in London. Her father sent her an annual subsidy of €100 for the rest of her life. In later years, she would express both admiration and disdain for New Zealand in her journals.

In 1911, Mansfield met John Middleton Murry, the Oxford scholar and editor of the literary magazine Rhythm. They were later to marry in 1918. Mansfield became a co-editor of Rhythm, which was subsequently called The Blue Review, in which more of her works were published. She and Murry lived in various houses in England and briefly in Paris. The Blue Review failed to gain enough readers and was no longer published. Their attempt to set up as writers in Paris was cut short by Murry's bankruptcy, which resulted from the failure of this and other journals. Life back in England meant frequently changed addresses and very limited funds.

Between 1915 and 1918, Mansfield moved between England and Bandoi, France. She and Murry developed close contact with other well-known writers of the time such as DH Lawrence, Bertrand Russell and Aldous Huxley. By October 1918 Mansfield had become seriously ill; she had been diagnosed with tuberculosis and was advised to enter a sanatorium. She could no longer spend time with writers in London. In the autumn of 1918 she was so ill that she decided to go to Ospedale in Italy. It was the publication of Bliss and Other Stories in 1920 that was to solidify Mansfield's reputation as a writer.

Mansfied also spent time in Menton, France, as the tenant of her father's cousin at " The Villa Isola Bella". There she wrote she pronounced to be "...the only story that satisfies me to any extent".

Mansfield produced a great deal of work in the final years of her life, and much of her prose and poetry remained unpublished at her death in 1923. After her death, her husband, Murry, took on the task of editing and publishing her works. His efforts resulted in two additional volumes of short stories. The Doves' Nest and Something Childish, published in 1923 and 1924 respectively, the publication of her Poems as well as a collection of critical writings (Novels and Novelist) and a number of editions of Mansfield's previously unpublished letters and journals.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('df09371a-2131-5292-9de9-78c7fc68d13f', 'd529480a-79c1-59af-b956-300c00e3d11a', 1, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 1

Questions 1-6
Questions 1-6
Do the following statements agree with the information given in Reading Passage 1?
In boxes 1 - 6 on your answer sheet, write
TRUE if the statement agrees with the information
FALSE if the statement contradicts the information
NOT GIVEN if there is no information on this
1
The name Katherine Mansfield, that appears on the writer's book, was exactly the same as her origin name
2
Mansfield won a prize for a story she wrote for the
High School Reporter.
3
How Pearl Button Was Kidnapped
portrayed Maori people in a favorable way.
4
when Mansfield was at Queen's college, she planned to be a professional writer.
5
Mansfield was unpopular with the other students at Queen's college
6
In London, Mansfield showed little interest in politics.

1 ____ The name Katherine Mansfield, that appears on the writer's book, was exactly the same as her origin name$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c214f183-0b7e-507d-823a-ae84a0530bd9', 'df09371a-2131-5292-9de9-78c7fc68d13f', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('583b4e83-c91b-5f63-9cdd-5622350aa17c', 'df09371a-2131-5292-9de9-78c7fc68d13f', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fb8f0745-62b0-5865-92d6-f6b676049947', 'df09371a-2131-5292-9de9-78c7fc68d13f', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('aaf0e38e-1a92-558a-9db0-f98af253d93c', 'd529480a-79c1-59af-b956-300c00e3d11a', 2, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 2

Questions 1-6
Questions 1-6
Do the following statements agree with the information given in Reading Passage 1?
In boxes 1 - 6 on your answer sheet, write
TRUE if the statement agrees with the information
FALSE if the statement contradicts the information
NOT GIVEN if there is no information on this
1
The name Katherine Mansfield, that appears on the writer's book, was exactly the same as her origin name
2
Mansfield won a prize for a story she wrote for the
High School Reporter.
3
How Pearl Button Was Kidnapped
portrayed Maori people in a favorable way.
4
when Mansfield was at Queen's college, she planned to be a professional writer.
5
Mansfield was unpopular with the other students at Queen's college
6
In London, Mansfield showed little interest in politics.

2 ____ Mansfield won a prize for a story she wrote for the High School Reporter.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('928fc580-4c4f-5fda-a70c-ac5b324d6a71', 'aaf0e38e-1a92-558a-9db0-f98af253d93c', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d078964d-d512-54a6-9059-f2d5c40f8449', 'aaf0e38e-1a92-558a-9db0-f98af253d93c', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('43c6c480-2cd4-557e-b35b-6b90d7afc691', 'aaf0e38e-1a92-558a-9db0-f98af253d93c', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('abd0254d-33b5-5270-a6ea-1d578ef270a5', 'd529480a-79c1-59af-b956-300c00e3d11a', 3, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 3

Questions 1-6
Questions 1-6
Do the following statements agree with the information given in Reading Passage 1?
In boxes 1 - 6 on your answer sheet, write
TRUE if the statement agrees with the information
FALSE if the statement contradicts the information
NOT GIVEN if there is no information on this
1
The name Katherine Mansfield, that appears on the writer's book, was exactly the same as her origin name
2
Mansfield won a prize for a story she wrote for the
High School Reporter.
3
How Pearl Button Was Kidnapped
portrayed Maori people in a favorable way.
4
when Mansfield was at Queen's college, she planned to be a professional writer.
5
Mansfield was unpopular with the other students at Queen's college
6
In London, Mansfield showed little interest in politics.

3 ____ How Pearl Button Was Kidnapped portrayed Maori people in a favorable way.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9fc4b2fa-db19-5cbf-b19f-37650a4139c0', 'abd0254d-33b5-5270-a6ea-1d578ef270a5', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a47a1c01-bb5f-543f-a3b6-b226720c6a94', 'abd0254d-33b5-5270-a6ea-1d578ef270a5', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a271ded2-565f-5008-a8cd-883316975462', 'abd0254d-33b5-5270-a6ea-1d578ef270a5', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('2e8b73e8-48fe-500e-a0f4-0717c9fbae9c', 'd529480a-79c1-59af-b956-300c00e3d11a', 4, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 4

Questions 1-6
Questions 1-6
Do the following statements agree with the information given in Reading Passage 1?
In boxes 1 - 6 on your answer sheet, write
TRUE if the statement agrees with the information
FALSE if the statement contradicts the information
NOT GIVEN if there is no information on this
1
The name Katherine Mansfield, that appears on the writer's book, was exactly the same as her origin name
2
Mansfield won a prize for a story she wrote for the
High School Reporter.
3
How Pearl Button Was Kidnapped
portrayed Maori people in a favorable way.
4
when Mansfield was at Queen's college, she planned to be a professional writer.
5
Mansfield was unpopular with the other students at Queen's college
6
In London, Mansfield showed little interest in politics.

4 ____ when Mansfield was at Queen's college, she planned to be a professional writer.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d1e8bc19-91a9-5e19-97d9-6db552a6244a', '2e8b73e8-48fe-500e-a0f4-0717c9fbae9c', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5964e141-3e77-5840-a1ee-6ccb0c4c1a61', '2e8b73e8-48fe-500e-a0f4-0717c9fbae9c', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('97e0f52d-744e-5f6e-94e9-dda2388b2ccc', '2e8b73e8-48fe-500e-a0f4-0717c9fbae9c', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('0f215200-3c01-5490-b02e-c97518dc342f', 'd529480a-79c1-59af-b956-300c00e3d11a', 5, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 5

Questions 1-6
Questions 1-6
Do the following statements agree with the information given in Reading Passage 1?
In boxes 1 - 6 on your answer sheet, write
TRUE if the statement agrees with the information
FALSE if the statement contradicts the information
NOT GIVEN if there is no information on this
1
The name Katherine Mansfield, that appears on the writer's book, was exactly the same as her origin name
2
Mansfield won a prize for a story she wrote for the
High School Reporter.
3
How Pearl Button Was Kidnapped
portrayed Maori people in a favorable way.
4
when Mansfield was at Queen's college, she planned to be a professional writer.
5
Mansfield was unpopular with the other students at Queen's college
6
In London, Mansfield showed little interest in politics.

5 ____ Mansfield was unpopular with the other students at Queen's college$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1238fcf8-6ab3-5455-95ac-7b39e85e0365', '0f215200-3c01-5490-b02e-c97518dc342f', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a621c969-4f1d-5ce2-bfb3-54cfdeeae676', '0f215200-3c01-5490-b02e-c97518dc342f', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7e39e6b3-0090-568d-8028-0265c841b652', '0f215200-3c01-5490-b02e-c97518dc342f', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('33152468-1b9e-5b16-90bd-0e284c341e72', 'd529480a-79c1-59af-b956-300c00e3d11a', 6, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 6

Questions 1-6
Questions 1-6
Do the following statements agree with the information given in Reading Passage 1?
In boxes 1 - 6 on your answer sheet, write
TRUE if the statement agrees with the information
FALSE if the statement contradicts the information
NOT GIVEN if there is no information on this
1
The name Katherine Mansfield, that appears on the writer's book, was exactly the same as her origin name
2
Mansfield won a prize for a story she wrote for the
High School Reporter.
3
How Pearl Button Was Kidnapped
portrayed Maori people in a favorable way.
4
when Mansfield was at Queen's college, she planned to be a professional writer.
5
Mansfield was unpopular with the other students at Queen's college
6
In London, Mansfield showed little interest in politics.

6 ____ In London, Mansfield showed little interest in politics.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b28be3ab-beba-506a-ba70-1759634ec03a', '33152468-1b9e-5b16-90bd-0e284c341e72', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('da5161c1-7f2c-58c9-aa26-13eebacda5c2', '33152468-1b9e-5b16-90bd-0e284c341e72', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3fe70270-749d-5015-ad01-47329131f349', '33152468-1b9e-5b16-90bd-0e284c341e72', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('1682a928-4913-5a79-9a72-27044e40f374', 'd529480a-79c1-59af-b956-300c00e3d11a', 7, 'NOTE_COMPLETION', 'READING', 3, $md$### Question 7

Questions 7-13
Questions 7-13
Complete the notes below
Choose
ONE WORD AND/OR A NUMBER
from the passage for each answer
Write your answers in boxes 7-13 on your answer sheet
Katherine Mansfield's adult years
7
- moved from England back to New Zealand
- first paid writing work was in a publication based in
8
- her
9
and
the New Zealand way of life made her feel dissatisfied
1908:
returned to London
1911-1919:
- Met John Middleton Murry in 1911
-
10
perverted.... Mansfield and Murry from staying together in Paris
- spent time with distinguished
11
- from 1916, tuberculosis restricted the time she spent in London
1920
her
12
was
consolidated when
Bliss and Other Stories
was published
wrote several stories at "Villa Isola Bella
1923-1924
Mansfield's
13
published
more of her works after her death

7 ____$md$, NULL, ARRAY['.*1906.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('a2cfef81-20a5-5bb4-afe9-3f879963e5f8', 'd529480a-79c1-59af-b956-300c00e3d11a', 8, 'NOTE_COMPLETION', 'READING', 3, $md$### Question 8

Questions 7-13
Questions 7-13
Complete the notes below
Choose
ONE WORD AND/OR A NUMBER
from the passage for each answer
Write your answers in boxes 7-13 on your answer sheet
Katherine Mansfield's adult years
7
- moved from England back to New Zealand
- first paid writing work was in a publication based in
8
- her
9
and
the New Zealand way of life made her feel dissatisfied
1908:
returned to London
1911-1919:
- Met John Middleton Murry in 1911
-
10
perverted.... Mansfield and Murry from staying together in Paris
- spent time with distinguished
11
- from 1916, tuberculosis restricted the time she spent in London
1920
her
12
was
consolidated when
Bliss and Other Stories
was published
wrote several stories at "Villa Isola Bella
1923-1924
Mansfield's
13
published
more of her works after her death

- first paid writing work was in a publication based in 8 ____$md$, NULL, ARRAY['.*australia.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('9a6dcc1d-1680-5207-b368-a781f558bc0b', 'd529480a-79c1-59af-b956-300c00e3d11a', 9, 'NOTE_COMPLETION', 'READING', 3, $md$### Question 9

Questions 7-13
Questions 7-13
Complete the notes below
Choose
ONE WORD AND/OR A NUMBER
from the passage for each answer
Write your answers in boxes 7-13 on your answer sheet
Katherine Mansfield's adult years
7
- moved from England back to New Zealand
- first paid writing work was in a publication based in
8
- her
9
and
the New Zealand way of life made her feel dissatisfied
1908:
returned to London
1911-1919:
- Met John Middleton Murry in 1911
-
10
perverted.... Mansfield and Murry from staying together in Paris
- spent time with distinguished
11
- from 1916, tuberculosis restricted the time she spent in London
1920
her
12
was
consolidated when
Bliss and Other Stories
was published
wrote several stories at "Villa Isola Bella
1923-1924
Mansfield's
13
published
more of her works after her death

- her 9 ____ and the New Zealand way of life made her feel dissatisfied$md$, NULL, ARRAY['.*family.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('83935843-c819-5e0c-ac02-936ac65a7559', 'd529480a-79c1-59af-b956-300c00e3d11a', 10, 'NOTE_COMPLETION', 'READING', 4, $md$### Question 10

Questions 7-13
Questions 7-13
Complete the notes below
Choose
ONE WORD AND/OR A NUMBER
from the passage for each answer
Write your answers in boxes 7-13 on your answer sheet
Katherine Mansfield's adult years
7
- moved from England back to New Zealand
- first paid writing work was in a publication based in
8
- her
9
and
the New Zealand way of life made her feel dissatisfied
1908:
returned to London
1911-1919:
- Met John Middleton Murry in 1911
-
10
perverted.... Mansfield and Murry from staying together in Paris
- spent time with distinguished
11
- from 1916, tuberculosis restricted the time she spent in London
1920
her
12
was
consolidated when
Bliss and Other Stories
was published
wrote several stories at "Villa Isola Bella
1923-1924
Mansfield's
13
published
more of her works after her death

- 10 ____ perverted.... Mansfield and Murry from staying together in Paris - spent time with distinguished 11 ____$md$, NULL, ARRAY['.*bankruptancy.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('51e43b04-2474-5941-9683-7200bf824ad3', 'd529480a-79c1-59af-b956-300c00e3d11a', 11, 'NOTE_COMPLETION', 'READING', 4, $md$### Question 11

Questions 7-13
Questions 7-13
Complete the notes below
Choose
ONE WORD AND/OR A NUMBER
from the passage for each answer
Write your answers in boxes 7-13 on your answer sheet
Katherine Mansfield's adult years
7
- moved from England back to New Zealand
- first paid writing work was in a publication based in
8
- her
9
and
the New Zealand way of life made her feel dissatisfied
1908:
returned to London
1911-1919:
- Met John Middleton Murry in 1911
-
10
perverted.... Mansfield and Murry from staying together in Paris
- spent time with distinguished
11
- from 1916, tuberculosis restricted the time she spent in London
1920
her
12
was
consolidated when
Bliss and Other Stories
was published
wrote several stories at "Villa Isola Bella
1923-1924
Mansfield's
13
published
more of her works after her death

- 10 ____ perverted.... Mansfield and Murry from staying together in Paris - spent time with distinguished 11 ____$md$, NULL, ARRAY['.*bankruptancy.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('40b21689-d2b0-52f1-babb-5b8ac479b6e4', 'd529480a-79c1-59af-b956-300c00e3d11a', 12, 'NOTE_COMPLETION', 'READING', 4, $md$### Question 12

Questions 7-13
Questions 7-13
Complete the notes below
Choose
ONE WORD AND/OR A NUMBER
from the passage for each answer
Write your answers in boxes 7-13 on your answer sheet
Katherine Mansfield's adult years
7
- moved from England back to New Zealand
- first paid writing work was in a publication based in
8
- her
9
and
the New Zealand way of life made her feel dissatisfied
1908:
returned to London
1911-1919:
- Met John Middleton Murry in 1911
-
10
perverted.... Mansfield and Murry from staying together in Paris
- spent time with distinguished
11
- from 1916, tuberculosis restricted the time she spent in London
1920
her
12
was
consolidated when
Bliss and Other Stories
was published
wrote several stories at "Villa Isola Bella
1923-1924
Mansfield's
13
published
more of her works after her death

her 12 ____ was consolidated when Bliss and Other Stories was published$md$, NULL, ARRAY['.*reputation.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('90a8e00a-dada-5fa9-9509-fe46a8d3d814', 'd529480a-79c1-59af-b956-300c00e3d11a', 13, 'NOTE_COMPLETION', 'READING', 4, $md$### Question 13

Questions 7-13
Questions 7-13
Complete the notes below
Choose
ONE WORD AND/OR A NUMBER
from the passage for each answer
Write your answers in boxes 7-13 on your answer sheet
Katherine Mansfield's adult years
7
- moved from England back to New Zealand
- first paid writing work was in a publication based in
8
- her
9
and
the New Zealand way of life made her feel dissatisfied
1908:
returned to London
1911-1919:
- Met John Middleton Murry in 1911
-
10
perverted.... Mansfield and Murry from staying together in Paris
- spent time with distinguished
11
- from 1916, tuberculosis restricted the time she spent in London
1920
her
12
was
consolidated when
Bliss and Other Stories
was published
wrote several stories at "Villa Isola Bella
1923-1924
Mansfield's
13
published
more of her works after her death

Mansfield's 13 ____ published more of her works after her death$md$, NULL, ARRAY['.*husband.*']);

COMMIT;
