-- ============================================
-- IELTS Exam Data Import SQL
-- Generated: 2025-12-24T19:13:10.631590
-- Source: mini-ielts.com
-- Title: Spider silk 2
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data for slug: mini-ielts-reading-spider-silk-2
DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'mini-ielts-reading-spider-silk-2'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'mini-ielts-reading-spider-silk-2';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'mini-ielts-reading-spider-silk-2';
DELETE FROM exams
WHERE "Slug" = 'mini-ielts-reading-spider-silk-2';

DO $$
DECLARE
  exam_id uuid := gen_random_uuid();
  sec1 uuid := gen_random_uuid();
  qid uuid;
BEGIN

  INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","ImageUrl","UpdatedAt")
  VALUES (
    exam_id,
    'mini-ielts-reading-spider-silk-2',
    'Spider silk 2',
    'IELTS Reading Practice Test from IELTS Mentor',
    'IELTS',
    'B2',
    'PUBLISHED',
    20,
    'http://images.mini-ielts.com/images/2022/12/spider1resizemd_resized.jpg',
    now()
  );

  INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","PassageMd")
  VALUES (
    sec1,
    exam_id,
    1,
    'Reading Passage - Spider silk 2',
    E'**Questions 1-5:**\nWhich section contains the following information?\n\nWrite the correct letter, **A-L**.\n\n---\n\n**Questions 6-10:**\nComplete the sentences below.\n\nWrite **NO MORE THAN TWO WORDS AND/OR A NUMBER** for each answer.\n\n---\n\n**Questions 11-13:**\nDo the following statements agree with the information given in the text?\n\nWrite\n- **TRUE** if the statement agrees with the information\n- **FALSE** if the statement contradicts the information\n- **NOT GIVEN** if there is no information on this',
    E'**Paragraph A.**\\nA strong, light bio-material made by genes from spiders could transform construction and industry\\n\\n**Paragraph B.**\\nScientists have succeeded in copying the silk-producing genes of the Golden Orb Weaver spider and are using them to create a synthetic material which they believe is the model for a new generation of advanced bio-materials. The new material, biosilk, which has been spun for the first time by researchers at DuPont, has an enormous range of potential uses in construction and manufacturing.\\n\\n**Paragraph C.**\\nThe attraction of the silk spun by the spider is a combination of great strength and enormous elasticity, which man-made fibres have been unable to replicate. On an equal-weight basis, spider silk is far stronger than steel and it is estimated that if a single strand could be made about 10m in diameter, it would be strong enough to stop a jumbo jet in flight. A third important factor is that it is extremely light. Army scientists are already looking at the possibilities of using it for lightweight, bulletproof vests and parachutes.\\n\\n**Paragraph D.**\\nFor some time, biochemists have been trying to synthesise the drag-line silk of the Golden Orb Weaver. The drag-line silk, which forms the radial arms of the web, is stronger than the other parts of the web and some biochemists believe a synthetic version could prove to be as important a material as nylon, which has been around for 50 years, since the discoveries of Wallace Carothers and his team ushered in the age of polymers.\\n\\n**Paragraph E.**\\nTo recreate the material, scientists, including Randolph Lewis at the University of Wyoming, first examined the silk-producing gland of the spider. ‘We took out the glands that produce the silk and looked at the coding for the protein material they make, which is spun into a web. We then went looking for clones with the right DNA,’ he says.\\n\\n**Paragraph F.**\\nAt DuPont, researchers have used both yeast and bacteria as hosts to grow the raw material, which they have spun into fibres. Robert Dorsch, DuPont’s director of biochemical development, says the globules of protein, comparable with marbles in an egg, are harvested and processed. ‘We break open the bacteria, separate out the globules of protein and use them as the raw starting material. With yeast, the gene system can be designed so that the material excretes the protein outside the yeast for better access,’ he says.\\n\\n**Paragraph G.**\\n‘The bacteria and the yeast produce the same protein, equivalent to that which the spider uses in the draglines of the web. The spider mixes the protein into a water-based solution and then spins it into a solid fibre in one go. Since we are not as clever as the spider and we are not using such sophisticated organisms, we substituted man-made approaches and dissolved the protein in chemical solvents, which are then spun to push the material through small holes to form the solid fibre.’\\n\\n**Paragraph H.**\\nResearchers at DuPont say they envisage many possible uses for a new biosilk material. They say that earthquake-resistant suspension bridges hung from cables of synthetic spider silk fibres may become a reality. Stronger ropes, safer seat belts, shoe soles that do not wear out so quickly and tough new clothing are among the other applications. Biochemists such as Lewis see the potential range of uses of biosilk as almost limitless. ‘It is very strong and retains elasticity: there are no man-made materials that can mimic both these properties. It is also a biological material with all the advantages that have over petrochemicals,’ he says.\\n\\n**Paragraph I.**\\nAt DuPont’s laboratories, Dorsch is excited by the prospect of new super-strong materials but he warns they are many years away. ‘We are at an early stage but theoretical predictions are that we will wind up with a very strong, tough material, with an ability to absorb shock, which is stronger and tougher than the man-made materials that are conventionally available to us,’ he says.\\n\\n**Paragraph J.**\\nThe spider is not the only creature that has aroused the interest of material scientists. They have also become envious of the natural adhesive secreted by the sea mussel. It produces a protein adhesive to attach itself to rocks. It is tedious and expensive to extract the protein from the mussel, so researchers have already produced a synthetic gene for use in surrogate bacteria.\\n\\n'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    1,
    'MATCHING_INFORMATION',
    'READING',
    2,
    'a comparison of the ways two materials are used to replace silk-producing glands',
    E'**Đáp án: E**\n\n> "They inserted the genes into **bacteria**... They also tried **yeast**..."\n\n(Đoạn E) Tác giả so sánh việc sử dụng hai loại vật liệu sinh học là vi khuẩn (bacteria) và nấm men (yeast) để thay thế tuyến tạo tơ của nhện. Vi khuẩn tạo ra protein nhưng làm hỏng cấu trúc, trong khi nấm men hoạt động tốt hơn.',
    '{"info-q1": ["E", "e"]}'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    2,
    'MATCHING_INFORMATION',
    'READING',
    2,
    'predictions regarding the availability of the synthetic silk',
    E'**Đáp án: H**\n\n> "DuPont... hopes to have the material **available** in the marketplace..."\n\n(Đoạn H) Đoạn này đưa ra dự đoán về khả năng thương mại hóa của sản phẩm. Từ khóa ''available'' (có sẵn) khớp với ''availability'' trong câu hỏi.',
    '{"info-q2": ["H", "h"]}'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    3,
    'MATCHING_INFORMATION',
    'READING',
    2,
    'ongoing research into other synthetic materials',
    E'**Đáp án: I**\n\n> "...researchers... are **looking into other natural materials**..."\n\n(Đoạn I) Tiêu đề này tóm tắt nội dung về các nghiên cứu đang diễn ra (''looking into'') đối với các vật liệu khác ngoài tơ nhện, như vỏ bào ngư hay tơ con trai.',
    '{"info-q3": ["I", "i"]}'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    4,
    'MATCHING_INFORMATION',
    'READING',
    2,
    'the research into the part of the spider that manufactures silk',
    E'**Đáp án: D**\n\n> "biochemists have been trying to **synthesise the drag-line silk**... which forms the radial arms of the web"\n\n(Đoạn D) Đoạn văn nói về nỗ lực nghiên cứu và tổng hợp loại tơ ''drag-line'' (một bộ phận/sản phẩm cụ thể của nhện). Đây là loại tơ bền nhất mà nhện sản xuất.',
    '{"info-q4": ["D", "d"]}'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    5,
    'MATCHING_INFORMATION',
    'READING',
    2,
    'the possible application of the silk in civil engineering',
    E'**Đáp án: G**\n\n> "...used to make lighter and stronger **bridge cables**... earthquake-resistant suspension bridges"\n\n(Đoạn G) Các ứng dụng như làm cáp cầu treo (bridge cables) thuộc lĩnh vực kỹ thuật dân dụng (civil engineering). Câu hỏi yêu cầu tìm ứng dụng trong lĩnh vực này.',
    '{"info-q5": ["G", "g"]}'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    6,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    'Synthetic gene grown in _______ or',
    E'**Đáp án: YEAST**\n\n> "They also tried **yeast**..."\n\n(Đoạn E) Gen tổng hợp được cấy vào nấm men (yeast) hoặc vi khuẩn để sản xuất protein. Câu hỏi yêu cầu điền tên vật liệu nuôi cấy.',
    '{"blank-q6": ["YEAST"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    7,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    'or _______',
    E'**Đáp án: BACTERIA**\n\n> "They inserted the genes into **bacteria**..."\n\n(Đoạn E) Tương tự như câu trên, vi khuẩn (bacteria) là môi trường nuôi cấy khác được nhắc đến trong quy trình tổng hợp gen.',
    '{"blank-q7": ["BACTERIA"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    8,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    'globules of _______ .',
    E'**Đáp án: PROTEIN**\n\n> "The bacteria reproduced... forming an insoluble **protein**."\n\n(Đoạn E) Kết quả của quá trình nuôi cấy trong vi khuẩn là tạo ra các khối ''globules'' của protein không hòa tan. Từ cần điền là danh từ chỉ sản phẩm tạo thành.',
    '{"blank-q8": ["PROTEIN"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    9,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    'dissolved in _______',
    E'**Đáp án: CHEMICAL**\n\n> "...dissolved in a harsh **chemical**..."\n\n(Đoạn E) Protein sau đó được hòa tan trong một loại hóa chất/dung môi mạnh. Từ khóa ''dissolved in'' trong câu hỏi giúp định vị thông tin này.',
    '{"blank-q9": ["CHEMICAL"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    10,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    'passed through _______',
    E'**Đáp án: HOLES**\n\n> "...carefully squirted through tiny **holes**..."\n\n(Đoạn E) Để tạo thành sợi tơ, dung dịch được ép qua các lỗ nhỏ, mô phỏng bộ phận spinneret của nhện. Từ khóa ''passed through'' tương đương với ''squirted through''.',
    '{"blank-q10": ["HOLES"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    11,
    'TRUE_FALSE_NOT_GIVEN',
    'READING',
    2,
    'Biosilk has already replaced nylon in parachute manufacture.',
    E'**Đáp án: FALSE**\n\n> "Army scientists are already **looking at the possibilities** of using it..."\n\n(Đoạn C) Bài đọc chỉ nói các nhà khoa học đang ''xem xét khả năng'' sử dụng, chưa khẳng định nó ''đã thay thế'' (has already replaced) nylon. Lỗi thường gặp: nhầm lẫn giữa kế hoạch tương lai và thực tế hiện tại.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'TRUE', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'FALSE', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'NOT GIVEN', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    12,
    'TRUE_FALSE_NOT_GIVEN',
    'READING',
    2,
    'The spider produces silk of varying strengths.',
    E'**Đáp án: TRUE**\n\n> "The drag-line silk... is **stronger than the other parts** of the web"\n\n(Đoạn D) Việc tơ khung (drag-line) khỏe hơn các phần khác chứng tỏ nhện sản xuất ra các loại tơ có độ bền khác nhau (varying strengths).',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'TRUE', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'FALSE', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'NOT GIVEN', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    13,
    'TRUE_FALSE_NOT_GIVEN',
    'READING',
    2,
    'Lewis and Dorsch co-operated in the synthetic production of silk.',
    E'**Đáp án: NOT GIVEN**\n\nBài đọc có nhắc đến các nghiên cứu và nhà khoa học khác nhau, nhưng **không có thông tin** nào nói rằng Lewis và Dorsch đã hợp tác (co-operated) với nhau trong quá trình sản xuất. Chúng ta không thể suy diễn mối quan hệ nếu bài không đề cập.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'TRUE', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'FALSE', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'NOT GIVEN', true);



  -- Delete old question groups for this exam
  DELETE FROM exam_question_groups WHERE "SectionId" = sec1;

  -- Insert question groups
  INSERT INTO exam_question_groups ("Id","SectionId","Idx","StartIdx","EndIdx","InstructionMd")
  VALUES (gen_random_uuid(), sec1, 1, 1, 5, E'Questions 1-5:**\nWhich section contains the following information?\n\nWrite the correct letter, **A-L**.\n\n---\n\n**');

  INSERT INTO exam_question_groups ("Id","SectionId","Idx","StartIdx","EndIdx","InstructionMd")
  VALUES (gen_random_uuid(), sec1, 2, 6, 10, E'Questions 6-10:**\nComplete the sentences below.\n\nWrite **NO MORE THAN TWO WORDS AND/OR A NUMBER** for each answer.\n\n---\n\n**');

  INSERT INTO exam_question_groups ("Id","SectionId","Idx","StartIdx","EndIdx","InstructionMd")
  VALUES (gen_random_uuid(), sec1, 3, 11, 13, E'Questions 11-13:**\nDo the following statements agree with the information given in the text?\n\nWrite\n- **TRUE** if the statement agrees with the information\n- **FALSE** if the statement contradicts the information\n- **NOT GIVEN** if there is no information on this');

END$$;


COMMIT;