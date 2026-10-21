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

body = {
    "topic": "Marine Ecosystems and Global Climate Change",
    "pmcids": [
        "PMC9540822",
        "PMC9640808",
        "PMC8556156"
    ],
    "provider": "minimax"
}

print("Submitting fresh generation job...", flush=True)
res = requests.post("http://127.0.0.1:42933/api/admin/reading-paper/jobs", headers=get_headers(), json=body)
print(f"HTTP Status: {res.status_code}", flush=True)
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

seen_logs = 0
terminal_statuses = {"Completed", "Failed", "Aborted", "Cancelled", "NeedsSources"}
start_time = time.time()
print(f"Monitoring job {job_id}...", flush=True)

while True:
    try:
        r = requests.get(f"http://127.0.0.1:42933/api/admin/reading-paper/jobs/{job_id}", headers=get_headers(), timeout=15)
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
                break
        else:
            print(f"Warning: HTTP {r.status_code}: {r.text}", flush=True)
    except Exception as e:
        print(f"Polling exception: {e}", flush=True)
        
    time.sleep(5)
