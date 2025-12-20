-- ============================================
-- IELTS Exam Data Import SQL
-- Generated: 2025-12-20T12:02:51.728938
-- Source: ielts-writing.info
-- Title: IELTS Reading Sample (Academic) #26
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data for slug: ielts-reading-ielts-reading-sample-academic-26
DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-ielts-reading-sample-academic-26'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-ielts-reading-sample-academic-26';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-ielts-reading-sample-academic-26';
DELETE FROM exams
WHERE "Slug" = 'ielts-reading-ielts-reading-sample-academic-26';

DO $$
DECLARE
  exam_id uuid := gen_random_uuid();
  sec1 uuid := gen_random_uuid();
  qid uuid;
BEGIN

  INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","UpdatedAt")
  VALUES (
    exam_id,
    'ielts-reading-ielts-reading-sample-academic-26',
    'IELTS Reading Sample (Academic) #26',
    'IELTS Reading Practice Test: IELTS Reading Sample (Academic) #26',
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
    'Reading Passage - IELTS Reading Sample (Academic) #26',
    E'# Passage\n\nIELTS Reading Academic 26\nOn the move\nEconomic analysis sheds light on the history of migration and on its future\nA.\nDURING successive waves of globalisation in the three centuries leading up to the first world war, migration of labour was consistently one of the biggest drivers of economic change. Since 1945 the world has experienced a new era of accelerating globalisation, and the international movement of labour is proving once again to be of the greatest economic and social significance. As a new study by Barry Chiswick of the University of Illinois at Chicago and Timothy Hatton of the University of Essex makes plain, it is economic factors that have been uppermost throughout the history of migration.\nB.\nFor many years after the discovery of America, the flow of, free migrants from Europe was steady but quite small: transport costs were high, conditions harsh and the dangers of migration great. In 1650 a free migrant''s passage to North America cost nearly half a year''s wages for a farm labourer in southern England. Slavery predominated until the slave trade was stopped in the first half of the 19th century. By around 1800, North America and the Caribbean islands had received some 8m immigrants. Of these, about 7m were African slaves.\nC.\nThe first era of mass voluntary migration was between 1850 and 1913. Over 1m people a year were drawn to the new world by the turn of the 20th century. Growing prosperity; falling transport costs and lower risk all pushed in the same direction. Between 1914 and 1945, war, global depression and government policy reduced migration. During some years in the 1930s, people returning to Europe from the United States, even though comparatively few, actually outnumbered immigrants going the other way. After the second world war the cost of travel fell steeply. But now the pattern changed. Before long Europe declined as a source of immigration and grew as a destination. Emigration from developing countries expanded rapidly: incomes there rose enough to make emigration feasible, but not enough to make it pointless. Many governments began trying to control immigration. Numbers, legal and illegal, surged nonetheless, as economics had its way.\nD.\nMigration, it is safe to assume, is in the interests of (voluntary) migrants: they would not move otherwise. The evidence suggests that it is also very much in the overall interests of the receiving countries. But, as Mr Chiswick and Mr Hatton point out, there are losers in those countries. The increase in the supply of labour means that the wages of competing workers may fall, at least to start with.\nE.\nThe economic conditions now seem propitious for an enormous further expansion of migration. On the face of it, this will be much like that of a century ago. As before, the main expansionary pressures arc rising incomes in the rich countries and rising incomes in the poor ones. (This second point is often neglected: as poor countries get a little less poor, emigration tends to increase, because people acquire the means to move.) The study emphasises, however, two crucial differences between then and now.\nF.\nOne is that, in the first decade of the 20th century, the receiving countries needed lots of unskilled workers in industry and farming. In the first decade of the 21st century, in contrast, opportunities for unskilled workers are dwindling. In the United States, wages of unskilled workers are falling. The fall is enough to hurt the workers concerned, but not to deter new immigrants.\nG.\nAnd the other big difference between now and a century ago? It is that the affected rich-country workers are in a stronger position to complain, and get something done. The most likely result is that a trend that is already well established will continue: countries will try to restrict the immigration of unskilled workers, giving preference to workers with skills.\nH.\nThis does help, in one way, quite apart from narrowing the rich countries'' shortage of skilled workers: it reduces the pressure to make low wages even lower. However, the idea has drawbacks too. It turns away many of the poorest people who want to migrate, which is hard to justify in humanitarian terms. Also, it pushes others from this group into illegal immigration, which exposes them to dangers, makes integration more difficult and may even make the wages of low-paid workers even lower than if the same migrants entered legally. On top of all this is the loss of skilled workers in the sending countries. Already some of the world''s poorest nations lose almost all the doctors they train to jobs in Europe or North America. Money immigrants send home offsets some of that loss, but not all.\nI.\nToday''s migration, much more than the migration of old, poses some insoluble dilemmas. Belief in individual freedom suggests that rich countries should adopt more liberal immigration rules, both for unskilled migrants and skilled ones. With or without such rules, more migrants are coming. And in either case, the question of compensation for the losers, in rich countries and poor countries alike, will demand some attention.\n\n.'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    1,
    'MULTIPLE_CHOICE_MULTIPLE',
    'READING',
    2,
    'WhichTHREEeffects are mentioned inthe passage?',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. It is more difficult for illegal immigrants to integrate.', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. Jobs in sending countries become more secure.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. More unskilled workers immigrate illegally.', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D. Unskilled workers in receiving countries may become poorer.', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, 'E. Workers in rich countries complain.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 6, 'F. Skilled workers may lose their jobs.', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    2,
    'MULTIPLE_CHOICE_MULTIPLE',
    'READING',
    2,
    'WhichTWOreasons are mentioned inthe passage?',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. Immigrants send money back to their country of origin.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. Immigration in greater numbers is inevitable.', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. It would be ethically correct.', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D. It would ease population pressures in poor countries.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, 'E. Rich countries need more skilled workers.', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    3,
    'MATCHING_INFORMATION',
    'READING',
    2,
    'Changing departure points and destinations for migrants',
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
    'Disadvantages of present immigration policies',
    'Choose the correct answer.',
    '{"info-q4": ["H", "h"]}'
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
    'The immigrants who rich countries find more acceptable',
    'Choose the correct answer.',
    '{"info-q5": ["G", "g"]}'
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
    'How earning more money affects migration',
    'Choose the correct answer.',
    '{"info-q6": ["E", "e"]}'
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
    'Migration was mainly compulsory',
    'Choose the correct answer.',
    '{"info-q7": ["B", "b"]}'
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
    'Changing the laws on immigration',
    'Choose the correct answer.',
    '{"info-q8": ["I", "i"]}'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    9,
    'MULTIPLE_CHOICE_SINGLE',
    'READING',
    2,
    'Pressure to migrate is increasing now because',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'Aeconomic conditions have become more desperate.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'Bimmigration restrictions are being relaxed.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'Cpeople generally earn more.', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'Dthere is a greater need for unskilled workers.', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    10,
    'MULTIPLE_CHOICE_SINGLE',
    'READING',
    2,
    'Lower incomes for unskilled workers in receiving countries have',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'Aencouraged countries to import skilled workers.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'Bled to protests about immigration.', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'Creduced the amount of money immigrants send home.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'Dprovided opportunities for immigrants in manufacturing and agriculture.', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    11,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    'Questions (...) - (...) Complete the notes below. Choose ONE WORD AND/OR A NUMBER from the passage for each answer. Write your answers in boxes (...) - (...) on your answer sheet.\n\n1 Until the early 19th century the majority of migrants to North America were _______ .',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank. The answer must fit grammatically.',
    '{"blank-q11": ["slaves", "African slaves"]}'::jsonb
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
    'Questions (...) - (...) Complete the notes below. Choose ONE WORD AND/OR A NUMBER from the passage for each answer. Write your answers in boxes (...) - (...) on your answer sheet.\n\n2 However, in the second half of the 19th century, _______ and cheaper travel meant that more people could afford to emigrate voluntarily.',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank. The answer must fit grammatically.',
    '{"blank-q12": ["growing prosperity", "rising incomes"]}'::jsonb
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
    'Questions (...) - (...) Complete the notes below. Choose ONE WORD AND/OR A NUMBER from the passage for each answer. Write your answers in boxes (...) - (...) on your answer sheet.\n\n3 At the beginning of the 20th century, immigrants to receiving countries found jobs as _______ in factories and on farms.',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank. The answer must fit grammatically.',
    '{"blank-q13": ["unskilled workers"]}'::jsonb
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
    'Questions (...) - (...) Complete the notes below. Choose ONE WORD AND/OR A NUMBER from the passage for each answer. Write your answers in boxes (...) - (...) on your answer sheet.\n\n4 After the second world war there was a great increase in emigrants from _______ .',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank. The answer must fit grammatically.',
    '{"blank-q14": ["developing countries"]}'::jsonb
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
    'Questions (...) - (...) Complete the notes below. Choose ONE WORD AND/OR A NUMBER from the passage for each answer. Write your answers in boxes (...) - (...) on your answer sheet.\n\n5 Nowadays, receiving countries generally prefer immigrants _______ .',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank. The answer must fit grammatically.',
    '{"blank-q15": ["with skills"]}'::jsonb
  );


END$$;


COMMIT;