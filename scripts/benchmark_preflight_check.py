#!/usr/bin/env python3
"""Phase 1 Preflight Verification for MiniMax-Text-01 vs MiniMax-M3 Live Benchmark."""

import json
import os
import subprocess
import sys
import time
import urllib.error
import urllib.request

REPO_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
AI_ENV_PATH = os.path.join(REPO_ROOT, "deploy", "envs", "ai.env")

def get_minimax_key() -> str:
    with open(AI_ENV_PATH, "r") as f:
        for line in f:
            if line.startswith("MINIMAX_API_KEY="):
                return line.strip().split("=", 1)[1]
    raise ValueError("MINIMAX_API_KEY not found in deploy/envs/ai.env")

def check_model_api(model_name: str, key: str, is_m3: bool = False) -> dict:
    print(f"Testing direct API completion for {model_name}...", flush=True)
    prompt = "Explain in 2 sentences why the sky is blue. Think carefully before answering." if is_m3 else "Respond strictly with JSON: {\"status\": \"ok\"}"
    payload = {
        "model": model_name,
        "messages": [{"role": "user", "content": prompt}],
        "temperature": 0.1,
        "max_tokens": 8192 if is_m3 else 100,
    }
    if is_m3:
        payload["reasoning_split"] = True
        payload["reasoning_effort"] = "low"

    req = urllib.request.Request(
        "https://api.minimaxi.chat/v1/chat/completions",
        data=json.dumps(payload).encode("utf-8"),
        headers={
            "Authorization": f"Bearer {key}",
            "Content-Type": "application/json",
        },
        method="POST"
    )

    t0 = time.time()
    with urllib.request.urlopen(req, timeout=30) as resp:
        elapsed = time.time() - t0
        data = json.loads(resp.read().decode())
        usage = data.get("usage", {})
        msg = data["choices"][0]["message"]
        content = msg.get("content", "").strip()
        reasoning = msg.get("reasoning_content")
        reasoning_tokens = usage.get("completion_tokens_details", {}).get("reasoning_tokens") if usage.get("completion_tokens_details") else None

        print(f"  -> HTTP {resp.status} in {elapsed:.2f}s")
        print(f"  -> Model in response: {data.get('model')}")
        print(f"  -> Content: {content}")
        print(f"  -> Tokens: prompt={usage.get('prompt_tokens')}, completion={usage.get('completion_tokens')}, reasoning={reasoning_tokens}")
        if is_m3:
            assert data.get("model") == "MiniMax-M3", f"Expected MiniMax-M3, got {data.get('model')}"
            assert reasoning_tokens is not None, "M3 must return reasoning_tokens"
        return data

def run_compose_preflight():
    compose_file = os.path.join(REPO_ROOT, "deploy", "compose.benchmark-text.yaml")
    print("\nStarting isolated benchmark compose container topology (Text-01)...", flush=True)
    subprocess.run(["docker", "compose", "-f", compose_file, "up", "-d"], check=True)

    try:
        print("Waiting for services to become healthy on ports 5448, 8086, 8087...", flush=True)
        deadline = time.time() + 60
        exam_healthy = False
        gen_healthy = False

        while time.time() < deadline:
            if not gen_healthy:
                try:
                    with urllib.request.urlopen("http://127.0.0.1:8086/healthz", timeout=2) as r:
                        if r.status == 200:
                            gen_healthy = True
                            print("  -> generation-service is healthy on port 8086", flush=True)
                except Exception:
                    pass

            if not exam_healthy:
                try:
                    with urllib.request.urlopen("http://127.0.0.1:8087/healthz", timeout=2) as r:
                        if r.status == 200:
                            exam_healthy = True
                            print("  -> exam-service is healthy on port 8087", flush=True)
                except Exception:
                    pass

            if gen_healthy and exam_healthy:
                break
            time.sleep(2)

        if not (gen_healthy and exam_healthy):
            raise RuntimeError(f"Services failed to become healthy (gen={gen_healthy}, exam={exam_healthy})")

        # Test internal authentication header
        print("Testing internal service authentication between services...", flush=True)
        int_req = urllib.request.Request(
            "http://127.0.0.1:8086/v1/autogen/reading-paper/sources?topic=preflight",
            headers={"X-Internal-Service-Key": "dev-internal-key-not-for-prod"}
        )
        with urllib.request.urlopen(int_req, timeout=10) as r:
            assert r.status == 200, f"Internal auth failed: {r.status}"
            print("  -> Internal auth passed (HTTP 200)", flush=True)

        print("\nAll Phase 1 Preflight Checks PASSED successfully!", flush=True)

    finally:
        print("Stopping preflight benchmark compose topology...", flush=True)
        subprocess.run(["docker", "compose", "-f", compose_file, "down", "-v"], check=True)

if __name__ == "__main__":
    key = get_minimax_key()
    check_model_api("MiniMax-Text-01", key, is_m3=False)
    check_model_api("MiniMax-M3", key, is_m3=True)
    run_compose_preflight()
