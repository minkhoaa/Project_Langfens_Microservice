#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
COMPOSE_FILE="${REPO_ROOT}/deploy/compose.yaml"

if ! command -v docker >/dev/null 2>&1; then
  echo "docker is required to run this script." >&2
  exit 1
fi

seed_exams() {
  echo "Seeding exam data..."
  docker compose -f "${COMPOSE_FILE}" exec -T exam-database \
    psql -U exam -d exam-db <<'EXAM_SQL'
\set ON_ERROR_STOP on

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Clear previously generated demo exams so the script is idempotent.
DELETE FROM exams WHERE "Slug" LIKE 'demo-exam-%';

DO $$
DECLARE
    categories text[] := ARRAY['IELTS', 'TOEIC', 'VSTEP'];
    levels text[] := ARRAY['A1', 'A2', 'B1', 'B2', 'C1', 'C2'];
    skills text[] := ARRAY['READING', 'LISTENING', 'WRITING', 'SPEAKING'];
    question_types text[] := ARRAY[
        'MULTIPLE_CHOICE_SINGLE',
        'MULTIPLE_CHOICE_MULTI',
        'TRUE_FALSE_NOT_GIVEN',
        'SHORT_ANSWER'
    ];
    sections_per_exam int := 3;
    questions_per_section int := 8;
    exam_idx int;
    section_idx int;
    question_idx int;
    option_idx int;
    exam_id uuid;
    section_id uuid;
    question_id uuid;
    correct_option int;
BEGIN
    FOR exam_idx IN 1..50 LOOP
        exam_id := uuid_generate_v4();
        INSERT INTO exams ("Id", "Slug", "Title", "DescriptionMd", "Category", "Level", "Status", "DurationMin", "CreatedAt", "UpdatedAt")
        VALUES (
            exam_id,
            format('demo-exam-%s', lpad(exam_idx::text, 3, '0')),
            format('Demo Practice Exam #%s', exam_idx),
            format('## Demo Exam %s%sThis mock dataset was generated for testing the exam service.', exam_idx, chr(10)),
            categories[((exam_idx - 1) % array_length(categories, 1)) + 1],
            levels[((exam_idx - 1) % array_length(levels, 1)) + 1],
            CASE
                WHEN exam_idx % 3 = 0 THEN 'PUBLISHED'
                WHEN exam_idx % 3 = 1 THEN 'DRAFT'
                ELSE 'ARCHIVED'
            END,
            60 + ((exam_idx - 1) % 4) * 15,
            now() - make_interval(days => exam_idx),
            now()
        );

        FOR section_idx IN 1..sections_per_exam LOOP
            section_id := uuid_generate_v4();
            INSERT INTO exam_sections ("Id", "ExamId", "Idx", "Title", "InstructionsMd")
            VALUES (
                section_id,
                exam_id,
                section_idx,
                format('Section %s.%s', exam_idx, section_idx),
                format('Answer every question for section %s focusing on academic reading/listening skills.', section_idx)
            );

            FOR question_idx IN 1..questions_per_section LOOP
                question_id := uuid_generate_v4();
                correct_option := ((question_idx + section_idx - 2) % 4) + 1;
                INSERT INTO exam_questions ("Id", "SectionId", "Idx", "Type", "Skill", "Difficulty", "PromptMd", "ExplanationMd")
                VALUES (
                    question_id,
                    section_id,
                    question_idx,
                    question_types[((exam_idx + question_idx - 2) % array_length(question_types, 1)) + 1],
                    skills[((section_idx + question_idx - 2) % array_length(skills, 1)) + 1],
                    1 + ((exam_idx + section_idx + question_idx) % 3),
                    format('### Question %s.%s.%s%sRead the passage and choose the best answer.', exam_idx, section_idx, question_idx, chr(10)),
                    format('This is a generated explanation for question %s.%s.%s.', exam_idx, section_idx, question_idx)
                );

                FOR option_idx IN 1..4 LOOP
                    INSERT INTO exam_options ("Id", "QuestionId", "Idx", "ContentMd", "IsCorrect")
                    VALUES (
                        uuid_generate_v4(),
                        question_id,
                        option_idx,
                        format('Option %s for question %s.%s.%s. Demo content for testing.', option_idx, exam_idx, section_idx, question_idx),
                        option_idx = correct_option
                    );
                END LOOP;
            END LOOP;
        END LOOP;
    END LOOP;
END
$$ LANGUAGE plpgsql;
EXAM_SQL
}

