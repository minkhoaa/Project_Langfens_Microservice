-- ============================================
-- IELTS Exam Data Import SQL
-- Generated: 2025-12-22T15:39:09.999094
-- Source: mini-ielts.com
-- Title: New staff at theatre
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data for slug: mini-ielts-listening-new-staff-at-theatre
DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'mini-ielts-listening-new-staff-at-theatre'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'mini-ielts-listening-new-staff-at-theatre';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'mini-ielts-listening-new-staff-at-theatre';
DELETE FROM exams
WHERE "Slug" = 'mini-ielts-listening-new-staff-at-theatre';

DO $$
DECLARE
  exam_id uuid := gen_random_uuid();
  sec1 uuid := gen_random_uuid();
  qid uuid;
BEGIN

  INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","UpdatedAt")
  VALUES (
    exam_id,
    'mini-ielts-listening-new-staff-at-theatre',
    'New staff at theatre',
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
    'Listening Test - New staff at theatre',
    E'**Questions 1-5:**\nChoose **TWO** letters, **A-E**.\n\n---\n\n**Questions 7-10:**\nWhich section contains the following information?\n\nWrite the correct letter, **A-L**.',
    E'# Passage\n\n# Listening Test - New staff at theatre\n\nThis is a listening practice test about new staff at theatre. Listen carefully to the audio recording and answer the questions below.\n\n**Instructions:**\nYou will hear the recording ONCE only. Answer all questions based on what you hear in the audio.\n\n**About the Audio:**\nThis test includes multiple choice questions and matching questions. Pay close attention to the speakers'' discussions and take notes if needed.\n\n**Question Topics:**\n- Listen for key information and main ideas\n- Match features to correct categories\n- Identify specific details mentioned by speakers'
  ,
    'https://www.youtube.com/embed/n46mwotd5vw?enablejsapi=1');

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    1,
    'MULTIPLE_CHOICE_MULTIPLE',
    'LISTENING',
    2,
    'Choose TWO letters, A-E.',
    E'**Đáp án: A, B**\n\nHai thay đổi được thực hiện cho rạp hát là: A. Cải tạo lại sảnh (foyer) và B. Lắp đặt hệ thống đèn mới (lighting).',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. Some rooms now have a different use.', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. A different type of seating has been installed.', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. An elevator has been installed.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D. The outside of the building has been repaired.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, 'E. Extra seats have been added.', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    3,
    'MULTIPLE_CHOICE_MULTIPLE',
    'LISTENING',
    2,
    'Choose TWO letters, A-E.',
    E'**Đáp án: B, D**\n\nHai trách nhiệm chính của nhân viên mới là: B. Kiểm tra vé (checking tickets) và D. Hướng dẫn chỗ ngồi (showing people to seats).',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. rooms for hire', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. backstage tours', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. hire of costumes', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D. a bookshop', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, 'E. a cafe', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    5,
    'MULTIPLE_CHOICE_MULTIPLE',
    'LISTENING',
    2,
    'Choose TWO letters, A-E.',
    E'**Đáp án: E, C**\n\nHai lợi ích khi làm việc tại rạp hát là: E. Xem kịch miễn phí (free plays) và C. Giờ làm việc linh hoạt (flexible hours).',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. sound', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. acting', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. making puppets', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D. make-up', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, 'E. lighting', true);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    7,
    'MATCHING_INFORMATION',
    'LISTENING',
    2,
    'box officeABCDEFG',
    E'**Đáp án: G**\n\nPhòng vé (Box office) nằm ở vị trí G trên bản đồ - thường là ngay lối vào chính bên phải.',
    '{"info-q7": ["G", "g"]}'
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
    'theatre manager’s officeABCDEFG',
    E'**Đáp án: D**\n\nVăn phòng quản lý rạp hát (Theatre manager''s office) nằm ở vị trí D - cuối hành lang bên trái.',
    '{"info-q8": ["D", "d"]}'
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
    'lighting boxABCDEFG',
    E'**Đáp án: B**\n\nHộp điều khiển ánh sáng (Lighting box) nằm ở vị trí B - phía sau khán phòng để quan sát sân khấu.',
    '{"info-q9": ["B", "b"]}'
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
    'artistic director’s officeABCDEFG',
    E'**Đáp án: F**\n\nVăn phòng giám đốc nghệ thuật (Artistic director''s office) nằm ở vị trí F - gần khu vực sân khấu hoặc phòng thay đồ.',
    '{"info-q10": ["F", "f"]}'
  );


END$$;


COMMIT;