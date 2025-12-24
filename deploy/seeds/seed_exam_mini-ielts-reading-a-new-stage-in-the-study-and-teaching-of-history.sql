-- ============================================
-- IELTS Exam Data Import SQL
-- Generated: 2025-12-24T13:45:02.014120
-- Source: mini-ielts.com
-- Title: A new stage in the study and teaching of history
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data for slug: mini-ielts-reading-a-new-stage-in-the-study-and-teaching-of-history
DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'mini-ielts-reading-a-new-stage-in-the-study-and-teaching-of-history'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'mini-ielts-reading-a-new-stage-in-the-study-and-teaching-of-history';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'mini-ielts-reading-a-new-stage-in-the-study-and-teaching-of-history';
DELETE FROM exams
WHERE "Slug" = 'mini-ielts-reading-a-new-stage-in-the-study-and-teaching-of-history';

DO $$
DECLARE
  exam_id uuid := gen_random_uuid();
  sec1 uuid := gen_random_uuid();
  qid uuid;
BEGIN

  INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","ImageUrl","UpdatedAt")
  VALUES (
    exam_id,
    'mini-ielts-reading-a-new-stage-in-the-study-and-teaching-of-history',
    'A new stage in the study and teaching of history',
    'IELTS Reading Practice Test from IELTS Mentor',
    'IELTS',
    'B2',
    'PUBLISHED',
    20,
    'https://res.cloudinary.com/grand-canyon-university/image/fetch/w_750,h_564,c_fill,g_faces,q_auto/https://www.gcu.edu/sites/default/files/media/images/Blog/gcu-experience/GettyImages-492915830.jpg',
    now()
  );

  INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","PassageMd")
  VALUES (
    sec1,
    exam_id,
    1,
    'Reading Passage - A new stage in the study and teaching of history',
    E'**Questions 1-9:**\nWhich section contains the following information?\n\nWrite the correct letter, **A-L**.\n\n---\n\n**Questions 10-14:**\nDo the following statements agree with the claims of the writer?\n\nWrite\n- **YES** if the statement agrees with the claims of the writer\n- **NO** if the statement contradicts the claims of the writer\n- **NOT GIVEN** if it is impossible to say what the writer thinks about this',
    E'**Paragraph A.**\\nFor hundreds of years, historians have relied on written or printed documents to provide the bulk of their source materials, and they have largely communicated with students and the wider public by writing books and journal articles. Today, however, the printed word is being superseded by a diversity of forms of communication, above all moving images on video or film\\n\\n**Paragraph B.**\\nThe development of this new form of communication is leading to a growing gap between the practice of professional historians based in academia, and the practice of those aiming to popularise the study of history among the general public, and to encourage people to create their own records for the future. On the one hand, there are mainstream academics who continue to use only the written word as they examine more and more fields with an ever- increasing number of sophisticated methodologies. On the other hand, film and video, especially as broadcast on television, are probably the major influence on the public''s consciousness of history, as they see film of events of fifty or a hundred years ago, events they had previously only read about.\\n\\n**Paragraph C.**\\nIn a related development, a great many people now document local and family events in the form of videos; many schools, too, produce video yearbooks. All these visual records may well prove to be invaluable sources of information for future historians. The glaring contradiction is that the two approaches-the academic and what we might term the popular - have intersected very little: with a few notable exceptions, professional historians have tended to avoid involvement in television programmes about history, and have even less impact on what is being captured and preserved on video. And the potential of moving images has wielded negligible influence on the academic study of history.\\n\\n**Paragraph D.**\\nThis gulf can be seen as resulting from the willingness or otherwise of individual historians to accept the validity of new forms of communication in the study of history. This is not the first time that the question has arisen. The study of history, as conceived of today, began with the transition from oral to literate culture, leading to the earliest written records and the earliest historical studies. The next great shift came with the advent of printing, which transformed everything. Today, as the printed word loses its dominance, historians are faced with a variety of forms of communication, ranging from simple audiotape to the promising complexities of videodiscs linked with computers. As yet, however, the use of moving images to record current events for the benefit of future historians does not even have a commonly agreed name.\\n\\n**Paragraph E.**\\nThis does not mean that mainstream historians have totally rejected the use of moving images as sources: the majority seem intrigued by the idea, and valuable research has been carried out into the history and analysis of films with a broad circulation, using them as a source of information on the social and intellectual history of the twentieth century. Journals such as American History Review have played a significant role in this field.\\n\\n**Paragraph F.**\\nYet the number of historians using moving images in their research or teaching is very small. The barrier seems to be that the profession is structured around the medium of the written word, and is somewhat insulated in its academic setting. The use of moving images presents a substantial challenge to this setting and its assumptions. As a result, historians have rejected the training, the institutions, the motivations and the professional structures that would be needed in order to use moving images effectively. Above all, they have rejected the necessity to learn complicated new skills.\\n\\n**Paragraph G.**\\nSo why should historians make this change? clearly, films or videos of events and people can be used as solid evidence of the past, linked to the words of the narrator (whether a television presenter/historian or a university teacher giving a lecture) but carrying information in their own right. Film has reintroduced the oral form as a mode of research and communication for documenting historical events. Now, with moving images, people are reminded that oral communication is not limited to words: it also includes body language, expression and tone, and is embedded in a context. Little of this is evident in a written transcript. A further effect of video and film is that the narrator gives up some control and has less need to give explanations, while the viewer becomes involved in the process of interpreting and understanding history.\\n\\n**Paragraph H.**\\nFilm or videotape can also aid historians by simplifying the work of the interviewer. Instead of trying to carry on an interview while simultaneously making notes about setting and other unspoken data, this new kind of historian can concentrate on the interview itself, and study the film later. The many benefits of using moving images as historical evidence easily outweigh worries about cost, technical skills, or the effect of a camera on a person telling his or her story. Moving images enhance the quality of historical research, and suggest new directions for historians to explore.\\n\\n'
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
    'an overview of the range of methods that have been used over time to document history',
    '',
    '{"info-q1": ["C", "c"]}'
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
    'the main reason why many historians are unwilling to use films in their work',
    '',
    '{"info-q2": ["E", "e"]}'
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
    'a reference to some differences between oral and written communication',
    '',
    '{"info-q3": ["F", "f"]}'
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
    'how most citizens today gain an understanding of history',
    '',
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
    'how current student events are sometimes captured for future audiences',
    '',
    '{"info-q5": ["B", "b"]}'
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
    'mention of the fact that the advantages of film are greater than the disadvantages',
    '',
    '{"info-q6": ["G", "g"]}'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    7,
    'MATCHING_INFORMATION',
    'READING',
    2,
    'the claim that there is no official title for film-based historical work',
    '',
    '{"info-q7": ["C", "c"]}'
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
    'reference to the active role the audience plays when watching films',
    '',
    '{"info-q8": ["F", "f"]}'
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
    'a list of requirements that historians see as obstacles to their use of film to recordhistory',
    '',
    '{"info-q9": ["E", "e"]}'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    10,
    'TRUE_FALSE_NOT_GIVEN',
    'READING',
    2,
    'YESNONOT GIVENThe needs of students in school have led to improvements in the teaching of history.',
    '',
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
    11,
    'YES_NO_NOT_GIVEN',
    'READING',
    2,
    'YESNONOT GIVENAcademic and popular historians have different attitudes towards the value of innovations in communication.',
    '',
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
    12,
    'YES_NO_NOT_GIVEN',
    'READING',
    2,
    'YESNONOT GIVENIt is common for historians to play a major role in creating historical documentaries for television.',
    '',
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
    13,
    'YES_NO_NOT_GIVEN',
    'READING',
    2,
    'YESNONOT GIVENArticles in American History Review have explored aspects of modern history through popular films.',
    '',
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
    14,
    'TRUE_FALSE_NOT_GIVEN',
    'READING',
    2,
    'YESNONOT GIVENDevelopments in technology are influencing a range of academic subjects.',
    '',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'TRUE', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'FALSE', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'NOT GIVEN', true);


END$$;


COMMIT;