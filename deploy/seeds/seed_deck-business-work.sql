-- ============================================
-- Vocabulary Deck: Business & Work
-- Category: ielts
-- Status: PUBLISHED
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DO $$
DECLARE
  deck_id uuid := 'a1000000-0000-4000-8000-000000000007';
  sys_user uuid := 'c0f680e7-ff83-469e-85b1-241ada48744e';
BEGIN

  INSERT INTO deck ("Id", "Slug", "UserId", "Title", "DescriptionMd", "Category", "Status", "CreatedAt", "UpdatedAt")
  VALUES (
    deck_id,
    'ielts-business-work',
    sys_user,
    'IELTS Business & Work',
    'Professional vocabulary for discussing employment, entrepreneurship, and the modern workplace — useful for Speaking Part 3 and Writing Task 2.',
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
    '**Entrepreneur**',
    'A person who sets up a business, taking on financial risks in the hope of profit.\n\n*Example:* Many young entrepreneurs are drawn to the tech industry.',
    'Noun — business founder'),
  (gen_random_uuid(), deck_id, 2,
    '**Revenue**',
    'Income generated from business activities.\n\n*Example:* The company''s revenue increased by 30% last year.',
    'Noun — business income'),
  (gen_random_uuid(), deck_id, 3,
    '**Work-life balance**',
    'The division of one''s time and focus between work and personal life.\n\n*Example:* Flexible hours help employees maintain a better work-life balance.',
    'Noun phrase — work vs personal time'),
  (gen_random_uuid(), deck_id, 4,
    '**Monopoly**',
    'The exclusive possession or control of the supply of a commodity or service.\n\n*Example:* The government regulates industries to prevent monopolies.',
    'Noun — single company controlling a market'),
  (gen_random_uuid(), deck_id, 5,
    '**Stakeholder**',
    'A person with an interest or concern in a business or project.\n\n*Example:* All stakeholders were consulted before the merger was approved.',
    'Noun — interested party'),
  (gen_random_uuid(), deck_id, 6,
    '**Outsource**',
    'To obtain goods or services from an outside supplier, often in another country.\n\n*Example:* Many companies outsource customer service to reduce costs.',
    'Verb — hire external provider'),
  (gen_random_uuid(), deck_id, 7,
    '**Corporate social responsibility**',
    'A business model where companies integrate social and environmental concerns into their operations.\n\n*Example:* Corporate social responsibility is increasingly important to consumers.',
    'Noun phrase — CSR, ethical business'),
  (gen_random_uuid(), deck_id, 8,
    '**Unemployment rate**',
    'The percentage of the labour force that is without work but available for and seeking employment.\n\n*Example:* The unemployment rate dropped to 4.2% last quarter.',
    'Noun phrase — jobless percentage'),
  (gen_random_uuid(), deck_id, 9,
    '**Meritocracy**',
    'A system where people are chosen based on their ability rather than wealth or status.\n\n*Example:* Singapore prides itself on being a meritocracy.',
    'Noun — advancement by merit'),
  (gen_random_uuid(), deck_id, 10,
    '**Layoff**',
    'The act of dismissing employees, typically for economic reasons.\n\n*Example:* The company announced mass layoffs affecting 2,000 workers.',
    'Noun — job dismissal'),
  (gen_random_uuid(), deck_id, 11,
    '**Franchise**',
    'An authorisation granted by a company to an individual or group to sell its products or services.\n\n*Example:* Opening a franchise is less risky than starting an independent business.',
    'Noun — licensed business model'),
  (gen_random_uuid(), deck_id, 12,
    '**Burnout**',
    'Physical or mental collapse caused by overwork or stress.\n\n*Example:* Employee burnout is a growing concern in high-pressure industries.',
    'Noun — exhaustion from overwork');
END $$;
COMMIT;
