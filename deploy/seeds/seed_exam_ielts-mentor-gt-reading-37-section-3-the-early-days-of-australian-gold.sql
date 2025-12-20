-- ============================================
-- IELTS Exam Data Import SQL
-- Generated: 2025-12-20T21:58:31.568950
-- Source: ielts-mentor.com
-- Title: GT Reading 37 Section 3 - The Early Days of Australian Gold
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data for slug: ielts-mentor-gt-reading-37-section-3-the-early-days-of-australian-gold
DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-mentor-gt-reading-37-section-3-the-early-days-of-australian-gold'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-mentor-gt-reading-37-section-3-the-early-days-of-australian-gold';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-mentor-gt-reading-37-section-3-the-early-days-of-australian-gold';
DELETE FROM exams
WHERE "Slug" = 'ielts-mentor-gt-reading-37-section-3-the-early-days-of-australian-gold';

DO $$
DECLARE
  exam_id uuid := gen_random_uuid();
  sec1 uuid := gen_random_uuid();
  qid uuid;
BEGIN

  INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","UpdatedAt")
  VALUES (
    exam_id,
    'ielts-mentor-gt-reading-37-section-3-the-early-days-of-australian-gold',
    'GT Reading 37 Section 3 - The Early Days of Australian Gold',
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
    'Reading Passage - GT Reading 37 Section 3 - The Early Days of Australian Gold',
    E'# Passage\n\n# The Early Days of Australian Gold\n\nAlthough gold had been rumoured to have been found in Australia as early as 1814, the first gold fields did not appear until forty years later. Gold discoveries were not considered blessings in the pre-1850’s Australian convict society, as the authorities believed gold fever could potentially cause anarchy in the small fledgling British colonies. Most finds were kept very quiet, as most finders soon found themselves accused of theft and punished violently for their trouble. Because the society was predominantly criminals and convicts, this story was easier to believe than the idea that these people were just picking it up in the bush. However, many of these people were hushed up and punished for another reason. Farmers, wealthy landowners and the authorities were afraid that if word got around that gold had been found, then many of their lowly paid workers and labourers would leave their jobs. This all ended when the California gold rush began to really heat up. Workers from all over the world migrated to the United States to strike it rich. Australia was no exception and when this labour drain began to impact the local economy, Australia’s governors began to look at gold differently. Gold in Australia was first ‘officially’ discovered in1851 by one Edward Hargraves. Hargraves had just returned empty-handed from the already under-way Californian Gold Rush and had a theory that the Australian and Californian terrains had various similarities. Hargraves travelled West of Sydney towards the Bathurst Plains and it was here that the first publicized gold was found. This area would become Australia’s earliest goldfield. The government officially declared the gold discovery on the 22nd of May 1851 and thousands flocked to the Bathurst plains. The first gold rush was well and truly on in New South Wales, but far more was yet to come. The Victorian Authorities in Melbourne grew anxious, as many of their population made their way north towards Bathurst to try their luck. As labour started to become scarcer, Governor La Trobe offered a £200 reward for any gold found within a 200 mile radius of Melbourne in an attempt to attract people to Melbourne. Soon after, gold was found at Warrandyte, now a suburb of Melbourne. This started an early mini gold rush. But these finds were not large enough to spark a state-wide gold frenzy. Rich gold fields were on the horizon, however. Ones that would change the new colony of Victoria forever. These gigantic finds were at what is now recognised as part of the State of Victoria’s Golden Triangle. A blacksmith discovered gold a few kilometres north of Ballarat, a small farming village west of Melbourne. This was to be one of the richest gold fields the world has ever seen. 10,000 miners arrived in less than a year and turned this once sleepy region into Victoria’s largest settlement. Miners and prospectors who were originally heading to Bathurst now turned towards Ballarat instead. The massive influx of immigrants was more than the fledgling colonies of New South Wales and Victoria could handle. Room soon became scarce, as lodging houses and hotels were quickly filled. Faced with the ongoing wave of immigrants arriving in ships almost daily, new measures had to be taken to provide some kind of accommodation for the new arrivals. `Canvas towns’ began to spring up in the south of Melbourne. New arrivals to Victoria were given a rough canvas tent and these were set up in rows, forming `streets’. The occupants of the canvas towns named the streets that were formed, mostly after prestigious English streets such as Bond Street, Regent Street and so on. The existence of these small canvas settlements was legalized by Governor LaTrobe in 1852, when he imposed a weekly rent of five shillings per tent. From a fledgling penal settlement, the gold rush and ensuing waves of immigration changed the face of the nation. Before 1851, Australia’s combined immigrant population was approximately 77,000. Most of those had been convicts sent by ship over the previous seventy years. The gold rush completely changed that. It suddenly seemed like a foolish idea, and indeed no longer a punishment, to give a free boat ride to Australia’s rich gold fields to anyone who had committed a crime. The arrival of skilled workers and tradesmen provided a boost to the economy as new facilities were made available. The colonies witnessed widespread progress in many areas of industry, particularly in manufacturing, as factories were gradually established and opened. The presence of so many migrants from different countries created tensions between different groups. Policies were established to limit the number of non-English-speaking migrants from entering Australia. These policies had their roots in the convict era, when the divisions between free men and newly emancipated convicts were sharply drawn. This social division developed into a cultural divide when migrants from non-English speaking backgrounds arrived in Australia. These cultural conflicts persisted for many years, and were the cause of longstanding tensions between different groups. The government’s immigration policies formed during the time of the gold rushes were rigorously enforced and persisted until not long ago.\n\nGold may be discovered in the year (28) ...............; major diggings started in 1844. Gold discoveries not liked, because of establishment worries of (29) ............... developing in colonies worries over labour leaving work to search for gold. Workers left anyway because of the (30) ................ Gold officially found in 1851 by Edward Hargraves on the (31) ............... - became Australia’s first goldfield. The discovery attracted thousands of people. Melbourne government offered a cash (32) ............... for finding gold near Melbourne to attract people there. Gold soon found, and some of the world’s biggest deposits found north of Melbourne. Many miners came to the town of (33) ............... to seek riches. Australian residential capacity was overloaded, so immigrant miners were housed under (34) ............... for a small cost. The Australian gold rush changed the country’s demographics from largely convict. Transportation as a punishment stopped. The new and more (35) ............... population that arrived in Australia stimulated the (36) ............... and industry developed. Old social division tensions from the convict era continued between English speakers and nonspeakers. The official (37) ............... continued until relatively recently.'
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
    'Section 28',
    'Choose the correct answer.',
    '{"section-28-q28": ["1814", "1814"]}'
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
    'Complete the blank. _______ Question 29',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q29": ["anarchy"]}'::jsonb
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
    'Complete the blank. _______ Question 30',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q30": ["California gold rush"]}'::jsonb
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
    'Complete the blank. _______ Question 31',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q31": ["Bathurst Plains"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    32,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    'Complete the blank. _______ Question 32',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q32": ["reward"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    33,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    'Complete the blank. _______ Question 33',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q33": ["Ballarat"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    34,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    'Complete the blank. _______ Question 34',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q34": ["Canvas", "", "canvas towns"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    35,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    'Complete the blank. _______ Question 35',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q35": ["skilled"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    36,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    'Complete the blank. _______ Question 36',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q36": ["economy"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    37,
    'SHORT_ANSWER',
    'READING',
    2,
    'Complete the summary using words from the passage.',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q37": ["(immigration) policies"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    38,
    'MULTIPLE_CHOICE_SINGLE',
    'READING',
    2,
    'Why did Australian convicts who first found gold often not tell anyone?',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. They were scared it would be taken from them.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. They had other jobs they wanted to keep.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. They were scared they would be accused of stealing it.', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D. They did not want other people to come and take their potential riches.', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    39,
    'MULTIPLE_CHOICE_SINGLE',
    'READING',
    2,
    'Why did Hargraves feel that he could find gold on the Bathurst Plains?',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. A miner in California told Hargraves that he had seen gold on the Bathurst Plains.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. Hargraves believed that California and the Bathurst Plains ground conditions were alike.', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. Hargraves was convinced by the bonus offered for finding gold on the Bathurst Plains.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D. News had been announced that gold could be found in the Bathurst Plains area.', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    40,
    'MULTIPLE_CHOICE_SINGLE',
    'READING',
    2,
    'When did the temporary shelters for Ballarat miners become officially acknowledged?',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. When the miners began to pay taxes.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. When too many miners got arrested.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. After public demonstrations forced the political administration.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D. When the miners officially paid for their accommodation.', true);


END$$;


COMMIT;