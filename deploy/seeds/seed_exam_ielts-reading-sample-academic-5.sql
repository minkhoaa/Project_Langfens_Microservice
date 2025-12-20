-- ============================================
-- IELTS Exam Data Import SQL
-- Generated: 2025-12-20T12:04:46.328283
-- Source: ielts-writing.info
-- Title: IELTS Reading Sample (Academic) #5
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data for slug: ielts-reading-ielts-reading-sample-academic-5
DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-ielts-reading-sample-academic-5'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-ielts-reading-sample-academic-5';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-ielts-reading-sample-academic-5';
DELETE FROM exams
WHERE "Slug" = 'ielts-reading-ielts-reading-sample-academic-5';

DO $$
DECLARE
  exam_id uuid := gen_random_uuid();
  sec1 uuid := gen_random_uuid();
  qid uuid;
BEGIN

  INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","UpdatedAt")
  VALUES (
    exam_id,
    'ielts-reading-ielts-reading-sample-academic-5',
    'IELTS Reading Sample (Academic) #5',
    'IELTS Reading Practice Test: IELTS Reading Sample (Academic) #5',
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
    'Reading Passage - IELTS Reading Sample (Academic) #5',
    E'# Passage\n\nAcademic Reading 22 - Passage 1\nA\nIf you took off your skin and laid it flat, it would cover an area of about twenty-one square feet, making it by far the body''s largest organ. Draped in place over our bodies, skin forms the barrier between what''s inside us and what''s outside. It protects us from a multitude of external forces. It serves as an avenue to our most intimate physical and psychological selves.\nB\nThis impervious yet permeable barrier, less than a millimetre thick in places, is composed of three layers. The outermost layer is the bloodless epidermis. The dermis includes collagen, elastin, and nerve endings. The innermost layer, subcutaneous fat, contains tissue that acts as an energy source, cushion and insulator for the body.\nC\nFrom these familiar characteristics of skin emerge the profound mysteries of touch, arguably our most essential source of sensory stimulation. We can live without seeing or hearing – in fact, without any of our other senses. But babies born without effective nerve connections between skin and brain can fail to thrive and may even die.\nD\nLaboratory experiments decades ago, now considered unethical and inhumane, kept baby monkeys from being touched by their mothers. It made no difference that the babies could see, hear and smell their mothers; without touching, the babies became apathetic, and failed to progress.\nE\nFor humans, insufficient touching in early years can have lifelong results. "In touching cultures, adult aggression is low, whereas in cultures where touch is limited, adult aggression is high," writes Tiffany Field, director of the Touch Research Institutes at the University of Miami School of Medicine. Studies of a variety of cultures show a correspondence between high rates of physical affection in childhood and low rates of adult physical violence.\nF\nWhile the effects of touching are easy to understand, the mechanics of it are less so. "Your skin has millions of nerve cells of various shapes at different depths," explains Stanley Bolanowski, a neuroscientist and associate director of the Institute for Sensory Research at Syracuse University. "When the nerve cells are stimulated, physical energy is transformed into energy used by the nervous system and passed from the skin to the spinal cord and brain. It''s called transduction, and no one knows exactly how it takes place." Suffice it to say that the process involves the intricate, splitsecond operation of a complex system of signals between neurons in the skin and brain.\nG\nThis is starting to sound very confusing until Bolanowski says: "In simple terms people perceive three basic things via skin: pressure, temperature, and pain." And then I''m sure he''s wrong. "When I get wet, my skin feels wet," I protest. "Close your eyes and lean back," says Bolanowski.\nH\nSomething cold and wet is on my forehead – so wet, in fact, that I wait for water to start dripping down my cheeks. "Open your eyes." Bolanowski says, showing me that the sensation comes from a chilled, but dry, metal cylinder. The combination of pressure and cold, he explains, is what makes my skin perceive wetness. He gives me a surgical glove to put on and has me put a finger in a glass of cold water. My finger feels wet, even though I have visual proof that it''s not touching water. My skin, which seemed so reliable, has been deceiving me my entire life. When I shower or wash my hands, I now realize, my skin feels pressure and temperature. It''s my brain that says I feel wet.\nI\nPerceptions of pressure, temperature and pain manifest themselves in many different ways. Gentle stimulation of pressure receptors can result in ticklishness; gentle stimulation of pain receptors, in itching. Both sensations arise from a neurological transmission, not from something that physically exists. Skin, I''m realizing, is under constant assault, both from within the body and from forces outside. Repairs occur with varying success.\nJ\nTake the spot where I nicked myself with a knife while slicing fruit. I have a crusty scab surrounded by pink tissue about a quarter inch long on my right palm. Under the scab, epidermal cells are migrating into the wound to close it up. When the process is complete, the scab will fall off to reveal new epidermis. It''s only been a few days, but my little self-repair is almost complete. Likewise, we recover quickly from slight burns. If you ever happen to touch a hot burner, just put your finger in cold water. The chances are you will have no blister, little pain and no scar. Severe burns, though, are a different matter.\n\n.'
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
    'The features of human skin, on and below the surface',
    'Choose the correct answer.',
    '{"info-q1": ["B", "b"]}'
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
    'An experiment in which the writer can see what is happening',
    'Choose the correct answer.',
    '{"info-q2": ["H", "h"]}'
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
    'Advice on how you can avoid damage to the skin',
    'Choose the correct answer.',
    '{"info-q3": ["J", "j"]}'
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
    'Cruel research methods used in the past',
    'Choose the correct answer.',
    '{"info-q4": ["D", "d"]}'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    5,
    'MULTIPLE_CHOICE_SINGLE',
    'READING',
    2,
    'How does a lack of affectionate touching affect children?',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'It makes them apathetic.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'They are more likely to become violent adults.', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'They will be less aggressive when they grow up.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'We do not really know.', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    6,
    'MULTIPLE_CHOICE_SINGLE',
    'READING',
    2,
    'After the ''wetness'' experiments, the writer says that',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'his skin is not normal.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'his skin was wet when it felt wet.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'he knew why it felt wet when it was dry.', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'the experiments taught him nothing new.', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    7,
    'MATCHING_INFORMATION',
    'READING',
    2,
    'Touch is unique among the five senses',
    'Choose the correct answer.',
    '{"info-q7": ["E", "e"]}'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    8,
    'MATCHING_INFORMATION',
    'READING',
    2,
    'A substance may feel wet',
    'Choose the correct answer.',
    '{"info-q8": ["H", "h"]}'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    9,
    'MATCHING_INFORMATION',
    'READING',
    2,
    'Something may tickle',
    'Choose the correct answer.',
    '{"info-q9": ["D", "d"]}'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    10,
    'MATCHING_INFORMATION',
    'READING',
    2,
    'The skin may itch',
    'Choose the correct answer.',
    '{"info-q10": ["G", "g"]}'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    11,
    'MATCHING_INFORMATION',
    'READING',
    2,
    'A small cut heals up quickly',
    'Choose the correct answer.',
    '{"info-q11": ["B", "b"]}'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    12,
    'TRUE_FALSE_NOT_GIVEN',
    'READING',
    2,
    'Even scientists have difficulty understanding how our sense of touch works.',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'TRUE', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'FALSE', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'NOT GIVEN', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    13,
    'YES_NO_NOT_GIVEN',
    'READING',
    2,
    'The skin is more sensitive to pressure than to temperature or pain.',
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
    14,
    'TRUE_FALSE_NOT_GIVEN',
    'READING',
    2,
    'The human skin is always good at repairing itself.',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'TRUE', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'FALSE', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'NOT GIVEN', false);


END$$;


COMMIT;