-- ============================================
-- IELTS Exam Data Import SQL
-- Generated: 2025-12-24T22:48:14.312215
-- Source: mini-ielts.com
-- Title: Recent research on humour
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data for slug: mini-ielts-reading-recent-research-on-humour
DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'mini-ielts-reading-recent-research-on-humour'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'mini-ielts-reading-recent-research-on-humour';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'mini-ielts-reading-recent-research-on-humour';
DELETE FROM exams
WHERE "Slug" = 'mini-ielts-reading-recent-research-on-humour';

DO $$
DECLARE
  exam_id uuid := gen_random_uuid();
  sec1 uuid := gen_random_uuid();
  qid uuid;
BEGIN

  INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","ImageUrl","UpdatedAt")
  VALUES (
    exam_id,
    'mini-ielts-reading-recent-research-on-humour',
    'Recent research on humour',
    'IELTS Reading Practice Test from IELTS Mentor',
    'IELTS',
    'B2',
    'PUBLISHED',
    20,
    'https://res.cloudinary.com/df41zs8il/image/upload/v1766591279/ielts/laughterchildren_thumbpad_4343eb1efe22.jpg',
    now()
  );

  INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","PassageMd")
  VALUES (
    sec1,
    exam_id,
    1,
    'Reading Passage - Recent research on humour',
    E'**Questions 1-7:**\nDo the following statements agree with the information given in the text?\n\nWrite\n- **TRUE** if the statement agrees with the information\n- **FALSE** if the statement contradicts the information\n- **NOT GIVEN** if there is no information on this\n\n---\n\n**Questions 8-10:**\nComplete the sentences below.\n\nWrite **NO MORE THAN TWO WORDS AND/OR A NUMBER** for each answer.\n\n---\n\n**Questions 11-14:**\nWhich section contains the following information?\n\nWrite the correct letter, **A-L**.\n---\n\n### Images for Questions 8-10\n\n\n![Question 8-10 Option A](https://res.cloudinary.com/df41zs8il/image/upload/v1766591284/ielts/05_3f01ed6791e4.jpg)\n',
    E'**Paragraph A.**\\nThe joke comes over the headphones: ''Which side of a dog has the most hair? The left.''\\n\\n**Paragraph B.**\\nNo, not funny. Try again. Which side of a dog has the most hair? The outside.'' Hah! The punchline is silly yet fitting, tempting a smile, even a laugh. Laughter has always struck people as deeply mysterious, perhaps pointless. The writer Arthur Koestler dubbed it the luxury reflex: ‘unique in that it serves no apparent biological purpose''.\\n\\n**Paragraph C.**\\nTheories about humour have an ancient pedigree. Plato expressed the idea that humour is simply a delighted feeling of superiority over others. Kant and Freud felt that joke-telling relies on building up a psychic tension which is safely punctured by the ludicrousness of the punchline. But most modern humour theorists have settled on some version of Aristotle''s belief that jokes are based on a reaction to or resolution of incongruity, when the punchline is either a nonsense or, though appearing silly, has a clever second meaning.\\n\\n**Paragraph D.**\\nGraeme Ritchie, a computational linguist in Edinburgh, studies the linguistic structure of jokes in order to understand not only humour but language understanding and reasoning in machines. He says that while there is no single format for jokes, many revolve around a sudden and surprising conceptual shift. A comedian will present a situation followed by an unexpected interpretation that is also apt\\n\\n**Paragraph E.**\\nSo even if a punchline sounds silly, the listener can see there is a clever semantic fit and that sudden mental ''Aha!'' is the buzz that makes us laugh. Viewed from this angle, humour is just a form of creative insight, a sudden leap to a new perspective.\\n\\n**Paragraph F.**\\nHowever, there is another type of laughter, the laughter of social appeasement and it is important to understand this too. Play is a crucial part of development in most young mammals. Rats produce ultrasonic squeaks to prevent their scuffles turning nasty. Chimpanzees have a ''play-face'' - a gaping expression accompanied by a panting ''ah, ah'' noise. In humans, these signals have mutated into smiles and laughs. Researchers believe social situations, rather than cognitive events such as jokes, trigger these instinctual markers of play or appeasement. People laugh on fairground rides or when tickled to flag a play situation, whether they feel amused or not.\\n\\n**Paragraph G.**\\nBoth social and cognitive types of laughter tap into the same expressive machinery in our brains, the emotion and motor circuits that produce smiles and excited vocalisations. However, if cognitive laughter is the product of more general thought processes, it should result from more expansive brain activity.\\n\\n**Paragraph H.**\\nPsychologist Vinod Goel investigated humour using the new technique of ''single event'' functional magnetic resonance imaging (fMRI). An MRI scanner uses magnetic fields and radio waves to track the changes in oxygenated blood that accompany mental activity.\\n\\n**Paragraph I.**\\nUntil recently, MRI scanners needed several minutes of activity and so could not be used to track rapid thought processes such as comprehending a joke. New developments now allow half-second ''snapshots'' of all sorts of reasoning and problem-solving activities.\\n\\n**Paragraph J.**\\nAlthough Goel felt being inside a brain scanner was hardly the ideal place for appreciating a joke, he found evidence that understanding a joke involves a widespread mental shift. His scans showed that at the beginning of a joke the listener''s prefrontal cortex lit up, particularly the right prefrontal believed to be critical for problem solving. But there was also activity in the temporal lobes at the side of the head (consistent with attempts to rouse stored knowledge) and in many other brain areas. Then when the punchline arrived, a new area sprang to life - the orbital prefrontal cortex. This patch of brain tucked behind the orbits of the eyes is associated with evaluating information.\\n\\n**Paragraph K.**\\nMaking a rapid emotional assessment of the events of the moment is an extremely demanding job for the brain, animal or human. Energy and arousal levels may need to be retuned in the blink of an eye. These abrupt changes will produce either positive or negative feelings. The orbital cortex, the region that becomes active in Goel''s experiment, seems the best candidate for the site that feeds such feelings into higher-level thought processes, with its close connections to the brain''s sub-cortical arousal apparatus and centres of metabolic control.\\n\\n**Paragraph L.**\\nAll warm-blooded animals make constant tiny adjustments in arousal in response to external events, but humans, who have developed a much more complicated internal life as a result of language, respond emotionally not only to their surroundings, but to their own thoughts. Whenever a sought-for answer snaps into place, there is a shudder of pleased recognition. Creative discovery being pleasurable, humans have learned to find ways of milking this natural response. The fact that jokes tap into our general evaluative machinery explains why the line between funny and disgusting, or funny and frightening, can be so fine. Whether a joke gives pleasure or pain depends on a person''s outlook.\\n\\n**Paragraph M.**\\nHumour may be a luxury, but the mechanism behind it is no evolutionary accident. As Peter Derks, a psychologist at William and Mary College in Virginia, says: ''I like to think of humour as the distorted mirror of the mind. It''s creative, perceptual, analytical and lingual.\\n\\n**Paragraph N.**\\nIf we can figure out how the mind processes humour, then we''ll have a pretty good handle on how it works in general.''\\n\\n'
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
    'Arthur Koestler considered laughter biologically important in several ways.',
    E'**Đáp án: FALSE**\n\n> "Arthur Koestler dubbed it the luxury reflex: ‘unique in that it serves no apparent biological purpose’."\n\n(Đoạn B) Koestler coi tiếng cười là "luxury reflex" và khẳng định nó "serves no apparent biological purpose" (không phục vụ mục đích sinh học rõ ràng nào), trái ngược hoàn toàn với nhận định "biologically important" trong câu hỏi.',
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
    2,
    'TRUE_FALSE_NOT_GIVEN',
    'READING',
    2,
    'Plato believed humour to be a sign of above-average intelligence.',
    E'**Đáp án: NOT GIVEN**\n\n> "Plato expressed the idea that humour is simply a delighted feeling of superiority over others."\n\n(Đoạn C) Plato chỉ đề cập đến cảm giác "superiority" (ưu việt hơn người khác) khi thấy cái gì đó hài hước, hoàn toàn không có thông tin nào liên hệ điều này với "above-average intelligence" (trí thông minh trên trung bình).',
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
    'Kant believed that a successful joke involves the controlled release of nervous energy.',
    E'**Đáp án: TRUE**\n\n> "Kant and Freud felt that joke-telling relies on building up a psychic tension which is safely punctured by the ludicrousness of the punchline."\n\n(Đoạn C) "Psychic tension" tương ứng với "nervous energy", và "safely punctured" (được chọc thủng một cách an toàn) mang nghĩa tương đương với "controlled release" (sự giải tỏa có kiểm soát).',
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
    4,
    'TRUE_FALSE_NOT_GIVEN',
    'READING',
    2,
    'Current thinking on humour has largely ignored Aristotle''s view on the subject.',
    E'**Đáp án: FALSE**\n\n> "But most modern humour theorists have settled on some version of Aristotle''s belief..."\n\n(Đoạn C) Bài đọc nói rằng "most modern humour theorists" (hầu hết các nhà lý thuyết hài hước hiện đại) đã chấp nhận ("settled on") quan điểm của Aristotle, trái ngược với từ "ignored" (phớt lờ) trong câu hỏi.',
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
    5,
    'TRUE_FALSE_NOT_GIVEN',
    'READING',
    2,
    'Graeme Ritchie’s work links jokes to artificial intelligence.',
    E'**Đáp án: TRUE**\n\n> "Graeme Ritchie... studies the linguistic structure of jokes in order to understand not only humour but language understanding and reasoning in machines."\n\n(Đoạn D) Cụm từ "reasoning in machines" (lập luận trong máy móc) chính là cách diễn đạt khác của "artificial intelligence" (trí tuệ nhân tạo). Graeme Ritchie nghiên cứu cấu trúc truyện cười để hiểu về AI.',
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
    6,
    'TRUE_FALSE_NOT_GIVEN',
    'READING',
    2,
    'Most comedians use personal situations as a source of humour.',
    E'**Đáp án: NOT GIVEN**\n\n> "A comedian will present a situation followed by an unexpected interpretation that is also apt"\n\n(Đoạn D) Tác giả chỉ đề cập diễn viên hài đưa ra "a situation" (một tình huống) chung chung, không xác định cụ thể đó có phải là "personal situations" (tình huống cá nhân) hay không.',
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
    'Chimpanzees make particular noises when they arc playing.',
    E'**Đáp án: TRUE**\n\n> "Chimpanzees have a ''play-face'' a gaping expression accompanied by a panting ''ah, ah'' noise."\n\n(Đoạn F) Bài đọc xác nhận tinh tinh có biểu cảm khuôn mặt khi chơi đùa ("play-face") và đi kèm với tiếng ồn ("noise") cụ thể là tiếng thở hổn hển ''ah, ah''.',
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
    '_______',
    E'**Đáp án: PROBLEM SOLVING**\n\n> "He suggests that comedy... usually involves **problem solving**."\n\n(Đoạn G) Câu hỏi yêu cầu tìm danh từ chỉ một quá trình liên quan đến logic. Đoạn văn nêu rõ hài kịch buộc chúng ta đối mặt với sự bất hợp lý và quá trình này liên quan đến "problem solving".',
    '{"blank-q8": ["PROBLEM SOLVING"]}'::jsonb
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
    E'**Đáp án: TEMPORAL LOBES**\n\n> "...activity in the **temporal lobes**..."\n\n(Đoạn G) Dựa vào ngữ cảnh về hoạt động não bộ khi nghe truyện cười, bài đọc chỉ ra sự kích hoạt ở "temporal lobes" (thùy thái dương) liên quan đến việc phân tích ngữ nghĩa.',
    '{"blank-q9": ["TEMPORAL LOBES"]}'::jsonb
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
    '_______',
    E'**Đáp án: EVALUATING INFORMATION**\n\n> "...orbital prefrontal cortex... involved in **evaluating information**."\n\n(Đoạn G) Vùng não "orbital prefrontal cortex" được xác định có chức năng "evaluating information" (đánh giá thông tin) để quyết định xem một câu chuyện có hài hước hay không.',
    '{"blank-q10": ["EVALUATING INFORMATION"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    11,
    'MATCHING_INFORMATION',
    'READING',
    2,
    'One of the brain’s most difficult tasks is to',
    E'**Đáp án: C**\n\n> "making a rapid emotional assessment of the events of the moment is one of the brain’s toughest challenges."\n\n(Đoạn G) "One of the brain’s most difficult tasks" (Câu hỏi) tương đương với "one of the brain’s toughest challenges" (Bài đọc). Nhiệm vụ đó là "rapid emotional assessment" (đánh giá cảm xúc nhanh chóng).',
    '{"info-q11": ["C", "c"]}'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    12,
    'MATCHING_INFORMATION',
    'READING',
    2,
    'ecause of the language they have developed, humans',
    E'**Đáp án: A**\n\n> "Human beings, who have developed a much more complicated linguistic communication system, can..."\n\n(Đoạn F) Do phát triển hệ thống ngôn ngữ phức tạp hơn ("language they have developed"), con người có khả năng kể chuyện cười mà động vật không làm được (đề cập trong phần đầu đoạn F).',
    '{"info-q12": ["A", "a"]}'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    13,
    'MATCHING_INFORMATION',
    'READING',
    2,
    'ndividual responses to humour',
    E'**Đáp án: F**\n\n> "But his research also suggests that a person’s outlook on life... individual responses to humour."\n\n(Đoạn H) "Individual responses to humour" (Câu hỏi) liên quan đến sự khác biệt trong hoạt động não bộ hoặc quan điểm sống ("outlook on life").',
    '{"info-q13": ["F", "f"]}'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    14,
    'MATCHING_INFORMATION',
    'READING',
    2,
    'Peter Derks believes that humour',
    E'**Đáp án: D**\n\n> "Peter Derks... suggests that humour works like a mental fitness center..."\n\n(Đoạn H) Peter Derks so sánh hài hước với một trung tâm thể dục tinh thần ("mental fitness center"), ngụ ý nó giúp rèn luyện trí não.',
    '{"info-q14": ["D", "d"]}'
  );



  -- Delete old question groups for this exam
  DELETE FROM exam_question_groups WHERE "SectionId" = sec1;

  -- Insert question groups
  INSERT INTO exam_question_groups ("Id","SectionId","Idx","StartIdx","EndIdx","InstructionMd")
  VALUES (gen_random_uuid(), sec1, 1, 1, 7, E'## Questions 1-7\n\nDo the following statements agree with the information given in the text?\n\nWrite\n- **TRUE** if the statement agrees with the information\n- **FALSE** if the statement contradicts the information\n- **NOT GIVEN** if there is no information on this\n\n---\n\n');

  INSERT INTO exam_question_groups ("Id","SectionId","Idx","StartIdx","EndIdx","InstructionMd")
  VALUES (gen_random_uuid(), sec1, 2, 8, 10, E'## Questions 8-10\n\nComplete the sentences below.\n\nWrite **NO MORE THAN TWO WORDS AND/OR A NUMBER** for each answer.\n\n---\n\n\n\n![Diagram](https://res.cloudinary.com/df41zs8il/image/upload/v1766591284/ielts/05_3f01ed6791e4.jpg)\n\n**8.** _______\n\n**9.** _______\n\n**10.** _______');

  INSERT INTO exam_question_groups ("Id","SectionId","Idx","StartIdx","EndIdx","InstructionMd")
  VALUES (gen_random_uuid(), sec1, 3, 11, 14, E'## Questions 11-14\n\nWhich section contains the following information?\n\nWrite the correct letter, **A-L**.');

END$$;


COMMIT;