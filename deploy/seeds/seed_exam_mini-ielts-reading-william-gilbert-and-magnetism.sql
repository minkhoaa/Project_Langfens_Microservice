-- ============================================
-- IELTS Exam Data Import SQL
-- Generated: 2025-12-23T00:58:01.390224
-- Source: mini-ielts.com
-- Title: William Gilbert and Magnetism
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data for slug: mini-ielts-reading-william-gilbert-and-magnetism
DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'mini-ielts-reading-william-gilbert-and-magnetism'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'mini-ielts-reading-william-gilbert-and-magnetism';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'mini-ielts-reading-william-gilbert-and-magnetism';
DELETE FROM exams
WHERE "Slug" = 'mini-ielts-reading-william-gilbert-and-magnetism';

DO $$
DECLARE
  exam_id uuid := gen_random_uuid();
  sec1 uuid := gen_random_uuid();
  qid uuid;
BEGIN

  INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","ImageUrl","UpdatedAt")
  VALUES (
    exam_id,
    'mini-ielts-reading-william-gilbert-and-magnetism',
    'William Gilbert and Magnetism',
    'IELTS Reading Practice Test from IELTS Mentor',
    'IELTS',
    'B2',
    'PUBLISHED',
    20,
    'http://images.mini-ielts.com/images/2024/wil-gilbert.jpeg',
    now()
  );

  INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","PassageMd")
  VALUES (
    sec1,
    exam_id,
    1,
    'Reading Passage - William Gilbert and Magnetism',
    E'**Questions 1-7:**\nChoose the correct heading for each paragraph from the list of headings below.\n\nWrite the correct number **i-x** in boxes **1-7** on your answer sheet.\n\n**List of Headings**\n- i. Early years of Gilbert\n- ii. What was new about his scientific research method\n- iii. The development of chemistry\n- iv. Questioning traditional astronomy\n- v. Pioneers of the early science\n- vi. Professional and social recognition\n- vii. Becoming the president of the Royal Science Society\n- viii. The great works of Gilbert\n- ix. His discovery about magnetism\n- x. His change of focus\n\n---\n\n**Questions 8-10:**\nDo the following statements agree with the information given in Reading Passage 1?\n\nIn boxes **8-10** on your answer sheet, write\n- **TRUE** if the statement agrees with the information\n- **FALSE** if the statement contradicts the information\n- **NOT GIVEN** if there is no information on this\n\n---\n\n**Questions 11-13:**\nChoose the correct answers **A-F**.\n\nWhich of the following are parts of Gilbert''s discovery?',
    E'# Passage\n\n# William Gilbert and Magnetism\n\n**Paragraph A.**\nThe 16th and 17th centuries saw two great pioneers of modern science: Galileo and Gilbert. The impact of their findings is eminent. Gilbert was the first modern scientist, also the accredited father of the science of electricity and magnetism, an Englishman of learning and a physician at the court of Elizabeth. Prior to him, all that was known of electricity and magnetism was what the ancients knew, nothing more than that the lodestone possessed magnetic properties and that amber and jet, when rubbed, would attract bits of paper or other substances of small specific gravity. However, he is less well known than he deserves.\n\n**Paragraph B.**\nGilbert’s birth pre-dated Galileo. Born in an eminent local family in Colchester County in the UK, on May 24, 1544, he went to grammar school, and then studied medicine at St John’s College, Cambridge, graduating in 1573. Later he travelled in the continent and eventually settled down in London.\n\n**Paragraph C.**\nHe was a very successful and eminent doctor. All this culminated in his election to the president of the Royal Science Society. He was also appointed personal physician to the Queen (Elizabeth I), and later knighted by the Queen. He faithfully served her until her death. However, he didn’t outlive the Queen for long and died on November 30, 1603, only a few months after his appointment as personal physician to King James.\n\n**Paragraph D.**\nGilbert was first interested in chemistry but later changed his focus due to the large portion of mysticism of alchemy involved (such as the transmutation of metal). He gradually developed his interest in physics after the great minds of the ancient, particularly about the knowledge the ancient Greeks had about lodestones, strange minerals with the power to attract iron. In the meantime, Britain became a major seafaring nation in 1588 when the Spanish Armada was defeat­ed, opening the way to British settlement of America. British ships depended on the magnetic compass, yet no one understood why it worked. Did the Pole Star attract it, as Columbus once speculated; or was there a magnetic mountain at the pole, as described in Odyssey, which ships would never approach, because the sail­ors thought its pull would yank out all their iron nails and fittings? For nearly 20 years, William Gilbert conducted ingenious experiments to understand magnet­ism. His works include On the Magnet, Magnetic Bodies, and the Great Magnet of the Earth.\n\n**Paragraph E.**\nE Gilbert’s discovery was so important to modern physics. He investigated the nature of magnetism and electricity. He even coined the word “electric”. Though the early beliefs of magnetism were also largely entangled with superstitions such as that rubbing garlic on lodestone can neutralise its magnetism, one example being that sailors even believed the smell of garlic would even interfere with the action of compass, which is why helmsmen were forbidden to eat it near a ship’s compass. Gilbert also found that metals can be magnetised by rubbing mater­ials such as fur, plastic or the like on them. He named the ends of a magnet “north pole” and “south pole”. The magnetic poles can attract or repel, depending on polarity. In addition, however, ordinary iron is always attracted to a magnet. Though he started to study the relationship between magnetism and electricity, sadly he didn’t complete it. His research of static electricity using amber and jet only demonstrated that objects with electrical charges can work like magnets attracting small pieces of paper and stuff. It is a French guy named du Fay that discovered that there are actually two electrical charges, positive and negative.\n\n**Paragraph F.**\nHe also questioned the traditional astronomical beliefs. Though a Copernican, he didn’t express in his quintessential beliefs whether the earth is at the centre of the universe or in orbit around the sun. However, he believed that stars are not equidistant from the earth but have their own earth-like planets orbiting around them. The earth itself is like a giant magnet, which is also why compasses always point north. They spin on an axis that is aligned with the earth’s polarity. He even likened the polarity of the magnet to the polarity of the earth and built an entire magnetic philosophy on this analogy. In his explanation, magnetism is the soul of the earth. Thus a perfectly spherical lodestone, when aligned with the earth’s poles, would wobble all by itself in 24 hours. Further, he also believed that the sun and other stars wobble just like the earth does around a crystal core, and speculated that the moon might also be a magnet caused to orbit by its magnetic attraction to the earth. This was perhaps the first proposal that a force might cause a heavenly orbit.\n\n**Paragraph G.**\nHis research method was revolutionary in that he used experiments rather than pure logic and reasoning like the ancient Greek philosophers did. It was a new attitude towards scientific investigation. Until then, scientific experiments were not in fashion. It was because of this scientific attitude, together with his contri­bution to our knowledge of magnetism, that a unit of magneto motive force, also known as magnetic potential, was named Gilbert in his honour. His approach of careful observation and experimentation rather than the authoritative opinion or deductive philosophy of others had laid the very foundation for modern science.'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    1,
    'MATCHING_HEADING',
    'READING',
    2,
    'Paragraph A',
    '',
    '{"paragraph-a-q1": ["v", "v"]}'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'i. Early years of Gilbert', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'ii. What was new about his scientific research method', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'iii. The development of chemistry', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'iv. Questioning traditional astronomy', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, 'v. Pioneers of the early science', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 6, 'vi. Professional and social recognition', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 7, 'vii. Becoming the president of the Royal Science Society', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 8, 'viii. The great works of Gilbert', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 9, 'ix. His discovery about magnetism', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 10, 'x. His change of focus', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    2,
    'MATCHING_HEADING',
    'READING',
    2,
    'Paragraph B',
    '',
    '{"paragraph-b-q2": ["i", "i"]}'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'i. Early years of Gilbert', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'ii. What was new about his scientific research method', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'iii. The development of chemistry', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'iv. Questioning traditional astronomy', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, 'v. Pioneers of the early science', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 6, 'vi. Professional and social recognition', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 7, 'vii. Becoming the president of the Royal Science Society', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 8, 'viii. The great works of Gilbert', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 9, 'ix. His discovery about magnetism', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 10, 'x. His change of focus', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    3,
    'MATCHING_HEADING',
    'READING',
    2,
    'Paragraph C',
    '',
    '{"paragraph-c-q3": ["vi", "vi"]}'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'i. Early years of Gilbert', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'ii. What was new about his scientific research method', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'iii. The development of chemistry', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'iv. Questioning traditional astronomy', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, 'v. Pioneers of the early science', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 6, 'vi. Professional and social recognition', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 7, 'vii. Becoming the president of the Royal Science Society', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 8, 'viii. The great works of Gilbert', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 9, 'ix. His discovery about magnetism', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 10, 'x. His change of focus', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    4,
    'MATCHING_HEADING',
    'READING',
    2,
    'Paragraph D',
    '',
    '{"paragraph-d-q4": ["x", "x"]}'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'i. Early years of Gilbert', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'ii. What was new about his scientific research method', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'iii. The development of chemistry', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'iv. Questioning traditional astronomy', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, 'v. Pioneers of the early science', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 6, 'vi. Professional and social recognition', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 7, 'vii. Becoming the president of the Royal Science Society', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 8, 'viii. The great works of Gilbert', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 9, 'ix. His discovery about magnetism', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 10, 'x. His change of focus', true);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    5,
    'MATCHING_HEADING',
    'READING',
    2,
    'Paragraph E',
    '',
    '{"paragraph-e-q5": ["ix", "ix"]}'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'i. Early years of Gilbert', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'ii. What was new about his scientific research method', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'iii. The development of chemistry', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'iv. Questioning traditional astronomy', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, 'v. Pioneers of the early science', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 6, 'vi. Professional and social recognition', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 7, 'vii. Becoming the president of the Royal Science Society', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 8, 'viii. The great works of Gilbert', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 9, 'ix. His discovery about magnetism', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 10, 'x. His change of focus', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    6,
    'MATCHING_HEADING',
    'READING',
    2,
    'Paragraph F',
    '',
    '{"paragraph-f-q6": ["iv", "iv"]}'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'i. Early years of Gilbert', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'ii. What was new about his scientific research method', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'iii. The development of chemistry', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'iv. Questioning traditional astronomy', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, 'v. Pioneers of the early science', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 6, 'vi. Professional and social recognition', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 7, 'vii. Becoming the president of the Royal Science Society', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 8, 'viii. The great works of Gilbert', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 9, 'ix. His discovery about magnetism', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 10, 'x. His change of focus', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    7,
    'MATCHING_HEADING',
    'READING',
    2,
    'Paragraph G',
    '',
    '{"paragraph-g-q7": ["ii", "ii"]}'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'i. Early years of Gilbert', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'ii. What was new about his scientific research method', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'iii. The development of chemistry', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'iv. Questioning traditional astronomy', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, 'v. Pioneers of the early science', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 6, 'vi. Professional and social recognition', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 7, 'vii. Becoming the president of the Royal Science Society', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 8, 'viii. The great works of Gilbert', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 9, 'ix. His discovery about magnetism', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 10, 'x. His change of focus', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    8,
    'TRUE_FALSE_NOT_GIVEN',
    'READING',
    2,
    'He is less famous than he should be.',
    '',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'TRUE. if the statement agrees with the information', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'FALSE. if the statement contradicts the information', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'NOT GIVEN. if there is no information on this', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    9,
    'TRUE_FALSE_NOT_GIVEN',
    'READING',
    2,
    'He was famous as a doctor before he was employed by the Queen.',
    '',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'TRUE. if the statement agrees with the information', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'FALSE. if the statement contradicts the information', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'NOT GIVEN. if there is no information on this', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    10,
    'TRUE_FALSE_NOT_GIVEN',
    'READING',
    2,
    'He lost faith in the medical theories of his time.',
    '',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'TRUE. if the statement agrees with the information', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'FALSE. if the statement contradicts the information', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'NOT GIVEN. if there is no information on this', true);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    11,
    'MULTIPLE_CHOICE_SINGLE',
    'READING',
    2,
    'Which of the following are parts of Gilbert''s discovery? (Answer 1 of 3)',
    '',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. Metal can be transformed into another.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. Garlic can remove magnetism.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. Metals can be magnetised.', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D. Stars are at different distances from the earth.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, 'E. The earth wobbles on its axis.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 6, 'F. There are two charges of electricity.', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    12,
    'MULTIPLE_CHOICE_SINGLE',
    'READING',
    2,
    'Which of the following are parts of Gilbert''s discovery? (Answer 2 of 3)',
    '',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. Metal can be transformed into another.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. Garlic can remove magnetism.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. Metals can be magnetised.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D. Stars are at different distances from the earth.', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, 'E. The earth wobbles on its axis.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 6, 'F. There are two charges of electricity.', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    13,
    'MULTIPLE_CHOICE_SINGLE',
    'READING',
    2,
    'Which of the following are parts of Gilbert''s discovery? (Answer 3 of 3)',
    '',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. Metal can be transformed into another.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. Garlic can remove magnetism.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. Metals can be magnetised.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D. Stars are at different distances from the earth.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, 'E. The earth wobbles on its axis.', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 6, 'F. There are two charges of electricity.', false);


END$$;


COMMIT;