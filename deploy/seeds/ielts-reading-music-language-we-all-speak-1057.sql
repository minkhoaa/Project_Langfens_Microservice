BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-music-language-we-all-speak-1057'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-music-language-we-all-speak-1057';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-music-language-we-all-speak-1057';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-music-language-we-all-speak-1057';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('3fe76d4f-a9a9-5983-85f2-fe540412f4c7', 'ielts-reading-music-language-we-all-speak-1057', $t$Music: Language We All Speak$t$, $md$## Music: Language We All Speak

Nguồn:
- Test: https://mini-ielts.com/1057/reading/music-language-we-all-speak
- Solution: https://mini-ielts.com/1057/view-solution/reading/music-language-we-all-speak$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('d8155a67-08a7-5b72-b428-bee6fd2da136', '3fe76d4f-a9a9-5983-85f2-fe540412f4c7', 1, $t$Reading — Music: Language We All Speak$t$, $md$Read the passage and answer questions **1–14**.

### Passage: Music: Language We All Speak

Section A - Music and language contrasted

Music is one of the human species' relatively few universal abilities. Without formal training, any individual, from Stone Age tribesman to suburban teenager, has the ability to recognise music and, in some fashion, to make it. Why this should be so is a mystery. After all, music isn't necessary for getting through the day, and if it aids in reproduction, it does so only in highly indirect ways. Language, by contrast, is also everywhere - but for reasons that are more obvious . With language, you and the members of your tribe can organise a migration across Africa, build reed boats and cross the seas, and communicate at night even when you can't see each other. Modern culture, in all its technological extravagance, springs directly from the human talent for manipulating symbols and syntax.

Scientists have always been intrigued by the connection between music and language. Yet over the years, words and melody have acquired a vastly different status in the lab and the seminar room. While language has long been considered essential to unlocking the mechanisms of human intelligence, music is generally treated as an evolutionary frippery - mere "auditory cheesecake", as the Harvard cognitive scientist Steven Pinker puts it .

Section B - Look back at some of the historical theories

But thanks to a decade-long wave of neuroscience research, that tune is changing. A flurry of recent publications suggests that language and music may equally be able to tell us who we are and where we're from - not just emotionally, but biologically. In July, the journal Nature Neuroscience devoted a special issue to the topic. And in an article in the 6 August issue of the Journal of Neuroscience, David Schwartz, Catherine Howe, and Dale Purves of Duke University argued that the sounds of music and the sounds of language are intricately connected .

To grasp the originality of this idea, it's necessary to realise two things about how music has traditionally been understood. First, musicologists have long emphasised that while each culture stamps a special identity onto its music, music itself has some universal qualities . For example, in virtually all cultures, sound is divided into some or all of the 12 intervals that make up the chromatic scale -that is, the scale represented by the keys on a piano. For centuries, observers have attributed this preference for certain combinations of tones to the mathematical properties of sound itself.

Some 2,500 years ago, Pythagoras was the first to note a direct relationship between the harmoniousness of a tone combination and the physical dimensions of the object that produced it . For example, a plucked string will always play an octave lower than a similar string half its size, and a fifth lower than a similar string two thirds its length. This link between simple ratios and harmony has influenced music theory ever since.

Section C - Current research on music

This music-is-math idea is often accompanied by the notion that music, formally speaking at least, exists apart from the world in which it was created. Writing recently in The New York Review of Books, pianist and critic Charles Rosen discussed the long-standing notion that while painting and sculpture reproduce at least some aspects of the natural world, and writing describes thoughts and feelings we are all familiar with, music is entirely abstracted from the world in which we live . Neither idea is right, according to David Schwartz and his colleagues. Human musical preferences are fundamentally shaped not by elegant algorithms or ratios but by the messy sounds of real life, and of speech in particular – which in turn is shaped by our evolutionary heritage. "The explanation of music, like the explanation of any product of the mind, must be rooted in biology, not in numbers per se," says Schwartz.

Schwartz, Howe, and Purves analysed a vast selection of speech sounds from a variety of languages to reveal the underlying patterns common to all utterances. In order to focus only on the raw sounds, they discarded all theories about speech and meaning, and sliced sentences into random bites. Using a database of over 100,000 brief segments of speech, they noted which frequency had the greatest emphasis in each sound. The resulting set of frequencies, they discovered, corresponded closely to the chromatic scale. In short, the building blocks of music are to be found in speech.

Far from being abstract, music presents a strange analogue to the patterns created by the sounds of speech. "Music, like visual arts, is rooted in our experience of the natural world," says Schwartz. "It emulates our sound environment in the way that visual arts emulate the visual environment." In music we hear the echo of our basic sound-making instrument - the vocal tract. The explanation for human music is simpler still than Pythagoras's mathematical equations: We like the sounds that are familiar to us - specifically, we like the sounds that remind us of us.

This brings up some chicken-or-egg evolutionary questions. It may be that music imitates speech directly, the researchers say, in which case it would seem that language evolved first. It's also conceivable that music came first and language is in effect an imitation of song - that in everyday speech we hit the musical notes we especially like. Alternately, it may be that music imitates the general products of the human sound-making system, which just happens to be mostly speech. "We can't know this," says Schwartz. "What we do know is that they both come from the same system, and it is this that shapes our preferences."

Section D - Communication in music with animals

Schwartz's study also casts light on the long-running question of whether animals understand or appreciate music. Despite the apparent abundance of "music" in the natural world - birdsong, whalesong, wolf howls, synchronised chimpanzee hooting - previous studies have found that many laboratory animals don't show a great affinity for the human variety of music making .

Marc Hauser and Josh McDermott of Harvard argued in the July issue of Nature Neuroscience that animals don't create or perceive music the way we do. The fact that laboratory monkeys can show recognition of human tunes is evidence , they say, of shared general features of the auditory system, not any specific chimpanzee musical ability. As for birds, those most musical beasts, they generally recognise their own tunes - a narrow repertoire - but don't generate novel melodies like we do . There are no avian Mozarts.

But what's been played to animals, Schwartz notes, is human music. If animals evolve preferences for sound as we do - based upon the soundscape in which they live - then their "music" would be fundamentally different from ours. In the same way our scales derive from human utterances, a cat's idea of a good tune would derive from yowls and meows. To demonstrate that animals don't appreciate sound the way we do, we'd need evidence that they don't respond to "music" constructed from their own sound environment.

Section E - Are we genetically designed for music?

No matter how the connection between language and music is parsed, what is apparent is that our sense of music, even our love for it, is as deeply rooted in our biology and in our brains as language is. This is most obvious with babies, says Sandra Trehub at the University of Toronto, who also published a paper in the Nature Neuroscience special issue.

For babies, music and speech are on a continuum. Mothers use musical speech to "regulate infants' emotional states", Trehub says. Regardless of what language they speak, the voice all mothers use with babies is the same: "something between speech and song". This kind of communication "puts the baby in a trancelike state, which may proceed to sleep or extended periods of rapture". So if the babies of the world could understand the latest research on language and music, they probably wouldn't be very surprised. The upshot, says , is that music may be even more of a necessity than we realise .$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('d69ad93a-f7b0-5bb9-bfed-6a09cd7a0df1', 'd8155a67-08a7-5b72-b428-bee6fd2da136', 1, 'MATCHING_HEADING', 'READING', 2, $md$### Question 1

Questions 1-5
Questions 1-5
Reading Passage has five sections
A-E
.
Choose the correct heading for each section from the list of headings below.
Write the correct number
i-viii
in boxes
1-5
on your answer sheet.
1
Section A
Locate
2
Section B
Locate
3
Section C
Locate
4
Section D
Locate
5
Section E
Locate
List of Headings
i.
Communication in music with animals
ii.
New discoveries on animal music
iii.
Music and language contrasted
iv.
Current research on music
v.
Music is beneficial for infants.
vi.
Music transcends cultures.
vii.
Look back at some of the historical theories
viii.
Are we genetically designed for music?

1 ____ Section A Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('654ab398-4655-5031-a4eb-7f1cae9e3c17', 'd69ad93a-f7b0-5bb9-bfed-6a09cd7a0df1', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('517fbc26-cb6c-5883-94d7-bf11bfb253a0', 'd69ad93a-f7b0-5bb9-bfed-6a09cd7a0df1', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('aa2fc6c7-324d-5528-97e2-71de0a093e31', 'd69ad93a-f7b0-5bb9-bfed-6a09cd7a0df1', 3, $md$iii$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0d154238-157c-55af-bcad-f3d30d2b7105', 'd69ad93a-f7b0-5bb9-bfed-6a09cd7a0df1', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d5b29f81-860b-54b5-8f6d-6e31067f6e91', 'd69ad93a-f7b0-5bb9-bfed-6a09cd7a0df1', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a63e623e-91e7-5d69-9cbd-ca62cb7f9798', 'd69ad93a-f7b0-5bb9-bfed-6a09cd7a0df1', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8c1a3e26-e062-5b1b-94ac-f6d1746bbe84', 'd69ad93a-f7b0-5bb9-bfed-6a09cd7a0df1', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3c452052-9bc9-52a8-814e-cd0d3288debe', 'd69ad93a-f7b0-5bb9-bfed-6a09cd7a0df1', 8, $md$viii$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('564b1b45-65a2-5e42-99ca-c1588251dcf1', 'd8155a67-08a7-5b72-b428-bee6fd2da136', 2, 'MATCHING_HEADING', 'READING', 2, $md$### Question 2

Questions 1-5
Questions 1-5
Reading Passage has five sections
A-E
.
Choose the correct heading for each section from the list of headings below.
Write the correct number
i-viii
in boxes
1-5
on your answer sheet.
1
Section A
Locate
2
Section B
Locate
3
Section C
Locate
4
Section D
Locate
5
Section E
Locate
List of Headings
i.
Communication in music with animals
ii.
New discoveries on animal music
iii.
Music and language contrasted
iv.
Current research on music
v.
Music is beneficial for infants.
vi.
Music transcends cultures.
vii.
Look back at some of the historical theories
viii.
Are we genetically designed for music?

2 ____ Section B Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1c66c340-4869-53aa-9075-1645a8c1c7fe', '564b1b45-65a2-5e42-99ca-c1588251dcf1', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f81d6cb7-0d0f-5b8c-a758-7cccb05a87a7', '564b1b45-65a2-5e42-99ca-c1588251dcf1', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d730b938-2ce6-5b7d-ab3e-460565a5cd77', '564b1b45-65a2-5e42-99ca-c1588251dcf1', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d82a6cc7-2bf6-53ac-a2a1-60a5ba09dfa1', '564b1b45-65a2-5e42-99ca-c1588251dcf1', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('82de1bb1-568c-5fb1-8d8b-17dcaed4906e', '564b1b45-65a2-5e42-99ca-c1588251dcf1', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('504b3968-bdc0-5777-9f23-f44cbaac4725', '564b1b45-65a2-5e42-99ca-c1588251dcf1', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f94cc1e2-b04d-56f3-a585-f172f99d65d7', '564b1b45-65a2-5e42-99ca-c1588251dcf1', 7, $md$vii$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d4201571-31c1-5dcf-af0f-3473af28b9e1', '564b1b45-65a2-5e42-99ca-c1588251dcf1', 8, $md$viii$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('9c758ceb-9dea-5ec6-bda3-779eab05e2aa', 'd8155a67-08a7-5b72-b428-bee6fd2da136', 3, 'MATCHING_HEADING', 'READING', 2, $md$### Question 3

Questions 1-5
Questions 1-5
Reading Passage has five sections
A-E
.
Choose the correct heading for each section from the list of headings below.
Write the correct number
i-viii
in boxes
1-5
on your answer sheet.
1
Section A
Locate
2
Section B
Locate
3
Section C
Locate
4
Section D
Locate
5
Section E
Locate
List of Headings
i.
Communication in music with animals
ii.
New discoveries on animal music
iii.
Music and language contrasted
iv.
Current research on music
v.
Music is beneficial for infants.
vi.
Music transcends cultures.
vii.
Look back at some of the historical theories
viii.
Are we genetically designed for music?

3 ____ Section C Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bba67ad3-89ea-5548-8662-f82837b281a2', '9c758ceb-9dea-5ec6-bda3-779eab05e2aa', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('13eb0bf5-4945-52e8-be10-a067fd109c56', '9c758ceb-9dea-5ec6-bda3-779eab05e2aa', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('02c38131-f456-5498-9df7-750711c6caf5', '9c758ceb-9dea-5ec6-bda3-779eab05e2aa', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('80c69496-6811-5346-83f6-ce898e8ef101', '9c758ceb-9dea-5ec6-bda3-779eab05e2aa', 4, $md$iv$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('82059757-ea44-5536-88b7-7fdaafe7c5f8', '9c758ceb-9dea-5ec6-bda3-779eab05e2aa', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2b0e8d47-d34f-5fa1-ae49-04c8a8fc0709', '9c758ceb-9dea-5ec6-bda3-779eab05e2aa', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('309a6238-a860-5609-a685-7665b993f68e', '9c758ceb-9dea-5ec6-bda3-779eab05e2aa', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f534abcb-c21b-5cd7-a87f-7ce695f0e544', '9c758ceb-9dea-5ec6-bda3-779eab05e2aa', 8, $md$viii$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('d62a2edc-07c2-50dd-8b15-69bd54eff2a6', 'd8155a67-08a7-5b72-b428-bee6fd2da136', 4, 'MATCHING_HEADING', 'READING', 2, $md$### Question 4

Questions 1-5
Questions 1-5
Reading Passage has five sections
A-E
.
Choose the correct heading for each section from the list of headings below.
Write the correct number
i-viii
in boxes
1-5
on your answer sheet.
1
Section A
Locate
2
Section B
Locate
3
Section C
Locate
4
Section D
Locate
5
Section E
Locate
List of Headings
i.
Communication in music with animals
ii.
New discoveries on animal music
iii.
Music and language contrasted
iv.
Current research on music
v.
Music is beneficial for infants.
vi.
Music transcends cultures.
vii.
Look back at some of the historical theories
viii.
Are we genetically designed for music?

4 ____ Section D Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7f650ae6-5ec0-56e0-b899-c1cbdbfc260d', 'd62a2edc-07c2-50dd-8b15-69bd54eff2a6', 1, $md$i$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d7f861db-33d3-51f2-9213-ee507a190022', 'd62a2edc-07c2-50dd-8b15-69bd54eff2a6', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2745ee98-bedc-55e8-b1a2-4429f6c59d2b', 'd62a2edc-07c2-50dd-8b15-69bd54eff2a6', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3f3634b5-df70-5f3d-9bae-0da0452defab', 'd62a2edc-07c2-50dd-8b15-69bd54eff2a6', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e0e2647c-a170-5a9b-9163-32f2802eb8c1', 'd62a2edc-07c2-50dd-8b15-69bd54eff2a6', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('69938aa3-9821-5099-944d-b1fa581608bc', 'd62a2edc-07c2-50dd-8b15-69bd54eff2a6', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8af766dc-ff1e-512a-8626-67be770ed6e5', 'd62a2edc-07c2-50dd-8b15-69bd54eff2a6', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('33e7aaec-1656-5ade-aa31-e5c313f69125', 'd62a2edc-07c2-50dd-8b15-69bd54eff2a6', 8, $md$viii$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('044d48fa-40f8-5cdc-84b7-3fe899083898', 'd8155a67-08a7-5b72-b428-bee6fd2da136', 5, 'MATCHING_HEADING', 'READING', 3, $md$### Question 5

Questions 1-5
Questions 1-5
Reading Passage has five sections
A-E
.
Choose the correct heading for each section from the list of headings below.
Write the correct number
i-viii
in boxes
1-5
on your answer sheet.
1
Section A
Locate
2
Section B
Locate
3
Section C
Locate
4
Section D
Locate
5
Section E
Locate
List of Headings
i.
Communication in music with animals
ii.
New discoveries on animal music
iii.
Music and language contrasted
iv.
Current research on music
v.
Music is beneficial for infants.
vi.
Music transcends cultures.
vii.
Look back at some of the historical theories
viii.
Are we genetically designed for music?

5 ____ Section E Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ef85a5eb-a325-5168-85f4-993bda1c24e0', '044d48fa-40f8-5cdc-84b7-3fe899083898', 1, $md$i$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4e587e17-f34d-564e-9671-dd163ffd09b7', '044d48fa-40f8-5cdc-84b7-3fe899083898', 2, $md$ii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('da240981-b310-5bae-83ae-790f7cc59323', '044d48fa-40f8-5cdc-84b7-3fe899083898', 3, $md$iii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2a26d95f-5849-5e0e-b88b-65c034f5c38b', '044d48fa-40f8-5cdc-84b7-3fe899083898', 4, $md$iv$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9506be37-8eee-52df-960c-73264c1ba2ab', '044d48fa-40f8-5cdc-84b7-3fe899083898', 5, $md$v$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a77fb925-430b-5745-9149-fe16f33dc175', '044d48fa-40f8-5cdc-84b7-3fe899083898', 6, $md$vi$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('38d0bb35-4875-5870-aa29-16c940bf5158', '044d48fa-40f8-5cdc-84b7-3fe899083898', 7, $md$vii$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('533d1130-e6e3-5d09-8aaa-382e3c02884f', '044d48fa-40f8-5cdc-84b7-3fe899083898', 8, $md$viii$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('2d090f62-d4a2-58aa-82a4-59094c7eaaa5', 'd8155a67-08a7-5b72-b428-bee6fd2da136', 6, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 6

Questions 6-12
Questions 6-12
Look at the following people (Questions
6-12
) and the list of statements below.
Match each person with the correct statement.
Write the correct letter
A-G
in boxes
6-12
on your answer sheet.
6
Steven Pinker
Locate
7
Musicologists
Locate
8
Greek philosopher Pythagoras
Locate
9
Schwartz, Howe, and Purves
Locate
10
Marc Hauser and Josh McDermott
Locate
11
Charles Rosen
Locate
12
Sandra Trehub
Locate
List of Statements
A
Music exists outside of the world it is created in.
B
Music has a universal character despite cultural influences on it.
C
Music is a necessity for humans.
D
Music preference is related to the surrounding influences.
E
He discovered the mathematical basis of music.
F
Music doesn't enjoy the same status of research interest as language.
G
Humans and monkeys have similar traits in perceiving sound.

6 ____ Steven Pinker Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('049c2f8c-40a4-5288-9d1b-1168148f761d', '2d090f62-d4a2-58aa-82a4-59094c7eaaa5', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7ec5e5d1-5564-59d6-b3dc-245717cd8f44', '2d090f62-d4a2-58aa-82a4-59094c7eaaa5', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b8e46440-b0a7-5dde-89d5-7b5a42d23d1c', '2d090f62-d4a2-58aa-82a4-59094c7eaaa5', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('88181b05-4341-59c6-985f-ec763df1d294', '2d090f62-d4a2-58aa-82a4-59094c7eaaa5', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4e44f258-cfa9-5222-93a4-3ddd6289571d', '2d090f62-d4a2-58aa-82a4-59094c7eaaa5', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6e1d4263-2659-5a6b-a7fc-877371ecf6af', '2d090f62-d4a2-58aa-82a4-59094c7eaaa5', 6, $md$F$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('794de72e-555d-5bf6-be16-d81d0a1d5dac', '2d090f62-d4a2-58aa-82a4-59094c7eaaa5', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('be6ccba1-82c4-566d-a901-1eeb87ed9feb', 'd8155a67-08a7-5b72-b428-bee6fd2da136', 7, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 7

Questions 6-12
Questions 6-12
Look at the following people (Questions
6-12
) and the list of statements below.
Match each person with the correct statement.
Write the correct letter
A-G
in boxes
6-12
on your answer sheet.
6
Steven Pinker
Locate
7
Musicologists
Locate
8
Greek philosopher Pythagoras
Locate
9
Schwartz, Howe, and Purves
Locate
10
Marc Hauser and Josh McDermott
Locate
11
Charles Rosen
Locate
12
Sandra Trehub
Locate
List of Statements
A
Music exists outside of the world it is created in.
B
Music has a universal character despite cultural influences on it.
C
Music is a necessity for humans.
D
Music preference is related to the surrounding influences.
E
He discovered the mathematical basis of music.
F
Music doesn't enjoy the same status of research interest as language.
G
Humans and monkeys have similar traits in perceiving sound.

7 ____ Musicologists Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e945a745-29c9-513e-88f6-ad3913e4cbf2', 'be6ccba1-82c4-566d-a901-1eeb87ed9feb', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9a669eff-1f24-5196-b901-f53ffcef1d51', 'be6ccba1-82c4-566d-a901-1eeb87ed9feb', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b33c3bc0-a0ee-590d-8bd8-7eeede1e98e0', 'be6ccba1-82c4-566d-a901-1eeb87ed9feb', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('eebb56e1-4e5c-5019-b980-0eb0eee43fde', 'be6ccba1-82c4-566d-a901-1eeb87ed9feb', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7be8aba8-a2bc-55e3-a9ac-f224b1d98b1d', 'be6ccba1-82c4-566d-a901-1eeb87ed9feb', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5e7cd70a-2a4f-5a8b-a23f-5eb16e0c0a16', 'be6ccba1-82c4-566d-a901-1eeb87ed9feb', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('26690d82-d56b-509b-93d5-38bad9b6cfc6', 'be6ccba1-82c4-566d-a901-1eeb87ed9feb', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('711a033d-73e6-51d8-8903-fd9718616661', 'd8155a67-08a7-5b72-b428-bee6fd2da136', 8, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 8

Questions 6-12
Questions 6-12
Look at the following people (Questions
6-12
) and the list of statements below.
Match each person with the correct statement.
Write the correct letter
A-G
in boxes
6-12
on your answer sheet.
6
Steven Pinker
Locate
7
Musicologists
Locate
8
Greek philosopher Pythagoras
Locate
9
Schwartz, Howe, and Purves
Locate
10
Marc Hauser and Josh McDermott
Locate
11
Charles Rosen
Locate
12
Sandra Trehub
Locate
List of Statements
A
Music exists outside of the world it is created in.
B
Music has a universal character despite cultural influences on it.
C
Music is a necessity for humans.
D
Music preference is related to the surrounding influences.
E
He discovered the mathematical basis of music.
F
Music doesn't enjoy the same status of research interest as language.
G
Humans and monkeys have similar traits in perceiving sound.

8 ____ Greek philosopher Pythagoras Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8fa47147-f3a3-5577-b06e-a811d045cacd', '711a033d-73e6-51d8-8903-fd9718616661', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8bc3a6be-8fa1-596a-84eb-499828770f7e', '711a033d-73e6-51d8-8903-fd9718616661', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6c9e4033-6365-52b0-be9b-dfead524da23', '711a033d-73e6-51d8-8903-fd9718616661', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3c772680-e6f0-5262-81fc-77c7b8c9a4dd', '711a033d-73e6-51d8-8903-fd9718616661', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d79b0fa5-a7ba-566c-90f1-13b5cff99385', '711a033d-73e6-51d8-8903-fd9718616661', 5, $md$E$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('48714b6e-a0d1-5ddf-8c0b-c54325c96bd1', '711a033d-73e6-51d8-8903-fd9718616661', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0684185b-2bcc-5572-bad9-f7d733b6f776', '711a033d-73e6-51d8-8903-fd9718616661', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('b5ddf086-7df1-57dd-9374-c3e3670f2217', 'd8155a67-08a7-5b72-b428-bee6fd2da136', 9, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 9

Questions 6-12
Questions 6-12
Look at the following people (Questions
6-12
) and the list of statements below.
Match each person with the correct statement.
Write the correct letter
A-G
in boxes
6-12
on your answer sheet.
6
Steven Pinker
Locate
7
Musicologists
Locate
8
Greek philosopher Pythagoras
Locate
9
Schwartz, Howe, and Purves
Locate
10
Marc Hauser and Josh McDermott
Locate
11
Charles Rosen
Locate
12
Sandra Trehub
Locate
List of Statements
A
Music exists outside of the world it is created in.
B
Music has a universal character despite cultural influences on it.
C
Music is a necessity for humans.
D
Music preference is related to the surrounding influences.
E
He discovered the mathematical basis of music.
F
Music doesn't enjoy the same status of research interest as language.
G
Humans and monkeys have similar traits in perceiving sound.

9 ____ Schwartz, Howe, and Purves Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('22b30ec4-caac-548f-af5b-220009afae48', 'b5ddf086-7df1-57dd-9374-c3e3670f2217', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6ecf6499-bae6-5bba-b54d-546d36fe03c4', 'b5ddf086-7df1-57dd-9374-c3e3670f2217', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9c3459f6-1e85-5e13-ad89-3dd83bc27e16', 'b5ddf086-7df1-57dd-9374-c3e3670f2217', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('14cb363b-8474-533b-8387-c519fd6d1220', 'b5ddf086-7df1-57dd-9374-c3e3670f2217', 4, $md$D$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e33f3d92-06a5-584b-874f-4796fafcc8d9', 'b5ddf086-7df1-57dd-9374-c3e3670f2217', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a7268007-3197-5c7a-9cb3-eddb84c08c46', 'b5ddf086-7df1-57dd-9374-c3e3670f2217', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('596c1022-cad8-5217-9f2e-05001788ebe7', 'b5ddf086-7df1-57dd-9374-c3e3670f2217', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('3a84dc32-79a1-5f45-b369-e98bf278eb09', 'd8155a67-08a7-5b72-b428-bee6fd2da136', 10, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 10

Questions 6-12
Questions 6-12
Look at the following people (Questions
6-12
) and the list of statements below.
Match each person with the correct statement.
Write the correct letter
A-G
in boxes
6-12
on your answer sheet.
6
Steven Pinker
Locate
7
Musicologists
Locate
8
Greek philosopher Pythagoras
Locate
9
Schwartz, Howe, and Purves
Locate
10
Marc Hauser and Josh McDermott
Locate
11
Charles Rosen
Locate
12
Sandra Trehub
Locate
List of Statements
A
Music exists outside of the world it is created in.
B
Music has a universal character despite cultural influences on it.
C
Music is a necessity for humans.
D
Music preference is related to the surrounding influences.
E
He discovered the mathematical basis of music.
F
Music doesn't enjoy the same status of research interest as language.
G
Humans and monkeys have similar traits in perceiving sound.

10 ____ Marc Hauser and Josh McDermott Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f6f82945-df85-5285-9b1f-fa7b420cc5e3', '3a84dc32-79a1-5f45-b369-e98bf278eb09', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b43a5527-1451-5362-bec9-42ffbf68beab', '3a84dc32-79a1-5f45-b369-e98bf278eb09', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c2d9d9b4-b8f9-50f9-b630-7d9d34e742ca', '3a84dc32-79a1-5f45-b369-e98bf278eb09', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0acd5873-c2a3-566c-9fb5-4ff2e3a5dfd9', '3a84dc32-79a1-5f45-b369-e98bf278eb09', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f6b1e9e2-98e1-5329-b275-617fbd6cca21', '3a84dc32-79a1-5f45-b369-e98bf278eb09', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('49a643a9-df9b-5bcf-9003-c5ce069196cb', '3a84dc32-79a1-5f45-b369-e98bf278eb09', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('caf677ee-5996-5220-8b2e-cd5d3d14acb8', '3a84dc32-79a1-5f45-b369-e98bf278eb09', 7, $md$G$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('c4f62ac6-78b5-5d99-8243-0af0f2f53479', 'd8155a67-08a7-5b72-b428-bee6fd2da136', 11, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 11

Questions 6-12
Questions 6-12
Look at the following people (Questions
6-12
) and the list of statements below.
Match each person with the correct statement.
Write the correct letter
A-G
in boxes
6-12
on your answer sheet.
6
Steven Pinker
Locate
7
Musicologists
Locate
8
Greek philosopher Pythagoras
Locate
9
Schwartz, Howe, and Purves
Locate
10
Marc Hauser and Josh McDermott
Locate
11
Charles Rosen
Locate
12
Sandra Trehub
Locate
List of Statements
A
Music exists outside of the world it is created in.
B
Music has a universal character despite cultural influences on it.
C
Music is a necessity for humans.
D
Music preference is related to the surrounding influences.
E
He discovered the mathematical basis of music.
F
Music doesn't enjoy the same status of research interest as language.
G
Humans and monkeys have similar traits in perceiving sound.

11 ____ Charles Rosen Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d6785981-97f1-5012-872c-5ed9a2b72760', 'c4f62ac6-78b5-5d99-8243-0af0f2f53479', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('27ee6ecc-a37e-5ab5-9f46-5d3bcc5723a1', 'c4f62ac6-78b5-5d99-8243-0af0f2f53479', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4347de56-0666-5fbe-949a-85b2ebf15c7f', 'c4f62ac6-78b5-5d99-8243-0af0f2f53479', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5a921720-be59-549f-85e7-a422645124ee', 'c4f62ac6-78b5-5d99-8243-0af0f2f53479', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a7d17568-220e-553b-a104-a94937cf1997', 'c4f62ac6-78b5-5d99-8243-0af0f2f53479', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('a7969c72-7327-5fa9-8439-ad229df787b7', 'c4f62ac6-78b5-5d99-8243-0af0f2f53479', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ad83355c-d66a-58e8-a4be-8539dd870455', 'c4f62ac6-78b5-5d99-8243-0af0f2f53479', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('31ed2351-04ea-59e6-b168-a5b1781810f8', 'd8155a67-08a7-5b72-b428-bee6fd2da136', 12, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 12

Questions 6-12
Questions 6-12
Look at the following people (Questions
6-12
) and the list of statements below.
Match each person with the correct statement.
Write the correct letter
A-G
in boxes
6-12
on your answer sheet.
6
Steven Pinker
Locate
7
Musicologists
Locate
8
Greek philosopher Pythagoras
Locate
9
Schwartz, Howe, and Purves
Locate
10
Marc Hauser and Josh McDermott
Locate
11
Charles Rosen
Locate
12
Sandra Trehub
Locate
List of Statements
A
Music exists outside of the world it is created in.
B
Music has a universal character despite cultural influences on it.
C
Music is a necessity for humans.
D
Music preference is related to the surrounding influences.
E
He discovered the mathematical basis of music.
F
Music doesn't enjoy the same status of research interest as language.
G
Humans and monkeys have similar traits in perceiving sound.

12 ____ Sandra Trehub Locate$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4a2068f1-ca42-5d5b-a250-401658f267f4', '31ed2351-04ea-59e6-b168-a5b1781810f8', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c0db9efb-d81f-5b07-ae2f-e6c5c63f1664', '31ed2351-04ea-59e6-b168-a5b1781810f8', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('18adba14-da3d-5e4e-9d16-083dca5121ae', '31ed2351-04ea-59e6-b168-a5b1781810f8', 3, $md$C$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b7c34b6d-e574-5e83-b5e0-f159a5287346', '31ed2351-04ea-59e6-b168-a5b1781810f8', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2bd2b8d7-1111-5c84-91f7-d08c8fd99de8', '31ed2351-04ea-59e6-b168-a5b1781810f8', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('78c398a3-1bd7-536c-a7a3-c33fe99db82e', '31ed2351-04ea-59e6-b168-a5b1781810f8', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('30ee4b00-ce4c-5409-853f-586ae87fe427', '31ed2351-04ea-59e6-b168-a5b1781810f8', 7, $md$G$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('2cf16882-00e2-52ae-b48d-58abd02e08f1', 'd8155a67-08a7-5b72-b428-bee6fd2da136', 13, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 13

Questions 13-14
Questions 13-14
Choose the correct letter
A, B, C
or
D
.
Write your answers in boxes
13-14
on your answer sheet.
13
Why was the study of animal music inconclusive?
A
Animals don’t have the same auditory system as humans.
B
Tests on animal music are limited.
C
Animals can’t make up new tunes.
D
There aren’t enough tests on a wide range of animals.
Locate
14
What is the main theme of this passage?
A
Language and learning
B
The evolution of music
C
The role of music in human society
D
Music for animals

Choose the correct letter A, B, C or D .$md$, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('20715b11-d6d7-581f-9c94-55c9c2b55a9a', 'd8155a67-08a7-5b72-b428-bee6fd2da136', 14, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 14

Questions 13-14
Questions 13-14
Choose the correct letter
A, B, C
or
D
.
Write your answers in boxes
13-14
on your answer sheet.
13
Why was the study of animal music inconclusive?
A
Animals don’t have the same auditory system as humans.
B
Tests on animal music are limited.
C
Animals can’t make up new tunes.
D
There aren’t enough tests on a wide range of animals.
Locate
14
What is the main theme of this passage?
A
Language and learning
B
The evolution of music
C
The role of music in human society
D
Music for animals

Choose the correct letter A, B, C or D .$md$, NULL);

COMMIT;
