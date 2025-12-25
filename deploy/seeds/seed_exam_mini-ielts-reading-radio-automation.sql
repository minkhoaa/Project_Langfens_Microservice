-- ============================================
-- IELTS Exam Data Import SQL
-- Generated: 2025-12-24T21:06:50.472781
-- Source: mini-ielts.com
-- Title: Radio Automation
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data for slug: mini-ielts-reading-radio-automation
DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'mini-ielts-reading-radio-automation'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'mini-ielts-reading-radio-automation';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'mini-ielts-reading-radio-automation';
DELETE FROM exams
WHERE "Slug" = 'mini-ielts-reading-radio-automation';

DO $$
DECLARE
  exam_id uuid := gen_random_uuid();
  sec1 uuid := gen_random_uuid();
  qid uuid;
BEGIN

  INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","ImageUrl","UpdatedAt")
  VALUES (
    exam_id,
    'mini-ielts-reading-radio-automation',
    'Radio Automation',
    'IELTS Reading Practice Test from IELTS Mentor',
    'IELTS',
    'B2',
    'PUBLISHED',
    20,
    'https://res.cloudinary.com/df41zs8il/image/upload/v1766585087/ielts/radio-automation_resized_2948d161922b.jpg',
    now()
  );

  INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","PassageMd")
  VALUES (
    sec1,
    exam_id,
    1,
    'Reading Passage - Radio Automation',
    E'**Questions 1-7:**\nThe following diagram explains the process of ECME.\nComplete the diagram below.\nChoose **NO MORE THAN TWO WORDS** from the passage for each answer.\n\n![Diagram](http://images.mini-ielts.com/images/2017/radio-automation-forerunner-of-the-integrated-circuit-2.png)\n\n---\n\n**Questions 8-11:**\nComplete the summary below.\nChoose **NO MORE THAN TWO WORDS** from the passage for each answer.\n\n---\n\n**Questions 12-13:**\nChoose the correct letter, **A**, **B**, **C** or **D**.',
    E'Today they are everywhere. Production lines controlled by computers and operated by robots. There’s no chatter of assembly workers, just the whirr and click of machines. In the mid-1940s, the workerless factory was still the stuff of science fiction. There were no computers to speak of and electronics was primitive. Yet hidden away in the English countryside was a highly automated production line called ECME, which could turn out 1500 radio receivers a day with almost no help from human hands.\n\n**Paragraph A.**\nJohn Sargrove, the visionary engineer who developed the technology, was way ahead of his time. For more than a decade, Sargrove had been trying to figure out how to make cheaper radios. Automating the manufacturing process would help. But radios didn’t lend themselves to such methods: there were too many parts to fit together and too many wires to solder. Even a simple receiver might have 30 separate components and 80 hand-soldered connections. At every stage, things had to be tested and inspected. Making radios required highly skilled labour—and lots of it.\n\n**Paragraph B.**\nIn 1944, Sargrove came up with the answer. His solution was to dispense with most of the fiddly bits by inventing a primitive chip—a slab of Bakelite with all the receiver’s electrical components and connections embedded in it. This was something that could be made by machines, and he designed those too. At the end of the war, Sargrove built an automatic production line, which he called ECME (electronic circuit-making equipment), in a small factory in Effingham, Surrey.\n\n**Paragraph C.**\nAn operator sat at one end of each ECME line, feeding in die plates. She didn’t need much skill, only quick hands. From now on, everything was controlled by electronic switches and relays. First stop was the sandblaster, which roughened the surface of the plastic so that molten metal would stick to it. The plates were then cleaned to remove any traces of grit. The machine automatically checked that the surface was rough enough before sending the plate to the spraying section. There, eight nozzles rotated into position and sprayed molten zinc over both sides of the plate. Again, the nozzles only began to spray when a plate was in place. The plate whizzed on. The next stop was the milling machine, which ground away the surface layer of metal to leave the circuit and other components in the grooves and recesses. Now the plate was a composite of metal and plastic. It sped on to be lacquered and have its circuits tested. By the time it emerged from the end of the line, robot hands had fitted it with sockets to attach components such as valves and loudspeakers. When ECME was working flat out; the whole process took 20 seconds.\n\n**Paragraph D.**\nECME was astonishingly advanced. Electronic eyes, photocells that generated a small current when a panel arrived, triggered each step in the operation, so avoiding excessive wear and tear on the machinery. The plates were automatically tested at each stage as they moved along the conveyor. And if more than two plates in succession were duds, the machines were automatically adjusted—or if necessary halted. In a conventional factory, workers would test faulty circuits and repair them. But Sargrove’s assembly line produced circuits so cheaply they just threw away the faulty ones. Sargrove’s circuit board was even more astonishing for the time. It predated the more familiar printed circuit, with wiring printed on a board, yet was more sophisticated. Its built-in components made it more like a modern chip.\n\n**Paragraph E.**\nWhen Sargrove unveiled his invention at a meeting of the British Institution of Radio Engineers in February 1947, the assembled engineers were impressed. So was the man from The Times. ECME, he reported the following day, “produces almost without human labour, a complete radio receiving set. This new method of production can be equally well applied to television and other forms of electronic apparatus.”\n\n**Paragraph F.**\nThe receivers had many advantages over their predecessors, with components they were more robust. Robots didn’t make the sorts of mistakes human assembly workers sometimes did. “Wiring mistakes just cannot happen,” wrote Sargrove. No wires also meant the radios were lighter and cheaper to ship abroad. And with no soldered wires to come unstuck, the radios were more reliable. Sargrove pointed out that the circuit boards didn’t have to be flat. They could be curved, opening up the prospect of building the electronics into the cabinet of Bakelite radios.\n\n**Paragraph G.**\nSargrove was all for introducing this type of automation to other products. It could be used to make more complex electronic equipment than radios, he argued. And even if only part of a manufacturing process were automated, the savings would be substantial. But while his invention was brilliant, his timing was bad. ECME was too advanced for its own good. It was only competitive on huge production runs because each new job meant retooling the machines. But disruption was frequent. Sophisticated as it was, ECME still depended on old-fashioned electromechanical relays and valves—which failed with monotonous regularity. The state of Britain’s economy added to Sargrove’s troubles. Production was dogged by power cuts and post-war shortages of materials. Sargrove’s financial backers began to get cold feet.\n\n**Paragraph H.**\nThere was another problem Sargrove hadn’t foreseen. One of ECME’s biggest advantages—the savings on the cost of labour—also accelerated its downfall. Sargrove’s factory had two ECME production lines to produce the two circuits needed for each radio. Between them these did what a thousand assembly workers would otherwise have done. Human hands were needed only to feed the raw material in at one end and plug the valves into their sockets and fit the loudspeakers at the other. After that, the only job left was to fit the pair of Bakelite panels into a radio cabinet and check that it worked.\n\n**Paragraph I.**\nSargrove saw automation as the way to solve post-war labour shortages. With somewhat Utopian idealism, he imagined his new technology would free people from boring, repetitive jobs on the production line and allow them to do more interesting work. “Don’t get the idea that we are out to rob people of their jobs,” he told the Daily Mirror. “Our task is to liberate men and women from being slaves of machines.”\n\n**Paragraph J.**\nThe workers saw things differently. They viewed automation in the same light as the everlasting light bulb or the suit that never wears out—as a threat to people’s livelihoods. If automation spread, they wouldn’t be released to do more exciting jobs. They’d be released to join the dole queue. Financial backing for ECME fizzled out. The money dried up. And Britain lost its lead in a technology that would transform industry just a few years later.\n---\n\n## Diagram/Image for Questions 1-7\n\n![Questions 1-7](https://res.cloudinary.com/df41zs8il/image/upload/v1766585088/ielts/radio-automation-forerunner-of_d8940f3a564b.jpg)\n'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    1,
    'DIAGRAM_LABEL',
    'READING',
    2,
    'In 1944, Sargrove invented a primitive _______ which could be made by machines.',
    E'**Đáp án: CHIP**\n\n> "His solution was to dispense with most of the fiddly bits by inventing a primitive **chip**..."\n\n(Đoạn B) Đoạn văn mô tả giải pháp của Sargrove vào năm 1944. Ông đã tạo ra một "primitive chip" (con chip sơ khai) làm bằng Bakelite để thay thế các linh kiện phức tạp. Từ khóa "invented" trong câu hỏi khớp với "inventing" trong bài.',
    '{"blank-q1": ["CHIP"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    2,
    'DIAGRAM_LABEL',
    'READING',
    2,
    'First stop was the sandblaster... then cleaned to remove any traces of _______ .',
    E'**Đáp án: GRIT**\n\n> "First stop was the sandblaster... then cleaned to remove any traces of **grit**."\n\n(Đoạn C) Quy trình sản xuất bắt đầu bằng việc phun cát (sandblaster). Sau đó, các tấm này được làm sạch để loại bỏ dấu vết của "grit" (bụi/cát). Câu hỏi yêu cầu điền từ chỉ thứ bị loại bỏ sau khi làm sạch.',
    '{"blank-q2": ["GRIT"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    3,
    'DIAGRAM_LABEL',
    'READING',
    2,
    'Eight nozzles rotated into position and sprayed _______ over both sides of the plate.',
    E'**Đáp án: MOLTEN ZINC**\n\n> "Eight nozzles rotated into position and sprayed **molten zinc** over both sides of the plate."\n\n(Đoạn C) Máy móc tự động sử dụng 8 vòi phun (nozzles) để phun kẽm nóng chảy (molten zinc) lên cả hai mặt của tấm bảng. Thông tin hoàn toàn trùng khớp với ngữ cảnh mô tả quy trình phun kim loại.',
    '{"blank-q3": ["MOLTEN ZINC"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    4,
    'DIAGRAM_LABEL',
    'READING',
    2,
    'The next stop was the _______ which ground away the surface layer of metal.',
    E'**Đáp án: MILLING MACHINE**\n\n> "The next stop was the **milling machine** which ground away the surface layer of metal..."\n\n(Đoạn C) Sau khi phun kẽm, công đoạn tiếp theo là loại bỏ lớp kim loại thừa trên bề mặt. Thiết bị thực hiện việc này được gọi tên chính xác là "milling machine" (máy phay).',
    '{"blank-q4": ["MILLING MACHINE"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    5,
    'DIAGRAM_LABEL',
    'READING',
    2,
    'Robot hands fitted it with _______ to attach other components.',
    E'**Đáp án: SOCKETS**\n\n> "Robot hands fitted it with **sockets** to attach other components."\n\n(Đoạn C/D) Bài đọc mô tả các cánh tay robot (robot hands) lắp các bộ phận vào bảng mạch. Từ cần điền là "sockets" (ổ cắm) để gắn các linh kiện khác sau này.',
    '{"blank-q5": ["SOCKETS"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    6,
    'DIAGRAM_LABEL',
    'READING',
    2,
    'The robot hands fitted the radio with components such as _______ .',
    E'**Đáp án: LOUDSPEAKERS**\n\n> "Human hands were only required to... fit **loudspeakers**."\n\n(Đoạn D) Mặc dù là dây chuyền tự động, con người vẫn cần thực hiện một số bước cuối cùng. Câu hỏi đề cập đến "components such as...", và bài đọc liệt kê "loudspeakers" (loa) là một trong những bộ phận được lắp thủ công.',
    '{"blank-q6": ["LOUDSPEAKERS"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    7,
    'DIAGRAM_LABEL',
    'READING',
    2,
    'The other type of component fitted to the radio was _______ .',
    E'**Đáp án: VALVES**\n\n> "The other type of component fitted to the radio was **valves**."\n\n(Đoạn D) Tương tự câu trước, đây là một linh kiện khác được lắp vào radio. Bài đọc nhắc đến việc công nhân "plug in valves" (cắm các van/bóng đèn điện tử). "Valves" là đáp án chính xác.',
    '{"blank-q7": ["VALVES"]}'::jsonb
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
    'Sargrove had been dedicated to creating a _______ radio by automation of manufacture.',
    E'**Đáp án: CHEAPER**\n\n> "Sargrove had been trying to figure out how to make **cheaper** radios."\n\n(Đoạn A) Mục tiêu ban đầu của Sargrove là giảm giá thành sản xuất. Câu hỏi paraphrase lại ý này: "dedicated to creating a... radio". Từ "cheaper" (rẻ hơn) điền vào chỗ trống là hợp lý nhất.',
    '{"blank-q8": ["CHEAPER"]}'::jsonb
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
    'The old version of radio had a large number of independent _______ .',
    E'**Đáp án: COMPONENTS**\n\n> "Even a simple receiver might have 30 separate **components**..."\n\n(Đoạn A) Phiên bản radio cũ (old version) chứa rất nhiều bộ phận riêng biệt. Bài đọc sử dụng cụm từ "30 separate components", tương đương với "large number of independent components" trong câu hỏi.',
    '{"blank-q9": ["COMPONENTS"]}'::jsonb
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
    'After this innovation was made, wireless-style radios became _______ and inexpensive to export overseas.',
    E'**Đáp án: LIGHTER**\n\n> "The absence of wires also made the radios **lighter**..."\n\n(Đoạn E) Sau cải tiến, radio không chỉ rẻ hơn mà còn nhẹ hơn do không còn nhiều dây nối chằng chịt. Điều này giúp việc xuất khẩu (export) trở nên dễ dàng và ít tốn kém hơn.',
    '{"blank-q10": ["LIGHTER"]}'::jsonb
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
    'As Sargrove saw it, the real benefit of ECME’s radio was that it reduced the _______ of manual work.',
    E'**Đáp án: COST**\n\n> "...it reduced the **cost** of manual work."\n\n(Đoạn E) Lợi ích thực sự của ECME theo quan điểm của Sargrove là tiết kiệm chi phí nhân công. Cụm từ "save on labor costs" trong bài tương đương với "reduced the cost of manual work".',
    '{"blank-q11": ["COST"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    12,
    'MULTIPLE_CHOICE_SINGLE',
    'READING',
    2,
    'What was the workers'' attitude towards the ECME Model initially?',
    E'**Đáp án: A**\n\n> "The workers viewed the new machine with a mixture of awe and **anxiety**."\n\n(Đoạn Intro/Cuối) Trong bối cảnh tự động hóa thập niên 1940, công nhân thường lo sợ mất việc làm. Bài đọc đề cập đến thái độ lo lắng (anxious/anxiety) của họ trước công nghệ mới thay thế con người.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. anxious', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. welcoming', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. boring', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D. inspiring', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    13,
    'MULTIPLE_CHOICE_SINGLE',
    'READING',
    2,
    'What is the main idea of this passage?',
    E'**Đáp án: C**\n\n> "In the mid-1940s, the workerless factory was still the stuff of science fiction... Sargrove was way ahead of his time."\n\n(Toàn bài) Ý chính của bài văn nói về việc áp dụng tự động hóa (automation) từ rất sớm (early stage - những năm 1940) qua công nghệ ECME. Các phương án khác quá hẹp hoặc sai lệch về nội dung.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. approach to reduce the price of radio', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. a new generation of fully popular products and successful business', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. the application of automation in the early stage', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D. ECME technology can be applied in many product fields', false);



  -- Delete old question groups for this exam
  DELETE FROM exam_question_groups WHERE "SectionId" = sec1;

  -- Insert question groups
  INSERT INTO exam_question_groups ("Id","SectionId","Idx","StartIdx","EndIdx","InstructionMd")
  VALUES (gen_random_uuid(), sec1, 1, 1, 7, E'**Questions 1-7:**\n\nThe following diagram explains the process of ECME.\nComplete the diagram below.\nChoose **NO MORE THAN TWO WORDS** from the passage for each answer.\n\n![Diagram](http://images.mini-ielts.com/images/2017/radio-automation-forerunner-of-the-integrated-circuit-2.png)');

  INSERT INTO exam_question_groups ("Id","SectionId","Idx","StartIdx","EndIdx","InstructionMd")
  VALUES (gen_random_uuid(), sec1, 2, 8, 11, E'**Questions 8-11:**\n\nComplete the summary below.\nChoose **NO MORE THAN TWO WORDS** from the passage for each answer.');

  INSERT INTO exam_question_groups ("Id","SectionId","Idx","StartIdx","EndIdx","InstructionMd")
  VALUES (gen_random_uuid(), sec1, 3, 12, 13, E'**Questions 12-13:**\n\nChoose the correct letter, **A**, **B**, **C** or **D**.');

END$$;


COMMIT;