-- ============================================
-- IELTS Exam Data Import SQL
-- Generated: 2025-12-20T20:26:32.299933
-- Source: ielts-mentor.com
-- Title: GT Reading 37 Section 2 - Want to Buy a Business? & Parcel Fox
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data for slug: ielts-mentor-gt-reading-37-section-2-want-to-buy-a-business-parcel-fox
DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-mentor-gt-reading-37-section-2-want-to-buy-a-business-parcel-fox'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-mentor-gt-reading-37-section-2-want-to-buy-a-business-parcel-fox';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-mentor-gt-reading-37-section-2-want-to-buy-a-business-parcel-fox';
DELETE FROM exams
WHERE "Slug" = 'ielts-mentor-gt-reading-37-section-2-want-to-buy-a-business-parcel-fox';

DO $$
DECLARE
  exam_id uuid := gen_random_uuid();
  sec1 uuid := gen_random_uuid();
  qid uuid;
BEGIN

  INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","UpdatedAt")
  VALUES (
    exam_id,
    'ielts-mentor-gt-reading-37-section-2-want-to-buy-a-business-parcel-fox',
    'GT Reading 37 Section 2 - Want to Buy a Business? & Parcel Fox',
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
    'Reading Passage - GT Reading 37 Section 2 - Want to Buy a Business? & Parcel Fox',
    E'# Passage\n\n# Want to Buy a Business? - Read On & Parcel Fox - Business Courier Service\n\nBuying an established business is a good option for some aspiring entrepreneurs, as much of the groundwork for success may have already been done by the existing owners. Before making an offer, there are some important things to investigate. Initially, it is likely that you may only have access to a company’s business sale memorandum. Sellers will usually ask you to sign a confidentiality undertaking or non-disclosure agreement before you can access sensitive or detailed information. They will usually also ask for details about you (via a CV) and evidence of your ability to fund a purchase. After an offer is made and agreed on, due diligence is carried out. This is where the buyer looks at the business in detail, including its finances, its employees, outstanding litigation, major contracts, IT and other technology. It may sound complex, but professionals such as accountants, solicitors, chartered surveyors, Business transfer agents, business brokers and corporate financiers can help. You can also do some of the research yourself. Much of the information you’ll want to know about a business you are hoping to buy will be confidential, while some will be publicly available. If a vendor is keen to sell, then they should co-operate fully and give you all of the information you need to arrive at an offer. This may include looking at bank loan details, property rental contracts and intellectual property licences, for example. It is likely you will be asked to sign a confidentiality agreement (also known as a non-disclosure agreement). This protects the existing business owner and stops you from using any information you have learned about the way the business is run should negotiations breakdown. Get a solicitor or lawyer to read anything you are asked to sign or check carefully for any clauses that could have a negative impact on any other businesses you own or are considering starting. You may already be looking at developing a product similar to one offered by the business, for example, and the confidentiality agreement may prevent you doing this if the deal falls through. Once a business has been purchased, it is important to respect the Data Protection Act for any information transferred to you under the sale, such as employee records. It is wise to seek expert legal advice or speak to the Information Commissioner’s Office. There are several stages to the official process of buying or selling a business. They start with valuing the business, followed by getting tax advice, market research and marketing, preliminary offers, negotiating terms, heads of agreement, legal sale and purchase agreement, completing due diligence, and finally, completing the sale. Ensure each stage of the negotiation is documented and include all agreements and conditions in the final contract. Do this even if the business is small and the sale straightforward. Take expert advice from an accountant and a solicitor throughout the process, as this will stop you making costly mistakes. You can also seek advice from a tax specialist to ensure that the deal you agree is tax efficient. Sellers should decide whether to use a business broker or not to handle the initial part of the process. When you’re setting up your business, it’s essential to think about how you’ll ultimately end your involvement with it. An exit strategy can help you to maximise the value you get from your business, successfully market your business to potential buyers or investors and ensure you end your involvement with as little disruption to the business as possible. Regardless of whether your exit occurs to a planned schedule or whether you are forced to make a move for unexpected reasons, the decisions you make when setting up can affect how easy it is for you to eventually exit your business.\n\n14. What is the first document that a business buyer will most probably be able to see before signing a non-disclosure agreement? UK Domestic Product This includes a complete range of delivery options to ensure that you can send and receive your goods exactly when you want them. You will have peace of mind, knowing that we’ll deliver THE next day at a time convenient to you, anywhere in the UK. Next Day Services: Pre 09:00 (delivery between 07:30 – 09:00) Pre 10:30 (delivery between 07:30 – 10:30) Pre 12:00 (delivery between 07:30 – 12:00) Next Day (delivery between 07:30 – 17:30)\n\nSaturday Delivery - We offer a Saturday delivery service with three delivery options: Pre 09:00 (delivery between 07:30 – 09:00) Pre 10:30 (delivery between 07:30 – 10:30) Pre 12:00 (delivery between 07:30 – 12:00) City Link Packaging: We offer all customers two free of charge secure packaging options Linkletter – This has been designed to carry documents weighing up to 1kg Citypack – This will take any item up to a maximum of 10kg Our Additional Services Include (at extra cost): Collect From Us - A service for people on the move, such as field sales or engineers. We’ll hold items at a specified depot for secure collection by your nominated person. Exchange - Combines the delivery of one item with the exchange for another to be delivered the next day. Third Party/Remote Collections - Collection from any address and delivery to any other address in the UK. Drop into Us - Goods can be dropped into any City Link depot regardless of where your account is held. Sameday Is tomorrow too late? If so, we have the solution. Sameday is our specialist, dedicated service for time-critical and time-definite deliveries. It’s perfect for deliveries of all sizes throughout the UK and Europe. By offering complete flexibility and dedication, we ensure that you get the exact service you need, and your customers want. Just one call will connect you to your local same day controller 24 hours a day, 7 days a week, 365 days a year. What’s more, once you confirm your booking we guarantee to be with you within the hour with an extensive range of vehicle options. Your local controller will tailor a complete solution for all your requirements. International Our International service is a versatile and reliable door-to-door delivery service for single or multi-item consignments and pallets. We pride ourselves in being able to offer a complete range of International export and import delivery services boasting total reliability, security and value for money. So whether you are a small or large volume shipper, we offer a flexible range of delivery solutions to support your business needs by sea, air and road.'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    14,
    'SHORT_ANSWER',
    'READING',
    2,
    'What is the first document that a business buyer will most probably be able to see before signing a non-disclosure agreement?',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q14": ["(Business) sale memorandum"]}'::jsonb
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
    'What process is carried out after an offer to buy a business has been submitted and accepted? _______',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q15": ["Due diligence"]}'::jsonb
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
    'What kind of information is given in the text as an example of information protected by the Data Protection Act? _______',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q16": ["Employee records"]}'::jsonb
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
    'According to the text, what is the first phase of the formal procedure of buying or selling a business? _______',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q17": ["Valuing (the business)"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    18,
    'SHORT_ANSWER',
    'READING',
    2,
    'What does the text say you can avoid by consulting an accountant and solicitor?',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q18": ["(Making) costly mistakes"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    19,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    'It is important to consult with someone specialising in taxation to ensure that your decision is _______',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q19": ["Tax efficient"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    20,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    'Because by eventually leaving the business you buy might adversely affect it, it’s important to plan an _______',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q20": ["Exit strategy"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    21,
    'TRUE_FALSE_NOT_GIVEN',
    'READING',
    2,
    'You can send documents weighing one and a half kilograms by Linkletter.',
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
    22,
    'TRUE_FALSE_NOT_GIVEN',
    'READING',
    2,
    'Deliveries can be made at any time on Saturdays using the UK Domestic Product.',
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
    23,
    'TRUE_FALSE_NOT_GIVEN',
    'READING',
    2,
    'Pets can be sent within the UK on payment of a special fee.',
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
    24,
    'TRUE_FALSE_NOT_GIVEN',
    'READING',
    2,
    'For a fee, packages can be picked up by Parcel Fox from any address in the UK.',
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
    25,
    'TRUE_FALSE_NOT_GIVEN',
    'READING',
    2,
    'A bespoke service for your delivery requirements can be arranged at any time during the year.',
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
    26,
    'TRUE_FALSE_NOT_GIVEN',
    'READING',
    2,
    'Sameday deliveries cannot be guaranteed for deliveries to the US.',
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
    27,
    'TRUE_FALSE_NOT_GIVEN',
    'READING',
    2,
    'International deliveries can only be sent by plane or ship.Parcel Fox - Business Courier Service',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'TRUE', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'FALSE', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'NOT GIVEN', false);


END$$;


COMMIT;