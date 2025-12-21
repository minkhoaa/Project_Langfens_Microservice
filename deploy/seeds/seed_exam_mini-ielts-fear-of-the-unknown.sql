-- ============================================
-- IELTS Exam Data Import SQL
-- Generated: 2025-12-21T13:58:44.559958
-- Source: ielts-mentor.com
-- Title: Fear of the Unknown
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data for slug: ielts-mentor-fear-of-the-unknown
DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-mentor-fear-of-the-unknown'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-mentor-fear-of-the-unknown';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-mentor-fear-of-the-unknown';
DELETE FROM exams
WHERE "Slug" = 'ielts-mentor-fear-of-the-unknown';

DO $$
DECLARE
  exam_id uuid := gen_random_uuid();
  sec1 uuid := gen_random_uuid();
  qid uuid;
BEGIN

  INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","UpdatedAt")
  VALUES (
    exam_id,
    'ielts-mentor-fear-of-the-unknown',
    'Fear of the Unknown',
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
    'Reading Passage - Fear of the Unknown',
    E'**Questions 1-7:**\nWhich section contains the following information?\n\nWrite the correct letter, **A-L**.\n\n---\n\n**Questions 8-11:**\nDo the following statements agree with the information given in the text?\n\nWrite\n- **TRUE** if the statement agrees with the information\n- **FALSE** if the statement contradicts the information\n- **NOT GIVEN** if there is no information on this\n\n---\n\n**Questions 12-14:**\nChoose the correct letter, **A**, **B**, **C** or **D**.\n\n---\n\nAmerican companies fear that innovation is the secret of success-and that they cannot innovate \nIn the small Umagic office in midtown Manhattan, a team of 30 computer programmers are working on setting up websites that will allow subscribers to feed in details about themselves and their problems and to receive advice from ‘virtual’ versions of personalities regarded as experts in their fields: for example, a well-known dietician, a celebrity fitness trainer, a psychologist well known in the media for here work on parent-child relationships . Umagic Systems is a young firm and it’s hard to predict how far they’ll go .hl ten years’ time, consulting a computer about your diet problems might seem natural or it might seem absurd. But the company and others like it are beginning to seriously worry large American firms, who see such half-crazy new and innovative ideas as a threat to their own future success. \nInnovation has become a major concern of American management. Firms have found that it is increasingly difficult to redesign existing products or to produce them more economically. \nThe stars of \nAmerican business tend today to be innovators such as Amazon (the internet bookstore) and Wal-Mart \n(the supermarket chain) which have produced completely new ideas or products that have changed their industries. \nOver the past \n15 years, the firms which have achieved the greatest profits have been the ones which have had the most innovations. But such profits aren’t easy to come by .One of the reasons for the increasing number of mergers between companies is a desperate search for new ideas. \nAnd a fortune is spent nowadays on identifying and protecting intellectual property: other people’s ideas. \nAccording to the Pasadena-based Patent & License Exchange in the United States , trading in intangible assets such as intellectual property rose from$15 billion in 1990 to $ 100 billion in 1998,with an increasing proportion of the rewards going to small firms and individuals. \nAnd therein lies the terror for big companies : that innovation seems to work best outside them. Many of the large established companies have been struggling to come up with new products recently.'' In the management of creativity ,size is your enemy,’ argues Peter Chemin ,who runs Fox TV and film empire for News Corporation. "One person managing 20 movies is never going to be as involved as one doing five movies .''He has thus tried to break down the studio into smaller units ,even at the risk of incurring higher costs. \nIt is easier for ideas to develop outside big firms these days. In the past, if a clever scientist had an idea he wanted to commercialise ,he would take it first to a big company. Now, with the banks encouraging individuals to set up new businesses through offering special loans, innovators are more likely to set up on their own. Umagic has already raised $5 million and is about to raise $25 million more. Even in capital-intensive businesses such as pharmaceuticals, entrepreneurs can conduct profitable, early- stage research,selling out to the big firms when they reach expensive,risky clinical trials. \nSome giants, including General Electric and Cisco, have been remarkably successful at buying up and integrating scores of small companies. But many others worry about the prices they have to pay and the difficulty in keeping hold of the people who dreamt up the ideas . Everybody would like to develop more ideas in-house. Procter & Gamble is now changing the entire direction of its business from global expansion to product development; one of its new aims is to get innovations accepted across the company .Elsewhere ,the search for innovation had led to a craze for '' intrapreneurship ’ -giving more power to individuals in the company and setting up internal ideas -factories so that talents staff will not leave. \nAnd yet innovation does not happen just because the chief executive wills it. Indeed ,it is extremely difficult to come up with new ideas year in, year out, especially brilliant ones. Underneath all experts'' diagrams , lists and charts ,most of the available answers seem to focus on two strengths that are difficult to impose: a culture that looks for new ideas, and leaders who know which ones to back. Companies have to discredit the widespread view that jobs working on new products are for ‘those who can''t cope in the real business''. They have to change the culture by introducing hard incentives, such as giving more generous bonuses to those who come up with successful new ideas and, particularly ,not punishing those whose experiments fail. \nWill all this reorganization and culture tweaking make big firms more creative? David Post, the founder of Umagic, isn''t so sure:’ He also recalls with glee the looks of total incomprehension when he tried to sell his ''virtual experts '' idea three years ago to firms such IBM , though ,as he cheerfully adds,’ of course, they could have been right''. Apparently, innovation -unlike diet,fitness and parenting -is one area where a computer cannot tell you what to do.'
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
    'the methods some companies use to try to keep their most creative employees',
    'Choose the correct answer.',
    '{"info-q1": ["F", "f"]}'
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
    'a new way of getting help with your personal difficulties',
    'Choose the correct answer.',
    '{"info-q2": ["A", "a"]}'
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
    'how much investment goes into safeguarding the ideas of individuals',
    'Choose the correct answer.',
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
    'two examples of companies which have succeeded through being innovative',
    'Choose the correct answer.',
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
    'how some innovators manage to avoid spending large sums of money ontesting outtheir ideas',
    'Choose the correct answer.',
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
    'acommonly held opinion about product designers that needs to be provedwrong',
    'Choose the correct answer.',
    '{"info-q6": ["G", "g"]}'
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
    'thetargetofone large company that has changed its business focus',
    'Choose the correct answer.',
    '{"info-q7": ["F", "f"]}'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    8,
    'TRUE_FALSE_NOT_GIVEN',
    'READING',
    2,
    'UmagicSystems is an example of a new innovative company.',
    'Choose the correct answer.',
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
    'Amazonand Wal-Mart have exchangedsuccessfulideas on innovation.',
    'Choose the correct answer.',
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
    'Usingfinancial rewards to encourage innovation is an outdated practice.',
    'Choose the correct answer.',
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
    'M failed to understand David Post''s ''virtual experts’ idea.',
    'Choose the correct answer.',
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
    'MULTIPLE_CHOICE_SINGLE',
    'READING',
    2,
    'What point does the writer make about intellectual property?',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, 'C. (Missing label)', true);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    13,
    'MULTIPLE_CHOICE_SINGLE',
    'READING',
    2,
    'Peter Chemin is an example of someone who has realized that',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, 'A. (Missing label)', true);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    14,
    'MULTIPLE_CHOICE_SINGLE',
    'READING',
    2,
    'In conclusion, the writer suggests that',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, 'D. (Missing label)', true);


END$$;


COMMIT;