import httpx
import json
import time
import asyncio
import os
import sys

headers = {
    "Accept": "application/x-ndjson",
    "Content-Type": "application/json",
    "X-Internal-Service-Key": "internal-get-exam-snapshot"
}

with open("/tmp/demo_init2.json") as f:
    init2 = json.load(f)

with open("/tmp/demo_init3.json") as f:
    init3 = json.load(f)

payload_sec2 = {
    "topic": init2["topic"],
    "index": 2,
    "source": init2["source"],
    "provider": "minimax",
    "runId": init2["runId"],
    "epoch": init2["epoch"],
    "leaseOwner": init2["leaseOwner"],
    "parentOperationId": init2["parentOperationId"]
}

payload_sec3 = {
    "topic": init3["topic"],
    "index": 3,
    "source": init3["source"],
    "provider": "minimax",
    "runId": init3["runId"],
    "epoch": init3["epoch"],
    "leaseOwner": init3["leaseOwner"],
    "parentOperationId": init3["parentOperationId"]
}

async def generate_section_stream(name: str, payload: dict, out_file: str):
    t0 = time.time()
    events = []
    error = None
    result = None
    print(f"[{name}] Starting generation request for {payload['source']['pmcid']}...", flush=True)
    async with httpx.AsyncClient(timeout=900.0) as client:
        try:
            async with client.stream(
                "POST",
                "http://127.0.0.1:8085/api/v1/autogen/reading-paper/section",
                headers=headers,
                json=payload
            ) as response:
                print(f"[{name}] Stream response status: {response.status_code}", flush=True)
                async for line in response.aiter_lines():
                    if not line.strip():
                        continue
                    try:
                        ev = json.loads(line)
                    except Exception:
                        continue
                    events.append(ev)
                    ev_type = ev.get("type")
                    if ev_type == "log":
                        print(f"[{name} LOG] {ev.get('level')}: {ev.get('message')}", flush=True)
                    elif ev_type == "error":
                        print(f"[{name} ERROR] {ev.get('message')}", flush=True)
                        error = ev
                    elif ev_type == "result":
                        print(f"[{name} RESULT] Successfully generated section!", flush=True)
                        result = ev.get("section")
        except Exception as exc:
            print(f"[{name} EXCEPTION] {exc}", flush=True)
            error = {"type": "client_exception", "message": str(exc)}

    dur = time.time() - t0
    out = {
        "name": name,
        "payload": payload,
        "durationSeconds": dur,
        "events": events,
        "error": error,
        "result": result
    }
    with open(out_file, "w") as f:
        json.dump(out, f, indent=2)
    return out

async def main():
    print("Dispatching Task A (Section 2) and Task B (Section 3) concurrently...", flush=True)
    out_sec2, out_sec3 = await asyncio.gather(
        generate_section_stream("Task A - Section 2", payload_sec2, "/tmp/out_sec2.json"),
        generate_section_stream("Task B - Section 3", payload_sec3, "/tmp/out_sec3.json")
    )
    print(f"\nAll completed! Section 2 took {out_sec2['durationSeconds']:.1f}s, Section 3 took {out_sec3['durationSeconds']:.1f}s", flush=True)

if __name__ == "__main__":
    asyncio.run(main())
