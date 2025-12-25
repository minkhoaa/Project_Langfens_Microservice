-- ============================================
-- IELTS Exam Data Import SQL
-- Generated: 2025-12-25T15:48:00.362407
-- Source: ielts-mentor.com
-- Title: Reading Test 119: Passage 3 - What is exploration?
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data for slug: ielts-mentor-reading-test-119-passage-3-what-is-exploration
DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-mentor-reading-test-119-passage-3-what-is-exploration'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-mentor-reading-test-119-passage-3-what-is-exploration';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-mentor-reading-test-119-passage-3-what-is-exploration';
DELETE FROM exams
WHERE "Slug" = 'ielts-mentor-reading-test-119-passage-3-what-is-exploration';

DO $$
DECLARE
  exam_id uuid := gen_random_uuid();
  sec1 uuid := gen_random_uuid();
  qid uuid;
BEGIN

  INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","ImageUrl","UpdatedAt")
  VALUES (
    exam_id,
    'ielts-mentor-reading-test-119-passage-3-what-is-exploration',
    'Reading Test 119: Passage 3 - What is exploration?',
    'IELTS Reading Practice Test from IELTS Mentor',
    'IELTS',
    'B2',
    'PUBLISHED',
    20,
    NULL,
    now()
  );

  INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","PassageMd")
  VALUES (
    sec1,
    exam_id,
    1,
    'Reading Passage - Reading Test 119: Passage 3 - What is exploration?',
    E'## Questions 27-32\n\nChoose the correct letter, **A**, **B**, **C** or **D**.\n\n**27.** The writer refers to visitors to New York to illustrate the point that\n- **A.** exploration is an intrinsic element of being human.\n- **B.** most people are enthusiastic about exploring.\n- **C.** exploration can lead to surprising results.\n- **D.** most people find exploration daunting.\n\n**28.** According to the second paragraph, what is the writer''s view of explorers?\n- **A.** Their discoveries have brought both benefits and disadvantages.\n- **B.** Their main value is in teaching others.\n- **C.** They act on an urge that is common to everyone.\n- **D.** They tend to be more attracted to certain professions than to others.\n\n**29.** The writer refers to a description of Egdon Heath to suggest that\n- **A.** Hardy was writing about his own experience of exploration.\n- **B.** Hardy was mistaken about the nature of exploration.\n- **C.** Hardy''s aim was to investigate people''s emotional states.\n- **D.** Hardy''s aim was to show the attraction of isolation.\n\n**30.** In the fourth paragraph, the writer refers to ''a golden age'' to suggest that\n- **A.** the amount of useful information produced by exploration has decreased.\n- **B.** fewer people are interested in exploring than in the 19th century.\n- **C.** recent developments have made exploration less exciting.\n- **D.** we are wrong to think that exploration is no longer necessary.\n\n**31.** In the sixth paragraph, when discussing the definition of exploration, the writer argues that\n- **A.** people tend to relate exploration to their own professional interests.\n- **B.** certain people are likely to misunderstand the nature of exploration.\n- **C.** the generally accepted definition has changed over time.\n- **D.** historians and scientists have more valid definitions than the general public.\n\n**32.** In the last paragraph, the writer explains that he is interested in\n- **A.** how someone''s personality is reflected in their choice of places to visit.\n- **B.** the human ability to cast new light on places that may be familiar.\n- **C.** how travel writing has evolved to meet changing demands.\n- **D.** the feelings that writers develop about the places that they explore.\n\n---\n\n## Questions 33-37\n\nLook at the following statements (Questions 33-37) and the list of explorers below.\n\nMatch each statement with the correct explorer, **A-E**.\n\n*NB You may use any letter more than once.*\n\n**List of Explorers:**\n- **A.** Peter Fleming\n- **B.** Ran Fiennes\n- **C.** Chris Bonington\n- **D.** Robin Hanbury-Tenison\n- **E.** Wilfred Thesiger\n\n**33.** He referred to the relevance of the form of transport used.\n**34.** He described feelings on coming back home after a long journey.\n**35.** He worked for the benefit of specific groups of people.\n**36.** He did not consider learning about oneself an essential part of exploration.\n**37.** He defined exploration as being both unique and of value to others.\n\n---\n\n## Questions 38-40\n\nComplete the summary below.\n\nChoose **NO MORE THAN TWO WORDS** from the passage for each answer.\n\n### The writer''s own bias\n\nThe writer has experience of a large number of **38** _______, and was the first stranger that certain previously **39** _______ people had encountered. He believes there is no need for further exploration of Earth''s **40** _______, except to answer specific questions such as how buffalo eat.',
    E'**Paragraph A.**\nWe are all explorers. Our desire to discover, and then share that new-found knowledge, is part of what makes us human – indeed, this has played an important part in our success as a species. Long before the first caveman slumped down beside the fire and grunted news that there were plenty of wildebeest over yonder, our ancestors had learnt the value of sending out scouts to investigate the unknown. This questing nature of ours undoubtedly helped our species spread around the globe, just as it nowadays no doubt helps the last nomadic Penan maintain their existence in the depleted forests of Borneo, and a visitor negotiate the subways of New York.\n\n**Paragraph B.**\nOver the years, we''ve come to think of explorers as a peculiar breed – different from the rest of us, different from those of us who are merely ''well travelled'', even; and perhaps there is a type of person more suited to seeking out the new, a type of caveman more inclined to risk venturing out. That, however, doesn''t take away from the fact that we all have this enquiring instinct, even today; and that in all sorts of professions – whether artist, marine biologist or astronomer – borders of the unknown are being tested each day.\n\n**Paragraph C.**\nThomas Hardy set some of his novels in Egdon Heath, a fictional area of uncultivated land, and used the landscape to suggest the desires and fears of his characters. He is delving into matters we all recognise because they are common to humanity. This is surely an act of exploration, and into a world as remote as the author chooses. Explorer and travel writer Peter Fleming talks of the moment when the explorer returns to the existence he has left behind with his loved ones. The traveller ''who has for weeks or months seen himself only as a puny and irrelevant alien crawling laboriously over a country in which he has no roots and no background, suddenly encounters his other self, a relatively solid figure, with a place in the minds of certain people''.\n\n**Paragraph D.**\nIn this book about the exploration of the earth''s surface, I have confined myself to those whose travels were real and who also aimed at more than personal discovery. But that still left me with another problem: the word ''explorer'' has become associated with a past era. We think back to a golden age, as if exploration peaked somehow in the 19th century – as if the process of discovery is now on the decline, though the truth is that we have named only one and a half million of this planet''s species, and there may be more than 10 million – and that''s not including bacteria. We have studied only 5 per cent of the species we know. We have scarcely mapped the ocean floors, and know even less about ourselves; we fully understand the workings of only 10 per cent of our brains.\n\n**Paragraph E.**\nHere is how some of today''s ''explorers'' define the word. Ran Fiennes, dubbed the ''greatest living explorer'', said, ''An explorer is someone who has done something that no human has done before – and also done something scientifically useful.'' Chris Bonington, a leading mountaineer, felt exploration was to be found in the act of physically touching the unknown: ''You have to have gone somewhere new.'' Then Robin Hanbury-Tenison, a campaigner on behalf of remote so-called ''tribal'' peoples, said, ''A traveller simply records information about some far-off world, and reports back; but an explorer changes the world.'' Wilfred Thesiger, who crossed Arabia''s Empty Quarter in 1946, and belongs to an era of unmechanised travel now lost to the rest of us, told me, ''If I''d gone across by camel when I could have gone by car, it would have been a stunt.'' To him, exploration meant bringing back information from a remote place regardless of any great self-discovery.\n\n**Paragraph F.**\nEach definition is slightly different – and tends to reflect the field of endeavour of each pioneer. It was the same whoever I asked: the prominent historian would say exploration was a thing of the past, the cutting-edge scientist would say it was of the present. And so on. They each set their own particular criteria; the common factor in their approach being that they all had, unlike many of us who simply enjoy travel or discovering new things, both a very definite objective from the outset and also a desire to record their findings.\n\n**Paragraph G.**\nI''d best declare my own bias. As a writer, I''m interested in the exploration of ideas. I''ve done a great many expeditions and each one was unique. I''ve lived for months alone with isolated groups of people all around the world, even two ''uncontacted tribes''. But none of these things is of the slightest interest to anyone unless, through my books, I''ve found a new slant, explored a new idea. Why? Because the world has moved on. The time has long passed for the great continental voyages – another walk to the poles, another crossing of the Empty Quarter. We know how the land surface of our planet lies; exploration of it is now down to the details – the habits of microbes, say, or the grazing behaviour of buffalo. Aside from the deep sea and deep underground, it''s the era of specialists. However, this is to disregard the role the human mind has in conveying remote places; and this is what interests me: how a fresh interpretation, even of a well-travelled route, can give its readers new insights.'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    27,
    'MULTIPLE_CHOICE_SINGLE',
    'READING',
    2,
    'The writer refers to visitors to New York to illustrate the point that',
    '',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. exploration is an intrinsic element of being human.', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. most people are enthusiastic about exploring.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. exploration can lead to surprising results.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D. most people find exploration daunting.', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    28,
    'MULTIPLE_CHOICE_SINGLE',
    'READING',
    2,
    'According to the second paragraph, what is the writer''s view of explorers?',
    '',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. Their discoveries have brought both benefits and disadvantages.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. Their main value is in teaching others.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. They act on an urge that is common to everyone.', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D. They tend to be more attracted to certain professions than to others.', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    29,
    'MULTIPLE_CHOICE_SINGLE',
    'READING',
    2,
    'The writer refers to a description of Egdon Heath to suggest that',
    '',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. Hardy was writing about his own experience of exploration.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. Hardy was mistaken about the nature of exploration.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. Hardy''s aim was to investigate people''s emotional states.', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D. Hardy''s aim was to show the attraction of isolation.', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    30,
    'MULTIPLE_CHOICE_SINGLE',
    'READING',
    2,
    'In the fourth paragraph, the writer refers to ''a golden age'' to suggest that',
    '',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. the amount of useful information produced by exploration has decreased.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. fewer people are interested in exploring than in the 19th century.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. recent developments have made exploration less exciting.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D. we are wrong to think that exploration is no longer necessary.', true);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    31,
    'MULTIPLE_CHOICE_SINGLE',
    'READING',
    2,
    'In the sixth paragraph, when discussing the definition of exploration, the writer argues that',
    '',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. people tend to relate exploration to their own professional interests.', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. certain people are likely to misunderstand the nature of exploration.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. the generally accepted definition has changed over time.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D. historians and scientists have more valid definitions than the general public.', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    32,
    'MULTIPLE_CHOICE_SINGLE',
    'READING',
    2,
    'In the last paragraph, the writer explains that he is interested in',
    '',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. how someone''s personality is reflected in their choice of places to visit.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. the human ability to cast new light on places that may be familiar.', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. how travel writing has evolved to meet changing demands.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D. the feelings that writers develop about the places that they explore.', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    33,
    'MATCHING_FEATURES',
    'READING',
    2,
    'He referred to the relevance of the form of transport used.',
    '',
    '{"feature-q33": ["E", "E"]}'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    34,
    'MATCHING_FEATURES',
    'READING',
    2,
    'He described feelings on coming back home after a long journey.',
    '',
    '{"feature-q34": ["A", "A"]}'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    35,
    'MATCHING_FEATURES',
    'READING',
    2,
    'He worked for the benefit of specific groups of people.',
    '',
    '{"feature-q35": ["D", "D"]}'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    36,
    'MATCHING_FEATURES',
    'READING',
    2,
    'He did not consider learning about oneself an essential part of exploration.',
    '',
    '{"feature-q36": ["E", "E"]}'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    37,
    'MATCHING_FEATURES',
    'READING',
    2,
    'He defined exploration as being both unique and of value to others.',
    '',
    '{"feature-q37": ["B", "B"]}'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    38,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    'The writer has experience of a large number of _______',
    '',
    '{"blank-q38": ["EXPEDITIONS"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    39,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    'and was the first stranger that certain previously _______ people had encountered.',
    '',
    '{"blank-q39": ["UNCONTACTED"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    40,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    'He believes there is no need for further exploration of Earth''s _______',
    '',
    '{"blank-q40": ["SURFACE"]}'::jsonb
  );



  -- Delete old question groups for this exam
  DELETE FROM exam_question_groups WHERE "SectionId" = sec1;

  -- Insert question groups
  INSERT INTO exam_question_groups ("Id","SectionId","Idx","StartIdx","EndIdx","InstructionMd")
  VALUES (gen_random_uuid(), sec1, 1, 27, 32, E'## Questions 27-32\n\nChoose the correct letter, **A**, **B**, **C** or **D**.\n\n**27.** The writer refers to visitors to New York to illustrate the point that\n- **A.** exploration is an intrinsic element of being human.\n- **B.** most people are enthusiastic about exploring.\n- **C.** exploration can lead to surprising results.\n- **D.** most people find exploration daunting.\n\n**28.** According to the second paragraph, what is the writer''s view of explorers?\n- **A.** Their discoveries have brought both benefits and disadvantages.\n- **B.** Their main value is in teaching others.\n- **C.** They act on an urge that is common to everyone.\n- **D.** They tend to be more attracted to certain professions than to others.\n\n**29.** The writer refers to a description of Egdon Heath to suggest that\n- **A.** Hardy was writing about his own experience of exploration.\n- **B.** Hardy was mistaken about the nature of exploration.\n- **C.** Hardy''s aim was to investigate people''s emotional states.\n- **D.** Hardy''s aim was to show the attraction of isolation.\n\n**30.** In the fourth paragraph, the writer refers to ''a golden age'' to suggest that\n- **A.** the amount of useful information produced by exploration has decreased.\n- **B.** fewer people are interested in exploring than in the 19th century.\n- **C.** recent developments have made exploration less exciting.\n- **D.** we are wrong to think that exploration is no longer necessary.\n\n**31.** In the sixth paragraph, when discussing the definition of exploration, the writer argues that\n- **A.** people tend to relate exploration to their own professional interests.\n- **B.** certain people are likely to misunderstand the nature of exploration.\n- **C.** the generally accepted definition has changed over time.\n- **D.** historians and scientists have more valid definitions than the general public.\n\n**32.** In the last paragraph, the writer explains that he is interested in\n- **A.** how someone''s personality is reflected in their choice of places to visit.\n- **B.** the human ability to cast new light on places that may be familiar.\n- **C.** how travel writing has evolved to meet changing demands.\n- **D.** the feelings that writers develop about the places that they explore.');

  INSERT INTO exam_question_groups ("Id","SectionId","Idx","StartIdx","EndIdx","InstructionMd")
  VALUES (gen_random_uuid(), sec1, 2, 33, 37, E'## Questions 33-37\n\nLook at the following statements (Questions 33-37) and the list of explorers below.\n\nMatch each statement with the correct explorer, **A-E**.\n\n*NB You may use any letter more than once.*\n\n**List of Explorers:**\n- **A.** Peter Fleming\n- **B.** Ran Fiennes\n- **C.** Chris Bonington\n- **D.** Robin Hanbury-Tenison\n- **E.** Wilfred Thesiger\n\n**33.** He referred to the relevance of the form of transport used.\n**34.** He described feelings on coming back home after a long journey.\n**35.** He worked for the benefit of specific groups of people.\n**36.** He did not consider learning about oneself an essential part of exploration.\n**37.** He defined exploration as being both unique and of value to others.');

  INSERT INTO exam_question_groups ("Id","SectionId","Idx","StartIdx","EndIdx","InstructionMd")
  VALUES (gen_random_uuid(), sec1, 3, 38, 40, E'## Questions 38-40\n\nComplete the summary below.\n\nChoose **NO MORE THAN TWO WORDS** from the passage for each answer.\n\n### The writer''s own bias\n\nThe writer has experience of a large number of **38** _______, and was the first stranger that certain previously **39** _______ people had encountered. He believes there is no need for further exploration of Earth''s **40** _______, except to answer specific questions such as how buffalo eat.');

END$$;


COMMIT;