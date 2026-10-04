#!/usr/bin/env python3
"""Build/check prompt documents only; this never runs Langfens project tests."""

from __future__ import annotations

import argparse
from datetime import datetime, timezone
import hashlib
import json
from pathlib import Path
import re
import zipfile


CORE_FILES = [
    "00-START-HERE.md",
    "03-OUTPUT-AND-GATE-CONTRACT.md",
    "01-ORCHESTRATOR-PROMPT.md",
    "02-G07-G08-RECOVERY-PROMPT.md",
]
FINAL_FILE = "04-FINAL-VERIFICATION-PROMPT.md"
CONTRACT = "03-OUTPUT-AND-GATE-CONTRACT.md"


def digest(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def write_json(path: Path, value: object) -> None:
    path.write_text(json.dumps(value, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    default_pack = Path(__file__).resolve().parents[1]
    parser.add_argument("--pack-dir", type=Path, default=default_pack)
    parser.add_argument("--plan-dir", type=Path, default=default_pack.parent / "langfens-loop-engine-v2")
    parser.add_argument("--zip-path", type=Path)
    args = parser.parse_args()
    pack, plan = args.pack_dir.resolve(), args.plan_dir.resolve()
    manifest_path = plan / "verification/test-manifest.json"
    original = json.loads(manifest_path.read_text(encoding="utf-8"))
    findings: list[str] = []
    phase_checks: list[dict] = []
    source_paths: list[Path] = []
    all_ids: set[str] = set()

    for phase in original["phases"]:
        number = phase["phase"]
        relative = phase["plan_file"]
        source, spec = pack / relative, plan / relative
        if not source.is_file() or not spec.is_file():
            findings.append(f"Missing source/spec for phase {number}: {relative}")
            continue
        text = source.read_text(encoding="utf-8")
        blocks = re.findall(r"^```text\n(.*?)^```\s*$", text, re.MULTILINE | re.DOTALL)
        expected = set(phase["required_test_ids"])
        found = set(re.findall(r"T\d{2}-\d{2}", text))
        expected_packages = set(re.findall(r"P" + number + r"-\d{2}", spec.read_text(encoding="utf-8")))
        found_packages = set(re.findall(r"P" + number + r"-\d{2}", text))
        check = {
            "phase": number,
            "file": relative,
            "source_sha256": digest(source),
            "original_plan_sha256": digest(spec),
            "required_test_ids": sorted(expected),
            "missing_test_ids": sorted(expected - found),
            "unexpected_test_ids": sorted(found - expected),
            "prompt_blocks": len(blocks),
            "contract_reference_in_each_prompt": [CONTRACT in b for b in blocks],
            "original_work_packages": sorted(expected_packages),
            "missing_work_packages": sorted(expected_packages - found_packages),
        }
        phase_checks.append(check)
        all_ids.update(found)
        if (check["missing_test_ids"] or check["unexpected_test_ids"]
                or check["missing_work_packages"] or len(blocks) != 2
                or not all(check["contract_reference_in_each_prompt"])):
            findings.append(f"Phase {number} structural check failed")
        source_paths.append(source)

    if len(phase_checks) != 16 or len(all_ids) != 124:
        findings.append("Expected 16 phases and 124 distinct original test IDs")

    ordered = [pack / name for name in CORE_FILES] + source_paths + [pack / FINAL_FILE]
    for source in ordered:
        if not source.is_file():
            findings.append(f"Missing core source: {source.name}")
            continue
        text = source.read_text(encoding="utf-8")
        fence_count = len(re.findall(r"^```", text, re.MULTILINE))
        if fence_count % 2:
            findings.append(f"Unbalanced Markdown fences: {source.name}")
        for referenced in re.findall(r"`((?:\d{2}-)[A-Z][A-Z0-9-]*\.md)`", text):
            if not (pack / referenced).is_file():
                findings.append(f"Missing exact file reference {referenced} in {source.name}")

    reviewed = pack / "verification/independent-pack-review.md"
    if not reviewed.is_file():
        findings.append("Missing independent document review")
    if findings:
        print(json.dumps({"scope": "prompt_documents_only", "status": "FAIL", "findings": findings}, ensure_ascii=False, indent=2))
        return 1

    header = (
        "# Langfens — Toàn bộ prompt thực thi và verify V2\n\n"
        "Bản ghép đầy đủ từ 21 file nguồn: supervisor, recovery G07/G08, hợp đồng đầu ra, "
        "16 phases với 32 prompt thực hiện/verify và final verification. "
        "Cài cả pack cùng plan gốc trong repo trước khi dùng. Đọc phần START-HERE đầu tiên.\n\n"
        "Kiểm định đi kèm chỉ kiểm tra tài liệu prompt. Chưa chạy tests hoặc kết luận gates của repo Langfens.\n\n"
    )
    parts = [header]
    for source in ordered:
        relative = source.relative_to(pack).as_posix()
        parts.append(f"\n<!-- SOURCE: {relative} -->\n\n")
        parts.append(source.read_text(encoding="utf-8").rstrip() + "\n")
        parts.append(f"\n<!-- END SOURCE: {relative} -->\n")
    combined = pack / "PROMPTS-ALL.md"
    combined.write_text("".join(parts), encoding="utf-8")

    # Compare each embedded source verbatim to prevent an out-of-date combined file.
    merged = combined.read_text(encoding="utf-8")
    for source in ordered:
        relative = source.relative_to(pack).as_posix()
        start = f"<!-- SOURCE: {relative} -->\n\n"
        end = f"\n<!-- END SOURCE: {relative} -->"
        embedded = merged.split(start, 1)[1].split(end, 1)[0]
        if embedded != source.read_text(encoding="utf-8").rstrip() + "\n":
            raise RuntimeError(f"Combined source differs: {relative}")

    timestamp = datetime.now(timezone.utc).isoformat()
    qa = {
        "kind": "prompt_document_qa",
        "scope": "prompt_documents_only",
        "status": "PASS",
        "checked_at_utc": timestamp,
        "project_execution_verified": False,
        "actual_project_gate_results": "NOT_ASSESSED",
        "notice": "PASS ở đây chỉ là structural document QA; không phải G00-G15 PASS.",
        "original_manifest_sha256": digest(manifest_path),
        "phase_count": len(phase_checks),
        "phase_prompt_count": sum(x["prompt_blocks"] for x in phase_checks),
        "original_test_ids_preserved": len(all_ids),
        "original_work_packages_preserved": sum(len(x["original_work_packages"]) for x in phase_checks),
        "combined_source_count": len(ordered),
        "combined_source_sync": True,
        "combined_sha256": digest(combined),
        "independent_review_sha256": digest(reviewed),
        "phase_checks": phase_checks,
        "findings": findings,
    }
    write_json(pack / "verification/document-qa.json", qa)

    # No self-hash: the package manifest lists all other files.
    file_manifest = pack / "package-manifest.json"
    entries = [{"path": p.relative_to(pack).as_posix(), "bytes": p.stat().st_size, "sha256": digest(p)}
               for p in sorted(pack.rglob("*")) if p.is_file() and p != file_manifest]
    write_json(file_manifest, {
        "kind": "prompt_pack_manifest", "version": "2.0", "created_at_utc": timestamp,
        "scope": "prompt_documents_only", "project_execution_verified": False,
        "phase_count": 16, "phase_prompt_count": 32, "original_test_ids": 124,
        "files": entries,
    })

    archive_info = None
    if args.zip_path:
        archive = args.zip_path.resolve()
        if archive.is_relative_to(pack):
            raise ValueError("Keep archive outside the source pack")
        archive.parent.mkdir(parents=True, exist_ok=True)
        members = [p for p in sorted(pack.rglob("*")) if p.is_file()]
        with zipfile.ZipFile(archive, "w", zipfile.ZIP_DEFLATED) as z:
            for path in members:
                z.write(path, arcname=f"{pack.name}/{path.relative_to(pack).as_posix()}")
        with zipfile.ZipFile(archive) as z:
            if z.testzip() is not None:
                raise RuntimeError("Archive CRC check failed")
            for path in members:
                name = f"{pack.name}/{path.relative_to(pack).as_posix()}"
                if hashlib.sha256(z.read(name)).hexdigest() != digest(path):
                    raise RuntimeError(f"Archive source differs: {name}")
        archive_info = {"path": str(archive), "bytes": archive.stat().st_size, "sha256": digest(archive), "members_verified": len(members)}

    print(json.dumps({
        "scope": "prompt_documents_only", "status": "PASS", "phase_count": 16,
        "phase_prompt_count": 32, "original_test_ids_preserved": 124,
        "original_work_packages_preserved": qa["original_work_packages_preserved"],
        "combined_source_sync": True, "combined_bytes": combined.stat().st_size,
        "project_execution_verified": False, "archive": archive_info,
    }, ensure_ascii=False, indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
