BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-classical-music-over-the-centuries-1430'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-classical-music-over-the-centuries-1430';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-classical-music-over-the-centuries-1430';
DELETE FROM exams WHERE "Slug" = 'ielts-reading-classical-music-over-the-centuries-1430';

INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","CreatedAt")
VALUES ('fc792853-0f68-540c-8637-9488be68a672', 'ielts-reading-classical-music-over-the-centuries-1430', $t$Classical music over the centuries$t$, $md$## Classical music over the centuries

Nguồn:
- Test: https://mini-ielts.com/1430/reading/classical-music-over-the-centuries
- Solution: https://mini-ielts.com/1430/view-solution/reading/classical-music-over-the-centuries$md$, 'IELTS', 'B2', 'PUBLISHED', 20, now());

INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","AudioUrl","TranscriptMd")
VALUES ('620cb101-b358-5f32-a1bf-18360db88fc7', 'fc792853-0f68-540c-8637-9488be68a672', 1, $t$Reading — Classical music over the centuries$t$, $md$Read the passage and answer questions **1–12**.

### Passage: Classical music over the centuries

I NDIAN CLASSICAL MUSIC

The origins of Indian classical music can be found from the oldest of scriptures, part of the Hindus tradition, the Vedas.

Samaveda, one of the four Vedas, describes music at length. Indian classical music has its origins as a meditation tool for attaining self realization. All different forms of these melodies (ragas) are believed to affect various “chakras” (energy centers, or “mood”) in the path of the Kundalini. However, there is little mention of these esoteric beliefs in Bharat’s Natyashastra , the first treatise laying down the fundamental principles of drama, dance and music. The Samadeva, one of the four Vedas, created out of riga-veda so that its hymns could be sung as Samagana, established its first pop.

Indian classical music has one of the most complex and complete musical systems ever developed. Like Western classical music, it divides the octave s into 12 Semitones of which the 7 basic notes are Sa Re Ga Ma Pa Dha Ni Sa, replacing Do Re Mi Fa So La Ti Do. However, it uses the just intonation tuning (unlike western classical music which uses the equal temperament tuning system).

Indian classical music is monophonic in nature and based around a single melody line which is played over a fixed drone. The performance is based melodically on particular rages and rhythmically on talas.

NATIONAL SYSTEM

Scholars of Europe in the seventeenth and eighteenth century were enormed by Indian music. With no facility to record the sound they explored for some existing system that might exist system that express sounds in the composition. There were pointers to an ancient notations system which scholars had also translated into Persian: still’ complexity of Indian classical music could not be expressed in writing. Though some western scholars did record compositions in staff notation system, Indian musicians used Pt.Bhakhande system. Though more accurate, this relies on Devanagari script rather than symbols and hence is cumbersome at times. A new notation system has been proposed which uses symbols and offers instantaneous comprehension like staff notation system. It is with standardization of a notation system that hitherto unknown compositions would see the light of day.

INSTRUMENTS

Instruments typically used in Hindustani music include sitar, sarood,tanpura, bansuri, shehnai, sarangi, and table. Instruments typically used in carnatic music include flute, gottuvadyam, veena mridangam, kanjira, ghatam and violon$md$, NULL, NULL);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('bf64ae2f-97ec-568e-b3b6-f665e099a3ad', '620cb101-b358-5f32-a1bf-18360db88fc7', 1, 'YES_NO_NOT_GIVEN', 'READING', 2, $md$### Question 1

Questions 1-8
Questions 1-8
Do the following statements agree with the information in reading passage? In boxes 1-8 in your answer sheet write
YES if the statement reflects the claims of the writer
NO if the statement contradicts the writer
NOT GIVEN if it is impossible to say what the writer thinks about this
1
Out of four Vedas, music is only described in samaveds.
2
Music is believed to have an effect on human body.
3
Indian classical music system is simple and sophisticated
.
4
There are 7 basic notes and 12 semitones in Indian classical music.
5
Talas in the Indian music is derived from western music
6
Indian classical music could express in writing.
7
The composition used by Indian musicians was based on Devnagri script.
8
. New script used for music had no symbols.

1 ____ Out of four Vedas, music is only described in samaveds.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('4854b05c-25d7-5ef1-b3ae-f82e81e616f2', 'bf64ae2f-97ec-568e-b3b6-f665e099a3ad', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('73225664-02d9-52f8-852d-ac4990e90786', 'bf64ae2f-97ec-568e-b3b6-f665e099a3ad', 2, $md$NO$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('8b33b107-140d-54f0-b3a1-363232a6122f', 'bf64ae2f-97ec-568e-b3b6-f665e099a3ad', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('88c692a8-6d12-5dfa-9b85-2bd866267e71', '620cb101-b358-5f32-a1bf-18360db88fc7', 2, 'YES_NO_NOT_GIVEN', 'READING', 2, $md$### Question 2

Questions 1-8
Questions 1-8
Do the following statements agree with the information in reading passage? In boxes 1-8 in your answer sheet write
YES if the statement reflects the claims of the writer
NO if the statement contradicts the writer
NOT GIVEN if it is impossible to say what the writer thinks about this
1
Out of four Vedas, music is only described in samaveds.
2
Music is believed to have an effect on human body.
3
Indian classical music system is simple and sophisticated
.
4
There are 7 basic notes and 12 semitones in Indian classical music.
5
Talas in the Indian music is derived from western music
6
Indian classical music could express in writing.
7
The composition used by Indian musicians was based on Devnagri script.
8
. New script used for music had no symbols.

2 ____ Music is believed to have an effect on human body.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9f8865ac-483d-5664-8c7e-5294836b2b5e', '88c692a8-6d12-5dfa-9b85-2bd866267e71', 1, $md$YES$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('d979ff52-082b-5eca-b8d7-9c93ecc4245f', '88c692a8-6d12-5dfa-9b85-2bd866267e71', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('bc16f612-8e5f-5af9-88ae-e03d544ba2b9', '88c692a8-6d12-5dfa-9b85-2bd866267e71', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('de0bb243-06a8-58e7-84e8-4cfa47fe2141', '620cb101-b358-5f32-a1bf-18360db88fc7', 3, 'YES_NO_NOT_GIVEN', 'READING', 2, $md$### Question 3

Questions 1-8
Questions 1-8
Do the following statements agree with the information in reading passage? In boxes 1-8 in your answer sheet write
YES if the statement reflects the claims of the writer
NO if the statement contradicts the writer
NOT GIVEN if it is impossible to say what the writer thinks about this
1
Out of four Vedas, music is only described in samaveds.
2
Music is believed to have an effect on human body.
3
Indian classical music system is simple and sophisticated
.
4
There are 7 basic notes and 12 semitones in Indian classical music.
5
Talas in the Indian music is derived from western music
6
Indian classical music could express in writing.
7
The composition used by Indian musicians was based on Devnagri script.
8
. New script used for music had no symbols.

3 ____ Indian classical music system is simple and sophisticated .$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('58c91351-9120-5eb1-a11d-e26a214c8127', 'de0bb243-06a8-58e7-84e8-4cfa47fe2141', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('528e6085-f059-594e-ac93-89c7f25e6a1e', 'de0bb243-06a8-58e7-84e8-4cfa47fe2141', 2, $md$NO$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e0e91dd3-4fe5-5659-86af-991ffa0016f7', 'de0bb243-06a8-58e7-84e8-4cfa47fe2141', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('3d097d74-9272-55bc-8825-1227112e9d73', '620cb101-b358-5f32-a1bf-18360db88fc7', 4, 'YES_NO_NOT_GIVEN', 'READING', 2, $md$### Question 4

Questions 1-8
Questions 1-8
Do the following statements agree with the information in reading passage? In boxes 1-8 in your answer sheet write
YES if the statement reflects the claims of the writer
NO if the statement contradicts the writer
NOT GIVEN if it is impossible to say what the writer thinks about this
1
Out of four Vedas, music is only described in samaveds.
2
Music is believed to have an effect on human body.
3
Indian classical music system is simple and sophisticated
.
4
There are 7 basic notes and 12 semitones in Indian classical music.
5
Talas in the Indian music is derived from western music
6
Indian classical music could express in writing.
7
The composition used by Indian musicians was based on Devnagri script.
8
. New script used for music had no symbols.

4 ____ There are 7 basic notes and 12 semitones in Indian classical music.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b59fb1ed-a16e-5277-9ee8-6e37c02162e1', '3d097d74-9272-55bc-8825-1227112e9d73', 1, $md$YES$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('e61c66a4-5637-55b4-ba98-1fac42cf9a43', '3d097d74-9272-55bc-8825-1227112e9d73', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('ebafd8c7-6cad-53ea-86a1-485e7dfb1371', '3d097d74-9272-55bc-8825-1227112e9d73', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('a21d58a1-9bed-5cea-b96b-13ada4ee1d0f', '620cb101-b358-5f32-a1bf-18360db88fc7', 5, 'YES_NO_NOT_GIVEN', 'READING', 3, $md$### Question 5

Questions 1-8
Questions 1-8
Do the following statements agree with the information in reading passage? In boxes 1-8 in your answer sheet write
YES if the statement reflects the claims of the writer
NO if the statement contradicts the writer
NOT GIVEN if it is impossible to say what the writer thinks about this
1
Out of four Vedas, music is only described in samaveds.
2
Music is believed to have an effect on human body.
3
Indian classical music system is simple and sophisticated
.
4
There are 7 basic notes and 12 semitones in Indian classical music.
5
Talas in the Indian music is derived from western music
6
Indian classical music could express in writing.
7
The composition used by Indian musicians was based on Devnagri script.
8
. New script used for music had no symbols.

5 ____ Talas in the Indian music is derived from western music$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b65b2346-412c-5704-9b53-5d4c33a28c3a', 'a21d58a1-9bed-5cea-b96b-13ada4ee1d0f', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('27ce1026-70d1-520b-bdb0-ac9392659922', 'a21d58a1-9bed-5cea-b96b-13ada4ee1d0f', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('b0314a66-9b70-52cb-83c9-096b9d25b129', 'a21d58a1-9bed-5cea-b96b-13ada4ee1d0f', 3, $md$NOT GIVEN$md$, true);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('4c92cfa7-4514-5008-b7ea-9809ab084784', '620cb101-b358-5f32-a1bf-18360db88fc7', 6, 'YES_NO_NOT_GIVEN', 'READING', 3, $md$### Question 6

Questions 1-8
Questions 1-8
Do the following statements agree with the information in reading passage? In boxes 1-8 in your answer sheet write
YES if the statement reflects the claims of the writer
NO if the statement contradicts the writer
NOT GIVEN if it is impossible to say what the writer thinks about this
1
Out of four Vedas, music is only described in samaveds.
2
Music is believed to have an effect on human body.
3
Indian classical music system is simple and sophisticated
.
4
There are 7 basic notes and 12 semitones in Indian classical music.
5
Talas in the Indian music is derived from western music
6
Indian classical music could express in writing.
7
The composition used by Indian musicians was based on Devnagri script.
8
. New script used for music had no symbols.

6 ____ Indian classical music could express in writing.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('78784c06-b592-59e9-b825-c2ddb41ceab4', '4c92cfa7-4514-5008-b7ea-9809ab084784', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('74e96bc4-a09f-56fc-a7e2-50b94daf8191', '4c92cfa7-4514-5008-b7ea-9809ab084784', 2, $md$NO$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('c55f7e4b-ff4a-5ba9-9387-a8e29f577b98', '4c92cfa7-4514-5008-b7ea-9809ab084784', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('432f1b53-b8d7-5b3f-8ea3-5c9757695243', '620cb101-b358-5f32-a1bf-18360db88fc7', 7, 'YES_NO_NOT_GIVEN', 'READING', 3, $md$### Question 7

Questions 1-8
Questions 1-8
Do the following statements agree with the information in reading passage? In boxes 1-8 in your answer sheet write
YES if the statement reflects the claims of the writer
NO if the statement contradicts the writer
NOT GIVEN if it is impossible to say what the writer thinks about this
1
Out of four Vedas, music is only described in samaveds.
2
Music is believed to have an effect on human body.
3
Indian classical music system is simple and sophisticated
.
4
There are 7 basic notes and 12 semitones in Indian classical music.
5
Talas in the Indian music is derived from western music
6
Indian classical music could express in writing.
7
The composition used by Indian musicians was based on Devnagri script.
8
. New script used for music had no symbols.

7 ____ The composition used by Indian musicians was based on Devnagri script.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('31017416-c3c1-5a9e-bc41-dd389b14a838', '432f1b53-b8d7-5b3f-8ea3-5c9757695243', 1, $md$YES$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('676a224a-3589-58de-b6c1-a8405ae8e0ce', '432f1b53-b8d7-5b3f-8ea3-5c9757695243', 2, $md$NO$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('2a98b817-6122-5da2-9ced-801bb632bf7d', '432f1b53-b8d7-5b3f-8ea3-5c9757695243', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
VALUES ('d1267f97-8948-56de-b843-7db19e1da4b9', '620cb101-b358-5f32-a1bf-18360db88fc7', 8, 'YES_NO_NOT_GIVEN', 'READING', 3, $md$### Question 8

Questions 1-8
Questions 1-8
Do the following statements agree with the information in reading passage? In boxes 1-8 in your answer sheet write
YES if the statement reflects the claims of the writer
NO if the statement contradicts the writer
NOT GIVEN if it is impossible to say what the writer thinks about this
1
Out of four Vedas, music is only described in samaveds.
2
Music is believed to have an effect on human body.
3
Indian classical music system is simple and sophisticated
.
4
There are 7 basic notes and 12 semitones in Indian classical music.
5
Talas in the Indian music is derived from western music
6
Indian classical music could express in writing.
7
The composition used by Indian musicians was based on Devnagri script.
8
. New script used for music had no symbols.

8 ____ . New script used for music had no symbols.$md$, NULL);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('99237f20-529e-5f4d-b739-9652d09fb1a0', 'd1267f97-8948-56de-b843-7db19e1da4b9', 1, $md$YES$md$, false);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('9d537743-963f-5693-b849-0d9bf468abd7', 'd1267f97-8948-56de-b843-7db19e1da4b9', 2, $md$NO$md$, true);
INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect")
VALUES ('7c052246-fbbe-5615-a0ac-754dcc4fe5e2', 'd1267f97-8948-56de-b843-7db19e1da4b9', 3, $md$NOT GIVEN$md$, false);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('494a79a5-2769-5ae6-b93a-014187e6deb9', '620cb101-b358-5f32-a1bf-18360db88fc7', 9, 'SHORT_ANSWER', 'READING', 3, $md$### Question 9

Question 9-12
Question 9-12
9. “Chakras” is a name given to energy centers in the path of
9
10. Out of all kind of music, Indian classical music is
10
and having complete system.
11. Monophonic music system is based on a single
11
.
12. The instruments flute, veena and violinare
12
in carnation music.

9. “Chakras” is a name given to energy centers in the path of 9 ____$md$, NULL, ARRAY['.*kundalin.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('7ed1eb87-83ef-5e90-8e50-d11de0673247', '620cb101-b358-5f32-a1bf-18360db88fc7', 10, 'SHORT_ANSWER', 'READING', 4, $md$### Question 10

Question 9-12
Question 9-12
9. “Chakras” is a name given to energy centers in the path of
9
10. Out of all kind of music, Indian classical music is
10
and having complete system.
11. Monophonic music system is based on a single
11
.
12. The instruments flute, veena and violinare
12
in carnation music.

10. Out of all kind of music, Indian classical music is 10 ____ and having complete system.$md$, NULL, ARRAY['.*most.*complex.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('4fb8eb7e-0785-5dbb-afab-a25170b7f7a9', '620cb101-b358-5f32-a1bf-18360db88fc7', 11, 'SHORT_ANSWER', 'READING', 4, $md$### Question 11

Question 9-12
Question 9-12
9. “Chakras” is a name given to energy centers in the path of
9
10. Out of all kind of music, Indian classical music is
10
and having complete system.
11. Monophonic music system is based on a single
11
.
12. The instruments flute, veena and violinare
12
in carnation music.

11. Monophonic music system is based on a single 11 ____ .$md$, NULL, ARRAY['.*melody.*line.*']);

INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptRegex")
VALUES ('059f8951-4e29-5b77-ad84-a27382d53c71', '620cb101-b358-5f32-a1bf-18360db88fc7', 12, 'SHORT_ANSWER', 'READING', 4, $md$### Question 12

Question 9-12
Question 9-12
9. “Chakras” is a name given to energy centers in the path of
9
10. Out of all kind of music, Indian classical music is
10
and having complete system.
11. Monophonic music system is based on a single
11
.
12. The instruments flute, veena and violinare
12
in carnation music.

12. The instruments flute, veena and violinare 12 ____ in carnation music.$md$, NULL, ARRAY['.*typically.*used.*']);

COMMIT;
