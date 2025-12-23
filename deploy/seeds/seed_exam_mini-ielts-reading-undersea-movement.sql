-- ============================================
-- IELTS Exam Data Import SQL
-- Generated: 2025-12-24T03:35:57.042530
-- Source: mini-ielts.com
-- Title: Undersea Movement
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup existing data for slug: mini-ielts-reading-undersea-movement
DELETE FROM exam_options WHERE "QuestionId" IN (
  SELECT q."Id" FROM exam_questions q
  JOIN exam_sections s ON s."Id" = q."SectionId"
  JOIN exams e ON e."Id" = s."ExamId"
  WHERE e."Slug" = 'mini-ielts-reading-undersea-movement'
);
DELETE FROM exam_questions USING exam_sections s, exams e
WHERE exam_questions."SectionId" = s."Id"
  AND s."ExamId" = e."Id"
  AND e."Slug" = 'mini-ielts-reading-undersea-movement';
DELETE FROM exam_sections USING exams e
WHERE exam_sections."ExamId" = e."Id"
  AND e."Slug" = 'mini-ielts-reading-undersea-movement';
DELETE FROM exams
WHERE "Slug" = 'mini-ielts-reading-undersea-movement';

DO $$
DECLARE
  exam_id uuid := gen_random_uuid();
  sec1 uuid := gen_random_uuid();
  qid uuid;