seed_vocabulary() {
  echo "Seeding vocabulary data..."
  docker compose -f "${COMPOSE_FILE}" exec -T vocabulary-database \
    psql -U vocabulary -d vocabulary-db <<'VOCAB_SQL'
\set ON_ERROR_STOP on

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Remove previous demo decks and their dependent data.
DELETE FROM deck WHERE "Slug" LIKE 'demo-deck-%';

DO $$
DECLARE
    owner_pool uuid[] := ARRAY[
        '11111111-1111-1111-1111-111111111111'::uuid,
        '22222222-2222-2222-2222-222222222222'::uuid,
        '33333333-3333-3333-3333-333333333333'::uuid,
        '44444444-4444-4444-4444-444444444444'::uuid,
        '55555555-5555-5555-5555-555555555555'::uuid,
        '66666666-6666-6666-6666-666666666666'::uuid
    ];
    categories text[] := ARRAY['Academic', 'Business', 'Travel', 'Daily Life', 'Idioms'];
    word_bank text[] := ARRAY[
        'abandon','benevolent','candid','diligent','eloquent','fathom','gregarious','humble','illuminate','jubilant',
        'kinetic','lucid','meticulous','nostalgia','ornate','pragmatic','quaint','resilient','serene','tenacious',
        'urbane','vivid','whimsical','yearn','zenith','alleviate','bolster','contemplate','deride','embark',
        'forge','galvanize','herald','immerse','juggle','kindle','lament','mediate','nurture','optimize',
        'pioneer','quell','revitalize','safeguard','taper','uplift','venture','wane','yoke','zeal'
    ];
    deck_idx int;
    card_idx int;
    cards_per_deck int := 12;
    deck_id uuid;
    owner_id uuid;
    word text;
BEGIN
    FOR deck_idx IN 1..50 LOOP
        deck_id := uuid_generate_v4();
        owner_id := owner_pool[((deck_idx - 1) % array_length(owner_pool, 1)) + 1];

        INSERT INTO deck ("Id", "Slug", "UserId", "Title", "DescriptionMd", "Category", "Status", "CreatedAt", "UpdatedAt")
        VALUES (
            deck_id,
            format('demo-deck-%s', lpad(deck_idx::text, 3, '0')),
            owner_id,
            format('Demo Vocabulary Deck #%s', deck_idx),
            format('### Deck %s%sA curated list of thematic vocabulary words for bulk testing.', deck_idx, chr(10)),
            categories[((deck_idx - 1) % array_length(categories, 1)) + 1],
            CASE WHEN deck_idx % 3 = 0 THEN 'PUBLISHED' ELSE 'DRAFT' END,
            now() - make_interval(days => deck_idx),
            now()
        );

        FOR card_idx IN 1..cards_per_deck LOOP
            word := word_bank[((deck_idx + card_idx - 2) % array_length(word_bank, 1)) + 1];
            INSERT INTO card ("Id", "DeckId", "Idx", "FrontMd", "BackMd", "HintMd")
            VALUES (
                uuid_generate_v4(),
                deck_id,
                card_idx,
                format('**%s**%sUse it in your own sentence.', initcap(word), chr(10)),
                format('*Definition:* %s meaning tailored for deck %s card %s.%s*Example:* Learners who %s ideas thrive in discussions.',
                       initcap(word),
                       deck_idx,
                       card_idx,
                       chr(10),
                       word),
                format('Picture the word "%s" in a vivid scene to strengthen memory.', word)
            );
        END LOOP;
    END LOOP;
END
$$ LANGUAGE plpgsql;
VOCAB_SQL
}

seed_exams
seed_vocabulary
echo "Seed completed successfully."
