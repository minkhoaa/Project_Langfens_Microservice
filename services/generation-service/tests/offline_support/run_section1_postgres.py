"""Run only the isolated, scripted Section 1 PostgreSQL gate (no provider calls).

python tests/offline_support/run_section1_postgres.py --create --evidence-dir /absolute/path
Repeat with --resource <printed-name> --verify-restart after restarting that container.
Uses cached postgres:16-alpine and NuGet dependencies only; never resets a database.
Do not enable the generic pytest TCP guard: the driver installs an exact-host guard.
"""
from __future__ import annotations

import argparse
import ipaddress
import json
import os
from pathlib import Path
import secrets
import subprocess
import sys
import time
from uuid import uuid4

ROOT = Path(__file__).resolve().parents[4]
PREFIX = "section1-pipeline-postgres-"
PURPOSE = "section1-scripted-pipeline"


def docker(*args):
    return subprocess.check_output(["docker", *args], text=True).strip()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--create", action="store_true", help="create a new labelled internal server and volume")
    parser.add_argument("--resource", default="section1-pipeline-postgres-5dd0367d")
    parser.add_argument("--evidence-dir", type=Path, required=True)
    parser.add_argument("--verify-restart", action="store_true")
    parser.add_argument("--crash-boundary", choices=("accepted", "generation", "evaluation", "repair", "finalization"), default="accepted")
    options = parser.parse_args()
    if options.create and options.verify_restart:
        parser.error("Restart verification must use the original resource/evidence")
    name = PREFIX + uuid4().hex[:8] if options.create else options.resource
    if not name.startswith(PREFIX) or not name[len(PREFIX):].isalnum():
        parser.error("Invalid session resource name")
    session = name[len(PREFIX):]
    network_name = "section1-pipeline-net-" + session
    volume = "section1-pipeline-data-" + session
    if options.create:
        labels = ["--label", "session=" + session, "--label", "purpose=" + PURPOSE]
        docker("network", "create", "--internal", *labels, network_name)
        docker("volume", "create", *labels, volume)
        # Secret stays in process/Docker configuration, never source or receipts.
        environment = dict(os.environ, POSTGRES_PASSWORD=secrets.token_hex(24))
        subprocess.run(["docker", "run", "-d", "--pull=never", "--name", name, "--network", network_name,
            *labels, "-v", volume + ":/var/lib/postgresql/data", "-e", "POSTGRES_DB=section1_pipeline",
            "-e", "POSTGRES_PASSWORD", "postgres:16-alpine"], env=environment, check=True,
            stdout=subprocess.DEVNULL)
    info = json.loads(docker("inspect", name))[0]
    assert info["Config"]["Labels"] == {"purpose": PURPOSE, "session": session}
    assert info["State"]["Running"], "Start only this previously verified disposable container before replay"
    assert set(info["NetworkSettings"]["Networks"]) == {network_name}
    network = json.loads(docker("network", "inspect", network_name))[0]
    assert network["Internal"] and network["Labels"] == {"purpose": PURPOSE, "session": session}
    mounts = info["Mounts"]
    assert len(mounts) == 1 and mounts[0]["Type"] == "volume" and mounts[0]["Name"] == volume
    assert mounts[0]["Destination"] == "/var/lib/postgresql/data"
    volume_info = json.loads(docker("volume", "inspect", volume))[0]
    assert volume_info["Labels"] == {"purpose": PURPOSE, "session": session}
    host = info["NetworkSettings"]["Networks"][network_name]["IPAddress"]
    assert ipaddress.ip_address(host).is_private and not ipaddress.ip_address(host).is_loopback
    docker_environment = dict(item.split("=", 1) for item in info["Config"]["Env"])
    assert docker_environment["POSTGRES_DB"] == "section1_pipeline"
    password = docker_environment["POSTGRES_PASSWORD"]
    assert password.isalnum()
    deadline = time.monotonic() + 30
    while True:
        ready = subprocess.run(["docker", "exec", name, "pg_isready", "-U", "postgres", "-d", "section1_pipeline"],
            stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        if ready.returncode == 0:
            break
        if time.monotonic() >= deadline:
            raise RuntimeError("Disposable PostgreSQL did not become ready")
        time.sleep(0.2)
    evidence = options.evidence_dir.resolve()
    evidence.mkdir(parents=True, exist_ok=True)
    environment = dict(os.environ)
    environment.update(
        SECTION1_PIPELINE_POSTGRES=f"Host={host};Port=5432;Database=section1_pipeline;Username=postgres;Password={password}",
        SECTION1_PIPELINE_RESOURCE_HOST=host, SECTION1_PIPELINE_RESOURCE_VERIFIED=name,
        SECTION1_PIPELINE_PYTHON=str(ROOT / "services/generation-service/.venv/bin/python"),
        SECTION1_PIPELINE_GENERATION_DIR=str(ROOT / "services/generation-service"),
        SECTION1_PIPELINE_EVIDENCE_DIR=str(evidence), READING_PAPER_WORKER_ENABLED="false",
        SECTION1_PIPELINE_RESTART_VERIFY="1" if options.verify_restart else "0",
        SECTION1_PIPELINE_CRASH_BOUNDARY=options.crash_boundary,
    )
    environment["READING_CLOSURE_TEST_POSTGRES"] = environment["SECTION1_PIPELINE_POSTGRES"]
    receipt = {"resource": name, "id": info["Id"], "labels": info["Config"]["Labels"],
        "network_id": network["Id"], "internal": True, "volume": volume, "database": "section1_pipeline",
        "source_sha": subprocess.check_output(["git", "rev-parse", "HEAD"], cwd=ROOT, text=True).strip()}
    (evidence / "resource-identity.json").write_text(json.dumps(receipt, indent=2) + "\n")
    selector = "FullyQualifiedName~Section1PostgresPipelineTests"
    if not options.verify_restart:
        selector += "|FullyQualifiedName~Section1ExecutionPolicySnapshotTests|FullyQualifiedName~R03CapsProfileTests|FullyQualifiedName~Section1OperationAuthorityTests"
    stem = "restart" if options.verify_restart else "integration"
    command = ["dotnet", "test", str(ROOT / "services/exam-service.Tests/exam-service.Tests.csproj"),
        "--no-restore", "--filter", selector, "--logger", f"trx;LogFileName={evidence}/{stem}.trx"]
    with (evidence / (stem + ".log")).open("w") as log:
        result = subprocess.run(command, cwd=ROOT, env=environment, stdout=log, stderr=subprocess.STDOUT)
    print("Resource:", name)
    print("Evidence:", evidence)
    print("\n".join((evidence / (stem + ".log")).read_text().splitlines()[-12:]))
    return result.returncode


if __name__ == "__main__":
    sys.exit(main())
