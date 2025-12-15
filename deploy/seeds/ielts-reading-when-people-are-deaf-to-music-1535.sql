BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-when-people-are-deaf-to-music-1535'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-when-people-are-deaf-to-music-1535';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-when-people-are-deaf-to-music-1535';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-when-people-are-deaf-to-music-1535';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('de9f80aa-3b79-57e0-94aa-2cd92046c594', 'ielts-reading-when-people-are-deaf-to-music-1535', $t$When people are deaf’ to music$t$, $md$## When people are deaf’ to music

Nguồn:
- Test: https://mini-ielts.com/1535/reading/when-people-are-deaf-to-music
- Solution: https://mini-ielts.com/1535/view-solution/reading/when-people-are-deaf-to-music$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('6f01ca37-9eb5-5354-bf44-7e392fab2063', 'de9f80aa-3b79-57e0-94aa-2cd92046c594', 1, $t$Reading — When people are deaf’ to music$t$, $md$Read the passage and answer questions **1–14**.

### Passage: When people are deaf’ to music

Music has long been considered a uniquely human concept. In fact, most psychologists agree that music is a universal human instinct. Like any ability, however, there is great variation in people's musical competence. For every brilliant pianist in the world, there are several people we refer to as " tone deaf". It is not simply that people with tone deafness (or' amusia") are unable to sing in tune, they are also unable to discriminate between tones or recognize familiar melodies. Such a" disorder" can occur after some sort of brain damage , but recently research has been undertaken in an attempt to discover the cause of congenital amusia (when people are born with the condition), which is not associated with any brain damage, hearing problems, or lack of exposure to music.

According to the research of Dr. Isabelie Peretz of the University of Montreat, amusia is more complicated than the inability to distinguish pitches. An amusia (a person who has the condition of amusia) can distinguish between two pitches that are far apart, but cannot tell the difference between intervals smaller than a half step on the Western diatonic scale, while most people can easily distinguish differences smaller than that, when listening to melodies which have had a single note altered so that it is out of key with the rest of the melody, do not notice a problem. As would be expected, amusics perform significantly worse at singing and tapping a rhythm along with a melody than do non-amusics.

The most fascinating aspect of amusia is how specific to music it is. Because of music’s close ties

to language, it might be expected that a musical impairment may be caused by a language impairment. Studies suggest, however, that language and music ability are independent of one another. People with brain damage in areas critical to language are often still able to sing, despite being unable to communicate through speech. Moreover, while amusics show deficiencies in their recognition of pitch differences in melodies, they show no tonal languages, such as Chinese, do not report having any difficulty discriminating between words that differ only in their intonation. The linguistic cues inherent in speech make discrimination of meaning much easier for amusics. Amusics are also successful most of the time at detecting the mood of a melody, can identify a speaker based on his or her voice and can discriminate and identify environmental sounds.

Recent work has been focused on locating the part of the brain that is responsible for amusia. The temporal lobes of the brain, the location of the primary auditory cortex, have been considered. It has long been believed that the temporal lobes, especially the right temporal lobe, are most active when activity, so any musical disability should logically stem from here as well. Because it has been shown that there is no hearing deficit in amusia, researchers moved on to the temporal neocortex, which is where more sophisticated processing of musical cues was thought to take place. New studies, however, have suggested that the deficits in amusics are located outside the auditory cortex. Brain scans of amusics do not show any reaction at all to differences smaller than a half step, when changes in tones are large, their brains overreact, showing twice as much activity on the right side of the brain as a normal brain hearing the same thing. These differences do not occur in the auditory cortex, indicating again that the deficits of amusia lie mostly in hearing impairment, but in higher processing of melodies.

So what does this all mean? Looking only at the research of Peretz in the field of neuropsychology of music, it would appear that amusia is some sort of disorder. As a student of neurobiology, however, I am skeptical. Certainly the studies by Peretz that have found significant differences between the brains of so-called amusics and normal brains are legitimate. The more important question now becomes one of normality. Every trait from skin color to intelligence to mood exists on a continuum-there is a great idea of variation from one extreme to the other. Just because we recognize that basic musical ability is something that the vast majority of people have, this doesn’t mean that the lack of it is abnormal

What makes an amusic worse off than a musical prodigy? Musical ability is culturally valued, and may have been a factor in survival at one point in human history, but it does not seem likely that it is being selected for on an evolutionary scale any longer. Darwin believed that music was adaptive as a way of finding a mate, but who needs to be able to sing to find a partner in an age when it is possible to express your emotions through a song on your IPod?

While the idea of amusia is interesting, it seems to be just one end of the continuum of innate musical ability. Comparing this ‘disorder’ to learning disorders like a specific language impairment seems to be going too far. Before, amusia can be declared a disability, further research must be done to determine whether lack of musical ability is actually detrimental in any way. If no disadvantages can be found of having amusia, then it is no more a disability than having poor fashion sense or bad handwriting.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('c9c5ddd1-2110-5bf3-b602-56524142f1f9', '6f01ca37-9eb5-5354-bf44-7e392fab2063', 1, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 1

Question 1-5
Question 1-5
Choose the correct letter,
A,
B, C
or
D
Write the correct letter in boxes 27-31 on your answer sheet
1. What does the writer tell US about people with tone deafness (amusia) in the first
paragraph?
A
They usually have hearing problems
B
Some can play a musical instrument very well
C
Some may be able to sing well-known melodies
D
They have several inabilities in regard to music
2. What is
the writer doing in the second paragraph?
A
outlining some of factors that cause amusia
B
summarising some findings about people with amusia
C
suggesting that people with amusia are disadvantaged
D
comparing the sing ability of amusia with their sense
3. What does
the writer say about the relationship between language ability
and musical ability?
A
People who are unable to speak can sometimes sing
B
People with amusia usually have language problems too
C
Speakers of tonal languages like Chinese rarely have amusia
D
People with amusia have difficulty recognizing people by
their voices
4. In the
third paragraph, the writer notes that most amusics are able to
A
learn how to sing in tune
B
identify a song by its tune
C
distinguish a sad tone from a happy tune
D
recognise when a singer is not sing in tune
5. What is the writer doing in the fourth paragraph?
A
claiming that amusics have problems in the auditory cortex
B
outlining progress in understanding the brains of amusics
C
proving that amuisa is located in the temporal lobes
D
explaining why studies of hearing are difficult

Choose the correct letter, A, B, C or D$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('3121530c-35a2-5645-b1dc-f026c2589584', '6f01ca37-9eb5-5354-bf44-7e392fab2063', 2, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 2

Question 1-5
Question 1-5
Choose the correct letter,
A,
B, C
or
D
Write the correct letter in boxes 27-31 on your answer sheet
1. What does the writer tell US about people with tone deafness (amusia) in the first
paragraph?
A
They usually have hearing problems
B
Some can play a musical instrument very well
C
Some may be able to sing well-known melodies
D
They have several inabilities in regard to music
2. What is
the writer doing in the second paragraph?
A
outlining some of factors that cause amusia
B
summarising some findings about people with amusia
C
suggesting that people with amusia are disadvantaged
D
comparing the sing ability of amusia with their sense
3. What does
the writer say about the relationship between language ability
and musical ability?
A
People who are unable to speak can sometimes sing
B
People with amusia usually have language problems too
C
Speakers of tonal languages like Chinese rarely have amusia
D
People with amusia have difficulty recognizing people by
their voices
4. In the
third paragraph, the writer notes that most amusics are able to
A
learn how to sing in tune
B
identify a song by its tune
C
distinguish a sad tone from a happy tune
D
recognise when a singer is not sing in tune
5. What is the writer doing in the fourth paragraph?
A
claiming that amusics have problems in the auditory cortex
B
outlining progress in understanding the brains of amusics
C
proving that amuisa is located in the temporal lobes
D
explaining why studies of hearing are difficult

Choose the correct letter, A, B, C or D$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('72b2fb9f-9c3e-57b8-8fb6-c1f3386b6ba9', '6f01ca37-9eb5-5354-bf44-7e392fab2063', 3, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 3

Question 1-5
Question 1-5
Choose the correct letter,
A,
B, C
or
D
Write the correct letter in boxes 27-31 on your answer sheet
1. What does the writer tell US about people with tone deafness (amusia) in the first
paragraph?
A
They usually have hearing problems
B
Some can play a musical instrument very well
C
Some may be able to sing well-known melodies
D
They have several inabilities in regard to music
2. What is
the writer doing in the second paragraph?
A
outlining some of factors that cause amusia
B
summarising some findings about people with amusia
C
suggesting that people with amusia are disadvantaged
D
comparing the sing ability of amusia with their sense
3. What does
the writer say about the relationship between language ability
and musical ability?
A
People who are unable to speak can sometimes sing
B
People with amusia usually have language problems too
C
Speakers of tonal languages like Chinese rarely have amusia
D
People with amusia have difficulty recognizing people by
their voices
4. In the
third paragraph, the writer notes that most amusics are able to
A
learn how to sing in tune
B
identify a song by its tune
C
distinguish a sad tone from a happy tune
D
recognise when a singer is not sing in tune
5. What is the writer doing in the fourth paragraph?
A
claiming that amusics have problems in the auditory cortex
B
outlining progress in understanding the brains of amusics
C
proving that amuisa is located in the temporal lobes
D
explaining why studies of hearing are difficult

Choose the correct letter, A, B, C or D$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('241dac02-2b05-56a7-b3fe-e6bbdf184a73', '6f01ca37-9eb5-5354-bf44-7e392fab2063', 4, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, $md$### Question 4

Question 1-5
Question 1-5
Choose the correct letter,
A,
B, C
or
D
Write the correct letter in boxes 27-31 on your answer sheet
1. What does the writer tell US about people with tone deafness (amusia) in the first
paragraph?
A
They usually have hearing problems
B
Some can play a musical instrument very well
C
Some may be able to sing well-known melodies
D
They have several inabilities in regard to music
2. What is
the writer doing in the second paragraph?
A
outlining some of factors that cause amusia
B
summarising some findings about people with amusia
C
suggesting that people with amusia are disadvantaged
D
comparing the sing ability of amusia with their sense
3. What does
the writer say about the relationship between language ability
and musical ability?
A
People who are unable to speak can sometimes sing
B
People with amusia usually have language problems too
C
Speakers of tonal languages like Chinese rarely have amusia
D
People with amusia have difficulty recognizing people by
their voices
4. In the
third paragraph, the writer notes that most amusics are able to
A
learn how to sing in tune
B
identify a song by its tune
C
distinguish a sad tone from a happy tune
D
recognise when a singer is not sing in tune
5. What is the writer doing in the fourth paragraph?
A
claiming that amusics have problems in the auditory cortex
B
outlining progress in understanding the brains of amusics
C
proving that amuisa is located in the temporal lobes
D
explaining why studies of hearing are difficult

Choose the correct letter, A, B, C or D$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('50d1b050-7f51-5eb3-ad55-fe7af606fc26', '6f01ca37-9eb5-5354-bf44-7e392fab2063', 5, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 5

Question 1-5
Question 1-5
Choose the correct letter,
A,
B, C
or
D
Write the correct letter in boxes 27-31 on your answer sheet
1. What does the writer tell US about people with tone deafness (amusia) in the first
paragraph?
A
They usually have hearing problems
B
Some can play a musical instrument very well
C
Some may be able to sing well-known melodies
D
They have several inabilities in regard to music
2. What is
the writer doing in the second paragraph?
A
outlining some of factors that cause amusia
B
summarising some findings about people with amusia
C
suggesting that people with amusia are disadvantaged
D
comparing the sing ability of amusia with their sense
3. What does
the writer say about the relationship between language ability
and musical ability?
A
People who are unable to speak can sometimes sing
B
People with amusia usually have language problems too
C
Speakers of tonal languages like Chinese rarely have amusia
D
People with amusia have difficulty recognizing people by
their voices
4. In the
third paragraph, the writer notes that most amusics are able to
A
learn how to sing in tune
B
identify a song by its tune
C
distinguish a sad tone from a happy tune
D
recognise when a singer is not sing in tune
5. What is the writer doing in the fourth paragraph?
A
claiming that amusics have problems in the auditory cortex
B
outlining progress in understanding the brains of amusics
C
proving that amuisa is located in the temporal lobes
D
explaining why studies of hearing are difficult

Choose the correct letter, A, B, C or D$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('cf14e1e0-f897-53a3-bc93-3bd3d06b0bd3', '6f01ca37-9eb5-5354-bf44-7e392fab2063', 6, 'YES_NO_NOT_GIVEN', 'READING', 3, $md$### Question 6

Question 6-9
Question 6-9
Do the following statements agree with the views of the writer in Reading Passage?
In boxes 6-9 on your answer sheet, write
YES
if the statement agrees with the claims of the writer
NO
if the statement contradicts the claims of the writer
NOT GIVEN
if it is impossible to say what the writer thinks about this
6
Perezt's research suggesting that amusia is a disorder is convincing.
7
People with musical ability are happier than those without this ability.
8
It is inappropriate to consider amusia as real disorder.
9
People with amusia often have bad handwriting.

6 ____ Perezt's research suggesting that amusia is a disorder is convincing.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b45ba57b-6f47-5adb-9cc4-ae621854df24', 'cf14e1e0-f897-53a3-bc93-3bd3d06b0bd3', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('425ad114-7707-52ee-b72c-5ae3d1495523', 'cf14e1e0-f897-53a3-bc93-3bd3d06b0bd3', 2, $md$NO$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4b13a363-5fc9-581a-b041-e4863251a422', 'cf14e1e0-f897-53a3-bc93-3bd3d06b0bd3', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('ae9c75d7-4b1b-56ed-895e-768c90304076', '6f01ca37-9eb5-5354-bf44-7e392fab2063', 7, 'YES_NO_NOT_GIVEN', 'READING', 3, $md$### Question 7

Question 6-9
Question 6-9
Do the following statements agree with the views of the writer in Reading Passage?
In boxes 6-9 on your answer sheet, write
YES
if the statement agrees with the claims of the writer
NO
if the statement contradicts the claims of the writer
NOT GIVEN
if it is impossible to say what the writer thinks about this
6
Perezt's research suggesting that amusia is a disorder is convincing.
7
People with musical ability are happier than those without this ability.
8
It is inappropriate to consider amusia as real disorder.
9
People with amusia often have bad handwriting.

7 ____ People with musical ability are happier than those without this ability.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('325a90a8-b58c-5ca9-a916-974ba397ccf6', 'ae9c75d7-4b1b-56ed-895e-768c90304076', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bb73c70c-7f08-5a7b-854a-809a7b489ed8', 'ae9c75d7-4b1b-56ed-895e-768c90304076', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('87ff2fac-ca14-5d30-9226-e1c3210f5910', 'ae9c75d7-4b1b-56ed-895e-768c90304076', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('791571e2-c98f-576c-ac96-6d0dd95ead93', '6f01ca37-9eb5-5354-bf44-7e392fab2063', 8, 'YES_NO_NOT_GIVEN', 'READING', 3, $md$### Question 8

Question 6-9
Question 6-9
Do the following statements agree with the views of the writer in Reading Passage?
In boxes 6-9 on your answer sheet, write
YES
if the statement agrees with the claims of the writer
NO
if the statement contradicts the claims of the writer
NOT GIVEN
if it is impossible to say what the writer thinks about this
6
Perezt's research suggesting that amusia is a disorder is convincing.
7
People with musical ability are happier than those without this ability.
8
It is inappropriate to consider amusia as real disorder.
9
People with amusia often have bad handwriting.

8 ____ It is inappropriate to consider amusia as real disorder.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f89c0179-1867-56f8-9d67-5841aed53431', '791571e2-c98f-576c-ac96-6d0dd95ead93', 1, $md$YES$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a71011c6-3b2e-52ba-b8ef-9089b1726307', '791571e2-c98f-576c-ac96-6d0dd95ead93', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('167cb685-aae0-56bd-8b8f-e7f890d2ad0c', '791571e2-c98f-576c-ac96-6d0dd95ead93', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('a713097c-3b84-5dee-b5d3-30bdf636f43c', '6f01ca37-9eb5-5354-bf44-7e392fab2063', 9, 'YES_NO_NOT_GIVEN', 'READING', 3, $md$### Question 9

Question 6-9
Question 6-9
Do the following statements agree with the views of the writer in Reading Passage?
In boxes 6-9 on your answer sheet, write
YES
if the statement agrees with the claims of the writer
NO
if the statement contradicts the claims of the writer
NOT GIVEN
if it is impossible to say what the writer thinks about this
6
Perezt's research suggesting that amusia is a disorder is convincing.
7
People with musical ability are happier than those without this ability.
8
It is inappropriate to consider amusia as real disorder.
9
People with amusia often have bad handwriting.

9 ____ People with amusia often have bad handwriting.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d4364f5e-f18a-5935-b436-8af434841115', 'a713097c-3b84-5dee-b5d3-30bdf636f43c', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0edaf85c-78fa-53da-9270-573d70f29eb5', 'a713097c-3b84-5dee-b5d3-30bdf636f43c', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('eb67c239-fbde-5b27-9af7-27c93c99bb36', 'a713097c-3b84-5dee-b5d3-30bdf636f43c', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('dce7dbfe-a56c-5013-ad49-394313bf3952', '6f01ca37-9eb5-5354-bf44-7e392fab2063', 10, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 10

Question 10-14
Question 10-14
Complete each
sentence with the correct ending, A-H below
Write the correct
letter, A-H in boxes 10-14 on your answer sheet
10
The reason
why some people are born with amusia is
11
One of the
difficulties amusia experience is
12
For amusia,
discrimination of meaning in speech is
13
Certain
reactions in the brain of an amusia are
14
In most
cultures, musical ability is
A
an inability to hear when spoken language rises and falls.
B
considered to be desirable.
C
an inability to follow the beat of music.
D
not a problem.
E
not yet well understood.
F
a result of injury to the mother.
G
more marked that with other people.
H
associated with intelligence.

10 ____ The reason why some people are born with amusia is$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('af2b7275-a0db-570b-9562-1daa0d6d2a40', '6f01ca37-9eb5-5354-bf44-7e392fab2063', 11, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 11

Question 10-14
Question 10-14
Complete each
sentence with the correct ending, A-H below
Write the correct
letter, A-H in boxes 10-14 on your answer sheet
10
The reason
why some people are born with amusia is
11
One of the
difficulties amusia experience is
12
For amusia,
discrimination of meaning in speech is
13
Certain
reactions in the brain of an amusia are
14
In most
cultures, musical ability is
A
an inability to hear when spoken language rises and falls.
B
considered to be desirable.
C
an inability to follow the beat of music.
D
not a problem.
E
not yet well understood.
F
a result of injury to the mother.
G
more marked that with other people.
H
associated with intelligence.

11 ____ One of the difficulties amusia experience is$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('f16feaef-f637-5d94-8c19-4ff0542ffea4', '6f01ca37-9eb5-5354-bf44-7e392fab2063', 12, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 12

Question 10-14
Question 10-14
Complete each
sentence with the correct ending, A-H below
Write the correct
letter, A-H in boxes 10-14 on your answer sheet
10
The reason
why some people are born with amusia is
11
One of the
difficulties amusia experience is
12
For amusia,
discrimination of meaning in speech is
13
Certain
reactions in the brain of an amusia are
14
In most
cultures, musical ability is
A
an inability to hear when spoken language rises and falls.
B
considered to be desirable.
C
an inability to follow the beat of music.
D
not a problem.
E
not yet well understood.
F
a result of injury to the mother.
G
more marked that with other people.
H
associated with intelligence.

12 ____ For amusia, discrimination of meaning in speech is$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('1af6951e-07a9-56fa-a951-b819b094eadb', '6f01ca37-9eb5-5354-bf44-7e392fab2063', 13, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 13

Question 10-14
Question 10-14
Complete each
sentence with the correct ending, A-H below
Write the correct
letter, A-H in boxes 10-14 on your answer sheet
10
The reason
why some people are born with amusia is
11
One of the
difficulties amusia experience is
12
For amusia,
discrimination of meaning in speech is
13
Certain
reactions in the brain of an amusia are
14
In most
cultures, musical ability is
A
an inability to hear when spoken language rises and falls.
B
considered to be desirable.
C
an inability to follow the beat of music.
D
not a problem.
E
not yet well understood.
F
a result of injury to the mother.
G
more marked that with other people.
H
associated with intelligence.

13 ____ Certain reactions in the brain of an amusia are$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('307a34ce-a05c-5520-bf0d-318069b0abd6', '6f01ca37-9eb5-5354-bf44-7e392fab2063', 14, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 14

Question 10-14
Question 10-14
Complete each
sentence with the correct ending, A-H below
Write the correct
letter, A-H in boxes 10-14 on your answer sheet
10
The reason
why some people are born with amusia is
11
One of the
difficulties amusia experience is
12
For amusia,
discrimination of meaning in speech is
13
Certain
reactions in the brain of an amusia are
14
In most
cultures, musical ability is
A
an inability to hear when spoken language rises and falls.
B
considered to be desirable.
C
an inability to follow the beat of music.
D
not a problem.
E
not yet well understood.
F
a result of injury to the mother.
G
more marked that with other people.
H
associated with intelligence.

14 ____ In most cultures, musical ability is$md$, NULL);

COMMIT;
