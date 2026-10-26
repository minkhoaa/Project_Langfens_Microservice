"""Actual exam Program/hosted-worker fixture on a freshly verified internal DB.

Never uses a historical database, provider credentials, published ports, or a
provider endpoint. The only generation destination is loopback port 9 (closed).
The image is just an offline rootfs; the tested build/runtime are mounted RO.
"""
from __future__ import annotations

import hashlib
import json
import os
from pathlib import Path
import secrets
import subprocess
import time
import urllib.request
from uuid import uuid4


def run(root, evidence, name, network, session, dsn, docker):
    binary_dir = root / "services/exam-service/bin/Debug/net10.0"
    with (evidence / "worker-build.log").open("w") as log:
        subprocess.run(["dotnet", "build", str(root / "services/exam-service/exam-service.csproj"), "--no-restore"],
            cwd=root, stdout=log, stderr=subprocess.STDOUT, check=True)
    source = subprocess.check_output(["git", "rev-parse", "HEAD"], cwd=root, text=True).strip()
    caps = dict(line.split("=", 1) for line in (root / "deploy/envs/loop-caps.env").read_text().splitlines()
        if line and not line.startswith("#"))
    runtime_env = dict(caps, **{
        "ConnectionStrings__exam-db": dsn, "ASPNETCORE_URLS": "http://0.0.0.0:8080", "ASPNETCORE_ENVIRONMENT": "Testing",
        "READING_PAPER_WORKER_ENABLED": "true", "GENERATION_SERVICE_URL": "http://127.0.0.1:9",
        "EXAMSERVICE__INTERNAL__API__KEY": secrets.token_hex(24), "JwtSettings__SignKey": secrets.token_hex(32),
        "JwtSettings__Issuer": "offline-fixture", "JwtSettings__Audience": "offline-fixture",
        "LANGFENS_SOURCE_SHA": source, "LD_LIBRARY_PATH": "/usr/lib", "DOTNET_ROOT": "/dotnet",
        "BENCHMARK_CAPS_MODE": "LIMITED", "BENCHMARK_MONETARY_CAP_MODE": "LIMITED", "HOME": "/tmp",
    })
    worker = "section1-worker-" + session
    command = ["docker", "run", "-d", "--pull=never", "--read-only", "--tmpfs", "/tmp", "--name", worker,
        "--label", "purpose=section1-offline-worker", "--label", "session=" + session,
        "--network", network, "--user", f"{os.getuid()}:{os.getgid()}", "-w", "/tmp", "-v", str(binary_dir) + ":/fixture:ro",
        "-v", "/usr/share/dotnet:/dotnet:ro", "-v", "/usr/lib:/usr/lib:ro", "-v", "/usr/lib:/lib64:ro",
        "--entrypoint", "/dotnet/dotnet"]
    for key in runtime_env:
        command.extend(["-e", key])
    command.extend(["langfens-exam:benchmark", "/fixture/exam-service.dll"])
    subprocess.run(command, env=dict(os.environ, **runtime_env), check=True, stdout=subprocess.DEVNULL)

    def sql(text):
        return docker("exec", name, "psql", "-U", "postgres", "-d", "section1_pipeline", "-Atc", text)

    generation = None
    try:
        info = json.loads(docker("inspect", worker))[0]
        assert info["Config"]["Labels"]["purpose"] == "section1-offline-worker"
        assert info["Config"]["Labels"]["session"] == session
        assert info["HostConfig"]["ReadonlyRootfs"] and not info["HostConfig"].get("PortBindings")
        assert set(info["NetworkSettings"]["Networks"]) == {network}
        host = info["NetworkSettings"]["Networks"][network]["IPAddress"]
        opener = urllib.request.build_opener(urllib.request.ProxyHandler({}))
        deadline = time.monotonic() + 90
        while True:
            assert json.loads(docker("inspect", worker))[0]["State"]["Running"], "Worker fixture exited; inspect worker-runtime.log"
            try:
                with opener.open(f"http://{host}:8080/healthz", timeout=2) as response:
                    if response.status == 200:
                        break
            except OSError:
                pass
            if time.monotonic() >= deadline:
                raise RuntimeError("Isolated worker host did not become healthy")
            time.sleep(0.2)
        # Also observe the actual Python service configuration, without any
        # provider key or inherited ai.env. Its source is mounted read-only.
        generation = "section1-generation-" + session
        generation_env = dict(caps, GENERATION_SERVICE_ENV_FILE="/dev/null", LANGFENS_SOURCE_SHA=source,
            EXAM_SERVICE_URL=f"http://{worker}:8080", EXAMSERVICE__EXAM__ADDRESS=f"http://{worker}:8080",
            EXAMSERVICE__INTERNAL__API__KEY=runtime_env["EXAMSERVICE__INTERNAL__API__KEY"],
            INTERNAL_API_KEY=runtime_env["EXAMSERVICE__INTERNAL__API__KEY"])
        gen_command = ["docker", "run", "-d", "--pull=never", "--read-only", "--tmpfs", "/tmp", "--name", generation,
            "--label", "purpose=section1-offline-generation", "--label", "session=" + session, "--network", network,
            "-v", str(root / "services/generation-service/app") + ":/app/app:ro", "--entrypoint", "python"]
        for key in generation_env:
            gen_command.extend(["-e", key])
        gen_command.extend(["eea0685d6d99", "-m", "uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8080", "--workers", "1"])
        subprocess.run(gen_command, env=dict(os.environ, **generation_env), check=True, stdout=subprocess.DEVNULL)
        gen_info = json.loads(docker("inspect", generation))[0]
        gen_host = gen_info["NetworkSettings"]["Networks"][network]["IPAddress"]
        deadline = time.monotonic() + 60
        while True:
            assert json.loads(docker("inspect", generation))[0]["State"]["Running"], "Generation fixture exited; inspect generation-runtime.log"
            try:
                with opener.open(f"http://{gen_host}:8080/healthz", timeout=2) as response:
                    if response.status == 200:
                        break
            except OSError:
                pass
            if time.monotonic() >= deadline:
                raise RuntimeError("Isolated generation host did not become healthy")
            time.sleep(0.2)
        gen_profile_json = docker("exec", generation, "python", "-c", "from app.config import settings; print(settings.loop_caps_profile_json)")
        gen_profile = json.loads(gen_profile_json)
        assert gen_profile["caps"]["loopOperationWallReservationSeconds"] == 60
        assert gen_profile["caps"]["standaloneRunBudgetCapTokens"] == int(caps["READING_PAPER_RUN_BUDGET_MAX_TOKENS"])
        assert gen_info["HostConfig"]["ReadonlyRootfs"] and not gen_info["HostConfig"].get("PortBindings")
        assert set(gen_info["NetworkSettings"]["Networks"]) == {network}
        gen_configured = dict(item.split("=", 1) for item in gen_info["Config"]["Env"])
        assert gen_configured["LANGFENS_SOURCE_SHA"] == source
        assert not any(gen_configured.get(key) for key in ("MINIMAX_API_KEY", "OPENAI_API_KEY", "GEMINI_API_KEY"))
        gen_mount = next(m for m in gen_info["Mounts"] if m["Destination"] == "/app/app")
        assert not gen_mount["RW"] and gen_mount["Source"] == str(root / "services/generation-service/app")
        assert sql("SELECT COUNT(*) FROM reading_paper_jobs") == "0", "Worker fixture requires an empty, never-used job database"
        identifier = str(uuid4())
        source_input = {"pmcid": "PMC1234567", "title": "OFFLINE topology fixture", "url": "https://example.invalid",
            "license": "CC BY 4.0", "wordCount": 800, "metadata": {"provider": "minimax", "acceptancePolicy": "acceptance_5_4_4_v1"}}
        sources = json.dumps([source_input])
        sql(f'''INSERT INTO reading_paper_jobs ("Id","Topic","Status","CompletedSections","SourcesJson","SectionsJson","Logs","Epoch","CancelVersion","EngineVersion","SchemaVersion","PolicyVersion","CreatedAt","UpdatedAt")
            VALUES ('{identifier}'::uuid,'OFFLINE topology fixture','Pending',0,$fixture${sources}$fixture$,'[]','Offline fixture only',1,0,'2.0.0','2.0.0','2.0.0',NOW(),NOW())''')
        deadline = time.monotonic() + 90
        while True:
            state = json.loads(sql(f'''SELECT json_build_object('job',j."Status",'run',r."Status",'epoch',r."Epoch",'jobEpoch',j."Epoch",
                'jobOwner',j."LeaseOwner",'runOwner',r."LeaseOwner",'profile',r."BudgetProfileJson",'profileHash',r."BudgetProfileSha256",
                'calls',r."BudgetCapCalls",'tokens',r."BudgetCapTokens",'wall',r."BudgetCapWallTimeSeconds")
                FROM reading_paper_jobs j LEFT JOIN reading_paper_runs r ON r."JobId"=j."Id" WHERE j."Id"='{identifier}'::uuid'''))
            if state["job"] == "Failed" and state["run"] == "FAILED":
                break
            if time.monotonic() >= deadline:
                raise RuntimeError("Worker fixture did not terminalize its isolated loopback-failure job")
            time.sleep(0.2)
        assert state["epoch"] == state["jobEpoch"] == 2
        assert state["jobOwner"] is None and state["runOwner"] is None
        assert state["calls"] == int(caps["READING_PAPER_RUN_BUDGET_MAX_CALLS"])
        assert state["tokens"] == int(caps["READING_PAPER_RUN_BUDGET_MAX_TOKENS"])
        assert state["wall"] == int(caps["READING_PAPER_RUN_BUDGET_MAX_WALL_TIME_SECONDS"])
        assert hashlib.sha256(state["profile"].encode()).hexdigest() == state["profileHash"]
        profile = json.loads(state["profile"])
        assert {k: v for k, v in profile.items() if k not in ("executionPolicy", "executionPolicyHash")} == gen_profile
        assert profile["caps"]["loopOperationWallReservationSeconds"] == 60
        assert profile["executionPolicy"]["providerCallSeconds"] == 60
        assert [g["count"] for g in profile["executionPolicy"]["sections"][0]["groups"]] == [5, 4, 4]
        assert sql("SELECT COUNT(*) FROM reading_paper_operations") == "0"
        instances = docker("ps", "--filter", "label=purpose=section1-offline-worker", "--filter", "label=session=" + session, "--format", "{{.Names}}")
        assert instances.splitlines() == [worker]
        mounts = {m["Destination"]: m for m in info["Mounts"]}
        assert mounts["/fixture"]["RW"] is False and mounts["/fixture"]["Source"] == str(binary_dir)
        configured = dict(item.split("=", 1) for item in info["Config"]["Env"])
        assert configured["LANGFENS_SOURCE_SHA"] == source
        assert not any(key in configured for key in ("MINIMAX_API_KEY", "OPENAI_API_KEY", "AI_SERVICE_ENV_FILE"))
        logs = docker("logs", worker)
        assert logs.count("ReadingPaperWorker started") == 1
        processes = docker("top", worker, "-eo", "pid,args")
        assert sum("/fixture/exam-service.dll" in line for line in processes.splitlines()) == 1
        runtimes = docker("exec", worker, "/dotnet/dotnet", "--list-runtimes")
        core_versions = [line.split()[1] for line in runtimes.splitlines() if line.startswith("Microsoft.NETCore.App ")]
        assert len(core_versions) == 1
        clean = not subprocess.check_output(["git", "status", "--porcelain"], cwd=root, text=True).strip()
        evidence_data = {"source_sha": source, "source_tree_clean": clean, "resource": name, "worker": worker, "pid": info["State"]["Pid"],
            "worker_instances": 1, "network_internal": True, "published_ports": 0, "historical_campaign_access": False,
            "real_provider_dispatches": 0, "generation_destination": "http://127.0.0.1:9", "job_id": identifier,
            "state": state, "policy_hash": profile["executionPolicyHash"],
            "binary_sha256": hashlib.sha256((binary_dir / "exam-service.dll").read_bytes()).hexdigest(),
            "build_files_sha256": {str(p.relative_to(binary_dir)): hashlib.sha256(p.read_bytes()).hexdigest()
                for p in sorted(binary_dir.glob("*")) if p.is_file()},
            "generation_runtime": {"container": generation, "source_sha": source, "profile": gen_profile,
                "profile_sha256": hashlib.sha256(gen_profile_json.encode()).hexdigest(),
                "source_files_sha256": {str(p.relative_to(root)): hashlib.sha256(p.read_bytes()).hexdigest()
                    for p in sorted((root / "services/generation-service/app").rglob("*.py"))}},
            "runtime_version": core_versions[0], "process_inventory": processes, "available_runtimes": runtimes,
            "caps_file_sha256": hashlib.sha256((root / "deploy/envs/loop-caps.env").read_bytes()).hexdigest()}
        (evidence / "worker-topology.json").write_text(json.dumps(evidence_data, indent=2) + "\n")
        print("WORKER_TOPOLOGY_OK one actual hosted worker, tested build mounted read-only, 60s pinned policy, fenced terminal states, zero provider dispatches")
        return 0
    finally:
        if generation:
            gen_logs = subprocess.run(["docker", "logs", generation], capture_output=True, text=True)
            (evidence / "generation-runtime.log").write_text(gen_logs.stdout + gen_logs.stderr)
            subprocess.run(["docker", "stop", generation], check=True, stdout=subprocess.DEVNULL)
        logs = subprocess.run(["docker", "logs", worker], capture_output=True, text=True)
        (evidence / "worker-runtime.log").write_text(logs.stdout + logs.stderr)
        subprocess.run(["docker", "stop", worker], check=True, stdout=subprocess.DEVNULL)
