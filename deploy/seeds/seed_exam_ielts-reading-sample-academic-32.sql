-- ============================================
-- IELTS Exam Data Import SQL
-- Generated: 2025-12-20T12:02:22.964367
-- Source: ielts-writing.info
-- Title: IELTS Reading Sample (Academic) #32
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data for slug: ielts-reading-ielts-reading-sample-academic-32
DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-ielts-reading-sample-academic-32'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-ielts-reading-sample-academic-32';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-ielts-reading-sample-academic-32';
DELETE FROM exams
WHERE "Slug" = 'ielts-reading-ielts-reading-sample-academic-32';

DO $$
DECLARE
  exam_id uuid := gen_random_uuid();
  sec1 uuid := gen_random_uuid();
  qid uuid;
BEGIN

  INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","UpdatedAt")
  VALUES (
    exam_id,
    'ielts-reading-ielts-reading-sample-academic-32',
    'IELTS Reading Sample (Academic) #32',
    'IELTS Reading Practice Test: IELTS Reading Sample (Academic) #32',
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
    'Reading Passage - IELTS Reading Sample (Academic) #32',
    E'# Passage\n\nIELTS Reading Academic 32\nCities of the future\nA.\nResearchers recently gave 1,000 people a questionnaire about ‘Cities of The Future’. To answer the questions, the people had to imagine and describe what they thought our cities might look like in the year 2050. Interestingly, a large number of people were anxious that they would become ‘dark, dangerous places’, which had endless traffic jams and very few green spaces. This group also predicted an increase in the level of pollution and thought people would always need to wear facemasks in order to breathe. They also believed that it would be less safe to walk on the street as there would be ‘more stealing’ and other criminal behaviour. A smaller number thought cities might become a lot cleaner, and might be built from more interesting materials. They were also looking forward to new technology such as flying cars and moving pavements. In general, they believed that the cities of the future would offer a much more convenient way of living. A few people were uncertain; for example, they thought the size of apartments might reduce as the population of the city grew, but they also thought that public transport would become better.\nB.\nWhat do the results from this questionnaire tell us? In a way, we shouldn’t be amazed by the descriptions of the largest group. So many Hollywood films show cities of the future as frightening places. Online newspapers are also responsible for spreading this same belief. Headlines such as ‘Global population rises – cities become crowded’ are becoming more frequent. Journalists rarely discuss how future cities might be a good place to live.\nC.\nThe facts are these: 50% of people now live in cities, even though cities only occupy 2% of the world’s land. By 2050, it is predicted that the number of people living there will rise to 70%. Some people are worried that villages in the countryside will become empty as everyone leaves for the city, and so traditional ways of life will be lost. This may be true, but we have to accept changes like this as part of human development. Rather than being negative, we should be hopeful that we can improve people’s lives as they move to cities. The way to do this is through intelligent planning.\nD.\nArchitects have a big role to play in our future cities. In the past, the architects who were responsible for planning our cities often designed buildings that they were interested in; but now it is time for them to listen carefully to what people living in cities are asking for. In many countries around the world, people are choosing to have smaller families or to wait longer before they start a family. For this reason, not everyone needs a large house. Smaller and cheaper houses are what they need. But ‘small’ doesn’t have to be the same as ‘ugly’ or ‘boring’. Western architects could perhaps look at some of the architecture in Japanese cities, where very stylish houses are built on small pieces of unused land.\nE.\nAnd what might cities of the future be made from? Engineering companies have produced some interesting new products, for example, wood-like material made from recycled newspapers or old drink cartons. One engineering team are even working on a project that uses mushrooms to create a hard building material. These new materials may seem strange, but we should remember that plastic was only invented in 1907 – at the time people thought that this was an unusual product, but now it is something we cannot manage without. Building a city of the future requires imagination and an open mind.\n\n.'
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
    'The duties and responsibilities of the people who design our cities',
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
    'The influence of cinema and the media on people’s view of the future',
    'Choose the correct answer.',
    '{"info-q2": ["B", "b"]}'
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
    'The types of material that future buildings might be made from',
    'Choose the correct answer.',
    '{"info-q3": ["E", "e"]}'
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
    'Some information and opinions about people living in cities and living in the countryside',
    'Choose the correct answer.',
    '{"info-q4": ["C", "c"]}'
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
    'What is the writer doing inParagraph B?',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'Explaining why many people will probably prefer to live in cities in the future.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'Giving a reason why many people feel negative about cities of the future.', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'Suggesting that newspapers show a more realistic view of future cities than films.', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    6,
    'MULTIPLE_CHOICE_SINGLE',
    'READING',
    2,
    'What point does the writer make inParagraph C?',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'It is important to encourage some people to stay in their villages.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'It is possible to maintain traditional village customs after moving to cities.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'It is necessary to think in a creative way about city design.', true);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    7,
    'MULTIPLE_CHOICE_SINGLE',
    'READING',
    2,
    'Paragraph D: In the writer’s opinion, architects who are responsible for planning cities',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'often make houses that are unattractive.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'must make buildings based on people’s needs.', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'should get experience by working in foreign cities.', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    8,
    'MULTIPLE_CHOICE_SINGLE',
    'READING',
    2,
    'Paragraph E: The writer refers to the invention of plastic to make the point that',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'we can expect building materials to be very different in the future.', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'we must accept that good-quality materials take a long time to create.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'we should use a variety of building materials to make our cities interesting.', false);


END$$;


COMMIT;