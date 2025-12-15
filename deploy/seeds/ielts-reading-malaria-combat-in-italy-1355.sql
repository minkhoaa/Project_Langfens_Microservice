BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-malaria-combat-in-italy-1355'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-malaria-combat-in-italy-1355';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-malaria-combat-in-italy-1355';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-malaria-combat-in-italy-1355';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('9b48577b-7ba2-5b2e-8707-ad8dbee4d891', 'ielts-reading-malaria-combat-in-italy-1355', $t$Malaria Combat in Italy$t$, $md$## Malaria Combat in Italy

Nguồn:
- Test: https://mini-ielts.com/1355/reading/malaria-combat-in-italy
- Solution: https://mini-ielts.com/1355/view-solution/reading/malaria-combat-in-italy$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('669dea9d-05de-5be5-8b35-85671e96c09a', '9b48577b-7ba2-5b2e-8707-ad8dbee4d891', 1, $t$Reading — Malaria Combat in Italy$t$, $md$Read the passage and answer questions **1–14**.

### Passage: Malaria Combat in Italy

A

Mal-aria. Bad air. Even the world is Italian, and this horrible disease marked the life of those in the peninsula for thousands of years. Giuseppe Garibaldi’s wife died of the disease, as did the country’s first prime minister, Cavour, in 1861. Yet by 1962, Italy was officially declared malaria-free, and it has remained so ever since. Frank Snowden’s study of this success story is a remarkable piece of historical work. Original, crystal-clear, analytical and passionate, Snowden (who has previously written about cholera) takes us to areas historians have rarely visited before.

B

Everybody now knows that malaria is carried by mosquitoes. Malaria has always been the subject of research for medical practitioners from time immemorial. However, many ancient texts, especially medical literature, mention of various aspects of malaria and even of its possible link with mosquitoes and insects. Early man, confronting the manifestations of malaria, attributed the fevers to supernatural influences: evil spirits, angered deities, or the black magic of sorcerers. But in the 19th century, most experts believed that the disease was not produced by unclean air (“miasma” or “poisoning of the air”). Two Americans, Josiah Clark Nott and Lewis Daniel Beauperthy, echoed Crawford’s ideas. Nott in his essay “Yellow Fever Contrasted with Bilious Fever,” published in 1850, dismissed the miasma theory as worthless, arguing that microscopic insects somehow transmitted by mosquitoes caused both malaria and yellow fever. Others made a link between swamps, water and malaria, but did not make the further leap towards insects. The consequences of these theories were that little was done to combat the disease before the end of the century. Things became so bad that 11m Italians (from a total population of 25m) were “permanently at risk”. In malarial zones, the life expectancy of land workers was a terrifying 22.5 years. Those who escaped death were weakened or suffered from splenomegaly – a “painful enlargement of the spleen” and “a lifeless stare”. The economic impact of the disease was immense. Epidemics were blamed on southern Italians, given the widespread belief that malaria was hereditary. In the 1880s, such theories began to collapse as the dreaded mosquito was identified as the real culprit.

C

Italian scientists, drawing on the pioneering work of French doctor Alphonse Laveran, were able to predict the cycles of fever but it was in Rome that further key discoveries were made. Giovanni Battista Grassi, a naturalist, found that a particular type of mosquito was the carrier of malaria. By experimenting on healthy volunteers (mosquitoes were released into rooms where they drank the blood of the human guinea pigs), Grassi was able to make the direct link between the insects (all females of a certain kind) and the disease. Soon, doctors and scientists made another startling discovery: the mosquitoes themselves were also infected and not mere carriers. Every year, during the mosquito season, malarial blood was moved around the population by the insects. Definitive proof of these new theories was obtained after an extraordinary series of experiments in Italy, where healthy people were introduced into malarial zones but kept free of mosquito bites – and remained well. The new Italian state had the necessary information to tackle the disease.

D

A complicated approach was adopted, which made use of quinine – a drug obtained from tree bark which had long been used to combat fever but was now seen as a crucial part of the war on malaria. Italy introduced a quinine law and a quinine tax in 1904, and the drug was administered to large numbers of rural workers. Despite its often terrible side-effects (the headaches produced were known as the “quinine-buzz”), the drug was successful in limiting the spread of the disease, and in breaking cycles of infection. In addition, Italy set up rural health centres and invested heavily in education programmes. Malaria, as Snowden shows, was not just a medical problem, but a social and regional issue, and could only be defeated through multi-layered strategies. Politics was itself transformed by the anti-malarial campaigns.

E

It was originally decided to give quinine to all those in certain regions – even healthy people; peasants were often suspicious of the medicine being forced upon them. Doctors were sometimes met with hostility and refusal, and many were dubbed “poisoners”. Despite these problems, the strategy was hugely successful. Deaths from malaria fell by some 80% in the first decade of the 20th century and some areas escaped altogether from the scourge of the disease.

F

Shamefully, the Italian malaria expert Alberto Missiroli had a role to play in the disaster: he did not distribute quinine, despite being well aware of the epidemic to come. Snowden claims that Missiroli was already preparing a new strategy – with the support of the US Rockefeller Foundation – using a new pesticide, DDT. Missiroli allowed the epidemic to spread, in order to create the ideal conditions for a massive, and lucrative, human experiment. Fifty-five thousand cases of malaria were recorded in the province of Littoria alone in 1944. It is estimated that more than a bird of those in the affected area contracted the disease. Thousands, nobody knows how many, died.

G

With the war over, the US government and the Rockefeller Foundation were free to experiment. DDT was sprayed from the air and 3m Italians had their bodies covered with the chemical. The effects were dramatic, and nobody really cared about the toxic effects of the chemical. By 1962, malaria was more or less gone from the whole peninsula. The last cases were noted in a poor region of Sicily. One of the final victims to die of the disease in Italy was the popular cyclist, Fausto Coppi. He had contracted malaria in Africa in 1960, and the failure of doctors in the north of Italy to spot the disease was a sign of the times. A few decades earlier, they would have immediately noticed the tell-tale signs; it was later claimed that a small dose of quinine would have saved his life.

H

As there are still more than 1m deaths every year from malaria worldwide, Snowden’s book also has contemporary relevance. This is a disease that affects every level of the societies where it is rampant. As Snowden writes: “In Italy, malaria undermined agricultural productivity, decimated the army, destroyed communities and left families impoverished.” The economic miracle of the 50s and 60s which made Italy into a modern industrial nation would not have been possible without the eradication of malaria. Moreover, this book convincingly argues that the disease was “an integral part of the big picture of modern Italian history”. This magnificent study, beautifully written and impeccably documented, deserves an audience beyond specialists in history, or in Italy. It also provides us with “a message of hope for a world struggling with the great present-day medical emergency”.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('99ad37f3-758a-5f7a-9cde-45b2990951df', '669dea9d-05de-5be5-8b35-85671e96c09a', 1, 'SUMMARY_COMPLETION', 'READING', 2, $md$### Question 1

Questions 1-4
Questions 1-4
Complete the following summary of the paragraphs of Reading Passage.
Using
NO MORE THAN TWO WORDS
from the Reading Passage for each answer.
Write your answers in boxes
1-4
on your answer sheet.
Theories for malaria origin have always been the issue of research for medical practitioners from ancient time. Although the link between malaria and mosquito was established lately, it has been recorded in words that
1
, including mosquito, may play the major culprits. In the 19th century, most experts rejected the idea of the miasma theory which related malaria to
2
. Even another widespread theory arose that southern Italians were blamed, to whom malaria was
3
. In southern Italy, the situation became so severe that near half the Italians population was thought to be “permanently at risk”. In malarial areas the
4
. Of rural workers was surprisingly shorter. In the 1880s, such theories began to withdraw as the mosquito was identified as the true cause.

Theories for malaria origin have always been the issue of research for medical practitioners from ancient time. Although the link between malaria and mosquito was established lately, it has been recorded in words that 1 ____ , including mosquito, may play the major culprits. In the 19th century, most experts rejected the idea of the miasma theory which related malaria to 2 ____ . Even another widespread theory arose that southern Italians were blamed, to whom malaria was 3 ____ . In southern Italy, the situation became so severe that near half the Italians population was thought to be “permanently at risk”. In malarial areas the 4 ____ . Of rural workers was surprisingly shorter. In the 1880s, such theories began to withdraw as the mosquito was identified as the true cause.$md$, NULL, ARRAY['.*insects.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('0f613e9a-2391-527c-8947-509e74c02344', '669dea9d-05de-5be5-8b35-85671e96c09a', 2, 'SUMMARY_COMPLETION', 'READING', 2, $md$### Question 2

Questions 1-4
Questions 1-4
Complete the following summary of the paragraphs of Reading Passage.
Using
NO MORE THAN TWO WORDS
from the Reading Passage for each answer.
Write your answers in boxes
1-4
on your answer sheet.
Theories for malaria origin have always been the issue of research for medical practitioners from ancient time. Although the link between malaria and mosquito was established lately, it has been recorded in words that
1
, including mosquito, may play the major culprits. In the 19th century, most experts rejected the idea of the miasma theory which related malaria to
2
. Even another widespread theory arose that southern Italians were blamed, to whom malaria was
3
. In southern Italy, the situation became so severe that near half the Italians population was thought to be “permanently at risk”. In malarial areas the
4
. Of rural workers was surprisingly shorter. In the 1880s, such theories began to withdraw as the mosquito was identified as the true cause.

Theories for malaria origin have always been the issue of research for medical practitioners from ancient time. Although the link between malaria and mosquito was established lately, it has been recorded in words that 1 ____ , including mosquito, may play the major culprits. In the 19th century, most experts rejected the idea of the miasma theory which related malaria to 2 ____ . Even another widespread theory arose that southern Italians were blamed, to whom malaria was 3 ____ . In southern Italy, the situation became so severe that near half the Italians population was thought to be “permanently at risk”. In malarial areas the 4 ____ . Of rural workers was surprisingly shorter. In the 1880s, such theories began to withdraw as the mosquito was identified as the true cause.$md$, NULL, ARRAY['.*insects.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('9209419b-061f-5537-b596-1d159f3675c3', '669dea9d-05de-5be5-8b35-85671e96c09a', 3, 'SUMMARY_COMPLETION', 'READING', 2, $md$### Question 3

Questions 1-4
Questions 1-4
Complete the following summary of the paragraphs of Reading Passage.
Using
NO MORE THAN TWO WORDS
from the Reading Passage for each answer.
Write your answers in boxes
1-4
on your answer sheet.
Theories for malaria origin have always been the issue of research for medical practitioners from ancient time. Although the link between malaria and mosquito was established lately, it has been recorded in words that
1
, including mosquito, may play the major culprits. In the 19th century, most experts rejected the idea of the miasma theory which related malaria to
2
. Even another widespread theory arose that southern Italians were blamed, to whom malaria was
3
. In southern Italy, the situation became so severe that near half the Italians population was thought to be “permanently at risk”. In malarial areas the
4
. Of rural workers was surprisingly shorter. In the 1880s, such theories began to withdraw as the mosquito was identified as the true cause.

Theories for malaria origin have always been the issue of research for medical practitioners from ancient time. Although the link between malaria and mosquito was established lately, it has been recorded in words that 1 ____ , including mosquito, may play the major culprits. In the 19th century, most experts rejected the idea of the miasma theory which related malaria to 2 ____ . Even another widespread theory arose that southern Italians were blamed, to whom malaria was 3 ____ . In southern Italy, the situation became so severe that near half the Italians population was thought to be “permanently at risk”. In malarial areas the 4 ____ . Of rural workers was surprisingly shorter. In the 1880s, such theories began to withdraw as the mosquito was identified as the true cause.$md$, NULL, ARRAY['.*insects.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('fdf69bed-e673-5cb9-aec7-90e32ac634fd', '669dea9d-05de-5be5-8b35-85671e96c09a', 4, 'SUMMARY_COMPLETION', 'READING', 2, $md$### Question 4

Questions 1-4
Questions 1-4
Complete the following summary of the paragraphs of Reading Passage.
Using
NO MORE THAN TWO WORDS
from the Reading Passage for each answer.
Write your answers in boxes
1-4
on your answer sheet.
Theories for malaria origin have always been the issue of research for medical practitioners from ancient time. Although the link between malaria and mosquito was established lately, it has been recorded in words that
1
, including mosquito, may play the major culprits. In the 19th century, most experts rejected the idea of the miasma theory which related malaria to
2
. Even another widespread theory arose that southern Italians were blamed, to whom malaria was
3
. In southern Italy, the situation became so severe that near half the Italians population was thought to be “permanently at risk”. In malarial areas the
4
. Of rural workers was surprisingly shorter. In the 1880s, such theories began to withdraw as the mosquito was identified as the true cause.

Theories for malaria origin have always been the issue of research for medical practitioners from ancient time. Although the link between malaria and mosquito was established lately, it has been recorded in words that 1 ____ , including mosquito, may play the major culprits. In the 19th century, most experts rejected the idea of the miasma theory which related malaria to 2 ____ . Even another widespread theory arose that southern Italians were blamed, to whom malaria was 3 ____ . In southern Italy, the situation became so severe that near half the Italians population was thought to be “permanently at risk”. In malarial areas the 4 ____ . Of rural workers was surprisingly shorter. In the 1880s, such theories began to withdraw as the mosquito was identified as the true cause.$md$, NULL, ARRAY['.*insects.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('7faa502e-308d-5a3e-9aee-026086f561a0', '669dea9d-05de-5be5-8b35-85671e96c09a', 5, 'YES_NO_NOT_GIVEN', 'READING', 3, $md$### Question 5

Questions 5-8
Questions 5-8
Do the following statements agree with the claims of the writer in Reading Passage?
In boxes
5-8
on your answer sheet write
YES
if the statement agrees with the claims of the writer
NO
if the statement contradicts the claims of the writer
NOT GIVEN
if it is impossible to say what the writer thinks about this
5
The volunteers in Grassi experiments were from all parts over Italy.
6
Healthy people could remain safe in malaria – infectious zone if they did not have mosquito bites.
7
Quinine is an effective drug which had long been used to combat malaria.
8
Eradicating malaria was a goal combined both medical and political significance.

5 ____ The volunteers in Grassi experiments were from all parts over Italy.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6114dda8-7375-58de-8e3a-d4b331e59211', '7faa502e-308d-5a3e-9aee-026086f561a0', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a70d2e4f-e191-5da9-9143-d734f879f9ef', '7faa502e-308d-5a3e-9aee-026086f561a0', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8e1d0e03-3164-5fb0-8a4c-d678e9135ff4', '7faa502e-308d-5a3e-9aee-026086f561a0', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('163b0245-d452-576f-b9ef-386c7d1cff4e', '669dea9d-05de-5be5-8b35-85671e96c09a', 6, 'YES_NO_NOT_GIVEN', 'READING', 3, $md$### Question 6

Questions 5-8
Questions 5-8
Do the following statements agree with the claims of the writer in Reading Passage?
In boxes
5-8
on your answer sheet write
YES
if the statement agrees with the claims of the writer
NO
if the statement contradicts the claims of the writer
NOT GIVEN
if it is impossible to say what the writer thinks about this
5
The volunteers in Grassi experiments were from all parts over Italy.
6
Healthy people could remain safe in malaria – infectious zone if they did not have mosquito bites.
7
Quinine is an effective drug which had long been used to combat malaria.
8
Eradicating malaria was a goal combined both medical and political significance.

6 ____ Healthy people could remain safe in malaria – infectious zone if they did not have mosquito bites.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('49da970d-827c-59d2-ab49-e322acbe86e1', '163b0245-d452-576f-b9ef-386c7d1cff4e', 1, $md$YES$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('86c376f7-fbb7-5d15-b01c-d6c5a2913b2e', '163b0245-d452-576f-b9ef-386c7d1cff4e', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7f1727a5-73cc-5e6a-a0ee-603219572875', '163b0245-d452-576f-b9ef-386c7d1cff4e', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('fb38f322-7053-5e45-b802-2db3666f3e8d', '669dea9d-05de-5be5-8b35-85671e96c09a', 7, 'YES_NO_NOT_GIVEN', 'READING', 3, $md$### Question 7

Questions 5-8
Questions 5-8
Do the following statements agree with the claims of the writer in Reading Passage?
In boxes
5-8
on your answer sheet write
YES
if the statement agrees with the claims of the writer
NO
if the statement contradicts the claims of the writer
NOT GIVEN
if it is impossible to say what the writer thinks about this
5
The volunteers in Grassi experiments were from all parts over Italy.
6
Healthy people could remain safe in malaria – infectious zone if they did not have mosquito bites.
7
Quinine is an effective drug which had long been used to combat malaria.
8
Eradicating malaria was a goal combined both medical and political significance.

7 ____ Quinine is an effective drug which had long been used to combat malaria.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8c6e673f-1344-5859-a518-3871b39822e3', 'fb38f322-7053-5e45-b802-2db3666f3e8d', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a353dd32-a554-5a63-8b9d-97bd5e31d63e', 'fb38f322-7053-5e45-b802-2db3666f3e8d', 2, $md$NO$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('afcdb44b-f645-5184-ad49-60d36dce53b2', 'fb38f322-7053-5e45-b802-2db3666f3e8d', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('2797deaa-7f69-5ef2-becf-fa2ccdf325cc', '669dea9d-05de-5be5-8b35-85671e96c09a', 8, 'YES_NO_NOT_GIVEN', 'READING', 3, $md$### Question 8

Questions 5-8
Questions 5-8
Do the following statements agree with the claims of the writer in Reading Passage?
In boxes
5-8
on your answer sheet write
YES
if the statement agrees with the claims of the writer
NO
if the statement contradicts the claims of the writer
NOT GIVEN
if it is impossible to say what the writer thinks about this
5
The volunteers in Grassi experiments were from all parts over Italy.
6
Healthy people could remain safe in malaria – infectious zone if they did not have mosquito bites.
7
Quinine is an effective drug which had long been used to combat malaria.
8
Eradicating malaria was a goal combined both medical and political significance.

8 ____ Eradicating malaria was a goal combined both medical and political significance.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8fe45a6c-9b1f-53a1-b487-d8ad9457a0e0', '2797deaa-7f69-5ef2-becf-fa2ccdf325cc', 1, $md$YES$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4bdc0c55-6ba7-56c0-a6ec-b26bda7f77e2', '2797deaa-7f69-5ef2-becf-fa2ccdf325cc', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3b394040-e3cd-574c-ae4f-14fbedd622ed', '2797deaa-7f69-5ef2-becf-fa2ccdf325cc', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('521f4431-cc52-53f1-ac31-cda24ae971e2', '669dea9d-05de-5be5-8b35-85671e96c09a', 9, 'MATCHING_INFORMATION', 'READING', 3, $md$### Question 9

Questions 9-14
Questions 9-14
Reading Passage has 8 paragraphs,
A-H
.
Which paragraph contains the following information?
Write the correct letter
A-H
in boxes
9-14
on your answer sheet.
9
A breakthrough was found that mosquito was the carrier of malaria
10
A scientist intentionally failed to restrict the epidemic area.
11
This successful story still holds true for today’s readers worldwide.
12
One of the final cases reported dying of malaria in Italy
13
the negative symptoms of the highly effective drug
14
A list of the speculative hypothesis was cited.

9 ____ A breakthrough was found that mosquito was the carrier of malaria$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a5d204ca-ff7c-57ff-a2c6-669340d529ed', '521f4431-cc52-53f1-ac31-cda24ae971e2', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('aa0cf7ba-80c3-5477-9d66-71a76602f1bb', '521f4431-cc52-53f1-ac31-cda24ae971e2', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('27140d30-43b2-5f91-aaa6-dfe9b4871e49', '521f4431-cc52-53f1-ac31-cda24ae971e2', 3, $md$C$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f81f3944-ad40-52b1-aca0-ee82b72bf6be', '521f4431-cc52-53f1-ac31-cda24ae971e2', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5ae7011b-f84d-52af-a36f-8cb950290fd8', '521f4431-cc52-53f1-ac31-cda24ae971e2', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('676f3c36-d915-511f-b138-78c5a188c240', '521f4431-cc52-53f1-ac31-cda24ae971e2', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('45cd3d57-90cf-5d04-afa4-0a65a68bd718', '521f4431-cc52-53f1-ac31-cda24ae971e2', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9c922fff-f788-55ee-9364-0439b59e860a', '521f4431-cc52-53f1-ac31-cda24ae971e2', 8, $md$H$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('3e4935b2-7c44-59a7-862b-774dd5898934', '669dea9d-05de-5be5-8b35-85671e96c09a', 10, 'MATCHING_INFORMATION', 'READING', 4, $md$### Question 10

Questions 9-14
Questions 9-14
Reading Passage has 8 paragraphs,
A-H
.
Which paragraph contains the following information?
Write the correct letter
A-H
in boxes
9-14
on your answer sheet.
9
A breakthrough was found that mosquito was the carrier of malaria
10
A scientist intentionally failed to restrict the epidemic area.
11
This successful story still holds true for today’s readers worldwide.
12
One of the final cases reported dying of malaria in Italy
13
the negative symptoms of the highly effective drug
14
A list of the speculative hypothesis was cited.

10 ____ A scientist intentionally failed to restrict the epidemic area.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('83dbcaae-d399-53cf-b139-5c5289f6a192', '3e4935b2-7c44-59a7-862b-774dd5898934', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d52d9a86-3720-5ab7-b4c8-44653ac8cd97', '3e4935b2-7c44-59a7-862b-774dd5898934', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d57d81d1-c095-5603-ae5f-d86d2570ff35', '3e4935b2-7c44-59a7-862b-774dd5898934', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a0e83220-9a0b-55aa-8fd5-7dccc3777a39', '3e4935b2-7c44-59a7-862b-774dd5898934', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6806ac4e-4e94-579c-9729-ea521bff61ae', '3e4935b2-7c44-59a7-862b-774dd5898934', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f3b34c14-ad37-5f4b-a5b9-2142e6cefa65', '3e4935b2-7c44-59a7-862b-774dd5898934', 6, $md$F$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('33c6329c-f60d-5ee8-a3df-902d5f3c8da7', '3e4935b2-7c44-59a7-862b-774dd5898934', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('58727126-4aa9-5db6-ab2b-085440914516', '3e4935b2-7c44-59a7-862b-774dd5898934', 8, $md$H$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('2b68c00d-4f0a-52e8-b66b-d7985cef5349', '669dea9d-05de-5be5-8b35-85671e96c09a', 11, 'MATCHING_INFORMATION', 'READING', 4, $md$### Question 11

Questions 9-14
Questions 9-14
Reading Passage has 8 paragraphs,
A-H
.
Which paragraph contains the following information?
Write the correct letter
A-H
in boxes
9-14
on your answer sheet.
9
A breakthrough was found that mosquito was the carrier of malaria
10
A scientist intentionally failed to restrict the epidemic area.
11
This successful story still holds true for today’s readers worldwide.
12
One of the final cases reported dying of malaria in Italy
13
the negative symptoms of the highly effective drug
14
A list of the speculative hypothesis was cited.

11 ____ This successful story still holds true for today’s readers worldwide.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('516c5d8c-5e42-512a-a16b-37484f1cc639', '2b68c00d-4f0a-52e8-b66b-d7985cef5349', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7d531958-0469-5c1f-ac0f-0b1e9f754b93', '2b68c00d-4f0a-52e8-b66b-d7985cef5349', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ee1fd828-272f-5863-82cd-7e113b46b1c7', '2b68c00d-4f0a-52e8-b66b-d7985cef5349', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('28ebd922-1180-55cc-98d1-32a4f2ad5532', '2b68c00d-4f0a-52e8-b66b-d7985cef5349', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('816d61f2-01f1-5410-82bc-a80cf75a8f27', '2b68c00d-4f0a-52e8-b66b-d7985cef5349', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ad466022-323d-51ee-9e6b-41757ad4aa82', '2b68c00d-4f0a-52e8-b66b-d7985cef5349', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bb0d01f8-5638-5399-b900-959e6ce8a4de', '2b68c00d-4f0a-52e8-b66b-d7985cef5349', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2cab8a3b-56a1-55a8-b8d1-e12df340c7ed', '2b68c00d-4f0a-52e8-b66b-d7985cef5349', 8, $md$H$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('44a02960-ab3b-5b87-b4b9-88fc97687c1a', '669dea9d-05de-5be5-8b35-85671e96c09a', 12, 'MATCHING_INFORMATION', 'READING', 4, $md$### Question 12

Questions 9-14
Questions 9-14
Reading Passage has 8 paragraphs,
A-H
.
Which paragraph contains the following information?
Write the correct letter
A-H
in boxes
9-14
on your answer sheet.
9
A breakthrough was found that mosquito was the carrier of malaria
10
A scientist intentionally failed to restrict the epidemic area.
11
This successful story still holds true for today’s readers worldwide.
12
One of the final cases reported dying of malaria in Italy
13
the negative symptoms of the highly effective drug
14
A list of the speculative hypothesis was cited.

12 ____ One of the final cases reported dying of malaria in Italy$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ff03c883-c78c-5f8d-a401-573d3d34bf69', '44a02960-ab3b-5b87-b4b9-88fc97687c1a', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c41f55ed-839c-5e38-aba7-586391b195d9', '44a02960-ab3b-5b87-b4b9-88fc97687c1a', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d18e77af-46b6-59f9-b460-2289469effca', '44a02960-ab3b-5b87-b4b9-88fc97687c1a', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('aee4d19e-3c86-5ef0-9be8-9d873990a344', '44a02960-ab3b-5b87-b4b9-88fc97687c1a', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8011f8e0-5908-5b44-8ac9-5c20300cefe4', '44a02960-ab3b-5b87-b4b9-88fc97687c1a', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3aee821d-bdcb-5ab4-9384-7add10564a91', '44a02960-ab3b-5b87-b4b9-88fc97687c1a', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cc90a607-6ea5-5968-b45e-8fb456d0e13e', '44a02960-ab3b-5b87-b4b9-88fc97687c1a', 7, $md$G$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('11b93c5b-80db-50bd-8535-fa73a66e7269', '44a02960-ab3b-5b87-b4b9-88fc97687c1a', 8, $md$H$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('9a7d124b-d809-5eda-85b5-adec26c79145', '669dea9d-05de-5be5-8b35-85671e96c09a', 13, 'MATCHING_INFORMATION', 'READING', 4, $md$### Question 13

Questions 9-14
Questions 9-14
Reading Passage has 8 paragraphs,
A-H
.
Which paragraph contains the following information?
Write the correct letter
A-H
in boxes
9-14
on your answer sheet.
9
A breakthrough was found that mosquito was the carrier of malaria
10
A scientist intentionally failed to restrict the epidemic area.
11
This successful story still holds true for today’s readers worldwide.
12
One of the final cases reported dying of malaria in Italy
13
the negative symptoms of the highly effective drug
14
A list of the speculative hypothesis was cited.

13 ____ the negative symptoms of the highly effective drug$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c20ab43d-b4c3-5ee0-90c2-1c1359de74ad', '9a7d124b-d809-5eda-85b5-adec26c79145', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('01303cc2-08b4-5239-9d2e-c7950196cbc5', '9a7d124b-d809-5eda-85b5-adec26c79145', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a39821ea-2b41-57df-a385-4ec784b9146e', '9a7d124b-d809-5eda-85b5-adec26c79145', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a19a634a-a2bb-58c3-8ee8-23902efefdd9', '9a7d124b-d809-5eda-85b5-adec26c79145', 4, $md$D$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('dda05cee-98a5-50dc-bab8-6702bb32da1a', '9a7d124b-d809-5eda-85b5-adec26c79145', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6854e9b3-3a41-52ae-8eda-11a8b17a2678', '9a7d124b-d809-5eda-85b5-adec26c79145', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ce3eff1a-a335-50b9-82ff-c4a2e53bffd2', '9a7d124b-d809-5eda-85b5-adec26c79145', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6f4e3ba1-7ac5-5572-b115-c869f8a5ed6c', '9a7d124b-d809-5eda-85b5-adec26c79145', 8, $md$H$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('f0fbd473-7b58-58dc-9a3b-f420e394e555', '669dea9d-05de-5be5-8b35-85671e96c09a', 14, 'MATCHING_INFORMATION', 'READING', 4, $md$### Question 14

Questions 9-14
Questions 9-14
Reading Passage has 8 paragraphs,
A-H
.
Which paragraph contains the following information?
Write the correct letter
A-H
in boxes
9-14
on your answer sheet.
9
A breakthrough was found that mosquito was the carrier of malaria
10
A scientist intentionally failed to restrict the epidemic area.
11
This successful story still holds true for today’s readers worldwide.
12
One of the final cases reported dying of malaria in Italy
13
the negative symptoms of the highly effective drug
14
A list of the speculative hypothesis was cited.

14 ____ A list of the speculative hypothesis was cited.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fa936f66-da0e-555b-9e6e-39c2d151cdc3', 'f0fbd473-7b58-58dc-9a3b-f420e394e555', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3c7f6864-43a1-518d-ba2b-b210247e072b', 'f0fbd473-7b58-58dc-9a3b-f420e394e555', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('82d8cf0e-bae3-57e8-b520-455c377e9618', 'f0fbd473-7b58-58dc-9a3b-f420e394e555', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a82e3881-5294-55d8-bb0f-bfd6c42dac5e', 'f0fbd473-7b58-58dc-9a3b-f420e394e555', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('033a13bc-822e-51f3-9f66-13d96cd4dd47', 'f0fbd473-7b58-58dc-9a3b-f420e394e555', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('dd7665bc-6d94-5823-b94b-fbb8ed2088b2', 'f0fbd473-7b58-58dc-9a3b-f420e394e555', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0a3f67fe-b13a-53d0-99f3-4ce9dc8d69f0', 'f0fbd473-7b58-58dc-9a3b-f420e394e555', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ab27b9da-abd8-55bf-b522-29844d205688', 'f0fbd473-7b58-58dc-9a3b-f420e394e555', 8, $md$H$md$, false);

COMMIT;
