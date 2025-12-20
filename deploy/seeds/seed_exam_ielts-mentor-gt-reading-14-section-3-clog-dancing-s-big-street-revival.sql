-- ============================================
-- IELTS Exam Data Import SQL
-- Generated: 2025-12-20T19:53:09.208593
-- Source: ielts-mentor.com
-- Title: GT Reading 14 Section 3 - Clog dancing’s big street revival
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data for slug: ielts-mentor-gt-reading-14-section-3-clog-dancing-s-big-street-revival
DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-mentor-gt-reading-14-section-3-clog-dancing-s-big-street-revival'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-mentor-gt-reading-14-section-3-clog-dancing-s-big-street-revival';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-mentor-gt-reading-14-section-3-clog-dancing-s-big-street-revival';
DELETE FROM exams
WHERE "Slug" = 'ielts-mentor-gt-reading-14-section-3-clog-dancing-s-big-street-revival';

DO $$
DECLARE
  exam_id uuid := gen_random_uuid();
  sec1 uuid := gen_random_uuid();
  qid uuid;
BEGIN

  INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","UpdatedAt")
  VALUES (
    exam_id,
    'ielts-mentor-gt-reading-14-section-3-clog-dancing-s-big-street-revival',
    'GT Reading 14 Section 3 - Clog dancing’s big street revival',
    'IELTS Reading Practice Test from IELTS Mentor',
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
    'Reading Passage - GT Reading 14 Section 3 - Clog dancing’s big street revival',
    E'# Passage\n\n# Clog dancing’s big street revival\n\nA. The streets of Newcastle, in the north-east of England, have begun to echo with a sound that has not been heard for about a century. A sharp, rhythmic knocking can be heard among the Saturday crowds in one of the city’s busiest intersections. It sounds a little like dozens of horses galloping along the street, but there are none in sight. In fact, it’s the noise of a hundred people dancing in wooden shoes, or clogs. The shoppers are about to be ambushed by the UK’s biggest clog dance event. The hundred volunteers have been coached to perform a mass routine. For ten minutes, the dancers bring the city centre to a standstill. There are people clogging on oil drums and between the tables of pavement cafes. A screaming, five-man team cuts through the onlookers and begins leaping over swords that look highly dangerous. Then, as swiftly as they appeared, the doggers melt back into the crowd, leaving the slightly stunned spectators to go about their business. B. This strange manifestation is the brainchild of conductor Charles Hazlewood, whose conversion to clog dancing came through an encounter with a folk band. The Unthanks. ''Rachel and Becky Unthank came to develop some ideas in my studio,’ Hazlewood says. ''Suddenly, they got up and began to mark out the rhythm with their feet - it was an extraordinary blur of shuffles, clicks and clacks that was an entirely new music for me. I thought, "Whatever this is, I want more of it”.’ Hazlewood was inspired to travel to Newcastle to make a television programme, Come Clog Dancing, in which he and a hundred other people learn to clog in a fortnight. Yet when he first went out recruiting, local people seemed unaware of their heritage. ''We went out on to the streets, looking for volunteers, but nobody seemed to know anything about clog dancing; or if they did, they thought it originated in the Netherlands.’ C. The roots of clog dancing go back several hundred years, and lie in traditional dances of the Dutch, Native Americans and African-Americans, in which the dancer strikes the ground with their heel or toes, to produce a rhythm that’s audible to everyone around. In England, clogging is believed to have first developed in the mid-19th century in the cotton mills of Lancashire, in the north-west, where workers created a dance that imitated the sound of the machinery. The style quickly spread and developed a number of regional variations. In Northumberland, it became a recreation for miners, who danced solo or to the accompaniment of a fiddle. ''The Northumberland style is very distinct from Lancashire clogging,’ says Laura Connolly, a virtuoso dancer who worked with Hazlewood on the programme. ''Northumbrian dancing is quite neat and precise with almost no upper-body movement, whereas the Lancastrian style is more flamboyant.’ D. Whatever the region, clogging remains very much a minority pursuit. Yet at the turn of the 20th century, clogging was a fully-fledged youth craze. Two famous comic film actors, Stan Laurel and Charlie Chaplin, both began their careers as doggers. But the dance almost completely died out with the passing of the industrial age. ''People danced in clogs because they were cheap, hardwearing and easily repaired,’ Connolly says. ‘Yet eventually, clogs became associated with poverty and people were almost ashamed to wear them.’ E. Fortunately, the key steps of the dances were preserved and handed down in a series of little blue books, often named after their inventors. ‘It means that we still know what Mrs Willis’s Rag or Ivy Sands’s Hornpipe were like,’ Connolly says. ‘It’s my dream that one day there’ll be a little blue book called Laura Connolly’s Jig.’ F. Her biggest challenge to date was to teach Hazlewood and 100 other beginners a routine sufficiently accomplished to perform on television, from scratch, in less than two weeks. ‘I started people off with something simple,’ she says. ‘It’s a basic shuffle that most people can pick up/ Once Hazlewood had absorbed the basics, Connolly encouraged him to develop a short solo featuring more complex steps - though he nearly came to grief attempting a tricky manoeuvre known as Charlie Chaplin Clicks, so named as it was the signature move of Chaplin’s film character the Little Tramp. ‘To be honest, I never quite got those right,’ Hazlewood says with a laugh. ‘We came up with a slightly easier version, which Laura thought we should call Charlie Hazlewood Clicks. The thing about clogs is that they’re all surface: there’s no grip and they’re slightly curved so you stand in a slightly peculiar way. The potential to fall over is enormous.’ On the day, Hazlewood managed to pull off a decent solo, clicks and all. T wasn’t convinced, until the moment I did it, that I was going to get it right,’ he admits. ‘But in the end, clog dancing is not so very different from conducting. Both require you to communicate a beat - only 1 had to learn how to express it with my feet, rather than my hands. But it’s a good feeling.’ G. ‘People forget that clogging was originally a street dance,’ Connolly says. ‘It was competitive, it was popular, and now young people are beginning to rediscover it for themselves. As soon as we finished in Newcastle, I had kids coming up to me saying, “Clog dancing’s cool - I want to do that!”’\n\nFirst the city’s shoppers hear a sound that seems to be created by a large number of 35 ....................., and then over a hundred people wearing clogs appear and dance. Most dance on the pavement, some on oil drums. One group uses 36 ..................... as part of its dance. The event was organised by Charles Hazlewood, a 37 ..................... . He was introduced to clog dancing by a folk band working with him in his studio.\n\n• Originated in the Netherlands and North America • In England, probably invented by factory workers copying the noise made by the 38 ..................... in mills • In Northumberland, was danced by 39 ...................... • Very popular in the early 20th century • Lost popularity when clogs were thought to indicate 40 .....................'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    28,
    'MULTIPLE_CHOICE_SINGLE',
    'READING',
    2,
    '28. Section A ...........................',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    29,
    'MULTIPLE_CHOICE_SINGLE',
    'READING',
    2,
    '29. Section B ...........................',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    30,
    'MULTIPLE_CHOICE_SINGLE',
    'READING',
    2,
    '30. Section C ...........................',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    31,
    'MULTIPLE_CHOICE_SINGLE',
    'READING',
    2,
    '31. Section D ...........................',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    32,
    'MULTIPLE_CHOICE_SINGLE',
    'READING',
    2,
    '32. Section E ...........................',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    33,
    'MULTIPLE_CHOICE_SINGLE',
    'READING',
    2,
    '33. Section F ...........................',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    34,
    'MULTIPLE_CHOICE_SINGLE',
    'READING',
    2,
    '34. Section G ........................... Clog dancing’s big street revival A. The streets of Newcastle, in the north-east of England, have begun to echo with a sound that has not been heard for about a century. A sharp, rhythmic knocking can be heard among the Saturday crowds in one of the city’s busiest intersections. It sounds a little like dozens of horses galloping along the street, but there are none in sight. In fact, it’s the noise of a hundred people dancing in wooden shoes, or clogs. The shoppers are about to be ambushed by the UK’s biggest clog dance event. The hundred volunteers have been coached to perform a mass routine. For ten minutes, the dancers bring the city centre to a standstill. There are people clogging on oil drums and between the tables of pavement cafes. A screaming, five-man team cuts through the onlookers and begins leaping over swords that look highly dangerous. Then, as swiftly as they appeared, the doggers melt back into the crowd, leaving the slightly stunned spectators to go about their business. B. This strange manifestation is the brainchild of conductor Charles Hazlewood, whose conversion to clog dancing came through an encounter with a folk band. The Unthanks. ''Rachel and Becky Unthank came to develop some ideas in my studio,’ Hazlewood says. ''Suddenly, they got up and began to mark out the rhythm with their feet - it was an extraordinary blur of shuffles, clicks and clacks that was an entirely new music for me. I thought, "Whatever this is, I want more of it”.’ Hazlewood was inspired to travel to Newcastle to make a television programme, Come Clog Dancing, in which he and a hundred other people learn to clog in a fortnight. Yet when he first went out recruiting, local people seemed unaware of their heritage. ''We went out on to the streets, looking for volunteers, but nobody seemed to know anything about clog dancing; or if they did, they thought it originated in the Netherlands.’ C. The roots of clog dancing go back several hundred years, and lie in traditional dances of the Dutch, Native Americans and African-Americans, in which the dancer strikes the ground with their heel or toes, to produce a rhythm that’s audible to everyone around. In England, clogging is believed to have first developed in the mid-19th century in the cotton mills of Lancashire, in the north-west, where workers created a dance that imitated the sound of the machinery. The style quickly spread and developed a number of regional variations. In Northumberland, it became a recreation for miners, who danced solo or to the accompaniment of a fiddle. ''The Northumberland style is very distinct from Lancashire clogging,’ says Laura Connolly, a virtuoso dancer who worked with Hazlewood on the programme. ''Northumbrian dancing is quite neat and precise with almost no upper-body movement, whereas the Lancastrian style is more flamboyant.’ D. Whatever the region, clogging remains very much a minority pursuit. Yet at the turn of the 20th century, clogging was a fully-fledged youth craze. Two famous comic film actors, Stan Laurel and Charlie Chaplin, both began their careers as doggers. But the dance almost completely died out with the passing of the industrial age. ''People danced in clogs because they were cheap, hardwearing and easily repaired,’ Connolly says. ‘Yet eventually, clogs became associated with poverty and people were almost ashamed to wear them.’ E. Fortunately, the key steps of the dances were preserved and handed down in a series of little blue books, often named after their inventors. ‘It means that we still know what Mrs Willis’s Rag or Ivy Sands’s Hornpipe were like,’ Connolly says. ‘It’s my dream that one day there’ll be a little blue book called Laura Connolly’s Jig.’ F. Her biggest challenge to date was to teach Hazlewood and 100 other beginners a routine sufficiently accomplished to perform on television, from scratch, in less than two weeks. ‘I started people off with something simple,’ she says. ‘It’s a basic shuffle that most people can pick up/ Once Hazlewood had absorbed the basics, Connolly encouraged him to develop a short solo featuring more complex steps - though he nearly came to grief attempting a tricky manoeuvre known as Charlie Chaplin Clicks, so named as it was the signature move of Chaplin’s film character the Little Tramp. ‘To be honest, I never quite got those right,’ Hazlewood says with a laugh. ‘We came up with a slightly easier version, which Laura thought we should call Charlie Hazlewood Clicks. The thing about clogs is that they’re all surface: there’s no grip and they’re slightly curved so you stand in a slightly peculiar way. The potential to fall over is enormous.’ On the day, Hazlewood managed to pull off a decent solo, clicks and all. T wasn’t convinced, until the moment I did it, that I was going to get it right,’ he admits. ‘But in the end, clog dancing is not so very different from conducting. Both require you to communicate a beat - only 1 had to learn how to express it with my feet, rather than my hands. But it’s a good feeling.’ G. ‘People forget that clogging was originally a street dance,’ Connolly says. ‘It was competitive, it was popular, and now young people are beginning to rediscover it for themselves. As soon as we finished in Newcastle, I had kids coming up to me saying, “Clog dancing’s cool - I want to do that!”’',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. The streets of Newcastle, in the north-east of England, have begun to echo with a sound that has not been heard for about a century. A sharp, rhythmic knocking can be heard among the Saturday crowds in one of the city’s busiest intersections. It sounds a little like dozens of horses galloping along the street, but there are none in sight. In fact, it’s the noise of a hundred people dancing in wooden shoes, or clogs.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. This strange manifestation is the brainchild of conductor Charles Hazlewood, whose conversion to clog dancing came through an encounter with a folk band. The Unthanks. ''Rachel and Becky Unthank came to develop some ideas in my studio,’ Hazlewood says. ''Suddenly, they got up and began to mark out the rhythm with their feet - it was an extraordinary blur of shuffles, clicks and clacks that was an entirely new music for me. I thought, "Whatever this is, I want more of it”.’', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. The roots of clog dancing go back several hundred years, and lie in traditional dances of the Dutch, Native Americans and African-Americans, in which the dancer strikes the ground with their heel or toes, to produce a rhythm that’s audible to everyone around. In England, clogging is believed to have first developed in the mid-19th century in the cotton mills of Lancashire, in the north-west, where workers created a dance that imitated the sound of the machinery. The style quickly spread and developed a number of regional variations. In Northumberland, it became a recreation for miners, who danced solo or to the accompaniment of a fiddle.', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D. Whatever the region, clogging remains very much a minority pursuit. Yet at the turn of the 20th century, clogging was a fully-fledged youth craze. Two famous comic film actors, Stan Laurel and Charlie Chaplin, both began their careers as doggers. But the dance almost completely died out with the passing of the industrial age. ''People danced in clogs because they were cheap, hardwearing and easily repaired,’ Connolly says. ‘Yet eventually, clogs became associated with poverty and people were almost ashamed to wear them.’', false);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    35,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    'Complete the blank. _______ Question 35',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q35": ["horses (galloping)"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    36,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    'Complete the blank. _______ Question 36',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q36": ["swords"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    37,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    'Complete the blank. _______ Question 37',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q37": ["conductor"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    38,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    'Complete the blank. _______ Question 38',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q38": ["machinery"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    39,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    'Complete the blank. _______ Question 39',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q39": ["miners"]}'::jsonb
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","BlankAcceptTexts")
  VALUES (
    qid,
    sec1,
    40,
    'SUMMARY_COMPLETION',
    'READING',
    2,
    'Complete the blank. _______ Question 40',
    'Use NO MORE THAN THREE WORDS from the passage to complete the blank.',
    '{"blank-q40": ["poverty"]}'::jsonb
  );


END$$;


COMMIT;