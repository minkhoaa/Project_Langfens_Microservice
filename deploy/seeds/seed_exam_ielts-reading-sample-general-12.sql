-- ============================================
-- IELTS Exam Data Import SQL
-- Generated: 2025-12-19T15:25:29.533848
-- Source: ielts-writing.info
-- Title: IELTS Reading Sample (General) #12
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data for slug: ielts-reading-ielts-reading-sample-general-12
DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-ielts-reading-sample-general-12'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-ielts-reading-sample-general-12';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-ielts-reading-sample-general-12';
DELETE FROM exams
WHERE "Slug" = 'ielts-reading-ielts-reading-sample-general-12';

DO $$
DECLARE
  exam_id uuid := gen_random_uuid();
  sec1 uuid := gen_random_uuid();
  qid uuid;
BEGIN

  INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","UpdatedAt")
  VALUES (
    exam_id,
    'ielts-reading-ielts-reading-sample-general-12',
    'IELTS Reading Sample (General) #12',
    'IELTS Reading Practice Test: IELTS Reading Sample (General) #12',
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
    'Reading Passage - IELTS Reading Sample (General) #12',
    E'# Passage\n\n×\nIELTS Reading General 22\nThe Future of fish\nThe face of the ocean has changed completely since the first commercial fishers cast their nets and hooks over a thousand years ago. Fisheries intensified over the centuries, but even by the nineteenth century it was still felt, justifiably, that the plentiful resources of the sea were for the most part beyond the reach of fishing, and so there was little need to restrict fishing or create protected areas. The twentieth century heralded an escalation in fishing intensity that is unprecedented in the history of the oceans, and modern fishing technologies leave fish no place to hide. Today, the only refuges from fishing are those we deliberately create. Unhappily, the sea trails far behind the land in terms of the area and the quality of protection given.\nFor centuries, as fishing and commerce have expanded, we have held onto the notion that the sea is different from the land. We still view it as a place where people and nations should be free to come and go at will, as well as somewhere that should be free for us to exploit. Perhaps this is why we have been so reluctant to protect the sea. On land, protected areas have proliferated as human populations have grown. Here, compared to the sea, we have made greater headway in our struggle to maintain the richness and variety of wildlife and landscape. Twelve percent of the world’s land is now contained in protected areas, whereas the corresponding figure for the sea is but three-fifths of one percent. Worse still, most marine protected areas allow some fishing to continue. Areas off-limits to all exploitation cover something like one five-thousandth of the total area of the world’s seas.\nToday, we are belatedly coming to realise that ‘natural refuges’ from fishing have played a critical role in sustaining fisheries, and maintaining healthy and diverse marine ecosystems. This does not mean that marine reserves can rebuild fisheries on their own – other management measures are also required for that. However, places that are off-limits to fishing constitute the last and most important part of our package of reform for fisheries management. They underpin and enhance all our other efforts. There are limits to protection though.\nReserves cannot bring back what has died out. We can never resurrect globally extinct species, and restoring locally extinct animals may require reintroductions from elsewhere, if natural dispersal from remaining populations is insufficient. We are also seeing, in cases such as northern cod in Canada, that fishing can shift marine ecosystems into different states, where different mixes of species prevail. In many cases, these species are less desirable, since the prime fishing targets have gone or are much reduced in numbers, and changes may be difficult to reverse, even with a complete moratorium on fishing. The Mediterranean sailed by Ulysses, the legendary king of ancient Greece, supported abundant monk seals, loggerhead turtles and porpoises. Their disappearance through hunting and overfishing has totally restructured food webs, and recovery is likely to be much harder to achieve than their destruction was. This means that the sooner we act to protect marine life, the more certain will be our success.\nTo some people, creating marine reserves is an admission of failure. According to their logic, reserves should not be necessary if we have done our work properly in managing the uses we make of the sea. Many fisheries managers are still wedded to the idea that one day their models will work, and politicians will listen to their advice. Just give the approach time, and success will be theirs. How much time have we got? This approach has been tried and refined for the last 50 years. There have been few successes which to feather the managers’ caps, but a growing litany of failure. The Common Fisheries Policy, the European Union’s instrument for the management of fisheries and aquaculture, exemplifies the worst pitfalls: flawed models, flawed advice, watered-down recommendations from government bureaucrats and then the disregard of much of this advice by politicians. When it all went wrong, as it inevitably had to, Europe sent its boats to other countries in order to obtain fish for far less than they were actually worth.\nWe are squandering the wealth of oceans. If we don’t break out of this cycle of failure, humanity will lose a key source of protein, and much more besides. Disrupting natural ecosystem processes, such as water purification, nutrient cycling, and carbon storage, could have ramifications for human life itself. We can go a long way to avoiding this catastrophic mistake with simple common-sense management. Marine reserves lie at the heart of the reform. But they will not be sufficient if they are implemented only here and there to shore up the crumbling edifice of the ‘rational fisheries management’ envisioned by scientists in the 1940s and 1950s. They have to be placed centre stage as a fundamental underpinning for everything we do in the oceans. Reserves are a first resort, not a final resort when all else fails.\nSHARE THIS PAGE\nCONTACT US\nIELTS QUESTIONS\nLIFE IN THE UK TEST\nThe reading, writing and listening practice tests on this website have been designed to resemble the format of the IELTS test as closely as possible. They are not, however, real IELTS tests; they are designed to practise exam technique to help students to face the IELTS test with confidence and to perform to the best of their ability.\nWhile using this site, you agree to have read and accepted our terms of use, cookie and privacy policy.\nDear readers,\nThis is to inform you that we have moved to a new domain,\nhttps://www.ielts-writing.info/EXAM/\n.\nOur old domain, https://www.ielts-exam.net/ will remain active till the time we migrate all our content to the new domain.\nWe look forward to your continuing support.\nOK, I understand'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
  VALUES (
    qid,
    sec1,
    1,
    'YES_NO_NOT_GIVEN',
    'READING',
    2,
    'It is more than a thousand years since people started to catch fish for commercial use.',
    'Choose the correct answer.'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'YES', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'NO', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'NOT GIVEN', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
  VALUES (
    qid,
    sec1,
    2,
    'YES_NO_NOT_GIVEN',
    'READING',
    2,
    'In general, open access to the oceans is still regarded as desirable.',
    'Choose the correct answer.'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'YES', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'NO', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'NOT GIVEN', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
  VALUES (
    qid,
    sec1,
    3,
    'YES_NO_NOT_GIVEN',
    'READING',
    2,
    'Sea fishing is now completely banned in the majority of protected areas.',
    'Choose the correct answer.'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'YES', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'NO', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'NOT GIVEN', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
  VALUES (
    qid,
    sec1,
    4,
    'YES_NO_NOT_GIVEN',
    'READING',
    2,
    'People should be encouraged to reduce the amount of fish they eat.',
    'Choose the correct answer.'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'YES', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'NO', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'NOT GIVEN', true);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
  VALUES (
    qid,
    sec1,
    5,
    'YES_NO_NOT_GIVEN',
    'READING',
    2,
    'The re-introduction of certain mammals to the Mediterranean is a straightforward task.',
    'Choose the correct answer.'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'YES', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'NO', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'NOT GIVEN', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
  VALUES (
    qid,
    sec1,
    6,
    'MULTIPLE_CHOICE_SINGLE',
    'READING',
    2,
    'Write your answres in boxes 6-8 on your answer sheet.',
    'Choose the correct answer.'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. Fisheries policies are currently based on uncertain estimates.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. Accurate predictions will allow governments to plan properly.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. Fisheries managers should provide clearer information.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D. Action to protect fish stocks is urgently needed.', true);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
  VALUES (
    qid,
    sec1,
    7,
    'MULTIPLE_CHOICE_SINGLE',
    'READING',
    2,
    'Write your answres in boxes 6-8 on your answer sheet.',
    'Choose the correct answer.'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. Measures that it advocated were hastily implemented.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. Officials exaggerated some of its recommendations.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. It was based on predictions which were inaccurate.', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D. The policy makers acquired a good reputation.', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
  VALUES (
    qid,
    sec1,
    8,
    'MULTIPLE_CHOICE_SINGLE',
    'READING',
    2,
    'Write your answres in boxes 6-8 on your answer sheet.',
    'Choose the correct answer.'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. The means of avoiding the worst outcomes needs to be prioritised.', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. Measures already taken to avoid a crisis are probably sufficient.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. The situation is now so severe that there is no likely solution.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D. It is no longer clear which measures would be most effective.', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    9,
    'MATCHING_INFORMATION',
    'READING',
    2,
    '**Q9** - Fill in blank ___[9]:\n\nUp till the twentieth century the world’s supply of fish was sufficient for its needs. It was unnecessary to introduce ___[9] of any kind, because large areas of the oceans were inaccessible.\n\n**Word List:**\nA. action\nB. controls\nC. failure\nD. fish catches\nE. fish processing\nF. fishing techniques\nG. large boats\nH. marine reserves\nI. the land\nJ. the past',
    'Complete the blank with words from the passage.',
    '{"blank-q9": ["B"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    10,
    'MATCHING_INFORMATION',
    'READING',
    2,
    '**Q10** - Fill in blank ___[10]:\n\nHowever, as ___[10] improved, this situation changed, and in the middle of the twentieth century, policies were introduced to regulate ___[11] . These policies have not succeeded. Today, by comparison with ___[12] , the oceans have very little legal protection.\n\n**Word List:**\nA. action\nB. controls\nC. failure\nD. fish catches\nE. fish processing\nF. fishing techniques\nG. large boats\nH. marine reserves\nI. the land\nJ. the past',
    'Complete the blank with words from the passage.',
    '{"blank-q10": ["F"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    11,
    'MATCHING_INFORMATION',
    'READING',
    2,
    '**Q11** - Fill in blank ___[11]:\n\nHowever, as ___[10] improved, this situation changed, and in the middle of the twentieth century, policies were introduced to regulate ___[11] . These policies have not succeeded. Today, by comparison with ___[12] , the oceans have very little legal protection.\n\n**Word List:**\nA. action\nB. controls\nC. failure\nD. fish catches\nE. fish processing\nF. fishing techniques\nG. large boats\nH. marine reserves\nI. the land\nJ. the past',
    'Complete the blank with words from the passage.',
    '{"blank-q11": ["D"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    12,
    'MATCHING_INFORMATION',
    'READING',
    2,
    '**Q12** - Fill in blank ___[12]:\n\nHowever, as ___[10] improved, this situation changed, and in the middle of the twentieth century, policies were introduced to regulate ___[11] . These policies have not succeeded. Today, by comparison with ___[12] , the oceans have very little legal protection.\n\n**Word List:**\nA. action\nB. controls\nC. failure\nD. fish catches\nE. fish processing\nF. fishing techniques\nG. large boats\nH. marine reserves\nI. the land\nJ. the past',
    'Complete the blank with words from the passage.',
    '{"blank-q12": ["I"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    13,
    'MATCHING_INFORMATION',
    'READING',
    2,
    '**Q13** - Fill in blank ___[13]:\n\nDespite the doubts that many officials have about the concept of ___[13] , these should be at the heart of any action taken. The consequences of further ___[14] are very serious, and may even affect our continuing existence.\n\n**Word List:**\nA. action\nB. controls\nC. failure\nD. fish catches\nE. fish processing\nF. fishing techniques\nG. large boats\nH. marine reserves\nI. the land\nJ. the past',
    'Complete the blank with words from the passage.',
    '{"blank-q13": ["H"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    14,
    'MATCHING_INFORMATION',
    'READING',
    2,
    '**Q14** - Fill in blank ___[14]:\n\nDespite the doubts that many officials have about the concept of ___[13] , these should be at the heart of any action taken. The consequences of further ___[14] are very serious, and may even affect our continuing existence.\n\n**Word List:**\nA. action\nB. controls\nC. failure\nD. fish catches\nE. fish processing\nF. fishing techniques\nG. large boats\nH. marine reserves\nI. the land\nJ. the past',
    'Complete the blank with words from the passage.',
    '{"blank-q14": ["C"]}'::jsonb
  );


END$$;


COMMIT;