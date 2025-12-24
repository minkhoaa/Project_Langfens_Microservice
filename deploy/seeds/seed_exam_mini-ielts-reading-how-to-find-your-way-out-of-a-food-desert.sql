-- ============================================
-- IELTS Exam Data Import SQL
-- Generated: 2025-12-24T13:45:02.180909
-- Source: mini-ielts.com
-- Title: How to find your way out of a food desert
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data for slug: mini-ielts-reading-how-to-find-your-way-out-of-a-food-desert
DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'mini-ielts-reading-how-to-find-your-way-out-of-a-food-desert'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'mini-ielts-reading-how-to-find-your-way-out-of-a-food-desert';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'mini-ielts-reading-how-to-find-your-way-out-of-a-food-desert';
DELETE FROM exams
WHERE "Slug" = 'mini-ielts-reading-how-to-find-your-way-out-of-a-food-desert';

DO $$
DECLARE
  exam_id uuid := gen_random_uuid();
  sec1 uuid := gen_random_uuid();
  qid uuid;
BEGIN

  INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","ImageUrl","UpdatedAt")
  VALUES (
    exam_id,
    'mini-ielts-reading-how-to-find-your-way-out-of-a-food-desert',
    'How to find your way out of a food desert',
    'IELTS Reading Practice Test from IELTS Mentor',
    'IELTS',
    'B2',
    'PUBLISHED',
    20,
    'https://icma.org/sites/default/files/2359_food_desert_.jpg',
    now()
  );

  INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","PassageMd")
  VALUES (
    sec1,
    exam_id,
    1,
    'Reading Passage - How to find your way out of a food desert',
    E'**Questions 1-6:**\nComplete the sentences below.\n\nWrite **NO MORE THAN TWO WORDS AND/OR A NUMBER** for each answer.\n\n---\n\n**Questions 7-13:**\nDo the following statements agree with the information given in the text?\n\nWrite\n- **TRUE** if the statement agrees with the information\n- **FALSE** if the statement contradicts the information\n- **NOT GIVEN** if there is no information on this',
    E'**Paragraph A.**\\nOrdinary citizens have been using the internet to draw attention to the lack of healthy eating options in inner cities\\n\\n**Paragraph B.**\\nOver the last few months, a survey has been carried out of over 200 greengrocers and convenience stores in Crown Heights, a neighborhood in Brooklyn, New York. As researchers from the Brooklyn Food Association enter the details, colorful dots appear on their online map, which display the specific location of each of the food stores in a handful of central Brooklyn neighborhoods. Clicking on a dot will show you the store''s name and whether it carries fresh fruit and vegetables, wholegrain bread, low-fat dairy and other healthy options.\\n\\n**Paragraph C.**\\nThe researchers plan eventually to survey the entire borough of Brooklyn. ‘We want to get to a more specific and detailed description of what that looks like’, says Jeffrey Heehs, who leads the project. He hopes it will help residents find fresh food in urban areas where the stores sell mostly packaged snacks or fast food, areas otherwise known as food deserts. The aim of the project is also to assist government officials in assessing food availability, and in forming future policies about what kind of food should be sold and where.\\n\\n**Paragraph D.**\\nIn fact, the Brooklyn project represents the intersection of two growing trends: mapping fresh food markets in US cities, and private citizens creating online maps of local neighborhood features. According to Michael Goodchild, a geographer at the University of California at Santa Barbara, citizen map makers may make maps because there is no good government map, or to record problems such as burned-out traffic lights.\\n\\n**Paragraph E.**\\nAccording to recent studies, people at higher risk of chronic disease and who receive minimal incomes for the work they do, frequently live in neighborhoods located in food deserts. But how did these food deserts arise? Linda Alwitt and Thomas Donley, marketing researchers at DePaul University in Chicago, found that supermarkets often can’t afford the amount of land required for their stores in cities. City planning researcher Cliff Guy and colleagues at the University of Leeds in the UK found in 2004 that smaller urban groceries tend to close due to competition from suburban supermarkets.\\n\\n**Paragraph F.**\\nAs fresh food stores leave a neighborhood, residents find it harder to eat well and stay healthy. Food deserts are linked with lower local health outcomes, and they may be a driving force in the health disparities between lower-income and affluent people in the US. Until recently, the issue attracted little national attention, and received no ongoing funding for research.\\n\\n**Paragraph G.**\\nNow, more US cities are becoming aware of their food landscapes. Last year, the United States Department of Agriculture launched a map of where food stores are located in all the US counties. Mari Gallagher, who runs a private consulting firm, says her researchers have mapped food stores and related them to health statistics for the cities of Detroit, Chicago, Cincinnati and Washington, D.c. These maps help cities identify where food deserts are and, occasionally, have documented that people living in food deserts have higher rates of diet-related diseases.\\n\\n**Paragraph H.**\\nThe Brooklyn project differs in that it’s run by a local core of five volunteers who have worked on the project for the past year, rather than trained, academic researchers. To gather data, they simply go to individual stores with pre-printed surveys in hand, and once the storekeeper''s permission has been obtained, check off boxes on their list against the products for sole in the store. Their approach to data collection and research has been made possible by technologies such as mapping software and GPS-related smart phones, Google Maps and OpenStreeMap, an open-source online map with a history of involvement in social issues. Like Brooklyn Food Association volunteers, many citizen online map makers use maps to bring local problems to official attention, Goodchild says. Heehs, the mapping project leader, says that after his group gathers more data, it will compare neighborhoods, come up with solutions to address local needs, and then present them to New York City officials. Their website hasn’t caught them much local or official attention yet, however. It was launched only recently, but its creators haven’t yet set up systems to see who’s looking at it.\\n\\n**Paragraph I.**\\nExperts who visited the Brooklyn group’s site were optimistic but cautious. ‘This kind of detailed information could be very useful’ says Michele Ver Ploeg, an economist for the Department of Agriculture. To make the map more helpful to both residents and policy makers, she would like to see price data for healthy products, too. Karen Ansel, a registered dietician and a spokesperson for the American Dietetic Association, found the site confusing to navigate. ‘That said, with this information in place the group has the tools to build a more user-friendly site that could be ... very helpful to consumers’, she says. ‘The group also should ensure their map is available to those who don’t have internet access at home’, she adds. In fact, a significant proportion of Brooklyn residents don’t have internet access at home and 8 percent rely on dial-up service, instead of high-speed internet access, according to Gretchen Maneval, director of Brooklyn College’s Center for the study of Brooklyn. ‘It’s still very much a work in progress’, Heehs says of the online map. They’ll start advertising it online and by email to other community groups, such as urban food garden associations, next month. He also hopes warmer days in the spring will draw out fresh volunteers to spread awareness and to finish surveying, as they have about two-thirds of Brooklyn left to cover.\\n\\n'
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
    'The online map provides users with a store’s name, _______ and details of its produce',
    '',
    '{"blank-q1": ["LOCATION"]}'::jsonb
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
    'One goal of the mapping project is to help develop new _______ on food.',
    '',
    '{"blank-q2": ["POLICIES"]}'::jsonb
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
    'Citizen maps are sometimes made when _______ maps are unsatisfactory.',
    '',
    '{"blank-q3": ["GOVERNMENT"]}'::jsonb
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
    'New research suggests that people living in food deserts often have low _______',
    '',
    '{"blank-q4": ["INCOMES"]}'::jsonb
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
    'Some supermarkets are unable to buy enough _______ inside cities for their stores',
    '',
    '{"blank-q5": ["LAND"]}'::jsonb
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
    'Small grocery stores in cities often cannot cope with supermarket _______',
    '',
    '{"blank-q6": ["SUBURBAN"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    7,
    'TRUE_FALSE_NOT_GIVEN',
    'READING',
    2,
    'A group of professional researchers are in charge of the Brooklyn project.',
    '',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'TRUE', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'FALSE', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'NOT GIVEN', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    8,
    'TRUE_FALSE_NOT_GIVEN',
    'READING',
    2,
    'The Brooklyn project team carries out their assessment of stores without the owner’s knowledge',
    '',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'TRUE', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'FALSE', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'NOT GIVEN', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    9,
    'TRUE_FALSE_NOT_GIVEN',
    'READING',
    2,
    'The Brooklyn project has experienced technical difficulties setting up the website',
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
    10,
    'TRUE_FALSE_NOT_GIVEN',
    'READING',
    2,
    'The city government has taken a considerable interest in the Brooklyn project website',
    '',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'TRUE', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'FALSE', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'NOT GIVEN', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    11,
    'TRUE_FALSE_NOT_GIVEN',
    'READING',
    2,
    'Michele Ver Ploeg believes the Brooklyn project website should contain additional information',
    '',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'TRUE', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'FALSE', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'NOT GIVEN', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    12,
    'TRUE_FALSE_NOT_GIVEN',
    'READING',
    2,
    'The rate of internet use in Brooklyn is unlikely to increase in the near future',
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
    13,
    'TRUE_FALSE_NOT_GIVEN',
    'READING',
    2,
    'Jeffrey Heehs would like more people to assist with the Brooklyn project research',
    '',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'TRUE', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'FALSE', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'NOT GIVEN', false);


END$$;


COMMIT;