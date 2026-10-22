import argparse
import base64
import hashlib
import hmac
import json
import os
import sys
import time
import urllib.error
import urllib.request
import uuid

secret = os.getenv("JWT_SIGNING_KEY") or os.getenv("JwtSettings__SignKey") or "bTNGPmniBGyINHPdsmONct16TIqqb1bZ"
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

def is_valid_uuid(val: str) -> bool:
    try:
        uuid.UUID(str(val))
        return True
    except Exception:
        return False

def resolve_job_id(cli_job_id: str | None) -> str | None:
    if cli_job_id:
        if not is_valid_uuid(cli_job_id):
            print(f"Error: Provided --job-id '{cli_job_id}' is not a valid UUID", file=sys.stderr)
            sys.exit(1)
        return cli_job_id

    # Check marker file
    if os.path.exists("current_fresh_job_id.txt"):
        with open("current_fresh_job_id.txt", "r") as f:
            cand = f.read().strip()
            if is_valid_uuid(cand):
                return cand

    return None

def main():
    parser = argparse.ArgumentParser(
        description="Autonomous IELTS Reading Generation Admin Job Controller (Offline-Hardened)"
    )
    parser.add_argument(
        "--mode",
        choices=["new", "resume", "monitor"],
        default="new",
        help="Execution mode: new (submit new job), resume (safely resume existing job), monitor (poll existing job)",
    )
    parser.add_argument(
        "--job-id",
        type=str,
        default=None,
        help="Existing Job UUID to resume or monitor without creating duplicate jobs",
    )
    parser.add_argument(
        "--provider",
        type=str,
        default="minimax",
        help="LLM provider name (e.g. minimax, groq, mock)",
    )
    parser.add_argument(
        "--offline",
        action="store_true",
        default=os.getenv("OFFLINE_MODE", "false").lower() in ("true", "1", "yes"),
        help="Enforce offline safety guard; prevents new live network job submissions",
    )
    parser.add_argument(
        "--base-url",
        type=str,
        default=os.getenv("EXAM_SERVICE_URL", "http://127.0.0.1:42933"),
        help="Exam Service base URL",
    )

    args = parser.parse_args()
    base_url = args.base_url

    # Offline safety guard check
    if args.offline and args.mode == "new":
        print(
            "ERROR: [OFFLINE_GUARD] Submitting a new live generation job is prohibited while in OFFLINE mode "
            "or when provider quota is exhausted. Use --mode resume --job-id <id> or --mode monitor.",
            file=sys.stderr,
        )
        sys.exit(1)

    job_id = None

    if args.mode == "new":
        pmcids = ["PMC9540822", "PMC9640808", "PMC8556156"]
        body = {
            "topic": "Marine Ecosystems and Global Climate Change",
            "pmcids": pmcids,
            "provider": args.provider,
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

    elif args.mode == "resume":
        job_id = resolve_job_id(args.job_id)
        if not job_id:
            print("ERROR: --mode resume requires an existing job ID via --job-id <uuid> or current_fresh_job_id.txt", file=sys.stderr)
            sys.exit(1)

        print(f"\n[Step 1] Inspecting existing job {job_id} before resumption...", flush=True)
        try:
            get_req = urllib.request.Request(f"{base_url}/api/admin/reading-paper/jobs/{job_id}", headers=get_headers())
            with urllib.request.urlopen(get_req, timeout=30) as r:
                data = json.loads(r.read().decode())
                current_status = data.get("status")
                print(f"Existing job found: ID = {job_id}, Status = {current_status}, Completed = {data.get('completedSections')}", flush=True)
                if current_status in ("Failed", "NeedsSources"):
                    print(f"Re-triggering failed job via retry endpoint...", flush=True)
                    retry_req = urllib.request.Request(
                        f"{base_url}/api/admin/reading-paper/jobs/{job_id}/retry",
                        data=b"{}",
                        headers=get_headers(),
                        method="POST",
                    )
                    with urllib.request.urlopen(retry_req, timeout=30) as retry_resp:
                        print(f"Retry acknowledged: HTTP {retry_resp.status}", flush=True)
        except urllib.error.HTTPError as e:
            print(f"Error inspecting or retrying job: HTTP {e.code}: {e.read().decode()}", file=sys.stderr)
            sys.exit(1)

    elif args.mode == "monitor":
        job_id = resolve_job_id(args.job_id)
        if not job_id:
            print("ERROR: --mode monitor requires an existing job ID via --job-id <uuid> or current_fresh_job_id.txt", file=sys.stderr)
            sys.exit(1)
        print(f"\n[Step 1] Binding monitor to existing job ID: {job_id} (Zero new jobs created)", flush=True)

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
                        print("SUCCESS: Full-paper 40-question IELTS Academic run completed!", flush=True)
                        sys.exit(0)
                    else:
                        print(f"FAILURE: Job ended in status {status}", flush=True)
                        sys.exit(1)
        except Exception as e:
            print(f"Polling exception: {e}", flush=True)

        time.sleep(10)

if __name__ == "__main__":
    main()
