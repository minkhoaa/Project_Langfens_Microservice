-- ============================================
-- IELTS Exam Data Import SQL
-- Generated: 2025-12-24T13:45:02.341143
-- Source: mini-ielts.com
-- Title: The dingo debate
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data for slug: mini-ielts-reading-the-dingo-debate
DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'mini-ielts-reading-the-dingo-debate'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'mini-ielts-reading-the-dingo-debate';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'mini-ielts-reading-the-dingo-debate';
DELETE FROM exams
WHERE "Slug" = 'mini-ielts-reading-the-dingo-debate';

DO $$
DECLARE
  exam_id uuid := gen_random_uuid();
  sec1 uuid := gen_random_uuid();
  qid uuid;
BEGIN

  INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","ImageUrl","UpdatedAt")
  VALUES (
    exam_id,
    'mini-ielts-reading-the-dingo-debate',
    'The dingo debate',
    'IELTS Reading Practice Test from IELTS Mentor',
    'IELTS',
    'B2',
    'PUBLISHED',
    20,
    'https://upload.wikimedia.org/wikipedia/commons/6/66/Dingo_on_the_road.jpg',
    now()
  );

  INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","PassageMd")
  VALUES (
    sec1,
    exam_id,
    1,
    'Reading Passage - The dingo debate',
    E'**Questions 1-10:**\nWhich section contains the following information?\n\nWrite the correct letter, **A-L**.\n\n---\n\n**Questions 11-13:**\nComplete the sentences below.\n\nWrite **NO MORE THAN TWO WORDS AND/OR A NUMBER** for each answer.',
    E'**Paragraph A.**\\nGraziers see them as pests, and poisoning is common, but some biologists think Australia’s dingoes are the best weapon in a war against imported cats and foxes.\\n\\n**Paragraph B.**\\n**Paragraph A.**\nA plane flies a slow pattern over Carlton Hill station, a 3,600 square kilometre ranch in the Kimberley region in northwest Australia. As the plane circles, those aboard drop 1,000 small pieces of meat, one by one, onto the scrubland below, each piece laced with poison; this practice is known as baiting.\\n\\n**Paragraph C.**\\nBesides 50,000 head of cattle, Carlton Hill is home to the dingo, Australia’s largest mammalian predator and the bane of a grazier''s (cattle farmer''s) life. Stuart McKechnie, manager of Carlton Hill, complains that graziers’ livelihoods are threatened when dingoes prey on cattle. But one man wants the baiting to end, and for dingoes to once again roam Australia’s wide-open spaces. According to Chris Johnson of James Cook University, ‘Australia needs more dingoes to protect our biodiversity.’\\n\\n**Paragraph D.**\\n**Paragraph B.**\nAbout 4,000 years ago, Asian sailors introduced dingoes to Australia. Throughout the ensuing millennia, these descendants of the wolf spread across the continent and, as the Tasmanian tiger disappeared completely from Australia, dingoes became Australia’s top predators. As agricultural development took place, the European settlers found that they could not safely keep their livestock where dingoes roamed. So began one of the most sustained efforts at pest control in Australia’s history. Over the last 150 years, dingoes have been shot and poisoned, and fences have been used in an attempt to keep them away from livestock. But at the same time, as the European settlers tried to eliminate one native pest from Australia, they introduced more of their own.\\n\\n**Paragraph E.**\\n**Paragraph C.**\nIn 1860, the rabbit was unleashed on Australia by a wealthy landowner and by 1980 rabbits had covered most of the mainland. Rabbits provide huge prey base for two other introduced species: the feral (wild) cat and the red fox.\\n\\n**Paragraph F.**\\nThe Interaction between foxes, cats and rabbits is a huge problem for native mammals. In good years, rabbit numbers increase dramatically, and fox and cat populations grow quickly in response to the abundance of this prey. When bad seasons follow, rabbit numbers are significantly reduced - and the dwindling but still large fox and cat populations are left with little to eat besides native mammals.\\n\\n**Paragraph G.**\\n**Paragraph D.**\nAustralian mammals generally reproduce much more slowly than rabbits, cats and foxes - and adaption to prevent overpopulation in the arid environment, where food can be scarce and unreliable - and populations decline because they can’t grow fast enough to replace animals killed by the predators. Johnson says dingoes are the solution to this problem because they keep cat and fox populations under control. Besides regularly eating the smaller predators, dingoes will kill them simply to lessen competition.\\n\\n**Paragraph H.**\\nDingo packs live in large, stable territories and generally have only one fertile, which limits their rate of increase. In the 4,000 years that dingoes have been Australia, they have contributed to few, if any, extinctions, Johnsons says.\\n\\n**Paragraph I.**\\n**Paragraph E.**\nReaching out from a desolate spot where three states meet, for 2,500 km in either direction, is the world’s longest fence, two metres high and stretching from the coast in Queensland to the Great Australian Bight in South Australia; it is there to keep dingoes out of southeast, the fence separates the main types of livestock found in Australia. To the northwest of the fence, cattle predominate; to the southwest, sheep fill the landscape. In fact, Australia is a land dominated by these animals - 25 million cattle, 100 million sheep and just over 20 million people.\\n\\n**Paragraph J.**\\n**Paragraph F.**\nWhile there is no argument that dingoes will prey on sheep if given the chance, they don’t hunt cattle once the calves are much past two or three weeks old, according to McKechnie. And a study in Queensland suggests that dingoes don’t even prey heavily on the newborn calves unless their staple prey disappears due to deteriorating conditions like drought.\\n\\n**Paragraph K.**\\nThis study, co-authored by Lee Alien of the Robert Wicks Research Centre in Queensland, suggests that the aggressive baiting programs used against dingoes may actually be counter-productive for graziers. When dingoes are removed from an area by baiting m the area is recolonized by younger, more solitary dingoes. These animals aren’t capable of going after the large prey like kangaroos, so they turn to calves. In their study, some of the highest rates of calf predation occurred in areas that had been baited.\\n\\n**Paragraph L.**\\n**Paragraph G.**\nMark Clifford, general manager of a firm that manages over 200,000 head of cattle, is not convinced by Allen’s assertion. Clifford says, ‘It’s obvious if we drop or loosen control on dingoes, we are going to lose more calves.’ He doesn’t believe that dingoes will go after kangaroos when calves are around. Nor is he persuaded of dingoes’ supposed ecological benefits, saying he is not convinced that they manage to catch cats that often, believing they are more likely to catch small native animals instead.\\n\\n**Paragraph M.**\\n**Paragraph H.**\nMcKechnie agrees that dingoes kill the wallabies (small native animals) that compete with his cattle for food, but points out that in parts of Westers Australia, there are no fixes, and not very many cats. He doesn’t see how relaxing controls on dingoes in his area will improve the ecological balance.\\n\\n**Paragraph N.**\\nJohnson sees a need for a change in philosophy on the part of graziers. ‘There might be a number of different ways of thinking through dingo management in cattle country,’ he says. ‘At the moment, though, that hasn’t got through to graziers. There’s still just on prescription, and that is to bait as widely as possible.’\\n\\n'
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
    'a description of a barrier designed to stop dingoes, which also divides two kinds of non-natives animals',
    '',
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
    'how dingoes ensure that rival species do not dominate',
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
    'READING',
    2,
    'a reference to a widespread non-native species that other animals feed on',
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
    'mention of the dingo’s arrival in Australia',
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
    'READING',
    2,
    'research which has proved',
    '',
    '{"info-q5": ["F", "f"]}'
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
    'description of a method used to kill dingoes',
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
    'READING',
    2,
    'way that the structure of dingo groups affects how quickly their',
    '',
    '{"info-q7": ["D", "d"]}'
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
    'Dingoes tend to hunt native animals rather than hunting other non-native',
    '',
    '{"info-q8": ["D", "d"]}'
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
    'The presence of dingoes puts the income of some people',
    '',
    '{"info-q9": ["A", "a"]}'
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
    'Dingoes have had little impact on the dying out of animal species in',
    '',
    '{"info-q10": ["B", "b"]}'
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
    'The dingo replaced the _______ as the main predatory animal in Australia.',
    '',
    '{"blank-q11": ["TASMANIAN TIGER"]}'::jsonb
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
    'Foxes and cats are more likely to hunt native animals when there are fewer _______',
    '',
    '{"blank-q12": ["RABBITS"]}'::jsonb
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
    'Australian animals reproduce at a slow rate as a natural way of avoiding _______',
    '',
    '{"blank-q13": ["OVERPOPULATION"]}'::jsonb
  );


END$$;


COMMIT;