BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-learning-to-walk-1517'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-learning-to-walk-1517';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-learning-to-walk-1517';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-learning-to-walk-1517';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('f93c8b73-212d-5b60-a8ca-f04812b23c5d', 'ielts-reading-learning-to-walk-1517', $t$Learning to Walk$t$, $md$## Learning to Walk

Nguồn:
- Test: https://mini-ielts.com/1517/reading/learning-to-walk
- Solution: https://mini-ielts.com/1517/view-solution/reading/learning-to-walk$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('ef56caf5-6f0c-50aa-9d34-15c294cfb6bd', 'f93c8b73-212d-5b60-a8ca-f04812b23c5d', 1, $t$Reading — Learning to Walk$t$, $md$Read the passage and answer questions **1–14**.

### Passage: Learning to Walk

These days the feet of a typical city dweller rarely encounter terrain any more uneven than a crack in the pavement. While that may not seem like a problem, it turns out that by flattening our urban environment we have put ourselves at risk of a surprising number of chronic illnesses and disabilities. Fortunately, the commercial market has come to the rescue with a choice of products. Research into the idea that flat floors could be detrimental to our health was pioneered back in the late 1960s in Long Beach, California. Podiatrist Charles Brantingham and physiologist Bruce Beekman were concerned with the growing epidemic of high blood pressure, varicose veins and deep-vein thromboses and reckoned they might be linked to the uniformity of the surfaces that we tend to stand and walk on.

The trouble, they believed, was that walking continuously on flat floors, sidewalks and streets concentrates forces on just a few areas of the foot. As a result, these surfaces are likely to be far more conducive to chronic stress syndromes than natural surfaces, where the foot meets the ground in a wide variety of orientations. They understood that the anatomy of the foot parallels that of the human hand - each having 26 bones, 33 joints and more than 100 muscles, tendons and ligaments - and that modern lifestyles waste all this potential flexibility.

Brantingham and Beekman became convinced that the damage could be rectified by making people wobble. To test their ideas, they got 65 factory workers to try standing on a variable terrain floor - spongy mats with varying degrees of resistance across the surface. This modest irregularity allowed the soles of the volunteers' feet to deviate slightly from the horizontal each time they shifted position. As the researchers hoped, this simple intervention made a huge difference, within a few weeks. Even if people were wobbling slightly, it activated a host of muscles in their legs, which in turn helped pump blood back to their hearts. The muscle action prevented the pooling of blood in their feet and legs, reducing the stress on the heart and circulation. Yet decades later, the flooring of the world's largest workplaces remains relentlessly smooth. Earlier this year, however, the idea was revived when other researchers in the US announced findings from a similar experiment with people over 60. John Fisher and colleagues at the Oregon Research Institute in Eugene designed a mat intended to replicate the effect of walking on cobblestones*.

In tests funded by the National Institute of Aging, they got some 50 adults to walk on the toots in their bare feet for less than an hour, three times a week. After 16 weeks, these people showed marked improvements in mobility, and even a significant reduction in blood pressure. People in a control group who walked on ordinary floors also improved but not as dramatically. The mats are now available for purchase and production is being scaled up. Even so, demand could exceed supply if this footstimulating activity really is a 'useful nonpharmacological approach for preventing or controlling hypertension of older adults, as the researchers believe. They are not alone in recognising the benefits of cobblestones. Reflexologists have long advocated walking on textured surfaces to stimulate so-called 'acupoints' on the soles of the feet. They believe that pressure applied to particular spots on the foot connects directly to particular organs of the body and somehow enhances their function. In China, spas, apartment blocks and even factories promote their cobblestone paths as healthful amenities. Fisher admits he got the concept from regular visits to the country. Here, city dwellers take daily walks along cobbled paths for five or ten minutes, perhaps several times a day, to improve their health. The idea is now taking off in Europe too.

People in Germany, Austria and Switzerland can now visit 'barefoot parks' and walk along 'paths of the senses - with mud, logs, stone and moss underfoot. And it is not difficult to construct your own path with simple everyday objects such as stones or bamboo poles. But if none of these solutions appeal, there is another option. A new shoe on the market claims to transform flat, hard, artificial surfaces into something like uneven ground. 'These shoes have an unbelievable effect,' says Benno Nigg, an exercise scientist at Calgary University in Canada.

Known as the Masai Barefoot Technology, the shoes have rounded soles that cause you to rock slightly when you stand still, exercising the small muscles around the ankle that are responsible for stability. Forces in the joint are reduced, putting less strain on the system, Nigg claims.

Some of these options may not appeal to all consumers and there is a far simpler alternative.

If the urban environment is detrimental to our health, then it is obvious where we should turn. A weekend or even a few hours spent in the countryside could help alleviate a sufferer's aches and pains, and would require only the spending of time.

However, for many modern citizens, the countryside is not as accessible as it once was and is in fact a dwindling resource. Our concrete cities are growing at a terrifying rate - perhaps at the same rate as our health problems.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('a3d09471-b121-5af3-bee6-073c3d8322a2', 'ef56caf5-6f0c-50aa-9d34-15c294cfb6bd', 1, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 1

Questions 1-5
Questions 1-5
Do the following statements agree with the information given in Reading Passage?
In boxes 1-5 on your answer sheet, write
TRUE if the statement agrees with the information
FALSE if the statement contradicts the information
NOT GIVEN if there is no information on this
1
Brantingham and Beekman were the first researchers to investigate the relationship between health problems and flat floors.
2
The subjects in Fisher's control group experienced a decline in their physical condition.
3
The manufacturers are increasing the number of cobblestone mats they are making.
4
Fisher based his ideas on what he saw during an overseas trip.
5
The Masai Barefoot Technology shoes are made to fit people of all ages.

1 ____ Brantingham and Beekman were the first researchers to investigate the relationship between health problems and flat floors.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b32ae898-ee3e-5d71-808c-c9ab22763165', 'a3d09471-b121-5af3-bee6-073c3d8322a2', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c5a33f16-c7f2-5711-9977-8a037f9d2d1a', 'a3d09471-b121-5af3-bee6-073c3d8322a2', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fc99eeac-158a-5d84-abd4-282aaf68ef78', 'a3d09471-b121-5af3-bee6-073c3d8322a2', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('071b8679-05e5-5bd8-a1ec-2c8e33272909', 'ef56caf5-6f0c-50aa-9d34-15c294cfb6bd', 2, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 2

Questions 1-5
Questions 1-5
Do the following statements agree with the information given in Reading Passage?
In boxes 1-5 on your answer sheet, write
TRUE if the statement agrees with the information
FALSE if the statement contradicts the information
NOT GIVEN if there is no information on this
1
Brantingham and Beekman were the first researchers to investigate the relationship between health problems and flat floors.
2
The subjects in Fisher's control group experienced a decline in their physical condition.
3
The manufacturers are increasing the number of cobblestone mats they are making.
4
Fisher based his ideas on what he saw during an overseas trip.
5
The Masai Barefoot Technology shoes are made to fit people of all ages.

2 ____ The subjects in Fisher's control group experienced a decline in their physical condition.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('76c99f2c-102b-5a97-8ff6-21f90c0d0a7f', '071b8679-05e5-5bd8-a1ec-2c8e33272909', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('583a2519-ac41-598b-a1dd-ffd95e603e5c', '071b8679-05e5-5bd8-a1ec-2c8e33272909', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e94c5d1f-65b4-5659-993d-648994391d56', '071b8679-05e5-5bd8-a1ec-2c8e33272909', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('76c99c95-e473-57ae-b537-ea79e74af8c1', 'ef56caf5-6f0c-50aa-9d34-15c294cfb6bd', 3, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 3

Questions 1-5
Questions 1-5
Do the following statements agree with the information given in Reading Passage?
In boxes 1-5 on your answer sheet, write
TRUE if the statement agrees with the information
FALSE if the statement contradicts the information
NOT GIVEN if there is no information on this
1
Brantingham and Beekman were the first researchers to investigate the relationship between health problems and flat floors.
2
The subjects in Fisher's control group experienced a decline in their physical condition.
3
The manufacturers are increasing the number of cobblestone mats they are making.
4
Fisher based his ideas on what he saw during an overseas trip.
5
The Masai Barefoot Technology shoes are made to fit people of all ages.

3 ____ The manufacturers are increasing the number of cobblestone mats they are making.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('113952f5-eca9-5205-9b7b-12fee3d3d917', '76c99c95-e473-57ae-b537-ea79e74af8c1', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a1351027-e0b9-5752-9b7b-6a530e64ab6c', '76c99c95-e473-57ae-b537-ea79e74af8c1', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3c229856-65d7-5ed3-bb47-684deb12d5f2', '76c99c95-e473-57ae-b537-ea79e74af8c1', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('2ded81c3-e461-5b5c-b04e-392989902a49', 'ef56caf5-6f0c-50aa-9d34-15c294cfb6bd', 4, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 4

Questions 1-5
Questions 1-5
Do the following statements agree with the information given in Reading Passage?
In boxes 1-5 on your answer sheet, write
TRUE if the statement agrees with the information
FALSE if the statement contradicts the information
NOT GIVEN if there is no information on this
1
Brantingham and Beekman were the first researchers to investigate the relationship between health problems and flat floors.
2
The subjects in Fisher's control group experienced a decline in their physical condition.
3
The manufacturers are increasing the number of cobblestone mats they are making.
4
Fisher based his ideas on what he saw during an overseas trip.
5
The Masai Barefoot Technology shoes are made to fit people of all ages.

4 ____ Fisher based his ideas on what he saw during an overseas trip.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f208dcc9-9110-5102-baa5-d44df0fe716b', '2ded81c3-e461-5b5c-b04e-392989902a49', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9b1e0d08-0727-5376-817a-8d8807a9cb8a', '2ded81c3-e461-5b5c-b04e-392989902a49', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('22eac505-ec48-5ed8-a952-ce03ad94dfdb', '2ded81c3-e461-5b5c-b04e-392989902a49', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('02bc2449-b4ed-58a8-9e2d-f044232ed736', 'ef56caf5-6f0c-50aa-9d34-15c294cfb6bd', 5, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 5

Questions 1-5
Questions 1-5
Do the following statements agree with the information given in Reading Passage?
In boxes 1-5 on your answer sheet, write
TRUE if the statement agrees with the information
FALSE if the statement contradicts the information
NOT GIVEN if there is no information on this
1
Brantingham and Beekman were the first researchers to investigate the relationship between health problems and flat floors.
2
The subjects in Fisher's control group experienced a decline in their physical condition.
3
The manufacturers are increasing the number of cobblestone mats they are making.
4
Fisher based his ideas on what he saw during an overseas trip.
5
The Masai Barefoot Technology shoes are made to fit people of all ages.

5 ____ The Masai Barefoot Technology shoes are made to fit people of all ages.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d4282c43-90d0-54ad-891e-18379efd031f', '02bc2449-b4ed-58a8-9e2d-f044232ed736', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0f6eea43-8f71-5580-b0d6-39cb6e2b204c', '02bc2449-b4ed-58a8-9e2d-f044232ed736', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a2f38aa9-5692-5cbc-8077-95993e6e0cb3', '02bc2449-b4ed-58a8-9e2d-f044232ed736', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('886c2964-5bb6-5d93-9a38-60e8af8abf80', 'ef56caf5-6f0c-50aa-9d34-15c294cfb6bd', 6, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 6

Questions 6-8
Questions 6-8
Choose the correct letter, A, B, C or D.
Write the correct letter in boxes 6-8 on your answer sheet.
6. The writer suggests that Brantingham and Beekman's findings were
A
ignored by big companies.
B
doubted by other researchers.
C
applicable to a narrow range of people.
D
surprising to them.
7. What claim is made by the designers of the cobblestone mats"?
A
They need to be used continuously in order to have a lasting effect.
B
They would be as beneficial to younger people as to older people.
C
They could be an effective alternative to medical intervention.
D
Their effects may vary depending on individual users.
8. Which of the following points does the writer make in the final paragraph?
A
People should question new theories that scientists put forward.
B
High prices do not necessarily equate to a quality product.
C
People are setting up home in the country for health reasons.
D
The natural environment is fast disappearing.

Choose the correct letter, A, B, C or D.$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('1cf2dfff-0d33-5a57-b7d3-84c10c547f15', 'ef56caf5-6f0c-50aa-9d34-15c294cfb6bd', 7, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 7

Questions 6-8
Questions 6-8
Choose the correct letter, A, B, C or D.
Write the correct letter in boxes 6-8 on your answer sheet.
6. The writer suggests that Brantingham and Beekman's findings were
A
ignored by big companies.
B
doubted by other researchers.
C
applicable to a narrow range of people.
D
surprising to them.
7. What claim is made by the designers of the cobblestone mats"?
A
They need to be used continuously in order to have a lasting effect.
B
They would be as beneficial to younger people as to older people.
C
They could be an effective alternative to medical intervention.
D
Their effects may vary depending on individual users.
8. Which of the following points does the writer make in the final paragraph?
A
People should question new theories that scientists put forward.
B
High prices do not necessarily equate to a quality product.
C
People are setting up home in the country for health reasons.
D
The natural environment is fast disappearing.

Choose the correct letter, A, B, C or D.$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('55c20b50-3d29-58b0-be0a-18c96ca75ab7', 'ef56caf5-6f0c-50aa-9d34-15c294cfb6bd', 8, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 8

Questions 6-8
Questions 6-8
Choose the correct letter, A, B, C or D.
Write the correct letter in boxes 6-8 on your answer sheet.
6. The writer suggests that Brantingham and Beekman's findings were
A
ignored by big companies.
B
doubted by other researchers.
C
applicable to a narrow range of people.
D
surprising to them.
7. What claim is made by the designers of the cobblestone mats"?
A
They need to be used continuously in order to have a lasting effect.
B
They would be as beneficial to younger people as to older people.
C
They could be an effective alternative to medical intervention.
D
Their effects may vary depending on individual users.
8. Which of the following points does the writer make in the final paragraph?
A
People should question new theories that scientists put forward.
B
High prices do not necessarily equate to a quality product.
C
People are setting up home in the country for health reasons.
D
The natural environment is fast disappearing.

Choose the correct letter, A, B, C or D.$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('cf2777a6-6436-55c9-a8a8-12e1d200baa5', 'ef56caf5-6f0c-50aa-9d34-15c294cfb6bd', 9, 'NOTE_COMPLETION', 'READING', 3, $md$### Question 9

Questions 9-14
Questions 9-14
Complete the summary below.
Choose
ONE WORD ONLY
from the passage for each answer.
Write your answers in boxes 9-14 on your answer sheet.
In their research, Brantingham and Beekman looked at the complex physical
9
of the foot and noted that the surfaces of modem environments restrict its movement. They invented a mat which they tried out on factory workers. Whenever the workers walked on it, the different levels of
10
in the mat would encourage greater muscle action. In turn, this lessened the effect of
11
on the cardiovascular system.
Similar research was undertaken by John Fisher and colleagues in Oregon. As a result of their findings, they decided to market cobblestone mats to the elderly as a means of dealing with
12
. Reflexologists claim that by manipulating specific parts of the feet, the performance of certain
13
will also improve. Finally, Benno Nigg at Calgary University believes that specially shaped
14
on shoes should give health benefits.

In their research, Brantingham and Beekman looked at the complex physical 9 ____ of the foot and noted that the surfaces of modem environments restrict its movement. They invented a mat which they tried out on factory workers. Whenever the workers walked on it, the different levels of 10 ____ in the mat would encourage greater muscle action. In turn, this lessened the effect of 11 ____ on the cardiovascular system.$md$, NULL, ARRAY['.*anatomy.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('34941212-babf-52c2-ba24-f6cb48c800c0', 'ef56caf5-6f0c-50aa-9d34-15c294cfb6bd', 10, 'NOTE_COMPLETION', 'READING', 4, $md$### Question 10

Questions 9-14
Questions 9-14
Complete the summary below.
Choose
ONE WORD ONLY
from the passage for each answer.
Write your answers in boxes 9-14 on your answer sheet.
In their research, Brantingham and Beekman looked at the complex physical
9
of the foot and noted that the surfaces of modem environments restrict its movement. They invented a mat which they tried out on factory workers. Whenever the workers walked on it, the different levels of
10
in the mat would encourage greater muscle action. In turn, this lessened the effect of
11
on the cardiovascular system.
Similar research was undertaken by John Fisher and colleagues in Oregon. As a result of their findings, they decided to market cobblestone mats to the elderly as a means of dealing with
12
. Reflexologists claim that by manipulating specific parts of the feet, the performance of certain
13
will also improve. Finally, Benno Nigg at Calgary University believes that specially shaped
14
on shoes should give health benefits.

In their research, Brantingham and Beekman looked at the complex physical 9 ____ of the foot and noted that the surfaces of modem environments restrict its movement. They invented a mat which they tried out on factory workers. Whenever the workers walked on it, the different levels of 10 ____ in the mat would encourage greater muscle action. In turn, this lessened the effect of 11 ____ on the cardiovascular system.$md$, NULL, ARRAY['.*anatomy.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('9da9efa3-3829-515b-9f68-e19cd40f3c65', 'ef56caf5-6f0c-50aa-9d34-15c294cfb6bd', 11, 'NOTE_COMPLETION', 'READING', 4, $md$### Question 11

Questions 9-14
Questions 9-14
Complete the summary below.
Choose
ONE WORD ONLY
from the passage for each answer.
Write your answers in boxes 9-14 on your answer sheet.
In their research, Brantingham and Beekman looked at the complex physical
9
of the foot and noted that the surfaces of modem environments restrict its movement. They invented a mat which they tried out on factory workers. Whenever the workers walked on it, the different levels of
10
in the mat would encourage greater muscle action. In turn, this lessened the effect of
11
on the cardiovascular system.
Similar research was undertaken by John Fisher and colleagues in Oregon. As a result of their findings, they decided to market cobblestone mats to the elderly as a means of dealing with
12
. Reflexologists claim that by manipulating specific parts of the feet, the performance of certain
13
will also improve. Finally, Benno Nigg at Calgary University believes that specially shaped
14
on shoes should give health benefits.

In their research, Brantingham and Beekman looked at the complex physical 9 ____ of the foot and noted that the surfaces of modem environments restrict its movement. They invented a mat which they tried out on factory workers. Whenever the workers walked on it, the different levels of 10 ____ in the mat would encourage greater muscle action. In turn, this lessened the effect of 11 ____ on the cardiovascular system.$md$, NULL, ARRAY['.*anatomy.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('3701ed19-4d10-54e1-9637-20a76bb0d690', 'ef56caf5-6f0c-50aa-9d34-15c294cfb6bd', 12, 'NOTE_COMPLETION', 'READING', 4, $md$### Question 12

Questions 9-14
Questions 9-14
Complete the summary below.
Choose
ONE WORD ONLY
from the passage for each answer.
Write your answers in boxes 9-14 on your answer sheet.
In their research, Brantingham and Beekman looked at the complex physical
9
of the foot and noted that the surfaces of modem environments restrict its movement. They invented a mat which they tried out on factory workers. Whenever the workers walked on it, the different levels of
10
in the mat would encourage greater muscle action. In turn, this lessened the effect of
11
on the cardiovascular system.
Similar research was undertaken by John Fisher and colleagues in Oregon. As a result of their findings, they decided to market cobblestone mats to the elderly as a means of dealing with
12
. Reflexologists claim that by manipulating specific parts of the feet, the performance of certain
13
will also improve. Finally, Benno Nigg at Calgary University believes that specially shaped
14
on shoes should give health benefits.

Similar research was undertaken by John Fisher and colleagues in Oregon. As a result of their findings, they decided to market cobblestone mats to the elderly as a means of dealing with 12 ____ . Reflexologists claim that by manipulating specific parts of the feet, the performance of certain 13 ____ will also improve. Finally, Benno Nigg at Calgary University believes that specially shaped 14 ____ on shoes should give health benefits.$md$, NULL, ARRAY['.*hypertension.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('c033d161-f4f7-5194-9944-76fe5c7ea2ff', 'ef56caf5-6f0c-50aa-9d34-15c294cfb6bd', 13, 'NOTE_COMPLETION', 'READING', 4, $md$### Question 13

Questions 9-14
Questions 9-14
Complete the summary below.
Choose
ONE WORD ONLY
from the passage for each answer.
Write your answers in boxes 9-14 on your answer sheet.
In their research, Brantingham and Beekman looked at the complex physical
9
of the foot and noted that the surfaces of modem environments restrict its movement. They invented a mat which they tried out on factory workers. Whenever the workers walked on it, the different levels of
10
in the mat would encourage greater muscle action. In turn, this lessened the effect of
11
on the cardiovascular system.
Similar research was undertaken by John Fisher and colleagues in Oregon. As a result of their findings, they decided to market cobblestone mats to the elderly as a means of dealing with
12
. Reflexologists claim that by manipulating specific parts of the feet, the performance of certain
13
will also improve. Finally, Benno Nigg at Calgary University believes that specially shaped
14
on shoes should give health benefits.

Similar research was undertaken by John Fisher and colleagues in Oregon. As a result of their findings, they decided to market cobblestone mats to the elderly as a means of dealing with 12 ____ . Reflexologists claim that by manipulating specific parts of the feet, the performance of certain 13 ____ will also improve. Finally, Benno Nigg at Calgary University believes that specially shaped 14 ____ on shoes should give health benefits.$md$, NULL, ARRAY['.*hypertension.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('0d4a67d0-92ab-5e4d-b6f6-a198ae75acea', 'ef56caf5-6f0c-50aa-9d34-15c294cfb6bd', 14, 'NOTE_COMPLETION', 'READING', 4, $md$### Question 14

Questions 9-14
Questions 9-14
Complete the summary below.
Choose
ONE WORD ONLY
from the passage for each answer.
Write your answers in boxes 9-14 on your answer sheet.
In their research, Brantingham and Beekman looked at the complex physical
9
of the foot and noted that the surfaces of modem environments restrict its movement. They invented a mat which they tried out on factory workers. Whenever the workers walked on it, the different levels of
10
in the mat would encourage greater muscle action. In turn, this lessened the effect of
11
on the cardiovascular system.
Similar research was undertaken by John Fisher and colleagues in Oregon. As a result of their findings, they decided to market cobblestone mats to the elderly as a means of dealing with
12
. Reflexologists claim that by manipulating specific parts of the feet, the performance of certain
13
will also improve. Finally, Benno Nigg at Calgary University believes that specially shaped
14
on shoes should give health benefits.

Similar research was undertaken by John Fisher and colleagues in Oregon. As a result of their findings, they decided to market cobblestone mats to the elderly as a means of dealing with 12 ____ . Reflexologists claim that by manipulating specific parts of the feet, the performance of certain 13 ____ will also improve. Finally, Benno Nigg at Calgary University believes that specially shaped 14 ____ on shoes should give health benefits.$md$, NULL, ARRAY['.*hypertension.*']);

COMMIT;
