-- ============================================
-- IELTS Exam Data Import SQL
-- Generated: 2025-12-24T07:42:32.702137
-- Source: mini-ielts.com
-- Title: Basement of museum
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data for slug: mini-ielts-listening-basement-of-museum
DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'mini-ielts-listening-basement-of-museum'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'mini-ielts-listening-basement-of-museum';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'mini-ielts-listening-basement-of-museum';
DELETE FROM exams
WHERE "Slug" = 'mini-ielts-listening-basement-of-museum';

DO $$
DECLARE
  exam_id uuid := gen_random_uuid();
  sec1 uuid := gen_random_uuid();
  qid uuid;
BEGIN

  INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","ImageUrl","UpdatedAt")
  VALUES (
    exam_id,
    'mini-ielts-listening-basement-of-museum',
    'Basement of museum',
    'IELTS Reading Practice Test from IELTS Mentor',
    'IELTS',
    'B2',
    'PUBLISHED',
    20,
    'https://res.cloudinary.com/df41zs8il/image/upload/v1766534842/ielts/Basement_of_museum_thumbpad_9fca2d618c74.jpg',
    now()
  );

  INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","PassageMd","AudioUrl")
  VALUES (
    sec1,
    exam_id,
    1,
    'Listening Test - Basement of museum',
    E'**Questions 1-10:**\nWhich section contains the following information?\n\nWrite the correct letter, **A-L**.',
    E'# Basement of Museum\n\n---\n\n## Questions 1-6\n\nWhat does the speaker say about each of the following collections?\n\nChoose **SIX** answers from the box and write the correct letter, **A-G**, next to Questions 1-6.\n\n### Comments:\n- **A** was given by one person\n- **B** was recently publicised in the media\n- **C** includes some items given by members of the public\n- **D** includes some items given by the artists\n- **E** includes the most popular exhibits in the museum\n- **F** is the largest of its kind in the country\n- **G** has had some of its contents relocated\n\n### Collections:\n- **1** 20th- and 21st-century paintings → _______\n- **2** 19th-century paintings → _______\n- **3** Sculptures → _______\n- **4** ''Around the world'' exhibition → _______\n- **5** Coins → _______\n- **6** Porcelain and glass → _______\n\n---\n\n## Questions 7-10\n\nLabel the plan below. Write the correct letter, **A-H**, next to Questions 7-10.\n\n### Basement of museum\n\n*(Map image unavailable from source)*\n\n**Locations on map:**\n- **A** → **B** → **C** → **D** → **E** → **F** → **G** → **H**\n\n- **7** restaurant → _______\n- **8** café → _______\n- **9** baby-changing facilities → _______\n- **10** cloakroom → _______\n'
  ,
    'https://www.youtube.com/embed/VP3-VPJzQoQ');

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    1,
    'MATCHING_INFORMATION',
    'LISTENING',
    2,
    '20th- and 21st-century paintings',
    '',
    '{"info-q1": ["E", "e"]}'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    2,
    'MATCHING_INFORMATION',
    'LISTENING',
    2,
    '19th-century paintings',
    '',
    '{"info-q2": ["D", "d"]}'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    3,
    'MATCHING_INFORMATION',
    'LISTENING',
    2,
    'Sculptures',
    '',
    '{"info-q3": ["G", "g"]}'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    4,
    'MATCHING_INFORMATION',
    'LISTENING',
    2,
    '''Around the world'' exhibition',
    '',
    '{"info-q4": ["B", "b"]}'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    5,
    'MATCHING_INFORMATION',
    'LISTENING',
    2,
    'Coins',
    '',
    '{"info-q5": ["C", "c"]}'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    6,
    'MATCHING_INFORMATION',
    'LISTENING',
    2,
    'Porcelain and glass',
    '',
    '{"info-q6": ["A", "a"]}'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    7,
    'MATCHING_INFORMATION',
    'LISTENING',
    2,
    'restaurant',
    '',
    '{"info-q7": ["F", "f"]}'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    8,
    'MATCHING_INFORMATION',
    'LISTENING',
    2,
    'café',
    '',
    '{"info-q8": ["H", "h"]}'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    9,
    'MATCHING_INFORMATION',
    'LISTENING',
    2,
    'baby-changing facilities',
    '',
    '{"info-q9": ["C", "c"]}'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    10,
    'MATCHING_INFORMATION',
    'LISTENING',
    2,
    'cloakroom',
    '',
    '{"info-q10": ["B", "b"]}'
  );


END$$;


COMMIT;