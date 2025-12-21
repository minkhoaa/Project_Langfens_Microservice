-- ============================================
-- IELTS Exam Data Import SQL
-- Generated: 2025-12-19T11:23:56.800270
-- Target: Australian Parrots Reading Passage
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data for slug: ielts-reading-the-importance-of-law
DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-the-importance-of-law'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-the-importance-of-law';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-the-importance-of-law';
DELETE FROM exams
WHERE "Slug" = 'ielts-reading-the-importance-of-law';

DO $$
DECLARE
  exam_id uuid := gen_random_uuid();
  sec1 uuid := gen_random_uuid();
  qid uuid;
BEGIN

  INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","UpdatedAt")
  VALUES (
    exam_id,
    'ielts-reading-the-importance-of-law',
    'The importance of law',
    'IELTS Reading Practice Test: The importance of law',
    'IELTS',
    'B2',
    'PUBLISHED',
    20,
    now()
  );

  INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","PassageMd")
  VALUES (
    sec1,
    exam_id,
    1,
    'Reading Passage - The importance of law',
    E'',
    E'# Passage\n\nA The law influences all of us virtually all the time, it governs almost all aspects of our behavior, and even what happens to us when we are no longer alive. It affects us from the embryo onwards. It governs the air we breathe, the food and drink we consume, our travel, family relationships, and our property. It applies at the bottom of the ocean and in space.\n\nEach time we examine a label on a food product, engage in work as an employee or employer, travel on the roads, go to school to learn or to teach, stay in a hotel, borrow a library book, create or dissolve a commercial company, play sports, or engage the services of someone for anything from plumbing a sink to planning a city, we are in the world of law.\n\nB Law has also become much more widely recognised as the standard by which behavior needs to be judged. A very telling development in recent history is the way in which the idea of law has permeated all parts of social life. The universal standard of whether something is socially tolerated is progressively becoming whether it is legal, rather than something that has always been considered acceptable. In earlier times, most people were illiterate.\n\nToday, by contrast, a vast number of people can read, and it is becoming easier for people to take an interest in law, and for the general population to help actually shape the law in many countries. However, law is a versatile instrument that can be used equally well for the improvement or the degradation of humanity.\n\nC This, of course, puts law in a very significant position. In our rapidly developing world, all sorts of skills and knowledge are valuable. Those people, for example, with knowledge of computers, the internet, and communications technology are relied upon by the rest of us.\n\nThere is now someone with IT skills or an IT help desk in every UK school, every company, every hospital, every local and central government office. Without their knowledge, many parts of commercial and social life today would seize up in minutes. But legal understanding is just as vital and as universally needed. The American comedian Jerry Seinfeld put it like this, \'\'We are all throwing the dice, playing the game, moving our pieces around the board, but if there is a problem, the lawyer is the only person who has read the inside of the top of the box.\'\' In other words, the lawyer is the only person who has read and made sense of the rules.\n\nD The number of laws has never been greater. In the UK alone, about 35 new Acts of Parliament are produced every year, thereby delivering thousands of new rules. The legislative output of the British Parliament has more than doubled in recent times from 1,100 pages a year in the early 1970s,to over 2,500 pages a year today. Between 1997 and\n\n2006,the legislature passed 365 Acts of Parliament and more than 32,000 legally binding statutory instruments. In a system with so much law, lawyers do a great deal not just to vindicate the rights of citizens and organizations but also to help develop the law through legal arguments, some of which are adapted by judges to become laws. Law courts can and do produce new law and revise old law, but they do so having heard the arguments of lawyers.\n\nE However, despite their important role in developing the rules, lawyers are not universally admired. Anti-lawyer jokes have a long history going back to the ancient Greeks.\n\nMore recently the son of a famous Hollywood actor was asked at his junior school what his father did for a living, to which he replied,\'\'My daddy is a movie actor, and sometimes he plays the good guy, and sometimes he plays the lawyer. For balance, though, it Is worth remembering that there are and have been many heroic and revered lawyers such as the Roman philosopher and politician Cicero and Mahatma Gandi, the Indian campaigner for independence.\n\nF People sometimes make comments that characterise lawyers as professionals whose concerns put personal reward above truth, or who gain financially from misfortune. There are undoubtedly lawyers that would fit that bill, Just as there are some scientists, Journalists and others In that category, But, In general, it is no more Just to say that lawyers are bad because they make a living from people\'\'s problems than it is to make the same accusation In respect of nurses or IT consultants, A great many lawyers are involved in public law work, such as that Involving civil liberties, housing and other Issues. Such work Is not lavishly remunerated and the quality of the service provided by these lawyers relies on considerable professional dedication, Moreover, much legal work has nothing to do with conflict or misfortune, but is primarily concerned with drafting documents, Another source of social disaffection for lawyers, and disaffection for the law, is a limited public understanding of how law works and how It could be changed. Greater clarity about these issues, maybe as a result of better public relations, would reduce many aspects of public dissatisfaction with the law.'
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
    'Read Paragraph A carefully and identify its main idea. Match it with the most suitable heading from the list.',
    '{"paragraph-q1": []}'::jsonb
  );

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
    'Read Paragraph B carefully and identify its main idea. Match it with the most suitable heading from the list.',
    '{"paragraph-q2": []}'::jsonb
  );

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
    'Read Paragraph C carefully and identify its main idea. Match it with the most suitable heading from the list.',
    '{"paragraph-q3": []}'::jsonb
  );

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
    'Read Paragraph D carefully and identify its main idea. Match it with the most suitable heading from the list.',
    '{"paragraph-q4": []}'::jsonb
  );

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
    'Read Paragraph E carefully and identify its main idea. Match it with the most suitable heading from the list.',
    '{"paragraph-q5": []}'::jsonb
  );

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
    'Read Paragraph F carefully and identify its main idea. Match it with the most suitable heading from the list.',
    '{"paragraph-q6": []}'::jsonb
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
    'Lawyers as professionals People sometimes say that _______ is of little interest to lawyers, who are more concerned with making money. This may well be the case with some individuals, in the same way that some (...) . or scientific experts may also be driven purely by financial greed. However, criticising lawyers because their work is concerned with people''s problems would be similar to attacking IT staff or (...) for the same reason. In fact, many lawyers focus on questions relating, for example, to housing or civil liberties, which requires them to have (...) to their work. What''s more, a lot of lawyers'' time is spent writing (...) rather than dealing with people''s misfortunes.',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank. The answer must fit grammatically.',
    '{"blank-q9": []}'::jsonb
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
    'Lawyers as professionals People sometimes say that (...) is of little interest to lawyers, who are more concerned with making money. This may well be the case with some individuals, in the same way that some _______ . or scientific experts may also be driven purely by financial greed. However, criticising lawyers because their work is concerned with people''s problems would be similar to attacking IT staff or (...) for the same reason. In fact, many lawyers focus on questions relating, for example, to housing or civil liberties, which requires them to have (...) to their work. What''s more, a lot of lawyers'' time is spent writing (...) rather than dealing with people''s misfortunes.',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank. The answer must fit grammatically.',
    '{"blank-q10": []}'::jsonb
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
    'Lawyers as professionals People sometimes say that (...) is of little interest to lawyers, who are more concerned with making money. This may well be the case with some individuals, in the same way that some (...) . or scientific experts may also be driven purely by financial greed. However, criticising lawyers because their work is concerned with people''s problems would be similar to attacking IT staff or _______ for the same reason. In fact, many lawyers focus on questions relating, for example, to housing or civil liberties, which requires them to have (...) to their work. What''s more, a lot of lawyers'' time is spent writing (...) rather than dealing with people''s misfortunes.',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank. The answer must fit grammatically.',
    '{"blank-q11": []}'::jsonb
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
    'Lawyers as professionals People sometimes say that (...) is of little interest to lawyers, who are more concerned with making money. This may well be the case with some individuals, in the same way that some (...) . or scientific experts may also be driven purely by financial greed. However, criticising lawyers because their work is concerned with people''s problems would be similar to attacking IT staff or (...) for the same reason. In fact, many lawyers focus on questions relating, for example, to housing or civil liberties, which requires them to have _______ to their work. What''s more, a lot of lawyers'' time is spent writing (...) rather than dealing with people''s misfortunes.',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank. The answer must fit grammatically.',
    '{"blank-q12": []}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd")
  VALUES (
    qid,
    sec1,
    12,
    'MULTIPLE_CHOICE_MULTIPLE',
    'READING',
    2,
    'Choose TWO letters, A-E.',
    'Select 2 correct options. Order doesn''t matter.'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES
    (gen_random_uuid(), qid, 1, 'A. There should be a person with legal training in every hospital.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES
    (gen_random_uuid(), qid, 2, 'B. Lawyers with experience in commercial law are the most in demand.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES
    (gen_random_uuid(), qid, 3, 'C. Knowledge of the law is as important as having computer skills.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES
    (gen_random_uuid(), qid, 4, 'D. Society could not function effectively without legal experts.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES
    (gen_random_uuid(), qid, 5, 'E. Schools should teach students about the law.', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    13,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    'Lawyers as professionals People sometimes say that (...) is of little interest to lawyers, who are more concerned with making money. This may well be the case with some individuals, in the same way that some (...) . or scientific experts may also be driven purely by financial greed. However, criticising lawyers because their work is concerned with people''s problems would be similar to attacking IT staff or (...) for the same reason. In fact, many lawyers focus on questions relating, for example, to housing or civil liberties, which requires them to have (...) to their work. What''s more, a lot of lawyers'' time is spent writing _______ rather than dealing with people''s misfortunes.',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank. The answer must fit grammatically.',
    '{"blank-q13": []}'::jsonb
  );

END$$;


COMMIT;