import base64
import hashlib
import hmac
import json
import os
import sys
import time
import urllib.request

def b64url(b: bytes) -> str:
    return base64.urlsafe_b64encode(b).rstrip(b"=").decode("ascii")

def create_admin_jwt(secret: str = None) -> str:
    if secret is None:
        secret = os.getenv("JWT_SIGNING_KEY") or os.getenv("JwtSettings__SignKey")
    if not secret:
        raise ValueError(
            "Required JWT signing key is not set. "
            "Please configure JWT_SIGNING_KEY or JwtSettings__SignKey environment variable."
        )
    header = {"alg": "HS256", "typ": "JWT"}
    payload = {
        "sub": "00000000-0000-0000-0000-000000000001",
        "roles": "ADMIN",
        "iss": "IssuerName",
        "aud": "AudienceName",
        "exp": int(time.time()) + 7200,
    }
    part1 = b64url(json.dumps(header, separators=(",", ":")).encode("utf-8"))
    part2 = b64url(json.dumps(payload, separators=(",", ":")).encode("utf-8"))
    sig = hmac.new(secret.encode("utf-8"), f"{part1}.{part2}".encode("utf-8"), hashlib.sha256).digest()
    part3 = b64url(sig)
    return f"{part1}.{part2}.{part3}"

def main():
    token = create_admin_jwt()
    headers = {
        "Authorization": f"Bearer {token}",
        "Content-Type": "application/json",
        "Accept": "application/json"
    }

    base_url = "http://127.0.0.1:42933"

    # Submit 1-section job
    pmcids = ["PMC9540822"]
    body = {
        "topic": "Marine Ecosystems and Global Climate Change",
        "pmcids": pmcids,
        "provider": "minimax"
    }

    print(f"[Step 1] Submitting 1-section job for {pmcids} with provider MiniMax...", flush=True)
    req = urllib.request.Request(
        f"{base_url}/api/admin/reading-paper/jobs",
        data=json.dumps(body).encode("utf-8"),
        headers=headers,
        method="POST"
    )

    try:
        with urllib.request.urlopen(req, timeout=120) as resp:
            job_data = json.loads(resp.read().decode())
            job_id = job_data["id"]
            status = job_data.get("status")
            print(f"Job created: ID = {job_id}, status = {status}", flush=True)
    except urllib.error.HTTPError as e:
        print(f"Error submitting job: HTTP {e.code}: {e.read().decode()}", flush=True)
        sys.exit(1)

    print(f"[Step 2] Monitoring job {job_id}...", flush=True)
    seen_logs = 0
    terminal_statuses = {"Completed", "Failed", "Aborted", "Cancelled", "NeedsSources"}
    start_time = time.time()

    while True:
        try:
            get_req = urllib.request.Request(
                f"{base_url}/api/admin/reading-paper/jobs/{job_id}",
                headers=headers
            )
            with urllib.request.urlopen(get_req, timeout=15) as r:
                data = json.loads(r.read().decode())
                status = data.get("status")
                completed = data.get("completedSections")
                logs = data.get("logs") or []

                if len(logs) > seen_logs:
                    for entry in logs[seen_logs:]:
                        ts = entry.get("timestamp", "")
                        lvl = entry.get("level", "")
                        msg = entry.get("message", "")
                        print(f"[{ts}] [{lvl}] {msg}", flush=True)
                    seen_logs = len(logs)

                if status in terminal_statuses:
                    elapsed = time.time() - start_time
                    print("\n==========================================", flush=True)
                    print(f"Job reached terminal status: {status} in {elapsed:.1f}s", flush=True)
                    print(f"Completed sections: {completed}", flush=True)
                    print(f"Exam ID: {data.get('examId')}", flush=True)
                    if data.get("error"):
                        print(f"Error: {data.get('error')}", flush=True)
                    print("==========================================", flush=True)
                    if status == "Completed":
                        print("SECTION 1 LIVE PIPELINE: PASS", flush=True)
                        sys.exit(0)
                    else:
                        print("SECTION 1 LIVE PIPELINE: FAILED", flush=True)
                        sys.exit(1)
        except Exception as e:
            print(f"Polling exception: {e}", flush=True)

        time.sleep(5)

if __name__ == "__main__":
    main()

