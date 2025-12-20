-- ============================================
-- IELTS Exam Data Import SQL
-- Generated: 2025-12-20T12:03:36.400757
-- Source: ielts-writing.info
-- Title: IELTS Reading Sample (Academic) #17
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data for slug: ielts-reading-ielts-reading-sample-academic-17
DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-ielts-reading-sample-academic-17'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-ielts-reading-sample-academic-17';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-ielts-reading-sample-academic-17';
DELETE FROM exams
WHERE "Slug" = 'ielts-reading-ielts-reading-sample-academic-17';

DO $$
DECLARE
  exam_id uuid := gen_random_uuid();
  sec1 uuid := gen_random_uuid();
  qid uuid;
BEGIN

  INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","UpdatedAt")
  VALUES (
    exam_id,
    'ielts-reading-ielts-reading-sample-academic-17',
    'IELTS Reading Sample (Academic) #17',
    'IELTS Reading Practice Test: IELTS Reading Sample (Academic) #17',
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
    'Reading Passage - IELTS Reading Sample (Academic) #17',
    E'# Passage\n\nAcademic Reading Passage 37\nHistory of the Steam Engine\nThe first steam-powered machine was built in 1698 by \n		the English military engineer Thomas Savery (c. 1650-1715). His invention, \n		designed to pump water out of coal mines, was known as the Miner''s Friend. \n		The machine, which had no moving parts, consisted of a simple boiler - a \n		steam chamber whose valves were located on the surface - and a pipe leading \n		to the water in the mine below. Water was heated in the boiler chamber until \n		its steam filled the chamber, forcing out any remaining water or air. The \n		valves were then closed and cold water was sprayed over the chamber. This \n		chilled and condensed the steam inside to form a vacuum. When the valves \n		were reopened, the vacuum sucked up the water from the mine, and the process \n		could then be repeated.\nA few years later, an English engineer named Thomas Newcomen \n		(1663-1729) improved the steam pump. He increased efficiency by setting \n		a moving piston inside a cylinder, a technique still in use today. A cylinder \n		- a long, thin, closed chamber separate from the boiler - replaced the large, \n		open boiler chamber. A piston - a sliding piece that fits in the cylinder \n		- was used to create motion instead of a vacuum. Steam filled the cylinder \n		from an open valve. When filled, the cylinder was sprayed with water, causing \n		the steam inside to condense into water and create a partial vacuum. The \n		pressure of the outside air then forced the piston down, producing a power \n		stroke. The piston was connected to a beam, which was connected to a water \n		pump at the bottom of the mine by a pump-rod. Through these connections, \n		the movement of the piston caused the water pump to suck up the water.\nThe most important improvement in steam engine \n		design was brought about by the Scottish engineer James Watt (1736-1819). \n		He set out to improve the performance of Newcomen''s engine and by 1769 had \n		arrived at the conclusion: if the steam were condensed separately from the \n		cylinder, the cylinder could always be kept hot. That year he introduced \n		the design of a steam engine that had a separate condenser and sealed cylinders. \n		Since this kept the heating and cooling processes separate, his machine \n		could work constantly, without any long pause at each cycle to reheat the \n		cylinder. Watt''s refined steam engine design\nused one-third less fuel than \n		a comparable Newcomen engine.\nOver the next 15 years, Watt continued to improve his \n		engine and made three significant additions. He introduced the centrifugal \n		governor, a device that could control steam output and engine speed. He \n		made the engine double-acting by allowing steam to enter alternately on \n		either side of the piston. This allowed the engine to work rapidly and deliver \n		power on the downward and upward piston stroke. Most important, he attached \n		a flywheel to the engine.\nFlywheels allow the engine to run more smoothly by creating \n		a more constant load, and they convert the conventional back-and-forth power \n		stroke into a circular (rotary) motion that can be adapted more readily \n		to power machinery. By 1790, Watt''s improved steam engine offered a powerful, \n		reliable power source that could be located almost anywhere. It was used \n		to pump bellows for blast furnaces, to power huge hammers for shaping and \n		strengthening forged metals, and to turn machinery at textile mills. More \n		than anything, it was Watt''s steam engine that speeded up the Industrial \n		Revolution both in England and the rest of the world.\nSteam was successfully adapted to powerboats in 1802 \n		and railways in 1829. Later, some of the first automobiles were powered \n		by steam. In the 1880s, the English engineer Charles A. Parsons (1854-1931) \n		produced the first steam turbine, a new steam technology that was more efficient \n		and which enabled the steam engine to evolve into a highly sophisticated \n		and powerful engine that propelled huge ships and ran turbogenerators that \n		supplied electricity.\nOnce the dominant power source, steam engines eventually \n		declined in popularity as other power sources became available. Although \n		there were more than 60,000 steam cars made in the United States between \n		1897 and 1927, the steam engine eventually gave way to the internal combustion \n		engine as a power source for vehicles.\n\n.'
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
    'His invention was the first to use moving parts.',
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
    'His invention allowed steam power to be converted into electric power.',
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
    'His invention was the single biggest step in development.',
    'Choose the correct answer.',
    '{"info-q3": ["C", "c"]}'
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
    'His invention was a simple solution to an industrial problem.',
    'Choose the correct answer.',
    '{"info-q4": ["A", "a"]}'
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
    'His invention was the first continuous power source.',
    'Choose the correct answer.',
    '{"info-q5": ["C", "c"]}'
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
    'His invention first used a method people still use now.',
    'Choose the correct answer.',
    '{"info-q6": ["B", "b"]}'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    7,
    'MATCHING_INFORMATION',
    'READING',
    2,
    'His invention allowed a much greater degree of control.',
    'Choose the correct answer.',
    '{"info-q7": ["C", "c"]}'
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
    'Questions (...) - (...) Complete the notes below. Choose ONE WORD AND/OR A NUMBER from the passage for each answer. Write your answers in boxes (...) - (...) on your answer sheet.\n\nThe Miner''s Friend used condensed steam to (8) _______ , which sucked water from mines.',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank. The answer must fit grammatically.',
    '{"blank-q8": ["form a vacuum"]}'::jsonb
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
    'Questions (...) - (...) Complete the notes below. Choose ONE WORD AND/OR A NUMBER from the passage for each answer. Write your answers in boxes (...) - (...) on your answer sheet.\n\nDesign improved: Newcomen (9) _______ using a piston and cylinder instead of an open boiler.',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank. The answer must fit grammatically.',
    '{"blank-q9": ["increased efficiency"]}'::jsonb
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
    'Questions (...) - (...) Complete the notes below. Choose ONE WORD AND/OR A NUMBER from the passage for each answer. Write your answers in boxes (...) - (...) on your answer sheet.\n\n1769: separating heating and cooling processes meant no (10) _______ between power strokes.',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank. The answer must fit grammatically.',
    '{"blank-q10": ["long pause", "pause"]}'::jsonb
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
    'Questions (...) - (...) Complete the notes below. Choose ONE WORD AND/OR A NUMBER from the passage for each answer. Write your answers in boxes (...) - (...) on your answer sheet.\n\nFurther development: became easier to (11) _______ through the use of the flywheel.',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank. The answer must fit grammatically.',
    '{"blank-q11": ["power machinery"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    12,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    'Questions (...) - (...) Complete the notes below. Choose ONE WORD AND/OR A NUMBER from the passage for each answer. Write your answers in boxes (...) - (...) on your answer sheet.\n\nNineteenth century: steam power (12) _______ for use in various means of transport.',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank. The answer must fit grammatically.',
    '{"blank-q12": ["successfully adapted", "adapted"]}'::jsonb
  );


END$$;


COMMIT;