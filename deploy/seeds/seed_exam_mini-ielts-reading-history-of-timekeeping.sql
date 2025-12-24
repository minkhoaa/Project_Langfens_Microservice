-- ============================================
-- IELTS Exam Data Import SQL
-- Generated: 2025-12-24T13:44:59.594719
-- Source: mini-ielts.com
-- Title: History of timekeeping
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data for slug: mini-ielts-reading-history-of-timekeeping
DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'mini-ielts-reading-history-of-timekeeping'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'mini-ielts-reading-history-of-timekeeping';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'mini-ielts-reading-history-of-timekeeping';
DELETE FROM exams
WHERE "Slug" = 'mini-ielts-reading-history-of-timekeeping';

DO $$
DECLARE
  exam_id uuid := gen_random_uuid();
  sec1 uuid := gen_random_uuid();
  qid uuid;
BEGIN

  INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","ImageUrl","UpdatedAt")
  VALUES (
    exam_id,
    'mini-ielts-reading-history-of-timekeeping',
    'History of timekeeping',
    'IELTS Reading Practice Test from IELTS Mentor',
    'IELTS',
    'B2',
    'PUBLISHED',
    20,
    'http://images.mini-ielts.com/images/2022/15/history-of-timekeeping_resized.jpg',
    now()
  );

  INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","PassageMd")
  VALUES (
    sec1,
    exam_id,
    1,
    'Reading Passage - History of timekeeping',
    E'**Questions 1-4:**\nDo the following statements agree with the claims of the writer?\n\nWrite\n- **YES** if the statement agrees with the claims of the writer\n- **NO** if the statement contradicts the claims of the writer\n- **NOT GIVEN** if it is impossible to say what the writer thinks about this\n\n---\n\n**Questions 5-10:**\nWhich section contains the following information?\n\nWrite the correct letter, **A-L**.\n\n---\n\n**Questions 11-13:**\nChoose the correct letter, **A**, **B**, **C** or **D**.',
    E'**Paragraph A.**\\nEver since man first noticed the regular movement of the Sun and the stars, we have wondered about the passage of time. Prehistoric people first recorded the phases of the Moon some 30,000 years ago, and recording time has been a way by which humanity has observed the heavens and represented the progress of civilization.\\n\\n**Paragraph B.**\\nThe earliest natural events to be recognized were in the heavens, but during the course of the year, there were many other events that indicated significant changes in the environment. Seasonal winds and rains, the flooding of rivers, the flowering of trees and plants, and the breeding cycles or migration of animals and birds, all led to natural divisions of the year, and further observation and local customs led to the recognition of the seasons.\\n\\n**Paragraph C.**\\nEgyptian shadow clocks divided daytime into 12 parts with each part further divided into more precise parts. One type of shadow clock consisted of a long stem with five variable marks and an elevated crossbar which cast a shadow over those marks. It was positioned eastward in the morning and was turned west at noon. Obelisks functioned in much the same manner: the shadow cast on the markers around it allowed the Egyptians to calculate the time. The obelisk also indicated whether it was morning or afternoon, as well as the summer and winter solstices. 1500 BCE, was similar in shape to a bent T-square. It measured the passage of time by the shadow cast by its crossbar on a non-linear rule. The T was oriented eastward in the mornings and turned around at noon so that it could cast its shadow in the opposite direction. Although accurate, shadow clocks relied on the sun, and so were useless at night and in cloudy weather.\\n\\n**Paragraph D.**\\nThe early inventions were made to divide the day or the night into different periods in order to regulate work or ritual, so the lengths of the time periods varied greatly from place to place and from one culture to another.\\n\\n**Paragraph E.**\\nThere is archaeological evidence of oil lamps about 4,000 BCE, and the Chinese were using oil for heating and lighting by 2,000 BCE. Oil lamps are still significant in religious practices, symbolic of the journey from darkness and ignorance to light and knowledge. The shape of the lamp gradually evolved into the typical pottery style shown. It was possible to devise a way of measuring the level in the oil reservoir to measure the passing of time.\\n\\n**Paragraph F.**\\nMarked candles were used for telling the time in China from the sixth century CE. There is a popular story that King Alfred the Great invented the candle clock, but we know they were in use in England from the tenth century CE. However, the rate of burning is subject to draughts, and the variable quality of the wax. Life oil lamps, candles were used to mark the passage of time from one event to another, rather than tell the time of day.\\n\\n**Paragraph G.**\\nThe water clock, or clepsydra, appears to have been invented about 1,500 BCE and was a device which relied on the steady flow of water from or into a container. Measurements could be marked on the container or on a receptacle for the water. In comparison with the candle or the oil lamp, the clepsydra was more reliable, but the water flow still depended on the variation of pressure from the head of water in the container.\\n\\n**Paragraph H.**\\nAstronomical and astrological clock making was developed in China from 200 to 1300 CE. Early Chinese clepsydras drove various mechanisms illustrating astronomical phenomena. The astronomer Su Sung and his associates built an elaborate clepsydra in 1088 CE. This device incorporated a water-driven bucket system originally invented about 725 CE. Among the displays were a bronze power-driven rotating celestial globe, and manikins that rang gongs, and indicated special times of the day.\\n\\n**Paragraph I.**\\nAs the technology of glass-blowing developed, from some time in the 14th century it became possible to make sandglasses. Originally, sandglasses were used as a measure for periods of time like the lamps or candles, but as clocks became more accurate they were used to calibrate sandglasses to measure specific periods of time, and to determine the duration of sermons, university lectures, and even periods of torture.\\n\\n**Paragraph J.**\\nThe Division of the Day and the Length of the ‘Hour’ An Egyptian sundial from about 1,500 BCE is the earliest evidence of the division of the day into equal parts, but the sundial was no use at night. The passage of time was extremely important for astronomers and priests who were responsible for determining the exact hour for the daily rituals and for the important religious festivals, so a water clock was invented.\\n\\n**Paragraph K.**\\nThe Egyptians improved upon the sundial with a ‘merkhet’, one of the oldest known astronomical instruments. It was developed around 600 BCE and uses a string with a weight as a plumb line to obtain a true vertical line, as in the picture. The other object is the rib of a palm leaf, stripped of its fronds and split at one end, making a thin slit for a sight.\\n\\n**Paragraph L.**\\nA pair of merkhets were used to establish a North-South direction by lining them up one behind the other with the Pole Star. Viewing the plumb lines through the sight made sure the two merkhets and the sight were in the same straight line with the Pole Star. This allowed for the measurement of night-time events with a water clock when certain stars crossed the vertical plumb line (a ‘transit line’), and these events could then be recorded by ‘night-time lines’ drawn on a sundial.\\n\\n**Paragraph M.**\\nThere are various theories about how the 24 hour day developed. The fact that the day was divided into 12 hours might be because 12 is a factor of 60, and both the Babylonian and Egyptian civilisations recognised a zodiac cycle of 12 constellations. On the other hand, (excuse the pun) finger-counting with base 12 was a possibility. The fingers each have 3 joints, and so counting on the joints gives one ‘full hand’ of 12.\\n\\n**Paragraph N.**\\nIn classical Greek and Roman times they used twelve hours from sunrise to sunset; but since summer days and winter nights are longer than winter days and summer nights, the lengths of the hours varied throughout the year.\\n\\n'
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
    'YESNONOT GIVENTimekeeper’s exact date of origin was not clear today.',
    '',
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
    2,
    'YES_NO_NOT_GIVEN',
    'READING',
    2,
    'YESNONOT GIVENPeople use candles and oil lamps for recording time to do things in the early days.',
    '',
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
    3,
    'YES_NO_NOT_GIVEN',
    'READING',
    2,
    'YESNONOT GIVENOil lamps are used for religious beliefs in 4000 BCE.',
    '',
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
    4,
    'TRUE_FALSE_NOT_GIVEN',
    'READING',
    2,
    'YESNONOT GIVENThe sundials have always been inaccurate to record time in ancient Egypt.',
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
    5,
    'MATCHING_INFORMATION',
    'READING',
    2,
    't is used the container tag position recording time',
    '',
    '{"info-q5": ["B", "b"]}'
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
    't is used to measure a particular time',
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
    't is used only in the sunny day',
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
    't is used oil cistern to measure the passage of time',
    '',
    '{"info-q8": ["C", "c"]}'
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
    't isn’t only used to tell the time',
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
    't is more accurate than candles and oil lamps',
    '',
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
    '11Which picture shows the working principle of clepsydra?',
    '',
    '{"info-q11": ["C", "c"]}'
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
    '12Which picture best describes the wooden shadow?',
    '',
    '{"info-q12": ["A", "a"]}'
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
    '13The picture below illustrates the oil lamp clock’s working',
    '',
    '{"info-q13": ["D", "d"]}'
  );


END$$;


COMMIT;