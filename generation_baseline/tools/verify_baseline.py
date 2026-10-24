#!/usr/bin/env python3
"""Offline JSON contract/catalog checks; not a legacy documentation or campaign gate."""
from __future__ import annotations

import argparse
import json
from pathlib import Path

BASE = Path(__file__).resolve().parents[1]


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--json-out", type=Path, help="Optional report path; historical evidence is not overwritten by default.")
    args = parser.parse_args()
    issues: list[str] = []
    checks = 0

    def check(label: str, ok: bool) -> None:
        nonlocal checks
        checks += 1
        if not ok:
            issues.append(label)

    def load(path: str):
        return json.loads((BASE / path).read_text(encoding="utf-8"))

    schemas = load("contracts/JSON_SCHEMAS.json")
    check("schema 2020-12", schemas.get("$schema", "").endswith("2020-12/schema"))
    check("schema count >= 20", len(schemas.get("$defs", {})) >= 20)
    for name in ["GenerationRequest", "GenerationResult", "SolverView", "AnswerVerificationView",
                 "GoldReferenceView", "EvaluationResult", "ExperimentManifest", "StudentAttempt"]:
        check("defined schema " + name, name in schemas["$defs"])
    try:
        import jsonschema
        jsonschema.Draft202012Validator.check_schema(schemas)
        check("JSON Schema meta validation", True)
        examples = load("contracts/SCHEMA_EXAMPLES.json")

        def validator(definition: str):
            return jsonschema.Draft202012Validator({
                "$schema": schemas["$schema"], "$defs": schemas["$defs"], "$ref": "#/$defs/" + definition,
            })

        for name, definition in [("generation_result_valid", "GenerationResult"),
                                 ("solver_view_valid", "SolverView"), ("usage_unknown_valid", "UsageRecord")]:
            check("example " + name, validator(definition).is_valid(examples[name]))
        bad = dict(examples["solver_view_valid"], generator_proposed_answer="CANARY_SECRET")
        check("solver rejects proposed answer", not validator("SolverView").is_valid(bad))
    except ModuleNotFoundError:
        check("jsonschema dependency present", False)

    catalog = load("verification/TEST_CATALOG.json")["cases"]
    check("280 planned test cases", len(catalog) == 280)
    check("unique test IDs", len({x["test_id"] for x in catalog}) == len(catalog))
    check("all planned NOT_RUN", all(x["status"] == "NOT_RUN" for x in catalog))
    for phase in range(14):
        for sprint in range(1, 6):
            sid = f"RG{phase:02d}-S{sprint:02d}"
            check("4 test cases " + sid, sum(x["sprint"] == sid for x in catalog) == 4)

    report = {
        "package": "generation_baseline", "scope": "OFFLINE_JSON_CONTRACTS_ONLY",
        "checks": checks, "passed": checks - len(issues), "failed": len(issues), "failures": issues,
        "legacy_documentation_gate": "RETIRED", "source_repo_verified": False,
        "live_provider_tests": "NOT_RUN", "db_integration_tests": "NOT_RUN", "scientific_campaign": "NOT_RUN",
    }
    if args.json_out:
        args.json_out.parent.mkdir(parents=True, exist_ok=True)
        args.json_out.write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
    print(f"Offline JSON contract/catalog checks: {checks - len(issues)}/{checks} PASS (not campaign approval)")
    for issue in issues:
        print("FAIL:", issue)
    return 1 if issues else 0


if __name__ == "__main__":
    raise SystemExit(main())
