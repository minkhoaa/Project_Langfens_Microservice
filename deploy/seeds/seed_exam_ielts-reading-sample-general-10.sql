-- ============================================
-- IELTS Exam Data Import SQL
-- Generated: 2025-12-20T12:03:08.100076
-- Source: ielts-writing.info
-- Title: IELTS Reading Sample (General) #10
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data for slug: ielts-reading-ielts-reading-sample-general-10
DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-ielts-reading-sample-general-10'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-ielts-reading-sample-general-10';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-ielts-reading-sample-general-10';
DELETE FROM exams
WHERE "Slug" = 'ielts-reading-ielts-reading-sample-general-10';

DO $$
DECLARE
  exam_id uuid := gen_random_uuid();
  sec1 uuid := gen_random_uuid();
  qid uuid;
BEGIN

  INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","UpdatedAt")
  VALUES (
    exam_id,
    'ielts-reading-ielts-reading-sample-general-10',
    'IELTS Reading Sample (General) #10',
    'IELTS Reading Practice Test: IELTS Reading Sample (General) #10',
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
    'Reading Passage - IELTS Reading Sample (General) #10',
    E'# Passage\n\nIELTS Reading General 20\nA.\nPopular interest in Mars, the ‘Red Planet’, is long-established, but has enjoyed two dramatic flowerings, one in the 1890s and the other a century later.\nB.\nAny speculation about life on Mars, then or now, is part of a long discussion on ‘the plurality of worlds’. Pluralists believe that there are other worlds apart from ours which contain life — an idea that had its origins in classical Greece. In the 19th century, the new science of astrophysics suggested that large numbers of stars in the sky were similar to the sun in their composition — perhaps they too were circled by planetary systems. Nearer to home Mars, our neighbour in the solar system, seemed to offer the evidence the pluralists had lacked until then.\nC.\nThe characteristics of Mars’ orbit are such that its distance from Earth varies considerably — from 34.5 to 234.5 million miles. From an astronomer’s standpoint it was particularly well-placed for observation in 1877, 1892 and 1909. Observations in each of these years intensified discussion about possible life on Mars.\nD.\nIf life, intelligent or otherwise, were to be found on Mars then life on Earth would not be unique. The scientific, theological and cultural outcomes of such a discovery could be stupendous. In 1859, Fr. Angelo Secchi, director of the Vatican observatory and a confirmed pluralist, observed markings on the surface of Mars which he described as\ncanali\n, ‘channels’. The fateful word had been launched on its career, although there was little immediate development from Secchi’s work.\nE.\nIn 1877 another Italian, Giovanni Schiaparelli, one of Europe’s most distinguished astronomers, also observed the\ncanali\n, but he added the refinement that they appeared to be constituents of a system. Other astronomers observed features that might he continents or seas; Schiaparelli confirmed these findings and gave them finely sonorous classical names such as Hellas, Mare Etythraeum, Promethei Sinus.\nF.\nAlthough Schiaparelli was cautious in his public statements, recent research suggests that he was a pluralist. Certainly his choice of familiar place names for the planet, and his publicising of the calla network, encouraged pluralist speculation. Inevitably, cumuli was soon being translated into English as ‘canals’ rather than ‘channels’. In 1882 Schiaparelli further fuelled speculation by discovering twin canals; a configuration which he named ‘gemination’; he described no fewer than sixty canals and twenty geminations.\nG.\nSome of Schiaparellrs findings were confirmed by the astronomers Perrotin and Thollon at Nice Observatory in 1886. In 1888, however, Perrotin confused matters by announcing that the Martian continent of ‘Libya’ observed by Schiaparelli in 1886 ‘no longer exists today’. The confusion grew; two prestigious observatories in the US found in one case no canals, in another a few of them but no geminations, and no changes to Libya.\nH.\nWhile the observers exchanged reports and papers, the popularisers got to work. They were generally restrained at first. The British commentator Richard Proctor thought that the canals might be rivers; he was among the first to suggest that a Martian canal would have to be ‘fifteen or twenty miles broad’ to be seen from Earth. The leading French pluralist, Camille Flammarion, published his definitive\nLa Planete Mars\nin 1892: ‘the canals may be due ... to the rectification of old rivers by the inhabitants for the purpose of the general distribution of water ...’. Other commentators supposed the ‘canals’ might be an optical illusion, a line first advanced by the English artist Nathaniel Green, teacher of painting to Queen Victoria and an amateur astronomer.\nI.\nThe canals debate might have levelled off at this point had it not been for the incursion of its most prominent controversialist — and convinced pluralist — Percival Lowell. Lowell, an eminent Bostonian, entered the astronomical argument after a career in business and diplomacy, mainly in the Orient. He may not have brought an entirely objective mind to the task. Even before he started observing he had announced that the canals were probably ‘the work of some sort of intelligent beings’.\nJ.\nThe newly-arrived popular press was very willing to report Lowell’s findings and views; canal mania grew apace. By 1910 Lowell had reported over 400 canals with.an average length of 1,500 miles. He wrote plausibly about the Martian atmosphere and the means by which the canals distributed water from Mars polar caps to irrigate the planet before evaporation returned moisture to the poles. This water cycle appealed to popular evolutionism which perceived Mars as an old, dying world trying to avert its fate by rational and large-scale engineering — this was, after all, an age of great canals: Panama, Dortmund-Ems, Manchester, Corinth.\nSource:\nHistory Today\n, July, 1998\n\n.'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    1,
    'MULTIPLE_CHOICE_SINGLE',
    'READING',
    2,
    'What do pluralists believe?',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. There is life in other parts of the universe.', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. Other stars have planets.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. There is life on Mars.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D. There are many other stars like the sun.', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    2,
    'MULTIPLE_CHOICE_SINGLE',
    'READING',
    2,
    'What circumstance helped astronomers to study Mars in the late 19th century?',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. A new science had developed.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. People believed that there was life on other planets.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. Mars was close to Earth on several occasions.', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D. There was popular interest in Mars at the time.', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    3,
    'MATCHING_INFORMATION',
    'READING',
    2,
    'Schiapareili',
    'Choose the correct answer.',
    '{"info-q3": ["D", "d"]}'
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
    'Perrotin',
    'Choose the correct answer.',
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
    'Proctor',
    'Choose the correct answer.',
    '{"info-q5": ["I", "i"]}'
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
    'Flammarion',
    'Choose the correct answer.',
    '{"info-q6": ["H", "h"]}'
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
    'Green',
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
    'Lowell',
    'Choose the correct answer.',
    '{"info-q8": ["E", "e"]}'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    9,
    'YES_NO_NOT_GIVEN',
    'READING',
    2,
    'Discussion about whether there is life on Mars forms part of a long tradition.',
    'Choose the correct answer.',
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
    10,
    'YES_NO_NOT_GIVEN',
    'READING',
    2,
    'The belief that life existed on Mars was encouraged by a translation error.',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'YES', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'NO', false);
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
    'The limitations of 19th century technology encouraged the idea that there were canals on Mars.',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'YES', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'NO', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'NOT GIVEN', true);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    12,
    'YES_NO_NOT_GIVEN',
    'READING',
    2,
    'All Lowell''s statements about Mars were based on what he was able to see.',
    'Choose the correct answer.',
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
    'Lowell''s investigations of Mars aroused little interest outside the scientific community.',
    'Choose the correct answer.',
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
    14,
    'YES_NO_NOT_GIVEN',
    'READING',
    2,
    'Lowell''s theory about how canals on Mars were used may have been inspired by fashionable ideas of the time.',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'YES', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'NO', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'NOT GIVEN', false);


END$$;


COMMIT;