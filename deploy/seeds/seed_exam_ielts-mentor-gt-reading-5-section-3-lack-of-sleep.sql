-- ============================================
-- IELTS Exam Data Import SQL
-- Generated: 2025-12-21T11:33:21.640029
-- Source: ielts-mentor.com
-- Title: GT Reading 5 Section 3 - Lack of sleep
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data for slug: ielts-mentor-gt-reading-5-section-3-lack-of-sleep
DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-mentor-gt-reading-5-section-3-lack-of-sleep'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-mentor-gt-reading-5-section-3-lack-of-sleep';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-mentor-gt-reading-5-section-3-lack-of-sleep';
DELETE FROM exams
WHERE "Slug" = 'ielts-mentor-gt-reading-5-section-3-lack-of-sleep';

DO $$
DECLARE
  exam_id uuid := gen_random_uuid();
  sec1 uuid := gen_random_uuid();
  qid uuid;
BEGIN

  INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","UpdatedAt")
  VALUES (
    exam_id,
    'ielts-mentor-gt-reading-5-section-3-lack-of-sleep',
    'GT Reading 5 Section 3 - Lack of sleep',
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
    'Reading Passage - GT Reading 5 Section 3 - Lack of sleep',
    E'**Questions 28-35:**\nThe passage has seven sections labelled **A-G**.\nWhich section contains the following information?\n\nWrite the correct letter, **A-G**.\n\n*NB You may use any letter more than once.*\n\n---\n\n**Questions 36-40:**\nDo the following statements agree with the information given in the passage?\n\nWrite\n- **TRUE** if the statement agrees with the information\n- **FALSE** if the statement contradicts the information\n- **NOT GIVEN** if there is no information on this\n\n---\n\n# LACK OF SLEEP\n\n**Paragraph A.**\nIt is estimated that the average man or woman needs between seven-and-a-half and eight hours'' sleep a night. Some can manage on a lot less. Baroness Thatcher, for example, was reported to be able to get by on four hours'' sleep a night when she was Prime Minister of Britain. Dr Jill Wilkinson, senior lecturer in psychology at Surrey University and co-author of ''Psychology in Counselling and Therapeutic Practice'', states that healthy individuals sleeping less than five hours or even as little as two hours in every 24 hours are rare, but represent a sizeable minority.\n\n**Paragraph B.**\nThe latest beliefs are that the main purposes of sleep are to enable the body to rest and replenish, allowing time for repairs to take place and for tissue to be regenerated. One supporting piece of evidence for this rest-and-repair theory is that production of the growth hormone somatotropin, which helps tissue to regenerate, peaks while we are asleep. Lack of sleep, however, can compromise the immune system, muddle thinking, cause depression, promote anxiety and encourage irritability.\n\n**Paragraph C.**\nResearchers in San Diego deprived a group of men of sleep between 3am and 7am on just one night, and found that levels of their bodies'' natural defences against viral infections had fallen significantly when measured the following morning. ''Sleep is essential for our physical and emotional well-being and there are few aspects of daily living that are not disrupted by the lack of it'', says Professor William Regelson of Virginia University, a specialist in insomnia. ''Because it can seriously undermine the functioning of the immune system, sufferers are vulnerable to infection.''\n\n**Paragraph D.**\nFor many people, lack of sleep is rarely a matter of choice. Some have problems getting to sleep, others with staying asleep until the morning. Despite popular belief that sleep is one long event, research shows that, in an average night, there are five stages of sleep and four cycles, during which the sequence of stages is repeated. In the first light phase, the heart rate and blood pressure go down and the muscles relax. In the next two stages, sleep gets progressively deeper. In stage four, usually reached after an hour, the slumber is so deep that, if awoken, the sleeper would be confused and disorientated. It is in this phase that sleep-walking can occur, with an average episode lasting no more than 15 minutes.\n\nIn the fifth stage, the rapid eye movement (REM) stage, the heartbeat quickly gets back to normal levels, brain activity accelerates to daytime heights and above and the eyes move constantly beneath closed lids as if the sleeper is looking at something. During this stage, the body is almost paralysed. This REM phase is also the time when we dream.\n\n**Paragraph E.**\nSleeping patterns change with age, which is why many people over 60 develop insomnia. In America, that age group consumes almost half the sleep medication on the market. One theory for the age-related change is that it is due to hormonal changes. The temperature rise occurs at daybreak in the young, but at three or four in the morning in the elderly. Age aside, it is estimated that roughly one in three people suffer some kind of sleep disturbance. Causes can be anything from pregnancy and stress to alcohol and heart disease. Smoking is a known handicap to sleep, with one survey showing that ex-smokers got to sleep in 18 minutes rather than their earlier average of 52 minutes.\n\n**Paragraph F.**\nApart from self-help therapy such as regular exercise, there are psychological treatments, including relaxation training and therapy aimed at getting rid of pre-sleep worries and anxieties. There is also sleep reduction therapy, where the aim is to improve sleep quality by strictly regulating the time people go to bed and when they get up. Medication is regarded by many as a last resort and often takes the form of sleeping pills, normally benzodiazepines, which are minor tranquillizers.\n\n**Paragraph G.**\nProfessor Regelson advocates the use of melatonin for treating sleep disorders. Melatonin is a naturally secreted hormone, located in the pineal gland deep inside the brain. The main function of the hormone is to control the body''s biological clock, so we know when to sleep and when to wake. The gland detects light reaching it through the eye; when there is no light, it secretes the melatonin into the bloodstream, lowering the body temperature and helping to induce sleep. Melatonin pills contain a synthetic version of the hormone and are commonly used for jet lag as well as for sleep disturbance. John Nicholls, sales manager of one of America''s largest health food shops, claims that sales of the pill have increased dramatically. He explains that it is sold in capsules, tablets, lozenges and mixed with herbs. It is not effective for all insomniacs, but many users have weaned themselves off sleeping tablets as a result of its application.'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    28,
    'MATCHING_INFORMATION',
    'READING',
    2,
    'the different amounts of sleep that people require',
    'Choose the correct answer.',
    '{"info-q28": ["A", "a"]}'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    29,
    'MATCHING_INFORMATION',
    'READING',
    2,
    'an investigation into the results of sleep deprivation',
    'Choose the correct answer.',
    '{"info-q29": ["C", "c"]}'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    30,
    'MATCHING_INFORMATION',
    'READING',
    2,
    'some reasons why people may suffer from sleep disorders',
    'Choose the correct answer.',
    '{"info-q30": ["E", "e"]}'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    31,
    'MATCHING_INFORMATION',
    'READING',
    2,
    'lifestyle changes which can help overcome sleep-related problems',
    'Choose the correct answer.',
    '{"info-q31": ["F", "f"]}'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    32,
    'MATCHING_INFORMATION',
    'READING',
    2,
    'a process by which sleep helps us to remain mentally and physically healthy',
    'Choose the correct answer.',
    '{"info-q32": ["B", "b"]}'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    33,
    'MATCHING_INFORMATION',
    'READING',
    2,
    'claims about a commercialised man-made product for sleeplessness',
    'Choose the correct answer.',
    '{"info-q33": ["G", "g"]}'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    34,
    'MATCHING_INFORMATION',
    'READING',
    2,
    'the role of physical changes in sleeping habits',
    'Choose the correct answer.',
    '{"info-q34": ["E", "e"]}'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    35,
    'MATCHING_INFORMATION',
    'READING',
    2,
    'the processes involved during sleep',
    'Choose the correct answer.',
    '{"info-q35": ["D", "d"]}'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    36,
    'TRUE_FALSE_NOT_GIVEN',
    'READING',
    2,
    'Sleep can cure some illnesses.',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'TRUE', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'FALSE', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'NOT GIVEN', true);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    37,
    'TRUE_FALSE_NOT_GIVEN',
    'READING',
    2,
    'The various stages of sleep occur more than once a night.',
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
    38,
    'TRUE_FALSE_NOT_GIVEN',
    'READING',
    2,
    'Dreaming and sleep-walking occur at similar stages of sleep.',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'TRUE', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'FALSE', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'NOT GIVEN', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    39,
    'TRUE_FALSE_NOT_GIVEN',
    'READING',
    2,
    'Sleepers move around a lot during the REM stage of sleep.',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'TRUE', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'FALSE', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'NOT GIVEN', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    40,
    'TRUE_FALSE_NOT_GIVEN',
    'READING',
    2,
    'The body temperature rises relatively early in elderly people.',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'TRUE', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'FALSE', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'NOT GIVEN', false);


END$$;


COMMIT;