-- ============================================
-- IELTS Exam Data Import SQL
-- Generated: 2025-12-24T22:00:02.603114
-- Source: mini-ielts.com
-- Title: The Rainmaker design
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data for slug: mini-ielts-reading-the-rainmaker-design
DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'mini-ielts-reading-the-rainmaker-design'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'mini-ielts-reading-the-rainmaker-design';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'mini-ielts-reading-the-rainmaker-design';
DELETE FROM exams
WHERE "Slug" = 'mini-ielts-reading-the-rainmaker-design';

DO $$
DECLARE
  exam_id uuid := gen_random_uuid();
  sec1 uuid := gen_random_uuid();
  qid uuid;
BEGIN

  INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","ImageUrl","UpdatedAt")
  VALUES (
    exam_id,
    'mini-ielts-reading-the-rainmaker-design',
    'The Rainmaker design',
    'IELTS Reading Practice Test from IELTS Mentor',
    'IELTS',
    'B2',
    'PUBLISHED',
    20,
    'http://images.mini-ielts.com/images/2018/2021/the-rainmaker-design_resized.jpg',
    now()
  );

  INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","PassageMd")
  VALUES (
    sec1,
    exam_id,
    1,
    'Reading Passage - The Rainmaker design',
    E'**Questions 27-31:**\nDo the following statements agree with the claims of the writer?\n\nWrite\n- **YES** if the statement agrees with the claims of the writer\n- **NO** if the statement contradicts the claims of the writer\n- **NOT GIVEN** if it is impossible to say what the writer thinks about this\n\n---\n\n**Questions 32-40:**\nComplete the sentences below.\n\nWrite **NO MORE THAN TWO WORDS AND/OR A NUMBER** for each answer.\n---\n\n### Images for Questions 32-36\n\n\n![Question 32-36 Option A](http://images.mini-ielts.com/images/2018/2021/the-rainmaker-design.jpg)\n',
    E'**Paragraph A.**\\nSometimes ideas just pop up out of the blue. Or in Charlie Paton’s case, out of the rain. ‘I was on a bus in Morocco traveling through the desert,’ he remembers. ‘It had been raining and the bus was full of hot, wet people. The windows steamed up and I went to sleep with a towel against the glass. When I woke, the thing was soaking wet. I had to wring it out. And it set me thinking. Why was it so wet?\\n\\n**Paragraph B.**\\nThe answer, of course, was condensation. Back home in London, a physicist friend, Philip Davies, explained that the glass, chilled by the rain outside, had cooled the hot humid air inside the bus below its dew point, causing droplets of water to form on the inside of the window. Intrigued, Paton – a lighting engineer by profession – started rigging up his own equipment. ‘I made my own solar stills It occurred to me that you might be able to produce water in this way in the desert, simply by cooling the air. I wondered whether you could make enough to irrigate fields and grow crops.’\\n\\n**Paragraph C.**\\nToday, a decade on, his dream has taken shape as a giant greenhouse on a desert island off Abu Dhabi in the Persian Gulf – the first commercially viable version of his ‘seawater greenhouse’. Local scientists, working with Paton, are watering the desert and growing vegetables in what is basically a giant dew-making machine that produces freshwater and cool air from sun and seawater. In awarding Paton first prize in a design competition two years ago, Marco Goldschmied, president of the Royal Institute of British Architects, called it ‘a truly original idea which has the potential to impact on the lives of millions of people living in coastal water-starved areas around the world’.\\n\\n**Paragraph D.**\\nThe seawater greenhouse as developed by Paton has three main parts. They both air-condition the greenhouse and provide water for irrigation. The front of the greenhouse faces into the prevailing wind so that hot dry air blows in through a front wall. The wall is made of perforated cardboard kept moist by a constant trickle of seawater pumped up from the ocean. The purpose is to cool and moisten the incoming desert air. The cool moist air allows the plants to grow faster. And, crucially, because much less water evaporates from the leaves, the plants need much less moisture to grow than if they were being irrigated in the hot dry desert air outside the greenhouse.\\n\\n**Paragraph E.**\\nThe air-conditioning of the interior of the greenhouse is completed by the second feature: the roof. It has two layers: an outer layer of clear polyethylene and an inner coated layer that reflects infrared radiation. This combination ensures that visible light can stream through to the plants, maximizing the rate of plant growth through photosynthesis but at the same time heat from the infrared radiation is trapped in the space between the layers, and kept away from the plants. This helps keep the air around the plants cool.\\n\\n**Paragraph F.**\\nAt the back of the greenhouse sits the third elements. This is the main water production unit. Here, the air hits a second moist cardboard wall that increases its humidity as it reaches the condenser, which finally collects from the hot humid air the moisture for irrigating the plants. The condenser is a metal surface kept cool by still more seawater. It is the equivalent of the window on Paton’s Morcoccan bus. Drops of pure distilled water from on the condenser and flow into a tank for irrigating the crops.\\n\\n**Paragraph G.**\\nThe Abu Dhai greenhouse more or less runs itself. Sensors switch everything on when the sun rises and alter flows of air and seawater through the day in response to changes in temperature, humidity, and sunlight. On windless days, fans ensure a constant flow of air through the greenhouse. ‘Once it is turned to the local environment, you don’t need anymore there for it to work,’ says Paton. “We can run the entire operation of one 13-amp plug, and in the future, we could make it entirely independent of the grid, powered from a few solar panels.’\\n\\n**Paragraph H.**\\nCritics point out that construction costs of around $4 a square foot are quite high. By illustration, however, Paton presents that it can cool as efficiently as a 500-kilowatt air conditioner while using less than 3 kilowatts of electricity. Thus the plants need only an eighth of the volume of water used by those grown conventionally. And so the effective cost of the desalinated water in the greenhouse is only a quarter that of water from a standard desalinator, which is good economics. Besides it really suggests an environmentally-friendly way of providing air conditioning on a scale large enough to cool large greenhouses where crops can be grown despite the high outside temperatures.\\n\\n'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    27,
    'YES_NO_NOT_GIVEN',
    'READING',
    2,
    'The idea just came to Charlie Paton by accident.',
    '',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'YES', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'NO', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'NOT GIVEN', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    28,
    'YES_NO_NOT_GIVEN',
    'READING',
    2,
    'The bus was well ventilated.',
    '',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'YES', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'NO', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'NOT GIVEN', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    29,
    'YES_NO_NOT_GIVEN',
    'READING',
    2,
    'After waking up, Paton found his towel was wet.',
    '',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'YES', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'NO', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'NOT GIVEN', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    30,
    'YES_NO_NOT_GIVEN',
    'READING',
    2,
    'The fan on the bus did not work well.',
    '',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'YES', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'NO', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'NOT GIVEN', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    31,
    'YES_NO_NOT_GIVEN',
    'READING',
    2,
    'Paton immediately operated his own business in the Persian Gulf after talking with Philip Davies.',
    '',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'YES', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'NO', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'NOT GIVEN', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    32,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    '_______',
    '',
    '{"blank-q32": []}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    33,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    '_______',
    '',
    '{"blank-q33": []}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    34,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    '_______',
    '',
    '{"blank-q34": []}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    35,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    '_______',
    '',
    '{"blank-q35": []}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    36,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    '_______',
    '',
    '{"blank-q36": []}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    37,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    'When there is no wind, _______ help to retain the flow of air.',
    '',
    '{"blank-q37": []}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    38,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    'Even in the future, we have an ideal plan to power the greenhouse from _______ .',
    '',
    '{"blank-q38": []}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    39,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    'However, there are still some critics who argue that _______ are not good economics.',
    '',
    '{"blank-q39": []}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    40,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    'To justify himself, Paton presents favorable arguments against these critics and suggests that it is an _______ approach to provide air conditioning in a scale large sense.',
    '',
    '{"blank-q40": []}'::jsonb
  );



  -- Delete old question groups for this exam
  DELETE FROM exam_question_groups WHERE "SectionId" = sec1;

  -- Insert question groups
  INSERT INTO exam_question_groups ("Id","SectionId","Idx","StartIdx","EndIdx","InstructionMd")
  VALUES (gen_random_uuid(), sec1, 1, 27, 31, E'## Questions 27-31\n\nDo the following statements agree with the claims of the writer?\n\nWrite\n- **YES** if the statement agrees with the claims of the writer\n- **NO** if the statement contradicts the claims of the writer\n- **NOT GIVEN** if it is impossible to say what the writer thinks about this\n\n---\n\n');

  INSERT INTO exam_question_groups ("Id","SectionId","Idx","StartIdx","EndIdx","InstructionMd")
  VALUES (gen_random_uuid(), sec1, 2, 32, 40, E'## Questions 32-40\n\nComplete the sentences below.\n\nWrite **NO MORE THAN TWO WORDS AND/OR A NUMBER** for each answer.\n\n![Diagram](http://images.mini-ielts.com/images/2018/2021/the-rainmaker-design.jpg)\n\n**32.** _______\n\n**33.** _______\n\n**34.** _______\n\n**35.** _______\n\n**36.** _______\n\n**37.** When there is no wind, _______ help to retain the flow of air.\n\n**38.** Even in the future, we have an ideal plan to power the greenhouse from _______ .\n\n**39.** However, there are still some critics who argue that _______ are not good economics.\n\n**40.** To justify himself, Paton presents favorable arguments against these critics and suggests that it is an _______ approach to provide air conditioning in a scale large sense.');

END$$;


COMMIT;