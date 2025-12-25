-- ============================================
-- IELTS Exam Data Import SQL
-- Generated: 2025-12-25T00:06:52.468460
-- Source: mini-ielts.com
-- Title: Crows Can be Craftsmen too
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data for slug: mini-ielts-reading-crows-can-be-craftsmen-too
DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'mini-ielts-reading-crows-can-be-craftsmen-too'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'mini-ielts-reading-crows-can-be-craftsmen-too';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'mini-ielts-reading-crows-can-be-craftsmen-too';
DELETE FROM exams
WHERE "Slug" = 'mini-ielts-reading-crows-can-be-craftsmen-too';

DO $$
DECLARE
  exam_id uuid := gen_random_uuid();
  sec1 uuid := gen_random_uuid();
  qid uuid;
BEGIN

  INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","ImageUrl","UpdatedAt")
  VALUES (
    exam_id,
    'mini-ielts-reading-crows-can-be-craftsmen-too',
    'Crows Can be Craftsmen too',
    'IELTS Reading Practice Test from IELTS Mentor',
    'IELTS',
    'B2',
    'PUBLISHED',
    20,
    'https://res.cloudinary.com/df41zs8il/image/upload/v1766596004/ielts/crows-can-be-craftsmen-too_thu_097360a774ab.jpg',
    now()
  );

  INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","PassageMd")
  VALUES (
    sec1,
    exam_id,
    1,
    'Reading Passage - Crows Can be Craftsmen too',
    E'**Questions 1-4:**\nComplete the diagrams.\nChoose **NO MORE THAN TWO WORDS** from the passage for each answer.\n\n---\n\n**Questions 5-9:**\nClassify the following statements as referring to the crow(s) in:\n- **A** the study by Hunt and Gray\n- **B** the study by Kacelnik, Chappell and Weir\n- **C** both studies\n\nWrite the correct letter, **A, B or C.**\n\n---\n\n**Questions 10-13:**\nComplete the summary.\nChoose **NO MORE THAN TWO WORDS** from the passage for each answer.',
    E'**Paragraph A.**\\nA remarkable colony of inventors has emerged on an isolated Pacific island.They can fashion tools out of materials scavenged from the rainforest. They can even customise a tool for a given job. Meet the crows of New Caledonia.\\n\\n**Paragraph B.**\\nThinkers as diverse as Freud, Engels and Thomas Carlyle once pointed to the use of tools as being a defining behaviour of human beings. Then it was found that many animals also used them, from the’fishing sticks’of apes to the rocks dropped on ostrich eggs by Egyptian vultures. Crows are particularly crafty. Earlier studies showed that they are almost human-like in their use of tools, with technological features that match the stone and bone tool cultures that emerged among primitive humans between 2.5 million and 70,000 BC.\\n\\n**Paragraph C.**\\nBut only humans were thought to have the brain power required for cumulative technological evolution. This is the skill for innovation that took our ancestors two million years ago from creating flakes of flint, for use in cutting, to honing knives, blades, arrowheads and axeheads.\\n\\n**Paragraph D.**\\nNow this ‘unique’ attribute of humans has also turned out to be a flattering delusion. A new study shows that the crows of New Caledonia are inventive. With their evolving leaf tools, the birds have levered man off his pedestal.\\n\\n**Paragraph E.**\\nDr Gavin Hunt and Dr Russell Gray of the University of Auckland have spent the past decade studying feathered technology in New Caledonia, 900 miles north-east of Australia. After an intensive field survey of local crow industry, the scientists found that the birds rip the leaves of the pandanus tree to fashion three distinct types of tool for grub and insect extraction: wide, narrow and tapered.\\n\\n**Paragraph F.**\\nLong ago, the birds discovered that they could rip the serrated edge off the leaves to make a wide tool. The skill spread and the crows honed tools with finer working tips, by either narrowing tools or tapering them. (Because the leaves are reinforced by tough parallel fibres, the tapered design is made in steps. The crow nips the leaf, rips along the fibres, makes another cut and tears again, repeating until it has a tool with usually two, three or four steps.)\\n\\n**Paragraph G.**\\nLeaf tool manufacture is an example of culture: the birds leam through example and their tool-making wisdom grows in sophistication down the generations. The crows appear to have the cognitive requirements for cumulative, though rudimentary, technological evolution, said Dr Gray. Tool manufacture in New Caledonian crows shows striking flexibility and innovation.’ The ability of the birds to innovate is further shown by their making of other tools. They often strip a twig of leaves and cut it off just below a shortened offshoot to create a hook to get bugs out. They also use simpler tools to extract grubs from the dead wood of trees.\\n\\n**Paragraph H.**\\nProf Alex Kacelnik, fellow of Pembroke College, Oxford, praised the study as’extremely important’. It complements his own research, with Dr Jackie Chappell and Alex Weir, which has turned Betty the New Caledonian crow into a star by revealing her to be the first animal, other than man, to show a basic understanding of cause and effect.\\n\\n**Paragraph I.**\\nBetty began making tools after her partner snatched away a hook made for her by the researchers, forcing her to make her own from garden wire to fish out morsels from a tube. She wedged the end of the wire into the base of the food tube and turned her head to form the hook. What amazed the researchers is that she can even adapt her hooks if they are not up to the job, something that even chimpanzees are unable to do. Although chimps use sticks in experiments, they have not shown any human-like understanding of basic physical laws.’When she starts bending the wire it is as if she has a clear objective, even correcting the angle of the hook if it is not right,’ said Prof Kacelnik.’Although many animals use tools, purposeful modification of objects to solve new problems, without training or prior experience, is virtually unknown.’\\n\\n**Paragraph J.**\\n‘While we have been emphasising the individual ability of animals like Betty to solve problems, the New Zealand team has been emphasising tool manufacture, the cultural traditions and transmission of information in the wild,’ said Prof Kacelnik. Both strands of research are related by how the crows are not genetically programmed to use a tool, like a spider and his web. Instead, the birds creatively invent new kinds of tools to solve problems and can share skills with others.\\n\\n**Paragraph K.**\\nThe crow family are the Einsteins of the avian world, though Prof Kacelnik added that, at least in terms of tool making, the Pacific crows are smarter than their British cousins. We have not yet identified what it is that makes these crows so special, though it is something to do with ecological circumstances,’said Prof Kacelnik.\\n\\n**Paragraph L.**\\nOnce scientists have got to the bottom of what makes Pacific crows master toolmakers, they may have to think again about how this skill evolved in humans.\\n\\n\n---\n\n## Diagram/Image for Questions 1-4\n\n![Questions 1-4](https://res.cloudinary.com/df41zs8il/image/upload/v1766596011/ielts/a_0f8f84b00a95.jpg)\n'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    1,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    'Label 1 on diagram: _______',
    '',
    '{"blank-q1": ["RIPS"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    2,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    'Label 2 on diagram: _______',
    '',
    '{"blank-q2": ["PANDANUS"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    3,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    'Label 3 on diagram: _______',
    '',
    '{"blank-q3": ["WIDE"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    4,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    'Label 4 on diagram: _______',
    '',
    '{"blank-q4": ["TAPERED"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    5,
    'MULTIPLE_CHOICE_SINGLE',
    'READING',
    2,
    'can share tool-making skills with other crows',
    '',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. the study by Hunt and Gray', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. the study by Kacelnik, Chappell and Weir', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. both studies', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    6,
    'MULTIPLE_CHOICE_SINGLE',
    'READING',
    2,
    'can make special tools for a particular purpose',
    '',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. the study by Hunt and Gray', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. the study by Kacelnik, Chappell and Weir', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. both studies', true);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    7,
    'MULTIPLE_CHOICE_SINGLE',
    'READING',
    2,
    'can solve problems by understanding rather than learning',
    '',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. the study by Hunt and Gray', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. the study by Kacelnik, Chappell and Weir', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. both studies', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    8,
    'MULTIPLE_CHOICE_SINGLE',
    'READING',
    2,
    'can make tools better than British crows can',
    '',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. the study by Hunt and Gray', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. the study by Kacelnik, Chappell and Weir', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. both studies', true);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    9,
    'MULTIPLE_CHOICE_SINGLE',
    'READING',
    2,
    'can manufacture hooks to extract food',
    '',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. the study by Hunt and Gray', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. the study by Kacelnik, Chappell and Weir', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. both studies', true);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    10,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    'It used to be thought that only human beings used tools. Even after we learned that many other **10** _______ also do so, it was still believed that only humans were intelligent enough to gradually evolve better tools.',
    '',
    '{"blank-q10": ["ANIMALS"]}'::jsonb
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
    'A study of crows in **11** _______, however, shows that these birds use a leaf tool which has been evolved over several generations.',
    '',
    '{"blank-q11": ["NEW CALEDONIA"]}'::jsonb
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
    'A crow in another study has shown the human-like ability to understand **12** _______ in order to manufacture tools, which not even **13** _______ can do.',
    '',
    '{"blank-q12": ["PHYSICAL LAWS"]}'::jsonb
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
    'A crow in another study has shown the human-like ability to understand **12** _______ in order to manufacture tools, which not even **13** _______ can do.',
    '',
    '{"blank-q13": ["CHIMPANZEES", "CHIMPS"]}'::jsonb
  );



  -- Delete old question groups for this exam
  DELETE FROM exam_question_groups WHERE "SectionId" = sec1;

  -- Insert question groups
  INSERT INTO exam_question_groups ("Id","SectionId","Idx","StartIdx","EndIdx","InstructionMd")
  VALUES (gen_random_uuid(), sec1, 1, 1, 4, E'## Questions 1-4\n\nComplete the diagrams.\n\nChoose **NO MORE THAN TWO WORDS** from the passage for each answer.\n\n![Diagram](https://res.cloudinary.com/df41zs8il/image/upload/v1766596011/ielts/a_0f8f84b00a95.jpg)\n\n**1** _______  \n**2** _______  \n**3** _______  \n**4** _______');

  INSERT INTO exam_question_groups ("Id","SectionId","Idx","StartIdx","EndIdx","InstructionMd")
  VALUES (gen_random_uuid(), sec1, 2, 5, 9, E'## Questions 5-9\n\nClassify the following statements as referring to the crow(s) in:\n\n- **A** the study by Hunt and Gray\n- **B** the study by Kacelnik, Chappell and Weir\n- **C** both studies\n\nWrite the correct letter, **A, B or C.**\n\n**5** can share tool-making skills with other crows  \n**6** can make special tools for a particular purpose  \n**7** can solve problems by understanding rather than learning  \n**8** can make tools better than British crows can  \n**9** can manufacture hooks to extract food');

  INSERT INTO exam_question_groups ("Id","SectionId","Idx","StartIdx","EndIdx","InstructionMd")
  VALUES (gen_random_uuid(), sec1, 3, 10, 13, E'## Questions 10-13\n\nComplete the summary.\n\nChoose **NO MORE THAN TWO WORDS** from the passage for each answer.\n\nIt used to be thought that only human beings used tools. Even after we learned that many other **10** _______ also do so, it was still believed that only humans were intelligent enough to gradually evolve better tools. A study of crows in **11** _______, however, shows that these birds use a leaf tool which has been evolved over several generations. A crow in another study has shown the human-like ability to understand **12** _______ in order to manufacture tools, which not even **13** _______ can do.');

END$$;


COMMIT;