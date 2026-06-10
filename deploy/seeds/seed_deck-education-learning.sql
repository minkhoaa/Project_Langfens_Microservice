-- ============================================
-- Vocabulary Deck: Education & Learning
-- Category: ielts
-- Status: PUBLISHED
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DO $$
DECLARE
  deck_id uuid := 'a1000000-0000-4000-8000-000000000005';
  sys_user uuid := 'c0f680e7-ff83-469e-85b1-241ada48744e';
BEGIN

  INSERT INTO deck ("Id", "Slug", "UserId", "Title", "DescriptionMd", "Category", "Status", "CreatedAt", "UpdatedAt")
  VALUES (
    deck_id,
    'ielts-education-learning',
    sys_user,
    'IELTS Education & Learning',
    'Essential vocabulary for discussing schooling, higher education, teaching methods, and lifelong learning — one of the most common IELTS topics.',
    'ielts',
    'PUBLISHED',
    NOW(),
    NOW()
  )
  ON CONFLICT ("Id") DO UPDATE SET
    "Title" = EXCLUDED."Title",
    "DescriptionMd" = EXCLUDED."DescriptionMd",
    "Status" = EXCLUDED."Status",
    "UpdatedAt" = NOW();

  DELETE FROM card WHERE "DeckId" = deck_id;

  INSERT INTO card ("Id", "DeckId", "Idx", "FrontMd", "BackMd", "HintMd") VALUES
  (gen_random_uuid(), deck_id, 1,
    '**Curriculum**',
    'The subjects comprising a course of study in a school or college.\n\n*Example:* The national curriculum should include more practical skills.',
    'Noun — set of subjects taught'),
  (gen_random_uuid(), deck_id, 2,
    '**Pedagogy**',
    'The method and practice of teaching.\n\n*Example:* Modern pedagogy emphasises student-centred learning.',
    'Noun — teaching methods'),
  (gen_random_uuid(), deck_id, 3,
    '**Academic achievement**',
    'The extent to which a student has attained their educational goals.\n\n*Example:* Academic achievement is influenced by both home and school environments.',
    'Noun phrase — educational success'),
  (gen_random_uuid(), deck_id, 4,
    '**Critical thinking**',
    'The objective analysis of an issue in order to form a judgement.\n\n*Example:* Universities should develop students'' critical thinking skills.',
    'Noun phrase — analytical reasoning'),
  (gen_random_uuid(), deck_id, 5,
    '**Rote learning**',
    'Memorisation technique based on repetition.\n\n*Example:* Rote learning is effective for vocabulary but not for understanding concepts.',
    'Noun phrase — learning by memorising'),
  (gen_random_uuid(), deck_id, 6,
    '**Extracurricular**',
    'Activities pursued in addition to the normal course of study.\n\n*Example:* Extracurricular activities help students develop social skills.',
    'Adjective — outside the classroom'),
  (gen_random_uuid(), deck_id, 7,
    '**Literacy**',
    'The ability to read and write.\n\n*Example:* Digital literacy is now considered as important as traditional literacy.',
    'Noun — reading/writing ability'),
  (gen_random_uuid(), deck_id, 8,
    '**Scholarship**',
    'A grant or payment made to support a student''s education.\n\n*Example:* She received a full scholarship to study at Oxford.',
    'Noun — financial aid for study'),
  (gen_random_uuid(), deck_id, 9,
    '**Vocational training**',
    'Education that prepares people for a specific trade or craft.\n\n*Example:* Vocational training in plumbing and carpentry is in high demand.',
    'Noun phrase — job-specific training'),
  (gen_random_uuid(), deck_id, 10,
    '**Lifelong learning**',
    'The ongoing, voluntary, and self-motivated pursuit of knowledge.\n\n*Example:* Lifelong learning is essential in a rapidly changing job market.',
    'Noun phrase — continuous education'),
  (gen_random_uuid(), deck_id, 11,
    '**Tuition**',
    'A sum of money charged for teaching by a school, college, or university.\n\n*Example:* Rising tuition fees prevent many students from attending university.',
    'Noun — fee for education'),
  (gen_random_uuid(), deck_id, 12,
    '**Plagiarism**',
    'The practice of taking someone else''s work or ideas and passing them as one''s own.\n\n*Example:* Universities have strict policies against plagiarism.',
    'Noun — copying others'' work');
END $$;
COMMIT;
