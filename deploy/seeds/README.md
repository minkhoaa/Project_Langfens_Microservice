Seed scripts for local docker-compose databases (excluding auth)

Prerequisites
- docker and docker compose are up using deploy/compose.yaml
- The containers for exam-database, course-database, vocabulary-database, attempt-database are healthy

Quick start (recommended)
- Run all seeds in one go:

  bash deploy/seeds/seed_all.sh

The script uses a temporary postgres:16-alpine container to run psql against each DB inside the compose network `backend`.

Manual commands (one by one)
- Exam DB only:

  docker run --rm --network backend -e PGPASSWORD=exam \
    -v "$PWD/deploy/seeds:/seeds:ro" postgres:16-alpine \
    psql -h exam-database -p 5432 -U exam -d exam-db -v ON_ERROR_STOP=1 -f /seeds/seed_exam.sql

- Course DB only:

  docker run --rm --network backend -e PGPASSWORD=course \
    -v "$PWD/deploy/seeds:/seeds:ro" postgres:16-alpine \
    psql -h course-database -p 5432 -U course -d course-db -v ON_ERROR_STOP=1 -f /seeds/seed_course.sql

- Vocabulary DB only:

  docker run --rm --network backend -e PGPASSWORD=vocabulary \
    -v "$PWD/deploy/seeds:/seeds:ro" postgres:16-alpine \
    psql -h vocabulary-database -p 5432 -U vocabulary -d vocabulary-db -v ON_ERROR_STOP=1 -f /seeds/seed_vocabulary.sql

- Attempt DB only:

  docker run --rm --network backend -e PGPASSWORD=attempt \
    -v "$PWD/deploy/seeds:/seeds:ro" postgres:16-alpine \
    psql -h attempt-database -p 5432 -U attempt -d attempt-db -v ON_ERROR_STOP=1 -f /seeds/seed_attempt.sql

Verification snippets
- Exam:

  docker run --rm --network backend -e PGPASSWORD=exam postgres:16-alpine \
    psql -h exam-database -p 5432 -U exam -d exam-db -c \
    "SELECT slug, title, status FROM exams WHERE slug='ielts-reading-sample-1';"

- Attempt:

  docker run --rm --network backend -e PGPASSWORD=attempt postgres:16-alpine \
    psql -h attempt-database -p 5432 -U attempt -d attempt-db -c \
    "SELECT id, examid, status, rawscore, scaledscore FROM attempts WHERE id='00000000-0000-0000-0000-00000000aa01';"

- Course:

  docker run --rm --network backend -e PGPASSWORD=course postgres:16-alpine \
    psql -h course-database -p 5432 -U course -d course-db -c \
    "SELECT slug, title, status FROM course WHERE slug='intro-ielts-reading';"

- Vocabulary:

  docker run --rm --network backend -e PGPASSWORD=vocabulary postgres:16-alpine \
    psql -h vocabulary-database -p 5432 -U vocabulary -d vocabulary-db -c \
    "SELECT slug, title, status FROM deck WHERE slug='ielts-reading-vocab-1';"

Notes
- These scripts are idempotent by slug/ids and safe to re-run.
- Order matters: run seed_exam.sql before seed_attempt.sql (seed_all.sh already ensures correct order).
