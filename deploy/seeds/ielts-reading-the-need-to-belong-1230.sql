BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-the-need-to-belong-1230'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-the-need-to-belong-1230';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-the-need-to-belong-1230';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-the-need-to-belong-1230';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('2594186d-059d-5c3c-8fe3-2de8f269a54f', 'ielts-reading-the-need-to-belong-1230', $t$The Need to Belong$t$, $md$## The Need to Belong

Nguồn:
- Test: https://mini-ielts.com/1230/reading/the-need-to-belong
- Solution: https://mini-ielts.com/1230/view-solution/reading/the-need-to-belong$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('89894001-a26c-5a60-9c60-76ab0bd32c4e', '2594186d-059d-5c3c-8fe3-2de8f269a54f', 1, $t$Reading — The Need to Belong$t$, $md$Read the passage and answer questions **1–13**.

### Passage: The Need to Belong

No one likes to feel left out, ignored by colleagues at meetings or not be invited to the big party that everyone is talking about Imagine not being part of a joke, or worse still, if the joke is on you. For most people, living the life of an outsider can have a negative effect on self­e-steem and mood. It can even lead to negative behaviour. The pull to belong is extremely strong. Scientists believe that, in part, there is an evolutionary explanation for why we have this need to belong.

In the past, people hunted and cooked together in tribes and each member of the group would be assigned a role. As each member had a purpose, it meant that in the event of the loss of one person, the group as a whole would suffer. For this reason, they had a vested interest in protecting each other. To our prehistoric ancestors, membership of a group meant the difference between survival and death.Those who were rejected and excluded from joining a group had to fend for themselves and struggled to stay alive alone in the wild. Apart from protection, being part of a group also ensured that genes could be passed on to future generations. Although it is very different now from the way our primitive ancestors lived, our brains have not had time to evolve to fit today’s lifestyles. In this day and age, it is no longer a matter of survival to be affiliated to a tribe or group, but the evolutionary instinct to find protection still lingers.

This inherent feeling of security that comes with being part of a group is powerful enough to make people employ both conscious and unconscious strategies to gain membership. One obvious way people try to be accepted into a group is self-presentation, which is the act of portraying yourself in the best possible light An individual will attempt to outwardly display the characteristics which are important to the group’s advancement At the same time, they will conceal any parts of their personality that may be seen as undesirable or not useful to a group. An example of self-presentation is the job application process. A candidate applying for a job will promote themselves as motivated, but is likely to hide the fact that they are disorganised. These conscious tactics that people use are not a surprise to anyone, but we also use other strategies unknowingly.

Psychologists Jessica Larkin, Tanya Chartrand and Robert Arkin suggested that people often resort to automatic mimicry to gain affiliation into groups, much like our primitive ancestors used to do. Before humans had the ability to speak, physical imitation was a method of begging for a place in the group. Most will be unaware they are doing it Larkin and her co-workers decided to test this hypothesis.

They took a group of student volunteers and had them play a game called Cyberball, a ball­tossing arcade game that resembled American football. The volunteers were led to believe they were all playing against each other, but in actual fact they were not The computer was manipulating the game by passing the ball to some volunteers and excluding others.

The ‘accepted’and ‘rejected’students were then asked if they enjoyed the game and about their opinions of the other players. Participants were then put alone in a room and their natural foot movements were filmed. Then a female entered the room under the pretence of conducting a fake photo descnption task. I he female deliberately moved her foot during the task, but not in a way that would be noticeable to the volunteer. It turned out that the rejected students mimicked the female’s foot movements the most This revealed that after exclusion, people will automatically mimic to affiliate with someone new.

However, Larkin and her colleagues wanted to go further.They believed that more often than not, in the real world, we actually know the people that reject us. How do we behave towards the group that we know has excluded us? The experiment was repeated with this question in mind. In the second experiment, only female volunteers played the Cyberball game, during which they experienced rejection by either men or women.Then each volunteer did the fake photo task, but this time with a man and then a woman. The results clearly indicated that the female students that felt rejected would unconsciously make more of an effort to mimic members of their own in-group – that is, other women – rather than men. This deep-wired instinct to mimic was not only directed towards random people, as initially thought, but targeted to specific groups, the particular group that did the rejecting in the first place.

To some, it is inconceivable why people will go to great lengths to be accepted into one of life’s social groups or clubs, enduring rejection and sometimes humiliation in order to be accepted. You only have to look at college campuses, which are notorious for strict initiations inflicted on candidates desperately seeking membership. But it happens and will continue to happen, because the desire to belong is a very powerful force and a fundamental part of human nature.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('32419fb5-429a-5063-a034-765f036403ba', '89894001-a26c-5a60-9c60-76ab0bd32c4e', 1, 'SUMMARY_COMPLETION', 'READING', 2, $md$### Question 1

Questions 1-5
Questions 1-5
Complete the summary.
Choose
NO MORE THAN TWO WORDS
from the passage for each answer.
Modern mans basic need to belong to clubs and groups dates back to early history. Each person within the group had a
1
to play and was considered integral to the entire groups dynamics and success. For an individual, belonging to a group could affect their chances of
2
In those times, few could avoid death living alone in
3
. Living with other humans offered
4
from danger. Staying in a group also meant that
5
could be passed down to descendants.

Modern mans basic need to belong to clubs and groups dates back to early history. Each person within the group had a 1 ____ to play and was considered integral to the entire groups dynamics and success. For an individual, belonging to a group could affect their chances of 2 ____ In those times, few could avoid death living alone in 3 ____ . Living with other humans offered 4 ____ from danger. Staying in a group also meant that 5 ____ could be passed down to descendants.$md$, NULL, ARRAY['.*role.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('2202172d-3416-57b7-9aba-84dc99fea68b', '89894001-a26c-5a60-9c60-76ab0bd32c4e', 2, 'SUMMARY_COMPLETION', 'READING', 2, $md$### Question 2

Questions 1-5
Questions 1-5
Complete the summary.
Choose
NO MORE THAN TWO WORDS
from the passage for each answer.
Modern mans basic need to belong to clubs and groups dates back to early history. Each person within the group had a
1
to play and was considered integral to the entire groups dynamics and success. For an individual, belonging to a group could affect their chances of
2
In those times, few could avoid death living alone in
3
. Living with other humans offered
4
from danger. Staying in a group also meant that
5
could be passed down to descendants.

Modern mans basic need to belong to clubs and groups dates back to early history. Each person within the group had a 1 ____ to play and was considered integral to the entire groups dynamics and success. For an individual, belonging to a group could affect their chances of 2 ____ In those times, few could avoid death living alone in 3 ____ . Living with other humans offered 4 ____ from danger. Staying in a group also meant that 5 ____ could be passed down to descendants.$md$, NULL, ARRAY['.*role.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('338f8887-c34a-5b84-891c-96b15a4acee4', '89894001-a26c-5a60-9c60-76ab0bd32c4e', 3, 'SUMMARY_COMPLETION', 'READING', 2, $md$### Question 3

Questions 1-5
Questions 1-5
Complete the summary.
Choose
NO MORE THAN TWO WORDS
from the passage for each answer.
Modern mans basic need to belong to clubs and groups dates back to early history. Each person within the group had a
1
to play and was considered integral to the entire groups dynamics and success. For an individual, belonging to a group could affect their chances of
2
In those times, few could avoid death living alone in
3
. Living with other humans offered
4
from danger. Staying in a group also meant that
5
could be passed down to descendants.

Modern mans basic need to belong to clubs and groups dates back to early history. Each person within the group had a 1 ____ to play and was considered integral to the entire groups dynamics and success. For an individual, belonging to a group could affect their chances of 2 ____ In those times, few could avoid death living alone in 3 ____ . Living with other humans offered 4 ____ from danger. Staying in a group also meant that 5 ____ could be passed down to descendants.$md$, NULL, ARRAY['.*role.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('77974b3c-34e8-5ade-9795-b765a30f97e0', '89894001-a26c-5a60-9c60-76ab0bd32c4e', 4, 'SUMMARY_COMPLETION', 'READING', 2, $md$### Question 4

Questions 1-5
Questions 1-5
Complete the summary.
Choose
NO MORE THAN TWO WORDS
from the passage for each answer.
Modern mans basic need to belong to clubs and groups dates back to early history. Each person within the group had a
1
to play and was considered integral to the entire groups dynamics and success. For an individual, belonging to a group could affect their chances of
2
In those times, few could avoid death living alone in
3
. Living with other humans offered
4
from danger. Staying in a group also meant that
5
could be passed down to descendants.

Modern mans basic need to belong to clubs and groups dates back to early history. Each person within the group had a 1 ____ to play and was considered integral to the entire groups dynamics and success. For an individual, belonging to a group could affect their chances of 2 ____ In those times, few could avoid death living alone in 3 ____ . Living with other humans offered 4 ____ from danger. Staying in a group also meant that 5 ____ could be passed down to descendants.$md$, NULL, ARRAY['.*role.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('85608b1d-0390-54c6-895c-09fd9fce145b', '89894001-a26c-5a60-9c60-76ab0bd32c4e', 5, 'SUMMARY_COMPLETION', 'READING', 3, $md$### Question 5

Questions 1-5
Questions 1-5
Complete the summary.
Choose
NO MORE THAN TWO WORDS
from the passage for each answer.
Modern mans basic need to belong to clubs and groups dates back to early history. Each person within the group had a
1
to play and was considered integral to the entire groups dynamics and success. For an individual, belonging to a group could affect their chances of
2
In those times, few could avoid death living alone in
3
. Living with other humans offered
4
from danger. Staying in a group also meant that
5
could be passed down to descendants.

Modern mans basic need to belong to clubs and groups dates back to early history. Each person within the group had a 1 ____ to play and was considered integral to the entire groups dynamics and success. For an individual, belonging to a group could affect their chances of 2 ____ In those times, few could avoid death living alone in 3 ____ . Living with other humans offered 4 ____ from danger. Staying in a group also meant that 5 ____ could be passed down to descendants.$md$, NULL, ARRAY['.*role.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('2da99323-312b-563a-99ac-627b04c6f37a', '89894001-a26c-5a60-9c60-76ab0bd32c4e', 6, 'SHORT_ANSWER', 'READING', 3, $md$### Question 6

Question 6-10
Question 6-10
Complete the flow chart below
Use
NO MORE THAN THREE WORDS
from the passage for each answer.
THE PROCEDURE FOR LARKIN’S EXPERIMENT
Volunteers believed they were playing a computer game, similar to
6
The computer was controlling the gameplay,
7
to some and not others.
The volunteers gave their
8
after the game.
Each volunteer first sat on their own in a room and had their foot movements
9
The volunteer took part in a task with a woman who
10
on purpose

Volunteers believed they were playing a computer game, similar to 6 ____$md$, NULL, ARRAY['.*american.*football.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('d05468db-a722-51bf-b575-d9992a4411b0', '89894001-a26c-5a60-9c60-76ab0bd32c4e', 7, 'SHORT_ANSWER', 'READING', 3, $md$### Question 7

Question 6-10
Question 6-10
Complete the flow chart below
Use
NO MORE THAN THREE WORDS
from the passage for each answer.
THE PROCEDURE FOR LARKIN’S EXPERIMENT
Volunteers believed they were playing a computer game, similar to
6
The computer was controlling the gameplay,
7
to some and not others.
The volunteers gave their
8
after the game.
Each volunteer first sat on their own in a room and had their foot movements
9
The volunteer took part in a task with a woman who
10
on purpose

The computer was controlling the gameplay, 7 ____ to some and not others.$md$, NULL, ARRAY['.*passing.*the.*ball.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('caa9c0d6-9796-5c3b-a085-9caace3f632f', '89894001-a26c-5a60-9c60-76ab0bd32c4e', 8, 'SHORT_ANSWER', 'READING', 3, $md$### Question 8

Question 6-10
Question 6-10
Complete the flow chart below
Use
NO MORE THAN THREE WORDS
from the passage for each answer.
THE PROCEDURE FOR LARKIN’S EXPERIMENT
Volunteers believed they were playing a computer game, similar to
6
The computer was controlling the gameplay,
7
to some and not others.
The volunteers gave their
8
after the game.
Each volunteer first sat on their own in a room and had their foot movements
9
The volunteer took part in a task with a woman who
10
on purpose

The volunteers gave their 8 ____ after the game.$md$, NULL, ARRAY['.*opinions.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('c4caff45-d99c-55bd-9013-34d185e5060e', '89894001-a26c-5a60-9c60-76ab0bd32c4e', 9, 'SHORT_ANSWER', 'READING', 3, $md$### Question 9

Question 6-10
Question 6-10
Complete the flow chart below
Use
NO MORE THAN THREE WORDS
from the passage for each answer.
THE PROCEDURE FOR LARKIN’S EXPERIMENT
Volunteers believed they were playing a computer game, similar to
6
The computer was controlling the gameplay,
7
to some and not others.
The volunteers gave their
8
after the game.
Each volunteer first sat on their own in a room and had their foot movements
9
The volunteer took part in a task with a woman who
10
on purpose

Each volunteer first sat on their own in a room and had their foot movements 9 ____$md$, NULL, ARRAY['.*filmed.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('c8e42b69-0228-520a-9542-32fc4c959bc5', '89894001-a26c-5a60-9c60-76ab0bd32c4e', 10, 'SHORT_ANSWER', 'READING', 4, $md$### Question 10

Question 6-10
Question 6-10
Complete the flow chart below
Use
NO MORE THAN THREE WORDS
from the passage for each answer.
THE PROCEDURE FOR LARKIN’S EXPERIMENT
Volunteers believed they were playing a computer game, similar to
6
The computer was controlling the gameplay,
7
to some and not others.
The volunteers gave their
8
after the game.
Each volunteer first sat on their own in a room and had their foot movements
9
The volunteer took part in a task with a woman who
10
on purpose

The volunteer took part in a task with a woman who 10 ____ on purpose$md$, NULL, ARRAY['.*moved.*her.*foot.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('e742c64a-6279-532f-9ef5-f2b5985e9d8e', '89894001-a26c-5a60-9c60-76ab0bd32c4e', 11, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 11

Question 11-13
Question 11-13
Choose the correct letter
A,B,C
or
D
11
Which of the following is NOT mentioned in the first paragraph?
A
one experts view on evolution
B
the consequences of being excluded
C
being made fun of by the people around you
D
a social event that people are eagerly awaiting
12
According to the article, which method do people consciously use to obtain membership into their chosen group?
A
They tell the group they are strongly motivated.
B
They convey the best parts of their personality to the group.
C
They show how the group will be important to their lives.
D
They alter aspects of their personality to suit others.
13
The writers main purpose in writing this article is to
A
explain how people feel when they face rejection.
B
encourage people to go it alone and not be part of a group.
C
show the unconscious drive behind the need to belong.
D
compare how the modern lifestyle is different to the past.

Choose the correct letter A,B,C or D$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('9988d72d-1735-5de0-93c7-fdc944678bb4', '89894001-a26c-5a60-9c60-76ab0bd32c4e', 12, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 12

Question 11-13
Question 11-13
Choose the correct letter
A,B,C
or
D
11
Which of the following is NOT mentioned in the first paragraph?
A
one experts view on evolution
B
the consequences of being excluded
C
being made fun of by the people around you
D
a social event that people are eagerly awaiting
12
According to the article, which method do people consciously use to obtain membership into their chosen group?
A
They tell the group they are strongly motivated.
B
They convey the best parts of their personality to the group.
C
They show how the group will be important to their lives.
D
They alter aspects of their personality to suit others.
13
The writers main purpose in writing this article is to
A
explain how people feel when they face rejection.
B
encourage people to go it alone and not be part of a group.
C
show the unconscious drive behind the need to belong.
D
compare how the modern lifestyle is different to the past.

Choose the correct letter A,B,C or D$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('7fa1b740-7b7d-53c7-8450-7f650bfad977', '89894001-a26c-5a60-9c60-76ab0bd32c4e', 13, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 13

Question 11-13
Question 11-13
Choose the correct letter
A,B,C
or
D
11
Which of the following is NOT mentioned in the first paragraph?
A
one experts view on evolution
B
the consequences of being excluded
C
being made fun of by the people around you
D
a social event that people are eagerly awaiting
12
According to the article, which method do people consciously use to obtain membership into their chosen group?
A
They tell the group they are strongly motivated.
B
They convey the best parts of their personality to the group.
C
They show how the group will be important to their lives.
D
They alter aspects of their personality to suit others.
13
The writers main purpose in writing this article is to
A
explain how people feel when they face rejection.
B
encourage people to go it alone and not be part of a group.
C
show the unconscious drive behind the need to belong.
D
compare how the modern lifestyle is different to the past.

Choose the correct letter A,B,C or D$md$, NULL);

COMMIT;
