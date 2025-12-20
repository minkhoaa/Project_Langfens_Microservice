-- ============================================
-- IELTS Exam Data Import SQL
-- Generated: 2025-12-20T17:47:27.149547
-- Source: ielts-mentor.com
-- Title: GT Reading 12 Section 3 - The coal industry
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data for slug: ielts-mentor-gt-reading-12-section-3-the-coal-industry
DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-mentor-gt-reading-12-section-3-the-coal-industry'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-mentor-gt-reading-12-section-3-the-coal-industry';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-mentor-gt-reading-12-section-3-the-coal-industry';
DELETE FROM exams
WHERE "Slug" = 'ielts-mentor-gt-reading-12-section-3-the-coal-industry';

DO $$
DECLARE
  exam_id uuid := gen_random_uuid();
  sec1 uuid := gen_random_uuid();
  qid uuid;
BEGIN

  INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","UpdatedAt")
  VALUES (
    exam_id,
    'ielts-mentor-gt-reading-12-section-3-the-coal-industry',
    'GT Reading 12 Section 3 - The coal industry',
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
    'Reading Passage - GT Reading 12 Section 3 - The coal industry',
    E'# Passage\n\nA Pollution control in coal mining B The greenhouse effect C The coal industry and the environment D Sustainable population growth\n\ni Global warming ii The dangers of the coal industry iii Superclean coal iv Environment protection measures v Coal as an energy source vi Coal and the enhanced greenhouse effect vii Research and development viii Mining site drainage\n\nA Coal is expected to continue to account for almost 27 per cent of the world’s energy needs. However, with growing international awareness of pressures on the environment and the need to achieve sustainable development of energy resources, the way in which the resource is extracted, transported and used is critical. A wide range of pollution control devices and practices is in place at most modern mines and significant resources are spent on rehabilitating mined land. In addition, major research and development programmes are being devoted to lifting efficiencies and reducing emissions of greenhouse gases during coal consumption. Such measures are helping coal to maintain its status as a major supplier of the world’s energy needs. B The coal industry has been targeted by its critics as a significant contributor to the greenhouse effect. However, the greenhouse effect is a natural phenomenon involving the increase in global surface temperature due to the presence of greenhouse gases - water vapour, carbon dioxide, tropospheric ozone, methane and nitrous oxide - in the atmosphere. Without the greenhouse effect, the earth’s average surface temperature would be 33-35 degrees C lower, or -15 degrees C. Life on earth, as we know it today, would not be possible. There is concern that this natural phenomenon is being altered by a greater build-up of gases from human activity, perhaps giving rise to additional warming and changes in the earth’s climate. This additional build-up and its forecast outcome has been called the enhanced greenhouse effect. Considerable uncertainty exists, however, about the enhanced greenhouse effect, particularly in relation to the extent and timing of any future increases in global temperature. Greenhouse gases arise from a wide range of sources and their increasing concentration is largely related to the compound effects of increased population, improved living standards and changes in lifestyle. From a current base of 5 billion, the United Nations predicts that the global population may stabilise in the twenty-first century between 8 and 14 billion, with more than 90 per cent of the projected increase taking place in the world’s developing nations. The associated activities to support that growth, particularly to produce the required energy and food, will cause further increases in greenhouse gas emissions. The challenge, therefore, is to attain a sustainable balance between population, economic growth and the environment. The major greenhouse gas emissions from human activities are carbon dioxide (CO2), methane and nitrous oxide. Chlorofluorocarbons (CFCs) are the only major contributor to the greenhouse effect that does not occur naturally, coming from such sources as refrigeration, plastics and manufacture. Coal’s total contribution to greenhouse gas emissions is thought to be about 18 per cent, with about half of this coming from electricity generation. C The world-wide coal industry allocates extensive resources to researching and developing new technologies and ways of capturing greenhouse gases. Efficiencies are likely to be improved dramatically, and hence CO2 emissions reduced, through combustion and gasification techniques which are now at pilot and demonstration stages. Clean coal is another avenue for improving fuel conversion efficiency. Investigations are under way into super clean coal (3-5 per cent ash) and ultraclean coal (less than 1 per cent ash). Superclean coal has the potential to enhance the combustion efficiency of conventional pulverised fuel power plants. Ultraclean coal will enable coal to be used in advanced power systems such as coal-fired gas turbines which, when operated in combined cycle, have the potential to achieve much greater efficiencies. D Defendants of mining point out that, environmentally, coal mining has two important factors in its favour. It makes only temporary use of the land and produces no toxic chemical wastes. By carefully pre-planning projects, implementing pollution control measures, monitoring the effects of mining and rehabilitating mined areas, the coal industry minimises the impact on the neighbouring community, the immediate environment and long-term land capability. Dust levels are controlled by spraying roads and stockpiles, and water pollution is controlled by carefully separating clean water runoff from runoff which contains sediments or salt from mine workings. The latter is treated and re-used for dust suppression. Noise is controlled by modifying equipment and by using insulation and sound enclosures around machinery. Since mining activities represent only a temporary use of the land, extensive rehabilitation measures are adopted to ensure that land capability after mining meets agreed and appropriate standards which, in some cases, are superior to the land’s pre-mining condition. Where the mining is underground, the surface area can be simultaneously used for forests, cattle grazing and crop raising, or even reservoirs and urban development, with little or no disruption to the existing land use. In all cases, mining is subject to stringent controls and approvals processes. In open-cut operations, however, the land is used exclusively for mining but land rehabilitation measures generally progress with the mine’s development. As core samples are extracted to assess the quality and quantity of coal at a site, they are also analysed to assess the ability of the soil or subsoil material to support vegetation. Topsoils are stripped and stockpiled prior to mining for subsequent dispersal over rehabilitated areas. As mining ceases in one section of the open-cut, the disturbed area is reshaped. Drainage within and off the site is carefully designed to make the new land surface as stable as the local environment allows: often dams are built to protect the area from soil erosion and to serve as permanent sources of water. Based on the soil requirements, the land is suitably fertilised and revegetated.'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    27,
    'MATCHING_INFORMATION',
    'READING',
    2,
    'on your answer sheet.',
    'Choose the correct answer.',
    '{"info-q27": ["C", "c"]}'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, 'E', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 6, 'F', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    28,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    '28. Section A _______.',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q28": ["V", "v"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    29,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    '29. Section B _______.',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q29": ["VI"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    30,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    '30. Section C _______.',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q30": ["VII"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    31,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    '31. Section D _______.',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q31": ["IV"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    32,
    'MULTIPLE_CHOICE_SINGLE',
    'READING',
    2,
    '32. The global increase in greenhouse gases has been attributed to A. industrial pollution in developing countries. B. coal mining and electricity generation. C. reduced rainfall in many parts of the world. D. trends in population and lifestyle.',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. industrial pollution in developing countries.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. coal mining and electricity generation.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. reduced rainfall in many parts of the world.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D. trends in population and lifestyle.', true);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    33,
    'MULTIPLE_CHOICE_SINGLE',
    'READING',
    2,
    '33. The proportion of all greenhouse gases created by coal is approximately A. 14 per cent. B. 18 per cent. C. 27 per cent. D. 90 per cent.',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. 14 per cent.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. 18 per cent.', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. 27 per cent.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D. 90 per cent.', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    34,
    'MULTIPLE_CHOICE_SINGLE',
    'READING',
    2,
    '34. Current research aims to increase the energy-producing efficiency of coal by A. burning it at a lower temperature. B. developing new gasification techniques. C. extracting CO2 from it. D. recycling greenhouse gases.',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. burning it at a lower temperature.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. developing new gasification techniques.', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. extracting CO2 from it.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D. recycling greenhouse gases.', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    35,
    'MULTIPLE_CHOICE_SINGLE',
    'READING',
    2,
    '35. Compared with ordinary coal, new, ‘clean’ coals may generate power A. more cleanly and more efficiently. B. more cleanly but less efficiently. C. more cleanly but at higher cost. D. more cleanly but much more slowly.',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. more cleanly and more efficiently.', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. more cleanly but less efficiently.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. more cleanly but at higher cost.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D. more cleanly but much more slowly.', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    36,
    'MULTIPLE_CHOICE_SINGLE',
    'READING',
    2,
    '36. To control dust at mine sites, mining companies often use A. chemicals which may be toxic. B. topsoil taken from the site before mining. C. fresh water from nearby dams. D. runoff water containing sediments.',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. chemicals which may be toxic.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. topsoil taken from the site before mining.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. fresh water from nearby dams.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D. runoff water containing sediments.', true);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    37,
    'YES_NO_NOT_GIVEN',
    'READING',
    2,
    'TRUE if the statement agrees with the information, FALSE if it contradicts, NOT GIVEN if there is no information on this.\n\n37. The coal industry should be abandoned in favour of alternative energy sources because of the environmental damage it causes.',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'YES', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'NO', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'NOT GIVEN', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    38,
    'YES_NO_NOT_GIVEN',
    'READING',
    2,
    'TRUE if the statement agrees with the information, FALSE if it contradicts, NOT GIVEN if there is no information on this.\n\n38. The greatest threats to the environment are the gases produced by industries which support the high standard of living of a growing world population.',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'YES', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'NO', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'NOT GIVEN', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    39,
    'YES_NO_NOT_GIVEN',
    'READING',
    2,
    'TRUE if the statement agrees with the information, FALSE if it contradicts, NOT GIVEN if there is no information on this.\n\n39. World population in the twenty-first century will probably exceed 8 billion.',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'YES', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'NO', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'NOT GIVEN', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    40,
    'TRUE_FALSE_NOT_GIVEN',
    'READING',
    2,
    'TRUE if the statement agrees with the information, FALSE if it contradicts, NOT GIVEN if there is no information on this.\n\n40. CFC emissions have been substantially reduced in recent years.',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'TRUE', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'FALSE', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'NOT GIVEN', true);


END$$;


COMMIT;