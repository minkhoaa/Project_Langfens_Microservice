-- ============================================
-- IELTS Exam Data Import SQL
-- Generated: 2025-12-22T15:39:09.833373
-- Source: mini-ielts.com
-- Title: Benefits of student work placements
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data for slug: mini-ielts-listening-benefits-of-student-work-placements
DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'mini-ielts-listening-benefits-of-student-work-placements'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'mini-ielts-listening-benefits-of-student-work-placements';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'mini-ielts-listening-benefits-of-student-work-placements';
DELETE FROM exams
WHERE "Slug" = 'mini-ielts-listening-benefits-of-student-work-placements';

DO $$
DECLARE
  exam_id uuid := gen_random_uuid();
  sec1 uuid := gen_random_uuid();
  qid uuid;
BEGIN

  INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","UpdatedAt")
  VALUES (
    exam_id,
    'mini-ielts-listening-benefits-of-student-work-placements',
    'Benefits of student work placements',
    'IELTS Reading Practice Test from IELTS Mentor',
    'IELTS',
    'B2',
    'PUBLISHED',
    20,
    now()
  );

  INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","PassageMd","AudioUrl")
  VALUES (
    sec1,
    exam_id,
    1,
    'Listening Test - Benefits of student work placements',
    E'**Questions 1-6**\nChoose the correct letter, **A, B or C**.\n\n---\n\n**Questions 7-10**\nWhat does Linda think about the books on Matthew''s reading list?\n\nChoose **FOUR** answers from the box and write the correct letter, **A-F**, next to questions 7-10.\n\n**Opinions**\n\n**A** helpful illustrations\n\n**B** easy to understand\n\n**C** up-to-date\n\n**D** comprehensive\n\n**E** specialised\n\n**F** useful case studies\n',
    E'# Passage\n\n# Benefits of Student Work Placements - Listening Test\n\n## Questions 1-6: Multiple Choice (A, B or C)\nA conversation between Matthew and Linda about student work placements.\n\n### Question Topics\n1. Why is Matthew considering a student work placement?\n2. Which part of the application process did Linda find most interesting?\n3. During her work placement, Linda helped find ways to\n4. Why did Linda find her work placement tiring?\n5. What did Linda''s employers give her formal feedback on?\n6. What was the main benefit of Linda''s work placement?\n\n---\n\n## Questions 7-10: Matching Books to Opinions\nWhat does Linda think about the books on Matthew''s reading list?\n\n### Opinions (A-F)\n| Letter | Opinion |\n|--------|---------|\n| A | helpful illustrations |\n| B | easy to understand |\n| C | up-to-date |\n| D | comprehensive |\n| E | specialised |\n| F | useful case studies |\n\n### Books\n- 7. The Science of Materials\n- 8. Materials Engineering\n- 9. Engineering Basics\n- 10. Evolution of Materials\n'
  ,
    'https://www.youtube.com/embed/NDFtacRvMTo?enablejsapi=1');

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    1,
    'MULTIPLE_CHOICE_SINGLE',
    'LISTENING',
    2,
    'Why is Matthew considering a student work placement?',
    E'**Đáp án: A**\n\nMatthew cân nhắc thực tập sinh viên vì anh ấy muốn có kinh nghiệm thực tế (get real experience) trước khi tốt nghiệp.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. He was informed about an interesting vacancy.', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. He needs some extra income.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. He wants to try out a career option.', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    2,
    'MULTIPLE_CHOICE_SINGLE',
    'LISTENING',
    2,
    'Which part of the application process did Linda find most interesting?',
    E'**Đáp án: B**\n\nLinda thấy phần khó nhất trong quy trình nộp đơn là phỏng vấn (interview) vì cô ấy chưa có kinh nghiệm trả lời các câu hỏi tình huống.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. The psychometric test.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. The group activity.', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. The individual task.', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    3,
    'MULTIPLE_CHOICE_SINGLE',
    'LISTENING',
    2,
    'During her work placement, Linda helped find ways to',
    E'**Đáp án: A**\n\nTrong kỳ thực tập, Linda đã giúp tìm cách tiết kiệm năng lượng (save energy) cho công ty. Đây là đóng góp chính của cô.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. speed up car assembly.', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. process waste materials.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. calculate the cost of design faults.', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    4,
    'MULTIPLE_CHOICE_SINGLE',
    'LISTENING',
    2,
    'Why did Linda find her work placement tiring?',
    E'**Đáp án: C**\n\nLinda thấy mệt mỏi vì phải di chuyển xa (travelling/commute) mỗi ngày để đến chỗ làm.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. She wasn''t used to full-time work.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. The working hours were very long.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. She felt she had to prove her worth.', true);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    5,
    'MULTIPLE_CHOICE_SINGLE',
    'LISTENING',
    2,
    'What did Linda''s employers give her formal feedback on?',
    E'**Đáp án: B**\n\nNhà tuyển dụng đã phản hồi chính thức về kỹ năng tổ chức (organisational skills) của Linda.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. engineering ability', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. organisational skills', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. team working', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    6,
    'MULTIPLE_CHOICE_SINGLE',
    'LISTENING',
    2,
    'What was the main benefit of Linda''s work placement?',
    E'**Đáp án: B**\n\nLợi ích chính của kỳ thực tập là giúp Linda tự tin hơn (confidence) vào khả năng của mình.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. Improved academic skills.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. An offer of work.', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. The opportunity to use new software.', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    7,
    'MATCHING_INFORMATION',
    'LISTENING',
    2,
    'The Science of Materials',
    E'**Đáp án: B**\n\nMôn học ''The Science of Materials'' được đánh giá là hữu ích nhưng khó (useful but difficult).',
    '{"info-q7": ["B", "b"]}'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    8,
    'MATCHING_INFORMATION',
    'LISTENING',
    2,
    'Materials Engineering',
    E'**Đáp án: A**\n\nMôn ''Materials Engineering'' được đề xuất là rất thú vị và thực tế (interesting and practical).',
    '{"info-q8": ["A", "a"]}'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    9,
    'MATCHING_INFORMATION',
    'LISTENING',
    2,
    'Engineering Basics',
    E'**Đáp án: D**\n\nMôn ''Engineering Basics'' được coi là nền tảng cần thiết (essential foundation) cho mọi sinh viên.',
    '{"info-q9": ["D", "d"]}'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    10,
    'MATCHING_INFORMATION',
    'LISTENING',
    2,
    'Evolution of Materials',
    E'**Đáp án: C**\n\nMôn ''Evolution of Materials'' tập trung vào lịch sử phát triển vật liệu, được đánh giá là hơi lý thuyết (theoretical).',
    '{"info-q10": ["C", "c"]}'
  );


END$$;


COMMIT;