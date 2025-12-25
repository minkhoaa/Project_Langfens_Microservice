-- ============================================
-- IELTS Full Test Import SQL (Multi-Section)
-- Generated: 2025-12-25T13:22:48.152315
-- Source: ielts-mentor.com
-- Title: IELTS Academic Reading Test 119
-- Sections: 3
-- Questions: 40
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data for slug: ielts-mentor-reading-full-test-119
DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-mentor-reading-full-test-119'
);
DELETE FROM exam_question_groups WHERE "SectionId" IN (
  SELECT s."Id" FROM exam_sections s
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-mentor-reading-full-test-119'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-mentor-reading-full-test-119';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-mentor-reading-full-test-119';
DELETE FROM exams WHERE "Slug" = 'ielts-mentor-reading-full-test-119';

DO $$
DECLARE
  exam_id uuid := gen_random_uuid();
  sec1 uuid := gen_random_uuid();
  sec2 uuid := gen_random_uuid();
  sec3 uuid := gen_random_uuid();
  qid uuid;
BEGIN

  INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","ImageUrl","UpdatedAt")
  VALUES (
    exam_id,
    'ielts-mentor-reading-full-test-119',
    'IELTS Academic Reading Test 119',
    'Full IELTS Academic Reading Test with 3 passages',
    'IELTS',
    'B2',
    'PUBLISHED',
    60,
    NULL,
    now()
  );

  -- Section 1
  INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","PassageMd")
  VALUES (
    sec1,
    exam_id,
    1,
    'Reading Test 119: Passage 1 - Nutmeg - a valuable spice',
    E'**Questions 1-13:**\nComplete the sentences below.\n\nWrite **NO MORE THAN TWO WORDS AND/OR A NUMBER** for each answer.\n\n---\n\n**Questions 5-7:**\nDo the following statements agree with the information given in the text?\n\nWrite\n- **TRUE** if the statement agrees with the information\n- **FALSE** if the statement contradicts the information\n- **NOT GIVEN** if there is no information on this',
    E'**Paragraph A.**\\n# Reading Test 119: Passage 1 - Nutmeg - a valuable spice & Nutmeg - a valuable spice\n\nThe nutmeg tree, Myristica fragrans, is a large evergreen tree native to Southeast Asia. Until the late 18th century, it only grew in one place in the world: a small group of islands in the Banda Sea, part of the Moluccas – or Spice Islands – in northeastern Indonesia. The tree is thickly branched with dense foliage of tough, dark green oval leaves, and produces small, yellow, bell-shaped flowers and pale yellow pear-shaped fruits. The fruit is encased in a flesh husk. When the fruit is ripe, this husk splits into two halves along a ridge running the length of the fruit. Inside is a purple-brown shiny seed, 2-3 cm long by about 2 cm across, surrounded by a lacy red or crimson covering called an ‘aril’. These are the sources of the two spices nutmeg and mace, the former being produced from the dried seed and the latter from the aril.\n\nNutmeg was a highly prized and costly ingredient in European cuisine in the Middle Ages, and was used as a flavouring, medicinal, and preservative agent. Throughout this period, the Arabs were the exclusive importers of the spice to Europe. They sold nutmeg for high prices to merchants based in Venice, but they never revealed the exact location of the source of this extremely valuable commodity. The Arab-Venetian dominance of the trade finally ended in 1512, when the Portuguese reached the Banda Islands and began exploiting its precious resources.\n\nAlways in danger of competition from neighbouring Spain, the Portuguese began subcontracting their spice distribution to Dutch traders. Profits began to flow into the Netherlands, and the Dutch commercial fleet swiftly grew into one of the largest in the world. The Dutch quietly gained control of most of the shipping and trading of spices in Northern Europe. Then, in 1580, Portugal fell under Spanish rule, and by the end of the 16th century the Dutch found themselves locked out of the market. As prices for pepper, nutmeg, and other spices soared across Europe, they decided to fight back.\n\nIn 1602, Dutch merchants founded the VOC, a trading corporation better known as the Dutch East India Company. By 1617, the VOC was the richest commercial operation in the world. The company had 50,000 employees worldwide, with a private army of 30,000 men and a fleet of 200 ships. At the same time, thousands of people across Europe were dying of the plague, a highly contagious and deadly disease. Doctors were desperate for a way to stop the spread of this disease, and they decided nutmeg held the cure. Everybody wanted nutmeg, and many were willing to spare no expense to have it. Nutmeg bought for a few pennies in Indonesia could be sold for 68,000 times its original cost on the streets of London. The only problem was the short supply. And that’s where the Dutch found their opportunity.\n\nThe Banda Islands were ruled by local sultans who insisted on maintaining a neutral trading policy towards foreign powers. This allowed them to avoid the presence of Portuguese or Spanish troops on their soil, but it also left them unprotected from other invaders. In 1621, the Dutch arrived and took over. Once securely in control of the Bandas, the Dutch went to work protecting their new investment. They concentrated all nutmeg production into a few easily guarded areas, uprooting and destroying any trees outside the plantation zones. Anyone caught growing a nutmeg seedling or carrying seeds without the proper authority was severely punished. In addition, all exported nutmeg was covered with lime to make sure there was no chance a fertile seed which could be grown elsewhere would leave the islands. There was only one obstacle to Dutch domination. One of the Banda Islands, a sliver of land called Run, only 3 km long by less than 1 km wide, was under the control of the British. After decades of fighting for control of this tiny island, the Dutch and British arrived at a compromise settlement, the Treaty of Breda, in 1667. Intent on securing their hold over every nutmeg-producing island, the Dutch offered a trade: if the British would give them the island of Run, they would in turn give Britain a distant and much less valuable island in North America. The British agreed. That other island was Manhattan, which is how New Amsterdam became New York. The Dutch now had a monopoly over the nutmeg trade which would last for another century.\n\nThen, in 1770, a Frenchman named Pierre Poivre successfully smuggled nutmeg plants to safety in Mauritius, an island off the coast of Africa. Some of these were later exported to the Caribbean where they thrived, especially on the island of Grenada. Next, in 1778, a volcanic eruption in the Banda region caused a tsunami that wiped out half the nutmeg groves. Finally, in 1809, the British returned to Indonesia and seized the Banda Islands by force. They returned the islands to the Dutch in 1817, but not before transplanting hundreds of nutmeg seedlings to plantations in several locations across southern Asia. The Dutch nutmeg monopoly was over.\n\nToday, nutmeg is grown in Indonesia, the Caribbean, India, Malaysia, Papua New Guinea and Sri Lanka, and world nutmeg production is estimated to average between 10,000 and 12,000 tonnes per year.\n\n5. In the Middle Ages, most Europeans knew where nutmeg was grown. 6. The VOC was the world’s first major trading company. 7. Following the Treaty of Breda, the Dutch had control of all the islands where nutmeg grew.\\n\\n'
  );

  -- Section 2
  INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","PassageMd")
  VALUES (
    sec2,
    exam_id,
    2,
    'Reading Test 119: Passage 2 - Driverless Cars',
    E'**Questions 14-18:**\nWhich section contains the following information?\n\nWrite the correct letter, **A-L**.\n\n---\n\n**Questions 19-26:**\nChoose the correct letter, **A**, **B**, **C** or **D**.',
    E'**Paragraph A.**\\n# Reading Test 119: Passage 2 - Driverless Cars & Driverless cars\n\nA. The automotive sector is well used to adapting to automation in manufacturing. The implementation of robotic car manufacture from the 1970s onwards led to significant cost savings and improvements in the reliability and flexibility of vehicle mass production. A new challenge to vehicle production is now on the horizon and, again, it comes from automation. However, this time it is not to do with the manufacturing process, but with the vehicles themselves.\n\nResearch projects on vehicle automation are not new. Vehicles with limited self-driving capabilities have been around for more than 50 years, resulting in significant contributions towards driver assistance systems. But since Google announced in 2010 that it had been trialling self-driving cars on the streets of California, progress in this field has quickly gathered pace.\n\nB. There are many reasons why technology is advancing so fast. One frequently cited motive is safety; indeed, research at the UK’s Transport Research Laboratory has demonstrated that more than 90 percent of road collisions involve human error as a contributory factor, and it is the primary cause in the vast majority. Automation may help to reduce the incidence of this.\n\nAnother aim is to free the time people spend driving for other purposes. If the vehicle can do some or all of the driving, it may be possible to be productive, to socialise or simply to relax while automation systems have responsibility for safe control of the vehicle. If the vehicle can do the driving, those who are challenged by existing mobility models – such as older or disabled travellers – may be able to enjoy significantly greater travel autonomy.\n\nC. Beyond these direct benefits, we can consider the wider implications for transport and society, and how manufacturing processes might need to respond as a result. At present, the average car spends more than 90 percent of its life parked. Automation means that initiatives for car-sharing become much more viable, particularly in urban areas with significant travel demand. If a significant proportion of the population choose to use shared automated vehicles, mobility demand can be met by far fewer vehicles.\n\nD. The Massachusetts Institute of Technology investigated automated mobility in Singapore, finding that fewer than 30 percent of the vehicles currently used would be required if fully automated car sharing could be implemented. If this is the case, it might mean that we need to manufacture far fewer vehicles to meet demand. However, the number of trips being taken would probably increase, partly because empty vehicles would have to be moved from one customer to the next.\n\nModelling work by the University of Michigan Transportation Research Institute suggests automated vehicles might reduce vehicle ownership by 43 percent, but that vehicles’ average annual mileage double as a result. As a consequence, each vehicle would be used more intensively, and might need replacing sooner. This faster rate of turnover may mean that vehicle production will not necessarily decrease.\n\nE. Automation may prompt other changes in vehicle manufacture. If we move to a model where consumers are tending not to own a single vehicle but to purchase access to a range of vehicle through a mobility provider, drivers will have the freedom to select one that best suits their needs for a particular journey, rather than making a compromise across all their requirements.\n\nSince, for most of the time, most of the seats in most cars are unoccupied, this may boost production of a smaller, more efficient range of vehicles that suit the needs of individuals. Specialised vehicles may then be available for exceptional journeys, such as going on a family camping trip or helping a son or daughter move to university.\n\nF. There are a number of hurdles to overcome in delivering automated vehicles to our roads. These include the technical difficulties in ensuring that the vehicle works reliably in the infinite range of traffic, weather and road situations it might encounter; the regulatory challenges in understanding how liability and enforcement might change when drivers are no longer essential for vehicle operation; and the societal changes that may be required for communities to trust and accept automated vehicles as being a valuable part of the mobility landscape.\n\nG. It’s clear that there are many challenges that need to be addressed but, through robust and targeted research, these can most probably be conquered within the next 10 years. Mobility will change in such potentially significant ways and in association with so many other technological developments, such as telepresence and virtual reality, that it is hard to make concrete predictions about the future. However, one thing is certain: change is coming, and the need to be flexible in response to this will be vital for those involved in manufacturing the vehicles that will deliver future mobility.\n\n14. reference to the amount of time when a car is not in use. 15. mention of several advantages of driverless vehicles for individual road-users. 16. reference to the opportunity of choosing the most appropriate vehicle for each trip. 17. an estimate of how long it will take to overcome a number of problems 18. a suggestion that the use of driverless cars may have no effect on the number of vehicles manufactured.\n\nFigures from the Transport Research Laboratory indicate that most motor accidents are partly due to 19 ..................., so the introduction of driverless vehicles will result in greater safety. In addition to the direct benefits of automation, it may bring other advantages. For example, schemes for 20 ................... will be more workable, especially in towns and cities, resulting in fewer cars on the road.\n\nAccording to the University of Michigan Transportation Research Institute, there could be a 43 percent drop in 21 ................... of cars. However, this would mean that the yearly 22 ...................of each car would, on average, be twice as high as it currently is. This would lead to a higher turnover of vehicles, and therefore no reduction in automotive manufacturing.\n\nA. Car travellers could enjoy considerable cost savings. B. It would be easier to find parking spaces in urban areas. C. Travellers could spend journeys doing something other than driving. D. People who find driving physically difficult could travel independently. E. A reduction in the number of cars would mean a reduction in pollution.\n\nA. making sure the general public has confidence in automated vehicles B. managing the pace of transition from conventional to automated vehicles C. deciding how to compensate professional drivers who become redundant D. setting up the infrastructure to make roads suitable for automated vehicles E. getting automated vehicles to adapt to various different driving conditions\\n\\n'
  );

  -- Section 3
  INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","PassageMd")
  VALUES (
    sec3,
    exam_id,
    3,
    'Reading Test 119: Passage 3 - What is exploration?',
    E'**Questions 27-32:**\nChoose the correct letter, **A**, **B**, **C** or **D**.\n\n---\n\n**Questions 33-37:**\nWhich section contains the following information?\n\nWrite the correct letter, **A-L**.\n\n---\n\n**Questions 38-40:**\nComplete the sentences below.\n\nWrite **NO MORE THAN TWO WORDS AND/OR A NUMBER** for each answer.',
    E'**Paragraph A.**\\n# Reading Test 119: Passage 3 - What is exploration? & What is exploration?\n\nWe are all explorers. Our desire to discover, and then share that new-found knowledge, is part of what makes us human – indeed, this has played an important part in our success as a species. Long before the first caveman slumped down beside the fire and grunted news that there were plenty of wildebeest over yonder, our ancestors had learnt the value of sending out scouts to investigate the unknown. This questing nature of ours undoubtedly helped our species spread around the globe, just as it nowadays no doubt helps the last nomadic Penan maintain their existence in the depleted forests of Borneo, and a visitor negotiate the subways of New York.\n\nOver the years, we’ve come to think of explorers as a peculiar breed – different from the rest of us, different from those of us who are merely ‘well travelled’, even; and perhaps there is a type of person more suited to seeking out the new, a type of caveman more inclined to risk venturing out. That, however, doesn’t take away from the fact that we all have this enquiring instinct, even today; and that in all sorts of professions – whether artist, marine biologist or astronomer – borders of the unknown are being tested each day.\n\nThomas Hardy set some of his novels in Egdon Heath, a fictional area of uncultivated land, and used the landscape to suggest the desires and fears of his characters. He is delving into matters we all recognise because they are common to humanity. This is surely an act of exploration, and into a world as remote as the author chooses. Explorer and travel writer Peter Fleming talks of the moment when the explorer returns to the existence he has left behind with his loved ones. The traveller ‘who has for weeks or months seen himself only as a puny and irrelevant alien crawling laboriously over a country in which he has no roots and no background, suddenly encounters his other self, a relatively solid figure, with a place in the minds of certain people’.\n\nIn this book about the exploration of the earth’s surface, I have confined myself to those whose travels were real and who also aimed at more than personal discovery. But that still left me with another problem: the word ‘explorer’ has become associated with a past era. We think back to a golden age, as if exploration peaked somehow in the 19th century – as if the process of discovery is now on the decline, though the truth is that we have named only one and a half million of this planet’s species, and there may be more than 10 million – and that’s not including bacteria. We have studied only 5 per cent of the species we know. We have scarcely mapped the ocean floors, and know even less about ourselves; we fully understand the workings of only 10 per cent of our brains.\n\nHere is how some of today’s ‘explorers’ define the word. Ran Fiennes, dubbed the ‘greatest living explorer’, said, ‘An explorer is someone who has done something that no human has done before – and also done something scientifically useful.’ Chris Bonington, a leading mountaineer, felt exploration was to be found in the act of physically touching the unknown: ‘You have to have gone somewhere new.’ Then Robin Hanbury-Tenison, a campaigner on behalf of remote so-called ‘tribal’ peoples, said, ‘A traveller simply records information about some far-off world, and reports back; but an explorer changes the world.’ Wilfred Thesiger, who crossed Arabia’s Empty Quarter in 1946, and belongs to an era of unmechanised travel now lost to the rest of us, told me, ‘If I’d gone across by camel when I could have gone by car, it would have been a stunt.’ To him, exploration meant bringing back information from a remote place regardless of any great self-discovery.\n\nEach definition is slightly different – and tends to reflect the field of endeavour of each pioneer. It was the same whoever I asked: the prominent historian would say exploration was a thing of the past, the cutting-edge scientist would say it was of the present. And so on. They each set their own particular criteria; the common factor in their approach being that they all had, unlike many of us who simply enjoy travel or discovering new things, both a very definite objective from the outset and also a desire to record their findings.\n\nI’d best declare my own bias. As a writer, I’m interested in the exploration of ideas. I’ve done a great many expeditions and each one was unique. I’ve lived for months alone with isolated groups of people all around the world, even two ‘uncontacted tribes’. But none of these things is of the slightest interest to anyone unless, through my books, I’ve found a new slant, explored a new idea. Why? Because the world has moved on. The time has long passed for the great continental voyages – another walk to the poles, another crossing of the Empty Quarter. We know how the land surface of our planet lies; exploration of it is now down to the details – the habits of microbes, say, or the grazing behaviour of buffalo. Aside from the deep sea and deep underground, it’s the era of specialists. However, this is to disregard the role the human mind has in conveying remote places; and this is what interests me: how a fresh interpretation, even of a well-travelled route, can give its readers new insights.\n\nA. exploration is an intrinsic element of being human. B. most people are enthusiastic about exploring. C. exploration can lead to surprising results. D. most people find exploration daunting.\n\nA. Their discoveries have brought both benefits and disadvantages. B. Their main value is in teaching others. C. They act on an urge that is common to everyone. D. They tend to be more attracted to certain professions than to others.\n\nA. Hardy was writing about his own experience of exploration. B. Hardy was mistaken about the nature of exploration. C. Hardy’s aim was to investigate people’s emotional states. D. Hardy’s aim was to show the attraction of isolation.\n\nA. the amount of useful information produced by exploration has decreased. B. fewer people are interested in exploring than in the 19th century. C. recent developments have made exploration less exciting. D. we are wrong to think that exploration is no longer necessary.\n\nA. people tend to relate exploration to their own professional interests. B. certain people are likely to misunderstand the nature of exploration. C. the generally accepted definition has changed over time. D. historians and scientists have more valid definitions than the general public.\n\nA. how someone’s personality is reflected in their choice of places to visit. B. the human ability to cast new light on places that may be familiar. C. how travel writing has evolved to meet changing demands. D. the feelings that writers develop about the places that they explore.\\n\\n'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    1,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    E'_______ _______ in shape',
    '',
    '{"blank-q1": ["OVAL"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    2,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    E'_______ _______ surrounds the fruit and breaks open when the fruit is ripe',
    '',
    '{"blank-q2": ["HUSK"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    3,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    E'_______ _______ is used to produce the spice nutmeg',
    '',
    '{"blank-q3": ["SEED"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    4,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    E'_______ _______',
    '',
    '{"blank-q4": ["MACE"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    5,
    'TRUE_FALSE_NOT_GIVEN',
    'READING',
    2,
    E'TRUE if the statement agrees with the information, FALSE if it contradicts, NOT GIVEN if there is no information on this.\n\n5. In the Middle Ages, most Europeans knew where nutmeg was grown.',
    '',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, E'TRUE', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, E'FALSE', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, E'NOT GIVEN', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    6,
    'TRUE_FALSE_NOT_GIVEN',
    'READING',
    2,
    E'TRUE if the statement agrees with the information, FALSE if it contradicts, NOT GIVEN if there is no information on this.\n\n6. The VOC was the world’s first major trading company.',
    '',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, E'TRUE', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, E'FALSE', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, E'NOT GIVEN', true);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    7,
    'TRUE_FALSE_NOT_GIVEN',
    'READING',
    2,
    E'TRUE if the statement agrees with the information, FALSE if it contradicts, NOT GIVEN if there is no information on this.\n\n7. Following the Treaty of Breda, the Dutch had control of all the islands where nutmeg grew.',
    '',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, E'TRUE', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, E'FALSE', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, E'NOT GIVEN', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    8,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    E'Complete the blank. _______ Question 8',
    '',
    '{"blank-q8": ["ARABS"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    9,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    E'Complete the blank. _______ Question 9',
    '',
    '{"blank-q9": ["PLAGUE"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    10,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    E'Complete the blank. _______ Question 10',
    '',
    '{"blank-q10": ["LIME"]}'::jsonb
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
    E'Complete the blank. _______ Question 11',
    '',
    '{"blank-q11": ["RUN"]}'::jsonb
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
    E'Complete the blank. _______ Question 12',
    '',
    '{"blank-q12": ["MAURITIUS"]}'::jsonb
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
    E'Complete the blank. _______ Question 13',
    '',
    '{"blank-q13": ["TSUNAMI"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec2,
    14,
    'MATCHING_INFORMATION',
    'READING',
    2,
    E'Write the correct letter, A-F.\n\n14. reference to the amount of time when a car is not in use.',
    E'**Đáp án: C**\n\n> "At present, the average car spends more than 90 percent of its life parked."\n\n(Đoạn C) Đoạn văn đề cập cụ thể đến khoảng thời gian xe không được sử dụng (parked) là hơn 90% vòng đời của nó. Thông tin này khớp hoàn toàn với yêu cầu của câu hỏi về "amount of time when a car is not in use".',
    '{"info-q14": ["C", "c"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec2,
    15,
    'MATCHING_INFORMATION',
    'READING',
    2,
    E'Write the correct letter, A-F.\n\n15. mention of several advantages of driverless vehicles for individual road-users.',
    E'**Đáp án: B**\n\n> "...free the time people spend driving for other purposes... be productive, to socialise or simply to relax..."\n\n(Đoạn B) Tác giả liệt kê nhiều lợi ích cho người dùng cá nhân (individual road-users) như có thời gian để làm việc, giao lưu hoặc thư giãn. Đây là các lợi thế trực tiếp của xe tự lái.',
    '{"info-q15": ["B", "b"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec2,
    16,
    'MATCHING_INFORMATION',
    'READING',
    2,
    E'Write the correct letter, A-F.\n\n16. reference to the opportunity of choosing the most appropriate vehicle for each trip.',
    E'**Đáp án: E**\n\n> "Travellers could simply order... a vehicle... best suited to their particular journey..."\n\n(Đoạn E) Bài đọc nói về cơ hội chọn loại phương tiện phù hợp nhất (best suited) cho từng chuyến đi cụ thể, thay vì phải dùng một chiếc xe cho mọi mục đích.',
    '{"info-q16": ["E", "e"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec2,
    17,
    'MATCHING_INFORMATION',
    'READING',
    2,
    E'Write the correct letter, A-F.\n\n17. an estimate of how long it will take to overcome a number of problems',
    E'**Đáp án: G**\n\n> "...these can most probably be conquered within the next 10 years."\n\n(Đoạn G) Câu hỏi yêu cầu một ước tính thời gian (estimate of how long) để vượt qua các vấn đề. Đoạn G đưa ra mốc thời gian cụ thể là "within the next 10 years" để giải quyết các thách thức.',
    '{"info-q17": ["G", "g"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec2,
    18,
    'MATCHING_INFORMATION',
    'READING',
    2,
    E'Write the correct letter, A-F.\n\n18. a suggestion that the use of driverless cars may have no effect on the number of vehicles manufactured.',
    E'**Đáp án: D**\n\n> "...vehicle production will not necessarily decrease."\n\n(Đoạn D) Tác giả gợi ý rằng dù mô hình sở hữu thay đổi, việc sản xuất xe (vehicle manufactured) sẽ không nhất thiết sụt giảm do tốc độ thay thế xe nhanh hơn.',
    '{"info-q18": ["D", "d"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec2,
    19,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    E'_______ _______, so the introduction of driverless vehicles will result in greater safety. In addition to the direct benefits of automation, it may bring other advantages. For example, schemes for',
    E'**Đáp án: HUMAN ERROR**\n\n> "...research... has demonstrated that more than 90 percent of road collisions involve human error..."\n\n(Đoạn B) Bài đọc khẳng định nguyên nhân chính của tai nạn là lỗi con người. Việc giới thiệu xe tự lái sẽ giảm thiểu yếu tố này, dẫn đến an toàn hơn.',
    '{"blank-q19": ["HUMAN ERROR"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec2,
    20,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    E'_______ _______ will be more workable, especially in towns and cities, resulting in fewer cars on the road.',
    E'**Đáp án: CARSHARING / CAR-SHARING**\n\n> "Schemes for car-sharing will be more workable..."\n\n(Đoạn C) Đoạn văn nói rằng các mô hình chia sẻ xe (car-sharing) sẽ trở nên khả thi hơn, đặc biệt là ở các thị trấn và thành phố, giúp giảm lượng xe trên đường.',
    '{"blank-q20": ["CARSHARING/ CAR-SHARING"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec2,
    21,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    E'_______ _______ of cars. However, this would mean that the yearly',
    E'**Đáp án: OWNERSHIP**\n\n> "...reduce the need for individual ownership of cars."\n\n(Đoạn C) Việc xe tự lái và chia sẻ xe phát triển sẽ làm giảm nhu cầu sở hữu xe cá nhân (individual ownership).',
    '{"blank-q21": ["OWNERSHIP"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec2,
    22,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    E'_______ _______of each car would, on average, be twice as high as it currently is. This would lead to a higher turnover of vehicles, and therefore no reduction in automotive manufacturing.',
    E'**Đáp án: MILEAGE**\n\n> "...the yearly mileage of each car would, on average, be twice as high..."\n\n(Đoạn D) Do xe được sử dụng chuyên sâu hơn trong các mô hình chia sẻ, tổng số dặm đi được hàng năm (yearly mileage) của mỗi xe sẽ cao gấp đôi so với hiện tại.',
    '{"blank-q22": ["MILEAGE"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec2,
    23,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    E'Complete the summary using words from the passage _______.',
    '',
    '{"blank-q23": ["AND"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec2,
    24,
    'MATCHING_INFORMATION',
    'READING',
    2,
    E'on your answer sheet.',
    '',
    '{"info-q24": ["C", "c"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec2,
    25,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    E'Complete the summary using words from the passage _______.',
    '',
    '{"blank-q25": ["& 26. A"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec2,
    26,
    'MATCHING_INFORMATION',
    'READING',
    2,
    E'on your answer sheet.',
    '',
    '{"info-q26": ["E", "e"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec3,
    27,
    'MCQ_SINGLE',
    'READING',
    2,
    E'The writer refers to visitors to New York to illustrate the point that',
    '',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, E'exploration is an intrinsic element of being human.', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, E'most people are enthusiastic about exploring.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, E'exploration can lead to surprising results.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, E'most people find exploration daunting.', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec3,
    28,
    'MCQ_SINGLE',
    'READING',
    2,
    E'According to the second paragraph, what is the writer’s view of explorers?',
    '',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, E'Their discoveries have brought both benefits and disadvantages.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, E'Their main value is in teaching others.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, E'They act on an urge that is common to everyone.', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, E'They tend to be more attracted to certain professions than to others.', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec3,
    29,
    'MCQ_SINGLE',
    'READING',
    2,
    E'The writer refers to a description of Egdon Heath to suggest that',
    '',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, E'Hardy was writing about his own experience of exploration.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, E'Hardy was mistaken about the nature of exploration.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, E'Hardy’s aim was to investigate people’s emotional states.', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, E'Hardy’s aim was to show the attraction of isolation.', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec3,
    30,
    'MCQ_SINGLE',
    'READING',
    2,
    E'In the fourth paragraph, the writer refers to ‘a golden age’ to suggest that',
    '',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, E'the amount of useful information produced by exploration has decreased.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, E'fewer people are interested in exploring than in the 19th century.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, E'recent developments have made exploration less exciting.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, E'we are wrong to think that exploration is no longer necessary.', true);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec3,
    31,
    'MCQ_SINGLE',
    'READING',
    2,
    E'In the sixth paragraph, when discussing the definition of exploration, the writer argues that',
    '',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, E'people tend to relate exploration to their own professional interests.', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, E'certain people are likely to misunderstand the nature of exploration.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, E'the generally accepted definition has changed over time.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, E'historians and scientists have more valid definitions than the general public.', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec3,
    32,
    'MCQ_SINGLE',
    'READING',
    2,
    E'In the last paragraph, the writer explains that he is interested in',
    '',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, E'how someone’s personality is reflected in their choice of places to visit.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, E'the human ability to cast new light on places that may be familiar.', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, E'how travel writing has evolved to meet changing demands.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, E'the feelings that writers develop about the places that they explore.', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec3,
    33,
    'MATCHING_INFORMATION',
    'READING',
    2,
    E'He referred to the relevance of the form of transport used.',
    '',
    '{"info-q33": ["E", "e"]}'::jsonb
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, E'Paragraph A', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, E'Paragraph B', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, E'Paragraph C', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, E'Paragraph D', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, E'Paragraph E', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 6, E'Paragraph F', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 7, E'Paragraph G', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec3,
    34,
    'MATCHING_INFORMATION',
    'READING',
    2,
    E'He described feelings on coming back home after a long journey.',
    '',
    '{"info-q34": ["A", "a"]}'::jsonb
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, E'Paragraph A', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, E'Paragraph B', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, E'Paragraph C', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, E'Paragraph D', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, E'Paragraph E', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 6, E'Paragraph F', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 7, E'Paragraph G', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec3,
    35,
    'MATCHING_INFORMATION',
    'READING',
    2,
    E'He worked for the benefit of specific groups of people.',
    '',
    '{"info-q35": ["D", "d"]}'::jsonb
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, E'Paragraph A', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, E'Paragraph B', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, E'Paragraph C', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, E'Paragraph D', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, E'Paragraph E', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 6, E'Paragraph F', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 7, E'Paragraph G', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec3,
    36,
    'MATCHING_INFORMATION',
    'READING',
    2,
    E'He did not consider learning about oneself an essential part of exploration.',
    '',
    '{"info-q36": ["E", "e"]}'::jsonb
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, E'Paragraph A', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, E'Paragraph B', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, E'Paragraph C', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, E'Paragraph D', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, E'Paragraph E', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 6, E'Paragraph F', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 7, E'Paragraph G', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec3,
    37,
    'MATCHING_INFORMATION',
    'READING',
    2,
    E'He defined exploration as being both unique and of value to others.',
    '',
    '{"info-q37": ["B", "b"]}'::jsonb
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, E'Paragraph A', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, E'Paragraph B', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, E'Paragraph C', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, E'Paragraph D', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, E'Paragraph E', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 6, E'Paragraph F', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 7, E'Paragraph G', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec3,
    38,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    E'_______ , and was the first stranger that certain previously',
    '',
    '{"blank-q38": ["EXPEDITIONS"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec3,
    39,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    E'_______ people had encountered.',
    '',
    '{"blank-q39": ["UNCONTACTED", "ISOLATED"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec3,
    40,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    E'_______ , except to answer specific questions such as how buffalo eat.',
    '',
    '{"blank-q40": ["SURFACE"]}'::jsonb
  );

  INSERT INTO exam_question_groups ("Id","SectionId","Idx","StartIdx","EndIdx","InstructionMd")
  VALUES (gen_random_uuid(), sec1, 1, 1, 13, E'Questions 1-13:**\nComplete the sentences below.\n\nWrite **NO MORE THAN TWO WORDS AND/OR A NUMBER** for each answer.\n\n---\n\n**\n\n**1.** _______ _______ in shape\n\n**2.** _______ _______ surrounds the fruit and breaks open when the fruit is ripe\n\n**3.** _______ _______ is used to produce the spice nutmeg\n\n**4.** _______ _______\n\n**5.** TRUE if the statement agrees with the information, FALSE if it contradicts, NOT GIVEN if there is no information on this.\n\n5. In the Middle Ages, most Europeans knew where nutmeg was grown.\n\n**6.** TRUE if the statement agrees with the information, FALSE if it contradicts, NOT GIVEN if there is no information on this.\n\n6. The VOC was the world’s first major trading company.\n\n**7.** TRUE if the statement agrees with the information, FALSE if it contradicts, NOT GIVEN if there is no information on this.\n\n7. Following the Treaty of Breda, the Dutch had control of all the islands where nutmeg grew.\n\n**8.** Complete the blank. _______ Question 8\n\n**9.** Complete the blank. _______ Question 9\n\n**10.** Complete the blank. _______ Question 10\n\n**11.** Complete the blank. _______ Question 11\n\n**12.** Complete the blank. _______ Question 12\n\n**13.** Complete the blank. _______ Question 13');
  INSERT INTO exam_question_groups ("Id","SectionId","Idx","StartIdx","EndIdx","InstructionMd")
  VALUES (gen_random_uuid(), sec1, 2, 5, 7, E'Questions 5-7:**\nDo the following statements agree with the information given in the text?\n\nWrite\n- **TRUE** if the statement agrees with the information\n- **FALSE** if the statement contradicts the information\n- **NOT GIVEN** if there is no information on this');
  INSERT INTO exam_question_groups ("Id","SectionId","Idx","StartIdx","EndIdx","InstructionMd")
  VALUES (gen_random_uuid(), sec2, 1, 14, 18, E'Questions 14-18:**\nWhich section contains the following information?\n\nWrite the correct letter, **A-L**.\n\n---\n\n**');
  INSERT INTO exam_question_groups ("Id","SectionId","Idx","StartIdx","EndIdx","InstructionMd")
  VALUES (gen_random_uuid(), sec2, 2, 19, 26, E'Questions 19-26:**\nChoose the correct letter, **A**, **B**, **C** or **D**.\n\n**19.** _______ _______, so the introduction of driverless vehicles will result in greater safety. In addition to the direct benefits of automation, it may bring other advantages. For example, schemes for\n\n**20.** _______ _______ will be more workable, especially in towns and cities, resulting in fewer cars on the road.\n\n**21.** _______ _______ of cars. However, this would mean that the yearly\n\n**22.** _______ _______of each car would, on average, be twice as high as it currently is. This would lead to a higher turnover of vehicles, and therefore no reduction in automotive manufacturing.\n\n**23.** Complete the summary using words from the passage _______.\n\n**24.** on your answer sheet.\n\n**25.** Complete the summary using words from the passage _______.\n\n**26.** on your answer sheet.');
  INSERT INTO exam_question_groups ("Id","SectionId","Idx","StartIdx","EndIdx","InstructionMd")
  VALUES (gen_random_uuid(), sec3, 1, 27, 32, E'Questions 27-32:**\nChoose the correct letter, **A**, **B**, **C** or **D**.\n\n---\n\n**');
  INSERT INTO exam_question_groups ("Id","SectionId","Idx","StartIdx","EndIdx","InstructionMd")
  VALUES (gen_random_uuid(), sec3, 2, 33, 37, E'Questions 33-37:**\nWhich section contains the following information?\n\nWrite the correct letter, **A-L**.\n\n---\n\n**');
  INSERT INTO exam_question_groups ("Id","SectionId","Idx","StartIdx","EndIdx","InstructionMd")
  VALUES (gen_random_uuid(), sec3, 3, 38, 40, E'Questions 38-40:**\nComplete the sentences below.\n\nWrite **NO MORE THAN TWO WORDS AND/OR A NUMBER** for each answer.\n\n**38.** _______ , and was the first stranger that certain previously\n\n**39.** _______ people had encountered.\n\n**40.** _______ , except to answer specific questions such as how buffalo eat.');

END$$;

COMMIT;