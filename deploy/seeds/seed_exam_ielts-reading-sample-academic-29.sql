-- ============================================
-- IELTS Exam Data Import SQL
-- Generated: 2025-12-20T12:02:35.049789
-- Source: ielts-writing.info
-- Title: IELTS Reading Sample (Academic) #29
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data for slug: ielts-reading-ielts-reading-sample-academic-29
DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-ielts-reading-sample-academic-29'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-ielts-reading-sample-academic-29';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-ielts-reading-sample-academic-29';
DELETE FROM exams
WHERE "Slug" = 'ielts-reading-ielts-reading-sample-academic-29';

DO $$
DECLARE
  exam_id uuid := gen_random_uuid();
  sec1 uuid := gen_random_uuid();
  qid uuid;
BEGIN

  INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","UpdatedAt")
  VALUES (
    exam_id,
    'ielts-reading-ielts-reading-sample-academic-29',
    'IELTS Reading Sample (Academic) #29',
    'IELTS Reading Practice Test: IELTS Reading Sample (Academic) #29',
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
    'Reading Passage - IELTS Reading Sample (Academic) #29',
    E'# Passage\n\nIELTS Reading Academic 29\nTWISTED LIGHT\nA.\nWhy is your mobile phone or wireless signal so slow? If you ask your service provider, they''ll tell you that it''s the bandwidth. We''re running out of signal space on the wireless spectrum. All wireless communications travel through radio or optical frequencies: your TV or radio programmes, your GPS device that helps you find your way, your mobile and smartphone, laptop and wirelessly connected PC. The demands from users and industry on a limited resource, the wireless spectrum, are growing daily and are closely regulated. The reason is that two users cannot use the same signal: think about radio stations, which have to operate on different frequencies otherwise they cause interference with each other. Likewise mobile phone operators cannot transit over the same frequency in the same market at the same time. Government-controlled agencies grant licences to use the wireless spectrum but if a wireless company wants to add more spectrum to its service to boost its capacity, it''s likely to be disappointed as there isn''t much more available. What is needed is a way of pushing more data through the same amount of bandwidth.\nB.\nNow scientists may have found a way of manipulating light waves to carry more information: potentially enough for users to be able to download a film onto a smartphone in a single second. By twisting light waves, scientists could possibly transmit data at speeds of 2.56 terrabits per second: that''s 85,000 times faster than the 30 megabits per second currently possible. To put it another way, this is the same as transmitting 70 DVDs through the air in about a second. Researchers based in America, China, Israel and Pakistan have built on previous research from Sweden, which negates the need for more bandwidth by making better use of the spectrum. The basis of the research is to manipulate the properties of light.\nC.\nOne property of light is wavelength: lasers, radio waves, microwaves are simply different wavelengths of light. Light is made up of photons and photons have two other properties that define a beam of light: spin angular momentum and orbital angular momentum. A good way of thinking about how photons travel is to think of the orbit of a planet: it spins around on its axis (spin angular momentum), and at the same time the planet is also revolving around the sun (orbital angular momentum). The latter force means that light can be twisted around its axis of travel to take the shape of a spiral or a corkscrew. At the centre of the spiral the light waves cancel each other out, leaving darkness in the middle, called an optical vortex. When light travels, it is formed into a spiral shape and it can be manipulated. There are infinite possibilities for ways in which the photon can be made to spiral: clockwise, counterclockwise, tight spirals or loose ones. Each of these spiral states can be uniquely identified but, more importantly for wireless communication, the spirals can be wrapped up within each other — or multiplexed — into a single beam. The beam can be transmitted and unwound at the receiving end to get the data streams back out again, essentially doubling or trebling or even quadrupling the bandwidth.\nD.\nScientists have been twisting light since the 1970s, and the spin angular momentum of waves is already manipulated in standard wireless communication. For years, Bo Thide of the Swedish Institute of Space Physics theorised that the orbital angular momentum could be used to create the spiral signal or as Thiele calls it a ''radio vortex''. Then in an experiment in Venice, his team transmitted two signals simultaneously on the same frequency over a distance of 442 metres. Following on from this, researchers in America, China, Israel and Pakistan, led by Alan Wilner, twisted together eight light data streams, each stream with its own level of orbital angular momentum twist. One of the streams was transmitted as a thin stream while the others were transmitted around the outside. The data beam was then sent to a receiver and untwisted to recover the data.\nE.\nThe achievement is very exciting for developers of wireless network technology as the useful spectrum of frequencies is largely used up. The orbital angular momentum model would allow for an infinite number of data transmissons without taking up any more of the spectrum. There is a problem, however: researchers can only transmit the data stream one metre, which is an insignificant distance for communication purposes. The short transmission range is due to turbulence in the atmosphere, which disrupts the signal as the light hits air molecules. But the scientists are planning to be able to send the beam considerably further. One idea is to create links every kilometre to extend the network. Another is to build high-speed satellite communication links where the atmospheric problems would not affect the signal. Another possibility is to adapt the technology for fibre-optic use, the way data is currently transmitted over the Internet. Unfortunately, at this point standard fibre-optic cables are not capable of carrying multichannel signals and fibre-optic cables that can carry the signal experience problems of interference between channels as they carry data with high bit-rates.\nF.\nNevertheless, exploiting the orbital angular momentum gives scientists options that could lead to significant increases in data transfer; even a modest increase in the existing data transfer rate is worthwhile. Furthermore, very often technology is pulled along by innovative research so a novel solution to carrying the data-rich signal may not be far behind.\n\n.'
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
    'Changing light waves to increase capacity',
    'Choose the correct answer.',
    '{"info-q1": ["C", "c"]}'
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
    'A practical demonstration of the new technology',
    'Choose the correct answer.',
    '{"info-q2": ["D", "d"]}'
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
    'Use of the wireless spectrum needing to be monitored closely',
    'Choose the correct answer.',
    '{"info-q3": ["A", "a"]}'
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
    'Overcoming the problem of the short range of the new signal',
    'Choose the correct answer.',
    '{"info-q4": ["E", "e"]}'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    5,
    'MATCHING_INFORMATION',
    'READING',
    2,
    'Improvements in data transmission possibly leading to technological breakthroughs',
    'Choose the correct answer.',
    '{"info-q5": ["F", "f"]}'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    6,
    'MATCHING_INFORMATION',
    'READING',
    2,
    'The prospect of saving people a lot of time',
    'Choose the correct answer.',
    '{"info-q6": ["B", "b"]}'
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
    'Questions (...) - (...) Complete the notes below. Choose ONE WORD AND/OR A NUMBER from the passage for each answer. Write your answers in boxes (...) - (...) on your answer sheet.\n\nResearchers are looking for a way of using the _______ more efficiently. One option is to transmit signals that are twisted into (...) and wrapping them together, or (...) them. This is still problematic on earth due to (...) but scientists hope that (...) cable technology will catch up with the research breakthrough.',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank. The answer must fit grammatically.',
    '{"blank-q7": ["wireless spectrum"]}'::jsonb
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
    'Questions (...) - (...) Complete the notes below. Choose ONE WORD AND/OR A NUMBER from the passage for each answer. Write your answers in boxes (...) - (...) on your answer sheet.\n\nResearchers are looking for a way of using the (...) more efficiently. One option is to transmit signals that are twisted into _______ and wrapping them together, or (...) them. This is still problematic on earth due to (...) but scientists hope that (...) cable technology will catch up with the research breakthrough.',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank. The answer must fit grammatically.',
    '{"blank-q8": ["spirals"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    9,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    'Questions (...) - (...) Complete the notes below. Choose ONE WORD AND/OR A NUMBER from the passage for each answer. Write your answers in boxes (...) - (...) on your answer sheet.\n\nResearchers are looking for a way of using the (...) more efficiently. One option is to transmit signals that are twisted into (...) and wrapping them together, or _______ them. This is still problematic on earth due to (...) but scientists hope that (...) cable technology will catch up with the research breakthrough.',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank. The answer must fit grammatically.',
    '{"blank-q9": ["multiplexing"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    10,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    'Questions (...) - (...) Complete the notes below. Choose ONE WORD AND/OR A NUMBER from the passage for each answer. Write your answers in boxes (...) - (...) on your answer sheet.\n\nResearchers are looking for a way of using the (...) more efficiently. One option is to transmit signals that are twisted into (...) and wrapping them together, or (...) them. This is still problematic on earth due to _______ but scientists hope that (...) cable technology will catch up with the research breakthrough.',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank. The answer must fit grammatically.',
    '{"blank-q10": ["atmospheric interference"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    11,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    'Questions (...) - (...) Complete the notes below. Choose ONE WORD AND/OR A NUMBER from the passage for each answer. Write your answers in boxes (...) - (...) on your answer sheet.\n\nResearchers are looking for a way of using the (...) more efficiently. One option is to transmit signals that are twisted into (...) and wrapping them together, or (...) them. This is still problematic on earth due to (...) but scientists hope that _______ cable technology will catch up with the research breakthrough.',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank. The answer must fit grammatically.',
    '{"blank-q11": ["fibre-optic"]}'::jsonb
  );


END$$;


COMMIT;