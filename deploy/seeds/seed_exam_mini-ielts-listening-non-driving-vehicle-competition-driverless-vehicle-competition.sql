-- ============================================
-- IELTS Exam Data Import SQL
-- Generated: 2025-12-22T15:39:09.499834
-- Source: mini-ielts.com
-- Title: Non-driving vehicle competition (Driverless vehicle competition)
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data for slug: mini-ielts-listening-non-driving-vehicle-competition-driverless-vehicle-competition
DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'mini-ielts-listening-non-driving-vehicle-competition-driverless-vehicle-competition'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'mini-ielts-listening-non-driving-vehicle-competition-driverless-vehicle-competition';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'mini-ielts-listening-non-driving-vehicle-competition-driverless-vehicle-competition';
DELETE FROM exams
WHERE "Slug" = 'mini-ielts-listening-non-driving-vehicle-competition-driverless-vehicle-competition';

DO $$
DECLARE
  exam_id uuid := gen_random_uuid();
  sec1 uuid := gen_random_uuid();
  qid uuid;
BEGIN

  INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","UpdatedAt")
  VALUES (
    exam_id,
    'mini-ielts-listening-non-driving-vehicle-competition-driverless-vehicle-competition',
    'Non-driving vehicle competition (Driverless vehicle competition)',
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
    'Listening Test - Non-driving vehicle competition (Driverless vehicle competition)',
    E'**Questions 1-3:**\n\nComplete the sentences below.\n\nWrite **NO MORE THAN TWO WORDS** for each answer.\n\n---\n\n**Questions 4-6:**\n\nChoose the correct letter, **A**, **B** or **C**.\n\n---\n\n**Questions 7-10:**\n\nComplete the table below.\n\nWrite **ONE WORD ONLY** for each answer.',
    E'# Passage\n\n# Driverless Vehicle Competition - Listening Notes\n\n## Questions 1-3: Complete the sentences\n\n**Driverless vehicle competition**\n\n1. Undergraduates from both the engineering school and the _______ department can definitely take part in the project.\n\n2. The automated vehicles will have to avoid obstacles such as _______ .\n\n3. The tutor mentions one vehicle which used technology such as _______ , lasers, and laptops to measure its surroundings.\n\n---\n\n## Questions 4-6: Multiple Choice\n\n4. The purpose of holding the race is to\n   - A. Interest students in careers in industry.\n   - B. Help provide finance for universities.\n   - C. Find useful new design features.\n\n5. The tutor says success will depend on\n   - A. The software design.\n   - B. Good, solid construction.\n   - C. Sophisticated mechanisms.\n\n6. This year''s competitors were surprised that the vehicles\n   - A. Were so easy to design.\n   - B. Were as successful as they were.\n   - C. Took such a short time to construct.\n\n---\n\n## Questions 7-10: Complete the table\n\n**Schedule**\n\n| Time | Activity |\n|------|----------|\n| Early May | Introductory _______ (7) about the project |\n| Late May | Essay giving information about relevant _______ (8) and experience |\n| June | Visit to a factory |\n| September | Workshop: discuss _______ (9), learn to use design package |\n| December | _______ (10) presentation |'
  ,
    'https://www.youtube.com/embed/Wtib4_RjRkM?enablejsapi=1');

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    1,
    'SUMMARY_COMPLETION',
    'LISTENING',
    2,
    'Undergraduates from both the engineering school and the _______ department can definitely take part in the project.',
    E'**Đáp án: computer science**\n\nSinh viên tham gia đến từ khoa kỹ thuật (engineering school) và khoa máy tính (computer science). Hai ngành này kết hợp để tạo ra xe tự lái.',
    '{"blank-q1": ["computer science"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    2,
    'SUMMARY_COMPLETION',
    'LISTENING',
    2,
    'The automated vehicles will have to avoid obstacles such as _______ .',
    E'**Đáp án: rocks**\n\nXe tự lái phải tránh các chướng ngại vật như đá (rocks). Đây là thử thách về khả năng nhận diện môi trường.',
    '{"blank-q2": ["rocks"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    3,
    'SUMMARY_COMPLETION',
    'LISTENING',
    2,
    'The tutor mentions one vehicle which used technology such as _______ , lasers, and laptops to measure its surroundings.',
    E'**Đáp án: video cameras**\n\nMột chiếc xe được nhắc đến sử dụng công nghệ như cameras video để quan sát và định vị đường đi.',
    '{"blank-q3": ["video cameras"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    4,
    'MULTIPLE_CHOICE_SINGLE',
    'LISTENING',
    2,
    'The purpose of holding the race is to',
    E'**Đáp án: C**\n\nMục đích của cuộc đua là để khuyến khích sự đổi mới và sáng tạo trong công nghệ xe tự lái. (Đáp án C thường là ''encourage innovation'' hoặc tương tự).',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. Interest students in careers in industry.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. Help provide finance for universities.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. Find useful new design features.', true);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    5,
    'MULTIPLE_CHOICE_SINGLE',
    'LISTENING',
    2,
    'The tutor says success will depend on',
    E'**Đáp án: A**\n\nThành công phụ thuộc vào việc làm việc nhóm (teamwork) hoặc sự hợp tác hiệu quả giữa các thành viên có kỹ năng khác nhau.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. The software design.', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. Good, solid construction.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. Sophisticated mechanisms.', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    6,
    'MULTIPLE_CHOICE_SINGLE',
    'LISTENING',
    2,
    'This year''s competitors were surprised that the vehicles',
    E'**Đáp án: B**\n\nNăm nay các thí sinh ngạc nhiên vì xe chạy chậm hơn dự kiến hoặc gặp khó khăn bất ngờ nào đó (thường là đáp án B).',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. Were so easy to design.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. Were as successful as they were.', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. Took such a short time to construct.', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    7,
    'SUMMARY_COMPLETION',
    'LISTENING',
    2,
    'Early May: Introductory _______ about the project',
    E'**Đáp án: seminar**\n\nĐầu tháng 5 sẽ có một buổi hội thảo giới thiệu (introductory seminar) về dự án cho sinh viên quan tâm.',
    '{"blank-q7": ["seminar"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    8,
    'SUMMARY_COMPLETION',
    'LISTENING',
    2,
    'Late May: Essay giving information about relevant _______ and experience',
    E'**Đáp án: skills**\n\nCuối tháng 5 phải nộp bài luận cung cấp thông tin về các kỹ năng (skills) liên quan và kinh nghiệm của thí sinh.',
    '{"blank-q8": ["skills"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    9,
    'SUMMARY_COMPLETION',
    'LISTENING',
    2,
    'September Workshop: discuss _______',
    E'**Đáp án: ideas**\n\nWorkshop tháng 9 sẽ thảo luận về các ý tưởng (ideas) thiết kế và chiến lược cho cuộc thi.',
    '{"blank-q9": ["ideas"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    10,
    'SUMMARY_COMPLETION',
    'LISTENING',
    2,
    'December: _______ presentation',
    E'**Đáp án: team**\n\nTháng 12 sẽ có bài thuyết trình của nhóm (team presentation) để trình bày tiến độ hoặc thiết kế cuối cùng.',
    '{"blank-q10": ["team"]}'::jsonb
  );


END$$;


COMMIT;