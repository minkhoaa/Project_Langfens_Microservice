-- ============================================
-- IELTS Exam Data Import SQL
-- Generated: 2025-12-25T14:06:36.607184
-- Source: ielts-mentor.com
-- Title: Reading Test 119: Passage 1 - Nutmeg - a valuable spice
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data for slug: ielts-mentor-reading-test-119-passage-1-nutmeg-a-valuable-spice
DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-mentor-reading-test-119-passage-1-nutmeg-a-valuable-spice'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-mentor-reading-test-119-passage-1-nutmeg-a-valuable-spice';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-mentor-reading-test-119-passage-1-nutmeg-a-valuable-spice';
DELETE FROM exams
WHERE "Slug" = 'ielts-mentor-reading-test-119-passage-1-nutmeg-a-valuable-spice';

DO $$
DECLARE
  exam_id uuid := gen_random_uuid();
  sec1 uuid := gen_random_uuid();
  qid uuid;
BEGIN

  INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","ImageUrl","UpdatedAt")
  VALUES (
    exam_id,
    'ielts-mentor-reading-test-119-passage-1-nutmeg-a-valuable-spice',
    'Reading Test 119: Passage 1 - Nutmeg - a valuable spice',
    'IELTS Reading Practice Test from IELTS Mentor',
    'IELTS',
    'B2',
    'PUBLISHED',
    20,
    NULL,
    now()
  );

  INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","PassageMd")
  VALUES (
    sec1,
    exam_id,
    1,
    'Reading Passage - Reading Test 119: Passage 1 - Nutmeg - a valuable spice',
    E'## Questions 1-4\n\nComplete the notes below.\n\nChoose **ONE WORD ONLY** from the passage for each answer.\n\n### The nutmeg tree and fruit\n\n- the leaves of the tree are **1** _______ in shape\n- the **2** _______ surrounds the fruit and breaks open when the fruit is ripe\n- the **3** _______ is used to produce the spice nutmeg\n- the covering known as the aril is used to produce **4** _______\n- the tree has yellow flowers and fruit\n\n---\n\n## Questions 5-7\n\nDo the following statements agree with the information given in Reading Passage?\n\nWrite:\n- **TRUE** if the statement agrees with the information\n- **FALSE** if the statement contradicts the information\n- **NOT GIVEN** if there is no information on this\n\n**5.** In the Middle Ages, most Europeans knew where nutmeg was grown.\n\n**6.** The VOC was the world''s first major trading company.\n\n**7.** Following the Treaty of Breda, the Dutch had control of all the islands where nutmeg grew.\n\n---\n\n## Questions 8-13\n\nComplete the table below.\n\nChoose **ONE WORD ONLY** from the passage for each answer.\n\n| Date | Event |\n|------|-------|\n| Before 1512 | The **8** _______ held a monopoly on nutmeg trading with Europe |\n| 1602 | Dutch East India Company founded; the **9** _______ disease led to increased demand |\n| 1621 | Dutch take control, cover nutmeg with **10** _______ to prevent cultivation elsewhere |\n| 1667 | Treaty of Breda: island of **11** _______ exchanged for Manhattan |\n| 1770 | Pierre Poivre smuggled nutmeg to **12** _______ |\n| 1778 | A **13** _______ destroyed half the nutmeg groves |',
    E'**Paragraph A.**\\n# Reading Test 119: Passage 1 - Nutmeg - a valuable spice & Nutmeg - a valuable spice\n\nThe nutmeg tree, Myristica fragrans, is a large evergreen tree native to Southeast Asia. Until the late 18th century, it only grew in one place in the world: a small group of islands in the Banda Sea, part of the Moluccas – or Spice Islands – in northeastern Indonesia. The tree is thickly branched with dense foliage of tough, dark green oval leaves, and produces small, yellow, bell-shaped flowers and pale yellow pear-shaped fruits. The fruit is encased in a flesh husk. When the fruit is ripe, this husk splits into two halves along a ridge running the length of the fruit. Inside is a purple-brown shiny seed, 2-3 cm long by about 2 cm across, surrounded by a lacy red or crimson covering called an ‘aril’. These are the sources of the two spices nutmeg and mace, the former being produced from the dried seed and the latter from the aril.\n\nNutmeg was a highly prized and costly ingredient in European cuisine in the Middle Ages, and was used as a flavouring, medicinal, and preservative agent. Throughout this period, the Arabs were the exclusive importers of the spice to Europe. They sold nutmeg for high prices to merchants based in Venice, but they never revealed the exact location of the source of this extremely valuable commodity. The Arab-Venetian dominance of the trade finally ended in 1512, when the Portuguese reached the Banda Islands and began exploiting its precious resources.\n\nAlways in danger of competition from neighbouring Spain, the Portuguese began subcontracting their spice distribution to Dutch traders. Profits began to flow into the Netherlands, and the Dutch commercial fleet swiftly grew into one of the largest in the world. The Dutch quietly gained control of most of the shipping and trading of spices in Northern Europe. Then, in 1580, Portugal fell under Spanish rule, and by the end of the 16th century the Dutch found themselves locked out of the market. As prices for pepper, nutmeg, and other spices soared across Europe, they decided to fight back.\n\nIn 1602, Dutch merchants founded the VOC, a trading corporation better known as the Dutch East India Company. By 1617, the VOC was the richest commercial operation in the world. The company had 50,000 employees worldwide, with a private army of 30,000 men and a fleet of 200 ships. At the same time, thousands of people across Europe were dying of the plague, a highly contagious and deadly disease. Doctors were desperate for a way to stop the spread of this disease, and they decided nutmeg held the cure. Everybody wanted nutmeg, and many were willing to spare no expense to have it. Nutmeg bought for a few pennies in Indonesia could be sold for 68,000 times its original cost on the streets of London. The only problem was the short supply. And that’s where the Dutch found their opportunity.\n\nThe Banda Islands were ruled by local sultans who insisted on maintaining a neutral trading policy towards foreign powers. This allowed them to avoid the presence of Portuguese or Spanish troops on their soil, but it also left them unprotected from other invaders. In 1621, the Dutch arrived and took over. Once securely in control of the Bandas, the Dutch went to work protecting their new investment. They concentrated all nutmeg production into a few easily guarded areas, uprooting and destroying any trees outside the plantation zones. Anyone caught growing a nutmeg seedling or carrying seeds without the proper authority was severely punished. In addition, all exported nutmeg was covered with lime to make sure there was no chance a fertile seed which could be grown elsewhere would leave the islands. There was only one obstacle to Dutch domination. One of the Banda Islands, a sliver of land called Run, only 3 km long by less than 1 km wide, was under the control of the British. After decades of fighting for control of this tiny island, the Dutch and British arrived at a compromise settlement, the Treaty of Breda, in 1667. Intent on securing their hold over every nutmeg-producing island, the Dutch offered a trade: if the British would give them the island of Run, they would in turn give Britain a distant and much less valuable island in North America. The British agreed. That other island was Manhattan, which is how New Amsterdam became New York. The Dutch now had a monopoly over the nutmeg trade which would last for another century.\n\nThen, in 1770, a Frenchman named Pierre Poivre successfully smuggled nutmeg plants to safety in Mauritius, an island off the coast of Africa. Some of these were later exported to the Caribbean where they thrived, especially on the island of Grenada. Next, in 1778, a volcanic eruption in the Banda region caused a tsunami that wiped out half the nutmeg groves. Finally, in 1809, the British returned to Indonesia and seized the Banda Islands by force. They returned the islands to the Dutch in 1817, but not before transplanting hundreds of nutmeg seedlings to plantations in several locations across southern Asia. The Dutch nutmeg monopoly was over.\n\nToday, nutmeg is grown in Indonesia, the Caribbean, India, Malaysia, Papua New Guinea and Sri Lanka, and world nutmeg production is estimated to average between 10,000 and 12,000 tonnes per year.'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    1,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    'the leaves of the tree are _______ in shape',
    E'**Đáp án: OVAL**\n\n> "The tree is thickly branched with dense foliage of tough, dark green **oval** leaves..."\n\n(Đoạn 1) Bài đọc mô tả lá cây (leaves) có hình bầu dục (oval). Câu hỏi yêu cầu điền tính từ chỉ hình dáng của lá.',
    '{"blank-q1": ["oval"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    2,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    'the _______ surrounds the fruit and breaks open when the fruit is ripe',
    E'**Đáp án: HUSK**\n\n> "The fruit is encased in a flesh **husk**. When the fruit is ripe, this **husk** splits into two halves..."\n\n(Đoạn 1) Vỏ (husk) bao quanh quả và sẽ tách đôi khi quả chín. Thông tin hoàn toàn khớp với câu hỏi.',
    '{"blank-q2": ["husk"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    3,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    'the _______ is used to produce the spice nutmeg',
    E'**Đáp án: SEED**\n\n> "...sources of the two spices nutmeg and mace, the former being produced from the dried **seed**..."\n\n(Đoạn 1) "The former" ở đây ám chỉ nutmeg, được sản xuất từ hạt (seed) đã phơi khô.',
    '{"blank-q3": ["seed"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    4,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    'the covering known as the aril is used to produce _______',
    E'**Đáp án: MACE**\n\n> "...sources of the two spices nutmeg and mace, ... and the latter from the **aril**."\n\n(Đoạn 1) "The latter" ám chỉ mace, được tạo ra từ lớp vỏ hạt (aril). Câu hỏi yêu cầu tên loại gia vị còn lại.',
    '{"blank-q4": ["mace"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    5,
    'TRUE_FALSE_NOT_GIVEN',
    'READING',
    2,
    'In the Middle Ages, most Europeans knew where nutmeg was grown.',
    E'**Đáp án: FALSE**\n\n> "...they [the Arabs] never revealed the exact location of the source of this extremely valuable commodity."\n\n(Đoạn 2) Người Ả Rập giấu kín vị trí nguồn gốc của nhục đậu khấu, nên người châu Âu không thể biết nơi trồng nó. Điều này trái ngược với câu hỏi (most Europeans knew).',
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
    6,
    'TRUE_FALSE_NOT_GIVEN',
    'READING',
    2,
    'The VOC was the world''s first major trading company.',
    E'**Đáp án: NOT GIVEN**\n\n(Toàn bài) Bài đọc có đề cập đến công ty VOC (Dutch East India Company) ở các đoạn sau, nhưng không có thông tin nào khẳng định đây là công ty thương mại lớn **đầu tiên** (first major) trên thế giới. Do đó không thể kiểm chứng.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'TRUE', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'FALSE', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'NOT GIVEN', true);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    7,
    'TRUE_FALSE_NOT_GIVEN',
    'READING',
    2,
    'Following the Treaty of Breda, the Dutch had control of all the islands where nutmeg grew.',
    E'**Đáp án: TRUE**\n\n> "...giving the Dutch full control of the Banda Islands."\n\n(Đoạn nói về Treaty of Breda) Sau hiệp ước Breda, Anh nhường đảo Run cho Hà Lan, giúp Hà Lan kiểm soát toàn bộ các đảo trồng nhục đậu khấu. Thông tin khớp với câu hỏi.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'TRUE', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'FALSE', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'NOT GIVEN', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    8,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    'Before 1512, the _______ held a monopoly on nutmeg trading with Europe.',
    E'**Đáp án: ARABS**\n\n> "Throughout this period, the **Arabs** were the exclusive importers of the spice to Europe."\n\n(Đoạn 2) Người Ả Rập là những nhà nhập khẩu độc quyền gia vị này vào châu Âu thời Trung Cổ.',
    '{"blank-q8": ["Arabs"]}'::jsonb
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
    'The _______ disease led to increased European demand for nutmeg.',
    E'**Đáp án: PLAGUE**\n\n> "Doctors believed nutmeg could cure the **plague**."\n\n(Đoạn về London) Người ta tin rằng nhục đậu khấu có thể chữa được bệnh dịch hạch, khiến giá cả tăng vọt.',
    '{"blank-q9": ["plague"]}'::jsonb
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
    'The Dutch covered exported nutmeg with _______ to prevent its cultivation elsewhere.',
    E'**Đáp án: LIME**\n\n> "...all exported nutmeg was covered with **lime** to make sure there was no chance a fertile seed which could be grown elsewhere would leave the islands."\n\n(Đoạn về Dutch control) Người Hà Lan phủ vôi lên hạt để ngăn chúng nảy mầm ở nơi khác.',
    '{"blank-q10": ["lime"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    11,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    'The island of _______ was exchanged for Manhattan.',
    E'**Đáp án: RUN**\n\n> "...in return for the British giving the island of **Run** to the Dutch."\n\n(Đoạn về Treaty of Breda) Người Anh trao quyền kiểm soát đảo Run cho Hà Lan để đổi lấy một thuộc địa khác ở Bắc Mỹ.',
    '{"blank-q11": ["Run"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    12,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    'Pierre Poivre smuggled nutmeg plants to _______.',
    E'**Đáp án: MAURITIUS**\n\n> "...smuggled nutmeg plants to safety in **Mauritius**."\n\n(Đoạn về Pierre Poivre) Một người Pháp đã lén mang hạt giống đến trồng thành công tại Mauritius.',
    '{"blank-q12": ["Mauritius"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    13,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    'A _______ destroyed half the nutmeg groves in the Banda region.',
    E'**Đáp án: TSUNAMI**\n\n> "...half the nutmeg groves were torn up by a **tsunami**."\n\n(Đoạn cuối) Một trận sóng thần đã phá hủy một nửa số vườn cây nhục đậu khấu, phá vỡ sự độc quyền của Hà Lan.',
    '{"blank-q13": ["tsunami"]}'::jsonb
  );



  -- Delete old question groups for this exam
  DELETE FROM exam_question_groups WHERE "SectionId" = sec1;

  -- Insert question groups
  INSERT INTO exam_question_groups ("Id","SectionId","Idx","StartIdx","EndIdx","InstructionMd")
  VALUES (gen_random_uuid(), sec1, 1, 1, 4, E'## Questions 1-4\n\nComplete the notes below.\n\nChoose **ONE WORD ONLY** from the passage for each answer.\n\n### The nutmeg tree and fruit\n\n- the leaves of the tree are **1** _______ in shape\n- the **2** _______ surrounds the fruit and breaks open when the fruit is ripe\n- the **3** _______ is used to produce the spice nutmeg\n- the covering known as the aril is used to produce **4** _______\n- the tree has yellow flowers and fruit');

  INSERT INTO exam_question_groups ("Id","SectionId","Idx","StartIdx","EndIdx","InstructionMd")
  VALUES (gen_random_uuid(), sec1, 2, 5, 7, E'## Questions 5-7\n\nDo the following statements agree with the information given in Reading Passage?\n\nWrite:\n- **TRUE** if the statement agrees with the information\n- **FALSE** if the statement contradicts the information\n- **NOT GIVEN** if there is no information on this\n\n**5.** In the Middle Ages, most Europeans knew where nutmeg was grown.\n\n**6.** The VOC was the world''s first major trading company.\n\n**7.** Following the Treaty of Breda, the Dutch had control of all the islands where nutmeg grew.');

  INSERT INTO exam_question_groups ("Id","SectionId","Idx","StartIdx","EndIdx","InstructionMd")
  VALUES (gen_random_uuid(), sec1, 3, 8, 13, E'## Questions 8-13\n\nComplete the table below.\n\nChoose **ONE WORD ONLY** from the passage for each answer.\n\n| Date | Event |\n|------|-------|\n| Before 1512 | The **8** _______ held a monopoly on nutmeg trading with Europe |\n| 1602 | Dutch East India Company founded; the **9** _______ disease led to increased demand |\n| 1621 | Dutch take control, cover nutmeg with **10** _______ to prevent cultivation elsewhere |\n| 1667 | Treaty of Breda: island of **11** _______ exchanged for Manhattan |\n| 1770 | Pierre Poivre smuggled nutmeg to **12** _______ |\n| 1778 | A **13** _______ destroyed half the nutmeg groves |');

END$$;


COMMIT;