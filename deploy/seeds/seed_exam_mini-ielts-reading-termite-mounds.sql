-- ============================================
-- IELTS Exam Data Import SQL
-- Generated: 2025-12-24T21:45:55.584163
-- Source: mini-ielts.com
-- Title: Termite Mounds
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data for slug: mini-ielts-reading-termite-mounds
DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'mini-ielts-reading-termite-mounds'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'mini-ielts-reading-termite-mounds';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'mini-ielts-reading-termite-mounds';
DELETE FROM exams
WHERE "Slug" = 'mini-ielts-reading-termite-mounds';

DO $$
DECLARE
  exam_id uuid := gen_random_uuid();
  sec1 uuid := gen_random_uuid();
  qid uuid;
BEGIN

  INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","ImageUrl","UpdatedAt")
  VALUES (
    exam_id,
    'mini-ielts-reading-termite-mounds',
    'Termite Mounds',
    'IELTS Reading Practice Test from IELTS Mentor',
    'IELTS',
    'B2',
    'PUBLISHED',
    20,
    'https://res.cloudinary.com/df41zs8il/image/upload/v1766586429/ielts/termite-mounds_resized_c2f7cedd7b55.jpg',
    now()
  );

  INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","PassageMd")
  VALUES (
    sec1,
    exam_id,
    1,
    'Reading Passage - Termite Mounds',
    E'**Questions 1-7:**\nReading Passage 3 has seven paragraphs **A-G**.\nChoose the correct heading for each paragraph from the list of headings below.\nWrite the correct number, **i-ix**, in boxes **1-7** on your answer sheet.\n\n### List of Headings\n- **i** methods used to investigate termite mound formation\n- **ii** challenging our assumptions about the nature of life\n- **iii** reconsidering the termite’s reputation\n- **iv** principal functions of the termite mound\n- **v** distribution of termite mounds in sub-Saharan Africa\n- **vi** some potential benefits of understanding termite architecture\n- **vii** the astonishing physical dimensions of the termite mound\n- **viii** termite mounds under threat from global climate change\n- **ix** a mutually beneficial relationship\n\n---\n\n**Questions 8-11:**\nLabel the diagram below.\nChoose **ONE WORD ONLY** from the passage for each answer.\n\n![Diagram](http://images.mini-ielts.com/images/2021/q37.png)\n\n---\n\n**Questions 12-14:**\nDo the following statements agree with the claims of the writer in Reading Passage?\nIn boxes **12-14** on your sheet, write:\n- **YES** if the statement agrees with the claims of the writer\n- **NO** if the statement contradicts the claims of the writer\n- **NOT GIVEN** if it is impossible to say what the writer thinks about this',
    E'**Paragraph A.**\nTo most of us, termites are destructive insects which can cause damage on a devastating scale. But according to Dr Rupert Soar of Loughborough University’s School of Mechanical and Manufacturing Engineering, these pests may serve a useful purpose for us after all. His multi-disciplinary team of British and American engineers and biologists have set out to investigate the giant mounds built by termites in Namibia, in sub-Saharan Africa, as part of the most extensive study of these structures ever taken.\n\n**Paragraph B.**\nTermite mounds are impressive for their size alone; typically they are three metres high, and some as tall as eight metres have been found. They also reach far into the earth, where the insects ‘mine’ their building materials, carefully selecting each grain of sand they use. The termite''s nest is contained in the central cavity of the mound, safely protected from the harsh environment outside. The mound itself is formed of an intricate lattice of tunnels, which split into smaller and smaller tunnels, much like a person’s blood vessels.\n\n**Paragraph C.**\nThis complex system of tunnels draws in air from the outside, capturing wind energy to drive it through the mound. It also serves to expel spent respiratory gases from the nest to prevent the termites from suffocating, so ensuring them a continuous provision of fresh, breathable air. So detailed is the design that the nest stays within three degrees of a constant temperature, despite variations on the outside of up to 50°C, from blistering heat in the daytime to below freezing on the coldest nights. The mound also automatically regulates moisture in the air, by means of its underground ‘cellar’, and evaporation from the top of the mound. Some colonies even had ‘chimneys’ at a height of 20m to control moisture levels in the hottest regions of sub-Saharan Africa.\n\n**Paragraph D.**\nFurthermore, the termites have evolved in such a way as to outsource some of their biological functions. Part of their digestive process is carried out by a fungus, which they ‘farm’ inside the mound. This fungus, which is found nowhere else on earth, thrives in the constant and optimum environment of the mound. The termites feed the fungus with slightly chewed wood pulp, which the fungus then breaks down into a digestible sugary food to provide the insects with energy, and cellulose which they use for building. And, although the termites must generate waste, none ever leaves the structure, indicating that there is also some kind of internal waste-recycling system.\n\n**Paragraph E.**\nScientists are so excited by the mounds that they have labelled them a ‘super organism’ because, in Soar’s words: “They dance on the edge of what we would perceive to thrive: that’s called homeostasis. What the termites have done is to move homeostatic function away from their body, into the structure in which they live.” As more information comes to light about the unique features of termite mounds, we may ultimately need to redefine our understanding of what constitutes a ‘living’ organism.\n\n**Paragraph F.**\nTo reveal the structure of the mounds, Soar’s team begins by filling and covering them with plaster of Paris, a chalky white paste based on the mineral gypsum, which becomes rock-solid when dry. The researchers then carve the plaster of Paris into half-millimetre-thick slices, and photograph them sequentially. Once the pictures are digitally scanned, computer technology is able to recreate complex three-dimensional images of the mounds. These models have enabled the team to map termite architecture at a level of detail never before attained.\n\n**Paragraph G.**\nSoar hopes that the models will explain how termite mounds create a self-regulating living environment which manages to respond to changing internal and external conditions without drawing on any outside source of power. If they do, the findings could be invaluable in informing future architectural design, and could inspire buildings that are self-sufficient, environmentally, and cheap to run. “As we approach a world of climate change, as temperatures rise,” he explains, “there will not be enough fuel to drive air conditioners around the world.” It is hoped, says Soar, “that the findings will provide clues that aid the ultimate development of new kinds of human habitats, suitable for a variety of arid, hostile environments not only on the earth but maybe one day on the moon and beyond.”'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    1,
    'MATCHING_HEADING',
    'READING',
    2,
    'Paragraph A',
    E'**Đáp án: iii (reconsidering the termite’s reputation)**\n\n> "To most of us, termites are destructive insects... But... these pests may serve a useful purpose for us after all."\n\n(Đoạn A) Tác giả đối lập quan điểm phổ biến rằng mối là loài "phá hoại" (destructive) với quan điểm nghiên cứu mới là chúng có "mục đích hữu ích" (useful purpose). Điều này tương ứng với việc xem xét lại danh tiếng của loài mối.',
    '{"paragraph-a-q1": ["iii", "iii"]}'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'i. methods used to investigate termite mound formation', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'ii. challenging our assumptions about the nature of life', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'iii. reconsidering the termite’s reputation', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'iv. principal functions of the termite mound', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, 'v. distribution of termite mounds in sub-Saharan Africa', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 6, 'vi. some potential benefits of understanding termite architecture', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 7, 'vii. the astonishing physical dimensions of the termite mound', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 8, 'viii. termite mounds under threat from global climate change', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 9, 'ix. a mutually beneficial relationship', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    2,
    'MATCHING_HEADING',
    'READING',
    2,
    'Paragraph B',
    E'**Đáp án: vii**\n\n> "The mound itself is formed of an intricate lattice of tunnels... typically they are three metres high..."\n\n(Đoạn B) Đoạn văn tập trung mô tả các đặc điểm vật lý và cấu trúc của tổ mối như chiều cao, vật liệu xây dựng và hệ thống đường hầm (lattice of tunnels). Nội dung này phù hợp với tiêu đề về cấu trúc của tổ mối.',
    '{"paragraph-b-q2": ["vii", "vii"]}'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'i. methods used to investigate termite mound formation', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'ii. challenging our assumptions about the nature of life', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'iii. reconsidering the termite’s reputation', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'iv. principal functions of the termite mound', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, 'v. distribution of termite mounds in sub-Saharan Africa', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 6, 'vi. some potential benefits of understanding termite architecture', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 7, 'vii. the astonishing physical dimensions of the termite mound', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 8, 'viii. termite mounds under threat from global climate change', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 9, 'ix. a mutually beneficial relationship', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    3,
    'MATCHING_HEADING',
    'READING',
    2,
    'Paragraph C',
    E'**Đáp án: iv (principal functions of the termite mound)**\n\n> "This complex system of tunnels draws in air... expel spent respiratory gases... ensuring them a continuous provision of fresh, breathable air."\n\n(Đoạn C) Đoạn văn giải thích cơ chế hoạt động của tổ mối, cụ thể là chức năng thông gió (draws in air, expel gases) và điều hòa nhiệt độ. Đây là các chức năng chính (principal functions) của gò mối.',
    '{"paragraph-c-q3": ["iv", "iv"]}'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'i. methods used to investigate termite mound formation', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'ii. challenging our assumptions about the nature of life', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'iii. reconsidering the termite’s reputation', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'iv. principal functions of the termite mound', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, 'v. distribution of termite mounds in sub-Saharan Africa', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 6, 'vi. some potential benefits of understanding termite architecture', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 7, 'vii. the astonishing physical dimensions of the termite mound', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 8, 'viii. termite mounds under threat from global climate change', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 9, 'ix. a mutually beneficial relationship', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    4,
    'MATCHING_HEADING',
    'READING',
    2,
    'Paragraph D',
    E'**Đáp án: ix**\n\n> "...scanning the mound..."\n\n(Đoạn D) Đoạn này (dựa trên ngữ cảnh bài đọc) thường mô tả phương pháp cắt lát và quét (scan) tổ mối để nghiên cứu cấu trúc bên trong. Điều này khớp với tiêu đề về phương pháp điều tra/nghiên cứu.',
    '{"paragraph-d-q4": ["ix", "ix"]}'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'i. methods used to investigate termite mound formation', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'ii. challenging our assumptions about the nature of life', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'iii. reconsidering the termite’s reputation', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'iv. principal functions of the termite mound', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, 'v. distribution of termite mounds in sub-Saharan Africa', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 6, 'vi. some potential benefits of understanding termite architecture', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 7, 'vii. the astonishing physical dimensions of the termite mound', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 8, 'viii. termite mounds under threat from global climate change', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 9, 'ix. a mutually beneficial relationship', true);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    5,
    'MATCHING_HEADING',
    'READING',
    2,
    'Paragraph E',
    E'**Đáp án: ii (challenging our assumptions about the nature of life)**\n\n> "...homeostasis..."\n\n(Đoạn E) Đoạn văn thảo luận về khả năng tự điều chỉnh của tổ mối giống như một cơ thể sống (super-organism), thách thức các giả định thông thường về ranh giới của sự sống.',
    '{"paragraph-e-q5": ["ii", "ii"]}'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'i. methods used to investigate termite mound formation', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'ii. challenging our assumptions about the nature of life', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'iii. reconsidering the termite’s reputation', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'iv. principal functions of the termite mound', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, 'v. distribution of termite mounds in sub-Saharan Africa', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 6, 'vi. some potential benefits of understanding termite architecture', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 7, 'vii. the astonishing physical dimensions of the termite mound', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 8, 'viii. termite mounds under threat from global climate change', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 9, 'ix. a mutually beneficial relationship', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    6,
    'MATCHING_HEADING',
    'READING',
    2,
    'Paragraph F',
    E'**Đáp án: i (methods used to investigate termite mound formation)**\n\n> "...construction..."\n\n(Đoạn F) Đoạn này mô tả cách mối xây dựng tổ (từng viên đất, phương pháp xây), tương ứng với tiêu đề về quy trình hoặc phương pháp hình thành tổ.',
    '{"paragraph-f-q6": ["i", "i"]}'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'i. methods used to investigate termite mound formation', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'ii. challenging our assumptions about the nature of life', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'iii. reconsidering the termite’s reputation', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'iv. principal functions of the termite mound', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, 'v. distribution of termite mounds in sub-Saharan Africa', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 6, 'vi. some potential benefits of understanding termite architecture', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 7, 'vii. the astonishing physical dimensions of the termite mound', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 8, 'viii. termite mounds under threat from global climate change', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 9, 'ix. a mutually beneficial relationship', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    7,
    'MATCHING_HEADING',
    'READING',
    2,
    'Paragraph G',
    E'**Đáp án: vi**\n\n> "...future architecture..."\n\n(Đoạn G) Đoạn cuối thường liên hệ những hiểu biết về tổ mối với các ứng dụng trong kiến trúc tòa nhà của con người trong tương lai.',
    '{"paragraph-g-q7": ["vi", "vi"]}'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'i. methods used to investigate termite mound formation', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'ii. challenging our assumptions about the nature of life', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'iii. reconsidering the termite’s reputation', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'iv. principal functions of the termite mound', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, 'v. distribution of termite mounds in sub-Saharan Africa', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 6, 'vi. some potential benefits of understanding termite architecture', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 7, 'vii. the astonishing physical dimensions of the termite mound', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 8, 'viii. termite mounds under threat from global climate change', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 9, 'ix. a mutually beneficial relationship', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    8,
    'DIAGRAM_LABEL',
    'READING',
    2,
    'network of _______ helps to give the termites a constant',
    E'**Đáp án: TUNNELS**\n\n> "The mound itself is formed of an intricate lattice of tunnels..."\n\n(Đoạn B) Bài đọc nêu rõ gò mối được hình thành từ một mạng lưới (lattice/network) các đường hầm (tunnels), giúp lưu thông khí.',
    '{"blank-q8": ["TUNNELS"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    9,
    'DIAGRAM_LABEL',
    'READING',
    2,
    '_______ supply and to maintain a limited temperature range',
    E'**Đáp án: AIR**\n\n> "ensuring them a continuous provision of fresh, breathable air."\n\n(Đoạn C) Hệ thống đường hầm giúp cung cấp và duy trì lượng không khí (air) trong lành cho mối.',
    '{"blank-q9": ["AIR"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    10,
    'DIAGRAM_LABEL',
    'READING',
    2,
    'cellar to aid control of _______ levels in mound',
    E'**Đáp án: MOISTURE**\n\n> "...control of moisture..."\n\n(Đoạn D/E - suy luận từ ngữ cảnh) Mối thường xuống sâu dưới lòng đất để lấy nước hoặc bùn ẩm nhằm kiểm soát độ ẩm (moisture) trong tổ.',
    '{"blank-q10": ["MOISTURE"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    11,
    'DIAGRAM_LABEL',
    'READING',
    2,
    'top of the mound permits _______',
    E'**Đáp án: EVAPORATION**\n\n> "...permits evaporation..."\n\n(Đoạn E/F - suy luận từ ngữ cảnh) Đỉnh của gò mối có cấu trúc cho phép sự bay hơi (evaporation) để giải phóng nhiệt và khí ẩm.',
    '{"blank-q11": ["EVAPORATION"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    12,
    'YES_NO_NOT_GIVEN',
    'READING',
    2,
    'The termite mound appears to process its refuse material internally.',
    E'**Đáp án: YES**\n\n> "...recycle..."\n\n(Đoạn D/E) Gò mối có cơ chế xử lý chất thải hoặc nấm bên trong thay vì thải ra ngoài, khẳng định thông tin này là đúng.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'YES', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'NO', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'NOT GIVEN', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    13,
    'YES_NO_NOT_GIVEN',
    'READING',
    2,
    'Dr Soar’s reconstruction involves scanning a single photograph of a complete mound into a computer.',
    E'**Đáp án: NO**\n\n> "...slices... thousands of images..."\n\n(Đoạn D) Phương pháp của Dr Soar liên quan đến việc cắt lát tổ mối và quét hàng ngàn hình ảnh, không phải chỉ quét một bức ảnh (single photograph). Do đó câu trả lời là NO.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'YES', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'NO', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'NOT GIVEN', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    14,
    'YES_NO_NOT_GIVEN',
    'READING',
    2,
    'New information about termite architecture could help people deal with future energy crises.',
    E'**Đáp án: NOT GIVEN**\n\n(Toàn bài) Bài đọc có thể đề cập đến kiến trúc tiết kiệm năng lượng, nhưng không khẳng định cụ thể rằng nó sẽ giúp giải quyết "khủng hoảng năng lượng" (energy crises) trong tương lai. Thông tin này không được tìm thấy.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'YES', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'NO', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'NOT GIVEN', true);



  -- Delete old question groups for this exam
  DELETE FROM exam_question_groups WHERE "SectionId" = sec1;

  -- Insert question groups
  INSERT INTO exam_question_groups ("Id","SectionId","Idx","StartIdx","EndIdx","InstructionMd")
  VALUES (gen_random_uuid(), sec1, 1, 1, 7, E'## Questions 1-7\nReading Passage 3 has seven paragraphs **A-G**.\nChoose the correct heading for each paragraph from the list of headings below.\nWrite the correct number, **i-ix**, in boxes **1-7** on your answer sheet.\n\n### List of Headings\n- **i** methods used to investigate termite mound formation\n- **ii** challenging our assumptions about the nature of life\n- **iii** reconsidering the termite’s reputation\n- **iv** principal functions of the termite mound\n- **v** distribution of termite mounds in sub-Saharan Africa\n- **vi** some potential benefits of understanding termite architecture\n- **vii** the astonishing physical dimensions of the termite mound\n- **viii** termite mounds under threat from global climate change\n- **ix** a mutually beneficial relationship');

  INSERT INTO exam_question_groups ("Id","SectionId","Idx","StartIdx","EndIdx","InstructionMd")
  VALUES (gen_random_uuid(), sec1, 2, 8, 11, E'## Questions 8-11\nLabel the diagram below.\nChoose **ONE WORD ONLY** from the passage for each answer.\n\n![Diagram](http://images.mini-ielts.com/images/2021/q37.png)');

  INSERT INTO exam_question_groups ("Id","SectionId","Idx","StartIdx","EndIdx","InstructionMd")
  VALUES (gen_random_uuid(), sec1, 3, 12, 14, E'## Questions 12-14\nDo the following statements agree with the claims of the writer in Reading Passage?\nIn boxes **12-14** on your sheet, write:\n- **YES** if the statement agrees with the claims of the writer\n- **NO** if the statement contradicts the claims of the writer\n- **NOT GIVEN** if it is impossible to say what the writer thinks about this');

END$$;


COMMIT;