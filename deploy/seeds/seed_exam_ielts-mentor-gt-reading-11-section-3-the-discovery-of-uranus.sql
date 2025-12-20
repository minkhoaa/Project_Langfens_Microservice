-- ============================================
-- IELTS Exam Data Import SQL
-- Generated: 2025-12-20T18:22:10.432502
-- Source: ielts-mentor.com
-- Title: GT Reading 11 Section 3 - The Discovery of Uranus
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data for slug: ielts-mentor-gt-reading-11-section-3-the-discovery-of-uranus
DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-mentor-gt-reading-11-section-3-the-discovery-of-uranus'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-mentor-gt-reading-11-section-3-the-discovery-of-uranus';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-mentor-gt-reading-11-section-3-the-discovery-of-uranus';
DELETE FROM exams
WHERE "Slug" = 'ielts-mentor-gt-reading-11-section-3-the-discovery-of-uranus';

DO $$
DECLARE
  exam_id uuid := gen_random_uuid();
  sec1 uuid := gen_random_uuid();
  qid uuid;
BEGIN

  INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","UpdatedAt")
  VALUES (
    exam_id,
    'ielts-mentor-gt-reading-11-section-3-the-discovery-of-uranus',
    'GT Reading 11 Section 3 - The Discovery of Uranus',
    'IELTS Reading Practice Test from IELTS Mentor',
    'IELTS',
    'B2',
    'PUBLISHED',
    20,
    now()
  );

  INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd")
  VALUES (
    sec1,
    exam_id,
    1,
    'Reading Passage - GT Reading 11 Section 3 - The Discovery of Uranus',
    E'# Passage\n\n# The Discovery of Uranus\n\nSomeone once put forward an attractive though unlikely theory. Throughout the Earth''s annual revolution around the sun, there is one point of space always hidden from our eyes. This point is the opposite part of the Earth''s orbit, which is always hidden by the sun. Could there be another planet there, essentially similar to our own, but always invisible? If a space probe today sent back evidence that such a world existed it would cause not much more sensation than Sir William Herschel''s discovery of a new planet, Uranus, in 1781.\n\nHerschel was an extraordinary man - no other astronomer has ever covered so vast a field of work - and his career deserves study. He was born in Hanover in Germany in 1738, left the German army in 1757, and arrived in England the same year with no money but quite exceptional music ability. He played the violin and oboe and at one time was organist in the Octagon Chapel in the city of Bath. Herschel''s was an active mind, and deep inside he was conscious that music was not his destiny; he, therefore, read widely in science and the arts, but not until 1772 did he come across a book on astronomy. He was then 34, middle-aged by the standards of the time, but without hesitation he embarked on his new career, financing it by his professional work as a musician. He spent years mastering the art of telescope construction, and even by present-day standards, his instruments are comparable with the best.\n\nSerious observation began in 1774. He set himself the astonishing task of ''reviewing the heavens'', in other words, pointing his telescope to every accessible part of the sky and recording what he saw. The first review was made in 1775; the second, and most momentous, in 1780-81. It was during the latter part of this that he discovered Uranus. Afterwards, supported by the royal grant in recognition of his work, he was able to devote himself entirely to astronomy. His final achievements spread from the sun and moon to remote galaxies (of which he discovered hundreds), and papers flooded from his pen until his death in 1822. Among these there was one sent to the Royal Society in 1781, entitled An Account of a Comet. In his own words:\n\nOn Tuesday the 13th of March, between ten and eleven in the evening, while I was examining the small stars in the neighbourhood of H Geminorum, I perceived one that appeared visibly larger than the rest; being struck with its uncommon magnitude, I compared it to H Geminorum and the small star in the quartile between Auriga and Gemini, and finding it to be much larger than either of them, suspected it to be a comet.\n\nHerschel''s care was the hallmark of a great observer; he was not prepared to jump any conclusions. Also, to be fair, the discovery of a new planet was the last thought in anybody''s mind. But further observation by other astronomers besides Herschel revealed two curious facts. For comet, it showed a remarkably sharp disc; furthermore, it was moving so slowly that it was thought to be a great distance from the sun, and comets are only normally visible in the immediate vicinity of the sun. As its orbit came to be worked out the truth dawned that it was a new planet far beyond Saturn''s realm, and that the ''reviewer of the heavens'' had stumbled across an unprecedented prize. Herschel wanted to call it Georgium Sidus (Star of George) in honour of his royal patron King George III of Great Britain. The planet was later for a time called Herschel in honour of its discoverer. The name Uranus, which was first proposed by the German astronomer Johann Elert Bode, was in use by the late 19th century.\n\nUranus is a giant in construction, but not so much in size; its diameter compares unfavourably with that of Jupiter and Saturn, though on the terrestrial scale it is still colossal. Uranus'' atmosphere consists largely of hydrogen and helium, with a trace of methane. Through a telescope the planet appears as a small bluish-green disc with a faint green periphery. In 1977, while recording the occultation of a star behind the planet, the American astronomer James L. Elliot discovered the presence of five rings encircling the equator of Uranus. Four more rings were discovered in January 1986 during the exploratory flight of Voyager 2 , In addition to its rings, Uranus has 15 satellites (''moons''), the last 10 discovered by Voyager 2 on the same flight; all revolve about its equator and move with the planet in an east- west direction. The two largest moons, Titania and Oberon, were discovered by Herschel in 1787. The next two, Umbriel and Ariel, were found in 1851 by the British astronomer William Lassell. Miranda, thought before 1986 to be the innermost moon, was discovered in 1948 by the American astronomer Gerard Peter Kuiper.\n\nThe suggested names of the new planet started with........ (37) ........, then........ (38) ......., before finally settling on Uranus. The first five rings around Uranus were discovered by ........ (39) ......... From 1948 until 1986, the moon ........ (40)........ was believed to be the moon closest to the surface of Uranus.'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    27,
    'SHORT_ANSWER',
    'READING',
    2,
    'Herschel began investigating astronomy in _______',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q27": ["1772"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    28,
    'SHORT_ANSWER',
    'READING',
    2,
    'Discovery of the planet Uranus: _______',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q28": ["1781"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    29,
    'SHORT_ANSWER',
    'READING',
    2,
    'Discovery of the moons Titania and Oberon: _______',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q29": ["1787"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    30,
    'SHORT_ANSWER',
    'READING',
    2,
    'First discovery of Uranus'' rings: _______',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q30": ["1977"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    31,
    'SHORT_ANSWER',
    'READING',
    2,
    'Discovery of the last 10 moons of Uranus: _______',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q31": ["1986"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    32,
    'YES_NO_NOT_GIVEN',
    'READING',
    2,
    'It is improbable that there is a planet hidden behind the sun.',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'YES', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'NO', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'NOT GIVEN', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    33,
    'YES_NO_NOT_GIVEN',
    'READING',
    2,
    'Herschel knew immediately that he had found a new planet.',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'YES', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'NO', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'NOT GIVEN', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    34,
    'YES_NO_NOT_GIVEN',
    'READING',
    2,
    'Herschel collaborated with other astronomers of his time.',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'YES', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'NO', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'NOT GIVEN', true);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    35,
    'YES_NO_NOT_GIVEN',
    'READING',
    2,
    'Herschel''s newly-discovered object was considered to be too far from the sun to be a comet.',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'YES', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'NO', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'NOT GIVEN', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    36,
    'YES_NO_NOT_GIVEN',
    'READING',
    2,
    'Herschel''s discovery was the most important find of the last three hundred years.',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'YES', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'NO', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'NOT GIVEN', true);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    37,
    'SHORT_ANSWER',
    'READING',
    2,
    'The suggested names of the new planet started with _______, then Herschel, before finally settling on Uranus.',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q37": ["GEORGIUM SIDUS"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    38,
    'SHORT_ANSWER',
    'READING',
    2,
    'The suggested names were Georgium Sidus, then _______, before finally settling on Uranus.',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q38": ["HERSCHEL"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    39,
    'SHORT_ANSWER',
    'READING',
    2,
    'The first five rings around Uranus were discovered by _______.',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q39": ["JAMES L. ELLIOT"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    40,
    'SHORT_ANSWER',
    'READING',
    2,
    'From 1948 until 1986, the moon _______ was believed to be the moon closest to the surface of Uranus.',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q40": ["MIRANDA"]}'::jsonb
  );


END$$;


COMMIT;