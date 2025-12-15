BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-inside-the-mind-of-a-fan-how-watching-sport-affects-the-brain-1398'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-inside-the-mind-of-a-fan-how-watching-sport-affects-the-brain-1398';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-inside-the-mind-of-a-fan-how-watching-sport-affects-the-brain-1398';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-inside-the-mind-of-a-fan-how-watching-sport-affects-the-brain-1398';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('d6b0b16a-1cff-5823-a91a-4e40cde866cd', 'ielts-reading-inside-the-mind-of-a-fan-how-watching-sport-affects-the-brain-1398', $t$Inside the mind of a fan: How watching sport affects the brain$t$, $md$## Inside the mind of a fan: How watching sport affects the brain

Nguồn:
- Test: https://mini-ielts.com/1398/reading/inside-the-mind-of-a-fan-how-watching-sport-affects-the-brain
- Solution: https://mini-ielts.com/1398/view-solution/reading/inside-the-mind-of-a-fan-how-watching-sport-affects-the-brain$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('6c571ec7-4310-598f-a16c-7c67825adf2b', 'd6b0b16a-1cff-5823-a91a-4e40cde866cd', 1, $t$Reading — Inside the mind of a fan: How watching sport affects the brain$t$, $md$Read the passage and answer questions **1–14**.

### Passage: Inside the mind of a fan: How watching sport affects the brain

A

At about the same time that the poet Homer invented the epic here, the ancient Greeks started a festival in which men competed in a single race, about 200 metres long. The winner received a branch of wild olives. The Greeks called this celebration the Olympics. Through the ancient sprint remains, today the Olympics are far more than that. Indeed, the Games seem to celebrate the dream of progress as embodied in the human form. That the Games are intoxicating to watch is beyond question. During the Athens Olympics in 2004, 3.4 billion people, half the world, watched them on television. Certainly, being a spectator is a thrilling experience: but why?

B

In 1996, three Italian neuroscientists, Giacomo Rizzolatti, Leonardo Forgassi and Vittorio Gallese, examined the premotor cortex of monkeys. The discovered that inside these primate brains there were groups of cells that ‘store vocabularies of motor actions’. Just as there are grammars of movement. These networks of cells are the bodily ‘sentences’ we use every day, the ones our brain has chosen to retain and refine. Think, for example, about a golf swing. To those who have only watched the Master’s Tournament on TV, golfing seems easy. To the novice, however, the skill of casting a smooth arc with a lop-side metal stick is virtually impossible. This is because most novices swing with their consciousness, using an area of brain next to the premotor cortex. To the expert, on the other hand, a perfectly balanced stroke is second nature. For him, the motor action has become memorized, and the movements are embedded in the neurons of his premotor cortex. He hits the ball with the tranquility of his perfected autopilot.

C

These neurons in the premotor cortex, besides explaining why certain athletes seem to possess almost unbelievable levels of skill, have an even more amazing characteristic, one that caused Rizzolatti, Fogassi and Gallese to give them the lofty title ‘mirror neurons’. They note, The main functional characteristic of mirror neurons is that they become active both when the monkey performs a particular action (for example, grasping an object or holding it) and, astonishingly, when it sees another individual performing a similar action.’ Humans have an even more elaborate mirror neuron system. These peculiar cells mirror, inside the brain, the outside world: they enable us to internalize the actions of another. In order to be activated, though, these cells require what the scientists call ‘goal-orientated movements’. If we are staring at a photograph, a fixed image of a runner mid-stride, our mirror neurons are totally silent. They only fire when the runner is active: running, moving or sprinting.

D

What these electrophysiological studies indicate is that when we watch a golfer or a runner in action, the mirror neurons in our own premotor cortex light up as if we were the ones competing. This phenomenon of neural mirror was first discovered in 1954, when two French physiologists, Gastaut and Berf, found that the brains of humans vibrate with two distinct wavelengths, alpha and mu. The mu system is involved in neural mirroring. It is active when your bodies are still, and disappears whenever we do something active, like playing a sport or changing the TV channel. The surprising fact is that the mu signal is also quiet when we watch someone else being active, as on TV, these results are the effect of mirror neurons.

E

Rizzolatti, Fogassi and Gallese call the idea for mirror neurons the ‘direct matching hypothesis’. They believe that we only understand the movement of sports stars when we ‘map the visual representation of the observed action onto our motor representation of the same action’. According to this theory, watching an Olympic athlete ‘causes the motor system of the observer to resonate. The “motor knowledge” of the observer is used to understand the observed action.’ But mirror neurons are more than just the neural basis for our attitude to sport. It turns out that watching a great golfer makes us better golfers, and watching a great sprinter actually makes us run faster. This ability to learn by watching is a crucial skill. From the acquisition of language as infants to learning facial expressions, mimesis (copying) is an essential part of being conscious. The best athletes are those with a premotor cortex capable of imagining the movements of victory, together with the physical properties to make those movements real.

F

But how many of us regularly watch sports in order to be a better athlete? Rather, we watch sport for the feeling, the human drama. This feeling also derives from mirror neurons. By letting spectators share in the motions of victory, they also allow us to share in its feelings. This is because they are directly connected to the amygdale, one of the main brain regions involved in emotion. During the Olympics, the mirror neurons of whole nations will be electrically identical, their athletes causing spectators to feel, just for a second or two, the same thing. Watching sports brings people together. Most of us will never run a mile in under four minutes, or hit a home run. Our consolation comes in watching, when we gather around the TV, we all feel, just for a moment, what it is to do something perfectly.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('e8031c93-7708-535d-ae8e-627bacf652e8', '6c571ec7-4310-598f-a16c-7c67825adf2b', 1, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 1

Questions 1-6
Questions 1-6
Reading Passage has six paragraphs,
A-F
.
Which paragraph contains the following information?
Write the correct letter,
A-F
, in boxes
1-6
on your answer sheet.
NB
You may use any letter more than once.
1
an explanation of why watching sport may be emotionally satisfying
2
an explanation of why beginners find sporting tasks difficult
3
a factor that needs to combine with mirroring to attain sporting excellence
4
a comparison of human and animal mirror neurons
5
the first discovery of brain activity related to mirror neurons
6
a claim linking observation to improvement in performance

1 ____ an explanation of why watching sport may be emotionally satisfying$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2add236f-85d6-5536-96b5-7d712eaf6f61', 'e8031c93-7708-535d-ae8e-627bacf652e8', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1c21d381-b2ef-5d87-bffc-867d0abd5b23', 'e8031c93-7708-535d-ae8e-627bacf652e8', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f6dc5056-28a2-5972-be98-8e6c03d3930d', 'e8031c93-7708-535d-ae8e-627bacf652e8', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0e7426b0-c066-5ed5-b342-313ffd7895f4', 'e8031c93-7708-535d-ae8e-627bacf652e8', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b418aa72-7440-5053-bedd-c837e914b72e', 'e8031c93-7708-535d-ae8e-627bacf652e8', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fc7a4171-755d-54a6-baad-f88944bf5483', 'e8031c93-7708-535d-ae8e-627bacf652e8', 6, $md$F$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('a159be1b-db13-5e32-95fe-848139e2463f', '6c571ec7-4310-598f-a16c-7c67825adf2b', 2, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 2

Questions 1-6
Questions 1-6
Reading Passage has six paragraphs,
A-F
.
Which paragraph contains the following information?
Write the correct letter,
A-F
, in boxes
1-6
on your answer sheet.
NB
You may use any letter more than once.
1
an explanation of why watching sport may be emotionally satisfying
2
an explanation of why beginners find sporting tasks difficult
3
a factor that needs to combine with mirroring to attain sporting excellence
4
a comparison of human and animal mirror neurons
5
the first discovery of brain activity related to mirror neurons
6
a claim linking observation to improvement in performance

2 ____ an explanation of why beginners find sporting tasks difficult$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0bc16505-6145-5433-8741-4f3df3c80524', 'a159be1b-db13-5e32-95fe-848139e2463f', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4578d896-11a1-5474-82f6-c89fe6a064f6', 'a159be1b-db13-5e32-95fe-848139e2463f', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8648b1c4-4260-548a-a8f4-494dc350e37d', 'a159be1b-db13-5e32-95fe-848139e2463f', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fc091dce-0f77-5fa9-a8cd-3c08cf5bc8fb', 'a159be1b-db13-5e32-95fe-848139e2463f', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9b05830d-d1a4-5ad8-91c9-f66854f44a0f', 'a159be1b-db13-5e32-95fe-848139e2463f', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c8f8d5eb-24ea-5a45-b48e-60fc0a90261e', 'a159be1b-db13-5e32-95fe-848139e2463f', 6, $md$F$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('38973a03-e2a2-593e-a748-928b84bde943', '6c571ec7-4310-598f-a16c-7c67825adf2b', 3, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 3

Questions 1-6
Questions 1-6
Reading Passage has six paragraphs,
A-F
.
Which paragraph contains the following information?
Write the correct letter,
A-F
, in boxes
1-6
on your answer sheet.
NB
You may use any letter more than once.
1
an explanation of why watching sport may be emotionally satisfying
2
an explanation of why beginners find sporting tasks difficult
3
a factor that needs to combine with mirroring to attain sporting excellence
4
a comparison of human and animal mirror neurons
5
the first discovery of brain activity related to mirror neurons
6
a claim linking observation to improvement in performance

3 ____ a factor that needs to combine with mirroring to attain sporting excellence$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b8f82d8d-8bee-517b-bef2-90dc08c3c13e', '38973a03-e2a2-593e-a748-928b84bde943', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('566b8211-3215-543c-bf37-082906fbbc5c', '38973a03-e2a2-593e-a748-928b84bde943', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ceed12f7-352b-58e6-afad-22f71c95c726', '38973a03-e2a2-593e-a748-928b84bde943', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('800556e9-30ef-5c41-ae0c-c238a6882811', '38973a03-e2a2-593e-a748-928b84bde943', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b6845bed-1ae1-5e01-9913-a3631a7133bc', '38973a03-e2a2-593e-a748-928b84bde943', 5, $md$E$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('52fb79ae-74d1-55ec-a381-d4c1f3d1814d', '38973a03-e2a2-593e-a748-928b84bde943', 6, $md$F$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('eb78c23d-6293-5c20-bb10-cde62aa92d12', '6c571ec7-4310-598f-a16c-7c67825adf2b', 4, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 4

Questions 1-6
Questions 1-6
Reading Passage has six paragraphs,
A-F
.
Which paragraph contains the following information?
Write the correct letter,
A-F
, in boxes
1-6
on your answer sheet.
NB
You may use any letter more than once.
1
an explanation of why watching sport may be emotionally satisfying
2
an explanation of why beginners find sporting tasks difficult
3
a factor that needs to combine with mirroring to attain sporting excellence
4
a comparison of human and animal mirror neurons
5
the first discovery of brain activity related to mirror neurons
6
a claim linking observation to improvement in performance

4 ____ a comparison of human and animal mirror neurons$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cdf150ee-13df-50b9-983f-1cd4527e5835', 'eb78c23d-6293-5c20-bb10-cde62aa92d12', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('846360ef-f567-5a0a-b77a-ef66c89ad4b8', 'eb78c23d-6293-5c20-bb10-cde62aa92d12', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1ea3a2e9-b372-57b2-b94f-f2f378a9002c', 'eb78c23d-6293-5c20-bb10-cde62aa92d12', 3, $md$C$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('235ad0ff-64f6-5dea-8dea-2513021bc850', 'eb78c23d-6293-5c20-bb10-cde62aa92d12', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2246d29b-9df4-5a8e-b00f-4ffa470a3629', 'eb78c23d-6293-5c20-bb10-cde62aa92d12', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('73861608-16ff-50eb-aa5c-50e8177721a0', 'eb78c23d-6293-5c20-bb10-cde62aa92d12', 6, $md$F$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('c787fb95-75d9-5d58-a8ad-3a0636c31d67', '6c571ec7-4310-598f-a16c-7c67825adf2b', 5, 'MATCHING_INFORMATION', 'READING', 3, $md$### Question 5

Questions 1-6
Questions 1-6
Reading Passage has six paragraphs,
A-F
.
Which paragraph contains the following information?
Write the correct letter,
A-F
, in boxes
1-6
on your answer sheet.
NB
You may use any letter more than once.
1
an explanation of why watching sport may be emotionally satisfying
2
an explanation of why beginners find sporting tasks difficult
3
a factor that needs to combine with mirroring to attain sporting excellence
4
a comparison of human and animal mirror neurons
5
the first discovery of brain activity related to mirror neurons
6
a claim linking observation to improvement in performance

5 ____ the first discovery of brain activity related to mirror neurons$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b42c3319-d49a-58b2-9570-6b49f4f18061', 'c787fb95-75d9-5d58-a8ad-3a0636c31d67', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5860ba2b-17be-594d-aed2-3d0acfbcf904', 'c787fb95-75d9-5d58-a8ad-3a0636c31d67', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3ee6f2ff-8787-507e-84af-426d6114514b', 'c787fb95-75d9-5d58-a8ad-3a0636c31d67', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d4aa74f0-adf5-5692-9174-c2e82c844aeb', 'c787fb95-75d9-5d58-a8ad-3a0636c31d67', 4, $md$D$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2f772d2b-ed0e-5ce2-ba1d-e79601f13c9a', 'c787fb95-75d9-5d58-a8ad-3a0636c31d67', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('31e53ed2-589a-537c-8580-ada4421c62b1', 'c787fb95-75d9-5d58-a8ad-3a0636c31d67', 6, $md$F$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('6c8cc256-428d-552c-b51a-87f60766e404', '6c571ec7-4310-598f-a16c-7c67825adf2b', 6, 'MATCHING_INFORMATION', 'READING', 3, $md$### Question 6

Questions 1-6
Questions 1-6
Reading Passage has six paragraphs,
A-F
.
Which paragraph contains the following information?
Write the correct letter,
A-F
, in boxes
1-6
on your answer sheet.
NB
You may use any letter more than once.
1
an explanation of why watching sport may be emotionally satisfying
2
an explanation of why beginners find sporting tasks difficult
3
a factor that needs to combine with mirroring to attain sporting excellence
4
a comparison of human and animal mirror neurons
5
the first discovery of brain activity related to mirror neurons
6
a claim linking observation to improvement in performance

6 ____ a claim linking observation to improvement in performance$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ee958ef8-3771-59d7-8d0f-697ac722c27f', '6c8cc256-428d-552c-b51a-87f60766e404', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fc082d5c-7abc-53c1-b0d3-be430ad78659', '6c8cc256-428d-552c-b51a-87f60766e404', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cb2b863d-1034-5753-ae77-cb408a18658d', '6c8cc256-428d-552c-b51a-87f60766e404', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3abe9d6a-d569-54d5-9550-9ddb9faa675e', '6c8cc256-428d-552c-b51a-87f60766e404', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fe8ab8d7-1ede-5eac-aef2-4f316eff8425', '6c8cc256-428d-552c-b51a-87f60766e404', 5, $md$E$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ceaa0e79-4617-5b70-9f51-7008267ce81c', '6c8cc256-428d-552c-b51a-87f60766e404', 6, $md$F$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('c7e150e8-11e2-5689-8b61-e04ece941d4c', '6c571ec7-4310-598f-a16c-7c67825adf2b', 7, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 7

Questions 7-9
Questions 7-9
Choose the correct letter,
A
,
B
,
C
or
D
.
Write your answers in boxes
7-9
on your answer sheet.
7.
The writer uses the term ‘grammar of movement’ to mean
A
a level of sporting skill.
B
a system of words about movement.
C
a pattern of connected cells.
D
a type of golf swing.
8.
The writer states that expert players perform their actions
A
without conscious thought.
B
by planning each phase of movement.
C
without regular practice.
D
by thinking about the actions of others.
9.
The writer states that the most common motive for watching sport is to
A
improve personal performance.
B
feel linked with people of different nationalities.
C
experience strong positive emotions.
D
realize what skill consists of.

Choose the correct letter, A , B , C or D .$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('a9deac57-6ff3-515e-b904-ec31f5aa91ff', '6c571ec7-4310-598f-a16c-7c67825adf2b', 8, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 8

Questions 7-9
Questions 7-9
Choose the correct letter,
A
,
B
,
C
or
D
.
Write your answers in boxes
7-9
on your answer sheet.
7.
The writer uses the term ‘grammar of movement’ to mean
A
a level of sporting skill.
B
a system of words about movement.
C
a pattern of connected cells.
D
a type of golf swing.
8.
The writer states that expert players perform their actions
A
without conscious thought.
B
by planning each phase of movement.
C
without regular practice.
D
by thinking about the actions of others.
9.
The writer states that the most common motive for watching sport is to
A
improve personal performance.
B
feel linked with people of different nationalities.
C
experience strong positive emotions.
D
realize what skill consists of.

Choose the correct letter, A , B , C or D .$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('603cd8da-69d0-5e6c-995f-c8c478b0e58b', '6c571ec7-4310-598f-a16c-7c67825adf2b', 9, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 9

Questions 7-9
Questions 7-9
Choose the correct letter,
A
,
B
,
C
or
D
.
Write your answers in boxes
7-9
on your answer sheet.
7.
The writer uses the term ‘grammar of movement’ to mean
A
a level of sporting skill.
B
a system of words about movement.
C
a pattern of connected cells.
D
a type of golf swing.
8.
The writer states that expert players perform their actions
A
without conscious thought.
B
by planning each phase of movement.
C
without regular practice.
D
by thinking about the actions of others.
9.
The writer states that the most common motive for watching sport is to
A
improve personal performance.
B
feel linked with people of different nationalities.
C
experience strong positive emotions.
D
realize what skill consists of.

Choose the correct letter, A , B , C or D .$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('a0a27478-6815-521b-b438-c2acdc025a1f', '6c571ec7-4310-598f-a16c-7c67825adf2b', 10, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 10

Questions 10-14
Questions 10-14
Do the following statements agree with the views of the writer in Reading Passage?
In boxes
10-14
on your answer sheet, write
YES
if the statement is true
NO
if the statement is false
NOT GIVEN
if the information is not given in the passage
10
Inexpert sports players are too aware of what they are doing.
11
Monkeys have a more complex mirror neuron system than humans.
12
Looking at a photograph can activate mirror neurons.
13
Gastaut and Bert were both researchers and sports players.
14
The mu system is at rest when we are engaged in an activity.

10 ____ Inexpert sports players are too aware of what they are doing.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1ac298f9-4524-5bec-95ea-75801c174c52', 'a0a27478-6815-521b-b438-c2acdc025a1f', 1, $md$YES$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('db0a2377-82b5-521e-8911-b9530fba87aa', 'a0a27478-6815-521b-b438-c2acdc025a1f', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7b48e60f-1454-5a5b-a919-19adbd158623', 'a0a27478-6815-521b-b438-c2acdc025a1f', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('f1441795-f982-5bfb-b609-86d0a54a3310', '6c571ec7-4310-598f-a16c-7c67825adf2b', 11, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 11

Questions 10-14
Questions 10-14
Do the following statements agree with the views of the writer in Reading Passage?
In boxes
10-14
on your answer sheet, write
YES
if the statement is true
NO
if the statement is false
NOT GIVEN
if the information is not given in the passage
10
Inexpert sports players are too aware of what they are doing.
11
Monkeys have a more complex mirror neuron system than humans.
12
Looking at a photograph can activate mirror neurons.
13
Gastaut and Bert were both researchers and sports players.
14
The mu system is at rest when we are engaged in an activity.

11 ____ Monkeys have a more complex mirror neuron system than humans.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1fa26379-c004-54ef-9a6a-6bbb9f20b108', 'f1441795-f982-5bfb-b609-86d0a54a3310', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2389b177-def6-5d1b-bb52-7f2ef44d8f2e', 'f1441795-f982-5bfb-b609-86d0a54a3310', 2, $md$NO$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d858bd82-811c-5857-a29d-974cffa9d8c4', 'f1441795-f982-5bfb-b609-86d0a54a3310', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('23d20e25-d214-5cd7-a2a2-9cb52d6701d3', '6c571ec7-4310-598f-a16c-7c67825adf2b', 12, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 12

Questions 10-14
Questions 10-14
Do the following statements agree with the views of the writer in Reading Passage?
In boxes
10-14
on your answer sheet, write
YES
if the statement is true
NO
if the statement is false
NOT GIVEN
if the information is not given in the passage
10
Inexpert sports players are too aware of what they are doing.
11
Monkeys have a more complex mirror neuron system than humans.
12
Looking at a photograph can activate mirror neurons.
13
Gastaut and Bert were both researchers and sports players.
14
The mu system is at rest when we are engaged in an activity.

12 ____ Looking at a photograph can activate mirror neurons.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d28efe2c-dd85-59cb-bf50-72420851d61e', '23d20e25-d214-5cd7-a2a2-9cb52d6701d3', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0d8607e6-e19d-5da9-8bb5-6bbc472ea2fe', '23d20e25-d214-5cd7-a2a2-9cb52d6701d3', 2, $md$NO$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ed77e657-c829-5fc3-b602-a7cf1d8502c1', '23d20e25-d214-5cd7-a2a2-9cb52d6701d3', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('fa8786a4-9a7a-5988-aa70-918113f7eaab', '6c571ec7-4310-598f-a16c-7c67825adf2b', 13, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 13

Questions 10-14
Questions 10-14
Do the following statements agree with the views of the writer in Reading Passage?
In boxes
10-14
on your answer sheet, write
YES
if the statement is true
NO
if the statement is false
NOT GIVEN
if the information is not given in the passage
10
Inexpert sports players are too aware of what they are doing.
11
Monkeys have a more complex mirror neuron system than humans.
12
Looking at a photograph can activate mirror neurons.
13
Gastaut and Bert were both researchers and sports players.
14
The mu system is at rest when we are engaged in an activity.

13 ____ Gastaut and Bert were both researchers and sports players.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('91e7eddf-ccca-5c7d-8f71-40e13ca98b03', 'fa8786a4-9a7a-5988-aa70-918113f7eaab', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a18a00d2-c463-5cc2-9fcf-540698cabc32', 'fa8786a4-9a7a-5988-aa70-918113f7eaab', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b856564f-8d2e-5e0b-88fc-951623fa5c41', 'fa8786a4-9a7a-5988-aa70-918113f7eaab', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('3a00c5eb-7b29-5488-99f8-27a44724bd46', '6c571ec7-4310-598f-a16c-7c67825adf2b', 14, 'TRUE_FALSE_NOT_GIVEN', 'READING', 4, $md$### Question 14

Questions 10-14
Questions 10-14
Do the following statements agree with the views of the writer in Reading Passage?
In boxes
10-14
on your answer sheet, write
YES
if the statement is true
NO
if the statement is false
NOT GIVEN
if the information is not given in the passage
10
Inexpert sports players are too aware of what they are doing.
11
Monkeys have a more complex mirror neuron system than humans.
12
Looking at a photograph can activate mirror neurons.
13
Gastaut and Bert were both researchers and sports players.
14
The mu system is at rest when we are engaged in an activity.

14 ____ The mu system is at rest when we are engaged in an activity.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ac7f731c-ced3-5397-be6f-553accad4dd0', '3a00c5eb-7b29-5488-99f8-27a44724bd46', 1, $md$YES$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e2cf1dab-5fce-5bef-8e09-43a882370347', '3a00c5eb-7b29-5488-99f8-27a44724bd46', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('468af3c3-63aa-5c81-a963-842a0969f9a1', '3a00c5eb-7b29-5488-99f8-27a44724bd46', 3, $md$NOT GIVEN$md$, false);

COMMIT;
