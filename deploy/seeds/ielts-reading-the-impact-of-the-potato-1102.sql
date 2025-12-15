BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-the-impact-of-the-potato-1102'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-the-impact-of-the-potato-1102';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-the-impact-of-the-potato-1102';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-the-impact-of-the-potato-1102';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('8406e7e5-ea03-530f-ad47-101150c53e56', 'ielts-reading-the-impact-of-the-potato-1102', $t$The Impact of the Potato$t$, $md$## The Impact of the Potato

Nguồn:
- Test: https://mini-ielts.com/1102/reading/the-impact-of-the-potato
- Solution: https://mini-ielts.com/1102/view-solution/reading/the-impact-of-the-potato$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('6e92f64f-c40c-50ea-a244-de84e3e4f278', '8406e7e5-ea03-530f-ad47-101150c53e56', 1, $t$Reading — The Impact of the Potato$t$, $md$Read the passage and answer questions **1–13**.

### Passage: The Impact of the Potato

Jeff Chapman relates the story of history the most important vegetable

A The potato was first cultivated in South America between three and seven thousand years ago, though scientists believe they may have grown wild in the region as long as 13,000 years ago. The genetic patterns of potato distribution indicate that the potato probably originated in the mountainous west-central region of the continent.

B Early Spanish chroniclers who misused the Indian word batata (sweet potato) as the name for the potato noted the importance of the tuber to the Incan Empire. The Incas had learned to preserve the potato for storage by dehydrating and mashing potatoes into a substance called Chuchu could be stored in a room for up to 10 years, providing excellent insurance against possible crop failures. As well as using the food as a staple crop, the Incas thought potatoes made childbirth easier and used it to treat injuries.

C The Spanish conquistadors first encountered the potato when they arrived in Peru in 1532 in search of gold , and noted Inca miners eating chuchu. At the time the Spaniards failed to realize that the potato represented a far more important treasure than either silver or gold, but they did gradually begin to use potatoes as basic rations aboard their ships. After the arrival of the potato in Spain in 1570，a few Spanish farmers began to cultivate them on a small scale, mostly as food for livestock.

D Throughout Europe, potatoes were regarded with suspicion, distaste and fear. Generally considered to be unfit for human consumption, they were used only as animal fodder and sustenance for the starving. In northern Europe, potatoes were primarily grown in botanical gardens as an exotic novelty. Even peasants refused to eat from a plant that produced ugly, misshapen tubers and that had come from a heathen civilization . Some felt that the potato plant’s resemblance to plants in the nightshade family hinted that it was the creation of witches or devils.

E In meat-loving England, farmers and urban workers regarded potatoes with extreme distaste. In 1662, the Royal Society recommended the cultivation of the tuber to the English government and the nation, but this recommendation had little impact. Potatoes did not become a staple until, during the food shortages associated with the Revolutionary Wars , the English government began to officially encourage potato cultivation. In 1795, the Board of Agriculture issued a pamphlet entitled “Hints Respecting the Culture and Use of Potatoes”； this was followed shortly by pro-potato editorials and potato recipes in The Times. Gradually, the lower classes began to follow the lead of the upper classes.

F A similar pattern emerged across the English Channel in the Netherlands, Belgium and France. While the potato slowly gained ground in eastern France (where it was often the only crop remaining after marauding soldiers plundered wheat fields and vineyards), it did not achieve widespread acceptance until the late 1700s. The peasants remained suspicious, in spite of a 1771 paper from the Facult de Paris testifying that the potato was not harmful but beneficial. The people began to overcome their distaste when the plant received the royal seal of approval: Louis XVI began to sport a potato flower in his buttonhole, and Marie-Antoinette wore the purple potato blossom in her hair.

G Frederick the Great of Prussia saw the potato’s potential to help feed his nation and lower the price of bread, but faced the challenge of overcoming the people’s prejudice against the plant. When he issued a 1774 order for his subjects to grow potatoes as protection against famine, the town of Kolberg replied: “The things have neither smell nor taste, not even the dogs will eat them, so what use are they to us?” Trying a less direct approach to encourage his subjects to begin planting potatoes, Frederick used a bit of reverse psychology: he planted a royal field of potato plants and stationed a heavy guard to protect this field from thieves. Nearby peasants naturally assumed that anything worth guarding was worth stealing, and so snuck into the field and snatched the plants for their home gardens. Of course, this was entirely in line with Frederick’s wishes.

H Historians debate whether the potato was primarily a cause or an effect of the huge population boom in industrial-era England and Wales. Prior to 1800，the English diet had consisted primarily of meat , supplemented by bread, butter and cheese. Few vegetables were consumed, most vegetables being regarded as nutritionally worthless and potentially harmful. This view began to change gradually in the late 1700s. The Industrial Revolution was drawing an ever increasing percentage of the populace into crowded cities, where only the richest could afford homes with ovens or coal storage rooms, and people were working 12-16 hour days which left them with little time or energy to prepare food. High yielding, easily prepared potato crops were the obvious solution to England’s food problems.

I Whereas most of their neighbors regarded the potato with suspicion and had to be persuaded to use it by the upper classes, the Irish peasantry embraced the tuber more passionately than anyone since the Incas. The potato was well suited to the Irish the soil and climate, and its high yield suited the most important concern of most Irish farmers: to feed their families.

J The most dramatic example of the potato’s potential to alter population patterns occurred in Ireland, where the potato had become a staple by 1800. The Irish population doubled to eight million between 1780 and 1841，this without any significant expansion of industry or reform of agricultural techniques beyond the widespread cultivation of the potato. Though Irish landholding practices were primitive in comparison with those of England, the potato’s high yields allowed even the poorest farmers to produce more healthy food than they needed with scarcely any investment or hard labor. Even children could easily plant, harvest and cook potatoes, which of course required no threshing, curing or grinding. The abundance provided by potatoes greatly decreased infant mortality and encouraged early marriage.

----------------------------------------------------

Great thanks to volunteer Ngoc Nguyen has contributed these explanations and question markings.

If you want to make a better world like this, please contact us$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('b22bda73-d675-5db5-b4d5-0931a8540e9f', '6e92f64f-c40c-50ea-a244-de84e3e4f278', 1, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 1

Questions 1-5
Questions 1-5
Do the following statements agree with the views of the writer in Reading Passage 1?
In boxes
1-5
on your answer sheet, write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
1
The early Spanish called potato as the Incan name ‘Chuchu’
Locate
2
The purposes of Spanish coming to Peru were to find out potatoes
Locate
3
The Spanish believed that the potato has the same nutrients as other vegetables
4
Peasants at that time did not like to eat potatoes because they were ugly
Locate
5
The popularity of potatoes in the UK was due to food shortages during the war
Locate

1 ____ The early Spanish called potato as the Incan name ‘Chuchu’ Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('51663610-fc7f-5629-9295-b4dd3e842646', 'b22bda73-d675-5db5-b4d5-0931a8540e9f', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('906cc54a-ee2b-56a8-97c5-ef7c408800b2', 'b22bda73-d675-5db5-b4d5-0931a8540e9f', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0b72adb4-c19e-5000-994e-c360ba665fab', 'b22bda73-d675-5db5-b4d5-0931a8540e9f', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('a8c05724-e195-5991-8392-43e26561a0b5', '6e92f64f-c40c-50ea-a244-de84e3e4f278', 2, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 2

Questions 1-5
Questions 1-5
Do the following statements agree with the views of the writer in Reading Passage 1?
In boxes
1-5
on your answer sheet, write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
1
The early Spanish called potato as the Incan name ‘Chuchu’
Locate
2
The purposes of Spanish coming to Peru were to find out potatoes
Locate
3
The Spanish believed that the potato has the same nutrients as other vegetables
4
Peasants at that time did not like to eat potatoes because they were ugly
Locate
5
The popularity of potatoes in the UK was due to food shortages during the war
Locate

2 ____ The purposes of Spanish coming to Peru were to find out potatoes Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c7cce5fe-8cd4-5bf3-adef-b00422b6334c', 'a8c05724-e195-5991-8392-43e26561a0b5', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('dc3a5eb0-de2e-5666-a296-bf0624e4e798', 'a8c05724-e195-5991-8392-43e26561a0b5', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('51032287-631d-5987-a0ac-b5724ff340d2', 'a8c05724-e195-5991-8392-43e26561a0b5', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('602b5bbc-989e-5416-8c87-e5853b8bfbda', '6e92f64f-c40c-50ea-a244-de84e3e4f278', 3, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 3

Questions 1-5
Questions 1-5
Do the following statements agree with the views of the writer in Reading Passage 1?
In boxes
1-5
on your answer sheet, write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
1
The early Spanish called potato as the Incan name ‘Chuchu’
Locate
2
The purposes of Spanish coming to Peru were to find out potatoes
Locate
3
The Spanish believed that the potato has the same nutrients as other vegetables
4
Peasants at that time did not like to eat potatoes because they were ugly
Locate
5
The popularity of potatoes in the UK was due to food shortages during the war
Locate

3 ____ The Spanish believed that the potato has the same nutrients as other vegetables$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('771bb297-f1d4-550b-bb78-6bece4d1b267', '602b5bbc-989e-5416-8c87-e5853b8bfbda', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f32ef40c-0e77-5c94-8297-281ecd100e5c', '602b5bbc-989e-5416-8c87-e5853b8bfbda', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4ea9531e-a204-5860-8f44-7381d2ed91e4', '602b5bbc-989e-5416-8c87-e5853b8bfbda', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('ec1d9576-fbe9-5f1d-a15f-0fdcd63d171e', '6e92f64f-c40c-50ea-a244-de84e3e4f278', 4, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 4

Questions 1-5
Questions 1-5
Do the following statements agree with the views of the writer in Reading Passage 1?
In boxes
1-5
on your answer sheet, write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
1
The early Spanish called potato as the Incan name ‘Chuchu’
Locate
2
The purposes of Spanish coming to Peru were to find out potatoes
Locate
3
The Spanish believed that the potato has the same nutrients as other vegetables
4
Peasants at that time did not like to eat potatoes because they were ugly
Locate
5
The popularity of potatoes in the UK was due to food shortages during the war
Locate

4 ____ Peasants at that time did not like to eat potatoes because they were ugly Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7ba72393-c52e-5f05-933b-c22565280021', 'ec1d9576-fbe9-5f1d-a15f-0fdcd63d171e', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2428e933-9867-5fcb-9f03-959c8032924f', 'ec1d9576-fbe9-5f1d-a15f-0fdcd63d171e', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cb928374-06fc-5842-a697-70681ecf6be6', 'ec1d9576-fbe9-5f1d-a15f-0fdcd63d171e', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('bfeb5e91-3222-58ce-9585-96f3d2e452ab', '6e92f64f-c40c-50ea-a244-de84e3e4f278', 5, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 5

Questions 1-5
Questions 1-5
Do the following statements agree with the views of the writer in Reading Passage 1?
In boxes
1-5
on your answer sheet, write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
1
The early Spanish called potato as the Incan name ‘Chuchu’
Locate
2
The purposes of Spanish coming to Peru were to find out potatoes
Locate
3
The Spanish believed that the potato has the same nutrients as other vegetables
4
Peasants at that time did not like to eat potatoes because they were ugly
Locate
5
The popularity of potatoes in the UK was due to food shortages during the war
Locate

5 ____ The popularity of potatoes in the UK was due to food shortages during the war Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('619a400d-f181-54c4-91b3-20cd6c129842', 'bfeb5e91-3222-58ce-9585-96f3d2e452ab', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0c328a2e-3744-5dc2-940c-951f44fdfec1', 'bfeb5e91-3222-58ce-9585-96f3d2e452ab', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b16039cd-cbcf-5371-b4e9-66fce854f435', 'bfeb5e91-3222-58ce-9585-96f3d2e452ab', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('3b683a15-d97c-500a-9843-deead800987c', '6e92f64f-c40c-50ea-a244-de84e3e4f278', 6, 'SENTENCE_COMPLETION', 'READING', 3, $md$### Question 6

Questions 6-13
Questions 6-13
Complete the sentences below with
NO MORE THAN ONE WORD
from the passage for each answer.
Write your answers in boxes
6-13
on your answer sheet.
6.
In France, people started to overcome their disgusting about potatoes because the King put a potato
in his button hole.
Locate
7.
Frederick realized the potential of potato but he had to handle the
against potatoes from ordinary people.
Locate
8.
The King of Prussia adopted some
psychology to make people accept potatoes.
Locate
9.
Before 1800，the English people preferred eating
with bread, butter and cheese.
Locate
10.
The obvious way to deal with England food problems were high yielding potato
Locate
11.
The Irish
and climate suited potatoes well.
Locate
12.
Between 1780 and 1841, based on the
of the potatoes, the Irish population doubled to eight million.
Locate
13.
The potato’s high yields help the poorest farmers to produce more healthy food almost without
Locate

6. In France, people started to overcome their disgusting about potatoes because the King put a potato ____ in his button hole. Locate 7. Frederick realized the potential of potato but he had to handle the ____ against potatoes from ordinary people. Locate 8. The King of Prussia adopted some ____ psychology to make people accept potatoes. Locate 9. Before 1800，the English people preferred eating ____ with bread, butter and cheese. Locate 10. The obvious way to deal with England food problems were high yielding potato ____ Locate 11. The Irish ____ and climate suited potatoes well. Locate 12. Between 1780 and 1841, based on the ____ of the potatoes, the Irish population doubled to eight million. Locate 13. The potato’s high yields help the poorest farmers to produce more healthy food almost without ____ Locate$md$, NULL, ARRAY['.*flower.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('be6316fc-6c44-56cb-ab2b-04db6485dcf1', '6e92f64f-c40c-50ea-a244-de84e3e4f278', 7, 'SENTENCE_COMPLETION', 'READING', 3, $md$### Question 7

Questions 6-13
Questions 6-13
Complete the sentences below with
NO MORE THAN ONE WORD
from the passage for each answer.
Write your answers in boxes
6-13
on your answer sheet.
6.
In France, people started to overcome their disgusting about potatoes because the King put a potato
in his button hole.
Locate
7.
Frederick realized the potential of potato but he had to handle the
against potatoes from ordinary people.
Locate
8.
The King of Prussia adopted some
psychology to make people accept potatoes.
Locate
9.
Before 1800，the English people preferred eating
with bread, butter and cheese.
Locate
10.
The obvious way to deal with England food problems were high yielding potato
Locate
11.
The Irish
and climate suited potatoes well.
Locate
12.
Between 1780 and 1841, based on the
of the potatoes, the Irish population doubled to eight million.
Locate
13.
The potato’s high yields help the poorest farmers to produce more healthy food almost without
Locate

6. In France, people started to overcome their disgusting about potatoes because the King put a potato ____ in his button hole. Locate 7. Frederick realized the potential of potato but he had to handle the ____ against potatoes from ordinary people. Locate 8. The King of Prussia adopted some ____ psychology to make people accept potatoes. Locate 9. Before 1800，the English people preferred eating ____ with bread, butter and cheese. Locate 10. The obvious way to deal with England food problems were high yielding potato ____ Locate 11. The Irish ____ and climate suited potatoes well. Locate 12. Between 1780 and 1841, based on the ____ of the potatoes, the Irish population doubled to eight million. Locate 13. The potato’s high yields help the poorest farmers to produce more healthy food almost without ____ Locate$md$, NULL, ARRAY['.*flower.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('1cdc31d3-092b-5652-8a56-b04272cdcb9f', '6e92f64f-c40c-50ea-a244-de84e3e4f278', 8, 'SENTENCE_COMPLETION', 'READING', 3, $md$### Question 8

Questions 6-13
Questions 6-13
Complete the sentences below with
NO MORE THAN ONE WORD
from the passage for each answer.
Write your answers in boxes
6-13
on your answer sheet.
6.
In France, people started to overcome their disgusting about potatoes because the King put a potato
in his button hole.
Locate
7.
Frederick realized the potential of potato but he had to handle the
against potatoes from ordinary people.
Locate
8.
The King of Prussia adopted some
psychology to make people accept potatoes.
Locate
9.
Before 1800，the English people preferred eating
with bread, butter and cheese.
Locate
10.
The obvious way to deal with England food problems were high yielding potato
Locate
11.
The Irish
and climate suited potatoes well.
Locate
12.
Between 1780 and 1841, based on the
of the potatoes, the Irish population doubled to eight million.
Locate
13.
The potato’s high yields help the poorest farmers to produce more healthy food almost without
Locate

6. In France, people started to overcome their disgusting about potatoes because the King put a potato ____ in his button hole. Locate 7. Frederick realized the potential of potato but he had to handle the ____ against potatoes from ordinary people. Locate 8. The King of Prussia adopted some ____ psychology to make people accept potatoes. Locate 9. Before 1800，the English people preferred eating ____ with bread, butter and cheese. Locate 10. The obvious way to deal with England food problems were high yielding potato ____ Locate 11. The Irish ____ and climate suited potatoes well. Locate 12. Between 1780 and 1841, based on the ____ of the potatoes, the Irish population doubled to eight million. Locate 13. The potato’s high yields help the poorest farmers to produce more healthy food almost without ____ Locate$md$, NULL, ARRAY['.*flower.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('5bf06c65-a1df-5489-aef7-22e46822f0bf', '6e92f64f-c40c-50ea-a244-de84e3e4f278', 9, 'SENTENCE_COMPLETION', 'READING', 3, $md$### Question 9

Questions 6-13
Questions 6-13
Complete the sentences below with
NO MORE THAN ONE WORD
from the passage for each answer.
Write your answers in boxes
6-13
on your answer sheet.
6.
In France, people started to overcome their disgusting about potatoes because the King put a potato
in his button hole.
Locate
7.
Frederick realized the potential of potato but he had to handle the
against potatoes from ordinary people.
Locate
8.
The King of Prussia adopted some
psychology to make people accept potatoes.
Locate
9.
Before 1800，the English people preferred eating
with bread, butter and cheese.
Locate
10.
The obvious way to deal with England food problems were high yielding potato
Locate
11.
The Irish
and climate suited potatoes well.
Locate
12.
Between 1780 and 1841, based on the
of the potatoes, the Irish population doubled to eight million.
Locate
13.
The potato’s high yields help the poorest farmers to produce more healthy food almost without
Locate

6. In France, people started to overcome their disgusting about potatoes because the King put a potato ____ in his button hole. Locate 7. Frederick realized the potential of potato but he had to handle the ____ against potatoes from ordinary people. Locate 8. The King of Prussia adopted some ____ psychology to make people accept potatoes. Locate 9. Before 1800，the English people preferred eating ____ with bread, butter and cheese. Locate 10. The obvious way to deal with England food problems were high yielding potato ____ Locate 11. The Irish ____ and climate suited potatoes well. Locate 12. Between 1780 and 1841, based on the ____ of the potatoes, the Irish population doubled to eight million. Locate 13. The potato’s high yields help the poorest farmers to produce more healthy food almost without ____ Locate$md$, NULL, ARRAY['.*flower.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('48a6a79a-0b79-5dc4-ab5e-e5849446cee2', '6e92f64f-c40c-50ea-a244-de84e3e4f278', 10, 'SENTENCE_COMPLETION', 'READING', 4, $md$### Question 10

Questions 6-13
Questions 6-13
Complete the sentences below with
NO MORE THAN ONE WORD
from the passage for each answer.
Write your answers in boxes
6-13
on your answer sheet.
6.
In France, people started to overcome their disgusting about potatoes because the King put a potato
in his button hole.
Locate
7.
Frederick realized the potential of potato but he had to handle the
against potatoes from ordinary people.
Locate
8.
The King of Prussia adopted some
psychology to make people accept potatoes.
Locate
9.
Before 1800，the English people preferred eating
with bread, butter and cheese.
Locate
10.
The obvious way to deal with England food problems were high yielding potato
Locate
11.
The Irish
and climate suited potatoes well.
Locate
12.
Between 1780 and 1841, based on the
of the potatoes, the Irish population doubled to eight million.
Locate
13.
The potato’s high yields help the poorest farmers to produce more healthy food almost without
Locate

6. In France, people started to overcome their disgusting about potatoes because the King put a potato ____ in his button hole. Locate 7. Frederick realized the potential of potato but he had to handle the ____ against potatoes from ordinary people. Locate 8. The King of Prussia adopted some ____ psychology to make people accept potatoes. Locate 9. Before 1800，the English people preferred eating ____ with bread, butter and cheese. Locate 10. The obvious way to deal with England food problems were high yielding potato ____ Locate 11. The Irish ____ and climate suited potatoes well. Locate 12. Between 1780 and 1841, based on the ____ of the potatoes, the Irish population doubled to eight million. Locate 13. The potato’s high yields help the poorest farmers to produce more healthy food almost without ____ Locate$md$, NULL, ARRAY['.*flower.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('058cdf5f-8212-54f4-97f2-56bd83e1c311', '6e92f64f-c40c-50ea-a244-de84e3e4f278', 11, 'SENTENCE_COMPLETION', 'READING', 4, $md$### Question 11

Questions 6-13
Questions 6-13
Complete the sentences below with
NO MORE THAN ONE WORD
from the passage for each answer.
Write your answers in boxes
6-13
on your answer sheet.
6.
In France, people started to overcome their disgusting about potatoes because the King put a potato
in his button hole.
Locate
7.
Frederick realized the potential of potato but he had to handle the
against potatoes from ordinary people.
Locate
8.
The King of Prussia adopted some
psychology to make people accept potatoes.
Locate
9.
Before 1800，the English people preferred eating
with bread, butter and cheese.
Locate
10.
The obvious way to deal with England food problems were high yielding potato
Locate
11.
The Irish
and climate suited potatoes well.
Locate
12.
Between 1780 and 1841, based on the
of the potatoes, the Irish population doubled to eight million.
Locate
13.
The potato’s high yields help the poorest farmers to produce more healthy food almost without
Locate

6. In France, people started to overcome their disgusting about potatoes because the King put a potato ____ in his button hole. Locate 7. Frederick realized the potential of potato but he had to handle the ____ against potatoes from ordinary people. Locate 8. The King of Prussia adopted some ____ psychology to make people accept potatoes. Locate 9. Before 1800，the English people preferred eating ____ with bread, butter and cheese. Locate 10. The obvious way to deal with England food problems were high yielding potato ____ Locate 11. The Irish ____ and climate suited potatoes well. Locate 12. Between 1780 and 1841, based on the ____ of the potatoes, the Irish population doubled to eight million. Locate 13. The potato’s high yields help the poorest farmers to produce more healthy food almost without ____ Locate$md$, NULL, ARRAY['.*flower.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('c8b6b881-816c-53d0-912f-61afef6fb9d3', '6e92f64f-c40c-50ea-a244-de84e3e4f278', 12, 'SENTENCE_COMPLETION', 'READING', 4, $md$### Question 12

Questions 6-13
Questions 6-13
Complete the sentences below with
NO MORE THAN ONE WORD
from the passage for each answer.
Write your answers in boxes
6-13
on your answer sheet.
6.
In France, people started to overcome their disgusting about potatoes because the King put a potato
in his button hole.
Locate
7.
Frederick realized the potential of potato but he had to handle the
against potatoes from ordinary people.
Locate
8.
The King of Prussia adopted some
psychology to make people accept potatoes.
Locate
9.
Before 1800，the English people preferred eating
with bread, butter and cheese.
Locate
10.
The obvious way to deal with England food problems were high yielding potato
Locate
11.
The Irish
and climate suited potatoes well.
Locate
12.
Between 1780 and 1841, based on the
of the potatoes, the Irish population doubled to eight million.
Locate
13.
The potato’s high yields help the poorest farmers to produce more healthy food almost without
Locate

6. In France, people started to overcome their disgusting about potatoes because the King put a potato ____ in his button hole. Locate 7. Frederick realized the potential of potato but he had to handle the ____ against potatoes from ordinary people. Locate 8. The King of Prussia adopted some ____ psychology to make people accept potatoes. Locate 9. Before 1800，the English people preferred eating ____ with bread, butter and cheese. Locate 10. The obvious way to deal with England food problems were high yielding potato ____ Locate 11. The Irish ____ and climate suited potatoes well. Locate 12. Between 1780 and 1841, based on the ____ of the potatoes, the Irish population doubled to eight million. Locate 13. The potato’s high yields help the poorest farmers to produce more healthy food almost without ____ Locate$md$, NULL, ARRAY['.*flower.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('b28c5ae8-85a2-5abd-9c3f-c7805e441725', '6e92f64f-c40c-50ea-a244-de84e3e4f278', 13, 'SENTENCE_COMPLETION', 'READING', 4, $md$### Question 13

Questions 6-13
Questions 6-13
Complete the sentences below with
NO MORE THAN ONE WORD
from the passage for each answer.
Write your answers in boxes
6-13
on your answer sheet.
6.
In France, people started to overcome their disgusting about potatoes because the King put a potato
in his button hole.
Locate
7.
Frederick realized the potential of potato but he had to handle the
against potatoes from ordinary people.
Locate
8.
The King of Prussia adopted some
psychology to make people accept potatoes.
Locate
9.
Before 1800，the English people preferred eating
with bread, butter and cheese.
Locate
10.
The obvious way to deal with England food problems were high yielding potato
Locate
11.
The Irish
and climate suited potatoes well.
Locate
12.
Between 1780 and 1841, based on the
of the potatoes, the Irish population doubled to eight million.
Locate
13.
The potato’s high yields help the poorest farmers to produce more healthy food almost without
Locate

6. In France, people started to overcome their disgusting about potatoes because the King put a potato ____ in his button hole. Locate 7. Frederick realized the potential of potato but he had to handle the ____ against potatoes from ordinary people. Locate 8. The King of Prussia adopted some ____ psychology to make people accept potatoes. Locate 9. Before 1800，the English people preferred eating ____ with bread, butter and cheese. Locate 10. The obvious way to deal with England food problems were high yielding potato ____ Locate 11. The Irish ____ and climate suited potatoes well. Locate 12. Between 1780 and 1841, based on the ____ of the potatoes, the Irish population doubled to eight million. Locate 13. The potato’s high yields help the poorest farmers to produce more healthy food almost without ____ Locate$md$, NULL, ARRAY['.*flower.*']);

COMMIT;
