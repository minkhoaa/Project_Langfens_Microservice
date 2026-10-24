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
job_id = "27f333b8-1f96-4d68-a1ec-c7cf6def4a00"

print(f"Monitoring resumed job {job_id}...", flush=True)
t0 = time.time()
seen_logs = set()
while True:
    time.sleep(10)
    try:
        r = requests.get(f"{base_url}/api/admin/reading-paper/jobs/{job_id}", headers=get_headers(), timeout=15)
        if r.status_code != 200:
            print(f"Polling HTTP {r.status_code}", flush=True)
            continue
        data = r.json()
        status = data.get("status")
        sections = data.get("completedSections")
        exam_id = data.get("examId")
        err = data.get("error")
        
        # Print new logs
        for log in data.get("logs", []):
            line = f"[{log.get('timestamp')}] [{log.get('level')}] {log.get('message')}"
            if line not in seen_logs:
                seen_logs.add(line)
                print(line, flush=True)
                
        elapsed = time.time() - t0
        print(f"[{elapsed:.1f}s] Status = {status}, Sections = {sections}", flush=True)
        
        if status in ("Completed", "Failed", "Cancelled"):
            print("==========================================", flush=True)
            print(f"Job reached terminal status: {status} in {elapsed:.1f}s", flush=True)
            print(f"Completed sections: {sections}", flush=True)
            print(f"Exam ID: {exam_id}", flush=True)
            print(f"Error: {err}", flush=True)
            print("==========================================", flush=True)
            with open("reports/resumed_job_result.json", "w") as f:
                json.dump(data, f, indent=2)
            if status == "Completed":
                print("SUCCESS: Resumed job completed successfully!", flush=True)
                sys.exit(0)
            else:
                print("FAILURE: Resumed job ended in status " + status, flush=True)
                sys.exit(1)
    except Exception as e:
        print(f"Polling error: {e}", flush=True)
