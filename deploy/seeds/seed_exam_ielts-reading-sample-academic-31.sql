-- ============================================
-- IELTS Exam Data Import SQL
-- Generated: 2025-12-20T12:02:26.885126
-- Source: ielts-writing.info
-- Title: IELTS Reading Sample (Academic) #31
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data for slug: ielts-reading-ielts-reading-sample-academic-31
DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-reading-ielts-reading-sample-academic-31'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-ielts-reading-sample-academic-31';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-reading-ielts-reading-sample-academic-31';
DELETE FROM exams
WHERE "Slug" = 'ielts-reading-ielts-reading-sample-academic-31';

DO $$
DECLARE
  exam_id uuid := gen_random_uuid();
  sec1 uuid := gen_random_uuid();
  qid uuid;
BEGIN

  INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","UpdatedAt")
  VALUES (
    exam_id,
    'ielts-reading-ielts-reading-sample-academic-31',
    'IELTS Reading Sample (Academic) #31',
    'IELTS Reading Practice Test: IELTS Reading Sample (Academic) #31',
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
    'Reading Passage - IELTS Reading Sample (Academic) #31',
    E'# Passage\n\nIELTS Reading Academic 31\n‘Eyes on the World’: Travel photography in the 21st century\nOne of the world’s first travel shoots took place in 1849 when two young Frenchmen, Gustave Flaubert and Maxime Du Camp, decided they would set out on a great adventure and travel to Egypt. Du Camp took hundreds of photographs of the Pyramids and the Sphinx, and when he returned home and published his travel album, the images amazed the European public and turned Du Camp into a celebrity overnight.\nWhile Du Camp’s photographs may appear simple in comparison to modern photographs with their special effects, it seems to me that nowadays the majority of photographers fail to realise what the challenges were in taking photographs in the 19th century. To begin with, foreign travel was expensive and difficult to organise. Fortunately, Du Camp had money of his own and he was also able to get additional funding for the journey from the French government. Another issue was the size and weight of 19th-century cameras – they were very large and heavy. Finally, not only was there a great deal of equipment and chemicals to transport, but travelling itself could be highly dangerous. Of course, travel photographers do still take risks as part of their job, but the level of danger is hardly the same as when Du Camp was travelling across continents.\nNevertheless, as any professional photographer knows, to be good at the job still requires hard work and dedication. The popular idea that great photographs are often the result of a photographer being in exactly the right place at exactly the right time, just by chance, does not reflect reality. Last year, for example, on a visit to Reykjavik, Iceland, I met several photographers I knew. We were all there for the annual Winter Lights festival, involving works by many artists and musicians. One shot we all wanted was the perfect image of the\naurora borealis\n– the strange green lights that sometimes appear briefly in the sky as the sun is going down. It took hours for everyone to decide how best to catch this moment and to work out where to place themselves to get the best result. In the end, I was delighted with the way my photographs turned out. In general, professional photographers share the feeling that the most rewarding photographs are the ones you’ve worked hard for.\nEvents like this attract photographers because the atmosphere can help create some wonderful photo opportunities. The Day of the Dead in Mexico is a perfect example. Although other countries have a similar event, for example, All Souls Day in the Philippines, the Mexican event is a photographer’s dream. It’s a time of celebration, when people remember relatives who have already passed away. Good photographs will capture that sense of joy in the bright and colourful decorations on the gravestones and in the faces of the families who are using humour and art to remember their dead. What’s more, the local people are usually happy to share this experience with outsiders so visitors can participate if they wish. The festival is held in November, and should be included in any photographer’s diary.\nTravelling as a photographer has encouraged me to question some ideas I previously believed to be true. An example of this is the popular belief that some groups of native Americans strongly dislike photographs and will turn away from cameras. This, however, is not the case. From talking to native Americans I’ve met on my journeys, it seems that it is now acceptable to regard photographs as valuable connections to ancestors and even include them in important ceremonies, some of which I have been lucky to observe and record.\nOne question that people often ask is whether it’s possible to make a reasonable living in the travel photography industry today. Gone are the easy days when photographers simply shot photos for magazines and newspapers, sent them to an editor and got paid at the end of every month: these forms of media now usually buy photos for their stories directly from companies that store millions of them. As a result, photographers now need to be more flexible about the kind of projects they work on. One way to do this is by working for big businesses. In the past, photographers often decided where they would like to go, and could perhaps experiment more with the kinds of photographs they took. However, working for a big business often means that you are sent where the company wants you to go; perhaps to a beach or a mountain if they want to promote these as tourist destinations. The desert is another popular place: many car companies like to shoot this kind of background to advertise their new vehicles. Of course, nowadays this kind of well-paid work opportunity is very popular, so a huge number of photographers will all apply for the same job; a situation which you didn’t see so much in the past. Nevertheless, in my experience, whether photographers are amateurs or professionals, there is a generally positive feeling between them: they are supportive of each other and willing to share advice about work opportunities and the risks that travelling to foreign destinations sometimes involves.\n\n.'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    1,
    'YES_NO_NOT_GIVEN',
    'READING',
    2,
    'Most photographers understand how hard it was to take photographs in the 19th century.',
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
    2,
    'MULTIPLE_CHOICE_MULTIPLE',
    'READING',
    2,
    'ChooseFOURideas which are found in the text.',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. Some photographers like to take photographs of serious subjects while others like to take amusing ones.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. The typical career of a photographer is not the same today as it was in the past.', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. Newspapers no longer buy so many photographs from individual photographers.', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D. Big businesses sometimes use photographers to take pictures of their products or services.', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, 'E. The internet has made it much easier to see the work of many photographers.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 6, 'F. There are a huge number of training courses if people want to study photography.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 7, 'G. Photographers talk to each other about their experiences and provide useful information.', true);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    3,
    'YES_NO_NOT_GIVEN',
    'READING',
    2,
    'Some of the chemicals that Du Camp used for his photography were unsafe.',
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
    4,
    'YES_NO_NOT_GIVEN',
    'READING',
    2,
    'There is a lot of luck involved in taking really good photographs.',
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
    5,
    'YES_NO_NOT_GIVEN',
    'READING',
    2,
    'It’s usually photographs that require a lot of effort that professional photographers are most pleased with.',
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
    6,
    'YES_NO_NOT_GIVEN',
    'READING',
    2,
    'All Souls Day in the Philippines is an older festival than the Day of the Dead in Mexico.',
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
    7,
    'YES_NO_NOT_GIVEN',
    'READING',
    2,
    'Mexican locals are happy for foreigners to attend Day of the Dead celebrations.',
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
    8,
    'YES_NO_NOT_GIVEN',
    'READING',
    2,
    'It has become common for some native American groups to photograph important ceremonies.',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'YES', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'NO', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'NOT GIVEN', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    9,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    'Questions (...) - (...) Complete the notes below. Choose ONE WORD AND/OR A NUMBER from the passage for each answer. Write your answers in boxes (...) - (...) on your answer sheet.\n\nNowadays photographers no longer receive from the work they do, and they need to look for different kinds of project. One option is to get a job with a large company and take photographs for . A job like this is attractive to many photographers, and there is between them. However, it is also true th _______',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank. The answer must fit grammatically.',
    '{"blank-q9": ["regular income"]}'::jsonb
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
    'Questions (...) - (...) Complete the notes below. Choose ONE WORD AND/OR A NUMBER from the passage for each answer. Write your answers in boxes (...) - (...) on your answer sheet.\n\nNowadays photographers no longer receive from the work they do, and they need to look for different kinds of project. One option is to get a job with a large company and take photographs for . A job like this is attractive to many photographers, and there is between them. However, it is also true th _______',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank. The answer must fit grammatically.',
    '{"blank-q10": ["marketing purposes"]}'::jsonb
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
    'Questions (...) - (...) Complete the notes below. Choose ONE WORD AND/OR A NUMBER from the passage for each answer. Write your answers in boxes (...) - (...) on your answer sheet.\n\nNowadays photographers no longer receive from the work they do, and they need to look for different kinds of project. One option is to get a job with a large company and take photographs for . A job like this is attractive to many photographers, and there is between them. However, it is also true th _______',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank. The answer must fit grammatically.',
    '{"blank-q11": ["great competition"]}'::jsonb
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
    'Questions (...) - (...) Complete the notes below. Choose ONE WORD AND/OR A NUMBER from the passage for each answer. Write your answers in boxes (...) - (...) on your answer sheet.\n\nNowadays photographers no longer receive from the work they do, and they need to look for different kinds of project. One option is to get a job with a large company and take photographs for . A job like this is attractive to many photographers, and there is between them. However, it is also true th _______',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank. The answer must fit grammatically.',
    '{"blank-q12": ["good relationships"]}'::jsonb
  );


END$$;


COMMIT;