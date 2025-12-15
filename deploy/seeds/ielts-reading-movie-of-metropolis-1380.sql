BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-movie-of-metropolis-1380'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-movie-of-metropolis-1380';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-movie-of-metropolis-1380';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-movie-of-metropolis-1380';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('9c397000-3984-5baf-97bc-70640830db01', 'ielts-reading-movie-of-metropolis-1380', $t$Movie of Metropolis$t$, $md$## Movie of Metropolis

Nguồn:
- Test: https://mini-ielts.com/1380/reading/movie-of-metropolis
- Solution: https://mini-ielts.com/1380/view-solution/reading/movie-of-metropolis$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('83d3c8ed-c586-569d-80b2-389982663071', '9c397000-3984-5baf-97bc-70640830db01', 1, $t$Reading — Movie of Metropolis$t$, $md$Read the passage and answer questions **1–14**.

### Passage: Movie of Metropolis

… being the science-fiction film that is steadily becoming a fact

When German director Fritz Lang visited the United States in 1924, his first glimpse of the country was a night-time view of the New York skyline from the deck of an ocean liner. This, he later recalled, was the direct inspiration for what is still probably the most innovative and influential science-fiction film ever made – Metropolis.

B

Metropolis is a bleak vision of the early twenty-first century that is at once both chilling and exhilarating. This spectacular city of the future is a technological marvel of high-rise buildings connected by elevated railways and airships. It’s also a world of extreme inequality and social division. The workers live below ground and exist as machines working in an endless routine of mind-numbing 10-hour shifts while the city’s elite lead lives of luxury high above. Presiding over them all is the Master of Metropolis, John Fredersen, whose sole satisfaction seems to lie in the exercise of power.

C

Lang’s graphic depiction of the future is conceived in almost totally abstract terms. The function of the individual machines is never defined. Instead, this mass of dials, levers and gauges symbolically stands for all machines and all industry, with the workers as slave-live extensions of the equipment they have to operate. Lang emphasizes this idea in the famous shift-change sequence at the start of the movie when the workers walk in zombie-like geometric ranks, all dressed in the same dark overalls and all exhibiting the same bowed head and dead-eyed stare. An extraordinary fantasy sequence sees one machine transformed into a huge open-jawed statue which then literally swallows them up.

D

On one level the machines and the exploited workers simply provide the wealth and services which allow the elite to live their lives of leisure, but on a more profound level, the purpose of all this demented industry is to serve itself. Power, control and the continuance of the system from one 10-hour shift to the next is all that counts. The city consumes people and their labour and in the process becomes a perverse parody of a living being.

E

It is enlightening, I think, to relate the film to the modern global economy in which multinational corporations now routinely close their factories in one continent so that they can take advantage of cheap labour in another. Like the industry in Metropolis, these corporations’ goals of increased efficiency and profits have little to do with the welfare of the majority of their employees or that of the population at large. Instead, their aims are to sustain the momentum of their own growth and to increase the monetary rewards to a tiny elite – their executives and shareholders. Fredersen himself is the essence of the big company boss: Rupert Murdoch would probably feel perfectly at home in his huge skyscraper office with its panoramic view of the city below. And it is important that there is never any mention of government in Metropolis – the whole concept is by implication obsolete. The only people who have power are the supreme industrialist, Fredersen, and his magician/scientist cohort Rotwang.

F

So far so good: when the images are allowed to speak for themselves the film is impeccable both in its symbolism and in its cynicism. The problem with Metropolis is its sentimental story-line, which sees Freder, Fredersen’s son, instantly falling in love with the visionary Maria. Maria leads an underground pseudo-religious movement and preaches that the workers should not rebel but should await the arrival of a ‘Mediator’ between the ‘Head’ (capital) and the ‘Hands’ (labour). That mediator is the ‘Heart’ – love, as embodied, finally, by Freder’s love of Maria and his father’s love of him.

G

Lang wrote the screenplay in collaboration with his then-wife Thea von Harbou. In 1933 he fled from the Nazis (and continued a very successful career in Hollywood). She stayed in Germany and continued to make films under the Hitler regime. There is a constant tension within the film between the too-tidy platitudes of von Harbou’s script and the uncompromisingly caustic vigour of Lang’s imagery.

H

To my mind, both in Metropolis and in the real world, it’s not so much that the ‘Head’ and ‘Hands’ require a ‘Heart’ to mediate between them but that the ‘Hands’ need to develop their own ‘Head’, their own political consciousness, and act accordingly – through the ballot box, through buying power and through a sceptical resistance to the materialistic fantasies of the Fredersens.

I

All the same, Metropolis is probably more accurate now as a representation of industrial and social relations than it has been at any time since its original release. And Fredersen is certainly still the most potent movie symbol of the handful of elusive corporate figureheads who increasingly treat the world as a Metropolis-like global village.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('c001e968-683d-564c-9d83-a781b1b9be39', '83d3c8ed-c586-569d-80b2-389982663071', 1, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 1

Questions 1-4
Questions 1-4
Do the following statements agree with the claims of the writer in Reading Passage?
In boxes
1-4
on your answer sheet, write
YES
if the statement is true
NO
if the statement is false
NOT GIVEN
if the information is not given in the passage
1
The inspiration of the movie-
Metropolis
-comes from the director’s visit in the USA in 1924.
2
The Master of Metropolis, John Fredersen, is portrayed from an industrialist that the director met in the US.
3
The start of the movie exhibits the workers working in full energy.
4
The director and his wife got divorced because his wife decided to stay in Germany.

1 ____ The inspiration of the movie- Metropolis -comes from the director’s visit in the USA in 1924.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0db3f1e5-2ddd-5db6-ad71-31dd969832e5', 'c001e968-683d-564c-9d83-a781b1b9be39', 1, $md$YES$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f633703e-1853-51a1-8bd6-e09117c52b1c', 'c001e968-683d-564c-9d83-a781b1b9be39', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('54d634cf-e466-585a-8995-163b032062b3', 'c001e968-683d-564c-9d83-a781b1b9be39', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('5dd8bfc7-d448-5ba1-8668-4bf061bd3518', '83d3c8ed-c586-569d-80b2-389982663071', 2, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 2

Questions 1-4
Questions 1-4
Do the following statements agree with the claims of the writer in Reading Passage?
In boxes
1-4
on your answer sheet, write
YES
if the statement is true
NO
if the statement is false
NOT GIVEN
if the information is not given in the passage
1
The inspiration of the movie-
Metropolis
-comes from the director’s visit in the USA in 1924.
2
The Master of Metropolis, John Fredersen, is portrayed from an industrialist that the director met in the US.
3
The start of the movie exhibits the workers working in full energy.
4
The director and his wife got divorced because his wife decided to stay in Germany.

2 ____ The Master of Metropolis, John Fredersen, is portrayed from an industrialist that the director met in the US.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0f20d230-0067-5768-8181-9c4cf2adaed0', '5dd8bfc7-d448-5ba1-8668-4bf061bd3518', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9995005e-32e3-515c-9407-6b29485b3d0e', '5dd8bfc7-d448-5ba1-8668-4bf061bd3518', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('357010a2-8e7f-5901-8dc8-234dce4b04fa', '5dd8bfc7-d448-5ba1-8668-4bf061bd3518', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('07c8c42a-da92-54fc-82da-b9d9deb1fc38', '83d3c8ed-c586-569d-80b2-389982663071', 3, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 3

Questions 1-4
Questions 1-4
Do the following statements agree with the claims of the writer in Reading Passage?
In boxes
1-4
on your answer sheet, write
YES
if the statement is true
NO
if the statement is false
NOT GIVEN
if the information is not given in the passage
1
The inspiration of the movie-
Metropolis
-comes from the director’s visit in the USA in 1924.
2
The Master of Metropolis, John Fredersen, is portrayed from an industrialist that the director met in the US.
3
The start of the movie exhibits the workers working in full energy.
4
The director and his wife got divorced because his wife decided to stay in Germany.

3 ____ The start of the movie exhibits the workers working in full energy.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d702b020-ddf1-5500-a0db-3b35e91237b7', '07c8c42a-da92-54fc-82da-b9d9deb1fc38', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('acd5bd33-1f26-54b2-a72f-6bd21ebbca3e', '07c8c42a-da92-54fc-82da-b9d9deb1fc38', 2, $md$NO$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1aff6ccc-1670-5286-b3d1-359f014896a3', '07c8c42a-da92-54fc-82da-b9d9deb1fc38', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('39c34709-3c7e-57b0-ba26-283717f038e0', '83d3c8ed-c586-569d-80b2-389982663071', 4, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, $md$### Question 4

Questions 1-4
Questions 1-4
Do the following statements agree with the claims of the writer in Reading Passage?
In boxes
1-4
on your answer sheet, write
YES
if the statement is true
NO
if the statement is false
NOT GIVEN
if the information is not given in the passage
1
The inspiration of the movie-
Metropolis
-comes from the director’s visit in the USA in 1924.
2
The Master of Metropolis, John Fredersen, is portrayed from an industrialist that the director met in the US.
3
The start of the movie exhibits the workers working in full energy.
4
The director and his wife got divorced because his wife decided to stay in Germany.

4 ____ The director and his wife got divorced because his wife decided to stay in Germany.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a5063a57-d106-5490-b59d-4f021d603bab', '39c34709-3c7e-57b0-ba26-283717f038e0', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('876e182b-48df-5eb5-9cf6-d7f700ab822e', '39c34709-3c7e-57b0-ba26-283717f038e0', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('626bdf8b-96a0-5490-a757-35e26af9280f', '39c34709-3c7e-57b0-ba26-283717f038e0', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('4b8a3b4f-f2dd-51c4-b9e9-4d659f6467b3', '83d3c8ed-c586-569d-80b2-389982663071', 5, 'SUMMARY_COMPLETION', 'READING', 3, $md$### Question 5

Questions 5-10
Questions 5-10
Complete the summary below.
Using
NO MORE THAN TWO WORDS
from the Reading Passage for each answer.
Write your answers in boxes
5-10
on your answer sheet.
The director depicts a world of inequality and
5
. In the future, the mindless masses of workers living underground are treated as
6
. And the master of them is
7
, who is in charge of the whole city. The writer claims that the director, Fritz Lang, presents the movie in an
8
term, where the
9
of the individual machines is not defined. Besides the writer compares the film to the modern global economy in which multinational corporations concern more about the growing
10
and money.

The director depicts a world of inequality and 5 ____ . In the future, the mindless masses of workers living underground are treated as 6 ____ . And the master of them is 7 ____ , who is in charge of the whole city. The writer claims that the director, Fritz Lang, presents the movie in an 8 ____ term, where the 9 ____ of the individual machines is not defined. Besides the writer compares the film to the modern global economy in which multinational corporations concern more about the growing 10 ____ and money.$md$, NULL, ARRAY['.*social.*division.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('10d84cba-c226-59e9-b88d-fab5123e99a3', '83d3c8ed-c586-569d-80b2-389982663071', 6, 'SUMMARY_COMPLETION', 'READING', 3, $md$### Question 6

Questions 5-10
Questions 5-10
Complete the summary below.
Using
NO MORE THAN TWO WORDS
from the Reading Passage for each answer.
Write your answers in boxes
5-10
on your answer sheet.
The director depicts a world of inequality and
5
. In the future, the mindless masses of workers living underground are treated as
6
. And the master of them is
7
, who is in charge of the whole city. The writer claims that the director, Fritz Lang, presents the movie in an
8
term, where the
9
of the individual machines is not defined. Besides the writer compares the film to the modern global economy in which multinational corporations concern more about the growing
10
and money.

The director depicts a world of inequality and 5 ____ . In the future, the mindless masses of workers living underground are treated as 6 ____ . And the master of them is 7 ____ , who is in charge of the whole city. The writer claims that the director, Fritz Lang, presents the movie in an 8 ____ term, where the 9 ____ of the individual machines is not defined. Besides the writer compares the film to the modern global economy in which multinational corporations concern more about the growing 10 ____ and money.$md$, NULL, ARRAY['.*social.*division.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('461c7b48-9cdb-5a4b-9112-3221353a4fd2', '83d3c8ed-c586-569d-80b2-389982663071', 7, 'SUMMARY_COMPLETION', 'READING', 3, $md$### Question 7

Questions 5-10
Questions 5-10
Complete the summary below.
Using
NO MORE THAN TWO WORDS
from the Reading Passage for each answer.
Write your answers in boxes
5-10
on your answer sheet.
The director depicts a world of inequality and
5
. In the future, the mindless masses of workers living underground are treated as
6
. And the master of them is
7
, who is in charge of the whole city. The writer claims that the director, Fritz Lang, presents the movie in an
8
term, where the
9
of the individual machines is not defined. Besides the writer compares the film to the modern global economy in which multinational corporations concern more about the growing
10
and money.

The director depicts a world of inequality and 5 ____ . In the future, the mindless masses of workers living underground are treated as 6 ____ . And the master of them is 7 ____ , who is in charge of the whole city. The writer claims that the director, Fritz Lang, presents the movie in an 8 ____ term, where the 9 ____ of the individual machines is not defined. Besides the writer compares the film to the modern global economy in which multinational corporations concern more about the growing 10 ____ and money.$md$, NULL, ARRAY['.*social.*division.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('2971f415-2da5-55cf-a4f2-30a46da56219', '83d3c8ed-c586-569d-80b2-389982663071', 8, 'SUMMARY_COMPLETION', 'READING', 3, $md$### Question 8

Questions 5-10
Questions 5-10
Complete the summary below.
Using
NO MORE THAN TWO WORDS
from the Reading Passage for each answer.
Write your answers in boxes
5-10
on your answer sheet.
The director depicts a world of inequality and
5
. In the future, the mindless masses of workers living underground are treated as
6
. And the master of them is
7
, who is in charge of the whole city. The writer claims that the director, Fritz Lang, presents the movie in an
8
term, where the
9
of the individual machines is not defined. Besides the writer compares the film to the modern global economy in which multinational corporations concern more about the growing
10
and money.

The director depicts a world of inequality and 5 ____ . In the future, the mindless masses of workers living underground are treated as 6 ____ . And the master of them is 7 ____ , who is in charge of the whole city. The writer claims that the director, Fritz Lang, presents the movie in an 8 ____ term, where the 9 ____ of the individual machines is not defined. Besides the writer compares the film to the modern global economy in which multinational corporations concern more about the growing 10 ____ and money.$md$, NULL, ARRAY['.*social.*division.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('55b21e5a-18f9-53ad-9d42-bf121a4ee5e8', '83d3c8ed-c586-569d-80b2-389982663071', 9, 'SUMMARY_COMPLETION', 'READING', 3, $md$### Question 9

Questions 5-10
Questions 5-10
Complete the summary below.
Using
NO MORE THAN TWO WORDS
from the Reading Passage for each answer.
Write your answers in boxes
5-10
on your answer sheet.
The director depicts a world of inequality and
5
. In the future, the mindless masses of workers living underground are treated as
6
. And the master of them is
7
, who is in charge of the whole city. The writer claims that the director, Fritz Lang, presents the movie in an
8
term, where the
9
of the individual machines is not defined. Besides the writer compares the film to the modern global economy in which multinational corporations concern more about the growing
10
and money.

The director depicts a world of inequality and 5 ____ . In the future, the mindless masses of workers living underground are treated as 6 ____ . And the master of them is 7 ____ , who is in charge of the whole city. The writer claims that the director, Fritz Lang, presents the movie in an 8 ____ term, where the 9 ____ of the individual machines is not defined. Besides the writer compares the film to the modern global economy in which multinational corporations concern more about the growing 10 ____ and money.$md$, NULL, ARRAY['.*social.*division.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('8c080aa2-f658-504c-afb9-14a435d37cec', '83d3c8ed-c586-569d-80b2-389982663071', 10, 'SUMMARY_COMPLETION', 'READING', 4, $md$### Question 10

Questions 5-10
Questions 5-10
Complete the summary below.
Using
NO MORE THAN TWO WORDS
from the Reading Passage for each answer.
Write your answers in boxes
5-10
on your answer sheet.
The director depicts a world of inequality and
5
. In the future, the mindless masses of workers living underground are treated as
6
. And the master of them is
7
, who is in charge of the whole city. The writer claims that the director, Fritz Lang, presents the movie in an
8
term, where the
9
of the individual machines is not defined. Besides the writer compares the film to the modern global economy in which multinational corporations concern more about the growing
10
and money.

The director depicts a world of inequality and 5 ____ . In the future, the mindless masses of workers living underground are treated as 6 ____ . And the master of them is 7 ____ , who is in charge of the whole city. The writer claims that the director, Fritz Lang, presents the movie in an 8 ____ term, where the 9 ____ of the individual machines is not defined. Besides the writer compares the film to the modern global economy in which multinational corporations concern more about the growing 10 ____ and money.$md$, NULL, ARRAY['.*social.*division.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('561d8e67-2b15-5665-bf97-29a424c239b7', '83d3c8ed-c586-569d-80b2-389982663071', 11, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 11

Questions 11-14
Questions 11-14
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
11-14
on your answer sheet.
11.
The first sentence in
paragraph B
indicates
A
the author’s fear about technology
B
the inspiration of the director
C
the contradictory feelings towards future
D
the city elite’s well management of the workers
12.
Why the function of the individual machines is not defined?
A
Because Lang sticks to theme in a symbolic way.
B
Because workers are more important to exploit.
C
Because the fantasy sequence is difficult to take.
D
Because the focus of the movie is not about machines.
13.
The writer’s purpose in paragraph five is to
A
emphasize the multinational corporations’ profit-oriented goal.
B
compare the movie with the reality in the modern global economy
C
exploit the difference between fantasy and reality
D
enlighten the undeveloped industry
14.
What is the writer’s opinion about the movie?
A
The movie’s story-line is excellent.
B
The movie has a poor implication in symbolism.
C
The movie is perfect in all aspects.
D
The movie is good but could be better.

Choose the correct letter, A , B , C or D .$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('24d01264-6439-5436-b8d3-3e30e4f3a6d4', '83d3c8ed-c586-569d-80b2-389982663071', 12, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 12

Questions 11-14
Questions 11-14
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
11-14
on your answer sheet.
11.
The first sentence in
paragraph B
indicates
A
the author’s fear about technology
B
the inspiration of the director
C
the contradictory feelings towards future
D
the city elite’s well management of the workers
12.
Why the function of the individual machines is not defined?
A
Because Lang sticks to theme in a symbolic way.
B
Because workers are more important to exploit.
C
Because the fantasy sequence is difficult to take.
D
Because the focus of the movie is not about machines.
13.
The writer’s purpose in paragraph five is to
A
emphasize the multinational corporations’ profit-oriented goal.
B
compare the movie with the reality in the modern global economy
C
exploit the difference between fantasy and reality
D
enlighten the undeveloped industry
14.
What is the writer’s opinion about the movie?
A
The movie’s story-line is excellent.
B
The movie has a poor implication in symbolism.
C
The movie is perfect in all aspects.
D
The movie is good but could be better.

Choose the correct letter, A , B , C or D .$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('e069f794-f27a-57c8-ae1e-e235c58daa94', '83d3c8ed-c586-569d-80b2-389982663071', 13, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 13

Questions 11-14
Questions 11-14
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
11-14
on your answer sheet.
11.
The first sentence in
paragraph B
indicates
A
the author’s fear about technology
B
the inspiration of the director
C
the contradictory feelings towards future
D
the city elite’s well management of the workers
12.
Why the function of the individual machines is not defined?
A
Because Lang sticks to theme in a symbolic way.
B
Because workers are more important to exploit.
C
Because the fantasy sequence is difficult to take.
D
Because the focus of the movie is not about machines.
13.
The writer’s purpose in paragraph five is to
A
emphasize the multinational corporations’ profit-oriented goal.
B
compare the movie with the reality in the modern global economy
C
exploit the difference between fantasy and reality
D
enlighten the undeveloped industry
14.
What is the writer’s opinion about the movie?
A
The movie’s story-line is excellent.
B
The movie has a poor implication in symbolism.
C
The movie is perfect in all aspects.
D
The movie is good but could be better.

Choose the correct letter, A , B , C or D .$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('17de4015-ead9-5465-b833-b118ee63a67c', '83d3c8ed-c586-569d-80b2-389982663071', 14, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 14

Questions 11-14
Questions 11-14
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
11-14
on your answer sheet.
11.
The first sentence in
paragraph B
indicates
A
the author’s fear about technology
B
the inspiration of the director
C
the contradictory feelings towards future
D
the city elite’s well management of the workers
12.
Why the function of the individual machines is not defined?
A
Because Lang sticks to theme in a symbolic way.
B
Because workers are more important to exploit.
C
Because the fantasy sequence is difficult to take.
D
Because the focus of the movie is not about machines.
13.
The writer’s purpose in paragraph five is to
A
emphasize the multinational corporations’ profit-oriented goal.
B
compare the movie with the reality in the modern global economy
C
exploit the difference between fantasy and reality
D
enlighten the undeveloped industry
14.
What is the writer’s opinion about the movie?
A
The movie’s story-line is excellent.
B
The movie has a poor implication in symbolism.
C
The movie is perfect in all aspects.
D
The movie is good but could be better.

Choose the correct letter, A , B , C or D .$md$, NULL);

COMMIT;
