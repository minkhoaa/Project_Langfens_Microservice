import base64
import hashlib
import hmac
import json
import os
import sys
import time
import urllib.error
import urllib.request

secret = "bTNGPmniBGyINHPdsmONct16TIqqb1bZ"
os.makedirs("reports", exist_ok=True)

def b64url(b: bytes) -> str:
    return base64.urlsafe_b64encode(b).rstrip(b"=").decode("ascii")

def get_headers():
    header = {"alg": "HS256", "typ": "JWT"}
    payload = {
        "sub": "00000000-0000-0000-0000-000000000001",
        "roles": "ADMIN",
        "iss": "IssuerName",
        "aud": "AudienceName",
        "exp": int(time.time()) + 14400,
    }
    p1 = b64url(json.dumps(header, separators=(",", ":")).encode("utf-8"))
    p2 = b64url(json.dumps(payload, separators=(",", ":")).encode("utf-8"))
    sig = hmac.new(secret.encode("utf-8"), f"{p1}.{p2}".encode("utf-8"), hashlib.sha256).digest()
    p3 = b64url(sig)
    token = f"{p1}.{p2}.{p3}"
    return {
        "Authorization": f"Bearer {token}",
        "Content-Type": "application/json",
        "Accept": "application/json",
    }

base_url = "http://127.0.0.1:42933"

pmcids = ["PMC9540822", "PMC9640808", "PMC8556156"]
body = {
    "topic": "Marine Ecosystems and Global Climate Change",
    "pmcids": pmcids,
    "provider": "minimax",
}

print(f"\n[Step 1] Submitting full 3-passage IELTS Academic generation job with provider '{body['provider']}'...", flush=True)
req = urllib.request.Request(
    f"{base_url}/api/admin/reading-paper/jobs",
    data=json.dumps(body).encode("utf-8"),
    headers=get_headers(),
    method="POST",
)

try:
    with urllib.request.urlopen(req, timeout=120) as resp:
        job_data = json.loads(resp.read().decode())
        job_id = job_data["id"]
        status = job_data.get("status")
        print(f"Job created successfully: ID = {job_id}, status = {status}", flush=True)
except urllib.error.HTTPError as e:
    print(f"Error submitting job: HTTP {e.code}: {e.read().decode()}", flush=True)
    sys.exit(1)

with open("current_fresh_job_id.txt", "w") as f:
    f.write(job_id)

print(f"\n[Step 2] Monitoring job {job_id} until terminal status...", flush=True)
seen_logs = 0
terminal_statuses = {"Completed", "Failed", "Aborted", "Cancelled", "NeedsSources"}
start_time = time.time()

while True:
    try:
        get_req = urllib.request.Request(
            f"{base_url}/api/admin/reading-paper/jobs/{job_id}",
            headers=get_headers(),
        )
        with urllib.request.urlopen(get_req, timeout=30) as r:
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

                with open("reports/fresh_monitored_job_result.json", "w") as f:
                    json.dump(data, f, indent=2)
                with open(f"reports/job_{job_id}.json", "w") as f:
                    json.dump(data, f, indent=2)

                if status == "Completed":
                    print("SUCCESS: Full-paper 40-question MiniMax LIVE acceptance run completed!", flush=True)
                    sys.exit(0)
                else:
                    print(f"FAILURE: Job ended in status {status}", flush=True)
                    sys.exit(1)
    except Exception as e:
        print(f"Polling exception: {e}", flush=True)

    time.sleep(10)
