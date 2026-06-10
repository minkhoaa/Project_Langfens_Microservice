-- ============================================
-- Vocabulary Deck: IELTS Speaking Conversations
-- Category: speaking
-- Status: PUBLISHED
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DO $$
DECLARE
  deck_id uuid := 'a1000000-0000-4000-8000-000000000010';
  sys_user uuid := 'c0f680e7-ff83-469e-85b1-241ada48744e';
BEGIN

  INSERT INTO deck ("Id", "Slug", "UserId", "Title", "DescriptionMd", "Category", "Status", "CreatedAt", "UpdatedAt")
  VALUES (
    deck_id,
    'ielts-speaking-conversations',
    sys_user,
    'IELTS Speaking Conversations',
    'Natural phrases and expressions for IELTS Speaking Parts 1-3 — fillers, opinion starters, hedging language, and idiomatic expressions that boost fluency scores.',
    'speaking',
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
    '**To be honest...**',
    'Used to introduce an honest opinion, often one that is slightly negative.\n\n*Example:* To be honest, I find public speaking quite nerve-wracking.',
    'Opinion starter — Part 1 & 3'),
  (gen_random_uuid(), deck_id, 2,
    '**I''d have to say...**',
    'A natural way to begin an answer, buying thinking time.\n\n*Example:* I''d have to say that my hometown has changed a lot in recent years.',
    'Fluency filler — sounds natural'),
  (gen_random_uuid(), deck_id, 3,
    '**It''s on the tip of my tongue**',
    'Used when you almost remember something but can''t quite recall it.\n\n*Example:* What''s the name of that restaurant? It''s on the tip of my tongue.',
    'Idiom — almost remember'),
  (gen_random_uuid(), deck_id, 4,
    '**By and large**',
    'On the whole; generally speaking.\n\n*Example:* By and large, I think the education system works well.',
    'Phrase — generally, mostly'),
  (gen_random_uuid(), deck_id, 5,
    '**Having said that...**',
    'Used to introduce a contrasting point after stating something.\n\n*Example:* The city is beautiful. Having said that, it can be very expensive.',
    'Contrast phrase — Part 3'),
  (gen_random_uuid(), deck_id, 6,
    '**I''m quite keen on...**',
    'A natural way to express enthusiasm for something.\n\n*Example:* I''m quite keen on photography — I take my camera everywhere.',
    'Expressing preference — Part 1'),
  (gen_random_uuid(), deck_id, 7,
    '**A blessing in disguise**',
    'Something that seems bad at first but turns out to be good.\n\n*Example:* Losing that job was a blessing in disguise — I found a much better one.',
    'Idiom — good from bad'),
  (gen_random_uuid(), deck_id, 8,
    '**I''m inclined to think...**',
    'A hedged way to express your opinion, showing sophistication.\n\n*Example:* I''m inclined to think that technology has done more good than harm.',
    'Hedging — sounds academic'),
  (gen_random_uuid(), deck_id, 9,
    '**Once in a blue moon**',
    'Very rarely.\n\n*Example:* I only eat fast food once in a blue moon.',
    'Idiom — very rarely'),
  (gen_random_uuid(), deck_id, 10,
    '**It boils down to...**',
    'The most important or basic aspect of something.\n\n*Example:* Success in language learning really boils down to consistent practice.',
    'Phrase — the key point is...'),
  (gen_random_uuid(), deck_id, 11,
    '**I couldn''t agree more**',
    'Complete agreement with someone''s opinion.\n\n*Example:* I couldn''t agree more — public transport should be free for students.',
    'Strong agreement — Part 3'),
  (gen_random_uuid(), deck_id, 12,
    '**At the end of the day**',
    'Used to give the most important fact or reason after considering everything.\n\n*Example:* At the end of the day, it''s your decision to make.',
    'Phrase — ultimately, in conclusion');
END $$;
COMMIT;
