-- ============================================
-- Vocabulary Deck: Technology & Innovation
-- Category: ielts
-- Status: PUBLISHED
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DO $$
DECLARE
  deck_id uuid := 'a1000000-0000-4000-8000-000000000003';
  sys_user uuid := 'c0f680e7-ff83-469e-85b1-241ada48744e';
BEGIN

  INSERT INTO deck ("Id", "Slug", "UserId", "Title", "DescriptionMd", "Category", "Status", "CreatedAt", "UpdatedAt")
  VALUES (
    deck_id,
    'ielts-technology-innovation',
    sys_user,
    'IELTS Technology & Innovation',
    'Key vocabulary for discussing digital transformation, artificial intelligence, and the impact of technology on society.',
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
    '**Artificial intelligence**',
    'The simulation of human intelligence by machines.\n\n*Example:* Artificial intelligence is transforming healthcare diagnostics.',
    'Noun phrase — AI'),
  (gen_random_uuid(), deck_id, 2,
    '**Automation**',
    'The use of machines or technology to perform tasks without human intervention.\n\n*Example:* Automation in factories has reduced the need for manual labour.',
    'Noun — machines doing human jobs'),
  (gen_random_uuid(), deck_id, 3,
    '**Obsolete**',
    'No longer produced or used; out of date.\n\n*Example:* Landline phones are becoming obsolete in many countries.',
    'Adjective — outdated'),
  (gen_random_uuid(), deck_id, 4,
    '**Breakthrough**',
    'A sudden, dramatic, and important discovery or development.\n\n*Example:* The vaccine was a major breakthrough in the fight against the disease.',
    'Noun — major advance'),
  (gen_random_uuid(), deck_id, 5,
    '**Digital divide**',
    'The gap between those who have access to technology and those who do not.\n\n*Example:* The digital divide is widening between rural and urban communities.',
    'Noun phrase — tech inequality'),
  (gen_random_uuid(), deck_id, 6,
    '**Cybersecurity**',
    'The protection of computer systems and networks from digital attacks.\n\n*Example:* Cybersecurity has become a top priority for governments worldwide.',
    'Noun — digital security'),
  (gen_random_uuid(), deck_id, 7,
    '**Innovation**',
    'A new method, idea, or product.\n\n*Example:* Open-source software has driven innovation in the tech industry.',
    'Noun — new invention or idea'),
  (gen_random_uuid(), deck_id, 8,
    '**Tech-savvy**',
    'Well informed about or proficient in the use of modern technology.\n\n*Example:* Today''s teenagers are generally more tech-savvy than their parents.',
    'Adjective — good with technology'),
  (gen_random_uuid(), deck_id, 9,
    '**Disruptive technology**',
    'An innovation that significantly alters the way an industry operates.\n\n*Example:* Ride-sharing apps are a disruptive technology in the transport sector.',
    'Noun phrase — game-changing tech'),
  (gen_random_uuid(), deck_id, 10,
    '**User interface**',
    'The point of interaction between a user and a computer system.\n\n*Example:* A well-designed user interface makes software intuitive to use.',
    'Noun phrase — UI'),
  (gen_random_uuid(), deck_id, 11,
    '**Algorithm**',
    'A set of rules or calculations used by a computer to solve problems.\n\n*Example:* Social media algorithms determine what content appears in your feed.',
    'Noun — computer logic/rules'),
  (gen_random_uuid(), deck_id, 12,
    '**Surveillance**',
    'Close observation, especially of a suspected person or group.\n\n*Example:* Facial recognition technology has raised concerns about mass surveillance.',
    'Noun — monitoring/watching');
END $$;
COMMIT;
