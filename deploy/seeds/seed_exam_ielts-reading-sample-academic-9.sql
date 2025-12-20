-- ============================================
-- IELTS Exam Data Import SQL
-- Generated: 2025-12-20T12:04:30.401085
-- Source: ielts-writing.info
-- Title: IELTS Reading Sample (Academic) #9
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data for slug: ielts-reading-ielts-reading-sample-academic-9
DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-ielts-reading-sample-academic-9'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-ielts-reading-sample-academic-9';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-ielts-reading-sample-academic-9';
DELETE FROM exams
WHERE "Slug" = 'ielts-reading-ielts-reading-sample-academic-9';

DO $$
DECLARE
  exam_id uuid := gen_random_uuid();
  sec1 uuid := gen_random_uuid();
  qid uuid;
BEGIN

  INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","UpdatedAt")
  VALUES (
    exam_id,
    'ielts-reading-ielts-reading-sample-academic-9',
    'IELTS Reading Sample (Academic) #9',
    'IELTS Reading Practice Test: IELTS Reading Sample (Academic) #9',
    'IELTS',
    'B2',
    'PUBLISHED',
    20,
    now()
  );

  INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd")
  VALUES (
    sec1,
    exam_id,
    1,
    'Reading Passage - IELTS Reading Sample (Academic) #9',
    E'# Passage\n\nAcademic Reading Passage 27\nThe Truth About ART\nModern art has had something of a bad press recently - or, to be more precise, it has always had a bad press in certain newspapers and amongst certain sectors of the public. In the public mind, it seems, art (that is, graphic art - pictures - and spatial art - sculpture) is divided into two broad categories. The first is ''classic'' art, by which is meant representational painting, drawing and sculpture; the second is ''modern'' art, also known as abstract or non-representational. British popular taste runs decidedly in favour of the former, if one believes a recent survey conducted by Charlie Moore, owner of the Loft Gallery and Workshops in Kent, and one of Britain''s most influential artistic commentators. He found that the man (or woman) in the street has a distrust of cubism, abstracts, sculptures made of bricks and all types of so-called ''found'' art, He likes Turner and Constable, the great representatives of British watercolour and oil painting respectively, or the French Impressionists, and his taste for statues is limited to the realistic figures of the great and good that litter the British landscape - Robin Hood in Nottingham and Oliver Cromwell outside the Houses of Parliament. This everyman does not believe in primary colours, abstraction and geometry in nature - the most common comment is that such-and-such a painting is "something a child could have done".\nLewis Williams, director of the Beaconsfield Galleries in Hampshire, which specialises in modern painting, agrees. "Look around you at what art is available every day," he says. "Our great museums and galleries specialise in work which is designed to appeal to the lowest common denominator. It may be representational, it may be ''realistic'' in one sense, but a lot of it wouldn''t make it into the great European galleries. Britain has had maybe two or three major world painters in the last 1000 years, so we make up the space with a lot of second-rate material."\nWilliams believes that our ignorance of what modern art is has been caused by this lack of exposure to truly great art. He compares the experience of the average British city-dweller with that of a citizen of Italy, France or Spain.\n"Of course, we don''t appreciate any kind of art in the same way because of the paucity of good art in Britain. We don''t have galleries of the quality of those in Madrid, Paris, Versailles, Florence, New York or even some places in Russia. We distrust good art - by which I mean both modern and traditional artistic forms - because we don''t have enough of it to learn about it. In other countries, people are surrounded by it from birth. Indeed they take it as a birthright, and are proud of it. The British tend to be suspicious of it. It''s not valued here."\nNot everyone agrees. Emily Cope, who runs the Osborne Art House, believes that while the British do not have the same history of artistic experience as many European countries, their senses are as finely attuned to art as anyone else''s.\n"Look at what sells - in the great art auction houses, in greetings cards, in posters. Look at what''s going on in local amateur art classes up and down the country. Of course, the British are not the same as other countries, but that''s true of all nationalities. The French artistic experience and outlook is not the same as the Italian. In Britain, we have artistic influences from all over the world. There''s the Irish, Welsh, and Scottish influences, as well as Caribbean, African and European. We also have strong links with the Far East, in particular the Indian subcontinent. All these influences come to bear in creating a British artistic outlook. There''s this tendency to say that British people only want garish pictures of clowns crying or ships sailing into battle, and that anything new or different is misunderstood. That''s not my experience at all. The British public is poorly educated in art, but that''s not the same as being uninterested in it."\nCope points to Britain''s long tradition of visionary artists such as William Blake, the London engraver and poet who died in 1827. Artists like Blake tended to be one-offs rather than members of a school, and their work is diverse and often word-based so it is difficult to export.\nPerhaps, as ever, the truth is somewhere in between these two opinions. It is true that visits to traditional galleries like the National and the National Portrait Gallery outnumber attendance at more modern shows, but this is the case in every country except Spain, perhaps because of the influence of the two most famous non-traditional Spanish painters of the 20th century, Picasso and Dali. However, what is also true is that Britain has produced a long line of individual artists with unique, almost unclassifiable styles such as Blake, Samuel Palmer and Henry Moore.\n\n.'
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
    'British people don''t appreciate art because they don''t see enough art around them all the time.',
    'Choose the correct answer.',
    '{"info-q1": ["B", "b"]}'
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
    'British museums aim to appeal to popular tastes in art.',
    'Choose the correct answer.',
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
    'The average Englishman likes the works of Turner and Constable.',
    'Choose the correct answer.',
    '{"info-q3": ["A", "a"]}'
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
    'Britain, like every other country, has its own view of what art is.',
    'Choose the correct answer.',
    '{"info-q4": ["C", "c"]}'
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
    'In Britain, interest in art is mainly limited to traditional forms such as representational painting.',
    'Choose the correct answer.',
    '{"info-q5": ["A", "a"]}'
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
    'British art has always been affected by other cultures.',
    'Choose the correct answer.',
    '{"info-q6": ["C", "c"]}'
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
    'Galleries in other countries are of better quality that those in Britain.',
    'Choose the correct answer.',
    '{"info-q7": ["B", "b"]}'
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
    'People are not raised to appreciate art.',
    'Choose the correct answer.',
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
    'The British have a limited knowledge of art.',
    'Choose the correct answer.',
    '{"info-q9": ["C", "c"]}'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    10,
    'MULTIPLE_CHOICE_SINGLE',
    'READING',
    2,
    'Many British artists',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'Aare engravers or poets.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'Bare great but liked only in Britain.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'Cdo not belong to a school or general trend.', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'Dare influenced by Picasso and Dali.', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    11,
    'MULTIPLE_CHOICE_SINGLE',
    'READING',
    2,
    '''Classic'' art can be described as',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'Asentimental, realistic paintings with geometric shapes.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'Brealistic paintings with primary colours.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'Cabstract modern paintings and sculptures.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'Drealistic, representational pictures and sculptures.', true);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    12,
    'MULTIPLE_CHOICE_SINGLE',
    'READING',
    2,
    'In Spain, people probably enjoy modern art because',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'Atheir artists have a classifiable style.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'Bthe most renowned modern artists are Spanish.', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'Cthey attend many modern exhibitions.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'Dthey have different opinions on art.', false);


END$$;


COMMIT;