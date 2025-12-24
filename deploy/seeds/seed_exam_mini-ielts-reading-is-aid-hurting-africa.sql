-- ============================================
-- IELTS Exam Data Import SQL
-- Generated: 2025-12-24T13:44:59.919457
-- Source: mini-ielts.com
-- Title: IS AID HURTING AFRICA?
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data for slug: mini-ielts-reading-is-aid-hurting-africa
DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'mini-ielts-reading-is-aid-hurting-africa'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'mini-ielts-reading-is-aid-hurting-africa';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'mini-ielts-reading-is-aid-hurting-africa';
DELETE FROM exams
WHERE "Slug" = 'mini-ielts-reading-is-aid-hurting-africa';

DO $$
DECLARE
  exam_id uuid := gen_random_uuid();
  sec1 uuid := gen_random_uuid();
  qid uuid;
BEGIN

  INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","ImageUrl","UpdatedAt")
  VALUES (
    exam_id,
    'mini-ielts-reading-is-aid-hurting-africa',
    'IS AID HURTING AFRICA?',
    'IELTS Reading Practice Test from IELTS Mentor',
    'IELTS',
    'B2',
    'PUBLISHED',
    20,
    'http://images.mini-ielts.com/images/2/extinct-the-giant-deer-1_resized.png',
    now()
  );

  INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","PassageMd")
  VALUES (
    sec1,
    exam_id,
    1,
    'Reading Passage - IS AID HURTING AFRICA?',
    E'**Questions 1-11:**\nComplete the chart on the following page.\nChoose **ONE WORD OR A NUMBER** from the passage for each answer.\n\n---\n\n**Questions 12-13:**\nChoose **TWO** letters, **A-E**.\nWhich of the statements does the writer of the passage support?',
    E'# IS AID HURTING AFRICA?\n\nDespite its population of more than one billion and its rich land and natural resources, the continent of Africa remains poor. The combined economies of its 54 states equal that of one European country: the Netherlands.\n\nIt is difficult to speak of Africa as a unit as its states differ from each other in culture, climate, size, and political system. Since mid-20th-century independence, many African states have pursued different economic policies. Yet, none of them has overcome poverty. Why might this be?\n\nOne theory says Africa is unlucky. Sparsely populated with diverse language and culture, it contains numerous landlocked countries, and it is far from international markets. Dambisa Moyo, a Zambian-born economist, has another theory. In her 2009 book, Dead Aid, she proposes that international aid is largely to blame for African poverty because it has encouraged dependence and corruption, and has diverted talented people from the business. One of her statistics is that from 1970-98, when aid to Africa was highest, poverty rose from eleven to 66%. If aid were cut, she believes Africans would utilise their resources more creatively.\n\nWhen a state lacks the capacity to care for its people, international non-governmental organisations (NGOs), like Oxfam or the Red Cross, assume this role. While NGOs distribute food or medical supplies, Moyo argues they reduce the ability of the state to provide. Furthermore, during this process, those in government and the military siphon off aid goods and money themselves. Transparency International, an organisation that surveys corruption, rates the majority of African states poorly.\n\nMoyo provides another example. Maybe a Hollywood star donates American-made mosquito nets. Certainly, this benefits malaria-prone areas, but it also draws business away from local African traders who supply nets. More consultation is needed between do-gooder foreigners and local communities.\n\nMoyo also suggests African nations increase their wealth by investment in bonds, or by increased co-operation with China.\n\nThe presidents of Rwanda and Senegal are strong supporters of Moyo, but critics say her theories are simplistic. The international aid community is not responsible for geography, nor has it anything to do with the military takeover, corruption, or legislation that hampers trade. Africans have had half a century of self-government and economic control, yet, as the population of the continent doubled, its GDP has risen only 60%. In the same period, Malaysia and Vietnam threw off colonialism and surged ahead economically by investing in education, health, and infrastructure; by lowering taxes on international trade; and, by being fortunate to be surrounded by other successful nations.\n\nThe economist Paul Collier has speculated that if aid were cut, African governments would not find alternative sources of income, nor would they reduce corruption. Another economist, Jeffrey Sachs, has calculated that twice the amount of aid currently given is needed to prevent suffering on a grand scale.\n\nIn *Dead Aid*, Moyo presents her case through a fictitious country called ''Dongo'', but nowhere does she provide examples of real aid organisations causing actual problems. Her approach may be entertaining, but it is hardly academic.\n\nOther scholars point out that Africa is dominated by tribal societies with military-government elites. Joining the army, rather than doing business, was the easiest route to personal wealth and power. Unsurprisingly, military takeovers have occurred in almost every African country. In the 1960s and 70s, European colonials were replaced by African ''colonials'' – African generals and their families. Meantime, the very small, educated bourgeoisie has moved abroad. All over Africa, strongmen leaders have ruled for a long time, or one unstable military regime has succeeded another. As a result, business, separate from the military government is rare, and international investment limited.\n\nPost-secondary education rates are low in Africa. Communications and transportation remain basic although mobile phones are having an impact. The distances farmers must travel to market are vast due to poor roads. High cross-border taxes and long bureaucratic delays are par for the course. African rural populations exceed those elsewhere in the world. Without a decent infrastructure or an educated urbanised workforce, a business cannot prosper. Recent World Bank statistics show that in southern Africa, the number of companies using the internet for business is 20% as opposed to 40% in South America or 80% in the US. There are 37 days each year without water whereas there is less than one day in Europe. The average cost of sending one container to the US is $7600, but only $3900 from East Asia or the Pacific. All these problems are the result of poor state planning.\n\nGreat ethnic and linguistic diversity within African countries has led to tribal favouritism. Governments are often controlled by one tribe or allied tribes; civil war is usually tribal. It is estimated each civil war costs a country roughly $64 billion. Southern Africa had 34 such conflicts from 1940-2000 while South Asia, the next-affected region, had only 24 in the same period. To this day, a number of bloody conflicts continue.\n\nOther opponents of Moyo add that her focus on market investment and more business with China is shortsighted. The 2008 financial crisis meant that countries with market investments lost money. Secondly, China''s real intentions in Africa are unknown, but everyone can see China is buying up African farmland and securing cheap oil supplies.\n\nAll over Africa, there are untapped resources, but distance, diversity, and low population density contribute to poverty. Where there is no TV, infrequent electricity, and bad roads, there still seems to be money for automatic weapons just the right size for 12-year-old boys to use. Blaming the West for assisting with aid fails to address the issues of continuous conflict, ineffective government, and little infrastructure. Nor does it prevent terrible suffering.\n\nHas aid caused problems for Africa, or is Africa''s strife of its own making or due to geography? Whatever you think, Dambisa Moyo''s book has generated lively discussion, which is fruitful for Africa.'
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
    'Africa has rich _______ and natural resources',
    '',
    '{"blank-q1": ["land"]}'::jsonb
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
    'Despite this, Africa remains _______',
    '',
    '{"blank-q2": ["poor"]}'::jsonb
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
    'Moyo believes international _______ is to blame',
    '',
    '{"blank-q3": ["aid"]}'::jsonb
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
    'Aid has diverted talented people from _______',
    '',
    '{"blank-q4": ["business"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    5,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    'More consultation is needed between foreigners and local _______',
    '',
    '{"blank-q5": ["communities"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    6,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    'Moyo suggests increased co-operation with _______',
    '',
    '{"blank-q6": ["China"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    7,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    'Aid community is not responsible for _______',
    '',
    '{"blank-q7": ["geography"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    8,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    'Malaysia and Vietnam surged ahead by _______ in education',
    '',
    '{"blank-q8": ["investment"]}'::jsonb
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
    'Post-secondary _______ rates are low in Africa',
    '',
    '{"blank-q9": ["education"]}'::jsonb
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
    'Southern Africa had _______ civil conflicts from 1940-2000',
    '',
    '{"blank-q10": ["34"]}'::jsonb
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
    'Twice the amount of aid is needed to prevent _______',
    '',
    '{"blank-q11": ["suffering"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    12,
    'MULTIPLE_CHOICE_SINGLE',
    'READING',
    2,
    'Which statements does the writer of the passage support? (First answer for Q12-13)',
    '',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. Moyo is right that international aid is causing Africa''s problems.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. Moyo has ignored the role of geography in Africa.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. Convincing evidence is lacking in Moyo''s theory.', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D. Most political leaders in Africa agree with Moyo''s analysis.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, 'E. Useful discussion about Africa has resulted from Moyo''s book.', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    13,
    'MULTIPLE_CHOICE_SINGLE',
    'READING',
    2,
    'Which statements does the writer of the passage support? (Second answer for Q12-13)',
    '',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. Moyo is right that international aid is causing Africa''s problems.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. Moyo has ignored the role of geography in Africa.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. Convincing evidence is lacking in Moyo''s theory.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D. Most political leaders in Africa agree with Moyo''s analysis.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, 'E. Useful discussion about Africa has resulted from Moyo''s book.', true);


END$$;


COMMIT;