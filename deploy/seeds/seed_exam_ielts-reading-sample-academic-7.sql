-- ============================================
-- IELTS Exam Data Import SQL
-- Generated: 2025-12-20T12:04:38.436209
-- Source: ielts-writing.info
-- Title: IELTS Reading Sample (Academic) #7
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data for slug: ielts-reading-ielts-reading-sample-academic-7
DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-ielts-reading-sample-academic-7'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-ielts-reading-sample-academic-7';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-ielts-reading-sample-academic-7';
DELETE FROM exams
WHERE "Slug" = 'ielts-reading-ielts-reading-sample-academic-7';

DO $$
DECLARE
  exam_id uuid := gen_random_uuid();
  sec1 uuid := gen_random_uuid();
  qid uuid;
BEGIN

  INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","UpdatedAt")
  VALUES (
    exam_id,
    'ielts-reading-ielts-reading-sample-academic-7',
    'IELTS Reading Sample (Academic) #7',
    'IELTS Reading Practice Test: IELTS Reading Sample (Academic) #7',
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
    'Reading Passage - IELTS Reading Sample (Academic) #7',
    E'# Passage\n\nAcademic Reading 24 - Passage 1\nBy Laura Carlsen, The New Internationalist | December 1, 2004\nMaize is Mexico’s lifeblood – the country’s history and identity are entwined with it. But this centuries-old relationship is now threatened by free trade. Laura Carlsen investigates the threat and profiles a growing activist movement.\nOn a mountain top in southern Mexico, Indian families gather. They chant and sprinkle cornmeal in consecration, praying for the success of their new crops, the unity of their communities and the health of their families. In this village in Oaxaca people eat corn tamales, sow maize plots and teach children to care for the plant. The cultural rhythms of this community, its labours, rituals and celebrations will be defined – as they have been for millennia – by the lifecycle of corn. Indeed, if it weren’t for the domestication of teocintle (the ancestor of modern maize) 9,000 years ago mesoamerican civilization could never have developed. In the Mayan sacred book, the Popol Vuh, the gods create people out of cornmeal. The ‘people of corn’ flourished and built one of the most remarkable cultures in human history.\nBut in Mexico and Central America today maize has come under attack. As a result of the North American Free Trade Agreement (NAFTA) Mexico has been flooded with imported corn from north of the border in the US. The contamination of native varieties with genetically modified imported maize could have major consequences for Mexican campesinos (farmers), for local biodiversity and for the world’s genetic reserves.\nA decade ago Mexican bureaucrats and business people had it all figured out. NAFTA would drive ‘uncompetitive’ maize farmers from the countryside to work in booming assembly factories across the country. Their standard of living would rise as the cost of providing services like electricity and water to scattered rural communities would fall. Best of all, cheap imported maize from the US – the world’s most efficient and most heavily subsidized producer – would be a benefit to Mexican consumers.\nUnfortunately, it didn’t turn out that way. There weren’t quite enough of those factory jobs and the ones that did materialize continued to be along the US border, not further in Mexico. And despite a huge drop in the price farmers received for their corn, consumers often ended up paying more. The price of tortillas – the country’s staple food – rose nearly fivefold as the Government stopped domestic subsidies and giant agribusiness firms took over the market. Free trade defenders like Mexico’s former Under-Secretary of Agriculture Luis Tellez suggest: ‘It’s not that NAFTA failed, it’s just that reality didn’t turn out the way we planned it.’ Part of that reality was that the Government did nothing to help campesinos in the supposed transition. Nor did NAFTA recognize inequalities or create compensation funds to help the victims of free trade – unlike what occurred with economic integration in the European Union.\nBasically, Mexico adopted a sink-or-swim policy for small farmers, opening the floodgates to tons of imported US corn. Maize imports tripled under NAFTA and producer prices fell by half. The drop in income immediately hit the most vulnerable and poorest members of rural society. While more than a third of the corn grown by small farmers is used to feed their families, the rest is sold on local markets. Without this critical cash, rural living standards plunged.\nMaize is at the heart of indigenous and campesino identity. José Carrillo de la Cruz, a Huichol Indian from northern Jalisco, describes that relationship: ‘Corn is the force, the life and the strength of the Huichol. If there were a change, if someone from outside patented our corn, it would end our life and existence.’\nThe good news is that the free-trade threat to Mexico’s culture and food security has sparked a lively resistance. ‘In Defence of Corn’, a movement to protect local maize varieties, is not a membership organization but a series of forums and actions led by campesinos themselves. It’s a direct challenge to both free trade and the dictums of corporate science.\nThe farmers’ tenacity and refusal to abandon the crop of their ancestors is impressive. But larger economic conditions continue to shape their lives. Rural poverty and hunger have soared under free trade – and placed a heavier burden on women left to work the land. The battle for food sovereignty continues. Movement leaders insist that the Government reassess its free trade policies and develop a real rural development programme.\n\n.'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    1,
    'YES_NO_NOT_GIVEN',
    'READING',
    2,
    'After NAFTA, a lot of corn from the USA has been sold in Mexico.',
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
    2,
    'YES_NO_NOT_GIVEN',
    'READING',
    2,
    'Following NAFTA, Mexican business people tried to stop maize farmers from working in factories throughout the country.',
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
    3,
    'YES_NO_NOT_GIVEN',
    'READING',
    2,
    'The Mexican farmers were paid a lot less for their corn after NAFTA.',
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
    4,
    'YES_NO_NOT_GIVEN',
    'READING',
    2,
    'Many Mexican farmers wanted to leave Mexico after the Free Trade Agreement.',
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
    5,
    'YES_NO_NOT_GIVEN',
    'READING',
    2,
    'The Mexican farmers were not able to do anything to help themselves after the Trade Agreement.',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'YES', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'NO', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'NOT GIVEN', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    6,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    'Questions (...) - (...) Complete the notes below. Choose ONE WORD AND/OR A NUMBER from the passage for each answer. Write your answers in boxes (...) - (...) on your answer sheet.\n\nFor thousands of years, corn has been a very important 6 in the Mexican culture. After the North American Free Trade Agreement, 7 corn has been imported from the USA in very large amounts. Mexican business people hoped that this would mean that Mexican farmers had to get jobs in factories and that t _______',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank. The answer must fit grammatically.',
    '{"blank-q6": ["crop"]}'::jsonb
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
    'Questions (...) - (...) Complete the notes below. Choose ONE WORD AND/OR A NUMBER from the passage for each answer. Write your answers in boxes (...) - (...) on your answer sheet.\n\nFor thousands of years, corn has been a very important 6 in the Mexican culture. After the North American Free Trade Agreement, 7 corn has been imported from the USA in very large amounts. Mexican business people hoped that this would mean that Mexican farmers had to get jobs in factories and that t _______',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank. The answer must fit grammatically.',
    '{"blank-q7": ["genetically modified"]}'::jsonb
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
    'Questions (...) - (...) Complete the notes below. Choose ONE WORD AND/OR A NUMBER from the passage for each answer. Write your answers in boxes (...) - (...) on your answer sheet.\n\nFor thousands of years, corn has been a very important 6 in the Mexican culture. After the North American Free Trade Agreement, 7 corn has been imported from the USA in very large amounts. Mexican business people hoped that this would mean that Mexican farmers had to get jobs in factories and that t _______',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank. The answer must fit grammatically.',
    '{"blank-q8": ["standard of living"]}'::jsonb
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
    'Questions (...) - (...) Complete the notes below. Choose ONE WORD AND/OR A NUMBER from the passage for each answer. Write your answers in boxes (...) - (...) on your answer sheet.\n\nFor thousands of years, corn has been a very important 6 in the Mexican culture. After the North American Free Trade Agreement, 7 corn has been imported from the USA in very large amounts. Mexican business people hoped that this would mean that Mexican farmers had to get jobs in factories and that t _______',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank. The answer must fit grammatically.',
    '{"blank-q9": ["helped"]}'::jsonb
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
    'Questions (...) - (...) Complete the notes below. Choose ONE WORD AND/OR A NUMBER from the passage for each answer. Write your answers in boxes (...) - (...) on your answer sheet.\n\nFor thousands of years, corn has been a very important 6 in the Mexican culture. After the North American Free Trade Agreement, 7 corn has been imported from the USA in very large amounts. Mexican business people hoped that this would mean that Mexican farmers had to get jobs in factories and that t _______',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank. The answer must fit grammatically.',
    '{"blank-q10": ["movement"]}'::jsonb
  );


END$$;


COMMIT;