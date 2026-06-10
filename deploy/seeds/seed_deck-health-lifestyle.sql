-- ============================================
-- Vocabulary Deck: Health & Lifestyle
-- Category: ielts
-- Status: PUBLISHED
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DO $$
DECLARE
  deck_id uuid := 'a1000000-0000-4000-8000-000000000004';
  sys_user uuid := 'c0f680e7-ff83-469e-85b1-241ada48744e';
BEGIN

  INSERT INTO deck ("Id", "Slug", "UserId", "Title", "DescriptionMd", "Category", "Status", "CreatedAt", "UpdatedAt")
  VALUES (
    deck_id,
    'ielts-health-lifestyle',
    sys_user,
    'IELTS Health & Lifestyle',
    'Vocabulary for discussing physical health, mental well-being, diet, and healthy habits — frequently tested in IELTS Speaking Part 1 and Writing Task 2.',
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
    '**Sedentary lifestyle**',
    'A way of life that involves little physical activity.\n\n*Example:* A sedentary lifestyle increases the risk of heart disease.',
    'Noun phrase — inactive living'),
  (gen_random_uuid(), deck_id, 2,
    '**Well-being**',
    'The state of being comfortable, healthy, or happy.\n\n*Example:* Regular exercise contributes significantly to mental well-being.',
    'Noun — overall health/happiness'),
  (gen_random_uuid(), deck_id, 3,
    '**Preventive medicine**',
    'Medical care focused on preventing disease rather than treating it.\n\n*Example:* Vaccination is a cornerstone of preventive medicine.',
    'Noun phrase — stopping illness before it starts'),
  (gen_random_uuid(), deck_id, 4,
    '**Chronic disease**',
    'A long-lasting health condition that persists for months or years.\n\n*Example:* Diabetes is a chronic disease that affects millions worldwide.',
    'Noun phrase — long-term illness'),
  (gen_random_uuid(), deck_id, 5,
    '**Balanced diet**',
    'A diet that contains the right proportions of all necessary nutrients.\n\n*Example:* Nutritionists recommend a balanced diet rich in fruits and vegetables.',
    'Noun phrase — healthy eating'),
  (gen_random_uuid(), deck_id, 6,
    '**Obesity**',
    'The condition of being grossly overweight.\n\n*Example:* Childhood obesity has become a global health concern.',
    'Noun — extreme overweight'),
  (gen_random_uuid(), deck_id, 7,
    '**Immune system**',
    'The body''s defence mechanism against disease and infection.\n\n*Example:* A strong immune system helps protect against common illnesses.',
    'Noun phrase — body''s defence'),
  (gen_random_uuid(), deck_id, 8,
    '**Mental health**',
    'A person''s condition with regard to their psychological and emotional well-being.\n\n*Example:* Schools should prioritise students'' mental health alongside academic achievement.',
    'Noun phrase — psychological health'),
  (gen_random_uuid(), deck_id, 9,
    '**Life expectancy**',
    'The average period that a person is expected to live.\n\n*Example:* Life expectancy in Japan is among the highest in the world.',
    'Noun phrase — average lifespan'),
  (gen_random_uuid(), deck_id, 10,
    '**Remedy**',
    'A medicine or treatment for a disease or injury.\n\n*Example:* Ginger tea is a popular home remedy for sore throats.',
    'Noun — cure or treatment'),
  (gen_random_uuid(), deck_id, 11,
    '**Epidemic**',
    'A widespread occurrence of an infectious disease in a community at a particular time.\n\n*Example:* The obesity epidemic affects both developed and developing nations.',
    'Noun — disease outbreak'),
  (gen_random_uuid(), deck_id, 12,
    '**Rehabilitation**',
    'The process of helping someone regain health or normal life through therapy.\n\n*Example:* Physical rehabilitation is essential after a serious injury.',
    'Noun — recovery process');
END $$;
COMMIT;
