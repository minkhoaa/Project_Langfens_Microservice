-- ============================================
-- IELTS Exam Data Import SQL
-- Generated: 2025-12-20T16:28:24.807027
-- Source: ielts-mentor.com
-- Title: GT Reading 63 Section 2 - Vacancy for food preparation assistant & Setting up a business partnership
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data for slug: ielts-mentor-gt-reading-63-section-2-vacancy-for-food-preparation-assistant-setting-up-a-business-partnership
DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-mentor-gt-reading-63-section-2-vacancy-for-food-preparation-assistant-setting-up-a-business-partnership'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-mentor-gt-reading-63-section-2-vacancy-for-food-preparation-assistant-setting-up-a-business-partnership';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-mentor-gt-reading-63-section-2-vacancy-for-food-preparation-assistant-setting-up-a-business-partnership';
DELETE FROM exams
WHERE "Slug" = 'ielts-mentor-gt-reading-63-section-2-vacancy-for-food-preparation-assistant-setting-up-a-business-partnership';

DO $$
DECLARE
  exam_id uuid := gen_random_uuid();
  sec1 uuid := gen_random_uuid();
  qid uuid;
BEGIN

  INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","UpdatedAt")
  VALUES (
    exam_id,
    'ielts-mentor-gt-reading-63-section-2-vacancy-for-food-preparation-assistant-setting-up-a-business-partnership',
    'GT Reading 63 Section 2 - Vacancy for food preparation assistant & Setting up a business partnership',
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
    'Reading Passage - GT Reading 63 Section 2 - Vacancy for food preparation assistant & Setting up a business partnership',
    E'# Passage\n\n# Vacancy for food preparation assistant & Setting up a business partnership in the UK\n\nDurrant House plc runs restaurants and cafes as concessions in airports, train stations and other busy environments around the country. We currently have a vacancy for a food preparation assistant in our restaurant at Locksley Stadium, serving football fans and concert-goers before, during and after events. In addition, we cater for private parties several times a week. If you have relevant experience and a passion for preparing food to a very high standard, we’ll be delighted to hear from you. You must be able to multitask and to work in a fast-paced environment. It goes without saying that working as an effective and supportive member of a team is essential so you need to be happy in this type of work.\n\nThe role includes the usual responsibilities, such as treating hygiene as your number one priority, cleaning work areas, and doing whatever is required to provide food of excellent quality. The person appointed will carry out a range of tasks, including ensuring all raw food items are fresh, preparing vegetables to be cooked, making sure frozen food products are used in rotation, and throwing away any food products that are near or have passed their expiry date. He or she will be required to familiarise themselves with the storage system, so as to put food product supplies in the proper place and retrieve them in the right order. In particular; we are looking for someone with skill at baking, to play a large role in the production of pies and cakes.\n\nGiven the nature of the venue, working hours vary from week to week, depending on the events being held, and will often involve starting early in the morning or finishing late at night. You can expect to work an average of around 18 hours a week, although this cannot be guaranteed. You will also have the opportunity to work in another of our sites for one or two days a week, or for longer periods, and will be paid for ten days of holidays a year, Training will be provided in food safety.\n\nIf this sounds like the job for you, please contact Jo Simmons at This email address is being protected from spambots. You need JavaScript enabled to view it..\n\n• maintaining high standards of 17 .................. and quality • checking the freshness of raw food • ensuring no food is used after its expiry date • leaming the procedure for the 18 .................. of food • doing a considerable amount of the baking\n\nTwo or more people can go into business together by setting up either a limited company or a partnership. A partnership is the easier way to get started, and simply links two or more people together in a simple business structure. Unlike a limited company, a partnership doesn’t have a separate legal status. The partners are usually self-employed individuals, although a limited company counts as a ‘legal person’ and can also be a partner.\n\nIn a partnership, you and your partner or partners personally share responsibility for your business. This means, among other things, that if your business cannot afford to pay its debts, you must pay them yourselves. Again, this is not the case with a limited company. Partners share the business’s profits, and each partner pays tax on their share.\n\nWhen you set up a business partnership you need to choose a name. You can trade under your own names, for example, ‘Smith and Jones’, or you can choose another name for your business. You don’t need to register your name. However, you should register your name as a trademark if you want to stop people from trading under your business name.\n\nBusiness partnership names must not include ‘limited’, ‘Ltd’, ‘limited liability partnership’, ‘LLP’, ‘public limited company’ or ‘pic’, be offensive, or be the same as an existing trademark. Your name also can’t suggest a connection with government or local authorities, unless you get permission. There is no central database of partnership names in the UK, so to avoid using the same name as another business, it is advisable to search on the internet for the name you are considering.\n\nYou must include all the partners’ names and the business name (if you have one) on official paperwork, for example invoices. You must choose a ‘nominated partner’ who is responsible for registering your partnership with HM Revenue and Customs (HMRC), the government department responsible for the collection of taxes. This person is responsible for managing the partnership’s tax returns and keeping business records. Alternatively, you can appoint an agent to deal with HMRC on your behalf.\n\nAll partners need to register with HMRC separately and send their own tax returns as individuals. You must register by 5 October in your business’s second tax year, or you could be charged a penalty. You must also register for VAT if your VAT taxable turnover is more than £85,000. You can choose to register if it’s below this, for example to reclaim VAT on business supplies. ................. as a legal body. ................. . ................. are divided between the partners. ................. . ................. . ................. and other documents. ................. for all contact with HMRC. ................. if you miss the deadline for registering the partnership.'
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
    'Location of restaurant: in a _______',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q15": ["STADIUM"]}'::jsonb
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
    'must enjoy working in a _______',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q16": ["TEAM"]}'::jsonb
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
    'maintaining high standards of _______ and quality',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q17": ["HYGIENE"]}'::jsonb
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
    'learning the procedure for the _______ of food',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q18": ["STORAGE"]}'::jsonb
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
    'working hours are not _______',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q19": ["GUARANTEED"]}'::jsonb
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
    'A partnership is different from a limited company in not having its own _______ as a legal body.',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q20": ["STATUS"]}'::jsonb
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
    'The partners are personally responsible for paying all the partnership''s _______.',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q21": ["DEBTS"]}'::jsonb
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
    'The partnership''s _______ are divided between the partners.',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q22": ["PROFITS"]}'::jsonb
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
    'Registering the partnership''s name prevents others from using that name when _______.',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q23": ["TRADING"]}'::jsonb
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
    'The best way to find out if a name is already in use is to use the _______.',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q24": ["INTERNET"]}'::jsonb
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
    'The names of the partners and the partnership must appear on _______ and other documents.',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q25": ["INVOICES"]}'::jsonb
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
    'You must have a nominated partner, or someone to act as your _______ for all contact with HMRC.',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q26": ["AGENT"]}'::jsonb
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
    'You will have to pay a _______ if you miss the deadline for registering the partnership.',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q27": ["PENALTY"]}'::jsonb
  );


END$$;


COMMIT;