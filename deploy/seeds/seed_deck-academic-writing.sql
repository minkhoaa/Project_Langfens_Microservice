-- ============================================
-- Vocabulary Deck: Academic Writing Essentials
-- Category: ielts
-- Status: PUBLISHED
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DO $$
DECLARE
  deck_id uuid := 'a1000000-0000-4000-8000-000000000001';
  sys_user uuid := 'c0f680e7-ff83-469e-85b1-241ada48744e';
BEGIN

  -- Upsert deck
  INSERT INTO deck ("Id", "Slug", "UserId", "Title", "DescriptionMd", "Category", "Status", "CreatedAt", "UpdatedAt")
  VALUES (
    deck_id,
    'ielts-academic-writing-essentials',
    sys_user,
    'IELTS Academic Writing Essentials',
    'Core vocabulary for IELTS Writing Task 2 — linking words, hedging language, and academic expressions that boost your Coherence & Lexical Resource scores.',
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

  -- Remove old cards for this deck
  DELETE FROM card WHERE "DeckId" = deck_id;

  -- Cards
  INSERT INTO card ("Id", "DeckId", "Idx", "FrontMd", "BackMd", "HintMd") VALUES
  (gen_random_uuid(), deck_id, 1,
    '**Furthermore**',
    'In addition; moreover.\n\n*Example:* Furthermore, the evidence suggests that early intervention yields better outcomes.',
    'Linking word — adds a supporting point'),
  (gen_random_uuid(), deck_id, 2,
    '**Nevertheless**',
    'In spite of that; however.\n\n*Example:* The study was small; nevertheless, its findings are significant.',
    'Linking word — introduces a contrast'),
  (gen_random_uuid(), deck_id, 3,
    '**Consequently**',
    'As a result.\n\n*Example:* He failed to prepare; consequently, he performed poorly.',
    'Linking word — shows cause and effect'),
  (gen_random_uuid(), deck_id, 4,
    '**Substantiate**',
    'To provide evidence to support or prove the truth of something.\n\n*Example:* The researcher could not substantiate her claims with data.',
    'Academic verb — formal for "prove"'),
  (gen_random_uuid(), deck_id, 5,
    '**Predominantly**',
    'Mainly; for the most part.\n\n*Example:* The workforce is predominantly female in this sector.',
    'Adverb — indicates majority'),
  (gen_random_uuid(), deck_id, 6,
    '**Detrimental**',
    'Causing harm or damage.\n\n*Example:* Excessive screen time can be detrimental to children''s development.',
    'Adjective — formal for "harmful"'),
  (gen_random_uuid(), deck_id, 7,
    '**Mitigate**',
    'To make something less severe or harmful.\n\n*Example:* Governments should take steps to mitigate the effects of climate change.',
    'Academic verb — reduce negative impact'),
  (gen_random_uuid(), deck_id, 8,
    '**Pivotal**',
    'Of crucial importance.\n\n*Example:* Education plays a pivotal role in social mobility.',
    'Adjective — very important'),
  (gen_random_uuid(), deck_id, 9,
    '**Corroborate**',
    'To confirm or give support to a statement or theory.\n\n*Example:* The witness corroborated the defendant''s account of events.',
    'Academic verb — confirm with evidence'),
  (gen_random_uuid(), deck_id, 10,
    '**Inevitably**',
    'As is certain to happen; unavoidably.\n\n*Example:* Rapid urbanisation inevitably leads to housing shortages.',
    'Adverb — something that must happen'),
  (gen_random_uuid(), deck_id, 11,
    '**A plethora of**',
    'A large or excessive amount of.\n\n*Example:* A plethora of research has been conducted on this topic.',
    'Phrase — means "a lot of" (formal)'),
  (gen_random_uuid(), deck_id, 12,
    '**Conversely**',
    'Introducing a statement or idea that reverses the one before.\n\n*Example:* Urban areas offer more jobs. Conversely, rural areas provide a better quality of life.',
    'Linking word — introduces opposite view');
END $$;
COMMIT;
