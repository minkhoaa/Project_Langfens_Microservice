-- ============================================================
-- Langfens IELTS: YouPass Reading 5-Exam Seed Pack
-- Strictly append-only: checks slug existence before insert
-- Zero destructive operations (NO DELETE / DROP)
-- Native source order starting at Q1..QN
-- ============================================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- ============================================================
-- Exam: IELTS Reading: The Impact of the Potato
-- Slug: youpass-reading-practice-impact-of-the-potato
-- Source: 10009_youpass-collect-the-impact-of-the-potato.json
-- ============================================================
DO $$
BEGIN
  -- Check if exam already exists (strictly append-only)
  IF EXISTS (SELECT 1 FROM exams WHERE "Slug" = 'youpass-reading-practice-impact-of-the-potato') THEN
    RAISE NOTICE 'Exam with slug % already exists, skipping.', 'youpass-reading-practice-impact-of-the-potato';
    RETURN;
  END IF;

  -- Insert Exam
  INSERT INTO exams ("Id", "Slug", "Title", "DescriptionMd", "Category", "Level", "Status", "DurationMin", "CreatedAt", "UpdatedAt")
  VALUES ('059b3933-008b-5971-a3d5-2ce082254d7e', 'youpass-reading-practice-impact-of-the-potato', E'IELTS Reading: The Impact of the Potato', E'IELTS Academic Reading Practice: IELTS Reading: The Impact of the Potato', 'IELTS', 'B2', 'PUBLISHED', 60, now(), now());

  -- Insert Section 1
  INSERT INTO exam_sections ("Id", "ExamId", "Idx", "Title", "PassageMd", "InstructionsMd")
  VALUES ('c56f0b24-826f-5262-9d59-48e44ced4654', '059b3933-008b-5971-a3d5-2ce082254d7e', 1, E'The Impact of the Potato', E'Jeff Chapman relates the story of history''s most important vegetable

A. The potato was first cultivated in South America between three and seven thousand years ago, though scientists believe they may have grown wild in the region as long as 13,000 years ago. The genetic patterns of potato distribution indicate that the potato probably originated in the mountainous west-central region of the continent.

B. Early Spanish chroniclers who misused the Indian word batata (sweet potato) as the name for the potato noted the importance of the tuber to the Incan Empire. The Incas had learned to preserve the potato for storage by dehydrating and mashing potatoes into a substance called Chuchu could be stored in a room for up to 10 years, providing excellent insurance against possible crop failures. As well as using the food as a staple crop, the Incas thought potatoes made childbirth easier and used it to treat injuries.

C. The Spanish conquistadors first encountered the potato when they arrived in Peru in 1532 in search of gold, and noted Inca miners eating chuchu. At the time the Spaniards failed to realize that the potato represented a far more important treasure than either silver or gold, but they did gradually begin to use potatoes as basic rations aboard their ships. After the arrival of the potato in Spain in 1570, a few Spanish farmers began to cultivate them on a small scale, mostly as food for livestock.

D. Throughout Europe, potatoes were regarded with suspicion, distaste and fear. Generally considered to be unfit for human consumption, they were used only as animal fodder and sustenance for the starving. In northern Europe, potatoes were primarily grown in botanical gardens as an exotic novelty. Even peasants refused to eat from a plant that produced ugly, misshapen tubers and that had come from a heathen civilization. Some felt that the potato plant''s resemblance to plants in the nightshade family hinted that it was the creation of witches or devils.

E. In meat-loving England, farmers and urban workers regarded potatoes with extreme distaste. In 1662, the Royal Society recommended the cultivation of the tuber to the English government and the nation, but this recommendation had little impact. Potatoes did not become a staple until, during the food shortages associated with the Revolutionary Wars, the English government began to officially encourage potato cultivation. In 1795, the Board of Agriculture issued a pamphlet entitled "Hints Respecting the Culture and Use of Potatoes" this was followed shortly by pro-potato editorials and potato recipes in The Times. Gradually, the lower classes began to follow the lead of the upper classes.

F. A similar pattern emerged across the English Channel in the Netherlands, Belgium and France. While the potato slowly gained ground in eastern France (where it was often the only crop remaining after marauding soldiers plundered wheat fields and vineyards), it did not achieve widespread acceptance until the late 1700s. The peasants remained suspicious, in spite of a 1771 paper from the Faculté de Paris testifying that the potato was not harmful but beneficial. The people began to overcome their distaste when the plant received the royal seal of approval: Louis XVI began to sport a potato flower in his buttonhole, and Marie-Antoinette wore the purple potato blossom in her hair.

G. Frederick the Great of Prussia saw the potato''s potential to help feed his nation and lower the price of bread, but faced the challenge of overcoming the people''s prejudice against the plant. When he issued a 1774 order for his subjects to grow potatoes as protection against famine, the town of Kolberg replied: "The things have neither smell nor taste, not even the dogs will eat them, so what use are they to us?" Trying a less direct approach to encourage his subjects to begin planting potatoes, Frederick used a bit of reverse psychology: he planted a royal field of potato plants and stationed a heavy guard to protect this field from thieves. Nearby peasants naturally assumed that anything worth guarding was worth stealing, and so snuck into the field and snatched the plants for their home gardens. Of course, this was entirely in line with Frederick''s wishes.

H. Historians debate whether the potato was primarily a cause or an effect of the huge population boom in industrial-era England and Wales. Prior to 1800, the English diet had consisted primarily of meat, supplemented by bread, butter and cheese. Few vegetables were consumed, most vegetables being regarded as nutritionally worthless and potentially harmful. This view began to change gradually in the late 1700s. The Industrial Revolution was drawing an ever increasing percentage of the populace into crowded cities, where only the richest could afford homes with ovens or coal storage rooms, and people were working 12-16 hour days which left them with little time or energy to prepare food. High yielding, easily prepared potato crops were the obvious solution to England''s food problems.

I. Whereas most of their neighbors regarded the potato with suspicion and had to be persuaded to use it by the upper classes, the Irish peasantry embraced the tuber more passionately than anyone since the Incas. The potato was well suited to the Irish the soil and climate, and its high yield suited the most important concern of most Irish farmers: to feed their families.

J. The most dramatic example of the potato''s potential to alter population patterns occurred in Ireland, where the potato had become a staple by 1800. The Irish population doubled to eight million between 1780 and 1841 this without any significant expansion of industry or reform of agricultural techniques beyond the widespread cultivation of the potato. Though Irish landholding practices were primitive in comparison with those of England, the potato''s high yields allowed even the poorest farmers to produce more healthy food than they needed with scarcely any investment or hard labor. Even children could easily plant, harvest and cook potatoes, which of course required no threshing, curing or grinding. The abundance provided by potatoes greatly decreased infant mortality and encouraged early marriage.', E'Read the passage and answer the questions.');

  -- Insert Question Group 1
  INSERT INTO exam_question_groups ("Id", "SectionId", "Idx", "StartIdx", "EndIdx", "InstructionMd")
  VALUES ('9bb2ec7b-ada6-5ee7-89ed-84a243f4aa1e', 'c56f0b24-826f-5262-9d59-48e44ced4654', 1, 1, 5, E'### Questions 1–5

Do the following statements agree with the views of the writer in Reading Passage?
In boxes 1–5 on your answer sheet, write
TRUE                  if the statement agrees with the information
FALSE                if the statement contradicts the information
NOT GIVEN      if there is no information on this');

  -- Question 1 (TRUE_FALSE_NOT_GIVEN)
  INSERT INTO exam_questions ("Id", "SectionId", "GroupId", "Idx", "Type", "Skill", "Difficulty", "PromptMd", "ExplanationMd", "BlankAcceptTexts", "MatchPairs", "ShortAnswerAcceptTexts")
  VALUES ('7f74061d-f6d0-5c36-aab7-1c01267f9ab4', 'c56f0b24-826f-5262-9d59-48e44ced4654', '9bb2ec7b-ada6-5ee7-89ed-84a243f4aa1e', 1, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, E'The early Spanish called potato as the Incan name ''Chuchu''', E'Bước 1: Hiểu câu hỏi: 

Người Tây Ban Nha thời kỳ đầu gọi khoai tây bằng tên của người Inca là ''Chuchu''.

Bước 2: Tìm các keywords được paraphrase trong bài: 

Early Spanish ~ Early Spanish chroniclers 

called potato as ~ misused the Indian word batata... as the name for the potato 

Chuchu ~ substance called Chuchu

Bước 3: So sánh và đối chiếu: 

Bài đọc chỉ rõ: "Những người chép sử Tây Ban Nha thời kỳ đầu đã dùng sai từ ''batata'' (khoai lang) làm tên cho khoai tây... Người Inca đã học cách bảo quản khoai tây... thành một chất gọi là Chuchu". 

==> Điều này trái ngược với thông tin trong câu hỏi, vì người Tây Ban Nha gọi nó là ''batata'', còn ''Chuchu'' là tên món ăn đã qua chế biến của người Inca (...misused the Indian word batata... mashing potatoes into a substance called Chuchu).

Bước 4: Đáp án: FALSE', NULL, NULL, NULL);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('d092b681-a3f5-5faf-bd23-1999a08a1b05', '7f74061d-f6d0-5c36-aab7-1c01267f9ab4', 1, E'TRUE', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('135d7a9c-ecf1-5f6d-9baa-cb362d5bb8f4', '7f74061d-f6d0-5c36-aab7-1c01267f9ab4', 2, E'FALSE', true);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('c3881af0-4f14-52f2-a2c5-bccc72c487b6', '7f74061d-f6d0-5c36-aab7-1c01267f9ab4', 3, E'NOT GIVEN', false);

  -- Question 2 (TRUE_FALSE_NOT_GIVEN)
  INSERT INTO exam_questions ("Id", "SectionId", "GroupId", "Idx", "Type", "Skill", "Difficulty", "PromptMd", "ExplanationMd", "BlankAcceptTexts", "MatchPairs", "ShortAnswerAcceptTexts")
  VALUES ('47b5c190-dbe5-5a2e-b244-af6437bb3571', 'c56f0b24-826f-5262-9d59-48e44ced4654', '9bb2ec7b-ada6-5ee7-89ed-84a243f4aa1e', 2, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, E'The purposes of Spanish coming to Peru were to find out potatoes', E'Bước 1: Hiểu câu hỏi: 

Mục đích của người Tây Ban Nha đến Peru là để tìm ra khoai tây.

Bước 2: Tìm các keywords được paraphrase trong bài: 

purposes ~ in search of 

find out potatoes ~ gold

Bước 3: So sánh và đối chiếu: 

Bài đọc chỉ rõ: "Những người chinh phục Tây Ban Nha lần đầu tiên bắt gặp khoai tây khi họ đến Peru vào năm 1532 để tìm vàng". 

==> Điều này trái ngược với thông tin trong câu hỏi "mục đích là tìm khoai tây" (arrived in Peru in 1532 in search of gold).

Bước 4: Đáp án: FALSE', NULL, NULL, NULL);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('de2e756b-2929-558b-9b34-487d945d9685', '47b5c190-dbe5-5a2e-b244-af6437bb3571', 1, E'TRUE', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('50b97be0-3ee9-5ba3-8989-b74f89fe481b', '47b5c190-dbe5-5a2e-b244-af6437bb3571', 2, E'FALSE', true);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('fbc493aa-c63e-5cbf-84f4-a6800df9b09d', '47b5c190-dbe5-5a2e-b244-af6437bb3571', 3, E'NOT GIVEN', false);

  -- Question 3 (TRUE_FALSE_NOT_GIVEN)
  INSERT INTO exam_questions ("Id", "SectionId", "GroupId", "Idx", "Type", "Skill", "Difficulty", "PromptMd", "ExplanationMd", "BlankAcceptTexts", "MatchPairs", "ShortAnswerAcceptTexts")
  VALUES ('959f3bd6-0969-5006-8412-b6cb566ce5c9', 'c56f0b24-826f-5262-9d59-48e44ced4654', '9bb2ec7b-ada6-5ee7-89ed-84a243f4aa1e', 3, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, E'The Spanish believed that the potato has the same nutrients as other vegetables', E'Bước 1: Hiểu câu hỏi: 

Người Tây Ban Nha tin rằng khoai tây có các chất dinh dưỡng giống như các loại rau khác.

Bước 2: Tìm các keywords được paraphrase trong bài: 

Spanish believed ~ từ khóa không xuất hiện 

same nutrients ~ từ khóa không xuất hiện

Bước 3: So sánh và đối chiếu: 
Bài đọc đề cập đến việc người Tây Ban Nha sử dụng khoai tây làm lương thực cơ bản trên tàu và thức ăn cho gia súc. Đoạn H có nhắc đến quan điểm chung của người Anh về rau củ là "không có giá trị dinh dưỡng" (nutritionally worthless). 
==> Tuy nhiên, bài đọc không hề nhắc đến thông tin "về niềm tin cụ thể của người Tây Ban Nha so sánh dinh dưỡng của khoai tây với các loại rau khác".

Bước 4: Đáp án: NOT GIVEN', NULL, NULL, NULL);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('50dd0d47-228d-578b-a33d-a3f3996e2469', '959f3bd6-0969-5006-8412-b6cb566ce5c9', 1, E'TRUE', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('f64ebd0d-8c9c-5a70-8ac2-91900d68e2c9', '959f3bd6-0969-5006-8412-b6cb566ce5c9', 2, E'FALSE', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('000bcd5b-8b2c-589c-adc4-5aedf534087d', '959f3bd6-0969-5006-8412-b6cb566ce5c9', 3, E'NOT GIVEN', true);

  -- Question 4 (TRUE_FALSE_NOT_GIVEN)
  INSERT INTO exam_questions ("Id", "SectionId", "GroupId", "Idx", "Type", "Skill", "Difficulty", "PromptMd", "ExplanationMd", "BlankAcceptTexts", "MatchPairs", "ShortAnswerAcceptTexts")
  VALUES ('c08684a7-7dd9-50f9-b80f-c4bc008e5587', 'c56f0b24-826f-5262-9d59-48e44ced4654', '9bb2ec7b-ada6-5ee7-89ed-84a243f4aa1e', 4, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, E'Peasants at that time did not like to eat potatoes because they were ugly', E'Bước 1: Hiểu câu hỏi: 

Nông dân thời đó không thích ăn khoai tây vì chúng xấu xí.

Bước 2: Tìm các keywords được paraphrase trong bài:

did not like to eat ~ refused to eat

ugly ~ ugly, misshapen tubers

Bước 3: So sánh và đối chiếu: 

Bài đọc chỉ rõ: "Ngay cả những người nông dân cũng từ chối ăn từ một loại cây tạo ra những củ xấu xí, dị dạng". 

==> Điều này đồng nghĩa với thông tin trong câu hỏi "không thích ăn vì xấu xí" (peasants refused to eat... produced ugly, misshapen tubers).

Bước 4: Đáp án: TRUE', NULL, NULL, NULL);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('515c77fb-fd77-5606-8cbe-863fed0c88a4', 'c08684a7-7dd9-50f9-b80f-c4bc008e5587', 1, E'TRUE', true);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('12e392da-6a46-56f1-9e1b-0da3724d8eff', 'c08684a7-7dd9-50f9-b80f-c4bc008e5587', 2, E'FALSE', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('b517300a-6964-539e-abc1-8ca67b3955a1', 'c08684a7-7dd9-50f9-b80f-c4bc008e5587', 3, E'NOT GIVEN', false);

  -- Question 5 (TRUE_FALSE_NOT_GIVEN)
  INSERT INTO exam_questions ("Id", "SectionId", "GroupId", "Idx", "Type", "Skill", "Difficulty", "PromptMd", "ExplanationMd", "BlankAcceptTexts", "MatchPairs", "ShortAnswerAcceptTexts")
  VALUES ('992e533d-a966-561f-9d20-c14753605703', 'c56f0b24-826f-5262-9d59-48e44ced4654', '9bb2ec7b-ada6-5ee7-89ed-84a243f4aa1e', 5, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, E'The popularity of potatoes in the UK was due to food shortages during the war', E'Bước 1: Hiểu câu hỏi: 

Sự phổ biến của khoai tây ở Vương quốc Anh là do thiếu hụt lương thực trong chiến tranh.

Bước 2: Tìm các keywords được paraphrase trong bài:

popularity ~ become a staple 

due to ~ during

food shortages during the war ~ food shortages associated with the Revolutionary Wars

Bước 3: So sánh và đối chiếu: 

Bài đọc chỉ rõ: "Khoai tây không trở thành thực phẩm chủ yếu cho đến khi... những thiếu hụt lương thực liên quan đến các cuộc Chiến tranh Cách mạng". 

==> Điều này đồng nghĩa với thông tin trong câu hỏi "sự phổ biến là do thiếu hụt lương thực trong chiến tranh" (Potatoes did not become a staple until... food shortages associated with the Revolutionary Wars).

Bước 4: Đáp án: TRUE', NULL, NULL, NULL);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('fa558342-2040-59da-b462-f8fdc67a7751', '992e533d-a966-561f-9d20-c14753605703', 1, E'TRUE', true);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('043403b9-de2a-5b6a-a847-ea40c6ae0b52', '992e533d-a966-561f-9d20-c14753605703', 2, E'FALSE', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('ca2b18c5-c889-5130-928b-941102cbb4e1', '992e533d-a966-561f-9d20-c14753605703', 3, E'NOT GIVEN', false);

  -- Insert Question Group 2
  INSERT INTO exam_question_groups ("Id", "SectionId", "Idx", "StartIdx", "EndIdx", "InstructionMd")
  VALUES ('1eb66f57-be68-5777-9464-64a331599096', 'c56f0b24-826f-5262-9d59-48e44ced4654', 2, 6, 13, E'### Questions 6–13

Complete the sentences below with NO MORE THAN ONE WORD from the passage for each answer.');

  -- Question 6 (SENTENCE_COMPLETION)
  INSERT INTO exam_questions ("Id", "SectionId", "GroupId", "Idx", "Type", "Skill", "Difficulty", "PromptMd", "ExplanationMd", "BlankAcceptTexts", "MatchPairs", "ShortAnswerAcceptTexts")
  VALUES ('a5897381-55cf-5c08-b44d-137d2673284d', 'c56f0b24-826f-5262-9d59-48e44ced4654', '1eb66f57-be68-5777-9464-64a331599096', 6, 'SENTENCE_COMPLETION', 'READING', 2, E'In France, people started to overcome their disgusting about potatoes because the King put a potato [6] in his button hole.', E'Bước 1: Hiểu câu hỏi và Giải thích ngữ pháp: 

Ở Pháp, mọi người bắt đầu vượt qua sự ghê tởm về khoai tây vì Nhà vua đã cài một ____ khoai tây vào khuy áo của mình.

Bước 2: Xác định loại từ dựa trên các dấu hiệu: 

Loại từ: NOUN (Danh từ số ít) 

Dấu hiệu: put a potato + NOUN (Cụm danh từ chỉ vật được cài vào áo)

Bước 3: Tìm các keywords được paraphrase trong bài: 

overcome their disgusting ~ overcome their distaste

put ~ sport (chưng diện/đeo)

button hole ~ buttonhole

Bước 4: So sánh và đối chiếu: 

Bài đọc chỉ rõ: "Louis XVI bắt đầu chưng diện một bông hoa khoai tây trên khuy áo của mình". (Louis XVI began to sport a potato flower in his buttonhole).

Bước 5: Đáp án: flower', '{"6": ["flower"]}'::jsonb, NULL, NULL);

  -- Question 7 (SENTENCE_COMPLETION)
  INSERT INTO exam_questions ("Id", "SectionId", "GroupId", "Idx", "Type", "Skill", "Difficulty", "PromptMd", "ExplanationMd", "BlankAcceptTexts", "MatchPairs", "ShortAnswerAcceptTexts")
  VALUES ('d21915f3-98b8-5fdd-8639-fb15a5ea1f51', 'c56f0b24-826f-5262-9d59-48e44ced4654', '1eb66f57-be68-5777-9464-64a331599096', 7, 'SENTENCE_COMPLETION', 'READING', 2, E'Frederick realized the potential of potato but he had to handle the [7] against potatoes from ordinary people.', E'Bước 1: Hiểu câu hỏi và Giải thích ngữ pháp: 

Frederick nhận ra tiềm năng của khoai tây nhưng ông phải xử lý ____ chống lại khoai tây từ những người dân thường.

 

Bước 2: Xác định loại từ dựa trên các dấu hiệu:

Loại từ: NOUN

Dấu hiệu: handle the + NOUN (Tân ngữ của động từ ''handle'')

 

Bước 3: Tìm các keywords được paraphrase trong bài:

handle ~ overcoming 

ordinary people ~ the people

 

Bước 4: So sánh và đối chiếu: 

Bài đọc chỉ rõ: "...nhưng phải đối mặt với thách thức vượt qua định kiến của mọi người đối với loài cây này". (...faced the challenge of overcoming the people''s prejudice against the plant.).

 

Bước 5: Đáp án: prejudice', '{"7": ["prejudice"]}'::jsonb, NULL, NULL);

  -- Question 8 (SENTENCE_COMPLETION)
  INSERT INTO exam_questions ("Id", "SectionId", "GroupId", "Idx", "Type", "Skill", "Difficulty", "PromptMd", "ExplanationMd", "BlankAcceptTexts", "MatchPairs", "ShortAnswerAcceptTexts")
  VALUES ('00a19365-432f-5c70-932c-c5e024ef1146', 'c56f0b24-826f-5262-9d59-48e44ced4654', '1eb66f57-be68-5777-9464-64a331599096', 8, 'SENTENCE_COMPLETION', 'READING', 2, E'The King of Prussia adopted some [8] psychology to make people accept potatoes.', E'Bước 1: Hiểu câu hỏi và Giải thích ngữ pháp: 

Vua nước Phổ đã áp dụng một chút tâm lý ____ để khiến mọi người chấp nhận khoai tây.

 

Bước 2: Xác định loại từ dựa trên các dấu hiệu: 

Loại từ: ADJECTIVE 

Dấu hiệu: some + ADJECTIVE + psychology (Tính từ bổ nghĩa cho danh từ ''psychology'')

 

Bước 3: Tìm các keywords được paraphrase trong bài:

adopted ~ used 

psychology ~ từ khóa giữ nguyên

 

Bước 4: So sánh và đối chiếu: 

Bài đọc chỉ rõ: "...Frederick đã sử dụng một chút tâm lý ngược". (...Frederick used a bit of reverse psychology...).

 

Bước 5: Đáp án: reverse', '{"8": ["reverse"]}'::jsonb, NULL, NULL);

  -- Question 9 (SENTENCE_COMPLETION)
  INSERT INTO exam_questions ("Id", "SectionId", "GroupId", "Idx", "Type", "Skill", "Difficulty", "PromptMd", "ExplanationMd", "BlankAcceptTexts", "MatchPairs", "ShortAnswerAcceptTexts")
  VALUES ('041e4376-6bf8-5282-9892-79d9a780e304', 'c56f0b24-826f-5262-9d59-48e44ced4654', '1eb66f57-be68-5777-9464-64a331599096', 9, 'SENTENCE_COMPLETION', 'READING', 2, E'Before 1800, the English people preferred eating [9] with bread, butter and cheese.', E'Bước 1: Hiểu câu hỏi và Giải thích ngữ pháp: 

Trước năm 1800, người Anh thích ăn ____ với bánh mì, bơ và phô mai.

 

Bước 2: Xác định loại từ dựa trên các dấu hiệu: 

Loại từ: NOUN 

Dấu hiệu: eating + NOUN (Tân ngữ của động từ ''eating'')

 

Bước 3: Tìm các keywords được paraphrase trong bài: 

Before 1800 ~ Prior to 1800

preferred eating ~ consisted primarily of

 

Bước 4: So sánh và đối chiếu: 

Bài đọc chỉ rõ: "Trước năm 1800, chế độ ăn uống của người Anh chủ yếu bao gồm thịt, bổ sung thêm bánh mì, bơ và phô mai". (...consisted primarily of meat, supplemented by bread...).

 

Bước 5: Đáp án: meat', '{"9": ["meat"]}'::jsonb, NULL, NULL);

  -- Question 10 (SENTENCE_COMPLETION)
  INSERT INTO exam_questions ("Id", "SectionId", "GroupId", "Idx", "Type", "Skill", "Difficulty", "PromptMd", "ExplanationMd", "BlankAcceptTexts", "MatchPairs", "ShortAnswerAcceptTexts")
  VALUES ('9b85191f-cfb6-5856-95fb-a2fa25ecdb50', 'c56f0b24-826f-5262-9d59-48e44ced4654', '1eb66f57-be68-5777-9464-64a331599096', 10, 'SENTENCE_COMPLETION', 'READING', 2, E'The obvious way to deal with England food problems were high yielding potato [10]', E'Bước 1: Hiểu câu hỏi và Giải thích ngữ pháp: 

Cách rõ ràng để giải quyết các vấn đề lương thực của Anh là các ____ khoai tây năng suất cao.

 

Bước 2: Xác định loại từ dựa trên các dấu hiệu:

Loại từ: NOUN

Dấu hiệu: high yielding potato + NOUN (Danh từ chính trong cụm danh từ)

 

Bước 3: Tìm các keywords được paraphrase trong bài:

obvious way to deal with ~ obvious solution to

high yielding ~ từ khóa giữ nguyên

 

Bước 4: So sánh và đối chiếu: 

Bài đọc chỉ rõ: "Các vụ mùa khoai tây năng suất cao, dễ chế biến là giải pháp rõ ràng cho các vấn đề lương thực của Anh". (High yielding, easily prepared potato crops were the obvious solution...).

 

Bước 5: Đáp án: crops', '{"10": ["crops"]}'::jsonb, NULL, NULL);

  -- Question 11 (SENTENCE_COMPLETION)
  INSERT INTO exam_questions ("Id", "SectionId", "GroupId", "Idx", "Type", "Skill", "Difficulty", "PromptMd", "ExplanationMd", "BlankAcceptTexts", "MatchPairs", "ShortAnswerAcceptTexts")
  VALUES ('3f8d1cec-f865-56ec-90f3-3d1a1c8cb76f', 'c56f0b24-826f-5262-9d59-48e44ced4654', '1eb66f57-be68-5777-9464-64a331599096', 11, 'SENTENCE_COMPLETION', 'READING', 2, E'The Irish [11] and climate suited potatoes well.', E'Bước 1: Hiểu câu hỏi và Giải thích ngữ pháp: 

____ và khí hậu của Ireland rất phù hợp với khoai tây.

 

Bước 2: Xác định loại từ dựa trên các dấu hiệu:

Loại từ: NOUN

Dấu hiệu: The Irish + NOUN (Danh từ đi cùng với ''climate'')

 

Bước 3: Tìm các keywords được paraphrase trong bài:

suited potatoes well ~ potato was well suited to

climate ~ từ khóa giữ nguyên

 

Bước 4: So sánh và đối chiếu: 

Bài đọc chỉ rõ: "Khoai tây rất phù hợp với đất đai và khí hậu của người Ireland". (The potato was well suited to the Irish the soil and climate...).

 

Bước 5: Đáp án: soil', '{"11": ["soil"]}'::jsonb, NULL, NULL);

  -- Question 12 (SENTENCE_COMPLETION)
  INSERT INTO exam_questions ("Id", "SectionId", "GroupId", "Idx", "Type", "Skill", "Difficulty", "PromptMd", "ExplanationMd", "BlankAcceptTexts", "MatchPairs", "ShortAnswerAcceptTexts")
  VALUES ('6252b5f7-4ddb-580e-ae11-e620727896f4', 'c56f0b24-826f-5262-9d59-48e44ced4654', '1eb66f57-be68-5777-9464-64a331599096', 12, 'SENTENCE_COMPLETION', 'READING', 2, E'Between 1780 and 1841, based on the [12] of the potatoes, the Irish population doubled to eight million.', E'Bước 1: Hiểu câu hỏi và Giải thích ngữ pháp: 

Giữa năm 1780 và 1841, dựa trên sự ____ của khoai tây, dân số Ireland đã tăng gấp đôi lên tám triệu người.

 

Bước 2: Xác định loại từ dựa trên các dấu hiệu:

Loại từ: NOUN 

Dấu hiệu: based on the + NOUN + of the potatoes (Danh từ chỉ hành động hoặc tính chất)

 

Bước 3: Tìm các keywords được paraphrase trong bài:

Between 1780 and 1841 ~ từ khóa giữ nguyên 

population doubled ~ từ khóa giữ nguyên

 

Bước 4: So sánh và đối chiếu: 

Bài đọc chỉ rõ: "Dân số Ireland tăng gấp đôi... điều này diễn ra mà không có bất kỳ sự mở rộng công nghiệp hay cải cách nông nghiệp nào đáng kể ngoài sự canh tác rộng rãi của khoai tây". (...without any significant expansion... beyond the widespread cultivation of the potato.).

 

Bước 5: Đáp án: cultivation', '{"12": ["cultivation"]}'::jsonb, NULL, NULL);

  -- Question 13 (SENTENCE_COMPLETION)
  INSERT INTO exam_questions ("Id", "SectionId", "GroupId", "Idx", "Type", "Skill", "Difficulty", "PromptMd", "ExplanationMd", "BlankAcceptTexts", "MatchPairs", "ShortAnswerAcceptTexts")
  VALUES ('787c64dc-7833-5e3f-bb26-53ac36800917', 'c56f0b24-826f-5262-9d59-48e44ced4654', '1eb66f57-be68-5777-9464-64a331599096', 13, 'SENTENCE_COMPLETION', 'READING', 2, E'The potato''s high yields help the poorest farmers to produce more healthy food almost without [13]', E'Bước 1: Hiểu câu hỏi và Giải thích ngữ pháp: 

Năng suất cao của khoai tây giúp những người nông dân nghèo nhất sản xuất nhiều thực phẩm lành mạnh hơn gần như không cần ____.

 

Bước 2: Xác định loại từ dựa trên các dấu hiệu:

Loại từ: NOUN 

Dấu hiệu: without + NOUN (Tân ngữ của giới từ ''without'')

 

Bước 3: Tìm các keywords được paraphrase trong bài:

almost without ~ scarcely any

poorest farmers ~ từ khóa giữ nguyên

 

Bước 4: So sánh và đối chiếu: 

Bài đọc chỉ rõ: "...cho phép ngay cả những người nông dân nghèo nhất sản xuất nhiều thực phẩm lành mạnh hơn mức họ cần với rất ít sự đầu tư hoặc lao động vất vả". (...scarcely any investment or hard labor.).

 

Bước 5: Đáp án: investment', '{"13": ["investment"]}'::jsonb, NULL, NULL);

  RAISE NOTICE 'Successfully seeded exam % with % questions.', 'youpass-reading-practice-impact-of-the-potato', 13;
END$$;

-- ============================================================
-- Exam: IELTS Reading: Caral: An Ancient South American City
-- Slug: youpass-reading-practice-caral-ancient-city
-- Source: 10011_youpass-collect-caral-an-ancient-south-american-city.json
-- ============================================================
DO $$
BEGIN
  -- Check if exam already exists (strictly append-only)
  IF EXISTS (SELECT 1 FROM exams WHERE "Slug" = 'youpass-reading-practice-caral-ancient-city') THEN
    RAISE NOTICE 'Exam with slug % already exists, skipping.', 'youpass-reading-practice-caral-ancient-city';
    RETURN;
  END IF;

  -- Insert Exam
  INSERT INTO exams ("Id", "Slug", "Title", "DescriptionMd", "Category", "Level", "Status", "DurationMin", "CreatedAt", "UpdatedAt")
  VALUES ('4b405ce8-0f24-5181-a4a8-6f7e8bcfe805', 'youpass-reading-practice-caral-ancient-city', E'IELTS Reading: Caral: An Ancient South American City', E'IELTS Academic Reading Practice: IELTS Reading: Caral: An Ancient South American City', 'IELTS', 'B2', 'PUBLISHED', 60, now(), now());

  -- Insert Section 1
  INSERT INTO exam_sections ("Id", "ExamId", "Idx", "Title", "PassageMd", "InstructionsMd")
  VALUES ('eb3e28c8-1472-5f54-a04d-42f4aef62840', '4b405ce8-0f24-5181-a4a8-6f7e8bcfe805', 1, E'Caral: An Ancient South American City', E'Huge earth and rock mounds rise out of the desert of the Supe Valley near the coast of Peru in South America. These immense mounds appear simply to be part of the geographical landscape in this arid region squeezed between the Pacific Ocean and the Andes mountains. But looks deceive. These are actually human-made pyramids strong evidence indicates they are the remains of a city known as Caral that flourished nearly 5,000 years ago. If true, it would be the oldest known urban center in the Americas and among the most ancient in the world.

Research undertaken by Peruvian archaeologist Ruth Shady suggests that the 150-acre complex of pyramids, plazas and residential buildings was a thriving metropolis when Egypt''s great pyramids were still being built. Though discovered in 1905, for years Caral attracted little attention, largely because archaeologists believed the structures were fairly recent. But the monumental scale of the pyramids had long interested Shady, who began excavations at the site in 1996, about 22 kilometers from the coast and 190 kilometers north of Peru''s capital city of Lima.

Shady and her crew searched for broken remains of the pots and containers that most such sites contain. Not finding any only made her more excited: it meant Caral could be what archaeologists term pre-ceramic, that is, existing before the advent in the area of pot-firing techniques. Shady''s team undertook the task of excavating Piramide Mayor, the largest of the pyramids. After carefully clearing away many hundreds of years'' worth of rubble and sand, they identified staircases, walls covered with remnants of colored plaster, and brickwork. In the foundations, they found the remains of grass-like reeds woven into bags. The original workers, she surmised, must have filled these bags with stones from a nearby quarry and laid them atop one another inside retaining walls, gradually giving rise to the pyramid''s immense structure. Shady had samples of the reeds subjected to radiocarbon dating and found that the reeds were 4,600 years old. This evidence indicated that Caral was, in fact, more than 1,000 years older than what had previously been thought to be the oldest urban center in the Americas.

What amazed archaeologists was not just the age, but the complexity and scope of Caral. Piramide Mayor alone covers an area nearly the size of four football fields and is 18 meters tall. A nine-meter-wide staircase rises from a circular plaza at the foot of the pyramid, passing over three terraced levels until it reaches the top. Thousands of manual laborers would have been needed to build such a project, not counting the many architects, craftsmen, and managers. Shady''s team found the remains of a large amphitheater, containing almost 70 musical instruments made of bird and deer bones. Clearly music played an important role in Caral''s society. Around the perimeter of Caral are a series of smaller mounds and various buildings. These indicate a hierarchy of living arrangements: large, well-kept rooms atop pyramids for the elite, ground-level quarters for craftsmen, and shabbier outlying dwellings for workers.

But why had Caral been built in the first place? Her excavations convinced Shady that Caral once served as a trade center for the region, which extends from the rainforests of the Amazon to the high forests of the Andes. Shady found evidence of a rich trading environment, including seeds of the cocoa bush and necklaces of shells, neither of which was native to the immediate Caral area. This environment gave rise to people who did not take part in the production of food, allowing them to become priests and planners, builders and designers. Thus occupational specialization, elemental to an urban society, emerged.

But what sustained such a trading center and drew travelers to it? Was it food? Shady and her team found the bones of small edible fish, which must have come from the Pacific coast to the west, in the excavations. But they also found evidence of squash, sweet potatoes and beans having been grown locally. Shady theorized that Caral''s early farmers diverted the area''s rivers into canals, which still cross the Supe Valley today, to irrigate their fields. But because she found no traces of maize, which can be traded or stored and used in times of crop failure, she concluded that Caral''s trade leverage was not based on stockpiling food supplies.

It was evidence of another crop in the excavations that gave Shady the best clue to Caral''s success. In nearly every excavated building, her team discovered evidence of cotton – seeds, fibers and textiles. Her theory fell into place when a large fishing net made of those fibers, unearthed in an unrelated dig on Peru''s coast, turned out to be as old as Caral. ''The farmers of Caral grew the cotton that the fishermen needed to make their nets,'' Shady speculates. ''And the fishermen gave them shellfish and dried fish in exchange for these nets.'' In essence, the people of Caral enabled fishermen to work with larger and more effective nets, which made the resources of the sea more readily available, and the fishermen probably used dried squash grown by the Caral people as flotation devices for their nets.', E'Read the passage and answer the questions.');

  -- Insert Question Group 1
  INSERT INTO exam_question_groups ("Id", "SectionId", "Idx", "StartIdx", "EndIdx", "InstructionMd")
  VALUES ('fa34fd6c-103b-5d3e-ace9-da169c7bab93', 'eb3e28c8-1472-5f54-a04d-42f4aef62840', 1, 1, 6, E'### Questions 1–6

Do the following statements agree with the information given in Reading Passage? Write

TRUE           if the statement agrees with the information

FALSE           if the statement contradicts the information

NOT GIVEN if there is no information on this');

  -- Question 1 (TRUE_FALSE_NOT_GIVEN)
  INSERT INTO exam_questions ("Id", "SectionId", "GroupId", "Idx", "Type", "Skill", "Difficulty", "PromptMd", "ExplanationMd", "BlankAcceptTexts", "MatchPairs", "ShortAnswerAcceptTexts")
  VALUES ('9f1affa4-7294-5e31-a08a-808c5611f923', 'eb3e28c8-1472-5f54-a04d-42f4aef62840', 'fa34fd6c-103b-5d3e-ace9-da169c7bab93', 1, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, E'Caral was built at the same time as the construction of the Egyptian pyramids.', E'Bước 1: Hiểu câu hỏi:
Caral được xây dựng cùng thời điểm với việc xây dựng các kim tự tháp Ai Cập.

Bước 2: Tìm các keywords được paraphrase trong bài:

Caral... was a thriving metropolis ~ Caral was built

when ~ at the same time

Egypt''s great pyramids were still being built ~ construction of the Egyptian pyramids

Bước 3: So sánh và đối chiếu:
Bài đọc chỉ rõ: "Caral là một đô thị thịnh vượng khi các kim tự tháp vĩ đại của Ai Cập vẫn đang được xây dựng" (...was a thriving metropolis when Egypt''s great pyramids were still being built).
==> Điều này trái ngược với thông tin trong câu hỏi "Caral được xây dựng cùng thời điểm với việc xây dựng các kim tự tháp Ai Cập" (Caral was built at the same time as the construction of the Egyptian pyramids). Việc Caral đã là một "đô thị thịnh vượng" trong khi các kim tự tháp vẫn "đang được xây dựng" ngụ ý rằng Caral đã được xây dựng từ trước đó.

Bước 4: Đáp án: FALSE', NULL, NULL, NULL);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('697ce6db-2612-5139-8ea2-8252980d8d5e', '9f1affa4-7294-5e31-a08a-808c5611f923', 1, E'TRUE', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('a484809b-7713-5fbd-9fe4-eaa14e21c39b', '9f1affa4-7294-5e31-a08a-808c5611f923', 2, E'FALSE', true);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('62cf4838-2b8c-5d9d-8d8d-bc5445b9faf4', '9f1affa4-7294-5e31-a08a-808c5611f923', 3, E'NOT GIVEN', false);

  -- Question 2 (TRUE_FALSE_NOT_GIVEN)
  INSERT INTO exam_questions ("Id", "SectionId", "GroupId", "Idx", "Type", "Skill", "Difficulty", "PromptMd", "ExplanationMd", "BlankAcceptTexts", "MatchPairs", "ShortAnswerAcceptTexts")
  VALUES ('78decdbb-6c93-5d24-b6c5-1cfcc07859c8', 'eb3e28c8-1472-5f54-a04d-42f4aef62840', 'fa34fd6c-103b-5d3e-ace9-da169c7bab93', 2, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, E'The absence of pottery at the archaeological dig gave Shady a significant clue to the age of the site.', E'Bước 1: Hiểu câu hỏi:
Sự vắng mặt của đồ gốm tại cuộc khai quật khảo cổ đã cho Shady một manh mối quan trọng về tuổi của địa điểm.

Bước 2: Tìm các keywords được paraphrase trong bài:

Not finding any [pots] / pre-ceramic ~ absence of pottery

existing before the advent... of pot-firing techniques / meant Caral could be... ~ clue to the age

Bước 3: So sánh và đối chiếu:
Bài đọc chỉ rõ: "Việc không tìm thấy bất kỳ thứ gì [đồ gốm] chỉ làm bà ấy phấn khích hơn: điều đó có nghĩa là Caral có thể là... tiền gốm sứ, nghĩa là, tồn tại trước khi kỹ thuật nung gốm ra đời" (Not finding any only made her more excited: it meant Caral... could be... pre-ceramic, existing before the advent... of pot-firing techniques).
==> Điều này đồng nghĩa với thông tin trong câu hỏi "Sự vắng mặt của đồ gốm... đã cho Shady một manh mối quan trọng về tuổi của địa điểm" (The absence of pottery... gave Shady a significant clue to the age of the site).

Bước 4: Đáp án: TRUE', NULL, NULL, NULL);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('381037a6-a126-52ab-ab45-5e5794f1f232', '78decdbb-6c93-5d24-b6c5-1cfcc07859c8', 1, E'TRUE', true);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('2609d987-f15e-540f-8626-efab7806a079', '78decdbb-6c93-5d24-b6c5-1cfcc07859c8', 2, E'FALSE', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('686550ae-eff5-55a7-bb2c-110aadaa304d', '78decdbb-6c93-5d24-b6c5-1cfcc07859c8', 3, E'NOT GIVEN', false);

  -- Question 3 (TRUE_FALSE_NOT_GIVEN)
  INSERT INTO exam_questions ("Id", "SectionId", "GroupId", "Idx", "Type", "Skill", "Difficulty", "PromptMd", "ExplanationMd", "BlankAcceptTexts", "MatchPairs", "ShortAnswerAcceptTexts")
  VALUES ('26991a54-8d10-55a2-ba4f-b91b1c02756f', 'eb3e28c8-1472-5f54-a04d-42f4aef62840', 'fa34fd6c-103b-5d3e-ace9-da169c7bab93', 3, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, E'The stones used to build Piramide Mayor came from a location far away.', E'Bước 1: Hiểu câu hỏi:
Những viên đá được sử dụng để xây dựng Piramide Mayor đến từ một địa điểm ở rất xa.

Bước 2: Tìm các keywords được paraphrase trong bài:

filled these bags with stones ~ stones used to build

nearby ~ far away (Trái nghĩa)

Bước 3: So sánh và đối chiếu:
Bài đọc chỉ rõ: "...lấp đầy những chiếc túi này bằng đá từ một mỏ đá gần đó" (...filled these bags with stones from a nearby quarry).
==> Điều này trái ngược với thông tin trong câu hỏi "đến từ một địa điểm ở rất xa" (came from a location far away).

Bước 4: Đáp án: FALSE', NULL, NULL, NULL);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('1648d7ea-3bd4-58a2-83d4-bd0b634012d6', '26991a54-8d10-55a2-ba4f-b91b1c02756f', 1, E'TRUE', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('65f55cf6-3923-5639-858c-ed1bdb158755', '26991a54-8d10-55a2-ba4f-b91b1c02756f', 2, E'FALSE', true);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('2c0fe24a-bcae-50ae-8360-b548851c68c4', '26991a54-8d10-55a2-ba4f-b91b1c02756f', 3, E'NOT GIVEN', false);

  -- Question 4 (TRUE_FALSE_NOT_GIVEN)
  INSERT INTO exam_questions ("Id", "SectionId", "GroupId", "Idx", "Type", "Skill", "Difficulty", "PromptMd", "ExplanationMd", "BlankAcceptTexts", "MatchPairs", "ShortAnswerAcceptTexts")
  VALUES ('8b8e577f-91f2-56d2-87fa-96c435651c98', 'eb3e28c8-1472-5f54-a04d-42f4aef62840', 'fa34fd6c-103b-5d3e-ace9-da169c7bab93', 4, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, E'The huge and complicated structures of Piramide Mayor suggest that its construction required an organised team of builders.', E'Bước 1: Hiểu câu hỏi:
Các cấu trúc khổng lồ và phức tạp của Piramide Mayor cho thấy việc xây dựng nó đòi hỏi một đội ngũ xây dựng có tổ chức.

Bước 2: Tìm các keywords được paraphrase trong bài:

huge earth and rock mounds / complexity and scope ~ huge and complicated structures

manual laborers... architects, craftsmen, and managers ~ organised team of builders

Bước 3: So sánh và đối chiếu:
Bài đọc chỉ rõ: "Hàng ngàn lao động chân tay sẽ là cần thiết... chưa kể đến nhiều kiến trúc sư, thợ thủ công và người quản lý" (Thousands of manual laborers... not counting the many architects, craftsmen, and managers).
==> Điều này đồng nghĩa với thông tin trong câu hỏi "đòi hỏi một đội ngũ xây dựng có tổ chức" (required an organised team of builders).

Bước 4: Đáp án: TRUE', NULL, NULL, NULL);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('e48355a2-f4c4-56f3-8ac3-9d0ff2c80cdf', '8b8e577f-91f2-56d2-87fa-96c435651c98', 1, E'TRUE', true);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('00c3c652-99bb-5dbc-8dc9-a2027b0b9dd6', '8b8e577f-91f2-56d2-87fa-96c435651c98', 2, E'FALSE', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('c614ddd6-9190-5b6b-ba8c-9f0acb859730', '8b8e577f-91f2-56d2-87fa-96c435651c98', 3, E'NOT GIVEN', false);

  -- Question 5 (TRUE_FALSE_NOT_GIVEN)
  INSERT INTO exam_questions ("Id", "SectionId", "GroupId", "Idx", "Type", "Skill", "Difficulty", "PromptMd", "ExplanationMd", "BlankAcceptTexts", "MatchPairs", "ShortAnswerAcceptTexts")
  VALUES ('26280f2f-3112-5dc4-a38e-147176b8941e', 'eb3e28c8-1472-5f54-a04d-42f4aef62840', 'fa34fd6c-103b-5d3e-ace9-da169c7bab93', 5, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, E'Archaeological evidence shows that the residents of Caral were highly skilled musicians.', E'Bước 1: Hiểu câu hỏi:
Bằng chứng khảo cổ cho thấy cư dân Caral là những nhạc sĩ có kỹ năng cao.

Bước 2: Tìm các keywords được paraphrase trong bài:

Caral''s society ~ residents of Caral

highly skilled musicians ~ từ khóa cần tìm

Bước 3: So sánh và đối chiếu:
Bài đọc đề cập đến việc tìm thấy "gần 70 nhạc cụ" và kết luận rằng "âm nhạc đóng một vai trò quan trọng".
==> Tuy nhiên, bài đọc không hề đề cập đến việc họ có "kỹ năng cao" (highly skilled) hay không.

Bước 4: Đáp án: NOT GIVEN', NULL, NULL, NULL);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('b856fa70-ae11-5578-8ef8-26ba9eca380c', '26280f2f-3112-5dc4-a38e-147176b8941e', 1, E'TRUE', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('69f489c2-a6f2-57db-882c-df35bd5e12f0', '26280f2f-3112-5dc4-a38e-147176b8941e', 2, E'FALSE', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('94081fc6-a0f1-5603-a7c9-6ab0c8f16c2c', '26280f2f-3112-5dc4-a38e-147176b8941e', 3, E'NOT GIVEN', true);

  -- Question 6 (TRUE_FALSE_NOT_GIVEN)
  INSERT INTO exam_questions ("Id", "SectionId", "GroupId", "Idx", "Type", "Skill", "Difficulty", "PromptMd", "ExplanationMd", "BlankAcceptTexts", "MatchPairs", "ShortAnswerAcceptTexts")
  VALUES ('b8c54fb2-5ad5-52c0-aaca-1f97c7b934dc', 'eb3e28c8-1472-5f54-a04d-42f4aef62840', 'fa34fd6c-103b-5d3e-ace9-da169c7bab93', 6, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, E'The remains of housing areas at Caral suggest that there were no class distinctions in residential areas.', E'Bước 1: Hiểu câu hỏi:
Tàn tích của các khu nhà ở tại Caral cho thấy không có sự phân biệt giai cấp trong các khu dân cư.

Bước 2: Tìm các keywords được paraphrase trong bài:

living arrangements / rooms / quarters / dwellings ~ housing areas

hierarchy / elite / workers ~ no class distinctions (Trái nghĩa)

Bước 3: So sánh và đối chiếu:
Bài đọc chỉ rõ: "Những điều này chỉ ra một hệ thống phân cấp trong sắp xếp sinh hoạt: phòng lớn... cho giới tinh hoa, khu vực... cho thợ thủ công, và những nơi ở tồi tàn hơn... cho công nhân" (These indicate a hierarchy... large rooms... for the elite... shabbier quarters... for workers).
==> Điều này trái ngược với thông tin trong câu hỏi "không có sự phân biệt giai cấp" (no class distinctions).

Bước 4: Đáp án: FALSE', NULL, NULL, NULL);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('aabf87f1-aaca-50e1-98f8-ac72463c64ac', 'b8c54fb2-5ad5-52c0-aaca-1f97c7b934dc', 1, E'TRUE', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('4e2cf491-4db0-5388-ae2d-13b888cce90b', 'b8c54fb2-5ad5-52c0-aaca-1f97c7b934dc', 2, E'FALSE', true);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('7d6ab71d-291a-5b0f-b3c5-ebf68c7ee974', 'b8c54fb2-5ad5-52c0-aaca-1f97c7b934dc', 3, E'NOT GIVEN', false);

  -- Insert Question Group 2
  INSERT INTO exam_question_groups ("Id", "SectionId", "Idx", "StartIdx", "EndIdx", "InstructionMd")
  VALUES ('b21f9d75-d364-5725-9480-d546265f1841', 'eb3e28c8-1472-5f54-a04d-42f4aef62840', 2, 7, 13, E'### Questions 7–13

Complete the notes below. 

Choose ONE WORD ONLY from the passage for each answer.');

  -- Question 7 (SUMMARY_COMPLETION)
  INSERT INTO exam_questions ("Id", "SectionId", "GroupId", "Idx", "Type", "Skill", "Difficulty", "PromptMd", "ExplanationMd", "BlankAcceptTexts", "MatchPairs", "ShortAnswerAcceptTexts")
  VALUES ('b6b7bdeb-3925-584e-aa93-075390d39027', 'eb3e28c8-1472-5f54-a04d-42f4aef62840', 'b21f9d75-d364-5725-9480-d546265f1841', 7, 'SUMMARY_COMPLETION', 'READING', 2, E'the [7] of a certain plant', E'Bước 1: Hiểu câu hỏi và Giải thích ngữ pháp:
Cần tìm một danh từ chỉ bộ phận của cây, là vật phẩm được phát hiện tại Caral nhưng không có tự nhiên ở khu vực này.

Bước 2: Xác định loại từ dựa trên các dấu hiệu:

Loại từ: NOUN

Dấu hiệu: the + NOUN + of (Sau mạo từ ''the'' và trước giới từ ''of'').

Bước 3: Tìm các keywords được paraphrase trong bài:

found evidence ~ discovered at Caral

neither of which was native ~ not naturally occurring

cocoa bush ~ certain plant

Bước 4: So sánh và đối chiếu:
Bài đọc chỉ rõ: "...bao gồm hạt của cây bụi ca cao" (...including seeds of the cocoa bush).

Bước 5: Đáp án: seeds.
...hạt của một loại cây nhất định (...the seeds of a certain plant).', '{"7": ["seeds"]}'::jsonb, NULL, NULL);

  -- Question 8 (SUMMARY_COMPLETION)
  INSERT INTO exam_questions ("Id", "SectionId", "GroupId", "Idx", "Type", "Skill", "Difficulty", "PromptMd", "ExplanationMd", "BlankAcceptTexts", "MatchPairs", "ShortAnswerAcceptTexts")
  VALUES ('a38d73e5-d211-5960-a69e-f7ac0481acac', 'eb3e28c8-1472-5f54-a04d-42f4aef62840', 'b21f9d75-d364-5725-9480-d546265f1841', 8, 'SUMMARY_COMPLETION', 'READING', 2, E'[8] used to make jewellery', E'Bước 1: Hiểu câu hỏi và Giải thích ngữ pháp:
Cần tìm một danh từ chỉ vật liệu được dùng để làm đồ trang sức.

Bước 2: Xác định loại từ dựa trên các dấu hiệu:

Loại từ: NOUN (số nhiều)

Dấu hiệu: NOUN + used to... (Làm chủ ngữ của mệnh đề rút gọn).

Bước 3: Tìm các keywords được paraphrase trong bài:

necklaces ~ make jewellery

neither of which was native ~ not naturally occurring

Bước 4: So sánh và đối chiếu:
Bài đọc chỉ rõ: "...và những chiếc vòng cổ bằng vỏ sò" (...and necklaces of shells).

Bước 5: Đáp án: shells.
Vỏ sò được dùng để làm đồ trang sức (Shells used to make jewellery).', '{"8": ["shells"]}'::jsonb, NULL, NULL);

  -- Question 9 (SUMMARY_COMPLETION)
  INSERT INTO exam_questions ("Id", "SectionId", "GroupId", "Idx", "Type", "Skill", "Difficulty", "PromptMd", "ExplanationMd", "BlankAcceptTexts", "MatchPairs", "ShortAnswerAcceptTexts")
  VALUES ('ea33692a-2aa0-5a5d-bfff-eb669187421c', 'eb3e28c8-1472-5f54-a04d-42f4aef62840', 'b21f9d75-d364-5725-9480-d546265f1841', 9, 'SUMMARY_COMPLETION', 'READING', 2, E'the remains of certain food such as [9]', E'Bước 1: Hiểu câu hỏi và Giải thích ngữ pháp:
Cần tìm một danh từ chỉ loại thực phẩm cụ thể mà tàn tích của nó được tìm thấy.

Bước 2: Xác định loại từ dựa trên các dấu hiệu:

Loại từ: NOUN

Dấu hiệu: such as + NOUN (Sau ''such as'').

Bước 3: Tìm các keywords được paraphrase trong bài:

bones ~ remains

edible... ~ certain food

come from the Pacific coast ~ not naturally occurring

Bước 4: So sánh và đối chiếu:
Bài đọc chỉ rõ: "...tìm thấy xương của những con cá nhỏ ăn được, thứ chắc chắn phải đến từ bờ biển Thái Bình Dương" (...found bones of small edible fish, which must have come from the Pacific coast).

Bước 5: Đáp án: fish.
...tàn tích của một số loại thực phẩm như cá (...the remains of certain food such as fish).', '{"9": ["fish"]}'::jsonb, NULL, NULL);

  -- Question 10 (SUMMARY_COMPLETION)
  INSERT INTO exam_questions ("Id", "SectionId", "GroupId", "Idx", "Type", "Skill", "Difficulty", "PromptMd", "ExplanationMd", "BlankAcceptTexts", "MatchPairs", "ShortAnswerAcceptTexts")
  VALUES ('9902bb1e-b9f2-5947-869b-a1ee8c8ceb8a', 'eb3e28c8-1472-5f54-a04d-42f4aef62840', 'b21f9d75-d364-5725-9480-d546265f1841', 10, 'SUMMARY_COMPLETION', 'READING', 2, E'[10] still in existence today indicate water diverted from rivers', E'Bước 1: Hiểu câu hỏi và Giải thích ngữ pháp:
Cần tìm một danh từ chỉ công trình thủy lợi vẫn còn tồn tại đến ngày nay.

Bước 2: Xác định loại từ dựa trên các dấu hiệu:

Loại từ: NOUN (số nhiều)

Dấu hiệu: NOUN + still in existence... (Làm chủ ngữ của câu).

Bước 3: Tìm các keywords được paraphrase trong bài:

still cross the Supe Valley today ~ still in existence today

diverted the area''s rivers into ~ water diverted from rivers

Bước 4: So sánh và đối chiếu:
Bài đọc chỉ rõ: "...dẫn nước sông của khu vực vào các kênh rạch, thứ vẫn cắt ngang Thung lũng Supe ngày nay" (...diverted the area''s rivers into canals, which still cross the Supe Valley today).

Bước 5: Đáp án: canals.
Kênh rạch vẫn còn tồn tại đến ngày nay... (Canals still in existence today...).', '{"10": ["canals"]}'::jsonb, NULL, NULL);

  -- Question 11 (SUMMARY_COMPLETION)
  INSERT INTO exam_questions ("Id", "SectionId", "GroupId", "Idx", "Type", "Skill", "Difficulty", "PromptMd", "ExplanationMd", "BlankAcceptTexts", "MatchPairs", "ShortAnswerAcceptTexts")
  VALUES ('909004cd-19d1-5c60-8ea1-e16765f61129', 'eb3e28c8-1472-5f54-a04d-42f4aef62840', 'b21f9d75-d364-5725-9480-d546265f1841', 11, 'SUMMARY_COMPLETION', 'READING', 2, E'no evidence that [11] was grown', E'Bước 1: Hiểu câu hỏi và Giải thích ngữ pháp:
Cần tìm danh từ chỉ loại cây trồng mà không có bằng chứng là đã được trồng tại Caral.

Bước 2: Xác định loại từ dựa trên các dấu hiệu:

Loại từ: NOUN

Dấu hiệu: that + NOUN + was grown (Làm chủ ngữ cho mệnh đề phụ).

Bước 3: Tìm các keywords được paraphrase trong bài:

found no traces of ~ no evidence

Bước 4: So sánh và đối chiếu:
Bài đọc chỉ rõ: "Nhưng bởi vì bà ấy không tìm thấy dấu vết nào của ngô..." (But because she found no traces of maize).

Bước 5: Đáp án: maize.
...không có bằng chứng rằng ngô đã được trồng (...no evidence that maize was grown).', '{"11": ["maize"]}'::jsonb, NULL, NULL);

  -- Question 12 (SUMMARY_COMPLETION)
  INSERT INTO exam_questions ("Id", "SectionId", "GroupId", "Idx", "Type", "Skill", "Difficulty", "PromptMd", "ExplanationMd", "BlankAcceptTexts", "MatchPairs", "ShortAnswerAcceptTexts")
  VALUES ('31a68b40-7f8c-5b93-aafb-cbdd1f6bd028', 'eb3e28c8-1472-5f54-a04d-42f4aef62840', 'b21f9d75-d364-5725-9480-d546265f1841', 12, 'SUMMARY_COMPLETION', 'READING', 2, E'the excavation findings and fishing nets found on the coast suggest Caral farmers traded [12]', E'Bước 1: Hiểu câu hỏi và Giải thích ngữ pháp:
Cần tìm danh từ chỉ vật phẩm mà nông dân Caral đã buôn bán/trao đổi.

Bước 2: Xác định loại từ dựa trên các dấu hiệu:

Loại từ: NOUN

Dấu hiệu: traded + NOUN (Sau động từ ''traded'').

Bước 3: Tìm các keywords được paraphrase trong bài:

fishing nets ~ từ khóa giữ nguyên

farmers... grew... that fishermen needed ~ farmers... traded

Bước 4: So sánh và đối chiếu:
Bài đọc chỉ rõ: "''Nông dân Caral đã trồng bông mà ngư dân cần để làm lưới của họ''" (''The farmers of Caral grew the cotton that the fishermen needed for their nets'').

Bước 5: Đáp án: cotton.
...nông dân Caral đã buôn bán bông (...Caral farmers traded cotton).', '{"12": ["cotton"]}'::jsonb, NULL, NULL);

  -- Question 13 (SUMMARY_COMPLETION)
  INSERT INTO exam_questions ("Id", "SectionId", "GroupId", "Idx", "Type", "Skill", "Difficulty", "PromptMd", "ExplanationMd", "BlankAcceptTexts", "MatchPairs", "ShortAnswerAcceptTexts")
  VALUES ('c873efd4-f635-5f9e-ad12-5676f28f3f78', 'eb3e28c8-1472-5f54-a04d-42f4aef62840', 'b21f9d75-d364-5725-9480-d546265f1841', 13, 'SUMMARY_COMPLETION', 'READING', 2, E'dried squash may have been used to aid [13]', E'Bước 1: Hiểu câu hỏi và Giải thích ngữ pháp:
Bí khô có thể đã được sử dụng để hỗ trợ [việc gì/cái gì].

Bước 2: Xác định loại từ dựa trên các dấu hiệu:

Loại từ: NOUN

Dấu hiệu: aid + NOUN (Sau động từ ''aid'').

Bước 3: Tìm các keywords được paraphrase trong bài:

dried squash ~ từ khóa giữ nguyên

used... as... devices ~ used to aid

Bước 4: So sánh và đối chiếu:
Bài đọc chỉ rõ: "...ngư dân có lẽ đã sử dụng bí khô... làm thiết bị nổi cho lưới của họ" (...fishermen probably used dried squash... as flotation devices for their nets).

Bước 5: Đáp án: flotation.
...bí khô có thể đã được sử dụng để hỗ trợ sự nổi (...dried squash may have been used to aid flotation).', '{"13": ["flotation"]}'::jsonb, NULL, NULL);

  RAISE NOTICE 'Successfully seeded exam % with % questions.', 'youpass-reading-practice-caral-ancient-city', 13;
END$$;

-- ============================================================
-- Exam: IELTS Reading: Reading in a whole new way
-- Slug: youpass-reading-practice-reading-in-a-whole-new-way
-- Source: 10425_youpass-collect-reading-in-a-whole-new-way.json
-- ============================================================
DO $$
BEGIN
  -- Check if exam already exists (strictly append-only)
  IF EXISTS (SELECT 1 FROM exams WHERE "Slug" = 'youpass-reading-practice-reading-in-a-whole-new-way') THEN
    RAISE NOTICE 'Exam with slug % already exists, skipping.', 'youpass-reading-practice-reading-in-a-whole-new-way';
    RETURN;
  END IF;

  -- Insert Exam
  INSERT INTO exams ("Id", "Slug", "Title", "DescriptionMd", "Category", "Level", "Status", "DurationMin", "CreatedAt", "UpdatedAt")
  VALUES ('e7b53117-9aec-5dc2-9eef-b147dde32879', 'youpass-reading-practice-reading-in-a-whole-new-way', E'IELTS Reading: Reading in a whole new way', E'IELTS Academic Reading Practice: IELTS Reading: Reading in a whole new way', 'IELTS', 'B2', 'PUBLISHED', 60, now(), now());

  -- Insert Section 1
  INSERT INTO exam_sections ("Id", "ExamId", "Idx", "Title", "PassageMd", "InstructionsMd")
  VALUES ('c809a54f-a21e-570f-907f-f82b0c47943d', 'e7b53117-9aec-5dc2-9eef-b147dde32879', 1, E'Reading in a whole new way', E'Reading and writing, like all technologies, are constantly changing. In ancient times, authors often dictated their books. Dictation sounded like an uninterrupted series of words, so scribes wrote these down in one long continuous string, just as they occur in speech. For this reason, text was written without spaces between words until the 11th century.

This continuous script made books hard to read, so only a few people were accomplished at reading them aloud to others. Being able to read silently to yourself was considered an amazing talent; writing was an even rarer skill. In fact, in 15th-century Europe, only one in 20 adult males could write.

After Gutenberg''s invention of the printing press in about 1440, mass-produced books changed the way people read and wrote. The technology of printing increased the number of words available, and more types of media, such as newspapers and magazines, broadened what was written about. Authors no longer had to produce scholarly works, as was common until then, but could write, for example, inexpensive, heart-rending love stories or publish autobiographies, even if they were unknown.

In time, the power of the written word gave birth to the idea of authority and expertise. Laws were compiled into official documents, contracts were written down and nothing was valid unless it was in this form. Painting, music, architecture, dance were all important, but the heartbeat of many cultures was the turning pages of a book. By the early 19th century, public libraries had been built in many cities.

Today, words are migrating from paper to computers, phones, laptops and game consoles. Some 4.5 billion digital screens illuminate our lives. Letters are no longer fixed in black ink on paper, but flitter on a glass surface in a rainbow of colors as fast as our eyes can blink. Screens fill our pockets, briefcases, cars, living-room walls and the sides of buildings. They sit in front of us when we work — regardless of what we do. And of course, these newly ubiquitous screens have changed how we read and write.

The first screens that overtook culture, several decades ago — the big, fat, warm tubes of television — reduced the time we spent reading to such an extent that it seemed as if reading and writing were over. Educators and parents worried deeply that the TV generation would be unable to write. But the interconnected, cool, thin displays of computer screens launched an epidemic of writing that continues to swell. As a consequence, the amount of time people spend reading has almost tripled since 1980. By 2008, the World Wide Web contained more than a trillion pages, and that total grows rapidly every day.

But it is not book reading or newspaper reading, it is screen reading. Screens are always on, and, unlike books, we never stop staring at them. This new platform is very visual, and it is gradually merging words with moving images. You might think of this new medium as books we watch, or television we read. We also use screens to present data, and this encourages numeracy: visualising data and reading charts, looking at pictures and symbols are all part of this new literacy.

Screens engage our bodies, too. The most we may do while reading a book is to flip the pages or turn over a corner, but when we use a screen, we interact with what we see. In the futuristic movie Minority Report, the main character stands in front of a screen and hunts through huge amounts of information as if conducting an orchestra. Just as it seemed strange five centuries ago to see someone read silently, in the future it will seem strange to read without moving your body.

In addition, screens encourage more utilitarian (practical) thinking. A new idea or unfamiliar fact will cause a reflex to do something: to research a word, to question your screen ''friends'' for their opinions or to find alternative views. Book reading strengthened our analytical skills, encouraging us to think carefully about how we feel. Screen reading, on the other hand, encourages quick responses, associating this idea with another, equipping us to deal with the thousands of new thoughts expressed every day. For example, we review a movie for our friends while we watch it; we read the owner''s manual of a device we see in a shop before we purchase it, rather than after we get home and discover that it can''t do what we need it to do.

Screens provoke action instead of persuasion. Propaganda is less effective, and false information is hard to deliver in a world of screens because while misinformation travels fast, corrections do, too. On a screen, it is often easier to correct a falsehood than to tell one in the first place. Wikipedia works so well because it removes an error in a single click. In books, we find a revealed truth; on the screen, we assemble our own truth from pieces. What is more, a screen can reveal the inner nature of things. Waving the camera eye of a smartphone over the bar code of a manufactured product reveals its price, origins and even relevant comments by other owners. It is as if the screen displays the object''s intangible essence. A popular children''s toy (Webkinz) instills stuffed animals with a virtual character that is ''hidden'' inside; a screen enables children to play with this inner character online in a virtual world.

In the near future, screens will be the first place we''ll look for answers, for friends, for news, for meaning, for our sense of who we are and who we can be.', E'Read the passage and answer the questions.');

  -- Insert Question Group 1
  INSERT INTO exam_question_groups ("Id", "SectionId", "Idx", "StartIdx", "EndIdx", "InstructionMd")
  VALUES ('f2bfac9e-7311-567e-99fb-1c3f0632911d', 'c809a54f-a21e-570f-907f-f82b0c47943d', 1, 1, 5, E'### Questions 1–5

Choose the correct letter, A, B, C or D.');

  -- Question 1 (MULTIPLE_CHOICE_SINGLE)
  INSERT INTO exam_questions ("Id", "SectionId", "GroupId", "Idx", "Type", "Skill", "Difficulty", "PromptMd", "ExplanationMd", "BlankAcceptTexts", "MatchPairs", "ShortAnswerAcceptTexts")
  VALUES ('4249a0d3-81f3-5b18-aaa5-fad76ba049bf', 'c809a54f-a21e-570f-907f-f82b0c47943d', 'f2bfac9e-7311-567e-99fb-1c3f0632911d', 1, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, E'What does the writer say about dictation?', E'Bước 1: Hiểu và tìm keywords trong câu hỏi: 

Tác giả nói gì về việc đọc chính tả (dictation)?

 

Bước 2: Tìm thông tin dựa trên keywords: 

Bài đọc chỉ rõ "Đọc chính tả nghe như một chuỗi từ không bị ngắt quãng, vì vậy các thư ký viết chúng thành một chuỗi liên tục dài, giống như cách chúng xuất hiện trong lời nói. Vì lý do này, văn bản được viết không có khoảng cách giữa các từ cho đến thế kỷ 11". 

==> Thông tin được in đậm đồng nghĩa với câu B (It affected the way people wrote – Nó ảnh hưởng đến cách mọi người viết).

 

Bước 3: Đáp án: B

 

Bước 4: Giải thích đáp án gây nhiễu:

Đáp án A -> Đoạn văn không nhắc đến việc "dictation giúp mọi người học đọc".

Đáp án C -> Bài không nói dictation không được dùng cho đến thế kỷ 11 – thực ra đó là mốc thời gian khoảng cách giữa các từ xuất hiện.

Đáp án D -> Đoạn văn không đề cập đến việc "dictation chủ yếu dùng cho thư từ".', NULL, NULL, NULL);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('1feb44cf-68bb-55fb-bec9-0925a840fa91', '4249a0d3-81f3-5b18-aaa5-fad76ba049bf', 1, E'A. It helped people learn to read.', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('96621799-1de7-53b1-8f2b-ce6261771a4c', '4249a0d3-81f3-5b18-aaa5-fad76ba049bf', 2, E'B. It affected the way people wrote.', true);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('e120191a-893a-51b3-950e-75e80a1db4e5', '4249a0d3-81f3-5b18-aaa5-fad76ba049bf', 3, E'C. It was not used until the 11th century.', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('35db9cac-8a70-5217-8928-9ec334c2e64f', '4249a0d3-81f3-5b18-aaa5-fad76ba049bf', 4, E'D. It was used mainly for correspondence.', false);

  -- Question 2 (MULTIPLE_CHOICE_SINGLE)
  INSERT INTO exam_questions ("Id", "SectionId", "GroupId", "Idx", "Type", "Skill", "Difficulty", "PromptMd", "ExplanationMd", "BlankAcceptTexts", "MatchPairs", "ShortAnswerAcceptTexts")
  VALUES ('52683ad8-e1b2-54a2-a0fb-1acf89ed2086', 'c809a54f-a21e-570f-907f-f82b0c47943d', 'f2bfac9e-7311-567e-99fb-1c3f0632911d', 2, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, E'According to the writer, what changed after the invention of the printing press?', E'Bước 1: Hiểu và tìm keywords trong câu hỏi: 

Theo tác giả, điều gì thay đổi sau khi máy in được phát minh?

 

Bước 2: Tìm thông tin dựa trên keywords: 

Bài đọc chỉ rõ "Các tác giả không còn phải sản xuất các tác phẩm học thuật như trước đây, mà có thể viết các câu chuyện tình cảm rẻ tiền, hay xuất bản tự truyện, thậm chí nếu họ là người vô danh". 

==> Thông tin được in đậm đồng nghĩa với câu D (Authors had a wider choice of topics – Các tác giả có nhiều lựa chọn chủ đề hơn).

 

Bước 3: Đáp án: D

 

Bước 4: Giải thích đáp án gây nhiễu:

Đáp án A -> Đoạn văn không nói "truyện lãng mạn trở nên phổ biến hơn tiểu thuyết nghiêm túc" – đây chỉ là một ví dụ về thể loại mới.

Đáp án B -> Đoạn văn không đề cập đến việc "báo phổ biến hơn sách".

Đáp án C -> Đoạn văn không nói "độc giả yêu cầu thêm tự truyện".', NULL, NULL, NULL);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('c739d776-5579-5311-aeed-eb8ec7f981e8', '52683ad8-e1b2-54a2-a0fb-1acf89ed2086', 1, E'A. Romance became more popular than serious fiction.', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('49c19697-fa17-5515-9fc9-1f35e90390dc', '52683ad8-e1b2-54a2-a0fb-1acf89ed2086', 2, E'B. Newspapers became more popular than books.', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('c814c49e-5130-5ec9-ae41-b6f9a8b6ccdd', '52683ad8-e1b2-54a2-a0fb-1acf89ed2086', 3, E'C. Readers asked for more autobiographies.', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('d0d0f2b1-8145-53af-9371-66f561fb230d', '52683ad8-e1b2-54a2-a0fb-1acf89ed2086', 4, E'D. Authors had a wider choice of topics.', true);

  -- Question 3 (MULTIPLE_CHOICE_SINGLE)
  INSERT INTO exam_questions ("Id", "SectionId", "GroupId", "Idx", "Type", "Skill", "Difficulty", "PromptMd", "ExplanationMd", "BlankAcceptTexts", "MatchPairs", "ShortAnswerAcceptTexts")
  VALUES ('ae0e02cb-7826-5179-a21b-7c9f411904d1', 'c809a54f-a21e-570f-907f-f82b0c47943d', 'f2bfac9e-7311-567e-99fb-1c3f0632911d', 3, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, E'In the third paragraph, the writer focuses on the', E'Bước 1: Hiểu và tìm keywords trong câu hỏi: 

Ở đoạn thứ ba, tác giả tập trung vào điều gì?

 

Bước 2: Tìm thông tin dựa trên keywords: 

Bài đọc chỉ rõ "Sức mạnh của chữ viết đã sinh ra ý tưởng về thẩm quyền và chuyên môn. Luật pháp được biên soạn thành văn bản chính thức, hợp đồng được viết xuống và không có gì có giá trị trừ khi ở dạng này". 

==> Thông tin được in đậm đồng nghĩa với câu C (The growing status of the written word – Địa vị ngày càng tăng của chữ viết).

 

Bước 3: Đáp án: C

 

Bước 4: Giải thích đáp án gây nhiễu:

Đáp án A -> Đoạn văn không tập trung vào "mối lo ngại pháp lý của tác giả".

Đáp án B -> Đoạn văn không nói về "sự thay đổi nhanh chóng của thư viện công cộng".

Đáp án D -> Đoạn văn không đề cập đến "sự công nhận sách như một hình thức nghệ thuật".', NULL, NULL, NULL);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('235a3c2d-d707-52c6-93c3-7257a28b9483', 'ae0e02cb-7826-5179-a21b-7c9f411904d1', 1, E'A. legal concerns of authors.', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('02d5a35a-a5ad-5fb3-aa5d-8022ecd3ad22', 'ae0e02cb-7826-5179-a21b-7c9f411904d1', 2, E'B. rapid changes in public libraries.', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('8dbbd9b4-c5ba-5072-945a-615d59c31c00', 'ae0e02cb-7826-5179-a21b-7c9f411904d1', 3, E'C. growing status of the written word.', true);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('3ba6a6ce-5db9-5fb3-bf1d-775c56f5333d', 'ae0e02cb-7826-5179-a21b-7c9f411904d1', 4, E'D. recognition of the book as an art form.', false);

  -- Question 4 (MULTIPLE_CHOICE_SINGLE)
  INSERT INTO exam_questions ("Id", "SectionId", "GroupId", "Idx", "Type", "Skill", "Difficulty", "PromptMd", "ExplanationMd", "BlankAcceptTexts", "MatchPairs", "ShortAnswerAcceptTexts")
  VALUES ('ed8888ec-ff48-567a-8199-9525bbd94db7', 'c809a54f-a21e-570f-907f-f82b0c47943d', 'f2bfac9e-7311-567e-99fb-1c3f0632911d', 4, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, E'What does the writer say about screens in the fourth paragraph?', E'Bước 1: Hiểu và tìm keywords trong câu hỏi: 

Tác giả nói gì về màn hình trong đoạn thứ tư?

 

Bước 2: Tìm thông tin dựa trên keywords: 

Bài đọc chỉ rõ "Màn hình lấp đầy túi, cặp xách, xe hơi, tường phòng khách và mặt các tòa nhà của chúng ta. Chúng ngồi trước mặt chúng ta khi chúng ta làm việc – bất kể chúng ta làm gì". 

==> Thông tin được in đậm đồng nghĩa với câu D (They can be found everywhere – Chúng có thể được tìm thấy ở khắp nơi).

 

Bước 3: Đáp án: D

 

Bước 4: Giải thích đáp án gây nhiễu:

Đáp án A -> Đoạn văn không nói "màn hình khó đọc".

Đáp án B -> Đoạn văn không đề cập đến việc "màn hình có hại cho sức khỏe".

Đáp án C -> Đoạn văn không nói "màn hình có thể cải thiện công việc của chúng ta".', NULL, NULL, NULL);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('c706352a-9d6a-5aa7-8c32-ccc13db9d87d', 'ed8888ec-ff48-567a-8199-9525bbd94db7', 1, E'A. They are hard to read.', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('433a7586-c823-5b3a-9774-5f4514d6296c', 'ed8888ec-ff48-567a-8199-9525bbd94db7', 2, E'B. They are bad for our health.', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('43ccac99-582a-5001-8d7d-8b9319d3c976', 'ed8888ec-ff48-567a-8199-9525bbd94db7', 3, E'C. They can improve our work.', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('b7f7647d-f087-5de9-904e-10d440401ff2', 'ed8888ec-ff48-567a-8199-9525bbd94db7', 4, E'D. They can be found everywhere.', true);

  -- Question 5 (MULTIPLE_CHOICE_SINGLE)
  INSERT INTO exam_questions ("Id", "SectionId", "GroupId", "Idx", "Type", "Skill", "Difficulty", "PromptMd", "ExplanationMd", "BlankAcceptTexts", "MatchPairs", "ShortAnswerAcceptTexts")
  VALUES ('5cae239d-cb99-5e9e-ac23-1a79ab844904', 'c809a54f-a21e-570f-907f-f82b0c47943d', 'f2bfac9e-7311-567e-99fb-1c3f0632911d', 5, 'MULTIPLE_CHOICE_SINGLE', 'READING', 2, E'According to the writer, computers differ from television because they', E'Bước 1: Hiểu và tìm keywords trong câu hỏi: 

Theo tác giả, máy tính khác với truyền hình ở điểm nào?

 

Bước 2: Tìm thông tin dựa trên keywords: 

Bài đọc chỉ rõ "Các màn hình máy tính kết nối đã tạo ra một làn sóng viết lách tiếp tục lan rộng. Kết quả là, lượng thời gian mọi người dành cho việc đọc đã tăng gần gấp ba lần kể từ năm 1980". 

==> Thông tin được in đậm đồng nghĩa với câu A (They encourage more reading – Chúng khuyến khích đọc nhiều hơn).

 

Bước 3: Đáp án: A

 

Bước 4: Giải thích đáp án gây nhiễu:

Đáp án B -> Đoạn văn không nói "máy tính thu hút nhiều chỉ trích hơn".

Đáp án C -> Đoạn văn không đề cập đến việc "máy tính chiếm nhiều thời gian giải trí hơn".

Đáp án D -> Đoạn văn không nói "máy tính có nhiều nội dung giáo dục hơn".', NULL, NULL, NULL);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('d69be932-04fd-5296-a487-751999f47f18', '5cae239d-cb99-5e9e-ac23-1a79ab844904', 1, E'A. encourage more reading.', true);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('a3e2c113-3024-57dc-8158-e1f8fd992034', '5cae239d-cb99-5e9e-ac23-1a79ab844904', 2, E'B. attract more criticism.', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('2d859955-d68c-50ef-bedf-8cd34e067762', '5cae239d-cb99-5e9e-ac23-1a79ab844904', 3, E'C. take up more of our leisure time.', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('083c48e2-ec9b-5bf7-b86b-8aa565637faa', '5cae239d-cb99-5e9e-ac23-1a79ab844904', 4, E'D. include more educational content.', false);

  -- Insert Question Group 2
  INSERT INTO exam_question_groups ("Id", "SectionId", "Idx", "StartIdx", "EndIdx", "InstructionMd")
  VALUES ('9446db9f-5d14-5240-83dc-9261497fab8b', 'c809a54f-a21e-570f-907f-f82b0c47943d', 2, 6, 10, E'### Questions 6–10

Do the following statements agree with the views of the writer?
Write:

YES if the statement agrees

NO if it contradicts 

NOT GIVEN if it is impossible to say.');

  -- Question 6 (YES_NO_NOT_GIVEN)
  INSERT INTO exam_questions ("Id", "SectionId", "GroupId", "Idx", "Type", "Skill", "Difficulty", "PromptMd", "ExplanationMd", "BlankAcceptTexts", "MatchPairs", "ShortAnswerAcceptTexts")
  VALUES ('4130a91e-65e7-5bbc-9801-b96a062817eb', 'c809a54f-a21e-570f-907f-f82b0c47943d', '9446db9f-5d14-5240-83dc-9261497fab8b', 6, 'YES_NO_NOT_GIVEN', 'READING', 2, E'Screen reading has reduced the number of books and newspapers people read.', E'Bước 1: Hiểu câu hỏi: 

Việc đọc trên màn hình đã làm giảm số lượng sách và báo mà mọi người đọc.

 

Bước 2: Tìm các keywords được paraphrase trong bài:

screen reading ~ từ khóa giữ nguyên

reduced the number ~ không có thông tin cụ thể

books and newspapers ~ từ khóa giữ nguyên

 

Bước 3: So sánh và đối chiếu: 

Bài đọc đề cập đến việc "Đây không phải là đọc sách hay báo, mà là đọc màn hình". 

==> Tuy nhiên, bài đọc không hề nhắc đến thông tin "màn hình có làm giảm số lượng sách và báo mà mọi người đọc hay không" (Screen reading has reduced the number of books and newspapers people read).

 

Bước 4: Đáp án: NOT GIVEN', NULL, NULL, NULL);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('8b8eb5c7-d24c-560d-8c34-15c8e831aabd', '4130a91e-65e7-5bbc-9801-b96a062817eb', 1, E'YES', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('f3a4f0f5-ce0b-5099-b4d5-2368503c879c', '4130a91e-65e7-5bbc-9801-b96a062817eb', 2, E'NO', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('2a2f3e77-df0f-5088-9b83-0a5ec84dc8a9', '4130a91e-65e7-5bbc-9801-b96a062817eb', 3, E'NOT GIVEN', true);

  -- Question 7 (YES_NO_NOT_GIVEN)
  INSERT INTO exam_questions ("Id", "SectionId", "GroupId", "Idx", "Type", "Skill", "Difficulty", "PromptMd", "ExplanationMd", "BlankAcceptTexts", "MatchPairs", "ShortAnswerAcceptTexts")
  VALUES ('3c7eac93-d939-57f4-a78f-bd5a671af243', 'c809a54f-a21e-570f-907f-f82b0c47943d', '9446db9f-5d14-5240-83dc-9261497fab8b', 7, 'YES_NO_NOT_GIVEN', 'READING', 2, E'Screen literacy requires a wider range of visual skills than book-based literacy.', E'Bước 1: Hiểu câu hỏi: 

Khả năng đọc màn hình đòi hỏi nhiều kỹ năng thị giác hơn so với khả năng đọc dựa trên sách.

 

Bước 2: Tìm các keywords được paraphrase trong bài:

wider range of visual skills ~ visualising data, reading charts, looking at pictures and symbols

screen literacy ~ new literacy

book-based literacy ~ book reading

 

Bước 3: So sánh và đối chiếu: Bài đọc chỉ rõ "Nền tảng mới này rất trực quan và dần dần hợp nhất chữ viết với hình ảnh chuyển động. Hình dung dữ liệu và đọc biểu đồ, nhìn vào hình ảnh và ký hiệu đều là một phần của khả năng đọc viết mới này". 

==> Điều này đồng nghĩa với thông tin trong câu hỏi "khả năng đọc màn hình đòi hỏi nhiều kỹ năng thị giác hơn" (Screen literacy requires a wider range of visual skills than book-based literacy).

 

Bước 4: Đáp án: YES', NULL, NULL, NULL);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('fca3cdeb-e421-5a5e-8fcf-7ea12ccd2c74', '3c7eac93-d939-57f4-a78f-bd5a671af243', 1, E'YES', true);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('3be1fe39-8a5b-5e03-af6b-c9b37bb259e2', '3c7eac93-d939-57f4-a78f-bd5a671af243', 2, E'NO', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('147418f4-eb64-5c0a-87f6-3c3460d4e26f', '3c7eac93-d939-57f4-a78f-bd5a671af243', 3, E'NOT GIVEN', false);

  -- Question 8 (YES_NO_NOT_GIVEN)
  INSERT INTO exam_questions ("Id", "SectionId", "GroupId", "Idx", "Type", "Skill", "Difficulty", "PromptMd", "ExplanationMd", "BlankAcceptTexts", "MatchPairs", "ShortAnswerAcceptTexts")
  VALUES ('56698db8-24ae-565f-ac14-0791f2b903b3', 'c809a54f-a21e-570f-907f-f82b0c47943d', '9446db9f-5d14-5240-83dc-9261497fab8b', 8, 'YES_NO_NOT_GIVEN', 'READING', 2, E'Screen reading is more active than book reading.', E'Bước 1: Hiểu câu hỏi: 

Đọc trên màn hình tích cực hơn so với đọc sách.

 

Bước 2: Tìm các keywords được paraphrase trong bài:

more active ~ engage our bodies / interact with what we see

screen reading ~ từ khóa giữ nguyên

book reading ~ từ khóa giữ nguyên

 

Bước 3: So sánh và đối chiếu: Bài đọc chỉ rõ "Điều nhiều nhất chúng ta có thể làm khi đọc sách là lật trang hoặc gập góc, nhưng khi sử dụng màn hình, chúng ta tương tác với những gì chúng ta thấy". 

==> Điều này đồng nghĩa với thông tin trong câu hỏi "đọc trên màn hình tích cực hơn đọc sách" (Screen reading is more active than book reading).

 

Bước 4: Đáp án: YES', NULL, NULL, NULL);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('ec1ef9de-30db-53ee-97ae-5b988ec64374', '56698db8-24ae-565f-ac14-0791f2b903b3', 1, E'YES', true);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('1bfd7d84-285d-5555-947c-73c39fc3c850', '56698db8-24ae-565f-ac14-0791f2b903b3', 2, E'NO', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('0140037d-9ef8-53e4-abca-41be69fa1172', '56698db8-24ae-565f-ac14-0791f2b903b3', 3, E'NOT GIVEN', false);

  -- Question 9 (YES_NO_NOT_GIVEN)
  INSERT INTO exam_questions ("Id", "SectionId", "GroupId", "Idx", "Type", "Skill", "Difficulty", "PromptMd", "ExplanationMd", "BlankAcceptTexts", "MatchPairs", "ShortAnswerAcceptTexts")
  VALUES ('1dc3be82-43cf-573c-8efd-2a60ed13e3ff', 'c809a54f-a21e-570f-907f-f82b0c47943d', '9446db9f-5d14-5240-83dc-9261497fab8b', 9, 'YES_NO_NOT_GIVEN', 'READING', 2, E'Screens and books produce similar thought patterns in their readers.', E'Bước 1: Hiểu câu hỏi: 

Màn hình và sách tạo ra các kiểu tư duy tương tự ở người đọc.

 

Bước 2: Tìm các keywords được paraphrase trong bài:

similar thought patterns ~ trái ngược với thông tin trong bài

screens and books ~ từ khóa giữ nguyên

 

Bước 3: So sánh và đối chiếu: 

Bài đọc chỉ rõ "Đọc sách củng cố kỹ năng phân tích của chúng ta, khuyến khích chúng ta suy nghĩ cẩn thận. Đọc trên màn hình, mặt khác, khuyến khích phản ứng nhanh". 

==> Điều này trái ngược với thông tin trong câu hỏi "màn hình và sách tạo ra các kiểu tư duy tương tự" (Screens and books produce similar thought patterns).

 

Bước 4: Đáp án: NO', NULL, NULL, NULL);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('cf4defac-5203-5495-8667-2084028518f1', '1dc3be82-43cf-573c-8efd-2a60ed13e3ff', 1, E'YES', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('2cf6fd7f-e90f-51e1-8eb1-ea21d8d84102', '1dc3be82-43cf-573c-8efd-2a60ed13e3ff', 2, E'NO', true);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('1a79f7c4-7ead-52d4-ad81-10fd7a7265eb', '1dc3be82-43cf-573c-8efd-2a60ed13e3ff', 3, E'NOT GIVEN', false);

  -- Question 10 (YES_NO_NOT_GIVEN)
  INSERT INTO exam_questions ("Id", "SectionId", "GroupId", "Idx", "Type", "Skill", "Difficulty", "PromptMd", "ExplanationMd", "BlankAcceptTexts", "MatchPairs", "ShortAnswerAcceptTexts")
  VALUES ('7ed9e3c7-ede3-5cec-9e76-2e3836bc9230', 'c809a54f-a21e-570f-907f-f82b0c47943d', '9446db9f-5d14-5240-83dc-9261497fab8b', 10, 'YES_NO_NOT_GIVEN', 'READING', 2, E'People are easily persuaded to believe lies on the screen.', E'Bước 1: Hiểu câu hỏi: 

Mọi người dễ dàng bị thuyết phục tin vào những điều sai trên màn hình.

 

Bước 2: Tìm các keywords được paraphrase trong bài:

easily persuaded to believe lies ~ trái ngược với false information is hard to deliver

on the screen ~ từ khóa giữ nguyên

 

Bước 3: So sánh và đối chiếu: 

Bài đọc chỉ rõ "Thông tin sai lệch rất khó phát tán trong thế giới màn hình vì trong khi thông tin sai lan nhanh, các bản sửa chữa cũng vậy. Trên màn hình, thường dễ dàng hơn để sửa một sai lầm hơn là nói dối ngay từ đầu". 

==> Điều này trái ngược với thông tin trong câu hỏi "mọi người dễ dàng bị thuyết phục tin vào những điều sai" (People are easily persuaded to believe lies on the screen).

 

Bước 4: Đáp án: NO', NULL, NULL, NULL);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('1ec93bc7-133c-5f48-9594-d1771081aff7', '7ed9e3c7-ede3-5cec-9e76-2e3836bc9230', 1, E'YES', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('d38701f6-a761-565e-a747-17639ee821d1', '7ed9e3c7-ede3-5cec-9e76-2e3836bc9230', 2, E'NO', true);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('069392b8-c86a-54e1-9909-dc4962f16ccd', '7ed9e3c7-ede3-5cec-9e76-2e3836bc9230', 3, E'NOT GIVEN', false);

  -- Insert Question Group 3
  INSERT INTO exam_question_groups ("Id", "SectionId", "Idx", "StartIdx", "EndIdx", "InstructionMd")
  VALUES ('fa246b3a-3dc0-5340-9e69-af0790577338', 'c809a54f-a21e-570f-907f-f82b0c47943d', 3, 11, 14, E'### Questions 11–14

Complete each sentence with the correct ending, A–F, below.');

  -- Question 11 (MATCHING_INFORMATION)
  INSERT INTO exam_questions ("Id", "SectionId", "GroupId", "Idx", "Type", "Skill", "Difficulty", "PromptMd", "ExplanationMd", "BlankAcceptTexts", "MatchPairs", "ShortAnswerAcceptTexts")
  VALUES ('f0fb15cf-005a-5f1f-aafd-b5b509e6c522', 'c809a54f-a21e-570f-907f-f82b0c47943d', 'fa246b3a-3dc0-5340-9e69-af0790577338', 11, 'MATCHING_INFORMATION', 'READING', 2, E'The film Minority Report illustrates', E'Bước 1: Hiểu câu hỏi: 

Bộ phim Minority Report minh họa điều gì?

 

Bước 2: Tìm các keywords được paraphrase trong bài:

Minority Report ~ từ khóa giữ nguyên

illustrates ~ seemed strange / moving your body

physically when they read screens ~ read without moving your body

 

Bước 3: So sánh và đối chiếu: 

Bài đọc chỉ rõ "Trong bộ phim tương lai Minority Report, nhân vật chính đứng trước màn hình và tìm kiếm thông tin như đang chỉ huy một dàn nhạc. Cũng như việc thấy ai đó đọc thầm có vẻ kỳ lạ năm thế kỷ trước, trong tương lai sẽ có vẻ kỳ lạ khi đọc mà không cố động cơ thể". 

==> Thông tin được in đậm đồng nghĩa với đáp án D (how people behave physically when they read screens – cách mọi người cư xử về mặt thể chất khi đọc màn hình).

 

Bước 4: Đáp án: D', NULL, '{"11": ["D", "D. how people behave physically when they read screens."]}'::jsonb, NULL);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('7020c672-b67a-53a7-84cb-2d15b8a12c05', 'f0fb15cf-005a-5f1f-aafd-b5b509e6c522', 1, E'A. the accuracy of its information.', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('c89f221c-af40-572f-b356-94b9073f68f5', 'f0fb15cf-005a-5f1f-aafd-b5b509e6c522', 2, E'B. people''s ability to concentrate.', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('22479dc6-3e47-5db4-a93c-5e3231392a4f', 'f0fb15cf-005a-5f1f-aafd-b5b509e6c522', 3, E'C. the global use of the Internet.', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('7a910f50-0c40-5e8d-acc6-b49979518252', 'f0fb15cf-005a-5f1f-aafd-b5b509e6c522', 4, E'D. how people behave physically when they read screens.', true);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('b963d806-a1cb-5ae0-a08a-85adf5d5313c', 'f0fb15cf-005a-5f1f-aafd-b5b509e6c522', 5, E'E. the screen''s ability to make an object seem real.', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('37700873-8bda-5db3-9694-8433df4e94fd', 'f0fb15cf-005a-5f1f-aafd-b5b509e6c522', 6, E'F. how rapidly opinions can be communicated.', false);

  -- Question 12 (MATCHING_INFORMATION)
  INSERT INTO exam_questions ("Id", "SectionId", "GroupId", "Idx", "Type", "Skill", "Difficulty", "PromptMd", "ExplanationMd", "BlankAcceptTexts", "MatchPairs", "ShortAnswerAcceptTexts")
  VALUES ('de56d6c4-a027-5cc7-a91b-6d60204b2f03', 'c809a54f-a21e-570f-907f-f82b0c47943d', 'fa246b3a-3dc0-5340-9e69-af0790577338', 12, 'MATCHING_INFORMATION', 'READING', 2, E'Our behaviour when we watch a film shows', E'Bước 1: Hiểu câu hỏi: 

Hành vi của chúng ta khi xem phim cho thấy điều gì?

 

Bước 2: Tìm các keywords được paraphrase trong bài:

watch a film ~ từ khóa giữ nguyên

behaviour ~ review a movie for our friends

how rapidly opinions can be communicated ~ while we watch it

 

Bước 3: So sánh và đối chiếu: 

Bài đọc chỉ rõ "Ví dụ, chúng ta đánh giá một bộ phim cho bạn bè trong khi chúng ta xem nó". 

==> Thông tin được in đậm đồng nghĩa với đáp án F (how rapidly opinions can be communicated – ý kiến có thể được truyền đạt nhanh như thế nào).

 

Bước 4: Đáp án: F', NULL, '{"12": ["F", "F. how rapidly opinions can be communicated."]}'::jsonb, NULL);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('8678dba3-e98c-5533-b5bf-282ad8c3b8c7', 'de56d6c4-a027-5cc7-a91b-6d60204b2f03', 1, E'A. the accuracy of its information.', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('c49d8de6-feda-587b-a95a-b4d1d1dd65bf', 'de56d6c4-a027-5cc7-a91b-6d60204b2f03', 2, E'B. people''s ability to concentrate.', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('9cd4e47f-c5a1-5a23-ab63-fae98be5af9e', 'de56d6c4-a027-5cc7-a91b-6d60204b2f03', 3, E'C. the global use of the Internet.', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('2a2f46f6-50f0-5a74-985a-ca8055a4f8da', 'de56d6c4-a027-5cc7-a91b-6d60204b2f03', 4, E'D. how people behave physically when they read screens.', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('229be772-2055-5b40-b40a-59f301845e5f', 'de56d6c4-a027-5cc7-a91b-6d60204b2f03', 5, E'E. the screen''s ability to make an object seem real.', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('384566db-f312-52e7-9daa-ec46d3889452', 'de56d6c4-a027-5cc7-a91b-6d60204b2f03', 6, E'F. how rapidly opinions can be communicated.', true);

  -- Question 13 (MATCHING_INFORMATION)
  INSERT INTO exam_questions ("Id", "SectionId", "GroupId", "Idx", "Type", "Skill", "Difficulty", "PromptMd", "ExplanationMd", "BlankAcceptTexts", "MatchPairs", "ShortAnswerAcceptTexts")
  VALUES ('9eb0a2b0-af5e-5fbf-b01d-f44a63933c63', 'c809a54f-a21e-570f-907f-f82b0c47943d', 'fa246b3a-3dc0-5340-9e69-af0790577338', 13, 'MATCHING_INFORMATION', 'READING', 2, E'Wikipedia''s success relies on', E'Bước 1: Hiểu câu hỏi: 

Sự thành công của Wikipedia dựa vào điều gì?

 

Bước 2: Tìm các keywords được paraphrase trong bài:

Wikipedia''s success ~ từ khóa giữ nguyên

accuracy of its information ~ removes an error

relies on ~ works so well because

 

Bước 3: So sánh và đối chiếu: 

Bài đọc chỉ rõ "Wikipedia hoạt động tốt vì nó loại bỏ lỗi chỉ bằng một cú nhấp chuột". 

==> Thông tin được in đậm đồng nghĩa với đáp án A (the accuracy of its information – độ chính xác của thông tin).

 

Bước 4: Đáp án: A', NULL, '{"13": ["A", "A. the accuracy of its information."]}'::jsonb, NULL);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('a111fafe-c513-5243-b0a9-e9fa75a97d86', '9eb0a2b0-af5e-5fbf-b01d-f44a63933c63', 1, E'A. the accuracy of its information.', true);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('13a29050-d1cf-5143-8a41-d980c44a10fe', '9eb0a2b0-af5e-5fbf-b01d-f44a63933c63', 2, E'B. people''s ability to concentrate.', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('aee5b7e5-9d98-5cd7-ac7b-eccf3974c87c', '9eb0a2b0-af5e-5fbf-b01d-f44a63933c63', 3, E'C. the global use of the Internet.', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('2ee0624a-1f2c-54f8-98ea-59627fe11532', '9eb0a2b0-af5e-5fbf-b01d-f44a63933c63', 4, E'D. how people behave physically when they read screens.', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('83aa0879-36d5-5e83-95f2-179b071d7cdf', '9eb0a2b0-af5e-5fbf-b01d-f44a63933c63', 5, E'E. the screen''s ability to make an object seem real.', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('68448dd7-42ce-51d0-b5dd-b7e3e3fca695', '9eb0a2b0-af5e-5fbf-b01d-f44a63933c63', 6, E'F. how rapidly opinions can be communicated.', false);

  -- Question 14 (MATCHING_INFORMATION)
  INSERT INTO exam_questions ("Id", "SectionId", "GroupId", "Idx", "Type", "Skill", "Difficulty", "PromptMd", "ExplanationMd", "BlankAcceptTexts", "MatchPairs", "ShortAnswerAcceptTexts")
  VALUES ('6c384fa7-0df1-5453-83b1-b6d9f252068a', 'c809a54f-a21e-570f-907f-f82b0c47943d', 'fa246b3a-3dc0-5340-9e69-af0790577338', 14, 'MATCHING_INFORMATION', 'READING', 2, E'Webkinz is an example of', E'Bước 1: Hiểu câu hỏi: 

Webkinz là ví dụ về điều gì?

 

Bước 2: Tìm các keywords được paraphrase trong bài:

Webkinz ~ từ khóa giữ nguyên

screen''s ability to make an object seem real ~ reveals the inner nature / intangible essence

example of ~ instills stuffed animals with a virtual character

 

Bước 3: So sánh và đối chiếu: 

Bài đọc chỉ rõ "Một màn hình có thể tiết lộ bản chất bên trong của sự vật. Webkinz trang bị cho thú nhồi bông một nhân vật ảo được ''ẩn'' bên trong; màn hình cho phép trẻ em chơi với nhân vật bên trong này trực tuyến". 

==> Thông tin được in đậm đồng nghĩa với đáp án E (the screen''s ability to make an object seem real – khả năng của màn hình khiến một vật thể trở nên có thực).

 

Bước 4: Đáp án: E', NULL, '{"14": ["E", "E. the screen''s ability to make an object seem real."]}'::jsonb, NULL);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('a88b0166-01df-5604-9a50-5e61ceb76a8f', '6c384fa7-0df1-5453-83b1-b6d9f252068a', 1, E'A. the accuracy of its information.', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('690f9630-e46a-5e53-b674-11063d94b3fd', '6c384fa7-0df1-5453-83b1-b6d9f252068a', 2, E'B. people''s ability to concentrate.', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('b8734ddc-40fe-56c0-b4c0-8acfde036bbb', '6c384fa7-0df1-5453-83b1-b6d9f252068a', 3, E'C. the global use of the Internet.', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('11dfaccb-295d-5f56-b2ca-78c04118089a', '6c384fa7-0df1-5453-83b1-b6d9f252068a', 4, E'D. how people behave physically when they read screens.', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('76738a3a-a900-5e25-bf44-a60aa3d03db6', '6c384fa7-0df1-5453-83b1-b6d9f252068a', 5, E'E. the screen''s ability to make an object seem real.', true);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('200bb278-28ef-5f57-a9ed-495ff532fda6', '6c384fa7-0df1-5453-83b1-b6d9f252068a', 6, E'F. how rapidly opinions can be communicated.', false);

  RAISE NOTICE 'Successfully seeded exam % with % questions.', 'youpass-reading-practice-reading-in-a-whole-new-way', 14;
END$$;

-- ============================================================
-- Exam: IELTS Reading: Western Immigration of Canada
-- Slug: youpass-reading-practice-western-immigration-of-canada
-- Source: 10282_youpass-collect-western-immigration-of-canada.json
-- ============================================================
DO $$
BEGIN
  -- Check if exam already exists (strictly append-only)
  IF EXISTS (SELECT 1 FROM exams WHERE "Slug" = 'youpass-reading-practice-western-immigration-of-canada') THEN
    RAISE NOTICE 'Exam with slug % already exists, skipping.', 'youpass-reading-practice-western-immigration-of-canada';
    RETURN;
  END IF;

  -- Insert Exam
  INSERT INTO exams ("Id", "Slug", "Title", "DescriptionMd", "Category", "Level", "Status", "DurationMin", "CreatedAt", "UpdatedAt")
  VALUES ('ea9cc216-5182-5b04-8631-a3ad34646e5c', 'youpass-reading-practice-western-immigration-of-canada', E'IELTS Reading: Western Immigration of Canada', E'IELTS Academic Reading Practice: IELTS Reading: Western Immigration of Canada', 'IELTS', 'B2', 'PUBLISHED', 60, now(), now());

  -- Insert Section 1
  INSERT INTO exam_sections ("Id", "ExamId", "Idx", "Title", "PassageMd", "InstructionsMd")
  VALUES ('68561a58-394e-5f05-87bb-ded5ac370691', 'ea9cc216-5182-5b04-8631-a3ad34646e5c', 1, E'[YouPass Collect] - Western Immigration of Canada', E'Demand of western immigration

By the mid-1870s Canada wanted an immigrant population of agricultural settlers established in the West. No urban centres existed on the prairies in the 1870s, and rural settlement was the focus of the federal government''s attention. The western rural settlement was desired, as it would provide homesteads for the sons and daughters of eastern farmers, as eastern agricultural land filled to capacity. As well, eastern farmers and politicians viewed western Canada, with its broad expanses of unpopulated land, as a prime location for expanding Canada''s agricultural output, especially in terms of wheat production to serve the markets of eastern Canada.

To bolster Canada''s population and agricultural output, the federal government took steps to secure western land. The Dominion of Canada purchased Rupert''s Land from the Hudson''s Bay Company in 1870. In 1872, the federal government enacted the Dominion Lands Act. This act enabled settlers to acquire 160 acres of free land, as long as settlers remained on their land for a period of three years, made certain minor improvements to the land, and paid a $10.00 registration fee. The Canadian government also created a Mounted Police Force in 1873. The Mounties journeyed west to secure the area for future settlers. By 1876 the NWMP had established themselves in the West. The major posts included Swan River, Fort Saskatchewan, Fort Calgary, Fort Walsh and Fort Macleod. All of these initiatives attracted a number of Eastern-Canadian settlers, as well as European and American immigrants, to Canada''s West, and particularly to the area of Manitoba.

The surest way to protect Canadian territory, and to achieve the secondary goal for joining British Columbia to the rest of the country, was to import large numbers of Eastern Canadian and British settlers. Settling the West also made imperative the building of a transcontinental railway. The railway would work to create an east-west economy, in which western Canada would feed the growing urban industrial population of the east, and in return become a market for eastern Canadian manufactured goods.

Winnipeg became the metropolis of the West during this period. Winnipeg''s growth before 1900 was the result of a combination of land speculation, growth of housing starts, and the federal government''s solution in 1881 of Winnipeg as a major stop along the CPR. This decision culminated in a land boom between 1881 and 1883 which resulted in the transformation of hamlets like Portage la Prairie and Brandon into towns, and a large increase in Manitoba''s population. Soon, Winnipeg stood at the junction of three transcontinental railway lines which employed thousands in rail yards. Winnipeg also became the major processor of agricultural products for the surrounding hinterland.

The majority of settlers to Winnipeg, and the surrounding countryside, during this early period, were primarily Protestant English-speaking settlers from Ontario and the British Isles. These settlers established Winnipeg upon a British-Ontarian ethos which came to dominate the society''s social, political, and economic spirit. This British-Ontarian ethnic homogeneity, however, did not last very long. Increasing numbers of foreign immigrants, especially from Austria-Hungary and Ukraine soon added a new ethnic element to the recent British, the older First Nation Métis, and Selkirk''s settler population base. Settling the West with (in particular) Eastern Canadians and British immigrant offered the advantage of safeguarding the 49th parallel from the threat of American take-over, had not the Minnesota legislature passed a resolution which provided for the annexation of the Red River district. The Red River in 1870 was the most important settlement on the Canadian prairies. It contained 11,963 inhabitants of whom 9,700 were Métis and First Nations. But neighbouring Minnesota already had a population of over 100,000.

Not all of the settlers who came to western Canada in the 1880s, however, desired to remain there. In the 1870s and 1880s, economic depression kept the value of Canada''s staple exports low, which discouraged many from permanent settlement in the West. Countries including Brazil, Argentina, Australia, New Zealand and the United States competed with Canada for immigrants. Many immigrants and thousands of Canadians chose to settle in the accessible and attractive American frontier. Canada before 1891 has been called "a huge demographic railway station" where thousands of men, women, and children were constantly going and coming, and where the number of departures invariably exceeded that of arrivals.

By 1891 Eastern Canada had its share of both large urban centres and problems associated with city life. While the booming economic centres of Toronto and Montreal were complete with electricity and telephones in the cities'' wealthiest areas by the turn of the century, slum conditions characterised the poorest areas like the district known as ''the Ward'' in Toronto. Chickens and pigs ran through the streets; privy buckets spilled onto backyards and lanes creating cesspools in urban slums. These same social reformers believed that rural living, in stark contrast to urban, would lead to a healthy, moral, and charitable way of life. Social reformers praised the ability of fresh air, hard work, and open spaces for ''Canadianizing'' immigrants. Agricultural pursuits were seen as especially fitting for attaining this ''moral'' and family-oriented way of life, in opposition to the single male-dominated atmosphere of the cities. Certainly, agriculture played an important part in the Canadian economy in 1891. One-third of the workforce worked on farms.

The Canadian government presented Canada''s attractions to potential overseas migrants in several ways. The government offered free or cheap land to potential agriculturists. As well, the government established agents and/or agencies for the purpose of attracting emigrants overseas. Assisted passage schemes, bonuses and commissions to agents and settlers and pamphlets also attracted some immigrants to Canada. The most influential form of attracting others to Canada, however, remained the letters home written by emigrants already in Canada. Letters from trusted friends and family members. Letters home often contained exaggerations of the ''wonder of the new world.'' Migrant workers and settlers already in Canada did not want to disappoint, or worry, their family and friends at home. Embellished tales of good fortune and happiness often succeeded in encouraging others to come.', E'Read the passage and answer the questions.');

  -- Insert Question Group 1
  INSERT INTO exam_question_groups ("Id", "SectionId", "Idx", "StartIdx", "EndIdx", "InstructionMd")
  VALUES ('d41b879b-7058-5621-a56a-aaaa4888fcd8', '68561a58-394e-5f05-87bb-ded5ac370691', 1, 1, 7, E'### Questions 1–7

The Reading Passage has eight paragraphs. 
Choose the correct heading from the list below. 
Choose the correct number, i-xii, in boxes 1–7.

**List of Headings:**
- i. i. Not all would stay in Canada forever
- ii. ii. Government''s safeguard in the West
- iii. iii. Eastern Canada is full
- iv. iv. Built-up to the new infrastructure
- v. v. An exclusive British domination in Ontario established ever since
- vi. vi. Ethnic and language make-up
- vii. vii. Pursuing a pure life
- viii. viii. Police recruited from mid-class families
- ix. ix. Demand of western immigration
- x. x. Early major urban development of the West
- xi. xi. Attracting urban environment
- xii. xii. Advertising of Western Canada');

  -- Question 1 (MATCHING_HEADING)
  INSERT INTO exam_questions ("Id", "SectionId", "GroupId", "Idx", "Type", "Skill", "Difficulty", "PromptMd", "ExplanationMd", "BlankAcceptTexts", "MatchPairs", "ShortAnswerAcceptTexts")
  VALUES ('87e28f66-2d90-5cb4-a1eb-cbde2d1df19f', '68561a58-394e-5f05-87bb-ded5ac370691', 'd41b879b-7058-5621-a56a-aaaa4888fcd8', 1, 'MATCHING_HEADING', 'READING', 2, E'Paragraph 1', E'Bước 1: Đọc và hiểu đoạn 1: 

Vào giữa thập niên 1870, Canada muốn có dân số nhập cư là những người định cư nông nghiệp ở miền Tây. Không có trung tâm đô thị nào trên vùng thảo nguyên. Việc định cư nông thôn miền Tây được mong muốn vì nó cung cấp trang trại nhà ở cho con em nông dân miền Đông khi đất nông nghiệp miền Đông đã lấp đầy. Miền Tây cũng được xem là địa điểm mở rộng sản lượng nông nghiệp, đặc biệt là lúa mì.

 

Bước 2: Tóm tắt nội dung chính của đoạn 1: 
Đoạn 1 có nội dung chính là "Nhu cầu thu hút người nhập cư đến định cư nông nghiệp tại miền Tây Canada vào giữa thập niên 1870 để mở rộng sản lượng nông nghiệp".

 

Bước 3: So sánh và đối chiếu: 

Thông tin được in đậm phù hợp với tiêu đề ix "Demand of western immigration" (Nhu cầu nhập cư miền Tây).

 

Bước 4: Loại trừ các tiêu đề dễ gây nhầm lẫn:

iii "Eastern Canada is full": Đoạn 1 có đề cập đến đất nông nghiệp miền Đông đang lấp đầy, nhưng đây chỉ là lý do phụ. Nội dung chính xoay quanh nhu cầu thu hút người nhập cư miền Tây, không phải sự quá tải của miền Đông → Tiêu đề không phù hợp.

 

Bước 5: Đáp án: ix', NULL, '{"1": ["ix", "ix. Demand of western immigration"]}'::jsonb, NULL);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('48d76f3f-3b89-5868-b490-2db152316f72', '87e28f66-2d90-5cb4-a1eb-cbde2d1df19f', 1, E'i. Not all would stay in Canada forever', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('c51508a9-aefc-57c5-994a-f5dfd025e0b0', '87e28f66-2d90-5cb4-a1eb-cbde2d1df19f', 2, E'ii. Government''s safeguard in the West', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('5f1225d3-6296-5fd6-b1c3-e70049042e3f', '87e28f66-2d90-5cb4-a1eb-cbde2d1df19f', 3, E'iii. Eastern Canada is full', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('8cec3987-47f2-5350-835c-6cb72239ad8b', '87e28f66-2d90-5cb4-a1eb-cbde2d1df19f', 4, E'iv. Built-up to the new infrastructure', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('a1a7fe09-d3f5-5918-8f17-8409e871c9da', '87e28f66-2d90-5cb4-a1eb-cbde2d1df19f', 5, E'v. An exclusive British domination in Ontario established ever since', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('0c28298d-22dd-5462-ba57-111a3afa6244', '87e28f66-2d90-5cb4-a1eb-cbde2d1df19f', 6, E'vi. Ethnic and language make-up', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('0b76361c-e9da-5e3c-9548-92279cb608bb', '87e28f66-2d90-5cb4-a1eb-cbde2d1df19f', 7, E'vii. Pursuing a pure life', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('cd381261-9c25-5ce5-a83b-29af3c7388e6', '87e28f66-2d90-5cb4-a1eb-cbde2d1df19f', 8, E'viii. Police recruited from mid-class families', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('6292af0c-d8d7-572e-919a-6acbc89739e3', '87e28f66-2d90-5cb4-a1eb-cbde2d1df19f', 9, E'ix. Demand of western immigration', true);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('bb2e9e93-fd50-5e5f-a442-508cbd0e58f7', '87e28f66-2d90-5cb4-a1eb-cbde2d1df19f', 10, E'x. Early major urban development of the West', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('d853c182-8755-5b3e-ab9c-b909c5028e86', '87e28f66-2d90-5cb4-a1eb-cbde2d1df19f', 11, E'xi. Attracting urban environment', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('c830f7ee-609f-59ab-90be-116a5c69c4ed', '87e28f66-2d90-5cb4-a1eb-cbde2d1df19f', 12, E'xii. Advertising of Western Canada', false);

  -- Question 2 (MATCHING_HEADING)
  INSERT INTO exam_questions ("Id", "SectionId", "GroupId", "Idx", "Type", "Skill", "Difficulty", "PromptMd", "ExplanationMd", "BlankAcceptTexts", "MatchPairs", "ShortAnswerAcceptTexts")
  VALUES ('fd282a5c-bf6b-5143-a99f-92e1f16ddd04', '68561a58-394e-5f05-87bb-ded5ac370691', 'd41b879b-7058-5621-a56a-aaaa4888fcd8', 2, 'MATCHING_HEADING', 'READING', 2, E'Paragraph 2', E'Bước 1: Đọc và hiểu đoạn 2: 

Chính phủ liên bang thực hiện các bước để bảo vệ lãnh thổ miền Tây: mua vùng đất Rupert''s Land năm 1870, ban hành Dominion Lands Act năm 1872 cho phép nhận 160 mẫu đất miễn phí, thành lập Lực lượng Cảnh sát Mounted năm 1873, đến 1876 NWMP đã thiết lập các đồn lũy ở miền Tây. Tất cả thu hút người định cư đến Manitoba.

 

Bước 2: Tóm tắt nội dung chính của đoạn 2: 
Đoạn 2 có nội dung chính là "Các biện pháp bảo vệ và quản lý lãnh thổ miền Tây của chính phủ thông qua đạo luật đất đai và thành lập lực lượng cảnh sát".

 

Bước 3: So sánh và đối chiếu: 

Thông tin được in đậm phù hợp với tiêu đề ii "Government''s safeguard in the West" (Sự bảo vệ của chính phủ ở miền Tây).

 

Bước 4: Loại trừ các tiêu đề dễ gây nhầm lẫn:

viii "Police recruited from mid-class families": Đoạn 2 có đề cập đến Lực lượng Cảnh sát Mounted, nhưng không hề nhắc đến nguồn gốc xuất thân tầng lớp trung lưu của cảnh sát → Tiêu đề không phù hợp.

 

Bước 5: Đáp án: ii', NULL, '{"2": ["ii", "ii. Government''s safeguard in the West"]}'::jsonb, NULL);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('5ffe6c9d-aa37-5fb4-acf3-6a8b07da4810', 'fd282a5c-bf6b-5143-a99f-92e1f16ddd04', 1, E'i. Not all would stay in Canada forever', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('a1a45731-4c57-5c65-a13b-de40e838af1f', 'fd282a5c-bf6b-5143-a99f-92e1f16ddd04', 2, E'ii. Government''s safeguard in the West', true);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('4391b1e6-22f6-5001-8688-f61c73b7cc7b', 'fd282a5c-bf6b-5143-a99f-92e1f16ddd04', 3, E'iii. Eastern Canada is full', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('bfff7e9a-42fe-51cf-a743-602e9cbc4a88', 'fd282a5c-bf6b-5143-a99f-92e1f16ddd04', 4, E'iv. Built-up to the new infrastructure', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('6a819bc9-9ce3-5bbc-ae59-d537a5f15c48', 'fd282a5c-bf6b-5143-a99f-92e1f16ddd04', 5, E'v. An exclusive British domination in Ontario established ever since', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('55d42feb-0935-5bc2-87d1-4100207b0098', 'fd282a5c-bf6b-5143-a99f-92e1f16ddd04', 6, E'vi. Ethnic and language make-up', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('0ea3021c-0a26-5177-9cb2-b72819c65405', 'fd282a5c-bf6b-5143-a99f-92e1f16ddd04', 7, E'vii. Pursuing a pure life', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('95ee6600-0f9e-57b7-b593-93d22de5f027', 'fd282a5c-bf6b-5143-a99f-92e1f16ddd04', 8, E'viii. Police recruited from mid-class families', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('39434b9a-6e22-59bf-9478-7270538b7db8', 'fd282a5c-bf6b-5143-a99f-92e1f16ddd04', 9, E'ix. Demand of western immigration', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('4563b584-31a1-56b2-91ae-5e4d8aa23a2b', 'fd282a5c-bf6b-5143-a99f-92e1f16ddd04', 10, E'x. Early major urban development of the West', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('7181014a-430b-5c87-92d2-f58fedd8af72', 'fd282a5c-bf6b-5143-a99f-92e1f16ddd04', 11, E'xi. Attracting urban environment', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('e5f3bab8-d1bc-58c1-9684-28114f8b8112', 'fd282a5c-bf6b-5143-a99f-92e1f16ddd04', 12, E'xii. Advertising of Western Canada', false);

  -- Question 3 (MATCHING_HEADING)
  INSERT INTO exam_questions ("Id", "SectionId", "GroupId", "Idx", "Type", "Skill", "Difficulty", "PromptMd", "ExplanationMd", "BlankAcceptTexts", "MatchPairs", "ShortAnswerAcceptTexts")
  VALUES ('86099b7b-2baa-5d41-9e51-a520f499fb8c', '68561a58-394e-5f05-87bb-ded5ac370691', 'd41b879b-7058-5621-a56a-aaaa4888fcd8', 3, 'MATCHING_HEADING', 'READING', 2, E'Paragraph 3', E'Bước 1: Đọc và hiểu đoạn 3: 

Cách chắc chắn nhất để bảo vệ lãnh thổ Canada và kết nối British Columbia với phần còn lại là đưa nhiều người định cư đến. Việc định cư miền Tây đòi hỏi phải xây dựng tuyến đường sắt xuyên lục địa, giúp tạo ra nền kinh tế theo trục đông-tây: miền Tây cung cấp lương thực, miền Đông cung cấp hàng hóa sản xuất.

 

Bước 2: Tóm tắt nội dung chính của đoạn 3: 
Đoạn 3 có nội dung chính là "Sự cần thiết phải xây dựng cơ sở hạ tầng đường sắt xuyên lục địa để bảo vệ lãnh thổ và kết nối kinh tế đông-tây".

 

Bước 3: So sánh và đối chiếu: 

Thông tin được in đậm phù hợp với tiêu đề iv "Built-up to the new infrastructure" (Xây dựng cơ sở hạ tầng mới).

 

Bước 4: Loại trừ các tiêu đề dễ gây nhầm lẫn:

x "Early major urban development of the West": Đoạn 3 nói về đường sắt như một công cụ kinh tế và bảo vệ lãnh thổ, không đề cập đến sự phát triển đô thị cụ thể → Tiêu đề không phù hợp.

 

Bước 5: Đáp án: iv', NULL, '{"3": ["iv", "iv. Built-up to the new infrastructure"]}'::jsonb, NULL);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('bca35593-55db-5073-9510-e39ec7f498af', '86099b7b-2baa-5d41-9e51-a520f499fb8c', 1, E'i. Not all would stay in Canada forever', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('b070556e-d344-5be4-8762-a061c84965b7', '86099b7b-2baa-5d41-9e51-a520f499fb8c', 2, E'ii. Government''s safeguard in the West', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('7ba5c726-389c-55db-8fb7-23aa3a1ba5be', '86099b7b-2baa-5d41-9e51-a520f499fb8c', 3, E'iii. Eastern Canada is full', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('5dfc469e-4cc4-58eb-afe8-7584300a0c6d', '86099b7b-2baa-5d41-9e51-a520f499fb8c', 4, E'iv. Built-up to the new infrastructure', true);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('58a4a867-39f2-52fa-9c6f-da37fc26cb91', '86099b7b-2baa-5d41-9e51-a520f499fb8c', 5, E'v. An exclusive British domination in Ontario established ever since', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('dce4dd73-3601-5280-91fe-e7c983502da4', '86099b7b-2baa-5d41-9e51-a520f499fb8c', 6, E'vi. Ethnic and language make-up', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('53434400-a665-5449-90a6-d35c32167e4e', '86099b7b-2baa-5d41-9e51-a520f499fb8c', 7, E'vii. Pursuing a pure life', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('2fcb0711-8ed3-5f86-a692-fa163988849b', '86099b7b-2baa-5d41-9e51-a520f499fb8c', 8, E'viii. Police recruited from mid-class families', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('c67d79e7-0401-5ae5-a923-a67996f36245', '86099b7b-2baa-5d41-9e51-a520f499fb8c', 9, E'ix. Demand of western immigration', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('0e350c0f-1bb3-57b1-9ccd-95d08eb5eafe', '86099b7b-2baa-5d41-9e51-a520f499fb8c', 10, E'x. Early major urban development of the West', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('275f1fe1-b12d-52ae-a699-4a618cf401e6', '86099b7b-2baa-5d41-9e51-a520f499fb8c', 11, E'xi. Attracting urban environment', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('dc234697-0cc3-50ff-a4db-697f5274b1b8', '86099b7b-2baa-5d41-9e51-a520f499fb8c', 12, E'xii. Advertising of Western Canada', false);

  -- Question 4 (MATCHING_HEADING)
  INSERT INTO exam_questions ("Id", "SectionId", "GroupId", "Idx", "Type", "Skill", "Difficulty", "PromptMd", "ExplanationMd", "BlankAcceptTexts", "MatchPairs", "ShortAnswerAcceptTexts")
  VALUES ('a5ba780a-09ac-52dc-8643-fb9b526936ba', '68561a58-394e-5f05-87bb-ded5ac370691', 'd41b879b-7058-5621-a56a-aaaa4888fcd8', 4, 'MATCHING_HEADING', 'READING', 2, E'Paragraph 4', E'Bước 1: Đọc và hiểu đoạn 4: 

Winnipeg trở thành đô thị lớn nhất miền Tây trong giai đoạn này. Sự phát triển của Winnipeg đến từ đầu cơ đất đai, xây dựng nhà ở, và quyết định của chính phủ năm 1881 chọn Winnipeg làm điểm dừng chính trên tuyến CPR. Điều này dẫn đến cơn sốt đất 1881–1883, biến các làng nhỏ thành thị trấn. Winnipeg nằm ở ngã tư của ba tuyến đường sắt và trở thành trung tâm chế biến nông sản.

 

Bước 2: Tóm tắt nội dung chính của đoạn 4: 
Đoạn 4 có nội dung chính là "Sự phát triển đô thị sớm và nổi bật của Winnipeg — đô thị lớn đầu tiên của miền Tây Canada — nhờ đầu cơ đất và tuyến đường sắt".

 

Bước 3: So sánh và đối chiếu: 

Thông tin được in đậm phù hợp với tiêu đề x "Early major urban development of the West" (Sự phát triển đô thị lớn đầu tiên ở miền Tây).

 

Bước 4: Loại trừ các tiêu đề dễ gây nhầm lẫn:

iv "Built-up to the new infrastructure": Đoạn 4 có đề cập đến đường sắt nhưng chỉ như một yếu tố góp phần vào sự phát triển của Winnipeg. Trọng tâm đoạn là đô thị hóa, không phải xây dựng hạ tầng → Tiêu đề không phù hợp.

 

Bước 5: Đáp án: x', NULL, '{"4": ["x", "x. Early major urban development of the West"]}'::jsonb, NULL);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('45a65172-555d-5245-afac-8e800d085f29', 'a5ba780a-09ac-52dc-8643-fb9b526936ba', 1, E'i. Not all would stay in Canada forever', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('a2276756-4c1d-5ef0-ac99-31be202684b7', 'a5ba780a-09ac-52dc-8643-fb9b526936ba', 2, E'ii. Government''s safeguard in the West', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('2338309f-f0a7-5b99-96e5-ec42e7a4203d', 'a5ba780a-09ac-52dc-8643-fb9b526936ba', 3, E'iii. Eastern Canada is full', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('bd71358e-4d58-5944-8881-04d046273124', 'a5ba780a-09ac-52dc-8643-fb9b526936ba', 4, E'iv. Built-up to the new infrastructure', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('28b633ac-a29f-5c4e-a5c6-7b23a49d9dac', 'a5ba780a-09ac-52dc-8643-fb9b526936ba', 5, E'v. An exclusive British domination in Ontario established ever since', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('59c086ef-b57a-560d-b0f7-3c9875d0a7a7', 'a5ba780a-09ac-52dc-8643-fb9b526936ba', 6, E'vi. Ethnic and language make-up', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('aea55222-1e06-5ad0-ada9-59ba4ac81951', 'a5ba780a-09ac-52dc-8643-fb9b526936ba', 7, E'vii. Pursuing a pure life', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('97410ddc-7178-5bfb-9c77-3eaaf86f2d11', 'a5ba780a-09ac-52dc-8643-fb9b526936ba', 8, E'viii. Police recruited from mid-class families', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('7622a201-38cd-52ba-8a70-22497c7f3e7b', 'a5ba780a-09ac-52dc-8643-fb9b526936ba', 9, E'ix. Demand of western immigration', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('df64df37-09a6-5346-a13a-56ac6d3aa2ef', 'a5ba780a-09ac-52dc-8643-fb9b526936ba', 10, E'x. Early major urban development of the West', true);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('3707f4e9-9411-5f34-ad94-459e7c8308f9', 'a5ba780a-09ac-52dc-8643-fb9b526936ba', 11, E'xi. Attracting urban environment', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('1b3d2d4a-dc19-5bb8-83c5-d2a9263554b1', 'a5ba780a-09ac-52dc-8643-fb9b526936ba', 12, E'xii. Advertising of Western Canada', false);

  -- Question 5 (MATCHING_HEADING)
  INSERT INTO exam_questions ("Id", "SectionId", "GroupId", "Idx", "Type", "Skill", "Difficulty", "PromptMd", "ExplanationMd", "BlankAcceptTexts", "MatchPairs", "ShortAnswerAcceptTexts")
  VALUES ('f83f0dab-8dc8-574e-a395-833b2b451095', '68561a58-394e-5f05-87bb-ded5ac370691', 'd41b879b-7058-5621-a56a-aaaa4888fcd8', 5, 'MATCHING_HEADING', 'READING', 2, E'Paragraph 5', E'Bước 1: Đọc và hiểu đoạn 5: 

Phần lớn người định cư ban đầu đến Winnipeg là người Anh-ngữ theo đạo Tin lành từ Ontario và quần đảo Anh, hình thành nên tinh thần Anh-Ontario. Tuy nhiên, sự thuần nhất này không kéo dài lâu — ngày càng có nhiều người nhập cư từ Áo-Hungary và Ukraine bổ sung yếu tố dân tộc mới bên cạnh người Anh, người Métis và người của Selkirk.

 

Bước 2: Tóm tắt nội dung chính của đoạn 5: 
Đoạn 5 có nội dung chính là "Thành phần dân tộc và ngôn ngữ của người định cư miền Tây — ban đầu thuần nhất người Anh nhưng dần đa dạng hóa bởi các nhóm dân tộc khác".

 

Bước 3: So sánh và đối chiếu: 

Thông tin được in đậm phù hợp với tiêu đề vi "Ethnic and language make-up" (Thành phần dân tộc và ngôn ngữ).

 

Bước 4: Loại trừ các tiêu đề dễ gây nhầm lẫn:

v "An exclusive British domination in Ontario established ever since": Đoạn 5 có đề cập đến sự thống trị Anh-Ontario, nhưng bài nhấn mạnh rằng sự thuần nhất này không kéo dài (did not last very long) → hoàn toàn trái ngược với "ever since" trong tiêu đề → Tiêu đề không phù hợp.

 

Bước 5: Đáp án: vi', NULL, '{"5": ["vi", "vi. Ethnic and language make-up"]}'::jsonb, NULL);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('9a83adb7-9b03-52c3-995b-1a4d922278b8', 'f83f0dab-8dc8-574e-a395-833b2b451095', 1, E'i. Not all would stay in Canada forever', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('a35ba052-7209-5f13-bc45-8fec1987ca0b', 'f83f0dab-8dc8-574e-a395-833b2b451095', 2, E'ii. Government''s safeguard in the West', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('a66b1cce-fa72-517e-a5d5-b31687f3b4ad', 'f83f0dab-8dc8-574e-a395-833b2b451095', 3, E'iii. Eastern Canada is full', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('f9f79081-aa20-52d8-8217-af7024dd7c44', 'f83f0dab-8dc8-574e-a395-833b2b451095', 4, E'iv. Built-up to the new infrastructure', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('b057bd95-8272-58a6-af09-2b33659b24a3', 'f83f0dab-8dc8-574e-a395-833b2b451095', 5, E'v. An exclusive British domination in Ontario established ever since', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('94d50da7-abdd-533e-b2e4-0331d2977735', 'f83f0dab-8dc8-574e-a395-833b2b451095', 6, E'vi. Ethnic and language make-up', true);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('3b7507af-6267-502f-89bf-5d5a5478f3fe', 'f83f0dab-8dc8-574e-a395-833b2b451095', 7, E'vii. Pursuing a pure life', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('c49a3d35-05fb-5165-a2b6-a79cafedffef', 'f83f0dab-8dc8-574e-a395-833b2b451095', 8, E'viii. Police recruited from mid-class families', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('d5968187-a45c-5a04-9e9e-d102e5d711c8', 'f83f0dab-8dc8-574e-a395-833b2b451095', 9, E'ix. Demand of western immigration', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('6d667bde-40d3-521e-aaef-392207c085f4', 'f83f0dab-8dc8-574e-a395-833b2b451095', 10, E'x. Early major urban development of the West', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('cfdd0dfc-5566-55a2-8b6e-16423892c5bb', 'f83f0dab-8dc8-574e-a395-833b2b451095', 11, E'xi. Attracting urban environment', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('62d41c65-fceb-5fce-8c5e-f5c775767046', 'f83f0dab-8dc8-574e-a395-833b2b451095', 12, E'xii. Advertising of Western Canada', false);

  -- Question 6 (MATCHING_HEADING)
  INSERT INTO exam_questions ("Id", "SectionId", "GroupId", "Idx", "Type", "Skill", "Difficulty", "PromptMd", "ExplanationMd", "BlankAcceptTexts", "MatchPairs", "ShortAnswerAcceptTexts")
  VALUES ('46949aed-2a1f-5979-94f1-c4ef9531f3d4', '68561a58-394e-5f05-87bb-ded5ac370691', 'd41b879b-7058-5621-a56a-aaaa4888fcd8', 6, 'MATCHING_HEADING', 'READING', 2, E'Paragraph 6', E'Bước 1: Đọc và hiểu đoạn 6: 

Không phải tất cả người định cư đến miền Tây đều muốn ở lại. Suy thoái kinh tế thập niên 1870–1880 giữ giá trị xuất khẩu ở mức thấp. Nhiều quốc gia cạnh tranh với Canada thu hút người nhập cư. Canada trước 1891 được gọi là "một nhà ga đường sắt nhân khẩu học khổng lồ" — số người rời đi luôn nhiều hơn số người đến.

 

Bước 2: Tóm tắt nội dung chính của đoạn 6: 
Đoạn 6 có nội dung chính là "Không phải tất cả người định cư đều ở lại Canada — nhiều người rời đi do suy thoái kinh tế và áp lực cạnh tranh từ các quốc gia khác".

 

Bước 3: So sánh và đối chiếu: 

Thông tin được in đậm phù hợp với tiêu đề i "Not all would stay in Canada forever" (Không phải tất cả đều ở lại Canada mãi mãi).

 

Bước 4: Loại trừ các tiêu đề dễ gây nhầm lẫn:

xi "Attracting urban environment": Đoạn 6 không đề cập đến môi trường đô thị thu hút. Nội dung trọng tâm là lý do người định cư rời bỏ Canada → Tiêu đề không phù hợp.

 

Bước 5: Đáp án: i', NULL, '{"6": ["i", "i. Not all would stay in Canada forever"]}'::jsonb, NULL);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('1197fc7f-ecdb-51d4-8795-a0078082c238', '46949aed-2a1f-5979-94f1-c4ef9531f3d4', 1, E'i. Not all would stay in Canada forever', true);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('352cf54f-bfbb-5654-9216-2d268fb4defb', '46949aed-2a1f-5979-94f1-c4ef9531f3d4', 2, E'ii. Government''s safeguard in the West', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('c7ef0a4a-b6c2-5a22-883f-5be096cde193', '46949aed-2a1f-5979-94f1-c4ef9531f3d4', 3, E'iii. Eastern Canada is full', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('231abc39-8cec-5abc-8312-c3d89045c889', '46949aed-2a1f-5979-94f1-c4ef9531f3d4', 4, E'iv. Built-up to the new infrastructure', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('fba39a26-8a14-5aae-8574-3a49b9a77d46', '46949aed-2a1f-5979-94f1-c4ef9531f3d4', 5, E'v. An exclusive British domination in Ontario established ever since', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('6b459cde-0f56-585c-a48f-9599d9093da3', '46949aed-2a1f-5979-94f1-c4ef9531f3d4', 6, E'vi. Ethnic and language make-up', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('2a2c9fd0-b0ee-5fd9-93a4-0273f5aec0d5', '46949aed-2a1f-5979-94f1-c4ef9531f3d4', 7, E'vii. Pursuing a pure life', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('cd84f3af-7638-5824-8c49-a19544cf0da2', '46949aed-2a1f-5979-94f1-c4ef9531f3d4', 8, E'viii. Police recruited from mid-class families', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('62ce07dc-4ce5-5fbd-a823-1c7bb22aa3ce', '46949aed-2a1f-5979-94f1-c4ef9531f3d4', 9, E'ix. Demand of western immigration', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('0ef9e461-3411-5f8b-a91f-0cfe7d7e14ab', '46949aed-2a1f-5979-94f1-c4ef9531f3d4', 10, E'x. Early major urban development of the West', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('1543d901-7733-53b9-805c-a1bc85e51d4c', '46949aed-2a1f-5979-94f1-c4ef9531f3d4', 11, E'xi. Attracting urban environment', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('44af9b7e-f5e0-5daf-bb44-8b0ba3e08718', '46949aed-2a1f-5979-94f1-c4ef9531f3d4', 12, E'xii. Advertising of Western Canada', false);

  -- Question 7 (MATCHING_HEADING)
  INSERT INTO exam_questions ("Id", "SectionId", "GroupId", "Idx", "Type", "Skill", "Difficulty", "PromptMd", "ExplanationMd", "BlankAcceptTexts", "MatchPairs", "ShortAnswerAcceptTexts")
  VALUES ('e087aa08-e54f-5288-a66d-dbbccd0f186f', '68561a58-394e-5f05-87bb-ded5ac370691', 'd41b879b-7058-5621-a56a-aaaa4888fcd8', 7, 'MATCHING_HEADING', 'READING', 2, E'Paragraph 7', E'Bước 1: Đọc và hiểu đoạn 7: 

Đến năm 1891, miền Đông Canada có các đô thị lớn nhưng đi kèm với điều kiện sống tồi tệ ở các khu ổ chuột. Các nhà cải cách xã hội tin rằng lối sống nông thôn — không khí trong lành, lao động chăm chỉ, không gian rộng lớn — sẽ dẫn đến cuộc sống lành mạnh, đạo đức và nhân ái. Họ coi đây là cách "Canada hóa" người nhập cư. Hoạt động nông nghiệp được xem là phù hợp để đạt được lối sống "thuần khiết" và hướng đến gia đình.

 

Bước 2: Tóm tắt nội dung chính của đoạn 7: 
Đoạn 7 có nội dung chính là "Các nhà cải cách xã hội ca ngợi lối sống nông thôn thuần khiết và đạo đức như một lý tưởng lành mạnh, đối lập với sự ô nhiễm của đời sống đô thị".

 

Bước 3: So sánh và đối chiếu: 

Thông tin được in đậm phù hợp với tiêu đề vii "Pursuing a pure life" (Theo đuổi cuộc sống thuần khiết).

 

Bước 4: Loại trừ các tiêu đề dễ gây nhầm lẫn:

xii "Advertising of Western Canada": Đoạn 7 không hề nhắc đến các hình thức quảng cáo trực tiếp như tờ rơi, đại lý hay thư từ. Những hình thức đó nằm ở đoạn 8 — đoạn không được hỏi trong bài. Đoạn 7 chỉ nói về lý tưởng sống, không phải chiến dịch quảng bá → Tiêu đề không phù hợp.

 

Bước 5: Đáp án: vii', NULL, '{"7": ["vii", "vii. Pursuing a pure life"]}'::jsonb, NULL);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('166dcc52-2a63-5659-ad1a-4a3c1a77a326', 'e087aa08-e54f-5288-a66d-dbbccd0f186f', 1, E'i. Not all would stay in Canada forever', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('fe08c72a-cf2b-5c57-bd99-d9afd57c6cbf', 'e087aa08-e54f-5288-a66d-dbbccd0f186f', 2, E'ii. Government''s safeguard in the West', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('c983fb89-0a49-5784-9945-d82874312d21', 'e087aa08-e54f-5288-a66d-dbbccd0f186f', 3, E'iii. Eastern Canada is full', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('8730b51d-2ad9-5710-9b65-9e9d23be7237', 'e087aa08-e54f-5288-a66d-dbbccd0f186f', 4, E'iv. Built-up to the new infrastructure', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('e175ae5e-e069-5a5e-9abd-3e8fdcfd6518', 'e087aa08-e54f-5288-a66d-dbbccd0f186f', 5, E'v. An exclusive British domination in Ontario established ever since', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('4f4fc028-9632-5731-93da-73f9b0ee944d', 'e087aa08-e54f-5288-a66d-dbbccd0f186f', 6, E'vi. Ethnic and language make-up', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('777633bc-a4e0-5cd0-ad38-7a7b6b65921f', 'e087aa08-e54f-5288-a66d-dbbccd0f186f', 7, E'vii. Pursuing a pure life', true);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('8855f0b6-4578-519f-b982-5aac73f2c0e7', 'e087aa08-e54f-5288-a66d-dbbccd0f186f', 8, E'viii. Police recruited from mid-class families', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('00d08e94-eeca-5a47-8fb2-6f5c178705dc', 'e087aa08-e54f-5288-a66d-dbbccd0f186f', 9, E'ix. Demand of western immigration', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('ff4bd4ca-4373-57ea-9a3a-f3761a984e87', 'e087aa08-e54f-5288-a66d-dbbccd0f186f', 10, E'x. Early major urban development of the West', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('3ecb5f7d-dead-5a01-8032-b14955e9874a', 'e087aa08-e54f-5288-a66d-dbbccd0f186f', 11, E'xi. Attracting urban environment', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('dcc6c953-3a30-5408-a216-986cef327928', 'e087aa08-e54f-5288-a66d-dbbccd0f186f', 12, E'xii. Advertising of Western Canada', false);

  -- Insert Question Group 2
  INSERT INTO exam_question_groups ("Id", "SectionId", "Idx", "StartIdx", "EndIdx", "InstructionMd")
  VALUES ('abf3c1c2-7047-59ff-b9d4-5aea41c628e0', '68561a58-394e-5f05-87bb-ded5ac370691', 2, 8, 13, E'### Questions 8–13

Complete the following summary of the paragraphs of Reading Passage. 
Using NO MORE THAN TWO WORDS from the Reading Passage for each answer.');

  -- Question 8 (SUMMARY_COMPLETION)
  INSERT INTO exam_questions ("Id", "SectionId", "GroupId", "Idx", "Type", "Skill", "Difficulty", "PromptMd", "ExplanationMd", "BlankAcceptTexts", "MatchPairs", "ShortAnswerAcceptTexts")
  VALUES ('316e9319-b44e-5025-a9bf-3131a9d1aab1', '68561a58-394e-5f05-87bb-ded5ac370691', 'abf3c1c2-7047-59ff-b9d4-5aea41c628e0', 8, 'SUMMARY_COMPLETION', 'READING', 2, E'The western rural settlement was desired, as it would provide [8] for the sons and daughters of eastern farmers.', E'Bước 1: Hiểu câu hỏi và Giải thích ngữ pháp: 

Việc định cư nông thôn miền Tây được mong muốn vì nó sẽ cung cấp ______ cho con trai và con gái của những nông dân miền Đông.

 

Bước 2: Xác định loại từ dựa trên các dấu hiệu: 
• Loại từ: NOUN
• Dấu hiệu: provide + NOUN → cần danh từ chỉ thứ được cung cấp cho con em nông dân miền Đông

 

Bước 3: Tìm các keywords được paraphrase trong bài: 

• homesteads ~ provide ______
• sons and daughters of eastern farmers ~ từ khóa giữ nguyên

 

Bước 4: So sánh và đối chiếu: 

Bài đọc chỉ rõ: "Việc định cư nông thôn miền Tây được mong muốn vì nó sẽ cung cấp trang trại nhà ở cho con trai và con gái của những nông dân miền Đông, khi đất nông nghiệp miền Đông đã lấp đầy" (it would provide homesteads for the sons and daughters of eastern farmers, as eastern agricultural land filled to capacity).

 

Bước 5: Đáp án: homesteads
Cung cấp trang trại nhà ở cho con trai và con gái của những nông dân miền Đông (provide homesteads for the sons and daughters of eastern farmers).', '{"8": ["homesteads"]}'::jsonb, NULL, NULL);

  -- Question 9 (SUMMARY_COMPLETION)
  INSERT INTO exam_questions ("Id", "SectionId", "GroupId", "Idx", "Type", "Skill", "Difficulty", "PromptMd", "ExplanationMd", "BlankAcceptTexts", "MatchPairs", "ShortAnswerAcceptTexts")
  VALUES ('e7a88776-7187-520d-90da-a8be3819919f', '68561a58-394e-5f05-87bb-ded5ac370691', 'abf3c1c2-7047-59ff-b9d4-5aea41c628e0', 9, 'SUMMARY_COMPLETION', 'READING', 2, E'Eastern farmers and politicians viewed western Canada as a prime location for expanding Canada''s [9]', E'Bước 1: Hiểu câu hỏi và Giải thích ngữ pháp: 

Các nông dân và chính trị gia miền Đông xem miền Tây Canada là địa điểm lý tưởng để mở rộng ______ của Canada.

 

Bước 2: Xác định loại từ dựa trên các dấu hiệu: 
• Loại từ: NOUN (tối đa 2 từ)
• Dấu hiệu: expanding Canada''s + NOUN → cần danh từ chỉ thứ được mở rộng, đứng sau sở hữu cách "Canada''s"

 

Bước 3: Tìm các keywords được paraphrase trong bài: 

• agricultural output ~ expanding Canada''s ______
• prime location ~ viewed western Canada as a prime location

 

Bước 4: So sánh và đối chiếu: 

Bài đọc chỉ rõ: "Các nông dân và chính trị gia miền Đông xem miền Tây Canada là địa điểm lý tưởng để mở rộng sản lượng nông nghiệp của Canada, đặc biệt về sản xuất lúa mì" (eastern farmers and politicians viewed western Canada as a prime location for expanding Canada''s agricultural output, especially in terms of wheat production).

 

Bước 5: Đáp án: agricultural output
Mở rộng sản lượng nông nghiệp của Canada (expanding Canada''s agricultural output).', '{"9": ["agricultural output"]}'::jsonb, NULL, NULL);

  -- Question 10 (SUMMARY_COMPLETION)
  INSERT INTO exam_questions ("Id", "SectionId", "GroupId", "Idx", "Type", "Skill", "Difficulty", "PromptMd", "ExplanationMd", "BlankAcceptTexts", "MatchPairs", "ShortAnswerAcceptTexts")
  VALUES ('a360497b-048c-5123-92bd-06d34bea34cf', '68561a58-394e-5f05-87bb-ded5ac370691', 'abf3c1c2-7047-59ff-b9d4-5aea41c628e0', 10, 'SUMMARY_COMPLETION', 'READING', 2, E'especially in terms of [10] production.', E'Bước 1: Hiểu câu hỏi và Giải thích ngữ pháp: 

Đặc biệt về sản xuất ______.

 

Bước 2: Xác định loại từ dựa trên các dấu hiệu: 
• Loại từ: NOUN
• Dấu hiệu: ______ production → cần danh từ chỉ loại nông sản đứng trước "production"

 

Bước 3: Tìm các keywords được paraphrase trong bài: 

• wheat ~ ______ production
• especially in terms of ~ từ khóa giữ nguyên
• serve the markets of eastern Canada ~ phục vụ thị trường miền Đông

 

Bước 4: So sánh và đối chiếu: 

Bài đọc chỉ rõ: "Đặc biệt về sản xuất lúa mì để phục vụ thị trường miền Đông Canada" (especially in terms of wheat production to serve the markets of eastern Canada).

 

Bước 5: Đáp án: wheat
Đặc biệt về sản xuất lúa mì (especially in terms of wheat production).', '{"10": ["wheat"]}'::jsonb, NULL, NULL);

  -- Question 11 (SUMMARY_COMPLETION)
  INSERT INTO exam_questions ("Id", "SectionId", "GroupId", "Idx", "Type", "Skill", "Difficulty", "PromptMd", "ExplanationMd", "BlankAcceptTexts", "MatchPairs", "ShortAnswerAcceptTexts")
  VALUES ('e606f001-75ee-551e-b4f6-bdfe06b28c19', '68561a58-394e-5f05-87bb-ded5ac370691', 'abf3c1c2-7047-59ff-b9d4-5aea41c628e0', 11, 'SUMMARY_COMPLETION', 'READING', 2, E'The Dominion of Canada purchased Rupert''s Land from the Hudson''s Bay [11] in 1870.', E'Bước 1: Hiểu câu hỏi và Giải thích ngữ pháp: 

Dominion of Canada mua vùng đất Rupert''s Land từ Hudson''s Bay ______ vào năm 1870.

 

Bước 2: Xác định loại từ dựa trên các dấu hiệu: 
• Loại từ: NOUN (tên tổ chức)
• Dấu hiệu: Hudson''s Bay + NOUN → cần danh từ hoàn thành tên tổ chức đứng sau "Hudson''s Bay"

 

Bước 3: Tìm các keywords được paraphrase trong bài: 

• Company ~ Hudson''s Bay ______
• purchased Rupert''s Land ~ từ khóa giữ nguyên
• in 1870 ~ từ khóa giữ nguyên

 

Bước 4: So sánh và đối chiếu: 

Bài đọc chỉ rõ: "Dominion of Canada mua vùng đất Rupert''s Land từ Công ty Hudson''s Bay vào năm 1870" (The Dominion of Canada purchased Rupert''s Land from the Hudson''s Bay Company in 1870).

 

Bước 5: Đáp án: company
Mua từ Công ty Hudson''s Bay (Hudson''s Bay Company in 1870).', '{"11": ["Company"]}'::jsonb, NULL, NULL);

  -- Question 12 (SUMMARY_COMPLETION)
  INSERT INTO exam_questions ("Id", "SectionId", "GroupId", "Idx", "Type", "Skill", "Difficulty", "PromptMd", "ExplanationMd", "BlankAcceptTexts", "MatchPairs", "ShortAnswerAcceptTexts")
  VALUES ('83cdaae9-c188-5dad-81dd-283e2b85a7a7', '68561a58-394e-5f05-87bb-ded5ac370691', 'abf3c1c2-7047-59ff-b9d4-5aea41c628e0', 12, 'SUMMARY_COMPLETION', 'READING', 2, E'The Canadian government also created a Mounted [12] in 1873.', E'Bước 1: Hiểu câu hỏi và Giải thích ngữ pháp: 

Chính phủ Canada thành lập một Mounted ______ vào năm 1873.

 

Bước 2: Xác định loại từ dựa trên các dấu hiệu: 
• Loại từ: NOUN (tối đa 2 từ)
• Dấu hiệu: Mounted + NOUN → cần danh từ hoàn thành tên lực lượng đứng sau "Mounted"; giới hạn NO MORE THAN TWO WORDS

 

Bước 3: Tìm các keywords được paraphrase trong bài: 

• Police Force ~ Mounted ______
• created ~ từ khóa giữ nguyên
• in 1873 ~ từ khóa giữ nguyên

 

Bước 4: So sánh và đối chiếu: 

Bài đọc chỉ rõ: "Chính phủ Canada thành lập Lực lượng Cảnh sát Mounted vào năm 1873 để bảo đảm an ninh khu vực cho những người định cư trong tương lai" (The Canadian government also created a Mounted Police Force in 1873. The Mounties journeyed west to secure the area for future settlers).

 

Bước 5: Đáp án: Police Force
Thành lập Lực lượng Cảnh sát Mounted (a Mounted Police Force in 1873).', '{"12": ["Police Force"]}'::jsonb, NULL, NULL);

  -- Question 13 (SUMMARY_COMPLETION)
  INSERT INTO exam_questions ("Id", "SectionId", "GroupId", "Idx", "Type", "Skill", "Difficulty", "PromptMd", "ExplanationMd", "BlankAcceptTexts", "MatchPairs", "ShortAnswerAcceptTexts")
  VALUES ('e5a484e7-8807-5adc-917f-ae115c238355', '68561a58-394e-5f05-87bb-ded5ac370691', 'abf3c1c2-7047-59ff-b9d4-5aea41c628e0', 13, 'SUMMARY_COMPLETION', 'READING', 2, E'Settling the West also made imperative the building of a [13].', E'Bước 1: Hiểu câu hỏi và Giải thích ngữ pháp: 

Chính phủ Canada thành lập một Mounted ______ vào năm 1873.

 

Bước 2: Xác định loại từ dựa trên các dấu hiệu: 
• Loại từ: NOUN (tối đa 2 từ)
• Dấu hiệu: Mounted + NOUN → cần danh từ hoàn thành tên lực lượng đứng sau "Mounted"; giới hạn NO MORE THAN TWO WORDS

 

Bước 3: Tìm các keywords được paraphrase trong bài: 

• Police Force ~ Mounted ______
• created ~ từ khóa giữ nguyên
• in 1873 ~ từ khóa giữ nguyên

 

Bước 4: So sánh và đối chiếu: 

Bài đọc chỉ rõ: "Chính phủ Canada thành lập Lực lượng Cảnh sát Mounted vào năm 1873 để bảo đảm an ninh khu vực cho những người định cư trong tương lai" (The Canadian government also created a Mounted Police Force in 1873. The Mounties journeyed west to secure the area for future settlers).

 

Bước 5: Đáp án: Police Force
Thành lập Lực lượng Cảnh sát Mounted (a Mounted Police Force in 1873).', '{"13": ["transcontinental railway"]}'::jsonb, NULL, NULL);

  RAISE NOTICE 'Successfully seeded exam % with % questions.', 'youpass-reading-practice-western-immigration-of-canada', 13;
END$$;

-- ============================================================
-- Exam: IELTS Reading: The Legend of Tea
-- Slug: youpass-reading-practice-the-legend-of-tea
-- Source: 8033_actual-test-the-legend-of-tea.json
-- ============================================================
DO $$
BEGIN
  -- Check if exam already exists (strictly append-only)
  IF EXISTS (SELECT 1 FROM exams WHERE "Slug" = 'youpass-reading-practice-the-legend-of-tea') THEN
    RAISE NOTICE 'Exam with slug % already exists, skipping.', 'youpass-reading-practice-the-legend-of-tea';
    RETURN;
  END IF;

  -- Insert Exam
  INSERT INTO exams ("Id", "Slug", "Title", "DescriptionMd", "Category", "Level", "Status", "DurationMin", "CreatedAt", "UpdatedAt")
  VALUES ('5890a237-5d25-52ea-9525-41cbd939e7b0', 'youpass-reading-practice-the-legend-of-tea', E'IELTS Reading: The Legend of Tea', E'IELTS Academic Reading Practice: IELTS Reading: The Legend of Tea', 'IELTS', 'B2', 'PUBLISHED', 60, now(), now());

  -- Insert Section 1
  INSERT INTO exam_sections ("Id", "ExamId", "Idx", "Title", "PassageMd", "InstructionsMd")
  VALUES ('764ebb67-5b3c-539f-aba3-f695a3807036', '5890a237-5d25-52ea-9525-41cbd939e7b0', 1, E'The Legend of Tea', E'A. The story of tea began in ancient China over 5,000 years ago. According to the legend, Shen Nung, an early emperor was a skilled ruler, creative scientist and patron of the arts. His far-sighted edicts required, among other things, that all drinking water be boiled as a hygienic precaution. One summer day while visiting a distant region of his realm, he and the court stopped to rest. In accordance with his ruling, the servants began to boil water for the court to drink. Dried leaves from the near by bush fell into the boiling water, and a brown liquid was infused into the water. As a scientist, the Emperor was interested in the new liquid, drank some, and found it very refreshing. And so, according to legend, tea was created.

B. Tea consumption spread throughout the Chinese culture reaching into every aspect of the society. In 800 A.D. Lu Yu wrote the first definitive book on tea, the Ch’a Ching. His work clearly showed the Zen Buddhist philosophy to which he was exposed as a child. It was this form of tea service that Zen Buddhist missionaries would later introduce to imperial Japan.

C. The first tea seeds were brought to Japan by the returning Buddhist priest Yeisei, who had seen the value of tea in China in enhancing religious mediation. As a result, he is known as the “Father of Tea” in Japan. Because of this early association, tea in Japan has always been associated with Zen Buddhism. Tea received almost instant imperial sponsorship and spread rapidly from the royal court and monasteries to the other sections of Japanese society.

D. Tea was elevated to an art form resulting in the creation of the Japanese Tea Ceremony. The best description of this complex art form was probably written by the Irish-Greek journalist- historian Lafcadio Hearn, one of the few foreigners ever to be granted Japanese citizenship during this era. He wrote from personal observation, “The Tea ceremony requires years of training and practice to graduate in art...yet the whole of this art, as to its detail, signifies no more than the making and serving of a cup of tea. The supremely important matter is that the act be performed in the most perfect, most polite, most graceful, most charming manner possible”.

E. Such a purity of form, of expression prompted the creation of supportive arts and services. A special form of architecture developed for “tea houses”, based on the duplication of the simplicity of a forest cottage. The cultural/artistic hostesses of Japan, the Geishi, began to specialize in the presentation of the tea ceremony. As more and more people became involved in the excitement surrounding tea, the purity of the original Zen concept was lost. The tea ceremony became corrupted, boisterous and highly embellished. “Tea Tournament” were held among the wealthy where nobles competed among each other for rich prizes in naming various tea blends. Rewarding winners with gifts of silk, armor, and jewelry was totally alien to the original Zen attitude of the ceremony.

F. The first European to personally encounter tea and write about it was the Portuguese Jesuit Father Jasper de Cruz in 1560. Portugal, with her technologically advanced navy, had been successful in gaining the first right of trade with China. The Portuguese developed a trade route by which they shipped their tea to Lisbon, and then Dutch ships transported it to France, Holland, and the Baltic countries. Because of the success of the Dutch navy in the Pacific, tea became very fashionable in the Dutch capital. This was due in part to the high cost of the tea (over $100 per pound) which immediately made it the domain of the wealthy. Slowly, as the amount of tea imported increased, the price fell as the volume of sale expanded.

G. As the consumption of tea increased dramatically in Dutch society, doctors and university authorities argued back and forth as to the negative and/or positive benefits of tea. Known as “tea heretics”, the public largely ignored the scholarly debate and continued to enjoy their new beverage though the controversy lasted from 1635 to roughly 1657. Throughout this period France and Holland led Europe in the use of tea.

H. As the craze for things oriental swept Europe, tea became part of the way of life. The social critic Marie de Rabutin made the first mention in 1680 of adding milk to tea. During the same period, Dutch inns provided the first restaurant service of tea. Tavern owners would furnish guests with a portable tea set complete with a heating unit. The independent Dutchman would then prepare tea for himself and his friends outside in the tavern’s garden. Tea remained popular in France for only about fifty years, being replaced by a stronger preference for wine, chocolate, and exotic coffees.

I. By 1650 the Dutch were actively involved in trade throughout the Western world. Peter Stuyvesant brought the first tea to America to the colonists in the Dutch settlement of New Amsterdam (later re-named New York by the English). Settlers here were confirmed tea drinkers. And indeed, on acquiring the colony, the English found that the small settlement consumed more tea at that time then all England put together.

J. Great Britain was the last of the three great sea-faring nations to break into the Chinese and East Indian trade routes. The first samples of tea reached England between 1652 and 1654. Tea quickly proved popular enough to replace ale as the national drink of England. Tea mania swept across England as it had earlier spread throughout France and Holland. Tea importation rose from 40,000 pounds in 1699 to an annual average of 240,000 pounds by 1708. Tea was drunk by all levels of society.', E'Read the passage and answer the questions.');

  -- Insert Question Group 1
  INSERT INTO exam_question_groups ("Id", "SectionId", "Idx", "StartIdx", "EndIdx", "InstructionMd")
  VALUES ('51681dbd-3fe8-5543-8c48-c85f13247c61', '764ebb67-5b3c-539f-aba3-f695a3807036', 1, 1, 5, E'### Questions 1–5

Reading Passage 3 contains 10 paragraphs, A-J.

Which paragraphs state the following information?');

  -- Question 1 (MATCHING_INFORMATION)
  INSERT INTO exam_questions ("Id", "SectionId", "GroupId", "Idx", "Type", "Skill", "Difficulty", "PromptMd", "ExplanationMd", "BlankAcceptTexts", "MatchPairs", "ShortAnswerAcceptTexts")
  VALUES ('6b16e63e-f980-5e0e-afcc-81baa589c45c', '764ebb67-5b3c-539f-aba3-f695a3807036', '51681dbd-3fe8-5543-8c48-c85f13247c61', 1, 'MATCHING_INFORMATION', 'READING', 2, E'Coffee took the place of tea.', E'Bước 1: Hiểu câu hỏi: 

Tìm đoạn văn nói rằng cà phê (hoặc các thức uống khác) đã thay thế (took the place of) trà.

 

Bước 2: Tìm các keywords được paraphrase trong câu hỏi:

Coffee ~ wine, chocolate, and exotic coffees

took the place of ~ replaced

tea ~ từ khóa giữ nguyên

 

Bước 3: So sánh và đối chiếu:

Đoạn H chỉ rõ: "Trà vẫn phổ biến ở Pháp chỉ trong khoảng 50 năm, bị thay thế (replaced) bởi sở thích mạnh mẽ hơn đối với rượu vang, sô cô la và các loại cà phê (coffees) kỳ lạ." (Tea remained popular in France... being replaced by a stronger preference for wine, chocolate, and exotic coffees.)

==> Thông tin này cho thấy đoạn H đã "nêu rõ việc trà bị thay thế bởi các thức uống khác, bao gồm cả cà phê".

 

Bước 4: Đáp án: H', NULL, '{"1": ["H", "H"]}'::jsonb, NULL);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('f5b9ce26-3f85-524a-9190-1cc67a821ccb', '6b16e63e-f980-5e0e-afcc-81baa589c45c', 1, E'A', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('26bdcb41-fe27-51da-af44-a96c61adf619', '6b16e63e-f980-5e0e-afcc-81baa589c45c', 2, E'B', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('327dc421-f2b1-5baa-89e3-823213794993', '6b16e63e-f980-5e0e-afcc-81baa589c45c', 3, E'C', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('c968e7a3-bf74-50b6-b2e6-f1bfcfe0da5d', '6b16e63e-f980-5e0e-afcc-81baa589c45c', 4, E'D', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('302e6e25-6b48-5f53-b874-138ccc5754bf', '6b16e63e-f980-5e0e-afcc-81baa589c45c', 5, E'E', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('21929279-f149-55fb-94cf-7566f8bef33c', '6b16e63e-f980-5e0e-afcc-81baa589c45c', 6, E'F', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('d34b08b1-cd86-5677-9d78-cc040ac45fbb', '6b16e63e-f980-5e0e-afcc-81baa589c45c', 7, E'G', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('06a573e5-b39e-58ed-abfe-259413c92027', '6b16e63e-f980-5e0e-afcc-81baa589c45c', 8, E'H', true);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('3858e8a0-876c-59d3-bcb3-a75a57b28d44', '6b16e63e-f980-5e0e-afcc-81baa589c45c', 9, E'I', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('01ebd58a-388b-55d6-9f48-75eb20b4d900', '6b16e63e-f980-5e0e-afcc-81baa589c45c', 10, E'J', false);

  -- Question 2 (MATCHING_INFORMATION)
  INSERT INTO exam_questions ("Id", "SectionId", "GroupId", "Idx", "Type", "Skill", "Difficulty", "PromptMd", "ExplanationMd", "BlankAcceptTexts", "MatchPairs", "ShortAnswerAcceptTexts")
  VALUES ('890955ca-6cc2-5911-8d23-efc942e6e3db', '764ebb67-5b3c-539f-aba3-f695a3807036', '51681dbd-3fe8-5543-8c48-c85f13247c61', 2, 'MATCHING_INFORMATION', 'READING', 2, E'Religious implications were abandoned.', E'Bước 1: Hiểu câu hỏi:

Tìm đoạn văn nói rằng các ý nghĩa/hàm ý (implications) tôn giáo đã bị từ bỏ (abandoned).

 

Bước 2: Tìm các keywords được paraphrase trong câu hỏi:

Religious implications ~ purity of the original Zen concept (sự thuần khiết của khái niệm Zen ban đầu)

abandoned ~ lost (mất đi), corrupted (biến chất), alien to (xa lạ với)

 

Bước 3: So sánh và đối chiếu:

Đoạn E chỉ rõ: "Khi ngày càng có nhiều người tham gia... sự thuần khiết của khái niệm Zen ban đầu đã bị mất đi (lost). Trà đạo trở nên sai lệch (corrupted)... Việc thưởng... hoàn toàn xa lạ (alien) với thái độ Zen ban đầu của buổi lễ." (As more and more people became involved... the purity of the original Zen concept was lost. The tea ceremony became corrupted... Rewarding winners... was totally alien to the original Zen attitude...)

==> Thông tin này cho thấy đoạn E đã "mô tả việc ý nghĩa tôn giáo (Zen) ban đầu của trà đã bị mất đi/từ bỏ".

 

Bước 4: Đáp án: E', NULL, '{"2": ["E", "E"]}'::jsonb, NULL);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('1f5c9e94-70d0-59dc-9a53-87f58cd47e1e', '890955ca-6cc2-5911-8d23-efc942e6e3db', 1, E'A', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('4f072878-f536-5186-8401-48be5544d43b', '890955ca-6cc2-5911-8d23-efc942e6e3db', 2, E'B', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('6e9c7df9-10c0-5f49-bbaa-c455e4914074', '890955ca-6cc2-5911-8d23-efc942e6e3db', 3, E'C', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('948309d2-9229-575d-93ed-7770f0862f4d', '890955ca-6cc2-5911-8d23-efc942e6e3db', 4, E'D', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('2295e1f4-ea35-555f-af32-3db4e05e26df', '890955ca-6cc2-5911-8d23-efc942e6e3db', 5, E'E', true);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('a4abf4e5-31cb-5694-a6bc-8326d98bba79', '890955ca-6cc2-5911-8d23-efc942e6e3db', 6, E'F', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('cb1b6152-c078-5e8e-88e8-52e0d6c0e765', '890955ca-6cc2-5911-8d23-efc942e6e3db', 7, E'G', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('53349b60-0a0b-5561-9b54-17ef1e08abb8', '890955ca-6cc2-5911-8d23-efc942e6e3db', 8, E'H', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('c03547f8-3f84-5cea-9d57-7d3e545a7a89', '890955ca-6cc2-5911-8d23-efc942e6e3db', 9, E'I', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('8d2e8ffb-8d77-5177-b33f-7a9def87ac35', '890955ca-6cc2-5911-8d23-efc942e6e3db', 10, E'J', false);

  -- Question 3 (MATCHING_INFORMATION)
  INSERT INTO exam_questions ("Id", "SectionId", "GroupId", "Idx", "Type", "Skill", "Difficulty", "PromptMd", "ExplanationMd", "BlankAcceptTexts", "MatchPairs", "ShortAnswerAcceptTexts")
  VALUES ('025e52ed-e645-5167-b8b2-0fc27c010c16', '764ebb67-5b3c-539f-aba3-f695a3807036', '51681dbd-3fe8-5543-8c48-c85f13247c61', 3, 'MATCHING_INFORMATION', 'READING', 2, E'Tea aroused controversies in Europe.', E'Bước 1: Hiểu câu hỏi:

Tìm đoạn văn nói trà gây ra tranh cãi (controversies) ở châu Âu (Europe).

 

Bước 2: Tìm các keywords được paraphrase trong câu hỏi:

controversies ~ argued back and forth, scholarly debate, controversy

Europe ~ Dutch society, France and Holland

 

Bước 3: So sánh và đối chiếu:

Đoạn G chỉ rõ: "...các bác sĩ và nhà chức trách đại học ở xã hội Hà Lan (Dutch) đã tranh luận qua lại (argued back and forth)... công chúng phần lớn phớt lờ cuộc tranh luận học thuật (scholarly debate)... mặc dù cuộc tranh cãi (controversy) kéo dài..." (...doctors and university authorities (in Dutch society) argued back and forth... the public largely ignored the scholarly debate... though the controversy lasted...)

==> Thông tin này cho thấy đoạn G đã "mô tả về một cuộc tranh cãi (controversy) học thuật về trà ở châu Âu (Hà Lan)".

 

Bước 4: Đáp án: G', NULL, '{"3": ["G", "G"]}'::jsonb, NULL);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('096aed8b-1033-501e-970d-dc71090fc8c5', '025e52ed-e645-5167-b8b2-0fc27c010c16', 1, E'A', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('727829f5-20f3-5be2-bf92-0bfd836c57cc', '025e52ed-e645-5167-b8b2-0fc27c010c16', 2, E'B', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('cad7f711-e784-5a7c-aa49-ce617da944a1', '025e52ed-e645-5167-b8b2-0fc27c010c16', 3, E'C', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('5666ed50-d7f6-5b59-b8c1-20436ceb6513', '025e52ed-e645-5167-b8b2-0fc27c010c16', 4, E'D', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('7c6baaa7-e16c-58b1-b61b-f6b5b7ec6922', '025e52ed-e645-5167-b8b2-0fc27c010c16', 5, E'E', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('12523a33-3287-5af4-9cb1-47249d26aa66', '025e52ed-e645-5167-b8b2-0fc27c010c16', 6, E'F', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('be7d2a21-d5b0-581a-82be-a31bbe9e9be5', '025e52ed-e645-5167-b8b2-0fc27c010c16', 7, E'G', true);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('5aed1c17-99bf-59f6-86d4-552d728f4e6a', '025e52ed-e645-5167-b8b2-0fc27c010c16', 8, E'H', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('5c5eac03-2af8-5439-a4f7-2ac83f431ac7', '025e52ed-e645-5167-b8b2-0fc27c010c16', 9, E'I', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('0dd1343b-051c-51ba-baa1-9dde36249503', '025e52ed-e645-5167-b8b2-0fc27c010c16', 10, E'J', false);

  -- Question 4 (MATCHING_INFORMATION)
  INSERT INTO exam_questions ("Id", "SectionId", "GroupId", "Idx", "Type", "Skill", "Difficulty", "PromptMd", "ExplanationMd", "BlankAcceptTexts", "MatchPairs", "ShortAnswerAcceptTexts")
  VALUES ('2181e7ac-242a-5eae-9ad1-38b312c6476d', '764ebb67-5b3c-539f-aba3-f695a3807036', '51681dbd-3fe8-5543-8c48-c85f13247c61', 4, 'MATCHING_INFORMATION', 'READING', 2, E'Tea was once the symbol of the wealth in the Netherlands.', E'Bước 1: Hiểu câu hỏi:

Tìm đoạn văn nói trà là biểu tượng của sự giàu có (symbol of the wealth) ở Hà Lan (Netherlands).

 

Bước 2: Tìm các keywords được paraphrase trong câu hỏi:

symbol of the wealth ~ high cost, domain of the wealthy (phạm vi của người giàu)

the Netherlands ~ Dutch capital (thủ đô Hà Lan)

 

Bước 3: So sánh và đối chiếu:

Đoạn F chỉ rõ: "...trà trở nên rất thời thượng ở thủ đô Hà Lan (Dutch capital). Điều này một phần là do chi phí cao của trà (high cost)... điều này ngay lập tức khiến nó trở thành phạm vi (sở hữu) của người giàu (domain of the wealthy)." (...tea became very fashionable in the Dutch capital. This was due in part to the high cost of the tea... which immediately made it the domain of the wealthy.)

==> Thông tin này cho thấy đoạn F đã "giải thích tại sao trà là biểu tượng cho sự giàu có (chi phí cao, dành cho người giàu) ở Hà Lan".

 

Bước 4: Đáp án: F', NULL, '{"4": ["F", "F"]}'::jsonb, NULL);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('95539b85-df56-5a3d-9a26-2679d7f1c392', '2181e7ac-242a-5eae-9ad1-38b312c6476d', 1, E'A', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('4decce7f-3c51-555e-9e9e-1c7f2216b8d4', '2181e7ac-242a-5eae-9ad1-38b312c6476d', 2, E'B', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('2a54a515-1499-5396-99e1-8a1cf6f08de9', '2181e7ac-242a-5eae-9ad1-38b312c6476d', 3, E'C', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('10da0d05-b1fd-5537-86e9-eea45dd0b7e6', '2181e7ac-242a-5eae-9ad1-38b312c6476d', 4, E'D', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('e043b7de-3d61-5f9c-b82a-efa7fa556005', '2181e7ac-242a-5eae-9ad1-38b312c6476d', 5, E'E', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('454b3ef2-7bba-5e8c-b2c8-675081bce6e6', '2181e7ac-242a-5eae-9ad1-38b312c6476d', 6, E'F', true);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('3c534f2f-769a-5279-8431-7fc8007fdbcf', '2181e7ac-242a-5eae-9ad1-38b312c6476d', 7, E'G', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('71bcb29d-e4c1-506d-8aab-be86f7514e96', '2181e7ac-242a-5eae-9ad1-38b312c6476d', 8, E'H', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('0bff1c80-2f3d-5453-9e22-0199fd39462e', '2181e7ac-242a-5eae-9ad1-38b312c6476d', 9, E'I', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('a4d0af46-819f-563d-9151-3b967564cb5b', '2181e7ac-242a-5eae-9ad1-38b312c6476d', 10, E'J', false);

  -- Question 5 (MATCHING_INFORMATION)
  INSERT INTO exam_questions ("Id", "SectionId", "GroupId", "Idx", "Type", "Skill", "Difficulty", "PromptMd", "ExplanationMd", "BlankAcceptTexts", "MatchPairs", "ShortAnswerAcceptTexts")
  VALUES ('cf48e017-f125-5b75-85db-8b0cfa92cf51', '764ebb67-5b3c-539f-aba3-f695a3807036', '51681dbd-3fe8-5543-8c48-c85f13247c61', 5, 'MATCHING_INFORMATION', 'READING', 2, E'A kind of ceremonical art was born related to tea.', E'Bước 1: Hiểu câu hỏi:

Tìm đoạn văn nói một nghệ thuật nghi lễ (ceremonial art) đã ra đời (was born) liên quan đến trà.

 

Bước 2: Tìm các keywords được paraphrase trong câu hỏi:

ceremonial art ~ art form, Japanese Tea Ceremony (Trà đạo Nhật Bản)

was born related to tea ~ Tea was elevated to... (Trà được nâng lên thành...), creation of... (sự tạo ra của...)

 

Bước 3: So sánh và đối chiếu:

Đoạn D chỉ rõ: "Trà đã được nâng lên thành một hình thức nghệ thuật (art form) dẫn đến việc tạo ra Trà đạo Nhật Bản (Japanese Tea Ceremony)." (Tea was elevated to an art form resulting in the creation of the Japanese Tea Ceremony.)

==> Thông tin này cho thấy đoạn D đã "mô tả sự ra đời của một nghệ thuật nghi lễ (Trà đạo) từ trà".

 

Bước 4: Đáp án: D', NULL, '{"5": ["D", "D"]}'::jsonb, NULL);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('cb0040d6-f892-50bc-a944-40f9949ad428', 'cf48e017-f125-5b75-85db-8b0cfa92cf51', 1, E'A', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('28017e14-54fb-54c3-a841-b11e87db3c79', 'cf48e017-f125-5b75-85db-8b0cfa92cf51', 2, E'B', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('94ec55dd-1d39-5284-9109-90bf40c57a06', 'cf48e017-f125-5b75-85db-8b0cfa92cf51', 3, E'C', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('8b9c8500-99ee-5a0b-9cab-e54a6c582983', 'cf48e017-f125-5b75-85db-8b0cfa92cf51', 4, E'D', true);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('87dae016-e359-50ed-805b-b4fe727af905', 'cf48e017-f125-5b75-85db-8b0cfa92cf51', 5, E'E', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('fe0c0047-0a69-52c0-b7c4-2b27da7a8214', 'cf48e017-f125-5b75-85db-8b0cfa92cf51', 6, E'F', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('8532453d-e027-5a13-8d6f-dc4966272064', 'cf48e017-f125-5b75-85db-8b0cfa92cf51', 7, E'G', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('d2fda33b-6bc8-558b-9be8-d4fc23eb37ea', 'cf48e017-f125-5b75-85db-8b0cfa92cf51', 8, E'H', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('6260b756-1811-5e7c-8b64-86f14b5d9d8d', 'cf48e017-f125-5b75-85db-8b0cfa92cf51', 9, E'I', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('1a177c78-138b-5469-a55f-7ad74e33f313', 'cf48e017-f125-5b75-85db-8b0cfa92cf51', 10, E'J', false);

  -- Insert Question Group 2
  INSERT INTO exam_question_groups ("Id", "SectionId", "Idx", "StartIdx", "EndIdx", "InstructionMd")
  VALUES ('496db412-0d54-52b1-b619-11016b83c1d9', '764ebb67-5b3c-539f-aba3-f695a3807036', 2, 6, 9, E'### Questions 6–9

Do the following statements agree with the claims of the writer in Reading Passage ?

On your answer sheet please choose

TRUE                      if the statement is true

FALSE                    if the statement is false

NOT GIVEN           if the information is not given in the passage.');

  -- Question 6 (TRUE_FALSE_NOT_GIVEN)
  INSERT INTO exam_questions ("Id", "SectionId", "GroupId", "Idx", "Type", "Skill", "Difficulty", "PromptMd", "ExplanationMd", "BlankAcceptTexts", "MatchPairs", "ShortAnswerAcceptTexts")
  VALUES ('9a1d1b32-133d-5eba-a3f5-42aa8b09d6e5', '764ebb67-5b3c-539f-aba3-f695a3807036', '496db412-0d54-52b1-b619-11016b83c1d9', 6, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, E'The introduction of tea to imperial Japan originates from missionary purposes.', E'Bước 1: Hiểu câu hỏi:

Việc giới thiệu trà đến Nhật Bản hoàng gia (imperial Japan) bắt nguồn từ các mục đích truyền giáo (missionary purposes).

 

Bước 2: Tìm các keywords được paraphrase trong bài:

introduction of tea to imperial Japan ~ introduce to imperial Japan

missionary purposes ~ Zen Buddhist missionaries (nhà truyền giáo Thiền tông)

 

Bước 3: So sánh và đối chiếu:

Bài đọc chỉ rõ (ở Đoạn B): "Chính hình thức phục vụ trà này mà các nhà truyền giáo Thiền tông (Zen Buddhist missionaries) sau này sẽ giới thiệu đến Nhật Bản hoàng gia (introduce to imperial Japan)." (It was this form of tea service that Zen Buddhist missionaries would later introduce to imperial Japan.)

==> Điều này đồng nghĩa với thông tin trong câu hỏi "Việc giới thiệu trà đến Nhật Bản hoàng gia bắt nguồn từ mục đích truyền giáo (missionary)".

 

Bước 4: Đáp án: TRUE', NULL, NULL, NULL);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('2526374d-fc03-5308-970e-f870ef17eb77', '9a1d1b32-133d-5eba-a3f5-42aa8b09d6e5', 1, E'TRUE', true);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('a1f7e480-6619-5e0f-9f72-b4b9b94e8f8b', '9a1d1b32-133d-5eba-a3f5-42aa8b09d6e5', 2, E'FALSE', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('e53ddf2d-33b9-51f1-b84e-07a931e3230f', '9a1d1b32-133d-5eba-a3f5-42aa8b09d6e5', 3, E'NOT GIVEN', false);

  -- Question 7 (TRUE_FALSE_NOT_GIVEN)
  INSERT INTO exam_questions ("Id", "SectionId", "GroupId", "Idx", "Type", "Skill", "Difficulty", "PromptMd", "ExplanationMd", "BlankAcceptTexts", "MatchPairs", "ShortAnswerAcceptTexts")
  VALUES ('5412e15b-63e9-5536-9913-d158b6acb5f5', '764ebb67-5b3c-539f-aba3-f695a3807036', '496db412-0d54-52b1-b619-11016b83c1d9', 7, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, E'Tea had spread to all sections of Japanese society over a very long time.', E'Bước 1: Hiểu câu hỏi:

Trà đã lan rộng đến mọi tầng lớp (all sections) trong xã hội Nhật Bản trong một thời gian rất dài (over a very long time).

 

Bước 2: Tìm các keywords được paraphrase trong bài:

spread ~ spread rapidly

all sections of Japanese society ~ other sections of Japanese society

over a very long time ~ (Đây là thông tin cần kiểm chứng)

 

Bước 3: So sánh và đối chiếu:

Bài đọc chỉ rõ (ở Đoạn C): "Trà gần như ngay lập tức nhận được sự bảo trợ của hoàng gia và lan truyền nhanh chóng (spread rapidly) từ cung đình và tu viện đến các bộ phận khác của xã hội Nhật Bản." (Tea received almost instant imperial sponsorship and spread rapidly... to the other sections of Japanese society.)

==> Điều này trái ngược với thông tin trong câu hỏi là "trong một thời gian rất dài (a very long time)". Bài đọc nói rõ là "nhanh chóng (rapidly)".

 

Bước 4: Đáp án: FALSE', NULL, NULL, NULL);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('ed08efaa-efbe-5ff9-b8e2-67b90ecb705a', '5412e15b-63e9-5536-9913-d158b6acb5f5', 1, E'TRUE', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('c73d9df5-9100-5684-bf11-664a15cc2963', '5412e15b-63e9-5536-9913-d158b6acb5f5', 2, E'FALSE', true);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('f867c261-64e2-597f-b6aa-727c88d11a07', '5412e15b-63e9-5536-9913-d158b6acb5f5', 3, E'NOT GIVEN', false);

  -- Question 8 (TRUE_FALSE_NOT_GIVEN)
  INSERT INTO exam_questions ("Id", "SectionId", "GroupId", "Idx", "Type", "Skill", "Difficulty", "PromptMd", "ExplanationMd", "BlankAcceptTexts", "MatchPairs", "ShortAnswerAcceptTexts")
  VALUES ('20a4496f-fa97-5b4a-b384-f90bd0d6177e', '764ebb67-5b3c-539f-aba3-f695a3807036', '496db412-0d54-52b1-b619-11016b83c1d9', 8, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, E'Drinking tea has significant health benefits.', E'Bước 1: Hiểu câu hỏi:

Uống trà có lợi ích sức khỏe đáng kể (significant health benefits).

 

Bước 2: Tìm các keywords được paraphrase trong bài:

health benefits ~ positive benefits (lợi ích tích cực)

 

Bước 3: So sánh và đối chiếu:

Bài đọc đề cập đến việc (ở Đoạn G): "...các bác sĩ... đã tranh luận qua lại về những lợi ích tiêu cực và/hoặc tích cực (negative and/or positive benefits) của trà." (...doctors... argued back and forth as to the negative and/or positive benefits of tea.)

==> Tuy nhiên, bài đọc chỉ nhắc đến việc có một cuộc tranh luận về lợi ích (benefits), chứ không hề khẳng định rằng trà "có lợi ích sức khỏe đáng kể". Bài đọc không đưa ra kết luận cho cuộc tranh luận đó.

 

Bước 4: Đáp án: NOT GIVEN', NULL, NULL, NULL);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('33c9c226-56d6-5f25-b4e5-c285f5041e13', '20a4496f-fa97-5b4a-b384-f90bd0d6177e', 1, E'TRUE', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('a88b04e3-be6f-5006-8985-3db913b47349', '20a4496f-fa97-5b4a-b384-f90bd0d6177e', 2, E'FALSE', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('32517c33-6393-5c7e-9feb-289e9f63d8c8', '20a4496f-fa97-5b4a-b384-f90bd0d6177e', 3, E'NOT GIVEN', true);

  -- Question 9 (TRUE_FALSE_NOT_GIVEN)
  INSERT INTO exam_questions ("Id", "SectionId", "GroupId", "Idx", "Type", "Skill", "Difficulty", "PromptMd", "ExplanationMd", "BlankAcceptTexts", "MatchPairs", "ShortAnswerAcceptTexts")
  VALUES ('d0a688bc-ee5f-58d1-b5a0-7dcf26739426', '764ebb67-5b3c-539f-aba3-f695a3807036', '496db412-0d54-52b1-b619-11016b83c1d9', 9, 'TRUE_FALSE_NOT_GIVEN', 'READING', 2, E'Dutchmen preferred to add milk to their tea.', E'Bước 1: Hiểu câu hỏi:

Người Hà Lan (Dutchmen) thích (preferred) thêm sữa vào trà của họ.

 

Bước 2: Tìm các keywords được paraphrase trong bài:

Dutchmen ~ Dutch

add milk to tea ~ adding milk to tea

 

Bước 3: So sánh và đối chiếu:

Bài đọc đề cập đến việc (ở Đoạn H): "Nhà phê bình xã hội Marie de Rabutin (một người Pháp) đã đề cập lần đầu tiên... về việc thêm sữa vào trà." ([The social critic Marie de Rabutin made the first mention... of adding milk to tea.) (Đoạn H cũng nói về các quán trọ Hà Lan (Dutch inns) nhưng là về việc họ phục vụ trà, không phải về việc họ thêm sữa vào trà).

==> Tuy nhiên, bài đọc không hề nhắc đến thông tin "người Hà Lan (Dutchmen) thích (preferred)" làm việc này.

 

Bước 4: Đáp án: NOT GIVEN', NULL, NULL, NULL);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('78c155db-21d3-59ca-9d08-081f22ad36ca', 'd0a688bc-ee5f-58d1-b5a0-7dcf26739426', 1, E'TRUE', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('9840291e-1f52-5649-9a48-d7847fc7ff65', 'd0a688bc-ee5f-58d1-b5a0-7dcf26739426', 2, E'FALSE', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('103af101-04ad-5454-b4b7-e39325d29f68', 'd0a688bc-ee5f-58d1-b5a0-7dcf26739426', 3, E'NOT GIVEN', true);

  -- Insert Question Group 3
  INSERT INTO exam_question_groups ("Id", "SectionId", "Idx", "StartIdx", "EndIdx", "InstructionMd")
  VALUES ('85882c4f-b9ef-52b9-a618-ca7729048ed3', '764ebb67-5b3c-539f-aba3-f695a3807036', 3, 10, 14, E'### Questions 10–14

Use the information in the passage to match the people (listed 10-14) with opinions or deeds (listed A-J) below.

NB Some discovery may match more than one person.

**List of Options:**
- A. discovered the value of tea as a refreshing drink.
- B. published a book about tea and Buddhism.
- C. introduced tea to Japanese society.
- D. depicted the art of tea ceremony.
- E. elevated tea drinking to an art.
- F. realized the value of tea in strengthening religious intervention.
- G. wrote about tea and his country started the first tea trade with China.
- H. developed a trade route by shipping tea to Lisbon.
- I. first brought tea to America.
- J. brought the first tea to Americans in the Netherlands.');

  -- Question 10 (MATCHING_FEATURES)
  INSERT INTO exam_questions ("Id", "SectionId", "GroupId", "Idx", "Type", "Skill", "Difficulty", "PromptMd", "ExplanationMd", "BlankAcceptTexts", "MatchPairs", "ShortAnswerAcceptTexts")
  VALUES ('5ae00aa6-975a-5324-b3f1-ffa2469e2829', '764ebb67-5b3c-539f-aba3-f695a3807036', '85882c4f-b9ef-52b9-a618-ca7729048ed3', 10, 'MATCHING_FEATURES', 'READING', 2, E'Jasper de Cruz', E'Bước 1: Hiểu câu hỏi:

Đề hỏi Jasper de Cruz đã làm gì hoặc có ý kiến gì?

 

Bước 2: Tìm các keywords được paraphrase trong bài:

• Jasper de Cruz ~ từ khóa giữ nguyên• wrote about tea ~ write about it• his country ~ Portugal• started the first tea trade with China ~ gaining the first right of trade with China

 

Bước 3: So sánh và đối chiếu:Đoạn F chỉ rõ: "Người châu Âu đầu tiên trực tiếp tiếp xúc với trà và viết về nó là Tu sĩ Dòng Tên người Bồ Đào Nha, Cha Jasper de Cruz vào năm 1560. Bồ Đào Nha, với hải quân công nghệ tiên tiến, đã thành công trong việc giành được quyền giao thương đầu tiên với Trung Quốc" (The first European to personally encounter tea and write about it was the Portuguese Jesuit Father Jasper de Cruz in 1560. Portugal, with her technologically advanced navy, had been successful in gaining the first right of trade with China.).

==> Thông tin này khớp với Lựa chọn G: wrote about tea and his country started the first tea trade with China. (đã viết về trà và đất nước của ông ấy bắt đầu giao dịch trà đầu tiên với Trung Quốc).

 

Bước 4: Đáp án: G', NULL, '{"10": ["G", "G. wrote about tea and his country started the first tea trade with China."]}'::jsonb, NULL);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('52623ee6-5db6-515a-8dd7-59d5d0a1ae4e', '5ae00aa6-975a-5324-b3f1-ffa2469e2829', 1, E'A. discovered the value of tea as a refreshing drink.', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('c03bafcd-6db7-5d89-949b-759aebd88a1d', '5ae00aa6-975a-5324-b3f1-ffa2469e2829', 2, E'B. published a book about tea and Buddhism.', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('ca1fd88f-9d1f-5f36-b6c4-c06a1eb65826', '5ae00aa6-975a-5324-b3f1-ffa2469e2829', 3, E'C. introduced tea to Japanese society.', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('b3427fce-fc79-5df8-a924-9c0644743b1c', '5ae00aa6-975a-5324-b3f1-ffa2469e2829', 4, E'D. depicted the art of tea ceremony.', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('b6c1bf56-874e-506d-af10-4932c01840fb', '5ae00aa6-975a-5324-b3f1-ffa2469e2829', 5, E'E. elevated tea drinking to an art.', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('3080dce3-ccba-5379-ba15-3c328f79b19d', '5ae00aa6-975a-5324-b3f1-ffa2469e2829', 6, E'F. realized the value of tea in strengthening religious intervention.', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('3573b47b-552a-5028-91d2-1ccdb5d7ca78', '5ae00aa6-975a-5324-b3f1-ffa2469e2829', 7, E'G. wrote about tea and his country started the first tea trade with China.', true);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('ea74e5bd-57d7-5844-ab92-2377c02d1100', '5ae00aa6-975a-5324-b3f1-ffa2469e2829', 8, E'H. developed a trade route by shipping tea to Lisbon.', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('378bd398-d401-521c-89da-9092989a7989', '5ae00aa6-975a-5324-b3f1-ffa2469e2829', 9, E'I. first brought tea to America.', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('84056cfd-9ec6-5a6c-990c-45cc5df3cace', '5ae00aa6-975a-5324-b3f1-ffa2469e2829', 10, E'J. brought the first tea to Americans in the Netherlands.', false);

  -- Question 11 (MATCHING_FEATURES)
  INSERT INTO exam_questions ("Id", "SectionId", "GroupId", "Idx", "Type", "Skill", "Difficulty", "PromptMd", "ExplanationMd", "BlankAcceptTexts", "MatchPairs", "ShortAnswerAcceptTexts")
  VALUES ('d1829707-b4df-504b-8b0a-3e7c3a035a56', '764ebb67-5b3c-539f-aba3-f695a3807036', '85882c4f-b9ef-52b9-a618-ca7729048ed3', 11, 'MATCHING_FEATURES', 'READING', 2, E'Peter Stuyvesant', E'Bước 1: Hiểu câu hỏi:

Đề hỏi Peter Stuyvesant đã làm gì hoặc có ý kiến gì?

 

Bước 2: Tìm các keywords được paraphrase trong bài:

• Peter Stuyvesant ~ từ khóa giữ nguyên• first brought tea to America ~ brought the first tea to America

 

Bước 3: So sánh và đối chiếu:

Đoạn I chỉ rõ: "Peter Stuyvesant đã mang những ấm trà đầu tiên đến Mỹ cho những người dân thuộc địa tại khu định cư của Hà Lan ở New Amsterdam" (By 1650 the Dutch were actively involved in trade throughout the Western world. Peter Stuyvesant brought the first tea to America to the colonists in the Dutch settlement of New Amsterdam...).

==> Thông tin này khớp với Lựa chọn I: first brought tea to America. (lần đầu tiên mang trà đến Mỹ).

 

Bước 4: Đáp án: I', NULL, '{"11": ["I", "I. first brought tea to America."]}'::jsonb, NULL);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('0231b1b6-f812-518b-8620-4df78eafe6bc', 'd1829707-b4df-504b-8b0a-3e7c3a035a56', 1, E'A. discovered the value of tea as a refreshing drink.', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('44618e6e-bd5e-53d7-932a-dd6661873a38', 'd1829707-b4df-504b-8b0a-3e7c3a035a56', 2, E'B. published a book about tea and Buddhism.', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('a422e8e8-f597-53ed-a39c-91256c9c8118', 'd1829707-b4df-504b-8b0a-3e7c3a035a56', 3, E'C. introduced tea to Japanese society.', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('b6459d56-9c67-5be2-9120-9cc65388e3dd', 'd1829707-b4df-504b-8b0a-3e7c3a035a56', 4, E'D. depicted the art of tea ceremony.', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('a6d5509e-315e-5ade-bcf9-95c1845337b8', 'd1829707-b4df-504b-8b0a-3e7c3a035a56', 5, E'E. elevated tea drinking to an art.', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('7ea59fc0-6703-5f8f-854b-6f784d0c2749', 'd1829707-b4df-504b-8b0a-3e7c3a035a56', 6, E'F. realized the value of tea in strengthening religious intervention.', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('ca8b309b-dfe5-5ae1-bf43-751fbe6ab9b5', 'd1829707-b4df-504b-8b0a-3e7c3a035a56', 7, E'G. wrote about tea and his country started the first tea trade with China.', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('e4e7fced-68fe-5acb-9696-a74e2412d8d0', 'd1829707-b4df-504b-8b0a-3e7c3a035a56', 8, E'H. developed a trade route by shipping tea to Lisbon.', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('000777e0-72c1-5641-9ca3-06abbc5d23fc', 'd1829707-b4df-504b-8b0a-3e7c3a035a56', 9, E'I. first brought tea to America.', true);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('c8ed4b7b-bd57-54d2-b538-fe938f6d4bd5', 'd1829707-b4df-504b-8b0a-3e7c3a035a56', 10, E'J. brought the first tea to Americans in the Netherlands.', false);

  -- Question 12 (MATCHING_FEATURES)
  INSERT INTO exam_questions ("Id", "SectionId", "GroupId", "Idx", "Type", "Skill", "Difficulty", "PromptMd", "ExplanationMd", "BlankAcceptTexts", "MatchPairs", "ShortAnswerAcceptTexts")
  VALUES ('1786bfec-246e-547f-bf7b-c1b4cec3a77e', '764ebb67-5b3c-539f-aba3-f695a3807036', '85882c4f-b9ef-52b9-a618-ca7729048ed3', 12, 'MATCHING_FEATURES', 'READING', 2, E'Lu Yu', E'Bước 1: Hiểu câu hỏi:

Đề hỏi Lu Yu đã làm gì hoặc có ý kiến gì?

 

Bước 2: Tìm các keywords được paraphrase trong bài:

• Lu Yu ~ từ khóa giữ nguyên• published a book about tea ~ wrote the first definitive book on tea• Buddhism ~ Zen Buddhist philosophy

 

Bước 3: So sánh và đối chiếu:

Đoạn B chỉ rõ: "Vào năm 800 sau Công nguyên, Lục Vũ (Lu Yu) đã viết cuốn sách chính thức đầu tiên về trà, cuốn Trà Kinh (Ch’a Ching). Tác phẩm của ông thể hiện rõ triết lý Thiền tông (Zen Buddhist philosophy) mà ông đã tiếp xúc từ khi còn nhỏ" (In 800 A.D. Lu Yu wrote the first definitive book on tea, the Ch’a Ching. His work clearly showed the Zen Buddhist philosophy to which he was exposed as a child.).

==> Thông tin này khớp với Lựa chọn B: published a book about tea and Buddhism. (xuất bản một cuốn sách về trà và Phật giáo).

 

Bước 4: Đáp án: B', NULL, '{"12": ["B", "B. published a book about tea and Buddhism."]}'::jsonb, NULL);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('ff3d6b6d-055f-5b44-b8f2-cf997923023d', '1786bfec-246e-547f-bf7b-c1b4cec3a77e', 1, E'A. discovered the value of tea as a refreshing drink.', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('b243ec9c-2487-5f6a-b242-b7dfead64b76', '1786bfec-246e-547f-bf7b-c1b4cec3a77e', 2, E'B. published a book about tea and Buddhism.', true);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('33118c90-3f6a-5894-9f3c-37dfd21415af', '1786bfec-246e-547f-bf7b-c1b4cec3a77e', 3, E'C. introduced tea to Japanese society.', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('2aaba132-8089-5a4e-a3dd-4fecff493897', '1786bfec-246e-547f-bf7b-c1b4cec3a77e', 4, E'D. depicted the art of tea ceremony.', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('79a00fd7-061e-59b0-9099-317826b471bc', '1786bfec-246e-547f-bf7b-c1b4cec3a77e', 5, E'E. elevated tea drinking to an art.', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('52dc11e3-451f-5283-a69c-46352fa3eab5', '1786bfec-246e-547f-bf7b-c1b4cec3a77e', 6, E'F. realized the value of tea in strengthening religious intervention.', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('94325932-d193-5234-a35e-bd5499f8698a', '1786bfec-246e-547f-bf7b-c1b4cec3a77e', 7, E'G. wrote about tea and his country started the first tea trade with China.', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('f4ae43b0-ac93-5ecf-9313-7d61f1fe4b14', '1786bfec-246e-547f-bf7b-c1b4cec3a77e', 8, E'H. developed a trade route by shipping tea to Lisbon.', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('6dc87b29-9cdc-5264-9932-fca87ca30e3c', '1786bfec-246e-547f-bf7b-c1b4cec3a77e', 9, E'I. first brought tea to America.', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('306c3a68-ae89-520d-86dc-86b221765288', '1786bfec-246e-547f-bf7b-c1b4cec3a77e', 10, E'J. brought the first tea to Americans in the Netherlands.', false);

  -- Question 13 (MATCHING_FEATURES)
  INSERT INTO exam_questions ("Id", "SectionId", "GroupId", "Idx", "Type", "Skill", "Difficulty", "PromptMd", "ExplanationMd", "BlankAcceptTexts", "MatchPairs", "ShortAnswerAcceptTexts")
  VALUES ('ed4f9326-3aec-5971-aef6-a8c49aca558c', '764ebb67-5b3c-539f-aba3-f695a3807036', '85882c4f-b9ef-52b9-a618-ca7729048ed3', 13, 'MATCHING_FEATURES', 'READING', 2, E'Lafcadio Hearn', E'Bước 1: Hiểu câu hỏi:

Đề hỏi Lafcadio Hearn đã làm gì hoặc có ý kiến gì?

 

Bước 2: Tìm các keywords được paraphrase trong bài:

• Lafcadio Hearn ~ từ khóa giữ nguyên• depicted ~ description ... written by• the art of tea ceremony ~ this complex art form (the Japanese Tea Ceremony)

 

Bước 3: So sánh và đối chiếu:

Đoạn D chỉ rõ: "Sự mô tả hay nhất về loại hình nghệ thuật phức tạp này [Trà đạo Nhật Bản] có lẽ được viết bởi nhà báo-sử gia người Ireland gốc Hy Lạp Lafcadio Hearn" (The best description of this complex art form was probably written by the Irish-Greek journalist-historian Lafcadio Hearn...).

==> Thông tin này khớp với Lựa chọn D: depicted the art of tea ceremony. (đã mô tả nghệ thuật của trà đạo). Depicted (mô tả) ~ description (bản mô tả).

 

Bước 4: Đáp án: D', NULL, '{"13": ["D", "D. depicted the art of tea ceremony."]}'::jsonb, NULL);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('caa59a8d-63ca-5fff-b1d5-1045a805b741', 'ed4f9326-3aec-5971-aef6-a8c49aca558c', 1, E'A. discovered the value of tea as a refreshing drink.', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('e3a25380-f9b6-59f3-8a6d-c9f4db92be86', 'ed4f9326-3aec-5971-aef6-a8c49aca558c', 2, E'B. published a book about tea and Buddhism.', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('78b7f9fd-ea6c-557e-a263-4197353c4e74', 'ed4f9326-3aec-5971-aef6-a8c49aca558c', 3, E'C. introduced tea to Japanese society.', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('7f63324c-155b-592a-ae99-060ab727b964', 'ed4f9326-3aec-5971-aef6-a8c49aca558c', 4, E'D. depicted the art of tea ceremony.', true);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('a341066d-b05c-5790-91f4-33c8cbe263b5', 'ed4f9326-3aec-5971-aef6-a8c49aca558c', 5, E'E. elevated tea drinking to an art.', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('b247296c-1452-5020-afa5-c3d447191fc9', 'ed4f9326-3aec-5971-aef6-a8c49aca558c', 6, E'F. realized the value of tea in strengthening religious intervention.', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('c31c144a-3b85-5d5a-8f34-20a6742ce143', 'ed4f9326-3aec-5971-aef6-a8c49aca558c', 7, E'G. wrote about tea and his country started the first tea trade with China.', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('59722e62-11c8-5442-bf79-944714755f30', 'ed4f9326-3aec-5971-aef6-a8c49aca558c', 8, E'H. developed a trade route by shipping tea to Lisbon.', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('3413b388-e7b0-5f85-81ff-09b7834cbbf8', 'ed4f9326-3aec-5971-aef6-a8c49aca558c', 9, E'I. first brought tea to America.', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('7b92ec79-583e-569b-a6da-c555d3b1185e', 'ed4f9326-3aec-5971-aef6-a8c49aca558c', 10, E'J. brought the first tea to Americans in the Netherlands.', false);

  -- Question 14 (MATCHING_FEATURES)
  INSERT INTO exam_questions ("Id", "SectionId", "GroupId", "Idx", "Type", "Skill", "Difficulty", "PromptMd", "ExplanationMd", "BlankAcceptTexts", "MatchPairs", "ShortAnswerAcceptTexts")
  VALUES ('4e4d1070-95a2-5f5f-b256-5f2a4f18e220', '764ebb67-5b3c-539f-aba3-f695a3807036', '85882c4f-b9ef-52b9-a618-ca7729048ed3', 14, 'MATCHING_FEATURES', 'READING', 2, E'Shen Nung', E'Bước 1: Hiểu câu hỏi:

Đề hỏi Shen Nung đã làm gì hoặc có ý kiến gì?

 

Bước 2: Tìm các keywords được paraphrase trong bài:

(Tìm tên Shen Nung trong bài đọc -> Đoạn A)

 

Bước 3: So sánh và đối chiếu:

Bài đọc chỉ rõ đoạn trích liên quan đến Shen Nung (ở Đoạn A): "Theo truyền thuyết, Thần Nông (Shen Nung)... Là một nhà khoa học, Hoàng đế quan tâm đến chất lỏng mới, uống thử, và thấy nó rất sảng khoái (refreshing)." (According to the legend, Shen Nung... As a scientist, the Emperor was interested in the new liquid, drank some, and found it very refreshing.)

==> Thông tin này khớp với Lựa chọn A: discovered the value of tea as a refreshing drink. (đã khám phá ra giá trị của trà như một thức uống sảng khoái).

 

Bước 4: Đáp án: A', NULL, '{"14": ["A", "A. discovered the value of tea as a refreshing drink."]}'::jsonb, NULL);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('faa58e12-5806-515b-9c6b-518c82d961fa', '4e4d1070-95a2-5f5f-b256-5f2a4f18e220', 1, E'A. discovered the value of tea as a refreshing drink.', true);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('cf2a3d40-8d96-5e83-b1dc-9e37e2578b1d', '4e4d1070-95a2-5f5f-b256-5f2a4f18e220', 2, E'B. published a book about tea and Buddhism.', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('4ff04d37-4774-59b4-9816-f6388577d64e', '4e4d1070-95a2-5f5f-b256-5f2a4f18e220', 3, E'C. introduced tea to Japanese society.', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('2e587aed-a312-5194-b28a-a8f0b72c680c', '4e4d1070-95a2-5f5f-b256-5f2a4f18e220', 4, E'D. depicted the art of tea ceremony.', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('279a65a0-3018-5662-b207-e47394654051', '4e4d1070-95a2-5f5f-b256-5f2a4f18e220', 5, E'E. elevated tea drinking to an art.', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('5b9b8d36-1175-519b-ab0a-53a7e608b912', '4e4d1070-95a2-5f5f-b256-5f2a4f18e220', 6, E'F. realized the value of tea in strengthening religious intervention.', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('d0e649a1-1584-54da-bec2-886a9ab8d489', '4e4d1070-95a2-5f5f-b256-5f2a4f18e220', 7, E'G. wrote about tea and his country started the first tea trade with China.', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('b2f288c9-87b4-57cd-be0a-6f7630fbc938', '4e4d1070-95a2-5f5f-b256-5f2a4f18e220', 8, E'H. developed a trade route by shipping tea to Lisbon.', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('48f4c487-1deb-565c-869f-7ffc9646e086', '4e4d1070-95a2-5f5f-b256-5f2a4f18e220', 9, E'I. first brought tea to America.', false);
  INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
  VALUES ('5beb1592-dc9a-55e7-be8c-3208b902b967', '4e4d1070-95a2-5f5f-b256-5f2a4f18e220', 10, E'J. brought the first tea to Americans in the Netherlands.', false);

  RAISE NOTICE 'Successfully seeded exam % with % questions.', 'youpass-reading-practice-the-legend-of-tea', 14;
END$$;

COMMIT;
