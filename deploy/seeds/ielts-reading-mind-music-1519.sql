BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-mind-music-1519'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-mind-music-1519';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-mind-music-1519';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-mind-music-1519';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('dee8feaa-9beb-5ba2-85d7-1240f1cf0229', 'ielts-reading-mind-music-1519', $t$Mind Music$t$, $md$## Mind Music

Nguồn:
- Test: https://mini-ielts.com/1519/reading/mind-music
- Solution: https://mini-ielts.com/1519/view-solution/reading/mind-music$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('58a263e2-7ba9-53b5-afe3-aacd6f585b81', 'dee8feaa-9beb-5ba2-85d7-1240f1cf0229', 1, $t$Reading — Mind Music$t$, $md$Read the passage and answer questions **1–13**.

### Passage: Mind Music

Scientists investigate 'earworms', the music we can't get out of our head

A Ever had a song stuck in your head, playing on an endless loop? Scientists call them

'involuntary musical images', or 'earworms, and a wave of new research is shining light on why they occur and what can be learned from them. Some neuroscientists and cognitive psychologists are studying earworms to explore the mysteries of memory and the part of the brain that is beyond our conscious control. The idea that we have full control over our thought processes is an illusion,' says psychologist Lauren Stewart, who founded the master's program in music, mind and brain at Goldsmiths, University of London, UK, where recent research has taken place. Researchers haven't been able to watch what happens in the brain when earworms occur, because they happen unpredictably. Much of what is known about them comes from surveys, questionnaires, diaries and lab experiments.

B A Goldsmiths study published in the journal Memory and Cognition this year showed that the singing we hear in our heads tends to be true to actual recordings. Researchers had 17 volunteers tap to the beat of any earworm they heard during a four-day period while a device attached to their wrist recorded their movements. The tapping tempos were within 10% of the tempos of the original recordings. Another Goldsmiths study, published this year in Consciousness and Cognition, found that people who report hearing earworms often, and find them most intrusive, have slightly different brain structures, with more gray matter in areas associated with processing emotions.

C Studies also show that the music in our heads often starts playing during times of 'low cognitive load', such as while showering, getting dressed, walking, or doing chores. Dr Stewart likens earworms to 'sonic screen savers' that keep the mind entertained while it is otherwise unoccupied. She and her colleagues tested that theory by having volunteers listen to songs and giving them various tasks afterwards. The volunteers who sat idly for the next five minutes were the most likely to report hearing the music m their heads. Dr Stewart observed that the more challenging the activity, the less likely the volunteers were to hear the music. Diary studies also show songs tend to match people's moods and therefore they are not random. If you are energized and upbeat, an earworm that occurs is likely to be uptempo too.

D Songs the brain fixates on are usually those it has been exposed to recently, surveys show, which is why tunes getting heavy radio play frequently top the earworm charts. Even tunes you may have heard but didn't pay attention to can worm their way into your subconscious, says Ira Hyman, a psychologist at Western Washington University in Bellingham, USA. In an unpublished study there, participants who listened to music while doing other tasks were more likely to report that the songs returned as earworms later on, compared with participants who simply listened.

E Some earworms are just fragments of a song that repeat like a broken record. So, when the mind hits a part of a song it can't remember, it loops back rather than moving on. That could make an earworm even more entrenched, Dr Hyman says. According to a theory known as the Zeigarik effect, named for a Soviet psychologist, Bluma Zeigarnik, unfinished thoughts and activities weigh on the mind more heavily than those that are completed, although experiments exposing students to interrupted songs have yielded mixed results.

F Researchers say they can't pinpoint a spot in the brain where earworms live. Imaging studies by Andrea Halpern at Bucknell University, in Lewisburg, USA, have shown that deliberately imagining music and actually listening to music activate many of the same neurological networks. Dr Halpern's earlier studies showed that when subjects listened to the first few notes of familiar music, areas in the right frontal and superior temporal portions of the brain became activated, along with the supplementary motor area at the top, which is typically involved in remembering sequences. When the same subjects listened to unfamiliar music and were asked to recall it, there was activity in the left frontal portions of the brain instead.

G One factor that makes some songs stick might be repetition. 'Repetition leads to familiarity which leads to anticipation, which is satisfied by hearing the song,' says John Seabrook, author of The Song Machine: Inside the Hit Factory, about how producers pump pop songs full of aural "hooks', the punchy melodic phrases designed to target the brain and leave it wanting more. The researchers are comparing the melodic structure of 100 often-mentioned songs with 100 similarly popular songs that weren't cited as earworms, to assess the difference. Songs with earworm potential appear to share certain features: a repeating pattern of ups and downs in pitch, and an irregular musical interval.

H The researchers plan next to test their results in reverse, and play ringtones from songs of both the earworm and non earworm variety for volunteers several times a day to see which ones get stuck. Drs Stewart and Halper are now working together to recruit survey participants for a study looking at whether people at different stages of life experience earworms differently. 'You can argue that older people might get them more often because they know more songs,' Dr Halpern says. 'But the few responses we have so far indicate that they have earworms less often. It could be that they don't play music as often as younger people do.$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('ea5dd936-d702-539f-90ed-37f3d22a079b', '58a263e2-7ba9-53b5-afe3-aacd6f585b81', 1, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 1

Questions 1-4
Questions 1-4
The reading Passage has eight paragraphs, A-H.
Which paragraph contains the following information?
Write the correct letter, A-H, in boxes 1-4 on your answer sheet.
1
a description of the characteristics common to songs with earworms
2
a justitication for research into earworms
3
a description of the brain's reaction to known and unknown songs
4
details of proposed research into the frequency with which earworms occur indifferent age groups

1 ____ a description of the characteristics common to songs with earworms$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5d62432b-d91e-5ba9-9578-0d377bb05e13', 'ea5dd936-d702-539f-90ed-37f3d22a079b', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('01883cbf-11e2-52d2-8d8f-e7d02c5c47d2', 'ea5dd936-d702-539f-90ed-37f3d22a079b', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('62002b34-cad0-5cec-8e98-6046dac85ba2', 'ea5dd936-d702-539f-90ed-37f3d22a079b', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2ef7a200-e9de-5b61-8d42-1a4227f04ae8', 'ea5dd936-d702-539f-90ed-37f3d22a079b', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b3e5a9e2-cc62-51b0-8219-a6db50fe86d2', 'ea5dd936-d702-539f-90ed-37f3d22a079b', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('09928836-b3da-5a20-a9c9-0a8c9f1705a5', 'ea5dd936-d702-539f-90ed-37f3d22a079b', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cf990141-bf34-5cf3-be3d-51d41bf7cddc', 'ea5dd936-d702-539f-90ed-37f3d22a079b', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6169602c-b73b-564e-90cd-c6b87eeeb05e', 'ea5dd936-d702-539f-90ed-37f3d22a079b', 8, $md$H$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('e1696ef8-fe23-5930-9058-b5461c003775', '58a263e2-7ba9-53b5-afe3-aacd6f585b81', 2, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 2

Questions 1-4
Questions 1-4
The reading Passage has eight paragraphs, A-H.
Which paragraph contains the following information?
Write the correct letter, A-H, in boxes 1-4 on your answer sheet.
1
a description of the characteristics common to songs with earworms
2
a justitication for research into earworms
3
a description of the brain's reaction to known and unknown songs
4
details of proposed research into the frequency with which earworms occur indifferent age groups

2 ____ a justitication for research into earworms$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9dcb548d-d9af-5d3a-8440-21c99c1e121a', 'e1696ef8-fe23-5930-9058-b5461c003775', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('df796eda-b595-52ba-bc7d-7fe6abecd77f', 'e1696ef8-fe23-5930-9058-b5461c003775', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('00f9733b-ce92-5cb9-ad9e-3df688998a09', 'e1696ef8-fe23-5930-9058-b5461c003775', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8f749bf5-f612-507b-a2ad-46554817c608', 'e1696ef8-fe23-5930-9058-b5461c003775', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('74da4169-50b8-5dcc-bba4-51d837314bf2', 'e1696ef8-fe23-5930-9058-b5461c003775', 5, $md$E$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e0e2872f-929d-59ea-befd-169970d7669d', 'e1696ef8-fe23-5930-9058-b5461c003775', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cb37f8b6-ec93-523e-a8e6-95903b6e76ad', 'e1696ef8-fe23-5930-9058-b5461c003775', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('afe087fd-53c4-5149-8740-b0a201abb684', 'e1696ef8-fe23-5930-9058-b5461c003775', 8, $md$H$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('e0512abe-3b93-56cd-8e02-165846e73ecc', '58a263e2-7ba9-53b5-afe3-aacd6f585b81', 3, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 3

Questions 1-4
Questions 1-4
The reading Passage has eight paragraphs, A-H.
Which paragraph contains the following information?
Write the correct letter, A-H, in boxes 1-4 on your answer sheet.
1
a description of the characteristics common to songs with earworms
2
a justitication for research into earworms
3
a description of the brain's reaction to known and unknown songs
4
details of proposed research into the frequency with which earworms occur indifferent age groups

3 ____ a description of the brain's reaction to known and unknown songs$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8ce35cb7-5bb8-524f-8b51-6c59b63ba31d', 'e0512abe-3b93-56cd-8e02-165846e73ecc', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('43861eb2-9189-5ea4-a2b1-9ced4e85f8f8', 'e0512abe-3b93-56cd-8e02-165846e73ecc', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('518119d3-6887-5f3a-b2e2-a11aaa833b32', 'e0512abe-3b93-56cd-8e02-165846e73ecc', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cd9b6aad-be8d-5126-b9c4-9c57e9458c37', 'e0512abe-3b93-56cd-8e02-165846e73ecc', 4, $md$D$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('69526186-e2f2-524a-ac22-ea3beec39efa', 'e0512abe-3b93-56cd-8e02-165846e73ecc', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('eba9e1a9-8ded-5761-a258-e67c724c61b2', 'e0512abe-3b93-56cd-8e02-165846e73ecc', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4c57b83b-8770-5f04-b964-6d5dab75ac8a', 'e0512abe-3b93-56cd-8e02-165846e73ecc', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4a3ad2d3-37a2-57ef-b48b-36719376af41', 'e0512abe-3b93-56cd-8e02-165846e73ecc', 8, $md$H$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('fccced94-afe8-566d-af49-352190070d7c', '58a263e2-7ba9-53b5-afe3-aacd6f585b81', 4, 'MATCHING_INFORMATION', 'READING', 2, $md$### Question 4

Questions 1-4
Questions 1-4
The reading Passage has eight paragraphs, A-H.
Which paragraph contains the following information?
Write the correct letter, A-H, in boxes 1-4 on your answer sheet.
1
a description of the characteristics common to songs with earworms
2
a justitication for research into earworms
3
a description of the brain's reaction to known and unknown songs
4
details of proposed research into the frequency with which earworms occur indifferent age groups

4 ____ details of proposed research into the frequency with which earworms occur indifferent age groups$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7d6d41fa-88d4-5c7d-9c8e-d6c3988c03e5', 'fccced94-afe8-566d-af49-352190070d7c', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1be095f8-f7ed-5fa1-bd3b-35503247f46c', 'fccced94-afe8-566d-af49-352190070d7c', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5b4da3b0-d7a1-5e8d-b9cb-0a824d6bcc3c', 'fccced94-afe8-566d-af49-352190070d7c', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('5ea3d3fb-11b8-5884-91ec-bd581b16a532', 'fccced94-afe8-566d-af49-352190070d7c', 4, $md$D$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('29d9cc00-1b20-5cd3-80d0-021921f3bb88', 'fccced94-afe8-566d-af49-352190070d7c', 5, $md$E$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('733dfe95-e430-5e31-be4a-317d620bd18d', 'fccced94-afe8-566d-af49-352190070d7c', 6, $md$F$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2007e712-175d-56cc-815a-e96df0b21d47', 'fccced94-afe8-566d-af49-352190070d7c', 7, $md$G$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4d0cb779-bb70-5863-84fc-824064eafd9b', 'fccced94-afe8-566d-af49-352190070d7c', 8, $md$H$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('2c6031a7-5108-5ccc-9c61-963b88656087', '58a263e2-7ba9-53b5-afe3-aacd6f585b81', 5, 'SUMMARY_COMPLETION', 'READING', 3, $md$### Question 5

Questions 5-8
Questions 5-8
Complete the summary below.
Choose
ONE WORD ONLY
from the passage for each answer.
Write your answers in boxes 5-8 on your answer sheet.
Goldsmiths study
Researchers from Goldsmiths concluded that the music we imagine in our minds is quite similar to recordings. They proved this by asking volunteers to record the rhythm of music using a monitor on their
5
. Further research has demonstrated that those
who hear earworms more frequently have brains that may deal with
6
differently from other people, Dr Stewart also believes that the brain is
7
by earworms when it is not focused on a task. In fact, a reduction in the occurrence of earworms was found to be directly related to how
8
the task was Interestingly, volunteers' diaries revealed that the songs they heard inside their head reflected their moods, so the choice of music is not accidental.

Researchers from Goldsmiths concluded that the music we imagine in our minds is quite similar to recordings. They proved this by asking volunteers to record the rhythm of music using a monitor on their 5 ____ . Further research has demonstrated that those who hear earworms more frequently have brains that may deal with 6 ____ differently from other people, Dr Stewart also believes that the brain is 7 ____ by earworms when it is not focused on a task. In fact, a reduction in the occurrence of earworms was found to be directly related to how 8 ____ the task was Interestingly, volunteers' diaries revealed that the songs they heard inside their head reflected their moods, so the choice of music is not accidental.$md$, NULL, ARRAY['.*wrist.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('f6318598-65a3-5163-a41d-5aa61bb9c95a', '58a263e2-7ba9-53b5-afe3-aacd6f585b81', 6, 'SUMMARY_COMPLETION', 'READING', 3, $md$### Question 6

Questions 5-8
Questions 5-8
Complete the summary below.
Choose
ONE WORD ONLY
from the passage for each answer.
Write your answers in boxes 5-8 on your answer sheet.
Goldsmiths study
Researchers from Goldsmiths concluded that the music we imagine in our minds is quite similar to recordings. They proved this by asking volunteers to record the rhythm of music using a monitor on their
5
. Further research has demonstrated that those
who hear earworms more frequently have brains that may deal with
6
differently from other people, Dr Stewart also believes that the brain is
7
by earworms when it is not focused on a task. In fact, a reduction in the occurrence of earworms was found to be directly related to how
8
the task was Interestingly, volunteers' diaries revealed that the songs they heard inside their head reflected their moods, so the choice of music is not accidental.

Researchers from Goldsmiths concluded that the music we imagine in our minds is quite similar to recordings. They proved this by asking volunteers to record the rhythm of music using a monitor on their 5 ____ . Further research has demonstrated that those who hear earworms more frequently have brains that may deal with 6 ____ differently from other people, Dr Stewart also believes that the brain is 7 ____ by earworms when it is not focused on a task. In fact, a reduction in the occurrence of earworms was found to be directly related to how 8 ____ the task was Interestingly, volunteers' diaries revealed that the songs they heard inside their head reflected their moods, so the choice of music is not accidental.$md$, NULL, ARRAY['.*wrist.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('c249c6bd-426e-5c9c-bea4-9e9361b40581', '58a263e2-7ba9-53b5-afe3-aacd6f585b81', 7, 'SUMMARY_COMPLETION', 'READING', 3, $md$### Question 7

Questions 5-8
Questions 5-8
Complete the summary below.
Choose
ONE WORD ONLY
from the passage for each answer.
Write your answers in boxes 5-8 on your answer sheet.
Goldsmiths study
Researchers from Goldsmiths concluded that the music we imagine in our minds is quite similar to recordings. They proved this by asking volunteers to record the rhythm of music using a monitor on their
5
. Further research has demonstrated that those
who hear earworms more frequently have brains that may deal with
6
differently from other people, Dr Stewart also believes that the brain is
7
by earworms when it is not focused on a task. In fact, a reduction in the occurrence of earworms was found to be directly related to how
8
the task was Interestingly, volunteers' diaries revealed that the songs they heard inside their head reflected their moods, so the choice of music is not accidental.

Researchers from Goldsmiths concluded that the music we imagine in our minds is quite similar to recordings. They proved this by asking volunteers to record the rhythm of music using a monitor on their 5 ____ . Further research has demonstrated that those who hear earworms more frequently have brains that may deal with 6 ____ differently from other people, Dr Stewart also believes that the brain is 7 ____ by earworms when it is not focused on a task. In fact, a reduction in the occurrence of earworms was found to be directly related to how 8 ____ the task was Interestingly, volunteers' diaries revealed that the songs they heard inside their head reflected their moods, so the choice of music is not accidental.$md$, NULL, ARRAY['.*wrist.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('30e10fd9-b788-51ef-ace7-61d41a70f7eb', '58a263e2-7ba9-53b5-afe3-aacd6f585b81', 8, 'SUMMARY_COMPLETION', 'READING', 3, $md$### Question 8

Questions 5-8
Questions 5-8
Complete the summary below.
Choose
ONE WORD ONLY
from the passage for each answer.
Write your answers in boxes 5-8 on your answer sheet.
Goldsmiths study
Researchers from Goldsmiths concluded that the music we imagine in our minds is quite similar to recordings. They proved this by asking volunteers to record the rhythm of music using a monitor on their
5
. Further research has demonstrated that those
who hear earworms more frequently have brains that may deal with
6
differently from other people, Dr Stewart also believes that the brain is
7
by earworms when it is not focused on a task. In fact, a reduction in the occurrence of earworms was found to be directly related to how
8
the task was Interestingly, volunteers' diaries revealed that the songs they heard inside their head reflected their moods, so the choice of music is not accidental.

Researchers from Goldsmiths concluded that the music we imagine in our minds is quite similar to recordings. They proved this by asking volunteers to record the rhythm of music using a monitor on their 5 ____ . Further research has demonstrated that those who hear earworms more frequently have brains that may deal with 6 ____ differently from other people, Dr Stewart also believes that the brain is 7 ____ by earworms when it is not focused on a task. In fact, a reduction in the occurrence of earworms was found to be directly related to how 8 ____ the task was Interestingly, volunteers' diaries revealed that the songs they heard inside their head reflected their moods, so the choice of music is not accidental.$md$, NULL, ARRAY['.*wrist.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('a1fb0f55-896d-572a-87dc-98a9638d8843', '58a263e2-7ba9-53b5-afe3-aacd6f585b81', 9, 'MULTIPLE_CHOICE_SINGLE', 'READING', 3, $md$### Question 9

Questions 9-13
Questions 9-13
Look at the following statements and the list of researcher below.
Match each statement with the correct person, A, B, C or D.
Write the correct letter. A, B, C or D, in boxes 9-13 on your answer sheet.
NB You may use any letter more than once.
9
Some musicians create music that is intentionally memorable.
10
People are unable to completely regulate how they think.
11
We can remember songs without knowing that we have heard them.
12
Thinking about music has a similar effect on the brain to hearing music.
13
Earworms are more persistent when only a short section of the song is constantly replayed.
List of Researchers
A Lauren Stewart
B Ira Hyman
C Andrea Haiper
D John Seabrook

9 ____ Some musicians create music that is intentionally memorable.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2a4d6824-0dde-5878-9da6-87f32d072c57', 'a1fb0f55-896d-572a-87dc-98a9638d8843', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ebb76188-5c66-5099-ad13-bc3920399d9d', 'a1fb0f55-896d-572a-87dc-98a9638d8843', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6e2d3ea4-cbcb-57f3-afe3-09d7fffc3b62', 'a1fb0f55-896d-572a-87dc-98a9638d8843', 3, $md$C$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('0d9dff8b-59d8-593b-87d7-1c17ece8b804', 'a1fb0f55-896d-572a-87dc-98a9638d8843', 4, $md$D$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('7645bec4-9e36-5892-a287-236ef4b950b4', '58a263e2-7ba9-53b5-afe3-aacd6f585b81', 10, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 10

Questions 9-13
Questions 9-13
Look at the following statements and the list of researcher below.
Match each statement with the correct person, A, B, C or D.
Write the correct letter. A, B, C or D, in boxes 9-13 on your answer sheet.
NB You may use any letter more than once.
9
Some musicians create music that is intentionally memorable.
10
People are unable to completely regulate how they think.
11
We can remember songs without knowing that we have heard them.
12
Thinking about music has a similar effect on the brain to hearing music.
13
Earworms are more persistent when only a short section of the song is constantly replayed.
List of Researchers
A Lauren Stewart
B Ira Hyman
C Andrea Haiper
D John Seabrook

10 ____ People are unable to completely regulate how they think.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c80f96cc-57be-54e3-b4a8-e3f56e22a478', '7645bec4-9e36-5892-a287-236ef4b950b4', 1, $md$A$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c5ec04f0-2304-5ad4-9e99-6beecd9eb2f4', '7645bec4-9e36-5892-a287-236ef4b950b4', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('709b0eb1-8065-5d0b-91c0-49a49289f1e3', '7645bec4-9e36-5892-a287-236ef4b950b4', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('f94268b8-1c63-5e2d-affa-d78c4bdaa21e', '7645bec4-9e36-5892-a287-236ef4b950b4', 4, $md$D$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('f793e4f1-f0af-5e21-802c-61f8658f2054', '58a263e2-7ba9-53b5-afe3-aacd6f585b81', 11, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 11

Questions 9-13
Questions 9-13
Look at the following statements and the list of researcher below.
Match each statement with the correct person, A, B, C or D.
Write the correct letter. A, B, C or D, in boxes 9-13 on your answer sheet.
NB You may use any letter more than once.
9
Some musicians create music that is intentionally memorable.
10
People are unable to completely regulate how they think.
11
We can remember songs without knowing that we have heard them.
12
Thinking about music has a similar effect on the brain to hearing music.
13
Earworms are more persistent when only a short section of the song is constantly replayed.
List of Researchers
A Lauren Stewart
B Ira Hyman
C Andrea Haiper
D John Seabrook

11 ____ We can remember songs without knowing that we have heard them.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('440a432d-5cb6-5767-8230-898cf8f50c8c', 'f793e4f1-f0af-5e21-802c-61f8658f2054', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('1834d29f-38da-5935-ab82-42e50e71d57c', 'f793e4f1-f0af-5e21-802c-61f8658f2054', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9867f98e-5f17-5585-b7c4-279cfb639c9e', 'f793e4f1-f0af-5e21-802c-61f8658f2054', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ef3ee469-3456-5388-9561-ad57b50d89e5', 'f793e4f1-f0af-5e21-802c-61f8658f2054', 4, $md$D$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('218251e4-7eb0-55fa-94b8-a86e5bf5c62a', '58a263e2-7ba9-53b5-afe3-aacd6f585b81', 12, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 12

Questions 9-13
Questions 9-13
Look at the following statements and the list of researcher below.
Match each statement with the correct person, A, B, C or D.
Write the correct letter. A, B, C or D, in boxes 9-13 on your answer sheet.
NB You may use any letter more than once.
9
Some musicians create music that is intentionally memorable.
10
People are unable to completely regulate how they think.
11
We can remember songs without knowing that we have heard them.
12
Thinking about music has a similar effect on the brain to hearing music.
13
Earworms are more persistent when only a short section of the song is constantly replayed.
List of Researchers
A Lauren Stewart
B Ira Hyman
C Andrea Haiper
D John Seabrook

12 ____ Thinking about music has a similar effect on the brain to hearing music.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('921014a3-43d6-591e-996a-1a5b0b2cd210', '218251e4-7eb0-55fa-94b8-a86e5bf5c62a', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('405a9284-b247-56e2-95af-05fabf2b0ac0', '218251e4-7eb0-55fa-94b8-a86e5bf5c62a', 2, $md$B$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('82b1acbf-1516-5883-a616-823817497de0', '218251e4-7eb0-55fa-94b8-a86e5bf5c62a', 3, $md$C$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('13537c20-76cc-5a77-a89c-2794eb868287', '218251e4-7eb0-55fa-94b8-a86e5bf5c62a', 4, $md$D$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('b50c85a4-e471-5efa-8ee4-7ae459076501', '58a263e2-7ba9-53b5-afe3-aacd6f585b81', 13, 'MULTIPLE_CHOICE_SINGLE', 'READING', 4, $md$### Question 13

Questions 9-13
Questions 9-13
Look at the following statements and the list of researcher below.
Match each statement with the correct person, A, B, C or D.
Write the correct letter. A, B, C or D, in boxes 9-13 on your answer sheet.
NB You may use any letter more than once.
9
Some musicians create music that is intentionally memorable.
10
People are unable to completely regulate how they think.
11
We can remember songs without knowing that we have heard them.
12
Thinking about music has a similar effect on the brain to hearing music.
13
Earworms are more persistent when only a short section of the song is constantly replayed.
List of Researchers
A Lauren Stewart
B Ira Hyman
C Andrea Haiper
D John Seabrook

13 ____ Earworms are more persistent when only a short section of the song is constantly replayed.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('cc02dff4-7298-5c9a-9308-3e96858d0f5d', 'b50c85a4-e471-5efa-8ee4-7ae459076501', 1, $md$A$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('533e0b2d-74eb-5e0b-bd90-2b8dacc4421f', 'b50c85a4-e471-5efa-8ee4-7ae459076501', 2, $md$B$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('6b68d7ac-f8e8-55ed-bd27-26cec19540b4', 'b50c85a4-e471-5efa-8ee4-7ae459076501', 3, $md$C$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('3774a990-66a6-50e1-9e72-84f5c2179c6c', 'b50c85a4-e471-5efa-8ee4-7ae459076501', 4, $md$D$md$, false);

COMMIT;
