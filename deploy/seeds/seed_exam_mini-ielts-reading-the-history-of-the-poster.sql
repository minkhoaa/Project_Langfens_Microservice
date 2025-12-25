-- ============================================
-- IELTS Exam Data Import SQL
-- Generated: 2025-12-25T01:21:00.475974
-- Source: mini-ielts.com
-- Title: The history of the poster
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data for slug: mini-ielts-reading-the-history-of-the-poster
DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'mini-ielts-reading-the-history-of-the-poster'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'mini-ielts-reading-the-history-of-the-poster';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'mini-ielts-reading-the-history-of-the-poster';
DELETE FROM exams
WHERE "Slug" = 'mini-ielts-reading-the-history-of-the-poster';

DO $$
DECLARE
  exam_id uuid := gen_random_uuid();
  sec1 uuid := gen_random_uuid();
  qid uuid;
BEGIN

  INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","ImageUrl","UpdatedAt")
  VALUES (
    exam_id,
    'mini-ielts-reading-the-history-of-the-poster',
    'The history of the poster',
    'IELTS Reading Practice Test from IELTS Mentor',
    'IELTS',
    'B2',
    'PUBLISHED',
    20,
    'http://images.mini-ielts.com/images/2017/17/historyofposter_thumbpad.jpg',
    now()
  );

  INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","PassageMd")
  VALUES (
    sec1,
    exam_id,
    1,
    'Reading Passage - The history of the poster',
    E'**Questions 1-5:**\nComplete the table below.\nChoose **NO MORE THAN THREE WORDS** from the passage for each answer.\n\n---\n\n**Questions 6-9:**\nComplete the flow chart below.\nWrite **NO MORE THAN THREE WORDS** from the passage for each answer.\n\n---\n\n**Questions 10-13:**\nDo the following statements agree with the information in the reading passage?\n\nWrite:\n- **TRUE** if the statement agrees with the information\n- **FALSE** if the statement contradicts the information\n- **NOT GIVEN** if there is no information on this',
    E'**Paragraph A.**\n\nThe appearance of the poster has changed continuously over the past two centuries.\n\n**Paragraph B.**\n\nThe first posters were known as ‘broadsides’ and were used for public and commercial announcements. Printed on one side only using metal type, they were quickly and crudely produced in large quantities. As they were meant to be read at a distance, they required large lettering.\n\n**Paragraph C.**\n\nThere were a number of negative aspects of large metal type. It was expensive, required a large amount of storage space and was extremely heavy. If a printer did have a collection of large metal type, it was likely that there were not enough letters. So printers did their best by mixing and matching styles.\n\n**Paragraph D.**\n\nCommercial pressure for large type was answered with the invention of a system for wood type production. In 1827, Darius Wells invented a special wood drill - the lateral router - capable of cutting letters on wood blocks. The router was used in combination with William Leavenworth’s pantograpn (1834) to create decorative wooden letters of all shapes and sizes. The first posters began to appear, but they had little colour and design; often wooden type was mixed with metal type in a conglomeration of styles.\n\n**Paragraph E.**\n\nA major development in poster design was the application of lithography, invented by Alois Senefelder in 1796, which allowed artists to hand-draw letters, opening the field of type design to endless styles. The method involved drawing with a greasy crayon onto finely surfaced Bavarian limestone and offsetting that image onto paper. This direct process captured the artist''s true intention; however, the final printed image was in reverse. The images and lettering needed to be drawn backwards, often reflected in a mirror or traced on transfer paper.\n\n**Paragraph F.**\n\nAs a result of this technical difficulty, the invention of the lithographic process had little impact on posters until the 1860s, when Jules Cheret came up with his ‘three-stone lithographic process’. This gave artists the opportunity to experiment with a wide spectrum of colours.\n\n**Paragraph G.**\n\nAlthough the process was difficult, the result was remarkable, with nuances of colour impossible in other media even to this day. The ability to mix words and images in such an attractive and economical format finally made the lithographic poster a powerful innovation.\n\n**Paragraph H.**\n\nStarting in the 1870s, posters became the main vehicle for advertising prior to the magazine era and the dominant means of mass communication in the rapidly growing cities of Europe and America. Yet in the streets of Paris, Milan and Berlin, these artistic prints were so popular that they were stolen off walls almost as soon as they were hung. Cheret, later known as ‘the father of the modern poster’, organised the first exhibition of posters in 1884 and two years later published the first book on poster art. He quickly took advantage of the public interest by arranging for artists to create posters, at a reduced size, that were suitable for in-home display.\n\n**Paragraph I.**\n\nThanks to Cheret. the poster slowly took hold in other countries in the 1890s and came to celebrate each society’s unique cultural institutions: the cafe in France, the opera and fashion in Italy, festivals in Spain, literature in Holland and trade fairs in Germany.\n\n**Paragraph J.**\n\nThe first poster shows were held in Great Britain and Italy in 1894, Germany in 1896 and Russia in 1897. The most important poster show ever, to many observers, was held in Reims, France, in 1896 and featured an unbelievable 1,690 posters arranged by country.\n\n**Paragraph K.**\n\nIn the early 20th century, the poster continued to play a large communication role and to go through a range of styles. By the 1950s, however, it had begun to share the spotlight with other media, mainly radio and print. By this time, most posters were printed using the mass production technique of photo offset, which resulted in the familiar dot pattern seen in newspapers and magazines. In addition, the use of photography in posters, begun in Russia in the twenties, started to become as common as illustration.\n\n**Paragraph L.**\n\nIn the late fifties, a new graphic style that had strong reliance on typographic elements in black and white appeared. The new style came to be known as the International Typographic Style. It made use of a mathematical grid, strict graphic rules and black-and-white photography to provide a clear and logical structure. It became the predominant style in the world in the 1970s and continues to exert its influence today.\n\n**Paragraph M.**\n\nIt was perfectly suited to the increasingly international post-war marketplace, where there was a strong demand for clarity. This meant that the accessibility of words and symbols had to be taken into account. Corporations wanted international identification, and events such as the Olympics called for universal solutions, which the Typographic Style could provide.\n\n**Paragraph N.**\n\nHowever, the International Typographic Style began to lose its energy in the late 1970s. Many criticised it for being cold, formal and dogmatic.\n\n**Paragraph O.**\n\nA young teacher in Basel. Wolfgang Weingart, experimented with the offset printing process to produce posters that appeared complex and chaotic, playful and spontaneous - all in stark contrast to what had gone before. Weingart''s liberation of typography was an important foundation for several new styles. These ranged from Memphis and Retro to the advances now being made in computer graphics. Adapted from www.internationalposter.com'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    1,
    'TABLE_COMPLETION',
    'READING',
    2,
    'cost, weight and _______ difficulties',
    '',
    '{"blank-q1": ["STORAGE SPACE"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    2,
    'TABLE_COMPLETION',
    'READING',
    2,
    'Darius''s wood drill used in connection with another _______',
    '',
    '{"blank-q2": ["INVENTION"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    3,
    'TABLE_COMPLETION',
    'READING',
    2,
    'lacked both _______',
    '',
    '{"blank-q3": ["COLOUR AND DESIGN"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    4,
    'TABLE_COMPLETION',
    'READING',
    2,
    'design tool - a _______',
    '',
    '{"blank-q4": ["GREASY CRAYON"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    5,
    'TABLE_COMPLETION',
    'READING',
    2,
    'had to use a mirror or _______ to achieve correct image',
    '',
    '{"blank-q5": ["TRANSFER PAPER"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    6,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    'combination of both _______ on coloured posters',
    '',
    '{"blank-q6": ["WORDS AND IMAGES"]}'::jsonb
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
    'posters used for advertising and _______ in Europe',
    '',
    '{"blank-q7": ["MASS COMMUNICATION"]}'::jsonb
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
    'Cheret’s poster _______ and book on poster art',
    '',
    '{"blank-q8": ["EXHIBITION"]}'::jsonb
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
    'posters represent _______ around the world',
    '',
    '{"blank-q9": ["UNIQUE CULTURAL INSTITUTIONS"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    10,
    'TRUE_FALSE_NOT_GIVEN',
    'READING',
    2,
    'By the 1950s, photographs were more widely seen than artists'' illustrations on posters.',
    '',
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
    11,
    'TRUE_FALSE_NOT_GIVEN',
    'READING',
    2,
    'Features of the Typographic Style can be seen in modern-day posters.',
    '',
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
    12,
    'TRUE_FALSE_NOT_GIVEN',
    'READING',
    2,
    'The Typographic Style met a global need at a particular time in history.',
    '',
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
    'TRUE_FALSE_NOT_GIVEN',
    'READING',
    2,
    'Weingart got many of his ideas from his students in Basel.',
    '',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'TRUE', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'FALSE', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'NOT GIVEN', true);



  -- Delete old question groups for this exam
  DELETE FROM exam_question_groups WHERE "SectionId" = sec1;

  -- Insert question groups
  INSERT INTO exam_question_groups ("Id","SectionId","Idx","StartIdx","EndIdx","InstructionMd")
  VALUES (gen_random_uuid(), sec1, 1, 1, 5, E'## Questions 1-5\n\nComplete the notes below.\n\nChoose **NO MORE THAN THREE WORDS** from the passage for each answer.\n\n### Early Printing Methods\n\n**Metal type**\n- **Features:** produced large print\n- **Problems:**\n  - cost, weight and **1** _______ difficulties\n  - mixed styles\n\n**Wood type**\n- **Features:**\n  - Darius''s wood drill used in connection with another **2** _______\n  - produced a range of letters\n- **Problems:**\n  - lacked both **3** _______\n  - mixed type\n\n**Lithography**\n- **Features:**\n  - letters drawn by hand\n  - design tool - a **4** _______\n- **Problems:** had to use a mirror or **5** _______ to achieve correct image');

  INSERT INTO exam_question_groups ("Id","SectionId","Idx","StartIdx","EndIdx","InstructionMd")
  VALUES (gen_random_uuid(), sec1, 2, 6, 9, E'## Questions 6-9\n\nComplete the flow chart below.\n\nWrite **NO MORE THAN THREE WORDS** from the passage for each answer.\n\n### Jules Cheret\n\n**1860s** - invention of ''three-stone lithographic process''\n\n↓\n\ncombination of both **6** _______ on coloured posters\n\n↓\n\n**1870s** - posters used for advertising and **7** _______ in Europe\n\n↓\n\n**1884-86** - Cheret’s poster **8** _______ and book on poster art\n\n↓\n\n**1890s** - posters represent **9** _______ around the world');

  INSERT INTO exam_question_groups ("Id","SectionId","Idx","StartIdx","EndIdx","InstructionMd")
  VALUES (gen_random_uuid(), sec1, 3, 10, 13, E'## Questions 10-13\n\nDo the following statements agree with the information in the reading passage?\n\nWrite:\n- **TRUE** if the statement agrees with the information\n- **FALSE** if the statement contradicts the information\n- **NOT GIVEN** if there is no information on this');

END$$;


COMMIT;