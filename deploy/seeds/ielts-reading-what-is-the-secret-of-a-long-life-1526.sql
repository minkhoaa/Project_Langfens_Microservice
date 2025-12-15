BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-what-is-the-secret-of-a-long-life-1526'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-what-is-the-secret-of-a-long-life-1526';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-what-is-the-secret-of-a-long-life-1526';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-what-is-the-secret-of-a-long-life-1526';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('d0459416-54b1-5918-9523-7ac8fae97bf0', 'ielts-reading-what-is-the-secret-of-a-long-life-1526', $t$What is the secret of a long life?$t$, $md$## What is the secret of a long life?

Nguồn:
- Test: https://mini-ielts.com/1526/reading/what-is-the-secret-of-a-long-life
- Solution: https://mini-ielts.com/1526/view-solution/reading/what-is-the-secret-of-a-long-life$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('fd4eabb5-e6eb-509d-a5a2-d1e7583ef7b4', 'd0459416-54b1-5918-9523-7ac8fae97bf0', 1, $t$Reading — What is the secret of a long life?$t$, $md$Read the passage and answer questions **1–13**.

### Passage: What is the secret of a long life?

This year, the number of retired pensioners in the UK exceeded the number of under 18 years old for the first time in history. That's remarkable in its own right, but the real 'population explosion' has been among the oldest of the old — the centenarians. In fact, this imbalance is the fastest growing demographic in much of the developed world. In the UK, the number of centenarians has increased by 60 per cent since the early 20th century. And their ranks are set swell even further, thanks to the ageing baby-boomer generation: by 2030 there will be about a million worldwide.

These trends raise social, ethical and economic dilemmas. Are medical advances artificially prolonging life, with hide regard for the quality of that life? If growing numbers of elderly people become dependent on state or familial support, society faces skyrocketing costs and commitments. Yet researchers who study the oldest old have made a surprising discovery that presents a less pessimistic view of the future than many anticipate.

It is becoming clear that people who break through the 90-plus barrier represent a physical elite. Far from gaining a longer burden of disability, their extra years tend to be healthy ones. And supercentenarians, people aged 110 or over, are even better examples of ageing well. The average supercentenarian had freely gone about their daily life up until the age of 105 or so, some five to ten years longer even than centenarians.

One of the most comprehensive studies comes from Denmark. In 1998 Kare Christensen, at the University of Southern Denmark, contacted every single one of 3600 people born in 1905 who was still alive. Assessing their health over the subsequent decade, he found that the proportion of people who managed to remain independent throughout was constantly around one-third of the total. Each individual risked becoming more infirm, but the unhealthiest ones passed away at earlier ages, leaving the strongest behind. In 2005, only 166 of the people in Christensen's sample were still alive, but one-third of those were still entirely self-sufficient.

Christensen's optimistic findings are echoed in studies all over the world. In the MC, Carol Brayne at the University of Cambridge studied 958 people aged over 90, and found that only one-quarter of them were living in accommodation specifically catering for the needs of older people. Research in China reveals that centenarians and nonagenarians spend fewer days ill and in bed than younger elderly groups. Of course, people can live independently without being entirely healthy, and it is true that most centenarians suffer from some kind of ailment. These range from osteoarthritis to simple loneliness.

Not all the oldest old survive by delaying illness or disability, though. Many soldier through it. Jessica Even of Ohio State University examined the medical histories of over 400 centenarians. She found that those who achieve extreme longevity tend to fall into three categories. About 40 per cent were 'delayers', who avoided chronic diseases until after the age of 80. Another 40 per cent were 'survivors', who suffered from chronic diseases before the age of 80 but lived longer to tell the tale. The final 20 per cent were 'escapers', who reached their century with no sign of the most common chronic diseases. Intriguingly, one-third of male centenarians were in this category, compared with only 15 per cent of women. In fact, the two sexes fare very differently when it comes to longevity. There are far more female centenarians, but the reasons for this are unclear. Certainly, women tend to lead healthier lifestyles and experience fewer serious accidents. They also go to their doctor more. Men are more prone to risky behaviour and chronic illness, so it must be genetics which allows some men to reach extreme old age. Evidence of this comes from longevity hotspots.

The Japanese island of Okinawa is the front runner. At 58 centenarians per 100,000 people, it has the world's highest proportion in this age group, with Sardinia and Iceland not too far behind. All three are relatively isolated island communities, which leads to less genetic variation amongst inhabitants. In these places, the result has been a predisposition towards a longer life. Of course, members of such communities usually share a particular environment, too, but this alone cannot explain longevity. Gerontologists have emphasised the importance of regular exercise, so anyone aiming to reach a century should not underestimate this. They have also found that the influence on lifespan of social factors such as wealth fades as we age. By comparing 10,000 pairs of Scandinavian twins, Christensen found that genes are key, but that they only start exerting a strong influence on our lifespan after the age of 60. Before then, those who are both identical and non­identical have largely independent chances of reaching a given age.

Longevity genes have also been found in abundance in other organisms, including over 70 in particular worms. Unfortunately, it's a different story in humans. While many genes have been suggested to affect lifespan, very few have been consistently verified in multiple populations.

Note:

1 .’’Centenarian”: someone who is 100 years or older.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('f74732ae-3e4e-5962-a3e1-8f912cf28842', 'fd4eabb5-e6eb-509d-a5a2-d1e7583ef7b4', 1, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 1

Questions 1-7
Questions 1-7
Do the following statements agree with the information given in the Reading Passage?
In boxes 1-7 on your answer sheet, write
TRUE if the statement agrees with the information
FALSE if the statement contradicts the information
NOT GIVEN if there is no information on this
1
The greatest growth in the centenarian population across the world is in the UK.
2
Fewer families today are looking after their elderly members.
3
People who live beyond 90 years old are likely to be in good health.
4
Centenarians tend to be in better physical health than supercentenarians.
5
None of the oldest survivors in Christensen's study could take care of themselves.
6
Research findings from Cambridge and China conflicted with Christensen's findings in Denmark.
7
Centenarians may suffer from stronger feelings of isolation than people a generation younger.

1 ____ The greatest growth in the centenarian population across the world is in the UK.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5fd6ddb3-ec5d-56cd-a5b6-f7bfac527097', 'f74732ae-3e4e-5962-a3e1-8f912cf28842', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('630f7d93-f4ac-5e62-bf3e-1e3b5a4dcfa2', 'f74732ae-3e4e-5962-a3e1-8f912cf28842', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('87417d8c-1b6a-558d-b7c2-163cb796f320', 'f74732ae-3e4e-5962-a3e1-8f912cf28842', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('f2756cbf-e45a-5a8f-981c-4efbfe8f9f51', 'fd4eabb5-e6eb-509d-a5a2-d1e7583ef7b4', 2, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 2

Questions 1-7
Questions 1-7
Do the following statements agree with the information given in the Reading Passage?
In boxes 1-7 on your answer sheet, write
TRUE if the statement agrees with the information
FALSE if the statement contradicts the information
NOT GIVEN if there is no information on this
1
The greatest growth in the centenarian population across the world is in the UK.
2
Fewer families today are looking after their elderly members.
3
People who live beyond 90 years old are likely to be in good health.
4
Centenarians tend to be in better physical health than supercentenarians.
5
None of the oldest survivors in Christensen's study could take care of themselves.
6
Research findings from Cambridge and China conflicted with Christensen's findings in Denmark.
7
Centenarians may suffer from stronger feelings of isolation than people a generation younger.

2 ____ Fewer families today are looking after their elderly members.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c58937ab-7e37-59de-ba4b-cb47e139c171', 'f2756cbf-e45a-5a8f-981c-4efbfe8f9f51', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ef275799-40ed-5cfd-9f15-de370b6ad4b8', 'f2756cbf-e45a-5a8f-981c-4efbfe8f9f51', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f7368bce-350c-57ef-8d35-9b6240391864', 'f2756cbf-e45a-5a8f-981c-4efbfe8f9f51', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('16055268-59e9-5b0f-9047-a0957e22c9cc', 'fd4eabb5-e6eb-509d-a5a2-d1e7583ef7b4', 3, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 3

Questions 1-7
Questions 1-7
Do the following statements agree with the information given in the Reading Passage?
In boxes 1-7 on your answer sheet, write
TRUE if the statement agrees with the information
FALSE if the statement contradicts the information
NOT GIVEN if there is no information on this
1
The greatest growth in the centenarian population across the world is in the UK.
2
Fewer families today are looking after their elderly members.
3
People who live beyond 90 years old are likely to be in good health.
4
Centenarians tend to be in better physical health than supercentenarians.
5
None of the oldest survivors in Christensen's study could take care of themselves.
6
Research findings from Cambridge and China conflicted with Christensen's findings in Denmark.
7
Centenarians may suffer from stronger feelings of isolation than people a generation younger.

3 ____ People who live beyond 90 years old are likely to be in good health.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f1fa77b7-e8f7-5df4-9e12-fe753881e9a0', '16055268-59e9-5b0f-9047-a0957e22c9cc', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2d9f6fdb-c453-5550-9ac8-fe69bf9cc04e', '16055268-59e9-5b0f-9047-a0957e22c9cc', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('44fea0e4-14c4-5109-8a8d-769a10fc97aa', '16055268-59e9-5b0f-9047-a0957e22c9cc', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('f496b322-fcdf-5dfa-b2af-8ea2dc3e6f2f', 'fd4eabb5-e6eb-509d-a5a2-d1e7583ef7b4', 4, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 4

Questions 1-7
Questions 1-7
Do the following statements agree with the information given in the Reading Passage?
In boxes 1-7 on your answer sheet, write
TRUE if the statement agrees with the information
FALSE if the statement contradicts the information
NOT GIVEN if there is no information on this
1
The greatest growth in the centenarian population across the world is in the UK.
2
Fewer families today are looking after their elderly members.
3
People who live beyond 90 years old are likely to be in good health.
4
Centenarians tend to be in better physical health than supercentenarians.
5
None of the oldest survivors in Christensen's study could take care of themselves.
6
Research findings from Cambridge and China conflicted with Christensen's findings in Denmark.
7
Centenarians may suffer from stronger feelings of isolation than people a generation younger.

4 ____ Centenarians tend to be in better physical health than supercentenarians.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8debc5ba-ab64-5eaf-ba33-d85149b82383', 'f496b322-fcdf-5dfa-b2af-8ea2dc3e6f2f', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f4998c27-8159-588c-b03c-49b512d83e8b', 'f496b322-fcdf-5dfa-b2af-8ea2dc3e6f2f', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ce25d121-9f68-540d-82f0-5204325999f2', 'f496b322-fcdf-5dfa-b2af-8ea2dc3e6f2f', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('72b6291a-b690-5eec-ae2c-639b067b971f', 'fd4eabb5-e6eb-509d-a5a2-d1e7583ef7b4', 5, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 5

Questions 1-7
Questions 1-7
Do the following statements agree with the information given in the Reading Passage?
In boxes 1-7 on your answer sheet, write
TRUE if the statement agrees with the information
FALSE if the statement contradicts the information
NOT GIVEN if there is no information on this
1
The greatest growth in the centenarian population across the world is in the UK.
2
Fewer families today are looking after their elderly members.
3
People who live beyond 90 years old are likely to be in good health.
4
Centenarians tend to be in better physical health than supercentenarians.
5
None of the oldest survivors in Christensen's study could take care of themselves.
6
Research findings from Cambridge and China conflicted with Christensen's findings in Denmark.
7
Centenarians may suffer from stronger feelings of isolation than people a generation younger.

5 ____ None of the oldest survivors in Christensen's study could take care of themselves.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('39c584b1-3b93-5b21-bec3-26223fe7cc77', '72b6291a-b690-5eec-ae2c-639b067b971f', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f4363fb0-6c1c-5856-919a-0b02b05dc6c4', '72b6291a-b690-5eec-ae2c-639b067b971f', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('688dc8a5-ade7-5a2f-8123-256f2ca5c8ba', '72b6291a-b690-5eec-ae2c-639b067b971f', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('a7eba0cb-b3de-53d6-9fda-5a5fa44fe7a9', 'fd4eabb5-e6eb-509d-a5a2-d1e7583ef7b4', 6, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 6

Questions 1-7
Questions 1-7
Do the following statements agree with the information given in the Reading Passage?
In boxes 1-7 on your answer sheet, write
TRUE if the statement agrees with the information
FALSE if the statement contradicts the information
NOT GIVEN if there is no information on this
1
The greatest growth in the centenarian population across the world is in the UK.
2
Fewer families today are looking after their elderly members.
3
People who live beyond 90 years old are likely to be in good health.
4
Centenarians tend to be in better physical health than supercentenarians.
5
None of the oldest survivors in Christensen's study could take care of themselves.
6
Research findings from Cambridge and China conflicted with Christensen's findings in Denmark.
7
Centenarians may suffer from stronger feelings of isolation than people a generation younger.

6 ____ Research findings from Cambridge and China conflicted with Christensen's findings in Denmark.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('10e597f7-f481-5e21-9a0c-67e39a3e3bfe', 'a7eba0cb-b3de-53d6-9fda-5a5fa44fe7a9', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7be033a4-7d5f-571d-9e40-6fbccd074f38', 'a7eba0cb-b3de-53d6-9fda-5a5fa44fe7a9', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6ac11dfd-619e-546c-bdfe-280f4d3bfa99', 'a7eba0cb-b3de-53d6-9fda-5a5fa44fe7a9', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('d8b47ed0-d811-51b9-8971-be70304f43f6', 'fd4eabb5-e6eb-509d-a5a2-d1e7583ef7b4', 7, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 7

Questions 1-7
Questions 1-7
Do the following statements agree with the information given in the Reading Passage?
In boxes 1-7 on your answer sheet, write
TRUE if the statement agrees with the information
FALSE if the statement contradicts the information
NOT GIVEN if there is no information on this
1
The greatest growth in the centenarian population across the world is in the UK.
2
Fewer families today are looking after their elderly members.
3
People who live beyond 90 years old are likely to be in good health.
4
Centenarians tend to be in better physical health than supercentenarians.
5
None of the oldest survivors in Christensen's study could take care of themselves.
6
Research findings from Cambridge and China conflicted with Christensen's findings in Denmark.
7
Centenarians may suffer from stronger feelings of isolation than people a generation younger.

7 ____ Centenarians may suffer from stronger feelings of isolation than people a generation younger.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f0c37939-2a18-51e3-a515-7ee9d5dac168', 'd8b47ed0-d811-51b9-8971-be70304f43f6', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2a7aed0a-b2c0-5ee2-9064-7ba00bc8a66a', 'd8b47ed0-d811-51b9-8971-be70304f43f6', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b6b18cf7-4329-5675-9a1f-2730e991d282', 'd8b47ed0-d811-51b9-8971-be70304f43f6', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('4f98277f-883d-5e37-85f8-bf80936dd20d', 'fd4eabb5-e6eb-509d-a5a2-d1e7583ef7b4', 8, 'SHORT_ANSWER', 'READING', 3, $md$### Question 8

Questions 8-13
Questions 8-13
Answer the questions below.
Choose ONE WORD ONLY from the passage for each answer
Write your answers in boxes 8-13 on your answer sheet.
8. What name has Jessica Evert given to the category of centenarians who become 100 without suffering serious disease?
8
9. What factor is most likely to contribute to longevity in men?
9
10. Which place has the largest proportion of centenarians in the world?
10
11. According to gerontologists, what should people avoid neglecting if they wish to reach old age?
11
12. What social influence on longevity decreases as people get older?
12
13. In which species, apart from humans, have longevity genes been reliably identified?
13

8. What name has Jessica Evert given to the category of centenarians who become 100 without suffering serious disease? 8 ____$md$, NULL, ARRAY['.*escapers.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('099c8ab8-fff3-5c0d-94b6-dc82bc94de6c', 'fd4eabb5-e6eb-509d-a5a2-d1e7583ef7b4', 9, 'SHORT_ANSWER', 'READING', 3, $md$### Question 9

Questions 8-13
Questions 8-13
Answer the questions below.
Choose ONE WORD ONLY from the passage for each answer
Write your answers in boxes 8-13 on your answer sheet.
8. What name has Jessica Evert given to the category of centenarians who become 100 without suffering serious disease?
8
9. What factor is most likely to contribute to longevity in men?
9
10. Which place has the largest proportion of centenarians in the world?
10
11. According to gerontologists, what should people avoid neglecting if they wish to reach old age?
11
12. What social influence on longevity decreases as people get older?
12
13. In which species, apart from humans, have longevity genes been reliably identified?
13

9. What factor is most likely to contribute to longevity in men? 9 ____$md$, NULL, ARRAY['.*genetics.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('ec0ffda0-2234-542f-a1f1-c01b271334ee', 'fd4eabb5-e6eb-509d-a5a2-d1e7583ef7b4', 10, 'SHORT_ANSWER', 'READING', 4, $md$### Question 10

Questions 8-13
Questions 8-13
Answer the questions below.
Choose ONE WORD ONLY from the passage for each answer
Write your answers in boxes 8-13 on your answer sheet.
8. What name has Jessica Evert given to the category of centenarians who become 100 without suffering serious disease?
8
9. What factor is most likely to contribute to longevity in men?
9
10. Which place has the largest proportion of centenarians in the world?
10
11. According to gerontologists, what should people avoid neglecting if they wish to reach old age?
11
12. What social influence on longevity decreases as people get older?
12
13. In which species, apart from humans, have longevity genes been reliably identified?
13

10. Which place has the largest proportion of centenarians in the world? 10 ____$md$, NULL, ARRAY['.*okinawa.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('f0b64e65-4392-5053-aa80-72e622da93e4', 'fd4eabb5-e6eb-509d-a5a2-d1e7583ef7b4', 11, 'SHORT_ANSWER', 'READING', 4, $md$### Question 11

Questions 8-13
Questions 8-13
Answer the questions below.
Choose ONE WORD ONLY from the passage for each answer
Write your answers in boxes 8-13 on your answer sheet.
8. What name has Jessica Evert given to the category of centenarians who become 100 without suffering serious disease?
8
9. What factor is most likely to contribute to longevity in men?
9
10. Which place has the largest proportion of centenarians in the world?
10
11. According to gerontologists, what should people avoid neglecting if they wish to reach old age?
11
12. What social influence on longevity decreases as people get older?
12
13. In which species, apart from humans, have longevity genes been reliably identified?
13

11. According to gerontologists, what should people avoid neglecting if they wish to reach old age? 11 ____$md$, NULL, ARRAY['.*exercise.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('d5f07f4d-4a57-5989-890a-1ffeb8185384', 'fd4eabb5-e6eb-509d-a5a2-d1e7583ef7b4', 12, 'SHORT_ANSWER', 'READING', 4, $md$### Question 12

Questions 8-13
Questions 8-13
Answer the questions below.
Choose ONE WORD ONLY from the passage for each answer
Write your answers in boxes 8-13 on your answer sheet.
8. What name has Jessica Evert given to the category of centenarians who become 100 without suffering serious disease?
8
9. What factor is most likely to contribute to longevity in men?
9
10. Which place has the largest proportion of centenarians in the world?
10
11. According to gerontologists, what should people avoid neglecting if they wish to reach old age?
11
12. What social influence on longevity decreases as people get older?
12
13. In which species, apart from humans, have longevity genes been reliably identified?
13

12. What social influence on longevity decreases as people get older? 12 ____$md$, NULL, ARRAY['.*wealth.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('13324613-1cd0-5241-a1f8-e7f9429dbc9d', 'fd4eabb5-e6eb-509d-a5a2-d1e7583ef7b4', 13, 'SHORT_ANSWER', 'READING', 4, $md$### Question 13

Questions 8-13
Questions 8-13
Answer the questions below.
Choose ONE WORD ONLY from the passage for each answer
Write your answers in boxes 8-13 on your answer sheet.
8. What name has Jessica Evert given to the category of centenarians who become 100 without suffering serious disease?
8
9. What factor is most likely to contribute to longevity in men?
9
10. Which place has the largest proportion of centenarians in the world?
10
11. According to gerontologists, what should people avoid neglecting if they wish to reach old age?
11
12. What social influence on longevity decreases as people get older?
12
13. In which species, apart from humans, have longevity genes been reliably identified?
13

13. In which species, apart from humans, have longevity genes been reliably identified? 13 ____$md$, NULL, ARRAY['.*worms.*']);

COMMIT;
