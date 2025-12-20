-- ============================================
-- IELTS Exam Data Import SQL
-- Generated: 2025-12-20T19:40:53.360488
-- Source: ielts-mentor.com
-- Title: GT Reading 60: Section 1 - Inland Mail Claim Form & Days Out For The Family
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data for slug: ielts-mentor-gt-reading-60-section-1-inland-mail-claim-form-days-out-for-the-family
DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-mentor-gt-reading-60-section-1-inland-mail-claim-form-days-out-for-the-family'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-mentor-gt-reading-60-section-1-inland-mail-claim-form-days-out-for-the-family';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-mentor-gt-reading-60-section-1-inland-mail-claim-form-days-out-for-the-family';
DELETE FROM exams
WHERE "Slug" = 'ielts-mentor-gt-reading-60-section-1-inland-mail-claim-form-days-out-for-the-family';

DO $$
DECLARE
  exam_id uuid := gen_random_uuid();
  sec1 uuid := gen_random_uuid();
  qid uuid;
BEGIN

  INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","UpdatedAt")
  VALUES (
    exam_id,
    'ielts-mentor-gt-reading-60-section-1-inland-mail-claim-form-days-out-for-the-family',
    'GT Reading 60: Section 1 - Inland Mail Claim Form & Days Out For The Family',
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
    'Reading Passage - GT Reading 60: Section 1 - Inland Mail Claim Form & Days Out For The Family',
    E'# Passage\n\n# Lost, Damaged or Delayed Inland Mail Claim Form & Days out for the family\n\nBefore completing this claim form for lost, damaged or delayed mail you should visit www.royalmail.com to find out all you need to know about our policies. Alternatively you can get the details from our "Mail Made easy" booklet, available at any local post office branch. When you fill in the form, make sure you complete it in full, using the checklist that we have provided to help you. If you find that you do not have the evidence required to make a claim but world like us to investigate an issue with your mail service, the easiest way to do this is by visiting our website.\n\nLost items If you wish to claim compensation for lost items, you should send us original proof of posting, e.g. a Post Office receipt. If claiming for the contents of a package, you also need to provide proof of value, e.g. till item reference number, receipt, bank statement etc.\n\nDamaged items When claiming compensation for lost items that have been damaged, you should send us the items themselves, if possible. However, if these are very large or unsafe to post, you may instead provide photographs as evidence of the damage. Please retain the original packaging (and damaged items, if not sent to us) as we may need to inspect them.\n\nTime restrictions We allow up to 15 working days for items to arrive, so cannot accept a claim for loss unless 15 working days or more have passed since the items was posted.\n\nClaims for lost or damaged items must be made within 12 months of the postal date. Claims for delayed item must be submitted within 3 months of the date they were posted if the claim is made by the sender, or within 1 month of receipt if the claim is made by the recipient of the item.\n\nA. Carrickfergus Castle Considered to be Northern Ireland’s oldest castle, Carrickfergus has seen more than 800 years of military occupation since its foundations were laid, During summer, traditional feasts are served, and fairs and craft markets provide an extra attraction. The history of the castle is explained and brought to life with exhibits and guided tours.\n\nB. Glamis Castle Shakespeare used Glamis as the background when he wrote one of his best-known plays, Macbeth and the Queen Mother Grew up here. It is also rumoured to have a secret chamber in the walls of the castle. There are many ghost tales associated with this castle, which will capture the imagination of younger visitors.\n\nC. Tintagel Castle High up on the cliff tops, Tintagel Castle is the legendary home of king Arthur. The visitor''s guide on sale at the reception is well worth of the money, as it can help you to visualise what it would have been like hundreds of years ago. you can park in the village car park and walk the half mile to the castle, or take the shuttle bus.\n\nD. Pickering Castle Built by William the conqueror, this is a great castle for children to run around in. There are lots of special events too, including a chance to come along and see some plays which are put on during the summer months. Nearby Helmsley Castle is also worth a visit.\n\nE. Stokesay Castle A range of workshops, including music and combat, are held here during the summer, children of all ages will enjoy learning at these and there is a guided tour which has been especially designed with younger visitors in mind. Some of them may find the dungeon quite scary though.\n\nF. Warwick Castle This castle is over 1,000 years old and has towers and a moat, and is just as you might imagine a castle to be. Children can even get to try on armour to see how heavy it is. At Christmas, a special market id held here – a great opportunity to look for presents and Christmas treats.\n\n8. At certain times of the year you can eat special meals here. 9. Children can get dressed up here. 10. There is another castle in the same area. 11. A lot of stories are told about this place. 12. Parts of the castle may be frightening for some children. 13. Play are performed here during part of the year. 14. A guided tour is offered which is particularly suitable for children.'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    1,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    '_______ that contains the relevant information.',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q1": ["booklet"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    2,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    '_______ to ensure all the relevant sections are completed.',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q2": ["checklist"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    3,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    '_______ to request action if you don’t have enough proof to make a claim).',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q3": ["website"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    4,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    'Complete the blank. _______ Question 4',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q4": ["value"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    5,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    '_______ showing the damage to the item.',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q5": []}'::jsonb
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
    '_______ that was used when the item was originally sent.',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q6": []}'::jsonb
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
    '_______ , you must claim within three months of posting the package.',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q7": ["sender"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    8,
    'MULTIPLE_CHOICE_SINGLE',
    'READING',
    2,
    'At certain times of the year you can eat special meals here.',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. Carrickfergus Castle', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. Glamis Castle', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. Tintagel Castle', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D. Pickering Castle', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    9,
    'MULTIPLE_CHOICE_SINGLE',
    'READING',
    2,
    'Children can get dressed up here.',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. Carrickfergus Castle', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. Glamis Castle', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. Tintagel Castle', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D. Pickering Castle', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    10,
    'MULTIPLE_CHOICE_SINGLE',
    'READING',
    2,
    'There is another castle in the same area.',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. Carrickfergus Castle', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. Glamis Castle', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. Tintagel Castle', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D. Pickering Castle', true);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    11,
    'MULTIPLE_CHOICE_SINGLE',
    'READING',
    2,
    'A lot of stories are told about this place.',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. Carrickfergus Castle', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. Glamis Castle', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. Tintagel Castle', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D. Pickering Castle', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    12,
    'MULTIPLE_CHOICE_SINGLE',
    'READING',
    2,
    'Parts of the castle may be frightening for some children.',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. Carrickfergus Castle', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. Glamis Castle', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. Tintagel Castle', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D. Pickering Castle', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    13,
    'MULTIPLE_CHOICE_SINGLE',
    'READING',
    2,
    'Play are performed here during part of the year.',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. Carrickfergus Castle', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. Glamis Castle', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. Tintagel Castle', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D. Pickering Castle', true);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    14,
    'MULTIPLE_CHOICE_SINGLE',
    'READING',
    2,
    'A guided tour is offered which is particularly suitable for children.',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. Carrickfergus Castle', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. Glamis Castle', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. Tintagel Castle', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D. Pickering Castle', false);


END$$;


COMMIT;