BEGIN

  INSERT INTO exams ("Id","Slug","Title","DescriptionMd","Category","Level","Status","DurationMin","ImageUrl","UpdatedAt")
  VALUES (
    exam_id,
    'mini-ielts-reading-undersea-movement',
    'Undersea Movement',
    'IELTS Reading Practice Test from IELTS Mentor',
    'IELTS',
    'B2',
    'PUBLISHED',
    20,
    'https://res.cloudinary.com/df41zs8il/image/upload/v1766530827/ielts/undersea-movement_resized_08eaeaa0d01f.jpg',
    now()
  );

  INSERT INTO exam_sections ("Id","ExamId","Idx","Title","InstructionsMd","PassageMd")
  VALUES (
    sec1,
    exam_id,
    1,
    'Reading Passage - Undersea Movement',
    E'**Questions 1-6:**\nWhich section contains the following information?\n\nWrite the correct letter, **A-L**.\n\n---\n\n**Questions 7-13:**\nComplete the sentences below.\n\nWrite **NO MORE THAN TWO WORDS AND/OR A NUMBER** for each answer.',
    E'**Paragraph A.**\\nThe underwater world holds many challenges. The most basic of these is movement. The density of water makes it difficult for animals to move. Forward movement is a complex interaction of underwater forces. Additionally, water itself has movement. Strong currents carry incredible power that can easily sweep creatures away. The challenges to aquatic movement result in a variety of swimming methods, used by a wide range of animals. The result is a dazzling underwater ballet.\\n\\n**Paragraph B.**\\nFish rely on their skeleton, fins, and muscles to move. The primary function of the skeleton is to aid movement of other parts. Their skull acts as a fulcrum and their vertebrae act as levers. The vertebral column consists of a series of vertebrae held together by ligaments, but not so tightly as to prevent slight sideways movement between each pair of vertebrae. The whole spine is, therefore, flexible. The skull is the only truly fixed part of a fish. It does not move in and off itself but acts as a point of stability for other bones. These other bones act as levers that cause movement of the fish’s body.\\n\\n**Paragraph C.**\\nWhile the bones provide the movement, the muscles supply the power. A typical fish has hundreds of muscles running in all directions around its body. This is why a fish can turn and twist and change directions quickly. The muscles on each side of the spine contract in a series from head to tail and down each side alternately, causing a wave-like movement to pass down the body. Such a movement may be very pronounced in fish such as eels, but hardly perceptible in others, e.g. mackerel. The frequency of the waves varies from about 50/min in the dogfish to 170/min in the mackerel. The sideways and backward thrust of the head and body against the water results in the resistance of the water pushing the fish sideways and forwards in a direction opposed to the thrust. When the corresponding set of muscles on the other side contracts, the fish experiences a similar force from the water on that side. The two sideways forces are equal and opposite unless the fish is making a turn, so they cancel out, leaving the sum of the two forward forces\\n\\n**Paragraph D.**\\nThe muscles involved in swimming are of two main types. The bulk of a fish’s body is composed of the so-called white muscle, while the much smaller areas at the roots of the fins and in a strip along the centre of each flank comprise red muscle. The red muscle receives a good supply of blood and contains ampler quantities of fat and glycogen, the storage form of glucose, which is used for most day-to-day swimming movements. In contrast, the white muscle has a poor blood supply and few energy stores, and it is used largely for short-term, fast swimming. It might seem odd that the body of an animal which adapts adapted so efficiently to its environment should be composed almost entirely of a type of muscle it rarely uses. However, this huge auxiliary power pack carried by a fish is of crucial significance if the life of the fish is threatened-by a predator, for instance-because it enables the fish to swim rapidly away from danger.\\n\\n**Paragraph E.**\\nThe fins are the most distinctive features of a fish, composed of bony spines protruding from the body with skin covering them and joining them together, either in a webbed fashion, as seen in most bony fish, or more similar to a flipper, as seen in sharks. These usually serve as a means for the fish to swim. But it must be emphasized that the swimming movements are produced by the whole of the muscular body, and in only a few fish do the fins contribute any propulsive force! Their main function is to control the stability and direction of the fish: as water passes over its body, a fish uses its fins to thrust in the direction it wishes to go.\\n\\n**Paragraph F.**\\nFins located in different places on a fish serve different purposes, such as moving forward, turning, and keeping an upright position. The tail fin, in its final lash may contribute as much as 40 per cent of the forward thrust. The median fins, that is, the dorsal, anal and ventral fins, control the rolling and yawing movements of the fish by increasing the vertical surface area presented to the water. The paired fins, pectoral and pelvic act as hydroplanes and control the pitch of the ash, causing it to swim downwards or upwards according to the angle to the water at which they are held by their muscles. The pectoral fins lie in front of the centre of gravity and, being readily mobile, are chiefly responsible for sending the ash up or down. The paired ins are also the means by which the fish slows down and stops.\\n\\n**Paragraph G.**\\nThe swimming speed of fish is not so fast as one would expect from watching their rapid movements in aquaria or ponds. Tuna seems to be the fastest at 44 mph, trout are recorded as doing 23 mph, pike 20 mph for short bursts and roach about 10 mph, while the majority of small fish probably do not exceed 2 or 3 mph. Many people have attempted to make accurate measurements of the speed at which various fish swim, either by timing them over known distances in their natural environment or by determining their performance in man-made swimming channels. From these studies, we can broadly categorise fish into four groups: “sneakers”, such as eels that are only capable of slow speeds but possess some staying power; “stayers”, that can swim quite fast over long periods; “sprinters” that can generate fast bursts of speed (e.g. pike); and “crawlers” that are sluggish swimmers, although they can accelerate slightly (bream, for example).\\n\\n**Paragraph H.**\\nOne type of sailfish is considered to be the fastest species of fish over short distances, achieving 68 mph over a three-second period, and anglers have recorded speeds in excess of 40 mph over longer periods for several species of tuna. One is likely to consider a fish’s swimming capabilities in relation to its size. However, it is generally true that a small fish is a more able swimmer than a much larger one. On the other hand in terms of speed in miles per hour, a big fish will, all other things being equal, be able to swim faster than a smaller fish.\\n\\n\n---\n\n## Images for Questions 7-10\n\n\n![Question 7-10 Option A](https://res.cloudinary.com/df41zs8il/image/upload/v1766531061/ielts/ielts-reading36_9c204ae773c0.jpg)\n'
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
    'categorizations of fish by swimming speed',
    '',
    '{"info-q1": ["G", "g"]}'
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
    'an example of fish capable of maintaining fast swimming for a long time',
    '',
    '{"info-q2": ["H", "h"]}'
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
    'how fish control stability',
    '',
    '{"info-q3": ["E", "e"]}'
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
    'frequency of the muscle movement of fish',
    '',
    '{"info-q4": ["C", "c"]}'
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
    'a mechanical model of fish skeleton',
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
    'energy storage devices in a fish',
    '',
    '{"info-q6": ["D", "d"]}'
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
    '_______',
    '',
    '{"blank-q7": ["FORWARD THRUST"]}'::jsonb
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
    '_______',
    '',
    '{"blank-q8": ["ROLLING AND YAWING"]}'::jsonb
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
    '_______',
    '',
    '{"blank-q9": ["PECTORAL AND PELVIC"]}'::jsonb
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
    '_______',
    '',
    '{"blank-q10": ["SLOWS AND STOPS"]}'::jsonb
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
    'The majority of a fish’s body comprises the _______ , and the red muscle is found only at the roots of the fins and in a strip along the centre of each flank.',
    '',
    '{"blank-q11": ["WHITE MUSCLE"]}'::jsonb
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
    'For most of its routine movements, the fish uses a lot of its _______ saved in body, and white muscle is mostly used for short-term, fast swimming, such as escaping from .',
    '',
    '{"blank-q12": ["FATS AND GLYCOGEN"]}'::jsonb
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
    'For most of its routine movements, the fish uses a lot of its saved in body, and white muscle is mostly used for short-term, fast swimming, such as escaping from _______ .',
    '',
    '{"blank-q13": ["PREDATOR"]}'::jsonb
  );


END$$;


COMMIT;