import jwt, time, requests, json, sys, os

secret = "bTNGPmniBGyINHPdsmONct16TIqqb1bZ"
os.makedirs("reports", exist_ok=True)

def get_headers():
    token = jwt.encode({
        "sub": "00000000-0000-0000-0000-000000000001",
        "roles": "ADMIN",
        "iss": "IssuerName",
        "aud": "AudienceName",
        "exp": int(time.time()) + 7200
    }, secret, algorithm="HS256")
    return {
        "Authorization": "Bearer " + token,
        "Content-Type": "application/json"
    }

base_url = "http://127.0.0.1:42933"

# 1. GET /api/admin/reading-paper/sources?topic=Environmental Science
print("[Step 1] Querying sources via Admin API...", flush=True)
t0 = time.time()
try:
    src_res = requests.get(f"{base_url}/api/admin/reading-paper/sources?topic=Environmental%20Science", headers=get_headers(), timeout=180)
    print(f"GET sources HTTP Status: {src_res.status_code} in {time.time() - t0:.1f}s", flush=True)
except Exception as e:
    print(f"GET sources exception (proceeding to job submission): {e}", flush=True)

# 2. POST /api/admin/reading-paper/jobs
pmcids = ["PMC9540822", "PMC9640808", "PMC8556156"]
body = {
    "topic": "Environmental Science",
    "pmcids": pmcids,
    "provider": "minimax"
}

print(f"\n[Step 2] Submitting generation job for topic '{body['topic']}' with {len(pmcids)} PMC sources using provider '{body['provider']}'...", flush=True)
res = requests.post(f"{base_url}/api/admin/reading-paper/jobs", headers=get_headers(), json=body, timeout=120)
print(f"POST jobs HTTP Status: {res.status_code}", flush=True)
if res.status_code not in (200, 201):
    print("Error submitting job:", res.text, flush=True)
    sys.exit(1)

job_data = res.json()
job_id = job_data["id"]
status = job_data.get("status")
print(f"Job created successfully: ID = {job_id}", flush=True)
print(f"Initial status = {status}", flush=True)

with open("current_fresh_job_id.txt", "w") as f:
    f.write(job_id)

# 3. GET /api/admin/reading-paper/jobs/{jobId}
seen_logs = 0
terminal_statuses = {"Completed", "Failed", "Aborted", "Cancelled", "NeedsSources"}
start_time = time.time()
print(f"\n[Step 3] Monitoring job {job_id} until terminal status...", flush=True)

while True:
    try:
        r = requests.get(f"{base_url}/api/admin/reading-paper/jobs/{job_id}", headers=get_headers(), timeout=30)
        if r.status_code == 200:
            data = r.json()
            status = data.get("status")
            completed = data.get("completedSections")
            logs = data.get("logs") or []

            # Print new logs
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

                # Save final job json
                with open("reports/fresh_monitored_job_result.json", "w") as f:
                    json.dump(data, f, indent=2)
                with open(f"reports/job_{job_id}.json", "w") as f:
                    json.dump(data, f, indent=2)

                if status == "Completed":
                    print("SUCCESS: Real MiniMax generation job completed successfully!", flush=True)
                    sys.exit(0)
                else:
                    print(f"FAILURE: Job ended in status {status}", flush=True)
                    sys.exit(1)
        else:
            print(f"Warning: HTTP {r.status_code}: {r.text}", flush=True)
    except Exception as e:
        print(f"Polling exception: {e}", flush=True)

    time.sleep(10)
