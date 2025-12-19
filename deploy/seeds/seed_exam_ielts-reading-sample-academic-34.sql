-- ============================================
-- IELTS Exam Data Import SQL
-- Generated: 2025-12-19T16:56:49.246888
-- Source: ielts-writing.info
-- Title: IELTS Reading Sample (Academic) #34
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data for slug: ielts-reading-ielts-reading-sample-academic-34
DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-ielts-reading-sample-academic-34'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-ielts-reading-sample-academic-34';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-ielts-reading-sample-academic-34';
DELETE FROM exams
WHERE "Slug" = 'ielts-reading-ielts-reading-sample-academic-34';

DO $$
DECLARE
  exam_id uuid := gen_random_uuid();
  sec1 uuid := gen_random_uuid();
  qid uuid;
BEGIN

  INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","UpdatedAt")
  VALUES (
    exam_id,
    'ielts-reading-ielts-reading-sample-academic-34',
    'IELTS Reading Sample (Academic) #34',
    'IELTS Reading Practice Test: IELTS Reading Sample (Academic) #34',
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
    'Reading Passage - IELTS Reading Sample (Academic) #34',
    E'# Passage\n\n×\nIELTS Reading Academic 34\nEngineering a solution to climate change\nA.\nLooking at the rate of climate change and the disastrous effects it is having on the world, scientists are concerned that we are acting too slowly. Many are now looking to geoengineering — large-scale human interventions to change the world''s climate — to counteract global warming. The schemes range from the mundane to science fiction but all come from the same impulse: if we don''t do something now, it may be too late to do anything.\nB.\nClimate change is now so rapid that, in the very near future, the Arctic will be ice-free during winter as less ice forms during winters and more melts in summer. Scientists say that tackling climate change isn''t a problem we need to deal with in 10 or 20 years'' time; we need to look at radical solutions now. A study has shown that the technologies to produce these geoengineering projects already exists and could be in place for around $5 billion a year. This is a bargain when compared with the cost of reducing carbon dioxide emissions, a major greenhouse gas: that figure stands at somewhere between $200 and $2,000 billion.\nC.\nSo what exactly are scientists planning to do to deal with global warming in the short term? Among the main schemes are shielding the earth from the sun''s rays either at ground or atmospheric level, or capturing the carbon produced by industry and sinking it back into the ground or the sea. Shielding the world has produced ideas that range from simple science to science fiction. One suggestion has been to make the roofs of buildings and roads whiter to reflect the sun''s rays back into space. While this has the advantage of simplicity, it simply won''t make much difference, reflecting only 0.15 watts per square metre, averaged across the planet. To put this into perspective, to stop earth warming we need to increase heat loss by about 3.7 watts per square metre averaged over the world. Another idea is to protect the Greenland ice field by covering it in giant sheets of reflective material. If this works, it could help in the Antartic where the giant Filchner-Ronne ice shelf is melting rapidly. If this glacier disappears completely, it would raise sea levels, causing catastrophic flood damage around the planet.\nD.\nIf reflecting heat back from the ground has little effect, there are two alternatives: seeding clouds and replicating volcanic activity. The first idea is to make clouds whiter by increasing the amount of rain in them. Sending salt particles into clouds should ''seed'' the clouds with more raindrops. Clouds carrying more raindrops would be whiter and better reflectors of sunlight. This could be good news for the earth and in addition could be stopped when necessary with the salt completely clear from the skies within ten years. Unfortunately, other research indicates that creating whiter clouds may have unwanted side effects, producing adverse weather conditions in the region and changing ocean currents. A much older idea is to replicate the effect volcanoes have had on the atmosphere. A volcanic eruption sends large amounts of ash and sulphur into the air, which block the sun and create cooler conditions. For example, when Mount Pinatubo erupted in 1991, it produced a sulphur dioxide cloud, which reduced average global temperatures by one degree centigrade. Geoengineers have long put forward the idea of circulating particles of sulphur in the atmosphere to counteract global warming. The particles would be delivered by aircraft or balloons spraying them into the atmosphere. However, this also has unpredictable effects on the amount and pattern of rainfall. Furthermore, this method would delay the recovery of the ozone layer over the Antartic by 30 to 70 years. More ambitious geoengineering projects have included placing billions of reflective balloons between the sun and the earth and putting giant mirrors into orbit. Scientists have criticised these approaches as ''science fiction'' and say they are unlikely to happen due to the huge costs involved.\nE.\nWhatever actions we take to block or reflect the heat from the sun, we will still need to reduce the amount of carbon dioxide in the atmosphere. Various geoengineering projects have been proposed to do this. Carbon capture technologies range from planting trees, which naturally use carbon dioxide as they grow, to pumping carbon back into the earth and trapping it there. This is a good idea but would only account for about 0.5 watts per square metre. Carbon capture technologies are already in use at power stations where the greenhouse gas is taken at point of production and pumped underground into depleted gas and oil reserves. However, the technology to do this is not very efficient. Other ideas for taking carbon out of the atmosphere include seeding the oceans with iron. This would increase the growth of plankton which, like trees, use carbon naturally. Unfortunately, this would only account for 0.2 watts per square metre.\nF.\nProponents of geoengineering have never regarded the earth-changing engineering projects as a complete solution. Nevertheless, the concept as a whole attracts many criticisms. One is that the problem of climate change is of such huge scale and complexity that there will not be one single solution. All proposals so far have advantages and disadvantages. The biggest problem of all is that many of the projects are untested and any of the proposals may have unforeseen consequences. For example, we could not suddenly stop a geoengineering scheme: keeping temperatures artificially low for a period then taking away the cause of this would cause the temperature to rise again rapidly. Furthermore, global engineering solutions to the problem of climate change would need the agreement of all the world''s leaders: having an American solution, a Chinese solution, a Brazilian solution, and so on simply wouldn''t be politically acceptable. But the biggest downfall is that geoengineering projects could reduce the political and popular pressure for reducing carbon emissions, as politicians point to geoengineering for an answer rather than tackling the real cause of climate change: human activity.\nSHARE THIS PAGE\nCONTACT US\nIELTS QUESTIONS\nLIFE IN THE UK TEST\nThe reading, writing and listening practice tests on this website have been designed to resemble the format of the IELTS test as closely as possible. They are not, however, real IELTS tests; they are designed to practise exam technique to help students to face the IELTS test with confidence and to perform to the best of their ability.\nWhile using this site, you agree to have read and accepted our terms of use, cookie and privacy policy.\nDear readers,\nThis is to inform you that we have moved to a new domain,\nhttps://www.ielts-writing.info/EXAM/\n.\nOur old domain, https://www.ielts-exam.net/ will remain active till the time we migrate all our content to the new domain.\nWe look forward to your continuing support.\nOK, I understand'
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
    'Section B',
    'Choose the correct answer.',
    '{"section-b-q1": ["vii. Why attempt geoengineering?"]}'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'i. Shielding the earth from the atmosphere', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'ii. Bouncing back the sun’s rays from earth', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'iii. The effect of volcanoes on the atmosphere', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'iv. Criticisms of geoengineering', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, 'v. Trapping greenhouse gases', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 6, 'vi. The root of the problem', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 7, 'vii. Why attempt geoengineering?', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 8, 'viii. Protecting glaciers', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 9, 'ix. The need for action', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    2,
    'MATCHING_HEADING',
    'READING',
    2,
    'Section C',
    'Choose the correct answer.',
    '{"section-c-q2": ["ii. Bouncing back the sun’s rays from earth"]}'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'i. Shielding the earth from the atmosphere', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'ii. Bouncing back the sun’s rays from earth', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'iii. The effect of volcanoes on the atmosphere', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'iv. Criticisms of geoengineering', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, 'v. Trapping greenhouse gases', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 6, 'vi. The root of the problem', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 7, 'vii. Why attempt geoengineering?', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 8, 'viii. Protecting glaciers', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 9, 'ix. The need for action', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    3,
    'MATCHING_HEADING',
    'READING',
    2,
    'Section D',
    'Choose the correct answer.',
    '{"section-d-q3": ["i. Shielding the earth from the atmosphere"]}'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'i. Shielding the earth from the atmosphere', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'ii. Bouncing back the sun’s rays from earth', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'iii. The effect of volcanoes on the atmosphere', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'iv. Criticisms of geoengineering', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, 'v. Trapping greenhouse gases', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 6, 'vi. The root of the problem', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 7, 'vii. Why attempt geoengineering?', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 8, 'viii. Protecting glaciers', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 9, 'ix. The need for action', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    4,
    'MATCHING_HEADING',
    'READING',
    2,
    'Section E',
    'Choose the correct answer.',
    '{"section-e-q4": ["v. Trapping greenhouse gases"]}'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'i. Shielding the earth from the atmosphere', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'ii. Bouncing back the sun’s rays from earth', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'iii. The effect of volcanoes on the atmosphere', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'iv. Criticisms of geoengineering', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, 'v. Trapping greenhouse gases', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 6, 'vi. The root of the problem', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 7, 'vii. Why attempt geoengineering?', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 8, 'viii. Protecting glaciers', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 9, 'ix. The need for action', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    5,
    'MATCHING_HEADING',
    'READING',
    2,
    'Section F',
    'Choose the correct answer.',
    '{"section-f-q5": ["iv. Criticisms of geoengineering"]}'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'i. Shielding the earth from the atmosphere', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'ii. Bouncing back the sun’s rays from earth', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'iii. The effect of volcanoes on the atmosphere', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'iv. Criticisms of geoengineering', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, 'v. Trapping greenhouse gases', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 6, 'vi. The root of the problem', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 7, 'vii. Why attempt geoengineering?', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 8, 'viii. Protecting glaciers', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 9, 'ix. The need for action', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    6,
    'MATCHING_FEATURES',
    'READING',
    2,
    'Removes carbon dioxide as soon as it is produced',
    'Choose the correct answer.',
    '{"feature-q6": ["C"]}'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C', true);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    7,
    'MATCHING_FEATURES',
    'READING',
    2,
    'Increases the reflectivity of white clouds',
    'Choose the correct answer.',
    '{"feature-q7": ["B"]}'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    8,
    'MATCHING_FEATURES',
    'READING',
    2,
    'Cleans carbon dioxide from the air naturally',
    'Choose the correct answer.',
    '{"feature-q8": ["C"]}'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C', true);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    9,
    'MATCHING_FEATURES',
    'READING',
    2,
    'Would increase the number of small plants and animals in the sea',
    'Choose the correct answer.',
    '{"feature-q9": ["C"]}'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C', true);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    10,
    'MATCHING_FEATURES',
    'READING',
    2,
    'May help prevent rising water levels',
    'Choose the correct answer.',
    '{"feature-q10": ["A"]}'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    11,
    'MATCHING_FEATURES',
    'READING',
    2,
    'Is similar to the effect volcanoes have on the atmosphere',
    'Choose the correct answer.',
    '{"feature-q11": ["B"]}'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C', false);


END$$;


COMMIT;