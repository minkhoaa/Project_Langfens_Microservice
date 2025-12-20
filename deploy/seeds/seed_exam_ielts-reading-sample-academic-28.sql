-- ============================================
-- IELTS Exam Data Import SQL
-- Generated: 2025-12-20T12:02:39.056193
-- Source: ielts-writing.info
-- Title: IELTS Reading Sample (Academic) #28
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data for slug: ielts-reading-ielts-reading-sample-academic-28
DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-ielts-reading-sample-academic-28'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-ielts-reading-sample-academic-28';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-ielts-reading-sample-academic-28';
DELETE FROM exams
WHERE "Slug" = 'ielts-reading-ielts-reading-sample-academic-28';

DO $$
DECLARE
  exam_id uuid := gen_random_uuid();
  sec1 uuid := gen_random_uuid();
  qid uuid;
BEGIN

  INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","UpdatedAt")
  VALUES (
    exam_id,
    'ielts-reading-ielts-reading-sample-academic-28',
    'IELTS Reading Sample (Academic) #28',
    'IELTS Reading Practice Test: IELTS Reading Sample (Academic) #28',
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
    'Reading Passage - IELTS Reading Sample (Academic) #28',
    E'# Passage\n\nIELTS Reading Academic 28\nPrivate Space\nA.\nIt''s a remarkable achievement: the question is no longer ''How can we send humans into space?'' but ''How can we keep them there?'' Spaceflight is reaching a turning point where new technologies in engine development, better understanding of aerodynamics and materials for body construction are making spaceflight possible for private industry.\nB.\nThe history of space exploration, until relatively recently, has been one of big government-backed projects like the Space Shuttle, Mars Landers and Long March rockets. But the most recent launches to the International Space Station (ISS) have been very special for at least three reasons. Firstly, along with 450 kg of scientific equipment, food and clothes, the rocket was carrying ice cream for the three space station astronauts. Secondly, the rocket was unmanned, being guided into docking position and back to earth again by remote control and automated systems. Finally, the rocket was commissioned from a private company by NASA.\nC.\nWhen the privately owned rocket delivered its goods to the ISS, it marked a milestone in the evolution of space flight and vindicated NASA''s decision to delegate routine supply flights to the space station. The flight has been a long time in development. It started with President George W Bush announcing his Vision for Space Exploration, calling for the ISS to be completed. Under the next President, America''s Space Shuttles were retired leaving NASA with no other choice but to look for alternative methods of supplying the ISS. The initiative was part of an effort to commercialise the space industry in order to decrease costs and spread the investment in the industry across a wider group than governments.\nD.\nThe initiative had many attractions for NASA. By outsourcing to the private sector the routine business of taking food and equipment to and from low-earth orbit, NASA can theoretically free up money to do things that it really wants to prioritise: missions such as sending astronauts to Mars and landing on asteroids by the 2030s. Now that the Space Exploration Technologies Corporation (spaceX) has proved that private enterprise can be players in space exploration, firms are pouring money into developing new spacecraft built to transport cargo, to mine asteroids and to carry passengers into space.\nE.\nIn the last half of the twentieth century only government-backed agencies like NASA and Russia''s ROSCOSMOS were capable of running space programmes due to the gigantic investment costs and uncertain payoffs. However, SpaceX and similar companies are proving that the former conditions are no longer relevant as new solutions are coming to light. Commercial companies like Boeing are able to raise large sums of money to run these projects. Furthermore, as the firms are running cargo and taxi services to lower orbits, the break-even point is lower, the technology is cheaper and they have the benefit of years of experience in commercial aviation and space flight. Opening space programmes to the commercial sector has the additional advantage of generating more solutions to old problems. An analogy is the invention of the Internet. when the technology went into the commercial sector, no one could have envisioned the development of social network sites. Likewise, no one can predict where commercial enterprise will take the space industry.\nF.\nThe uncertainty surrounding where the space industry will end up is a problem as well as an asset and it is unsettling private investors who like to invest in relatively certain prospects. At the moment the industry is dominated by big-spending billionaires like the owner of SpaceX. In addition, the relatively small number of companies in the area could pose a problem in the future. The commercial space industry is still very new and there is no guarantee that progress will be smoother. For one thing, no one is sure that the business model is sound: government is still the major, if not only, customer available to the private space companies. The other problem is that space travel is high risk: the loss of space shuttles Challenger in 1986 and Columbia in 2003 illustrates that even the most carefully planned launches have unavoidable risks associated with them. The question is what would happen to the industry if another accident occurred. Finally, many space experts are doubtful that, even if private industry takes over the ''taxi'' role for low-orbit missions, NASA will be able to achieve its ambitions, given its squeezed budgets and history of being used for political purposes. Furthermore, NASA may have created another space race, this time between government and private industry. If NASA doesn''t go to Mars or the asteroid belt, its private competitors certainly have plans to do so.\nG.\nIn spite of all of these risks, many argue that it is critical for the private sector and federal government to work together to push further into space.\n\n.'
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
    'NASA being able to spend money on important projects',
    'Choose the correct answer.',
    '{"info-q1": ["D", "d"]}'
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
    'Events leading to the commercialisation of spaceflight',
    'Choose the correct answer.',
    '{"info-q2": ["C", "c"]}'
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
    'New developments that have made spaceflight more accessible',
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
    'An automated rocket that successfully completed a mission',
    'Choose the correct answer.',
    '{"info-q4": ["B", "b"]}'
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
    'The great dangers of space travel',
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
    'New answers being found to previous questions',
    'Choose the correct answer.',
    '{"info-q6": ["E", "e"]}'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    7,
    'MULTIPLE_CHOICE_SINGLE',
    'READING',
    2,
    'Which is NOT mentioned as making private space night possible?',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'Anew methods of constructing the rockets', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'Bmodern substances from which to build the rockets', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'Cunderstanding better how air moves round objects', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'Dnew methods of making space suits', true);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    8,
    'MULTIPLE_CHOICE_SINGLE',
    'READING',
    2,
    'Why are the recent launches special?',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. Their destination was the International Space Station.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. They carried clothes.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. They were not managed by a private company.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D. The rocket is not owned by a government.', true);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    9,
    'MULTIPLE_CHOICE_SINGLE',
    'READING',
    2,
    'In order to make NASA look for other spaceflight providers, the US government',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'Ainvested in private space companies.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'Bstarted to build the international space station.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'Cstopped using the Space Shuttle.', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'Dallowed private companies to fly into space.', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    10,
    'MULTIPLE_CHOICE_SINGLE',
    'READING',
    2,
    'Private companies',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'Aneed to reduce the cost of space projects.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'Bhave social network sites.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'Care able to fly rockets at high orbits.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'Dact as ferries to and from the space station.', true);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    11,
    'MULTIPLE_CHOICE_SINGLE',
    'READING',
    2,
    'At present, the private space industry is characterised by',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'Auncertainty about how to make profits.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'Bcompanies controlled by individuals.', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'Ccompanies too small to raise the amount of money needed.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'Dgovernment interference.', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    12,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    'Questions (...) - (...) Complete the notes below. Choose ONE WORD AND/OR A NUMBER from the passage for each answer. Write your answers in boxes (...) - (...) on your answer sheet.\n\nThere are a number of problems with commercial space projects. To start with, the _______ might not be sound. There is also great (...) attached to space flight - what would happen if there was another (...) ? Experts doubt whether NASA can fulfil its (...) as it has often been under (...) pressure. Moreover, the development may lead to a (...) between NASA and the private space industry.',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank. The answer must fit grammatically.',
    '{"blank-q12": ["business model"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    13,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    'Questions (...) - (...) Complete the notes below. Choose ONE WORD AND/OR A NUMBER from the passage for each answer. Write your answers in boxes (...) - (...) on your answer sheet.\n\nThere are a number of problems with commercial space projects. To start with, the (...) might not be sound. There is also great _______ attached to space flight - what would happen if there was another (...) ? Experts doubt whether NASA can fulfil its (...) as it has often been under (...) pressure. Moreover, the development may lead to a (...) between NASA and the private space industry.',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank. The answer must fit grammatically.',
    '{"blank-q13": ["risk"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    14,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    'Questions (...) - (...) Complete the notes below. Choose ONE WORD AND/OR A NUMBER from the passage for each answer. Write your answers in boxes (...) - (...) on your answer sheet.\n\nThere are a number of problems with commercial space projects. To start with, the (...) might not be sound. There is also great (...) attached to space flight - what would happen if there was another _______ ? Experts doubt whether NASA can fulfil its (...) as it has often been under (...) pressure. Moreover, the development may lead to a (...) between NASA and the private space industry.',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank. The answer must fit grammatically.',
    '{"blank-q14": ["accident"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    15,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    'Questions (...) - (...) Complete the notes below. Choose ONE WORD AND/OR A NUMBER from the passage for each answer. Write your answers in boxes (...) - (...) on your answer sheet.\n\nThere are a number of problems with commercial space projects. To start with, the (...) might not be sound. There is also great (...) attached to space flight - what would happen if there was another (...) ? Experts doubt whether NASA can fulfil its _______ as it has often been under (...) pressure. Moreover, the development may lead to a (...) between NASA and the private space industry.',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank. The answer must fit grammatically.',
    '{"blank-q15": ["ambitions"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    16,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    'Questions (...) - (...) Complete the notes below. Choose ONE WORD AND/OR A NUMBER from the passage for each answer. Write your answers in boxes (...) - (...) on your answer sheet.\n\nThere are a number of problems with commercial space projects. To start with, the (...) might not be sound. There is also great (...) attached to space flight - what would happen if there was another (...) ? Experts doubt whether NASA can fulfil its (...) as it has often been under _______ pressure. Moreover, the development may lead to a (...) between NASA and the private space industry.',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank. The answer must fit grammatically.',
    '{"blank-q16": ["political"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    17,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    'Questions (...) - (...) Complete the notes below. Choose ONE WORD AND/OR A NUMBER from the passage for each answer. Write your answers in boxes (...) - (...) on your answer sheet.\n\nThere are a number of problems with commercial space projects. To start with, the (...) might not be sound. There is also great (...) attached to space flight - what would happen if there was another (...) ? Experts doubt whether NASA can fulfil its (...) as it has often been under (...) pressure. Moreover, the development may lead to a _______ between NASA and the private space industry.',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank. The answer must fit grammatically.',
    '{"blank-q17": ["space race", "race"]}'::jsonb
  );


END$$;


COMMIT;