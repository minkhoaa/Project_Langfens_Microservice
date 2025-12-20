-- ============================================
-- IELTS Exam Data Import SQL
-- Generated: 2025-12-20T19:40:53.355815
-- Source: ielts-mentor.com
-- Title: GT Reading 9 Section 2 - Advice to entrepreneurs & Managing the inventory
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data for slug: ielts-mentor-gt-reading-9-section-2-advice-to-entrepreneurs-managing-the-inventory
DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-mentor-gt-reading-9-section-2-advice-to-entrepreneurs-managing-the-inventory'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-mentor-gt-reading-9-section-2-advice-to-entrepreneurs-managing-the-inventory';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-mentor-gt-reading-9-section-2-advice-to-entrepreneurs-managing-the-inventory';
DELETE FROM exams
WHERE "Slug" = 'ielts-mentor-gt-reading-9-section-2-advice-to-entrepreneurs-managing-the-inventory';

DO $$
DECLARE
  exam_id uuid := gen_random_uuid();
  sec1 uuid := gen_random_uuid();
  qid uuid;
BEGIN

  INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","UpdatedAt")
  VALUES (
    exam_id,
    'ielts-mentor-gt-reading-9-section-2-advice-to-entrepreneurs-managing-the-inventory',
    'GT Reading 9 Section 2 - Advice to entrepreneurs & Managing the inventory',
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
    'Reading Passage - GT Reading 9 Section 2 - Advice to entrepreneurs & Managing the inventory',
    E'# Passage\n\n# Advice to entrepreneurs on starting a small business\n\nStep 1: Determine your marketing strategy. When the same aspect of the product appeals to a broad market base an undifferentiated marketing strategy works. Conversely, when advertising to different markets a differentiated strategy highlights different aspects of the product. A concentrated strategy, meanwhile, should be used when just one particular segment of the market is targeted, rather than a range of different segments. Step 2: Try out different ways of promoting your product. For example, test a variety of advertising campaigns within the same market base. Make sure each campaign emphasizes your product’s distinct selling point, and appeals to the emotions of each group you market your product to. Or consider testing the same campaign across more than one market base — you may find that one of them likes your product for a reason you hadn’t thought of. Or try placing your product in different types of stores, frequented by different consumer groups. Then evaluate the success of each campaign, and act on customer feedback gained from salespeople or follow-up surveys. Step 3: Seed the market, which means giving potential customers product samples, showing them why they need (or want) it. Strive to get your product into the hands of industry leaders, or companies that may need to purchase more than one item. Ask experts to test your product and provide testimonials. Step 4: Make your testimonials public by quoting them on your website and in your brochures, particularly the ones provided by experts and industry leaders. This will build credibility. Distribute press releases to the media to announce your product’s appearance, or any surprising and positive findings of the experts who have examined it. Step 5: Begin your chosen advertising campaign, targeting the markets you deemed as most receptive to your product. Hold a product release or grand opening event to generate local interest and publicity. Place ads in the publications your target market reads, on local radio and TV stations, and in newspapers. Step 6: Evaluate your product’s success on an ongoing basis. Note any longer-term changes in the market base, or in customer expectations of the product, and then reposition it as needed. For example, Proctor & Gamble repositioned its diapers by emphasising their range of sizes. They began marketing them under the name of Pampers Phases, which were geared toward babies and toddlers of different ages.\n\nInventory or stock refers to the goods and materials that a business holds for the ultimate purpose of resale. Inventory is among the more significant sources of revenue for a company. After all, inventory equals profit, so keeping an accurate account of product in stock and inventory to be ordered can have a dramatic financial impact on your business. In fact, bad inventory can affect more than just the bottom line, it can have a damaging effect on your organization in the following ways: Poor Customer Service: Lack of inventory control can result in a delay when shipping products to customers. Moreover, it can create a scenario in which you don’t have the proper parts available for a product because you failed to check your inventory. This results in overall poor service to the clients you serve, and customer dissatisfaction. Loss of Cost Effectiveness: Bad inventory can be quite costly to your organization. If you have too much inventory, it will be prone to damage or destruction over time due to reasons beyond your control. If you have no system for accurately monitoring inventory, you also may end up with shrinkage (inventory lost to theft). Finally, if you are spending more on additional inventory that you don’t need – because you don’t know what you have – you are wasting money. Poor Planning: Businesses track inventory so that they are able to fulfil customer orders at all times. However, it is also good business practice to plan ahead, and when you start with a bad cache of inventory, then you can’t properly plan. Moreover, if you have an unexpectedly large order – which is great for business, financially speaking – your bad inventory may again cost you money if you can’t fulfil it. ...…….. ...…….. in making deliveries. ...…….. and even ruin. ...…….. ...…….. may be lost if there is insufficient stock. ...……..'
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
    '_______ – a strategy for only one market segment.',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q15": ["concentrated (strategy)"]}'::jsonb
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
    'Complete the blank. _______ Question 16',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q16": ["selling point"]}'::jsonb
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
    'Complete the blank. _______ Question 17',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q17": ["stores"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    18,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    '_______ collected from customers.',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q18": ["feedback"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    19,
    'MATCHING_INFORMATION',
    'READING',
    2,
    '_______ to significant individuals or organisations',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, 'E', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 6, 'F', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    20,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    'minutes on Questions _______',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q20": ["testimonials"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    21,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    '_______ the product.',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q21": ["reposition"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    22,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    'Complete the blank. _______ Question 22',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q22": ["resale"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    23,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    'Complete the blank. _______ Question 23',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q23": ["delay"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    24,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    'Complete the blank. _______ Question 24',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q24": ["damage"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    25,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    'Complete the blank. _______ Question 25',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q25": ["theft"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    26,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    'Complete the blank. _______ Question 26',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q26": ["order"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    27,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    'Complete the blank. _______ Question 27',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q27": ["consultant"]}'::jsonb
  );


END$$;


COMMIT;