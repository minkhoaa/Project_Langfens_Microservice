-- ============================================
-- IELTS Exam Data Import SQL
-- Generated: 2025-12-25T00:28:29.197209
-- Source: mini-ielts.com
-- Title: A New Ice Age
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data for slug: mini-ielts-reading-a-new-ice-age
DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'mini-ielts-reading-a-new-ice-age'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'mini-ielts-reading-a-new-ice-age';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'mini-ielts-reading-a-new-ice-age';
DELETE FROM exams
WHERE "Slug" = 'mini-ielts-reading-a-new-ice-age';

DO $$
DECLARE
  exam_id uuid := gen_random_uuid();
  sec1 uuid := gen_random_uuid();
  qid uuid;
BEGIN

  INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","ImageUrl","UpdatedAt")
  VALUES (
    exam_id,
    'mini-ielts-reading-a-new-ice-age',
    'A New Ice Age',
    'IELTS Reading Practice Test from IELTS Mentor',
    'IELTS',
    'B2',
    'PUBLISHED',
    20,
    'https://res.cloudinary.com/df41zs8il/image/upload/v1766597303/ielts/ice-age_thumbpad_861fc73ba3cd.jpg',
    now()
  );

  INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","PassageMd")
  VALUES (
    sec1,
    exam_id,
    1,
    'Reading Passage - A New Ice Age',
    E'**Questions 1-4:**\nChoose the correct letter, **A**, **B**, **C** or **D**.\n\n---\n\n**Questions 5-9:**\nMatch each statement with the correct person **A-D**.\n\n---\n\n**Questions 10-13:**\nComplete the flow chart below.\nChoose **NO MORE THAN THREE WORDS** from the passage for each answer.',
    E'**Paragraph A.**\\nWilliam Curry is a serious, sober climate scientist, not an art critic. But he has spent a lot of time perusing Emanuel Gottlieb Leutze’s famous painting “George Washington Crossing the Delaware”, which depicts a boatload of colonial Ameri­can soldiers making their way to attack English and Hessian troops the day after Christmas in 1776. “Most people think these other guys in the boat are rowing, but they are actually pushing the ice away,” says Curry, tapping his finger on a reproduction of the painting. Sure enough, the lead oarsman is bashing the frozen river with his boot. “I grew up in Philadelphia. The place in this painting is 30 min­utes away by car. I can tell you, this kind of thing just doesn’t happen anymore.”\\n\\n**Paragraph B.**\\nBut it may again soon. And ice-choked scenes, similar to those immortalised by the 16th-century Flemish painter Pieter Brueghel the Elder, may also return to Europe. His works, including the 1565 masterpiece “Hunters in the Snow”, make the now-temperate European landscapes look more like Lapland. Such frigid set­tings were commonplace during a period dating roughly from 1300 to 1850 be­cause much of North America and Europe was in the throes of a little ice age. And now there is mounting evidence that the chill could return. A growing number of scientists believe conditions are ripe for another prolonged cooldown, or small ice age. While no one is predicting a brutal ice sheet like the one that covered the Northern Hemisphere with glaciers about 12,000 years ago, the next cooling trend could drop average temperatures 5 degrees Fahrenheit over much of the United States and 10 degrees in the Northeast, northern Europe, and northern Asia.\\n\\n**Paragraph C.**\\n“It could happen in 10 years,” says Terrence Joyce, who chairs the Woods Hole Physical Oceanography Department. “Once it does, it can take hundreds of years to reverse.” And he is alarmed that Americans have yet to take the threat seriously.\\n\\n**Paragraph D.**\\nA drop of 5 to 10 degrees entails much more than simply bumping up the thermo­stat and carrying on. Both economically and ecologically, such quick, persistent chilling could have devastating consequences. A 2002 report titled “Abrupt Climate Change: Inevitable Surprises”, produced by the National Academy of Sciences, pegged the cost from agricultural losses alone at $100 billion to $250 billion while also predicting that damage to ecologies could be vast and incalculable. A grim sampler: disappearing forests, increased housing expenses, dwindling fresh water, lower crop yields, and accelerated species extinctions.\\n\\n**Paragraph E.**\\nThe reason for such huge effects is simple. A quick climate change wreaks far more disruption than a slow one. People, animals, plants, and the economies that depend on them are like rivers; says the report: "For example, high water in a river will pose few problems until the water runs over the bank, after which levees can be breached and massive flooding can occur. Many biological processes undergo shifts at particular thresholds of temperature and precipitation.”\\n\\n**Paragraph F.**\\nPolitical changes since the last ice age could make survival far more difficult for the world''s poor. During previous cooling periods, whole tribes simply picked up and moved south, but that option doesn''t work in the modern, tense world of closed borders. "To the extent that abrupt climate change may cause rapid and ex­tensive changes of fortune for those who live off the land, the inability to migrate may remove one of the major safety nets for distressed people,” says the report.\\n\\n**Paragraph G.**\\nBut first things first. Isn''t the earth actually warming? Indeed it is, says Joyce. ‘ In his cluttered office, full of soft light from the foggy Cape Cod morning, he explains how such warming could actually be the surprising culprit of the next mini-ice age. The paradox is a result of the appearance over the past 30 years in the North Atlantic of huge rivers of fresh water - the equivalent of a 10-foot-thick layer - mixed into the salty sea. No one is certain where the fresh torrents are coming from, but a prime suspect is melting Arctic ice, caused by a build-up of carbon dioxide in the atmosphere that traps solar energy.\\n\\n**Paragraph H.**\\nThe freshwater trend is major news in ocean-science circles. Bob Dickson, a Brit­ish oceanographer who sounded an alarm at a February conference in Honolulu, has termed the drop in salinity and temperature in the Labrador Sea - a body of water between northeastern Canada and Greenland that adjoins the Atlantic - "arguably the largest full-depth changes observed in the modern instrumental oceanographic record”.\\n\\n**Paragraph I.**\\nThe trend could cause a little ice age by subverting the northern penetration of Gulf Stream waters. Normally, the Gulf Stream, laden with heat soaked up in the tropics, meanders up the east coasts of the United States and Canada. As it flows northward, the stream surrenders heat to the air. Because the prevailing North Atlantic winds blow eastward, a lot of the heat wafts to Europe. That’s why many scientists believe winter temperatures on the Continent are as much as 36 de­grees Fahrenheit warmer than those in North America at the same latitude. Frigid Boston, for example, lies at almost precisely the same latitude as balmy Rome. And some scientists say the heat also warms Americans and Canadians. “It’s a real mistake to think of this solely as a European phenomenon," says Joyce.\\n\\n**Paragraph J.**\\nHaving given up its heat to the air, the now-cooler water becomes denser and sinks into the North Atlantic by a mile or more in a process oceanographers call thermohaline circulation. This massive column of cascading cold is the main engine powering a deep-water current called the Great Ocean Conveyor that snakes through all the world’s oceans. But as the North Atlantic fills with fresh water, it grows less dense, making the waters carried northward by the Gulf Stream less able to sink. The new mass of relatively fresh water sits on top of the ocean like a big thermal blanket, threatening the thermohaline circulation. That in turn could make the Gulf Stream slow or veer southward. At some point, the whole system could simply shut down, and do so quickly. “There is increasing evidence that we are getting closer to a transition point, from which we can jump to a new state.”\\n\\n\n---\n\n## Diagram/Image for Questions 10-13\n\n![Questions 10-13](https://res.cloudinary.com/df41zs8il/image/upload/v1766597308/ielts/diagram_50ff07cd4689.jpg)\n'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    1,
    'MULTIPLE_CHOICE_SINGLE',
    'READING',
    2,
    'The writer uses paintings in the first paragraph to illustrate',
    '',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. possible future climate change', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. climate change of the last two centuries', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. the river doesn''t freeze in winter anymore', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D. how George Washington led his troops across the river', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    2,
    'MULTIPLE_CHOICE_SINGLE',
    'READING',
    2,
    'Which of the following do scientists believe to be possible?',
    '',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. The temperature may drop over much of the Northern Hemisphere', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. It will be colder than 12,000 years ago', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. The entire Northern Hemisphere will be covered in ice', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D. Europe will look more like Lapland', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    3,
    'MULTIPLE_CHOICE_SINGLE',
    'READING',
    2,
    'Why is it difficult for the poor to survive the next ice age?',
    '',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. People don''t live in tribes anymore', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. Politics are changing too fast today', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. Abrupt climate change causes people to live off their land', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D. Migration has become impossible because of closed borders', true);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    4,
    'MULTIPLE_CHOICE_SINGLE',
    'READING',
    2,
    'Why is continental Europe much warmer than North America in winter?',
    '',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. Wind blows most of the heat of tropical currents to Europe', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. Europe and North America are at different latitudes', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. The Gulf Stream has stopped yielding heat to the air', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D. The Gulf Stream moves north along the east coast of North America', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    5,
    'MATCHING_FEATURES',
    'READING',
    2,
    'Most Americans are not prepared for the next ice age',
    '',
    '{"feature-q5": ["B", "B"]}'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. William Curry', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. Terrence Joyce', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. Bob Dickson', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D. National Academy of Sciences', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    6,
    'MATCHING_FEATURES',
    'READING',
    2,
    'The result of abrupt climate change is catastrophic',
    '',
    '{"feature-q6": ["D", "D"]}'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. William Curry', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. Terrence Joyce', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. Bob Dickson', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D. National Academy of Sciences', true);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    7,
    'MATCHING_FEATURES',
    'READING',
    2,
    'The world is not as cold as it used to be',
    '',
    '{"feature-q7": ["A", "A"]}'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. William Curry', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. Terrence Joyce', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. Bob Dickson', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D. National Academy of Sciences', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    8,
    'MATCHING_FEATURES',
    'READING',
    2,
    'Global warming is closely connected to the ice age',
    '',
    '{"feature-q8": ["B", "B"]}'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. William Curry', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. Terrence Joyce', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. Bob Dickson', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D. National Academy of Sciences', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    9,
    'MATCHING_FEATURES',
    'READING',
    2,
    'Alerted people to the change of ocean water in a conference',
    '',
    '{"feature-q9": ["C", "C"]}'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. William Curry', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. Terrence Joyce', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. Bob Dickson', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D. National Academy of Sciences', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    10,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    'Label 10 on flow chart: _______',
    '',
    '{"blank-q10": ["HEAT"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    11,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    'Label 11 on flow chart: _______',
    '',
    '{"blank-q11": ["DENSER"]}'::jsonb
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
    'Label 12 on flow chart: _______',
    '',
    '{"blank-q12": ["GREAT OCEAN CONVEYOR"]}'::jsonb
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
    'Label 13 on flow chart: _______',
    '',
    '{"blank-q13": ["FRESH WATER"]}'::jsonb
  );



  -- Delete old question groups for this exam
  DELETE FROM exam_question_groups WHERE "SectionId" = sec1;

  -- Insert question groups
  INSERT INTO exam_question_groups ("Id","SectionId","Idx","StartIdx","EndIdx","InstructionMd")
  VALUES (gen_random_uuid(), sec1, 1, 1, 4, E'## Questions 1-4\n\nChoose the correct letter, **A**, **B**, **C** or **D**.\n\n**1** The writer uses paintings in the first paragraph to illustrate\n- **A** possible future climate change\n- **B** climate change of the last two centuries\n- **C** the river doesn''t freeze in winter anymore\n- **D** how George Washington led his troops across the river\n\n**2** Which of the following do scientists believe to be possible?\n- **A** The temperature may drop over much of the Northern Hemisphere\n- **B** It will be colder than 12,000 years ago\n- **C** The entire Northern Hemisphere will be covered in ice\n- **D** Europe will look more like Lapland\n\n**3** Why is it difficult for the poor to survive the next ice age?\n- **A** People don''t live in tribes anymore\n- **B** Politics are changing too fast today\n- **C** Abrupt climate change causes people to live off their land\n- **D** Migration has become impossible because of closed borders\n\n**4** Why is continental Europe much warmer than North America in winter?\n- **A** Wind blows most of the heat of tropical currents to Europe\n- **B** Europe and North America are at different latitudes\n- **C** The Gulf Stream has stopped yielding heat to the air\n- **D** The Gulf Stream moves north along the east coast of North America');

  INSERT INTO exam_question_groups ("Id","SectionId","Idx","StartIdx","EndIdx","InstructionMd")
  VALUES (gen_random_uuid(), sec1, 2, 5, 9, E'## Questions 5-9\n\nLook at the following statements (Questions 5-9) and the list of people in the box below.\n\nMatch each statement with the correct person **A-D**.\n\n*NB You may use any letter more than once.*\n\n### List of People\n- **A** William Curry\n- **B** Terrence Joyce\n- **C** Bob Dickson\n- **D** National Academy of Sciences\n\n**5** Most Americans are not prepared for the next ice age  \n**6** The result of abrupt climate change is catastrophic  \n**7** The world is not as cold as it used to be  \n**8** Global warming is closely connected to the ice age  \n**9** Alerted people to the change of ocean water in a conference');

  INSERT INTO exam_question_groups ("Id","SectionId","Idx","StartIdx","EndIdx","InstructionMd")
  VALUES (gen_random_uuid(), sec1, 3, 10, 13, E'## Questions 10-13\n\nComplete the flow chart below.\n\nChoose **NO MORE THAN THREE WORDS** from the passage for each answer.\n\n![Flow Chart](https://res.cloudinary.com/df41zs8il/image/upload/v1766597308/ielts/diagram_50ff07cd4689.jpg)\n\n**10** _______  \n**11** _______  \n**12** _______  \n**13** _______');

END$$;


COMMIT;