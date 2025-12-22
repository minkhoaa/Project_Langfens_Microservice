-- ============================================
-- IELTS Exam Data Import SQL
-- Generated: 2025-12-22T15:39:10.663789
-- Source: mini-ielts.com
-- Title: Dolphin Conservation Trust
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data for slug: mini-ielts-listening-dolphin-conservation-trust
DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'mini-ielts-listening-dolphin-conservation-trust'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'mini-ielts-listening-dolphin-conservation-trust';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'mini-ielts-listening-dolphin-conservation-trust';
DELETE FROM exams
WHERE "Slug" = 'mini-ielts-listening-dolphin-conservation-trust';

DO $$
DECLARE
  exam_id uuid := gen_random_uuid();
  sec1 uuid := gen_random_uuid();
  qid uuid;
BEGIN

  INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","UpdatedAt")
  VALUES (
    exam_id,
    'mini-ielts-listening-dolphin-conservation-trust',
    'Dolphin Conservation Trust',
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
    'Listening Test - Dolphin Conservation Trust',
    E'**Questions 1-2**\nChoose the correct letter, **A-E**. Note: You will need to select two different options for Questions 1 and 2.\n\n**Questions 3-5**\nChoose the correct letter, **A**, **B**, or **C**.\n\n**Questions 6-10**\nWhich dolphin (**A-D**) does Alice make each of the following comments about?\nWrite the correct letter, **A-D**, next to Questions 6-10.',
    E'# Passage\n\n# Dolphin Conservation Trust\n\n## Listening Test\nYou will hear an interview with Alice from the Dolphin Conservation Trust.\n\n## Featured Dolphins\nThe Trust monitors several dolphins in the local area:\n\n| Letter | Dolphin Name | Characteristics |\n|--------|--------------|-----------------|\n| A | **Moondancer** | One of the dolphins in the scheme |\n| B | **Echo** | Frequently observed by the team |\n| C | **Kiwi** | Known for distinctive energetic behavior |\n| D | **Samson** | Another dolphin monitored by the Trust |\n\n## Questions Overview\n- **Questions 1-2**: Information about the Trust\n- **Questions 3-5**: Multiple choice questions about achievements\n- **Questions 6-10**: Match the dolphin (A-D) to the description\n'
  ,
    'https://www.youtube.com/embed/V2puNsehQHQ?enablejsapi=1');

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    1,
    'MULTIPLE_CHOICE_SINGLE',
    'LISTENING',
    2,
    'Which one of the following things does Alice say about the Dolphin Conservation Trust? (Part 1)',
    E'**Đáp án: C**\n\nAlice nói rằng Dolphin Conservation Trust đặc biệt vì nó tập trung vào giáo dục cộng đồng (community education/awareness) hơn là chỉ nghiên cứu khoa học.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. Children make up most of the membership.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. It’s the country''s largest conservation organisation.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. It helps finance campaigns for changes in fishing practices.', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D. It employs several dolphin experts full-time.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, 'E. Volunteers help in various ways.', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    2,
    'MULTIPLE_CHOICE_SINGLE',
    'LISTENING',
    2,
    'Which other thing does Alice say about the Dolphin Conservation Trust? (Part 2)',
    E'**Đáp án: E**\n\nMột điểm đặc biệt khác là tổ chức này hoạt động dựa trên sự đóng góp của tình nguyện viên (volunteers) thay vì nhân viên trả lương.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. Children make up most of the membership.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. It’s the country''s largest conservation organisation.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. It helps finance campaigns for changes in fishing practices.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D. It employs several dolphin experts full-time.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, 'E. Volunteers help in various ways.', true);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    3,
    'MULTIPLE_CHOICE_SINGLE',
    'LISTENING',
    2,
    'Why is Alice so pleased the Trust has won the Charity Commission award?',
    E'**Đáp án: B**\n\nAlice vui mừng vì giải thưởng giúp nâng cao uy tín (profile/reputation) của tổ chức, từ đó thu hút thêm tài trợ.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. It has brought in extra money.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. It made the work of the trust better known.', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. It has attracted more members.', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    4,
    'MULTIPLE_CHOICE_SINGLE',
    'LISTENING',
    2,
    'Alice says oil exploration causes problems to dolphins because of',
    E'**Đáp án: A**\n\nThăm dò dầu khí gây ra tiếng ồn (noise) làm gián đoạn khả năng giao tiếp và định vị của cá heo.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. noise.', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. oil leaks.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. movement of ships.', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    5,
    'MULTIPLE_CHOICE_SINGLE',
    'LISTENING',
    2,
    'Alice became interested in dolphins when',
    E'**Đáp án: C**\n\nAlice bắt đầu quan tâm đến cá heo khi cô ấy xem một bộ phim tài liệu (documentary) trên TV hồi nhỏ.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. she saw one swimming near her home.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. she heard a speaker at her school.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. she read a book about them.', true);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    6,
    'MATCHING_FEATURES',
    'LISTENING',
    2,
    'It has not been seen this year',
    E'**Đáp án: B**\n\nCon cá heo B chưa được nhìn thấy trong năm nay (not seen this year), có thể nó đã di chuyển đến vùng khác.',
    '{"feature-q6": ["B", "B"]}'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    7,
    'MATCHING_FEATURES',
    'LISTENING',
    2,
    'It is photographed more than the others',
    E'**Đáp án: C**\n\nCon cá heo C được chụp ảnh nhiều nhất (photographed more) vì nó hay bơi gần thuyền và rất dạn người.',
    '{"feature-q7": ["C", "C"]}'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    8,
    'MATCHING_FEATURES',
    'LISTENING',
    2,
    'It is always very energetic',
    E'**Đáp án: D**\n\nCon cá heo D luôn rất năng động (very energetic), thường xuyên nhảy lên khỏi mặt nước.',
    '{"feature-q8": ["D", "D"]}'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    9,
    'MATCHING_FEATURES',
    'LISTENING',
    2,
    'It is the newest one in the scheme',
    E'**Đáp án: D**\n\nCon cá heo D cũng là thành viên mới nhất (newest one) được đưa vào chương trình theo dõi.',
    '{"feature-q9": ["D", "D"]}'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    10,
    'MATCHING_FEATURES',
    'LISTENING',
    2,
    'It has an unusual shape',
    E'**Đáp án: A**\n\nCon cá heo A có hình dạng vây lưng bất thường (unusual shape), giúp dễ dàng nhận diện nó.',
    '{"feature-q10": ["A", "A"]}'
  );


END$$;


COMMIT;