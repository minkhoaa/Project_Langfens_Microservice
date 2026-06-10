-- ============================================
-- Vocabulary Deck: Arts & Culture
-- Category: ielts
-- Status: PUBLISHED
-- ============================================

BEGIN;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DO $$
DECLARE
  deck_id uuid := 'a1000000-0000-4000-8000-000000000008';
  sys_user uuid := 'c0f680e7-ff83-469e-85b1-241ada48744e';
BEGIN

  INSERT INTO deck ("Id", "Slug", "UserId", "Title", "DescriptionMd", "Category", "Status", "CreatedAt", "UpdatedAt")
  VALUES (
    deck_id,
    'ielts-arts-culture',
    sys_user,
    'IELTS Arts & Culture',
    'Vocabulary for discussing art, music, literature, cultural traditions, and creative expression — important for Speaking Part 2 and Writing.',
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
    '**Contemporary art**',
    'Art produced in the present period, typically from the late 20th century onwards.\n\n*Example:* The gallery specialises in contemporary art from Southeast Asian artists.',
    'Noun phrase — modern art'),
  (gen_random_uuid(), deck_id, 2,
    '**Cultural heritage**',
    'The legacy of physical artefacts and intangible attributes inherited from past generations.\n\n*Example:* Traditional Vietnamese water puppetry is an important part of the country''s cultural heritage.',
    'Noun phrase — traditions from the past'),
  (gen_random_uuid(), deck_id, 3,
    '**Masterpiece**',
    'A work of outstanding artistry or skill.\n\n*Example:* The Mona Lisa is widely regarded as Leonardo da Vinci''s masterpiece.',
    'Noun — greatest work of art'),
  (gen_random_uuid(), deck_id, 4,
    '**Aesthetic**',
    'Concerned with beauty or the appreciation of beauty.\n\n*Example:* Japanese architecture is admired for its minimalist aesthetic.',
    'Adjective — related to beauty'),
  (gen_random_uuid(), deck_id, 5,
    '**Folklore**',
    'The traditional beliefs, customs, and stories of a community, passed through generations by word of mouth.\n\n*Example:* Vietnamese folklore includes many tales about dragons and fairies.',
    'Noun — traditional stories/customs'),
  (gen_random_uuid(), deck_id, 6,
    '**Performing arts**',
    'Forms of creative activity performed in front of an audience, such as drama, music, and dance.\n\n*Example:* The school offers courses in all the performing arts.',
    'Noun phrase — live arts (theatre, dance, music)'),
  (gen_random_uuid(), deck_id, 7,
    '**Abstract**',
    'Existing in thought or as an idea but not having a physical or concrete existence; in art, not representing reality.\n\n*Example:* Abstract art can be difficult to interpret.',
    'Adjective — non-representational'),
  (gen_random_uuid(), deck_id, 8,
    '**Patron of the arts**',
    'A person who gives financial or other support to artists or artistic projects.\n\n*Example:* The Medici family were famous patrons of the arts during the Renaissance.',
    'Noun phrase — arts supporter/sponsor'),
  (gen_random_uuid(), deck_id, 9,
    '**Literary genre**',
    'A category of literary composition, such as poetry, fiction, or drama.\n\n*Example:* Science fiction has become one of the most popular literary genres.',
    'Noun phrase — type of literature'),
  (gen_random_uuid(), deck_id, 10,
    '**Indigenous**',
    'Originating or occurring naturally in a particular place; native.\n\n*Example:* Indigenous Australian art is one of the oldest continuing artistic traditions.',
    'Adjective — native/original inhabitants'),
  (gen_random_uuid(), deck_id, 11,
    '**Renaissance**',
    'A revival of or renewed interest in something; historically, the cultural rebirth in Europe (14th-17th century).\n\n*Example:* There has been a renaissance of interest in traditional crafts.',
    'Noun — rebirth/revival'),
  (gen_random_uuid(), deck_id, 12,
    '**Cinematography**',
    'The art of making motion pictures; the technique of film photography.\n\n*Example:* The film was praised for its breathtaking cinematography.',
    'Noun — film camera art');
END $$;
COMMIT;
