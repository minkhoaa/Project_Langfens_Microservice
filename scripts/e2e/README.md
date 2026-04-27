# E2E Test Harness — Writing Module

Layer 2 (backend) and Layer 3 (browser) entry points. Spec at
`docs/superpowers/specs/2026-04-27-writing-e2e-simulation-design.md`.

## Pre-conditions
1. Ollama running on host with `bge-m3` pulled (LLM goes to Groq cloud — no need for `deepseek-v2:16b`).
2. `deploy/envs/ai.env` configured: `USE_OPENAI_LIKE=true`, `GROQ_API_KEYS=<keys>`, Qdrant cloud creds.
3. Stack up: `docker compose -f deploy/compose.local.yaml up -d`.
4. Test user seeded: `python -m scripts.e2e.seed_user`.
5. At least 1 writing exam exists in `writing-service` DB
   (admin endpoint or DB seed — out of scope of this harness).

## Quick commands
```bash
# Seed user (idempotent)
python -m scripts.e2e.seed_user

# Run golden backend flow
python -m scripts.e2e.full_writing_flow

# Pytest wrapper (CI-friendly)
pytest scripts/e2e/test_full_flow.py -v

# Failure modes (operator-driven)
docker stop ai-service && python -m scripts.e2e.failure_flows ai-down && docker start ai-service
```

## Make targets
```bash
make -C scripts/e2e e2e-up      # boot stack
make -C scripts/e2e e2e-test    # seed + golden flow
make -C scripts/e2e e2e-down    # tear down
```

## Exit codes for `full_writing_flow`
- `0` success
- `1` stack not ready / login failed
- `2` grading endpoint failed
- `3` comparison never produced within timeout
- `4` comparison schema invalid
