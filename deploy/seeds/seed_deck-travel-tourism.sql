-- ============================================
-- Vocabulary Deck: Travel & Tourism
-- Category: ielts
-- Status: PUBLISHED
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DO $$
DECLARE
  deck_id uuid := 'a1000000-0000-4000-8000-000000000006';
  sys_user uuid := 'c0f680e7-ff83-469e-85b1-241ada48744e';
BEGIN

  INSERT INTO deck ("Id", "Slug", "UserId", "Title", "DescriptionMd", "Category", "Status", "CreatedAt", "UpdatedAt")
  VALUES (
    deck_id,
    'ielts-travel-tourism',
    sys_user,
    'IELTS Travel & Tourism',
    'Vocabulary for discussing travel experiences, tourism impacts, and cultural exploration — essential for Speaking Part 2 and Writing Task 2.',
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
    '**Ecotourism**',
    'Tourism directed towards exotic, often threatened, natural environments, intended to support conservation efforts.\n\n*Example:* Ecotourism in Costa Rica has helped protect its rainforests.',
    'Noun — responsible travel'),
  (gen_random_uuid(), deck_id, 2,
    '**Itinerary**',
    'A planned route or journey; a list of places to visit.\n\n*Example:* Our itinerary included three cities in two weeks.',
    'Noun — travel plan'),
  (gen_random_uuid(), deck_id, 3,
    '**Heritage site**',
    'A place officially recognised for its cultural or natural significance.\n\n*Example:* Ha Long Bay is a UNESCO World Heritage Site.',
    'Noun phrase — protected landmark'),
  (gen_random_uuid(), deck_id, 4,
    '**Overcrowding**',
    'The condition of having more people than a place can comfortably hold.\n\n*Example:* Overcrowding in Venice has led to restrictions on tourist numbers.',
    'Noun — too many visitors'),
  (gen_random_uuid(), deck_id, 5,
    '**Off the beaten track**',
    'In or to a place where few people go; away from popular routes.\n\n*Example:* We found a wonderful restaurant off the beaten track.',
    'Idiom — not a tourist hotspot'),
  (gen_random_uuid(), deck_id, 6,
    '**Sustainable tourism**',
    'Tourism that takes full account of its current and future economic, social, and environmental impacts.\n\n*Example:* Sustainable tourism aims to minimise negative effects on local communities.',
    'Noun phrase — responsible tourism'),
  (gen_random_uuid(), deck_id, 7,
    '**Cultural immersion**',
    'Deep involvement in the culture and daily life of a foreign place.\n\n*Example:* Homestays provide a richer cultural immersion than hotels.',
    'Noun phrase — experiencing local culture'),
  (gen_random_uuid(), deck_id, 8,
    '**Backpacking**',
    'Travelling with a backpack, typically on a low budget.\n\n*Example:* Backpacking through Southeast Asia is popular among young travellers.',
    'Noun — budget travel with a rucksack'),
  (gen_random_uuid(), deck_id, 9,
    '**Hospitality**',
    'The friendly and generous reception and entertainment of guests.\n\n*Example:* Vietnamese hospitality is renowned among international tourists.',
    'Noun — welcoming behaviour'),
  (gen_random_uuid(), deck_id, 10,
    '**Souvenir**',
    'A thing that is kept as a reminder of a person, place, or event.\n\n*Example:* I bought a handmade scarf as a souvenir from my trip to Scotland.',
    'Noun — travel memento'),
  (gen_random_uuid(), deck_id, 11,
    '**Local cuisine**',
    'The style of cooking and food that is traditional in a particular region.\n\n*Example:* Sampling the local cuisine is one of the best parts of travelling.',
    'Noun phrase — regional food'),
  (gen_random_uuid(), deck_id, 12,
    '**Jet lag**',
    'Extreme tiredness felt after a long flight across different time zones.\n\n*Example:* It took me three days to recover from jet lag after flying to New York.',
    'Noun — tiredness from time zones');
END $$;
COMMIT;
