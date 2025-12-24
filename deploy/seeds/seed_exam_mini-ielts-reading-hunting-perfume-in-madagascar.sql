-- ============================================
-- IELTS Exam Data Import SQL
-- Generated: 2025-12-24T13:02:16.645800
-- Source: mini-ielts.com
-- Title: Hunting Perfume in Madagascar
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data for slug: mini-ielts-reading-hunting-perfume-in-madagascar
DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'mini-ielts-reading-hunting-perfume-in-madagascar'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'mini-ielts-reading-hunting-perfume-in-madagascar';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'mini-ielts-reading-hunting-perfume-in-madagascar';
DELETE FROM exams
WHERE "Slug" = 'mini-ielts-reading-hunting-perfume-in-madagascar';

DO $$
DECLARE
  exam_id uuid := gen_random_uuid();
  sec1 uuid := gen_random_uuid();
  qid uuid;
BEGIN

  INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","ImageUrl","UpdatedAt")
  VALUES (
    exam_id,
    'mini-ielts-reading-hunting-perfume-in-madagascar',
    'Hunting Perfume in Madagascar',
    'IELTS Reading Practice Test from IELTS Mentor',
    'IELTS',
    'B2',
    'PUBLISHED',
    20,
    'https://res.cloudinary.com/df41zs8il/image/upload/v1766554045/ielts/hunting-perfume-in-madagascar-_1d2e9b408fe1.jpg',
    now()
  );

  INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","PassageMd")
  VALUES (
    sec1,
    exam_id,
    1,
    'Reading Passage - Hunting Perfume in Madagascar',
    E'**Questions 1-5:**\nWhich section contains the following information?\n\nWrite the correct letter, **A-L**.\n\n---\n\n**Questions 6-10:**\nDo the following statements agree with the information given in the text?\n\nWrite\n- **TRUE** if the statement agrees with the information\n- **FALSE** if the statement contradicts the information\n- **NOT GIVEN** if there is no information on this\n\n---\n\n**Questions 11-13:**\nComplete the sentences below.\n\nWrite **NO MORE THAN TWO WORDS AND/OR A NUMBER** for each answer.',
    E'**Paragraph A.**\\nA . Ever since the unguentari plied their trade in ancient Rome, perfumers have to keep abreast of changing fashions. These days they have several thousand ingredients to choose from when creating new scents, but there is always demand for new combinations. The bigger the “palette7 of smells, the better the perfumer’s chance of creating something fresh and appealing. Even with everyday products such as shampoo and soap, kitchen cleaners and washing powders, consumers are becoming increasingly fussy. And many of today’s fragrances have to survive tougher treatment than ever before, resisting the destructive power of bleach or a high temperature wash cycle. Chemists can create new smells from synthetic molecules, and a growing number of the odours on the perfumer’s palette are artificial. But nature has been in the business far longer.\\n\\n**Paragraph B.**\\nB . The island of Madagascar is an evolutionary hot spot; 85% of its plants are unique, making it an ideal source for novel fragrances. Last October, Quest International, a company that develops fragrances for everything from the most delicate perfumes to cleaning products, sent an expedition to Madagascar in pursuit of some of nature’s most novel fragrances. With some simple technology, borrowed from the pollution monitoring industry, and a fair amount of ingenuity, the perfume hunters bagged 20 promising new aromas in the Madagascan rainforest. Each day the team set out from their “hotel”—a wooden hut lit by kerosene lamps, and trailed up and down paths and animal tracks, exploring the thick vegetation up to 10 meters on either side of the trail. Some smells came from obvious places, often big showy flowers within easy reach- Others were harder to pin down. “Often it was the very small flowers that were much more interesting, says Clery. After the luxuriance of the rainforest, the little-known island of Nosy Hara was a stark, dry place geologically and biologically very different from the mainland, “Apart from two beaches, the rest of the Island Is impenetrable, except by hacking through the bush, says Clery. One of the biggest prizes here was a sweet- smelling sap weeping from the gnarled branches of some ancient shrubby trees in the parched Interior. So far no one has been able to identify the plant.\\n\\n**Paragraph C.**\\nC . With most flowers or fruits, the hunters used a technique originally designed to trap and identify air pollutants. The technique itself is relatively simple. A glass bell jar or flask Ỉ S fitted over the flower. The fragrance molecules are trapped in this “headspace” and can be extracted by pumping the air out over a series of filters which absorb different types of volatile molecules. Back home in the laboratory, the molecules are flushed out of the filters and injected into a gas chromatograph for analysis. If it Is Impossible to attach the headspace gear, hunters fix an absorbent probe close to the source of the smell. The probe looks something like a hypodermic syringe, except that the ‘needle’ is made of silicone rubber which soaks up molecules from the air. After a few hours, the hunters retract the rubber needle and seal the tube, keeping the odour molecules inside until they can.be injected into the gas chromatograph in the laboratory.\\n\\n**Paragraph D.**\\nD . Some of the most promising fragrances were those given, off by resins that oozed from the bark of trees. Resins are the source of many traditional perfumes, including frankincense and myrrh. The most exciting resin came from a Calophyllum tree, which produces a strongly scented medicinal oil. The sap of this Calophyllum smelt rich and aromatic, a little like church incense. But It also smelt of something the fragrance industry has learnt to live without castoreum a substance extracted from the musk glands of beavers and once a key ingredient in many perfumes. The company does not use animal products any longer, but Ã was wonderful to find a tree with an animal smell.\\n\\n**Paragraph E.**\\nE . The group also set out from the island to capture the smell of coral reefs. Odors that conjure up sun kissed seas are highly sought after by the perfume industry. “From the ocean, the only thing we have is seaweed, and that has a dark and heavy aroma. We hope to find something unique among the corals,” says Dir. The challenge for the hunters was to extract a smell from water rather than air. This was an opportunity to try Clery’s new “aquaspace” apparatus a set of filters that work underwater. On Nosy Hara, jars were fixed over knobs of coral about 2 meters down and water pumped out over the absorbent filters. So what does coral smell like? “It’s a bit like lobster and crab,” says Clery. The team’s task now is to recreate the best of then captured smells. First they must identify the molecules that make up each fragrance. Some ingredients may be quite common chemicals. But some may be completely novel, or they may be too complex or expensive to make in the lab. The challenge then is to conjure up the fragrances with more readily available materials. “We can avoid the need to import plants from the rainforest by creating the smell with a different set of chemicals from those in the original material,” says Clery. “If we get it right, you can sniff the sample and it will transport you straight back to the moment you smelt it in the rainforest.”\\n\\n\n---\n\n## Images for Questions 11-13\n\n\n![Question 11-13 Option A](https://res.cloudinary.com/df41zs8il/image/upload/v1766554048/ielts/hunting-perfume-in-madagascar-_972e216f8f6e.jpg)\n'
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
    'One currently preferred spot to pick up plants for novel finding',
    '',
    '{"info-q1": ["B", "b"]}'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    2,
    'MATCHING_INFORMATION',
    'READING',
    2,
    'new task seems to be promising yet producing limited finding in fragrance source',
    '',
    '{"info-q2": ["E", "e"]}'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    3,
    'MATCHING_INFORMATION',
    'READING',
    2,
    'The demanding conditions for fragrance to endure',
    '',
    '{"info-q3": ["A", "a"]}'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    4,
    'MATCHING_INFORMATION',
    'READING',
    2,
    'substitute for substance no longer available to the perfume manufacture',
    '',
    '{"info-q4": ["D", "d"]}'
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
    'escription of an outdoor expedition on land chasing new fragrances',
    '',
    '{"info-q5": ["B", "b"]}'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    6,
    'TRUE_FALSE_NOT_GIVEN',
    'READING',
    2,
    'Manufacturers can choose to use synthetic odors for the perfume nowadays',
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
    7,
    'TRUE_FALSE_NOT_GIVEN',
    'READING',
    2,
    'Madagascar is chosen to be a place for hunting plants which are rare in other parts of the world',
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
    8,
    'TRUE_FALSE_NOT_GIVEN',
    'READING',
    2,
    'Capturing the smell is one of the most important things for creating new aromas',
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
    9,
    'TRUE_FALSE_NOT_GIVEN',
    'READING',
    2,
    'The technique the hunters used to trap fragrance molecules is totally out of their ; ingenuity',
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
    10,
    'TRUE_FALSE_NOT_GIVEN',
    'READING',
    2,
    'Most customers prefer the perfume made of substance extracted from the musk I glands of animals',
    '',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'TRUE', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'FALSE', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'NOT GIVEN', true);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    11,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    'Perfumers use the _______ technique to capture smells from plants.',
    '',
    '{"blank-q11": ["headspace"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    12,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    'Absorbent _______ are used to collect fragrance molecules.',
    '',
    '{"blank-q12": ["filters"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    13,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    'A _______ is used to inject samples into the spectrometer.',
    '',
    '{"blank-q13": ["needle"]}'::jsonb
  );


END$$;


COMMIT;