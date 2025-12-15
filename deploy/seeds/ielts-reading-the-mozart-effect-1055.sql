BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-the-mozart-effect-1055'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-the-mozart-effect-1055';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-the-mozart-effect-1055';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-the-mozart-effect-1055';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('d1a8a902-69ea-5a4d-9935-f424e4b1be00', 'ielts-reading-the-mozart-effect-1055', $t$The Mozart Effect$t$, $md$## The Mozart Effect

Nguồn:
- Test: https://mini-ielts.com/1055/reading/the-mozart-effect
- Solution: https://mini-ielts.com/1055/view-solution/reading/the-mozart-effect$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('55c04537-4c28-59bb-bb6a-affeeba99ee5', 'd1a8a902-69ea-5a4d-9935-f424e4b1be00', 1, $t$Reading — The Mozart Effect$t$, $md$Read the passage and answer questions **1–13**.

### Passage: The Mozart Effect

A

Music has been used for centuries to heal the body. In the Ebers Papyrus (one of the earliest medical documents, circa 1550 BC), it was recorded that physicians chanted to heal the sick (Castleman, 1994). In various cul­tures, we have observed singing as part of healing rituals. In the world of Western medicine, however, using music in medicine lost popularity until the introduction of the radio. Researchers then started to notice that lis­tening to music could have significant physical effects. Therapists noticed music could help calm anxiety, and researchers saw that listening to music, could cause a drop in blood pressure. In addition to these two areas, music has been used with cancer chemotherapy to reduce nausea, during surgery to reduce stress hormone production, during childbirth, and in stroke re­covery (Castleman, 1994 and Westley, 1998). It has been shown to decrease pain as well as enhance the effectiveness of the immune system. In Japan, compilations of music are used as medication of sorts. For example, if you want to cure a headache or migraine, the album suggested is Mendelssohn’s "Spring Song”, Dvorak's “Humoresque”, or part of George Gershwin’s "An American in Paris” (Campbell, 1998). Music is also being used to assist in learning, in a phenomenon called the Mozart Effect.

B

Frances H. Rauscher, PhD, first demonstrated the correlation between mu­sic and learning in an experiment in 1993 . His experiment indicated that a 10-minute dose of Mozart could temporarily boost intelligence. Groups of students were given intelligence tests after listening to silence, relaxation tapes, or Mozart’s "Sonata for Two Pianos in D Major” for a short time. He found that after silence, the average IQ score was 110, and after the relax­ation tapes, the score rose a point. After listening to Mozart’s music, how­ever, the score jumped to 119 (Westley, 1998). Even students who did not like the music still had an increased score in the IQ test. Rauscher hy­pothesised that “listening to complex , non-repetitive music, like Mozart's, may stimulate neural pathways that are important in thinking” (Castleman, 1994).

C

The same experiment was repeated on rats by Rauscher and Hong Hua Li from Stanford. Rats also demonstrated enhancement in their intelligence performance. These new studies indicate that rats that were exposed to Mozart’s showed “increased gene expression of BDNF (a neural growth factor), CREB (a learning and memory compound), and Synapsin I (a synap­tic growth protein) ” in the brain’s hippocampus, compared with rats in the control group, which heard only white noise (e.g. the whooshing sound of a V radio tuned between stations).

D

How exactly does the Mozart Effect work? Researchers are still trying to determine the actual mechanisms for the formation of these enhanced learning pathways. Neuroscientists suspect that music can actually help build and strengthen connections between neurons in the cerebral cortex in a process similar to what occurs in brain development despite its type.

When a baby is born, certain connections have already been made - like connections for heartbeat and breathing. As new information is learned and motor skills develop, new neural connections are formed . Neurons that are not used will eventually die while those used repeatedly will form strong connections . Although a large number of these neural connections require experience, they must also occur within a certain time frame. For example, a child born with cataracts cannot develop connections within the visual cortex. If the cataracts are removed by surgery right away, the child’s vi­sion develops normally. However, after the age of 2, if the cataracts are re­moved, the child will remain blind because those pathways cannot establish themselves.

E

Music seems to work in the same way. In October of 1997, researchers at the University of Konstanz in Germany found that music actually rewires neural circuits (Begley, 1996). Although some of these circuits are formed for physical skills needed to play an instrument, just listening to music strengthens connections used in higher-order thinking. Listening to music can then be thought of as “exercise” for the brain, improving concentration and enhancing intuition.

F

If you’re a little sceptical about the claims made by supporters of the Mozart Effect, you’re not alone . Many people accredit the advanced learning of some children who take music lessons to other personality traits, such as motivation and persistence, which are required in all types of learning . There have also been claims of that influencing the results of some experiments.

G

Furthermore, many people are critical of the role the media had in turning an isolated study into a trend for parents and music educators. After the Mozart Effect was published to the public, the sales of Mozart stayed on the top of the hit list for three weeks . In an article by Michael Linton, he wrote that the research that began this phenomenon (the study by re­searchers at the University of California, Irvine) showed only a temporary boost in IQ, which was not significant enough to even last throughout the course of the experiment. Using music to influence intelligence was used in Confucian civilisation and Plato alluded to Pythagorean music when he de- jj scribed its ideal state in The Republic. In both of these examples, music did not cause any overwhelming changes, and the theory eventually died out. Linton also asks, “If Mozart’s music were able to improve health, why was Mozart himself so frequently sick? If listening to Mozart’s music increases intelligence and encourages spirituality, why aren’t the world’s smartest and most spiritual people Mozart specialists?” Linton raises an interesting point, if the Mozart Effect causes such significant changes, why isn’t there more documented evidence?

H

The “trendiness’’ of the Mozart Effect may have died out somewhat, but there are still strong supporters (and opponents) of the claims made in 1993. Since that initial experiment, there has not been a surge of support­ing evidence. However, many parents, after playing classical music while pregnant or when their children are young, will swear by the Mozart Effect.

A classmate of mine once told me that listening to classical music while studying will help with memorisation. If we approach this controversy from a scientific aspect, although there has been some evidence that music does increase brain activity, actual improvements in learning and memory have not been adequately demonstrated.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('31a29949-36ee-52ba-a0b6-32d3dcec2381', '55c04537-4c28-59bb-bb6a-affeeba99ee5', 1, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 1

Questions 1-5
Questions 1-5
Reading Passage has eight paragraphs
A-H
.
Which paragraph contains the following information?
Write the correct letter
A-H
in boxes
1-5
on your answer sheet.
1
A description of how music affects the brain development of infants
Locate
2
Public’s first reaction to the discovery of the Mozart Effect
Locate
3
The description of Rauscher’s original experiment
Locate
4
The description of using music for healing in other countries
Locate
5
Other qualities needed in all learning
Locate

1 ____ A description of how music affects the brain development of infants Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7fa2b6e8-28d6-53a1-b3fd-3734f461e2c4', '31a29949-36ee-52ba-a0b6-32d3dcec2381', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3d5f25f2-6108-5754-b9c0-961e3aa47a29', '31a29949-36ee-52ba-a0b6-32d3dcec2381', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fca909e7-747c-5ca4-974d-46f86fd5b00a', '31a29949-36ee-52ba-a0b6-32d3dcec2381', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f6d8bc06-59b7-517b-ac2b-6ecd83f7715f', '31a29949-36ee-52ba-a0b6-32d3dcec2381', 4, $md$D$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6188de8e-8ce2-58ea-ab26-307f12f46291', '31a29949-36ee-52ba-a0b6-32d3dcec2381', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f9a525d0-ea47-593a-8e37-f47db96d1148', '31a29949-36ee-52ba-a0b6-32d3dcec2381', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('599a9f9e-b37c-5227-9d7c-db55e44643a1', '31a29949-36ee-52ba-a0b6-32d3dcec2381', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('10c29b59-31e3-55e1-b7aa-7af436c5f885', '31a29949-36ee-52ba-a0b6-32d3dcec2381', 8, $md$H$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('dc7813f2-949d-552f-b706-d298fcb91157', '55c04537-4c28-59bb-bb6a-affeeba99ee5', 2, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 2

Questions 1-5
Questions 1-5
Reading Passage has eight paragraphs
A-H
.
Which paragraph contains the following information?
Write the correct letter
A-H
in boxes
1-5
on your answer sheet.
1
A description of how music affects the brain development of infants
Locate
2
Public’s first reaction to the discovery of the Mozart Effect
Locate
3
The description of Rauscher’s original experiment
Locate
4
The description of using music for healing in other countries
Locate
5
Other qualities needed in all learning
Locate

2 ____ Public’s first reaction to the discovery of the Mozart Effect Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b839305b-abfa-5b37-9267-966aa19d347d', 'dc7813f2-949d-552f-b706-d298fcb91157', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('53e7fdda-b388-56a0-8675-39e2da27c0a8', 'dc7813f2-949d-552f-b706-d298fcb91157', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('93a3eabc-c59e-5964-8276-5bd2e947c425', 'dc7813f2-949d-552f-b706-d298fcb91157', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8dc6c638-59c9-5e20-8fc7-92b3e6cebc1b', 'dc7813f2-949d-552f-b706-d298fcb91157', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2c4d41f3-0c1c-567d-be8b-5018c60d4a9f', 'dc7813f2-949d-552f-b706-d298fcb91157', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8a1f6a34-654f-5f14-a076-fb4f41e3ae6c', 'dc7813f2-949d-552f-b706-d298fcb91157', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('00764685-6430-5fb4-a93a-f010e3888d96', 'dc7813f2-949d-552f-b706-d298fcb91157', 7, $md$G$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a923462a-4b75-5210-902d-99fdf65cfca5', 'dc7813f2-949d-552f-b706-d298fcb91157', 8, $md$H$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('9d0e966c-bf93-596c-8635-ca347e9d4ce0', '55c04537-4c28-59bb-bb6a-affeeba99ee5', 3, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 3

Questions 1-5
Questions 1-5
Reading Passage has eight paragraphs
A-H
.
Which paragraph contains the following information?
Write the correct letter
A-H
in boxes
1-5
on your answer sheet.
1
A description of how music affects the brain development of infants
Locate
2
Public’s first reaction to the discovery of the Mozart Effect
Locate
3
The description of Rauscher’s original experiment
Locate
4
The description of using music for healing in other countries
Locate
5
Other qualities needed in all learning
Locate

3 ____ The description of Rauscher’s original experiment Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b3111027-442c-57e3-8995-5531e4946358', '9d0e966c-bf93-596c-8635-ca347e9d4ce0', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b9ba7895-6957-5275-9ee2-beb7e5b193b9', '9d0e966c-bf93-596c-8635-ca347e9d4ce0', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4be131ab-bbb7-520b-9331-7805e6e1c2fb', '9d0e966c-bf93-596c-8635-ca347e9d4ce0', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d3c55d3f-ca63-57f6-89ae-ba05a006a661', '9d0e966c-bf93-596c-8635-ca347e9d4ce0', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b0fe0e82-e449-5df1-9a14-4c29876413bb', '9d0e966c-bf93-596c-8635-ca347e9d4ce0', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('46f73020-a1d4-5b5f-8ae7-f796dc8a35b2', '9d0e966c-bf93-596c-8635-ca347e9d4ce0', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6ab0b400-ebfa-50f1-93d6-d02b62a2bcba', '9d0e966c-bf93-596c-8635-ca347e9d4ce0', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b20d8296-b6dd-564d-9995-c39f95c52595', '9d0e966c-bf93-596c-8635-ca347e9d4ce0', 8, $md$H$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('46beb30b-a4b9-5584-b7d4-d7430fded2dc', '55c04537-4c28-59bb-bb6a-affeeba99ee5', 4, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 4

Questions 1-5
Questions 1-5
Reading Passage has eight paragraphs
A-H
.
Which paragraph contains the following information?
Write the correct letter
A-H
in boxes
1-5
on your answer sheet.
1
A description of how music affects the brain development of infants
Locate
2
Public’s first reaction to the discovery of the Mozart Effect
Locate
3
The description of Rauscher’s original experiment
Locate
4
The description of using music for healing in other countries
Locate
5
Other qualities needed in all learning
Locate

4 ____ The description of using music for healing in other countries Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9c2389c1-60e0-5b34-a180-20f386434115', '46beb30b-a4b9-5584-b7d4-d7430fded2dc', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fe5c7d04-3134-5cce-8a32-a8a9af3032d2', '46beb30b-a4b9-5584-b7d4-d7430fded2dc', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5f57c649-1a67-5965-83bf-80cd8c107dfc', '46beb30b-a4b9-5584-b7d4-d7430fded2dc', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('94f60ede-d900-5be1-965d-c86b47766e59', '46beb30b-a4b9-5584-b7d4-d7430fded2dc', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e589697b-80bd-5e55-bbaa-b49b8ef6bbb5', '46beb30b-a4b9-5584-b7d4-d7430fded2dc', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('adb595d5-5e01-5605-b232-329d3ddee040', '46beb30b-a4b9-5584-b7d4-d7430fded2dc', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5b057328-c317-53dd-96cd-cc8392e27cf6', '46beb30b-a4b9-5584-b7d4-d7430fded2dc', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('85c161ae-e526-5374-b20f-da65b7f3d7e9', '46beb30b-a4b9-5584-b7d4-d7430fded2dc', 8, $md$H$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('2694db92-aefb-50b8-b251-00202ff021f0', '55c04537-4c28-59bb-bb6a-affeeba99ee5', 5, 'MATCHING_INFORMATION', 'READING', 3, $md$### Question 5

Questions 1-5
Questions 1-5
Reading Passage has eight paragraphs
A-H
.
Which paragraph contains the following information?
Write the correct letter
A-H
in boxes
1-5
on your answer sheet.
1
A description of how music affects the brain development of infants
Locate
2
Public’s first reaction to the discovery of the Mozart Effect
Locate
3
The description of Rauscher’s original experiment
Locate
4
The description of using music for healing in other countries
Locate
5
Other qualities needed in all learning
Locate

5 ____ Other qualities needed in all learning Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7a1d3f97-cbcc-55bd-a3f2-733d0571c24b', '2694db92-aefb-50b8-b251-00202ff021f0', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('16ae1077-93d8-5b8f-8087-6c7aafd50b06', '2694db92-aefb-50b8-b251-00202ff021f0', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b547c403-ce75-599e-a1cb-cd0c4b955d69', '2694db92-aefb-50b8-b251-00202ff021f0', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5a69c868-2e4d-5a1a-bd0e-44ccf64c7f0a', '2694db92-aefb-50b8-b251-00202ff021f0', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e8ca92c0-7e60-5c5c-ae98-738ceba3b83a', '2694db92-aefb-50b8-b251-00202ff021f0', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('af3d9909-fb5f-5ab1-83e2-4ff55b935ca7', '2694db92-aefb-50b8-b251-00202ff021f0', 6, $md$F$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bd2fddfe-3e18-509a-a9ab-21dfd12e8cc1', '2694db92-aefb-50b8-b251-00202ff021f0', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6f619136-1a74-5848-9b6f-fced62380ad6', '2694db92-aefb-50b8-b251-00202ff021f0', 8, $md$H$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('43918d98-b760-5473-8125-bb12e2ca7191', '55c04537-4c28-59bb-bb6a-affeeba99ee5', 6, 'SUMMARY_COMPLETION', 'READING', 3, $md$### Question 6

Questions 6-8
Questions 6-8
Complete the summary below.
Choose
NO MORE THAN ONE WORD
from the passage for each answer.
Write your answers in boxes
6-8
on your answer sheet.
During the experiment conducted by Frances Rauscher, subjects were exposed to the music for a
6
Locate
period of time before they were tested. And Rauscher believes the enhancement in their performance is related to the
7
Locate
nature of Mozart’s music. Later, a similar experiment was also repeated on
8
Locate

During the experiment conducted by Frances Rauscher, subjects were exposed to the music for a 6 ____ Locate period of time before they were tested. And Rauscher believes the enhancement in their performance is related to the 7 ____ Locate nature of Mozart’s music. Later, a similar experiment was also repeated on 8 ____ Locate$md$, NULL, ARRAY['.*short.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('a08097a1-ba89-5fd3-989a-2d3d045a3cdd', '55c04537-4c28-59bb-bb6a-affeeba99ee5', 7, 'SUMMARY_COMPLETION', 'READING', 3, $md$### Question 7

Questions 6-8
Questions 6-8
Complete the summary below.
Choose
NO MORE THAN ONE WORD
from the passage for each answer.
Write your answers in boxes
6-8
on your answer sheet.
During the experiment conducted by Frances Rauscher, subjects were exposed to the music for a
6
Locate
period of time before they were tested. And Rauscher believes the enhancement in their performance is related to the
7
Locate
nature of Mozart’s music. Later, a similar experiment was also repeated on
8
Locate

During the experiment conducted by Frances Rauscher, subjects were exposed to the music for a 6 ____ Locate period of time before they were tested. And Rauscher believes the enhancement in their performance is related to the 7 ____ Locate nature of Mozart’s music. Later, a similar experiment was also repeated on 8 ____ Locate$md$, NULL, ARRAY['.*short.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('4f2d7466-6b86-50ef-be9e-111725941997', '55c04537-4c28-59bb-bb6a-affeeba99ee5', 8, 'SUMMARY_COMPLETION', 'READING', 3, $md$### Question 8

Questions 6-8
Questions 6-8
Complete the summary below.
Choose
NO MORE THAN ONE WORD
from the passage for each answer.
Write your answers in boxes
6-8
on your answer sheet.
During the experiment conducted by Frances Rauscher, subjects were exposed to the music for a
6
Locate
period of time before they were tested. And Rauscher believes the enhancement in their performance is related to the
7
Locate
nature of Mozart’s music. Later, a similar experiment was also repeated on
8
Locate

During the experiment conducted by Frances Rauscher, subjects were exposed to the music for a 6 ____ Locate period of time before they were tested. And Rauscher believes the enhancement in their performance is related to the 7 ____ Locate nature of Mozart’s music. Later, a similar experiment was also repeated on 8 ____ Locate$md$, NULL, ARRAY['.*short.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('56f8a5e7-792e-5ee7-9fe0-434bafa5d33a', '55c04537-4c28-59bb-bb6a-affeeba99ee5', 9, 'TRUE_FALSE_NOT_GIVEN', 'READING', 3, $md$### Question 9

Questions 9-13
Questions 9-13
Do the following statements agree with the information given in Reading Passage?
In boxes
9-13
on your answer sheet, write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
9
All kinds of music can enhance one’s brain performance to somewhat extent.
Locate
10
There is no neural connection made when a baby is born.
Locate
11
There are very few who question the Mozart Effect.
Locate
12
Michael Linton conducted extensive research on Mozart’s life.
13
There is not enough evidence in support of the Mozart Effect today.
Locate

9 ____ All kinds of music can enhance one’s brain performance to somewhat extent. Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('42120e20-bbe2-5c06-bbab-9bd12c62c3c6', '56f8a5e7-792e-5ee7-9fe0-434bafa5d33a', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('65f9f9eb-8080-5a7e-92bf-4f87ed268ce5', '56f8a5e7-792e-5ee7-9fe0-434bafa5d33a', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('606bd0a8-14ca-5a4a-a7c2-4558ef6d3dfa', '56f8a5e7-792e-5ee7-9fe0-434bafa5d33a', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('ddca756d-11a4-5861-ab03-75124a6c459c', '55c04537-4c28-59bb-bb6a-affeeba99ee5', 10, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 10

Questions 9-13
Questions 9-13
Do the following statements agree with the information given in Reading Passage?
In boxes
9-13
on your answer sheet, write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
9
All kinds of music can enhance one’s brain performance to somewhat extent.
Locate
10
There is no neural connection made when a baby is born.
Locate
11
There are very few who question the Mozart Effect.
Locate
12
Michael Linton conducted extensive research on Mozart’s life.
13
There is not enough evidence in support of the Mozart Effect today.
Locate

10 ____ There is no neural connection made when a baby is born. Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('186507f6-cd17-54f9-84e4-216a9a7af715', 'ddca756d-11a4-5861-ab03-75124a6c459c', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('806ddf42-e3c5-5383-9015-8de135129d1e', 'ddca756d-11a4-5861-ab03-75124a6c459c', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7153de54-3498-573c-a295-689512604758', 'ddca756d-11a4-5861-ab03-75124a6c459c', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('15f6e809-dd69-5ea9-942d-a06e3f4ef5b3', '55c04537-4c28-59bb-bb6a-affeeba99ee5', 11, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 11

Questions 9-13
Questions 9-13
Do the following statements agree with the information given in Reading Passage?
In boxes
9-13
on your answer sheet, write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
9
All kinds of music can enhance one’s brain performance to somewhat extent.
Locate
10
There is no neural connection made when a baby is born.
Locate
11
There are very few who question the Mozart Effect.
Locate
12
Michael Linton conducted extensive research on Mozart’s life.
13
There is not enough evidence in support of the Mozart Effect today.
Locate

11 ____ There are very few who question the Mozart Effect. Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8a818af3-597c-597f-81bd-f4d67dd0bbcb', '15f6e809-dd69-5ea9-942d-a06e3f4ef5b3', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('25485ea8-c0f5-5e0c-940e-e4c41bf66230', '15f6e809-dd69-5ea9-942d-a06e3f4ef5b3', 2, $md$FALSE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7812f981-d764-5199-a0e3-85d1fbcc7e73', '15f6e809-dd69-5ea9-942d-a06e3f4ef5b3', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('50e05f5a-b3dd-515f-8b41-defd74200759', '55c04537-4c28-59bb-bb6a-affeeba99ee5', 12, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 12

Questions 9-13
Questions 9-13
Do the following statements agree with the information given in Reading Passage?
In boxes
9-13
on your answer sheet, write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
9
All kinds of music can enhance one’s brain performance to somewhat extent.
Locate
10
There is no neural connection made when a baby is born.
Locate
11
There are very few who question the Mozart Effect.
Locate
12
Michael Linton conducted extensive research on Mozart’s life.
13
There is not enough evidence in support of the Mozart Effect today.
Locate

12 ____ Michael Linton conducted extensive research on Mozart’s life.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b389f52c-acdb-5101-b21a-0ac24414b502', '50e05f5a-b3dd-515f-8b41-defd74200759', 1, $md$TRUE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('77c18b6d-73be-53b1-964a-dcafa992f251', '50e05f5a-b3dd-515f-8b41-defd74200759', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('13d986d5-496b-5f6f-b249-27e610e22b40', '50e05f5a-b3dd-515f-8b41-defd74200759', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('ceb1b0ce-6e69-5154-b2c3-cef9a20355fc', '55c04537-4c28-59bb-bb6a-affeeba99ee5', 13, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 13

Questions 9-13
Questions 9-13
Do the following statements agree with the information given in Reading Passage?
In boxes
9-13
on your answer sheet, write
TRUE
if the statement agrees with the information
FALSE
if the statement contradicts the information
NOT GIVEN
if there is no information on this
9
All kinds of music can enhance one’s brain performance to somewhat extent.
Locate
10
There is no neural connection made when a baby is born.
Locate
11
There are very few who question the Mozart Effect.
Locate
12
Michael Linton conducted extensive research on Mozart’s life.
13
There is not enough evidence in support of the Mozart Effect today.
Locate

13 ____ There is not enough evidence in support of the Mozart Effect today. Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('97a72856-d164-5c88-abe3-fa9852d0e4a6', 'ceb1b0ce-6e69-5154-b2c3-cef9a20355fc', 1, $md$TRUE$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a8335cd2-a058-5044-ae9b-3db103d10daa', 'ceb1b0ce-6e69-5154-b2c3-cef9a20355fc', 2, $md$FALSE$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4263fd73-5b05-56a5-a1ce-03bc2aedb620', 'ceb1b0ce-6e69-5154-b2c3-cef9a20355fc', 3, $md$NOT GIVEN$md$, false);

COMMIT;
