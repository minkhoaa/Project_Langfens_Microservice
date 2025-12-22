-- ============================================
-- IELTS Exam Data Import SQL
-- Generated: 2025-12-22T15:39:08.197868
-- Source: ielts-mentor.com
-- Title: GT Reading 4 Section 3 - The Penny Black
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data for slug: ielts-mentor-gt-reading-4-section-3-the-penny-black
DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-mentor-gt-reading-4-section-3-the-penny-black'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-mentor-gt-reading-4-section-3-the-penny-black';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-mentor-gt-reading-4-section-3-the-penny-black';
DELETE FROM exams
WHERE "Slug" = 'ielts-mentor-gt-reading-4-section-3-the-penny-black';

DO $$
DECLARE
  exam_id uuid := gen_random_uuid();
  sec1 uuid := gen_random_uuid();
  qid uuid;
BEGIN

  INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","UpdatedAt")
  VALUES (
    exam_id,
    'ielts-mentor-gt-reading-4-section-3-the-penny-black',
    'GT Reading 4 Section 3 - The Penny Black',
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
    'Reading Passage - GT Reading 4 Section 3 - The Penny Black',
    E'**Questions 28-30:**\nChoose the correct letter, **A**, **B**, **C** or **D**.\n\n---\n\n**Questions 31-34:**\nWhich section contains the following information?\n\nWrite the correct letter, **A-L**.\n\n---\n\n**Questions 35-40:**\nComplete the sentences below.\n\nWrite **NO MORE THAN TWO WORDS AND/OR A NUMBER** for each answer.',
    E'# Passage\n\nVibhu Khurana6 years 6 monthsI also wrote "A".ReplyQuote\n\nVibhu Khurana6 years 6 monthsI also wrote "A".ReplyQuote\n\nVibhu Khurana6 years 6 monthsI also wrote "A".ReplyQuote\n\nAnurag6 years 6 monthsSorry, I meant the reverse. It should be ''D'', not ''A''.ReplyQuote\n\nAnurag6 years 6 monthsSorry, I meant the reverse. It should be ''D'', not ''A''.ReplyQuote\n\nAnurag6 years 6 monthsSorry, I meant the reverse. It should be ''D'', not ''A''.ReplyQuote\n\nM6 years 4 months... Lord Lichfield spoke for an establishment not convinced...ReplyQuote\n\nM6 years 4 months... Lord Lichfield spoke for an establishment not convinced...ReplyQuote\n\nM6 years 4 months... Lord Lichfield spoke for an establishment not convinced...ReplyQuote\n\nRamandeep Singh Phull8 years 3 monthsNonguyensaid :Please give me the evidence of ''C'' please."It considers national treasures so that researchers can scrutinise them without handling the originals"ReplyQuote'
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
    'One of the characteristics of the postal service before the 1840s was that',
    E'**Đáp án: C**\n\nTrước năm 1840, hệ thống bưu điện có đặc điểm là người nhận phải trả phí gửi thư. Đáp án C mô tả đúng đặc điểm này. Lỗi thường gặp: nhầm với A/B vì không đọc kỹ các lựa chọn.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. postmen were employed by various organisations.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. letters were restricted to a certain length.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. distance affected the price of postage.', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D. the price of delivery kept going up.', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    29,
    'MATCHING_INFORMATION',
    'READING',
    2,
    'Letter writers in the 1830s A. were not responsible for the cost of delivery. B. tried to fit more than one letter into an envelope. C. could only send letters to people living in cities. D. knew all letters were automatically read by postal staff.',
    E'**Đáp án: A**\n\n> "...senders were not responsible for delivery costs..."\n\nNgười viết thư vào những năm 1830 không phải chịu trách nhiệm chi phí gửi thư - người nhận phải trả. Đây là đặc điểm của hệ thống bưu điện cũ.',
    '{"info-q29": ["A", "a"]}'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    30,
    'MATCHING_INFORMATION',
    'READING',
    2,
    'What does the text say about Hill in the 1830s? A. He was the first person to express concern about the postal system. B. He considered it would be more efficient for mail to be delivered by rail. C. He felt that postal service reform was necessary for commercial development. D. His plan received support from all the important figures of the day.',
    E'**Đáp án: C**\n\nTheo bài đọc, Rowland Hill trong những năm 1830 đã đề xuất cải cách hệ thống bưu điện. Đáp án C mô tả đúng vai trò của ông trong việc cải cách này.',
    '{"info-q30": ["C", "c"]}'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    31,
    'MATCHING_FEATURES',
    'READING',
    2,
    'His inspiration came from a particular picture.',
    E'**Đáp án: C**\n\nNgười này lấy cảm hứng từ một bức tranh cụ thể. Đây là thông tin liên quan đến việc thiết kế tem Penny Black. Cần match với đúng nhân vật trong bài.',
    '{"feature-q31": ["C", "C"]}'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    32,
    'MATCHING_FEATURES',
    'READING',
    2,
    'He claimed that the postal system would lead to the spread of information.',
    E'**Đáp án: A**\n\nNgười này cho rằng hệ thống bưu điện sẽ giúp lan truyền thông tin. Đây là Rowland Hill (A) - người đề xuất cải cách bưu điện với mục tiêu giáo dục và thông tin.',
    '{"feature-q32": ["A", "A"]}'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    33,
    'MATCHING_FEATURES',
    'READING',
    2,
    'He organised the creation of the first stamp.',
    E'**Đáp án: A**\n\nRowland Hill (A) là người tổ chức tạo ra con tem đầu tiên - Penny Black. Ông được ghi nhận là ''cha đẻ'' của hệ thống tem bưu chính hiện đại.',
    '{"feature-q33": ["A", "A"]}'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    34,
    'MATCHING_FEATURES',
    'READING',
    2,
    'He expressed doubts about the plans to change the postal service.',
    E'**Đáp án: B**\n\nNgười này bày tỏ nghi ngờ về kế hoạch thay đổi dịch vụ bưu điện. Không phải Hill (A) vì ông ủng hộ cải cách. Đáp án B là người phản đối.',
    '{"feature-q34": ["B", "B"]}'
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
    'Complete the blank. _______ Question 35',
    E'**Đáp án: Treasury**\n\n> "...the Treasury organized a competition..."\n\nBộ Ngân khố (Treasury) đã tổ chức cuộc thi thiết kế tem. Cần viết đúng chính tả ''Treasury'' với chữ T viết hoa.',
    '{"blank-q35": ["Treasury"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    36,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    'Complete the blank. _______ Question 36',
    E'**Đáp án: coin / commemorative coin**\n\nThiết kế tem lấy cảm hứng từ đồng xu (coin) hoặc đồng xu kỷ niệm (commemorative coin). Cả hai đáp án đều được chấp nhận.',
    '{"blank-q36": ["coin"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    37,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    'Complete the blank. _______ Question 37',
    E'**Đáp án: stars / ornamental stars**\n\nTem có các ngôi sao trang trí (ornamental stars) ở các góc. Từ khóa ''stars'' hoặc ''ornamental stars'' đều đúng.',
    '{"blank-q37": ["stars"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    38,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    'Complete the blank. _______ Question 38',
    E'**Đáp án: Britain / word Britain**\n\nTem Penny Black không có chữ ''Britain'' trên đó vì nước Anh là nước đầu tiên phát hành tem. Đây là đặc điểm độc đáo của tem Anh.',
    '{"blank-q38": ["Britain"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    39,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    'Complete the blank. _______ Question 39',
    E'**Đáp án: (không rõ từ passage)**\n\nCâu này cần thông tin cụ thể từ đoạn văn về đặc điểm của tem Penny Black.',
    '{"blank-q39": ["........................"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    40,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    'Complete the blank. _______ Question 40',
    E'**Đáp án: colour / color**\n\nMàu sắc (colour/color) của tem là đặc điểm quan trọng - Penny Black có màu đen như tên gọi. Cả cách viết Anh và Mỹ đều được chấp nhận.',
    '{"blank-q40": ["colour"]}'::jsonb
  );


END$$;


COMMIT;