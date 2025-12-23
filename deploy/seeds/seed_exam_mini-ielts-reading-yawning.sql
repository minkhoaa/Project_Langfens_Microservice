-- ============================================
-- IELTS Exam Data Import SQL
-- Generated: 2025-12-23T03:01:03.774670
-- Source: mini-ielts.com
-- Title: Yawning
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data for slug: mini-ielts-reading-yawning
DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'mini-ielts-reading-yawning'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'mini-ielts-reading-yawning';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'mini-ielts-reading-yawning';
DELETE FROM exams
WHERE "Slug" = 'mini-ielts-reading-yawning';

DO $$
DECLARE
  exam_id uuid := gen_random_uuid();
  sec1 uuid := gen_random_uuid();
  qid uuid;
BEGIN

  INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","ImageUrl","UpdatedAt")
  VALUES (
    exam_id,
    'mini-ielts-reading-yawning',
    'Yawning',
    'IELTS Reading Practice Test from IELTS Mentor',
    'IELTS',
    'B2',
    'PUBLISHED',
    20,
    'https://www.verywellhealth.com/thmb/5TmIOVCYIohkXVZNwZAj0ToXjzg=/1500x0/filters:no_upscale():max_bytes(150000):strip_icc()/GettyImages-1337844041-5b537309c73c468eb3b7e4b5b983b4b9.jpg',
    now()
  );

  INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","PassageMd")
  VALUES (
    sec1,
    exam_id,
    1,
    'Reading Passage - Yawning',
    E'**Questions 1-6:**\nComplete the summary below using the list of words, A-K.\n\n**Word Bank:**\n- A. form and function\n- B. long yawns\n- C. 3 seconds\n- D. fixed action pattern\n- E. 68 seconds\n- F. short yawns\n- G. reflex\n- H. sneeze\n- I. short duration\n- J. 6 seconds\n- K. half-yawns\n\n---\n\n**Questions 7-11:**\nChoose the correct letter, **A**, **B**, **C** or **D**.\n\n---\n\n**Questions 12-14:**\nDo the following statements agree with the claims of the writer?\n\nWrite\n- **YES** if the statement agrees with the claims of the writer\n- **NO** if the statement contradicts the claims of the writer\n- **NOT GIVEN** if it is impossible to say what the writer thinks about this',
    E'# Passage\n\n**Paragraph A.**\\nHow and why we yarn still presents problems for researchers in an area which has only recently been opened up to study\\n\\n**Paragraph B.**\\nWhen Robert R Provine began studying yawning in the 1960s, it was difficult for him to convince research students of the merits of ''yawning science 1 . Although it may appear quirky to some, Provine''s decision to study yawning was a logical extension of his research in developmental neuroscience.\\n\\n**Paragraph C.**\\nThe verb ''to yawn'' is derived from the Old English ganien or ginian, meaning to gape or open wide. But in addition to gaping jaws, yawning has significant features that are easy to observe and analyse. Provine ''collected'' yawns to study by using a variation of the contagion response*. He asked people to ''think about yawning'' and, once they began to yawn to depress a button and that would record from the start of the yawn to the exhalation at its end.\\n\\n**Paragraph D.**\\nProvine''s early discoveries can be summanized as follows: the yawn is highly stereotyped but not invariant in its duration and form. It is an excellent example of the instinctive ''fixed action pattern'' of classical animal-behavior study, or ethology. It is not a reflex (short-duration, rapid, proportional response to a simple stimulus), but, once started, a yawn progresses with the inevitability of a sneeze. The standard yawn runs its course over about six seconds on average, but its duration can range from about three seconds to much longer than the average. There are no half-yawns: this is an example of the typical intensity of fixed action patterns and a reason why you cannot stifle yawns. Just like a cough, yawns can come in bouts with a highly variable inter-yawn interval, which is generally about 68 seconds but rarely more than 70. There is no relation between yawn frequency and duration: producers of short or long yawns do not compensate by yawning more or less often. Furthermore, Provine''s hypotheses about the form and function of yawning can be tested by three informative yawn variants which can be used to look at the roles of the nose, the mouth and the jaws.\\n\\n**Paragraph E.**\\nSubjects are asked to pinch their nose closed when they feel themselves start to yawn. Most subjects report being able to perform perfectly normal closed nose yawns. This indicates that the inhalation at the onset of a yawn, and the exhalation at its end, need not involve the nostrils - the mouth provides a sufficient airway.\\n\\n**Paragraph F.**\\nSubjects are asked to clench their teeth when they feel themselves start to yawn but allow themselves to inhale normally through their open lips and clenched teeth. This variant gives one the sensation of being stuck mid­yawn. This shows that gaping of the jaws is an essential component of the fixed action pattern of the yawn, and unless it is accomplished, the program (or pattern) will not run to completion. The yawn is also shown to be more than a deep breath, because, unlike normal breathing, inhalation and exhalation cannot be performed so well through the clenched teeth as through the nose.\\n\\n**Paragraph G.**\\nThis variant tests the adequacy of the nasal airway to sustain a yawn. Unlike normal breathing, which can be performed equally well through mouth or nose, yawning is impossible via nasal inhalation alone. As with the clenched teeth yawn, the nose yawn provides the unfulfilling sensation of being stuck in mid-yawn. Exhalation, on the other hand, can be accomplished equally well through nose or mouth. Through thin methodology Provine demonstrated that inhalation through the oral airway and the gaping of jaws are necessary for normal yawns. The motor program for yawning will not run to completion without feedback that these parts of the program have been accomplished.\\n\\n**Paragraph H.**\\nBut yawning is a powerful, generalized movement that involves much more than airway maneuvres and jaw-gaping. When yawning you also stretch your facial muscles, tilt your head back, narrow or close your eyes, produce tears, salivate, open the Eustachian tubes of your middle ear and perform many other, yet unspecified, cardiovascular and respiratory acts. Perhaps the yawn shares components with other behaviour. For example, in the yawn a kind of ''slow sneeze 1 or is the sneeze a ''fast yawn''? Both share common respiratory and other features including jaw gaping, eye closing and head tilting.\\n\\n**Paragraph I.**\\nYawning and stretching share properties and may be performed together as parts of a global motor complex. Studies by J I p deVries et al. in the early 1980s, charting movement in the developing foet US using ultrasound, observed a link between yawning and stretching. The most extraordinary demonstration of the yawn-stretch linkage occurs in many people paralyzed on one side of their body because of brain damage caused by a stroke, the prominent British neurologist Sir Francis Walshe noted in 1923 that when these people yawn, they are startled and mystified to observe that their otherwise paralyzed arm rises and flexes automatically in what neurologists term an ''associated response''. Yawning apparently activates undamaged, unconsciously controlled connections between the brain and the motor system, causing the paralyzed limb to move. It is not known whether the associated response is a positive prognosis for recovery, nor whether yawning is therapeutic for prevention of muscular deterioration.\\n\\n**Paragraph J.**\\nProvine speculated that, in general, yawning may have many functions, and selecting a single function from the available options may be an unrealistic goal. Yawning appears to be associated with a change of behavioral state, switching from one activity to another. Yawning is also a reminder that ancient and unconscious behavior linking US to the animal world lurks beneath the veneer of culture, rationality and language.\\n\\n'
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
    'Through his observation of yawns, Province was able to confirm that _______ do not exist.',
    '',
    '{"blank-q1": ["K", "k"]}'::jsonb
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
    'Just like a _______, yawns cannot be interrupted after they have begun.',
    '',
    '{"blank-q2": ["H", "h"]}'::jsonb
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
    'This is because yawns occur as a _______ rather than a stimulus response as was previously thought.',
    '',
    '{"blank-q3": ["D", "d"]}'::jsonb
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
    'In measuring the time taken to yawn, Provine found that a typical yawn lasts about _______.',
    '',
    '{"blank-q4": ["J", "j"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    5,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    'He also found that it is common for people to yawn a number of times in quick succession with the yawns usually being around _______ apart.',
    '',
    '{"blank-q5": ["E", "e"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    6,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    'When studying whether length and rate were connected, Province concluded that people who yawn less do not necessarily produce _______ to make up for this.',
    '',
    '{"blank-q6": ["B", "b"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    7,
    'MULTIPLE_CHOICE_SINGLE',
    'READING',
    2,
    'What did Provine conclude from his ''closed nose yawn'' experiment?',
    '',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. Ending a yawn requires use of the nostrils.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. You can yawn without breathing through your nose', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. Breathing through the nose produces a silent yawn.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D. The role of the nose in yawning needs further investigation.', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    8,
    'MULTIPLE_CHOICE_SINGLE',
    'READING',
    2,
    'Provine''s clenched teeth yawn''s experiment shows that',
    '',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. gaping of the jaws is required to complete a yawn.', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. gaping of the jaws makes you look like you need to breathe.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. the mouth provides a sufficient airway during yawns.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D. sneezing and yawning need the same amount of jaw movement.', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    9,
    'MULTIPLE_CHOICE_SINGLE',
    'READING',
    2,
    'What does the passage say about ''the nose yawn''?',
    '',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. The nose yawn is just like normal breathing.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. The nose yawn produces an unsatisfying feeling.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. The nose yawn can only be produced when opening the mouth.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D. The nose yawn allows the full yawning process to take place.', true);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    10,
    'MULTIPLE_CHOICE_SINGLE',
    'READING',
    2,
    'What is the purpose of the paragraph about yawning and stretching?',
    '',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. Yawning and sneezing share similar features.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. Yawning is a complex behavior involving many features.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. Yawning and stretching occur together in adults.', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D. Yawning may be linked to the animal world.', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    11,
    'MULTIPLE_CHOICE_SINGLE',
    'READING',
    2,
    'The neurologist Sir Francis Walshe is mentioned in the passage',
    '',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. to prove that paralysis can be cured by repeated yawning.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. to demonstrate the link between yawning and stretching.', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. as part of a study to find out why movement occurs when yawning.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D. to suggest that the paralyzed arm may demonstrate the contagion response.', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    12,
    'YES_NO_NOT_GIVEN',
    'READING',
    2,
    'This experiment is an example of the typical intensity of fixed action patterns.',
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
    13,
    'YES_NO_NOT_GIVEN',
    'READING',
    2,
    'Yawning may be therapeutic for preventing muscular deterioration.',
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
    14,
    'YES_NO_NOT_GIVEN',
    'READING',
    2,
    'Yawning has a single purpose.',
    '',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'YES', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'NO', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'NOT GIVEN', false);


END$$;


COMMIT;