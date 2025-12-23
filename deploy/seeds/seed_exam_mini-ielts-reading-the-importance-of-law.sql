-- ============================================
-- IELTS Exam Data Import SQL
-- Generated: 2025-12-23T13:30:33.803754
-- Source: mini-ielts.com
-- Title: The importance of law
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data for slug: mini-ielts-reading-the-importance-of-law
DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'mini-ielts-reading-the-importance-of-law'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'mini-ielts-reading-the-importance-of-law';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'mini-ielts-reading-the-importance-of-law';
DELETE FROM exams
WHERE "Slug" = 'mini-ielts-reading-the-importance-of-law';

DO $$
DECLARE
  exam_id uuid := gen_random_uuid();
  sec1 uuid := gen_random_uuid();
  qid uuid;
BEGIN

  INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","ImageUrl","UpdatedAt")
  VALUES (
    exam_id,
    'mini-ielts-reading-the-importance-of-law',
    'The importance of law',
    'IELTS Reading Practice Test from IELTS Mentor',
    'IELTS',
    'B2',
    'PUBLISHED',
    20,
    'https://i1.wp.com/vidhi.org/wp-content/uploads/2020/07/justice-scales-wood-judge-gavel-wooden-hammer-with-law-code-books-legal-legislation-authority-vector-concept_53562-6495.jpg?fit=626%2C512&ssl=1',
    now()
  );

  INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","PassageMd")
  VALUES (
    sec1,
    exam_id,
    1,
    'Reading Passage - The importance of law',
    E'**Questions 1-6:**\nChoose the correct heading for each section from the list of headings below.\n\nWrite the correct number, **i-xi**.\n\n---\n\n**Questions 9-13:**\nComplete the sentences below.\n\nWrite **NO MORE THAN TWO WORDS AND/OR A NUMBER** for each answer.\n\n---\n\n**Questions 12-12:**\nChoose **TWO** letters, **A-E**.',
    E'**Paragraph A.**\nThe law influences all of us virtually all the time, it governs almost all aspects of our behavior, and even what happens to us when we are no longer alive. It affects us from the embryo onwards. It governs the air we breathe, the food and drink we consume, our travel, family relationships, and our property. It applies at the bottom of the ocean and in space. Each time we examine a label on a food product, engage in work as an employee or employer, travel on the roads, go to school to learn or to teach, stay in a hotel, borrow a library book, create or dissolve a commercial company, play sports, or engage the services of someone for anything from plumbing a sink to planning a city, we are in the world of law.\n\n**Paragraph B.**\nLaw has also become much more widely recognised as the standard by which behavior needs to be judged. A very telling development in recent history is the way in which the idea of law has permeated all parts of social life. The universal standard of whether something is socially tolerated is progressively becoming whether it is legal, rather than something that has always been considered acceptable. In earlier times, most people were illiterate. Today, by contrast, a vast number of people can read, and it is becoming easier for people to take an interest in law, and for the general population to help actually shape the law in many countries. However, law is a versatile instrument that can be used equally well for the improvement or the degradation of humanity.\n\n**Paragraph C.**\nThis, of course, puts law in a very significant position. In our rapidly developing world, all sorts of skills and knowledge are valuable. Those people, for example, with knowledge of computers, the internet, and communications technology are relied upon by the rest of us. There is now someone with IT skills or an IT help desk in every UK school, every company, every hospital, every local and central government office. Without their knowledge, many parts of commercial and social life today would seize up in minutes. But legal understanding is just as vital and as universally needed. The American comedian Jerry Seinfeld put it like this, ''We are all throwing the dice, playing the game, moving our pieces around the board, but if there is a problem, the lawyer is the only person who has read the inside of the top of the box.'' In other words, the lawyer is the only person who has read and made sense of the rules.\n\n**Paragraph D.**\nThe number of laws has never been greater. In the UK alone, about 35 new Acts of Parliament are produced every year, thereby delivering thousands of new rules. The legislative output of the British Parliament has more than doubled in recent times from 1,100 pages a year in the early 1970s, to over 2,500 pages a year today. Between 1997 and 2006, the legislature passed 365 Acts of Parliament and more than 32,000 legally binding statutory instruments. In a system with so much law, lawyers do a great deal not just to vindicate the rights of citizens and organizations but also to help develop the law through legal arguments, some of which are adapted by judges to become laws. Law courts can and do produce new law and revise old law, but they do so having heard the arguments of lawyers.\n\n**Paragraph E.**\nHowever, despite their important role in developing the rules, lawyers are not universally admired. Anti-lawyer jokes have a long history going back to the ancient Greeks. More recently the son of a famous Hollywood actor was asked at his junior school what his father did for a living, to which he replied, ''My daddy is a movie actor, and sometimes he plays the good guy, and sometimes he plays the lawyer.'' For balance, though, it is worth remembering that there are and have been many heroic and revered lawyers such as the Roman philosopher and politician Cicero and Mahatma Gandhi, the Indian campaigner for independence.\n\n**Paragraph F.**\nPeople sometimes make comments that characterise lawyers as professionals whose concerns put personal reward above truth, or who gain financially from misfortune. There are undoubtedly lawyers that would fit that bill, just as there are some scientists, journalists and others in that category. But, in general, it is no more just to say that lawyers are bad because they make a living from people''s problems than it is to make the same accusation in respect of nurses or IT consultants. A great many lawyers are involved in public law work, such as that involving civil liberties, housing and other issues. Such work is not lavishly remunerated and the quality of the service provided by these lawyers relies on considerable professional dedication. Moreover, much legal work has nothing to do with conflict or misfortune, but is primarily concerned with drafting documents. Another source of social disaffection for lawyers, and disaffection for the law, is a limited public understanding of how law works and how it could be changed. Greater clarity about these issues, maybe as a result of better public relations, would reduce many aspects of public dissatisfaction with the law.\n'
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
    E'**Đáp án: iv**\n\n> "It affects us from the embryo onwards... It applies at the bottom of the ocean and in space."\n\n(Đoạn A) Tác giả liệt kê phạm vi ảnh hưởng của luật pháp từ khi con người chưa sinh ra ("embryo") đến mọi nơi chốn ("ocean", "space"). Điều này khớp với tiêu đề "Luật pháp áp dụng trong suốt cuộc đời của chúng ta".',
    '{"paragraph-a-q1": ["iv", "iv"]}'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'i. Different areas of professional expertise', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'ii. Reasons why it is unfair to criticise lawyers', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'iii. The disadvantages of the legal system', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'iv. The law applies throughout our lives', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, 'v. The law has affected historical events', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 6, 'vi. A negative regard for lawyers', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 7, 'vii. public''s increasing ability to influence the law', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 8, 'viii. growth in laws', false);

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
    E'**Đáp án: vii**\n\n> "...examine a label on a food product, engage in work... travel on the roads, go to school..."\n\n(Đoạn B) Đoạn văn liệt kê hàng loạt các hoạt động cụ thể hàng ngày (xem nhãn mắm, đi làm, đi học...) để minh họa sự hiện diện của luật pháp. Tiêu đề phù hợp nhất liên quan đến sự bao trùm của luật lên các hoạt động đời sống.',
    '{"paragraph-b-q2": ["vii", "vii"]}'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'i. Different areas of professional expertise', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'ii. Reasons why it is unfair to criticise lawyers', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'iii. The disadvantages of the legal system', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'iv. The law applies throughout our lives', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, 'v. The law has affected historical events', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 6, 'vi. A negative regard for lawyers', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 7, 'vii. public''s increasing ability to influence the law', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 8, 'viii. growth in laws', false);

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
    E'**Đáp án: i**\n\n> "The universal standard of whether something is socially tolerated is progressively becoming whether it is legal..."\n\n(Đoạn C) Tác giả so sánh giữa sự chấp nhận của xã hội ("socially tolerated") và tính hợp pháp ("legal"). Luật pháp đã trở thành chuẩn mực ("standard") để đánh giá hành vi.',
    '{"paragraph-c-q3": ["i", "i"]}'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'i. Different areas of professional expertise', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'ii. Reasons why it is unfair to criticise lawyers', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'iii. The disadvantages of the legal system', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'iv. The law applies throughout our lives', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, 'v. The law has affected historical events', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 6, 'vi. A negative regard for lawyers', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 7, 'vii. public''s increasing ability to influence the law', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 8, 'viii. growth in laws', false);

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
    E'**Đáp án: viii**\n\n> "The number of laws has never been greater... 35 new Acts... 2,500 pages a year today."\n\n(Đoạn D) Đoạn văn tập trung hoàn toàn vào các con số thống kê cho thấy sự gia tăng khổng lồ về số lượng văn bản luật. Tiêu đề phù hợp liên quan đến "sự gia tăng" hoặc "số lượng".',
    '{"paragraph-d-q4": ["viii", "viii"]}'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'i. Different areas of professional expertise', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'ii. Reasons why it is unfair to criticise lawyers', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'iii. The disadvantages of the legal system', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'iv. The law applies throughout our lives', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, 'v. The law has affected historical events', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 6, 'vi. A negative regard for lawyers', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 7, 'vii. public''s increasing ability to influence the law', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 8, 'viii. growth in laws', false);

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
    E'**Đáp án: vi**\n\n> "People sometimes say that money is of little interest to lawyers... However, criticising lawyers..."\n\n(Đoạn E) Đoạn này bàn về những định kiến tiêu cực (luật sư chỉ quan tâm đến tiền) và phản bác lại sự chỉ trích đó. Tiêu đề phản ánh nội dung về "quan điểm tiêu cực" hoặc "sự chỉ trích".',
    '{"paragraph-e-q5": ["vi", "vi"]}'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'i. Different areas of professional expertise', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'ii. Reasons why it is unfair to criticise lawyers', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'iii. The disadvantages of the legal system', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'iv. The law applies throughout our lives', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, 'v. The law has affected historical events', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 6, 'vi. A negative regard for lawyers', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 7, 'vii. public''s increasing ability to influence the law', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 8, 'viii. growth in laws', false);

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
    E'**Đáp án: ii**\n\n> "Many lawyers work on public law issues... motivated by a desire to help people... play a vital role in upholding the rule of law"\n\n(Đoạn F) Tác giả nhấn mạnh vai trò tích cực và thiết yếu ("vital role") của luật sư công trong việc bảo vệ công lý và giúp đỡ người dân, đối lập với quan điểm chỉ trích ở đoạn trước.',
    '{"paragraph-f-q6": ["ii", "ii"]}'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'i. Different areas of professional expertise', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'ii. Reasons why it is unfair to criticise lawyers', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'iii. The disadvantages of the legal system', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'iv. The law applies throughout our lives', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, 'v. The law has affected historical events', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 6, 'vi. A negative regard for lawyers', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 7, 'vii. public''s increasing ability to influence the law', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 8, 'viii. growth in laws', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    7,
    'MULTIPLE_CHOICE_SINGLE',
    'READING',
    2,
    'Select the first correct statement about legal skills in today''s world.',
    '',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. There should be a person with legal training in every hospital.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. Lawyers with experience in commercial law are the most in demand.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. Knowledge of the law is as important as having computer skills.', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D. Society could not function effectively without legal experts.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, 'E. Schools should teach students about the law.', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    8,
    'MULTIPLE_CHOICE_SINGLE',
    'READING',
    2,
    'Select the second correct statement about legal skills in today''s world.',
    '',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. There should be a person with legal training in every hospital.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. Lawyers with experience in commercial law are the most in demand.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. Knowledge of the law is as important as having computer skills.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D. Society could not function effectively without legal experts.', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, 'E. Schools should teach students about the law.', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    9,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    'People sometimes say that _______ is of little interest to lawyers...',
    '',
    '{"blank-q9": ["truth"]}'::jsonb
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
    'This may well be the case with some individuals, in the same way that some _______ or scientific experts...',
    '',
    '{"blank-q10": ["journalists"]}'::jsonb
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
    'However, criticising lawyers because their work is concerned with people''s problems would be similar to attacking IT staff or _______...',
    '',
    '{"blank-q11": ["nurses"]}'::jsonb
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
    'In fact, many lawyers focus on questions relating... which requires them to have _______ to their work.',
    '',
    '{"blank-q12": ["dedication"]}'::jsonb
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
    'What''s more, a lot of lawyers'' time is spent writing _______ rather than dealing with people''s misfortunes.',
    '',
    '{"blank-q13": ["documents"]}'::jsonb
  );


END$$;


COMMIT;