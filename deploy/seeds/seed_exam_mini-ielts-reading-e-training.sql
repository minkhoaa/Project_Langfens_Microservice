-- ============================================
-- IELTS Exam Data Import SQL
-- Generated: 2025-12-23T20:36:54.696824
-- Source: mini-ielts.com
-- Title: E-training
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data for slug: mini-ielts-reading-e-training
DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'mini-ielts-reading-e-training'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'mini-ielts-reading-e-training';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'mini-ielts-reading-e-training';
DELETE FROM exams
WHERE "Slug" = 'mini-ielts-reading-e-training';

DO $$
DECLARE
  exam_id uuid := gen_random_uuid();
  sec1 uuid := gen_random_uuid();
  qid uuid;
BEGIN

  INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","ImageUrl","UpdatedAt")
  VALUES (
    exam_id,
    'mini-ielts-reading-e-training',
    'E-training',
    'IELTS Reading Practice Test from IELTS Mentor',
    'IELTS',
    'B2',
    'PUBLISHED',
    20,
    'https://img.freepik.com/free-vector/e-learning-icons-flat_1284-3950.jpg?w=2000',
    now()
  );

  INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","PassageMd")
  VALUES (
    sec1,
    exam_id,
    1,
    'Reading Passage - E-training',
    E'**Questions 1-10:**\nChoose the correct heading for each section from the list of headings below.\n\nWrite the correct number, **i-xi**.\n\n---\n\n**Questions 11-11:**\nChoose **TWO** letters, **A-E**.',
    E'**Paragraph A.**\\nE-learning is the unifying term to describe the fields of online learning, web-based training, and technology-delivered instruction, which can be a great benefit to corporate e-learning. IBM, for instance, claims that the institution of its e-training program, Basic Blue, whose purpose is to train new managers, saved the company in the range of $200 million in 1999. Cutting the travel expenses required to bring employees and instructors to a central classroom account for the lion’s share of the savings. With an online course, employees can learn from any Internet-connected PC, anywhere in the world. Ernst and Young reduced training costs by 35 percent while improving consistency and scalability.\\n\\n**Paragraph B.**\\nIn addition to generally positive economic benefits, other advantages such as convenience, standardized delivery, self-paced learning, and a variety of available content, have made e-learning a high priority for many corporations. E-learning is widely believed to offer flexible “any time, any place” learning. The claim for “any place” is valid in principle and is a great development. Many people can engage with rich learning materials that simply were not possible in a paper of broadcast distance learning era. For teaching specific information and skills, e-training holds great promise. It can be especially effective at helping employees prepare for IT certification programs. E-learning also seems to effectively address topics such as sexual harassment education’, safety training and management training – all areas where a clear set of objectives can be identified. Ultimately, training experts recommend a “blended” approach that combines both online and in-person training as the instruction requires. E-learning is not an end-all solution. But if it helps decrease costs and windowless classrooms filled with snoring students, it definitely has its advantages.\\n\\n**Paragraph C.**\\nMuch of the discussion about implementing e-learning has focused on the technology, but as Driscoll and others have reminded us, e-learning is not just about the technology, but also many human factors. As any capable manager knows, teaching employees new skills is critical to a smoothly run business. Having said that, however, the traditional route of classroom instruction runs the risk of being expensive, slow and, oftentimes, ineffective. Perhaps the classroom’s greatest disadvantage is the fact that it takes employees out of their jobs. Every minute an employee is sitting in a classroom training session is a minute they’re not out on the floor working. It now looks as if there is a way to circumvent these traditional training drawbacks. E-training promises more effective teaching techniques by integrating audio, video, animation, text and interactive materials with the intent of teaching each student at his or her own pace. In addition to higher performance results, there are other immediate benefits to students such as increased time on task, higher levels of motivation, and reduced test anxiety for many learners.\\n\\n**Paragraph D.**\\nOn the other hand, nobody said E-training technology would be cheap. E-training service providers, on the average, charge from $10,000 to $60,000 to develop one hour of online instruction. This price varies depending on the complexity of the training topic and the media used. HTML pages are a little cheaper to develop while streaming-video presentations or flash animations cost more. Course content is just the starting place for the cost. A complete e-learning solution also includes the technology platform (the computers, applications and network connections that are used to deliver the courses). This technology platform, known as a learning management system (LMS), can either be installed onsite or outsourced. Add to that cost the necessary investments in network bandwidth to deliver multimedia courses, and you’re left holding one heck of a bill. For the LMS infrastructure and a dozen or so online courses, costs can top $500,000 in the first year. These kinds of costs mean that custom e-training is, for the time being, an option only for large organizations. For those companies that have a large enough staff, the e-training concept pays for itself. Aware of this fact, large companies are investing heavily in online training. Today, over half of the 400-plus courses that Rockwell Collins offers are delivered instantly to its clients in an e-learning format, a change that has reduced its annual training costs by 40%. Many other success stories exist.\\n\\n**Paragraph E.**\\nE-learning isn’t expected to replace the classroom entirely. For one thing, bandwidth limitations are still an issue in presenting multimedia over the Internet. Furthermore, e-training isn’t suited to every mode of instruction or topic. For instance, it’s rather ineffective imparting cultural values or building teams. If your company has a unique corporate culture is would be difficult to convey that to first-time employees through a computer monitor. Group training sessions are more ideal for these purposes. In addition, there is a perceived loss of research time because of the work involved in developing and teaching online classes. Professor Wallin estimated that it required between 500 and 1,000 person-hours, that is, Wallin-hours, to keep the course at the appropriate level of currency and usefulness. (Distance learning instructors often need technical skills, no matter how advanced the courseware system.) That amounts to between a quarter and half of a person-year. Finally, teaching materials require computer literacy and access to equipment. Any e-Learning system involves basic equipment and a minimum level of computer knowledge in order to perform the tasks required by the system. A student that does not possess these skills, or have access to these tools, cannot succeed in an e-Learning program.\\n\\n**Paragraph F.**\\nWhile few people debate the obvious advantages of e-learning, systematic research is needed to confirm that learners are actually acquiring and using the skills that are being taught online, and that e-learning is the best way to achieve the outcomes in a corporate environment. Nowadays, a go-between style of Blended learning, which refers to a mixing of different learning environments, is gaining popularity. It combines traditional face-to-face classroom methods with more modern computer-mediated activities. According to its proponents, the strategy creates a more integrated approach for both instructors and learners. Formerly, technology-based materials played a supporting role in face-to-face instruction. Through a blended learning approach, technology will be more important.\\n\\n'
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
    '',
    '{"paragraph-a-q1": ["i", "i"]}'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'i. overview of the benefits for application of E-training', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'ii. IBM''s successful choice of training', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'iii. Future directions and a new style of teaching', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'iv. learners'' achievement and advanced teaching materials', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, 'v. limitations when E-training compares with traditional class', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 6, 'vi. multimedia over the Internet can be a solution', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 7, 'vii. technology can be a huge financial burden', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 8, 'viii. the distance learners outperformed the traditional university learners worldwide', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 9, 'ix. other advantages besides economic consideration', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 10, 'x. Training offered to help people learn using computers', false);

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
    '',
    '{"paragraph-b-q2": ["ix", "ix"]}'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'i. overview of the benefits for application of E-training', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'ii. IBM''s successful choice of training', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'iii. Future directions and a new style of teaching', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'iv. learners'' achievement and advanced teaching materials', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, 'v. limitations when E-training compares with traditional class', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 6, 'vi. multimedia over the Internet can be a solution', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 7, 'vii. technology can be a huge financial burden', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 8, 'viii. the distance learners outperformed the traditional university learners worldwide', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 9, 'ix. other advantages besides economic consideration', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 10, 'x. Training offered to help people learn using computers', false);

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
    '',
    '{"paragraph-c-q3": ["iv", "iv"]}'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'i. overview of the benefits for application of E-training', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'ii. IBM''s successful choice of training', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'iii. Future directions and a new style of teaching', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'iv. learners'' achievement and advanced teaching materials', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, 'v. limitations when E-training compares with traditional class', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 6, 'vi. multimedia over the Internet can be a solution', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 7, 'vii. technology can be a huge financial burden', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 8, 'viii. the distance learners outperformed the traditional university learners worldwide', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 9, 'ix. other advantages besides economic consideration', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 10, 'x. Training offered to help people learn using computers', false);

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
    '',
    '{"paragraph-d-q4": ["vii", "vii"]}'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'i. overview of the benefits for application of E-training', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'ii. IBM''s successful choice of training', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'iii. Future directions and a new style of teaching', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'iv. learners'' achievement and advanced teaching materials', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, 'v. limitations when E-training compares with traditional class', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 6, 'vi. multimedia over the Internet can be a solution', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 7, 'vii. technology can be a huge financial burden', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 8, 'viii. the distance learners outperformed the traditional university learners worldwide', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 9, 'ix. other advantages besides economic consideration', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 10, 'x. Training offered to help people learn using computers', false);

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
    '',
    '{"paragraph-e-q5": ["v", "v"]}'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'i. overview of the benefits for application of E-training', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'ii. IBM''s successful choice of training', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'iii. Future directions and a new style of teaching', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'iv. learners'' achievement and advanced teaching materials', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, 'v. limitations when E-training compares with traditional class', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 6, 'vi. multimedia over the Internet can be a solution', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 7, 'vii. technology can be a huge financial burden', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 8, 'viii. the distance learners outperformed the traditional university learners worldwide', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 9, 'ix. other advantages besides economic consideration', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 10, 'x. Training offered to help people learn using computers', false);

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
    '',
    '{"paragraph-f-q6": ["iii", "iii"]}'
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'i. overview of the benefits for application of E-training', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'ii. IBM''s successful choice of training', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'iii. Future directions and a new style of teaching', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'iv. learners'' achievement and advanced teaching materials', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, 'v. limitations when E-training compares with traditional class', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 6, 'vi. multimedia over the Internet can be a solution', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 7, 'vii. technology can be a huge financial burden', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 8, 'viii. the distance learners outperformed the traditional university learners worldwide', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 9, 'ix. other advantages besides economic consideration', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 10, 'x. Training offered to help people learn using computers', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    7,
    'MATCHING_INFORMATION',
    'READING',
    2,
    'Projected Basic Blue in IBM achieved great success.',
    '',
    '{"info-q7": ["A", "a"]}'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    8,
    'MATCHING_INFORMATION',
    'READING',
    2,
    'E-learning wins as a priority for many corporations as its flexibility.',
    '',
    '{"info-q8": ["B", "b"]}'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    9,
    'MATCHING_INFORMATION',
    'READING',
    2,
    'The combination of traditional and e-training environments may prevail.',
    '',
    '{"info-q9": ["F", "f"]}'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    10,
    'MATCHING_INFORMATION',
    'READING',
    2,
    'Example of fast electronic delivery for a company''s products to its customers.',
    '',
    '{"info-q10": ["D", "d"]}'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    11,
    'MULTIPLE_CHOICE_SINGLE',
    'READING',
    2,
    'According to the passage, what are the limitations of e-training?',
    '',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. Technical facilities are hardly obtained.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. Presenting multimedia over the Internet is restricted due to the bandwidth limit.', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. It is ineffective imparting a unique corporate value to fresh employees.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D. Employees need to block a long time leaving their position attending training.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, 'E. More preparation time is needed to keep the course at a suitable level.', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    12,
    'MULTIPLE_CHOICE_SINGLE',
    'READING',
    2,
    'According to the passage, what are the limitations of e-training?',
    '',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. Technical facilities are hardly obtained.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. Presenting multimedia over the Internet is restricted due to the bandwidth limit.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. It is ineffective imparting a unique corporate value to fresh employees.', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D. Employees need to block a long time leaving their position attending training.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, 'E. More preparation time is needed to keep the course at a suitable level.', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    13,
    'MULTIPLE_CHOICE_SINGLE',
    'READING',
    2,
    'According to the passage, what are the limitations of e-training?',
    '',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. Technical facilities are hardly obtained.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. Presenting multimedia over the Internet is restricted due to the bandwidth limit.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. It is ineffective imparting a unique corporate value to fresh employees.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D. Employees need to block a long time leaving their position attending training.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, 'E. More preparation time is needed to keep the course at a suitable level.', true);


END$$;


COMMIT;