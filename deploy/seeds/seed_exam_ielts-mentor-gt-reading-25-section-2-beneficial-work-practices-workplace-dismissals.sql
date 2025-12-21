-- ============================================
-- IELTS Exam Data Import SQL
-- Generated: 2025-12-21T02:10:52.850626
-- Source: ielts-mentor.com
-- Title: GT Reading 25 Section 2 - Beneficial Work Practices & Workplace Dismissals
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data for slug: ielts-mentor-gt-reading-25-section-2-beneficial-work-practices-workplace-dismissals
DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-mentor-gt-reading-25-section-2-beneficial-work-practices-workplace-dismissals'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-mentor-gt-reading-25-section-2-beneficial-work-practices-workplace-dismissals';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-mentor-gt-reading-25-section-2-beneficial-work-practices-workplace-dismissals';
DELETE FROM exams
WHERE "Slug" = 'ielts-mentor-gt-reading-25-section-2-beneficial-work-practices-workplace-dismissals';

DO $$
DECLARE
  exam_id uuid := gen_random_uuid();
  sec1 uuid := gen_random_uuid();
  qid uuid;
BEGIN

  INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","UpdatedAt")
  VALUES (
    exam_id,
    'ielts-mentor-gt-reading-25-section-2-beneficial-work-practices-workplace-dismissals',
    'GT Reading 25 Section 2 - Beneficial Work Practices & Workplace Dismissals',
    'IELTS Reading Practice Test from IELTS Mentor',
    'IELTS',
    'B2',
    'PUBLISHED',
    20,
    now()
  );

  INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","PassageMd")
  VALUES (
    sec1,
    exam_id,
    1,
    'Reading Passage - GT Reading 25 Section 2 - Beneficial Work Practices & Workplace Dismissals',
    E'**Questions 15-21:** Choose the correct heading for each section from the list of headings below.\nWrite the correct number **i–x** in boxes 15–21.\n\n**Questions 22-23:** Complete the sentences below.\nChoose **NO MORE THAN THREE WORDS** from the text for each answer.\n\n**Questions 24-28:** Look at the statements and the options A-F.\nWrite the correct letter **A-F** in boxes 24-28.\n\n---\n\n# Workplace Dismissals',
    E'**Paragraph A.**\nSensible work practices are an important factor in the prevention of muscular fatigue; discomfort or pain in the arms, neck, hands or back; or eye strain which can be associated with constant or regular work at a keyboard and visual display unit (VDU).\n\n**Paragraph B.**\nIt is vital that the employer pays attention to the physical setting such as workplace design, the office environment, and placement of monitors as well as the organisation of the work and individual work habits. Operators must be able to recognise work-related health problems and be given the opportunity to participate in the management of these. Operators should take note of and follow the preventive measures outlined below.\n\n**Paragraph C.**\nThe typist must be comfortably accommodated in a chair that is adjustable for height with a backrest that is also easily adjustable both for angle and height. The backrest and sitting ledge (with a curved edge) should preferably be cloth-covered to avoid excessive perspiration.\n\n**Paragraph D.**\nWhen the keyboard operator is working from a paper file or manuscript, it should be at the same distance from the eyes as the screen. The most convenient position can be found by using some sort of holder. Individual arrangements will vary according to whether the operator spends more time looking at the VDU or the paper – whichever the eyes are focused on for the majority of time should be put directly in front of the operator.\n\n**Paragraph E.**\nWhile keying, it is advisable to have frequent but short pauses of around thirty to sixty seconds to proofread. When doing this, relax your hands. After you have been keying for sixty minutes, you should have a ten-minute change of activity. During this spell, it is important that you do not remain seated but stand up or walk around. This period could be profitably used to do filing or collect and deliver documents.\n\n**Paragraph F.**\nGenerally, the best position for a VDU is at right angles to the window. If this is not possible then glare from the window can be controlled by blinds, curtains or movable screens. Keep the face of the VDU vertical to avoid glare from overhead lighting.\n\n**Paragraph G.**\nUnsatisfactory work practices or working conditions may result in aches or pain. Symptoms should be reported to your supervisor early on so that the cause of the trouble can be corrected and the operator should seek medical attention.\n\ni. How can reflection problems be avoided? ii. How long should I work without a break? iii What if I experience any problems? iv. When is the best time to do filing chores? v. What makes a good seat? vi. What are the common health problems? vii. What is the best kind of lighting to have? viii. What are the roles of management and workers? ix. Why does a VDU create eye fatigue? x. Where should I place the documents? Section B Section D Section F Instances of minor misconduct and poor performance must first be addressed through some preliminary steps. Firstly, you should be given an improvement note. This will explain the problem, outline any necessary changes and offer some assistance in correcting the situation. Then, if your employer does not think your performance has improved, you may be given a written warning. The last step is called a final written warning which will inform you that you will be dismissed unless there are improvements in performance. If there is no improvement, your employer can begin the dismissal procedure. The dismissal procedure begins with a letter from the employer setting out the charges made against the employee. The employee will be invited to a meeting to discuss these accusations. If the employee denies the charges, he is given the opportunity to appear at a formal appeal hearing in front of a different manager. After this, a decision is made as to whether the employee will be let go or not. Dismissals Of the various types of dismissal, a fair dismissal is the best kind if an employer wants an employee out of the workplace. A fair dismissal is legally and contractually strong and it means all the necessary procedures have been correctly followed. In cases where an employee’s misconduct has been very serious, however, an employer may not have to follow all of these procedures. If the employer can prove that the employee’s behaviour was illegal, dangerous or severely wrong, the employee can be dismissed immediately: a procedure known as summary dismissal. Sometimes a dismissal is not considered to have taken place fairly. One of these types is wrongful dismissal and involves a breach of contract by the employer. This could involve dismissing an employee without notice or without following proper disciplinary and dismissal procedures. Another type, unfair dismissal, is when an employee is sacked without good cause. There is another kind of dismissal, known as constructive dismissal, which is slightly peculiar because the employee is not actually openly dismissed by the employer. In this case, the employee is forced into resigning by an employer who tries to make significant changes to the original contract. This could mean an employee might have to work night shifts after originally signing on for day work, or he could be made to work in dangerous conditions.'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    15,
    'MATCHING_HEADING',
    'READING',
    2,
    'Section A',
    'Choose the correct answer.',
    '{"section-a-q15": ["vi", "vi. What are the common health problems?"]}'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'i. How can reflection problems be avoided?', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'ii. How long should I work without a break?', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'iii. What if I experience any problems?', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'iv. When is the best time to do filing chores?', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, 'v. What makes a good seat?', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 6, 'vi. What are the common health problems?', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 7, 'vii. What is the best kind of lighting to have?', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 8, 'viii. What are the roles of management and workers?', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 9, 'ix. Why does a VDU create eye fatigue?', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 10, 'x. Where should I place the documents?', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    16,
    'MATCHING_HEADING',
    'READING',
    2,
    'Section B',
    'Choose the correct answer.',
    '{"section-b-q16": ["viii", "viii. What are the roles of management and workers?"]}'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'i. How can reflection problems be avoided?', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'ii. How long should I work without a break?', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'iii. What if I experience any problems?', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'iv. When is the best time to do filing chores?', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, 'v. What makes a good seat?', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 6, 'vi. What are the common health problems?', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 7, 'vii. What is the best kind of lighting to have?', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 8, 'viii. What are the roles of management and workers?', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 9, 'ix. Why does a VDU create eye fatigue?', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 10, 'x. Where should I place the documents?', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    17,
    'MATCHING_HEADING',
    'READING',
    2,
    'Section C',
    'Choose the correct answer.',
    '{"section-c-q17": ["v", "v. What makes a good seat?"]}'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'i. How can reflection problems be avoided?', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'ii. How long should I work without a break?', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'iii. What if I experience any problems?', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'iv. When is the best time to do filing chores?', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, 'v. What makes a good seat?', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 6, 'vi. What are the common health problems?', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 7, 'vii. What is the best kind of lighting to have?', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 8, 'viii. What are the roles of management and workers?', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 9, 'ix. Why does a VDU create eye fatigue?', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 10, 'x. Where should I place the documents?', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    18,
    'MATCHING_HEADING',
    'READING',
    2,
    'Section D',
    'Choose the correct answer.',
    '{"section-d-q18": ["x", "x. Where should I place the documents?"]}'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'i. How can reflection problems be avoided?', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'ii. How long should I work without a break?', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'iii. What if I experience any problems?', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'iv. When is the best time to do filing chores?', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, 'v. What makes a good seat?', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 6, 'vi. What are the common health problems?', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 7, 'vii. What is the best kind of lighting to have?', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 8, 'viii. What are the roles of management and workers?', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 9, 'ix. Why does a VDU create eye fatigue?', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 10, 'x. Where should I place the documents?', true);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    19,
    'MATCHING_HEADING',
    'READING',
    2,
    'Section E',
    'Choose the correct answer.',
    '{"section-e-q19": ["ii", "ii. How long should I work without a break?"]}'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'i. How can reflection problems be avoided?', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'ii. How long should I work without a break?', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'iii. What if I experience any problems?', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'iv. When is the best time to do filing chores?', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, 'v. What makes a good seat?', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 6, 'vi. What are the common health problems?', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 7, 'vii. What is the best kind of lighting to have?', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 8, 'viii. What are the roles of management and workers?', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 9, 'ix. Why does a VDU create eye fatigue?', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 10, 'x. Where should I place the documents?', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    20,
    'MATCHING_HEADING',
    'READING',
    2,
    'Section F',
    'Choose the correct answer.',
    '{"section-f-q20": ["i", "i. How can reflection problems be avoided?"]}'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'i. How can reflection problems be avoided?', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'ii. How long should I work without a break?', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'iii. What if I experience any problems?', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'iv. When is the best time to do filing chores?', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, 'v. What makes a good seat?', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 6, 'vi. What are the common health problems?', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 7, 'vii. What is the best kind of lighting to have?', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 8, 'viii. What are the roles of management and workers?', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 9, 'ix. Why does a VDU create eye fatigue?', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 10, 'x. Where should I place the documents?', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    21,
    'MATCHING_HEADING',
    'READING',
    2,
    'Section G',
    'Choose the correct answer.',
    '{"section-g-q21": ["iii", "iii. What if I experience any problems?"]}'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'i. How can reflection problems be avoided?', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'ii. How long should I work without a break?', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'iii. What if I experience any problems?', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'iv. When is the best time to do filing chores?', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, 'v. What makes a good seat?', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 6, 'vi. What are the common health problems?', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 7, 'vii. What is the best kind of lighting to have?', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 8, 'viii. What are the roles of management and workers?', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 9, 'ix. Why does a VDU create eye fatigue?', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 10, 'x. Where should I place the documents?', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    22,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    'If an employee receives a _________________________________________________.. , this means he will lose his job if his work does not get better.',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q22": ["final written warning"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    23,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    'If an employee does not accept the reasons for his dismissal, a _________________________________________________.. can be arranged.',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q23": ["formal appeal hearing"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    24,
    'MATCHING_INFORMATION',
    'READING',
    2,
    'Question 24',
    'Choose the correct answer.',
    '{"info-q24": ["B", "b"]}'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    25,
    'MATCHING_INFORMATION',
    'READING',
    2,
    'Question 25',
    'Choose the correct answer.',
    '{"info-q25": ["E", "e"]}'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    26,
    'MATCHING_INFORMATION',
    'READING',
    2,
    'Question 26',
    'Choose the correct answer.',
    '{"info-q26": ["D", "d"]}'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    27,
    'MATCHING_INFORMATION',
    'READING',
    2,
    'Question 27',
    'Choose the correct answer.',
    '{"info-q27": ["C", "c"]}'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    28,
    'MATCHING_INFORMATION',
    'READING',
    2,
    'Question 28',
    'Choose the correct answer.',
    '{"info-q28": ["A", "a"]}'
  );


END$$;


COMMIT;