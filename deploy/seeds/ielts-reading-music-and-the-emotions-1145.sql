BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-music-and-the-emotions-1145'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-music-and-the-emotions-1145';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-music-and-the-emotions-1145';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-music-and-the-emotions-1145';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('e0e318b6-e2f6-53db-85f2-2eec305efbf3', 'ielts-reading-music-and-the-emotions-1145', $t$Music and the emotions$t$, $md$## Music and the emotions

Nguồn:
- Test: https://mini-ielts.com/1145/reading/music-and-the-emotions
- Solution: https://mini-ielts.com/1145/view-solution/reading/music-and-the-emotions$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('1d8d1050-6c01-571a-a2d2-b1b71d4aedb0', 'e0e318b6-e2f6-53db-85f2-2eec305efbf3', 1, $t$Reading — Music and the emotions$t$, $md$Read the passage and answer questions **1–14**.

### Passage: Music and the emotions

Neuroscientist Jonah Lehrer considers the emotional power of music

Why does music make us feel? On the one hand, music is a purely abstract art form, devoid of language or explicit ideas. And yet, even though music says little, it still manages to touch us deeply. When listening to our favourite songs, our body betrays all the symptoms of emotional arousal. The pupils in our eyes dilate, our pulse and blood pressure rise, the electrical conductance of our skin is lowered, and the cerebellum, a brain region associated with bodily movement, becomes strangely active. Blood is even re-directed to the muscles in our legs. In other words, sound stirs us at our biological roots.

A recent paper in Neuroscience by a research team in Montreal, Canada, marks an important step in repealing the precise underpinnings of ‘the potent pleasurable stimulus’ that is music . Although the study involves plenty of fancy technology, including functional magnetic resonance imaging (fMRI) and ligand-based positron emission tomography (PET) scanning, the experiment itself was rather straightforward. After screening 217 individuals who responded to advertisements requesting people who experience ‘chills’ to instrumental music, the scientists narrowed down the subject pool to ten. They then asked the subjects to bring in their playlist of favourite songs - virtually every genre was represented, from techno to tango - and played them the music while their brain activity was monitored. Because the scientists were combining methodologies (PET and fMRI), they were able to obtain an impressively exact and detailed portrait of music in the brain. The first thing they discovered is that music triggers the production of dopamine - a chemical with a key role in setting people’s moods - by the neurons (nerve cells) in both the dorsal and ventral regions of the brain. As these two regions have long been linked with the experience of pleasure , this finding isn’t particularly surprising.

What is rather more significant is the finding that the dopamine neurons in the caudate- a region of the brain involved in learning stimulus-response associations , and in anticipating food and other ‘reward’ stimuli - were at their most active around 15 seconds before the participants’ favourite moments in the music. The researchers call this the ‘ anticipatory phase ’ and argue that the purpose of this activity is to help us predict the arrival of our favourite part. The question, of course, is what all these dopamine neurons are up to. Why are they so active in the period preceding the acoustic climax? After all, we typically associate surges of dopamine with pleasure, with the processing of actual rewards. And yet, this cluster of cells is most active when the ‘chills’ have yet to arrive, when the melodic pattern is still unresolved.

One way to answer the question is to look at the music and not the neurons. While music can often seem (at least to the outsider) like a labyrinth of intricate patterns, it turns out that the most important part of every song or symphony is when the patterns break down, when the sound becomes unpredictable. If the music is too obvious, it is annoyingly boring, like an alarm clock. Numerous studies, after all, have demonstrated that dopamine neurons quickly adapt to predictable rewards . If we know what’s going to happen next, then we don’t get excited. This is why composers often introduce a key note in the beginning of a song, spend most of the rest of the piece in the studious avoidance of the pattern, and then finally repeat it only at the end. The longer we are denied the pattern we expect, the greater the emotional release when the pattern returns, safe and sound.

To demonstrate this psychological principle, the musicologist Leonard Meyer, in his classic book Emotion and Meaning in Music (1956), analysed the 5th movement of Beethoven’s String Quartet in C-sharp minor, Op. 131. Meyer wanted to show how music is defined by its flirtation with - but not submission to - our expectations of order. Meyer dissected 50 measures (bars) of the masterpiece, showing how Beethoven begins with the clear statement of a rhythmic and harmonic pattern and then, in an ingenious tonal dance, carefully holds off repeating it. What Beethoven does instead is suggest variations of the pattern. Me wants to preserve an element of uncertainty in his music, making our brains beg for the one chord he refuses to give us. Beethoven saves that chord for the end.

According to Meyer, it is the suspenseful tension of music, arising out of our unfulfilled expectations, that is the source of the music’s feeling. While earlier theories of music focused on the way a sound can refer to the real world of images and experiences - its ‘connotative’ meaning - Meyer argued that the emotions we find in music come from the unfolding events of the music itself. This ‘embodied meaning’ arises from the patterns the symphony invokes and then ignores. It is this uncertainty that triggers the surge of dopamine in the , as we struggle to figure out what will happen next. We can predict some of the notes, but we can’t predict them all, and that is what keeps us listening, waiting expectantly for our reward, for the pattern to be completed.

----------------------------------------------------

Great thanks to volunteer Lan Nguyen has contributed these explanations markings.

If you want to make a better world like this, please contact us.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('f0020586-2e89-567c-8d3c-bccd21557869', '1d8d1050-6c01-571a-a2d2-b1b71d4aedb0', 1, 'NOTE_COMPLETION', 'READING', 2, $md$### Question 1

Questions 1-5
Questions 1-5
Complete the summary below.
Choose
NO MORE THAN TWO WORDS
from the passage for each answer.
Write your answers in boxes
1-5
on your answer sheet.
The Montreal Study
Participants, who were recruited for the study through advertisements, had their brain activity monitored while listening to their favourite music. It was noted that the music stimulated the brain’s neurons to release a substance called
1
Locate
in two of the parts of the brain which are associated with feeling
2
Locate
.
Researchers also observed that the neurons in the area of the brain called the
3
were particularly active just before the participants’ favourite moments in the music - the period known as the
4
. Activity in this part of the brain is associated with the expectation of ‘reward’ stimuli such as
5
Locate
.

Participants, who were recruited for the study through advertisements, had their brain activity monitored while listening to their favourite music. It was noted that the music stimulated the brain’s neurons to release a substance called 1 ____ Locate in two of the parts of the brain which are associated with feeling 2 ____ Locate .$md$, NULL, ARRAY['.*dopamine.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('28278378-9bdb-5d5b-9469-436539d7c3c8', '1d8d1050-6c01-571a-a2d2-b1b71d4aedb0', 2, 'NOTE_COMPLETION', 'READING', 2, $md$### Question 2

Questions 1-5
Questions 1-5
Complete the summary below.
Choose
NO MORE THAN TWO WORDS
from the passage for each answer.
Write your answers in boxes
1-5
on your answer sheet.
The Montreal Study
Participants, who were recruited for the study through advertisements, had their brain activity monitored while listening to their favourite music. It was noted that the music stimulated the brain’s neurons to release a substance called
1
Locate
in two of the parts of the brain which are associated with feeling
2
Locate
.
Researchers also observed that the neurons in the area of the brain called the
3
were particularly active just before the participants’ favourite moments in the music - the period known as the
4
. Activity in this part of the brain is associated with the expectation of ‘reward’ stimuli such as
5
Locate
.

Participants, who were recruited for the study through advertisements, had their brain activity monitored while listening to their favourite music. It was noted that the music stimulated the brain’s neurons to release a substance called 1 ____ Locate in two of the parts of the brain which are associated with feeling 2 ____ Locate .$md$, NULL, ARRAY['.*dopamine.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('df3af579-c4d0-59cc-af1a-3500d78613e9', '1d8d1050-6c01-571a-a2d2-b1b71d4aedb0', 3, 'NOTE_COMPLETION', 'READING', 2, $md$### Question 3

Questions 1-5
Questions 1-5
Complete the summary below.
Choose
NO MORE THAN TWO WORDS
from the passage for each answer.
Write your answers in boxes
1-5
on your answer sheet.
The Montreal Study
Participants, who were recruited for the study through advertisements, had their brain activity monitored while listening to their favourite music. It was noted that the music stimulated the brain’s neurons to release a substance called
1
Locate
in two of the parts of the brain which are associated with feeling
2
Locate
.
Researchers also observed that the neurons in the area of the brain called the
3
were particularly active just before the participants’ favourite moments in the music - the period known as the
4
. Activity in this part of the brain is associated with the expectation of ‘reward’ stimuli such as
5
Locate
.

Researchers also observed that the neurons in the area of the brain called the 3 ____ were particularly active just before the participants’ favourite moments in the music - the period known as the 4 ____ . Activity in this part of the brain is associated with the expectation of ‘reward’ stimuli such as 5 ____ Locate .$md$, NULL, ARRAY['.*caudate.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('2d642a89-d0af-5d6e-b6f6-3df3bd1efb8e', '1d8d1050-6c01-571a-a2d2-b1b71d4aedb0', 4, 'NOTE_COMPLETION', 'READING', 2, $md$### Question 4

Questions 1-5
Questions 1-5
Complete the summary below.
Choose
NO MORE THAN TWO WORDS
from the passage for each answer.
Write your answers in boxes
1-5
on your answer sheet.
The Montreal Study
Participants, who were recruited for the study through advertisements, had their brain activity monitored while listening to their favourite music. It was noted that the music stimulated the brain’s neurons to release a substance called
1
Locate
in two of the parts of the brain which are associated with feeling
2
Locate
.
Researchers also observed that the neurons in the area of the brain called the
3
were particularly active just before the participants’ favourite moments in the music - the period known as the
4
. Activity in this part of the brain is associated with the expectation of ‘reward’ stimuli such as
5
Locate
.

Researchers also observed that the neurons in the area of the brain called the 3 ____ were particularly active just before the participants’ favourite moments in the music - the period known as the 4 ____ . Activity in this part of the brain is associated with the expectation of ‘reward’ stimuli such as 5 ____ Locate .$md$, NULL, ARRAY['.*caudate.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('61550039-0bbc-5c23-9839-f76044ebd7a1', '1d8d1050-6c01-571a-a2d2-b1b71d4aedb0', 5, 'NOTE_COMPLETION', 'READING', 3, $md$### Question 5

Questions 1-5
Questions 1-5
Complete the summary below.
Choose
NO MORE THAN TWO WORDS
from the passage for each answer.
Write your answers in boxes
1-5
on your answer sheet.
The Montreal Study
Participants, who were recruited for the study through advertisements, had their brain activity monitored while listening to their favourite music. It was noted that the music stimulated the brain’s neurons to release a substance called
1
Locate
in two of the parts of the brain which are associated with feeling
2
Locate
.
Researchers also observed that the neurons in the area of the brain called the
3
were particularly active just before the participants’ favourite moments in the music - the period known as the
4
. Activity in this part of the brain is associated with the expectation of ‘reward’ stimuli such as
5
Locate
.

Researchers also observed that the neurons in the area of the brain called the 3 ____ were particularly active just before the participants’ favourite moments in the music - the period known as the 4 ____ . Activity in this part of the brain is associated with the expectation of ‘reward’ stimuli such as 5 ____ Locate .$md$, NULL, ARRAY['.*caudate.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('a8b18c4c-01fd-59d8-852a-cb351bae9fdd', '1d8d1050-6c01-571a-a2d2-b1b71d4aedb0', 6, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 6

Questions 6-10
Questions 6-10
Choose the correct letter,
A, B, C
or
D
.
Write the correct letter in boxes
6-10
on your answer sheet
6
What point does the writer emphasise in the first paragraph?
A
how dramatically our reactions to music can vary
B
how intense our physical responses to music can be
C
how little we know about the way that music affects us
D
how much music can tell us about how our brains operate
Locate
7
What view of the Montreal study does the writer express in the second paragraph?
A
Its aims were innovative.
B
The approach was too simplistic.
C
It produced some remarkably precise data.
D
The technology used was unnecessarily complex.
Locate
8
What does the writer find interesting about the results of the Montreal study?
A
the timing of participants’ neural responses to the music
B
the impact of the music on participants’ emotional state
C
the section of participants’ brains which was activated by the music
D
the type of music which had the strongest effect on participants’ brains
Locate
9
Why does the writer refer to Meyer’s work on music and emotion?
A
to propose an original theory about the subject
B
to offer support for the findings of the Montreal study
C
to recommend the need for further research into the subject
D
to present a view which opposes that of the Montreal researchers
Locate
10
According to Leonard Meyer, what causes the listener’s emotional response to music?
A
the way that the music evokes poignant memories in the listener
B
the association of certain musical chords with certain feelings
C
the listener’s sympathy with the composer’s intentions
D
the internal structure of the musical composition

Choose the correct letter, A, B, C or D .$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('f28effcd-6126-5d7b-9a90-80ba0ea492ed', '1d8d1050-6c01-571a-a2d2-b1b71d4aedb0', 7, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 7

Questions 6-10
Questions 6-10
Choose the correct letter,
A, B, C
or
D
.
Write the correct letter in boxes
6-10
on your answer sheet
6
What point does the writer emphasise in the first paragraph?
A
how dramatically our reactions to music can vary
B
how intense our physical responses to music can be
C
how little we know about the way that music affects us
D
how much music can tell us about how our brains operate
Locate
7
What view of the Montreal study does the writer express in the second paragraph?
A
Its aims were innovative.
B
The approach was too simplistic.
C
It produced some remarkably precise data.
D
The technology used was unnecessarily complex.
Locate
8
What does the writer find interesting about the results of the Montreal study?
A
the timing of participants’ neural responses to the music
B
the impact of the music on participants’ emotional state
C
the section of participants’ brains which was activated by the music
D
the type of music which had the strongest effect on participants’ brains
Locate
9
Why does the writer refer to Meyer’s work on music and emotion?
A
to propose an original theory about the subject
B
to offer support for the findings of the Montreal study
C
to recommend the need for further research into the subject
D
to present a view which opposes that of the Montreal researchers
Locate
10
According to Leonard Meyer, what causes the listener’s emotional response to music?
A
the way that the music evokes poignant memories in the listener
B
the association of certain musical chords with certain feelings
C
the listener’s sympathy with the composer’s intentions
D
the internal structure of the musical composition

Choose the correct letter, A, B, C or D .$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('6ed917f7-0c91-5376-9c4e-88900b6446a8', '1d8d1050-6c01-571a-a2d2-b1b71d4aedb0', 8, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 8

Questions 6-10
Questions 6-10
Choose the correct letter,
A, B, C
or
D
.
Write the correct letter in boxes
6-10
on your answer sheet
6
What point does the writer emphasise in the first paragraph?
A
how dramatically our reactions to music can vary
B
how intense our physical responses to music can be
C
how little we know about the way that music affects us
D
how much music can tell us about how our brains operate
Locate
7
What view of the Montreal study does the writer express in the second paragraph?
A
Its aims were innovative.
B
The approach was too simplistic.
C
It produced some remarkably precise data.
D
The technology used was unnecessarily complex.
Locate
8
What does the writer find interesting about the results of the Montreal study?
A
the timing of participants’ neural responses to the music
B
the impact of the music on participants’ emotional state
C
the section of participants’ brains which was activated by the music
D
the type of music which had the strongest effect on participants’ brains
Locate
9
Why does the writer refer to Meyer’s work on music and emotion?
A
to propose an original theory about the subject
B
to offer support for the findings of the Montreal study
C
to recommend the need for further research into the subject
D
to present a view which opposes that of the Montreal researchers
Locate
10
According to Leonard Meyer, what causes the listener’s emotional response to music?
A
the way that the music evokes poignant memories in the listener
B
the association of certain musical chords with certain feelings
C
the listener’s sympathy with the composer’s intentions
D
the internal structure of the musical composition

Choose the correct letter, A, B, C or D .$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('999d78e5-bd7b-5ce5-9371-55db9e7f5fe4', '1d8d1050-6c01-571a-a2d2-b1b71d4aedb0', 9, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 9

Questions 6-10
Questions 6-10
Choose the correct letter,
A, B, C
or
D
.
Write the correct letter in boxes
6-10
on your answer sheet
6
What point does the writer emphasise in the first paragraph?
A
how dramatically our reactions to music can vary
B
how intense our physical responses to music can be
C
how little we know about the way that music affects us
D
how much music can tell us about how our brains operate
Locate
7
What view of the Montreal study does the writer express in the second paragraph?
A
Its aims were innovative.
B
The approach was too simplistic.
C
It produced some remarkably precise data.
D
The technology used was unnecessarily complex.
Locate
8
What does the writer find interesting about the results of the Montreal study?
A
the timing of participants’ neural responses to the music
B
the impact of the music on participants’ emotional state
C
the section of participants’ brains which was activated by the music
D
the type of music which had the strongest effect on participants’ brains
Locate
9
Why does the writer refer to Meyer’s work on music and emotion?
A
to propose an original theory about the subject
B
to offer support for the findings of the Montreal study
C
to recommend the need for further research into the subject
D
to present a view which opposes that of the Montreal researchers
Locate
10
According to Leonard Meyer, what causes the listener’s emotional response to music?
A
the way that the music evokes poignant memories in the listener
B
the association of certain musical chords with certain feelings
C
the listener’s sympathy with the composer’s intentions
D
the internal structure of the musical composition

Choose the correct letter, A, B, C or D .$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('e10f90d6-48e1-5e47-a429-e77fc5ef3193', '1d8d1050-6c01-571a-a2d2-b1b71d4aedb0', 10, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 10

Questions 6-10
Questions 6-10
Choose the correct letter,
A, B, C
or
D
.
Write the correct letter in boxes
6-10
on your answer sheet
6
What point does the writer emphasise in the first paragraph?
A
how dramatically our reactions to music can vary
B
how intense our physical responses to music can be
C
how little we know about the way that music affects us
D
how much music can tell us about how our brains operate
Locate
7
What view of the Montreal study does the writer express in the second paragraph?
A
Its aims were innovative.
B
The approach was too simplistic.
C
It produced some remarkably precise data.
D
The technology used was unnecessarily complex.
Locate
8
What does the writer find interesting about the results of the Montreal study?
A
the timing of participants’ neural responses to the music
B
the impact of the music on participants’ emotional state
C
the section of participants’ brains which was activated by the music
D
the type of music which had the strongest effect on participants’ brains
Locate
9
Why does the writer refer to Meyer’s work on music and emotion?
A
to propose an original theory about the subject
B
to offer support for the findings of the Montreal study
C
to recommend the need for further research into the subject
D
to present a view which opposes that of the Montreal researchers
Locate
10
According to Leonard Meyer, what causes the listener’s emotional response to music?
A
the way that the music evokes poignant memories in the listener
B
the association of certain musical chords with certain feelings
C
the listener’s sympathy with the composer’s intentions
D
the internal structure of the musical composition

Choose the correct letter, A, B, C or D .$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('a5a26c33-42d5-5097-8263-a4c6c6184da5', '1d8d1050-6c01-571a-a2d2-b1b71d4aedb0', 11, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 11

Questions 11-14
Questions 11-14
Complete each sentence with the correct ending,
A-F
, below.
Write the correct letter,
A-F
, in boxes
11-14
on your answer sheet.
11
The Montreal researchers discovered that
Locate
12
Many studies have demonstrated that
Locate
13
Meyer’s analysis of Beethoven’s music shows that
Locate
14
Earlier theories of music suggested that
A
our response to music depends on our initial emotional state.
B
neuron activity decreases if outcomes become predictable.
C
emotive music can bring to mind actual pictures and events.
D
experiences on our past can influence our emotional reaction to music.
E
emotive music delays giving listeners what they expect to hear.
F
neuron activity increases prior to key points in a musical piece.

11 ____ The Montreal researchers discovered that Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a1b2da3a-f958-574c-aded-9e5b8b37191b', 'a5a26c33-42d5-5097-8263-a4c6c6184da5', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9d4090cf-c348-54e5-b529-0d7b2c9cd27c', 'a5a26c33-42d5-5097-8263-a4c6c6184da5', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('86ebbe98-a990-5521-8243-3da0befd88d9', 'a5a26c33-42d5-5097-8263-a4c6c6184da5', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('fd528c5e-a233-542b-a271-52eb2242a82a', 'a5a26c33-42d5-5097-8263-a4c6c6184da5', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('06f72614-cf43-5756-9b2c-2444aa8a67a2', 'a5a26c33-42d5-5097-8263-a4c6c6184da5', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1e6dade3-66a7-5af6-9317-a3ecdfa2c738', 'a5a26c33-42d5-5097-8263-a4c6c6184da5', 6, $md$F$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('af742389-5d7b-5670-8fcd-2d14c4a1d843', '1d8d1050-6c01-571a-a2d2-b1b71d4aedb0', 12, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 12

Questions 11-14
Questions 11-14
Complete each sentence with the correct ending,
A-F
, below.
Write the correct letter,
A-F
, in boxes
11-14
on your answer sheet.
11
The Montreal researchers discovered that
Locate
12
Many studies have demonstrated that
Locate
13
Meyer’s analysis of Beethoven’s music shows that
Locate
14
Earlier theories of music suggested that
A
our response to music depends on our initial emotional state.
B
neuron activity decreases if outcomes become predictable.
C
emotive music can bring to mind actual pictures and events.
D
experiences on our past can influence our emotional reaction to music.
E
emotive music delays giving listeners what they expect to hear.
F
neuron activity increases prior to key points in a musical piece.

12 ____ Many studies have demonstrated that Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c517bdc1-63a1-58e6-aa68-1d53d3bd23d1', 'af742389-5d7b-5670-8fcd-2d14c4a1d843', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('aafaba71-bad3-5a43-aa16-3468c4fee6eb', 'af742389-5d7b-5670-8fcd-2d14c4a1d843', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f91eba8a-5bd6-5545-8280-c0bceca47ea8', 'af742389-5d7b-5670-8fcd-2d14c4a1d843', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a5d5b030-a4eb-5d2f-a1fd-66ed4a60cdbe', 'af742389-5d7b-5670-8fcd-2d14c4a1d843', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ba16e7c3-3be2-5ad4-894a-4867be6fbb40', 'af742389-5d7b-5670-8fcd-2d14c4a1d843', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('84ce1157-41d2-5847-a92a-fe167d0ee176', 'af742389-5d7b-5670-8fcd-2d14c4a1d843', 6, $md$F$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('426a95b1-cd34-542e-8d60-d1aa5524dde6', '1d8d1050-6c01-571a-a2d2-b1b71d4aedb0', 13, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 13

Questions 11-14
Questions 11-14
Complete each sentence with the correct ending,
A-F
, below.
Write the correct letter,
A-F
, in boxes
11-14
on your answer sheet.
11
The Montreal researchers discovered that
Locate
12
Many studies have demonstrated that
Locate
13
Meyer’s analysis of Beethoven’s music shows that
Locate
14
Earlier theories of music suggested that
A
our response to music depends on our initial emotional state.
B
neuron activity decreases if outcomes become predictable.
C
emotive music can bring to mind actual pictures and events.
D
experiences on our past can influence our emotional reaction to music.
E
emotive music delays giving listeners what they expect to hear.
F
neuron activity increases prior to key points in a musical piece.

13 ____ Meyer’s analysis of Beethoven’s music shows that Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('efbc0569-c3ca-5676-98d8-89f1f118c9fb', '426a95b1-cd34-542e-8d60-d1aa5524dde6', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('08b97028-7b03-57e5-a99a-f2ad089bc898', '426a95b1-cd34-542e-8d60-d1aa5524dde6', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0f7d1aea-0da5-52aa-b6af-c57e072c2edb', '426a95b1-cd34-542e-8d60-d1aa5524dde6', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('db40d4c0-005d-57bd-85a1-a3d2c0028bad', '426a95b1-cd34-542e-8d60-d1aa5524dde6', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b30cb101-2efd-58fa-956c-c3a4a258a01a', '426a95b1-cd34-542e-8d60-d1aa5524dde6', 5, $md$E$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a4942916-7921-5797-b72b-921846e24164', '426a95b1-cd34-542e-8d60-d1aa5524dde6', 6, $md$F$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('79dec3d1-b12e-57f8-800a-c56d6b4adee0', '1d8d1050-6c01-571a-a2d2-b1b71d4aedb0', 14, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 14

Questions 11-14
Questions 11-14
Complete each sentence with the correct ending,
A-F
, below.
Write the correct letter,
A-F
, in boxes
11-14
on your answer sheet.
11
The Montreal researchers discovered that
Locate
12
Many studies have demonstrated that
Locate
13
Meyer’s analysis of Beethoven’s music shows that
Locate
14
Earlier theories of music suggested that
A
our response to music depends on our initial emotional state.
B
neuron activity decreases if outcomes become predictable.
C
emotive music can bring to mind actual pictures and events.
D
experiences on our past can influence our emotional reaction to music.
E
emotive music delays giving listeners what they expect to hear.
F
neuron activity increases prior to key points in a musical piece.

14 ____ Earlier theories of music suggested that$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e61e2239-c605-5032-a2d0-10f5c9a8ce84', '79dec3d1-b12e-57f8-800a-c56d6b4adee0', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8204c047-6548-5be2-ba01-4e465d87af35', '79dec3d1-b12e-57f8-800a-c56d6b4adee0', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('09b9a4cc-98ea-5690-b557-8c70fce62884', '79dec3d1-b12e-57f8-800a-c56d6b4adee0', 3, $md$C$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('01887aff-bd81-50eb-a2de-fdf18ff8eb57', '79dec3d1-b12e-57f8-800a-c56d6b4adee0', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e4c01a10-05ab-5518-b17d-5e9aaa912b50', '79dec3d1-b12e-57f8-800a-c56d6b4adee0', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7e5214d7-e823-5bca-87cb-d59d1d94c25e', '79dec3d1-b12e-57f8-800a-c56d6b4adee0', 6, $md$F$md$, false);

COMMIT;
