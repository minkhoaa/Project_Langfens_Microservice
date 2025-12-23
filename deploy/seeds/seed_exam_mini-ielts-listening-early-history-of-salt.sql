-- ============================================
-- IELTS Exam Data Import SQL
-- Generated: 2025-12-23T03:09:56.985561
-- Source: mini-ielts.com
-- Title: Early history of salt
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data for slug: mini-ielts-listening-early-history-of-salt
DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'mini-ielts-listening-early-history-of-salt'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'mini-ielts-listening-early-history-of-salt';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'mini-ielts-listening-early-history-of-salt';
DELETE FROM exams
WHERE "Slug" = 'mini-ielts-listening-early-history-of-salt';

DO $$
DECLARE
  exam_id uuid := gen_random_uuid();
  sec1 uuid := gen_random_uuid();
  qid uuid;
BEGIN

  INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","ImageUrl","UpdatedAt")
  VALUES (
    exam_id,
    'mini-ielts-listening-early-history-of-salt',
    'Early history of salt',
    'IELTS Reading Practice Test from IELTS Mentor',
    'IELTS',
    'B2',
    'PUBLISHED',
    20,
    'http://www.todayifoundout.com/wp-content/uploads/2014/01/salt3.jpg',
    now()
  );

  INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","PassageMd","AudioUrl")
  VALUES (
    sec1,
    exam_id,
    1,
    'Listening Test - Early history of salt',
    E'**Questions 1-10:**\nComplete the sentences below.\n\nWrite **NO MORE THAN TWO WORDS AND/OR A NUMBER** for each answer.',
    E'# Passage\n\n# Listening Test - The Early History of Salt\n\nThis is a listening practice test about the early history of salt and its importance in human civilization.\n\n**About the Audio:**\nThis test discusses the essential role of salt throughout human history, from ancient Rome to ancient Sweden and other civilizations.\n\n**Topics covered:**\n- Salt as essential for human health\n- The origin of the word ''salary'' from Latin ''sol arium argentum'' used to describe payment to Roman soldiers\n- How animals were kept in forests at the right time of year in Ancient Sweden\n- The availability of fresh meat only in October\n- The diet of the king in Sweden and salt consumption\n- Beer consumption due to overly salty food\n- Salt extraction from oceans and deserts\n- Concentrated and purer salt from spring water compared to sea water\n- Shipping routes that needed protection\n- People carrying salt as a natural means of transport\n\n**Instructions:**\nListen carefully to the audio recording and complete the notes below. Write ONE WORD ONLY for each answer.'
  ,
    'https://www.youtube.com/embed/-J35kdzyyro?enablejsapi=1');

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    1,
    'SUMMARY_COMPLETION',
    'LISTENING',
    2,
    'Salt is essential for human _______',
    E'**Đáp án: HEALTH**\n\n> "Salt as essential for human health"\n\n(Phần Topics covered) Bài nghe khẳng định muối là thành phần thiết yếu đối với sức khỏe con người. Thông tin này khớp hoàn toàn với nội dung câu hỏi về vai trò của muối. Thí sinh cần chú ý nghe danh từ đi sau tính từ ''essential'' để bắt kịp từ khóa.',
    '{"blank-q1": ["HEALTH"]}'::jsonb
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
    'The word _______ comes from the Latin word’s solarium argetum, which was used to describe the payment to Roman soldiers.',
    E'**Đáp án: SALARY**\n\n> "The origin of the word ''salary'' from Latin ''sol arium argentum'' used to describe payment to Roman soldiers"\n\n(Phần Topics covered) Nguồn gốc của từ ''salary'' bắt nguồn từ cụm từ Latin dùng để chỉ khoản thanh toán cho binh lính La Mã. Từ khóa ''Latin'' và ''payment'' là dấu hiệu trực tiếp dẫn đến đáp án. Lỗi thường gặp là thí sinh có thể viết sai chính tả từ này.',
    '{"blank-q2": ["SALARY"]}'::jsonb
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
    'Animals were kept in the local _______ at the right time of year.',
    E'**Đáp án: FOREST**\n\n> "How animals were kept in forests at the right time of year in Ancient Sweden"\n\n(Phần Topics covered) Tại Thụy Điển cổ đại, động vật được giữ trong các khu rừng vào những thời điểm thích hợp trong năm. Từ ''local'' trong câu hỏi tương ứng với bối cảnh địa phương được nhắc tới. Cần tránh nhầm lẫn với các địa điểm chăn nuôi khác.',
    '{"blank-q3": ["FOREST"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    4,
    'SUMMARY_COMPLETION',
    'LISTENING',
    2,
    'Fresh meat was only available in _______',
    E'**Đáp án: OCTOBER**\n\n> "The availability of fresh meat only in October"\n\n(Phần Topics covered) Bài nghe nêu rõ thịt tươi chỉ có sẵn vào duy nhất tháng 10. Đây là mốc thời gian cụ thể cần điền vào sau giới từ ''in''. Lưu ý quy tắc viết hoa chữ cái đầu đối với các tháng trong tiếng Anh.',
    '{"blank-q4": ["OCTOBER"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    5,
    'SUMMARY_COMPLETION',
    'LISTENING',
    2,
    'Salt has been used widely: we can tell from the diet of the _______ in Sweden.',
    E'**Đáp án: KING**\n\n> "The diet of the king in Sweden and salt consumption"\n\n(Phần Topics covered) Chế độ ăn uống của nhà vua ở Thụy Điển cho thấy muối đã được sử dụng rộng rãi như thế nào. Từ khóa ''diet'' dẫn dắt trực tiếp đến đối tượng sở hữu là ''king''. Thí sinh cần nghe kỹ để không nhầm sang các tầng lớp xã hội khác.',
    '{"blank-q5": ["KING"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    6,
    'SUMMARY_COMPLETION',
    'LISTENING',
    2,
    '_______ Consumption increased rapidly because the food was much too salty.',
    E'**Đáp án: BEER**\n\n> "Beer consumption due to overly salty food"\n\n(Phần Topics covered) Lượng tiêu thụ bia tăng lên nhanh chóng do thức ăn quá mặn khiến người ta khát. Mối quan hệ nhân quả này giúp xác định loại đồ uống được nhắc tới là ''beer''. Cần chú ý danh từ chỉ sự tiêu thụ (consumption) trong câu.',
    '{"blank-q6": ["BEER"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    7,
    'SUMMARY_COMPLETION',
    'LISTENING',
    2,
    'People mainly extract salt from oceans and _______ in the basins.',
    E'**Đáp án: DESERTS**\n\n> "Salt extraction from oceans and deserts"\n\n(Phần Topics covered) Muối được khai thác chủ yếu từ đại dương và các sa mạc. Từ ''oceans'' đi kèm với ''deserts'' qua liên từ ''and'', xác định hai nguồn khai thác chính. Lỗi phổ biến là viết nhầm thành ''desserts'' (món tráng miệng) do phát âm tương tự.',
    '{"blank-q7": ["DESERTS"]}'::jsonb
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
    'Salt from spring water is more _______ and purer compared to that from sea water',
    E'**Đáp án: CONCENTRATED**\n\n> "Concentrated and purer salt from spring water compared to sea water"\n\n(Phần Topics covered) Muối từ nước suối có đặc điểm là đậm đặc và tinh khiết hơn muối biển. Từ ''concentrated'' đi song song với ''purer'' để mô tả chất lượng muối. Đây là tính từ dài, đòi hỏi thí sinh phải nắm vững cách phát âm để nhận diện chính xác.',
    '{"blank-q8": ["CONCENTRATED"]}'::jsonb
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
    '- Locals needed to protect the _______ by which they imported salt.',
    E'**Đáp án: SHIPPING**\n\n> "Shipping routes that needed protection"\n\n(Phần Topics covered) Người dân địa phương cần bảo vệ các tuyến đường vận chuyển dùng để nhập khẩu muối. Từ ''shipping'' đóng vai trò bổ nghĩa cho ''routes'' (tuyến đường) trong ngữ cảnh này. Cần tập trung vào mục đích của việc bảo vệ là dành cho hoạt động vận tải.',
    '{"blank-q9": ["SHIPPING"]}'::jsonb
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
    '- People carrying salt around were seen as a natural means of _______',
    E'**Đáp án: TRANSPORT**\n\n> "People carrying salt around were seen as a natural means of transport"\n\n(Phần Topics covered) Việc con người mang theo muối được xem là một phương tiện vận chuyển tự nhiên. Cụm từ ''means of transport'' là một kết hợp từ (collocation) rất phổ biến trong tiếng Anh. Thí sinh cần nghe rõ danh từ cuối cùng sau cấu trúc ''means of''.',
    '{"blank-q10": ["TRANSPORT"]}'::jsonb
  );


END$$;


COMMIT;