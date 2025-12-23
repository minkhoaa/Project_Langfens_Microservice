-- ============================================
-- IELTS Exam Data Import SQL
-- Generated: 2025-12-23T02:34:52.752798
-- Source: mini-ielts.com
-- Title: Australian parrots and their adaptation to habitat change
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data for slug: mini-ielts-reading-australian-parrots-and-their-adaptation-to-habitat-change
DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'mini-ielts-reading-australian-parrots-and-their-adaptation-to-habitat-change'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'mini-ielts-reading-australian-parrots-and-their-adaptation-to-habitat-change';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'mini-ielts-reading-australian-parrots-and-their-adaptation-to-habitat-change';
DELETE FROM exams
WHERE "Slug" = 'mini-ielts-reading-australian-parrots-and-their-adaptation-to-habitat-change';

DO $$
DECLARE
  exam_id uuid := gen_random_uuid();
  sec1 uuid := gen_random_uuid();
  qid uuid;
BEGIN

  INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","ImageUrl","UpdatedAt")
  VALUES (
    exam_id,
    'mini-ielts-reading-australian-parrots-and-their-adaptation-to-habitat-change',
    'Australian parrots and their adaptation to habitat change',
    'IELTS Reading Practice Test from IELTS Mentor',
    'IELTS',
    'B2',
    'PUBLISHED',
    20,
    'https://discovery.sndimg.com/content/dam/images/discovery/fullset/2021/10/5/GettyImages-CA23675.jpg.rend.hgtvcom.616.411.suffix/1633472913953.jpeg',
    now()
  );

  INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","PassageMd")
  VALUES (
    sec1,
    exam_id,
    1,
    'Reading Passage - Australian parrots and their adaptation to habitat change',
    E'**Questions 1-6:**\nWhich paragraph contains the following information?\n\nWrite the correct letter, **A-J**.\n\n---\n\n**Questions 7-9:**\nChoose the correct letter, **A**, **B**, **C** or **D**.\n\n---\n\n**Questions 10-13:**\nComplete the sentences below.\n\nWrite **NO MORE THAN TWO WORDS AND/OR A NUMBER** for each answer.',
    E'# Passage\n\n# Australian parrots and their adaptation to habitat change\n\n**Paragraph A.**\nParrots are found across the tropic and in all southern hemisphere continents except Antarctica, but nowhere do they display such a richness of diversity and form as in Australia. One-sixth of the world''s 345 parrot species are found there, and Australia has long been renowned for the number and variety of its parrots.\n\n**Paragraph B.**\nIn the 16th century, the German cartographer Mercator made a world map that included a place, somewhere near present-day Australia, that he named Terra Psittacorum – the Land of Parrots – and the first European settlers in Australia often referred to the country as Parrot Land. In 1865, the celebrated British naturalist and wildlife artist John Gould said: "No group of birds gives Australia so tropical and benign an air as the numerous species of this great family by which it is tenanted."\n\n**Paragraph C.**\nParrots are descendants of an ancient line. Due to their great diversity, and since most species inhabit Africa, Australia and South America, it seems almost certain that parrots originated millions of years ago on the ancient southern continent of Gondwana, before it broke up into the separate southern hemisphere continents we know today. Much of Gondwana comprised vast rainforests intersected by huge slow-flowing rivers and expansive lakes, but by eight million years ago, great changes were underway. The center of the continent of Australia had begun to dry out, and the rainforests that once covered it gradually contracted to the continental margins, where, to a limited extent, they still exist today.\n\n**Paragraph D.**\nThe creatures that remained in those shrinking rainforests had to adapt to the drier conditions or face extinction. Reacting to these desperate circumstances, the parrot family, typically found in jungles in other parts of the world, has populated some of Australia''s harshest environments. The parrots spread from ancestral forests through eucalypt woodlands to colonise the central deserts of Australia, and as a consequence they diversified into a wide range of species with adaptations that reflect the many changes animals and plants had to make to survive in these areas.\n\n**Paragraph E.**\nThese evolutionary pressures helped mould keratin, the substance from which beaks are made, into a range of tools capable of gathering the new food types favored by various species of parrot. The size of a parrot''s short, blunt beak and the length of that beak''s curved upper part are related to the type of food each species eats. Some have comparatively long beaks that are perfect for extracting seeds from fruit; others have broader and stronger beaks that are designed for cracking hard seeds.\n\n**Paragraph F.**\nDifferently shaped beaks are not the only adaptations that have been made during the developing relationship between parrots and their food plants. Like all of Australia''s many honey-eating birds, the rainbow-coloured lorikeets and the flowers on which they feed have long co-evolved with features such as the shape and colour of the flowers adapted to the bird''s particular needs. For example, red is the most attractive colour to birds, and thus flowers which depend on birds for pollination are more often red, and lorikeets'' tongues have bristles which help them to collect as much pollen as possible.\n\n**Paragraph G.**\nToday, most of Australia''s parrots inhabit woodland and open forest, and their numbers decline towards both deserts and wetter areas. The majority are nomadic to some degree, moving around to take advantage of feeding and breeding places. Two of the dry country parrots, the pink and grey galah and the pink, white and yellow corella have expanded their ranges in recent years. They are among the species that have adapted well to the changes brought about by European settlement – forest felling created grasslands where galahs and corellas thrive.\n\n**Paragraph H.**\nBut other parrot species did not fare so well when their environments were altered. The clearing of large areas of rainforest is probably responsible for the disappearance of the double-eyed fig parrot, and numbers of ground parrots declined when a great part of their habitat was destroyed by the draining of coastal swamps. Even some parrot species that benefited from forest clearing at first are now confronted by a shortage of nesting sites due to further man-made changes.\n\n**Paragraph I.**\nNew conditions also sometimes favour an incoming species over one that originally inhabited the area. For example, after farmers cleared large areas of forest on Kangaroo Island off the coast of South Australia, the island was colonised by galahs. They were soon going down holes and destroying black cockatoo eggs in order to take the hole for their own use. Their success precipitated a partial collapse in the black cockatoo population when the latter lost the struggle for scarce nesting hollows.\n\n**Paragraph J.**\nThere may be no final answer to ensuring an equitable balance between parrot species. Nest box programmes help ease the shortage of nesting sites in some places, but there are not enough, they are expensive and they are not an adequate substitute for large, old trees, such as the habitat they represent and nectar, pollen and seeds they provide. Competition between parrots for nest sites is a result of the changes we humans have made to the Earth. We are the most widespread and dangerous competitors that parrots have ever had to face, but we also have the knowledge and skill to maintain the wonderfully rich diversity of Australia''s parrots. All we need is the will to do so.'
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
    'An example of how one parrot species may survive at the expense of another',
    '',
    '{"info-q1": ["D", "d"]}'
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
    'A description of how plants may adapt to attract birds',
    '',
    '{"info-q2": ["G", "g"]}'
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
    'Example of two parrot species which benefited from changes to the environment',
    '',
    '{"info-q3": ["C", "c"]}'
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
    'How the varied Australian landscape resulted in a great variety of parrot species',
    '',
    '{"info-q4": ["H", "h"]}'
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
    'A reason why most parrot species are native to the southern hemisphere',
    '',
    '{"info-q5": ["E", "e"]}'
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
    'An example of a parrot species which did not survive changes to its habitat',
    '',
    '{"info-q6": ["F", "f"]}'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    7,
    'MULTIPLE_CHOICE_SINGLE',
    'READING',
    2,
    'The writer believes that most parrot species',
    '',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. Move from Africa and South America to Australia', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. Had ancestors in either Africa, Australia or South America', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. Had ancestors in a continent which later split up', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D. Came from a continent now covered by water', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    8,
    'MULTIPLE_CHOICE_SINGLE',
    'READING',
    2,
    'What does the Writer say about parrot''s beak?',
    '',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. They are longer than those of other birds', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. They are made of a unique material', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. They are used more efficiently than those of other species', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D. They are specially adapted to suit the diet', true);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    9,
    'MULTIPLE_CHOICE_SINGLE',
    'READING',
    2,
    'Which of the following is NOT mentioned by the writer as a disadvantage of nesting boxes?',
    '',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. They cost too much', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. They need to be maintained', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. They provide only shelter, not food', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D. They are too few of them', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    10,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    'There are 345 varieties of parrot in existence and, of these, _______ live in Australia.',
    '',
    '{"blank-q10": ["one-sixth"]}'::jsonb
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
    'As early as the _______, the mapmaker recognized that parrots lived in that part of the world.',
    '',
    '{"blank-q11": ["16th century"]}'::jsonb
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
    'As early as the _______, the mapmaker _______ recognized that parrots lived in that part of the world.',
    '',
    '{"blank-q12": ["Mercator"]}'::jsonb
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
    '_______, the famous painter of animals and birds, commented on the size and beauty of the Australian parrot family.',
    '',
    '{"blank-q13": ["John Gould"]}'::jsonb
  );


END$$;


COMMIT;