-- ============================================
-- IELTS Exam Data Import SQL
-- Generated: 2025-12-20T19:01:45.024049
-- Source: ielts-mentor.com
-- Title: GT Reading 33 Section 1 - Shoe World & CD Directory
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data for slug: ielts-mentor-gt-reading-33-section-1-shoe-world-cd-directory
DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-mentor-gt-reading-33-section-1-shoe-world-cd-directory'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-mentor-gt-reading-33-section-1-shoe-world-cd-directory';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-mentor-gt-reading-33-section-1-shoe-world-cd-directory';
DELETE FROM exams
WHERE "Slug" = 'ielts-mentor-gt-reading-33-section-1-shoe-world-cd-directory';

DO $$
DECLARE
  exam_id uuid := gen_random_uuid();
  sec1 uuid := gen_random_uuid();
  qid uuid;
BEGIN

  INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","UpdatedAt")
  VALUES (
    exam_id,
    'ielts-mentor-gt-reading-33-section-1-shoe-world-cd-directory',
    'GT Reading 33 Section 1 - Shoe World & CD Directory',
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
    'Reading Passage - GT Reading 33 Section 1 - Shoe World & CD Directory',
    E'# Passage\n\n# SHOE WORLD\n\nA. Outdoors Summer or winter, our Outdoors ranges are the best choice to meet your child’s schooling requirements. Our shoes feature a comfortable inner sole and easy-tie laces. Only occasional cleaning needed. Shoes come in two sizes. $10 and $20 varieties available. B. Cool-Clicks Fashion shoes for children. Open back, great, relaxed summer shoe. Flat-soled, easy to put on and off. One size only, in black or brown - $35. C. The Pace-Setter Popular thin-soled men’s sports shoe. Double leather surface for greater durability. Trendy and fashionable - half green, half blue with colourful red and yellow stripped laces - $50. D. Jeansia Ladies footwear as per the design of a Paris-based boutique fashion house. Winner of 2009 Gloria Award. The shiny silver coating makes the Jeansia even more attractive. Adjustable heels in all sizes - $75. E. Easy-Wear A favourite among working men and women. A light-weight, comfortable shoe for daily use. The Rexene surface adds to shoe durability. Variety of embossed icons printed on each pair; choose as per your design taste - $35. F. Formal Men’s formal shoes. Won silver medal in recent EU Summer Fashion Show. Available in white and brown shades. 3- layer sole, all in beautiful leather. Purchase includes a free shoe brush - $85. G. Everyday Cost-effective, everyday children’s shoe. Available in a variety of cute, vibrant hues. Animal cartoon prints – cows, donkeys, horses and elephants in greys and whites. Durable rubber sole. One extra pair of laces free - $15. H. Sunny Unisex shoes made of pure Italian leather. Two different styles - Hawaii and Malaya. Comfortable walking shoes, great for around the home. Available in brown only, no cleaning needed. Waterproof and come in two styles - $35 and $45. I. Bosa-Nova Exceptional country-style women’s footwear. The Bosa-Nova is our only imported shoe. The curved sole actually massages your feet as you walk. Genuine leather upper. Purple-coloured elastic back, a variety of sizes - $95. J. Supreme Elegant choice for ladies. Thin but durable leather processed using the latest micro-fibre technology. Will look new for years to come. 4 different colours in 2 sizes. Medium-heel with see-through, flat sole. Stylish black laces. $125. Customers may visit any of our stores and place a personal order. Depending upon stock availability, individual stores periodically offer discounts on particular models. Please note that apart from our discounted shoes, our usual 1-year guarantee applies to all advertised shoes. $20 gift voucher with every purchase over $100. Valid until the first week of January. There is no money back for goods purchased unless they have defects. Goods sold and unused may be exchanged for other goods of an equivalent price.\n\ni. Canada’s Forests ii. Mountain Biking: Routes in Canada iii. Canada Shopping Guide iv. Foods: Prepare a Canadian Dish! v. Insects of Canada: Visualisation and Illustration vi. Private Property: Canada Buying Guide vii. Canadian Demography viii. 4-Wheel Driving: Canada’s Challenge ix. Canadian Desert Art x. Survival in Canada’s Wild xi. Canadian Wildlife Cycles xii. Food for Thought: Philosophy and Canadian Society 7. Section A 8. Section B 9 . Section C 10. Section D 11. Section E 12. Section F 13. Section G 14. Section H\n\nA. The driest parts of Canada have a long history of aboriginal people. Among other findings, archaeologists have uncovered evidence of their creativity – ancient painting, pottery and stone-made statues of imaginary characters. This CD contains high-resolution images of their creative expression. Some drawings have been reproduced. Extensive photographs and informative texts. B. This CD is a compilation of information regarding Canada’s human populations. In-depth information about population size, growth, density, and distribution are covered. Statistics and graphs presented which bring the information to life! Migration trends in Canada are also a focus. A publication for beginners and experts alike. C. A manual on Canada’s woods and jungles. Satellite images as well as illustrations. Full of useful data. The origins, development and future of landscape trends are discussed. Several case studies on the natural resources in jungles and the impact of industrialisation upon them. D. Contains a detailed list of Canada’s retailers from several industries – souvenirs, fashion, toys, electronics to name a few. A must-have for tourists. Addresses, phone numbers and opening hours are all provided. Relevant internet sites are also easy to access. A world of information is just a click away! E. If you are a person who thinks that crossing hilly areas on two wheels is the ultimate in excitement then this CD is for you! Contains detailed routes through the slopes of Canada. Full of relevant and useful tips, including how to handle varying weather conditions. Additional information on camping and crisis management also included. F. Full of authentic Canadian recipes. Lunch, dinner, snacks, ice-creams, desserts and lots more. Select, specialty dishes with some drink preparation tips also included. Some video footage from Canada’s top cook shows. Possible purchase locations for some of the rare cooking ingredients, especially spices and natural herbs, are provided. G. Graphics illustrators have worked with entomologists to give us an idea how these small creatures reproduce and have survived for thousands of years. Their contribution to soil protection is discussed. Pest control and its pros and cons are drawn from articles published by the National University of Canada. H. Focuses on outdoor safety including infections and self-medications, safety equipment, food, living arrangements and other wildlife skills. Weather changes and ways to cope with them are discussed in detail. A photo gallery featuring a selection of picturesque, natural Canadian scenery is included free with every CD.'
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
    'Which shoe can be lowered and raised?',
    'Choose the correct answer.',
    '{"info-q1": ["D", "d"]}'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, 'E', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 6, 'F', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    2,
    'MATCHING_INFORMATION',
    'READING',
    2,
    'Which TWO types of casual shoes are sold for children?',
    'Choose the correct answer.',
    '{"info-q2": ["B, G", "b, g"]}'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, 'E', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 6, 'F', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    3,
    'MATCHING_INFORMATION',
    'READING',
    2,
    'Which TWO types of shoes are suitable for both men and women?',
    'Choose the correct answer.',
    '{"info-q3": ["E, H", "e, h"]}'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, 'E', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 6, 'F', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    4,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    'Which shoe is shipped from another country? _______',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q4": ["I", "i"]}'::jsonb
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
    'Which TWO shoes come with additional items at no extra cost?',
    'Choose the correct answer.',
    '{"info-q5": ["F, G", "f, g"]}'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, 'E', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 6, 'F', true);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    6,
    'MATCHING_INFORMATION',
    'READING',
    2,
    'Which TWO types of shoes come in only two different colours?ot on',
    'Choose the correct answer.',
    '{"info-q6": ["B, F", "b, f"]}'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, 'E', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 6, 'F', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    7,
    'MULTIPLE_CHOICE_SINGLE',
    'READING',
    2,
    '7. Section A',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, 'IX. (Missing label)', true);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    8,
    'MATCHING_INFORMATION',
    'READING',
    2,
    '8. Section B 9 . Section C',
    'Choose the correct answer.',
    '{"info-q8": ["VII", "vii"]}'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    9,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    'Section 9 _______.',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q9": ["I", "i"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    10,
    'MULTIPLE_CHOICE_SINGLE',
    'READING',
    2,
    '10. Section D',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, 'III. (Missing label)', true);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    11,
    'MULTIPLE_CHOICE_SINGLE',
    'READING',
    2,
    '11. Section E',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, 'II. (Missing label)', true);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    12,
    'MULTIPLE_CHOICE_SINGLE',
    'READING',
    2,
    '12. Section F',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, 'IV. (Missing label)', true);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    13,
    'MULTIPLE_CHOICE_SINGLE',
    'READING',
    2,
    '13. Section G',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, 'V. (Missing label)', true);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    14,
    'MATCHING_INFORMATION',
    'READING',
    2,
    '14. Section H CD Summaries A. The driest parts of Canada have a long history of aboriginal people. Among other findings, archaeologists have uncovered evidence of their creativity – ancient painting, pottery and stone-made statues of imaginary characters. This CD contains high-resolution images of their creative expression. Some drawings have been reproduced. Extensive photographs and informative texts. B. This CD is a compilation of information regarding Canada’s human populations. In-depth information about population size, growth, density, and distribution are covered. Statistics and graphs presented which bring the information to life! Migration trends in Canada are also a focus. A publication for beginners and experts alike. C. A manual on Canada’s woods and jungles. Satellite images as well as illustrations. Full of useful data. The origins, development and future of landscape trends are discussed. Several case studies on the natural resources in jungles and the impact of industrialisation upon them. D. Contains a detailed list of Canada’s retailers from several industries – souvenirs, fashion, toys, electronics to name a few. A must-have for tourists. Addresses, phone numbers and opening hours are all provided. Relevant internet sites are also easy to access. A world of information is just a click away! E. If you are a person who thinks that crossing hilly areas on two wheels is the ultimate in excitement then this CD is for you! Contains detailed routes through the slopes of Canada. Full of relevant and useful tips, including how to handle varying weather conditions. Additional information on camping and crisis management also included. F. Full of authentic Canadian recipes. Lunch, dinner, snacks, ice-creams, desserts and lots more. Select, specialty dishes with some drink preparation tips also included. Some video footage from Canada’s top cook shows. Possible purchase locations for some of the rare cooking ingredients, especially spices and natural herbs, are provided. G. Graphics illustrators have worked with entomologists to give us an idea how these small creatures reproduce and have survived for thousands of years. Their contribution to soil protection is discussed. Pest control and its pros and cons are drawn from articles published by the National University of Canada. H. Focuses on outdoor safety including infections and self-medications, safety equipment, food, living arrangements and other wildlife skills. Weather changes and ways to cope with them are discussed in detail. A photo gallery featuring a selection of picturesque, natural Canadian scenery is included free with every CD.',
    'Choose the correct answer.',
    '{"info-q14": ["X", "x"]}'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D', false);


END$$;


COMMIT;