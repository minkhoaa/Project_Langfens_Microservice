BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup old sample rows
DELETE FROM attempt_answer WHERE "AttemptId" IN (
  SELECT a."Id" FROM attempts a WHERE a."UserId" IN (
    '11111111-1111-1111-1111-111111111111','33333333-3333-3333-3333-333333333333'
  )
);
DELETE FROM attempts WHERE "UserId" IN (
  '11111111-1111-1111-1111-111111111111','33333333-3333-3333-3333-333333333333'
);
-- Also cleanup the specific demo attempt if exists
DELETE FROM attempt_answer WHERE "AttemptId" = '00000000-0000-0000-0000-00000000aa01';
DELETE FROM attempts       WHERE "Id"        = '00000000-0000-0000-0000-00000000aa01';

-- Recreate the specific demo attempt with 2 answers
INSERT INTO attempts (
  "Id", "UserId", "ExamId", "DurationSec", "StartedAt", "SubmittedAt", "GradedAt",
  "RawScore", "ScaledScore", "CreatedAt", "UpdatedAt", "PaperJson", "status"
) VALUES (
  '00000000-0000-0000-0000-00000000aa01',
  '11111111-1111-1111-1111-111111111111',
  'e9a1353a-cc2c-4fe1-9b19-13b7c4a4c101',
  900,
  now() - interval '20 minutes',
  now() - interval '5 minutes',
  now() - interval '3 minutes',
  10.00,
  6.50,
  now() - interval '20 minutes',
  now() - interval '3 minutes',
  NULL,
  'SUBMITTED'
);
INSERT INTO attempt_answer (
  "Id", "AttemptId", "SectionId", "QuestionId", "SelectedOptionIds", "TextAnswer", "IsCorrect", "AwardedPoints"
) VALUES (
  '00000000-0000-0000-0000-00000000bb01',
  '00000000-0000-0000-0000-00000000aa01',
  '9a414f37-6cce-4f3c-9e12-0c3b79c3d101',
  'f1019b8f-8a5f-4a7a-8e7e-111111111101',
  ARRAY['a1010001-0000-0000-0000-000000000001']::uuid[],
  NULL,
  TRUE,
  1.00
), (
  '00000000-0000-0000-0000-00000000bb02',
  '00000000-0000-0000-0000-00000000aa01',
  '9a414f37-6cce-4f3c-9e12-0c3b79c3d101',
  'f1019b8f-8a5f-4a7a-8e7e-111111111102',
  ARRAY['a1010002-0000-0000-0000-000000000002']::uuid[],
  NULL,
  TRUE,
  1.00
);

-- Bulk-generate 60 additional attempts across two users with varied statuses
DO $$
DECLARE
  i int;
  uid uuid;
  aid uuid;
  st text;
BEGIN
  FOR i IN 1..60 LOOP
    uid := CASE WHEN (i % 2 = 0) THEN '11111111-1111-1111-1111-111111111111'::uuid ELSE '33333333-3333-3333-3333-333333333333'::uuid END;
    st := CASE (i % 3) WHEN 0 THEN 'SUBMITTED' WHEN 1 THEN 'IN_PROGRESS' ELSE 'GRADED' END;
    aid := gen_random_uuid();
    INSERT INTO attempts ("Id","UserId","ExamId","DurationSec","StartedAt","SubmittedAt","GradedAt","RawScore","ScaledScore","CreatedAt","UpdatedAt","PaperJson","status")
    VALUES (
      aid, uid, gen_random_uuid(), 3600,
      now() - ((i||' hours')::interval),
      CASE WHEN st IN ('SUBMITTED','GRADED') THEN now() - ((i-1)||' hours')::interval ELSE NULL END,
      CASE WHEN st = 'GRADED' THEN now() - ((i-2)||' hours')::interval ELSE NULL END,
      CASE WHEN st = 'GRADED' THEN (10 + (i % 20))::decimal ELSE NULL END,
      CASE WHEN st = 'GRADED' THEN (5 + (i % 4))::decimal ELSE NULL END,
      now() - ((i||' hours')::interval), now(), NULL, st
    );
  END LOOP;
END$$;

COMMIT;
