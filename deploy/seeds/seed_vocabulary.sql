BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Cleanup all sample IELTS vocab decks
DELETE FROM card WHERE "DeckId" IN (
  SELECT d."Id" FROM deck d WHERE d."Slug" LIKE 'ielts-reading-vocab-%'
);
DELETE FROM deck WHERE "Slug" LIKE 'ielts-reading-vocab-%';

-- Generate 50 decks x 20 cards = 1000 cards
DO $$
DECLARE
  i int; j int;
  deck_id uuid;
BEGIN
  FOR i IN 1..50 LOOP
    deck_id := gen_random_uuid();
    INSERT INTO deck ("Id","Slug","Title","DescriptionMd","Category","Status","CreatedAt","UpdatedAt") VALUES (
      deck_id,
      'ielts-reading-vocab-'||i,
      'IELTS Reading — Core Vocabulary '||i,
      'Auto-generated deck #'||i||' with 20 cards.',
      'IELTS','PUBLISHED', now() - (i||' days')::interval, now()
    );

    FOR j IN 1..20 LOOP
      INSERT INTO card ("Id","DeckId","Idx","FrontMd","BackMd","HintMd") VALUES (
        gen_random_uuid(), deck_id, j,
        'term-'||i||'-'||j,
        'definition for term '||i||'-'||j,
        'hint '||i||'-'||j
      );
    END LOOP;
  END LOOP;
END$$;

COMMIT;
