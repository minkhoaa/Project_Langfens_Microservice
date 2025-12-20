-- ============================================
-- IELTS Exam Data Import SQL
-- Generated: 2025-12-20T14:47:30.827391
-- Source: ielts-mentor.com
-- Title: GT Reading 61 Section 3 - Marine Ecosystems
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data for slug: ielts-mentor-gt-reading-61-section-3-marine-ecosystems
DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-mentor-gt-reading-61-section-3-marine-ecosystems'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-mentor-gt-reading-61-section-3-marine-ecosystems';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-mentor-gt-reading-61-section-3-marine-ecosystems';
DELETE FROM exams
WHERE "Slug" = 'ielts-mentor-gt-reading-61-section-3-marine-ecosystems';

DO $$
DECLARE
  exam_id uuid := gen_random_uuid();
  sec1 uuid := gen_random_uuid();
  qid uuid;
BEGIN

  INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","UpdatedAt")
  VALUES (
    exam_id,
    'ielts-mentor-gt-reading-61-section-3-marine-ecosystems',
    'GT Reading 61 Section 3 - Marine Ecosystems',
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
    'Reading Passage - GT Reading 61 Section 3 - Marine Ecosystems',
    E'# Passage\n\n# Marine Ecosystem\n\nList of Headings i. Plans for more marine protected areas ii. A historical overview of one specific area iii. Why more has not been done to save marine creatures iv. What the press has missed v. Where biodiversity has been shown to help vi. Who is currently being blamed vii. A reason for some optimism viii. Various factors other than fishing\n\nA For some time now, the world’s oceans and the people who fish them have been a constant source of bad environmental news: cod is effectively an endangered species of fish in some places now; every year thousands of dolphins are injured by fishing vessels; huge tuna farms are ruining the Mediterranean Sea.\n\nWhat is more, marine biologists recently warned that our seafood is in terminal decline. According to research published in Science last November, stocks of all the fish and shellfish that we currently eat will collapse before 2050. Or at least that’s how the media reported it.\n\nB However, the scientist who led the study has said that the main conclusion of his research has been buried beneath the headlines. While the danger to our seafood supply is real enough, says Boris Worm, assistant professor of marine conservation biology at Dalhousie University, Canada, there is a more serious point: that the way in which we manage the oceans is not only threatening the survival of individual species, it’s upsetting the delicate balance of marine communities and thus causing the collapse of entire ecosystems. Research has shown that the number of ecosystems where all higher forms of life are extinct, so-called dead zones, is increasing.\n\nThe point that many reports failed to highlight, says Worm, is that we have to revolutionise the way our marine resources are run, changing the focus from stocks and quotas to biodiversity and ecosystem protection. And to do that, we must change the way the debate about our marine resources is conducted in the public domain.\n\nC Around 7,500 years ago, shrinking glaciers and the resulting higher water levels led to the development of what’s called the Wadden Sea, a 13,500-square-kilometre area of the North Sea. During the first 5,000 years or so, the sea pulsated with life. There was a high level of biodiversity on the seabed too, and the salt marshes and mud flats on the coast supported millions of birds. This continued until around 2,000 years ago, when human pressure began to affect it. Research has shown that some of the larger creatures disappeared more than 500 years ago. And by the late 19th century, populations of most of the other mammals and fish were severely reduced, leading to the collapse of several traditional fisheries.\n\nD What’s interesting is that overfishing isn’t the main agent of the decline, as we might assume. It’s due to an ongoing combination of exploitation, habitat destruction and pollution. Coastal development, for example, destroys large areas of wetlands that support a range of species. Pollution fuels a process known as eutrophication, which kills certain seagrasses. Nutrients such as nitrogen and phosphorus contained in human and industrial waste promote the growth of tiny phytoplankton. This over-enrichment of the sea can ultimately lead to the collapse of the entire system through oxygen starvation.\n\nMost marine ecosystems have an in-built capacity to deal with a certain amount of pollution because shellfish can absorb phytoplankton. But in many cases, these have been largely removed by fishing, so the effect of any nutrient-rich pollutants entering the system is increased. In a healthy system, coastal wetlands also act as filters, so their destruction causes even more pollution. These processes have been fairly well understood for a number of years.\n\nE What the Science paper has demonstrated, however, is that the decline in the health of ecosystems is greater where the number of different species is low. The population of marbled rock cod around the South Atlantic island of South Georgia, for example, still hasn’t recovered after the fishing industry caused its collapse during the 1970s. By contrast, North Sea cod has withstood very heavy fishing for hundreds of years, says Worm, and although it has declined substantially, it hasn’t yet collapsed completely. Worm believes that, ‘to have a greater number of species makes an ecosystem more robust’. His theory is backed up by evidence from experiments into how ecosystems react to change.\n\nF And some positive news came from the study. Worm and his colleagues were able to show that it’s possible to reverse such damage as long as there are enough species. A survey of 44 protected areas revealed increases in biodiversity and fish catches close to the reserves. Worm says, ‘We should be focusing our attention on protecting all of our marine resources at the ecosystem level, and managing levels of fishing, pollution and habitat disturbance to ensure that crucial services that maintain the health of the ecosystem continue to function.’ To anyone who knows anything about ecology, it would appear that Worm is just stating the obvious. And many protected areas on land are now managed in this way.\n\nG However, there has long been a tendency to view our oceans as a limitless resource, combined with a widespread failure to make an emotional connection with most marine wildlife. True, we have created a small number of marine protected areas. ''We seem to have understood the value of protecting ecosystems in areas such as the Australian Great Barrier Reef that we consider to be particularly beautiful'' says John Shepherd, Professor of Marine Sciences at Southampton University in the UK. ‘Human nature will always draw us towards those species or habitats that are more aesthetically pleasing. That’s why there will always be support for protecting pandas and very little for worms, even though nematodes play a vital role in maintaining the health of an ecosystem.’'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    28,
    'MATCHING_HEADING',
    'READING',
    2,
    '28. Section A',
    'Choose the correct answer.',
    '{"28.-section-a-q28": ["vi", "vi. Who is currently being blamed"]}'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'i. Plans for more marine protected areas', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'ii. A historical overview of one specific area', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'iii. Why more has not been done to save marine creatures', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'iv. What the press has missed', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, 'v. Where biodiversity has been shown to help', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 6, 'vi. Who is currently being blamed', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 7, 'vii. A reason for some optimism', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 8, 'viii. Various factors other than fishing', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    29,
    'MATCHING_HEADING',
    'READING',
    2,
    '29. Section B',
    'Choose the correct answer.',
    '{"29.-section-b-q29": ["iv", "iv. What the press has missed"]}'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'i. Plans for more marine protected areas', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'ii. A historical overview of one specific area', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'iii. Why more has not been done to save marine creatures', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'iv. What the press has missed', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, 'v. Where biodiversity has been shown to help', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 6, 'vi. Who is currently being blamed', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 7, 'vii. A reason for some optimism', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 8, 'viii. Various factors other than fishing', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    30,
    'MATCHING_HEADING',
    'READING',
    2,
    '30. Section C',
    'Choose the correct answer.',
    '{"30.-section-c-q30": ["ii", "ii. A historical overview of one specific area"]}'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'i. Plans for more marine protected areas', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'ii. A historical overview of one specific area', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'iii. Why more has not been done to save marine creatures', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'iv. What the press has missed', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, 'v. Where biodiversity has been shown to help', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 6, 'vi. Who is currently being blamed', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 7, 'vii. A reason for some optimism', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 8, 'viii. Various factors other than fishing', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    31,
    'MATCHING_HEADING',
    'READING',
    2,
    '31. Section D',
    'Choose the correct answer.',
    '{"31.-section-d-q31": ["viii", "viii. Various factors other than fishing"]}'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'i. Plans for more marine protected areas', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'ii. A historical overview of one specific area', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'iii. Why more has not been done to save marine creatures', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'iv. What the press has missed', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, 'v. Where biodiversity has been shown to help', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 6, 'vi. Who is currently being blamed', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 7, 'vii. A reason for some optimism', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 8, 'viii. Various factors other than fishing', true);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    32,
    'MATCHING_HEADING',
    'READING',
    2,
    '32. Section E',
    'Choose the correct answer.',
    '{"32.-section-e-q32": ["v", "v. Where biodiversity has been shown to help"]}'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'i. Plans for more marine protected areas', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'ii. A historical overview of one specific area', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'iii. Why more has not been done to save marine creatures', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'iv. What the press has missed', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, 'v. Where biodiversity has been shown to help', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 6, 'vi. Who is currently being blamed', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 7, 'vii. A reason for some optimism', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 8, 'viii. Various factors other than fishing', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    33,
    'MATCHING_HEADING',
    'READING',
    2,
    '33. Section F',
    'Choose the correct answer.',
    '{"33.-section-f-q33": ["vii", "vii. A reason for some optimism"]}'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'i. Plans for more marine protected areas', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'ii. A historical overview of one specific area', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'iii. Why more has not been done to save marine creatures', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'iv. What the press has missed', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, 'v. Where biodiversity has been shown to help', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 6, 'vi. Who is currently being blamed', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 7, 'vii. A reason for some optimism', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 8, 'viii. Various factors other than fishing', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    34,
    'MATCHING_HEADING',
    'READING',
    2,
    '34. Section G',
    'Choose the correct answer.',
    '{"34.-section-g-q34": ["iii", "iii. Why more has not been done to save marine creatures"]}'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'i. Plans for more marine protected areas', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'ii. A historical overview of one specific area', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'iii. Why more has not been done to save marine creatures', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'iv. What the press has missed', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, 'v. Where biodiversity has been shown to help', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 6, 'vi. Who is currently being blamed', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 7, 'vii. A reason for some optimism', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 8, 'viii. Various factors other than fishing', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    35,
    'MULTIPLE_CHOICE_SINGLE',
    'READING',
    2,
    '35. Boris Worm’s main concern is that A. marine ecosystems will completely break down. B. insufficient attention is being paid to fish numbers. C. there will no longer be enough seafood for people to eat. D. politicians will be unwilling to discuss marine resources.',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. marine ecosystems will completely break down.', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. insufficient attention is being paid to fish numbers.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. there will no longer be enough seafood for people to eat.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D. politicians will be unwilling to discuss marine resources.', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    36,
    'MULTIPLE_CHOICE_SINGLE',
    'READING',
    2,
    '36. What point does John Shepherd make? A. Marine conservation areas are not high on the list of visitor attractions. B. People know very little about how different species actually live. C. The public are much less likely to help unattractive creatures D. The marine environment was better understood in the past.',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. Marine conservation areas are not high on the list of visitor attractions.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. People know very little about how different species actually live.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. The public are much less likely to help unattractive creatures', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D. The marine environment was better understood in the past.', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    37,
    'MULTIPLE_CHOICE_SINGLE',
    'READING',
    2,
    '37. Which of the following best summarises the text as a whole? A. Scientists disagree about the state of the world’s oceans. B. A radical review of marine resource management is needed. C. The fishing industry is mainly responsible for today’s problems. D. The natural systems of our seas will not be able to repair themselves.',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. Scientists disagree about the state of the world’s oceans.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. A radical review of marine resource management is needed.', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. The fishing industry is mainly responsible for today’s problems.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D. The natural systems of our seas will not be able to repair themselves.', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    38,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    '_______ slowly contracting.',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q38": ["GLACIERS"]}'::jsonb
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
    '_______ living on the wetlands along the shore.',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q39": ["BIRDS"]}'::jsonb
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
    '_______ which is essential for their survival.',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q40": ["OXYGEN"]}'::jsonb
  );


END$$;


COMMIT;