-- ============================================
-- IELTS Exam Data Import SQL
-- Generated: 2025-12-24T22:17:04.437393
-- Source: mini-ielts.com
-- Title: The history of cakes at weddings
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data for slug: mini-ielts-reading-the-history-of-cakes-at-weddings
DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'mini-ielts-reading-the-history-of-cakes-at-weddings'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'mini-ielts-reading-the-history-of-cakes-at-weddings';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'mini-ielts-reading-the-history-of-cakes-at-weddings';
DELETE FROM exams
WHERE "Slug" = 'mini-ielts-reading-the-history-of-cakes-at-weddings';

DO $$
DECLARE
  exam_id uuid := gen_random_uuid();
  sec1 uuid := gen_random_uuid();
  qid uuid;
BEGIN

  INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","ImageUrl","UpdatedAt")
  VALUES (
    exam_id,
    'mini-ielts-reading-the-history-of-cakes-at-weddings',
    'The history of cakes at weddings',
    'IELTS Reading Practice Test from IELTS Mentor',
    'IELTS',
    'B2',
    'PUBLISHED',
    20,
    'https://res.cloudinary.com/df41zs8il/image/upload/v1766588221/ielts/royal-wedding-cake_resized_1bc5fccce51c.jpg',
    now()
  );

  INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","PassageMd")
  VALUES (
    sec1,
    exam_id,
    1,
    'Reading Passage - The history of cakes at weddings',
    E'**Questions 1-6:**\nDo the following statements agree with the information given in the passage?\nWrite:\n- **TRUE** if the statement agrees with the information\n- **FALSE** if the statement contradicts the information\n- **NOT GIVEN** if there is no information on this\n\n**1.** Breaking a cake over the bride’s head was the last part of an ancient Roman wedding ceremony.\n**2.** Confetti is still made of nuts, dried fruit and honeyed almonds.\n**3.** The groom’s family used to supply the confetti.\n**4.** It was considered lucky for a newly married couple to be able to kiss over a tower of spiced buns.\n**5.** Only brides were allowed to eat Bride Pie.\n**6.** The wedding cakes eaten in Britain today developed from Bride Cake of the 17th century.\n\n---\n\n**Questions 7-9:**\nComplete the notes below.\nChoose **ONE WORD ONLY** from the passage for each answer.\n\n### Wedding cakes\n**17th century - Britain Bride Cake:**\n- expensive ingredients were a sign of wealth\n- less expensive round cakes were made of **7** _______ with currants in between and sugar on top\n- they were baked on a hearth stone because not all homes had **8** _______\n\n**Now - United States - Groom’s cake:**\n- guest receive pieces of the groom’s cake\n- cakes may represent the **9** _______ of the groom\n\n---\n\n**Questions 10-13:**\nLabel the diagram below.\nChoose **ONE WORD ONLY** from the passage for each answer.\n\n![Diagram](https://res.cloudinary.com/df41zs8il/image/upload/v1766589423/ielts/cake_3b3cb4106bbb.jpg)\n\n**10.** Examples of wedding cakes with several **10** _______.\n**11.** In the early 1900s, **11** _______ were used to keep individual cakes apart.\n**12.** The size of these cakes as well as their **12** _______ affects pricing.\n**13.** Hardened **13** _______ between cakes stopped higher cakes sinking into lower cakes.',
    E'**Paragraph A.**\nIn Western cultures, since antiquity, weddings customarily have been celebrated with a special cake. Ancient Roman wedding ceremonies were finalized by breaking a cake of wheat or barley over the bride’s head as a symbol of good fortune. The newly married couple then ate some of the crumbs together. Afterward, the wedding guests gathered up the remaining crumbs as tokens of good luck. Wedding guests were also supplied with sweetmeats called confetti, a sweet mixture of nuts, dried fruit and honeyed almonds. Handfuls of confetti were showered over the bride and groom; indeed, it seems to have been the custom to throw confetti about enthusiastically. Eventually, confetti in the form of sweets and nuts was replaced with rice, flower petals, or colored paper, and these new types of confetti continue to be thrown over newly married couples in many countries around the world.\n\n**Paragraph B.**\nWhen the Romans invaded Britain in 43 AD, many of their customs and traditions became part of British life. These customs included their wedding customs, and when the Normans invaded Britain in 1066 they brought many French traditions. Other changes came about due to increased trade and contact with Europe, but present-day British wedding traditions remain firmly rooted in the past. In medieval Britain, small spiced buns, which were common everyday fare, were often eaten at weddings. These were stacked in a towering pile, as high as possible. If the bride and groom were able to kiss over the tall stack, it augured a lifetime of riches. The earliest British recipe exclusively for eating at weddings is Bride Pie, which was recorded in 1685. This was a large round pie with an elaborately decorated pastry crust that concealed a filling of oysters, pine nuts, lamb and spices. Each guest had to eat a small piece of the pie; not to do so was considered extremely impolite. A ring was traditionally placed in the pie, and the lady who found it would be next to marry.\n\n**Paragraph C.**\nIn the 17th century, Bride Pie was changed into Bride Cake, the predecessor of the modern British wedding cake. Cakes containing dried fruit and sugar, symbols of prosperity, gradually became the centerpieces for weddings. Some people made Bride Cake in the cheaper form of two large rounds of pastry sandwiched together with currants and sprinkled with sugar. Very few homes at the time could boast of having ovens, but this type of pastry cake could be cooked on a baking stone on the hearth.\n\n**Paragraph D.**\nLater in the 17th century, there was a new development when wedding cakes began to be made in pairs, one for the bride and another for the groom. Both cakes were dark, heavy fruitcakes; the groom’s cake was smaller than the bride’s cake, and was cut up into little squares that were placed in boxes for the guests to take home as a wedding memento. Groom’s cakes gradually died out and are no longer part of British weddings. However, the tradition has undergone a revival in the United States, where for many years the groom’s cake has served as a wedding gift for guests. Modern groom’s cakes are often formed and decorated to depict the groom’s hobby, for example a golf bag, a camera, a chess board.\n\n**Paragraph E.**\nGroom’s cakes were never covered with icing, but Bride Cake covered with white icing first appeared sometime in the 17th century. After the cake was baked, it was covered with a pure white, smooth icing made with double refined sugar, egg whites, and orange-flower water. The mixture was beaten for two hours, then spread over the cake and dried in the oven until hard. A pure white color was much sought after for wedding cake icing because white icing meant that only the finest refined sugar had been used. Thus a pure white cake was a status symbol, as it displayed the family’s wealth.\n\n**Paragraph F.**\nThe late 1800s in Britain saw the introduction of a new tradition, with the first multi-tiered wedding cakes. These were impressive cakes: they were heavy because they were made with so much dried fruit, and highly decorated with icing and embellished with sugar flowers, doves, horseshoes and bells. The first multi-tiered cakes comprised iced cakes stacked on top of each other rather like a succession of boxes gradually decreasing in size. The cakes from the upper tiers did not sink into the lower tiers because they were not put on top of each other until the icing between each cake had had time to harden. It was not until the beginning of the 20th century that the cake tiers were separated and supported by columns.\n\n**Paragraph G.**\nTwenty-first-century weddings are big business for Britain’s wedding industry. Over 300,000 people get married each year and a wedding can cost thousands of pounds. The cost of the all-important wedding cake can be hundreds of pounds, depending on the dimension and design. It will be interesting to see whether wedding cakes continue to be popular at weddings.'
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
    'Breaking a cake over the bride’s head was the last part of an ancient Roman wedding ceremony.',
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
    2,
    'TRUE_FALSE_NOT_GIVEN',
    'READING',
    2,
    'Confetti is still made of nuts, dried fruit and honeyed almonds.',
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
    3,
    'TRUE_FALSE_NOT_GIVEN',
    'READING',
    2,
    'The groom’s family used to supply the confetti.',
    '',
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
    4,
    'TRUE_FALSE_NOT_GIVEN',
    'READING',
    2,
    'It was considered lucky for a newly married couple to be able to kiss over a tower of spiced buns.',
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
    5,
    'TRUE_FALSE_NOT_GIVEN',
    'READING',
    2,
    'Only brides were allowed to eat Bride Pie.',
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
    6,
    'TRUE_FALSE_NOT_GIVEN',
    'READING',
    2,
    'The wedding cakes eaten in Britain today developed from Bride Cake of the 17th century.',
    '',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'TRUE', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'FALSE', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'NOT GIVEN', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    7,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    'less expensive round cakes were made of _______ with currants in between and sugar on top',
    '',
    '{"blank-q7": ["PASTRY"]}'::jsonb
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
    'they were baked on a hearth stone because not all homes had _______',
    '',
    '{"blank-q8": ["OVENS"]}'::jsonb
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
    'cakes may represent the _______ of the groom',
    '',
    '{"blank-q9": ["HOBBY"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    10,
    'DIAGRAM_LABEL',
    'READING',
    2,
    'Examples of wedding cakes with several _______ .',
    '',
    '{"blank-q10": ["BOXES"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    11,
    'DIAGRAM_LABEL',
    'READING',
    2,
    'In the early 1900s, _______ were used to keep individual cakes apart.',
    '',
    '{"blank-q11": ["COLUMNS"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    12,
    'DIAGRAM_LABEL',
    'READING',
    2,
    'The size of these cakes as well as their _______ affects pricing.',
    '',
    '{"blank-q12": ["DESIGN"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    13,
    'DIAGRAM_LABEL',
    'READING',
    2,
    'Hardened _______ between cakes stopped higher cakes sinking into lower cakes.',
    '',
    '{"blank-q13": ["ICING"]}'::jsonb
  );



  -- Delete old question groups for this exam
  DELETE FROM exam_question_groups WHERE "SectionId" = sec1;

  -- Insert question groups
  INSERT INTO exam_question_groups ("Id","SectionId","Idx","StartIdx","EndIdx","InstructionMd")
  VALUES (gen_random_uuid(), sec1, 1, 1, 6, E'## Questions 1-6\n\nDo the following statements agree with the information given in the passage?\n\nWrite:\n- **TRUE** if the statement agrees with the information\n- **FALSE** if the statement contradicts the information\n- **NOT GIVEN** if there is no information on this');

  INSERT INTO exam_question_groups ("Id","SectionId","Idx","StartIdx","EndIdx","InstructionMd")
  VALUES (gen_random_uuid(), sec1, 2, 7, 9, E'## Questions 7-9\n\nComplete the notes below.\n\nChoose **ONE WORD ONLY** from the passage for each answer.\n\n### Wedding cakes\n**17th century - Britain Bride Cake:**\n- expensive ingredients were a sign of wealth\n- less expensive round cakes were made of **7** _______ with currants in between and sugar on top\n- they were baked on a hearth stone because not all homes had **8** _______\n\n**Now - United States - Groom’s cake:**\n- guest receive pieces of the groom’s cake\n- cakes may represent the **9** _______ of the groom');

  INSERT INTO exam_question_groups ("Id","SectionId","Idx","StartIdx","EndIdx","InstructionMd")
  VALUES (gen_random_uuid(), sec1, 3, 10, 13, E'## Questions 10-13\n\nLabel the diagram below.\n\nChoose **ONE WORD ONLY** from the passage for each answer.\n\n![Diagram](https://res.cloudinary.com/df41zs8il/image/upload/v1766589423/ielts/cake_3b3cb4106bbb.jpg)');

END$$;


COMMIT;