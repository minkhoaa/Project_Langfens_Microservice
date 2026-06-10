-- ============================================
-- Vocabulary Deck: Food & Nutrition
-- Category: ielts
-- Status: PUBLISHED
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DO $$
DECLARE
  deck_id uuid := 'a1000000-0000-4000-8000-000000000009';
  sys_user uuid := 'c0f680e7-ff83-469e-85b1-241ada48744e';
BEGIN

  INSERT INTO deck ("Id", "Slug", "UserId", "Title", "DescriptionMd", "Category", "Status", "CreatedAt", "UpdatedAt")
  VALUES (
    deck_id,
    'ielts-food-nutrition',
    sys_user,
    'IELTS Food & Nutrition',
    'Vocabulary for discussing food culture, nutrition science, organic farming, and dietary habits — a frequent topic in IELTS Speaking and Writing.',
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
    '**Organic food**',
    'Food produced without the use of synthetic pesticides, fertilisers, or genetically modified organisms.\n\n*Example:* Demand for organic food has increased significantly over the past decade.',
    'Noun phrase — natural, chemical-free food'),
  (gen_random_uuid(), deck_id, 2,
    '**Processed food**',
    'Food that has been altered from its natural state, often with added preservatives or chemicals.\n\n*Example:* A diet high in processed food is linked to various health problems.',
    'Noun phrase — industrially prepared food'),
  (gen_random_uuid(), deck_id, 3,
    '**Malnutrition**',
    'Lack of proper nutrition, caused by not having enough to eat or not eating the right foods.\n\n*Example:* Malnutrition remains a serious problem in many developing countries.',
    'Noun — poor nutrition'),
  (gen_random_uuid(), deck_id, 4,
    '**Culinary**',
    'Of or for cooking.\n\n*Example:* Bangkok is known for its vibrant culinary scene.',
    'Adjective — related to cooking'),
  (gen_random_uuid(), deck_id, 5,
    '**Food additive**',
    'A substance added to food to preserve it or improve its flavour, appearance, or texture.\n\n*Example:* Many consumers are concerned about the health effects of food additives.',
    'Noun phrase — added ingredient'),
  (gen_random_uuid(), deck_id, 6,
    '**Dietary fibre**',
    'The indigestible part of plant foods that aids digestion.\n\n*Example:* Whole grains are an excellent source of dietary fibre.',
    'Noun phrase — plant-based nutrient for digestion'),
  (gen_random_uuid(), deck_id, 7,
    '**Genetically modified**',
    'Having had genetic material altered through genetic engineering.\n\n*Example:* The debate over genetically modified crops continues worldwide.',
    'Adjective phrase — GMO'),
  (gen_random_uuid(), deck_id, 8,
    '**Staple food**',
    'A food that is eaten routinely and in such quantities that it constitutes a dominant portion of a diet.\n\n*Example:* Rice is the staple food in most Southeast Asian countries.',
    'Noun phrase — main food in a diet'),
  (gen_random_uuid(), deck_id, 9,
    '**Gastronomy**',
    'The practice or art of choosing, cooking, and eating good food.\n\n*Example:* French gastronomy is celebrated worldwide.',
    'Noun — art of fine dining'),
  (gen_random_uuid(), deck_id, 10,
    '**Preservative**',
    'A substance used to preserve food, preventing decomposition or fermentation.\n\n*Example:* Many people try to avoid products with artificial preservatives.',
    'Noun — keeps food fresh longer'),
  (gen_random_uuid(), deck_id, 11,
    '**Gluten-free**',
    'Containing no gluten, a protein found in wheat and related grains.\n\n*Example:* Gluten-free options are now widely available in most supermarkets.',
    'Adjective — without wheat protein'),
  (gen_random_uuid(), deck_id, 12,
    '**Farm-to-table**',
    'A movement where food is sourced directly from local farms to restaurants or consumers.\n\n*Example:* Farm-to-table restaurants emphasise fresh, locally sourced ingredients.',
    'Adjective phrase — local, direct sourcing');
END $$;
COMMIT;
