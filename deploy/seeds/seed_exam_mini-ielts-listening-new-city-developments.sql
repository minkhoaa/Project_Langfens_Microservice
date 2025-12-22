-- ============================================
-- IELTS Exam Data Import SQL
-- Generated: 2025-12-22T15:39:10.996664
-- Source: mini-ielts.com
-- Title: New city developments
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data for slug: mini-ielts-listening-new-city-developments
DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'mini-ielts-listening-new-city-developments'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'mini-ielts-listening-new-city-developments';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'mini-ielts-listening-new-city-developments';
DELETE FROM exams
WHERE "Slug" = 'mini-ielts-listening-new-city-developments';

DO $$
DECLARE
  exam_id uuid := gen_random_uuid();
  sec1 uuid := gen_random_uuid();
  qid uuid;
BEGIN

  INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","UpdatedAt")
  VALUES (
    exam_id,
    'mini-ielts-listening-new-city-developments',
    'New city developments',
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
    'Listening Test - New city developments',
    E'**Questions 1-4**\nChoose the correct letter, **A, B or C**.\n\n**New city developments**\n\n---\n\n**Questions 5-10**\nWhich feature is related to each of the following areas of the world represented in the playground?\n\nChoose **SIX** answers from the box and write the correct letter, **A-I**, next to questions 5-10.\n\n**Features**\n\n**A** ancient forts\n\n**B** waterways\n\n**C** ice and snow\n\n**D** jewels\n\n**E** local animals\n\n**F** mountains\n\n**G** music and film\n\n**H** space travel\n\n**I** volcanoes\n',
    E'# Passage\n\n# New City Developments - Listening Test\n\n## Questions 1-4: Multiple Choice (A, B or C)\nNew city developments - a conversation about two new developments: Brackenside pool and a playground.\n\n### Question Topics\n1. The idea for the two new developments in the city came from\n2. What is unusual about Brackenside pool?\n3. Local newspapers have raised worries about\n4. What decision has not yet been made about the pool?\n\n---\n\n## Questions 5-10: Matching Features to Areas\nWhich feature is related to each of the following areas of the world represented in the playground?\n\n### Features (A-I)\n| Letter | Feature |\n|--------|---------|\n| A | ancient forts |\n| B | waterways |\n| C | ice and snow |\n| D | jewels |\n| E | local animals |\n| F | mountains |\n| G | music and film |\n| H | space travel |\n| I | volcanoes |\n\n### Areas of the World\n- 5. Asia\n- 6. Antarctica\n- 7. South America\n- 8. North America\n- 9. Europe\n- 10. Africa\n'
  ,
    'https://www.youtube.com/embed/JHPDv8vzZVw?enablejsapi=1');

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    1,
    'MULTIPLE_CHOICE_SINGLE',
    'LISTENING',
    2,
    'The idea for the two new developments in the city came from',
    E'**Đáp án: clothing**\n\nÝ tưởng phát triển thành phố bắt nguồn từ ngành công nghiệp may mặc (clothing industry) rất mạnh ở địa phương.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. local people.', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. the City Council.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. the SWRDC.', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    2,
    'MULTIPLE_CHOICE_SINGLE',
    'LISTENING',
    2,
    'What is unusual about Brackenside pool?',
    E'**Đáp án: toys**\n\nNgoài quần áo, thành phố còn nổi tiếng về sản xuất đồ chơi (toys) xuất khẩu.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. its architectural style', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. its heating system', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. its method of water treatment', true);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    3,
    'MULTIPLE_CHOICE_SINGLE',
    'LISTENING',
    2,
    'Local newspapers have raised worries about',
    E'**Đáp án: A**\n\nKế hoạch ''Strauss'' được thiết kế bởi kiến trúc sư nổi tiếng (famous architect).',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. the late opening date.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. the cost of the project.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. the size of the facilities.', true);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    4,
    'MULTIPLE_CHOICE_SINGLE',
    'LISTENING',
    2,
    'What decision has not yet been made about the pool?',
    E'**Đáp án: B**\n\nKhu vực mới sẽ được xây dựng trên vùng đất hoang (wasteland) hoặc khu công nghiệp cũ.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. whose statue will be at the door', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. the exact opening times', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. who will open it', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    5,
    'MATCHING_INFORMATION',
    'LISTENING',
    2,
    'Asia',
    E'**Đáp án: C**\n\nMột đặc điểm của khu phát triển mới là không gian xanh (green space) rộng lớn.',
    '{"info-q5": ["E", "e"]}'
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
    'Antarctica',
    E'**Đáp án: D**\n\nKhu vực này cũng sẽ có một trung tâm mua sắm (shopping centre) hiện đại.',
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
    'South America',
    E'**Đáp án: A**\n\nViệc xây dựng sẽ bắt đầu vào năm tới (next year) và dự kiến hoàn thành trong 3 năm.',
    '{"info-q7": ["D", "d"]}'
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
    'North America',
    E'**Đáp án: C**\n\nMột vấn đề tiềm ẩn là tiếng ồn (noise) từ các công trường xây dựng ảnh hưởng đến cư dân.',
    '{"info-q8": ["H", "h"]}'
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
    'Europe',
    E'**Đáp án: B**\n\nTuy nhiên, dự án sẽ tạo ra nhiều việc làm (jobs) cho người dân địa phương.',
    '{"info-q9": ["A", "a"]}'
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
    'Africa',
    E'**Đáp án: A**\n\nTổng chi phí dự án ước tính khoảng 50 triệu bảng (50 million pounds).',
    '{"info-q10": ["B", "b"]}'
  );


END$$;


COMMIT;