BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-twin-study-two-of-a-kind-1368'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-twin-study-two-of-a-kind-1368';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-twin-study-two-of-a-kind-1368';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-twin-study-two-of-a-kind-1368';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('e7d14dab-d6e7-504e-b94a-2d67732c3fa5', 'ielts-reading-twin-study-two-of-a-kind-1368', $t$Twin Study: Two of a kind$t$, $md$## Twin Study: Two of a kind

Nguồn:
- Test: https://mini-ielts.com/1368/reading/twin-study-two-of-a-kind
- Solution: https://mini-ielts.com/1368/view-solution/reading/twin-study-two-of-a-kind$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('565d3891-2e8c-5c17-939e-d68ba41e1ec1', 'e7d14dab-d6e7-504e-b94a-2d67732c3fa5', 1, $t$Reading — Twin Study: Two of a kind$t$, $md$Read the passage and answer questions **1–7**.

### Passage: Twin Study: Two of a kind

A

THE scientific study of twins goes back to the late 19th century, when Francis Galton, an early geneticist, realised that they came in two varieties: identical twins born from one egg and non-identical twins that had come from two. That insight turned out to be key, although it was not until 1924 that it was used to formulate what is known as the twin rule of pathology, and twin studies really got going.

B

The twin rule of pathology states that any heritable disease will be more concordant (that is, more likely to be jointly present or absent) in identical twins than in non-identical twins – and, in turn, will be more concordant in non-identical twins than in non-siblings. Early work, for example, showed that the statistical correlation of skin-mole counts between identical twins was 0.4, while non-identical twins had a correlation of only 0.2. (A score of 1.0 implies a perfect correlation, while a score of zero implies no correlation.) This result suggests that moles are heritable, but it also implies that there is an environmental component to the development of moles, otherwise, the correlation in identical twins would be close to 1.0.

C

Twin research has shown that whether or not someone takes up smoking is determined mainly by environmental factors, but once he does so, how much he smokes is largely down to his genes. And while a person’s religion is clearly a cultural attribute, there is a strong genetic component to religious fundamentalism. Twin studies are also unraveling the heritability of various aspects of human personality. Traits from neuroticism and anxiety to thrill – and novelty-seeking all have large genetic components. Parenting matters, but it does not determine personality in the way that some had thought.

D

More importantly, perhaps, twin studies are helping the understanding of diseases such as cancer, asthma, osteoporosis, arthritis and immune disorders. And twins can be used, within ethical, for medical experiments. A study that administered vitamin C to one twin and a placebo to the other found that it had no effect on the common cold. The lesson from all of today’s twin studies is that most human traits are at least partially influenced by genes. However, for the most part, the age-old dichotomy between nature and nurture is not very useful. Many genetic programs are open to input from the environment, and genes are frequently switched on or off by environmental signals. It is also possible that genes themselves influence their environment. Some humans have an innate preference for participation in sports. Others are drawn to novelty. Might people also be drawn to certain kinds of friends and types of experience? In this way, a person’s genes might shape the environment they act in as much as the environment shapes the actions of the genes.

E

In the past, such research has been controversial. Josef Mengele, a Nazi doctor working at the Auschwitz extermination camp during the second world war, was fascinated by twins. He sought them out among arrivals at the camp and preserved them from the gas-chambers for a series of brutal experiments. After the war, Cyril Burt, a British psychologist who worked on the heredity of intelligence, tainted twin research with results that appear, in retrospect, to have been rather too good. Some of his data on identical twins who had been reared apart were probably faked. In any case, the prevailing ideology in the social sciences after the war was Marxist and disliked suggestions that differences in human potential might have underlying genetic causes. Twin studies were thus viewed with suspicion.

F

The ideological pendulum has swung back; however, as the human genome project and its aftermath have turned genes for abstract concepts to real pieces of DNA. The role of genes in sensitive areas such as intelligence is acknowledged by all but a few die-hards. The interesting questions now concern how nature and nurture interact to produce particular bits of biology, rather than which of the two is more important. Twin studies, which are a good way to ask these questions, are back in fashion, and many twins are enthusiastic participants in this research.

G

Research at the Twinsburg festival began in a small way, with a single stand in 1979. Gradually, news spread and more scientists began turning up. This year, half a dozen groups of researchers were lodged in a specially pitched research tent. In one corner of this tent, Paul Breslin, who works at the Monell Institute in Philadelphia, watched over several tables where twins sat sipping clear liquids from cups and making notes. It was the team’s third year at Twinsburg. Dr Breslin and his colleagues want to find out how genes influence human perception, particularly the senses of smell and taste and those (warmth, cold, pain, tingle, itch and so on) that result from stimulation of the skin. Perception is an example of something that is probably influenced by both genes and experience. Even before birth, people are exposed to flavours such as chocolate, garlic, mint and vanilla that pass intact into the bloodstream, and thus to the fetus. Though it is not yet clear whether such pre-natal exposure shapes taste-perception, there is evidence that it shapes preferences for foods encountered later in life.

H

However, there are clearly genetic influences at work, as well – for example in the ability to taste quinine. Some people experience this as intensely bitter, even when it is present at very low levels. Others, whose genetic endowment is different, are less bothered by it. Twin studies make this extremely clear. Within a pair of identical twins, either both, or neither, will find quinine hard to swallow. Non-identical twins will agree less frequently.

I

On the other side of the tent Dennis Drayna, from the National Institute on Deafness and Other Communication Disorders, in Maryland, was studying hearing. He wants to know what happens to sounds after they reach the ear. It is not clear, he says, whether the sound is processed into sensation mostly in the ear or in the brain. Dr Drayna has already been involved in a twin study which revealed that the perception of musical pitch is highly heritable. At Twinsburg, he is playing different words, or parts of words, into the left and right ears of his twinned volunteers. The composite of the two sounds that an individual reports hearing depends on how he processes this diverse information and that, Dr Drayna believes, may well be influenced by genetics.

J

Elsewhere in the marquee, Peter Miraldi, of Kent State University in Ohio, was trying to find out whether genes affect an individual’s motivation to communicate with others. A number of twin studies have shown that personality and sociability are heritable, so he thinks this is fertile ground. And next to Mr Miraldi was a team of dermatologists from Case Western Reserve University in Cleveland. They are looking at the development of skin disease and male-pattern baldness. The goal of the latter piece of research is to find the genes responsible for making men’s hair fall out.

K

The busiest part of the tent, however, was the queue for forensic-science research into fingerprints. The origins of this study are shrouded in mystery. For many months, the festival’s organisers have been convinced that the Secret Service – the American government agency responsible for, among other things, the safety of the president – is behind it. When The Economist contacted the Secret Service for more information, we were referred to Steve Nash, who is chairman of the International Association for Identification (IAI) and is also a detective in the scientific investigations section of the Marin Country Sheriff’s Office in California. The IAI, based in Minnesota, is an organisation of forensic scientists from around the world. Among other things, it publishes the Journal of Forensic Identification.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('c0914c3a-41a3-51af-aa36-aa754c8b2614', '565d3891-2e8c-5c17-939e-d68ba41e1ec1', 1, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 1

Questions 1-5
Questions 1-5
The Reading Passage has seven paragraphs
A-K
Which paragraph contains the following information?
Write the correct letter
A-K
, in boxes
1-5
on your answer sheet.
NB
You may use any letter more than once.
1
Mentioned research conducted in Ohio
2
Medical contribution to the researches for twins.
3
Research situation under life-threatening conditions
4
Data of similarities of identical twins
5
Reasons that make one study unconvincing

1 ____ Mentioned research conducted in Ohio$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4e53e561-2356-5756-81bf-2289c742a97b', 'c0914c3a-41a3-51af-aa36-aa754c8b2614', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('507af426-da41-5f15-9d21-9df0a2242327', 'c0914c3a-41a3-51af-aa36-aa754c8b2614', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ef05ffac-f34e-5056-affc-e893c39cbb21', 'c0914c3a-41a3-51af-aa36-aa754c8b2614', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2083530c-8b18-5148-83dd-cbe79ce3def5', 'c0914c3a-41a3-51af-aa36-aa754c8b2614', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c8b2e217-e786-5f47-b716-f24c16bed40d', 'c0914c3a-41a3-51af-aa36-aa754c8b2614', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8319cee0-fbfb-5c60-8e0d-fc6ee873c83a', 'c0914c3a-41a3-51af-aa36-aa754c8b2614', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('87c834da-4876-53eb-a29a-8d03471faec9', 'c0914c3a-41a3-51af-aa36-aa754c8b2614', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c5ac4237-c805-5b77-8789-3b3937926987', 'c0914c3a-41a3-51af-aa36-aa754c8b2614', 8, $md$H$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8710e216-f873-5db9-b2c0-e59e2adc4f14', 'c0914c3a-41a3-51af-aa36-aa754c8b2614', 9, $md$I$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('21537382-90e6-51c0-81f0-af642ebfb255', 'c0914c3a-41a3-51af-aa36-aa754c8b2614', 10, $md$J$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c3801d1e-9e12-5017-84a5-337dd7bc8df9', 'c0914c3a-41a3-51af-aa36-aa754c8b2614', 11, $md$K$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('80a45d92-08c4-5d8a-9d98-464ada8b9044', '565d3891-2e8c-5c17-939e-d68ba41e1ec1', 2, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 2

Questions 1-5
Questions 1-5
The Reading Passage has seven paragraphs
A-K
Which paragraph contains the following information?
Write the correct letter
A-K
, in boxes
1-5
on your answer sheet.
NB
You may use any letter more than once.
1
Mentioned research conducted in Ohio
2
Medical contribution to the researches for twins.
3
Research situation under life-threatening conditions
4
Data of similarities of identical twins
5
Reasons that make one study unconvincing

2 ____ Medical contribution to the researches for twins.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b7da119e-f627-5d65-a59d-5fb64f8870b6', '80a45d92-08c4-5d8a-9d98-464ada8b9044', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('80f4b15e-b0c8-56dc-85df-09c3ffa3d91d', '80a45d92-08c4-5d8a-9d98-464ada8b9044', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2ce4fbb6-ae23-578f-a1ac-7780726e59ba', '80a45d92-08c4-5d8a-9d98-464ada8b9044', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('444be8b4-e96f-556f-b884-65f2a9d74ce8', '80a45d92-08c4-5d8a-9d98-464ada8b9044', 4, $md$D$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('51134d48-399b-5ea7-be2b-f9028a976b57', '80a45d92-08c4-5d8a-9d98-464ada8b9044', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d2534a06-3ee4-57cc-9402-f5f9529ad342', '80a45d92-08c4-5d8a-9d98-464ada8b9044', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0b7f6cb8-b0d3-5d3d-9268-1bbaf168be28', '80a45d92-08c4-5d8a-9d98-464ada8b9044', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f96be3a5-c931-5865-8570-ac83706209e2', '80a45d92-08c4-5d8a-9d98-464ada8b9044', 8, $md$H$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('629f58d3-e421-520f-94e1-e629ee65a081', '80a45d92-08c4-5d8a-9d98-464ada8b9044', 9, $md$I$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c8934004-064a-5712-8cb1-5eab3cb16b2b', '80a45d92-08c4-5d8a-9d98-464ada8b9044', 10, $md$J$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b80d5b10-f202-5645-a9fa-f4ce907ed0e2', '80a45d92-08c4-5d8a-9d98-464ada8b9044', 11, $md$K$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('aa9e68e4-4766-5244-a29c-f47c1fc93303', '565d3891-2e8c-5c17-939e-d68ba41e1ec1', 3, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 3

Questions 1-5
Questions 1-5
The Reading Passage has seven paragraphs
A-K
Which paragraph contains the following information?
Write the correct letter
A-K
, in boxes
1-5
on your answer sheet.
NB
You may use any letter more than once.
1
Mentioned research conducted in Ohio
2
Medical contribution to the researches for twins.
3
Research situation under life-threatening conditions
4
Data of similarities of identical twins
5
Reasons that make one study unconvincing

3 ____ Research situation under life-threatening conditions$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ee96437a-29ad-5a16-a056-20b6169c1a8f', 'aa9e68e4-4766-5244-a29c-f47c1fc93303', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bafa5a83-6833-5eca-8fa3-c80c4f6d5bbd', 'aa9e68e4-4766-5244-a29c-f47c1fc93303', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('09ac4a9f-7087-5902-adcd-58f413125109', 'aa9e68e4-4766-5244-a29c-f47c1fc93303', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a9ecf005-5834-5fe1-b04e-a4b9323aaef6', 'aa9e68e4-4766-5244-a29c-f47c1fc93303', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6863ea3e-9145-56a4-b786-ccaf14fdc75d', 'aa9e68e4-4766-5244-a29c-f47c1fc93303', 5, $md$E$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('40521460-6623-5772-a0ff-1b079739c740', 'aa9e68e4-4766-5244-a29c-f47c1fc93303', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('eeace0ee-de6f-5187-87c9-957e295a3f04', 'aa9e68e4-4766-5244-a29c-f47c1fc93303', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cfbedf80-4d18-58ad-a6ba-e4cc973fabb1', 'aa9e68e4-4766-5244-a29c-f47c1fc93303', 8, $md$H$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('11ed283f-4592-566d-a7de-50109dd86cd8', 'aa9e68e4-4766-5244-a29c-f47c1fc93303', 9, $md$I$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a409f9e6-55d6-58a1-8aef-dde2ecb9f485', 'aa9e68e4-4766-5244-a29c-f47c1fc93303', 10, $md$J$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4f5a8026-7695-574c-a397-05dc09f5d8b9', 'aa9e68e4-4766-5244-a29c-f47c1fc93303', 11, $md$K$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('f262ef34-e4c7-53fa-ae4e-2f70e5610227', '565d3891-2e8c-5c17-939e-d68ba41e1ec1', 4, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 4

Questions 1-5
Questions 1-5
The Reading Passage has seven paragraphs
A-K
Which paragraph contains the following information?
Write the correct letter
A-K
, in boxes
1-5
on your answer sheet.
NB
You may use any letter more than once.
1
Mentioned research conducted in Ohio
2
Medical contribution to the researches for twins.
3
Research situation under life-threatening conditions
4
Data of similarities of identical twins
5
Reasons that make one study unconvincing

4 ____ Data of similarities of identical twins$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('36c136a6-b844-5372-b184-eec12fe67c3b', 'f262ef34-e4c7-53fa-ae4e-2f70e5610227', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8f5307d7-096d-5b41-85c0-ed6d3b3759c4', 'f262ef34-e4c7-53fa-ae4e-2f70e5610227', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('624df09e-dbcb-51ff-9a6c-6c22e1166b68', 'f262ef34-e4c7-53fa-ae4e-2f70e5610227', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('868bdff6-cdb9-5b2f-b702-5a12e92c3422', 'f262ef34-e4c7-53fa-ae4e-2f70e5610227', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('78648c2c-342b-5db1-a616-99caa16cb241', 'f262ef34-e4c7-53fa-ae4e-2f70e5610227', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b58a1b31-4e62-5778-a8f8-e146e23dce45', 'f262ef34-e4c7-53fa-ae4e-2f70e5610227', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c16f2d33-ae28-55c3-901c-5bfa309aa389', 'f262ef34-e4c7-53fa-ae4e-2f70e5610227', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('59455c2b-431b-5c0f-82c2-9a2f0b8ae773', 'f262ef34-e4c7-53fa-ae4e-2f70e5610227', 8, $md$H$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('394bef30-8117-51c9-acfd-84a8027243d1', 'f262ef34-e4c7-53fa-ae4e-2f70e5610227', 9, $md$I$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('19cbbafd-2f19-5b34-8303-e1acf79f9ca0', 'f262ef34-e4c7-53fa-ae4e-2f70e5610227', 10, $md$J$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('02ae50a5-01a4-5805-91fe-89a383766978', 'f262ef34-e4c7-53fa-ae4e-2f70e5610227', 11, $md$K$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('1c392391-bb06-5907-a7a1-873048ad7c26', '565d3891-2e8c-5c17-939e-d68ba41e1ec1', 5, 'MATCHING_INFORMATION', 'READING', 3, $md$### Question 5

Questions 1-5
Questions 1-5
The Reading Passage has seven paragraphs
A-K
Which paragraph contains the following information?
Write the correct letter
A-K
, in boxes
1-5
on your answer sheet.
NB
You may use any letter more than once.
1
Mentioned research conducted in Ohio
2
Medical contribution to the researches for twins.
3
Research situation under life-threatening conditions
4
Data of similarities of identical twins
5
Reasons that make one study unconvincing

5 ____ Reasons that make one study unconvincing$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9cfeaad2-e6a7-59f5-8adc-ebd156da6870', '1c392391-bb06-5907-a7a1-873048ad7c26', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b42a75f4-30db-5690-b78e-8063432a464e', '1c392391-bb06-5907-a7a1-873048ad7c26', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4ed86a97-5bfa-52d9-8a2e-b124c760a895', '1c392391-bb06-5907-a7a1-873048ad7c26', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6e9c31d4-c840-5728-8c5f-3c55a95f2d60', '1c392391-bb06-5907-a7a1-873048ad7c26', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('06ed0e0b-3a07-5301-875a-ed17a7d3fea5', '1c392391-bb06-5907-a7a1-873048ad7c26', 5, $md$E$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('90892e0b-cdf1-56f5-830b-09a0e4df7669', '1c392391-bb06-5907-a7a1-873048ad7c26', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7ed3c0a0-6d60-5fb8-b060-de82973f870e', '1c392391-bb06-5907-a7a1-873048ad7c26', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1bf066a1-55a0-54d4-a0db-522fbc243517', '1c392391-bb06-5907-a7a1-873048ad7c26', 8, $md$H$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3e14fa55-97f3-585f-90d3-8c366112be1c', '1c392391-bb06-5907-a7a1-873048ad7c26', 9, $md$I$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1845484e-05f3-5c06-9b21-646e7fce4106', '1c392391-bb06-5907-a7a1-873048ad7c26', 10, $md$J$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('df3c8d22-c0a0-5eb2-84d3-d8dc51368837', '1c392391-bb06-5907-a7a1-873048ad7c26', 11, $md$K$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('39658014-1248-565a-a295-1516b9cad642', '565d3891-2e8c-5c17-939e-d68ba41e1ec1', 6, 'SUMMARY_COMPLETION', 'READING', 3, $md$### Question 6

Questions 6-7
Questions 6-7
Complete the following summary of the paragraphs of Reading Passage
Using
NO MORE THAN TWO WORDS
from the Reading Passage for each answer.
Write your answers in boxes
6-7
on your answer sheet.
The first one that conducted research on twins is called
6
. He separated twins into two categories: non-identical and identical twins. The twin research was used in a medical application in as early as the year of
7
.

The first one that conducted research on twins is called 6 ____ . He separated twins into two categories: non-identical and identical twins. The twin research was used in a medical application in as early as the year of 7 ____ .$md$, NULL, ARRAY['.*francis.*galton.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('e2f52452-5b53-5557-8ec1-3ad8806ee979', '565d3891-2e8c-5c17-939e-d68ba41e1ec1', 7, 'SUMMARY_COMPLETION', 'READING', 3, $md$### Question 7

Questions 6-7
Questions 6-7
Complete the following summary of the paragraphs of Reading Passage
Using
NO MORE THAN TWO WORDS
from the Reading Passage for each answer.
Write your answers in boxes
6-7
on your answer sheet.
The first one that conducted research on twins is called
6
. He separated twins into two categories: non-identical and identical twins. The twin research was used in a medical application in as early as the year of
7
.

The first one that conducted research on twins is called 6 ____ . He separated twins into two categories: non-identical and identical twins. The twin research was used in a medical application in as early as the year of 7 ____ .$md$, NULL, ARRAY['.*francis.*galton.*']);

COMMIT;
