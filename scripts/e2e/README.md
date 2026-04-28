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

## Ollama (host) setup

Ollama runs on the host (not in Docker) and serves only the embedding model.
The chat LLM runs on Groq cloud — no local model pull required.

```bash
# 1. Pull the embedding model (~500 MB).
ollama pull bge-m3

# 2. Bind Ollama to 0.0.0.0 so Docker containers can reach it.
sudo mkdir -p /etc/systemd/system/ollama.service.d
sudo tee /etc/systemd/system/ollama.service.d/override.conf >/dev/null <<'EOF'
[Service]
Environment="OLLAMA_HOST=0.0.0.0:11434"
EOF
sudo systemctl daemon-reload
sudo systemctl restart ollama

# 3. Verify reachable from a container's perspective.
curl -s http://172.17.0.1:11434/api/tags | head -c 200
```

If you cannot use `sudo`, run a tiny TCP proxy on the host as a workaround:

```python
# /tmp/ollama_proxy.py
import socket, threading
def fwd(s, d):
    try:
        while data := s.recv(65536): d.sendall(data)
    finally:
        try: d.shutdown(socket.SHUT_WR)
        except OSError: pass
def handle(c):
    u = socket.create_connection(("127.0.0.1", 11434))
    threading.Thread(target=fwd, args=(c, u), daemon=True).start()
    threading.Thread(target=fwd, args=(u, c), daemon=True).start()
l = socket.socket(); l.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
l.bind(("0.0.0.0", 11435)); l.listen(128)
while True: handle(l.accept()[0])
```

```bash
python3 /tmp/ollama_proxy.py &
# Then set OLLAMA_BASE_URL=http://host.docker.internal:11435 in deploy/envs/ai.env
```

GPU note: bge-m3 on CUDA returns NaN embeddings for some inputs. The
ai-service forces CPU mode (`num_gpu: 0`); see `services/ai-service/app/services/embedding_service.py`.

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
- `5` comparison persisted-but-empty (Defect #3 regression)
