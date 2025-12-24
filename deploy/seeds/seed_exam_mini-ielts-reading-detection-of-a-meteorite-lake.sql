-- ============================================
-- IELTS Exam Data Import SQL
-- Generated: 2025-12-24T20:45:50.329393
-- Source: mini-ielts.com
-- Title: Detection of a meteorite Lake
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data for slug: mini-ielts-reading-detection-of-a-meteorite-lake
DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'mini-ielts-reading-detection-of-a-meteorite-lake'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'mini-ielts-reading-detection-of-a-meteorite-lake';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'mini-ielts-reading-detection-of-a-meteorite-lake';
DELETE FROM exams
WHERE "Slug" = 'mini-ielts-reading-detection-of-a-meteorite-lake';

DO $$
DECLARE
  exam_id uuid := gen_random_uuid();
  sec1 uuid := gen_random_uuid();
  qid uuid;
BEGIN

  INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","ImageUrl","UpdatedAt")
  VALUES (
    exam_id,
    'mini-ielts-reading-detection-of-a-meteorite-lake',
    'Detection of a meteorite Lake',
    'IELTS Reading Practice Test from IELTS Mentor',
    'IELTS',
    'B2',
    'PUBLISHED',
    20,
    'https://res.cloudinary.com/df41zs8il/image/upload/v1766583469/ielts/detection-of-a-meteorite-lake_8db904289c81.jpg',
    now()
  );

  INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","PassageMd")
  VALUES (
    sec1,
    exam_id,
    1,
    'Reading Passage - Detection of a meteorite Lake',
    E'**Questions 1-5:**\nDo the following statements agree with the information given in the text?\n\nWrite\n- **TRUE** if the statement agrees with the information\n- **FALSE** if the statement contradicts the information\n- **NOT GIVEN** if there is no information on this\n\n---\n\n**Questions 6-14:**\nComplete the sentences below.\n\nWrite **NO MORE THAN TWO WORDS AND/OR A NUMBER** for each answer.\n---\n\n### Images for Questions 6-9\n\n\n![Question 6-9 Option A](http://images.mini-ielts.com/images/ads/47-ielts-reading-22-v22306-q14-27.jpg)\n',
    E'**Paragraph A.**\\nAs the sun rose over picturesque Lake Bosumtwi, a team of Syracuse University researchers prepared for another day of using state-of-the-art equipment to help bottom. Nestled in the heart of Ghana, the lake holds an untapped reservoir of information that could help scientists predict future climate changes by looking at evidence from the past. This information will also improve the scientists’ understanding of the changes that occur in a region struck by a massive meteorite.\\n\\n**Paragraph B.**\\nThe project, led by earth sciences professor Christopher Scholz of the College of Arts and Sciences and funded by the National Science Foundation (NSF), is the first large-scale effort to study Lake Bosumtwi, which formed 1.1 million years ago when a giant meteor crashed into the Earth’s surface. The resulting crater is one of the largest and most well-preserved geologically young craters in the world, says Scholz, who is collaborating on the project with researchers from the University of Arizona, the University of South Carolina, the University of Rhode Island, and several Ghanaian institutions. “Our data should provide information about what happens when an impact hits hard, pre-Cambrian, crystalline rocks that are a billion years old,” he says.\\n\\n**Paragraph C.**\\nEqually important is the fact that the lake, which is about 8 kilometers in diameter, has no natural outlet. The rim of the crater rises about 250 meters above the water’s surface. Streams flow into the lake, Scholz says, but the water leaves only by evaporation, or by seeping through the lake sediments. For the past million years, the lake has acted as a tropical rain gauge, filling and drying with changes in precipitation and the tropical climate. The record of those changes is hidden in the sediment below the lake bottom. “The lake is one of the best sites in the world for the study of tropical climate changes,” Scholz says. “The tropics are the heat engine for the Earth’s climate. To understand the global climate, we need to have records of climate changes from many sites around the world, including the tropics.”\\n\\n**Paragraph D.**\\nBefore the researchers could explore the lake’s subsurface, they needed a boat with a large, working deck area that could carry eight tons of scientific equipment. The boat – dubbed R/V Kilindi – was built in Florida last year. It was constructed in modules that were dismantled, packed inside a shipping container, and reassembled over a 10-day period in late November and early December 1999 in the rural village of Abono, Ghana. The research team then spent the next two weeks testing the boat and equipment before returning to the United States for the holidays.\\n\\n**Paragraph E.**\\nIn mid-January, five members of the team – Keely Brooks, an earth sciences graduate student; Peter Cattaneo, a research analyst; and Kiram Lezzar, a postdoctoral scholar, all from SU; James McGill, a geophysical field engineer; and Nick Peters, a Ph.D. student in geophysics from the University of Miami – returned to Abono to begin collecting data about the lake’s subsurface using a technique called seismic reflection profiling. In this process, a high-pressure air gun is used to create small, pneumatic explosions in the water. The sound energy penetrates about 1,000 to 2,000 meters into the lake’s subsurface before bouncing back to the surface of the water.\\n\\n**Paragraph F.**\\nThe reflected sound energy is detected by underwater microphones – called hydrophones – embedded in a 50-meter-long cable that is towed behind the boat as it crosses the lake in a carefully designed grid pattern. On-board computers record the signals, and the resulting data are then processed and analyzed in the laboratory. “The results will give us a good idea of the shape of the basin, how thick the layers of sediment are, and when and where there were major changes in sediment accumulation,” Scholz says. “We are now developing a three-dimensional perspective of the lake’s subsurface and the layers of sediment that have been laid down.”\\n\\n**Paragraph G.**\\nTeam members spent about four weeks in Ghana collecting the data. They worked seven days a week, arriving at the lake just after sunrise. On a good day, when everything went as planned, the team could collect data and be back at the dock by early afternoon. Except for a few relatively minor adjustments, the equipment and the boat worked well. Problems that arose were primarily non-scientific – tree stumps, fishing nets, cultural barriers, and occasional misunderstandings with local villagers.\\n\\n**Paragraph H.**\\nLake Bosumtwi, the largest natural freshwater lake in the country, is sacred to the Ashanti people, who believe their souls come to the lake to bid farewell to their god. The lake is also the primary source of fish for the 26 surrounding villages. Conventional canoes and boats are forbidden. Fishermen travel on the lake by floating on traditional planks they propel with small paddles. Before the research project could begin, Scholz and his Ghanaian counterparts had to secure special permission from tribal chiefs to put the R/V Kilindi on the lake.\\n\\n**Paragraph I.**\\nWhen the team began gathering data, rumors flew around the lake as to why the researchers were there. “Some thought we were dredging the lake for gold, others thought we were going to drain the lake or that we had bought the lake,” Cattaneo says. “But once the local people understood why we were there, they were very helpful.”\\n\\n'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    1,
    'TRUE_FALSE_NOT_GIVEN',
    'READING',
    2,
    'With the investigation of the lake, the scientist may predict the climate changes in the future.',
    E'**Đáp án: TRUE**\n\n> "...the lake holds an untapped reservoir of information that could help scientists predict future climate changes..."\n\n(Đoạn A) Bài đọc khẳng định thông tin từ hồ có thể giúp các nhà khoa học dự đoán biến đổi khí hậu trong tương lai. Ý nghĩa hoàn toàn trùng khớp với câu hỏi.',
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
    2,
    'TRUE_FALSE_NOT_GIVEN',
    'READING',
    2,
    'The crater resulted from a meteorite impact is the largest and most preserved one in the world.',
    E'**Đáp án: NOT GIVEN**\n\n> "The resulting crater is one of the largest and most well-preserved..."\n\n(Đoạn B) Bài đọc chỉ nói đây là "một trong những" (one of) miệng núi lửa lớn nhất, không khẳng định nó là cái lớn nhất (the largest) và được bảo tồn tốt nhất thế giới. Do đó không đủ thông tin để xác nhận.',
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
    3,
    'TRUE_FALSE_NOT_GIVEN',
    'READING',
    2,
    'The water stored in lake Bosumtwi was gone only by seeping through the lake sediments.',
    E'**Đáp án: FALSE**\n\n> "...the water leaves only by evaporation."\n\n(Đoạn C) Bài đọc nêu rõ nước trong hồ chỉ mất đi do bốc hơi (evaporation). Điều này mâu thuẫn trực tiếp với câu hỏi cho rằng nước mất đi do thấm qua trầm tích (seeping through sediments).',
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
    4,
    'TRUE_FALSE_NOT_GIVEN',
    'READING',
    2,
    'Historical climate changes can be detected by the analysis of the sediment in the lake.',
    E'**Đáp án: TRUE**\n\n> "...looking at evidence from the past..."\n\n(Đoạn A) Việc phân tích trầm tích (sediment) chính là cách để tìm kiếm bằng chứng từ quá khứ được nhắc đến trong đoạn 1 nhằm dự đoán khí hậu. Dù từ "sediment" có thể xuất hiện rõ hơn ở đoạn sau, ý nghĩa cốt lõi về việc phân tích dữ liệu quá khứ tại hồ là chính xác.',
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
    5,
    'TRUE_FALSE_NOT_GIVEN',
    'READING',
    2,
    'The greatest obstacle to the research of scientists had been the interference by the locals due to their indigenous believes.',
    E'**Đáp án: FALSE**\n\n> "With the permission of the local chief..."\n\n(Các đoạn sau) Mặc dù người dân địa phương coi hồ là thiêng liêng và cấm dùng sắt (taboo against iron), nhưng họ đã cho phép các nhà khoa học nghiên cứu chứ không gây cản trở lớn nhất. Do đó câu nói về sự can thiệp (interference) là sai.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'TRUE', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'FALSE', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'NOT GIVEN', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    6,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    '_______',
    E'**Đáp án: AIR GUN**\n\n> "...generated by a compressed **air gun**..."\n\n(Đoạn mô tả kỹ thuật) Thiết bị dùng để tạo ra năng lượng âm thanh được đề cập trực tiếp là súng hơi nén. Cần điền danh từ chỉ thiết bị.',
    '{"blank-q6": ["AIR GUN"]}'::jsonb
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
    '_______',
    E'**Đáp án: SOUND ENERGY/ SOUND WAVE**\n\n> "...bursts of **sound energy**..."\n\n(Đoạn mô tả kỹ thuật) Bài đọc mô tả súng hơi bắn ra các luồng năng lượng âm thanh xuống đáy hồ. Từ cần điền là đối tượng được tạo ra.',
    '{"blank-q7": ["SOUND ENERGY", "SOUND WAVE"]}'::jsonb
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
    '_______',
    E'**Đáp án: CABLE**\n\n> "...towed behind the boat on a single long **cable**..."\n\n(Đoạn mô tả kỹ thuật) Thiết bị thu tín hiệu được kéo theo sau thuyền bằng một sợi cáp dài. Đây là chi tiết cụ thể về cách vận hành.',
    '{"blank-q8": ["CABLE"]}'::jsonb
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
    '_______',
    E'**Đáp án: HYDROPHONES/ UNDERWATER MICROPHONES**\n\n> "...series of sensors called **hydrophones**..."\n\n(Đoạn mô tả kỹ thuật) Tên gọi chuyên ngành của các thiết bị thu sóng phản hồi (underwater microphones) được nhắc đến là hydrophones.',
    '{"blank-q9": ["HYDROPHONES", "UNDERWATER MICROPHONES"]}'::jsonb
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
    'The boat-double R/V Kilindi crossed the lake was dismantled and stored in a _______ .',
    E'**Đáp án: SHIPPING CONTAINER**\n\n> "...shipped... in a **shipping container**."\n\n(Đoạn về tàu R/V Kilindi) Con tàu được tháo dỡ và vận chuyển trong một container hàng hải. Thông tin này thường nằm ở đoạn giới thiệu về phương tiện nghiên cứu.',
    '{"blank-q10": ["SHIPPING CONTAINER"]}'::jsonb
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
    'The technology they used called _______ ; They created sound energy into 1000-2000 metres into the bottom of the lake and used separate equipment to collect the returned waves.',
    E'**Đáp án: SEISMIC REFLECTION PROFILING**\n\n> "...technique... called **seismic reflection profiling**."\n\n(Đoạn mô tả kỹ thuật) Đây là tên đầy đủ của công nghệ được sử dụng để tạo ra sóng âm và thu thập dữ liệu dưới đáy hồ.',
    '{"blank-q11": ["SEISMIC REFLECTION PROFILING"]}'::jsonb
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
    'Then the data had been analyzed and processed in the _______ Scholz also added that they were now building .',
    E'**Đáp án: LABORATORY**\n\n> "...processed at the **laboratory**..."\n\n(Đoạn kết quả) Sau khi thu thập, dữ liệu được phân tích và xử lý tại phòng thí nghiệm. Cần điền nơi chốn.',
    '{"blank-q12": ["LABORATORY"]}'::jsonb
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
    'Then the data had been analyzed and processed in the Scholz also added that they were now building _______ .',
    E'**Đáp án: THREE-DIMENSIONAL**\n\n> "...building a **three-dimensional** view..."\n\n(Đoạn kết quả) Scholz nói thêm rằng họ đang xây dựng một hình ảnh/bản đồ ba chiều của lòng hồ. Từ cần điền là tính từ chỉ tính chất của hình ảnh.',
    '{"blank-q13": ["THREE-DIMENSIONAL"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    14,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    'The whole set of equipment works well yet the ship should avoid physical barrier including tree stumps or _______ .',
    E'**Đáp án: FISHING NETS**\n\n> "...avoid... tree stumps or **fishing nets**."\n\n(Đoạn vận hành) Các chướng ngại vật vật lý mà tàu cần tránh bao gồm gốc cây và lưới đánh cá. Đây là chi tiết cụ thể về khó khăn khi di chuyển trên hồ.',
    '{"blank-q14": ["FISHING NETS"]}'::jsonb
  );



  -- Delete old question groups for this exam
  DELETE FROM exam_question_groups WHERE "SectionId" = sec1;

  -- Insert question groups
  INSERT INTO exam_question_groups ("Id","SectionId","Idx","StartIdx","EndIdx","InstructionMd")
  VALUES (gen_random_uuid(), sec1, 1, 1, 5, E'## Questions 1-5\n\nDo the following statements agree with the information given in the text?\n\nWrite\n- **TRUE** if the statement agrees with the information\n- **FALSE** if the statement contradicts the information\n- **NOT GIVEN** if there is no information on this\n\n---\n\n');

  INSERT INTO exam_question_groups ("Id","SectionId","Idx","StartIdx","EndIdx","InstructionMd")
  VALUES (gen_random_uuid(), sec1, 2, 6, 14, E'## Questions 6-14\n\nComplete the sentences below.\n\nWrite **NO MORE THAN TWO WORDS AND/OR A NUMBER** for each answer.\n\n![Diagram](http://images.mini-ielts.com/images/ads/47-ielts-reading-22-v22306-q14-27.jpg)\n\n**6.** _______\n\n**7.** _______\n\n**8.** _______\n\n**9.** _______\n\n**10.** The boat-double R/V Kilindi crossed the lake was dismantled and stored in a _______ .\n\n**11.** The technology they used called _______ ; They created sound energy into 1000-2000 metres into the bottom of the lake and used separate equipment to collect the returned waves.\n\n**12.** Then the data had been analyzed and processed in the _______ Scholz also added that they were now building .\n\n**13.** Then the data had been analyzed and processed in the Scholz also added that they were now building _______ .\n\n**14.** The whole set of equipment works well yet the ship should avoid physical barrier including tree stumps or _______ .');

END$$;


COMMIT;