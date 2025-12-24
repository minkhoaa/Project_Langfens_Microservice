-- ============================================
-- IELTS Exam Data Import SQL
-- Generated: 2025-12-24T13:43:03.338494
-- Source: mini-ielts.com
-- Title: Nature works for Nature Work PLA
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data for slug: mini-ielts-reading-nature-works-for-nature-work-pla
DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'mini-ielts-reading-nature-works-for-nature-work-pla'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'mini-ielts-reading-nature-works-for-nature-work-pla';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'mini-ielts-reading-nature-works-for-nature-work-pla';
DELETE FROM exams
WHERE "Slug" = 'mini-ielts-reading-nature-works-for-nature-work-pla';

DO $$
DECLARE
  exam_id uuid := gen_random_uuid();
  sec1 uuid := gen_random_uuid();
  qid uuid;
BEGIN

  INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","ImageUrl","UpdatedAt")
  VALUES (
    exam_id,
    'mini-ielts-reading-nature-works-for-nature-work-pla',
    'Nature works for Nature Work PLA',
    'IELTS Reading Practice Test from IELTS Mentor',
    'IELTS',
    'B2',
    'PUBLISHED',
    20,
    'http://images.mini-ielts.com/images/2022/13/natureworksrgb_resized.jpg',
    now()
  );

  INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","PassageMd")
  VALUES (
    sec1,
    exam_id,
    1,
    'Reading Passage - Nature works for Nature Work PLA',
    E'## Questions 1-4\n\nWrite the letters A-F in boxes 1-4 on your answer sheet.\n\n**A** make things like clothes\n**B** produce plastic from plant\n**C** selling plastic in market\n**D** fermentation process\n**E** drape fabrics\n**F** wrapping products\n\n**1.** scientists manage to _______\n**2.** Cargill needs to have contacts with _______\n**3.** Nature work is used for _______\n**4.** Ingeo is used to _______\n\n---\n\n## Questions 5-8\n\nComplete the following summary of the paragraphs of Reading Passage.\nUsing **NO MORE THAN TWO WORDS** from the Reading Passage for each answer.\n\n### Process: the production of PLA\n\n![Process Diagram](https://res.cloudinary.com/df41zs8il/image/upload/ielts/1387_diagram.jpg)\n\n**5.** _______ (Raw material)\n**6.** _______ (Process step)\n**7.** _______ (Process step)\n**8.** _______ (Final product)\n\n---\n\n## Questions 9-10\n\nChoose the correct letter, **A, B, C** or **D**.\n\n**9.** Why did choose the PLA as material for food packaging?\n- **A** It smells good\n- **B** It can save food freshness\n- **C** It can be used on other materials\n- **D** Some other things need to be revised about it\n\n**10.** What is PLA packaging is used for?\n- **A** absorbing moisture\n- **B** composting facilities\n- **C** Packaging fresh food\n- **D** manufacturing\n\n---\n\n## Questions 11-12\n\nWhich **TWO** features of PLA are correct?  \nChoose **TWO** letters, A-E.\n\n- **A** It is made of renewable raw materials\n- **B** It involves the removal of carbon dioxide\n- **C** It is no use of fossil fuel product\n- **D** It uses renewable raw resources\n- **E** It is sustenance which can absorb the CO2 in the atmosphere\n\n---\n\n## Questions 13-14\n\nWhich **TWO** features of PLA are correct?\nChoose **TWO** letters, A-E.\n\n- **A** It takes in moisture of skin\n- **B** It is waterproof\n- **C** comfortable sportswear\n- **D** It''s fading under the sun\n- **E** It is only made in deep color\n',
    E'# Nature Works for Nature Work PLA\n\n**Paragraph A.**\nA dozen years ago, scientists at Cargill got the idea of converting lactic acid made from corn into plastic while examining possible new uses for materials produced from corn wet milling processes. In the past, several efforts had been made to develop plastics from lactic acid, but with limited success. Achieving this technological breakthrough didn''t come easily, but in time the efforts did succeed. A fermentation and distillation process using corn was designed to create a polymer suitable for a broad variety of applications.\n\n**Paragraph B.**\nAs an agricultural based firm, Cargill had taken this product as far as it could by 1997. The company needed a partner with access to plastics markets and polymerization capabilities, and began discussions with The Dow Chemical Company. The next step was the formation of the joint venture that created Cargill Dow LLC. Cargill Dow''s product is the world''s first commercially available plastic made from annually renewable resources such as corn: NatureWorks™ PLA is a family of packaging polymers made from non-petroleum based resources. Ingeo is a family of polymers for fibers made in a similar manner.\n\n**Paragraph C.**\nBy applying their unique technology to the processing of natural plant sugars, Cargill Dow has created a more environmentally friendly material that reaches the consumer in clothes, cups, packaging and other products. While Cargill Dow is a stand-alone business, it continues to leverage the agricultural processing, manufacturing and polymer expertise of the two parent companies in order to bring the best possible products to market.\n\n**Paragraph D.**\nThe basic raw materials for PLA are carbon dioxide and water. Growing plants, like corn, take these building blocks from the atmosphere and the soil. They are combined in the plant to make carbohydrates (sucrose and starch) through a process driven by photosynthesis. The process for making Nature Works PLA begins when a renewable resource such as corn is milled, separating starch from the raw material. Unrefined dextrose, in turn, is processed from the starch.\n\n**Paragraph E.**\nCargill Dow turns the unrefined dextrose into lactic acid using a fermentation process similar to that used by beer and wine producers. This is the same lactic acid that is used as a food additive and is found in muscle tissue in the human body. Through a special condensation process, a lactide is formed. This lactide is purified through vacuum distillation and becomes a polymer (the base for NatureWorks PLA) that is ready for use through a solvent-free melt process.\n\n**Paragraph F.**\nNature Works PLA fits all disposal systems and is fully compostable in commercial composting facilities. With the proper infrastructure, products made from this polymer can be recycled back to a monomer and re-used as a polymer. Thus, at the end of its life cycle, a product made from Nature Works PLA can be broken down into its simplest parts so that no sign of it remains.\n\n**Paragraph G.**\nPLA is now actively competing with traditional materials in packaging and fiber applications throughout the world. This new polymer now competes head-on with petroleum-based materials like polyester. A wide range of products that vary in molecular weight and crystallinity can be produced. Fiber and non-woven applications include clothing, fiberfill, blankets and wipes. Packaging applications include packaging films and food and beverage containers.\n\n**Paragraph H.**\nAs Nature Works PLA polymers are more oil- and grease-resistant and provide a better flavor and aroma barrier than existing petroleum-based polymers, grocery retailers are increasingly using this packaging for their fresh foods. PLA possess two properties that are particularly useful for drape fabrics and window furnishings. Their resistance to ultraviolet light reduces the amount of fading in such fabrics, and their refractive index is low, which means fabrics can be made with deep colors without requiring large amounts of dye. Sportswear makers have been drawn to the product as it has an inherent ability to take moisture away from the skin.\n\n**Paragraph I.**\nPLA combines inexpensive large-scale fermentation with chemical processing to produce a value-added polymer product that improves the environment. The source material for PLA is a natural sugar found in plants such as corn. As an alternative to traditional petroleum-based polymers, the production of PLA uses 20%-50% less fossil fuel and releases a lower amount of greenhouse gasses; carbon dioxide in the atmosphere is removed when the feedstock is grown and is returned to the earth when the polymer is degraded. Because the company is using raw materials that can be regenerated year after year, it is both cost-competitive and environmentally responsible.'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    1,
    'MATCHING_FEATURES',
    'READING',
    2,
    'Scientists manage to',
    '',
    '{"feature-q1": ["B", "B"]}'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    2,
    'MATCHING_FEATURES',
    'READING',
    2,
    'Cargill needs to have contacts with',
    '',
    '{"feature-q2": ["C", "C"]}'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    3,
    'MATCHING_FEATURES',
    'READING',
    2,
    'Nature Works is used for',
    '',
    '{"feature-q3": ["F", "F"]}'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    4,
    'MATCHING_FEATURES',
    'READING',
    2,
    'Ingeo is used to',
    '',
    '{"feature-q4": ["A", "A"]}'
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
    'Corn → _______ (separated from raw material)',
    '',
    '{"blank-q5": ["starch"]}'::jsonb
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
    'Dextrose → Lactic acid (through _______ process)',
    '',
    '{"blank-q6": ["fermentation"]}'::jsonb
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
    'Lactide formed (through _______ process)',
    '',
    '{"blank-q7": ["condensation"]}'::jsonb
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
    'Lactide → _______ (ready for use)',
    '',
    '{"blank-q8": ["polymer"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    9,
    'MULTIPLE_CHOICE_SINGLE',
    'READING',
    2,
    'Why did choose the PLA as material for food packaging?',
    '',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. It smells good', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. It can save food freshness', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. It can be used on other materials', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D. Some other things need to be revised about it', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    10,
    'MULTIPLE_CHOICE_SINGLE',
    'READING',
    2,
    'What is PLA packaging used for?',
    '',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. absorbing moisture', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. composting facilities', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. Packaging fresh food', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D. manufacturing', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    11,
    'MULTIPLE_CHOICE_SINGLE',
    'READING',
    2,
    'Which feature of PLA is correct? (First choice from Q11-12)',
    '',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. It is made of renewable raw materials', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. It involves the removal of carbon dioxide', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. It is no use of fossil fuel product', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D. It uses renewable raw resources', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, 'E. It is sustenance which can absorb the CO2 in the atmosphere', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    12,
    'MULTIPLE_CHOICE_SINGLE',
    'READING',
    2,
    'Which feature of PLA is correct? (Second choice from Q11-12)',
    '',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. It is made of renewable raw materials', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. It involves the removal of carbon dioxide', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. It is no use of fossil fuel product', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D. It uses renewable raw resources', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, 'E. It is sustenance which can absorb the CO2 in the atmosphere', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    13,
    'MULTIPLE_CHOICE_SINGLE',
    'READING',
    2,
    'Which feature of PLA fabric is correct? (First choice from Q13-14)',
    '',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. It takes in moisture of skin', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. It is waterproof', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. comfortable sportswear', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D. It''s fading under the sun', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, 'E. It is only made in deep color', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    14,
    'MULTIPLE_CHOICE_SINGLE',
    'READING',
    2,
    'Which feature of PLA fabric is correct? (Second choice from Q13-14)',
    '',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. It takes in moisture of skin', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. It is waterproof', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. comfortable sportswear', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D. It''s fading under the sun', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, 'E. It is only made in deep color', false);


END$$;


COMMIT;