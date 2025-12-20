-- ============================================
-- IELTS Exam Data Import SQL
-- Generated: 2025-12-20T17:46:58.121626
-- Source: ielts-mentor.com
-- Title: GT Reading 9 Section 3 - North American Quilts and Coverlets
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data for slug: ielts-mentor-gt-reading-9-section-3-north-american-quilts-and-coverlets
DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-mentor-gt-reading-9-section-3-north-american-quilts-and-coverlets'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-mentor-gt-reading-9-section-3-north-american-quilts-and-coverlets';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-mentor-gt-reading-9-section-3-north-american-quilts-and-coverlets';
DELETE FROM exams
WHERE "Slug" = 'ielts-mentor-gt-reading-9-section-3-north-american-quilts-and-coverlets';

DO $$
DECLARE
  exam_id uuid := gen_random_uuid();
  sec1 uuid := gen_random_uuid();
  qid uuid;
BEGIN

  INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","UpdatedAt")
  VALUES (
    exam_id,
    'ielts-mentor-gt-reading-9-section-3-north-american-quilts-and-coverlets',
    'GT Reading 9 Section 3 - North American Quilts and Coverlets',
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
    'Reading Passage - GT Reading 9 Section 3 - North American Quilts and Coverlets',
    E'# Passage\n\n# North American Quilts and Coverlets\n\ni. Methods of applying colour patterns to cloth ii. The origins and use of factory-made cloth iii. Specialist training for quilt and coverlet makers iv. Two types of quilt construction v. The production of rawmaterials vi. Dyeing techniques used in America vii. The rising price of manufactured textiles viii. Sources of natural dyes in America ix. The development of weaving techniques .................. .................. .................. .................. .................. .................. ..................\n\nParagraph A: The craft traditions which early American colonists from Europe brought to the ‘New World’ centred primarily around the use of linen and wool. These familiar choices were then adapted to America, whose climate and environment enabled the introduction and raising of sheep for wool and, in some areas – though with less success – the growing of flax for linen. The cultivation of silk – an exotic fibre originally brought from China – was attempted for a short time only in the northern states, although by the nineteenth-century silk was being used extensively. Cotton thrived in the southern region, but was restricted to small-scale home production until the late eighteenth and early nineteenth centuries, when the invention of new mechanical equipment facilitated its harvesting, spinning, and weaving on a large scale. Paragraph B: Quilts and coverlets were created from both homemade and commercially produced cloth. During the early colonial period (seventeenth century) and into the new republic (1776 onwards), most commercial fabric was imported from England. Even goods that had been produced in other regions, such as the popular dye-printed calicoes from India and woven silks from China, were brought into America via English ships. These were used in making quilts and also influenced American quilt design. Eventually, by the mid-nineteenth century, most of the fabrics found in quilts were industrially produced, and reflected the taste and achievements of the American textile industry. Specialty fabrics, particularly silk ribbons, had become popular by the second half of the nineteenth century. Paragraph C: Prior to the development of synthetic dyes in the nineteenth century, early American dyers utilized substances obtained from a variety of plants and animals, to create a wide-ranging colour palette. Red colours ranged from the orange-red hue produced from the madder root to the brilliant scarlet made from cochineal, the scale insect that grows on the cactus from Central and South America. Most of the blue colours were from indigo leaves, and browns derived from a variety of sources, including substances called tannins found in oak trees. Paragraph D: Unwoven yarn or finished cloth was coloured by immersing it into containers of hot dye solution. Numerous shades of colour could be achieved, depending on the quality of the dyes, the purity of water, the type of utensils used (a copper kettle, for example, could affect the colour), and the addition of specific metallic salts to create a strong colour which would not fade in light. These salts, along with other additives such as vinegar or ash, were essential to the dyeing process. The dyeing of textiles with natural dyes was both an art and a science. Indigo blue, for example, with its complex chemistry, required a series of steps in order to produce a durable, lightfast blue colour. Turkey Red was another complicated dye process. Originating in India, it was a method that involved immersing the cloth several times into oils, milk fats or dung. Toward the end of the eighteenth century, books were published on the science and philosophy of dyes, thus heralding a period of experimentation, and the creation of a whole new category of synthetic dyes that flourished at the end of the nineteenth century, and continue to be used today. Paragraph E: Methods of applying designs onto the surface of fabrics ranged from hand painting and stencilling 2 to block and roller printing. Block printing involved the use of carved wooden blocks. The surfaces of the blocks were covered with the dye which were thickened with gum Arabic or other starchy substances, and pressed directly onto the cloth. Some quilts were made with floral designs from block-printed fabrics. Etched plates of copper were also used for printing, and in 1783 technological developments led to covering cylindrical rollers with etched copperplates for continuous printing, a process called roller printing. This new technology enabled printers to produce more yardage at a much faster rate. Paragraph F: The creation of complex quilts composed of many small pieces of cloth – known as patchwork – requires systematic organization. A template might be used for creating the basic design unit, such as a square, diamond, or hexagon. The template – sometimes a heavy card or paper – ensured an even, regular unit size, thus enabling the quilter to join together the many pieces of fabric, following an overall design arrangement. Appliquéd quilts, also made by using fabric pieces, were put together in a different manner. Appliqué is a versatile technique, enabling the sewer to compose visual patterns with multiple layers of single-colour and printed fabrics, creating depth in the overall composition. Paragraph G: For American woven blankets, simple weaves were woven on simple looms. Creating designs in geometric patterning resulted from a weaver’s meticulous attention to the loom’s operation, along with the artistic use of contrasting colours and materials to highlight the pattern effects. Floral and larger-scale pictorial images generally required more complex patterning mechanisms. For example, the Jacquard mechanism, developed by French weaver Joseph-Marie Jacquard in the late eighteenth century, used a series of cards with pre-punched holes that would control the threads as they were woven on the loom. An early forerunner of the computer, the Jacquard loom was introduced to American weavers by the 1820s, and used extensively to produce woven coverlets with both large- and small-scale designs.'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    28,
    'MATCHING_HEADING',
    'READING',
    2,
    'Section 28',
    'Choose the correct answer.',
    '{"section-28-q28": ["v", "v. The production of rawmaterials"]}'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'i. Methods of applying colour patterns to cloth', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'ii. The origins and use of factory-made cloth', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'iii. Specialist training for quilt and coverlet makers', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'iv. Two types of quilt construction', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, 'v. The production of rawmaterials', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 6, 'vi. Dyeing techniques used in America', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 7, 'vii. The rising price of manufactured textiles', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 8, 'viii. Sources of natural dyes in America', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 9, 'ix. The development of weaving techniques', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    29,
    'MATCHING_HEADING',
    'READING',
    2,
    'Section 29',
    'Choose the correct answer.',
    '{"section-29-q29": ["ii", "ii. The origins and use of factory-made cloth"]}'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'i. Methods of applying colour patterns to cloth', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'ii. The origins and use of factory-made cloth', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'iii. Specialist training for quilt and coverlet makers', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'iv. Two types of quilt construction', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, 'v. The production of rawmaterials', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 6, 'vi. Dyeing techniques used in America', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 7, 'vii. The rising price of manufactured textiles', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 8, 'viii. Sources of natural dyes in America', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 9, 'ix. The development of weaving techniques', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    30,
    'MATCHING_HEADING',
    'READING',
    2,
    'Section 30',
    'Choose the correct answer.',
    '{"section-30-q30": ["viii", "viii. Sources of natural dyes in America"]}'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'i. Methods of applying colour patterns to cloth', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'ii. The origins and use of factory-made cloth', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'iii. Specialist training for quilt and coverlet makers', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'iv. Two types of quilt construction', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, 'v. The production of rawmaterials', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 6, 'vi. Dyeing techniques used in America', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 7, 'vii. The rising price of manufactured textiles', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 8, 'viii. Sources of natural dyes in America', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 9, 'ix. The development of weaving techniques', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    31,
    'MATCHING_HEADING',
    'READING',
    2,
    'Section 31',
    'Choose the correct answer.',
    '{"section-31-q31": ["vi", "vi. Dyeing techniques used in America"]}'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'i. Methods of applying colour patterns to cloth', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'ii. The origins and use of factory-made cloth', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'iii. Specialist training for quilt and coverlet makers', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'iv. Two types of quilt construction', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, 'v. The production of rawmaterials', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 6, 'vi. Dyeing techniques used in America', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 7, 'vii. The rising price of manufactured textiles', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 8, 'viii. Sources of natural dyes in America', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 9, 'ix. The development of weaving techniques', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    32,
    'MATCHING_HEADING',
    'READING',
    2,
    'Section 32',
    'Choose the correct answer.',
    '{"section-32-q32": ["i", "i. Methods of applying colour patterns to cloth"]}'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'i. Methods of applying colour patterns to cloth', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'ii. The origins and use of factory-made cloth', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'iii. Specialist training for quilt and coverlet makers', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'iv. Two types of quilt construction', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, 'v. The production of rawmaterials', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 6, 'vi. Dyeing techniques used in America', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 7, 'vii. The rising price of manufactured textiles', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 8, 'viii. Sources of natural dyes in America', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 9, 'ix. The development of weaving techniques', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    33,
    'MATCHING_HEADING',
    'READING',
    2,
    'Section 33',
    'Choose the correct answer.',
    '{"section-33-q33": ["iv", "iv. Two types of quilt construction"]}'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'i. Methods of applying colour patterns to cloth', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'ii. The origins and use of factory-made cloth', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'iii. Specialist training for quilt and coverlet makers', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'iv. Two types of quilt construction', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, 'v. The production of rawmaterials', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 6, 'vi. Dyeing techniques used in America', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 7, 'vii. The rising price of manufactured textiles', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 8, 'viii. Sources of natural dyes in America', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 9, 'ix. The development of weaving techniques', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    34,
    'MATCHING_HEADING',
    'READING',
    2,
    'Section 34',
    'Choose the correct answer.',
    '{"section-34-q34": ["ix", "ix. The development of weaving techniques"]}'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'i. Methods of applying colour patterns to cloth', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'ii. The origins and use of factory-made cloth', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'iii. Specialist training for quilt and coverlet makers', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'iv. Two types of quilt construction', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, 'v. The production of rawmaterials', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 6, 'vi. Dyeing techniques used in America', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 7, 'vii. The rising price of manufactured textiles', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 8, 'viii. Sources of natural dyes in America', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 9, 'ix. The development of weaving techniques', true);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    35,
    'MULTIPLE_CHOICE_SINGLE',
    'READING',
    2,
    '35. How suitable were various fibres for production by the first immigrants to America? A. Silk was produced in every geographical region. B. Cotton could be grown on large plantations. C. Wool presented no particular problems. D. Flax was the easiest fibre to cultivate.',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. Silk was produced in every geographical region.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. Cotton could be grown on large plantations.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. Wool presented no particular problems.', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D. Flax was the easiest fibre to cultivate.', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    36,
    'MULTIPLE_CHOICE_SINGLE',
    'READING',
    2,
    '36. What does the writer say about early cloth printing in America? A. Fabrics were printed using a variety of methods. B. The introduction of block printing speeded up the process. C. For a long time, flowers were the only image that was printed. D. Wooden printing equipment was quickly replaced by metal.',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. Fabrics were printed using a variety of methods.', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. The introduction of block printing speeded up the process.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. For a long time, flowers were the only image that was printed.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D. Wooden printing equipment was quickly replaced by metal.', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    37,
    'MULTIPLE_CHOICE_SINGLE',
    'READING',
    2,
    '37. The technique of creating patterns in woven cloth A. required little skill on the part of a loom operator. B. was only possible after complex looms were invented. C. had originated in eighteenth-century France. D. involved combining different colours and materials.',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. required little skill on the part of a loom operator.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. was only possible after complex looms were invented.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. had originated in eighteenth-century France.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D. involved combining different colours and materials.', true);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    38,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    '_______ was.',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q38": ["WATER"]}'::jsonb
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
    '_______ _______.',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q39": ["LIGHT"]}'::jsonb
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
    '_______ _______.',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q40": ["SYNTHETIC"]}'::jsonb
  );


END$$;


COMMIT;