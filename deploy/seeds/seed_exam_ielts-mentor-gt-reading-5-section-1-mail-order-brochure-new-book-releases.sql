-- ============================================
-- IELTS Exam Data Import SQL
-- Generated: 2025-12-21T10:59:39.827637
-- Source: ielts-mentor.com
-- Title: GT Reading 5 Section 1 - Mail Order Brochure & New Book Releases
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data for slug: ielts-mentor-gt-reading-5-section-1-mail-order-brochure-new-book-releases
DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-mentor-gt-reading-5-section-1-mail-order-brochure-new-book-releases'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-mentor-gt-reading-5-section-1-mail-order-brochure-new-book-releases';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-mentor-gt-reading-5-section-1-mail-order-brochure-new-book-releases';
DELETE FROM exams
WHERE "Slug" = 'ielts-mentor-gt-reading-5-section-1-mail-order-brochure-new-book-releases';

DO $$
DECLARE
  exam_id uuid := gen_random_uuid();
  sec1 uuid := gen_random_uuid();
  qid uuid;
BEGIN

  INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","UpdatedAt")
  VALUES (
    exam_id,
    'ielts-mentor-gt-reading-5-section-1-mail-order-brochure-new-book-releases',
    'GT Reading 5 Section 1 - Mail Order Brochure & New Book Releases',
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
    'Reading Passage - GT Reading 5 Section 1 - Mail Order Brochure & New Book Releases',
    E'**Questions 1-7:**\nDo the following statements agree with the information given in the text?\n\nWrite\n- **TRUE** if the statement agrees with the information\n- **FALSE** if the statement contradicts the information\n- **NOT GIVEN** if there is no information on this\n\n---\n\n**Questions 8-14:**\nLook at the book titles (i-xi) and the list of book descriptions (A-G).\n\nMatch each description to the correct book title.\n\n---\n\n# MAIL ORDER BROCHURE & New Book Releases\n\nFor under $10 Cotton socks C - made of pure cotton for long wearing Woollen socks C - to keep young feet warm in winter Sports socks M - to go with jeans and other casual clothes Patterned belts W - to go with jeans and other casual clothes For under $25 Cotton shirts W - for day and evening wear Silk shirts M - five sizes, in designer colours, for that special social occasion T-shirts C - hard-wearing, white with a variety of animal motifs Colour T-shirts M W - cotton and polyester blend, plain colours, no ironing For under $50 Blue jeans M W - non-shrink, colourfast, small sizes only Silk shirts M W - plain and patterned, all sizes Hooded jacket C - protects from the wind, 4 sizes, large strong pockets jacket W - waterproof with zipper front, all sizes\n\nAdditional monthly specials for July to September July - $10 voucher with any purchase over $60 August - Travel alarm clock worth $19.95 free with purchases of $80 or more! September - Children''s backpacks. Free with any credit card purchase over $75!\n\nNote: Postage and packing charges These are applied to each order as follows: Within Australia: $7.95 per address, regular post $17.95 for Express Delivery Service (overnight) Overseas: Surface Mail (allow a minimum of two months for delivery) Airmail (allow around two weeks delivery to most destinations)\n\n1. Women''s cotton socks cost less than men''s. 2. Men''s silk shirts are available in more than five colours. 3. Children''s T-shirts come in a variety of colours. 4. The child''s jacket has four pockets. 5. If you buy clothes worth $80 in August, you will receive a free alarm clock. 6. The charge for special next-day delivery in Australia is $7.95. 7. All clothing is guaranteed to arrive within two months for international delivery.\n\ni. Field Guide to Native Birds of Australia ii. The Bush on Two Wheels: 100 Top Rides iii. Bush Foods of Australian Aborigines iv.\n\n**Paragraph A.**\nPictorial History of the Dinosaur in Australia v. Bush walking in Australia vi. WorldGeographica vii. Driving Adventures for 4-wheel-drive Vehicles viii. Survival Techniques in the Wild ix. Encyclopaedia of Australian Wildlife x. Guide to the Art of the Australian Desert xi. Field Guide to Animals of the World\n\nA. This book describes the creativity of Aboriginal people living in the driest parts of Australia. Stunning reproductions of paintings, beautiful photography and informative text.\n\nB. Pocket-sized maps and illustrations with detailed information on the nesting sites and migration patterns of Australia. This is a classic booklet suitable for both beginner and expert.\n\nC. Packed full of information for the avid hiker, this book is a must. Photographs, maps and practical advice will guide your journeys on foot through the forests of the southern continent.\n\nD. More than an atlas - this book contains maps, photographs and an abundance of information on the land and climate of countries from around the globe.\n\nF. Here''s the A-Z of Australian native animals - take an in-depth look at their lives and characteristics, through fantastic photographs and informative text.'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    1,
    'TRUE_FALSE_NOT_GIVEN',
    'READING',
    2,
    'Women''s cotton socks cost less than men''s.',
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
    2,
    'TRUE_FALSE_NOT_GIVEN',
    'READING',
    2,
    'Men''s silk shirts are available in more than five colours.',
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
    3,
    'TRUE_FALSE_NOT_GIVEN',
    'READING',
    2,
    'Children''s T-shirts come in a variety of colours.',
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
    4,
    'TRUE_FALSE_NOT_GIVEN',
    'READING',
    2,
    'The child''s jacket has four pockets.',
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
    5,
    'TRUE_FALSE_NOT_GIVEN',
    'READING',
    2,
    'If you buy clothes worth $80 in August, you will receive a free alarm clock.',
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
    6,
    'TRUE_FALSE_NOT_GIVEN',
    'READING',
    2,
    'The charge for special next-day delivery in Australia is $7.95.',
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
    7,
    'TRUE_FALSE_NOT_GIVEN',
    'READING',
    2,
    'All clothing is guaranteed to arrive within two months for international delivery.',
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
    8,
    'MATCHING_FEATURES',
    'READING',
    2,
    'A. This book describes the creativity of Aboriginal people living in the driest parts of Australia. Stunning reproductions of paintings, beautiful photography and informative text.',
    'Choose the correct answer.',
    '{"feature-q8": ["X", "x. Guide to the Art of the Australian Desert"]}'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'i. Field Guide to Native Birds of Australia', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'ii. The Bush on Two Wheels: 100 Top Rides', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'iii. Bush Foods of Australian Aborigines', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'iv. Pictorial History of the Dinosaur in Australia', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, 'v. Bush walking in Australia', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 6, 'vi. WorldGeographica', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 7, 'vii. Driving Adventures for 4-wheel-drive Vehicles', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 8, 'viii. Survival Techniques in the Wild', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 9, 'ix. Encyclopaedia of Australian Wildlife', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 10, 'x. Guide to the Art of the Australian Desert', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 11, 'xi. Field Guide to Animals of the World', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    9,
    'MATCHING_FEATURES',
    'READING',
    2,
    'B. Pocket-sized maps and illustrations with detailed information on the nesting sites and migration patterns of Australia. This is a classic booklet suitable for both beginner and expert.',
    'Choose the correct answer.',
    '{"feature-q9": ["I", "i. Field Guide to Native Birds of Australia"]}'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'i. Field Guide to Native Birds of Australia', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'ii. The Bush on Two Wheels: 100 Top Rides', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'iii. Bush Foods of Australian Aborigines', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'iv. Pictorial History of the Dinosaur in Australia', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, 'v. Bush walking in Australia', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 6, 'vi. WorldGeographica', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 7, 'vii. Driving Adventures for 4-wheel-drive Vehicles', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 8, 'viii. Survival Techniques in the Wild', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 9, 'ix. Encyclopaedia of Australian Wildlife', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 10, 'x. Guide to the Art of the Australian Desert', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 11, 'xi. Field Guide to Animals of the World', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    10,
    'MATCHING_FEATURES',
    'READING',
    2,
    'C. Packed full of information for the avid hiker, this book is a must. Photographs, maps and practical advice will guide your journeys on foot through the forests of the southern continent.',
    'Choose the correct answer.',
    '{"feature-q10": ["V", "v. Bush walking in Australia"]}'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'i. Field Guide to Native Birds of Australia', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'ii. The Bush on Two Wheels: 100 Top Rides', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'iii. Bush Foods of Australian Aborigines', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'iv. Pictorial History of the Dinosaur in Australia', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, 'v. Bush walking in Australia', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 6, 'vi. WorldGeographica', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 7, 'vii. Driving Adventures for 4-wheel-drive Vehicles', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 8, 'viii. Survival Techniques in the Wild', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 9, 'ix. Encyclopaedia of Australian Wildlife', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 10, 'x. Guide to the Art of the Australian Desert', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 11, 'xi. Field Guide to Animals of the World', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    11,
    'MATCHING_FEATURES',
    'READING',
    2,
    'D. More than an atlas - this book contains maps, photographs and an abundance of information on the land and climate of countries from around the globe.',
    'Choose the correct answer.',
    '{"feature-q11": ["II", "ii. The Bush on Two Wheels: 100 Top Rides"]}'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'i. Field Guide to Native Birds of Australia', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'ii. The Bush on Two Wheels: 100 Top Rides', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'iii. Bush Foods of Australian Aborigines', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'iv. Pictorial History of the Dinosaur in Australia', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, 'v. Bush walking in Australia', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 6, 'vi. WorldGeographica', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 7, 'vii. Driving Adventures for 4-wheel-drive Vehicles', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 8, 'viii. Survival Techniques in the Wild', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 9, 'ix. Encyclopaedia of Australian Wildlife', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 10, 'x. Guide to the Art of the Australian Desert', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 11, 'xi. Field Guide to Animals of the World', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    12,
    'MATCHING_FEATURES',
    'READING',
    2,
    'E. Australia''s premier mountain biking guidebook - taking you through a host of national parks and state forests.',
    'Choose the correct answer.',
    '{"feature-q12": ["IX", "ix. Encyclopaedia of Australian Wildlife"]}'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'i. Field Guide to Native Birds of Australia', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'ii. The Bush on Two Wheels: 100 Top Rides', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'iii. Bush Foods of Australian Aborigines', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'iv. Pictorial History of the Dinosaur in Australia', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, 'v. Bush walking in Australia', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 6, 'vi. WorldGeographica', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 7, 'vii. Driving Adventures for 4-wheel-drive Vehicles', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 8, 'viii. Survival Techniques in the Wild', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 9, 'ix. Encyclopaedia of Australian Wildlife', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 10, 'x. Guide to the Art of the Australian Desert', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 11, 'xi. Field Guide to Animals of the World', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    13,
    'MATCHING_FEATURES',
    'READING',
    2,
    'F. Here''s the A-Z of Australian native animals - take an in-depth look at their lives and characteristics, through fantastic photographs and informative text.',
    'Choose the correct answer.',
    '{"feature-q13": ["IV", "iv. Pictorial History of the Dinosaur in Australia"]}'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'i. Field Guide to Native Birds of Australia', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'ii. The Bush on Two Wheels: 100 Top Rides', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'iii. Bush Foods of Australian Aborigines', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'iv. Pictorial History of the Dinosaur in Australia', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, 'v. Bush walking in Australia', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 6, 'vi. WorldGeographica', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 7, 'vii. Driving Adventures for 4-wheel-drive Vehicles', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 8, 'viii. Survival Techniques in the Wild', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 9, 'ix. Encyclopaedia of Australian Wildlife', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 10, 'x. Guide to the Art of the Australian Desert', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 11, 'xi. Field Guide to Animals of the World', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    14,
    'MATCHING_FEATURES',
    'READING',
    2,
    'G. Graphic artists have worked with researchers and scientists to illustrate how these prehistoric animals lived and died on the Australian continent.',
    'Choose the correct answer.',
    '{"feature-q14": ["VIII", "viii. Survival Techniques in the Wild"]}'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'i. Field Guide to Native Birds of Australia', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'ii. The Bush on Two Wheels: 100 Top Rides', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'iii. Bush Foods of Australian Aborigines', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'iv. Pictorial History of the Dinosaur in Australia', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, 'v. Bush walking in Australia', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 6, 'vi. WorldGeographica', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 7, 'vii. Driving Adventures for 4-wheel-drive Vehicles', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 8, 'viii. Survival Techniques in the Wild', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 9, 'ix. Encyclopaedia of Australian Wildlife', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 10, 'x. Guide to the Art of the Australian Desert', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 11, 'xi. Field Guide to Animals of the World', false);


END$$;


COMMIT;