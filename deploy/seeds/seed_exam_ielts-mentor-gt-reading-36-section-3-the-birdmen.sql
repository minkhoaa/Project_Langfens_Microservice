-- ============================================
-- IELTS Exam Data Import SQL
-- Generated: 2025-12-20T20:46:17.999878
-- Source: ielts-mentor.com
-- Title: GT Reading 36 Section 3 - The Birdmen
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data for slug: ielts-mentor-gt-reading-36-section-3-the-birdmen
DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-mentor-gt-reading-36-section-3-the-birdmen'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-mentor-gt-reading-36-section-3-the-birdmen';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-mentor-gt-reading-36-section-3-the-birdmen';
DELETE FROM exams
WHERE "Slug" = 'ielts-mentor-gt-reading-36-section-3-the-birdmen';

DO $$
DECLARE
  exam_id uuid := gen_random_uuid();
  sec1 uuid := gen_random_uuid();
  qid uuid;
BEGIN

  INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","UpdatedAt")
  VALUES (
    exam_id,
    'ielts-mentor-gt-reading-36-section-3-the-birdmen',
    'GT Reading 36 Section 3 - The Birdmen',
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
    'Reading Passage - GT Reading 36 Section 3 - The Birdmen',
    E'# Passage\n\n# The Birdmen\n\n*Will people finally be able to fly long distances without a plane? John Andres investigates*\n\nPeople have dreamt of flying since written history began. In the 1400s, Leonardo da Vinci drew detailed plans for human flying machines. You might have thought the invention of mechanised flight would have put an end to such ideas. Far from it. For many enthusiasts, the ultimate flight fantasy is the jet pack, a small piece of equipment on your back which enables you to climb vertically into the air and fly forwards, backwards and turn. Eric Scott was a stuntman in Hollywood for about a decade and has strapped jet packs to his back more than 600 times and propelled himself hundreds of metres into the air. Now he works for an energy-drink company that pays him to travel around the world with his jet pack. As Scott says: ''I get to do what I love and wherever I go I advertise Go Fast drinks. Existing packs work for little more than 30 seconds, but people are working on designs which let you fly around for 20 minutes. ''That would be amazing,'' says Scott.\nParamotoring is another way of getting into the air. It combines the sort of parachute used in paragliding with a small engine and propeller and is now becoming popular. Chris Clarke has been flying a paramotor for five years. ''Getting about is roughly comparable with driving a petrol-powered car in terms of expense. The trouble is that paramotoring is ill-suited to commuting because of the impossibility of taking off in strong winds,'' says Clarke.\nAnother keen paramotorist recently experienced a close call when in the air. ''I started to get a warm feeling in my back,'' says Patrick Vandenbulcke. I thought I was just sweating. But then I started to feel burning and I realized I had to get to the ground fast. After an inspection of the engine later, I noticed that the exhaust pipe had moved during the flight and the harness had started melting.'' This hasn''t put Vandenbulcke off, however, and he is enthusiastic about persuading others to take up paramotoring. However he warns: Although it seems cheaper to try to teach yourself, you will regret it later as you won''t have a good technique.'' A training course will cost over £1,000, while the equipment costs a few thousand pounds. You may pick up cheaper equipment secondhand, however. There was one pre-used kit advertised on a website, with a bit of damage to the cage and tips of the propellers due to a rough landing. ''Scared myself to death,'' the seller reported, ''hence the reason for this sale.''\nFun though it is, paramotoring is not in the same league as the acrobatics demonstrated by Yves Rossy. He has always enjoyed being a daredevil showman. He once parachuted from a plane above Lake Geneva and, intentionally skimming the top of a fountain as he landed, he descended to the lake where he grabbed some water ski equipment and started waterskiing while the crowd watched open-mouthed.\nRossy, who has been labelled ''the Birdman'', was born in 1959 in Switzerland. After flying planes for the air force from the ages of 20 to 28, he went on to do a job as a pilot with a commercial airline from 1988 to 2000. ''The cockpit of a plane is the most beautiful office in the world,'' he says, ''but I didn''t have any contact with the air around me. It was a bit like being in a box or a submarine under water.'' From then on, he, therefore, concentrated on becoming the first jet-powered flying man.\nIn May 2008, he stepped out of an aircraft at about 3000 metres. Within seconds he was soaring and diving at over 290 kph, at one point reaching 300 kph, about 104 kph faster than the typical falling skydiver. His speed was monitored by a plane flying alongside. Rossy started his flight with a free fall, then he powered four jet turbines to keep him in the air before releasing a parachute which enabled him to float to the ground. The jet turbines are attached to special wings which he can unfold. The wings were manufactured by a German firm called JCT Composites. Initially he had approached a company called Jet-Kit which specialised in miniature planes, but the wings they made for him weren''t rigid enough to support the weight of the engines. Rossy says he has become the first person to maintain a stable horizontal flight, thanks to aerodynamic carbon foldable wings.'' Without these special wings, it is doubtful he would have managed to do this.\nRossy''s ambitions include flying down the Grand Canyon. To do this, he will have to fit his wings with bigger, more powerful jets. The engines he currently uses already provide enough thrust to allow him to climb through the air, but then he needs the power to stay there. In terms of the physical strength involved, Rossy insists it''s no more difficult than riding a motorbike. ''But even the slightest change in position can cause problems. I have to focus hard on relaxing in the air, because if you put tension in your body, you start to swing round.'' If he makes it, other fliers will want to know whether they too will someday be able to soar. The answer is yes, possibly, but it is unlikely to be more than an expensive hobby.'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    28,
    'MULTIPLE_CHOICE_SINGLE',
    'READING',
    2,
    'What information is given about Vandenbulcke in paragraph 3?',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. He narrowly avoided a dangerous situation.', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. He did not understand the equipment he was using.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. He did not react fast enough to the situation.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D. He was fortunate to get the help he needed.', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    29,
    'MULTIPLE_CHOICE_SINGLE',
    'READING',
    2,
    'When the writer refers to some second-hand paramotoring equipment which was for sale, he is emphasising that -',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. paramotoring equipment is in short supply.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. paramotoring equipment needs to be carefully tested.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. paramotoring is a very expensive hobby.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D. paramotoring can be a dangerous pastime.', true);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    30,
    'MULTIPLE_CHOICE_SINGLE',
    'READING',
    2,
    'The description of what happened at Lake Geneva is given to suggest that Rossy',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. frequently changes his plans.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. likes to do what appears impossible.', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. is an excellent overall sportsman.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D. knows the area very thoroughly.', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    31,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    'Yves Rossy was born in 1959. He worked as both a military and _______ pilot before focusing on his ambition of becoming a jet-powered flying man.',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q31": ["commercial"]}'::jsonb
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
    'First he asked a firm which made _______ planes to construct some wings for him, but these proved unsuitable.',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q32": ["miniature"]}'::jsonb
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
    'First he asked a firm which made miniature planes to construct some _______ for him, but these proved unsuitable.',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q33": ["wings"]}'::jsonb
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
    'On a flight in May 2008, he managed to achieve a top speed of _______ easily exceeding the speed achieved by the average skydiver.',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q34": ["300 kph"]}'::jsonb
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
    'On a flight in May 2008, he managed to achieve a top speed of 300 kph easily exceeding the speed achieved by the average _______.',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q35": ["skydiver"]}'::jsonb
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
    'He acknowledges the role of his equipment in enabling him to set a flying record.',
    'Choose the correct answer.',
    '{"feature-q36": ["D", "D. Yves Rossy"]}'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. Eric Scott', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. Chris Clarke', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. Patrick Vandenbulcke', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D. Yves Rossy', true);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    37,
    'MATCHING_FEATURES',
    'READING',
    2,
    'He explains how he uses his flying expertise to promote a product.',
    'Choose the correct answer.',
    '{"feature-q37": ["A", "A. Eric Scott"]}'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. Eric Scott', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. Chris Clarke', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. Patrick Vandenbulcke', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D. Yves Rossy', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    38,
    'MATCHING_FEATURES',
    'READING',
    2,
    'He explains what led him to experiment with different ways of flying.',
    'Choose the correct answer.',
    '{"feature-q38": ["D", "D. Yves Rossy"]}'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. Eric Scott', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. Chris Clarke', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. Patrick Vandenbulcke', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D. Yves Rossy', true);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    39,
    'MATCHING_FEATURES',
    'READING',
    2,
    'He describes a mistake some beginners might make.',
    'Choose the correct answer.',
    '{"feature-q39": ["C", "C. Patrick Vandenbulcke"]}'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. Eric Scott', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. Chris Clarke', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. Patrick Vandenbulcke', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D. Yves Rossy', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    40,
    'MATCHING_FEATURES',
    'READING',
    2,
    'He mentions circumstances which prevent you from leaving the ground.',
    'Choose the correct answer.',
    '{"feature-q40": ["B", "B. Chris Clarke"]}'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. Eric Scott', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. Chris Clarke', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. Patrick Vandenbulcke', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D. Yves Rossy', false);


END$$;


COMMIT;