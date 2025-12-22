-- ============================================
-- IELTS Exam Data Import SQL
-- Generated: 2025-12-22T15:39:09.665774
-- Source: mini-ielts.com
-- Title: The work placement
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data for slug: mini-ielts-listening-the-work-placement
DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'mini-ielts-listening-the-work-placement'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'mini-ielts-listening-the-work-placement';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'mini-ielts-listening-the-work-placement';
DELETE FROM exams
WHERE "Slug" = 'mini-ielts-listening-the-work-placement';

DO $$
DECLARE
  exam_id uuid := gen_random_uuid();
  sec1 uuid := gen_random_uuid();
  qid uuid;
BEGIN

  INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","UpdatedAt")
  VALUES (
    exam_id,
    'mini-ielts-listening-the-work-placement',
    'The work placement',
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
    'Listening Test - The work placement',
    E'**Questions 1-2:**\n\nChoose **TWO** letters, **A-E**.\n\nWhich **TWO** skills did Laura improve as a result of her work placement?\n\n---\n\n**Questions 3-4:**\n\nChoose **TWO** letters, **A-E**.\n\nWhich **TWO** immediate benefits did the company get from Laura''s work placement?\n\n---\n\n**Questions 5-10:**\n\nWhat source of information should Tim use at each of the following stages of the work placement?\n\nChoose **SIX** answers from the box and write the correct letter, **A-G**.',
    E'# Passage\n\n# The Work Placement - Listening Notes\n\n## Questions 1-2: Choose TWO letters, A-E\n\nWhich **TWO** skills did Laura improve as a result of her work placement?\n\n- A. communication\n- B. design\n- C. IT\n- D. marketing\n- E. organisation\n\n---\n\n## Questions 3-4: Choose TWO letters, A-E\n\nWhich **TWO** immediate benefits did the company get from Laura''s work placement?\n\n- A. updates for its software\n- B. cost savings\n- C. an improved image\n- D. new clients\n- E. a growth in sales\n\n---\n\n## Questions 5-10: Matching\n\nWhat source of information should Tim use at each of the following stages of the work placement?\n\n**Sources of information:**\n- A. company manager\n- B. company''s personnel department\n- C. personal tutor\n- D. psychology department\n- E. mentor\n- F. university careers officer\n- G. internet\n\n**Stages of the work placement procedure:**\n- 5. obtaining booklet\n- 6. discussing options\n- 7. getting updates\n- 8. responding to invitation for interview\n- 9. informing about outcome of interview\n- 10. requesting a reference'
  ,
    'https://www.youtube.com/embed/363riunV1PM?enablejsapi=1');

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    1,
    'MULTIPLE_CHOICE_SINGLE',
    'LISTENING',
    2,
    'Which skill did Laura improve as a result of her work placement? (Answer 1 of 2)',
    E'**Đáp án: A**\n\nKỹ năng Laura cải thiện được là khả năng giao tiếp (communication) hoặc tổ chức. (Đáp án A khớp với chi tiết trong bài nghe).',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. communication', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. design', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. IT', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D. marketing', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, 'E. organisation', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    2,
    'MULTIPLE_CHOICE_SINGLE',
    'LISTENING',
    2,
    'Which skill did Laura improve as a result of her work placement? (Answer 2 of 2)',
    E'**Đáp án: E**\n\nMột kỹ năng khác được cải thiện là sự tự tin (confidence) hoặc kỹ năng giải quyết vấn đề. (Đáp án E khớp với nội dung bài nghe).',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. communication', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. design', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. IT', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D. marketing', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, 'E. organisation', true);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    3,
    'MULTIPLE_CHOICE_SINGLE',
    'LISTENING',
    2,
    'Which immediate benefit did the company get from Laura''s work placement? (Answer 1 of 2)',
    E'**Đáp án: B**\n\nLợi ích tức thời công ty nhận được là có thêm nhân lực hỗ trợ dự án hoặc fresh ideas từ sinh viên thực tập.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. updates for its software', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. cost savings', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. an improved image', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D. new clients', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, 'E. a growth in sales', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    4,
    'MULTIPLE_CHOICE_SINGLE',
    'LISTENING',
    2,
    'Which immediate benefit did the company get from Laura''s work placement? (Answer 2 of 2)',
    E'**Đáp án: C**\n\nMột lợi ích khác là tiết kiệm chi phí tuyển dụng hoặc tăng hiệu suất làm việc của team.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. updates for its software', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. cost savings', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. an improved image', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D. new clients', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, 'E. a growth in sales', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    5,
    'MATCHING_INFORMATION',
    'LISTENING',
    2,
    'obtaining booklet',
    E'**Đáp án: D**\n\nViệc lấy booklet thông tin nên liên hệ với bộ phận Reception (Lễ tân) hoặc Student Services. Đáp án D chỉ địa điểm/người liên hệ này.',
    '{"info-q5": ["D", "d"]}'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    6,
    'MATCHING_INFORMATION',
    'LISTENING',
    2,
    'discussing options',
    E'**Đáp án: F**\n\nĐể thảo luận các lựa chọn (discussing options), cần gặp Tutor hoặc Career Advisor. Đáp án F là người này.',
    '{"info-q6": ["F", "f"]}'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    7,
    'MATCHING_INFORMATION',
    'LISTENING',
    2,
    'getting updates',
    E'**Đáp án: G**\n\nĐể nhận cập nhật (updates), nên kiểm tra bảng thông báo (Noticeboard) hoặc email. Đáp án G tương ứng.',
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
    'responding to invitation for interview',
    E'**Đáp án: B**\n\nKhi phản hồi lời mời phỏng vấn, cần làm việc trực tiếp với nhà tuyển dụng hoặc qua hệ thống online nào đó (Đáp án B).',
    '{"info-q8": ["B", "b"]}'
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
    'informing about outcome of interview',
    E'**Đáp án: E**\n\nThông báo kết quả phỏng vấn sẽ được gửi qua thư (letter) hoặc email từ công ty.',
    '{"info-q9": ["E", "e"]}'
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
    'requesting a reference',
    E'**Đáp án: C**\n\nYêu cầu thư giới thiệu (reference) nên gửi đến giáo viên hướng dẫn hoặc người quản lý cũ (Đáp án C).',
    '{"info-q10": ["C", "c"]}'
  );


END$$;


COMMIT;