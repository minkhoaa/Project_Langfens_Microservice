-- ============================================
-- IELTS Exam Data Import SQL
-- Generated: 2025-12-25T09:25:59.139608
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

  INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","ImageUrl","UpdatedAt")
  VALUES (
    exam_id,
    'mini-ielts-listening-non-driving-vehicle-competition-driverless-vehicle-competition',
    'Non-driving vehicle competition (Driverless vehicle competition)',
    'IELTS Reading Practice Test from IELTS Mentor',
    'IELTS',
    'B2',
    'PUBLISHED',
    20,
    'https://res.cloudinary.com/df41zs8il/image/upload/v1766628406/ielts/shutterstock_383436070_0_2178bc613baf.jpg',
    now()
  );

  INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","PassageMd","AudioUrl")
  VALUES (
    sec1,
    exam_id,
    1,
    'Listening Test - Non-driving vehicle competition (Driverless vehicle competition)',
    E'**Questions 1-3:**\nComplete the sentences below.\n\nWrite **NO MORE THAN TWO WORDS AND/OR A NUMBER** for each answer.\n\n---\n\n**Questions 4-6:**\nChoose the correct letter, **A**, **B** or **C**.\n\n---\n\n**Questions 7-10:**\nComplete the flow-chart below.\n\nWrite **NO MORE THAN TWO WORDS** for each answer.',
    E'# Non-driving vehicle competition (Driverless vehicle competition)\n\nThis is a listening practice test about a driverless vehicle competition for university students. You will hear a tutor discussing the competition with students.\n\n**Instructions:**\n- You will hear the recording ONCE only\n- Answer all questions based on what you hear in the audio\n- Questions 1-3: Sentence completion\n- Questions 4-6: Multiple choice\n- Questions 7-10: Flow-chart completion'
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
    E'**Đáp án: COMPUTER SCIENCE**\n\n> "...the engineering school will be collaborating with the **computer science** department and possibly the Automotive Design Department..."\n\n(Đoạn 1) Người nói khẳng định sự hợp tác với khoa khoa học máy tính (computer science). Khoa Thiết kế Ô tô chỉ là "có thể" (possibly) và chưa được xác nhận.',
    '{"blank-q1": ["COMPUTER SCIENCE"]}'::jsonb
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
    E'**Đáp án: ROCKS**\n\n> "...avoid unexpected hazards. Things like **rocks**, for example."\n\n(Đoạn 2) Các phương tiện tự động phải tránh các chướng ngại vật (hazards) bất ngờ, và diễn giả đưa ra ví dụ cụ thể là "rocks" (đá).',
    '{"blank-q2": ["ROCKS"]}'::jsonb
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
    E'**Đáp án: VIDEO CAMERAS**\n\n> "...built a three-dimensional picture of its surroundings using **video cameras** and lasers."\n\n(Đoạn 3) Diễn giả đề cập đến một chiếc xe sử dụng công nghệ bao gồm "video cameras" (máy quay video) cùng với lasers để đo đạc môi trường xung quanh.',
    '{"blank-q3": ["VIDEO CAMERAS"]}'::jsonb
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
    E'**Đáp án: C**\n\n> "The sponsors are hoping to see **innovative design ideas** that they can transfer into commercial production."\n\n(Đoạn 4) Mục đích chính của cuộc đua là tìm kiếm các ý tưởng thiết kế đổi mới (new design features) để áp dụng vào sản xuất thương mại. Lựa chọn A và B không phải là mục tiêu chính của nhà tài trợ.',
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
    E'**Đáp án: A**\n\n> "Its strength was in its **onboard technology**... analyze the incoming information..."\n\n(Đoạn 3 & 4) Thành công phụ thuộc vào công nghệ và khả năng phân tích dữ liệu (tương ứng với thiết kế phần mềm/software). Diễn giả cũng nói rõ chiến thắng không phụ thuộc vào vẻ bề ngoài của xe ("what the vehicle looks like").',
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
    E'**Đáp án: B**\n\n> "...they were **pleased they got as far as they did**."\n\n(Đoạn 4) Mặc dù không xe nào hoàn thành đường đua, các đội thi vẫn ngạc nhiên và hài lòng vì xe đã đi được quãng đường xa như vậy (thành công hơn mong đợi).',
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
    'Introductory _______ about the project',
    E'**Đáp án: SEMINAR**\n\n> "...we''ll be scheduling a **seminar** to introduce the project..."\n\n(Đoạn 5) Vào đầu tháng 5, một buổi hội thảo (seminar) giới thiệu về dự án sẽ được tổ chức.',
    '{"blank-q7": ["SEMINAR"]}'::jsonb
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
    'Essay giving information about relevant _______ and experience',
    E'**Đáp án: SKILLS**\n\n> "You''ll need to tell us about any particular **skills** that you have..."\n\n(Đoạn 5) Bài luận (essay) yêu cầu cung cấp thông tin về các kỹ năng (skills) và kinh nghiệm liên quan của ứng viên.',
    '{"blank-q8": ["SKILLS"]}'::jsonb
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
    '• discuss _______',
    E'**Đáp án: IDEAS**\n\n> "...hold a weekend workshop to share **ideas**..."\n\n(Đoạn 5) Vào tháng 9, một buổi hội thảo (workshop) sẽ được tổ chức để thảo luận và chia sẻ các ý tưởng (ideas).',
    '{"blank-q9": ["IDEAS"]}'::jsonb
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
    'Selection of the _______',
    E'**Đáp án: TEAM**\n\n> "...following month will choose the **team**..."\n\n(Đoạn 5) Sau khi nộp bản phác thảo vào tháng 12, việc lựa chọn đội (team) sẽ diễn ra vào tháng tiếp theo.',
    '{"blank-q10": ["TEAM"]}'::jsonb
  );



  -- Delete old question groups for this exam
  DELETE FROM exam_question_groups WHERE "SectionId" = sec1;

  -- Insert question groups
  INSERT INTO exam_question_groups ("Id","SectionId","Idx","StartIdx","EndIdx","InstructionMd")
  VALUES (gen_random_uuid(), sec1, 1, 1, 3, E'**Questions 1-3:**\nComplete the sentences below.\n\nWrite **NO MORE THAN TWO WORDS AND/OR A NUMBER** for each answer.\n\n**1.** Undergraduates from both the engineering school and the _______ department can definitely take part in the project.\n\n**2.** The automated vehicles will have to avoid obstacles such as _______ .\n\n**3.** The tutor mentions one vehicle which used technology such as _______ , lasers, and laptops to measure its surroundings.');

  INSERT INTO exam_question_groups ("Id","SectionId","Idx","StartIdx","EndIdx","InstructionMd")
  VALUES (gen_random_uuid(), sec1, 2, 4, 6, E'**Questions 4-6:**\nChoose the correct letter, **A**, **B** or **C**.\n\n**4.** The purpose of holding the race is to\n- **A** Interest students in careers in industry.\n- **B** Help provide finance for universities.\n- **C** Find useful new design features.\n\n**5.** The tutor says success will depend on\n- **A** The software design.\n- **B** Good, solid construction.\n- **C** Sophisticated mechanisms.\n\n**6.** This year''s competitors were surprised that the vehicles\n- **A** Were so easy to design.\n- **B** Were as successful as they were.\n- **C** Took such a short time to construct.');

  INSERT INTO exam_question_groups ("Id","SectionId","Idx","StartIdx","EndIdx","InstructionMd")
  VALUES (gen_random_uuid(), sec1, 3, 7, 10, E'**Questions 7-10:**\nComplete the flow-chart below.\n\nWrite **NO MORE THAN TWO WORDS** for each answer.\n\n**Early May**\n**7.** Introductory _______ about the project\n\n**Late May**\n**8.** Essay giving information about relevant _______ and experience\n\n**September**\n**9.** • discuss _______\n\n**December**\nSubmit outline\n\n**January**\n**10.** Selection of the _______');

END$$;


COMMIT;