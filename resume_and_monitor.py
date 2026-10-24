import jwt, time, requests, json, sys, os

job_id = "28105069-8dc6-4fb5-a0e2-bd2c65e00533"
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

print(f"Calling POST /api/admin/reading-paper/jobs/{job_id}/retry...", flush=True)
res = requests.post(f"http://127.0.0.1:42933/api/admin/reading-paper/jobs/{job_id}/retry", headers=get_headers())
print(f"HTTP Status: {res.status_code}", flush=True)
if res.status_code != 200:
    print("Error retrying job:", res.text, flush=True)
    sys.exit(1)

job_data = res.json()
print(f"Job resumed: status = {job_data.get('status')}, epoch = {job_data.get('epoch')}", flush=True)

seen_logs = 0
terminal_statuses = {"Completed", "Failed", "Aborted", "Cancelled", "NeedsSources"}
start_time = time.time()
print(f"Monitoring resumed job {job_id}...", flush=True)

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
                with open("reports/resumed_job_result.json", "w") as f:
                    json.dump(data, f, indent=2)
                break
        else:
            print(f"Warning: HTTP {r.status_code}: {r.text}", flush=True)
    except Exception as e:
        print(f"Polling exception: {e}", flush=True)
        
    time.sleep(5)
