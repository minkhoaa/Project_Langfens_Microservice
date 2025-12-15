BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-tickling-and-laughter-1397'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-tickling-and-laughter-1397';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-tickling-and-laughter-1397';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-tickling-and-laughter-1397';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('f4a17af9-78d2-5b0f-914a-faa59ca17282', 'ielts-reading-tickling-and-laughter-1397', $t$Tickling and Laughter$t$, $md$## Tickling and Laughter

Nguồn:
- Test: https://mini-ielts.com/1397/reading/tickling-and-laughter
- Solution: https://mini-ielts.com/1397/view-solution/reading/tickling-and-laughter$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('22c8d6ce-bc34-50e8-9844-c7f37d28b9a8', 'f4a17af9-78d2-5b0f-914a-faa59ca17282', 1, $t$Reading — Tickling and Laughter$t$, $md$Read the passage and answer questions **1–14**.

### Passage: Tickling and Laughter

A

The fingers of an outstretched aim are nearing your body; you bend away folding your torso, bending your head to your shoulder in hopes that you don’t get tickled; but the inevitable occurs: yon arc tickled and in hysterics, you chuckle, titter, and burst into uncontrollable laughter. Why do we laugh when we are tickled?

B

Tickling is caused by a light sensation across our skin. At times the light sensation can cause itching; however, most of the time it causes giggling. If a feather is gently moved across the surface of the skin, it can also cause tickling and giggling. Heavy laughter is caused by someone or something placing repeated pressure on a person and tickling a particular area. The spots tickled often are feet, toes, sides, underarms, and neck which cause a great deal of laughter. Yngve Zotterman from Karolinska Institute has found that tickling sensations involve signals from nerve fibers. These nerve fibers are associated with pain and touch. Also, Zotterman has discovered tickling sensations to be associated not only with nerve fibers but also with sense of touch because people who have lost pain sensations still laugh when tickled. But really, why do we laugh? Why are we not able to tickle ourselves? What part of the brain is responsible for laughter and humor? Why do we say some people have no sense of humor?

C

Research has shown that laughter is more than just a person’s voice and movement and that it requires the coordination of many muscles throughout the body. Laughter also increases blood pressure and heart rate, changes breathing, reduces levels of certain neurochemicals (catecholamines, hormones) and provides a boost to dying immune system. Can laughter improve health? It may be a good way for people to relax because muscle tension is reduced after laughing. Human tests have found some evidence that humorous videos and tapes can reduce feelings of pain, prevent negative stress reactions and boost the brain’s biological battle against infection.

D

Researchers believe we process humor and laughter through a complex pathway of brain activity that encompasses three main brain components. In one new study, researchers used imaging equipment to photograph die brain activity of healthy volunteers while they underwent a sidesplitting assignment of reading written jokes, viewing cartoons from The New Yorker magazine as well as “The Far Side” and listening to digital recordings of laughter. Preliminary results indicate that the humor-processing pathway includes parts of the frontal lobe brain area, important for cognitive processing the supplementary motor area, important for movement; and the nucleus accumbens, associated with pleasure. Investigations support the notion that parts of the frontal lobe are involved in humor. Subjects’ brains were imaged while they were listening to jokes. An area of the frontal lobe was activated only when they thought a joke was funny. In a study that compared healthy individuals with people who had damage to their frontal lobes, the subjects with damaged frontal lobes were more likely to choose wrong punch lines to written jokes and didn’t laugh or smile as much at funny cartoons or jokes.

E

Even though we may know more about what parts of the brain are responsible for humor, it is still hard to explain why we don’t laugh or giggle when we tickle ourselves. Darwin theorized within “The Expressions of the Emotions in Man and Animals” that there was a link between tickling and laughter because of the anticipation of pleasure. Because we cannot tickle ourselves and have caused laughter, Darwin speculated surprise from another person touching a sensitive spot must have caused laughter. Some scientists believe that laughing caused by tickling is a built-in reflex even babies have. If we tickle ourselves in the same spot as our friend tickled us, we do not laugh as we did previously. The information sent to our spinal cord and brain should be exactly the same. Apparently, for tickling to work, the brain needs tension and surprise. When we tickle ourselves, we know exactly what will happen…there is no tension or surprise. How the brain uses this information about tension and surprise is still a mystery, but there is some evidence that the cerebellum may be involved. Because one part of the brain tells another: “It’s just you. Don’t get excited”. Investigations suggest that during self-tickling, the cerebellum tells an area called the somatosensory cortex what sensation to expect, and that dampens the tickling sensation. It looks as if the killjoy is found in the cerebellum. Further explorations to understand tickling and laughter were conducted by Christenfeld and Harris. Within ‘The Mystery of Ticklish Laughter and “Can a Machine Tickleyn they explained that people laughed equally whether tickled by a machine or by a person. The participants were not aware that who or what was tickling them. However, the laughter was equally resounded. It is suggested that tickling response is a reflex, which, like Darwin suggested earlier, is dependent on the element of surprise.

F

Damage to any one part of the brain may affect one’s overall ability to process humor. Peter Derks, a professor of psychology, conducted his research with a group of scientists at NASA-Langley in Hampton. Using a sophisticated electroencephalogram (EEG), they measured the brain activity of 10 people exposed to humorous stimuli. How quickly our brain recognizes the incongruity that deals with most humor and attaches an abstract meaning to it determines whether we laugh. However, different people find different jokes funny. That can be due to a number of factors, including differences in personality, intelligence, mental state and probably mood. But according to Derks, the majority of people recognize when a situation is meant to be humorous. In a series of experiments, he noticed that several patients recovering from brain injuries could not distinguish between something funny and something not.

G

Dr Shibata of the University of Rochester School of Medicine said our neurons get tickled when we hear a joke. The brain’s ‘Tunny bone” is located at the right frontal lobe just above the right eye and appears critical to our ability to recognize a joke. Dr Shibata gave his patients MRI scans to measure brain activity, trying to find out what part of the brain is particularly active while telling the punch line of a joke as opposed to the rest of the joke and funny cartoons in comparison to parts of the cartoons that are not funny. The jokes “tickled” the frontal lobes. The scans also showed activity in the nucleus accumbens, which is likely related to our feeling of mirth after hearing a good joke and our “addiction” to humor. While his research was about humor, the results could help lead to answers and solutions to depression. Parts of the brain that are active during humor are actually abnormal in patients with depression. Eventually, brain scans might be used to assess patients with depression and other mood disorders. The research may also explain why some stroke victims lose their sense of humor or suffer from other personality changes. The same part of the brain is also associated with social and emotional judgment and planning.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('caba45f4-0a3a-5d78-a158-6d7ec8c6b7cf', '22c8d6ce-bc34-50e8-9844-c7f37d28b9a8', 1, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 1

Questions 1-7
Questions 1-7
The Reading Passage has 7 paragraphs,
A-G
.
Which paragraph contains the following information?
Write the appropriate letter,
A-G
, in boxes
1-7
on your answer sheet.
NB
You may use any letter more than once.
1
Location of a brain section essential to the recognition of jokes
2
Laughter enhances immunity
3
Individual differences and the appreciation of humour
4
Parts of the brain responsible for tickling reflex
5
Neuropsychological mechanisms by which humor and laughter work
6
The connection between tickling and nerve fibers
7
Patients with emotional disorders

1 ____ Location of a brain section essential to the recognition of jokes$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('758d7da4-34d5-5adf-994f-727118280f92', 'caba45f4-0a3a-5d78-a158-6d7ec8c6b7cf', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('26702f1b-198d-5700-bc5a-6c3004db1972', 'caba45f4-0a3a-5d78-a158-6d7ec8c6b7cf', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('86cb9d35-6880-572e-8a8b-94ccee840a0d', 'caba45f4-0a3a-5d78-a158-6d7ec8c6b7cf', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('640d3260-361f-5cc4-b652-8ac685771584', 'caba45f4-0a3a-5d78-a158-6d7ec8c6b7cf', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e4845543-d7ce-56df-a79c-429f69f21123', 'caba45f4-0a3a-5d78-a158-6d7ec8c6b7cf', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1a59f2cc-56bb-5fbb-9740-365ded7ae84b', 'caba45f4-0a3a-5d78-a158-6d7ec8c6b7cf', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6ca095bd-edff-5c5a-bf25-31e7d73ffe34', 'caba45f4-0a3a-5d78-a158-6d7ec8c6b7cf', 7, $md$G$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('b90fb8f3-4b11-5ad2-8614-a76285d1bb56', '22c8d6ce-bc34-50e8-9844-c7f37d28b9a8', 2, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 2

Questions 1-7
Questions 1-7
The Reading Passage has 7 paragraphs,
A-G
.
Which paragraph contains the following information?
Write the appropriate letter,
A-G
, in boxes
1-7
on your answer sheet.
NB
You may use any letter more than once.
1
Location of a brain section essential to the recognition of jokes
2
Laughter enhances immunity
3
Individual differences and the appreciation of humour
4
Parts of the brain responsible for tickling reflex
5
Neuropsychological mechanisms by which humor and laughter work
6
The connection between tickling and nerve fibers
7
Patients with emotional disorders

2 ____ Laughter enhances immunity$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0f2d95af-ac4b-5c47-98c9-7a6e4dfcb5fd', 'b90fb8f3-4b11-5ad2-8614-a76285d1bb56', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('888629b6-604a-5d94-9c6e-3f870e3286bf', 'b90fb8f3-4b11-5ad2-8614-a76285d1bb56', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('84169335-b3a4-59e5-a701-06c33249f038', 'b90fb8f3-4b11-5ad2-8614-a76285d1bb56', 3, $md$C$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1028e6db-7884-5802-b6aa-10b9d1fa1f4e', 'b90fb8f3-4b11-5ad2-8614-a76285d1bb56', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4402675b-e8d0-51c9-b530-ac5f1a109aad', 'b90fb8f3-4b11-5ad2-8614-a76285d1bb56', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('34133468-db7f-5f2a-b6a3-e519bd144541', 'b90fb8f3-4b11-5ad2-8614-a76285d1bb56', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8099830e-e547-59ea-859e-ee1d3ce32d0a', 'b90fb8f3-4b11-5ad2-8614-a76285d1bb56', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('2c98fbae-548a-50f3-962f-e951f26de587', '22c8d6ce-bc34-50e8-9844-c7f37d28b9a8', 3, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 3

Questions 1-7
Questions 1-7
The Reading Passage has 7 paragraphs,
A-G
.
Which paragraph contains the following information?
Write the appropriate letter,
A-G
, in boxes
1-7
on your answer sheet.
NB
You may use any letter more than once.
1
Location of a brain section essential to the recognition of jokes
2
Laughter enhances immunity
3
Individual differences and the appreciation of humour
4
Parts of the brain responsible for tickling reflex
5
Neuropsychological mechanisms by which humor and laughter work
6
The connection between tickling and nerve fibers
7
Patients with emotional disorders

3 ____ Individual differences and the appreciation of humour$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('59fe9208-4a20-5e3e-a82f-771fbf284749', '2c98fbae-548a-50f3-962f-e951f26de587', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('31d04f6d-9891-57c6-9a06-a430875caa8a', '2c98fbae-548a-50f3-962f-e951f26de587', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b0ccefb8-32dd-5761-971b-9a5044c6a244', '2c98fbae-548a-50f3-962f-e951f26de587', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('38ccc3f0-6804-5b53-8501-1e735e8adf2d', '2c98fbae-548a-50f3-962f-e951f26de587', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('473a7b38-36b0-5099-adaf-1e2bc6d533e6', '2c98fbae-548a-50f3-962f-e951f26de587', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1814c65c-adf6-5341-b981-fdda52dd31d6', '2c98fbae-548a-50f3-962f-e951f26de587', 6, $md$F$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7ca67de1-d553-52a9-8ff0-1a7d07d8aed3', '2c98fbae-548a-50f3-962f-e951f26de587', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('52f87ad0-5003-56d5-bf78-38966f1aa858', '22c8d6ce-bc34-50e8-9844-c7f37d28b9a8', 4, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 4

Questions 1-7
Questions 1-7
The Reading Passage has 7 paragraphs,
A-G
.
Which paragraph contains the following information?
Write the appropriate letter,
A-G
, in boxes
1-7
on your answer sheet.
NB
You may use any letter more than once.
1
Location of a brain section essential to the recognition of jokes
2
Laughter enhances immunity
3
Individual differences and the appreciation of humour
4
Parts of the brain responsible for tickling reflex
5
Neuropsychological mechanisms by which humor and laughter work
6
The connection between tickling and nerve fibers
7
Patients with emotional disorders

4 ____ Parts of the brain responsible for tickling reflex$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('50294f4a-80f4-5a38-beb3-90a1c75510c1', '52f87ad0-5003-56d5-bf78-38966f1aa858', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e40bc98d-5362-51c5-bd27-efe13e8c78de', '52f87ad0-5003-56d5-bf78-38966f1aa858', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('89af1f08-b338-51ac-99d9-f1c80b6857a8', '52f87ad0-5003-56d5-bf78-38966f1aa858', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('32862b7b-b6c7-5615-9730-b1e82e431b00', '52f87ad0-5003-56d5-bf78-38966f1aa858', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1608536d-ae24-5f22-a9b1-eccceefb371d', '52f87ad0-5003-56d5-bf78-38966f1aa858', 5, $md$E$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8730cbb6-dcd7-5dac-abac-246388157337', '52f87ad0-5003-56d5-bf78-38966f1aa858', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('995b8027-deae-522d-aa21-5bb7b98448a0', '52f87ad0-5003-56d5-bf78-38966f1aa858', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('82e53d3e-671d-5ea9-9843-17d9364fd4ce', '22c8d6ce-bc34-50e8-9844-c7f37d28b9a8', 5, 'MATCHING_INFORMATION', 'READING', 3, $md$### Question 5

Questions 1-7
Questions 1-7
The Reading Passage has 7 paragraphs,
A-G
.
Which paragraph contains the following information?
Write the appropriate letter,
A-G
, in boxes
1-7
on your answer sheet.
NB
You may use any letter more than once.
1
Location of a brain section essential to the recognition of jokes
2
Laughter enhances immunity
3
Individual differences and the appreciation of humour
4
Parts of the brain responsible for tickling reflex
5
Neuropsychological mechanisms by which humor and laughter work
6
The connection between tickling and nerve fibers
7
Patients with emotional disorders

5 ____ Neuropsychological mechanisms by which humor and laughter work$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('761f0ed3-00eb-55cf-b6dc-2e61b75920de', '82e53d3e-671d-5ea9-9843-17d9364fd4ce', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fae7eb75-caaa-51fc-a324-5c2910bdcf5e', '82e53d3e-671d-5ea9-9843-17d9364fd4ce', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ca62740a-45f0-55af-a642-baeaa1f5d60b', '82e53d3e-671d-5ea9-9843-17d9364fd4ce', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6ac9963f-4e2b-590e-b8c5-fd56d2fb29a7', '82e53d3e-671d-5ea9-9843-17d9364fd4ce', 4, $md$D$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('506ac4ce-963c-59db-97d6-be597b80016b', '82e53d3e-671d-5ea9-9843-17d9364fd4ce', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e0dcaa2d-8330-5073-8deb-e8025c16b20b', '82e53d3e-671d-5ea9-9843-17d9364fd4ce', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fd4ed406-b4b0-50a7-86bd-54d690315456', '82e53d3e-671d-5ea9-9843-17d9364fd4ce', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('88dfc3fc-ca05-561c-accf-09b2b08ce72c', '22c8d6ce-bc34-50e8-9844-c7f37d28b9a8', 6, 'MATCHING_INFORMATION', 'READING', 3, $md$### Question 6

Questions 1-7
Questions 1-7
The Reading Passage has 7 paragraphs,
A-G
.
Which paragraph contains the following information?
Write the appropriate letter,
A-G
, in boxes
1-7
on your answer sheet.
NB
You may use any letter more than once.
1
Location of a brain section essential to the recognition of jokes
2
Laughter enhances immunity
3
Individual differences and the appreciation of humour
4
Parts of the brain responsible for tickling reflex
5
Neuropsychological mechanisms by which humor and laughter work
6
The connection between tickling and nerve fibers
7
Patients with emotional disorders

6 ____ The connection between tickling and nerve fibers$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5693140c-9b07-52d3-b763-4ef94a7868d1', '88dfc3fc-ca05-561c-accf-09b2b08ce72c', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f4d59e69-dbc6-5511-a864-feee56131068', '88dfc3fc-ca05-561c-accf-09b2b08ce72c', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fcba0836-c006-5a29-a829-53b543f1bef7', '88dfc3fc-ca05-561c-accf-09b2b08ce72c', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3e608906-50a8-527a-b01b-8f9afdccc45e', '88dfc3fc-ca05-561c-accf-09b2b08ce72c', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('52f4eb2c-f2a6-5d99-91a1-b426da55e362', '88dfc3fc-ca05-561c-accf-09b2b08ce72c', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1d5cd317-d0b0-576c-9073-add9ccca94f3', '88dfc3fc-ca05-561c-accf-09b2b08ce72c', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('79277161-1836-52a8-a4c7-fca30094fcf5', '88dfc3fc-ca05-561c-accf-09b2b08ce72c', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('a3a9471c-eb7c-5122-a2a0-f623c971c8e0', '22c8d6ce-bc34-50e8-9844-c7f37d28b9a8', 7, 'MATCHING_INFORMATION', 'READING', 3, $md$### Question 7

Questions 1-7
Questions 1-7
The Reading Passage has 7 paragraphs,
A-G
.
Which paragraph contains the following information?
Write the appropriate letter,
A-G
, in boxes
1-7
on your answer sheet.
NB
You may use any letter more than once.
1
Location of a brain section essential to the recognition of jokes
2
Laughter enhances immunity
3
Individual differences and the appreciation of humour
4
Parts of the brain responsible for tickling reflex
5
Neuropsychological mechanisms by which humor and laughter work
6
The connection between tickling and nerve fibers
7
Patients with emotional disorders

7 ____ Patients with emotional disorders$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('43222a2e-d29b-5e1c-84f2-b5267f93f5ef', 'a3a9471c-eb7c-5122-a2a0-f623c971c8e0', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d4021a38-6226-5efa-ac1e-dc2cd59b7ec6', 'a3a9471c-eb7c-5122-a2a0-f623c971c8e0', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('727b212d-e4d7-5e0f-892e-877b337b39d5', 'a3a9471c-eb7c-5122-a2a0-f623c971c8e0', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8597b801-3c5d-5469-ad5e-01d90718c9cb', 'a3a9471c-eb7c-5122-a2a0-f623c971c8e0', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2413cbda-2840-5cbc-9816-c05e879a1b7c', 'a3a9471c-eb7c-5122-a2a0-f623c971c8e0', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('eb6e4058-ec55-54ee-928b-f2dce3456443', 'a3a9471c-eb7c-5122-a2a0-f623c971c8e0', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('62bf1c08-fb13-575c-b700-8e801b5f43e1', 'a3a9471c-eb7c-5122-a2a0-f623c971c8e0', 7, $md$G$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('65a0842c-5a2a-5338-92ad-28e3acb8f48f', '22c8d6ce-bc34-50e8-9844-c7f37d28b9a8', 8, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 8

Questions 8-11
Questions 8-11
Look at the following researchers (listed
8-11
) and findings (listed
A-F
).
Match each researcher with the correct finding(s).
Write your answers in boxes
8-11
on your answer sheet.
NB
There are more findings than researchers. You may choose more than one finding for any of the researchers.
A
The surprise factor, combined with the anticipation of pleasure, cause laughter when tickled.
B
Laughing caused by tickling is a built-in reflex even babies have.
C
People also laugh when tickled by a machine if they are not aware of it.
D
People have different tastes for jokes and humour.
E
Jokes and funny cartoons activate the frontal lobes.
F
Tickling sensations involve more than nerve fibers.
8
Darwin
9
Christenfeld and Harris
10
Yngve Zotterman
11
Peter Derks

8 ____ Darwin$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2eabce5e-2b25-5ba7-9626-d4b511840c8c', '65a0842c-5a2a-5338-92ad-28e3acb8f48f', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('eb5e283f-94a2-5117-8a14-71ece5fc5767', '65a0842c-5a2a-5338-92ad-28e3acb8f48f', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7ced8e13-720e-58ce-b3cc-d378f96f99c0', '65a0842c-5a2a-5338-92ad-28e3acb8f48f', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('48fa7f08-6681-5f30-a42e-4eef89914d1b', '65a0842c-5a2a-5338-92ad-28e3acb8f48f', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('541447d6-d8e9-5458-a3b6-dcfd20c32ab6', '65a0842c-5a2a-5338-92ad-28e3acb8f48f', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2b4de3b3-d14d-5c36-8d87-004a81f492c2', '65a0842c-5a2a-5338-92ad-28e3acb8f48f', 6, $md$F$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('6bec70d6-9a10-5266-83e0-8becc72a8793', '22c8d6ce-bc34-50e8-9844-c7f37d28b9a8', 9, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 9

Questions 8-11
Questions 8-11
Look at the following researchers (listed
8-11
) and findings (listed
A-F
).
Match each researcher with the correct finding(s).
Write your answers in boxes
8-11
on your answer sheet.
NB
There are more findings than researchers. You may choose more than one finding for any of the researchers.
A
The surprise factor, combined with the anticipation of pleasure, cause laughter when tickled.
B
Laughing caused by tickling is a built-in reflex even babies have.
C
People also laugh when tickled by a machine if they are not aware of it.
D
People have different tastes for jokes and humour.
E
Jokes and funny cartoons activate the frontal lobes.
F
Tickling sensations involve more than nerve fibers.
8
Darwin
9
Christenfeld and Harris
10
Yngve Zotterman
11
Peter Derks

9 ____ Christenfeld and Harris$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('afefafd9-6a6a-5b64-903d-db8aeb404489', '6bec70d6-9a10-5266-83e0-8becc72a8793', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5c27f551-3177-5b48-8cdf-0b4a392e4bb1', '6bec70d6-9a10-5266-83e0-8becc72a8793', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('429b706b-899a-5f9b-b5a5-20af675a82a2', '6bec70d6-9a10-5266-83e0-8becc72a8793', 3, $md$C$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f3120bc3-b878-5f5e-b3f0-0eab8c16dee9', '6bec70d6-9a10-5266-83e0-8becc72a8793', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('744d35cd-55ac-5d6b-b8c5-9f2ca482eccb', '6bec70d6-9a10-5266-83e0-8becc72a8793', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('13f3fe6a-0fe2-5829-b6eb-86e6301a72b4', '6bec70d6-9a10-5266-83e0-8becc72a8793', 6, $md$F$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('6fde0281-bd24-5a35-bbef-a1ed4f4924b6', '22c8d6ce-bc34-50e8-9844-c7f37d28b9a8', 10, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 10

Questions 8-11
Questions 8-11
Look at the following researchers (listed
8-11
) and findings (listed
A-F
).
Match each researcher with the correct finding(s).
Write your answers in boxes
8-11
on your answer sheet.
NB
There are more findings than researchers. You may choose more than one finding for any of the researchers.
A
The surprise factor, combined with the anticipation of pleasure, cause laughter when tickled.
B
Laughing caused by tickling is a built-in reflex even babies have.
C
People also laugh when tickled by a machine if they are not aware of it.
D
People have different tastes for jokes and humour.
E
Jokes and funny cartoons activate the frontal lobes.
F
Tickling sensations involve more than nerve fibers.
8
Darwin
9
Christenfeld and Harris
10
Yngve Zotterman
11
Peter Derks

10 ____ Yngve Zotterman$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('44f4ffab-6506-59e3-ad4a-f38aa998a1cc', '6fde0281-bd24-5a35-bbef-a1ed4f4924b6', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('00faac97-4b04-5ae1-a643-4eeb0b6c7c89', '6fde0281-bd24-5a35-bbef-a1ed4f4924b6', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d086b836-5888-532c-8554-dc7e79fe6db3', '6fde0281-bd24-5a35-bbef-a1ed4f4924b6', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ddcf9248-aa05-54ef-a67d-0dec1afe9367', '6fde0281-bd24-5a35-bbef-a1ed4f4924b6', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0b0bdc0f-bd0c-5310-88d7-e9d13204fdd4', '6fde0281-bd24-5a35-bbef-a1ed4f4924b6', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d8dc444f-8d87-5fcd-b16e-ee024300fbad', '6fde0281-bd24-5a35-bbef-a1ed4f4924b6', 6, $md$F$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('ca9f6de9-3531-51dc-a0ec-41d89c183855', '22c8d6ce-bc34-50e8-9844-c7f37d28b9a8', 11, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 11

Questions 8-11
Questions 8-11
Look at the following researchers (listed
8-11
) and findings (listed
A-F
).
Match each researcher with the correct finding(s).
Write your answers in boxes
8-11
on your answer sheet.
NB
There are more findings than researchers. You may choose more than one finding for any of the researchers.
A
The surprise factor, combined with the anticipation of pleasure, cause laughter when tickled.
B
Laughing caused by tickling is a built-in reflex even babies have.
C
People also laugh when tickled by a machine if they are not aware of it.
D
People have different tastes for jokes and humour.
E
Jokes and funny cartoons activate the frontal lobes.
F
Tickling sensations involve more than nerve fibers.
8
Darwin
9
Christenfeld and Harris
10
Yngve Zotterman
11
Peter Derks

11 ____ Peter Derks$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7cf0c7d3-3dfc-514f-b313-6353f9c09350', 'ca9f6de9-3531-51dc-a0ec-41d89c183855', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5745d890-6ae3-52b4-aa85-02bba6aa19c1', 'ca9f6de9-3531-51dc-a0ec-41d89c183855', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('aea9b0c9-7f68-58ac-9658-16c5b9ece719', 'ca9f6de9-3531-51dc-a0ec-41d89c183855', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('012961eb-0168-5cdf-b53e-801e1cb63d3c', 'ca9f6de9-3531-51dc-a0ec-41d89c183855', 4, $md$D$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('50f2557c-8285-5f6c-aa1c-65781ece338f', 'ca9f6de9-3531-51dc-a0ec-41d89c183855', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f5ba8ef2-065f-5f18-8311-c99da2f9076e', 'ca9f6de9-3531-51dc-a0ec-41d89c183855', 6, $md$F$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('051cab7d-34a4-5e09-abf0-6049b6cbea09', '22c8d6ce-bc34-50e8-9844-c7f37d28b9a8', 12, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 12

Questions 12-14
Questions 12-14
Complete the summary below using
NO MORE THAN THREE WORDS
from the passage for each blank.
Write your answers in boxes
12-14
on your answer sheet.
Researchers believe three brain components to be involved in the processing of humor and laughter Results from one study using brain
12
indicate that parts of the brain responsible for
13
movement and pleasure are involved through a sophisticated pathway. Test subjects who suffered from frontal lobes damages had greater chances of picking
14
of jokes or did not respond to funny cartoons or jokes.

Researchers believe three brain components to be involved in the processing of humor and laughter Results from one study using brain 12 ____ indicate that parts of the brain responsible for 13 ____ movement and pleasure are involved through a sophisticated pathway. Test subjects who suffered from frontal lobes damages had greater chances of picking 14 ____ of jokes or did not respond to funny cartoons or jokes.$md$, NULL, ARRAY['.*imaging.*equipment.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('238291d1-2595-5368-91fd-de6e982c6e32', '22c8d6ce-bc34-50e8-9844-c7f37d28b9a8', 13, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 13

Questions 12-14
Questions 12-14
Complete the summary below using
NO MORE THAN THREE WORDS
from the passage for each blank.
Write your answers in boxes
12-14
on your answer sheet.
Researchers believe three brain components to be involved in the processing of humor and laughter Results from one study using brain
12
indicate that parts of the brain responsible for
13
movement and pleasure are involved through a sophisticated pathway. Test subjects who suffered from frontal lobes damages had greater chances of picking
14
of jokes or did not respond to funny cartoons or jokes.

Researchers believe three brain components to be involved in the processing of humor and laughter Results from one study using brain 12 ____ indicate that parts of the brain responsible for 13 ____ movement and pleasure are involved through a sophisticated pathway. Test subjects who suffered from frontal lobes damages had greater chances of picking 14 ____ of jokes or did not respond to funny cartoons or jokes.$md$, NULL, ARRAY['.*imaging.*equipment.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('30f60b8a-3c14-54f1-9e63-889d32311385', '22c8d6ce-bc34-50e8-9844-c7f37d28b9a8', 14, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 14

Questions 12-14
Questions 12-14
Complete the summary below using
NO MORE THAN THREE WORDS
from the passage for each blank.
Write your answers in boxes
12-14
on your answer sheet.
Researchers believe three brain components to be involved in the processing of humor and laughter Results from one study using brain
12
indicate that parts of the brain responsible for
13
movement and pleasure are involved through a sophisticated pathway. Test subjects who suffered from frontal lobes damages had greater chances of picking
14
of jokes or did not respond to funny cartoons or jokes.

Researchers believe three brain components to be involved in the processing of humor and laughter Results from one study using brain 12 ____ indicate that parts of the brain responsible for 13 ____ movement and pleasure are involved through a sophisticated pathway. Test subjects who suffered from frontal lobes damages had greater chances of picking 14 ____ of jokes or did not respond to funny cartoons or jokes.$md$, NULL, ARRAY['.*imaging.*equipment.*']);

COMMIT;
