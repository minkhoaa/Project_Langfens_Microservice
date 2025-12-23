-- ============================================
-- IELTS Exam Data Import SQL
-- Generated: 2025-12-23T22:01:34.720936
-- Source: mini-ielts.com
-- Title: Mind Music
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data for slug: mini-ielts-reading-mind-music
DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'mini-ielts-reading-mind-music'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'mini-ielts-reading-mind-music';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'mini-ielts-reading-mind-music';
DELETE FROM exams
WHERE "Slug" = 'mini-ielts-reading-mind-music';

DO $$
DECLARE
  exam_id uuid := gen_random_uuid();
  sec1 uuid := gen_random_uuid();
  qid uuid;
BEGIN

  INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","ImageUrl","UpdatedAt")
  VALUES (
    exam_id,
    'mini-ielts-reading-mind-music',
    'Mind Music',
    'IELTS Reading Practice Test from IELTS Mentor',
    'IELTS',
    'B2',
    'PUBLISHED',
    20,
    'https://news.utdallas.edu/files/2022/04/music-mind-stock-1000.jpg',
    now()
  );

  INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","PassageMd")
  VALUES (
    sec1,
    exam_id,
    1,
    'Reading Passage - Mind Music',
    E'**Questions 1-4:**\nThe reading Passage has eight paragraphs, A-H.\nWhich paragraph contains the following information?\nWrite the correct letter, A-H, in boxes 1-4 on your answer sheet.\n\n---\n\n**Questions 5-8:**\nComplete the summary below.\nChoose ONE WORD ONLY from the passage for each answer.\nWrite your answers in boxes 5-8 on your answer sheet.\n\n**Goldsmiths study**\nResearchers from Goldsmiths concluded that the music we imagine in our minds is quite similar to recordings.\n\n---\n\n**Questions 9-13:**\nLook at the following statements and the list of researchers below.\nMatch each statement with the correct person, A, B, C or D.\nWrite the correct letter, A, B, C or D, in boxes 9-13 on your answer sheet.\nNB You may use any letter more than once.\n\n**List of Researchers:**\nA. Lauren Stewart\nB. Ira Hyman\nC. Andrea Halpern\nD. John Seabrook',
    E'**Paragraph A.**\\nScientists investigate ''earworms'', the music we can''t get out of our head\\n\\n**Paragraph B.**\\nEver had a song stuck in your head, playing on an endless loop? Scientists call them\\n\\n**Paragraph C.**\\n''involuntary musical images'', or ''earworms, and a wave of new research is shining light on why they occur and what can be learned from them. Some neuroscientists and cognitive psychologists are studying earworms to explore the mysteries of memory and the part of the brain that is beyond our conscious control. The idea that we have full control over our thought processes is an illusion,'' says psychologist Lauren Stewart, who founded the master''s program in music, mind and brain at Goldsmiths, University of London, UK, where recent research has taken place. Researchers haven''t been able to watch what happens in the brain when earworms occur, because they happen unpredictably. Much of what is known about them comes from surveys, questionnaires, diaries and lab experiments.\\n\\n**Paragraph D.**\\nA Goldsmiths study published in the journal Memory and Cognition this year showed that the singing we hear in our heads tends to be true to actual recordings. Researchers had 17 volunteers tap to the beat of any earworm they heard during a four-day period while a device attached to their wrist recorded their movements. The tapping tempos were within 10% of the tempos of the original recordings. Another Goldsmiths study, published this year in Consciousness and Cognition, found that people who report hearing earworms often, and find them most intrusive, have slightly different brain structures, with more gray matter in areas associated with processing emotions.\\n\\n**Paragraph E.**\\nStudies also show that the music in our heads often starts playing during times of ''low cognitive load'', such as while showering, getting dressed, walking, or doing chores. Dr Stewart likens earworms to ''sonic screen savers'' that keep the mind entertained while it is otherwise unoccupied. She and her colleagues tested that theory by having volunteers listen to songs and giving them various tasks afterwards. The volunteers who sat idly for the next five minutes were the most likely to report hearing the music m their heads. Dr Stewart observed that the more challenging the activity, the less likely the volunteers were to hear the music. Diary studies also show songs tend to match people''s moods and therefore they are not random. If you are energized and upbeat, an earworm that occurs is likely to be uptempo too.\\n\\n**Paragraph F.**\\nSongs the brain fixates on are usually those it has been exposed to recently, surveys show, which is why tunes getting heavy radio play frequently top the earworm charts. Even tunes you may have heard but didn''t pay attention to can worm their way into your subconscious, says Ira Hyman, a psychologist at Western Washington University in Bellingham, USA. In an unpublished study there, participants who listened to music while doing other tasks were more likely to report that the songs returned as earworms later on, compared with participants who simply listened.\\n\\n**Paragraph G.**\\nSome earworms are just fragments of a song that repeat like a broken record. So, when the mind hits a part of a song it can''t remember, it loops back rather than moving on. That could make an earworm even more entrenched, Dr Hyman says. According to a theory known as the Zeigarik effect, named for a Soviet psychologist, Bluma Zeigarnik, unfinished thoughts and activities weigh on the mind more heavily than those that are completed, although experiments exposing students to interrupted songs have yielded mixed results.\\n\\n**Paragraph H.**\\nResearchers say they can''t pinpoint a spot in the brain where earworms live. Imaging studies by Andrea Halpern at Bucknell University, in Lewisburg, USA, have shown that deliberately imagining music and actually listening to music activate many of the same neurological networks. Dr Halpern''s earlier studies showed that when subjects listened to the first few notes of familiar music, areas in the right frontal and superior temporal portions of the brain became activated, along with the supplementary motor area at the top, which is typically involved in remembering sequences. When the same subjects listened to unfamiliar music and were asked to recall it, there was activity in the left frontal portions of the brain instead.\\n\\n**Paragraph I.**\\nOne factor that makes some songs stick might be repetition. ''Repetition leads to familiarity which leads to anticipation, which is satisfied by hearing the song,'' says John Seabrook, author of The Song Machine: Inside the Hit Factory, about how producers pump pop songs full of aural "hooks'', the punchy melodic phrases designed to target the brain and leave it wanting more. The researchers are comparing the melodic structure of 100 often-mentioned songs with 100 similarly popular songs that weren''t cited as earworms, to assess the difference. Songs with earworm potential appear to share certain features: a repeating pattern of ups and downs in pitch, and an irregular musical interval.\\n\\n**Paragraph J.**\\nThe researchers plan next to test their results in reverse, and play ringtones from songs of both the earworm and non earworm variety for volunteers several times a day to see which ones get stuck. Drs Stewart and Halper are now working together to recruit survey participants for a study looking at whether people at different stages of life experience earworms differently. ''You can argue that older people might get them more often because they know more songs,'' Dr Halpern says. ''But the few responses we have so far indicate that they have earworms less often. It could be that they don''t play music as often as younger people do.\\n\\n'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    1,
    'MATCHING_INFORMATION',
    'READING',
    2,
    'a description of the characteristics common to songs with earworms',
    '',
    '{"info-q1": ["G", "g"]}'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    2,
    'MATCHING_INFORMATION',
    'READING',
    2,
    'a justitication for research into earworms',
    '',
    '{"info-q2": ["A", "a"]}'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    3,
    'MATCHING_INFORMATION',
    'READING',
    2,
    'a description of the brain''s reaction to known and unknown songs',
    '',
    '{"info-q3": ["F", "f"]}'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    4,
    'MATCHING_INFORMATION',
    'READING',
    2,
    'details of proposed research into the frequency with which earworms occur indifferent age groups',
    '',
    '{"info-q4": ["H", "h"]}'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    5,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    'They proved this by asking volunteers to record the rhythm of music using a monitor on their _______.',
    '',
    '{"blank-q5": ["wrist"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    6,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    'Further research has demonstrated that those who hear earworms more frequently have brains that may deal with _______ differently from other people.',
    '',
    '{"blank-q6": ["emotions"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    7,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    'Dr Stewart also believes that the brain is _______ by earworms when it is not focused on a task.',
    '',
    '{"blank-q7": ["entertained"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    8,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    'In fact, a reduction in the occurrence of earworms was found to be directly related to how _______ the task was.',
    '',
    '{"blank-q8": ["challenging"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    9,
    'MATCHING_FEATURES',
    'READING',
    2,
    'Some musicians create music that is intentionally memorable.',
    '',
    '{"feature-q9": ["D", "D"]}'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    10,
    'MATCHING_FEATURES',
    'READING',
    2,
    'People are unable to completely regulate how they think.',
    '',
    '{"feature-q10": ["A", "A"]}'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    11,
    'MATCHING_FEATURES',
    'READING',
    2,
    'We can remember songs without knowing that we have heard them.',
    '',
    '{"feature-q11": ["B", "B"]}'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    12,
    'MATCHING_FEATURES',
    'READING',
    2,
    'Thinking about music has a similar effect on the brain to hearing music.',
    '',
    '{"feature-q12": ["C", "C"]}'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    13,
    'MATCHING_FEATURES',
    'READING',
    2,
    'Earworms are more persistent when only a short section of the song is constantly replayed.',
    '',
    '{"feature-q13": ["B", "B"]}'
  );


END$$;


COMMIT;