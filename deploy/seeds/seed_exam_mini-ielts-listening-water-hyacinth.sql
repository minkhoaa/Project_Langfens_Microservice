-- ============================================
-- IELTS Exam Data Import SQL
-- Generated: 2025-12-22T15:39:09.093750
-- Source: mini-ielts.com
-- Title: Water hyacinth
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data for slug: mini-ielts-listening-water-hyacinth
DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'mini-ielts-listening-water-hyacinth'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'mini-ielts-listening-water-hyacinth';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'mini-ielts-listening-water-hyacinth';
DELETE FROM exams
WHERE "Slug" = 'mini-ielts-listening-water-hyacinth';

DO $$
DECLARE
  exam_id uuid := gen_random_uuid();
  sec1 uuid := gen_random_uuid();
  qid uuid;
BEGIN

  INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","UpdatedAt")
  VALUES (
    exam_id,
    'mini-ielts-listening-water-hyacinth',
    'Water hyacinth',
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
    'Listening Test - Water hyacinth',
    E'**Questions 3-6:**\nChoose the correct letter, **A**, **B**, **C** or **D**.\n\n---\n\n**Questions 7-10:**\nWhich section contains the following information?\n\nWrite the correct letter, **A-L**.\n\n---\n\n**Questions 9-9:**\nChoose **TWO** letters, **A-E**.',
    E'# Passage\n\n# Listening Test - Water hyacinth\n\nThis is a listening practice test about water hyacinth. Listen carefully to the audio recording and answer the questions below.\n\n**Instructions:**\nYou will hear the recording ONCE only. Answer all questions based on what you hear in the audio.\n\n**About the Audio:**\nThis test includes multiple choice questions and matching questions. Pay close attention to the speakers'' discussions and take notes if needed.\n\n**Question Topics:**\n- Listen for key information and main ideas\n- Match features to correct categories\n- Identify specific details mentioned by speakers'
  ,
    'https://www.youtube.com/embed/JdWLY889K2o?enablejsapi=1');

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    3,
    'MULTIPLE_CHOICE_SINGLE',
    'LISTENING',
    2,
    '3Where was water hyacinth originally from?',
    E'**Đáp án: A**\n\nWater hyacinth có nguồn gốc từ Nam Mỹ (Latin America). Trong bài nghe, thông tin này thường được nhắc đến đầu tiên khi giới thiệu về loài cây này.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. latin America', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. Africa', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. Europe', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    4,
    'MULTIPLE_CHOICE_SINGLE',
    'LISTENING',
    2,
    '4What is the primary cause of the decrease in nutrients from the soil?',
    E'**Đáp án: C**\n\nNguyên nhân chính làm giảm dưỡng chất là do xói mòn đất (soil erosion). Cây này hấp thụ mạnh dưỡng chất, làm đất bị xói mòn và mất chất.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. soil erosion', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. a change of rainfall', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. loss or trees', true);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    5,
    'MULTIPLE_CHOICE_SINGLE',
    'LISTENING',
    2,
    '5When will the biological solution bring risks to the environment?',
    E'**Đáp án: C**\n\nGiải pháp sinh học sẽ gây rủi ro khi loài thiên địch tấn công các loài thực vật khác (attack other plants). Đây là rủi ro phổ biến khi du nhập loài mới để kiểm soát sinh học.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. immediately', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. 6 months later', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. many years later', true);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    6,
    'MULTIPLE_CHOICE_SINGLE',
    'LISTENING',
    2,
    '6What does John say about the mechanical solution?',
    E'**Đáp án: C**\n\nJohn nói rằng giải pháp cơ học (mechanical solution) là không hiệu quả (ineffective) vì cây phát triển lại quá nhanh sau khi bị cắt bỏ.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. ineffective', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. dangerous', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. expensive', true);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    7,
    'MATCHING_INFORMATION',
    'LISTENING',
    2,
    'dried water hyacinth',
    E'**Đáp án: D**\n\nBèo tây khô (dried water hyacinth) có thể dùng làm nhiên liệu (fuel) hoặc chất đốt. Đây là một ứng dụng hữu ích của loài cây này.',
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
    'mushroom farmers',
    E'**Đáp án: C**\n\nNông dân trồng nấm (mushroom farmers) sử dụng bèo tây làm cơ chất trồng nấm. Điều này giúp tận dụng nguồn sinh khối lớn của loài cây này.',
    '{"info-q8": ["C", "c"]}'
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
    'oyster and straw mushrooms',
    E'**Đáp án: E**\n\nNấm rơm và nấm sò (oyster and straw mushrooms) phát triển tốt trên cơ chất bèo tây. Đây là các loại nấm cụ thể được nhắc đến.',
    '{"info-q9": ["E", "e"]}'
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
    'Choose TWO letters, A-E',
    '',
    '{"info-q9": ["E", "e"]}'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. plants and fish are poisoned', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. Farmers cannot fish', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. the dam’s structure is damaged', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D. Electricity production is affected.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, 'E. electricity production is affected.', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    10,
    'MATCHING_INFORMATION',
    'LISTENING',
    2,
    'cows',
    E'**Đáp án: B**\n\nBò (cows) có thể ăn bèo tây, nhưng cần trộn với rơm khô để giảm hàm lượng nước. Bèo tây là nguồn thức ăn gia súc tiềm năng.',
    '{"info-q10": ["B", "b"]}'
  );


END$$;


COMMIT;