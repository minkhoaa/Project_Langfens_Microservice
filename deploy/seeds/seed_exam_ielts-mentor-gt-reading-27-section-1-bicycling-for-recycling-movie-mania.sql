-- ============================================
-- IELTS Exam Data Import SQL
-- Generated: 2025-12-21T01:15:31.110506
-- Source: ielts-mentor.com
-- Title: GT Reading 27 Section 1 - Bicycling for Recycling & Movie Mania
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data for slug: ielts-mentor-gt-reading-27-section-1-bicycling-for-recycling-movie-mania
DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'ielts-mentor-gt-reading-27-section-1-bicycling-for-recycling-movie-mania'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'ielts-mentor-gt-reading-27-section-1-bicycling-for-recycling-movie-mania';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'ielts-mentor-gt-reading-27-section-1-bicycling-for-recycling-movie-mania';
DELETE FROM exams
WHERE "Slug" = 'ielts-mentor-gt-reading-27-section-1-bicycling-for-recycling-movie-mania';

DO $$
DECLARE
  exam_id uuid := gen_random_uuid();
  sec1 uuid := gen_random_uuid();
  qid uuid;
BEGIN

  INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","UpdatedAt")
  VALUES (
    exam_id,
    'ielts-mentor-gt-reading-27-section-1-bicycling-for-recycling-movie-mania',
    'GT Reading 27 Section 1 - Bicycling for Recycling & Movie Mania',
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
    'Reading Passage - GT Reading 27 Section 1 - Bicycling for Recycling & Movie Mania',
    E'# Passage\n\n# Bicycling for Recycling & Movie Mania – Upcoming Films\n\n**Paragraph A.**\nAfter the remarkable achievements of last year, we have again organised a Bicycle Rally to promote the recycling of resources and usage of recycled goods for the protection of our environment. Unlike last year, this year, the rally will start in Werribee and will cover a slightly shorter 45-kilometre route. The reduction in distance is due to the new area being quite hilly!\n\n**Paragraph B.**\nThis year we have set ourselves the goal of raising £50,000 for our worthy cause. To help us do this, we have invited sponsorship from 20 large, commercial companies. If you would like to suggest a sponsor that we might not have considered, please contact us – there is no minimum donation amount. The funds raised will be used to launch our Recycled Resources, Recycled Goods countrywide awareness program in the coming months. We have also contacted numerous social organisations who will help us to best utilise the funds raised. We will provide all support to participants including arranging bicycles for those who do not have one, all safety measures throughout the route, food, drinks and transportation to and from Werribee - Western, Northern and Southern suburbs will be covered. Here are the particulars: DATE: 16 June 2007 START TIME: 8 AM START POINT: Werribee FINISH: Beacon Park COST: £12 Channel 2 has agreed to be our media partner and will telecast the entire rally. Don’t miss your chance to be on national TV! You are also invited to attend a post-rally press conference at the National Press Auditorium. Contact G. Jaisin on 0425 652 254 for more details.\n\n**Paragraph C.**\nEnquiry and Assistance: • General enquiries are welcome any time. • Sponsorship enquiries – at least 7 days prior to the rally. • Any special needs, call during business hours – 021 254 256 231. Safety measures: The route has five designated checkpoints – Werribee, Mentone, Parade Ground, William Port and Beacon Park. The first half of the route from Werribee to the Parade Ground passes through Bush Park and continues along the Eastern Coast. This section is quite isolated so we will establish emergency stops and drink booths with greater frequency. Each booth staff member will be issued with communication equipment to report any emergency situation from all remote areas. All emergency assistance, including paramedics, will be on standby. Accessories: Considering the unpredictable weather during this season you should be prepared for all conditions. This means being prepared for all climatic possibilities! All participants are advised to do a complete check of their bike brakes and gears prior to the start of the rally. Our bike mechanics will be on hand at the starting point 2 hours prior to the start of the rally. This service is free for all participants. Photo session: The finishing line at the north gate of Beacon Park will have a stage with a backdrop containing our Recycled Resources, Recycled Goods slogan. All the participants, upon finishing, will receive a bouquet and individual placard – both highlighting our recycling message. There will be a photo session involving all the participants. Photos will be forwarded to the local newspapers with a press release. This year we have decided to put a Support Book at the finishing point. We encourage you to sign the book and express your views on our rally theme or any other feedback you may care to provide. We are planning to forward all comments to the respective government policymakers as well as to the Ministry of Environment. Thanks in advance for your support and see you on the big day! G. Jaisin President, Rally Committee\n\n**Paragraph D.**\nA. Friends (June 1st) A group of friends go on a vacation together. They book a hotel and, upon arrival, discover that due to a misunderstanding, their booking got cancelled. In a new and strange city, they determine to spend the whole night on the street. They meet some peculiar people and observe unusual behaviours not seen during the daytime. A lot of laughs throughout! B. Four Feet (June 7th) An animation-based fantasy film where animals take control of a city. Excellent special effects, hilarious scenarios and even some commentary about the environment! The animal’s adventures put human beings into some difficult situations. In the home or office, in markets and on the streets, the animals make the rules - although a friendly understanding between animal and man enables both to co-exist…eventually! C. House Story (June 14th) A rich family buys a large country-house and discovers the existence of pre-historic residents! With pre-history meeting modern history, the clever plot intrigues from start to finish. People from the past keep visiting the everyday environment of the family in the house. The suspense in this supernatural thriller comes to a climax in a most interesting way. D. Runner (June 21st) Peter Goode has made a commitment to literally run around the world. The final leg of his journey involves running from New Mexico to Kansas, USA. Apparent mysteries stop him from time to time, but Peter’s will proves there is a way and we learn that not every life is filled with fun. Experience Peter’s struggles and the lengths to which one man will go to keep his word. E. Silver Ring (June 28th) A true romantic story of a young couple who aspire to wealth in order to lead a happy life. Dedicated to Allison Walsh and based on her bestselling novel, this film shows that money and happiness are not necessarily linked. Abstract love and affection on one side and material need and want on another – which side must this young couple take? F. The Creatures (July 5th) This is a documentary film sponsored by The Zoological Society. The film focuses on Global Warming and its effects on wild animals. Full of interesting facts and some expert interviews. Shot in the deep forests of the world. Incredible wild animal action adds real excitement to the film. Real-life footage in digital surround sound. G. The Trigger (July 12th) Having learned of the disappearance of two children, a retired detective undertakes a mission to locate them. They are eventually found by the detective, living in a small town in Italy. Although missing, the kids believe that they are still very much in their normal living environment. These American kids know Italy lane by lane and can speak the local dialect fluently. Nobody ever taught them the language. From beginning to end, unexplained occurrences keep the viewer guessing to the end.'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    1,
    'TRUE_FALSE_NOT_GIVEN',
    'READING',
    2,
    'Last year’s bike rally was a great success.',
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
    2,
    'TRUE_FALSE_NOT_GIVEN',
    'READING',
    2,
    'Compared to last year’s route, this year’s is longer.',
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
    3,
    'TRUE_FALSE_NOT_GIVEN',
    'READING',
    2,
    'Larger donations are expected from commercial companies.',
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
    4,
    'TRUE_FALSE_NOT_GIVEN',
    'READING',
    2,
    'Individual sponsors can donate any amount.',
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
    5,
    'TRUE_FALSE_NOT_GIVEN',
    'READING',
    2,
    'Participants are invited to attend a press conference before the date of the rally.',
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
    6,
    'TRUE_FALSE_NOT_GIVEN',
    'READING',
    2,
    'Emergency support will NOT be available in isolated areas.',
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
    7,
    'TRUE_FALSE_NOT_GIVEN',
    'READING',
    2,
    'Some government officials will be present at the end-point of the rally.',
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
    8,
    'MATCHING_INFORMATION',
    'READING',
    2,
    'This film is based on a book.',
    'Choose the correct answer.',
    '{"info-q8": ["E", "e"]}'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    9,
    'MULTIPLE_CHOICE_MULTIPLE',
    'READING',
    2,
    'These TWO films are all about mysteries.',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. Friends (June 1st)', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. The Submarine (June 8th)', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. Ghost Rider (June 15th)', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D. The Promise (June 22nd)', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, 'E. Scary Stuff (June 29th)', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 6, 'F. Speak to the Animals (June 30th)', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 7, 'G. Whodunnit? (June 30th)', true);

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    10,
    'MATCHING_INFORMATION',
    'READING',
    2,
    'This film is based on imaginary animal behaviour.',
    'Choose the correct answer.',
    '{"info-q10": ["B", "b"]}'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    11,
    'MATCHING_INFORMATION',
    'READING',
    2,
    'This film demonstrates the importance of keeping a promise.',
    'Choose the correct answer.',
    '{"info-q11": ["D", "d"]}'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    12,
    'MATCHING_INFORMATION',
    'READING',
    2,
    'This film focuses on environmental issues.',
    'Choose the correct answer.',
    '{"info-q12": ["F", "f"]}'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    13,
    'MATCHING_INFORMATION',
    'READING',
    2,
    'The need to choose is a focus of this film.',
    'Choose the correct answer.',
    '{"info-q13": ["E", "e"]}'
  );

  qid := gen_random_uuid();
  INSERT INTO exam_questions ("Id","SectionId","Idx","Type","Skill","Difficulty","PromptMd","ExplanationMd","MatchPairs")
  VALUES (
    qid,
    sec1,
    14,
    'MULTIPLE_CHOICE_MULTIPLE',
    'READING',
    2,
    'These TWO films will best entertain a fun-loving audience.',
    'Choose the correct answer.',
    NULL
  );
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 1, 'A. Friends (June 1st)', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 2, 'B. The Submarine (June 8th)', true);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 3, 'C. Ghost Rider (June 15th)', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 4, 'D. The Promise (June 22nd)', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 5, 'E. Scary Stuff (June 29th)', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 6, 'F. Speak to the Animals (June 30th)', false);
  INSERT INTO exam_options ("Id","QuestionId","Idx","ContentMd","IsCorrect") VALUES (gen_random_uuid(), qid, 7, 'G. Whodunnit? (June 30th)', false);


END$$;


COMMIT;