BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-mock-sustainable-futures'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-mock-sustainable-futures';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-mock-sustainable-futures';
DELETE FROM exams
WHERE "Slug" = 'ielts-reading-mock-sustainable-futures';

DO $$
DECLARE
  exam_id uuid := gen_random_uuid();
  sec1 uuid := gen_random_uuid();
  sec2 uuid := gen_random_uuid();
  sec3 uuid := gen_random_uuid();
  qid uuid;
BEGIN
  INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","UpdatedAt")
  VALUES (
    exam_id,
    'ielts-reading-mock-sustainable-futures',
    'IELTS Reading Mock Test - Sustainable Futures',
    'Three authentic-style IELTS Reading passages on vertical farming, circular cities, and ocean thermal energy. Includes every question type supported by the platform.',
    'IELTS',
    'C1',
    'PUBLISHED',
    60,
    now()
  );

  INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","PassageMd")
  VALUES (
    sec1,
    exam_id,
    1,
    'Reading Passage 1 - Vertical Farming Revolution',
    E'',
    E'# Passage\n\n**Paragraph A**  \nThe city of Norchester converted a derelict textile warehouse near the freight canal into twelve stacked growing floors. Each tower now produces the same yield as forty hectares of conventional farmland while occupying the footprint of a supermarket car park.\n\n**Paragraph B**  \nInside, trays glide under custom LED ribbons that provide the full light spectrum, allowing plants to grow independent of daylight. A nutrient-film irrigation loop recirculates 95 percent of its water; most moisture is captured from indoor condensation rather than rainfall. Sensors report humidity, carbon dioxide, and nutrient flow to a central dashboard that agronomists tweak from a mobile app.\n\n**Paragraph C**  \nElectricity comes from rooftop solar canopies and a coffee-waste biogas plant, while a neighboring data center pipes surplus heat through the risers to stabilize the climate.\n\n**Paragraph D**  \nThe municipality funds paid apprenticeships for residents who calibrate the farm and earn food-handling certificates. Weekly harvests leave the elevator-sized modules every 18 days, supplying clinics with subscription produce boxes and cutting truck emissions on the delivery route by 42 percent.'
  );

  INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","PassageMd")
  VALUES (
    sec2,
    exam_id,
    2,
    'Reading Passage 2 - Circular Cities Playbook',
    E'# Passage\n\n**Paragraph A**  \nNorchester''s Circular Cities Playbook opens with a zero-packaging charter. Market stalls dispense soap, rice, and tea into containers that residents bring from home, and scanners log each refill to a shared ledger so inspectors can see how much waste is prevented in real time.\n\n**Paragraph B**  \nThe "Repair Commons" turns tram depots into public workbenches. Retired electricians and teenagers swap techniques as they strip appliances, 3D-print missing cogs, and return patched speakers to neighbors while buskers narrate every fix to passers-by.\n\n**Paragraph C**  \nAcross the river, a sunken plaza stores stormwater. Figure 2 in the playbook shows the "Infiltration Spine": porous pavers resting on a perforated geotextile cradle, rain gardens, and reed beds that slow runoff before the cleaned water feeds cooling loops for the library.\n\n**Paragraph D**  \nEvery beam, pane, and cable pulled from demolition sites receives a materials passport. QR tags record the alloy, stress tests, and the dates when a component can be reused again, prioritizing laminated timber and reversible fasteners so buildings can be unbolted rather than crushed. Developers unlock a reuse credit once they document that 60 percent of a new shell comes from catalogued salvage.\n\n**Paragraph E**  \nA civic data trust publishes the resource ledger each Friday and lets citizens vote on who can see it. Metro tunnels now host algae-fed bioreactors that scrub air blowing toward Harbor Loop. Three districts test circular features: Harbor Loop runs a tidal micro-grid, Midtown Weave hangs thermal battery balconies to store heat overnight, and Plateau Step stitches algae terraces onto concrete walls. Citizen measurement circles log temperature and air-quality data, and once a crew submits 30 hours each member receives a stipend. A mobile pyrolysis kiln turns food scraps into biochar for the hillside tree nursery.'
  );

  INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","PassageMd")
  VALUES (
    sec3,
    exam_id,
    3,
    'Reading Passage 3 - Ocean Thermal Energy Conversion',
    E'# Passage\n\n**Paragraph A**  \nSeaShift, a floating thermal plant moored in Monsoon Bay, draws warm surface water at 26  degreesC and cold water from 900 meters below to power an Ocean Thermal Energy Conversion (OTEC) cycle. The design replaced an early tidal concept once engineers realized the bay''s swell was inconsistent.\n\n**Paragraph B**  \nA 1.2 meter-wide fiberglass pipe is tensioned to the seabed and rated for 25 years before major servicing. Sensors line the pipe, feeding tilt, vibration, and temperature data to Penbrooke University, which validated the corrosion model. Flash evaporators turn seawater into freshwater for the science barges, while condensers send chilled brine to the city archive. Mineral filters drop out calcite pellets that brickmakers fire into calcium-rich feedstock.\n\n**Paragraph C**  \nExcess electricity-about 18 percent of output-flows via a subsea cable to the mainland grid after the platform''s lab loads are satisfied. Engineers also braid kelp around the anchors to create shade for juvenile fish and to capture dissolved carbon. Teachers ferry students to the floating Sea Studio classroom twice a week.\n\n**Paragraph D**  \nA dive team certified by the Blue Spine Institute trains residents to inspect the structure. Their storm log recently noted biofouling sleeves forming along the southern anchor chain before a tropical storm, prompting an early flush of the working fluid loop.\n\n**Paragraph E**  \nThe public boardwalk tracing the perimeter doubles as a map of the thermal loop: warm intake pumps feed the evaporator dome, vapor spins the turbine hall, condensers liquefy the working fluid, and pumps drive it back offshore.'
  );

  -- Section 1 questions
  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
  VALUES (
    qid, sec1, 1,
    'TRUE_FALSE_NOT_GIVEN','READING',1,
    '1. The Norchester farm stacks crops so the footprint is smaller than that of a comparable flat farm.',
    'Paragraph A states that forty hectares of yield sit on a supermarket-sized base.'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES
    (gen_random_uuid(), qid, 1, 'True', true),
    (gen_random_uuid(), qid, 2, 'False', false),
    (gen_random_uuid(), qid, 3, 'Not Given', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
  VALUES (
    qid, sec1, 2,
    'TRUE_FALSE_NOT_GIVEN','READING',1,
    '2. The project sources all of its electricity from coal-fired plants.',
    'Paragraph C explains the mix of solar canopies, biogas, and waste heat-no coal is mentioned.'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES
    (gen_random_uuid(), qid, 1, 'True', false),
    (gen_random_uuid(), qid, 2, 'False', true),
    (gen_random_uuid(), qid, 3, 'Not Given', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
  VALUES (
    qid, sec1, 3,
    'TRUE_FALSE_NOT_GIVEN','READING',1,
    '3. Researchers have already copied the Norchester climate-control system for use in Antarctica.',
    'No other sites are described, so the answer is Not Given.'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES
    (gen_random_uuid(), qid, 1, 'True', false),
    (gen_random_uuid(), qid, 2, 'False', false),
    (gen_random_uuid(), qid, 3, 'Not Given', true);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
  VALUES (
    qid, sec1, 4,
    'TRUE_FALSE_NOT_GIVEN','READING',1,
    '4. Rainwater collected on the roof is the principal irrigation source for the towers.',
    'Paragraph B states that most moisture is captured from indoor condensation.'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES
    (gen_random_uuid(), qid, 1, 'True', false),
    (gen_random_uuid(), qid, 2, 'False', true),
    (gen_random_uuid(), qid, 3, 'Not Given', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
  VALUES (
    qid, sec1, 5,
    'TRUE_FALSE_NOT_GIVEN','READING',1,
    '5. Custom LED ribbons let the crops grow without relying on natural daylight.',
    'Paragraph B explicitly says the lighting provides the full spectrum indoors.'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES
    (gen_random_uuid(), qid, 1, 'True', true),
    (gen_random_uuid(), qid, 2, 'False', false),
    (gen_random_uuid(), qid, 3, 'Not Given', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
  VALUES (
    qid, sec1, 6,
    'TRUE_FALSE_NOT_GIVEN','READING',1,
    '6. Farm technicians adjust nutrient recipes through a mobile dashboard.',
    'Paragraph B says agronomists tweak the dashboard from a mobile app.'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES
    (gen_random_uuid(), qid, 1, 'True', true),
    (gen_random_uuid(), qid, 2, 'False', false),
    (gen_random_uuid(), qid, 3, 'Not Given', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid, sec1, 7,
    'FORM_COMPLETION','READING',2,
    'Complete the intake form. Write ONE WORD ONLY.\n\nOriginal building type: [blank-q7]',
    'Paragraph A notes the derelict textile warehouse that became the farm.',
    '{"blank-q7":["textile warehouse","warehouse"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid, sec1, 8,
    'FORM_COMPLETION','READING',2,
    'Complete the intake form. Write ONE WORD ONLY.\n\nPrimary irrigation source: [blank-q8]',
    'Paragraph B explains that water is captured from indoor condensation.',
    '{"blank-q8":["condensation","condensed humidity","condensed water"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid, sec1, 9,
    'FORM_COMPLETION','READING',2,
    'Complete the intake form. Write ONE WORD ONLY.\n\nMonitoring platform referenced: [blank-q9]',
    'Paragraph B names the central dashboard used by agronomists.',
    '{"blank-q9":["dashboard","central dashboard","digital dashboard"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid, sec1, 10,
    'NOTE_COMPLETION','READING',2,
    'Community impact notes - write ONE WORD ONLY.\n\nResident support: paid [blank-q10]',
    'Paragraph D highlights paid apprenticeships for residents.',
    '{"blank-q10":["apprenticeships","apprenticeship"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid, sec1, 11,
    'NOTE_COMPLETION','READING',2,
    'Community impact notes - write ONE WORD ONLY.\n\nMain customers: neighborhood [blank-q11]',
    'Paragraph D says clinics receive the subscription produce boxes.',
    '{"blank-q11":["clinics","community clinics","health clinics"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid, sec1, 12,
    'SENTENCE_COMPLETION','READING',2,
    'Complete the sentence. Write NO MORE THAN TWO WORDS.\n\nEach elevator-sized module produces a harvest every [blank-q12].',
    'Paragraph D states that harvests leave every 18 days.',
    '{"blank-q12":["18 days","eighteen days","18"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid, sec1, 13,
    'SENTENCE_COMPLETION','READING',2,
    'Complete the sentence. Write ONE NUMBER OR TWO WORDS.\n\nDelivery truck emissions have fallen by [blank-q13] percent.',
    'Paragraph D quantifies a 42 percent reduction.',
    '{"blank-q13":["42","42 percent","forty-two percent","42%"]}'::jsonb
  );

  -- Section 2 questions
  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid, sec2, 14,
    'MATCHING_HEADING','READING',2,
    'Choose the correct heading (A-F) for Paragraph B.\nA. Citizens repair appliances in public workshops\nB. Stormwater plazas imitate wetlands\nC. Passports for every building material\nD. Citizen stipends for experiments\nE. Quiet overnight logistics\nF. Guaranteeing data transparency',
    'Paragraph B focuses on the Repair Commons workshops.',
    '{"paragraph-b":["A"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid, sec2, 15,
    'MATCHING_HEADING','READING',2,
    'Choose the correct heading (A-F) for Paragraph C.\nA. Citizens repair appliances in public workshops\nB. Stormwater plazas imitate wetlands\nC. Passports for every building material\nD. Citizen stipends for experiments\nE. Quiet overnight logistics\nF. Guaranteeing data transparency',
    'Paragraph C details the Infiltration Spine that slows stormwater.',
    '{"paragraph-c":["B"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid, sec2, 16,
    'MATCHING_HEADING','READING',2,
    'Choose the correct heading (A-F) for Paragraph D.\nA. Citizens repair appliances in public workshops\nB. Stormwater plazas imitate wetlands\nC. Passports for every building material\nD. Citizen stipends for experiments\nE. Quiet overnight logistics\nF. Guaranteeing data transparency',
    'Paragraph D explains how materials passports work.',
    '{"paragraph-d":["C"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid, sec2, 17,
    'MATCHING_INFORMATION','READING',2,
    'Which paragraph mentions algae-fed bioreactors operating inside metro tunnels? Answer with A, B, C, D, or E.',
    'Paragraph E describes the metro tunnel bioreactors.',
    '{"info-q17":["E"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid, sec2, 18,
    'MATCHING_FEATURES','READING',2,
    'Which district pilots thermal battery balconies?\nA. Harbor Loop\nB. Midtown Weave\nC. Plateau Step',
    'Paragraph E links thermal battery balconies to Midtown Weave.',
    '{"feature-q18":["Midtown Weave","B"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid, sec2, 19,
    'MATCHING_ENDINGS','READING',2,
    'Match the stem with the correct ending.\nStem: "The reuse credit"...\nEndings: A. makes suppliers share live energy data. B. lets tenants swap compost for transit credit. C. rewards developers who catalog salvaged beams.',
    'Paragraph D says developers unlock the credit once salvage is documented.',
    '{"ending-q19":["C"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid, sec2, 20,
    'CLASSIFICATION','READING',2,
    'To which category does the zero-packaging charter belong?\nA. Preventing waste from entering landfill\nB. Rewarding citizen monitors\nC. Protecting data access',
    'Paragraph A describes a charter that reduces packaging waste.',
    '{"class-q20":["A"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
  VALUES (
    qid, sec2, 21,
    'MULTIPLE_CHOICE_SINGLE_IMAGE','READING',2,
    'Refer to Figure 2 (Infiltration Spine). What sits directly beneath the porous pavers to spread runoff evenly?',
    'Paragraph C mentions the perforated geotextile cradle under the pavers.'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES
    (gen_random_uuid(), qid, 1, 'A. Gravel swale', false),
    (gen_random_uuid(), qid, 2, 'B. Perforated geotextile cradle', true),
    (gen_random_uuid(), qid, 3, 'C. Clay liner', false),
    (gen_random_uuid(), qid, 4, 'D. Concrete slab', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
  VALUES (
    qid, sec2, 22,
    'MULTIPLE_CHOICE_SINGLE','READING',2,
    'Which material receives the highest reuse priority in the materials passport database?',
    'Paragraph D emphasizes laminated timber with reversible fasteners.'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES
    (gen_random_uuid(), qid, 1, 'A. Recycled glass panes', false),
    (gen_random_uuid(), qid, 2, 'B. Laminated timber frames', true),
    (gen_random_uuid(), qid, 3, 'C. Raw aluminum sheets', false),
    (gen_random_uuid(), qid, 4, 'D. Fired brick rubble', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
  VALUES (
    qid, sec2, 23,
    'MULTIPLE_CHOICE_SINGLE','READING',2,
    'When do citizen measurement circles receive their stipends?',
    'Paragraph E notes that stipends are paid after 30 logged hours.'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES
    (gen_random_uuid(), qid, 1, 'A. After logging ten hours', false),
    (gen_random_uuid(), qid, 2, 'B. After logging thirty hours', true),
    (gen_random_uuid(), qid, 3, 'C. Once a private sponsor approves the data', false),
    (gen_random_uuid(), qid, 4, 'D. Only during city festivals', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
  VALUES (
    qid, sec2, 24,
    'MULTIPLE_CHOICE_SINGLE','READING',2,
    'How often does the civic data trust publish the resource ledger?',
    'Paragraph E says the ledger is published every Friday.'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES
    (gen_random_uuid(), qid, 1, 'A. Every morning at sunrise', false),
    (gen_random_uuid(), qid, 2, 'B. Each Friday', true),
    (gen_random_uuid(), qid, 3, 'C. Once per quarter', false),
    (gen_random_uuid(), qid, 4, 'D. Only during emergencies', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid, sec2, 25,
    'SUMMARY_COMPLETION','READING',2,
    'Complete the summary. Write ONE OR TWO WORDS.\n\nWater travels through porous paving into [blank-q25] before feeding the library cooling loop.',
    'Paragraph C highlights rain gardens that slow the runoff.',
    '{"blank-q25":["rain gardens","rain-garden beds","rain garden"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid, sec2, 26,
    'SUMMARY_COMPLETION','READING',2,
    'Complete the summary. Write ONE WORD ONLY.\n\nFood scraps from the districts are turned into [blank-q26] for the hillside tree nursery.',
    'Paragraph E describes the pyrolysis kiln that produces biochar.',
    '{"blank-q26":["biochar"]}'::jsonb
  );

  -- Section 3 questions
  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
  VALUES (
    qid, sec3, 27,
    'YES_NO_NOT_GIVEN','READING',2,
    '27. SeaShift was initially designed to harvest tidal power.',
    'Paragraph A explains that the current design replaced an earlier tidal concept, so the statement is false.'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES
    (gen_random_uuid(), qid, 1, 'Yes', false),
    (gen_random_uuid(), qid, 2, 'No', true),
    (gen_random_uuid(), qid, 3, 'Not Given', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
  VALUES (
    qid, sec3, 28,
    'YES_NO_NOT_GIVEN','READING',2,
    '28. Engineers expect the cold-water intake pipe to run for at least twenty years before major servicing.',
    'Paragraph B states it is rated for 25 years.'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES
    (gen_random_uuid(), qid, 1, 'Yes', true),
    (gen_random_uuid(), qid, 2, 'No', false),
    (gen_random_uuid(), qid, 3, 'Not Given', false);
  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
  VALUES (
    qid, sec3, 29,
    'YES_NO_NOT_GIVEN','READING',2,
    '29. Local fishers demanded exclusive docking rights around the platform.',
    'Fishers are not mentioned, so the answer is Not Given.'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES
    (gen_random_uuid(), qid, 1, 'Yes', false),
    (gen_random_uuid(), qid, 2, 'No', false),
    (gen_random_uuid(), qid, 3, 'Not Given', true);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
  VALUES (
    qid, sec3, 30,
    'YES_NO_NOT_GIVEN','READING',2,
    '30. SeaShift exports part of its electricity to the mainland grid.',
    'Paragraph C says 18 percent of the output flows through the subsea cable.'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES
    (gen_random_uuid(), qid, 1, 'Yes', true),
    (gen_random_uuid(), qid, 2, 'No', false),
    (gen_random_uuid(), qid, 3, 'Not Given', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid, sec3, 31,
    'TABLE_COMPLETION','READING',2,
    'Subsystem log - write ONE OR TWO WORDS.\nFlash evaporator output: [blank-q31]',
    'Paragraph B says the flash evaporators produce freshwater for the barges.',
    '{"blank-q31":["freshwater","fresh water","drinking water","potable water","desalinated water"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid, sec3, 32,
    'TABLE_COMPLETION','READING',2,
    'Subsystem log - write ONE OR TWO WORDS.\nChilled brine destination: [blank-q32]',
    'Paragraph B directs the brine to the city archive.',
    '{"blank-q32":["city archive","the city archive","archive","archive vaults"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid, sec3, 33,
    'TABLE_COMPLETION','READING',2,
    'Subsystem log - write ONE OR TWO WORDS.\nMineral filter product: [blank-q33]',
    'Paragraph B states that mineral filters drop calcite pellets for feedstock.',
    '{"blank-q33":["calcite pellets","calcite feedstock","calcium-rich feedstock","calcite"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptTexts")
  VALUES (
    qid, sec3, 34,
    'SHORT_ANSWER','READING',3,
    'Answer with NO MORE THAN THREE WORDS.\nWhich institute certified the dive team?',
    'Paragraph D credits the Blue Spine Institute.',
    ARRAY['Blue Spine Institute','Blue Spine']
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","ShortAnswerAcceptTexts")
  VALUES (
    qid, sec3, 35,
    'SHORT_ANSWER','READING',3,
    'Answer with NO MORE THAN THREE WORDS.\nWhat is the floating classroom called?',
    'Paragraph C names the Sea Studio classroom.',
    ARRAY['Sea Studio','the Sea Studio']
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid, sec3, 36,
    'DIAGRAM_LABEL','READING',3,
    'Label the thermal loop diagram. Point X marks the chamber where the working fluid vaporizes. Write ONE OR TWO WORDS.',
    'Paragraph E calls this section the evaporator dome.',
    '{"label-q36":["evaporator dome","evaporator","flash evaporator"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid, sec3, 37,
    'MAP_LABEL','READING',3,
    'Label the bay indicated on the site map. Write ONE OR TWO WORDS.',
    'Paragraph A situates SeaShift in Monsoon Bay.',
    '{"label-q37":["Monsoon Bay"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid, sec3, 38,
    'NOTE_COMPLETION','READING',3,
    'Storm log excerpt - write ONE OR TWO WORDS.\nEngineers recorded [blank-q38] forming along the southern anchor chain.',
    'Paragraph D notes biofouling sleeves in the storm log.',
    '{"blank-q38":["biofouling sleeves","biofouling","fouling sleeves"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
  VALUES (
    qid, sec3, 39,
    'MULTIPLE_CHOICE_SINGLE','READING',3,
    'Why do engineers braid kelp around the anchors?',
    'Paragraph C says the kelp shades juvenile fish and captures dissolved carbon.'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES
    (gen_random_uuid(), qid, 1, 'A. To camouflage damaged sensors', false),
    (gen_random_uuid(), qid, 2, 'B. To shade young fish and capture carbon', true),
    (gen_random_uuid(), qid, 3, 'C. To weigh the anchors down', false),
    (gen_random_uuid(), qid, 4, 'D. To feed offshore fish farms', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","OrderCorrects")
  VALUES (
    qid, sec3, 40,
    'FLOW_CHART','READING',3,
    'Arrange the steps of SeaShift''s thermal loop from first to last. Drag the nodes so they read: warm intake pumps -> evaporator dome -> turbine hall -> condenser bay -> offshore return line.',
    'Paragraph E walks through the loop around the boardwalk.',
    ARRAY['warm-intake','evaporator-dome','turbine-hall','condenser-bay','return-line']
  );

END$$;

COMMIT;