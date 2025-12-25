-- ============================================
-- IELTS Exam Data Import SQL
-- Generated: 2025-12-25T14:37:50.349623
-- Source: ielts-mentor.com
-- Title: Reading Test 119: Passage 2 - Driverless Cars
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data for slug: ielts-mentor-reading-test-119-passage-2-driverless-cars
DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-mentor-reading-test-119-passage-2-driverless-cars'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-mentor-reading-test-119-passage-2-driverless-cars';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-mentor-reading-test-119-passage-2-driverless-cars';
DELETE FROM exams
WHERE "Slug" = 'ielts-mentor-reading-test-119-passage-2-driverless-cars';

DO $$
DECLARE
  exam_id uuid := gen_random_uuid();
  sec1 uuid := gen_random_uuid();
  qid uuid;
BEGIN

  INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","ImageUrl","UpdatedAt")
  VALUES (
    exam_id,
    'ielts-mentor-reading-test-119-passage-2-driverless-cars',
    'Reading Test 119: Passage 2 - Driverless Cars',
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
    'Reading Passage - Reading Test 119: Passage 2 - Driverless Cars',
    E'## Questions 14-18\n\nThe reading passage has seven sections, **A-G**.\n\nWhich section contains the following information?\n\nWrite the correct letter, **A-G**, in boxes 14-18 on your answer sheet.\n\n**14.** reference to the amount of time when a car is not in use\n\n**15.** mention of several advantages of driverless vehicles for individual road-users\n\n**16.** reference to the opportunity of choosing the most appropriate vehicle for each trip\n\n**17.** an estimate of how long it will take to overcome a number of problems\n\n**18.** a suggestion that the use of driverless cars may have no effect on the number of vehicles manufactured\n\n---\n\n## Questions 19-22\n\nComplete the summary below.\n\nChoose **NO MORE THAN TWO WORDS** from the passage for each answer.\n\n### The impact of driverless cars\n\nFigures from the Transport Research Laboratory indicate that most motor accidents are partly due to **19** _______, so the introduction of driverless vehicles will result in greater safety. In addition to the direct benefits of automation, it may bring other advantages. For example, schemes for **20** _______ will be more workable, especially in towns and cities, resulting in fewer cars on the road.\n\nAccording to the University of Michigan Transportation Research Institute, there could be a 43 percent drop in **21** _______ of cars. However, this would mean that the yearly **22** _______ of each car would, on average, be twice as high as it currently is. This would lead to a higher turnover of vehicles, and therefore no reduction in automotive manufacturing.\n\n---\n\n## Questions 23-24\n\nChoose **TWO** letters, **A-E**.\n\nWhich **TWO** benefits of automated vehicles does the writer mention?\n\n**A.** Car travellers could enjoy considerable cost savings.\n**B.** It would be easier to find parking spaces in urban areas.\n**C.** Travellers could spend journeys doing something other than driving.\n**D.** People who find driving physically difficult could travel independently.\n**E.** A reduction in the number of cars would mean a reduction in pollution.\n\n---\n\n## Questions 25-26\n\nChoose **TWO** letters, **A-E**.\n\nWhich **TWO** challenges to automated vehicle development does the writer mention?\n\n**A.** making sure the general public has confidence in automated vehicles\n**B.** managing the pace of transition from conventional to automated vehicles\n**C.** deciding how to compensate professional drivers who become redundant\n**D.** setting up the infrastructure to make roads suitable for automated vehicles\n**E.** getting automated vehicles to adapt to various different driving conditions',
    E'**Paragraph A.**\\n# Reading Test 119: Passage 2 - Driverless Cars & Driverless cars\n\nA. The automotive sector is well used to adapting to automation in manufacturing. The implementation of robotic car manufacture from the 1970s onwards led to significant cost savings and improvements in the reliability and flexibility of vehicle mass production. A new challenge to vehicle production is now on the horizon and, again, it comes from automation. However, this time it is not to do with the manufacturing process, but with the vehicles themselves.\n\nResearch projects on vehicle automation are not new. Vehicles with limited self-driving capabilities have been around for more than 50 years, resulting in significant contributions towards driver assistance systems. But since Google announced in 2010 that it had been trialling self-driving cars on the streets of California, progress in this field has quickly gathered pace.\n\nB. There are many reasons why technology is advancing so fast. One frequently cited motive is safety; indeed, research at the UK’s Transport Research Laboratory has demonstrated that more than 90 percent of road collisions involve human error as a contributory factor, and it is the primary cause in the vast majority. Automation may help to reduce the incidence of this.\n\nAnother aim is to free the time people spend driving for other purposes. If the vehicle can do some or all of the driving, it may be possible to be productive, to socialise or simply to relax while automation systems have responsibility for safe control of the vehicle. If the vehicle can do the driving, those who are challenged by existing mobility models – such as older or disabled travellers – may be able to enjoy significantly greater travel autonomy.\n\nC. Beyond these direct benefits, we can consider the wider implications for transport and society, and how manufacturing processes might need to respond as a result. At present, the average car spends more than 90 percent of its life parked. Automation means that initiatives for car-sharing become much more viable, particularly in urban areas with significant travel demand. If a significant proportion of the population choose to use shared automated vehicles, mobility demand can be met by far fewer vehicles.\n\nD. The Massachusetts Institute of Technology investigated automated mobility in Singapore, finding that fewer than 30 percent of the vehicles currently used would be required if fully automated car sharing could be implemented. If this is the case, it might mean that we need to manufacture far fewer vehicles to meet demand. However, the number of trips being taken would probably increase, partly because empty vehicles would have to be moved from one customer to the next.\n\nModelling work by the University of Michigan Transportation Research Institute suggests automated vehicles might reduce vehicle ownership by 43 percent, but that vehicles’ average annual mileage double as a result. As a consequence, each vehicle would be used more intensively, and might need replacing sooner. This faster rate of turnover may mean that vehicle production will not necessarily decrease.\n\nE. Automation may prompt other changes in vehicle manufacture. If we move to a model where consumers are tending not to own a single vehicle but to purchase access to a range of vehicle through a mobility provider, drivers will have the freedom to select one that best suits their needs for a particular journey, rather than making a compromise across all their requirements.\n\nSince, for most of the time, most of the seats in most cars are unoccupied, this may boost production of a smaller, more efficient range of vehicles that suit the needs of individuals. Specialised vehicles may then be available for exceptional journeys, such as going on a family camping trip or helping a son or daughter move to university.\n\nF. There are a number of hurdles to overcome in delivering automated vehicles to our roads. These include the technical difficulties in ensuring that the vehicle works reliably in the infinite range of traffic, weather and road situations it might encounter; the regulatory challenges in understanding how liability and enforcement might change when drivers are no longer essential for vehicle operation; and the societal changes that may be required for communities to trust and accept automated vehicles as being a valuable part of the mobility landscape.\n\nG. It’s clear that there are many challenges that need to be addressed but, through robust and targeted research, these can most probably be conquered within the next 10 years. Mobility will change in such potentially significant ways and in association with so many other technological developments, such as telepresence and virtual reality, that it is hard to make concrete predictions about the future. However, one thing is certain: change is coming, and the need to be flexible in response to this will be vital for those involved in manufacturing the vehicles that will deliver future mobility.\n\n14. reference to the amount of time when a car is not in use. 15. mention of several advantages of driverless vehicles for individual road-users. 16. reference to the opportunity of choosing the most appropriate vehicle for each trip. 17. an estimate of how long it will take to overcome a number of problems 18. a suggestion that the use of driverless cars may have no effect on the number of vehicles manufactured.\n\nFigures from the Transport Research Laboratory indicate that most motor accidents are partly due to 19 ..................., so the introduction of driverless vehicles will result in greater safety. In addition to the direct benefits of automation, it may bring other advantages. For example, schemes for 20 ................... will be more workable, especially in towns and cities, resulting in fewer cars on the road.\n\nAccording to the University of Michigan Transportation Research Institute, there could be a 43 percent drop in 21 ................... of cars. However, this would mean that the yearly 22 ...................of each car would, on average, be twice as high as it currently is. This would lead to a higher turnover of vehicles, and therefore no reduction in automotive manufacturing.\n\nA. Car travellers could enjoy considerable cost savings. B. It would be easier to find parking spaces in urban areas. C. Travellers could spend journeys doing something other than driving. D. People who find driving physically difficult could travel independently. E. A reduction in the number of cars would mean a reduction in pollution.\n\nA. making sure the general public has confidence in automated vehicles B. managing the pace of transition from conventional to automated vehicles C. deciding how to compensate professional drivers who become redundant D. setting up the infrastructure to make roads suitable for automated vehicles E. getting automated vehicles to adapt to various different driving conditions\\n\\n'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    14,
    'MATCHING_INFORMATION',
    'READING',
    2,
    'reference to the amount of time when a car is not in use',
    '',
    '{"info-q14": ["C", "c"]}'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    15,
    'MATCHING_INFORMATION',
    'READING',
    2,
    'mention of several advantages of driverless vehicles for individual road-users',
    '',
    '{"info-q15": ["B", "b"]}'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    16,
    'MATCHING_INFORMATION',
    'READING',
    2,
    'reference to the opportunity of choosing the most appropriate vehicle for each trip',
    '',
    '{"info-q16": ["E", "e"]}'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    17,
    'MATCHING_INFORMATION',
    'READING',
    2,
    'an estimate of how long it will take to overcome a number of problems',
    '',
    '{"info-q17": ["G", "g"]}'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    18,
    'MATCHING_INFORMATION',
    'READING',
    2,
    'a suggestion that the use of driverless cars may have no effect on the number of vehicles manufactured',
    '',
    '{"info-q18": ["D", "d"]}'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    19,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    'Figures from the Transport Research Laboratory indicate that most motor accidents are partly due to _______, so the introduction of driverless vehicles will result in greater safety.',
    '',
    '{"blank-q19": ["human error"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    20,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    'In addition to the direct benefits of automation, it may bring other advantages. For example, schemes for _______ will be more workable, especially in towns and cities, resulting in fewer cars on the road.',
    '',
    '{"blank-q20": ["car-sharing"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    21,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    'According to the University of Michigan Transportation Research Institute, there could be a 43 percent drop in _______ of cars.',
    '',
    '{"blank-q21": ["ownership"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    22,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    'However, this would mean that the yearly _______ of each car would, on average, be twice as high as it currently is.',
    '',
    '{"blank-q22": ["mileage"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    23,
    'MCQ_MULTIPLE',
    'READING',
    2,
    'Which TWO benefits of automated vehicles does the writer mention?',
    '',
    '{"blank-q23": ["C", "c"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    24,
    'MCQ_MULTIPLE',
    'READING',
    2,
    'Which TWO benefits of automated vehicles does the writer mention?',
    '',
    '{"blank-q24": ["D", "d"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    25,
    'MCQ_MULTIPLE',
    'READING',
    2,
    'Which TWO challenges to automated vehicle development does the writer mention?',
    '',
    '{"blank-q25": ["A", "a"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    26,
    'MCQ_MULTIPLE',
    'READING',
    2,
    'Which TWO challenges to automated vehicle development does the writer mention?',
    '',
    '{"blank-q26": ["E", "e"]}'::jsonb
  );



  -- Delete old question groups for this exam
  DELETE FROM exam_question_groups WHERE "SectionId" = sec1;

  -- Insert question groups
  INSERT INTO exam_question_groups ("Id","SectionId","Idx","StartIdx","EndIdx","InstructionMd")
  VALUES (gen_random_uuid(), sec1, 1, 14, 18, E'## Questions 14-18\n\nThe reading passage has seven sections, **A-G**.\n\nWhich section contains the following information?\n\nWrite the correct letter, **A-G**, in boxes 14-18 on your answer sheet.\n\n**14.** reference to the amount of time when a car is not in use\n\n**15.** mention of several advantages of driverless vehicles for individual road-users\n\n**16.** reference to the opportunity of choosing the most appropriate vehicle for each trip\n\n**17.** an estimate of how long it will take to overcome a number of problems\n\n**18.** a suggestion that the use of driverless cars may have no effect on the number of vehicles manufactured');

  INSERT INTO exam_question_groups ("Id","SectionId","Idx","StartIdx","EndIdx","InstructionMd")
  VALUES (gen_random_uuid(), sec1, 2, 19, 22, E'## Questions 19-22\n\nComplete the summary below.\n\nChoose **NO MORE THAN TWO WORDS** from the passage for each answer.\n\n### The impact of driverless cars\n\nFigures from the Transport Research Laboratory indicate that most motor accidents are partly due to **19** _______, so the introduction of driverless vehicles will result in greater safety. In addition to the direct benefits of automation, it may bring other advantages. For example, schemes for **20** _______ will be more workable, especially in towns and cities, resulting in fewer cars on the road.\n\nAccording to the University of Michigan Transportation Research Institute, there could be a 43 percent drop in **21** _______ of cars. However, this would mean that the yearly **22** _______ of each car would, on average, be twice as high as it currently is. This would lead to a higher turnover of vehicles, and therefore no reduction in automotive manufacturing.');

  INSERT INTO exam_question_groups ("Id","SectionId","Idx","StartIdx","EndIdx","InstructionMd")
  VALUES (gen_random_uuid(), sec1, 3, 23, 24, E'## Questions 23-24\n\nChoose **TWO** letters, **A-E**.\n\nWhich **TWO** benefits of automated vehicles does the writer mention?\n\n**A.** Car travellers could enjoy considerable cost savings.\n**B.** It would be easier to find parking spaces in urban areas.\n**C.** Travellers could spend journeys doing something other than driving.\n**D.** People who find driving physically difficult could travel independently.\n**E.** A reduction in the number of cars would mean a reduction in pollution.');

  INSERT INTO exam_question_groups ("Id","SectionId","Idx","StartIdx","EndIdx","InstructionMd")
  VALUES (gen_random_uuid(), sec1, 4, 25, 26, E'## Questions 25-26\n\nChoose **TWO** letters, **A-E**.\n\nWhich **TWO** challenges to automated vehicle development does the writer mention?\n\n**A.** making sure the general public has confidence in automated vehicles\n**B.** managing the pace of transition from conventional to automated vehicles\n**C.** deciding how to compensate professional drivers who become redundant\n**D.** setting up the infrastructure to make roads suitable for automated vehicles\n**E.** getting automated vehicles to adapt to various different driving conditions');

END$$;


COMMIT;