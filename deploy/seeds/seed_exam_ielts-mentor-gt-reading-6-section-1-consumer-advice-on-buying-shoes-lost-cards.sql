-- ============================================
-- IELTS Exam Data Import SQL
-- Generated: 2025-12-21T11:18:58.032550
-- Source: ielts-mentor.com
-- Title: GT Reading 6 Section 1 - Consumer advice on buying shoes & Lost Cards
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data for slug: ielts-mentor-gt-reading-6-section-1-consumer-advice-on-buying-shoes-lost-cards
DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-mentor-gt-reading-6-section-1-consumer-advice-on-buying-shoes-lost-cards'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-mentor-gt-reading-6-section-1-consumer-advice-on-buying-shoes-lost-cards';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-mentor-gt-reading-6-section-1-consumer-advice-on-buying-shoes-lost-cards';
DELETE FROM exams
WHERE "Slug" = 'ielts-mentor-gt-reading-6-section-1-consumer-advice-on-buying-shoes-lost-cards';

DO $$
DECLARE
  exam_id uuid := gen_random_uuid();
  sec1 uuid := gen_random_uuid();
  qid uuid;
BEGIN

  INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","UpdatedAt")
  VALUES (
    exam_id,
    'ielts-mentor-gt-reading-6-section-1-consumer-advice-on-buying-shoes-lost-cards',
    'GT Reading 6 Section 1 - Consumer advice on buying shoes & Lost Cards',
    'IELTS Reading Practice Test from IELTS Mentor',
    'IELTS',
    'B2',
    'PUBLISHED',
    20,
    now()
  );

  INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","PassageMd")
  VALUES (
    sec1,
    exam_id,
    1,
    'Reading Passage - GT Reading 6 Section 1 - Consumer advice on buying shoes & Lost Cards',
    E'**Questions 1-8:**\nDo the following statements agree with the information given in the text?\n\nWrite\n- **TRUE** if the statement agrees with the information\n- **FALSE** if the statement contradicts the information\n- **NOT GIVEN** if there is no information on this\n\n---\n\n**Questions 9-14:**\nChoose the correct letter, **A**, **B**, **C** or **D**.\n\n---\n\n# CONSUMER ADVICE ON BUYING SHOES',
    E'**Paragraph A.**\nIf you have a problem with shoes you\'\'ve recently bought, follow this four-step plan. Go back to the shop with proof of purchase. If you return faulty shoes at once, you have a right to insist on a refund. It is also likely that you will get one if you change your mind about the shoes and take them back immediately. But, if you delay or you\'\'ve had some use out of the shoes, the shop may not give you all your money back. It depends on the state of the shoes and how long you\'\'ve had them.\n\n**Paragraph B.**\nIf you are offered a credit note, you don\'\'t have to accept it. If you accept it, you will usually not be able to exchange it for cash later on. So, you may be left with an unwanted credit note, if you cannot find any other shoes you want from the shop. The shop may want to send the shoes back to head office for inspection. This is fair and could help to sort things out. But don\'\'t be put off by the shop which claims that it\'\'s the manufacturer\'\'s responsibility. This isn\'\'t true. It\'\'s the shop\'\'s legal duty to put things right.\n\n**Paragraph C.**\nIf you don\'\'t seem to be getting anywhere, you can get help. Free advice is available from a Citizens Advice Bureau (get the address from your telephone book), or from a local Trading Standards Department. Again, consult the telephone directory under County, Regional or Borough Council. All these departments have people who can advise you about faulty goods and what to do with them.\n\n**Paragraph D.**\nMost shops are covered by the Footwear Code of Practice. If the shop you are dealing with is covered, you can ask for the shoes to be sent to the Footwear Testing Centre for an independent opinion. The shop has to agree with whatever the resulting report says. There is a charge of £21. You pay £7 and the shop pays the rest (including postage).\n\n**Paragraph E.**\nAs a last resort, you can take your case to court. This is not as difficult as it sounds. The small claims procedure for amounts up to £1000 (£750 in Scotland) is a cheap, easy and informal way of taking legal action. The relevant forms are available from your nearest County Court or, in Scotland, the Sheriff Court. You can get advice and leaflets from the Citizens Advice Bureau. Alternatively, some bookshops sell advice packs which contain the relevant forms.\n\n---\n\n# LOST CARDS\n\n**Paragraph F.**\nIf you discover that your credit card, cheque book, debit card or cash card is missing, telephone the credit card company or bank as soon as possible. Follow this up with a letter. If you suspect theft, tell the police as well. In most circumstances, provided you act quickly, you will not have to pay any bills which a thief runs up on your account. Most home insurance policies will also cover you against even this limited risk.\n\n**Paragraph G.**\nBecause plastic money is now so common, central registration schemes such as Credit Card Shield and Card Protection System exist to help customers whose cards are lost or stolen. Under the schemes, you file details of all your cards - including cash cards and account cards issued by shops - with a central registry, for a small annual fee. Then, if any or all of your cards are stolen, you need to make only one phone call to the registry, which is open around the clock 365 days a year. As soon as you have called, your responsibility for any bills run up by the thief ends and the scheme\'\'s staff make sure that all the companies whose cards you had are notified.\n\n**Paragraph H.**\nCREDIT CARD: You will not have to pay more than £50 of the bills a thief runs up with your card. If you report the loss before the card is used, you will not have to pay anything.\n\n**Paragraph I.**\nCHEQUES AND GUARANTEE CARD: Unless you have been careless - by signing blank cheques, say - you will not have to pay for any forged cheques a thief uses. The bank or shop that accepts them will have to bear the loss.\n\n**Paragraph J.**\nDEBIT CARD (Switch or Visa Delta): The banks operate a system similar to that for credit cards, in that you are liable for bills up to £50.\n\n**Paragraph K.**\nCASH CARD: Legally, you can be made to pay back any sums a thief withdraws using your card, but only up to the time you report the loss and up to £50, unless the bank can prove gross negligence, such as writing your personal identification number on your card.\n\n**Tips:**\n• Never keep your card and a note of your personal number (which does not appear on the card) together.\n• Memorise your personal number if possible. If you must make a note of it, disguise it as something else - a telephone number, say.\n• The same rules and precautions apply to a credit card used as a cash card.'
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
    'If you return unwanted shoes straightaway, with a receipt, the shop will probably give you a refund.',
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
    2,
    'TRUE_FALSE_NOT_GIVEN',
    'READING',
    2,
    'You are advised to accept a credit note if you are offered one.',
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
    3,
    'TRUE_FALSE_NOT_GIVEN',
    'READING',
    2,
    'The factory is responsible for replacing unwanted shoes.',
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
    'You can ask any shoe shop to send shoes to the Footwear Testing Centre.',
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
    5,
    'TRUE_FALSE_NOT_GIVEN',
    'READING',
    2,
    'Shops prefer to give a credit note rather than change shoes.',
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
    6,
    'TRUE_FALSE_NOT_GIVEN',
    'READING',
    2,
    'The customer contributes to the cost of having faulty shoes tested.',
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
    7,
    'TRUE_FALSE_NOT_GIVEN',
    'READING',
    2,
    'The procedure for making a legal claim is easier in Scotland.',
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
    8,
    'TRUE_FALSE_NOT_GIVEN',
    'READING',
    2,
    'Legal advice and forms can be bought from certain shops.',
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
    9,
    'MULTIPLE_CHOICE_SINGLE',
    'READING',
    2,
    'What should you do first if you lose a credit card?',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. contact your insurance company', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. write a letter', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. contact the police', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D. make a phone call', true);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    10,
    'MULTIPLE_CHOICE_SINGLE',
    'READING',
    2,
    'Credit Card Shield is',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. an insurance company which deals with card theft.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. a system for registering people''s card details.', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. an emergency telephone answering service.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D. an agency for finding lost or stolen cards.', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    11,
    'MULTIPLE_CHOICE_SINGLE',
    'READING',
    2,
    'When contacted, the Card Protection System company will',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. inform the police about the loss of the card.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. get in touch with the relevant credit card companies.', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. ensure that lost cards are replaced.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D. give details about the loss of the card to shops.', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    12,
    'MULTIPLE_CHOICE_SINGLE',
    'READING',
    2,
    'You are fully covered by both banks and shops if you lose',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. a cheque that is signed but not otherwise completed.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. a blank unsigned cheque.', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. a Switch card', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D. a credit card', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    13,
    'MULTIPLE_CHOICE_SINGLE',
    'READING',
    2,
    'If you have written your personal number on a stolen card, you may have to',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. join a different credit card protection scheme.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. pay up to £50 for any loss incurred.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. pay for anything the thief buys on it.', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D. change your account to a different bank.', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    14,
    'MULTIPLE_CHOICE_SINGLE',
    'READING',
    2,
    'What happens if your cash card is stolen?',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. you arrange for the card to be returned.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. the bank stops you withdrawing money.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. you may have to pay up to £50 of any stolen money.', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D. you cannot use a cash card in future.', false);


END$$;


COMMIT;