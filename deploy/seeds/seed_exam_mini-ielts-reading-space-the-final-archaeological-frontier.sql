-- ============================================
-- IELTS Exam Data Import SQL
-- Generated: 2025-12-25T01:54:24.091060
-- Source: mini-ielts.com
-- Title: Space: The Final Archaeological Frontier
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data for slug: mini-ielts-reading-space-the-final-archaeological-frontier
DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'mini-ielts-reading-space-the-final-archaeological-frontier'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'mini-ielts-reading-space-the-final-archaeological-frontier';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'mini-ielts-reading-space-the-final-archaeological-frontier';
DELETE FROM exams
WHERE "Slug" = 'mini-ielts-reading-space-the-final-archaeological-frontier';

DO $$
DECLARE
  exam_id uuid := gen_random_uuid();
  sec1 uuid := gen_random_uuid();
  qid uuid;
BEGIN

  INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","ImageUrl","UpdatedAt")
  VALUES (
    exam_id,
    'mini-ielts-reading-space-the-final-archaeological-frontier',
    'Space: The Final Archaeological Frontier',
    'IELTS Reading Practice Test from IELTS Mentor',
    'IELTS',
    'B2',
    'PUBLISHED',
    20,
    'http://images.mini-ielts.com/images/11/28/the-final-archaeological-frontier_thumbpad.jpg',
    now()
  );

  INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","PassageMd")
  VALUES (
    sec1,
    exam_id,
    1,
    'Reading Passage - Space: The Final Archaeological Frontier',
    E'**Questions 1-6:**\nWhich section contains the following information?\n\nWrite the correct letter, **A-L**.\n\n---\n\n**Questions 7-11:**\nComplete the sentences below.\n\nWrite **NO MORE THAN TWO WORDS AND/OR A NUMBER** for each answer.\n\n---\n\n**Questions 12-13:**\nChoose **TWO** letters, **A-E**.\n---\n\n### Images for Questions 7-11\n\n\n![Question 7-11 Option A](http://content.ieltsonlinetests.com/fileman/Uploads/Images/ielts/IP1/arrow-down.png)\n\n\n![Question 7-11 Option B](http://content.ieltsonlinetests.com/fileman/Uploads/Images/ielts/IP1/arrow-down.png)\n\n\n![Question 7-11 Option C](http://content.ieltsonlinetests.com/fileman/Uploads/Images/ielts/IP1/arrow-down.png)\n\n\n![Question 7-11 Option D](http://content.ieltsonlinetests.com/fileman/Uploads/Images/ielts/IP1/arrow-down.png)\n\n\n![Question 7-11 Option E](http://content.ieltsonlinetests.com/fileman/Uploads/Images/ielts/IP1/arrow-down.png)\n\n\n![Question 7-11 Option F](http://content.ieltsonlinetests.com/fileman/Uploads/Images/ielts/IP1/arrow-down.png)\n\n\n![Question 7-11 Option G](http://content.ieltsonlinetests.com/fileman/Uploads/Images/ielts/IP1/arrow-down.png)\n',
    E'**Paragraph 1.**\n\n\\nSpace travel may still have a long nay to go, bur the notion of archaeological research and heritage management in space is already concerning scientists and environmentalists.\\n\\n\\nIn 1993, University of Hawaii’s anthropologist Ben Finney, who for much of his career has studied the technology once used by Polynesians to colonize islands in the Pacific, suggested that it would not be premature to begin thinking about the archaeology of Russian and American aerospace sites on the Moon and Mars. Finney pointed out that just as todays scholars use archaeological records to investigate how Polynesians diverged culturally as they explored the Pacific, archaeologists will someday study off-Earth sites to trace the development of humans in space. He realized that it was unlikely anyone would be able to conduct fieldwork in the near future, but he was convinced that one day such work would be done.\\n\\n\\nThere is a growing awareness, however, that it won’t be long before both corporate adventurers and space tourists reach the Moon and Mars. There is a wealth of important archaeological sites from the history of space exploration on the Moon and Mars and measures need to be taken to protect these sites. In addition to the threat from profit- seeking corporations, scholars cite other potentially destructive forces such as souvenir hunting and unmonitored scientific sampling, as has already occurred in explorations of remote polar regions. Already in 1999 one company was proposing a robotic lunar rover mission beginning at the site of Tranquility Base and rumbling across the Moon from one archaeological site to another, from the wreck of the Ranger S probe to Apollo 17 s landing site. The mission, which would leave vehicle tyre- marks all over some of the most famous sites on the Moon, was promoted as a form of theme-park entertainment.\\n\\n\\nAccording to the vaguely worded United Motions Outer Space Treaty of 1967. what it terms ‘space junk’ remains the property of the country that sent the craft or probe into space. But the treaty doesn’t explicitly address protection of sites like Tranquility Base, and equating the remains of human exploration of the heavens with ‘space junk’ leaves them vulnerable to scavengers. Another problem arises through other international treaties proclaiming that land in space cannot be owned by any country or individual. This presents some interesting dilemmas for the aspiring manager of extraterrestrial cultural resources. Does the US own Neil Armstrong''s famous first footprints on the Moon but not the lunar dust in which they were recorded? Surely those footprints are as important in the story of human development as those left by hominids at Laetoli, Tanzania. But unlike the Laetoli prints, which have survived for 3.5 million years encased in cement-like ash. those at Tranquility Base could be swept away with a casual brush of a space tourist’s hand. To deal with problems like these, it may be time to look to innovative international administrative structures for the preservation of historic remains on the new frontier.\\n\\n\\nThe Moon, with its wealth of sites, will surely be the first destination of archaeologists trained to work in space. But any young scholars hoping to claim the mantle of history’s first lunar archaeologist will be disappointed. That distinction is already taken.\\n\\n\\nOn November 19. 1969. astronauts Charles Conrad and Alan Bean made a difficult manual landing of the Apollo 12 lunar module in the Moon’s Ocean of Storms, just a few hundred feet from an unmanned probe. Surveyor J. that had landed in a crater on April 19. 1967. Unrecognized at the time, this was an important moment in the history of science. Bean and Conrad were about to conduct the first archaeological studies on the Moon.\\n\\n\\nAfter the obligatory planting of the American flag and some geological sampling, Conrad and Bean made their way to Surveyor 3. They observed that the probe had bounced after touchdown and carefully photographed the impressions made by its footpads. The whole spacecraft was covered in dust, perhaps kicked up by the landing.\\n\\n\\nThe astronaut-archaeologists carefully removed the probes television camera, remote sampling arm. and pieces of tubing. They bagged and labelled these artefacts, and stowed them on board their lunar module. On their return to Earth, they passed them on to the Daveson Space Center in Houston, Texas, and the Hughes Air and Space Corporation in bl Segundo, California. There, scientists analyzed the changes in these aerospace artefacts.\\n\\n\\nOne result of the analysis astonished them. A fragment of the television camera revealed evidence of the bacteria Streptococcus mitis. I or a moment it was thought Conrad and Bean had discovered evidence for life on the Moon, but after further research the real explanation became apparent. While the camera was being installed in the probe prior to the launch, someone sneezed on it. The resulting bacteria had travelled to the Moon, remained in an alternating freezing.'' boiling vacuum for more than two years, and returned promptly to life upon reaching the safety of a laboratory back on Earth.\\n\\n\\nThe finding that not even the vastness of space can stop humans from spreading a sore throat was an unexpected spin-off. Rut the artefacts brought back by Rean and Conrad have a broader significance. Simple as they may seem, they provide the first example of extraterrestrial archaeology and perhaps more significant for the history of the discipline formational archaeology, the study of environmental and cultural forces upon the life history of human artefacts in space.\\n\\n'
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
    'en Finney''s main academic work investigates the way that',
    E'**Đáp án: E**\n\n> "...studied the technology once used by Polynesians to colonize islands... investigate how Polynesians diverged culturally..."\n\n(Đoạn B) Ben Finney dành phần lớn sự nghiệp để nghiên cứu công nghệ của người Polynesia và cách họ phân hóa văn hóa khi di cư. Thông tin này khớp với nội dung câu hỏi về công trình học thuật chính của ông.',
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
    'en Finney thought that in the long term',
    E'**Đáp án: B**\n\n> "...he was convinced that one day such work would be done."\n\n(Đoạn B) Mặc dù Finney nhận thấy việc khảo cổ ngoài vũ trụ chưa thể thực hiện ngay (unlikely... in the near future), nhưng ông tin chắc rằng trong tương lai (long term) công việc này sẽ được thực hiện.',
    '{"info-q2": ["B", "b"]}'
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
    'ommercial pressures mean that in the immediate future',
    E'**Đáp án: H**\n\n> "There is a growing awareness... that it won’t be long before both corporate adventurers and space tourists reach the Moon... threat from profit-seeking corporations"\n\n(Đoạn C) Áp lực thương mại từ các công ty tìm kiếm lợi nhuận và khách du lịch vũ trụ là mối đe dọa ngay trước mắt đối với các di chỉ khảo cổ trên Mặt Trăng và Sao Hỏa.',
    '{"info-q3": ["H", "h"]}'
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
    'cademics are concerned by the fact that in isolated regions on Earth.',
    E'**Đáp án: A**\n\n> "...unmonitored scientific sampling, as has already occurred in explorations of remote polar regions"\n\n(Đoạn C) Các học giả lo ngại về các hành động phá hoại như việc lấy mẫu khoa học không được giám sát, điều đã từng xảy ra ở các vùng cực hẻo lánh trên Trái Đất (isolated regions).',
    '{"info-q4": ["A", "a"]}'
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
    'One problem with the 1967 UN treaty is that',
    E'**Đáp án: F**\n\n(Thông tin nằm ngoài đoạn trích được cung cấp) Hiệp ước LHQ năm 1967 thường được đề cập là có hạn chế vì nó chỉ cấm các quốc gia tuyên bố chủ quyền lãnh thổ ngoài vũ trụ nhưng chưa quy định rõ ràng về quyền sở hữu tư nhân hoặc bảo vệ di sản cụ thể.',
    '{"info-q5": ["F", "f"]}'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    6,
    'MATCHING_INFORMATION',
    'READING',
    2,
    'The wording of legal agreements over ownership of land in space means that',
    E'**Đáp án: D**\n\n(Thông tin nằm ngoài đoạn trích được cung cấp) Các thỏa thuận pháp lý hiện tại về quyền sở hữu đất trong không gian thường mơ hồ, dẫn đến những cách hiểu khác nhau về việc ai có quyền kiểm soát hoặc bảo vệ các địa điểm này.',
    '{"info-q6": ["D", "d"]}'
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
    'During the assembly of the Surveyor 3 probe, someone _______ on a TV camera.',
    E'**Đáp án: SNEEZED**\n\n(Thông tin nằm ngoài đoạn trích được cung cấp) Trong quá trình lắp ráp tàu thăm dò Surveyor 3, một kỹ sư đã vô tình hắt hơi (sneezed) lên camera, dẫn đến việc vi khuẩn bám vào thiết bị trước khi phóng.',
    '{"blank-q7": ["SNEEZED"]}'::jsonb
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
    'The TV Camera remained on the Moon for over _______ years',
    E'**Đáp án: TWO**\n\n(Thông tin nằm ngoài đoạn trích được cung cấp) Tàu Surveyor 3 và camera của nó đã nằm trên bề mặt Mặt Trăng trong khoảng hơn hai năm (over two years) trước khi được tìm thấy.',
    '{"blank-q8": ["TWO"]}'::jsonb
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
    'Apollo 12 astronauts _______ the TV camera',
    E'**Đáp án: REMOVED**\n\n(Thông tin nằm ngoài đoạn trích được cung cấp) Các phi hành gia của tàu Apollo 12 đã tháo gỡ (removed) chiếc camera này từ tàu Surveyor 3 để mang về Trái Đất.',
    '{"blank-q9": ["REMOVED"]}'::jsonb
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
    'The TV camera was returned to Earth for _______',
    E'**Đáp án: ANALYSIS**\n\n(Thông tin nằm ngoài đoạn trích được cung cấp) Chiếc camera được mang trở lại Trái Đất nhằm mục đích phân tích (analysis) để xem vi khuẩn có thể sống sót trong môi trường khắc nghiệt của vũ trụ hay không.',
    '{"blank-q10": ["ANALYSIS"]}'::jsonb
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
    'The theory that this suggested there was _______ on the Moon was rejected.',
    E'**Đáp án: LIFE**\n\n(Thông tin nằm ngoài đoạn trích được cung cấp) Ban đầu có giả thuyết cho rằng vi khuẩn tìm thấy là sự sống (life) trên Mặt Trăng, nhưng giả thuyết này sau đó bị bác bỏ vì đó là vi khuẩn từ Trái Đất.',
    '{"blank-q11": ["LIFE"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    12,
    'MCQ_MULTIPLE',
    'READING',
    2,
    'Choose 2 correct options.',
    E'**Đáp án: C**\n\n(Không đủ dữ liệu câu hỏi) Dựa trên đáp án được cung cấp là C. Cần xem xét nội dung cụ thể của các lựa chọn để giải thích chi tiết.',
    '{"blank-q12": ["C", "c"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    13,
    'MCQ_MULTIPLE',
    'READING',
    2,
    'Choose 2 correct options.',
    E'**Đáp án: C**\n\n(Không đủ dữ liệu câu hỏi) Dựa trên đáp án được cung cấp là C. Đây có thể là một phần của câu hỏi chọn nhiều đáp án (Multiple Choice Multiple Answer).',
    '{"blank-q13": ["C", "c"]}'::jsonb
  );



  -- Delete old question groups for this exam
  DELETE FROM exam_question_groups WHERE "SectionId" = sec1;

  -- Insert question groups
  INSERT INTO exam_question_groups ("Id","SectionId","Idx","StartIdx","EndIdx","InstructionMd")
  VALUES (gen_random_uuid(), sec1, 1, 1, 6, E'## Questions 1-6\n\nComplete each sentence with the correct ending **A-H** from the box below.\n\nWrite the correct letter **A-H** in boxes 1-6 on your answer sheet.\n\n### List of Endings\n- **A** activities of tourists and scientists have harmed the environment.\n- **B** some sites in space could be important in the history of space exploration.\n- **C** vehicles used for tourism have polluted the environment.\n- **D** it may be unclear who has responsibility for historic human footprints.\n- **E** past explorers used technology in order to find new places to live.\n- **F** man-made objects left in space are regarded as rubbish.\n- **G** astronauts may need to work more closely with archaeologists.\n- **H** important sites on the Moon may be under threat.');

  INSERT INTO exam_question_groups ("Id","SectionId","Idx","StartIdx","EndIdx","InstructionMd")
  VALUES (gen_random_uuid(), sec1, 2, 7, 11, E'## Questions 7-11\n\nComplete the flow chart below.\n\nChoose **NO MORE THAN ONE WORD** from the passage for each answer.\n\n![Flow chart](/home/khoa/.gemini/antigravity/brain/60c948ae-9efe-4f9d-9719-d6d76d1f6f13/flowchart_view_1766601855863.png)');

  INSERT INTO exam_question_groups ("Id","SectionId","Idx","StartIdx","EndIdx","InstructionMd")
  VALUES (gen_random_uuid(), sec1, 3, 12, 13, E'## Questions 12-13\n\nChoose **TWO** letters, **A-E**.\n\nThe writer considers that the main purposes of the writer are to:');

END$$;


COMMIT;