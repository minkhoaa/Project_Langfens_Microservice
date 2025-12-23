-- ============================================
-- IELTS Exam Data Import SQL
-- Generated: 2025-12-23T01:26:04.869278
-- Source: mini-ielts.com
-- Title: Pacific navigation and voyaging
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data for slug: mini-ielts-reading-pacific-navigation-and-voyaging
DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'mini-ielts-reading-pacific-navigation-and-voyaging'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'mini-ielts-reading-pacific-navigation-and-voyaging';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'mini-ielts-reading-pacific-navigation-and-voyaging';
DELETE FROM exams
WHERE "Slug" = 'mini-ielts-reading-pacific-navigation-and-voyaging';

DO $$
DECLARE
  exam_id uuid := gen_random_uuid();
  sec1 uuid := gen_random_uuid();
  qid uuid;
BEGIN

  INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","ImageUrl","UpdatedAt")
  VALUES (
    exam_id,
    'mini-ielts-reading-pacific-navigation-and-voyaging',
    'Pacific navigation and voyaging',
    'IELTS Reading Practice Test from IELTS Mentor',
    'IELTS',
    'B2',
    'PUBLISHED',
    20,
    'https://www.learnz.org.nz/sites/learnz.org.nz/files/b-lc192-01-navigation.jpg',
    now()
  );

  INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","PassageMd")
  VALUES (
    sec1,
    exam_id,
    1,
    'Reading Passage - Pacific navigation and voyaging',
    E'**Questions 1-5:**\nDo the following statements agree with the claims of the writer?\n\nWrite\n- **YES** if the statement agrees with the claims of the writer\n- **NO** if the statement contradicts the claims of the writer\n- **NOT GIVEN** if it is impossible to say what the writer thinks about this\n\n---\n\n**Questions 6-10:**\nChoose the correct letter, **A**, **B**, **C** or **D**.\n\n---\n\n**Questions 11-14:**\nComplete each sentence with the correct ending, **A-F**, below.\n\n- **A** was the variety of experimental techniques used\n- **B** was not of interest to young islanders today\n- **C** was not conclusive evidence in support of a single theory\n- **D** was being able to change their practices when necessary\n- **E** was the first time humans intentionally crossed an ocean\n- **F** was the speed with which it was conducted',
    E'# Passage\n\n**Paragraph A.**\\nThe many tiny islands of the Pacific Ocean had no human population until ancestors of today’s islanders sailed from Southeast Asia in ocean-going canoes approximately 2,000 years ago. At the present time, the debate continues about exactly how they migrated such vast distances across the ocean, without any of the modern technologies we take for granted.\\n\\n**Paragraph B.**\\nAlthough the romantic vision of some early twentieth-century writers of fleets of heroic navigators simultaneously setting sail had come to be considered by later investigators to be exaggerated, no considered assessment of Pacific voyaging was forthcoming until 1956 when the American historian Andrew Sharp published his research. Sharp challenged the ‘heroic vision’ by asserting that the expertise of the navigators was limited, and that the settlement of the islands was not systematic, being more dependent on good fortune by drifting canoes. Sharp’s theory was widely challenged, and deservedly so. If nothing else, however, it did spark renewed interest in the topic and precipitated valuable new research.\\n\\n**Paragraph C.**\\nSince the 1960s a wealth of investigations has been conducted, and most of them, thankfully, have been of the ‘non-armchair’ variety. While it would be wrong to denigrate all ‘armchair’ research - that based on an examination of available published materials - it has turned out that so little progress had been made in the area of Pacific voyaging because most writers relied on the same old sources - travelers’ journals or missionary narratives compiled by unskilled observers. After Sharp, this began to change, and researchers conducted most of their investigations not in libraries, but in the field.\\n\\n**Paragraph D.**\\nIn 1965, David Lewis, a physician and experienced yachtsman, set to work using his own unique philosophy: he took the yacht he had owned for many years and navigated through the islands in order to contact those men who still find their way at sea using traditional methods. He then accompanied these men, in their traditional canoes, on test voyages from which all modern instruments were banished from sight, though Lewis secretly used them to confirm the navigator’s calculations. His most famous such voyage was a return trip of around 1,000 nautical miles between two islands in mid­ocean. Far from drifting, as proposed by Sharp, Lewis found that ancient navigators would have known which course to steer by memorizing which stars rose and set in certain positions along the horizon and this gave them fixed directions by which to steer their boats.\\n\\n**Paragraph E.**\\nThe geographer Edwin Doran followed a quite different approach. He was interested in obtaining exact data on canoe sailing performance, and to that end employed the latest electronic instrumentation. Doran traveled on board traditional sailing canoes in some of the most remote parts of the Pacific, all the while using his instruments to record canoe speeds in different wind strengths - from gales to calms - the angle canoes could sail relative to the wind. In the process, he provided the first really precise attributes of traditional sailing canoes.\\n\\n**Paragraph F.**\\nA further contribution was made by Steven Horvath. As a physiologist, Horvath’s interest was not in navigation techniques or in canoes, but in the physical capabilities of the men themselves. By adapting standard physiological techniques, Horvath was able to calculate the energy expenditure required to paddle canoes of this sort at times when there was no wind to fill the sails, or when the wind was contrary. He concluded that paddles, or perhaps long oars, could indeed have propelled for long distances what were primarily sailing vessels.\\n\\n**Paragraph G.**\\nFinally, a team led by p Wall Garrard conducted important research, in this case by making investigations while remaining safely in the laboratory. Wall Garrard’s unusual method was to use the findings of linguists who had studied the languages of the Pacific islands, many of which are remarkably similar although the islands where they are spoken are sometimes thousands of kilometres apart. Clever adaptation of computer simulation techniques pioneered in other disciplines allowed him to produce convincing models suggesting the migrations were indeed systematic, but not simultaneous. Wall Garrard proposed the migrations should be seen not as a single journey made by a massed fleet of canoes, but as a series of ever more ambitious voyages, each pushing further into the unknown ocean.\\n\\n**Paragraph H.**\\nWhat do we learn about Pacific navigation and voyaging from this research? Quite correctly, none of the researchers tried to use their findings to prove one theory or another; experiments such as these cannot categorically confirm or negate a hypothesis. The strength of this research lay in the range of methodologies employed. When we splice together these findings we can propose that traditional navigators used a variety of canoe types, sources of water and navigation techniques, and it was this adaptability which was their greatest accomplishment. These navigators observed the conditions prevailing at sea at the time a voyage was made and altered their techniques accordingly. Furthermore, the canoes of the navigators were not drifting helplessly at sea but were most likely part of a systematic migration; as such, the Pacific peoples were able to view the ocean as an avenue, not a barrier, to communication before any other race on Earth. Finally, one unexpected but most welcome consequence of this research has been a renaissance in the practice of traditional voyaging. In some groups of islands in the Pacific today young people are resurrecting the skills of their ancestors, when a few decades ago it seemed they would be lost forever.\\n\\n'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    1,
    'YES_NO_NOT_GIVEN',
    'READING',
    2,
    'The Pacific islands were uninhabited when migrants arrived by sea from Southeast Asia',
    '',
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
    2,
    'YES_NO_NOT_GIVEN',
    'READING',
    2,
    'Andrew Sharp was the first person to write about the migrants to islanders',
    '',
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
    3,
    'YES_NO_NOT_GIVEN',
    'READING',
    2,
    'Andrew Sharp believed migratory voyages were based on more on luck than skill',
    '',
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
    4,
    'YES_NO_NOT_GIVEN',
    'READING',
    2,
    'Despite being controversial, Andrew Sharp’s research had positive results',
    '',
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
    5,
    'YES_NO_NOT_GIVEN',
    'READING',
    2,
    'Edwin Doran disagreed with the findings of Lewis’s research',
    '',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'YES', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'NO', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'NOT GIVEN', true);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    6,
    'MULTIPLE_CHOICE_SINGLE',
    'READING',
    2,
    'David Lewis''s research was different because',
    '',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. he observed traditional navigators at work', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. he conducted test voyages using his own yacht', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. he carried no modern instruments on test voyages', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D. he spoke the same language as the islanders he sailed with', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    7,
    'MULTIPLE_CHOICE_SINGLE',
    'READING',
    2,
    'What did David Lewis''s research discover about traditional navigators?',
    '',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. They used the sun and moon to find their position', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. They could not sail further than about 1,000 nautical miles', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. They knew which direction they were sailing in', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D. They were able to drift for long distances', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    8,
    'MULTIPLE_CHOICE_SINGLE',
    'READING',
    2,
    'What are we told about Edwin Doran''s research?',
    '',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. Data were collected after the canoes had returned to land', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. Canoe characteristics were recorded using modern instruments', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. Research was conducted in the most densely populated regions', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D. Navigators were not allowed to see the instruments Doran used', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    9,
    'MULTIPLE_CHOICE_SINGLE',
    'READING',
    2,
    'Which of the following did Steven Horvath discover during his research?',
    '',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. Canoe design was less important than human strength', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. New research methods had to be developed for use in canoes', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. Navigators became very tired on the longest voyages', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D. Human energy may have been used to assist sailing canoes', true);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    10,
    'MULTIPLE_CHOICE_SINGLE',
    'READING',
    2,
    'What is the writer''s opinion of p Wall Garrard''s research?',
    '',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. He is disappointed it was conducted in the laboratory', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. He is impressed by the originality of the techniques used', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. He is surprised it was used to help linguists with their research', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D. He is concerned that the islands studied are long distances apart', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    11,
    'MATCHING_FEATURES',
    'READING',
    2,
    'One limitation in the information produced by all of this research is that it',
    '',
    '{"feature-q11": ["C", "C"]}'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    12,
    'MATCHING_FEATURES',
    'READING',
    2,
    'The best thing about this type of research',
    '',
    '{"feature-q12": ["A", "A"]}'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    13,
    'MATCHING_FEATURES',
    'READING',
    2,
    'The most important achievement of traditional navigators',
    '',
    '{"feature-q13": ["D", "D"]}'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    14,
    'MATCHING_FEATURES',
    'READING',
    2,
    'The migration of people from Asia to the Pacific',
    '',
    '{"feature-q14": ["E", "E"]}'
  );


END$$;


COMMIT;