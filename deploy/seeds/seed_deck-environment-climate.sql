-- ============================================
-- Vocabulary Deck: Environment & Climate Change
-- Category: ielts
-- Status: PUBLISHED
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DO $$
DECLARE
  deck_id uuid := 'a1000000-0000-4000-8000-000000000002';
  sys_user uuid := 'c0f680e7-ff83-469e-85b1-241ada48744e';
BEGIN

  INSERT INTO deck ("Id", "Slug", "UserId", "Title", "DescriptionMd", "Category", "Status", "CreatedAt", "UpdatedAt")
  VALUES (
    deck_id,
    'ielts-environment-climate-change',
    sys_user,
    'IELTS Environment & Climate Change',
    'Essential vocabulary for discussing environmental issues, sustainability, and climate change — common IELTS Writing & Speaking topics.',
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
    '**Sustainable**',
    'Able to be maintained at a certain rate or level; avoiding the depletion of natural resources.\n\n*Example:* We need sustainable farming practices to feed future generations.',
    'Adjective — eco-friendly, long-term'),
  (gen_random_uuid(), deck_id, 2,
    '**Carbon footprint**',
    'The total amount of greenhouse gases produced directly and indirectly by human activities.\n\n*Example:* Flying has a much larger carbon footprint than taking the train.',
    'Noun phrase — environmental impact'),
  (gen_random_uuid(), deck_id, 3,
    '**Biodiversity**',
    'The variety of life in a particular habitat or ecosystem.\n\n*Example:* Deforestation threatens biodiversity in tropical rainforests.',
    'Noun — variety of species'),
  (gen_random_uuid(), deck_id, 4,
    '**Emission**',
    'The production and discharge of something, especially gas or radiation.\n\n*Example:* Car emissions are a major contributor to air pollution.',
    'Noun — release of pollutants'),
  (gen_random_uuid(), deck_id, 5,
    '**Renewable energy**',
    'Energy from a source that is not depleted when used, such as wind or solar power.\n\n*Example:* Solar and wind are the fastest-growing forms of renewable energy.',
    'Noun phrase — clean energy sources'),
  (gen_random_uuid(), deck_id, 6,
    '**Deforestation**',
    'The action of clearing a wide area of trees.\n\n*Example:* Deforestation in the Amazon has accelerated in recent years.',
    'Noun — cutting down forests'),
  (gen_random_uuid(), deck_id, 7,
    '**Ecological balance**',
    'A state of dynamic equilibrium within a community of organisms.\n\n*Example:* Introducing invasive species can disrupt the ecological balance.',
    'Noun phrase — natural harmony'),
  (gen_random_uuid(), deck_id, 8,
    '**Fossil fuels**',
    'Natural fuels such as coal, oil, and natural gas formed from ancient organic matter.\n\n*Example:* Burning fossil fuels releases carbon dioxide into the atmosphere.',
    'Noun phrase — non-renewable energy'),
  (gen_random_uuid(), deck_id, 9,
    '**Conservation**',
    'The protection of plants, animals, and natural areas from damaging effects of human activity.\n\n*Example:* Wildlife conservation requires international cooperation.',
    'Noun — protecting nature'),
  (gen_random_uuid(), deck_id, 10,
    '**Endangered species**',
    'A species that is at risk of extinction.\n\n*Example:* The giant panda was once classified as an endangered species.',
    'Noun phrase — animals at risk'),
  (gen_random_uuid(), deck_id, 11,
    '**Greenhouse effect**',
    'The trapping of the sun''s warmth in the planet''s lower atmosphere due to greenhouse gases.\n\n*Example:* The greenhouse effect is intensified by human activities.',
    'Noun phrase — global warming cause'),
  (gen_random_uuid(), deck_id, 12,
    '**Eco-friendly**',
    'Not harmful to the environment.\n\n*Example:* Many consumers now prefer eco-friendly packaging.',
    'Adjective — environmentally safe');
END $$;
COMMIT;
